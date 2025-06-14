--------------------------------------------------------
--  DDL for Procedure PROCESSINGSTEPS5
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."PROCESSINGSTEPS5" 
(
  v_UserLoginID IN VARCHAR2 DEFAULT 'DM585' 
)
AS
    v_TIMEKEY NUMBER(10,0) ;
   v_ProcessingDateAudit VARCHAR2(200) ;
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TIMEKEY INTO v_TIMEKEY 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;
   SELECT Date_ INTO v_ProcessingDateAudit
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   DELETE MAIN_PRO.Package_AUDIT

    WHERE  IdentityKey = 5;
   INSERT INTO MAIN_PRO.Package_AUDIT
     ( IdentityKey, UserID, Execution_date, PackageName, TableName, ExecutionStartTime, ExecutionStatus, ProcessingDate )
     ( SELECT 5 ,
              v_UserLoginID ,
              SYSDATE ,
              'Data Rev' ,
              'Reverse Feed Data' ,
              SYSDATE ,
              'P' ,
              v_ProcessingDateAudit 
         FROM DUAL  );
   UPDATE MAIN_PRO.Package_AUDIT
      SET ExecutionEndTime = SYSDATE
    WHERE  IdentityKey = 5
     AND Execution_date = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200)
     AND TableName = 'Reverse Feed Data';
   UPDATE MAIN_PRO.Package_AUDIT
      SET ExecutionStatus = 'Y'
    WHERE  IdentityKey = 5;
   DELETE MAIN_PRO.Package_AuditHist

    WHERE  TIMEKEY = v_TIMEKEY;
   INSERT INTO MAIN_PRO.Package_AuditHist
     ( IDENTITYKEY, USERID, EXECUTION_DATE, PACKAGENAME, TABLENAME, EXECUTIONSTARTTIME, EXECUTIONENDTIME, TIMEDURATION_MIN, EXECUTIONSTATUS, PROCESSINGDATE, TIMEKEY )
     ( SELECT IDENTITYKEY ,
              USERID ,
              EXECUTION_DATE ,
              PACKAGENAME ,
              TABLENAME ,
              EXECUTIONSTARTTIME ,
              EXECUTIONENDTIME ,
              TIMEDURATION_MIN ,
              EXECUTIONSTATUS ,
              PROCESSINGDATE ,
              v_TIMEKEY 
       FROM MAIN_PRO.Package_AUDIT  );
   MERGE INTO MAIN_PRO.ProcessMonitor A
   USING (SELECT A.ROWID row_id, B.UserID
   FROM MAIN_PRO.ProcessMonitor A
          JOIN Package_AuditHist B   ON A.TimeKey = B.timekey 
    WHERE B.IdentityKey = 5) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.UserID = src.UserID;
   OPEN  v_cursor FOR
      SELECT 5 StepNo  ,
             'Result' TableName  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROCESSINGSTEPS5" TO "ADF_CDR_RBL_STGDB";
