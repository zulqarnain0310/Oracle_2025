--------------------------------------------------------
--  DDL for Procedure SQLJOBSELECTION_24072023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --if OBJECT_ID('Tempdb..#temp') is not null
   --drop table #temp
   --			SELECT j.name,'IN-PROGRESS' Status 
   --			into #temp
   --			FROM msdb.dbo.sysjobactivity ja 
   --			LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id
   --			JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
   --			JOIN msdb.dbo.sysjobsteps js
   --			ON ja.job_id = js.job_id
   --			AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
   --			WHERE  ja.session_id = (
   --									 SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC
   --									 )
   --			AND start_execution_date is not null
   --			AND stop_execution_date is null
   --		if OBJECT_ID('Tempdb..#temp1') is not null
   --		drop table #temp1
   --select     A.job_id,a.NAME AS JobName,CASE WHEN enabled=1 THEN 'ENABLED' else 'DISABLED' end AS JobStatus ,c.Status
   --into       #temp1
   --from       MSDB.DBO.sysjobs a
   --inner join ACLAllJobsDetail b
   --on         a.name=b.JobName
   --left join  #temp c
   --on         c.name=b.JobName
   --order by 1
   --SELECT JobName,Case when Status is null then JobStatus else Status end as JobStatus FROM #temp1
   IF utils.object_id('TEMPDB..tt_Temp_118') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_118 ';
   END IF;
   DELETE FROM tt_Temp_118;
   UTILS.IDENTITY_RESET('tt_Temp_118');

   INSERT INTO tt_Temp_118 SELECT j.job_id ,
                                  j.NAME Jobname  ,
                                  js.step_id ,
                                  js.step_name CurrentStep  ,
                                  'IN-PROGRESS' RunningStatus  
        FROM msdb.sysjobactivity ja
               LEFT JOIN msdb.sysjobhistory jh   ON ja.job_history_id = jh.instance_id
               JOIN msdb.sysjobs j   ON ja.job_id = j.job_id
               JOIN msdb.sysjobsteps js   ON ja.job_id = js.job_id
               AND NVL(ja.last_executed_step_id, 0) + 1 = js.step_id
       WHERE  ja.session_id = ( SELECT session_id 
                                FROM msdb.syssessions 
                                  ORDER BY agent_start_date DESC
                                  FETCH FIRST 1 ROWS ONLY )
                AND start_execution_date IS NOT NULL
                AND stop_execution_date IS NULL;
   --			if OBJECT_ID('Tempdb..#temp1') is not null
   --drop table #temp1
   IF utils.object_id('TEMPDB..tt_TMPJobStepCount_5') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TMPJobStepCount_5 ';
   END IF;
   DELETE FROM tt_TMPJobStepCount_5;
   UTILS.IDENTITY_RESET('tt_TMPJobStepCount_5');

   INSERT INTO tt_TMPJobStepCount_5 ( 
   	SELECT A.job_id ,
           A.Name JobName  ,
           COUNT(B.step_name)  JobStepCount  
   	  FROM msdb.sysjobs A
             JOIN msdb.sysjobsteps B   ON A.job_id = B.job_id

   	--AND A.name='TESTJOB'
   	GROUP BY A.job_id,A.NAME );
   OPEN  v_cursor FOR
      SELECT A.Name JobName  ,
             CASE 
                  WHEN ENABLED = 1 THEN 'ENABLE'
             ELSE 'DISABLE'
                END JobStatus  ,
             c.RunningStatus ,
             D.JobStepCount TotalJobSteps  ,
             CASE 
                  WHEN c.step_id IS NULL THEN '0'
             ELSE c.step_id
                END CurrentJobStep  
        FROM MSDB.sysjobs a
               JOIN ACLAllJobsDetail b   ON a.NAME = b.JobName
               LEFT JOIN tt_Temp_118 c   ON c.Jobname = b.JobName
               LEFT JOIN tt_TMPJobStepCount_5 D   ON a.NAME = D.JobName
        ORDER BY 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --if OBJECT_ID('Tempdb..#tempFinal') is not null
   --drop table #tempFinal
   --SELECT JobName,JobStatus,RunDate,RunningStatus INTO #tempFinal FROM (
   --select A.JobName,Case when A.Status is null then JobStatus else A.Status end as JobStatus,B.RUN_DATE RunDate,
   --			CASE WHEN B.run_status=0 THEN 'FAILED'
   --				 WHEN B.run_status=1 THEN 'SUCCEEDED'
   --				 WHEN B.run_status=2 THEN 'RETRY'
   --				 WHEN B.run_status=3 THEN 'CANCELED'
   --				 WHEN B.run_status=4 THEN 'IN-PROGRESS'
   --				 ELSE 'YETTOSTART'
   --			END RunningStatus
   --			,ROW_NUMBER () OVER (PARTITION BY A.job_id ORDER BY B.RUN_DATE DESC,RUN_Time desc)RN
   --from #temp1 A
   --inner join msdb.dbo.sysjobhistory B
   --on A.job_id=B.job_id
   --)A WHERE RN=1
   --SELECT JobName,JobStatus,RunningStatus FROM #tempFinal
   OPEN  v_cursor FOR
      SELECT A.Jobname JobName  ,
             RunningStatus JobStatus  ,
             'RunningJob' TableName  
        FROM tt_Temp_118 A
               JOIN ACLAllJobsDetail B   ON A.Jobname = B.JobName
       WHERE  a.Jobname NOT LIKE '%RetryJobForFrontEnd%' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   IF utils.object_id('Tempdb..tt_temp2_15') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_15 ';
   END IF;
   DELETE FROM tt_temp2_15;
   UTILS.IDENTITY_RESET('tt_temp2_15');

   INSERT INTO tt_temp2_15 SELECT j.NAME ,
                                  'IN-PROGRESS' STATUS  
        FROM msdb.sysjobactivity ja
               LEFT JOIN msdb.sysjobhistory jh   ON ja.job_history_id = jh.instance_id
               JOIN msdb.sysjobs j   ON ja.job_id = j.job_id
               JOIN msdb.sysjobsteps js   ON ja.job_id = js.job_id
               AND NVL(ja.last_executed_step_id, 0) + 1 = js.step_id
       WHERE  ja.session_id = ( SELECT session_id 
                                FROM msdb.syssessions 
                                  ORDER BY agent_start_date DESC
                                  FETCH FIRST 1 ROWS ONLY )
                AND start_execution_date IS NOT NULL
                AND stop_execution_date IS NULL;
   OPEN  v_cursor FOR
      SELECT NAME RunningJob  ,
             STATUS JobStatus  ,
             'RunningJob' TableName  
        FROM tt_temp2_15 A
               JOIN ACLAllJobsDetail B   ON A.NAME = B.JobName
       WHERE  B.JobName NOT LIKE '%RetryJobForFrontEnd%' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSELECTION_24072023" TO "ADF_CDR_RBL_STGDB";
