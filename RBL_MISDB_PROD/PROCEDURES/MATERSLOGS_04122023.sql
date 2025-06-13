--------------------------------------------------------
--  DDL for Procedure MATERSLOGS_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MATERSLOGS_04122023" 
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
                OR UTILS.CONVERT_TO_VARCHAR2(DateApproved,200) BETWEEN v_Startdate AND v_Enddate ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MATERSLOGS_04122023" TO "ADF_CDR_RBL_STGDB";
