--------------------------------------------------------
--  DDL for Procedure MAINPROECESSFORASSETCLASSFICATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" /*================================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE :27-11-2019
DESCRIPTION : MAIN PROCESS FOR ASSET CLASSFIFCATION
--EXEC [PRO].[MAINPROECESSFORASSETCLASSFICATION]  @TIMEKEY=25841
=============================================================*/
AS
   /*------------------PROCESS START FOR ASSET CLASSFICATION------------------*/
   v_TIMEKEY NUMBER(10,0) ;
   v_SetID NUMBER(10,0) ;
   v_PROCESSDAY VARCHAR2(10) ;
   v_PROCESSMONTH VARCHAR2(200) ;
   v_temp NUMBER(1, 0) := 0;
--@TIMEKEY INT

BEGIN

    SELECT TIMEKEY INTO v_TIMEKEY
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;
   SELECT NVL(MAX(SETID) , 0) + 1 INTO v_SetID 
     FROM MAIN_PRO.ProcessMonitor 
    WHERE  TimeKey = v_TIMEKEY ;
    SELECT  utils.datename('WEEKDAY', ( SELECT MONTHFIRSTDATE 
                               FROM RBL_MISDB_PROD.SYSDATAMATRIX 
                                WHERE  TimeKey = v_TIMEKEY )) INTO v_PROCESSDAY FROM DUAL;
   SELECT MONTHFIRSTDATE INTO v_PROCESSMONTH 
     FROM RBL_MISDB_PROD.SYSDATAMATRIX 
    WHERE  TimeKey = v_TIMEKEY ;
   

   /*------------------REFERENCE PERIOD CALCULATION------------------*/
   DBMS_OUTPUT.PUT_LINE(1);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'InsertDataforAssetClassficationRBL' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Reference_Period_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Reference_Period_Calculation' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Reference_Period_Calculation(v_TIMEKEY => v_TIMEKEY) ;
      DELETE FROM MAIN_PRO.accountcal_bkp;
      UTILS.IDENTITY_RESET('MAIN_PRO.accountcal_bkp');

      INSERT INTO MAIN_PRO.accountcal_bkp 
        SELECT * 
           FROM GTT_accountcal ;
      DELETE FROM MAIN_PRO.CustomerCal_bkp;
      UTILS.IDENTITY_RESET('MAIN_PRO.CustomerCal_bkp');

      INSERT INTO MAIN_PRO.CustomerCal_bkp 
      SELECT * 
           FROM GTT_CustomerCal ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'REFERENCE_PERIOD_CALCULATION';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Reference_Period_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Reference_Period_Calculation' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'DPD_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      /*------------------DPD Calculation------------------*/
      DBMS_OUTPUT.PUT_LINE(2);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'DPD_Calculation' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.DPD_Calculation(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE  TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'DPD_Calculation';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'DPD_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------Marking_InMonthMark_Customer_Account_level------------------*/
   DBMS_OUTPUT.PUT_LINE(3);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'DPD_Calculation' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Marking_InMonthMark_Customer_Account_level' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Marking_InMonthMark_Customer_Account_level' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Marking_InMonthMark_Customer_Account_level(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE  TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Marking_InMonthMark_Customer_Account_level';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_InMonthMark_Customer_Account_level' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_InMonthMark_Customer_Account_level' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Marking_FlgDeg_Degreason' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      /*------------------Marking FlgDeg Degreason------------------*/
      DBMS_OUTPUT.PUT_LINE(4);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Marking_FlgDeg_Degreason' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Marking_FlgDeg_Degreason(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Marking_FlgDeg_Degreason';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_FlgDeg_Degreason' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_FlgDeg_Degreason' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'MaxDPD_ReferencePeriod_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      /*------------------MaxDPD REGARDING  ReferencePeriod Calculation------------------*/
      DBMS_OUTPUT.PUT_LINE(5);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'MaxDPD_ReferencePeriod_Calculation' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.MaxDPD_ReferencePeriod_Calculation(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'MaxDPD_ReferencePeriod_Calculation';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'MaxDPD_ReferencePeriod_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------NPA Date Calculation------------------*/
   DBMS_OUTPUT.PUT_LINE(6);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'MaxDPD_ReferencePeriod_Calculation' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'NPA_Date_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'NPA_Date_Calculation' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.NPA_Date_Calculation(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'NPA_Date_Calculation';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'NPA_Date_Calculation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------Update AssetClass------------------*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'NPA_Date_Calculation' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Update_AssetClass' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(7);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Update_AssetClass' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Update_AssetClass(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Update_AssetClass';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Update_AssetClass' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------NPA Erosion Aging------------------*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Update_AssetClass' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'NPA_Erosion_Aging' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(8);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'NPA_Erosion_Aging' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.NPA_Erosion_Aging(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'NPA_Erosion_Aging';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'NPA_Erosion_Aging' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------Final AssetClass Npadate------------------*/
   DBMS_OUTPUT.PUT_LINE(9);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'NPA_Erosion_Aging' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Final_AssetClass_Npadate' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Final_AssetClass_Npadate' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Final_AssetClass_Npadate(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE  TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Final_AssetClass_Npadate';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Final_AssetClass_Npadate' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPGRAD CUSTOMER ACCOUNT------------------*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Final_AssetClass_Npadate' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Upgrade_Customer_Account' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(10);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Upgrade_Customer_Account' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Upgrade_Customer_Account(v_TIMEKEY => v_TIMEKEY) ;
      --EXEC [PRO].[Recalculate_Balance_Again] @TIMEKEY=@TIMEKEY
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE  TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Upgrade_Customer_Account';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Upgrade_Customer_Account' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------MARKING SMA------------------*/
   DBMS_OUTPUT.PUT_LINE(11);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Upgrade_Customer_Account' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'SMA_MARKING' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'SMA_MARKING' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.SMA_MARKING(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'SMA_MARKING';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'SMA_MARKING' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------MARKING Marking_FlgPNPA------------------*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'SMA_MARKING' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Marking_FlgPNPA' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(12);
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Marking_FlgPNPA' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Marking_FlgPNPA(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Marking_FlgPNPA';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_FlgPNPA' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------Marking_NPA_Reason_NPAAccount------------------*/
   DBMS_OUTPUT.PUT_LINE(13);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_FlgPNPA' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'Marking_NPA_Reason_NPAAccount' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'Marking_NPA_Reason_NPAAccount' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.Marking_NPA_Reason_NPAAccount(v_TIMEKEY => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE  TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'Marking_NPA_Reason_NPAAccount';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_NPA_Reason_NPAAccount' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------Update PnpaAssetClassAlt_key------------------*/
   --IF (@PROCESSMONTH = EOMONTH(@PROCESSMONTH))
   --BEGIN
   --UPDATE PRO.ACCOUNTCAL SET PnpaAssetClassAlt_key = FINALASSETCLASSALT_KEY
   --UPDATE PRO.customercal SET PNPA_CLASS_KEY = SysAssetClassAlt_Key
   --END
   /*------------------End PnpaAssetClassAlt_key------------------*/
   /*------------------Update ProvisionKey AccountLevel------------------*/
   DBMS_OUTPUT.PUT_LINE(14);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'Marking_NPA_Reason_NPAAccount' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'UpdateProvisionKey_AccountWise' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
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
      MAIN_PRO.UPDATE_NPA_TYPE(v_TIMEKEY => v_TIMEKEY) ;
      MAIN_PRO.UpdateProvisionKey_AccountWise(v_TimeKey => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE  TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'UpdateProvisionKey_AccountWise';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdateProvisionKey_AccountWise' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE NET BALANCE AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(15);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdateProvisionKey_AccountWise' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'UpdateNetBalance_AccountWise' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
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
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'UpdateNetBalance_AccountWise';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdateNetBalance_AccountWise' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE Govt Guar Appropriation AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(16);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdateNetBalance_AccountWise' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'GovtGuarAppropriation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'GovtGuarAppropriation' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.GovtGuarAppropriation(v_TimeKey => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'GovtGuarAppropriation';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'GovtGuarAppropriation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE SecuritY AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(17);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'GovtGuarAppropriation' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'SecurityAppropriation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
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
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'SecurityAppropriation';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'SecurityAppropriation' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE USED RV  AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(18);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'SecurityAppropriation' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'UpdateUsedRV' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'UpdateUsedRV' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.UpdateUsedRV(v_TimeKey => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'UpdateUsedRV';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdateUsedRV' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE Provision Computation Secured AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(19);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdateUsedRV' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'ProvisionComputationSecured' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
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
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'ProvisionComputationSecured';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'ProvisionComputationSecured' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE GovtGurCoverAmount AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(20);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'ProvisionComputationSecured' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'GovtGurCoverAmount' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO MAIN_PRO.ProcessMonitor
        ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
        ( SELECT USER ,
                 'GovtGurCoverAmount' ,
                 'RUNNING' ,
                 SYSDATE ,
                 NULL ,
                 v_TIMEKEY ,
                 v_SetID 
            FROM DUAL  );
      MAIN_PRO.GovtGurCoverAmount(v_TimeKey => v_TIMEKEY) ;
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'GovtGurCoverAmount';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'GovtGurCoverAmount' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE UpdationProvisionComputationUnSecured AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(21);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'GovtGurCoverAmount' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'UpdationProvisionComputationUnSecured' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
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
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'UpdationProvisionComputationUnSecured';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdationProvisionComputationUnSecured' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------UPDATE UpdationProvisionComputationUnSecured AT ACCOUNT LEVEL------------------*/
   DBMS_OUTPUT.PUT_LINE(22);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdationProvisionComputationUnSecured' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'UpdationTotalProvision' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
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
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'UpdationTotalProvision';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdationTotalProvision' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;
   /*------------------INSERT DATA INTO HISTORY DATA------------------*/
   DBMS_OUTPUT.PUT_LINE(23);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'UpdationTotalProvision' ) = 'Y'
     AND ( SELECT Completed 
           FROM MAIN_PRO.AclRunningProcessStatus 
            WHERE  RunningProcessName = 'InsertDataIntoHistTable' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      --IF (@PROCESSMONTH = EOMONTH(@PROCESSMONTH))
      --BEGIN
      MAIN_PRO.InsertDataINTOHIST_TABLE_OPT(v_TIMEKEY => v_TIMEKEY) ;
      --END
      UPDATE MAIN_PRO.ProcessMonitor
         SET ENDTIME = SYSDATE,
             MODE_ = 'COMPLETE'
       WHERE TIMEKEY = v_TIMEKEY
        AND DESCRIPTION = 'InsertDataIntoHistTable';

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT Completed 
               FROM MAIN_PRO.AclRunningProcessStatus 
                WHERE  RunningProcessName = 'InsertDataIntoHistTable' ) = 'N';
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      RETURN;

   END;
   ELSE

   BEGIN
      --------------Added for DashBoard 04-03-2021
      UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
         SET CompletedCount = CompletedCount + 1
       WHERE  BandName = 'ASSET CLASSIFICATION';

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MAINPROECESSFORASSETCLASSFICATION" TO "ADF_CDR_RBL_STGDB";
