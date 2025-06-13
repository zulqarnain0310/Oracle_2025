--------------------------------------------------------
--  DDL for Procedure ACCOUNTLEVELDROPDOWN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" 
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
   --=========Get MetaData for Changes Fields=======
   OPEN  v_cursor FOR
      SELECT ENTITYKEY,
                MENUID,
                SCREENNAME,
                CTRLNAME,
                RESOURCEKEY,
                FLDDATATYPE,
                COL_LG,
                COL_MD,
                COL_SM,
                MINLENGTH,
                MAXLENGTH,
                ERRORCHECK,
                DATASEQ,
                FLDGRIDVIEW,
                CRITICALERRORTYPE,
                SCREENFIELDNO,
                ISEDITABLE,
                ISVISIBLE,
                ISUPPER,
                ISMANDATORY,
                ALLOWCHAR,
                DISALLOWCHAR,
                DEFAULTVALUE,
                ALLOWTOOLTIP,
                REFERENCECOLUMNNAME,
                REFERENCETABLENAME,
                MOC_FLAG,
                USERID,
                CREATEDBY,
                DATECREATED,
                MODIFIEDBY,
                DATEMODIFIED,
                SCREENFIELDGROUP,
                HIGHERLEVELEDIT,
                APPLICABLEFORWORKFLOW,
                ISEXTRACTEDEDITABLE,
                ISMOCVISIBLE,
             'AccountLevelNPAMOC' TableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'AccountLevelNPAMOC' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELDROPDOWN" TO "ADF_CDR_RBL_STGDB";
