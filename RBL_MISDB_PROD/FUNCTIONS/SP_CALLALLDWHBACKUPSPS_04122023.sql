--------------------------------------------------------
--  DDL for Function SP_CALLALLDWHBACKUPSPS_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" 
(
  v_UserId IN VARCHAR2 DEFAULT ' ' ,
  v_DateOfJob IN VARCHAR2 DEFAULT ' ' ,
  v_JobName IN VARCHAR2 DEFAULT ' ' ,
  v_IP_Address IN VARCHAR2 DEFAULT ' ' ,
  v_BackACLProcEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103) );
   v_ProcessingDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_temp NUMBER(1, 0) := 0;
--DECLARE
--	 @UserId				VARCHAR(20)     = 'C33228'
--	,@DateOfJob				VARCHAR(10)		= '05/07/2023'
--	,@JobName				VARCHAR(100)	= 'DWHBackup,UploadDWHBackup'
--	,@IP_Address			VARCHAR(20)     = '10.05.2.10'
--	,@BackACLProcEntityId	INT				= 60
--	,@Result				INT             = 0  --OUTPUT

BEGIN

   IF utils.object_id('TEMPDB..tt_TEMP_33') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_33 ';
   END IF;
   DELETE FROM tt_TEMP_33;
   INSERT INTO tt_TEMP_33
     ( UserId, JobName, DateOfJob, IP_Address, BackACLProcEntityId )
     ( SELECT v_UserId UserId  ,
              VALUE JobName  ,
              UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103) DateofJob  ,
              v_IP_Address IP_Address  ,
              v_BackACLProcEntityId BackACLProcEntityId  
       FROM TABLE(STRING_SPLIT(v_JobName, ','))  );
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM BackdatedProcMonitorStatus 
                       WHERE  BackdatedProcStatus = 'InProgress' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      v_Result := -4 ;
      RETURN v_Result;

   END;
   END IF;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_MISDB_PROD.BackdatedProcMonitorStatus ';
   --IF (@JobName='DWHBackup') 
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'DWHBackup' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('DWHBackup');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'DWHBackup' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      DWH_STG.SP_DWHBackupDaily() ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 1, 'DWHBackup', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'DWHBackup';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='UploadDWHBackup')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'UploadDWHBackup' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('LoadDWHBackup');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'UploadDWHBackup' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      DWH_STG.SP_LoadBackupDataInDWHMain(v_DateOfJob) ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 2, 'UploadDWHBackup', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'UploadDWHBackup';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='GoldMaster')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'GoldMaster' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('GoldMasterInsert');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'GoldMaster' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      GoldMasterInsertData() ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 3, 'GoldMaster', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'GoldMaster';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='ExpireRecords') 
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'ExpireRecords' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ExpireRecords');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'ExpireRecords' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      --EXEC ExpireRecords @DateOfJob      
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 4, 'ExpireRecords', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'ExpireRecords';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='DeletePackageAudit')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'DeletePackageAudit' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('PackageAuditDelete');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'DeletePackageAudit' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      DeletePackageAudit() ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 5, 'DeletePackageAudit', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'DeletePackageAudit';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='UpdateTimeKey')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'UpdateTimeKey' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('Update Timekey');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'UpdateTimeKey' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      DBMS_OUTPUT.PUT_LINE('sohel 1');
      UPDATE Automate_Advances
         SET EXT_FLG = 'N'
       WHERE  EXT_FLG = 'Y';
      UPDATE Automate_Advances
         SET EXT_FLG = 'Y'
       WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103);
      DBMS_OUTPUT.PUT_LINE('sohel 2');
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 6, 'UpdateTimeKey', v_UserId, SYSDATE );
      DBMS_OUTPUT.PUT_LINE('sohel 3');
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'UpdateTimeKey';
      DBMS_OUTPUT.PUT_LINE('sohel 4');
      v_Result := 1 ;
      DBMS_OUTPUT.PUT_LINE('sohel 5');

   END;
   END IF;
   --ELSE IF (@JobName='DeleteReverseFeedData')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'DeleteReverseFeedData' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('DeleteReverseFeedData');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'DeleteReverseFeedData' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      SP_DeleteReverseFeedData(v_DateOfJob) ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 7, 'DeleteReverseFeedData', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'DeleteReverseFeedData';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='DWHFinacleAccountInsert')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'DWHFinacleAccountInsert' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('DWHFinacleAccountInsert');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'DWHFinacleAccountInsert' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      SP_InsertDWH_FinaclAccountData(v_DateOfJob) ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 8, 'DWHFinacleAccountInsert', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'DWHFinacleAccountInsert';
      v_Result := 1 ;

   END;
   END IF;
   --ELSE IF (@JobName='InsertBuyOutDataIntoStageDB')
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM tt_TEMP_33 
                       WHERE  BackACLProcEntityId = v_BackACLProcEntityId
                                AND JobName = 'InsertBuyOutDataIntoStageDB' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('InsertBuyOutDataIntoStageDB');
      INSERT INTO RBL_MISDB_PROD.BackdatedProcMonitorStatus
        ( UserID, BackdatedProcStep, BackdatedProcStatus, BackdatedProcDateTime, ProcessingStartTime, TimeKey, BackACLProcEntityId )
        ( SELECT USER ,
                 'InsertBuyOutDataIntoStageDB' ,
                 'InProgress' ,
                 v_ProcessingDate ,
                 SYSDATE ,
                 v_TIMEKEY ,
                 v_BackACLProcEntityId 
            FROM DUAL  );
      SP_InsertBuyoutDataIntoStageDB(v_DateOfJob) ;
      INSERT INTO BackdatedTaskDetail
        ( BackACLProcEntityId, ActionExecutionDate, TaskId, TaskName, CreatedBy, DateCreated )
        VALUES ( v_BackACLProcEntityId, UTILS.CONVERT_TO_VARCHAR2(v_DateOfJob,200,p_style=>103), 9, 'InsertBuyOutDataIntoStageDB', v_UserId, SYSDATE );
      UPDATE RBL_MISDB_PROD.BackdatedProcMonitorStatus
         SET BackdatedProcStatus = 'Completed',
             ProcessingEndTime = SYSDATE
       WHERE  TIMEKEY = v_TIMEKEY
        AND BackACLProcEntityId = v_BackACLProcEntityId
        AND BackdatedProcStep = 'InsertBuyOutDataIntoStageDB';
      v_Result := 1 ;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE('Approve');
   UPDATE BackDatedACLProcDetail
      SET AuthorisationStatus = 'A',
          ApprovedBy = v_UserId,
          DateApproved = SYSDATE
    WHERE  EffectiveToTimeKey = 49999
     AND BackACLProcEntityId = v_BackACLProcEntityId
     AND AuthorisationStatus IN ( 'NP','MP' )
   ;
   DBMS_OUTPUT.PUT_LINE('Execute');
   UPDATE BackDatedACLProcDetail
      SET AuthorisationStatus = 'EX',
          ExecutedBy = v_UserId,
          DateExecuted = SYSDATE
    WHERE  EffectiveToTimeKey = 49999
     AND BackACLProcEntityId = v_BackACLProcEntityId
     AND AuthorisationStatus = 'A';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_CALLALLDWHBACKUPSPS_04122023" TO "ADF_CDR_RBL_STGDB";
