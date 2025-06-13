--------------------------------------------------------
--  DDL for Procedure CUSTOMERBASICDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   -----------------------------------------
   /*  New Customers EntityKey ID Update  */
   v_Customer_Key NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempCustomerBasicDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.CustomerBasicDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerEntityId = A.CustomerEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
   MERGE INTO RBL_MISDB_PROD.CustomerBasicDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.CustomerBasicDetail O
          JOIN RBL_TEMPDB.TempCustomerBasicDetail T   ON O.CustomerEntityId = T.CustomerEntityId
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.ParentBranchCode, 0) <> NVL(T.ParentBranchCode, 0)
     OR NVL(O.CustomerName, 0) <> NVL(T.CustomerName, 0)
     OR NVL(O.ConstitutionAlt_Key, 0) <> NVL(T.ConstitutionAlt_Key, 0)
     OR NVL(O.CustomerInitial, 0) <> NVL(T.CustomerInitial, 0)
     OR NVL(O.OccupationAlt_Key, 0) <> NVL(T.OccupationAlt_Key, 0)
     OR NVL(O.CustomerSinceDt, '1990-01-01') <> NVL(T.CustomerSinceDt, '1990-01-01')
     OR
     -- ISNULL(O.ConsentObtained,0)               <>ISNULL(T.ConsentObtained,0)            OR
    NVL(O.ReligionAlt_Key, 0) <> NVL(T.ReligionAlt_Key, 0)
     OR NVL(O.CasteAlt_Key, 0) <> NVL(T.CasteAlt_Key, 0)
     OR NVL(O.FarmerCatAlt_Key, 0) <> NVL(T.FarmerCatAlt_Key, 0)
     OR NVL(O.GaurdianSalutationAlt_Key, 0) <> NVL(T.GaurdianSalutationAlt_Key, 0)
     OR NVL(O.GaurdianName, 0) <> NVL(T.GaurdianName, 0)
     OR NVL(O.GuardianType, 0) <> NVL(T.GuardianType, 0)
     OR NVL(O.CustSalutationAlt_Key, 0) <> NVL(T.CustSalutationAlt_Key, 0)
     OR NVL(O.MaritalStatusAlt_Key, 0) <> NVL(T.MaritalStatusAlt_Key, 0)
     OR NVL(O.UCIF_id, ' ') <> NVL(T.UCIF_id, ' ') )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempCustomerBasicDetail A
          JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON B.CustomerEntityId = A.CustomerEntityId --And A.SourceAlt_Key=B.SourceAlt_Key

    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.CustomerBasicDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.CustomerBasicDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempCustomerBasicDetail BB
                       WHERE  AA.CustomerEntityId = BB.CustomerEntityId --And AA.SourceAlt_Key=BB.SourceAlt_Key

                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(Customer_Key)  

     INTO v_Customer_Key
     FROM RBL_MISDB_PROD.CustomerBasicDetail ;
   IF v_Customer_Key IS NULL THEN

   BEGIN
      v_Customer_Key := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.Customer_Key
   FROM RBL_TEMPDB.TempCustomerBasicDetail TEMP
          JOIN ( SELECT "TEMPCUSTOMERBASICDETAIL".CustomerId ,
                        (v_Customer_Key + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                           FROM DUAL  )  )) Customer_Key  
                 FROM RBL_TEMPDB.TempCustomerBasicDetail 
                  WHERE  "TEMPCUSTOMERBASICDETAIL".Customer_Key = 0
                           OR "TEMPCUSTOMERBASICDETAIL".Customer_Key IS NULL ) ACCT   ON Temp.CustomerId = ACCT.CustomerId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.Customer_Key = src.Customer_Key;
   ---------------------------------------------------------------------------------
   INSERT INTO RBL_MISDB_PROD.CustomerBasicDetail
     ( Customer_Key, CustomerEntityId, CustomerId, D2kCustomerid, UCIF_ID, UcifEntityID, ParentBranchCode, CustomerName, CustomerInitial, CustomerSinceDt, ConstitutionAlt_Key, OccupationAlt_Key, ReligionAlt_Key, CasteAlt_Key, FarmerCatAlt_Key, GaurdianSalutationAlt_Key, GaurdianName, GuardianType, CustSalutationAlt_Key, MaritalStatusAlt_Key, AssetClass, BIITransactionCode, D2K_REF_NO, ScrCrError, ReferenceAcNo, CustCRM_RatingAlt_Key, CustCRM_RatingDt, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, FLAG, MocStatus, MocDate, MocTypeAlt_Key, CommonMocTypeAlt_Key, LandHolding, ScrCrErrorSeq, Remark, SourceSystemAlt_Key )
     ( SELECT Customer_Key ,
              CustomerEntityId ,
              CustomerId ,
              D2kCustomerid ,
              UCIF_ID ,
              UcifEntityID ,
              ParentBranchCode ,
              CustomerName ,
              CustomerInitial ,
              CustomerSinceDt ,
              ConstitutionAlt_Key ,
              OccupationAlt_Key ,
              ReligionAlt_Key ,
              CasteAlt_Key ,
              FarmerCatAlt_Key ,
              GaurdianSalutationAlt_Key ,
              GaurdianName ,
              GuardianType ,
              CustSalutationAlt_Key ,
              MaritalStatusAlt_Key ,
              AssetClass ,
              BIITransactionCode ,
              D2K_REF_NO ,
              ScrCrError ,
              ReferenceAcNo ,
              CustCRM_RatingAlt_Key ,
              CustCRM_RatingDt ,
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
              FLAG ,
              MocStatus ,
              MocDate ,
              MocTypeAlt_Key ,
              CommonMocTypeAlt_Key ,
              LandHolding ,
              ScrCrErrorSeq ,
              Remark ,
              SourceSystemAlt_Key 
       FROM RBL_TEMPDB.TempCustomerBasicDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."CUSTOMERBASICDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
