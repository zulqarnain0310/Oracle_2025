--------------------------------------------------------
--  DDL for Procedure RPT_006
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_006" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	08-04-2021
DISCRIPTION		:   ACL Process Summary
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_TimeKey IN NUMBER
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@TimeKey AS INT=25811
   v_Flag CHAR(5);
   v_Department VARCHAR2(10);
   v_AuthenFlag CHAR(5);
   v_Code VARCHAR2(10);
   v_BankCode NUMBER(10,0);
   v_CurDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey );
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT AuthenticationFlag() 

     INTO v_AuthenFlag
     FROM DUAL ;
   SELECT ADflag() 

     INTO v_Flag
     FROM DUAL ;
   IF v_Flag = 'Y' THEN

   BEGIN
      v_Department := (SUBSTR(v_MisLocation, 0, 2)) ;
      v_Code := (SUBSTR(v_MisLocation, -3, 3)) ;

   END;
   ELSE
      IF v_Flag = 'SQL' THEN

      BEGIN
         IF v_AuthenFlag = 'Y' THEN

         BEGIN
            SELECT UserLocation 

              INTO v_Department
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserName
                      AND EffectiveToTimeKey = 49999 
              FETCH FIRST 1 ROWS ONLY;
            SELECT UserLocationCode 

              INTO v_Code
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserName
                      AND EffectiveToTimeKey = 49999 
              FETCH FIRST 1 ROWS ONLY;

         END;
         ELSE
            IF v_AuthenFlag = 'N' THEN

            BEGIN
               v_Department := 'RO' ;
               v_Code := '07' ;

            END;
            END IF;
         END IF;

      END;
      END IF;
   END IF;
   SELECT BankAlt_Key 

     INTO v_BankCode
     FROM SysReportformat ;
   IF ( utils.object_id('tempdb..tt_DATA_3') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA_3 ';
   END IF;
   DELETE FROM tt_DATA_3;
   UTILS.IDENTITY_RESET('tt_DATA_3');

   INSERT INTO tt_DATA_3 ( 
   	SELECT CASE 
                WHEN Description = 'InsertDataforAssetClassfication' THEN 'Data Preparation Process'
                WHEN Description = 'Reference_Period_Calculation' THEN 'Flags Initialisation Process'
                WHEN Description = 'DPD_Calculation' THEN 'Default Computation Process'
                WHEN Description = 'Marking_InMonthMark_Customer_Account_level' THEN 'A/C Level Degradation Process'
                WHEN Description = 'Marking_FlgDeg_Degreason' THEN 'NPA Date Assignment Process'
                WHEN Description = 'MaxDPD_ReferencePeriod_Calculation' THEN 'Security Erosion Process & NPA Ageing Process'
                WHEN Description = 'NPA_Date_Calculation' THEN 'Customer Level NPA marking & NPA Date Assignment Process'
                WHEN Description = 'Update_AssetClass' THEN 'NPA Ageing Process'
                WHEN Description = 'NPA_Erosion_Aging' THEN 'Cross Portfolio Percolation Process'
                WHEN Description = 'Final_AssetClass_Npadate' THEN 'Upgradation Process'
                WHEN Description = 'Upgrade_Customer_Account' THEN 'Asset Class Validation Process through Control Scrips'
                WHEN Description = 'SMA_MARKING' THEN 'Provision Computation Process (RBI Norms)'
                WHEN Description = 'Marking_FlgPNPA' THEN 'Provision Computation Process (Bank Norms)'
                WHEN Description = 'Marking_NPA_Reason_NPAAccount' THEN 'Manual Confirmation (Daily MOC)'
                WHEN Description IN ( 'UpdateProvisionKey_AccountWise','UpdateNetBalance_AccountWise','GovtGuarAppropriation','SecurityAppropriation','UpdateUsedRV','ProvisionComputationSecured','GovtGurCoverAmount','UpdationProvisionComputationUnSecured','UpdationTotalProvision' )
                 THEN 'Provision Processing'
                WHEN Description IN ( 'Reverse Feed Data Preparation Process','Data Updation to Main Tables' )
                 THEN 'Reverse Feed Data Preparation Process'
                WHEN Description = 'InsertDataIntoHistTable' THEN 'InsertDataIntoHistTable'
           ELSE Description
              END ProcessName  ,
           StartTime ExecutionStartTime  ,
           EndTime ExecutionEndTime  ,
           TimeTaken_Sec TimeDuration_Sec  ,
           Mode_ ExecutionStatus  
   	  FROM PRO_RBL_MISDB_PROD.ProcessMonitor 
   	 WHERE  TimeKey = v_TimeKey );
   ----------------------Final Selection-----------
   OPEN  v_cursor FOR
      SELECT ProcessName ,
             MIN(ExecutionStartTime)  ExecutionStartTime  ,
             MAX(ExecutionEndTime)  ExecutionEndTime  ,
             utils.datediff('SS', MIN(ExecutionStartTime) , MAX(ExecutionEndTime) ) TimeDuration_Sec  ,
             ExecutionStatus 
        FROM tt_DATA_3 
        GROUP BY ProcessName,ExecutionStatus
        ORDER BY ExecutionStartTime ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA_3 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_006" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_006" TO "ADF_CDR_RBL_STGDB";
