--------------------------------------------------------
--  DDL for Procedure ACCELERATEDPROVISIONDATAPROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" /*==============================            
Author : TRILOKI KHANNA     
CREATE DATE : 27-11-2019            
MODIFY DATE : 27-11-2019           
DESCRIPTION : UPDATE TOTAL PROVISION            
--EXEC [PRO].[AcceleratedProvisionDataProc] @TimeKey =28380              
=========================================*/
(
  v_TimeKey IN NUMBER
)
AS

BEGIN

   BEGIN
      DECLARE
         v_DATE VARCHAR2(200);

      BEGIN
         SELECT Date_ INTO v_DATE
           FROM RBL_MISDB_PROD.Automate_Advances 
          WHERE  EXT_FLG = 'Y' ;
         /* START - UCIF/CUSTOMER/ACCOUNT LEVEL - ACCLERATED PROVISION WOKR */
         -- UPDATE A  
         --SET A.AddlProvision=ISNULL(A.AddlProvision,0)+ISNULL(B.AdditionalProvAcct,0)  
         ----- insert into PRO.AcceleratedProvCalc_Hist  
         --- select a.AccountEntityID, @TimeKey
         MERGE INTO MAIN_PRO.AcceleratedProvCalc B 
         USING (SELECT B.ROWID row_id, NVL(B.AdditionalProvAcct, 0) AS AcclrtdAddlprov
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AcceleratedProvCalc B   ON A.AccountEntityID = B.AccountEntityId
                JOIN RBL_MISDB_PROD.DimParameter C   ON C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
                AND C.ParameterAlt_Key = B.AcceProDuration
                AND C.DimParameterName = 'DimAccProvDuration' 
          WHERE B.ProvTypes = 'ACCT'
           AND C.ParameterShortName = 'AccProThro') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.AcclrtdAddlprov = src.AcclrtdAddlprov;
         /* Accelerated Provision Through-out  */
         --UPDATE A  
         -- SET A.AddlProvision= ISNULL(A.AddlProvision,0)+  
         --        ( ((ISNULL(A.SecuredAmt,0)*isnull(b.ProvisionSecured,0))/100) +  
         --         + ((ISNULL(A.UnSecuredAmt,0)*isnull(b.ProvisionUnSecured,0))/100))  
         --insert into PRO.AcceleratedProvCalc_Hist  
         --select a.AccountEntityID, @TimeKey,( ((ISNULL(A.SecuredAmt,0)*isnull(b.AdditionalProvision,0))/100) +  
         --         + ((ISNULL(A.UnSecuredAmt,0)*isnull(b.AdditionalProvision,0))/100))  
         MERGE INTO MAIN_PRO.AcceleratedProvCalc B
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN b.Secured_Unsecured = 'SECURED' THEN ((NVL(A.SecuredAmt, 0) * NVL(b.AdditionalProvision, 0)) / 100)
         ELSE 0
            END + +CASE 
         WHEN Secured_Unsecured = 'UNSECURED' THEN ((NVL(A.UnSecuredAmt, 0) * NVL(b.AdditionalProvision, 0)) / 100)
         ELSE 0
            END) AS AcclrtdAddlprov
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AcceleratedProvCalc B   ON A.AccountEntityID = B.AccountEntityId
                JOIN RBL_MISDB_PROD.DimParameter C   ON C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
                AND C.ParameterAlt_Key = B.AcceProDuration
                AND C.DimParameterName = 'DimAccProvDuration' 
          WHERE B.ProvTypes <> 'ACCT'
           AND C.ParameterShortName = 'AccProThro'
           AND a.FinalAssetClassAlt_Key IN ( 3,4 )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.AcclrtdAddlprov = src.AcclrtdAddlprov;
         MERGE INTO MAIN_PRO.AcceleratedProvCalc B
         USING (SELECT B.ROWID row_id, (((NVL(A.SecuredAmt, 0) * NVL(b.AdditionalProvision, 0)) / 100) + +((NVL(A.UnSecuredAmt, 0) * NVL(b.AdditionalProvision, 0)) / 100)) AS AcclrtdAddlprov
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AcceleratedProvCalc B   ON A.AccountEntityID = B.AccountEntityId
                JOIN RBL_MISDB_PROD.DimParameter C   ON C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
                AND C.ParameterAlt_Key = B.AcceProDuration
                AND C.DimParameterName = 'DimAccProvDuration' 
          WHERE B.ProvTypes <> 'ACCT'
           AND C.ParameterShortName = 'AccProThro'
           AND a.FinalAssetClassAlt_Key = 2) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE 
         --SET B.AcclrtdAddlprov=( case when b.Secured_Unsecured='SECURED' THEN ((ISNULL(A.SecuredAmt,0)*isnull(b.AdditionalProvision,0))/100) else 0 END +  

         --          + CASE WHEN Secured_Unsecured='UNSECURED' then ((ISNULL(A.UnSecuredAmt,0)*isnull(b.AdditionalProvision,0))/100) ELSE 0 END)  
         SET B.AcclrtdAddlprov = src.AcclrtdAddlprov;
         /* Accelerated Provision till IRAC  */
         --UPDATE A  
         --SET A.AddlProvision= ISNULL(A.AddlProvision,0)+  
         --    (((ISNULL(a.SecuredAmt,0)*((ISNULL(B.CurrentProvisionPer,0)+ISNULL(B.AdditionalProvision,0))-B.ProvisionSecured))/100)  
         --     + ((ISNULL(a.UnSecuredAmt,0)*((ISNULL(B.CurrentProvisionPer,0)+ISNULL(B.AdditionalProvision,0))-B.ProvisionUnSecured))/100)  
         --    )  
         --insert into PRO.AcceleratedProvCalc_Hist  
         --select a.AccountEntityID, @TimeKey,(((ISNULL(a.SecuredAmt,0)*((ISNULL(B.CurrentProvisionPer,0)+ISNULL(B.AdditionalProvision,0))-B.ProvisionSecured))/100)  
         --     + ((ISNULL(a.UnSecuredAmt,0)*((ISNULL(B.CurrentProvisionPer,0)+ISNULL(B.AdditionalProvision,0))-B.ProvisionUnSecured))/100)  
         --    )  
         MERGE INTO MAIN_PRO.AcceleratedProvCalc B
         USING (SELECT B.ROWID row_id, (((NVL(a.SecuredAmt, 0) * ((NVL(B.CurrentProvisionPer, 0) + NVL(B.AdditionalProvision, 0)) - B.ProvisionSecured)) / 100) + ((NVL(a.UnSecuredAmt, 0) * ((NVL(B.CurrentProvisionPer, 0) + NVL(B.AdditionalProvision, 0)) - B.ProvisionUnSecured)) / 100)) AS AcclrtdAddlprov
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AcceleratedProvCalc B   ON A.AccountEntityID = B.AccountEntityId
                JOIN RBL_MISDB_PROD.DimParameter C   ON C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
                AND C.ParameterAlt_Key = B.AcceProDuration
                AND C.DimParameterName = 'DimAccProvDuration' 
          WHERE B.ProvTypes <> 'ACCT'
           AND C.ParameterShortName = 'AccProtillIRAC'
           AND ( ( (NVL(B.CurrentProvisionPer, 0) + NVL(B.AdditionalProvision, 0)) > B.ProvisionSecured )
           OR ( (NVL(B.CurrentProvisionPer, 0) + NVL(B.AdditionalProvision, 0)) > B.ProvisionUnSecured ) )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.AcclrtdAddlprov = src.AcclrtdAddlprov;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.AddlProvision, 0) + NVL(AcclrtdAddlprov, 0) AS AddlProvision
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AcceleratedProvCalc B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvision = src.AddlProvision;
         INSERT INTO MAIN_PRO.AcceleratedProvCalc_hist
           ( SELECT * 
             FROM MAIN_PRO.AcceleratedProvCalc  );

      END;
   EXCEPTION
      WHEN OTHERS THEN

   DECLARE v_SQLERRM VARCHAR(1000):=SQLERRM;
   BEGIN
   
      /* END - UCIF/CUSTOMER/ACCOUNT LEVEL - ACCLERATED PROVISION WOKR */
      /* END ACCELERATED PROVISION BUCKET WISE */
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'UpdationTotalProvision';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPROC" TO "ADF_CDR_RBL_STGDB";
