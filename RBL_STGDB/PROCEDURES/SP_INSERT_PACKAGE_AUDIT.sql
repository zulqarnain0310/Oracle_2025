--------------------------------------------------------
--  DDL for Procedure SP_INSERT_PACKAGE_AUDIT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" 
AS
   --Alter table Package_AUDIT
   --add Date_of_data Date 
   v_DateOfData VARCHAR2(200) ;
   v_temp NUMBER(1, 0) := 0;

BEGIN
 SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(date_of_data,200) INTO v_DateOfData
     FROM DWH_STG.account_data_finacle  ;
     
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE v_DateOfData = ( SELECT DISTINCT Date_of_data 
                              FROM RBL_STGDB.Package_AUDIT 
                               WHERE  Date_of_data = v_DateOfData );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO Package_AUDIT_MOD
        ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionEndTime, TimeDuration_Sec, ExecutionStatus, Date_of_data )
        ( SELECT Execution_date ,
                 DataBaseName ,
                 PackageName ,
                 TableName ,
                 ExecutionStartTime ,
                 ExecutionEndTime ,
                 TimeDuration_Sec ,
                 ExecutionStatus ,
                 Date_of_data 
          FROM Package_AUDIT 
           WHERE  Date_of_data >= v_DateOfData );
      DELETE Package_AUDIT

       WHERE  Date_of_data >= v_DateOfData;

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE 0 <> ( SELECT COUNT(*)  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  Execution_date > '2024-01-14'
                              AND Date_of_data IS NULL );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO Package_AUDIT_MOD
        ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionEndTime, TimeDuration_Sec, ExecutionStatus, Date_of_data )
        ( SELECT Execution_date ,
                 DataBaseName ,
                 PackageName ,
                 TableName ,
                 ExecutionStartTime ,
                 ExecutionEndTime ,
                 TimeDuration_Sec ,
                 ExecutionStatus ,
                 Date_of_data 
          FROM Package_AUDIT 
           WHERE  Execution_date > '2024-01-14'
                    AND Date_of_data IS NULL );
      DELETE Package_AUDIT

       WHERE  Execution_date > '2024-01-14'
                AND Date_of_data IS NULL;

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE 0 <> ( SELECT COUNT(*)  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_VARCHAR2(Execution_date,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO Package_AUDIT_MOD
        ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionEndTime, TimeDuration_Sec, ExecutionStatus, Date_of_data )
        ( SELECT Execution_date ,
                 DataBaseName ,
                 PackageName ,
                 TableName ,
                 ExecutionStartTime ,
                 ExecutionEndTime ,
                 TimeDuration_Sec ,
                 ExecutionStatus ,
                 Date_of_data 
          FROM Package_AUDIT 
           WHERE  UTILS.CONVERT_TO_VARCHAR2(Execution_date,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) );
      DELETE Package_AUDIT

       WHERE  UTILS.CONVERT_TO_VARCHAR2(Execution_date,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);

   END;
   END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."SP_INSERT_PACKAGE_AUDIT" TO "ADF_CDR_RBL_STGDB";
