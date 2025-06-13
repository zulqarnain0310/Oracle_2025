--------------------------------------------------------
--  DDL for Procedure MARKING_NPA_REASON_NPAACCOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : MARKING OF FLGDEG AND DEG REASON 
 --EXEC [PRO].[Marking_NPA_Reason_NPAAccount]  @TIMEKEY=25140
=============================================*/
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
   BEGIN
      DECLARE
         v_PROCESSDATE VARCHAR2(200);

      BEGIN
      
      SELECT DATE_ INTO v_PROCESSDATE
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TIMEKEY ;
       
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ' Degarde Account due to ALWYS_NPA and balance >=0' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CUSTOMERENTITYID = B.CUSTOMERENTITYID 
          WHERE A.ASSET_NORM = 'ALWYS_NPA'
           AND NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND ( B.FLGPROCESSING = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ' DEGRADE BY INT NOT SERVICED' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND ( A.DPD_INTSERVICE > 0 ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ', DEGRADE BY CONTI EXCESS' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_OVERDRAWN > 0 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ', DEGRADE BY NO CREDIT' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_NOCREDIT > 0 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ', DEGRADE BY OVERDUE' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_OVERDUE > 0 )
           AND NVL(a.DegReason, ' ') NOT LIKE '%NPA Due to overdue – Buyout Portfolio%'
           AND NVL(a.DegReason, ' ') NOT LIKE '%NPA with Seller%') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;-- Buyout changes
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ',NPA Due to overdue – Buyout Portfolio' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_OVERDUE > 0 )
           AND a.DegReason LIKE '%NPA Due to overdue – Buyout Portfolio%') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;-- Buyout changes
        
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ', DEGRADE BY DEBIT BALANCE ' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
                JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey ) 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_OVERDUE > 0 )
           AND A.DebitSinceDt IS NOT NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;--AND ISNULL(C.SrcSysProductCode,'N')='SAVING'
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ', DEGRADE BY STOCK STATEMENT' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_STOCKSTMT > 0 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ', DEGRADE BY REVIEW DUE DATE' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND A.DPD_RENEWAL > 0 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_REASON, ' ') || 'DEGARDE BY MOC' AS NPA_REASON
         FROM GTT_ACCOUNTCAL A
                JOIN MAIN_PRO.ChangedMocAclStatus B   ON A.CUSTOMERENTITYID = B.CustomerEntityID
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY )
                AND a.Asset_Norm = 'NORMAL' ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_REASON = src.NPA_REASON;
         MERGE INTO GTT_ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, 'PERCOLATION BY PAN CARD ' || ' ' || A.PANNO AS NPA_Reason
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_ACCOUNTCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE B.FinalAssetClassAlt_Key > 1
           AND B.NPA_Reason IS NULL
           AND A.DEGREASON LIKE '%PERCOLATION BY PAN CARD%') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, 'PERCOLATION BY AADHAR CARD ' || ' ' || A.AADHARCARDNO AS NPA_Reason
         FROM GTT_CUSTOMERCAL A
                JOIN GTT_ACCOUNTCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE B.FinalAssetClassAlt_Key > 1
           AND B.NPA_Reason IS NULL
           AND A.DEGREASON LIKE '%PERCOLATION BY AADHAR CARD%') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.NPA_Reason = src.NPA_Reason;
         IF utils.object_id('TEMPDB..GTT_TEMPTABLE_PERCOLATION') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE_PERCOLATION ';
         END IF;
         DELETE FROM GTT_TEMPTABLE_PERCOLATION;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLE_PERCOLATION');

         INSERT INTO GTT_TEMPTABLE_PERCOLATION SELECT A.REFCUSTOMERID REFCUSTOMERID  ,
                                                     A.CustomerAcID CustomerAcID  ,
                                                     A.NPA_Reason 
              FROM GTT_ACCOUNTCAL A
                     JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID
             WHERE  A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                      AND A.NPA_Reason IS NOT NULL
                      AND A.FinalAssetClassAlt_Key > 1
                      AND ( A.FLGDEG = 'N' )
              ORDER BY A.REFCUSTOMERID;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Link By AccountId' || ' ' || B.CustomerAcID AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_TEMPTABLE_PERCOLATION B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE A.FinalAssetClassAlt_Key > 1
           AND A.NPA_Reason IS NULL
           AND ( A.FLGDEG = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         IF utils.object_id('TEMPDB..tt_TEMPTABLE_PERCOLATIONFreshSlipage') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE_PERCOLATIONFre ';
         END IF;
         DELETE FROM GTT_TEMPTABLE_PERCOLATIONFre;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLE_PERCOLATIONFre');

         INSERT INTO GTT_TEMPTABLE_PERCOLATIONFre SELECT A.REFCUSTOMERID REFCUSTOMERID  ,
                                                        A.CustomerAcID CustomerAcID  ,
                                                        A.NPA_Reason 
              FROM GTT_ACCOUNTCAL A
                     JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID
             WHERE  A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                      AND A.NPA_Reason IS NOT NULL
                      AND A.FinalAssetClassAlt_Key > 1
                      AND ( A.FLGDEG = 'Y' )
              ORDER BY A.REFCUSTOMERID;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Link By AccountId' || ' ' || B.CustomerAcID AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_TEMPTABLE_PERCOLATIONFre B   ON A.REFCUSTOMERID = B.REFCUSTOMERID
                JOIN RBL_MISDB_PROD.DimProduct P   ON P.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND P.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND ( P.PRODUCTALT_KEY = A.PRODUCTALT_KEY ) 
          WHERE A.FinalAssetClassAlt_Key > 1
           AND ( NVL(A.DPD_Max, 0) < 90
           OR P.Agrischeme = 'Y'
           AND A.DPD_mAX < 366 )
           AND ( A.FLGDEG = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;--A.NPA_Reason IS NULL AND (A.FLGDEG='N')  As per Mail Changes done by Triloki 25/02/2020
         ---WRITE OF REASON UPDATED -----
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA Due To Writeoff Amount' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CUSTOMERENTITYID = B.CUSTOMERENTITYID 
          WHERE A.ASSET_NORM = 'ALWYS_NPA'
           AND NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND ( B.FLGPROCESSING = 'N' )
           AND A.WriteOffAmount > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
        
         IF utils.object_id('TEMPDB..GTT_TEMPTABLE_PERCOLATIONWRI') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE_PERCOLATIONWRI ';
         END IF;
         DELETE FROM GTT_TEMPTABLE_PERCOLATIONWRI;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLE_PERCOLATIONWRI');

         INSERT INTO GTT_TEMPTABLE_PERCOLATIONWRI SELECT A.REFCUSTOMERID REFCUSTOMERID  ,
                                                        A.CustomerAcID CustomerAcID  ,
                                                        A.NPA_Reason 
              FROM GTT_ACCOUNTCAL A
                     JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID
             WHERE  A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                      AND A.FinalAssetClassAlt_Key > 1
                      AND ( A.FLGDEG = 'N' )
                      AND A.WriteOffAmount > 0
                      AND A.NPA_Reason LIKE 'ALWYS_NPA Due To Writeoff Amount'
              ORDER BY A.REFCUSTOMERID;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Link By W/o AccountId' || ' ' || B.CustomerAcID AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_TEMPTABLE_PERCOLATIONWRI B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE A.FinalAssetClassAlt_Key > 1
           AND A.NPA_Reason NOT LIKE 'ALWYS_NPA Due To Writeoff Amount'
           AND ( A.FLGDEG = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ' Degarde Account due to ALWYS_NPA and balance >=0' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.CUSTOMERENTITYID = B.CUSTOMERENTITYID 
          WHERE B.ASSET_NORM = 'ALWYS_NPA'
           AND NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND ( B.FLGPROCESSING = 'N' )
           AND A.NPA_Reason IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.NPA_Reason, ' ') || ' Degarde Account due to ALWYS_NPA and balance >=0' AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID 
          WHERE B.ASSET_NORM = 'ALWYS_NPA'
           AND NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND ( B.FLGPROCESSING = 'N' )
           AND A.NPA_Reason IS NULL
           AND B.UcifEntityID > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         UPDATE GTT_ACCOUNTCAL
            SET NPA_Reason = 'NPA DUE TO FRAUD MARKING'
          WHERE  DegReason LIKE '%Fraud%';
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'PERCOLATION BY UCIC_ID' || B.UCIF_ID AS NPA_Reason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID 
          WHERE NVL(FinalAssetClassAlt_Key, 1) <> 1
           AND ( B.FLGPROCESSING = 'N' )
           AND A.NPA_Reason IS NULL
           AND B.UcifEntityID > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPA_Reason = src.NPA_Reason;
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Marking_NPA_Reason_NPAAccount';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

    V_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Marking_NPA_Reason_NPAAccount';

   END;END;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_NPA_REASON_NPAACCOUNT" TO "ADF_CDR_RBL_STGDB";
