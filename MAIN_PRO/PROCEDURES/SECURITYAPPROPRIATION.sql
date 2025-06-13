--------------------------------------------------------
--  DDL for Procedure SECURITYAPPROPRIATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."SECURITYAPPROPRIATION" /*=====================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : Security Appropriation MARKING
EXEC pro.SecurityAppropriation  @TIMEKEY=25410
====================================*/
(
  v_TimeKey IN NUMBER
)
AS

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
   BEGIN

      BEGIN
         -----------======================Fetching Security Data from  Customer Table================-----------------                    
         ----DELETE FROM SecurityDetails WHERE TIMEKEY =@TIMEKEY          
         ----INSERT INTO SecurityDetails          
         ----(          
         ----UCIF_ID,          
         ----TotalSecurity,          
         ----TIMEKEY          
         ----)          
         ----SELECT           
         ----UCIF_ID,          
         ----SUM(ISNULL(CurntQtrRv,0))TotalSecurity,          
         ----@TIMEKEY TIMEKEY          
         ----FROM           
         ----PRO.CUSTOMERCAL 
         ---- where  ISNULL(CurntQtrRv,0)>0                  
         ----GROUP BY UCIF_ID            
         ----      /*TempTableForSecurity  being create */                      
         ----IF OBJECT_ID('GTT_SECURITYDETAIL') IS NOT NULL                      
         ----DROP  TABLE GTT_SECURITYDETAIL                      
         ----SELECT UCIF_ID,SUM(ISNULL(TOTALSECURITY,0)) AS TOTALSECURITY INTO GTT_SECURITYDETAIL FROM SECURITYDETAILS                       
         ----WHERE TIMEKEY =@TIMEKEY                     
         ----GROUP BY UCIF_ID                      
         ----UPDATE  PRO.ACCOUNTCAL SET ApprRV=0                            
         ----;WITH CTE(UCIF_ID,TOTOSFUNDED)                    
         ----AS                    
         ----(                    
         ----SELECT B.UCIF_ID,SUM(ISNULL(A.NETBALANCE,0)) TOTOSFUNDED FROM  PRO.ACCOUNTCAL A    INNER JOIN PRO.CUSTOMERCAL B
         ---- ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                                 
         ----WHERE A.NETBALANCE>0  
         ----AND A.FlgAbinitio<>'Y'
         ----AND A.FinalAssetClassAlt_Key<>6
         ----AND A.FlgSecured='D'     
         ----GROUP BY B.UCIF_ID                  
         ----)                                          
         ----UPDATE D SET D.                                    
         ----ApprRV= CASE WHEN  ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY)>D.NETBALANCE THEN D.NETBALANCE       
         ----ELSE ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY) END                                           
         ----from CTE A inner join PRO.CustomerCal B on A.UCIF_ID=B.UCIF_ID                             
         ----inner join GTT_SECURITYDETAIL C on C.UCIF_ID=B.UCIF_ID                    
         ----INNER JOIN   pro.AccountCal D on D.UCIF_ID=B.UCIF_ID                  
         ----WHERE c.TotalSecurity>0
         ----AND D.FlgAbinitio<>'Y'
         ----AND D.FinalAssetClassAlt_Key<>6
         ----AND D.FlgSecured='D'
         DELETE SecurityDetails WHERE  TIMEKEY = v_TIMEKEY;
         
         INSERT INTO SecurityDetails
           ( REFCustomerId, TotalSecurity, TIMEKEY )
           ( SELECT REFCustomerId ,
                    SUM(NVL(CurntQtrRv, 0))  TotalSecurity  ,
                    v_TIMEKEY TIMEKEY  
             FROM GTT_CUSTOMERCAL 
              WHERE  NVL(CurntQtrRv, 0) > 0
               GROUP BY REFCUSTOMERID );
         /*TempTableForSecurity  being create */
         IF utils.object_id('GTT_SECURITYDETAIL') IS NOT NULL THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE GTT_SECURITYDETAIL';
         END IF;
         DELETE FROM GTT_SECURITYDETAIL;
         UTILS.IDENTITY_RESET('GTT_SECURITYDETAIL');

         INSERT INTO GTT_SECURITYDETAIL( SELECT REFCustomerId ,
                                           SUM(NVL(TOTALSECURITY, 0))  TOTALSECURITY
              FROM SECURITYDETAILS 
             WHERE  TIMEKEY = v_TIMEKEY
              GROUP BY REFCustomerId);
         UPDATE GTT_ACCOUNTCAL
            SET ApprRV = 0;

            MERGE INTO GTT_ACCOUNTCAL D
            USING (SELECT D.ROWID row_id, ((D.NETBALANCE / A.TOTOSFUNDED) * C.TOTALSECURITY) AS ApprRV
            FROM (
                        ( SELECT B.REFCUSTOMERID ,
                                              SUM(NVL(A.NETBALANCE, 0))  TOTOSFUNDED  
                           FROM GTT_ACCOUNTCAL A
                                  JOIN GTT_CUSTOMERCAL B   ON A.CUSTOMERENTITYID = B.CUSTOMERENTITYID
                          WHERE  A.NETBALANCE > 0
                                   AND A.FlgAbinitio <> 'Y'
                                   AND A.FinalAssetClassAlt_Key <> 6
                                   AND A.FlgSecured = 'D'
                           GROUP BY B.REFCUSTOMERID ) 
                    ) A
                   JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID
                   JOIN GTT_SECURITYDETAIL C   ON C.REFCustomerId = B.REFCUSTOMERID
                   JOIN GTT_ACCOUNTCAL D   ON D.RefCustomerID = B.RefCustomerID 
             WHERE c.TotalSecurity > 0
              AND D.FlgAbinitio <> 'Y'
              AND D.FinalAssetClassAlt_Key <> 6
              AND D.FlgSecured = 'D') src
            ON ( D.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET D.ApprRV
                                         --CASE WHEN  ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY)>D.NETBALANCE THEN D.NETBALANCE       
                                          --ELSE ((D.NETBALANCE/A.TOTOSFUNDED)*C.TOTALSECURITY) END                                           
                                          = src.ApprRV
            ;
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, NETBALANCE
         FROM GTT_ACCOUNTCAL A 
          WHERE A.FlgAbinitio <> 'Y'
           AND A.FinalAssetClassAlt_Key <> 6
           AND A.FlgSecured = 'S') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ApprRV = NETBALANCE;
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'SecurityAppropriation';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      -----------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
      V_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'SecurityAppropriation';

   END;END;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."SECURITYAPPROPRIATION" TO "ADF_CDR_RBL_STGDB";
