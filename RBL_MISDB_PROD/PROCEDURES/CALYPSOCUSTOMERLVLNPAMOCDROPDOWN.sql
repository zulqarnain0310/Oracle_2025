--------------------------------------------------------
--  DDL for Procedure CALYPSOCUSTOMERLVLNPAMOCDROPDOWN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" 
--(If  SUB-STANDARD then NPA Date Mandatory , date format DD-MM-YYYY
 --(If DOUBTFUL I  then NPA Date Mandatory , date format DD-MM-YYYY
 --(If LOS then NPA Date Mandatory , date format DD-MM-YYYY
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================  
 -- Author:    <FARAHNAAZ>  Exec [CustomerLvlNPAMOCDropDown] @AssetClassAlt_Key=1
 -- Create date:   <05/04/2021>  
 -- Description:   <All DropDown Select Query for [CustomerLvlNPAMOCDropDown]
 -- =============================================  

AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--@AssetClassAlt_Key INT =0

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'MOCType' Tablename  
        FROM DimParameter 
       WHERE  DimParameterName = 'MOCType'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'FraudAccountFlag' Tablename  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT AssetClassAlt_Key ,
             AssetClassName ,
             'AssetClass' Tablename  
        FROM DimAssetClass 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey
                AND AssetClassAlt_Key NOT IN ( 4,5 )

        ORDER BY AssetClassAlt_Key ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT MOCTypeAlt_Key ,
             MOCTypeName ,
             'MOCSource' TableName  
        FROM DimMOCType 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'MOCReason' TableName  
        FROM DimParameter 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey
                AND DimParameterName = 'DimMOCReason' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT SourceName SourceSystem  ,
             'SourceSystem' TableName  
        FROM DIMSOURCEDB 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --BEGIN
   --IF (@AssetClassAlt_Key=1)
   --Begin
   --Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key=2 
   --End
   --	IF (@AssetClassAlt_Key=2)
   --	Begin
   --	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (1,3) 
   --	End
   --	IF (@AssetClassAlt_Key=3)
   --	Begin
   --	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (2,4) 
   --	End
   --	IF (@AssetClassAlt_Key=4)
   --	Begin
   --	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (3,5) 
   --	End
   --	IF (@AssetClassAlt_Key=5)
   --	Begin
   --	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (4,6) 
   --	End
   --	IF (@AssetClassAlt_Key=6)
   --	Begin
   --	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (5) 
   --	End
   OPEN  v_cursor FOR
      SELECT ENTITYKEY,	MENUID,	SCREENNAME,	CTRLNAME,	RESOURCEKEY,	FLDDATATYPE,	COL_LG,	COL_MD,	COL_SM,	MINLENGTH,	MAXLENGTH,	ERRORCHECK,	DATASEQ,	FLDGRIDVIEW,	CRITICALERRORTYPE,	SCREENFIELDNO,	ISEDITABLE,	ISVISIBLE,	ISUPPER,	ISMANDATORY,	ALLOWCHAR,	DISALLOWCHAR,	DEFAULTVALUE,	ALLOWTOOLTIP,	REFERENCECOLUMNNAME,	REFERENCETABLENAME,	MOC_FLAG,	USERID,	CREATEDBY,	DATECREATED,	MODIFIEDBY,	DATEMODIFIED,	SCREENFIELDGROUP,	HIGHERLEVELEDIT,	APPLICABLEFORWORKFLOW,	ISEXTRACTEDEDITABLE,	ISMOCVISIBLE,
             'CalypsoCustomerLevelNPAMOC' TableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'CalypsoCustomerLevelNPAMOC' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLVLNPAMOCDROPDOWN" TO "ADF_CDR_RBL_STGDB";
