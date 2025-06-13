--------------------------------------------------------
--  DDL for Procedure CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" 
(
  v_UserID IN VARCHAR2 DEFAULT 'dm410' ,
  v_TimeKey IN NUMBER DEFAULT '49999' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --------------For Customer Tab------------
   OPEN  v_cursor FOR
      SELECT ScreenName ,
             CtrlName ,
             ResourceKey ,
             FldDataType ,
             Col_lg ,
             Col_md ,
             Col_sm ,
             MinLength ,
             MaxLength ,
             ErrorCheck ,
             DataSeq ,
             FldGridView ,
             CriticalErrorType ,
             ScreenFieldNo ,
             IsEditable ,
             IsVisible ,
             IsUpper ,
             IsMandatory ,
             AllowChar ,
             DisAllowChar ,
             DefaultValue ,
             AllowToolTip ,
             ReferenceColumnName ,
             ReferenceTableName ,
             MOC_Flag ,
             HigherLevelEdit ,
             NVL(IsMocVisible, 'N') IsMocVisible  ,
             CASE 
                  WHEN NVL(IsExtractedEditable, 'Y') = 'Y' THEN 'false'
             ELSE 'true'
                END IsExtractedEditable  
        FROM RBL_MISDB_PROD.MetaScreenFieldDetail 
       WHERE  ScreenName = 'Customer'
        ORDER BY DataSeq ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------For AdditionalCustomerDetails Tab--------
   OPEN  v_cursor FOR
      SELECT ScreenName ,
             CtrlName ,
             ResourceKey ,
             FldDataType ,
             Col_lg ,
             Col_md ,
             Col_sm ,
             MinLength ,
             MaxLength ,
             ErrorCheck ,
             DataSeq ,
             FldGridView ,
             CriticalErrorType ,
             ScreenFieldNo ,
             IsEditable ,
             IsVisible ,
             IsUpper ,
             IsMandatory ,
             AllowChar ,
             DisAllowChar ,
             DefaultValue ,
             AllowToolTip ,
             ReferenceColumnName ,
             ReferenceTableName ,
             MOC_Flag ,
             HigherLevelEdit ,
             CASE 
                  WHEN NVL(IsExtractedEditable, 'Y') = 'Y' THEN 'false'
             ELSE 'true'
                END IsExtractedEditable  
        FROM RBL_MISDB_PROD.MetaScreenFieldDetail 
       WHERE  ScreenName = 'AdditionalCustomerDetails'
        ORDER BY DataSeq ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------------For AddressDetails Tab-------------
   OPEN  v_cursor FOR
      SELECT ScreenName ,
             CtrlName ,
             ResourceKey ,
             FldDataType ,
             Col_lg ,
             Col_md ,
             Col_sm ,
             MinLength ,
             MaxLength ,
             ErrorCheck ,
             DataSeq ,
             FldGridView ,
             CriticalErrorType ,
             ScreenFieldNo ,
             IsEditable ,
             IsVisible ,
             IsUpper ,
             IsMandatory ,
             AllowChar ,
             DisAllowChar ,
             DefaultValue ,
             AllowToolTip ,
             ReferenceColumnName ,
             ReferenceTableName ,
             MOC_Flag ,
             HigherLevelEdit ,
             CASE 
                  WHEN NVL(IsExtractedEditable, 'Y') = 'Y' THEN 'false'
             ELSE 'true'
                END IsExtractedEditable  
        FROM RBL_MISDB_PROD.MetaScreenFieldDetail 
       WHERE  ScreenName = 'AddressDetails'
        ORDER BY DataSeq ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --- For Customer screen Speedup
   --Basic
   OPEN  v_cursor FOR
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimConstitution' MasterTable --Y

        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimReligion' MasterTable --Y

        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimCaste' MasterTable --Y

        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimSplCategory' MasterTable --N (Added in MetaParameterisedmasterTable)

        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimASsetClass' MasterTable --Y

        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimSalutation' MasterTable --Y

        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimAddressCategory' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimType' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimLegalNatureOfActivity' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimMiscSuit' MasterTable  
        FROM DUAL 
      UNION 

      --SELECT 'BasicDetailsMaster' TableName, 'DimOccupation' MasterTable UNION
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimBorrowerGroup' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimBranch' MasterTable  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'BasicDetailsMaster' TableName  ,
             'DimYesNo' MasterTable  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --Additional Details
   --SELECT 'AdditionalDetailsMaster' TableName, 'DimReasonForWillfulDefault' MasterTable UNION
   OPEN  v_cursor FOR
      SELECT 'AdditionalDetailsMaster' TableName  ,
             'DimConsortiumType' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AddressDetailsMaster' TableName  ,
             'DimTypeServiceSummon' MasterTable  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   -- Address Details
   OPEN  v_cursor FOR
      SELECT 'AddressDetailsMaster' TableName  ,
             'DimType' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AddressDetailsMaster' TableName  ,
             'DimCity' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AddressDetailsMaster' TableName  ,
             'DimGeography' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AddressDetailsMaster' TableName  ,
             'DimCountry' MasterTable  --UNION		
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --SELECT 'AddressDetailsMaster' TableName, 'DimAddressCategory' MasterTable 	
   --- All MasterList for $scope.ListModel
   OPEN  v_cursor FOR
      SELECT 'AllMasterList' TableName  ,
             'DimConstitution' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimReligion' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimCaste' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimSplCategory' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimASsetClass' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimSalutation' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimYesNo' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimBranch' MasterTable  
        FROM DUAL 
      UNION 

      --Additional Details
      SELECT 'AllMasterList' TableName  ,
             'DimReasonForWillfulDefault' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimConsortiumType' MasterTable  
        FROM DUAL 
      UNION 

      -- Address Details
      SELECT 'AllMasterList' TableName  ,
             'DimCity' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimGeography' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimCountry' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimAddressCategory' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimType' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimOccupation' MasterTable  
        FROM DUAL 
      UNION 
      SELECT 'AllMasterList' TableName  ,
             'DimTypeServiceSummon' MasterTable  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---
   OPEN  v_cursor FOR
      SELECT 'Customer' ResourceTable  
        FROM DUAL 
      UNION 
      SELECT 'OtherCustomer' ResourceTable  
        FROM DUAL 
      UNION 
      SELECT 'AdditionalCustomerDetails' ResourceTable  
        FROM DUAL 
      UNION 
      SELECT 'AddressDetails' ResourceTable  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERDETAILSSCREENMETAFIELDSBIND_COMMONFUNC_04122023" TO "ADF_CDR_RBL_STGDB";
