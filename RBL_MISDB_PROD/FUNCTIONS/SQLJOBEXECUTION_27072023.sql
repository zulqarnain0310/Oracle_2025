--------------------------------------------------------
--  DDL for Function SQLJOBEXECUTION_27072023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" 
(
  v_UserId IN VARCHAR2 DEFAULT ' ' ,
  v_ParameterKey IN NUMBER DEFAULT 0 ,
  v_ACLJobExecEntityId IN NUMBER DEFAULT 0 ,
  v_JobName IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  --,@Remarks				VARCHAR(500)    = ''
  v_IP_Address IN VARCHAR2 DEFAULT ' ' ,
  --,@AttachedFilePath	VARCHAR(500)    = ''
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   --BEGIN  TRY
   v_ErrorMessage VARCHAR2(500);
   --	@JobName VARCHAR(100)='insert_data_TestJob'
   v_JonbNameSTATUS VARCHAR2(50) := ( SELECT RUNNING_STATUS 
     FROM ( SELECT B.NAME JOBNAME  ,
                   CASE 
                        WHEN B.ENABLED = 1 THEN 'ENABLED'
                   ELSE 'DISABLED'
                      END JOBSTATUS  ,
                   A.RUN_DATE ,
                   CASE 
                        WHEN A.run_status = 0 THEN 'FAILED'
                        WHEN A.run_status = 1 THEN 'SUCCEEDED'
                        WHEN A.run_status = 2 THEN 'RETRY'
                        WHEN A.run_status = 3 THEN 'CANCELED'
                        WHEN A.run_status = 4 THEN 'IN-PROGRESS'
                   ELSE 'YetToStart'
                      END RUNNING_STATUS  ,
                   ROW_NUMBER() OVER ( PARTITION BY A.job_id ORDER BY A.RUN_DATE DESC  ) RN  
            FROM MSDB.sysjobs B
                   LEFT JOIN msdb.sysjobhistory A   ON A.job_id = B.job_id ) A
    WHERE  RN = 1
             AND JOBNAME = v_jobname );
   v_temp NUMBER(1, 0) := 0;
   --------------------------------------------------------------------------------------------------------	
   v_job_id VARCHAR2(500);

BEGIN

   -- from		  msdb.dbo.sysjobhistory A
   DBMS_OUTPUT.PUT_LINE(v_JonbNameSTATUS);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE 1 = ( SELECT COUNT(1)  
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
                             AND stop_execution_date IS NULL
                             AND J.NAME = v_JobName );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('SET JonbNameSTATUS In-Progress');
      v_JonbNameSTATUS := 'In-Progress' ;

   END;
   END IF;
   --select @status as JobStatus
   DBMS_OUTPUT.PUT_LINE(v_JonbNameSTATUS);
   DBMS_OUTPUT.PUT_LINE('ROOPALI');
   SELECT job_id 

     INTO v_job_id
     FROM msdb.sysjobs 
    WHERE  NAME = v_JobName;
   --------------------------------------------------------------------------------------------------------------
   IF v_ParameterKey = 3 THEN

   BEGIN
      IF v_JonbNameSTATUS <> 'IN-PROGRESS' THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('JOB START');
         msdb.sp_start_job(v_JobName) ;-- 'insert_data_TestJob'
         --SET @Result=1
         --RETURN @Result 
         IF ( v_OperationFlag = 22 ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Approve');
            UPDATE ACLJobExecDetail
               SET AuthorisationStatus = 'A',
                   ApprovedBy = v_UserId,
                   DateApproved = SYSDATE
             WHERE  EffectiveToTimeKey = 49999
              AND ACLJobExecEntityId = v_ACLJobExecEntityId
              AND AuthorisationStatus IN ( 'NP','MP' )
            ;
            DBMS_OUTPUT.PUT_LINE('Execute');
            UPDATE ACLJobExecDetail
               SET AuthorisationStatus = 'EX',
                   ExecutedBy = v_UserId,
                   DateExecuted = SYSDATE
             WHERE  EffectiveToTimeKey = 49999
              AND ACLJobExecEntityId = v_ACLJobExecEntityId
              AND AuthorisationStatus = 'A';

         END;
         END IF;
         --GOTO INSERT1
         --SELECTRETURN3:
         v_Result := 1 ;

      END;

      --RETURN @Result
      ELSE

      BEGIN
         --set @ErrorMessage=ERROR_MESSAGE()
         --GOTO TrasnferIN
         --   TrasnferOUT:
         v_Result := -3 ;
         RETURN v_Result;

      END;
      END IF;

   END;

   --END TRY

   --BEGIN CATCH

   --	INSERT INTO dbo.Error_Log

   --		SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber

   --		,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState

   --		,GETDATE()

   --	set @ErrorMessage= ERROR_MESSAGE()

   --	--RETURN -1

   --	--set @Result=-1

   --	--RETURN @Result

   --END CATCH
   ELSE
      IF v_ParameterKey = 1 THEN

      BEGIN
         --IF @JonbNameSTATUS<>'IN-PROGRESS'
         --BEGIN
         DBMS_OUTPUT.PUT_LINE('JOB ENABLE');
         msdb.sp_update_job(v_job_name => v_JobName -- N'insert_data_TestJob',
                            ,
                            v_enabled => 1) ;
         IF ( v_OperationFlag = 22 ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Approve');
            UPDATE ACLJobExecDetail
               SET AuthorisationStatus = 'A',
                   ApprovedBy = v_UserId,
                   DateApproved = SYSDATE
             WHERE  EffectiveToTimeKey = 49999
              AND ACLJobExecEntityId = v_ACLJobExecEntityId
              AND AuthorisationStatus IN ( 'NP','MP' )
            ;
            DBMS_OUTPUT.PUT_LINE('ENABLE');
            UPDATE ACLJobExecDetail
               SET AuthorisationStatus = 'EX',
                   ExecutedBy = v_UserId,
                   DateExecuted = SYSDATE
             WHERE  EffectiveToTimeKey = 49999
              AND ACLJobExecEntityId = v_ACLJobExecEntityId
              AND ACLJobExecStatus = 'ENABLE'
              AND AuthorisationStatus = 'A';

         END;
         END IF;
         --GOTO INSERT1
         --SELECTRETURN1:
         v_Result := 1 ;

      END;

      --RETURN @Result

      --END

      --ELSE 

      --BEGIN

      --	SET @Result=-1

      --	RETURN @Result

      --END

      --set @ErrorMessage= ERROR_MESSAGE()
      ELSE
         IF v_ParameterKey = 2 THEN

         BEGIN
            --IF @JonbNameSTATUS<>'IN-PROGRESS'
            --BEGIN
            DBMS_OUTPUT.PUT_LINE('JOB DISABLE');
            msdb.sp_update_job(v_job_name => v_JobName -- N'insert_data_TestJob',
                               ,
                               v_enabled => 0) ;
            IF ( v_OperationFlag = 22 ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Approve');
               UPDATE ACLJobExecDetail
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserId,
                      DateApproved = SYSDATE
                WHERE  EffectiveToTimeKey = 49999
                 AND ACLJobExecEntityId = v_ACLJobExecEntityId
                 AND AuthorisationStatus IN ( 'NP','MP' )
               ;
               DBMS_OUTPUT.PUT_LINE('DISABLE');
               UPDATE ACLJobExecDetail
                  SET AuthorisationStatus = 'EX',
                      ExecutedBy = v_UserId,
                      DateExecuted = SYSDATE
                WHERE  EffectiveToTimeKey = 49999
                 AND ACLJobExecEntityId = v_ACLJobExecEntityId
                 AND ACLJobExecStatus = 'DISABLE'

                 --AND CONVERT(DATE,ActionExecutionDate,103)=CONVERT(DATE,GETDATE(),103)
                 AND AuthorisationStatus = 'A';

            END;
            END IF;
            --GOTO INSERT1
            --SELECTRETURN2:
            v_Result := 1 ;

         END;

         --RETURN @Result

         --END

         --ELSE 

         --BEGIN

         --	SET @Result=-2

         --	RETURN @Result

         --END
         ELSE
            IF v_ParameterKey = 4 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(v_JonbNameSTATUS);
               IF v_JonbNameSTATUS = 'IN-PROGRESS' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(v_JonbNameSTATUS);
                  DBMS_OUTPUT.PUT_LINE('JOB STOP');
                  msdb.sp_STOP_job(v_job_name => v_JobName) ;
                  IF ( v_OperationFlag = 22 ) THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('Approve');
                     UPDATE ACLJobExecDetail
                        SET AuthorisationStatus = 'A',
                            ApprovedBy = v_UserId,
                            DateApproved = SYSDATE
                      WHERE  EffectiveToTimeKey = 49999
                       AND ACLJobExecEntityId = v_ACLJobExecEntityId
                       AND AuthorisationStatus IN ( 'NP','MP' )
                     ;
                     DBMS_OUTPUT.PUT_LINE('STOP');
                     UPDATE ACLJobExecDetail
                        SET AuthorisationStatus = 'EX',
                            ExecutedBy = v_UserId,
                            DateExecuted = SYSDATE
                      WHERE  EffectiveToTimeKey = 49999
                       AND ACLJobExecEntityId = v_ACLJobExecEntityId
                       AND ACLJobExecStatus = 'STOP'

                       --AND CONVERT(DATE,ActionExecutionDate,103)=CONVERT(DATE,GETDATE(),103)
                       AND AuthorisationStatus = 'A';

                  END;
                  END IF;
                  --	GOTO INSERT1
                  --SELECTRETURN4:
                  v_Result := 1 ;

               END;

               --RETURN @Result
               ELSE

               BEGIN
                  --  print @JonbNameSTATUS
                  --PRINT 'JOB STOP'
                  --EXEC msdb.dbo.sp_STOP_job
                  --	@job_name=@JobName					-- N'insert_data_TestJob',
                  --@enabled=0
                  --SET @Result=1
                  --RETURN @Result
                  DBMS_OUTPUT.PUT_LINE('PRASHANT1');
                  v_Result := -4 ;
                  DBMS_OUTPUT.PUT_LINE('PRASHANT2');
                  RETURN v_Result;

               END;
               END IF;

            END;
            END IF;
         END IF;
      END IF;
   END IF;
   --END  TRY
   --  BEGIN CATCH
   --TrasnferIN:
   --INSERT1:
   INSERT INTO RBL_MISDB_PROD.Error_Log
     ( SELECT utils.error_line ErrorLine  ,
              SQLERRM ErrorMessage  ,
              SQLCODE ErrorNumber  ,
              utils.error_procedure ErrorProcedure  ,
              utils.error_severity ErrorSeverity  ,
              utils.error_state ErrorState  ,
              SYSDATE 
         FROM DUAL  );
   DBMS_OUTPUT.PUT_LINE('PRASHANT');
   SELECT ErrorMessage || '-' || UTILS.CONVERT_TO_VARCHAR2(RunDate,20) || 'Date-' || UTILS.CONVERT_TO_VARCHAR2(RunTime,20) || 'Time' 

     INTO v_ErrorMessage
     FROM ( SELECT B.NAME JobName  ,
                   A.MESSAGE ErrorMessage  ,
                   A.run_date RunDate  ,
                   A.run_time RunTime  ,
                   ROW_NUMBER() OVER ( PARTITION BY B.NAME ORDER BY B.NAME, A.run_date DESC, A.run_time DESC  ) Rn  
            FROM MSDB.sysjobhistory A
                   JOIN MSDB.sysjobs B   ON A.job_id = B.job_id
             WHERE  B.NAME = v_JobName --and A.message like '%failed%'
           ) A
    WHERE  rn = 1
             AND ErrorMessage LIKE '%failed%';
   IF v_Result > 0 THEN

   BEGIN
      IF v_ParameterKey <> 3 THEN

      BEGIN
         INSERT INTO JobLogsHistory
           ( ACLJobExecEntityId, UserId, JobName, JobAction, DateOfJob, IP_Address, ActionResult, ErrorMessage )
           VALUES ( v_ACLJobExecEntityId, v_UserId, v_JobName, CASE 
                                                                    WHEN v_ParameterKey = 3 THEN 'START JOB'
                                                                    WHEN v_ParameterKey = 1 THEN 'ENABLED JOB'
                                                                    WHEN v_ParameterKey = 2 THEN 'DISABLED JOB'
                                                                    WHEN v_ParameterKey = 4 THEN 'STOP JOB'   END, SYSDATE, v_IP_Address, 
         --case when @ErrorMessage is not null then 'FAILED' else 'SUCCESS' END,@ErrorMessage)
         'SUCCEEDED', NULL );

      END;
      ELSE

      BEGIN
         INSERT INTO JobLogsHistory
           ( ACLJobExecEntityId, UserId, JobName, JobAction, DateOfJob, IP_Address, ActionResult, ErrorMessage )
           VALUES ( v_ACLJobExecEntityId, v_UserId, v_JobName, CASE 
                                                                    WHEN v_ParameterKey = 3 THEN 'START JOB'
                                                                    WHEN v_ParameterKey = 1 THEN 'ENABLED JOB'
                                                                    WHEN v_ParameterKey = 2 THEN 'DISABLED JOB'
                                                                    WHEN v_ParameterKey = 4 THEN 'STOP JOB'   END, SYSDATE, v_IP_Address, 
         -- case when @ErrorMessage is not null then 'FAILED' else 'SUCCESS' END,@ErrorMessage)
         NULL, NULL );
         msdb.sp_start_job(RetryJobForFrontEnd) ;--IF @ParameterKey=3
         --	BEGIN
         --	   exec msdb.dbo.sp_start_job RetryJobForFrontEnd	
         --	END
         --GOTO TrasnferOUT
         --END CATCH
         --PRINT 'PRASHANT'
         --INSERT INTO JobLogsHistory(UserId,	JobName,	JobAction,	Remarks,	DateOfJob,	IP_Address,	AttachedFilePath,	ActionResult,	ErrorMessage)
         --values(@UserId,@JobName,case when @ParameterKey=3 then 'START JOB'
         --						     when @ParameterKey=1 then 'ENABLED JOB'
         --							 when @ParameterKey=2 then 'DISABLED JOB'
         --							 when @ParameterKey=4 then 'STOP JOB' END  , @Remarks,GETDATE(),@IP_Address,@AttachedFilePath,
         --							  case when @ErrorMessage is not null then 'FAILED' else 'SUCCESS' END,@ErrorMessage)
         --select *  from JobLogsHistory

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBEXECUTION_27072023" TO "ADF_CDR_RBL_STGDB";
