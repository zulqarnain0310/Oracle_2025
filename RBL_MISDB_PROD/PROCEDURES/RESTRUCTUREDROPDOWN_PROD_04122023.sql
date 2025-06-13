--------------------------------------------------------
--  DDL for Procedure RESTRUCTUREDROPDOWN_PROD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" 
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

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREDROPDOWN_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
