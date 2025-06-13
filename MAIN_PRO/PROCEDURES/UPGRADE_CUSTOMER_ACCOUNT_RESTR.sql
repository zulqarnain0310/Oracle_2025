--------------------------------------------------------
--  DDL for Procedure UPGRADE_CUSTOMER_ACCOUNT_RESTR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : FIRST UPGRADE TO CUSTOMER LEVEL  AFTER THAT ACCOUNT LEVEL
=============================================*/
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN

DECLARE v_PROCESSDATE VARCHAR2(200) ;
         v_DysOfDelay NUMBER(3,0) := 90;
         v_SQLERRM VARCHAR(1000);
   BEGIN
         /*=========================================
          AUTHOR : TRILOKI KHANNA
          CREATE DATE : 09-04-2021
          MODIFY DATE : 09-04-2021
          DESCRIPTION : Test Case Cover in This SP

         RefCustomerID	TestCase
         143	Reversefeed Upgradation
         94	UPG-TL/DL - Ac Level: Eligible for Upgrade
         96	UPG-Bills/ PC - Ac Level: Eligible for Upgradae
         98	UPG-CC/OD: Eligible for Upgrade
         95	UPG-TL/DL - Ac Level: Not Eligible for Upgrade
         97	UPG-Bills/ PC - Ac Level: Not Eligible for Upgradae
         99	UPG-CC/OD: Not Eligible for Upgrade
         =============================================*/
         /*check the customer when all account to cutomer dpdmax must be 0*/
         SELECT Date_ INTO v_PROCESSDATE 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;
         /* END OF RESTR UPGRADE */
         /*pui UPGRADE */


      BEGIN
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET FLGUPG = 'N';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET FLGUPG = 'N';
         IF utils.object_id('TEMPDB..tt_TEMPTABLE_15') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_15 ';
         END IF;
         DELETE FROM tt_TEMPTABLE_15;
         UTILS.IDENTITY_RESET('tt_TEMPTABLE_15');

         INSERT INTO tt_TEMPTABLE_15 ( 
         	SELECT A.UCIF_ID ,
                 TOTALCOUNT 
         	  FROM ( SELECT A.UCIF_ID ,
                          COUNT(1)  TOTALCOUNT  
                   FROM MAIN_PRO.CUSTOMERCAL A
                          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.UCIF_ID = B.UCIF_ID
                    WHERE  ( A.FlgProcessing = 'N' )
                             AND A.UCIF_ID IS NOT NULL
                             AND B.Asset_Norm NOT IN ( 'ALWYS_STD' )

                     GROUP BY A.UCIF_ID ) A
                   JOIN ( SELECT A.UCIF_ID ,
                                 COUNT(1)  TOTALDPD_MAXCOUNT  
                          FROM MAIN_PRO.CUSTOMERCAL A
                                 JOIN MAIN_PRO.ACCOUNTCAL B   ON A.UCIF_ID = B.UCIF_ID
                           WHERE  ( B.DPD_IntService <= B.RefPeriodIntServiceUPG
                                    AND B.DPD_NoCredit <= B.RefPeriodNoCreditUPG
                                    AND B.DPD_Overdrawn <= B.RefPeriodOverDrawnUPG
                                    AND B.DPD_Overdue <= B.RefPeriodOverdueUPG
                                    AND B.DPD_Renewal <= B.RefPeriodReviewUPG
                                    AND B.DPD_StockStmt <= B.RefPeriodStkStatementUPG )
                                    AND B.InitialAssetClassAlt_Key NOT IN ( 1 )

                                    AND ( A.FlgProcessing = 'N' )
                                    AND B.Asset_Norm NOT IN ( 'ALWYS_NPA','ALWYS_STD' )

                                    AND NVL(A.MocStatusMark, 'N') = 'N'
                                    AND A.UCIF_ID IS NOT NULL
                                    AND NVL(B.UnserviedInt, 0) = 0
                                    AND NVL(B.AccountStatus, 'N') <> 'Z'
                            GROUP BY A.UCIF_ID ) B   ON A.UCIF_ID = B.UCIF_ID
                   AND A.TOTALCOUNT = B.TOTALDPD_MAXCOUNT );
         /*------ UPGRADING CUSTOMER-----------*/
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'U'
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN tt_TEMPTABLE_15 B   ON A.UCIF_ID = B.UCIF_ID
                JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE ( NOT ( NVL(A.Asset_Norm, 'NORMAL') = 'ALWYS_NPA' )
           AND C.ASSETCLASSGROUP = 'NPA'
           AND NOT ( NVL(A.FlgDeg, 'N') = 'Y' ) )
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgUpg = 'U';
         IF utils.object_id('TEMPDB..tt_TEMPTABLE_151') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE1 ';
         END IF;
         DELETE FROM tt_TEMPTABLE1;
         UTILS.IDENTITY_RESET('tt_TEMPTABLE1');

         INSERT INTO tt_TEMPTABLE1 ( 
         	SELECT A.UCIF_ID ,
                 TOTALCOUNT 
         	  FROM ( SELECT A.UCIF_ID ,
                          COUNT(1)  TOTALCOUNT  
                   FROM MAIN_PRO.CUSTOMERCAL A
                          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.UCIF_ID = B.UCIF_ID
                    WHERE  ( A.FlgProcessing = 'N' )
                             AND A.UCIF_ID IS NOT NULL
                             AND B.Asset_Norm NOT IN ( 'ALWYS_STD' )

                     GROUP BY A.UCIF_ID ) A
                   JOIN ( SELECT A.UCIF_ID ,
                                 COUNT(1)  TOTALDPD_MAXCOUNT  
                          FROM MAIN_PRO.CUSTOMERCAL A
                                 JOIN MAIN_PRO.ACCOUNTCAL B   ON A.UCIF_ID = B.UCIF_ID
                           WHERE  ( B.DPD_IntService <= B.RefPeriodIntServiceUPG
                                    AND B.DPD_NoCredit <= B.RefPeriodNoCreditUPG
                                    AND B.DPD_Overdrawn <= B.RefPeriodOverDrawnUPG
                                    AND B.DPD_Overdue <= B.RefPeriodOverdueUPG
                                    AND B.DPD_Renewal <= B.RefPeriodReviewUPG
                                    AND B.DPD_StockStmt <= B.RefPeriodStkStatementUPG )
                                    AND B.FinalAssetClassAlt_Key NOT IN ( 1 )

                                    AND ( A.FlgProcessing = 'N' )
                                    AND B.Asset_Norm NOT IN ( 'ALWYS_NPA','ALWYS_STD' )

                                    AND NVL(A.MocStatusMark, 'N') = 'N'
                                    AND NVL(B.UnserviedInt, 0) = 0
                                    AND A.UCIF_ID IS NOT NULL
                                    AND NVL(B.AccountStatus, 'N') <> 'Z'
                            GROUP BY A.UCIF_ID ) B   ON A.UCIF_ID = B.UCIF_ID
                   AND A.TOTALCOUNT = B.TOTALDPD_MAXCOUNT );
         /*------ UPGRADING CUSTOMER-----------*/
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'U'
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN tt_TEMPTABLE1 B   ON A.UCIF_ID = B.UCIF_ID
                JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE ( NOT ( NVL(A.Asset_Norm, 'NORMAL') = 'ALWYS_NPA' )
           AND C.ASSETCLASSGROUP = 'NPA'
           AND NOT ( NVL(A.FlgDeg, 'N') = 'Y' ) )
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgUpg = 'U';
         IF utils.object_id('TEMPDB..tt_TEMPTABLE_15RefCustomerID') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLERefCustomerID ';
         END IF;
         DELETE FROM tt_TEMPTABLERefCustomerID;
         UTILS.IDENTITY_RESET('tt_TEMPTABLERefCustomerID');

         INSERT INTO tt_TEMPTABLERefCustomerID ( 
         	SELECT A.RefCustomerID ,
                 TOTALCOUNT 
         	  FROM ( SELECT A.RefCustomerID ,
                          COUNT(1)  TOTALCOUNT  
                   FROM MAIN_PRO.CUSTOMERCAL A
                          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID
                    WHERE  ( A.FlgProcessing = 'N' )
                             AND A.UCIF_ID IS NULL
                             AND A.RefCustomerID IS NOT NULL
                             AND B.Asset_Norm NOT IN ( 'ALWYS_STD' )

                     GROUP BY A.RefCustomerID ) A
                   JOIN ( SELECT A.RefCustomerID ,
                                 COUNT(1)  TOTALDPD_MAXCOUNT  
                          FROM MAIN_PRO.CUSTOMERCAL A
                                 JOIN MAIN_PRO.ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID
                           WHERE  ( B.DPD_IntService <= B.RefPeriodIntServiceUPG
                                    AND B.DPD_NoCredit <= B.RefPeriodNoCreditUPG
                                    AND B.DPD_Overdrawn <= B.RefPeriodOverDrawnUPG
                                    AND B.DPD_Overdue <= B.RefPeriodOverdueUPG
                                    AND B.DPD_Renewal <= B.RefPeriodReviewUPG
                                    AND B.DPD_StockStmt <= B.RefPeriodStkStatementUPG )
                                    AND B.InitialAssetClassAlt_Key NOT IN ( 1 )

                                    AND ( A.FlgProcessing = 'N' )
                                    AND B.Asset_Norm NOT IN ( 'ALWYS_NPA','ALWYS_STD' )

                                    AND NVL(A.MocStatusMark, 'N') = 'N'
                                    AND A.UCIF_ID IS NULL
                                    AND A.RefCustomerID IS NOT NULL
                            GROUP BY A.RefCustomerID ) B   ON A.RefCustomerID = B.RefCustomerID
                   AND A.TOTALCOUNT = B.TOTALDPD_MAXCOUNT );
         /*-----------UPGRADING CUSTOMER----------*/
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'U'
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN tt_TEMPTABLERefCustomerID B   ON A.RefCustomerID = B.RefCustomerID
                JOIN RBL_MISDB_PROD.DIMASSETCLASS C   ON C.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE ( NOT ( NVL(A.Asset_Norm, 'NORMAL') = 'ALWYS_NPA' )
           AND C.ASSETCLASSGROUP = 'NPA'
           AND NOT ( NVL(A.FlgDeg, 'N') = 'Y' ) )
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgUpg = 'U';
         -------Changes done in case of Same Pan Number One Customer Upgrade and One Npa To handle that Issue ---
         IF utils.object_id('TEMPDB..tt_PANUPDATEUPGRADE') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PANUPDATEUPGRADE ';
         END IF;
         DELETE FROM tt_PANUPDATEUPGRADE;
         UTILS.IDENTITY_RESET('tt_PANUPDATEUPGRADE');

         INSERT INTO tt_PANUPDATEUPGRADE ( 
         	SELECT A.PANNO ,
                 A.TotalCountMAX ,
                 B.TotalCount 
         	  FROM ( SELECT COUNT(1)  TotalCountMAX  ,
                          PANNO 
                   FROM MAIN_PRO.CUSTOMERCAL 
                    WHERE  PANNO IS NOT NULL
                     GROUP BY PANNO ) A
                   JOIN ( SELECT COUNT(1)  TotalCount  ,
                                 PANNO 
                          FROM MAIN_PRO.CUSTOMERCAL 
                           WHERE  PANNO IS NOT NULL
                                    AND FLGUPG = 'U'
                            GROUP BY PANNO ) B   ON A.PANNO = B.PANNO
                   AND A.TotalCountMAX <> B.TotalCount );
         MERGE INTO MAIN_PRO.CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, 'N'
         FROM tt_PANUPDATEUPGRADE A
                JOIN MAIN_PRO.CUSTOMERCAL B   ON A.PANNO = B.PANNO 
          WHERE B.FlgUpg = 'U') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FLGUPG = 'N';
         /* RFESTR UPGRADE */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN ParameterShortNameEnum IN ( 'MSME_OLD','MSME_COVID','MSME_COVID_RF2' )
          THEN (CASE 
                     WHEN DPD_Breach_Date IS NOT NULL
                       AND (CASE 
                                 WHEN NVL(SP_ExpiryDate, '1900-01-01') >= NVL(SP_ExpiryExtendedDate, '1900-01-01') THEN SP_ExpiryDate
                     ELSE SP_ExpiryExtendedDate
                        END) >= v_PROCESSDATE THEN 'N'
         ELSE C.FlgUpg
            END)
         WHEN ParameterShortNameEnum IN ( 'PRUDENTIAL' )
          THEN (CASE 
                     WHEN DPD_Breach_Date IS NOT NULL
                       OR InvestmentGrade = 'N' THEN 'N'
         ELSE C.FlgUpg
            END)
         WHEN ParameterShortNameEnum IN ( 'IRAC','OTHER' )
          THEN (CASE 
                     WHEN DPD_Breach_Date IS NOT NULL
                       OR SP_ExpiryDate >= v_PROCESSDATE THEN 'N'
         ELSE C.FlgUpg
            END)
         ELSE B.FlgUpg
            END AS FLGUPG
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = B.CustomerEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key 
          WHERE D.DimParameterName = 'TypeofRestructuring'
           AND ParameterShortNameEnum IN ( 'IRAC','OTHER','MSME_OLD','MSME_COVID','MSME_COVID_RF2','PRUDENTIAL' )

           AND C.FlgUpg = 'U') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGUPG = src.FLGUPG;
         MERGE INTO RBL_MISDB_PROD.CUSTOMERCAL C
         USING (SELECT C.ROWID row_id, 'N', ',DEGRADEY BY RESTRUCTURE' AS pos_3
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = B.CustomerEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE A.FlgUpg = 'N'
           AND C.FlgUpg = 'U'
           AND ParameterShortNameEnum IN ( 'IRAC','OTHER','MSME_OLD','MSME_COVID','MSME_COVID_RF2','PRUDENTIAL' )
         ) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET C.FLGUPG = 'N',
                                      C.DegReason = pos_3;
         MERGE INTO MAIN_PRO.PUI_CAL A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN ActualDCCO_Date IS NOT NULL
           OR RevisedDCCO > v_PROCESSDATE
           OR ( RevisedDCCO IS NULL
           AND FinnalDCCO_Date > v_PROCESSDATE )
           AND ( ( NVL(CostOverRunPer, 0) <= 10 )
           OR ( NVL(RevisedDebt, 0) <= NVL(OriginalDebt, 0) ) ) THEN 'U'
         WHEN ( TakeOutFinance = 'N' ) THEN 'U'   END AS FLG_UPG
         FROM MAIN_PRO.PUI_CAL A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID 
          WHERE b.FinalAssetClassAlt_Key > 1
           AND B.DPD_Max = 0
           AND B.FlgUpg = 'U') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLG_UPG ---AND AssetClassSellerBookAlt_key>1
                                       = src.FLG_UPG;
         MERGE INTO MAIN_PRO.CUSTOMERCAL C 
         USING (SELECT C.ROWID row_id, 'N'
         FROM MAIN_PRO.PUI_CAL A
                JOIN MAIN_PRO.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID 
          WHERE A.FLG_UPG = 'N'
           AND C.FlgUpg = 'U') src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FLGUPG = 'N';
         /*END OF PUI WORK*/
         -------Changes done in case of Same Pan Number One Customer Upgrade and One Npa To handle that Issue ---
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET SysNPA_Dt = NULL,
                DbtDt = NULL,
                LossDt = NULL,
                ErosionDt = NULL,
                FlgErosion = 'N',
                SysAssetClassAlt_Key = 1,
                FlgDeg = 'N'
          WHERE  FlgUpg = 'U';
         /*--------MARKING UPGRADED ACCOUNT --------------*/
         MERGE INTO MAIN_PRO.ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, v_PROCESSDATE
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE NVL(A.FlgUpg, 'U') = 'U'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.UpgDate = v_PROCESSDATE,
                                      B.DegReason = NULL,
                                      B.FinalAssetClassAlt_Key = 1,
                                      B.FlgDeg = 'N',
                                      B.FinalNpaDt = NULL,
                                      B.FlgUpg = 'U';
         MERGE INTO MAIN_PRO.ACCOUNTCAL B
         USING (SELECT B.ROWID row_id, v_PROCESSDATE
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE NVL(A.FlgUpg, 'U') = 'U'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.UpgDate = v_PROCESSDATE,
                                      B.DegReason = NULL,
                                      B.FinalAssetClassAlt_Key = 1,
                                      B.FlgDeg = 'N',
                                      B.FinalNpaDt = NULL,
                                      B.FlgUpg = 'U';
         /* 16-04-2021 AMAR  -- ADDED THIS CODE FOR  COMMING NEW ACCOUNT BECOMING NPA DUE TO 
         	EXISTING NPA CUSTOMER  AND ALSO UPGRADEING */
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, 'N', NULL
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE InitialAssetClassAlt_Key = 1
           AND FinalAssetClassAlt_Key = 1
           AND FlgUpg = 'U') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FLGUPG = 'N',
                                      UpgDate = NULL;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id, NULL
         FROM MAIN_PRO.CUSTOMERCAL A 
          WHERE SysAssetClassAlt_Key = 1
           AND DegReason IS NOT NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = NULL;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_15 ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE1 ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLERefCustomerID ';
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Upgrade_Customer_Account';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   v_SQLERRM:=SQLERRM;
      --------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Upgrade_Customer_Account';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPGRADE_CUSTOMER_ACCOUNT_RESTR" TO "ADF_CDR_RBL_STGDB";
