--------------------------------------------------------
--  DDL for Procedure TEMPADVFACCREDITCARDDETAIL_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" 
AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --GO
   /*********************************************************************************************************/
   /*  New Customers Account Entity ID Update  */
   v_CreditCardEntityId NUMBER(10,0) := 0;

BEGIN

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --------------------------------------------------------------------------------------------------------------------------------------------------- 
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempAdvFacCreditCardDetail ';
   INSERT INTO RBL_TEMPDB.TempAdvFacCreditCardDetail
     ( EntityKey, AccountEntityId, CreditCardEntityId, CorporateUCIC_ID, CorporateCustomerID, Liability, MinimumAmountDue, CD, Bucket, DPD, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, ISChanged, AccountStatus, AccountBlkCode2, AccountBlkCode1, ChargeoffY_N )
     ( SELECT DISTINCT NULL EntityKey  ,
                       B.AccountEntityId ,
                       NULL CreditCardEntityId  ,
                       A.CorporateUCICID CorporateUCIC_ID  ,
                       A.CorporateCustomerID CorporateCustomerID  ,
                       A.Liability ,
                       NULL MinimumAmountDue  ,
                       A.CD ,
                       A.Bucket ,
                       A.DPD ,
                       B.SystemACID RefSystemAcId  ,
                       NULL AuthorisationStatus  ,
                       B.EffectiveFromTimeKey EffectiveFromTimeKey  ,
                       B.EffectiveToTimeKey EffectiveToTimeKey  ,
                       B.CreatedBy CreatedBy  ,
                       SYSDATE DateCreated  ,
                       NULL ModifiedBy  ,
                       NULL DateModified  ,
                       NULL ApprovedBy  ,
                       NULL DateApproved  ,
                       NULL D2Ktimestamp  ,
                       NULL MocStatus  ,
                       NULL MocDate  ,
                       'U' ISChanged  ,
                       A.AccountStatus ,
                       A.AccountBlkCode2 ,
                       A.AccountBlkCode1 ,
                       ChargeoffY_N 
       FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM06_STG A
              JOIN RBL_TEMPDB.TempAdvAcBasicDetail B   ON A.CustomerAcID = B.CustomerACID

       -------AND A.CUSTOMERACID='0005239504502474490'
       WHERE  NVL(CHARGEOFFY_n, 'N') <> 'Y' );
   /*********************************************************************************************************/
   /*  Existing Customers Account Entity ID Update  */
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, MAIN.CreditCardEntityId
   FROM TEMP ,RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
          JOIN RBL_MISDB_010922_UAT.AdvFacCreditCardDetail MAIN   ON TEMP.RefSystemAcId = MAIN.RefSystemAcId 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CreditCardEntityId = src.CreditCardEntityId;
   SELECT MAX(CreditCardEntityId)  

     INTO v_CreditCardEntityId
     FROM RBL_MISDB_010922_UAT.AdvFacCreditCardDetail ;
   IF v_CreditCardEntityId IS NULL THEN

   BEGIN
      v_CreditCardEntityId := 0 ;

   END;
   END IF;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, ACCT.CreditCardEntityId
   FROM TEMP ,RBL_TEMPDB.TempAdvFacCreditCardDetail TEMP
          JOIN ( SELECT "TEMPADVFACCREDITCARDDETAIL".RefSystemAcId ,
                        (v_CreditCardEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                 FROM DUAL  )  )) CreditCardEntityId  
                 FROM RBL_TEMPDB.TempAdvFacCreditCardDetail 
                  WHERE  "TEMPADVFACCREDITCARDDETAIL".CreditCardEntityId = 0
                           OR "TEMPADVFACCREDITCARDDETAIL".CreditCardEntityId IS NULL ) ACCT   ON TEMP.RefSystemAcId = ACCT.RefSystemAcId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CreditCardEntityId = src.CreditCardEntityId;/*********************************************************************************************************/
   ----------------------------------------------------Added by Amar Sir Dated 12-10-2022----------------------------------------------------------
   ??????SET A . AccountBlkCode2 = 'K' ????? FROM RBL_TEMPDB . DBO . TempAdvFacCreditCardDetail a INNER JOIN RBL_MISDB_010922_UAT . DBO . AdvFacCreditCardDetail b ??????ON B . EffectiveToTimeKey = 49999 ??????AND A . AccountEntityId = B . AccountEntityId WHERE  --SQLDEV: NOT RECOGNIZED
   --------------------------------------------------------------------------------------------------------------------
   WHERE ( A . AccountBlkCode2 , ' ' ) <> 'K' ??????AND B . AccountBlkCode2 = 'K'  --SQLDEV: NOT RECOGNIZED

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."TEMPADVFACCREDITCARDDETAIL_NEWDB" TO "ADF_CDR_RBL_STGDB";
