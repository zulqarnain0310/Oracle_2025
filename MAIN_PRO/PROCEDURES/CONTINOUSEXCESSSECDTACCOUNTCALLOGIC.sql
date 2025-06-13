--------------------------------------------------------
--  DDL for Procedure CONTINOUSEXCESSSECDTACCOUNTCALLOGIC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" /*==============================================
 AUTHER : TRILOKI SHANKER KHANNA
 CREATE DATE : 22-02-2021
 MODIFY DATE : 22-02-2021
 DESCRIPTION : INSERT DATA PRO.ContinousExcessSecDtAccountCalLogic
 EXEC PRO.ContinousExcessSecDtAccountCalLogic
  TRUNCATE TABLE  PRO.CONTINOUSEXCESSSECDTACCOUNTCAL
 ================================================*/
AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;

BEGIN

SELECT Date_ INTO v_DATE
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   IF utils.object_id('TEMPDB..GTT_ContinousExcessSecDtAcco') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_ContinousExcessSecDtAcco ';
   END IF;
   DELETE FROM GTT_ContinousExcessSecDtAcco;
   UTILS.IDENTITY_RESET('GTT_ContinousExcessSecDtAcco');

   INSERT INTO GTT_ContinousExcessSecDtAcco ( 
   	SELECT CustomerAcID 
   	  FROM Gtt_AccountCal A
             JOIN ( SELECT C.AccountEntityID ,
                           SUM(NVL(CurrentValue, 0))  CurrentValue  
                    FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B
                           JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail Advsec   ON Advsec.SecurityEntityID = b.SecurityEntityID
                           JOIN GTT_AccountCal C   ON Advsec.AccountEntityID = C.AccountEntityID
                           AND Advsec.SecurityAlt_Key = Advsec.SecurityAlt_Key
                           AND Advsec.EffectiveFromTimeKey <= v_TimeKey
                           AND Advsec.EffectiveToTimeKey >= v_TimeKey
                           JOIN RBL_MISDB_PROD.DimSecurity D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                           AND D.EffectiveToTimeKey >= v_TIMEKEY
                           AND D.SecurityAlt_Key = Advsec.SecurityAlt_Key
                     WHERE  Advsec.SecurityType = 'P'

                              --AND ISNULL(D.SecurityShortNameEnum,'') IN('PLD-NSC','PLD-KVP','PLD-G SEC','ASGN-LIFE POL','LI-FDR','LI-FDRSUBSI','LI-NRE DEP'

                              --    ,'LI-NRNR DEP','LI-FCNR-DEP','LI-RD-DEP','DEPNFBR')	
                              AND D.SecurityCRM = 'Y'

                    --		and ISNULL(C.Asset_Norm,'NORMAL')='CONDI_STD'		
                    GROUP BY C.AccountEntityID ) E   ON A.AccountEntityID = E.AccountEntityID
             AND NVL(A.Balance, 0) > 0
             AND NVL(A.Balance, 0) > NVL(A.SecurityValue, 0)
   	MINUS 
   	SELECT CustomerAcID 
   	  FROM MAIN_PRO.ContinousExcessSecDtAccountCal 
   	 WHERE  Effectivetotimekey = 49999 );
   INSERT INTO MAIN_PRO.ContinousExcessSecDtAccountCal
     ( CustomerAcID, AccountEntityId, Balance, SecurityValue, ContinousExcessSecDt, EffectiveFromTimeKey, EffectiveToTimeKey )
     ( SELECT B.CustomerAcID CustomerAcID  ,
              B.AccountEntityId AccountEntityId  ,
              B.Balance Balance  ,
              B.SecurityValue SecurityValue  ,
              v_DATE ContinousExcessSecDt  ,
              v_TimeKey EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  
       FROM GTT_ContinousExcessSecDtAcco A
              JOIN Gtt_AccountCal B   ON A.CustomerACID = B.CustomerACID );
   IF utils.object_id('TEMPDB..tt_ContinousExcessSecDtAccoEXP') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_ContinousExcessSecDtAcco ';
   END IF;
   DELETE FROM GTT_ContinousExcessSecDtAcco;
   UTILS.IDENTITY_RESET('GTT_ContinousExcessSecDtAcco');

   INSERT INTO GTT_ContinousExcessSecDtAcco ( 
   	SELECT CustomerAcID 
   	  FROM Gtt_AccountCal A
             JOIN ( SELECT C.AccountEntityID ,
                           SUM(NVL(CurrentValue, 0))  CurrentValue  
                    FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B
                           JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail Advsec   ON Advsec.SecurityEntityID = b.SecurityEntityID
                           JOIN Gtt_AccountCal C   ON Advsec.AccountEntityID = C.AccountEntityID
                           AND Advsec.SecurityAlt_Key = Advsec.SecurityAlt_Key
                           AND Advsec.EffectiveFromTimeKey <= v_TimeKey
                           AND Advsec.EffectiveToTimeKey >= v_TimeKey
                           JOIN RBL_MISDB_PROD.DimSecurity D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                           AND D.EffectiveToTimeKey >= v_TIMEKEY
                           AND D.SecurityAlt_Key = Advsec.SecurityAlt_Key
                     WHERE  Advsec.SecurityType = 'P'

                              --AND ISNULL(D.SecurityShortNameEnum,'') IN('PLD-NSC','PLD-KVP','PLD-G SEC','ASGN-LIFE POL','LI-FDR','LI-FDRSUBSI','LI-NRE DEP'

                              --    ,'LI-NRNR DEP','LI-FCNR-DEP','LI-RD-DEP','DEPNFBR')	
                              AND D.SecurityCRM = 'Y'

                    --		and ISNULL(C.Asset_Norm,'NORMAL')='CONDI_STD'		
                    GROUP BY C.AccountEntityID ) E   ON A.AccountEntityID = E.AccountEntityID
             AND NVL(A.Balance, 0) > 0
             AND NVL(A.Balance, 0) > NVL(A.SecurityValue, 0) );
   /*------EXPIRE DATA FOR ---------------------*/
   MERGE INTO MAIN_PRO.ContinousExcessSecDtAccountCal A
   USING (SELECT A.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimekey
   FROM MAIN_PRO.ContinousExcessSecDtAccountCal A
          LEFT JOIN ( SELECT A.CustomerAcID 
                      FROM MAIN_PRO.ContinousExcessSecDtAccountCal a
                             JOIN GTT_ContinousExcessSecDtAcco b   ON a.CustomerAcID = b.CustomerAcID ) C   ON A.CustomerAcID = C.CustomerAcID 
    WHERE C.CustomerAcID IS NULL
     AND A.EffectiveToTimeKey = 49999) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.EffectiveToTimekey = src.EffectiveToTimekey;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_ContinousExcessSecDtAcco ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_ContinousExcessSecDtAcco ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CONTINOUSEXCESSSECDTACCOUNTCALLOGIC" TO "ADF_CDR_RBL_STGDB";
