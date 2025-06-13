--------------------------------------------------------
--  DDL for Procedure ALL_CUSTOMER_EXPOSURE_DETAIL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_vEFFECTIVETO NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL A
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerEntityId = A.CustomerEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
   --------------------------------------------------------------------------------
   MERGE INTO RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL O
          JOIN RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL T   ON O.CustomerEntityId = T.CustomerEntityId
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.Balance_date, '1990-01-01') <> NVL(T.Balance_date, '1990-01-01')
     OR NVL(O.BUSINESS_SEGMENT, 0) <> NVL(T.BUSINESS_SEGMENT, 0)
     OR NVL(O.BUSINESS_SEGMENT_DESC, ' ') <> NVL(T.BUSINESS_SEGMENT_DESC, ' ')
     OR NVL(O.BUSINESS_SEGMENT_Taken_From, ' ') <> NVL(T.BUSINESS_SEGMENT_Taken_From, ' ')
     OR NVL(O.NAME_OF_RM, ' ') <> NVL(T.NAME_OF_RM, ' ')
     OR NVL(O.BRANCH_CODE, ' ') <> NVL(T.BRANCH_CODE, ' ')
     OR NVL(O.BRANCH_STATE, ' ') <> NVL(T.BRANCH_STATE, ' ')
     OR NVL(O.CONSTITUTION_CODE, ' ') <> NVL(T.CONSTITUTION_CODE, ' ')
     OR NVL(O.CONSTITUTION_DESC, ' ') <> NVL(T.CONSTITUTION_DESC, ' ')
     OR NVL(O.IMACS_ID, 0) <> NVL(T.IMACS_ID, 0)
     OR NVL(O.IMACS_GROUP_NAME, ' ') <> NVL(T.IMACS_GROUP_NAME, ' ')
     OR NVL(O.MASTER_RATIng, ' ') <> NVL(T.MASTER_RATIng, ' ')
     OR NVL(O.LAST_RATING_DATE, '1990-01-01') <> NVL(T.LAST_RATING_DATE, '1990-01-01')
     OR NVL(O.INDUSTRY_CODE, ' ') <> NVL(T.INDUSTRY_CODE, ' ')
     OR NVL(O.INDUSTRY_DESC, ' ') <> NVL(T.INDUSTRY_DESC, ' ')
     OR NVL(O.INTERNAL_INDUSTRY_CLASSIFICATION, ' ') <> NVL(T.INTERNAL_INDUSTRY_CLASSIFICATION, ' ')
     OR NVL(O.DSB_INDUSTRY_NAME, ' ') <> NVL(T.DSB_INDUSTRY_NAME, ' ')
     OR NVL(O.DSB_INDUSTRY_NAME_FOR_RBS, ' ') <> NVL(T.DSB_INDUSTRY_NAME_FOR_RBS, ' ')
     OR NVL(O.INDUSTRY_SERVICES_OTHERS, ' ') <> NVL(T.INDUSTRY_SERVICES_OTHERS, ' ')
     OR NVL(O.CREDPRO_LEVEL_2, ' ') <> NVL(T.CREDPRO_LEVEL_2, ' ')
     OR NVL(O.TYPE_FUNDED_NON_FUNDED_OR_TREASURY, ' ') <> NVL(T.TYPE_FUNDED_NON_FUNDED_OR_TREASURY, ' ')
     OR NVL(O.WHOLESALE_RETAIL_OTHER, ' ') <> NVL(T.WHOLESALE_RETAIL_OTHER, ' ')
     OR NVL(O.BORROWER_STATUS, ' ') <> NVL(T.BORROWER_STATUS, ' ')
     OR NVL(O.model_rating, ' ') <> NVL(T.model_rating, ' ')
     OR NVL(O.NPA_FLAG, ' ') <> NVL(T.NPA_FLAG, ' ')
     OR NVL(O.FB_LIM, 0) <> NVL(T.FB_LIM, 0)
     OR NVL(O.NFB_LIM, 0) <> NVL(T.NFB_LIM, 0)
     OR NVL(O.FB_LIEN_AMT, 0) <> NVL(T.FB_LIEN_AMT, 0)
     OR NVL(O.NFB_LIEN_AMT, 0) <> NVL(T.NFB_LIEN_AMT, 0)
     OR NVL(O.CB_FB_LIM, 0) <> NVL(T.CB_FB_LIM, 0)
     OR NVL(O.CB_NFB_LIM, 0) <> NVL(T.CB_NFB_LIM, 0)
     OR NVL(O.GROSS_FB_EXPOSURE_AS_PER_SYSTEM, 0) <> NVL(T.GROSS_FB_EXPOSURE_AS_PER_SYSTEM, 0)
     OR NVL(O.ADJUSTMENT_FOR_GROSS_FB, 0) <> NVL(T.ADJUSTMENT_FOR_GROSS_FB, 0)
     OR NVL(O.LCBD, 0) <> NVL(T.LCBD, 0)
     OR NVL(O.LCBR, 0) <> NVL(T.LCBR, 0)
     OR NVL(O.GROSS_FB_EXPOSURE, 0) <> NVL(T.GROSS_FB_EXPOSURE, 0)
     OR NVL(O.Overseas_FB_EXPOSURE_AS_PER_SYSTEM, 0) <> NVL(T.Overseas_FB_EXPOSURE_AS_PER_SYSTEM, 0)
     OR NVL(O.Overseas_ADJUSTMENT_FOR_GROSS_FB, 0) <> NVL(T.Overseas_ADJUSTMENT_FOR_GROSS_FB, 0)
     OR NVL(O.Overseas_FB_EXPOSURE, 0) <> NVL(T.Overseas_FB_EXPOSURE, 0)
     OR NVL(O.DOMESTIC_FB_Exp, 0) <> NVL(T.DOMESTIC_FB_Exp, 0)
     OR NVL(O.overseas_NFB_EXPOSURE, 0) <> NVL(T.overseas_NFB_EXPOSURE, 0)
     OR NVL(O.Domestic_NFB_EXPOSURE, 0) <> NVL(T.Domestic_NFB_EXPOSURE, 0)
     OR NVL(O.GROSS_NFB_EXPOSURE, 0) <> NVL(T.GROSS_NFB_EXPOSURE, 0)
     OR NVL(O.overseas_TOTAL_EXPOSURE, 0) <> NVL(T.overseas_TOTAL_EXPOSURE, 0)
     OR NVL(O.Domestic_TOTAL_EXPOSURE, 0) <> NVL(T.Domestic_TOTAL_EXPOSURE, 0)
     OR NVL(O.GROSS_TOTAL_EXPOSURE, 0) <> NVL(T.GROSS_TOTAL_EXPOSURE, 0)
     OR NVL(O.CREDIT_FB_EXPOSURE, 0) <> NVL(T.CREDIT_FB_EXPOSURE, 0)
     OR NVL(O.Overseas_CREDIT_FB_EXPOSURE, 0) <> NVL(T.Overseas_CREDIT_FB_EXPOSURE, 0)
     OR NVL(O.DOMESTIC_Credit_FB_Exp, 0) <> NVL(T.DOMESTIC_Credit_FB_Exp, 0)
     OR NVL(O.CREDIT_NFB_EXPOSURE, 0) <> NVL(T.CREDIT_NFB_EXPOSURE, 0)
     OR NVL(O.Overseas_Credit_NFB_Exp, 0) <> NVL(T.Overseas_Credit_NFB_Exp, 0)
     OR NVL(O.DOMESTIC_Credit_NFB_Exp, 0) <> NVL(T.DOMESTIC_Credit_NFB_Exp, 0)
     OR NVL(O.CREDIT_EXPOSURE, 0) <> NVL(T.CREDIT_EXPOSURE, 0)
     OR NVL(O.FB_OS_AS_PER_SYSTEM, 0) <> NVL(T.FB_OS_AS_PER_SYSTEM, 0)
     OR NVL(O.ADJUSTMENT_FOR_FB_OS, 0) <> NVL(T.ADJUSTMENT_FOR_FB_OS, 0)
     OR NVL(O.LCBD_OS, 0) <> NVL(T.LCBD_OS, 0)
     OR NVL(O.LCBR_OS, 0) <> NVL(T.LCBR_OS, 0)
     OR NVL(O.FB_OS, 0) <> NVL(T.FB_OS, 0)
     OR NVL(O.Overseas_FB_OS_AS_PER_SYSTEM, 0) <> NVL(T.Overseas_FB_OS_AS_PER_SYSTEM, 0)
     OR NVL(O.Overseas_ADJUSTMENT_FB_OS, 0) <> NVL(T.Overseas_ADJUSTMENT_FB_OS, 0)
     OR NVL(O.Overseas_FB_OS, 0) <> NVL(T.Overseas_FB_OS, 0)
     OR NVL(O.Domestic_FB_OS, 0) <> NVL(T.Domestic_FB_OS, 0)
     OR NVL(O.nfb_os_as_per_system, 0) <> NVL(T.nfb_os_as_per_system, 0)
     OR NVL(O.overseas_NFB_OS, 0) <> NVL(T.overseas_NFB_OS, 0)
     OR NVL(O.domestic_NFB_OS, 0) <> NVL(T.domestic_NFB_OS, 0)
     OR NVL(O.Total_OS, 0) <> NVL(T.Total_OS, 0)
     OR NVL(O.CB_FB_Collateral, 0) <> NVL(T.CB_FB_Collateral, 0)
     OR NVL(O.CB_NFB_Collateral, 0) <> NVL(T.CB_NFB_Collateral, 0)
     OR NVL(O.CB_Lien_Amt, 0) <> NVL(T.CB_Lien_Amt, 0)
     OR NVL(O.FB_VALUE, 0) <> NVL(T.FB_VALUE, 0)
     OR NVL(O.NFB_VALUE, 0) <> NVL(T.NFB_VALUE, 0)
     OR NVL(O.UNCONDITIONAL_FLAG, ' ') <> NVL(T.UNCONDITIONAL_FLAG, ' ')
     OR NVL(O.LER_O_s, 0) <> NVL(T.LER_O_s, 0)
     OR NVL(O.overseas_ler_O_s, 0) <> NVL(T.overseas_ler_O_s, 0)
     OR NVL(O.domestic_NFB_OS, 0) <> NVL(T.DOMESTIC_ler_O_s, 0)
     OR NVL(O.NON_SLR, 0) <> NVL(T.NON_SLR, 0)
     OR NVL(O.OVERSEAS_NON_SLR, 0) <> NVL(T.OVERSEAS_NON_SLR, 0)
     OR NVL(O.DOMESTIC_NON_SLR, 0) <> NVL(T.DOMESTIC_NON_SLR, 0)
     OR NVL(O.CREDIT_EXP_NONSLR, 0) <> NVL(T.CREDIT_EXP_NONSLR, 0)
     OR NVL(O.CREDIT_EXP_NONSLR_LER, 0) <> NVL(T.CREDIT_EXP_NONSLR_LER, 0)
     OR NVL(O.OVERSEAS_CREDIT_EXP_NONSLR_LER, 0) <> NVL(T.OVERSEAS_CREDIT_EXP_NONSLR_LER, 0)
     OR NVL(O.DOMESTIC_CREDIT_EXP_NONSLR_LER, 0) <> NVL(T.DOMESTIC_CREDIT_EXP_NONSLR_LER, 0)
     OR NVL(O.GROSS_EXPOSURE_NSLR, 0) <> NVL(T.GROSS_EXPOSURE_NSLR, 0)
     OR NVL(O.Credit_Exp_LER, 0) <> NVL(T.Credit_Exp_LER, 0)
     OR NVL(O.UNDRAWN_AMOUNT, 0) <> NVL(T.UNDRAWN_AMOUNT, 0)
     OR NVL(O.UNDRAWN_AMOUNT_FB_EXP, 0) <> NVL(T.UNDRAWN_AMOUNT_FB_EXP, 0)
     OR NVL(O.UNDRAWN_AMOUNT_NFB_EXP, 0) <> NVL(T.UNDRAWN_AMOUNT_NFB_EXP, 0)
     OR NVL(O.UNCONDITIONALLY_CANCELLABLE_EXP, 0) <> NVL(T.UNCONDITIONALLY_CANCELLABLE_EXP, 0)
     OR NVL(O.UNCONDITIONALLY_CANCELLABLE_EXP_FB, 0) <> NVL(T.UNCONDITIONALLY_CANCELLABLE_EXP_FB, 0)
     OR NVL(O.UNCONDITIONALLY_CANCELLABLE_EXP_NFB, 0) <> NVL(T.UNCONDITIONALLY_CANCELLABLE_EXP_NFB, 0)
     OR NVL(O.bank_nonbank_type, ' ') <> NVL(T.bank_nonbank_type, ' ')
     OR NVL(O.A1percent_OF_NW, ' ') <> NVL(T.A1percent_OF_NW, ' ')
     OR NVL(O.EXP_percent_OF_TIER_1CAPITAL_ECB, 0) <> NVL(T.EXP_percent_OF_TIER_1CAPITAL_ECB, 0)
     OR NVL(O.A10percent_OF_TIER_1CAPITAL, ' ') <> NVL(T.A10percent_OF_TIER_1CAPITAL, ' ')
     OR NVL(O.A1percent_OF_TIER_1CAPITAL, ' ') <> NVL(T.A1percent_OF_TIER_1CAPITAL, ' ')
     OR NVL(O.TREASURY_FLAG, ' ') <> NVL(T.TREASURY_FLAG, ' ')
     OR NVL(O.valution_business_date, '1990-01-01') <> NVL(T.valution_business_date, '1990-01-01')
     OR NVL(O.tech_off_bussiness_date, '1990-01-01') <> NVL(T.tech_off_bussiness_date, '1990-01-01')
     OR NVL(O.LER_Business_dt, '1990-01-01') <> NVL(T.LER_Business_dt, '1990-01-01')
     OR NVL(O.MOC, 0) <> NVL(T.MOC, 0)
     OR NVL(O.Post_MOC_FB_OS, 0) <> NVL(T.Post_MOC_FB_OS, 0)
     OR NVL(O.ler_limits_INR, 0) <> NVL(T.ler_limits_INR, 0)
     OR NVL(O.LER_Exposure, 0) <> NVL(T.LER_Exposure, 0)
     OR NVL(O.ler_limits_overseas_INR, 0) <> NVL(T.ler_limits_overseas_INR, 0)
     OR NVL(O.ler_limits_domestic_INR, 0) <> NVL(T.ler_limits_domestic_INR, 0)
     OR NVL(O.Undrawn_LER, 0) <> NVL(T.Undrawn_LER, 0)
     OR NVL(O.LER_Exposure_Overseas, 0) <> NVL(T.LER_Exposure_Overseas, 0)
     OR NVL(O.LER_Exposure_Domestic, 0) <> NVL(T.LER_Exposure_Domestic, 0)
     OR NVL(O.Total_OS_NSLROS_LEROS, 0) <> NVL(T.Total_OS_NSLROS_LEROS, 0)
     OR NVL(O.Total_LIMT_NSLROS_LEROS, 0) <> NVL(T.Total_LIMT_NSLROS_LEROS, 0)
     OR NVL(O.Total_OS_NSLROS_LEROS_Overseas, 0) <> NVL(T.Total_OS_NSLROS_LEROS_Overseas, 0)
     OR NVL(O.Total_OS_NSLROS_LEROS_Domestic, 0) <> NVL(T.Total_OS_NSLROS_LEROS_Domestic, 0)
     OR NVL(O.FB_LIM_Overseas, 0) <> NVL(T.FB_LIM_Overseas, 0)
     OR NVL(O.FB_LIM_Domestic, 0) <> NVL(T.FB_LIM_Domestic, 0)
     OR NVL(O.NFB_LIM_Overseas, 0) <> NVL(T.NFB_LIM_Overseas, 0)
     OR NVL(O.NFB_LIM_Domestic, 0) <> NVL(T.NFB_LIM_Domestic, 0)
     OR NVL(O.Total_LIMT_NSLROS_LEROS_Domestic, 0) <> NVL(T.Total_LIMT_NSLROS_LEROS_Domestic, 0)
     OR NVL(O.Total_LIMT_NSLROS_LEROS_Overseas, 0) <> NVL(T.Total_LIMT_NSLROS_LEROS_Overseas, 0)
     OR NVL(O.Clsg_Asset_Class, ' ') <> NVL(T.Clsg_Asset_Class, ' ')
     OR NVL(O.NFB_LIM_LER, 0) <> NVL(T.NFB_LIM_LER, 0)
     OR NVL(O.Credit_NFB_Exp_LER, 0) <> NVL(T.Credit_NFB_Exp_LER, 0)
     OR NVL(O.nfb_MOC, 0) <> NVL(T.nfb_MOC, 0)
     OR NVL(O.takeover, 0) <> NVL(T.takeover, 0)
     OR NVL(O.nfb_os, 0) <> NVL(T.nfb_os, 0)
     OR NVL(O.SHip_Sanct_Lim, 0) <> NVL(T.SHip_Sanct_Lim, 0)
     OR NVL(O.Ship_Liab, 0) <> NVL(T.Ship_Liab, 0)
     OR NVL(O.Ship_contingent_liab, 0) <> NVL(T.Ship_contingent_liab, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   MERGE INTO RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL A
          JOIN RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL B   ON B.CustomerEntityId = A.CustomerEntityId 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged = 'C';
   ---------------------------------------------------------------------------------------------------------------
   MERGE INTO RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL BB
                       WHERE  AA.CustomerEntityId = BB.CustomerEntityId
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   --	DECLARE @EntityKey BIGINT=0 
   --SELECT @EntityKey=MAX(EntityKey) FROM  RBL_MISDB.[dbo].[AdvCustOtherDetail] 
   --IF @EntityKey IS NULL  
   --BEGIN
   --	SET @EntityKey=0
   --END
   --UPDATE TEMP 
   --SET TEMP.EntityKey=ACCT.Customer_Key
   -- FROM RBL_TEMPDB.DBO.[TempAdvCustOtherDetail] TEMP
   --INNER JOIN (SELECT CUSTOMERENTITYID,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Customer_Key
   --			FROM RBL_TEMPDB.DBO.[TempAdvCustOtherDetail]
   --			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON  Temp.CustomerEntityId=ACCT.CustomerEntityId
   --Where Temp.IsChanged in ('N','C')
   INSERT INTO RBL_MISDB_PROD.ALL_CUSTOMER_EXPOSURE_DETAIL
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
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              NULL D2Ktimestamp  
       FROM RBL_TEMPDB.TEMP_ALL_CUSTOMER_EXPOSURE_DETAIL T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ALL_CUSTOMER_EXPOSURE_DETAIL" TO "ADF_CDR_RBL_STGDB";
