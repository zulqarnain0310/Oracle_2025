--------------------------------------------------------
--  DDL for Procedure ADVACRELATION_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   ------------------------------------------------------------------------------------------------------------------
   v_MAX NUMBER(10,0);
   ------------------------------------------------------------------------------------------------------------------
   v_MAX1 NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvAcRelations ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   INSERT INTO TempAdvAcRelations
     ( BranchCode, RelationEntityId, CustomerEntityId, AccountEntityId, RelationTypeAlt_Key, RelationSrNo, RelationshipAuthorityCodeAlt_Key, InwardNo, FacilityNo, GuaranteeValue, RefCustomerID, RefSystemAcId, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
     (  /*  THIS PART OF QUERY IS FOR Joint Borrower and Guarantor */
       SELECT TACBD.BranchCode ,
              NULL RelationEntityId  ,
              NVL(TACBD.CustomerEntityId, 0) CustomerEntityId  ,
              NVL(TACBD.AccountEntityId, 0) AccountEntityId  ,
              NULL RelationTypeAlt_Key  ,
              NULL RelationSrNo  ,
              NULL RelationshipAuthorityCodeAlt_Key  ,
              NULL InwardNo  ,
              NULL FacilityNo  ,
              NULL GuaranteeValue  ,
              AAS.CustomerID RefCustomerID  ,
              AAS.AccountID RefSystemAcId  ,
              v_Timekey ,
              49999 ,
              'SSISUSER' ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) 
       FROM RBL_STGDB.CUSTOMERRELATION_SOURCESYSTEM_STG AAS
              JOIN TempAdvAcBasicDetail TACBD   ON AAS.AccountID = TACBD.CustomerACID );
   ----------------------------------------------------------------------------------------------------------------
   MERGE INTO TAAR 
   USING (SELECT TAAR.ROWID row_id, TCBD.RelationEntityId
   FROM TAAR ,CurDat_RBL_MISDB_010922_UAT.AdvCustRelationship TCBD
          JOIN TempAdvAcRelations TAAR   ON TCBD.RefCustomerID = TAAR.RefCustomerID
          AND TCBD.EffectiveFromTimeKey <= v_Timekey
          AND TCBD.EffectiveToTimeKey >= v_Timekey ) src
   ON ( TAAR.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET RelationEntityId = src.RelationEntityId;
   SELECT MAX(RelationEntityId)  

     INTO v_MAX
     FROM ( SELECT MAX(RelationEntityId)  RelationEntityId  
            FROM CurDat_RBL_MISDB_010922_UAT.AdvCustRelationship 
            UNION ALL 
            SELECT MAX(RelationEntityId)  RelationEntityId  
            FROM RBL_MISDB_010922_UAT.ADVCUSTRELATIONSHIP_MOD  ) A;
   IF v_MAX IS NULL THEN

   BEGIN
      v_MAX := 0 ;

   END;
   END IF;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.ReletionEntityId
   FROM A ,TempAdvAcRelations A
          JOIN ( SELECT RefCustomerId ,
                        NVL(v_MAX, 0) + ROW_NUMBER() OVER ( ORDER BY RefCustomerId  ) ReletionEntityId  
                 FROM TempAdvAcRelations A
                  WHERE  RefCustomerId IS NOT NULL
                   GROUP BY RefCustomerId ) B   ON A.RefCustomerId = B.RefCustomerId 
    WHERE A.RelationEntityId IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.RelationEntityId = src.ReletionEntityId;
   SELECT MAX(RelationEntityId)  

     INTO v_MAX1
     FROM ( SELECT MAX(RelationEntityId)  RelationEntityId  
            FROM CurDat_RBL_MISDB_010922_UAT.AdvCustRelationship 
            UNION ALL 
            SELECT MAX(RelationEntityId)  RelationEntityId  
            FROM RBL_MISDB_010922_UAT.ADVCUSTRELATIONSHIP_MOD  ) A;
   IF v_MAX1 IS NULL THEN

   BEGIN
      v_MAX1 := 0 ;

   END;
   END IF;
   UPDATE TempAdvAcRelations
      SET RelationEntityId = v_MAX1 + 1
    WHERE  RelationEntityId IS NULL;
   ------------------------------------------------------------------------------------------------------------------
   MERGE INTO TAAR 
   USING (SELECT TAAR.ROWID row_id, (CASE 
   WHEN TCBD.ConstitutionAlt_Key IN ( 410,421 )
    THEN 16
   ELSE 15
      END) AS RelationTypeAlt_Key
   FROM TAAR ,TempAdvAcRelations TAAR
          JOIN CURDAT_RBL_MISDB_010922_UAT.CustomerBasicDetail TCBD   ON TAAR.refcustomerid = TCBD.customerID ) src
   ON ( TAAR.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET RelationTypeAlt_Key = src.RelationTypeAlt_Key;
   ------------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------------
   UPDATE TEmpAdvAcRelations
      SET RelationSrNo = 0;
   ------------------------------------------------------------------------------------------------------------------
   MERGE INTO TAAR 
   USING (SELECT TAAR.ROWID row_id, CASE 
   WHEN RelationTypeAlt_Key IN ( 15,16 )
    THEN 1
   ELSE 0
      END AS pos_2, CASE 
   WHEN RelationTypeAlt_Key = 17 THEN 42
   ELSE 0
      END AS pos_3
   FROM TAAR ,TempAdvAcRelations TAAR 
    WHERE EffectiveToTimeKey = 49999
     AND RelationTypeAlt_Key IN ( 15,16,17 )
   ) src
   ON ( TAAR.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET RelationSrNo = pos_2,
                                RelationshipAuthorityCodeAlt_Key = pos_3;
   ------------------------------------------------------------------------------------------------------------------
   MERGE INTO a 
   USING (SELECT a.ROWID row_id, 0
   FROM a ,TempAdvAcRelations a 
    WHERE RelationshipAuthorityCodeAlt_Key IS NULL) src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.RelationshipAuthorityCodeAlt_Key = 0;------------------------------------------------------------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACRELATION_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
