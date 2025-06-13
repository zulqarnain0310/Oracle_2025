--------------------------------------------------------
--  DDL for Procedure ADVFACCCDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   /*  New Customers EntityKey ID Update  */
   v_EntityKey NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvFacCCDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvFacCCDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.ADVFACCCDETAIL B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.ADVFACCCDETAIL O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.ADVFACCCDETAIL O
          JOIN RBL_TEMPDB.TempAdvFacCCDetail T   ON O.AccountEntityID = T.AccountEntityID

          --AND O.SourceAlt_Key=T.SourceAlt_Key
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.AdhocDt, '1900-01-01') <> NVL(T.AdhocDt, '1900-01-01')
     OR NVL(O.AdhocAmt, 0) <> NVL(T.AdhocAmt, 0)
     OR NVL(O.ContExcsSinceDt, '1900-01-01') <> NVL(T.ContExcsSinceDt, '1900-01-01')

     --OR ISNULL(O.MarginAmt,0)<>ISNULL(T.MarginAmt,0)
     OR NVL(O.DerecognisedInterest1, 0) <> NVL(T.DerecognisedInterest1, 0)
     OR NVL(O.DerecognisedInterest2, 0) <> NVL(T.DerecognisedInterest2, 0)

     --OR ISNULL(O.AdjReasonAlt_Key,0)<>ISNULL(T.AdjReasonAlt_Key,0)

     --OR ISNULL(O.EntityClosureDate,'1900-01-01')<>ISNULL(T.EntityClosureDate,'1900-01-01')

     --OR ISNULL(O.EntityClosureReasonAlt_Key,0)<>ISNULL(T.EntityClosureReasonAlt_Key,0)
     OR NVL(O.ClaimType, 'AA') <> NVL(T.ClaimType, 'AA')
     OR NVL(O.ClaimCoverAmt, 0) <> NVL(T.ClaimCoverAmt, 0)
     OR NVL(O.ClaimLodgedDt, '1900-01-01') <> NVL(T.ClaimLodgedDt, '1900-01-01')
     OR NVL(O.ClaimLodgedAmt, 0) <> NVL(T.ClaimLodgedAmt, 0)
     OR NVL(O.ClaimRecvDt, '1900-01-01') <> NVL(T.ClaimRecvDt, '1900-01-01')
     OR NVL(O.ClaimReceivedAmt, 0) <> NVL(T.ClaimReceivedAmt, 0)
     OR NVL(O.ClaimRate, 0) <> NVL(T.ClaimRate, 0)
     OR NVL(O.RefSystemAcid, 0) <> NVL(T.RefSystemAcid, 0)
     OR NVL(O.StockStmtDt, '1900-01-01') <> NVL(T.StockStmtDt, '1900-01-01') )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvFacCCDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvFacCCDetail A
          JOIN RBL_MISDB_PROD.ADVFACCCDETAIL B   ON B.AccountEntityId = A.AccountEntityId --And A.SourceAlt_Key=B.SourceAlt_Key

    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.ADVFACCCDETAIL AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.ADVFACCCDETAIL AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvFacCCDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID --And AA.SourceAlt_Key=BB.SourceAlt_Key

                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.ADVFACCCDETAIL ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacCCDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvFacCCDetail TEMP
          JOIN ( SELECT "TEMPADVFACCCDETAIL".AccountEntityId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvFacCCDetail 
                  WHERE  "TEMPADVFACCCDETAIL".EntityKey = 0
                           OR "TEMPADVFACCCDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   ------------------------------
   INSERT INTO RBL_MISDB_PROD.ADVFACCCDETAIL
     ( ENTITYKEY, AccountEntityId, AdhocDt, AdhocAmt, ContExcsSinceDt, DerecognisedInterest1, DerecognisedInterest2, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, AdhocExpiryDate, StockStmtDt )
     ( SELECT ENTITYKEY ,
              AccountEntityId ,
              AdhocDt ,
              AdhocAmt ,
              ContExcsSinceDt ,
              DerecognisedInterest1 ,
              DerecognisedInterest2 ,
              ClaimType ,
              ClaimCoverAmt ,
              ClaimLodgedDt ,
              ClaimLodgedAmt ,
              ClaimRecvDt ,
              ClaimReceivedAmt ,
              ClaimRate ,
              RefSystemAcid ,
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
              MocStatus ,
              MocDate ,
              MocTypeAlt_Key ,
              AdhocExpiryDate ,
              StockStmtDt 
       FROM RBL_TEMPDB.TempAdvFacCCDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACCCDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
