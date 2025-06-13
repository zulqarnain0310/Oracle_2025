--------------------------------------------------------
--  DDL for Procedure METADYNAMICQUICKACCESS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" 
(
  v_MenuId IN NUMBER DEFAULT 6668 ,
  v_TimeKey IN NUMBER DEFAULT 24528 ,
  v_Mode IN NUMBER DEFAULT 2 
)
AS
   ---------------------------------Added by Vijay 
   --IF @MenuId IN (640)
   --	BEGIN
   --	SELECT 'MetaGrid'  AS TableName, 'BranchCode' ControlName, 'Branch Code' Label
   --	UNION
   --	SELECT 'MetaGrid'  AS TableName, 'CustomerId' ControlName, 'Customer ID' Label
   --	UNION
   --	SELECT 'MetaGrid'  AS TableName, 'CustomerName' ControlName, 'Customer Name' Label
   --	--UNION
   --	--SELECT 'MetaGrid'  AS TableName, 'ProposalID' ControlName, 'Proposal ID' Label
   --	END
   --Else
   ----------------------------------------
   --Begin
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT 'MetaGrid' TableName  ,
             A.ControlName ,
             B.* 
        FROM MetaDynamicScreenField A
               JOIN MetaDynamicGrid B   ON A.ControlID = B.ControlId
       WHERE  MENUID = v_MENUID
                AND NVL(ValidCode, 'N') = 'Y'
        ORDER BY EntityKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --End
   OPEN  v_cursor FOR
      SELECT 'ScreenDetail' TableName  ,
             MenuCaption ,
             MenuId ,
             NonAllowOperation ,
             DeptGroupCode ,
             EnableMakerChecker ,
             ResponseTimeDisplay ,
             AccessLevel ,
             CASE 
                  WHEN NVL(GridApplicable, 'N') = 'Y' THEN 1
             ELSE 0
                END GridApplicable  ,
             CASE 
                  WHEN NVL(Accordian, 'N') = 'Y' THEN 1
             ELSE 0
                END Accordian  ,
             UTILS.CONVERT_TO_VARCHAR2(SYSDATE,10,p_style=>103) CURDATE  
        FROM SysCRisMacMenu 
       WHERE  MenuId = v_MenuId ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --Get Quick Access Fields Meta
   OPEN  v_cursor FOR
      SELECT 'QuickAccessMeta' TableName  ,
             ControlID ,
             ParentcontrolID ,
             Label ,
             'DynamicMaster_' || REPLACE(Label, ' ', ' ') || '_Msg' FieldMessage  ,
             ControlName ColumnName  ,
             ControlType ,
             ----------------------------Added by Vijay ----
             --,CASE WHEN ControlName='BranchCode' AND ControlType='shutter' THEN 'f2autocomplete' 
             --	WHEN ControlName <> 'BranchCode' AND ControlType='shutter' THEN 'text'	
             --	ELSE ControlType END ControlType 
             -----------------------
             AutoCmpltMinLength ,
             Col_sm ,
             Col_lg ,
             Col_md ,
             SourceTable ,
             DisplayRowOrder ,
             DisplayColumnOrder ,
             SourceColumn ,
             ReferenceTableFilter ,
             NVL(ReferenceTable, 'NA') ReferenceTable  ,
             NVL(ReferenceColumn, 'NA') ReferenceColumn  ,
             RefColumnValue ,
             ReferenceTableCond ,
             BaseColumnType ,
             DataType ,
             NVL(DataMinLength, 0) DataMinLength  ,
             NVL(DataMaxLength, 0) DataMaxLength  ,
             ControlName ,
             DisAllowedChar ,
             AllowedChar ,
             OnBlur ,
             OnBlurParameter ,
             OnClick ,
             OnClickParameter ,
             OnChange ,
             OnChangeParameter ,
             OnKeyPress ,
             OnKeyPressParameter ,
             OnFormLoad ,
             OnFormLoadParameter ,
             DefaultValue ,
             NVL(Class, ' ') Class  ,
             NVL(Style, ' ') Style  ,
             ControlName || 'Filter' ControlNameFilter  ,
             ' ' ControlNameFrom  ,
             ' ' ControlNameTo  ,
             0 IsBetween  
        FROM MetaDynamicScreenField B
       WHERE  MenuId = v_MenuId
                AND IsQuickSearch = 'Y'
        ORDER BY DisplayRowOrder,
                 DisplayColumnOrder ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'QuickAccessMaster' TableName  ,
             A.ControlID ,
             MasterTable 
        FROM MetaDynamicScreenField A
               JOIN MetaDynamicMaster B   ON A.ControlID = B.ControlID
       WHERE  MENUID = v_MENUID
                AND IsQuickSearch = 'Y' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ----------
   --if(@MenuId = '634')
   --(
   --SELECT 'InvestmentData'  AS TableName ,*
   --FROM SysCRisMacMenu A 
   --WHERE MENUID='635')
   --- Static SP ---------Added by Vijay
   OPEN  v_cursor FOR
      SELECT 'StaticSP' TableName  ,
             SSP.ControlID ,
             SPName ,
             ClientSideParams ,
             ServerSideParams 
        FROM MetaDynamicCallStaticSP SSP
               JOIN MetaDynamicScreenField FLD   ON SSP.ControlID = FLD.ControlID
               AND FLD.MenuID = v_MenuId ;
      DBMS_SQL.RETURN_RESULT(v_cursor);------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."METADYNAMICQUICKACCESS" TO "ADF_CDR_RBL_STGDB";
