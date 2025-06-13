--------------------------------------------------------
--  DDL for Procedure DASHBOARDRUN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DASHBOARDRUN" 
(
  v_Flag IN NUMBER
)
AS

BEGIN

   IF ( v_Flag = 1 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM RBL_MISDB_PROD.BANDAUDITSTATUS 
                          WHERE  StartDate = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200)
                                   AND BandName IN ( 'SourceToStage','StageToTemp','TempToMain' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE(2);
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET BandStatus = 'In Progress'
          WHERE  BandStatus = 'Failed';
         msdb.sp_start_job(u'ETLDataExtraction') ;

      END;
      ELSE

      BEGIN
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET StartDate = SYSDATE,
                CompletedCount = 0,
                BandStatus = 'Pending'
          WHERE  BandName IN ( 'SourceToStage','StageToTemp','TempToMain' )
         ;
         UPDATE BANDAUDITSTATUS
            SET StartDate = SYSDATE,
                CompletedCount = 0,
                BandStatus = 'Not Started'
          WHERE  BandName IN ( 'ASSET CLASSIFICATION' )
         ;
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET BandStatus = 'Started'
          WHERE  BandName = 'SourceToStage';
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET BandStatus = 'In Progress'
          WHERE  BandName = 'SourceToStage';
         msdb.sp_start_job(u'ETLDataExtraction') ;

      END;
      END IF;

   END;
   END IF;
   IF ( v_Flag = 2 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM BANDAUDITSTATUS 
                          WHERE  StartDate = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200)
                                   AND BandName IN ( 'ASSET CLASSIFICATION' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE(2);
         UPDATE BANDAUDITSTATUS
            SET StartDate = SYSDATE,
                CompletedCount = 1,
                BandStatus = 'Pending'
          WHERE  BandName IN ( 'ASSET CLASSIFICATION' )
         ;
         UPDATE BANDAUDITSTATUS
            SET BandStatus = 'Started'
          WHERE  BandName = 'ASSET CLASSIFICATION';
         UPDATE BANDAUDITSTATUS
            SET BandStatus = 'In Progress'
          WHERE  BandName = 'ASSET CLASSIFICATION';
         --EXEC msdb.dbo.sp_start_job N'RBL_Extraction' ;  
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET Completed = 'N'
          WHERE  id > 1;
         msdb.sp_start_job(u'ETLDataExtraction') ;
         UPDATE BANDAUDITSTATUS
            SET CompletedCount = CompletedCount + 1
          WHERE  BandName = 'ASSET CLASSIFICATION';
         UPDATE BANDAUDITSTATUS
            SET BandStatus = 'Completed'
          WHERE  BandName = 'ASSET CLASSIFICATION'
           AND TotalCount = CompletedCount;

      END;
      ELSE

      BEGIN
         UPDATE BANDAUDITSTATUS
            SET StartDate = SYSDATE,
                CompletedCount = 1,
                BandStatus = 'Pending'
          WHERE  BandName IN ( 'ASSET CLASSIFICATION' )
         ;
         UPDATE BANDAUDITSTATUS
            SET BandStatus = 'Started'
          WHERE  BandName = 'ASSET CLASSIFICATION';
         UPDATE BANDAUDITSTATUS
            SET BandStatus = 'In Progress'
          WHERE  BandName = 'ASSET CLASSIFICATION';
         --EXEC msdb.dbo.sp_start_job N'RBL_Extraction' ;  
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET Completed = 'N'
          WHERE  id > 1;
         msdb.sp_start_job(u'ETLDataExtraction') ;
         UPDATE BANDAUDITSTATUS
            SET CompletedCount = CompletedCount + 1
          WHERE  BandName = 'ASSET CLASSIFICATION';
         UPDATE BANDAUDITSTATUS
            SET BandStatus = 'Completed'
          WHERE  BandName = 'ASSET CLASSIFICATION'
           AND TotalCount = CompletedCount;-----------------------------------------
         /*
         DELETE FROM RBL_STGDB.dbo.Package_AUDIT WHERE Execution_date=CAST(GETDATE() As Date)

         DELETE FROM pro.ProcessMonitor WHERE CAST(StartTime as Date)=CAST(GETDATE() As Date)
         --------------------------

         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_STGDB','SourceToStageDB','Customer',GETDATE(),0
         UNION ALL
         Select GETDATE(),'RBL_STGDB','SourceToStageDB','Account1',GETDATE(),0
         UNION ALL
         Select GETDATE(),'RBL_STGDB','SourceToStageDB','Account2',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='Customer' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='Customer' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='SourceToStage'

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='Account1' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='Account1' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='SourceToStage'

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='Account2' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='Account2' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='SourceToStage'

         Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='SourceToStage' and TotalCount=CompletedCount

         -------------------

         Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='StageToTemp'

         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_TEMPDB','StageToTempDB','TempAdvAcBasicDetail',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='TempAdvAcBasicDetail' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='TempAdvAcBasicDetail' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='StageToTemp'


         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_TEMPDB','StageToTempDB','TempCustomerBasicDetail',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='TempCustomerBasicDetail' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='TempCustomerBasicDetail' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='StageToTemp'


         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_TEMPDB','StageToTempDB','TempAdvAcBalanceDetail',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='TempAdvAcBalanceDetail' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='TempAdvAcBalanceDetail' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='StageToTemp'

         Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='StageToTemp' and TotalCount=CompletedCount

         ----------------------------------


         Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='TempToMain'

         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_TEMPDB','TempToMainDB','AdvAcBasicDetail',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='AdvAcBasicDetail' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='AdvAcBasicDetail' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='TempToMain'


         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_TEMPDB','TempToMainDB','CustomerBasicDetail',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='CustomerBasicDetail' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='CustomerBasicDetail' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='TempToMain'


         Insert into RBL_STGDB.dbo.Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
         Select GETDATE(),'RBL_TEMPDB','TempToMainDB','AdvAcBalanceDetail',GETDATE(),0

         WAITFOR DELAY '00:00:30'

         Update RBL_STGDB.dbo.Package_AUDIT set ExecutionEndTime=GETDATE(),ExecutionStatus=1
         Where TableName='AdvAcBalanceDetail' 

         Update RBL_STGDB.dbo.Package_AUDIT set TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
         Where TableName='AdvAcBalanceDetail' 

         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='TempToMain'

         Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='TempToMain' and TotalCount=CompletedCount

         ----------------------------------



         ----------------------------------


         Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='ACL Degradation'

         INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
         SELECT ORIGINAL_LOGIN(),'Reference_Period_Calculation','RUNNING',GETDATE(),NULL,25864,1

         WAITFOR DELAY '00:00:30'


         UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE  TIMEKEY=25864 AND DESCRIPTION='REFERENCE_PERIOD_CALCULATION'


         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Degradation'


         INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
         SELECT ORIGINAL_LOGIN(),'DPD_Calculation','RUNNING',GETDATE(),NULL,25864,1

         WAITFOR DELAY '00:00:30'

         UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=25864 AND DESCRIPTION='DPD_Calculation'


         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Degradation'


         INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
         SELECT ORIGINAL_LOGIN(),'NPA_Date_Calculation','RUNNING',GETDATE(),NULL,25864,1

         WAITFOR DELAY '00:00:30'

         UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE  TIMEKEY=25864 AND DESCRIPTION='NPA_Date_Calculation'


         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Degradation'

         Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='ACL Degradation' and TotalCount=CompletedCount

         ----------------------------------


         Update BANDAUDITSTATUS set BandStatus='In Progress' where BandName='ACL Upgradation'

         INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
         SELECT ORIGINAL_LOGIN(),'Upgrade_Customer_Account','RUNNING',GETDATE(),NULL,25864,1

         WAITFOR DELAY '00:00:30'


         UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=25864 AND DESCRIPTION='Upgrade_Customer_Account'



         Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ACL Upgradation'


         Update BANDAUDITSTATUS set BandStatus='Completed' where BandName='ACL Upgradation' and TotalCount=CompletedCount

         ----------------------------------
         */

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DASHBOARDRUN" TO "ADF_CDR_RBL_STGDB";
