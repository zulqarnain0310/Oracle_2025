--------------------------------------------------------
--  DDL for Procedure PARAMETERVALUEDROPDOWN_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" 
(
  v_ParameterValue IN NUMBER DEFAULT 0 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         IF v_ParameterValue IN ( 1,2,13 )
          THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'Frequency' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_ParameterValue IN ( 3,5,14,22,23,24,25,26,27,28,29,30,31,32 )
          THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'Holidays' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_ParameterValue IN ( 4,10,11,12 )
          THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'System' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_ParameterValue = 6 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'Status' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_parametervalue = 15 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_Timekey
                         AND EffectiveToTimeKey >= v_Timekey
                         AND DimParameterName = 'Model' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_parametervalue = 7 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'CumulativeDefinePeriod' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_parametervalue = 8 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'CumulativeDefineDays' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_parametervalue = 9 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND DimParameterName = 'CumulativeDefineInterestServiced' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_parametervalue = 19 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT Parameter_Key ,
                      ParameterAlt_Key ,
                      ParameterName ,
                      'ParameterValue' TableName  
                 FROM DimParameter 
                WHERE  EffectiveFromTimeKey <= v_Timekey
                         AND EffectiveToTimeKey >= v_Timekey
                         AND DimParameterName = 'securityvalue' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PARAMETERVALUEDROPDOWN_04122023" TO "ADF_CDR_RBL_STGDB";
