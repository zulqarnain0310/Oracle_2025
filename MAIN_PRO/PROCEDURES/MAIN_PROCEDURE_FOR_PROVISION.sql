--------------------------------------------------------
--  DDL for Procedure MAIN_PROCEDURE_FOR_PROVISION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" /*============================================================
	AUTHER : SANJEEV KUMAR SHARMA
	CREATE DATE : 21-11-2017
	MODIFY DATE : 21-11-2017
	DESCRIPTION : MAIN PROCESS FOR ASSET CLASSFIFCATION
	EXEC [PRO].[MAIN_PROCEDURE_FOR_PROVISION]  24864
=============================================================*/
(
  v_TIMEKEY IN NUMBER
)
AS
   /*--------------------PROCESS START FOR PROVISION--------------------------------------*/
   v_SetID NUMBER(10,0) ;
   v_temp NUMBER(1, 0) := 0;

BEGIN

    SELECT NVL(MAX(NVL(SETID, 0)) , 0) + 1 INTO v_SetID
     FROM MAIN_PRO.ProcessMonitor 
    WHERE  TimeKey = v_TIMEKEY ;
    
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM MAIN_PRO.ProcessMonitor 
                       WHERE  TimeKey = v_TIMEKEY );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DELETE MAIN_PRO.ProcessMonitor

       WHERE  TIMEKEY = v_TIMEKEY;

   END;
   END IF;
   /*-------------Getting DPD AccountWise NPADAYS-------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'Getting_DPD_AccountWise_NPADAYS' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   --MAIN_PRO.Getting_DPD_AccountWise_NPADAYS(v_TIMEKEY => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'Getting_DPD_AccountWise_NPADAYS';
   /*-------------Update ProvisionKey AccountWise------------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'UpdateProvisionKey_AccountWise' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.UpdateProvisionKey_AccountWise(v_TimeKey => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'UpdateProvisionKey_AccountWise';
   /*-------------Update NetBalance AccountWise------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'UpdateNetBalance_AccountWise' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.UpdateNetBalance_AccountWise(v_TimeKey => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'UpdateNetBalance_AccountWise';
   /*------------ Security Appropriation------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'SecurityAppropriation' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.SecurityAppropriation(v_TimeKey => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'SecurityAppropriation';
   /*-------------Provision Computation Secured-------------------------------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'ProvisionComputationSecured' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.ProvisionComputationSecured(v_TimeKey => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'ProvisionComputationSecured';
   /*-------------Updation Provision Computation UnSecured -------------------------------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'UpdationProvisionComputationUnSecured' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.UpdationProvisionComputationUnSecured(v_TimeKey => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'UpdationProvisionComputationUnSecured';
   /*----------------------------Updation Total Provision-------------------------------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'UpdationTotalProvision' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.UpdationTotalProvision(v_TimeKey => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'UpdationTotalProvision';
   /*----------------------------MARKING OF FLG PROCESS-------------------------------------------------------------------------------------*/
   INSERT INTO MAIN_PRO.ProcessMonitor
     ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
     ( SELECT USER ,
              'MarkingFlgProcessing' ,
              'RUNNING' ,
              SYSDATE ,
              NULL ,
              v_TIMEKEY ,
              v_SetID 
         FROM DUAL  );
   MAIN_PRO.MarkingFlgProcessing(v_TIMEKEY => v_TIMEKEY) ;
   UPDATE MAIN_PRO.ProcessMonitor
      SET ENDTIME = SYSDATE,
          MODE_ = 'COMPLETE'
    WHERE  TIMEKEY = v_TIMEKEY
     AND DESCRIPTION = 'MarkingFlgProcessing';/*-------------------------------------------------PROCESS END FOR PROVISION----------------------------------------------------------------*/

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAIN_PROCEDURE_FOR_PROVISION" TO "ADF_CDR_RBL_STGDB";
