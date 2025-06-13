--------------------------------------------------------
--  DDL for Procedure SMAVALUEDROPDOWN_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" 
AS
   v_TimeKey NUMBER(10,0);
   --Select '' as Parameter_Key,'' as ParameterAlt_Key,'-Select-' as ParameterName,'ValueList' TableName
   --union
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList1' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList2' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList3' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList4' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList5' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList6' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList7' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList8' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList9' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList10' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList11' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList12' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT Parameter_Key ,
                   ParameterAlt_Key ,
                   ParameterName ,
                   'ValueList13' TableName  
              FROM DimParameter 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey
                      AND DimParameterName = 'Holidays' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMAVALUEDROPDOWN_04122023" TO "ADF_CDR_RBL_STGDB";
