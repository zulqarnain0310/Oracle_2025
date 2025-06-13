--------------------------------------------------------
--  DDL for Procedure ADVCUSTNPADETAIL_MAIN_LATER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" 
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
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvCustNPADetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvCustNPADetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvCustNPADetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerEntityId = A.CustomerEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvCustNPADetail A
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvCustNPADetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvCustNPADetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerEntityId = A.CustomerEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.AdvCustNPADetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvCustNPADetail O
          JOIN RBL_TEMPDB.TempAdvCustNPADetail T   ON O.CustomerEntityId = T.CustomerEntityId

          --AND O.SourceAlt_Key=T.SourceAlt_Key
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.Cust_AssetClassAlt_Key, 0) <> NVL(T.Cust_AssetClassAlt_Key, 0)
     OR NVL(O.NPADt, '1990-01-01') <> NVL(T.NPADt, '1990-01-01')
     OR NVL(O.LastInttChargedDt, '1990-01-01') <> NVL(T.LastInttChargedDt, '1990-01-01')
     OR NVL(O.LosDt, '1990-01-01') <> NVL(T.LosDt, '1990-01-01')
     OR NVL(O.DbtDt, '1990-01-01') <> NVL(T.DbtDt, '1990-01-01')
     OR NVL(O.DefaultReason1Alt_Key, 0) <> NVL(T.DefaultReason1Alt_Key, 0)
     OR NVL(O.DefaultReason2Alt_Key, 0) <> NVL(T.DefaultReason2Alt_Key, 0)
     OR NVL(O.StaffAccountability, 0) <> NVL(T.StaffAccountability, 0)
     OR NVL(O.LastIntBooked, '1990-01-01') <> NVL(T.LastIntBooked, '1990-01-01')
     OR NVL(O.RefCustomerID, 0) <> NVL(T.RefCustomerID, 0)
     OR NVL(O.MocStatus, 0) <> NVL(T.MocStatus, 0)
     OR NVL(O.MocDate, '1990-01-01') <> NVL(T.MocDate, '1990-01-01')
     OR NVL(O.MocTypeAlt_Key, 0) <> NVL(T.MocTypeAlt_Key, 0)
     OR NVL(O.NPA_Reason, 0) <> NVL(T.NPA_Reason, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvCustNPADetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvCustNPADetail A
          JOIN RBL_MISDB_PROD.AdvCustNPADetail B   ON B.CustomerEntityId = A.CustomerEntityId 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvCustNPADetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvCustNPADetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvCustNPADetail BB
                       WHERE  AA.CustomerEntityId = BB.CustomerEntityId
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvCustNPADetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvCustNPADetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvCustNPADetail TEMP
          JOIN ( SELECT "TEMPADVCUSTNPADETAIL".CustomerEntityId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvCustNPADetail 
                  WHERE  "TEMPADVCUSTNPADETAIL".EntityKey = 0
                           OR "TEMPADVCUSTNPADETAIL".EntityKey IS NULL ) ACCT   ON TEMP.CustomerEntityId = ACCT.CustomerEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   INSERT INTO RBL_MISDB_PROD.AdvCustNPADetail
     ( ENTITYKEY, CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, NPA_Reason )
     ( SELECT ENTITYKEY ,
              CustomerEntityId ,
              Cust_AssetClassAlt_Key ,
              NPADt ,
              LastInttChargedDt ,
              DbtDt ,
              LosDt ,
              DefaultReason1Alt_Key ,
              DefaultReason2Alt_Key ,
              StaffAccountability ,
              LastIntBooked ,
              RefCustomerID ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              D2Ktimestamp ,
              MocStatus ,
              MocDate ,
              MocTypeAlt_Key ,
              NPA_Reason 
       FROM RBL_TEMPDB.TempAdvCustNPADetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTNPADETAIL_MAIN_LATER" TO "ADF_CDR_RBL_STGDB";
