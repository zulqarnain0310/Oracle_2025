--------------------------------------------------------
--  DDL for Procedure CALYPSOCUSTOMERLEVELDROPDOWN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'RestructureFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'FITLFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'InherentWeaknessFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'SARFAESIFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'UnusualBounceFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'UnclearedEffectsFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'RePossessionFlag' TableName  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterShortNameEnum ParameterAlt_Key  ,
             ParameterName ,
             'FraudAccountFlag' Tablename  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimYesNo'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
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
      SELECT AssetClassMappingAlt_Key ,
             AssetClassAlt_Key ,
             AssetClassShortName ,
             'SMASubAssetClassValue' TableName  
        FROM DimAssetClassMapping 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --=========Get MetaData for Changes Fields=======
   OPEN  v_cursor FOR
      SELECT ENTITYKEY,	MENUID,	SCREENNAME,	CTRLNAME,	RESOURCEKEY,	FLDDATATYPE,	COL_LG,	COL_MD,	COL_SM,	MINLENGTH,	MAXLENGTH,	ERRORCHECK,	DATASEQ,	FLDGRIDVIEW,	CRITICALERRORTYPE,	SCREENFIELDNO,	ISEDITABLE,	ISVISIBLE,	ISUPPER,	ISMANDATORY,	ALLOWCHAR,	DISALLOWCHAR,	DEFAULTVALUE,	ALLOWTOOLTIP,	REFERENCECOLUMNNAME,	REFERENCETABLENAME,	MOC_FLAG,	USERID,	CREATEDBY,	DATECREATED,	MODIFIEDBY,	DATEMODIFIED,	SCREENFIELDGROUP,	HIGHERLEVELEDIT,	APPLICABLEFORWORKFLOW,	ISEXTRACTEDEDITABLE,	ISMOCVISIBLE,
             'CalypsoCustomerLevelNPAMOC' TableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'CalypsoCustomerLevelNPAMOC' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELDROPDOWN" TO "ADF_CDR_RBL_STGDB";
