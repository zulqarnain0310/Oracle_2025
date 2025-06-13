--------------------------------------------------------
--  DDL for Procedure SQLJOBSDETAILS_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" 
(
  v_JobName IN VARCHAR2,
  v_StartDate IN VARCHAR2,
  v_EndDate IN VARCHAR2
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --SELECT JobName,JobStatus,RunDate,RunningStatus,'JobDetails' Tablename FROM (
   --select  B.name AS JOBNAME,case when B.enabled=1 then'ENABLED' ELSE 'DISABLES'END AS JOBSTATUS,A.RUN_DATE RunDate,CASE WHEN A.run_status=0 THEN 'FAILED'
   --															WHEN A.run_status=1 THEN 'SUCCEEDED'
   --															WHEN A.run_status=2 THEN 'RETRY'
   --															WHEN A.run_status=3 THEN 'CANCELED'
   --															WHEN A.run_status=4 THEN 'IN-PROGRESS'
   --															ELSE 'YetToStart'
   --															END RunningStatus
   --              ,ROW_NUMBER () OVER (PARTITION BY A.job_id ORDER BY A.RUN_DATE DESC,RUN_Time desc)RN
   --from           MSDB.DBO.sysjobs B
   --left join	   msdb.dbo.sysjobhistory A
   --ON             A.job_id=B.job_id
   --)A WHERE RN=1
   IF utils.object_id('TEMPDB..tt_Temp_115') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_115 ';
   END IF;
   DELETE FROM tt_Temp_115;
   UTILS.IDENTITY_RESET('tt_Temp_115');

   INSERT INTO tt_Temp_115 SELECT j.job_id ,
                                  j.NAME Jobname  ,
                                  ja.start_execution_date JobStartTime  ,
                                  ja.stop_execution_date JobStopTime  ,
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
   IF utils.object_id('TEMPDB..tt_JobStartEndTimeDesc_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_JobStartEndTimeDesc_2 ';
   END IF;
   DELETE FROM tt_JobStartEndTimeDesc_2;
   UTILS.IDENTITY_RESET('tt_JobStartEndTimeDesc_2');

   INSERT INTO tt_JobStartEndTimeDesc_2 SELECT sj.NAME JobName  ,
                                               sja.run_requested_date ,
                                               sja.start_execution_date JobStartTime  ,
                                               sja.stop_execution_Date JobStopTime  ,
                                               UTILS.CONVERT_TO_VARCHAR2(sja.stop_execution_Date - sja.start_execution_date,12,p_style=>114) Duration  
        FROM msdb.sysjobactivity sja
               JOIN msdb.sysjobs sj   ON sja.job_id = sj.job_id
       WHERE  sja.run_requested_date IS NOT NULL
                AND sj.NAME = 'ABC123'
        ORDER BY sja.run_requested_date DESC;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_JobStartEndTimeDesc_2 ';
   IF v_JobName = ' ' THEN

   BEGIN
      INSERT INTO tt_JobStartEndTimeDesc_2
        SELECT sj.NAME JobName  ,
               sja.run_requested_date ,
               sja.start_execution_date JobStartTime  ,
               sja.stop_execution_Date JobStopTime  ,
               UTILS.CONVERT_TO_VARCHAR2(sja.stop_execution_Date - sja.start_execution_date,12,p_style=>114) Duration  
          FROM msdb.sysjobactivity sja
                 JOIN msdb.sysjobs sj   ON sja.job_id = sj.job_id
         WHERE  sja.run_requested_date IS NOT NULL
                --AND				sj.name=@JobName

          ORDER BY sja.run_requested_date DESC;

   END;
   ELSE

   BEGIN
      INSERT INTO tt_JobStartEndTimeDesc_2
        SELECT sj.NAME JobName  ,
               sja.run_requested_date ,
               sja.start_execution_date JobStartTime  ,
               sja.stop_execution_Date JobStopTime  ,
               UTILS.CONVERT_TO_VARCHAR2(sja.stop_execution_Date - sja.start_execution_date,12,p_style=>114) Duration  
          FROM msdb.sysjobactivity sja
                 JOIN msdb.sysjobs sj   ON sja.job_id = sj.job_id
         WHERE  sja.run_requested_date IS NOT NULL
                  AND sj.NAME = v_JobName
          ORDER BY sja.run_requested_date DESC;

   END;
   END IF;
   IF utils.object_id('TEMPDB..tt_TMPJobStepCount_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TMPJobStepCount_2 ';
   END IF;
   DELETE FROM tt_TMPJobStepCount_2;
   UTILS.IDENTITY_RESET('tt_TMPJobStepCount_2');

   INSERT INTO tt_TMPJobStepCount_2 ( 
   	SELECT A.job_id ,
           A.Name JobName  ,
           COUNT(B.step_name)  JobStepCount  
   	  FROM msdb.sysjobs A
             JOIN msdb.sysjobsteps B   ON A.job_id = B.job_id

   	--AND A.name='TESTJOB'
   	GROUP BY A.job_id,A.NAME );
   IF utils.object_id('TEMPDB..tt_SQLJobStatus_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SQLJobStatus_2 ';
   END IF;
   DELETE FROM tt_SQLJobStatus_2;
   UTILS.IDENTITY_RESET('tt_SQLJobStatus_2');

   INSERT INTO tt_SQLJobStatus_2 SELECT JobName ,
                                        JobStatus ,
                                        RunDate ,
                                        RunningStatus ,
                                        TotalJobSteps ,
                                        CurrentJobStep ,
                                        'JobDetails' Tablename  
        FROM ( SELECT B.NAME JOBNAME  ,
                      CASE 
                           WHEN B.ENABLED = 1 THEN 'ENABLED'
                      ELSE 'DISABLED'
                         END JOBSTATUS  ,
                      A.RUN_DATE RunDate  ,
                      CASE 
                           WHEN A.run_status = 0 THEN 'FAILED'
                           WHEN A.run_status = 1 THEN 'SUCCEEDED'
                           WHEN A.run_status = 2 THEN 'RETRY'
                           WHEN A.run_status = 3 THEN 'CANCELLED'
                           WHEN A.run_status = 4 THEN 'IN-PROGRESS'
                      ELSE 'YetToStart'
                         END RunningStatus  ,
                      D.JobStepCount TotalJobSteps  ,
                      CASE 
                           WHEN c.step_id IS NULL THEN '0'
                      ELSE c.step_id
                         END CurrentJobStep  ,
                      ROW_NUMBER() OVER ( PARTITION BY A.job_id ORDER BY A.RUN_DATE DESC, RUN_Time DESC  ) RN  
               FROM MSDB.sysjobs B
                      LEFT JOIN msdb.sysjobhistory A   ON A.job_id = B.job_id
                      LEFT JOIN tt_Temp_115 C   ON B.job_id = C.job_id
                      LEFT JOIN tt_TMPJobStepCount_2 D   ON B.NAME = D.JobName ) A
       WHERE  RN = 1;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.RunningStatus
   FROM A ,tt_SQLJobStatus_2 a
          JOIN tt_Temp_115 b   ON a.JOBNAME = b.Jobname ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.RunningStatus = src.RunningStatus;
   OPEN  v_cursor FOR
      SELECT A.* 
        FROM tt_SQLJobStatus_2 A
               JOIN ACLAllJobsDetail B   ON A.JOBNAME = B.JobName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --select *,'JobExecutionLogs' Tablename from JobLogsHistory
   --------------------------------------------------------History Start------------------------------------------------------------------------------------------------------------
   IF ( ( NVL(v_JobName, ' ') = ' ' )
     AND ( NVL(v_StartDate, ' ') = ' ' )
     AND ( NVL(v_EndDate, ' ') = ' ' ) ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('SATWAJI');
      OPEN  v_cursor FOR
         SELECT UserId ,
                RcaId ,
                JobName ,
                JobAction ,
                Remarks ,
                DateOfJob ,
                JobFinishTime ,
                IP_Address ,
                AttachedFilePath ,
                ActionResult ,
                ErrorMessage ,
                OriginatorEmpId ,
                RequestDate ,
                ApproverId ,
                ApproveDate ,
                DateofData ,
                Tablename 
           FROM ( SELECT * ,
                         ROW_NUMBER() OVER ( PARTITION BY UserId, JobName, JobAction, DateOfJob ORDER BY JobFinishTime DESC, UserId, JobName, JobAction  ) RN  
                  FROM ( SELECT --A.UserId
                          B.ExecutedBy UserId  ,
                          B.RCA_ID RcaId  ,
                          A.JobName ,
                          A.JobAction ,
                          B.Remarks ,
                          --,(CONVERT(VARCHAR(10),A.DateOfJob,103) +' '+ CONVERT(VARCHAR,A.DateOfJob,108)) DateOfJob 
                          (UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,30,p_style=>108)) DateOfJob  ,
                          --,(CONVERT(VARCHAR(10),C.JobStopTime,103) +' '+ CONVERT(VARCHAR,C.JobStopTime,108)) AS JobFinishTime
                          C.JobStopTime JobFinishTime  ,
                          A.IP_Address ,
                          A.AttachedFilePath ,
                          A.ActionResult ,
                          A.ErrorMessage ,
                          B.CreatedBy OriginatorEmpId  ,
                          (UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,30,p_style=>108)) RequestDate  ,
                          B.ApprovedBy ApproverId  ,
                          (UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,30,p_style=>108)) ApproveDate  ,
                          UTILS.CONVERT_TO_VARCHAR2(B.DateofData,10,p_style=>103) DateofData  ,
                          'JobExecutionLogs' Tablename  
                         FROM JobLogsHistory A
                                LEFT JOIN ACLJobExecDetail B   ON A.ACLJobExecEntityId = B.ACLJobExecEntityId
                                LEFT JOIN tt_JobStartEndTimeDesc_2 C   ON A.JobName = C.Jobname
                          WHERE  B.EffectiveToTimeKey = 49999 ) 
                       --ORDER BY convert(datetime,B.DateExecuted,105) DESC,6 DESC
                       A ) AA
          WHERE  RN = 1
           ORDER BY UTILS.CONVERT_TO_DATETIME(DateOfJob,p_style=>105) DESC,
                    6 DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      --where          convert(date,DateOfJob,103) >= convert(date,@StartDate,103)
      --and            convert(date,DateOfJob,103) <= convert(date,@EndDate,103)
      --and            JobName=@JobName
      DBMS_OUTPUT.PUT_LINE('SATWAJI1');

   END;
   ELSE
      IF ( ( NVL(v_JobName, ' ') = ' ' )
        AND ( NVL(v_StartDate, ' ') <> ' ' )
        AND ( NVL(v_EndDate, ' ') = ' ' ) ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SATWAJI2');
         OPEN  v_cursor FOR
            SELECT UserId ,
                   RcaId ,
                   JobName ,
                   JobAction ,
                   Remarks ,
                   DateOfJob ,
                   JobFinishTime ,
                   IP_Address ,
                   AttachedFilePath ,
                   ActionResult ,
                   ErrorMessage ,
                   OriginatorEmpId ,
                   RequestDate ,
                   ApproverId ,
                   ApproveDate ,
                   DateofData ,
                   Tablename 
              FROM ( SELECT * ,
                            ROW_NUMBER() OVER ( PARTITION BY UserId, JobName, JobAction, DateOfJob ORDER BY JobFinishTime DESC, UserId, JobName, JobAction  ) RN  
                     FROM ( SELECT --A.UserId
                             B.ExecutedBy UserId  ,
                             B.RCA_ID RcaId  ,
                             A.JobName ,
                             A.JobAction ,
                             B.Remarks ,
                             --,(CONVERT(VARCHAR(10),A.DateOfJob,103) +' '+ CONVERT(VARCHAR,A.DateOfJob,108)) DateOfJob
                             (UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,30,p_style=>108)) DateOfJob  ,
                             --,(CONVERT(VARCHAR(10),C.JobStopTime,103) +' '+ CONVERT(VARCHAR,C.JobStopTime,108)) AS JobFinishTime
                             C.JobStopTime JobFinishTime  ,
                             A.IP_Address ,
                             A.AttachedFilePath ,
                             A.ActionResult ,
                             A.ErrorMessage ,
                             B.CreatedBy OriginatorEmpId  ,
                             (UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,30,p_style=>108)) RequestDate  ,
                             B.ApprovedBy ApproverId  ,
                             (UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,30,p_style=>108)) ApproveDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(B.DateofData,10,p_style=>103) DateofData  ,
                             'JobExecutionLogs' Tablename  
                            FROM JobLogsHistory A
                                   LEFT JOIN ACLJobExecDetail B   ON A.ACLJobExecEntityId = B.ACLJobExecEntityId
                                   LEFT JOIN tt_JobStartEndTimeDesc_2 C   ON A.JobName = C.Jobname
                             WHERE  B.EffectiveToTimeKey = 49999
                                      AND UTILS.CONVERT_TO_VARCHAR2(A.DateOfJob,200,p_style=>103) = UTILS.CONVERT_TO_VARCHAR2(v_StartDate,200,p_style=>103) ) 
                          --and			convert(date,DateOfJob,103) <= convert(date,@EndDate,103)

                          --ORDER BY convert(datetime,B.DateExecuted,105) DESC,6 DESC

                          --and            JobName=@JobName
                          A ) AA
             WHERE  RN = 1
              ORDER BY UTILS.CONVERT_TO_DATETIME(DateOfJob,p_style=>105) DESC,
                       6 DESC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         DBMS_OUTPUT.PUT_LINE('SATWAJI3');

      END;
      ELSE
         IF ( ( NVL(v_JobName, ' ') = ' ' )
           AND ( NVL(v_StartDate, ' ') = ' ' )
           AND ( NVL(v_EndDate, ' ') <> ' ' ) ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SATWAJI4');
            OPEN  v_cursor FOR
               SELECT UserId ,
                      RcaId ,
                      JobName ,
                      JobAction ,
                      Remarks ,
                      DateOfJob ,
                      JobFinishTime ,
                      IP_Address ,
                      AttachedFilePath ,
                      ActionResult ,
                      ErrorMessage ,
                      OriginatorEmpId ,
                      RequestDate ,
                      ApproverId ,
                      ApproveDate ,
                      DateofData ,
                      Tablename 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY UserId, JobName, JobAction, DateOfJob ORDER BY JobFinishTime DESC, UserId, JobName, JobAction  ) RN  
                        FROM ( SELECT --A.UserId
                                B.ExecutedBy UserId  ,
                                B.RCA_ID RcaId  ,
                                A.JobName ,
                                A.JobAction ,
                                B.Remarks ,
                                --,(CONVERT(VARCHAR(10),A.DateOfJob,103) +' '+ CONVERT(VARCHAR,A.DateOfJob,108)) DateOfJob
                                (UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,30,p_style=>108)) DateOfJob  ,
                                --,(CONVERT(VARCHAR(10),C.JobStopTime,103) +' '+ CONVERT(VARCHAR,C.JobStopTime,108)) AS JobFinishTime
                                C.JobStopTime JobFinishTime  ,
                                A.IP_Address ,
                                A.AttachedFilePath ,
                                A.ActionResult ,
                                A.ErrorMessage ,
                                B.CreatedBy OriginatorEmpId  ,
                                (UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,30,p_style=>108)) RequestDate  ,
                                B.ApprovedBy ApproverId  ,
                                (UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,30,p_style=>108)) ApproveDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(B.DateofData,10,p_style=>103) DateofData  ,
                                'JobExecutionLogs' Tablename  
                               FROM JobLogsHistory A
                                      LEFT JOIN ACLJobExecDetail B   ON A.ACLJobExecEntityId = B.ACLJobExecEntityId
                                      LEFT JOIN tt_JobStartEndTimeDesc_2 C   ON A.JobName = C.Jobname
                                WHERE  B.EffectiveToTimeKey = 49999
                                         AND UTILS.CONVERT_TO_VARCHAR2(A.DateOfJob,200,p_style=>103) = UTILS.CONVERT_TO_VARCHAR2(v_EndDate,200,p_style=>103) ) 
                             --AND convert(date,DateOfJob,103) = convert(date,@StartDate,103)

                             --and      convert(date,DateOfJob,103) <= convert(date,@EndDate,103)

                             --ORDER BY convert(datetime,B.DateExecuted,105) DESC,6 DESC

                             --and            JobName=@JobName
                             A ) AA
                WHERE  RN = 1
                 ORDER BY UTILS.CONVERT_TO_DATETIME(DateOfJob,p_style=>105) DESC,
                          6 DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            DBMS_OUTPUT.PUT_LINE('SATWAJI5');

         END;
         ELSE
            IF ( ( NVL(v_JobName, ' ') = ' ' )
              AND ( NVL(v_StartDate, ' ') <> ' ' )
              AND ( NVL(v_EndDate, ' ') <> ' ' ) ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SATWAJI6');
               OPEN  v_cursor FOR
                  SELECT UserId ,
                         RcaId ,
                         JobName ,
                         JobAction ,
                         Remarks ,
                         DateOfJob ,
                         JobFinishTime ,
                         IP_Address ,
                         AttachedFilePath ,
                         ActionResult ,
                         ErrorMessage ,
                         OriginatorEmpId ,
                         RequestDate ,
                         ApproverId ,
                         ApproveDate ,
                         DateofData ,
                         Tablename 
                    FROM ( SELECT * ,
                                  ROW_NUMBER() OVER ( PARTITION BY UserId, JobName, JobAction, DateOfJob ORDER BY JobFinishTime DESC, UserId, JobName, JobAction  ) RN  
                           FROM ( SELECT --A.UserId
                                   B.ExecutedBy UserId  ,
                                   B.RCA_ID RcaId  ,
                                   A.JobName ,
                                   A.JobAction ,
                                   B.Remarks ,
                                   --,(CONVERT(VARCHAR(10),A.DateOfJob,103) +' '+ CONVERT(VARCHAR,A.DateOfJob,108)) DateOfJob 
                                   (UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,30,p_style=>108)) DateOfJob  ,
                                   --,(CONVERT(VARCHAR(10),C.JobStopTime,103) +' '+ CONVERT(VARCHAR,C.JobStopTime,108)) AS JobFinishTime
                                   C.JobStopTime JobFinishTime  ,
                                   A.IP_Address ,
                                   A.AttachedFilePath ,
                                   A.ActionResult ,
                                   A.ErrorMessage ,
                                   B.CreatedBy OriginatorEmpId  ,
                                   (UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,30,p_style=>108)) RequestDate  ,
                                   B.ApprovedBy ApproverId  ,
                                   (UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,30,p_style=>108)) ApproveDate  ,
                                   UTILS.CONVERT_TO_VARCHAR2(B.DateofData,10,p_style=>103) DateofData  ,
                                   'JobExecutionLogs' Tablename  
                                  FROM JobLogsHistory A
                                         LEFT JOIN ACLJobExecDetail B   ON A.ACLJobExecEntityId = B.ACLJobExecEntityId
                                         LEFT JOIN tt_JobStartEndTimeDesc_2 C   ON A.JobName = C.Jobname
                                   WHERE  B.EffectiveToTimeKey = 49999
                                            AND UTILS.CONVERT_TO_VARCHAR2(A.DateOfJob,200,p_style=>103) >= UTILS.CONVERT_TO_VARCHAR2(v_StartDate,200,p_style=>103)
                                            AND UTILS.CONVERT_TO_VARCHAR2(A.DateOfJob,200,p_style=>103) <= UTILS.CONVERT_TO_VARCHAR2(v_EndDate,200,p_style=>103) ) 
                                --ORDER BY convert(datetime,B.DateExecuted,105) DESC,6 DESC

                                --and            JobName=@JobName
                                A ) AA
                   WHERE  RN = 1
                    ORDER BY UTILS.CONVERT_TO_DATETIME(DateOfJob,p_style=>105) DESC,
                             6 DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               DBMS_OUTPUT.PUT_LINE('SATWAJI7');

            END;
            ELSE
               IF ( ( NVL(v_JobName, ' ') <> ' ' )
                 AND ( NVL(v_StartDate, ' ') = ' ' ) ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('SATWAJI8');
                  OPEN  v_cursor FOR
                     SELECT UserId ,
                            RcaId ,
                            JobName ,
                            JobAction ,
                            Remarks ,
                            DateOfJob ,
                            JobFinishTime ,
                            IP_Address ,
                            AttachedFilePath ,
                            ActionResult ,
                            ErrorMessage ,
                            OriginatorEmpId ,
                            RequestDate ,
                            ApproverId ,
                            ApproveDate ,
                            DateofData ,
                            Tablename 
                       FROM ( SELECT * ,
                                     ROW_NUMBER() OVER ( PARTITION BY UserId, JobName, JobAction, DateOfJob ORDER BY JobFinishTime DESC, UserId, JobName, JobAction  ) RN  
                              FROM ( SELECT --A.UserId
                                      B.ExecutedBy UserId  ,
                                      B.RCA_ID RcaId  ,
                                      A.JobName ,
                                      A.JobAction ,
                                      B.Remarks ,
                                      --,(CONVERT(VARCHAR(10),A.DateOfJob,103) +' '+ CONVERT(VARCHAR,A.DateOfJob,108)) DateOfJob 
                                      (UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,30,p_style=>108)) DateOfJob  ,
                                      --,(CONVERT(VARCHAR(10),C.JobStopTime,103) +' '+ CONVERT(VARCHAR,C.JobStopTime,108)) AS JobFinishTime
                                      C.JobStopTime JobFinishTime  ,
                                      A.IP_Address ,
                                      A.AttachedFilePath ,
                                      A.ActionResult ,
                                      A.ErrorMessage ,
                                      B.CreatedBy OriginatorEmpId  ,
                                      (UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,30,p_style=>108)) RequestDate  ,
                                      B.ApprovedBy ApproverId  ,
                                      (UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,30,p_style=>108)) ApproveDate  ,
                                      UTILS.CONVERT_TO_VARCHAR2(B.DateofData,10,p_style=>103) DateofData  ,
                                      'JobExecutionLogs' Tablename  
                                     FROM JobLogsHistory A
                                            LEFT JOIN ACLJobExecDetail B   ON A.ACLJobExecEntityId = B.ACLJobExecEntityId
                                            LEFT JOIN tt_JobStartEndTimeDesc_2 C   ON A.JobName = C.Jobname
                                      WHERE  B.EffectiveToTimeKey = 49999

                                               --where          convert(date,DateOfJob,103) >= convert(date,@StartDate,103)

                                               --and            convert(date,DateOfJob,103) <= convert(date,@EndDate,103)
                                               AND A.JobName = v_JobName ) 
                                   --ORDER BY convert(datetime,B.DateExecuted,105) DESC,6 DESC
                                   A ) AA
                      WHERE  RN = 1
                       ORDER BY UTILS.CONVERT_TO_DATETIME(DateOfJob,p_style=>105) DESC,
                                6 DESC ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);
                  DBMS_OUTPUT.PUT_LINE('SATWAJI9');

               END;
               ELSE
                  IF ( ( NVL(v_JobName, ' ') <> ' ' )
                    AND ( NVL(v_StartDate, ' ') <> ' ' ) ) THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('SATWAJI10');
                     OPEN  v_cursor FOR
                        SELECT UserId ,
                               RcaId ,
                               JobName ,
                               JobAction ,
                               Remarks ,
                               DateOfJob ,
                               JobFinishTime ,
                               IP_Address ,
                               AttachedFilePath ,
                               ActionResult ,
                               ErrorMessage ,
                               OriginatorEmpId ,
                               RequestDate ,
                               ApproverId ,
                               ApproveDate ,
                               DateofData ,
                               Tablename 
                          FROM ( SELECT * ,
                                        ROW_NUMBER() OVER ( PARTITION BY UserId, JobName, JobAction, DateOfJob ORDER BY JobFinishTime DESC, UserId, JobName, JobAction  ) RN  
                                 FROM ( SELECT --A.UserId
                                         B.ExecutedBy UserId  ,
                                         B.RCA_ID RcaId  ,
                                         A.JobName ,
                                         A.JobAction ,
                                         B.Remarks ,
                                         --,(CONVERT(VARCHAR(10),A.DateOfJob,103) +' '+ CONVERT(VARCHAR,A.DateOfJob,108)) DateOfJob
                                         (UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateExecuted,30,p_style=>108)) DateOfJob  ,
                                         --,(CONVERT(VARCHAR(10),C.JobStopTime,103) +' '+ CONVERT(VARCHAR,C.JobStopTime,108)) AS JobFinishTime
                                         C.JobStopTime JobFinishTime  ,
                                         A.IP_Address ,
                                         A.AttachedFilePath ,
                                         A.ActionResult ,
                                         A.ErrorMessage ,
                                         B.CreatedBy OriginatorEmpId  ,
                                         (UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateCreated,30,p_style=>108)) RequestDate  ,
                                         B.ApprovedBy ApproverId  ,
                                         (UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(B.DateApproved,30,p_style=>108)) ApproveDate  ,
                                         UTILS.CONVERT_TO_VARCHAR2(B.DateofData,10,p_style=>103) DateofData  ,
                                         'JobExecutionLogs' Tablename  
                                        FROM JobLogsHistory A
                                               LEFT JOIN ACLJobExecDetail B   ON A.ACLJobExecEntityId = B.ACLJobExecEntityId
                                               LEFT JOIN tt_JobStartEndTimeDesc_2 C   ON A.JobName = C.Jobname
                                         WHERE  B.EffectiveToTimeKey = 49999
                                                  AND UTILS.CONVERT_TO_VARCHAR2(A.DateOfJob,200,p_style=>103) >= UTILS.CONVERT_TO_VARCHAR2(v_StartDate,200,p_style=>103)
                                                  AND UTILS.CONVERT_TO_VARCHAR2(A.DateOfJob,200,p_style=>103) <= UTILS.CONVERT_TO_VARCHAR2(v_EndDate,200,p_style=>103)
                                                  AND A.JobName = v_JobName ) 
                                      --ORDER BY convert(datetime,B.DateExecuted,105) DESC,6 DESC
                                      A ) AA
                         WHERE  RN = 1
                          ORDER BY UTILS.CONVERT_TO_DATETIME(DateOfJob,p_style=>105) DESC,
                                   6 DESC ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);
                     DBMS_OUTPUT.PUT_LINE('SATWAJI11');

                  END;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
   ---------------------------------------------------------------History End-----------------------------------------------------------------------------------
   --		--------- Display Running Jobs ----------
   --		SELECT j.name AS Job_Name,'Running' CurrentStatus,'CurrentStatus' AS TableName FROM msdb.dbo.sysjobactivity ja 
   --		LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id
   --		JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
   --		JOIN msdb.dbo.sysjobsteps js
   --		ON ja.job_id = js.job_id
   --		AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
   --		WHERE  ja.session_id = (
   --								 SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC
   --								 )
   --		AND start_execution_date is not null
   --		AND stop_execution_date is null
   IF utils.object_id('Tempdb..tt_temp2_12') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_12 ';
   END IF;
   DELETE FROM tt_temp2_12;
   UTILS.IDENTITY_RESET('tt_temp2_12');

   INSERT INTO tt_temp2_12 SELECT j.NAME ,
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
   --SELECT name AS JobName,Status JobStatus,'RunningJob' AS TableName  
   --FROM           tt_temp2_12 A
   --INNER JOIN     ACLAllJobsDetail B
   --ON             A.name=B.JobName
   OPEN  v_cursor FOR
      SELECT NAME RunningJob  ,
             STATUS JobStatus  ,
             'RunningJob' TableName  
        FROM tt_temp2_12 A
               JOIN ACLAllJobsDetail B   ON A.NAME = B.JobName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT Timekey ActiveTimeKey  
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) LiveTimeKeyDate  ,
             'LiveTimeKeyDetails' TableName  
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(date_of_data,10,p_style=>103) DWHFinacleDate  ,
                      'DWHFinacleDate' TableName  
        FROM DWH_DWH_STG.account_data_finacle  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--SELECT * FROM tt_JobStartEndTimeDesc_2
   --WHERE JobName LIKE '%TESTNEW%'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBSDETAILS_04122023" TO "ADF_CDR_RBL_STGDB";
