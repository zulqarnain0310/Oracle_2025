--------------------------------------------------------
--  DDL for Procedure DERIVATIVEDATAPROCESSING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."DERIVATIVEDATAPROCESSING" 
----/*=========================================
 ---- AUTHER : TRILOKI KHANNA
 ---- CREATE DATE : 27-11-2019
 ---- MODIFY DATE : 27-11-2019
 ---- DESCRIPTION : UPDATE InvestmentDataProcessing
 ---- --EXEC [PRO].[InvestmentDataProcessing] @TIMEKEY=26053
 ----=============================================*/

(
  v_TIMEKEY IN NUMBER
)
AS
/*=========================================
-- AUTHOR : TRILOKI KHANNA
-- CREATE DATE : 09-04-2021
-- MODIFY DATE : 09-04-2021
-- DESCRIPTION : Test Case Cover in This SP

--=============================================*/

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
    V_Table_exists NUMBER(10);
   BEGIN
      DECLARE
         
         v_PROCESSDATE VARCHAR2(200) ;
         v_SUB_Days NUMBER(10,0) ;
         v_DB1_Days NUMBER(10,0) ;
         v_DB2_Days NUMBER(10,0) ;
         v_MoveToDB1 NUMBER(5,2) ;
         v_MoveToLoss NUMBER(5,2) ;
         v_SubStandard NUMBER(10,0) ;
         v_DoubtfulI NUMBER(10,0) ;
         v_DoubtfulII NUMBER(10,0) ;
         v_DoubtfulIII NUMBER(10,0);
         v_Loss NUMBER(10,0) ;

      BEGIN
      
        SELECT DATE_ INTO v_PROCESSDATE
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;
          
         SELECT RefValue INTO v_SUB_Days 
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'SUB_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT RefValue INTO v_DB1_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'DB1_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB2_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'DB2_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToDB1
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'MoveToDB1'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToLoss
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'MoveToLoss'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT PROVISIONALT_KEY INTO v_SubStandard
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulI
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-I'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulII
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-II'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulIII
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-III'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_Loss 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  segment = 'IRAC'
                   AND PROVISIONNAME = 'Loss'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;      
      
         UPDATE CurDat_RBL_MISDB_PROD.DerivativeDetail
            SET DPD = 0
          WHERE  EffectiveFromTimeKey <= v_timekey
           AND EffectiveToTimeKey >= v_timekey
           AND NVL(DPD, 0) = 0;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_DivOverdue = 0,
                                      A.DPD = 0,
                                      A.FLGDEG = 'N',
                                      A.FLGUPG = 'N',
                                      A.DEGREASON = NULL,
                                      A.UPGDATE = NULL;
         /*UPDATE PREVISOU DAY STATUS AS INITIAL STATUS FOR CURRENT DAY */
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, B.FinalAssetClassAlt_Key, B.NPIDt
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.DerivativeEntityID = B.DerivativeEntityID
                AND A.EffectiveFromTimeKey <= v_timekey
                AND A.EffectiveToTimeKey >= v_timekey
                AND B.EffectiveFromTimeKey <= v_timekey - 1
                AND B.EffectiveToTimeKey >= v_timekey - 1 ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.InitialAssetAlt_Key = src.FinalAssetClassAlt_Key,
                                      A.InitialNPIDt = src.NPIDt;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A  
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN Duedate IS NOT NULL THEN utils.datediff('DAY', Duedate, v_PROCESSDATE)
         ELSE 0
            END) AS DPD_DivOverdue
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_DivOverdue = src.DPD_DivOverdue;
         
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, DPD_DivOverdue
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD = DPD_DivOverdue;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, 'Y', 'DEGRADE BY Derivative Overdue' AS pos_3
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND DPD >= 90) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = 'Y',
                                      A.DEGREASON = pos_3;
         /*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL---------------*/
         /*------------Calculate NpaDt -------------------------------------*/
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, v_ProcessDate
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND NVL(A.FLGDEG, 'N') = 'Y') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPIDt = v_ProcessDate;
         
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, utils.dateadd('DAY', NVL(90, 0), utils.dateadd('DAY', -NVL(DPD, 0), v_ProcessDate)) AS NPIDt
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND NVL(A.FLGDEG, 'N') = 'Y'
           AND A.DEGREASON IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.NPIDt = src.NPIDt;
         
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                               FROM RBL_MISDB_PROD.DimAssetClass
                                                                                WHERE  DIMASSETCLASS.AssetClassShortName = 'SUB'
                                                                                         AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                         AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                             FROM RBL_MISDB_PROD.DimAssetClass
                                                                                              WHERE  DIMASSETCLASS.AssetClassShortName = 'DB1'
                                                                                                       AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                       AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days + v_DB2_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                          FROM RBL_MISDB_PROD.DimAssetClass
                                                                                                           WHERE  DIMASSETCLASS.AssetClassShortName = 'DB2'
                                                                                                                    AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                    AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', (v_DB1_Days + v_SUB_Days + v_DB2_Days), A.NPIDt) <= v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                            FROM RBL_MISDB_PROD.DimAssetClass
                                                                                                             WHERE  DIMASSETCLASS.AssetClassShortName = 'DB3'
                                                                                                                      AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                      AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )   END) AS FinalAssetClassAlt_Key
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND NVL(A.FlgDeg, 'N') = 'Y') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         IF utils.object_id('TEMPDB..GTT_TEMPMINASSETCLASS') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPMINASSETCLASS ';
         END IF;
         DELETE FROM GTT_TEMPMINASSETCLASS;
         UTILS.IDENTITY_RESET('GTT_TEMPMINASSETCLASS');

         INSERT INTO GTT_TEMPMINASSETCLASS ( 
         	SELECT UCIC_ID ,
                 MAX(NVL(FinalAssetClassAlt_Key, 1))  FinalAssetClassAlt_Key  ,
                 MIN(NPIDt)  NPIDt  
         	  FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
         	 WHERE  A.EffectiveFromTimeKey <= v_timekey
                    AND A.EffectiveToTimeKey >= v_timekey
                    AND NVL(FinalAssetClassAlt_Key, 1) > 1
         	  GROUP BY UCIC_ID );
              
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail B
         USING (SELECT B.ROWID row_id, A.FinalAssetClassAlt_Key, A.NPIDt, 'PERCOLATION BY' || ' ' || B.UCIC_ID AS pos_4
         FROM GTT_TEMPMINASSETCLASS A
                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON B.EffectiveFromTimeKey <= v_timekey
                AND B.EffectiveToTimeKey >= v_timekey
                AND B.UCIC_ID = B.UCIC_ID
                AND B.AssetClass_AltKey = 1 ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      B.NPIDt = src.NPIDt,
                                      B.DEGREASON = pos_4;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A  
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                               FROM RBL_MISDB_PROD.DimAssetClass
                                                                                WHERE  DIMASSETCLASS.AssetClassShortName = 'SUB'
                                                                                         AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                         AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                             FROM RBL_MISDB_PROD.DimAssetClass
                                                                                              WHERE  DIMASSETCLASS.AssetClassShortName = 'DB1'
                                                                                                       AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                       AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, A.NPIDt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days + v_DB2_Days, A.NPIDt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                          FROM RBL_MISDB_PROD.DimAssetClass
                                                                                                           WHERE  DIMASSETCLASS.AssetClassShortName = 'DB2'
                                                                                                                    AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                    AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', (v_DB1_Days + v_SUB_Days + v_DB2_Days), A.NPIDt) <= v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                            FROM RBL_MISDB_PROD.DimAssetClass
                                                                                                             WHERE  DIMASSETCLASS.AssetClassShortName = 'DB3'
                                                                                                                      AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                      AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )   END) AS FinalAssetClassAlt_Key
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE NVL(A.FlgDeg, 'N') <> 'Y'
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, 1, NULL
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE NVL(FinalAssetClassAlt_Key, 0) = 0
           AND A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = 1,
                                      A.NPIDt = NULL;
         /* AMAR 13042032MOC - CHANGES FOR AUTO AND MANUAL EFFECTS  */
         MERGE INTO RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails A 
         USING (SELECT A.ROWID row_id, v_TimeKey
         FROM RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails A 
          WHERE EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND A.MOCTYPE = 'AUTO') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = v_TimeKey;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail D
         USING (SELECT D.ROWID row_id, A.AssetClassAlt_Key, A.NPA_Date, CASE 
         WHEN A.AssetClassAlt_Key > 1 THEN 'NPA DUE TO MOC'
         ELSE NULL
            END AS pos_4
         FROM RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails A
                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail D   ON A.AccountEntityID = D.DerivativeEntityID
                AND D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND A.AccountENtityid IS NOT NULL ) src
         ON ( D.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET D.FinalAssetClassAlt_Key = src.AssetClassAlt_Key,
                                      D.NPIDt = src.NPA_Date,
                                      D.DEGREASON = pos_4;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail D
         USING (SELECT D.ROWID row_id, A.AssetClassAlt_Key, A.NPA_Date, CASE 
         WHEN A.AssetClassAlt_Key > 1 THEN 'NPA DUE TO MOC'
         ELSE NULL
            END AS pos_4
         FROM RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails A
                JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail D   ON A.CustomerID = D.CustomerID
                AND D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND A.CustomerID IS NOT NULL ) src
         ON ( D.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET D.FinalAssetClassAlt_Key = src.AssetClassAlt_Key,
                                      D.NPIDt = src.NPA_Date,
                                      D.DEGREASON = pos_4;
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A
         USING (SELECT A.ROWID row_id
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE A.EffectiveFromTimeKey <= v_timekey
           AND A.EffectiveToTimeKey >= v_timekey
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.UpgDate = NULL,
                                      A.FlgDeg = 'N',
                                      A.NPIDt = NULL,
                                      A.DBTDate = NULL,
                                      A.FlgUpg = 'N';
         /* END OF MOC CHANGES */
        
        
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'DerivativeDataProcessing';
         --------------Added for DashBoard 04-03-2021
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET CompletedCount = CompletedCount + 1
          WHERE  BandName = 'ASSET CLASSIFICATION';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   V_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'DerivativeDataProcessing';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."DERIVATIVEDATAPROCESSING" TO "ADF_CDR_RBL_STGDB";
