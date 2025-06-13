--------------------------------------------------------
--  DDL for Procedure MASTERSLOGSNAME_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" 
AS
   v_Startdate VARCHAR2(200) := '06/10/2021';
   v_Enddate VARCHAR2(200) := '07/12/2021';
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT 'AcBuSegmentName' Masetr_Name  ,
             AcBuSegmentCode Masetr_Code  ,
             AcBuSegmentDescription DESCRIPTION  ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy Modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAcBuSegment 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SplCategoryName' ,
             SplCatAlt_Key ,
             SplCatName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAcSplCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'Activity Name' ,
             ActivityValidCode ,
             ActivityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimActivity 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'MappingName' ,
             ActivityValidCode ,
             ActivityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimActivityMapping 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'MappingName' ,
             ActivityValidCode ,
             ActivityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimActivityMapping mod
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AddressCategoryname' ,
             AddressCategoryAlt_Key ,
             AddressCategoryName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAddressCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AreaName' ,
             AreaValidCode ,
             AreaName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimArea 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AssetClassName' ,
             AssetClassValidCode ,
             AssetClassName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAssetClass 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AssestClassMappingName' ,
             SrcSysClassCode ,
             SrcSysClassName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAssetClassMapping 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AssestClassMappingName' ,
             SrcSysClassCode ,
             SrcSysClassName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAssetclassMapping_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AuthorityName' ,
             AuthorityValidCode ,
             AuthorityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimAuthority 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BankingArrangementName' ,
             BankingArrangementAlt_Key ,
             ArrangementDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBankingArrangement 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BankingArrangementName' ,
             BankingArrangementAlt_Key ,
             ArrangementDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBankingArrangement_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BankRPName' ,
             BankCode ,
             BankName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBankRP 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BankRPName' ,
             BankCode ,
             BankName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBankRP_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BranchName' ,
             BranchCode ,
             BranchName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBranch 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BranchName' ,
             BranchCode ,
             BranchName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBranch_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BusinessNmae' ,
             BusinessGroupValidCode ,
             BusinessGroupName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessGroup 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BusinessRuleNmae' ,
             BusinessRuleColValidCode ,
             BusinessRuleColDesc ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessRuleCol 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BusinessRuleSetup' ,
             BusinessRule_Alt_key ,
             Businesscolvalues1 ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessRuleSetup 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'BusinessRuleSetup' ,
             BusinessRule_Alt_key ,
             Businesscolvalues1 ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimBusinessRuleSetup_mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'casteName' ,
             CasteValidCode ,
             CasteName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCaste 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CityName' ,
             CityValidCode ,
             CityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCity 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralchargeName' ,
             CollateralChargeTypeAltKey ,
             CollChargeDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralChargeType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralchargeName' ,
             CollateralChargeTypeAltKey ,
             CollChargeDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralChargeType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralName' ,
             CollateralCode ,
             CollateralDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralCode_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralOwnerName' ,
             CollateralOwnerTypeAltKey ,
             OwnerShipType ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralOwnerType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralOwnerName' ,
             CollateralOwnerTypeAltKey ,
             OwnerShipType ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralOwnerType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralsecurityMpapping Name' ,
             SecurityValidCode ,
             SecurityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSecurityMapping 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'CollateralsecurityMpapping Name' ,
             SecurityValidCode ,
             SecurityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSecurityMapping_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'collateralSubTypeName' ,
             CollateralTypeAltKey ,
             CollateralSubTypeDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSubType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'collateralSubTypeName' ,
             CollateralTypeAltKey ,
             CollateralSubTypeDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralSubType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'CollateralTypeNmae' ,
             CollateralTypeAltKey ,
             CollateralTypeDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CollateralTypeNmae' ,
             CollateralTypeAltKey ,
             CollateralTypeDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCollateralType_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ConsortiumType' ,
             SrcSysConsortiumCode ,
             Consortium_Name ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimConsortiumType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ConstitutionNmae' ,
             ConstitutionValidCode ,
             ConstitutionName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimConstitution 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'Country Nmae' ,
             CountryValidCode ,
             CountryName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCountry 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CreditratingNmae' ,
             CreditRatingValidCode ,
             CreditRatingName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCreditRating 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'CurrencyName' ,
             CurrencyCode ,
             CurrencyName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimCurrency 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'DepartmentName' ,
             DepartmentCode ,
             DepartmentName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.dimdepartment 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'DesignationName' ,
             DesignationValidCode ,
             DesignationName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimDesignation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ExposureBucketName' ,
             ExposureBucketAlt_Key ,
             BucketName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimExposureBucket 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ExposureBucketName' ,
             ExposureBucketAlt_Key ,
             BucketName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimExposureBucket_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'AgencyName' ,
             RatingValidCode ,
             AgencyRating ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimExtAgencyRating 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'FarmerCatNmat' ,
             FarmerCatAlt_Key ,
             FarmerCatName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimFarmerCat 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'GeographyName' ,
             GeographyValidCode ,
             DistrictName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimGeography 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'GLNmae' ,
             GLValidCode ,
             GLName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimGL 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'GLNmae' ,
             GLValidCode ,
             GLName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimGL_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ProductName' ,
             GLCode ,
             GLName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimGLProduct 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'IndustryNmae' ,
             IndustryOrderKey ,
             IndustryName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimIndustry 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'IssueCategoryNmae' ,
             IssuerCategoryAlt_Key ,
             IssuerCategoryName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimIssuerCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'KaretmasterName' ,
             KaretMasterAlt_Key ,
             KaretMasterValueName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimKaretMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'KaretmasterName' ,
             KaretMasterAlt_Key ,
             KaretMasterValueName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimKaretMaster_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'LegalNaturename' ,
             LegalNatureOfActivityAlt_Key ,
             LegalNatureOfActivityName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             NULL Approved_Date  
        FROM RBL_MISDB_PROD.DimLegalNatureOfActivity 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2('',200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'LoginAllowanceName' ,
             UserLocationCode ,
             UserLocationName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimMaxLoginAllow 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'MIscSuitNmae' ,
             LegalMiscSuitAlt_Key ,
             LegalMiscSuitName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             NULL Approved_Date  
        FROM RBL_MISDB_PROD.DimMiscSuit 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2('',200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'MOCTYPEName' ,
             MOCTypeAlt_Key ,
             MOCTypeName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimMOCType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'NPAAgeingName' ,
             NPAAlt_Key ,
             BusinessRule ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimNPAAgeingMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'NPAAgeingName' ,
             NPAAlt_Key ,
             BusinessRule ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimNPAAgeingMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'OccupationName' ,
             OccupationValidCode ,
             OccupationName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimOccupation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ParameterName' ,
             SrcSysParameterCode ,
             ParameterName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimParameter 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'partitionNmae' ,
             PartitionTbaleValidCode ,
             PartitionTbaleName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimPartitionTable 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ProductName' ,
             ProductCode ,
             ProductName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimProduct 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ProductName' ,
             ProductCode ,
             ProductName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimProduct_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ProvisionSegName' ,
             ProvisionAlt_Key ,
             ProvisionRule ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimProvision_Seg 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ProvisionSegName' ,
             ProvisionAlt_Key ,
             ProvisionRule ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimProvision_Seg_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'RegionName' ,
             RegionValidCode ,
             RegionName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimRegion 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ReligionName' ,
             ReligionValidCode ,
             ReligionName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimReligion 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ReportFrequencyName' ,
             ReportFrequencyValidCode ,
             ReportFrequencyName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Apprved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimReportFrequency 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ResolutionNatureName' ,
             RPNatureAlt_Key ,
             RPDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimResolutionPlanNature 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ResolutionNatureName' ,
             RPNatureAlt_Key ,
             RPDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimResolutionPlanNature_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SaluationName' ,
             SalutationValidCode ,
             SalutationName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSalutation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SchemeName' ,
             SchemeValidCode ,
             SchemeName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DIMSCHEME 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SecurityChargeTypename' ,
             SecurityChargeTypeCode ,
             SecurityChargeTypeName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSecurityChargeType 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SecurityErosionTypename' ,
             SecurityAlt_Key ,
             BusinessRule ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSecurityErosionMaster_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SegmentName' ,
             EWS_SegmentValidCode ,
             EWS_SegmentName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSegment 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SMANmae' ,
             SMAAlt_Key ,
             CustomerACID ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSMA 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SMANmae' ,
             SMAAlt_Key ,
             CustomerACID ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSMA_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SourceNmae' ,
             SourceAlt_Key ,
             SourceName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DIMSOURCEDB 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SourceNmae' ,
             SourceAlt_Key ,
             SourceName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSourceDB_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'SplCategoryNmae' ,
             SplCatValidCode ,
             SplCatName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSplCategory 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'StateName' ,
             StateValidCode ,
             StateName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimState 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'Subsectorname' ,
             SubSectorValidCode ,
             SubSectorName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModifie Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimSubSector 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModifie,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'TransactionSubTypeName' ,
             Transaction_Sub_Type_Code ,
             Transaction_Sub_Type_Description ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimTransactionSubTypeMaster 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'TransactionSubTypeName' ,
             Transaction_Sub_Type_Code ,
             Transaction_Sub_Type_Description ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimTransactionSubTypeMaster_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'TypeServiceSummonName' ,
             ServiceSummonValidCode ,
             ServiceSummonName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimTypeServiceSummon 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserDeletionReasonname' ,
             UserDeletionReasonValidCode ,
             UserDeletionReasonName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserDeletionReason 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserDeptGroupname' ,
             DeptGroupCode ,
             DeptGroupName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserDeptGroup 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserDeptGroupname' ,
             DeptGroupCode ,
             DeptGroupName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserDeptGroup_Mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserInfoname' ,
             UserLocationCode ,
             UserName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserInfo 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserInfoname' ,
             UserLocationCode ,
             UserName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserInfo_mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'userlocationname' ,
             UserLocationValidCode ,
             LocationName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.dimuserlocation 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserParametersname' ,
             EntityKey ,
             ParameterType ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserParameters 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserParametersname' ,
             EntityKey ,
             ParameterType ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimUserParameters_mod 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'UserRolename' ,
             UserRoleValidCode ,
             RoleDescription ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             NULL modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             NULL Approved_Date  
        FROM RBL_MISDB_PROD.DimUserRole 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2('',200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ValueExpirationNmae' ,
             ValueExpirationAltKey ,
             Documents ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifiedBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimValueExpiration 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'WorkFlowUseNmae' ,
             SrcSysWorkFlowUserRoleCode ,
             WorkFlowUserRoleName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimWorkFlowUserRole 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate )
      UNION 
      SELECT 'ZoneNmae' ,
             ZoneValidCode ,
             ZoneName ,
             CreatedBy Created_By  ,
             DateCreated Date_Created  ,
             ModifyBy modifiedby  ,
             DateModified Modified_Date  ,
             ApprovedBy Approved_By  ,
             DateApproved Approved_Date  
        FROM RBL_MISDB_PROD.DimZone 
       WHERE  ( UTILS.CONVERT_TO_VARCHAR2(DateCreated,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateModified,200) BETWEEN v_Startdate AND v_Enddate
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MASTERSLOGSNAME_04122023" TO "ADF_CDR_RBL_STGDB";
