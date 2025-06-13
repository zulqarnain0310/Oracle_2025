--------------------------------------------------------
--  DDL for Procedure NPA_EROSION_AGING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."NPA_EROSION_AGING" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : UPDATE  SysAssetClassAlt_Key  NPA Erosion Aging
 --EXEC [PRO].[NPA_Erosion_Aging] @TIMEKEY=26306
=============================================*/
--select * from rbl_stgdb.dbo.AUTOMATE_ADVANCES where EXT_FLG ='y'

(
  v_TIMEKEY IN NUMBER DEFAULT 26388 ,
  v_FlgMoc IN CHAR DEFAULT 'y' 
)
AS
--WITH RECOMPILE

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
   BEGIN
      DECLARE
         --declare @timekey int=26306
         v_PROCESSDATE VARCHAR2(200) ;

         v_MoveToDB1 NUMBER(5,2) ;
         v_MoveToLoss NUMBER(5,2) ;


         --OPTION(RECOMPILE)
         /*-------------------UPDATING ASSET CLASS DUE TO AGING--------*/
         --DECLARE @SUB_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='SUB_Days')
         --DECLARE @DB1_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB1_Days')
         --DECLARE @DB2_Days INT =(SELECT RefValue FROM PRO.refperiod WHERE BusinessRule='DB2_Days')
         --------------------------------------------------------------------------------
         v_SUB_Days NUMBER(10,0) ;
         v_DB1_Days NUMBER(10,0) ;
         v_DB2_Days NUMBER(10,0) ;
         --------------------------------------------------------------------
         --------------------------EMAIL Dated 06-06-2022-----------Doubtful I asset class date should be captured and account should become D-2 one year from D-I date and so on .Similarly for D-2 and D-3--------------
         v_SUB_Months NUMBER(10,0) ;
         v_DB1_Months NUMBER(10,0) ;
         v_DB2_Months NUMBER(10,0) ;

      BEGIN
      
               SELECT DATE_ INTO v_PROCESSDATE
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;

         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToDB1 
           FROM RBL_MISDB_PROD.DIMSECURITYEROSIONMASTER 
          WHERE  BusinessRule = 'Sub-Standard to Doubtful 1'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToLoss 
           FROM RBL_MISDB_PROD.DIMSECURITYEROSIONMASTER 
          WHERE  BusinessRule = 'Direct Loss'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;


         SELECT RefValue INTO v_SUB_Days 
           FROM RBL_MISDB_PROD.DIMNPAAGEINGMASTER 
          WHERE  BusinessRule = 'Sub-Standard to Doubtful 1'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB1_Days
           FROM RBL_MISDB_PROD.DIMNPAAGEINGMASTER 
          WHERE  BusinessRule = 'Doubtful 1 to Doubtful 2'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB2_Days 
           FROM RBL_MISDB_PROD.DIMNPAAGEINGMASTER 
          WHERE  BusinessRule = 'Doubtful 2 to Doubtful 3'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         --------------------------------------------------------------------
         --------------------------EMAIL Dated 06-06-2022-----------Doubtful I asset class date should be captured and account should become D-2 one year from D-I date and so on .Similarly for D-2 and D-3--------------
         SELECT RefValue INTO v_SUB_Months 
           FROM RBL_MISDB_PROD.DIMNPAAGEINGMASTER 
          WHERE  BusinessRule = 'Sub-Standard to Doubtful 1'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         
         SELECT RefValue INTO v_DB1_Months
           FROM RBL_MISDB_PROD.DIMNPAAGEINGMASTER 
          WHERE  BusinessRule = 'Doubtful 1 to Doubtful 2'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB2_Months
           FROM RBL_MISDB_PROD.DIMNPAAGEINGMASTER 
          WHERE  BusinessRule = 'Doubtful 2 to Doubtful 3'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;

      
         IF utils.object_id('TEMPDB..GTT_CTE_CustomerWiseBalance_EROSION') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_CTE_CustomerWiseBalance_EROSION ';
         END IF;
         DELETE FROM GTT_CTE_CustomerWiseBalance_EROSION;
         UTILS.IDENTITY_RESET('GTT_CTE_CustomerWiseBalance_EROSION');

         INSERT INTO GTT_CTE_CustomerWiseBalance_EROSION ( 
         	SELECT A.RefCustomerID ,
                 SUM(NVL(A.PrincOutStd, 0))  NetBalance  
         	  FROM GTT_ACCOUNTCAL A
                   JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID
         	 WHERE  ( b.SysAssetClassAlt_Key NOT IN ( SELECT AssetClassAlt_Key 
                                                    FROM RBL_MISDB_PROD.DimAssetClass 
                                                     WHERE  AssetClassShortName = 'STD'
                                                              AND EffectiveFromTimeKey <= v_TIMEKEY
                                                              AND EffectiveToTimeKey >= v_TIMEKEY )

                    AND SecApp = 'S' --ADDED ON 23102021 AMAR - FOR RBL ONLY SECURED ACCOUNTS FILTER
                   )

                    --AND ISNULL(B.FlgDeg,'N')<>'Y'
                    AND ( NVL(B.FlgProcessing, 'N') = 'N' )
                    AND NVL(A.PrincOutStd, 0) > 0
         	  GROUP BY A.RefCustomerID );
         /*----INTIAL LEVEL LossDt FlgErosion,ErosionDt NULL ------*/
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, 'N', NULL
         FROM GTT_CUSTOMERCAL B ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FlgErosion = 'N',
                                      B.ErosionDt = NULL;
         --B.LossDt=NULL,B.FlgErosion='N',B.ErosionDt=NULL
         --------UPDATE B SET B.FlgErosion='N',B.ErosionDt=NULL
         --------FROM  PRO.AccountCal A INNER JOIN PRO.CustomerCal B ON A.RefCustomerID=B.RefCustomerID
         --------INNER JOIN GTT_CTE_CustomerWiseBalance_EROSION C ON C.RefCustomerID=B.RefCustomerID
         --------INNER JOIN RBL_MISDB_PROD.DimAssetClass D ON D.AssetClassAlt_Key=B.SysAssetClassAlt_Key AND (D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY)
         --------WHERE ISNULL(A.NetBalance,0)>0  AND D.AssetClassShortName<>'STD' AND (ISNULL(B.FlgProcessing,'N')='N')
         --------OPTION(RECOMPILE)
         --------/*---UPDATING ASSET CLASS ON DUE TO EROSION OF SECURITY AND DBTDT AND LOSS DT DUE TO EROSION */
         -------------------New Logic 
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(C.NetBalance, 0) * v_MoveToLoss)
           AND D.AssetClassShortName <> 'LOS' THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                                                     FROM RBL_MISDB_PROD.DimAssetClass 
                                                      WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'LOS'
                                                               AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                                                               AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(B.PrvQtrRV, 0) * v_MoveToDB1)
           AND ( NVL(C.NetBalance, 0) >= NVL(B.CurntQtrRv, 0) )
           AND D.AssetClassShortName IN ( 'SUB' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB1'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         ELSE B.SysAssetClassAlt_Key
            END) AS pos_2, CASE 
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(C.NetBalance, 0) * v_MoveToLoss)
           AND D.AssetClassShortName <> 'LOS' THEN v_PROCESSDATE
         ELSE LossDt
            END AS pos_3, CASE 
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(B.PrvQtrRV, 0) * v_MoveToDB1)
           AND ( NVL(C.NetBalance, 0) >= NVL(B.CurntQtrRv, 0) )
           AND D.AssetClassShortName IN ( 'SUB' )
          THEN v_PROCESSDATE
         ELSE DbtDt
            END AS pos_4, CASE 
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(C.NetBalance, 0) * v_MoveToLoss)
           AND D.AssetClassShortName <> 'LOS' THEN 'Y'
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(B.PrvQtrRV, 0) * v_MoveToDB1)
           AND ( NVL(C.NetBalance, 0) >= NVL(B.CurntQtrRv, 0) )
           AND D.AssetClassShortName IN ( 'SUB' )
          THEN 'Y'
         ELSE 'N'
            END AS pos_5, CASE 
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(C.NetBalance, 0) * v_MoveToLoss)
           AND D.AssetClassShortName <> 'LOS' THEN v_PROCESSDATE
         WHEN NVL(B.CurntQtrRv, 0) < (NVL(B.PrvQtrRV, 0) * v_MoveToDB1)
           AND ( NVL(C.NetBalance, 0) >= NVL(B.CurntQtrRv, 0) )
           AND D.AssetClassShortName IN ( 'SUB' )
          THEN v_PROCESSDATE
         ELSE B.ErosionDt
            END AS pos_6
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID
                JOIN GTT_CTE_CustomerWiseBalance_EROSION C   ON C.RefCustomerID = B.RefCustomerID
                JOIN RBL_MISDB_PROD.DimAssetClass D   ON D.AssetClassAlt_Key = B.SysAssetClassAlt_Key
                AND ( D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE NVL(A.PrincOutStd, 0) > 0
           AND D.AssetClassShortName <> 'STD'
           AND ( NVL(B.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.SysAssetClassAlt_Key = pos_2,
                                      B.LossDt = pos_3,
                                      B.DbtDt -- Change 08/06/2018
                                       = pos_4,
                                      B.FlgErosion = pos_5,
                                      B.ErosionDt = pos_6;
         /*------INTIAL LEVEL  DBTDT IS SET TO NULL------*/
         /*---CALCULATE SysAssetClassAlt_Key,DbtDt ------------------ */
         MERGE INTO GTT_CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN utils.dateadd('MONTH', v_SUB_Days, A.SysNPA_Dt) > v_PROCESSDATE
           AND B.AssetClassShortName NOT IN ( 'DB1','DB2','DB3' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'SUB'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('MONTH', v_SUB_Days, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Days + v_DB1_Days, A.SysNPA_Dt) > v_PROCESSDATE
           AND B.AssetClassShortName NOT IN ( 'DB2','DB3' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB1'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('MONTH', v_SUB_Days + v_DB1_Days, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Days + v_DB1_Days + v_DB2_Days, A.SysNPA_Dt) > v_PROCESSDATE
           AND B.AssetClassShortName NOT IN ( 'DB3' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB2'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('MONTH', (v_DB1_Days + v_SUB_Days + v_DB2_Days), A.SysNPA_Dt) <= v_PROCESSDATE THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                                                                                                                  FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                                   WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB3'
                                                                                                                            AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                            AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         ELSE A.SysAssetClassAlt_Key
            END) AS pos_2, (CASE 
         WHEN utils.dateadd('MONTH', v_SUB_Days, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Days + v_DB1_Days, A.SysNPA_Dt) > v_PROCESSDATE THEN utils.dateadd('MONTH', v_SUB_Days, A.SysNPA_Dt)
         WHEN utils.dateadd('MONTH', v_SUB_Days + v_DB1_Days, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Days + v_DB1_Days + v_DB2_Days, A.SysNPA_Dt) > v_PROCESSDATE THEN utils.dateadd('MONTH', v_SUB_Days, A.SysNPA_Dt)
         WHEN utils.dateadd('MONTH', (v_DB1_Days + v_SUB_Days + v_DB2_Days), A.SysNPA_Dt) <= v_PROCESSDATE THEN utils.dateadd('MONTH', (v_SUB_Days), A.SysNPA_Dt)
         ELSE TO_DATE(DBTDT,'YYYY-MM-DD')
            END) AS pos_3
         FROM GTT_CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.DimAssetClass B   ON A.SysAssetClassAlt_Key = B.AssetClassAlt_Key
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.AssetClassShortName NOT IN ( 'STD','LOS' )


           -----AND ISNULL(A.FlgDeg,'N')<>'Y'   --amar 22-04-2022-- commented as discussed with Ashish Siron 22-04-2022 - In case of NPA date change thgrough MOC even account degerade on same date but it hshould be part of aging
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )
           AND DbtDt IS NULL
           AND A.SYSNPA_DT IS NOT NULL
           AND ( ( v_FlgMoc = 'N'
           AND NVL(A.FlgErosion, 'N') <> 'Y' )
           OR ( v_FlgMoc = 'Y' ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = pos_2,
                                      A.DBTDT = pos_3;
         /*------INTIAL LEVEL  DBTDT IS SET TO NULL------*/
         /*---CALCULATE SysAssetClassAlt_Key,DbtDt ------------------ */
         MERGE INTO GTT_CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN utils.dateadd('MONTH', v_SUB_Months, A.SysNPA_Dt) > v_PROCESSDATE
           AND B.AssetClassShortName NOT IN ( 'DB1','DB2','DB3' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'SUB'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('MONTH', v_SUB_Months, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Months + v_DB1_Months, A.SysNPA_Dt) > v_PROCESSDATE
           AND B.AssetClassShortName NOT IN ( 'DB2','DB3' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB1'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('MONTH', v_DB1_Months, A.DbtDt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_DB1_Months + v_DB2_Months, A.DbtDt) > v_PROCESSDATE
           AND B.AssetClassShortName NOT IN ( 'DB3' )
          THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                 FROM RBL_MISDB_PROD.DimAssetClass 
                  WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB2'
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                           AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('MONTH', (v_DB1_Months + v_DB2_Months), A.DbtDt) <= v_PROCESSDATE THEN ( SELECT RBL_MISDB_PROD.DimAssetClass.AssetClassAlt_Key 
                                                                                                     FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                      WHERE  RBL_MISDB_PROD.DimAssetClass.AssetClassShortName = 'DB3'
                                                                                                               AND RBL_MISDB_PROD.DimAssetClass.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                               AND RBL_MISDB_PROD.DimAssetClass.EffectiveToTimeKey >= v_TIMEKEY )
         ELSE A.SysAssetClassAlt_Key
            END) AS pos_2, (CASE 
         WHEN DbtDt IS NOT NULL
           AND utils.dateadd('MONTH', v_SUB_Months, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Months + v_DB1_Months, A.SysNPA_Dt) > v_PROCESSDATE THEN utils.dateadd('MONTH', v_SUB_Months, A.SysNPA_Dt)
         WHEN DbtDt IS NOT NULL
           AND utils.dateadd('MONTH', v_SUB_Months + v_DB1_Months, A.SysNPA_Dt) <= v_PROCESSDATE
           AND utils.dateadd('MONTH', v_SUB_Months + v_DB1_Months + v_DB2_Months, A.SysNPA_Dt) > v_PROCESSDATE THEN utils.dateadd('MONTH', v_SUB_Months, A.SysNPA_Dt)
         WHEN DbtDt IS NOT NULL
           AND utils.dateadd('MONTH', (v_DB1_Months + v_SUB_Months + v_DB2_Months), A.SysNPA_Dt) <= v_PROCESSDATE THEN utils.dateadd('MONTH', (v_SUB_Months), A.SysNPA_Dt)
         ELSE TO_DATE(DBTDT,'YYYY-MM-DD')
            END) AS pos_3
         FROM GTT_CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.DimAssetClass B   ON A.SysAssetClassAlt_Key = B.AssetClassAlt_Key
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.AssetClassShortName NOT IN ( 'STD','LOS' )


           -----AND ISNULL(A.FlgDeg,'N')<>'Y'   --amar 22-04-2022-- commented as discussed with Ashish Siron 22-04-2022 - In case of NPA date change thgrough MOC even account degerade on same date but it hshould be part of aging
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )
           AND DbtDt IS NOT NULL
           AND A.SYSNPA_DT IS NOT NULL
           AND ( ( v_FlgMoc = 'N'
           AND NVL(A.FlgErosion, 'N') <> 'Y' )
           OR ( v_FlgMoc = 'Y' ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = pos_2,
                                      A.DBTDT = pos_3;
         --------------------------------------------------END EMail Dated---------------------------------------------
         ---HANDLE ASSET CLASS FROM SOURCE DOUBT FUL BUT ON THE BASES OF NPA SUB SO CONDITION MODIFY---
         --------------------------------------------------END EMail Dated 16-06-2022---------------------------------------------
         ---For some cases security value is not apportioned in provision computation report so they are marked as loss asset---
         /*
         UPDATE A SET SysAssetClassAlt_Key=SrcAssetClassAlt_Key
         FROM PRO.CustomerCal A INNER JOIN RBL_MISDB_PROD.DimAssetClass B ON A.SrcAssetClassAlt_Key =B.AssetClassAlt_Key
         WHERE B.AssetClassShortName IN('DB1','DB2','DB3')
         AND ISNULL(A.FlgDeg,'N')<>'Y' AND (ISNULL(A.FlgProcessing,'N')='N')
         AND A.SYSNPA_DT IS NOT NULL
         AND SysAssetClassAlt_Key=2  AND ISNULL(FlgMoc,'N')<>'Y'



         UPDATE A SET SysAssetClassAlt_Key=SrcAssetClassAlt_Key
         FROM PRO.CustomerCal A INNER JOIN RBL_MISDB_PROD.DimAssetClass B ON A.SrcAssetClassAlt_Key =B.AssetClassAlt_Key
         WHERE B.AssetClassShortName IN('DB2')
         AND ISNULL(A.FlgDeg,'N')<>'Y' AND (ISNULL(A.FlgProcessing,'N')='N')
         AND A.SYSNPA_DT IS NOT NULL
         AND SysAssetClassAlt_Key in(2,3) AND ISNULL(FlgMoc,'N')<>'Y'


         UPDATE A SET SysAssetClassAlt_Key=SrcAssetClassAlt_Key
         FROM PRO.CustomerCal A INNER JOIN RBL_MISDB_PROD.DimAssetClass B ON A.SrcAssetClassAlt_Key =B.AssetClassAlt_Key
         WHERE B.AssetClassShortName IN('DB3')
         AND ISNULL(A.FlgDeg,'N')<>'Y' AND (ISNULL(A.FlgProcessing,'N')='N')
         AND A.SYSNPA_DT IS NOT NULL
         AND SysAssetClassAlt_Key in(2,3,4) AND ISNULL(FlgMoc,'N')<>'Y'


         UPDATE A SET SysAssetClassAlt_Key=SrcAssetClassAlt_Key
         FROM PRO.CustomerCal A INNER JOIN RBL_MISDB_PROD.DimAssetClass B ON A.SrcAssetClassAlt_Key =B.AssetClassAlt_Key
         WHERE B.AssetClassShortName IN('LOS')
         AND ISNULL(A.FlgDeg,'N')<>'Y' AND (ISNULL(A.FlgProcessing,'N')='N')
         AND A.SYSNPA_DT IS NOT NULL
         AND SysAssetClassAlt_Key in(2,3,4,5) AND ISNULL(FlgMoc,'N')<>'Y'

         */
         ------------------------------------
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'NPA_Erosion_Aging';

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
       WHERE  RUNNINGPROCESSNAME = 'NPA_Erosion_Aging';

   END;END;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."NPA_EROSION_AGING" TO "ADF_CDR_RBL_STGDB";
