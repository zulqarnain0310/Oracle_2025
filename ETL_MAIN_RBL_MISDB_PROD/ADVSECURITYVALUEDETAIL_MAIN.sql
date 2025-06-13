--------------------------------------------------------
--  DDL for Procedure ADVSECURITYVALUEDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" 
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
   MERGE INTO RBL_TEMPDB.TempAdvSecurityValueDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvSecurityValueDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvSecurityValueDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND A.SecurityEntityID = B.SecurityEntityID )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';
   MERGE INTO RBL_MISDB_PROD.AdvSecurityValueDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvSecurityValueDetail O
          JOIN RBL_TEMPDB.TempAdvSecurityValueDetail T   ON O.SecurityEntityID = T.SecurityEntityID
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(o.ValuationSourceAlt_Key, 0) <> NVL(T.ValuationSourceAlt_Key, 0)
     OR NVL(o.ValuationDate, '1990-01-01') <> NVL(T.ValuationDate, '1990-01-01')
     OR NVL(o.CurrentValue, 0) <> NVL(T.CurrentValue, 0)
     OR NVL(o.ValuationExpiryDate, '1990-01-01') <> NVL(T.ValuationExpiryDate, '1990-01-01')
     OR NVL(o.SecurityValueMain, 0) <> NVL(T.SecurityValueMain, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   --OR ISNULL(o.SecurityValueErosion,0) <> ISNULL(T.SecurityValueErosion,0) 
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvSecurityValueDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvSecurityValueDetail A
          JOIN RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.SecurityEntityID = B.SecurityEntityID 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvSecurityValueDetail AA
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvSecurityValueDetail AA
          JOIN RBL_MISDB_PROD.AdvSecurityDetail CC   ON AA.SecurityEntityID = CC.SecurityEntityID
          AND AA.EffectiveFromTimeKey = CC.EffectiveFromTimeKey
          JOIN RBL_TEMPDB.TempAdvAcBasicDetail BB   ON CC.AccountEntityId = BB.ACCOUNTENTITYID 
    WHERE AA.EffectiveToTimeKey = 49999
     AND BB.SourceAlt_Key = 4
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvSecurityValueDetail BB
                       WHERE  AA.SecurityEntityID = BB.SecurityEntityID
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvSecurityValueDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvSecurityValueDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvSecurityValueDetail TEMP
          JOIN ( SELECT "TEMPADVSECURITYVALUEDETAIL".COLLATERALID ,
                        "TEMPADVSECURITYVALUEDETAIL".SecurityEntityID ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvSecurityValueDetail 
                  WHERE  "TEMPADVSECURITYVALUEDETAIL".EntityKey = 0
                           OR "TEMPADVSECURITYVALUEDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.SecurityEntityID = ACCT.SecurityEntityID
          AND TEMP.COLLATERALID = ACCT.COLLATERALID 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   ------------------------------
   INSERT INTO RBL_MISDB_PROD.AdvSecurityValueDetail
     ( ENTITYKEY, SecurityEntityID, ValuationSourceAlt_Key, ValuationDate, CurrentValue, ValuationExpiryDate
   --,[CollateralID]
   , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, CurrentValueSource, CollateralValueatthetimeoflastreviewinRs, CollateralID, ExpiryBusinessRule, PeriodinMonth, SecurityValueMain )
     ( 
       --,SecurityValueErosion
       SELECT ENTITYKEY ,
              SecurityEntityID ,
              ValuationSourceAlt_Key ,
              ValuationDate ,
              CurrentValue ,
              ValuationExpiryDate ,
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
              NULL ,
              NULL ,
              CollateralID ,
              NULL ,
              NULL ,
              SecurityValueMain 

       -- ,SecurityValueErosion
       FROM RBL_TEMPDB.TempAdvSecurityValueDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVSECURITYVALUEDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
