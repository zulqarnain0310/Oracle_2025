--------------------------------------------------------
--  DDL for Procedure ADVACFINANCIALDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   -------------------------------
   /*  New Customers EntityKey ID Update  */
   v_EntityKey NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvAcFinancialDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvAcFinancialDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvAcFinancialDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';
   /*update date from main table */
   MERGE INTO RBL_TEMPDB.TempAdvAcFinancialDetail T
   USING (SELECT T.ROWID row_id, bAl.NpaDt
   FROM RBL_TEMPDB.TempAdvAcFinancialDetail T
          JOIN RBL_MISDB_PROD.AdvAcFinancialDetail bal   ON ( bAl.EffectiveToTimeKey = 49999 )
          AND t.AccountEntityId = bal.AccountEntityId 
    WHERE ( NVL(T.NpaDt, '1900-01-01') <> NVL(bal.NpaDt, '1900-01-01') )) src
   ON ( T.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET T.NpaDt = src.NpaDt;
   --------------------------------------------------------------------------------
   MERGE INTO RBL_MISDB_PROD.AdvAcFinancialDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvAcFinancialDetail O
          JOIN RBL_TEMPDB.TempAdvAcFinancialDetail T   ON O.AccountEntityID = T.AccountEntityID
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.Ac_LastReviewDueDt, '1990-01-01') <> NVL(T.Ac_LastReviewDueDt, '1990-01-01')
     OR NVL(O.Ac_ReviewTypeAlt_key, 0) <> NVL(T.Ac_ReviewTypeAlt_key, 0)
     OR NVL(O.Ac_ReviewDt, '1990-01-01') <> NVL(T.Ac_ReviewDt, '1990-01-01')
     OR NVL(O.Ac_ReviewAuthAlt_Key, 0) <> NVL(T.Ac_ReviewAuthAlt_Key, 0)
     OR NVL(O.Ac_NextReviewDueDt, '1990-01-01') <> NVL(T.Ac_NextReviewDueDt, '1990-01-01')
     OR NVL(O.DrawingPower, 0) <> NVL(T.DrawingPower, 0)
     OR NVL(O.InttRate, 0) <> NVL(T.InttRate, 0)
     OR NVL(O.UnAdjSubSidy, 0) <> NVL(T.UnAdjSubSidy, 0)
     OR NVL(O.LastInttRealiseDt, '1990-01-01') <> NVL(T.LastInttRealiseDt, '1990-01-01')
     OR NVL(O.LimitDisbursed, 0) <> NVL(T.LimitDisbursed, 0)
     OR NVL(O.CropDuration, 0) <> NVL(T.CropDuration, 0)
     OR NVL(O.RefCustomerId, 'AA') <> NVL(T.RefCustomerId, 'AA') )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   --OR ISNULL(O.Interest_due,0)						<> ISNULL(T.Interest_due,0)
   --OR ISNULL(O.other_dues,0)						<> ISNULL(T.other_dues,0)
   --OR ISNULL(O.penal_due,0)						<> ISNULL(T.penal_due,0)
   --OR ISNULL(O.int_receivable_adv,0)						<> ISNULL(T.int_receivable_adv,0)
   --OR ISNULL(O.penal_int_receivable,0)						<> ISNULL(T.penal_int_receivable,0)
   --OR ISNULL(O.Accrued_interest,0)						<> ISNULL(T.Accrued_interest,0)
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvAcFinancialDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvAcFinancialDetail A
          JOIN RBL_MISDB_PROD.AdvAcFinancialDetail B   ON B.AccountEntityId = A.AccountEntityId --And A.SourceAlt_Key=B.SourceAlt_Key

    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvAcFinancialDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvAcFinancialDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvAcFinancialDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID --And AA.SourceAlt_Key=BB.SourceAlt_Key

                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvAcFinancialDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvAcFinancialDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvAcFinancialDetail TEMP
          JOIN ( SELECT "TEMPADVACFINANCIALDETAIL".AccountEntityId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvAcFinancialDetail 
                  WHERE  "TEMPADVACFINANCIALDETAIL".EntityKey = 0
                           OR "TEMPADVACFINANCIALDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   ------------------------------
   INSERT INTO RBL_MISDB_PROD.AdvAcFinancialDetail
     ( ENTITYKEY, AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate, NpaDt, BookDebts, UnDrawnAmt, UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason, LimitDisbursed, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key
   -- ,Interest_due
    --,other_dues
    --,penal_due
    --,int_receivable_adv
    --,penal_int_receivable
    --,Accrued_interest
   , AccountBlkCode2 )
     ( SELECT ENTITYKEY ,
              AccountEntityId ,
              Ac_LastReviewDueDt ,
              Ac_ReviewTypeAlt_key ,
              Ac_ReviewDt ,
              Ac_ReviewAuthAlt_Key ,
              Ac_NextReviewDueDt ,
              DrawingPower ,
              InttRate ,
              NpaDt ,
              BookDebts ,
              UnDrawnAmt ,
              UnAdjSubSidy ,
              LastInttRealiseDt ,
              MocStatus ,
              MOCReason ,
              LimitDisbursed ,
              RefCustomerId ,
              RefSystemAcId ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              SYSDATE D2Ktimestamp  ,
              MocDate ,
              MocTypeAlt_Key ,
              CropDuration ,
              Ac_ReviewAuthLevelAlt_Key ,
              -- ,Interest_due
              --,other_dues
              --,penal_due
              --,int_receivable_adv
              --,penal_int_receivable
              -- ,Accrued_interest
              AccountBlkCode2 
       FROM RBL_TEMPDB.TempAdvAcFinancialDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);

END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACFINANCIALDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
