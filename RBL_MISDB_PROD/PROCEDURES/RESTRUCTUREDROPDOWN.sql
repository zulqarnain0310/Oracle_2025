--------------------------------------------------------
--  DDL for Procedure RESTRUCTUREDROPDOWN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" 
AS
   v_Timekey NUMBER(10,0);
   ---  Drop Down for asset Class----
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  currentstatus = 'C';

   BEGIN
      OPEN  v_cursor FOR
         SELECT AssetClassAlt_Key ,
                AssetClassName ,
                'AssetClassList' TableName  
           FROM RBL_MISDB_PROD.DimAssetClass 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for BankingRelationship---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'BankingRelationship' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'BankingRelationship' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for CovidMoratorium---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'CovidMoratorium' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'DimYesNoNA' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for CovidOTRCategory---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'CovidOTRCategory' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'Covid - OTR Category' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for RestructureFacility---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'RestructureFacility' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'RestructureFacility' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for InvestmentGrade---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'InvestmentGrade' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'DimYesNoNA' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for StatusofMonitoringPeriod---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'StatusofMonitoringPeriod' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'StatusofMonitoringPeriod' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for StatusofSpecificPeriod---- 
      OPEN  v_cursor FOR
         SELECT ParameterAlt_Key ,
                ParameterName ,
                'StatusofSpecificPeriod' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'StatusofSpecificPeriod' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for TypeofRestructuring---- 
      OPEN  v_cursor FOR
         SELECT
         --Parameter_Key
          ParameterAlt_Key ,
          ParameterName ,
          'TypeofRestructuring' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'TypeofRestructuring' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      OPEN  v_cursor FOR
         SELECT EWS_SegmentAlt_Key ,
                EWS_SegmentName ,
                'RevisedBusinessSegment' TableName  
           FROM DimSegment 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ---  Drop Down for TypeofRestructuring---- 
      OPEN  v_cursor FOR
         SELECT 
                --Parameter_Key
                CASE 
                     WHEN ParameterAlt_Key = 10 THEN 'N'
                     WHEN ParameterAlt_Key = 20 THEN 'Y'
                ELSE NULL
                   END ParameterAlt_Key  ,
                ParameterName ,
                'EquityConversionYN' TableName  
           FROM DimParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND DimParameterName = 'DimYesNo' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN" TO "ADF_CDR_RBL_STGDB";
