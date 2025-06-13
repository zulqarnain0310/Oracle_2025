--------------------------------------------------------
--  DDL for Procedure LASTCREDITDTACCOUNTCALUPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" /*==============================================
 AUTHER : TRILOKI SHANKER KHANNA
 CREATE DATE : 05-03-2021
 MODIFY DATE : 05-03-2021
 DESCRIPTION : INSERT DATA PRO.LastCreditDtAccountCal_BKUP
 --EXEC PRO.LastCreditDtAccountCalUpdate

 ================================================*/
AS
   v_Date VARCHAR2(200) ;
   v_EffectiveFrom NUMBER(10,0) ;
   v_TimeKey NUMBER(10,0) ;

BEGIN

   SELECT Date_ INTO v_Date 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;
   SELECT Timekey INTO v_EffectiveFrom 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;
   SELECT Timekey INTO v_TimeKey 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   IF utils.object_id('TempDB..GTT_CREDIT') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_CREDIT ';
   END IF;
   DELETE FROM GTT_CREDIT;
   UTILS.IDENTITY_RESET('GTT_CREDIT');

   INSERT INTO GTT_CREDIT ( 
   	SELECT * 
   	  FROM ( SELECT CustomerAcID ,
                    AccountEntityId ,
                    TxnDate ,
                    SUM(TxnAmount)  TxnAmount  
             FROM RBL_MISDB_PROD.AcDailyTxnDetail 
              WHERE  TxnDate = v_Date
                       AND TxnType = 'CREDIT'

             --And AccountEntityId In (1542689,359483,424133,2418688,550975,1635798)
             GROUP BY CustomerAcID,AccountEntityId,TxnDate ) A );
   IF utils.object_id('TempDB..GTT_ACCOUNTBAL') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_ACCOUNTBAL ';
   END IF;
   DELETE FROM GTT_ACCOUNTBAL;
   UTILS.IDENTITY_RESET('GTT_ACCOUNTBAL');

   INSERT INTO GTT_ACCOUNTBAL ( 
   	SELECT A.AccountEntityId ,
           C.CustomerAcID ,
           A.Balance 
   	  FROM RBL_MISDB_PROD.AdvAcBalanceDetail A
             JOIN GTT_CREDIT C   ON A.AccountEntityId = C.AccountEntityId
   	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
              AND A.EffectiveToTimeKey >= v_TimeKey );
   INSERT INTO MAIN_PRO.LastCreditDtAccountCal_BKUP
     ( CustomerAcID, AccountEntityId, LastCrDate, LasttoLastCrDate, CreditAmt, DebitAmt, STATUS, Credit_Flg, Acc_SrNo, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( 
       ------New
       SELECT Credit.CustomerAcID ,
              Credit.AccountEntityId ,
              Credit.TxnDate LastCrDate  ,
              NULL LasttoLastCrDate  ,
              Credit.TxnAmount CreditAmt  ,
              NULL DebitAmt  ,
              'C' STATUS  ,
              'C' CREDIT_FLG  ,
              1 Acc_Sr_No  ,
              v_EffectiveFrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  
       FROM MAIN_PRO.LastCreditDtAccountCal_BKUP CR
              RIGHT JOIN GTT_CREDIT Credit   ON Credit.AccountEntityId = CR.AccountEntityId
              AND CR.Status = 'C'

       --INNER JOIN (SELECT AccountEntityId,CustomerAcID,MAX(ISNULL(Acc_SrNo,0)) Acc_SrNo

       --            FROM  PRO.LastCreditDtAccountCal_BKUP

       --            GROUP BY AccountEntityId,CustomerAcID) MAXSr ON MAXSr.AccountEntityId=Cr.AccountEntityId
       WHERE  CR.CustomerAcID IS NULL
       UNION 

       ------------Old
       SELECT CR.CustomerAcID ,
              CR.AccountEntityId ,
              Credit.TxnDate LastCrDate  ,
              CR.LastCrDate LasttoLastCrDate  ,
              Credit.TxnAmount CreditAmt  ,
              CR.DebitAmt DebitAmt  ,
              'C' STATUS  ,
              'C' CREDIT_FLG  ,
              MAXSr.Acc_SrNo + 1 Acc_SrNo  ,
              v_EffectiveFrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  
       FROM MAIN_PRO.LastCreditDtAccountCal_BKUP CR
              JOIN GTT_CREDIT Credit   ON CR.AccountEntityId = Credit.AccountEntityId
              JOIN ( SELECT AccountEntityId ,
                            CustomerAcID ,
                            MAX(NVL(Acc_SrNo, 0))  Acc_SrNo  
                     FROM MAIN_PRO.LastCreditDtAccountCal_BKUP 
                       GROUP BY AccountEntityId,CustomerAcID ) MAXSr   ON MAXSr.AccountEntityId = Cr.AccountEntityId
        WHERE  STATUS = 'C' );
   --------------------------------------------------------------------
   ---------Previous record Expire
   IF utils.object_id('TempDB..tt_AccountCount') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCount ';
   END IF;
   DELETE FROM tt_AccountCount;
   UTILS.IDENTITY_RESET('tt_AccountCount');

   INSERT INTO tt_AccountCount ( 
   	SELECT CustomerAcID ,
           AccountEntityId ,
           COUNT(*)  Cnt  
   	  FROM MAIN_PRO.LastCreditDtAccountCal_BKUP 
   	 WHERE  STATUS = 'C'
   	  GROUP BY CustomerAcID,AccountEntityId

   	   HAVING COUNT(*)  > 1 );
   MERGE INTO MAIN_PRO.LastCreditDtAccountCal_BKUP CR
   USING (SELECT Cr.ROWID row_id, 'E', v_TimeKey - 1 AS pos_3
   FROM MAIN_PRO.LastCreditDtAccountCal_BKUP CR
          JOIN ( SELECT LastCreditDtAccountCal_BKUP.CustomerAcID ,
                        LastCreditDtAccountCal_BKUP.AccountEntityId ,
                        MIN(LastCreditDtAccountCal_BKUP.Acc_SrNo)  Acc_SrNo  
                 FROM MAIN_PRO.LastCreditDtAccountCal_BKUP 
                  WHERE  LastCreditDtAccountCal_BKUP.STATUS = 'C'
                   GROUP BY LastCreditDtAccountCal_BKUP.CustomerAcID,LastCreditDtAccountCal_BKUP.AccountEntityId ) MINCr   ON Cr.AccountEntityId = MINCr.AccountEntityId
          AND Cr.Acc_SrNo = MINCr.Acc_SrNo
          JOIN tt_AccountCount A   ON A.AccountEntityId = CR.AccountEntityId 
    WHERE CR.EffectiveFromTimeKey <> v_EffectiveFrom) src
   ON ( Cr.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET STATUS = 'E',
                                EffectiveToTimeKey = pos_3;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."LASTCREDITDTACCOUNTCALUPDATE" TO "ADF_CDR_RBL_STGDB";
