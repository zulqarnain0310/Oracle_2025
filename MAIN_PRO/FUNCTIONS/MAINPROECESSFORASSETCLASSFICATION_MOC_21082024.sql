--------------------------------------------------------
--  DDL for Function MAINPROECESSFORASSETCLASSFICATION_MOC_21082024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" 
-------------------------USE---RBL_MISDB-----------DATABASE------------

(
  iv_TIMEKEY IN NUMBER DEFAULT 25999 ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TIMEKEY NUMBER(10,0) := iv_TIMEKEY;--moc time key
   --DECLARE @ISMoc CHAR(1)= 'Y'
   --DECLARE @SetID INT=(SELECT MAX(SetID) FROM   PRO.ProcessMonitor_Moc)
   --SET @SetID=ISNULL(NULLIF(@SetID,0),1) +1
   --SET @TIMEKEY= (SELECT LastMonthDateKey FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)
   v_ISMoc CHAR(1) := 'Y';
   v_SetID NUMBER(10,0) := 1;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM SysDataMatrix 
                       WHERE  NVL(MOC_Initialised, 'N') = 'Y'
                                AND NVL(MOC_Frozen, 'N') = 'N' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      SELECT TimeKey 

        INTO v_TIMEKEY
        FROM SysDataMatrix 
       WHERE  NVL(MOC_Initialised, 'N') = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'There is no MOC Initialised Date available for MOC Process' 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN -1;

   END;
   END IF;
   BEGIN

      BEGIN
         ------------------InsertDataforAssetClassficationRBL_MOC------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'InsertDataforAssetClassficationRBL_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         INSERT INTO RBL_MISDB_PROD.MOCMonitorStatus
           ( UserID, MocMainSP, MocStatus, MocSubSP, MocStatusSub, TimeKey )
           ( SELECT USER ,
                    'MAINPROECESSFORASSETCLASSFICATION_MOC' ,
                    'InProgress' ,
                    'InsertDataforAssetClassficationRBL_MOC' ,
                    'InProgress' ,
                    v_TIMEKEY 
               FROM DUAL  );
         PRO_RBL_MISDB_PROD.InsertDataforAssetClassficationRBL_MOC(v_TimeKey) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('InsertDataforAssetClassficationRBL_MOC') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'InsertDataforAssetClassficationRBL_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'InsertDataforAssetClassficationRBL_MOC';
         ------------------DPD Calculation------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'DPD_Calculation_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'DPD_Calculation_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.DPD_Calculation(v_TIMEKEY => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('DPD_Calculation_MOC') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'DPD_Calculation_MOC'
           AND SETID = v_SETID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'DPD_Calculation_MOC';
         ------------------MaxDPD REGARDING  ReferencePeriod Calculation------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'MaxDPD_ReferencePeriod_Calculation_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'MaxDPD_ReferencePeriod_Calculation_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.MaxDPD_ReferencePeriod_Calculation(v_TIMEKEY => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('MaxDPD_ReferencePeriod_Calculation_MOC') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'MaxDPD_ReferencePeriod_Calculation_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'MaxDPD_ReferencePeriod_Calculation_MOC';
         ------------------NPA_Erosion_Aging_MOC------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'NPA_Erosion_Aging_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'NPA_Erosion_Aging_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.NPA_Erosion_Aging(v_TIMEKEY => v_TIMEKEY,
                                              v_FlgMoc => 'Y') ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('NPA_Erosion_Aging_MOC') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'NPA_Erosion_Aging_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'NPA_Erosion_Aging_MOC';
         ------------------Final_AssetClass_Npadate_moc------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Final_AssetClass_Npadate_moc' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'NPA_Erosion_Aging_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.Final_AssetClass_Npadate_MOC(v_TIMEKEY => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('Final_AssetClass_Npadate_moc') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'Final_AssetClass_Npadate_moc'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'Final_AssetClass_Npadate_moc';
         ------------------SMA_MARKING_MOC------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'SMA_MARKING_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'SMA_MARKING_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.SMA_MARKING(v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'SMA_MARKING_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'SMA_MARKING_MOC';
         ------------------UpdateProvisionKey_AccountWise_MOC------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdateProvisionKey_AccountWise_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'UpdateProvisionKey_AccountWise_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.UpdateProvisionKey_AccountWise(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdateProvisionKey_AccountWise_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'UpdateProvisionKey_AccountWise_MOC';
         ------------------UpdateNetBalance_AccountWise------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdateNetBalance_AccountWise_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'UpdateNetBalance_AccountWise_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.UpdateNetBalance_AccountWise(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdateNetBalance_AccountWise_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'UpdateNetBalance_AccountWise_MOC';
         ------------------GovtGuarAppropriation------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'GovtGuarAppropriation_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'GovtGuarAppropriation_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.GovtGuarAppropriation(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'GovtGuarAppropriation_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'GovtGuarAppropriation_MOC';
         ------------------SecurityAppropriation------------------
         --INSERT INTO PRO.ProcessMonitor_Moc(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
         --SELECT ORIGINAL_LOGIN(),'SecurityAppropriation_MOC','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID
         --EXEC  PRO.[SecurityAppropriation] @TIMEKEY=@TIMEKEY
         --UPDATE PRO.ProcessMonitor_Moc SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE TIMEKEY=@TIMEKEY AND DESCRIPTION='SecurityAppropriation_MOC' AND SETID=@SetID
         ------------------UpdateUsedRV_MOC------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdateUsedRV_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'UpdateUsedRV_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.UpdateUsedRV(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdateUsedRV_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'UpdateUsedRV_MOC';
         ------------------ProvisionComputationSecured------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'ProvisionComputationSecured_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'ProvisionComputationSecured_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.ProvisionComputationSecured(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'ProvisionComputationSecured_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'ProvisionComputationSecured_MOC';
         ------------------GovtGurCoverAmount------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'GovtGurCoverAmount_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'GovtGurCoverAmount_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.GovtGurCoverAmount(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'GovtGurCoverAmount_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'GovtGurCoverAmount_MOC';
         ------------------UpdationProvisionComputationUnSecured------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdationProvisionComputationUnSecured_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'UpdationProvisionComputationUnSecured_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.UpdationProvisionComputationUnSecured(v_TimeKey => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdationProvisionComputationUnSecured_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'UpdationProvisionComputationUnSecured_MOC';
         ------------------UpdationTotalProvision------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdationTotalProvision_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'UpdationTotalProvision_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.UpdationTotalProvision_Moc(v_TimeKey => v_TIMEKEY) ;---AMAR 29032023 FOR RESTR MOC CHANGES
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdationTotalProvision_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'UpdationTotalProvision_MOC';
         ------------------DataShiftingintoArchiveandPremocTable_MOC------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'DataShiftingintoArchiveandPremocTable_MOC' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'DataShiftingintoArchiveandPremocTable_MOC'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.DataShiftingintoArchiveandPremocTable(v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'DataShiftingintoArchiveandPremocTable_MOC'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'DataShiftingintoArchiveandPremocTable_MOC';
         -------------------------------------added by prashant-----------------28112023-----------------------------------
         UPDATE tt_AccountCal_26
            SET TotalProvision = 0
          WHERE  ( NVL(NetBalance, 0) <= 0
           OR NVL(TotalProvision, 0) <= 0 );
         ------------------PRO.UpdateDataInHistTable------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdateDataInHistTable' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'UpdateDataInHistTable'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.InsertDataINTOHIST_TABLE_OPT_MOC(v_TIMEKEY => v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdateDataInHistTable'
           AND SETID = v_SetID;
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'UpdateDataInHistTable';
         ------------------Cust_AccCal_Merge_Moc------------------
         INSERT INTO PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Cust_Acc_Merge_Moc' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'InProgress',
                MocSubSP = 'Cust_Acc_Merge_Moc'
          WHERE  TIMEKEY = v_TIMEKEY;
         PRO_RBL_MISDB_PROD.CustAccountMerge_MOC(v_TIMEKEY) ;
         UPDATE PRO_RBL_MISDB_PROD.PROCESSMONITOR_MOC
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'Cust_Acc_Merge_Moc';
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY
           AND MocSubSP = 'Cust_Acc_Merge_Moc';
         UPDATE RBL_MISDB_PROD.MOCMonitorStatus
            SET MocStatusSub = 'Completed',
                MocStatus = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.CUSTOMERCAL ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.ACCOUNTCAL ';
         /*TODO:SQLDEV*/ SET IDENTITY_INSERT PRO.CUSTOMERCAL ON /*END:SQLDEV*/
         INSERT INTO PRO_RBL_MISDB_PROD.CUSTOMERCAL
           ( EntityKey, BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, RBITotProvision, BankTotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, IsChanged, EntityKeyNew )
           ( SELECT EntityKey ,
                    BranchCode ,
                    UCIF_ID ,
                    UcifEntityID ,
                    CustomerEntityID ,
                    ParentCustomerID ,
                    RefCustomerID ,
                    SourceSystemCustomerID ,
                    CustomerName ,
                    CustSegmentCode ,
                    ConstitutionAlt_Key ,
                    PANNO ,
                    AadharCardNO ,
                    SrcAssetClassAlt_Key ,
                    SysAssetClassAlt_Key ,
                    SplCatg1Alt_Key ,
                    SplCatg2Alt_Key ,
                    SplCatg3Alt_Key ,
                    SplCatg4Alt_Key ,
                    SMA_Class_Key ,
                    PNPA_Class_Key ,
                    PrvQtrRV ,
                    CurntQtrRv ,
                    TotProvision ,
                    RBITotProvision ,
                    BankTotProvision ,
                    SrcNPA_Dt ,
                    SysNPA_Dt ,
                    DbtDt ,
                    DbtDt2 ,
                    DbtDt3 ,
                    LossDt ,
                    MOC_Dt ,
                    ErosionDt ,
                    SMA_Dt ,
                    PNPA_Dt ,
                    Asset_Norm ,
                    FlgDeg ,
                    FlgUpg ,
                    FlgMoc ,
                    FlgSMA ,
                    FlgProcessing ,
                    FlgErosion ,
                    FlgPNPA ,
                    FlgPercolation ,
                    FlgInMonth ,
                    FlgDirtyRow ,
                    DegDate ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CommonMocTypeAlt_Key ,
                    InMonthMark ,
                    MocStatusMark ,
                    SourceAlt_Key ,
                    BankAssetClass ,
                    Cust_Expo ,
                    MOCReason ,
                    AddlProvisionPer ,
                    FraudDt ,
                    FraudAmount ,
                    DegReason ,
                    CustMoveDescription ,
                    TotOsCust ,
                    MOCTYPE ,
                    IsChanged ,
                    EntityKeyNew 
             FROM tt_CUSTOMERCAL_40  );
         /*TODO:SQLDEV*/ SET IDENTITY_INSERT PRO.CUSTOMERCAL OFF /*END:SQLDEV*/
         /*TODO:SQLDEV*/ SET IDENTITY_INSERT PRO.ACCOUNTCAL ON /*END:SQLDEV*/
         INSERT INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL
           ( EntityKey, AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, UnserviedInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, DPD_IntService, DPD_NoCredit, DPD_Overdrawn, DPD_Overdue, DPD_Renewal, DPD_StockStmt, DPD_Max, DPD_FinMaxType, DPD_SMA, DPD_PrincOverdue, DPD_IntOverdueSince, DPD_OtherOverdueSince, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgFraud, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FraudDate, IsChanged, EntityKeyNew )
           ( SELECT EntityKey ,
                    AccountEntityID ,
                    UcifEntityID ,
                    CustomerEntityID ,
                    CustomerAcID ,
                    RefCustomerID ,
                    SourceSystemCustomerID ,
                    UCIF_ID ,
                    BranchCode ,
                    FacilityType ,
                    AcOpenDt ,
                    FirstDtOfDisb ,
                    ProductAlt_Key ,
                    SchemeAlt_key ,
                    SubSectorAlt_Key ,
                    SplCatg1Alt_Key ,
                    SplCatg2Alt_Key ,
                    SplCatg3Alt_Key ,
                    SplCatg4Alt_Key ,
                    SourceAlt_Key ,
                    ActSegmentCode ,
                    InttRate ,
                    Balance ,
                    BalanceInCrncy ,
                    CurrencyAlt_Key ,
                    DrawingPower ,
                    CurrentLimit ,
                    CurrentLimitDt ,
                    ContiExcessDt ,
                    StockStDt ,
                    DebitSinceDt ,
                    LastCrDate ,
                    PreQtrCredit ,
                    PrvQtrInt ,
                    CurQtrCredit ,
                    CurQtrInt ,
                    InttServiced ,
                    IntNotServicedDt ,
                    OverdueAmt ,
                    OverDueSinceDt ,
                    ReviewDueDt ,
                    SecurityValue ,
                    DFVAmt ,
                    GovtGtyAmt ,
                    CoverGovGur ,
                    WriteOffAmount ,
                    UnAdjSubSidy ,
                    CreditsinceDt ,
                    DegReason ,
                    Asset_Norm ,
                    REFPeriodMax ,
                    RefPeriodOverdue ,
                    RefPeriodOverDrawn ,
                    RefPeriodNoCredit ,
                    RefPeriodIntService ,
                    RefPeriodStkStatement ,
                    RefPeriodReview ,
                    NetBalance ,
                    ApprRV ,
                    SecuredAmt ,
                    UnSecuredAmt ,
                    ProvDFV ,
                    Provsecured ,
                    ProvUnsecured ,
                    ProvCoverGovGur ,
                    AddlProvision ,
                    TotalProvision ,
                    BankProvsecured ,
                    BankProvUnsecured ,
                    BankTotalProvision ,
                    RBIProvsecured ,
                    RBIProvUnsecured ,
                    RBITotalProvision ,
                    InitialNpaDt ,
                    FinalNpaDt ,
                    SMA_Dt ,
                    UpgDate ,
                    InitialAssetClassAlt_Key ,
                    FinalAssetClassAlt_Key ,
                    ProvisionAlt_Key ,
                    PNPA_Reason ,
                    SMA_Class ,
                    SMA_Reason ,
                    FlgMoc ,
                    MOC_Dt ,
                    CommonMocTypeAlt_Key ,
                    FlgDeg ,
                    FlgDirtyRow ,
                    FlgInMonth ,
                    FlgSMA ,
                    FlgPNPA ,
                    FlgUpg ,
                    FlgFITL ,
                    FlgAbinitio ,
                    NPA_Days ,
                    RefPeriodOverdueUPG ,
                    RefPeriodOverDrawnUPG ,
                    RefPeriodNoCreditUPG ,
                    RefPeriodIntServiceUPG ,
                    RefPeriodStkStatementUPG ,
                    RefPeriodReviewUPG ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    AppGovGur ,
                    UsedRV ,
                    ComputedClaim ,
                    UPG_RELAX_MSME ,
                    DEG_RELAX_MSME ,
                    PNPA_DATE ,
                    NPA_Reason ,
                    PnpaAssetClassAlt_key ,
                    DisbAmount ,
                    PrincOutStd ,
                    PrincOverdue ,
                    PrincOverdueSinceDt ,
                    IntOverdue ,
                    IntOverdueSinceDt ,
                    OtherOverdue ,
                    OtherOverdueSinceDt ,
                    RelationshipNumber ,
                    AccountFlag ,
                    CommercialFlag_AltKey ,
                    Liability ,
                    CD ,
                    AccountStatus ,
                    AccountBlkCode1 ,
                    AccountBlkCode2 ,
                    ExposureType ,
                    Mtm_Value ,
                    BankAssetClass ,
                    NpaType ,
                    SecApp ,
                    BorrowerTypeID ,
                    LineCode ,
                    ProvPerSecured ,
                    ProvPerUnSecured ,
                    MOCReason ,
                    AddlProvisionPer ,
                    FlgINFRA ,
                    RepossessionDate ,
                    DerecognisedInterest1 ,
                    DerecognisedInterest2 ,
                    ProductCode ,
                    FlgLCBG ,
                    UnserviedInt ,
                    OriginalBranchcode ,
                    AdvanceRecovery ,
                    NotionalInttAmt ,
                    PrvAssetClassAlt_Key ,
                    MOCTYPE ,
                    FlgSecured ,
                    DPD_IntService ,
                    DPD_NoCredit ,
                    DPD_Overdrawn ,
                    DPD_Overdue ,
                    DPD_Renewal ,
                    DPD_StockStmt ,
                    DPD_Max ,
                    DPD_FinMaxType ,
                    DPD_SMA ,
                    DPD_PrincOverdue ,
                    DPD_IntOverdueSince ,
                    DPD_OtherOverdueSince ,
                    RePossession ,
                    RCPending ,
                    PaymentPending ,
                    WheelCase ,
                    CustomerLevelMaxPer ,
                    FinalProvisionPer ,
                    IsIBPC ,
                    IsSecuritised ,
                    RFA ,
                    IsNonCooperative ,
                    Sarfaesi ,
                    WeakAccount ,
                    PUI ,
                    FlgFraud ,
                    FlgRestructure ,
                    RestructureDate ,
                    WeakAccountDate ,
                    SarfaesiDate ,
                    FlgUnusualBounce ,
                    UnusualBounceDate ,
                    FlgUnClearedEffect ,
                    UnClearedEffectDate ,
                    FraudDate ,
                    IsChanged ,
                    EntityKeyNew 
             FROM tt_AccountCal_26  );
         /*TODO:SQLDEV*/ SET IDENTITY_INSERT PRO.ACCOUNTCAL OFF /*END:SQLDEV*/
         ------------------------------------------------------
         -----------------ADDED BY PRASHANT----19122023------------
         -------------------------Added by Prashant 09-01-2023-----For DGU Report Post Moc flag--------------
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PostMOC_DGU_ReportFlag ';
         INSERT INTO PostMOC_DGU_ReportFlag
           VALUES ( UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200), 'Y' );
         -----------------------
         --	--SELECT 10
         v_Result := 1 ;
         RETURN 0;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      v_Result := -1 ;
      RETURN 0;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION_MOC_21082024" TO "ADF_CDR_RBL_STGDB";
