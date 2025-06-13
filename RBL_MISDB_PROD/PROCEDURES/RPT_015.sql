--------------------------------------------------------
--  DDL for Procedure RPT_015
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_015" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	26-04-2021
DISCRIPTION		:   Base NPA Movement Report 
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_TimeKey IN NUMBER,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@TimeKey AS INT=25999
   --,@Cost    AS FLOAT=1
   v_Flag CHAR(5);
   v_Department VARCHAR2(10);
   v_AuthenFlag CHAR(5);
   v_Code VARCHAR2(10);
   v_BankCode NUMBER(10,0);
   v_PerQtrKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
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
   ---------------------------------------------Final Selection---------------------------
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(NPAProcessingDate,20,p_style=>103) Created_Date  ,
             Movement_Flag ,
             ' ' MOC_Date  ,
             CustomerAcid ,
             DACI.AssetClassGroup I_AssetClassGroup  ,
             UTILS.CONVERT_TO_VARCHAR2(NPADt,20,p_style=>103) NPADt  ,
             NVL(InitialNPABalance, 0) / v_Cost InitialNPABalance  ,
             NVL(InitialUnservicedInterest, 0) / v_Cost InitialUnservicedInterest  ,
             NVL(InitialGNPABalance, 0) / v_Cost InitialGNPABalance  ,
             NVL(InitialProvision, 0) / v_Cost InitialProvision  ,
             NVL(InitialNNPABalance, 0) / v_Cost InitialNNPABalance  ,
             NVL(ExistingNPA_Addition, 0) / v_Cost ExistingNPA_Addition  ,
             NVL(FreshNPA_Addition, 0) / v_Cost FreshNPA_Addition  ,
             NVL(ReductionDuetoUpgradeAmount, 0) / v_Cost ReductionDuetoUpgradeAmount  ,
             NVL(ReductionDuetoRecovery_ExistingNPA, 0) / v_Cost ReductionDuetoRecovery_ExistingNPA  ,
             NVL(ReductionDuetoWrite_OffAmount, 0) / v_Cost ReductionDuetoWrite_OffAmount  ,
             NVL(ReductionDuetoRecovery_Arcs, 0) / v_Cost ReductionDuetoRecovery_Arcs  ,
             DACF.AssetClassGroup F_AssetClassGroup  ,
             MovementNature ,
             NVL(FinalNPABalance, 0) / v_Cost FinalNPABalance  ,
             NVL(FinalUnservicedInterest, 0) / v_Cost FinalUnservicedInterest  ,
             NVL(FinalGNPABalance, 0) / v_Cost FinalGNPABalance  ,
             MovementStatus ,
             NVL(FinalProvision, 0) / v_Cost FinalProvision  ,
             NVL(FinalNNPABalance, 0) / v_Cost FinalNNPABalance  ,
             NVL(TotalAddition_GNPA, 0) / v_Cost TotalAddition_GNPA  ,
             NVL(TotalReduction_GNPA, 0) / v_Cost TotalReduction_GNPA  ,
             NVL(TotalAddition_Provision, 0) / v_Cost TotalAddition_Provision  ,
             NVL(TotalReduction_Provision, 0) / v_Cost TotalReduction_Provision  ,
             NVL(TotalAddition_UnservicedInterest, 0) / v_Cost TotalAddition_UnservicedInterest  ,
             NVL(TotalReduction_UnservicedInterest, 0) / v_Cost TotalReduction_UnservicedInterest  
        FROM NPAMovement NPAM
               LEFT JOIN AdvAcFinancialDetail ACFD   ON ACFD.RefSystemAcId = NPAM.CustomerACID
               AND ACFD.EffectiveFromTimeKey <= v_TimeKey
               AND ACFD.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass DACI   ON NPAM.InitialAssetClassAlt_Key = DACI.AssetClassAlt_Key
               AND DACI.EffectiveFromTimeKey <= v_TimeKey
               AND DACI.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass DACF   ON NPAM.FinalAssetClassAlt_Key = DACF.AssetClassAlt_Key
               AND DACF.EffectiveFromTimeKey <= v_TimeKey
               AND DACF.EffectiveToTimeKey >= v_TimeKey
       WHERE  Timekey = v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_015" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_015" TO "ADF_CDR_RBL_STGDB";
