--------------------------------------------------------
--  DDL for Procedure ALL_CUSTOMER_EXPOSURE_DETAIL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --DECLARE @DATE AS DATE =(SELECT Date FROM RBL_MISDB.[dbo].Automate_Advances WHERE EXT_FLG='Y')
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL ';
   INSERT INTO RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL
     ( Balance_date, ucic, source_system, CustomerEntityId, CIF_ID, CUST_NAME, PAN, BUSINESS_SEGMENT, BUSINESS_SEGMENT_DESC, BUSINESS_SEGMENT_Taken_From, NAME_OF_RM, BRANCH_CODE, BRANCH_STATE, CONSTITUTION_CODE, CONSTITUTION_DESC, IMACS_ID, IMACS_GROUP_NAME, MASTER_RATIng, LAST_RATING_DATE, INDUSTRY_CODE, INDUSTRY_DESC, INTERNAL_INDUSTRY_CLASSIFICATION, DSB_INDUSTRY_NAME, DSB_INDUSTRY_NAME_FOR_RBS, INDUSTRY_SERVICES_OTHERS, CREDPRO_LEVEL_2, TYPE_FUNDED_NON_FUNDED_OR_TREASURY, WHOLESALE_RETAIL_OTHER, BORROWER_STATUS, model_rating, NPA_FLAG, FB_LIM, NFB_LIM, FB_LIEN_AMT, NFB_LIEN_AMT, CB_FB_LIM, CB_NFB_LIM, GROSS_FB_EXPOSURE_AS_PER_SYSTEM, ADJUSTMENT_FOR_GROSS_FB, LCBD, LCBR, GROSS_FB_EXPOSURE, Overseas_FB_EXPOSURE_AS_PER_SYSTEM, Overseas_ADJUSTMENT_FOR_GROSS_FB, Overseas_FB_EXPOSURE, DOMESTIC_FB_Exp, overseas_NFB_EXPOSURE, Domestic_NFB_EXPOSURE, GROSS_NFB_EXPOSURE, overseas_TOTAL_EXPOSURE, Domestic_TOTAL_EXPOSURE, GROSS_TOTAL_EXPOSURE, CREDIT_FB_EXPOSURE, Overseas_CREDIT_FB_EXPOSURE, DOMESTIC_Credit_FB_Exp, CREDIT_NFB_EXPOSURE, Overseas_Credit_NFB_Exp, DOMESTIC_Credit_NFB_Exp, CREDIT_EXPOSURE, FB_OS_AS_PER_SYSTEM, ADJUSTMENT_FOR_FB_OS, LCBD_OS, LCBR_OS, FB_OS, Overseas_FB_OS_AS_PER_SYSTEM, Overseas_ADJUSTMENT_FB_OS, Overseas_FB_OS, Domestic_FB_OS, nfb_os_as_per_system, overseas_NFB_OS, domestic_NFB_OS, Total_OS, CB_FB_Collateral, CB_NFB_Collateral, CB_Lien_Amt, FB_VALUE, NFB_VALUE, UNCONDITIONAL_FLAG, LER_O_s, overseas_ler_O_s, DOMESTIC_ler_O_s, NON_SLR, OVERSEAS_NON_SLR, DOMESTIC_NON_SLR, CREDIT_EXP_NONSLR, CREDIT_EXP_NONSLR_LER, OVERSEAS_CREDIT_EXP_NONSLR_LER, DOMESTIC_CREDIT_EXP_NONSLR_LER, GROSS_EXPOSURE_NSLR, Credit_Exp_LER, UNDRAWN_AMOUNT, UNDRAWN_AMOUNT_FB_EXP, UNDRAWN_AMOUNT_NFB_EXP, UNCONDITIONALLY_CANCELLABLE_EXP, UNCONDITIONALLY_CANCELLABLE_EXP_FB, UNCONDITIONALLY_CANCELLABLE_EXP_NFB, bank_nonbank_type, A1percent_OF_NW, EXP_percent_OF_TIER_1CAPITAL_ECB, A10percent_OF_TIER_1CAPITAL, A1percent_OF_TIER_1CAPITAL, TREASURY_FLAG, valution_business_date, tech_off_bussiness_date, LER_Business_dt, MOC, Post_MOC_FB_OS, ler_limits_INR, LER_Exposure, ler_limits_overseas_INR, ler_limits_domestic_INR, Undrawn_LER, LER_Exposure_Overseas, LER_Exposure_Domestic, Total_OS_NSLROS_LEROS, Total_LIMT_NSLROS_LEROS, Total_OS_NSLROS_LEROS_Overseas, Total_OS_NSLROS_LEROS_Domestic, FB_LIM_Overseas, FB_LIM_Domestic, NFB_LIM_Overseas, NFB_LIM_Domestic, Total_LIMT_NSLROS_LEROS_Domestic, Total_LIMT_NSLROS_LEROS_Overseas, Clsg_Asset_Class, NFB_LIM_LER, Credit_NFB_Exp_LER, nfb_MOC, takeover, nfb_os, SHip_Sanct_Lim, Ship_Liab, Ship_contingent_liab, Ischanged, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp )
     ( SELECT Balance_date ,
              ucic ,
              source_system ,
              CustomerEntityId ,
              CIF_ID ,
              CUST_NAME ,
              PAN ,
              BUSINESS_SEGMENT ,
              BUSINESS_SEGMENT_DESC ,
              BUSINESS_SEGMENT_Taken_From ,
              NAME_OF_RM ,
              BRANCH_CODE ,
              BRANCH_STATE ,
              CONSTITUTION_CODE ,
              CONSTITUTION_DESC ,
              IMACS_ID ,
              IMACS_GROUP_NAME ,
              MASTER_RATIng ,
              LAST_RATING_DATE ,
              INDUSTRY_CODE ,
              INDUSTRY_DESC ,
              INTERNAL_INDUSTRY_CLASSIFICATION ,
              DSB_INDUSTRY_NAME ,
              DSB_INDUSTRY_NAME_FOR_RBS ,
              INDUSTRY_SERVICES_OTHERS ,
              CREDPRO_LEVEL_2 ,
              TYPE_FUNDED_NON_FUNDED_OR_TREASURY ,
              WHOLESALE_RETAIL_OTHER ,
              BORROWER_STATUS ,
              model_rating ,
              NPA_FLAG ,
              FB_LIM ,
              NFB_LIM ,
              FB_LIEN_AMT ,
              NFB_LIEN_AMT ,
              CB_FB_LIM ,
              CB_NFB_LIM ,
              GROSS_FB_EXPOSURE_AS_PER_SYSTEM ,
              ADJUSTMENT_FOR_GROSS_FB ,
              LCBD ,
              LCBR ,
              GROSS_FB_EXPOSURE ,
              Overseas_FB_EXPOSURE_AS_PER_SYSTEM ,
              Overseas_ADJUSTMENT_FOR_GROSS_FB ,
              Overseas_FB_EXPOSURE ,
              DOMESTIC_FB_Exp ,
              overseas_NFB_EXPOSURE ,
              Domestic_NFB_EXPOSURE ,
              GROSS_NFB_EXPOSURE ,
              overseas_TOTAL_EXPOSURE ,
              Domestic_TOTAL_EXPOSURE ,
              GROSS_TOTAL_EXPOSURE ,
              CREDIT_FB_EXPOSURE ,
              Overseas_CREDIT_FB_EXPOSURE ,
              DOMESTIC_Credit_FB_Exp ,
              CREDIT_NFB_EXPOSURE ,
              Overseas_Credit_NFB_Exp ,
              DOMESTIC_Credit_NFB_Exp ,
              CREDIT_EXPOSURE ,
              FB_OS_AS_PER_SYSTEM ,
              ADJUSTMENT_FOR_FB_OS ,
              LCBD_OS ,
              LCBR_OS ,
              FB_OS ,
              Overseas_FB_OS_AS_PER_SYSTEM ,
              Overseas_ADJUSTMENT_FB_OS ,
              Overseas_FB_OS ,
              Domestic_FB_OS ,
              nfb_os_as_per_system ,
              overseas_NFB_OS ,
              domestic_NFB_OS ,
              Total_OS ,
              CB_FB_Collateral ,
              CB_NFB_Collateral ,
              CB_Lien_Amt ,
              FB_VALUE ,
              NFB_VALUE ,
              UNCONDITIONAL_FLAG ,
              LER_O_s ,
              overseas_ler_O_s ,
              DOMESTIC_ler_O_s ,
              NON_SLR ,
              OVERSEAS_NON_SLR ,
              DOMESTIC_NON_SLR ,
              CREDIT_EXP_NONSLR ,
              CREDIT_EXP_NONSLR_LER ,
              OVERSEAS_CREDIT_EXP_NONSLR_LER ,
              DOMESTIC_CREDIT_EXP_NONSLR_LER ,
              GROSS_EXPOSURE_NSLR ,
              Credit_Exp_LER ,
              UNDRAWN_AMOUNT ,
              UNDRAWN_AMOUNT_FB_EXP ,
              UNDRAWN_AMOUNT_NFB_EXP ,
              UNCONDITIONALLY_CANCELLABLE_EXP ,
              UNCONDITIONALLY_CANCELLABLE_EXP_FB ,
              UNCONDITIONALLY_CANCELLABLE_EXP_NFB ,
              bank_nonbank_type ,
              A1percent_OF_NW ,
              EXP_percent_OF_TIER_1CAPITAL_ECB ,
              A10percent_OF_TIER_1CAPITAL ,
              A1percent_OF_TIER_1CAPITAL ,
              TREASURY_FLAG ,
              valution_business_date ,
              tech_off_bussiness_date ,
              LER_Business_dt ,
              MOC ,
              Post_MOC_FB_OS ,
              ler_limits_INR ,
              LER_Exposure ,
              ler_limits_overseas_INR ,
              ler_limits_domestic_INR ,
              Undrawn_LER ,
              LER_Exposure_Overseas ,
              LER_Exposure_Domestic ,
              Total_OS_NSLROS_LEROS ,
              Total_LIMT_NSLROS_LEROS ,
              Total_OS_NSLROS_LEROS_Overseas ,
              Total_OS_NSLROS_LEROS_Domestic ,
              FB_LIM_Overseas ,
              FB_LIM_Domestic ,
              NFB_LIM_Overseas ,
              NFB_LIM_Domestic ,
              Total_LIMT_NSLROS_LEROS_Domestic ,
              Total_LIMT_NSLROS_LEROS_Overseas ,
              Clsg_Asset_Class ,
              NFB_LIM_LER ,
              Credit_NFB_Exp_LER ,
              nfb_MOC ,
              takeover ,
              nfb_os ,
              SHip_Sanct_Lim ,
              Ship_Liab ,
              Ship_contingent_liab ,
              Ischanged ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  
       FROM RBL_STGDB.ALL_CUSTOMER_EXPOSURE_DETAIL_STG A
              JOIN RBL_TEMPDB.TempCustomerBasicDetail B   ON A.CIF_ID = B.CustomerId );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ADF_CDR_RBL_STGDB";
