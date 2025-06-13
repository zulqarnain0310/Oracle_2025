--------------------------------------------------------
--  DDL for Procedure RPT_037_16052022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_037_16052022" 
--USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[Rpt-037]    Script Date: 5/12/2022 2:08:27 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 /*
Create By  - Manmohan Sharma
Report     - Masters Audit Log Report
Date       - 10 Nov 2021
*/
(
  v_DateFrom IN VARCHAR2,
  v_DateTo IN VARCHAR2
)
AS
   --DECLARE @DateFrom	AS VARCHAR(15)= '01/03/2022',
   --        @DateTo	AS VARCHAR(15)= '31/03/2022'
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_To1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   v_cursor SYS_REFCURSOR;

BEGIN

   -----------------------------------------------
   OPEN  v_cursor FOR
      SELECT 'AcBuSegmentName' Masters_Name  ,
             UTILS.CONVERT_TO_VARCHAR2(AcBuSegmentCode,4000) Masetr_Code  ,
             AcBuSegmentDescription Description  ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAcBuSegment 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SplCategoryName' ,
             UTILS.CONVERT_TO_VARCHAR2(SplCatAlt_Key,4000) ,
             SplCatName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAcSplCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'Activity Name' ,
             UTILS.CONVERT_TO_VARCHAR2(ActivityValidCode,4000) ,
             ActivityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimActivity 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'MappingName' ,
             UTILS.CONVERT_TO_VARCHAR2(ActivityValidCode,4000) ,
             ActivityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimActivityMapping 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'MappingName' ,
             UTILS.CONVERT_TO_VARCHAR2(ActivityValidCode,4000) ,
             ActivityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimActivityMapping mod
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AddressCategoryname' ,
             UTILS.CONVERT_TO_VARCHAR2(AddressCategoryAlt_Key,4000) ,
             AddressCategoryName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAddressCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AreaName' ,
             UTILS.CONVERT_TO_VARCHAR2(AreaValidCode,4000) ,
             AreaName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimArea 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AssetClassName' ,
             UTILS.CONVERT_TO_VARCHAR2(AssetClassValidCode,4000) ,
             AssetClassName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAssetClass 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AssestClassMappingName' ,
             UTILS.CONVERT_TO_VARCHAR2(SrcSysClassCode,4000) ,
             SrcSysClassName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAssetClassMapping 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AssestClassMappingName' ,
             UTILS.CONVERT_TO_VARCHAR2(SrcSysClassCode,4000) ,
             SrcSysClassName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAssetclassMapping_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AuthorityName' ,
             UTILS.CONVERT_TO_VARCHAR2(AuthorityValidCode,4000) ,
             AuthorityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimAuthority 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BankingArrangementName' ,
             UTILS.CONVERT_TO_VARCHAR2(BankingArrangementAlt_Key,4000) ,
             ArrangementDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBankingArrangement 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BankingArrangementName' ,
             UTILS.CONVERT_TO_VARCHAR2(BankingArrangementAlt_Key,4000) ,
             ArrangementDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBankingArrangement_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BankRPName' ,
             UTILS.CONVERT_TO_VARCHAR2(BankCode,4000) ,
             BankName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBankRP 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BankRPName' ,
             UTILS.CONVERT_TO_VARCHAR2(BankCode,4000) ,
             BankName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBankRP_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BranchName' ,
             UTILS.CONVERT_TO_VARCHAR2(BranchCode,4000) ,
             BranchName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBranch 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BranchName' ,
             UTILS.CONVERT_TO_VARCHAR2(BranchCode,4000) ,
             BranchName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBranch_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BusinessName' ,
             UTILS.CONVERT_TO_VARCHAR2(BusinessGroupValidCode,4000) ,
             BusinessGroupName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessGroup 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BusinessRuleName' ,
             UTILS.CONVERT_TO_VARCHAR2(BusinessRuleColValidCode,4000) ,
             BusinessRuleColDesc ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessRuleCol 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BusinessRuleSetup' ,
             UTILS.CONVERT_TO_VARCHAR2(BusinessRule_Alt_key,4000) ,
             Businesscolvalues1 ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessRuleSetup 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'BusinessRuleSetup' ,
             UTILS.CONVERT_TO_VARCHAR2(BusinessRule_Alt_key,4000) ,
             Businesscolvalues1 ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessRuleSetup_mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CASTeName' ,
             UTILS.CONVERT_TO_VARCHAR2(CASTeValidCode,4000) ,
             CASTeName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCaste 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CityName' ,
             UTILS.CONVERT_TO_VARCHAR2(CityValidCode,4000) ,
             CityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCity 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralchargeName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralChargeTypeAltKey,4000) ,
             CollChargeDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralChargeType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralchargeName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralChargeTypeAltKey,4000) ,
             CollChargeDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralChargeType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralCode,4000) ,
             CollateralDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralCode_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralOwnerName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralOwnerTypeAltKey,4000) ,
             OwnerShipType ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralOwnerType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralOwnerName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralOwnerTypeAltKey,4000) ,
             OwnerShipType ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralOwnerType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralsecurityMpapping Name' ,
             UTILS.CONVERT_TO_VARCHAR2(SecurityValidCode,4000) ,
             SecurityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSecurityMapping 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralsecurityMpapping Name' ,
             UTILS.CONVERT_TO_VARCHAR2(SecurityValidCode,4000) ,
             SecurityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSecurityMapping_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'collateralSubTypeName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralTypeAltKey,4000) ,
             CollateralSubTypeDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSubType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'collateralSubTypeName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralTypeAltKey,4000) ,
             CollateralSubTypeDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSubType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralTypename' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralTypeAltKey,4000) ,
             CollateralTypeDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CollateralTypeName' ,
             UTILS.CONVERT_TO_VARCHAR2(CollateralTypeAltKey,4000) ,
             CollateralTypeDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ConsortiumType' ,
             UTILS.CONVERT_TO_VARCHAR2(SrcSysConsortiumCode,4000) ,
             Consortium_Name ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimConsortiumType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ConstitutionName' ,
             UTILS.CONVERT_TO_VARCHAR2(ConstitutionValidCode,4000) ,
             ConstitutionName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimConstitution 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'Country Name' ,
             UTILS.CONVERT_TO_VARCHAR2(CountryValidCode,4000) ,
             CountryName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCountry 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CreditratingName' ,
             UTILS.CONVERT_TO_VARCHAR2(CreditRatingValidCode,4000) ,
             CreditRatingName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCreditRating 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'CurrencyName' ,
             UTILS.CONVERT_TO_VARCHAR2(CurrencyCode,4000) ,
             CurrencyName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimCurrency 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'DepartmentName' ,
             UTILS.CONVERT_TO_VARCHAR2(DepartmentCode,4000) ,
             DepartmentName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.dimdepartment 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'DesignationName' ,
             UTILS.CONVERT_TO_VARCHAR2(DesignationValidCode,4000) ,
             DesignationName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimDesignation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ExposureBucketName' ,
             UTILS.CONVERT_TO_VARCHAR2(ExposureBucketAlt_Key,4000) ,
             BucketName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimExposureBucket 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ExposureBucketName' ,
             UTILS.CONVERT_TO_VARCHAR2(ExposureBucketAlt_Key,4000) ,
             BucketName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimExposureBucket_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'AgencyName' ,
             UTILS.CONVERT_TO_VARCHAR2(RatingValidCode,4000) ,
             AgencyRating ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimExtAgencyRating 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'FarmerCatName' ,
             UTILS.CONVERT_TO_VARCHAR2(FarmerCatAlt_Key,4000) ,
             FarmerCatName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimFarmerCat 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'GeographyName' ,
             UTILS.CONVERT_TO_VARCHAR2(GeographyValidCode,4000) ,
             DistrictName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimGeography 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'GLName' ,
             UTILS.CONVERT_TO_VARCHAR2(GLValidCode,4000) ,
             GLName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimGL 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'GLName' ,
             UTILS.CONVERT_TO_VARCHAR2(GLValidCode,4000) ,
             GLName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimGL_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ProductName' ,
             UTILS.CONVERT_TO_VARCHAR2(GLCode,4000) ,
             GLName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimGLProduct 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'IndustryName' ,
             UTILS.CONVERT_TO_VARCHAR2(IndustryOrderKey,4000) ,
             IndustryName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimIndustry 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'IssueCategoryName' ,
             UTILS.CONVERT_TO_VARCHAR2(IssuerCategoryAlt_Key,4000) ,
             IssuerCategoryName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimIssuerCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'KaretmasterName' ,
             UTILS.CONVERT_TO_VARCHAR2(KaretMasterAlt_Key,4000) ,
             KaretMasterValueName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimKaretMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'KaretmasterName' ,
             UTILS.CONVERT_TO_VARCHAR2(KaretMasterAlt_Key,4000) ,
             KaretMasterValueName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimKaretMaster_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'LegalNaturename' ,
             UTILS.CONVERT_TO_VARCHAR2(LegalNatureOfActivityAlt_Key,4000) ,
             LegalNatureOfActivityName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             NULL Approved_Date  
        FROM RBL_MISDB_PROD.DimLegalNatureOfActivity 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2('',200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'LoginAllowanceName' ,
             UTILS.CONVERT_TO_VARCHAR2(UserLocationCode,4000) ,
             UserLocationName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimMaxLoginAllow 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'MIscSuitName' ,
             UTILS.CONVERT_TO_VARCHAR2(LegalMiscSuitAlt_Key,4000) ,
             LegalMiscSuitName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             NULL Approved_Date  
        FROM RBL_MISDB_PROD.DimMiscSuit 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2('',200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'MOCTYPEName' ,
             UTILS.CONVERT_TO_VARCHAR2(MOCTypeAlt_Key,4000) ,
             MOCTypeName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimMOCType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'NPAAgeingName' ,
             UTILS.CONVERT_TO_VARCHAR2(NPAAlt_Key,4000) ,
             BusinessRule ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimNPAAgeingMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'NPAAgeingName' ,
             UTILS.CONVERT_TO_VARCHAR2(NPAAlt_Key,4000) ,
             BusinessRule ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimNPAAgeingMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'OccupationName' ,
             UTILS.CONVERT_TO_VARCHAR2(OccupationValidCode,4000) ,
             OccupationName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimOccupation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ParameterName' ,
             UTILS.CONVERT_TO_VARCHAR2(SrcSysParameterCode,4000) ,
             ParameterName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimParameter 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'partitionName' ,
             UTILS.CONVERT_TO_VARCHAR2(PartitionTbaleValidCode,4000) ,
             PartitionTbaleName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimPartitionTable 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ProductName' ,
             UTILS.CONVERT_TO_VARCHAR2(ProductCode,4000) ,
             ProductName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimProduct 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ProductName' ,
             UTILS.CONVERT_TO_VARCHAR2(ProductCode,4000) ,
             ProductName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimProduct_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ProvisionSegName' ,
             UTILS.CONVERT_TO_VARCHAR2(ProvisionAlt_Key,4000) ,
             ProvisionRule ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimProvision_Seg 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ProvisionSegName' ,
             UTILS.CONVERT_TO_VARCHAR2(ProvisionAlt_Key,4000) ,
             ProvisionRule ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimProvision_Seg_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'RegionName' ,
             UTILS.CONVERT_TO_VARCHAR2(RegionValidCode,4000) ,
             RegionName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimRegion 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ReligionName' ,
             UTILS.CONVERT_TO_VARCHAR2(ReligionValidCode,4000) ,
             ReligionName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimReligion 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ReportFrequencyName' ,
             UTILS.CONVERT_TO_VARCHAR2(ReportFrequencyValidCode,4000) ,
             ReportFrequencyName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimReportFrequency 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ResolutionNatureName' ,
             UTILS.CONVERT_TO_VARCHAR2(RPNatureAlt_Key,4000) ,
             RPDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimResolutionPlanNature 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ResolutionNatureName' ,
             UTILS.CONVERT_TO_VARCHAR2(RPNatureAlt_Key,4000) ,
             RPDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimResolutionPlanNature_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SaluationName' ,
             UTILS.CONVERT_TO_VARCHAR2(SalutationValidCode,4000) ,
             SalutationName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSalutation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SchemeName' ,
             UTILS.CONVERT_TO_VARCHAR2(SchemeValidCode,4000) ,
             SchemeName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DIMSCHEME 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SecurityChargeTypename' ,
             UTILS.CONVERT_TO_VARCHAR2(SecurityChargeTypeCode,4000) ,
             SecurityChargeTypeName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSecurityChargeType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SecurityErosionTypeName' ,
             UTILS.CONVERT_TO_VARCHAR2(SecurityAlt_Key,4000) ,
             BusinessRule ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSecurityErosionMaster_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SegmentName' ,
             UTILS.CONVERT_TO_VARCHAR2(EWS_SegmentValidCode,4000) ,
             EWS_SegmentName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSegment 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SMAName' ,
             UTILS.CONVERT_TO_VARCHAR2(SMAAlt_Key,4000) ,
             CustomerACID ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSMA 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SMAName' ,
             UTILS.CONVERT_TO_VARCHAR2(SMAAlt_Key,4000) ,
             CustomerACID ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSMA_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SourceName' ,
             UTILS.CONVERT_TO_VARCHAR2(SourceAlt_Key,4000) ,
             SourceName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DIMSOURCEDB 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SourceName' ,
             UTILS.CONVERT_TO_VARCHAR2(SourceAlt_Key,20) ,
             SourceName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSourceDB_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SplCategoryName' ,
             UTILS.CONVERT_TO_VARCHAR2(SplCatValidCode,4000) ,
             SplCatName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSplCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'StateName' ,
             UTILS.CONVERT_TO_VARCHAR2(StateValidCode,4000) ,
             StateName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimState 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'SubsectorName' ,
             UTILS.CONVERT_TO_VARCHAR2(SubSectorValidCode,4000) ,
             SubSectorName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModifie,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimSubSector 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'TransactionSubTypeName' ,
             UTILS.CONVERT_TO_VARCHAR2(Transaction_Sub_Type_Code,4000) ,
             Transaction_Sub_Type_Description ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimTransactionSubTypeMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'TransactionSubTypeName' ,
             UTILS.CONVERT_TO_VARCHAR2(Transaction_Sub_Type_Code,4000) ,
             Transaction_Sub_Type_Description ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimTransactionSubTypeMaster_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'TypeServiceSummonName' ,
             UTILS.CONVERT_TO_VARCHAR2(ServiceSummonValidCode,4000) ,
             ServiceSummonName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimTypeServiceSummon 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserDeletionReasonname' ,
             UTILS.CONVERT_TO_VARCHAR2(UserDeletionReasonValidCode,4000) ,
             UserDeletionReasonName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimUserDeletionReason 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserDeptGroupName' ,
             UTILS.CONVERT_TO_VARCHAR2(DeptGroupCode,4000) ,
             DeptGroupName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimUserDeptGroup 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserDeptGroupName' ,
             UTILS.CONVERT_TO_VARCHAR2(DeptGroupCode,4000) ,
             DeptGroupName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
       /*
      UNION

      SELECT 
      'UserInfoName',
      CONVERT(VARCHAR(MAX),UserLocationCode),
      UserName,
      CreatedBy                                 AS [Created By],
      CONVERT(VARCHAR(20),DateCreated,103)      AS [Date Created],
      ModifyBy                                  AS [Modifiedby],
      CONVERT(VARCHAR(20),DateModified,103)     AS [Modified Date],
      ApprovedBy                                AS [Approved By],
      CONVERT(VARCHAR(20),DateApproved,103)     AS [Approved Date]
      FROM dbo.DimUserInfo 
      WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
            OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
            OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)
      */
      SELECT 'UserInfoName' ,
             UTILS.CONVERT_TO_VARCHAR2(UserLocationCode,4000) ,
             UserName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimUserInfo_mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserlocationName' ,
             UTILS.CONVERT_TO_VARCHAR2(UserLocationValidCode,4000) ,
             LocationName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.dimuserlocation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserParametersName' ,
             UTILS.CONVERT_TO_VARCHAR2(EntityKey,4000) ,
             ParameterType ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimUserParameters 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserParametersName' ,
             UTILS.CONVERT_TO_VARCHAR2(EntityKey,4000) ,
             ParameterType ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimUserParameters_mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'UserRoleName' ,
             UTILS.CONVERT_TO_VARCHAR2(UserRoleValidCode,4000) ,
             RoleDescription ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             NULL Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             NULL Approved_Date  
        FROM RBL_MISDB_PROD.DimUserRole 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2('',200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ValueExpirationName' ,
             UTILS.CONVERT_TO_VARCHAR2(ValueExpirationAltKey,4000) ,
             Documents ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifiedBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimValueExpiration 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'WorkFlowUseName' ,
             UTILS.CONVERT_TO_VARCHAR2(SrcSysWorkFlowUserRoleCode,4000) ,
             WorkFlowUserRoleName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimWorkFlowUserRole 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
      UNION 
      SELECT 'ZoneName' ,
             UTILS.CONVERT_TO_VARCHAR2(ZoneValidCode,4000) ,
             ZoneName ,
             CreatedBy Created_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateCreated,20,p_style=>103) Date_Created  ,
             ModifyBy Modifiedby  ,
             UTILS.CONVERT_TO_VARCHAR2(DateModified,20,p_style=>103) Modified_Date  ,
             ApprovedBy Approved_By  ,
             UTILS.CONVERT_TO_VARCHAR2(DateApproved,20,p_style=>103) Approved_Date  
        FROM RBL_MISDB_PROD.DimZone 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_From1 AND v_To1
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_From1 AND v_To1 )
        ORDER BY Masters_Name ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_037_16052022" TO "ADF_CDR_RBL_STGDB";
