--------------------------------------------------------
--  DDL for Procedure CUST_ACCCAL_MERGE_MOC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" /*==============================          
Author : TRILOKI KHANNA   
CREATE DATE : 13-03-2020          
MODIFY DATE : 13-03-2020         
DESCRIPTION : UPDATE TOTAL PROVISION          
--EXEC [pro].[Cust_AccCal_Merge_Moc] @TimeKey =25410            
=========================================*/
(
  v_TimeKey IN NUMBER
)
AS

BEGIN
DECLARE v_SQLERRM VARCHAR(1000);
   BEGIN

      BEGIN
         DELETE FROM GTT_AdvAcCal;
         UTILS.IDENTITY_RESET('GTT_AdvAcCal');

         INSERT INTO GTT_AdvAcCal ( 
         	SELECT O.* 
         	  FROM CurDat_RBL_MISDB_PROD.ADVACCAL O
                   JOIN MAIN_PRO.ACCOUNTCAL T   ON ( O.EffectiveFromTimeKey <= v_TimeKey
                   AND O.EffectiveToTimeKey >= v_TimeKey )
                   AND O.AccountEntityID = T.AccountEntityID
         	 WHERE  NVL(O.SecurityValue, 0) <> NVL(T.SecurityValue, 0)
                    OR NVL(O.DFVAmt, 0) <> NVL(T.DFVAmt, 0)
                    OR NVL(O.GovtGtyAmt, 0) <> NVL(T.GovtGtyAmt, 0)
                    OR NVL(O.CoverGovGur, 0) <> NVL(T.CoverGovGur, 0)
                    OR NVL(O.UnAdjSubSidy, 0) <> NVL(T.UnAdjSubSidy, 0)
                    OR NVL(O.NetBalance, 0) <> NVL(T.NetBalance, 0)
                    OR NVL(O.ApprRV, 0) <> NVL(T.ApprRV, 0)
                    OR NVL(O.SecuredAmt, 0) <> NVL(T.SecuredAmt, 0)
                    OR NVL(O.UnSecuredAmt, 0) <> NVL(T.UnSecuredAmt, 0)
                    OR NVL(O.ProvDFV, 0) <> NVL(T.ProvDFV, 0)
                    OR NVL(O.Provsecured, 0) <> NVL(T.Provsecured, 0)
                    OR NVL(O.ProvUnsecured, 0) <> NVL(T.ProvUnsecured, 0)
                    OR NVL(O.ProvCoverGovGur, 0) <> NVL(T.ProvCoverGovGur, 0)
                    OR NVL(O.TotalProvision, 0) <> NVL(T.TotalProvision, 0)
                    OR NVL(O.AddlProvision, 0) <> NVL(T.AddlProvision, 0)
                    OR NVL(O.SMA_Dt, '1900-01-01') <> NVL(T.SMA_Dt, '1900-01-01')
                    OR NVL(O.UpgDate, '1900-01-01') <> NVL(T.UpgDate, '1900-01-01')
                    OR NVL(O.DegReason, '0') <> CAST(NVL(T.DegReason, '0') AS VARCHAR(1000))
                    OR NVL(O.ProvisionAlt_Key, 0) <> NVL(T.ProvisionAlt_Key, 0)
                    OR NVL(O.SMA_Class, '0') <> NVL(T.SMA_Class, '0')
                    OR NVL(O.SMA_Reason, '0') <> CAST(NVL(T.SMA_Reason, '0') AS VARCHAR(1000))
                    OR NVL(O.SourceAlt_Key, 0) <> NVL(T.SourceAlt_Key, 0)
                    OR NVL(O.FlgDeg, '0') <> NVL(T.FlgDeg, '0')
                    OR NVL(O.FlgDirtyRow, '0') <> NVL(T.FlgDirtyRow, '0')
                    OR NVL(O.FlgInMonth, '0') <> NVL(T.FlgInMonth, '0')
                    OR NVL(O.FlgSMA, '0') <> NVL(T.FlgSMA, '0')
                    OR NVL(O.FlgPNPA, '0') <> NVL(T.FlgPNPA, '0')
                    OR NVL(O.FlgUpg, '0') <> NVL(T.FlgUpg, '0')

                    --OR ISNULL(O.DPD_FinMaxType,'0')		<> ISNULL(T.DPD_FinMaxType,'0')    
                    OR NVL(O.REFPeriodMax, 0) <> NVL(T.REFPeriodMax, 0)
                    OR NVL(O.FinalNpaDt, '1900-01-01') <> NVL(T.FinalNpaDt, '1900-01-01')
                    OR NVL(O.FlgFITL, '0') <> NVL(T.FlgFITL, '0')
                    OR NVL(O.FlgAbinitio, '0') <> NVL(T.FlgAbinitio, '0')
                    OR NVL(O.FinalAssetClassAlt_Key, 0) <> NVL(T.FinalAssetClassAlt_Key, 0)
                    OR NVL(O.NPA_Days, 0) <> NVL(T.NPA_Days, 0)
                    OR NVL(O.CommonMocTypeAlt_Key, 0) <> NVL(T.CommonMocTypeAlt_Key, 0) );
         MERGE INTO CurDat_RBL_MISDB_PROD.ADVACCAL O
         USING (SELECT O.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
         FROM CurDat_RBL_MISDB_PROD.ADVACCAL O
                JOIN GTT_AdvAcCal B   ON O.EffectiveFromTimeKey <= v_TimeKey
                AND O.EffectiveToTimeKey >= v_TimeKey
                AND O.EffectiveFromTimeKey < v_TimeKey
                AND O.AccountEntityID = B.AccountEntityID
                JOIN MAIN_PRO.ACCOUNTCAL T   ON T.AccountEntityID = O.AccountEntityID ) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE CurDat_RBL_MISDB_PROD.ADVACCAL O
          WHERE ROWID IN 
         ( SELECT O.ROWID
           FROM CurDat_RBL_MISDB_PROD.ADVACCAL O
                  JOIN GTT_AdvAcCal B   ON O.EffectiveFromTimeKey <= v_TimeKey
                  AND O.EffectiveToTimeKey >= v_TimeKey
                  AND O.AccountEntityID = B.AccountEntityID
          WHERE  O.EffectiveFromTimeKey = v_TimeKey
                   AND O.EffectiveToTimeKey >= v_TimeKey );
         --SELECT * FROM [CurDat].[AdvAcCal] WHERE ACCOUNTENTITYID=33 ORDER BY EffectiveFromTimeKey
         MERGE INTO CurDat_RBL_MISDB_PROD.ADVACCAL O
         USING (SELECT O.ROWID row_id, NVL(T.SecurityValue, 0) AS pos_2, NVL(T.DFVAmt, 0) AS pos_3, NVL(T.GovtGtyAmt, 0) AS pos_4, NVL(T.CoverGovGur, 0) AS pos_5, NVL(T.UnAdjSubSidy, 0) AS pos_6, NVL(T.NetBalance, 0) AS pos_7, NVL(T.ApprRV, 0) AS pos_8, NVL(T.SecuredAmt, 0) AS pos_9, NVL(T.UnSecuredAmt, 0) AS pos_10, NVL(T.ProvDFV, 0) AS pos_11, NVL(T.Provsecured, 0) AS pos_12, NVL(T.ProvUnsecured, 0) AS pos_13, NVL(T.ProvCoverGovGur, 0) AS pos_14, NVL(T.TotalProvision, 0) AS pos_15, NVL(T.AddlProvision, 0) AS pos_16, NVL(T.SMA_Dt, '1900-01-01') AS pos_17, NVL(T.UpgDate, '1900-01-01') AS pos_18, NVL(T.DegReason, '0') AS pos_19, NVL(T.ProvisionAlt_Key, 0) AS pos_20, NVL(T.SMA_Class, '0') AS pos_21, NVL(T.SMA_Reason, '0') AS pos_22, NVL(T.SourceAlt_Key, 0) AS pos_23, NVL(T.FlgDeg, '0') AS pos_24, NVL(T.FlgDirtyRow, '0') AS pos_25, NVL(T.FlgInMonth, '0') AS pos_26, NVL(T.FlgSMA, '0') AS pos_27, NVL(T.FlgPNPA, '0') AS pos_28, NVL(T.FlgUpg, '0') AS pos_29, NVL(T.REFPeriodMax, 0) AS pos_30, NVL(T.FinalNpaDt, '1900-01-01') AS pos_31, NVL(T.FlgFITL, '0') AS pos_32, NVL(T.FlgAbinitio, '0') AS pos_33, NVL(T.FinalAssetClassAlt_Key, 0) AS pos_34, NVL(T.NPA_Days, 0) AS pos_35, NVL(T.CommonMocTypeAlt_Key, 0) AS pos_36
         FROM CurDat_RBL_MISDB_PROD.ADVACCAL O
                JOIN GTT_AdvAcCal B   ON O.EffectiveFromTimeKey = v_TimeKey
                AND O.EffectiveToTimeKey = v_TimeKey
                AND O.AccountEntityID = B.AccountEntityID
                JOIN MAIN_PRO.ACCOUNTCAL T   ON O.AccountEntityID = T.AccountEntityID ) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.SecurityValue = pos_2,
                                      O.DFVAmt = pos_3,
                                      O.GovtGtyAmt = pos_4,
                                      O.CoverGovGur = pos_5,
                                      O.UnAdjSubSidy = pos_6,
                                      O.NetBalance = pos_7,
                                      O.ApprRV = pos_8,
                                      O.SecuredAmt = pos_9,
                                      O.UnSecuredAmt = pos_10,
                                      O.ProvDFV = pos_11,
                                      O.Provsecured = pos_12,
                                      O.ProvUnsecured = pos_13,
                                      O.ProvCoverGovGur = pos_14,
                                      O.TotalProvision = pos_15,
                                      O.AddlProvision = pos_16,
                                      O.SMA_Dt = pos_17,
                                      O.UpgDate = pos_18,
                                      O.DegReason = pos_19,
                                      O.ProvisionAlt_Key = pos_20,
                                      O.SMA_Class = pos_21,
                                      O.SMA_Reason = pos_22,
                                      O.SourceAlt_Key = pos_23,
                                      O.FlgDeg = pos_24,
                                      O.FlgDirtyRow = pos_25,
                                      O.FlgInMonth = pos_26,
                                      O.FlgSMA = pos_27,
                                      O.FlgPNPA = pos_28,
                                      O.FlgUpg
                                      --, O.DPD_FinMaxType			= ISNULL(T.DPD_FinMaxType,'0')    
                                       = pos_29,
                                      O.REFPeriodMax = pos_30,
                                      O.FinalNpaDt = pos_31,
                                      O.FlgFITL = pos_32,
                                      O.FlgAbinitio = pos_33,
                                      O.FinalAssetClassAlt_Key = pos_34,
                                      O.NPA_Days = pos_35,
                                      O.CommonMocTypeAlt_Key = pos_36;
         INSERT INTO CurDat_RBL_MISDB_PROD.ADVACCAL
           ( AccountEntityID, CustomerEntityID, CustomerAcID, RefSystemACID, RefCustomerID, BranchCode, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, UnAdjSubSidy
         --,DPD_IntService
          --,DPD_NoCredit
          --,DPD_Overdrawn
          --,DPD_Overdue
          --,DPD_Renewal
          --,DPD_StockStmt
          --,DPD_Max
         , NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, TotalProvision, AddlProvision, SMA_Dt, UpgDate, DegReason, Asset_Norm, PNPA_Reason, ProvisionAlt_Key, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, SMA_Class, SMA_Reason, SourceAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg
         --,DPD_FinMaxType
         , REFPeriodMax, FinalNpaDt, FlgFITL, FlgAbinitio, FinalAssetClassAlt_Key, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, CommonMocTypeAlt_Key, EffectiveFromTimeKey, EffectiveToTimeKey, FlgMoc, MOC_Dt )
           ( SELECT T.AccountEntityID ,
                    T.CustomerEntityID ,
                    T.CustomerAcID ,
                    T.CustomerAcID ,
                    T.RefCustomerID ,
                    T.BranchCode ,
                    T.SecurityValue ,
                    T.DFVAmt ,
                    T.GovtGtyAmt ,
                    T.CoverGovGur ,
                    T.UnAdjSubSidy ,
                    --,T.DPD_IntService
                    --,T.DPD_NoCredit
                    --,T.DPD_Overdrawn
                    --,T.DPD_Overdue
                    --,T.DPD_Renewal
                    --,T.DPD_StockStmt
                    --,T.DPD_Max
                    T.NetBalance ,
                    T.ApprRV ,
                    T.SecuredAmt ,
                    T.UnSecuredAmt ,
                    T.ProvDFV ,
                    T.Provsecured ,
                    T.ProvUnsecured ,
                    T.ProvCoverGovGur ,
                    T.TotalProvision ,
                    T.AddlProvision ,
                    T.SMA_Dt ,
                    T.UpgDate ,
                    T.DegReason ,
                    T.Asset_Norm ,
                    T.PNPA_Reason ,
                    T.ProvisionAlt_Key ,
                    T.RefPeriodOverdue ,
                    T.RefPeriodOverDrawn ,
                    T.RefPeriodNoCredit ,
                    T.RefPeriodIntService ,
                    T.RefPeriodStkStatement ,
                    T.RefPeriodReview ,
                    T.SMA_Class ,
                    T.SMA_Reason ,
                    T.SourceAlt_Key ,
                    T.FlgDeg ,
                    T.FlgDirtyRow ,
                    T.FlgInMonth ,
                    T.FlgSMA ,
                    T.FlgPNPA ,
                    T.FlgUpg ,
                    --,T.DPD_FinMaxType
                    T.REFPeriodMax ,
                    T.FinalNpaDt ,
                    T.FlgFITL ,
                    T.FlgAbinitio ,
                    T.FinalAssetClassAlt_Key ,
                    T.NPA_Days ,
                    T.RefPeriodOverdueUPG ,
                    T.RefPeriodOverDrawnUPG ,
                    T.RefPeriodNoCreditUPG ,
                    T.RefPeriodIntServiceUPG ,
                    T.RefPeriodStkStatementUPG ,
                    T.RefPeriodReviewUPG ,
                    T.CommonMocTypeAlt_Key ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    T.FlgMoc ,
                    T.MOC_Dt 
             FROM GTT_AdvAcCal A
                    JOIN MAIN_PRO.ACCOUNTCAL T   ON A.AccountEntityID = T.AccountEntityID );
         INSERT INTO CurDat_RBL_MISDB_PROD.ADVACCAL
           ( AccountEntityID, CustomerEntityID, CustomerAcID, RefSystemACID, RefCustomerID, BranchCode, SecurityValue, DFVAmt, OthAdjRec, GovtGtyAmt, CoverGovGur, UnAdjSubSidy, MarginAmt
         --,DPD_IntService
          --,DPD_NoCredit
          --,DPD_Overdrawn
          --,DPD_Overdue
          --,DPD_Renewal
          --,DPD_StockStmt
          --,DPD_Max
         , NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, TotalProvision, AddlProvision, SMA_Dt, UpgDate, DegReason, Asset_Norm, ExposureAmt, PNPA_Reason, ProvisionAlt_Key, PrvAssetClassAlt_Key, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, SMA_Class, SMA_Reason, SourceAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg
         --,DPD_FinMaxType
         , REFPeriodMax, FinalNpaDt, FlgFITL, FlgAbinitio, FinalAssetClassAlt_Key, NPA_Days
         --,RuleAlt_Key_IntService
          --,RuleAlt_Key_NoCredit
          --,RuleAlt_Key_Overdrawn
          --,RuleAlt_Key_Overdue
          --,RuleAlt_Key_Renewal
          --,RuleAlt_Key_StockStmt
         , RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, CommonMocTypeAlt_Key, EffectiveFromTimeKey, EffectiveToTimeKey, FlgMoc, MOC_Dt )
           ( SELECT A.AccountEntityID ,
                    A.CustomerEntityID ,
                    A.CustomerAcID ,
                    A.RefSystemACID ,
                    A.RefCustomerID ,
                    A.BranchCode ,
                    A.SecurityValue ,
                    A.DFVAmt ,
                    A.OthAdjRec ,
                    A.GovtGtyAmt ,
                    A.CoverGovGur ,
                    A.UnAdjSubSidy ,
                    A.MarginAmt ,
                    --,A.DPD_IntService
                    --,A.DPD_NoCredit
                    --,A.DPD_Overdrawn
                    --,A.DPD_Overdue
                    --,A.DPD_Renewal
                    --,A.DPD_StockStmt
                    --,A.DPD_Max
                    A.NetBalance ,
                    A.ApprRV ,
                    A.SecuredAmt ,
                    A.UnSecuredAmt ,
                    A.ProvDFV ,
                    A.Provsecured ,
                    A.ProvUnsecured ,
                    A.ProvCoverGovGur ,
                    A.TotalProvision ,
                    A.AddlProvision ,
                    A.SMA_Dt ,
                    A.UpgDate ,
                    A.DegReason ,
                    A.Asset_Norm ,
                    A.ExposureAmt ,
                    A.PNPA_Reason ,
                    A.ProvisionAlt_Key ,
                    A.PrvAssetClassAlt_Key ,
                    A.RefPeriodOverdue ,
                    A.RefPeriodOverDrawn ,
                    A.RefPeriodNoCredit ,
                    A.RefPeriodIntService ,
                    A.RefPeriodStkStatement ,
                    A.RefPeriodReview ,
                    A.SMA_Class ,
                    A.SMA_Reason ,
                    A.SourceAlt_Key ,
                    A.FlgDeg ,
                    A.FlgDirtyRow ,
                    A.FlgInMonth ,
                    A.FlgSMA ,
                    A.FlgPNPA ,
                    A.FlgUpg ,
                    --,A.DPD_FinMaxType
                    A.REFPeriodMax ,
                    A.FinalNpaDt ,
                    A.FlgFITL ,
                    A.FlgAbinitio ,
                    A.FinalAssetClassAlt_Key ,
                    A.NPA_Days ,
                    --,A.RuleAlt_Key_IntService
                    --,A.RuleAlt_Key_NoCredit
                    --,A.RuleAlt_Key_Overdrawn
                    --,A.RuleAlt_Key_Overdue
                    --,A.RuleAlt_Key_Renewal
                    --,A.RuleAlt_Key_StockStmt
                    A.RefPeriodOverdueUPG ,
                    A.RefPeriodOverDrawnUPG ,
                    A.RefPeriodNoCreditUPG ,
                    A.RefPeriodIntServiceUPG ,
                    A.RefPeriodStkStatementUPG ,
                    A.RefPeriodReviewUPG ,
                    A.CommonMocTypeAlt_Key ,
                    v_TimeKey + 1 EffectiveFromTimeKey  ,
                    A.EffectiveToTimeKey ,
                    A.FlgMoc ,
                    A.MOC_Dt 
             FROM GTT_AdvAcCal A
              WHERE  EffectiveToTimeKey > v_TimeKey );
         DELETE PreMoc_RBL_MISDB_PROD.ADVACCAL A
          WHERE ROWID IN 
         ( SELECT A.ROWID
           FROM PreMoc_RBL_MISDB_PROD.ADVACCAL A
                  LEFT JOIN CurDat_RBL_MISDB_PROD.ADVACCAL B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                  AND B.EffectiveToTimeKey = v_TimeKey )
                  AND B.FlgMoc = 'Y'
                  AND A.AccountEntityID = B.AccountEntityID
          WHERE  ( A.EffectiveFromTimeKey = v_TimeKey
                   AND A.EffectiveToTimeKey = v_TimeKey )
                   AND B.AccountEntityID IS NULL );
         /* CUSTOMER CAL*/

         DELETE FROM GTT_AdvCustCal;
         UTILS.IDENTITY_RESET('GTT_AdvCustCal');

         INSERT INTO GTT_AdvCustCal ( 
         	SELECT O.* 
         	  FROM CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
                   JOIN MAIN_PRO.CUSTOMERCAL T   ON ( O.EffectiveFromTimeKey <= v_TimeKey
                   AND O.EffectiveToTimeKey >= v_TimeKey )
                   AND O.CustomerEntityID = T.CustomerEntityID
         	 WHERE  ( NVL(O.UCIF_ID, 0) <> NVL(T.UCIF_ID, 0)
                    OR NVL(O.CustSegmentCode, 0) <> NVL(T.CustSegmentCode, 0)
                    OR NVL(O.SrcAssetClassAlt_Key, 0) <> NVL(T.SrcAssetClassAlt_Key, 0)
                    OR NVL(O.SysAssetClassAlt_Key, 0) <> NVL(T.SysAssetClassAlt_Key, 0)
                    OR NVL(O.SMA_Class_Key, 0) <> NVL(T.SMA_Class_Key, 0)
                    OR NVL(O.PNPA_Class_Key, 0) <> NVL(T.PNPA_Class_Key, 0)
                    OR NVL(O.PrvQtrRV, 0) <> NVL(T.PrvQtrRV, 0)
                    OR NVL(O.CurntQtrRv, 0) <> NVL(T.CurntQtrRv, 0)
                    OR NVL(O.TotProvision, 0) <> NVL(T.TotProvision, 0)
                    OR NVL(O.SrcNPA_Dt, '1900-01-01') <> NVL(T.SrcNPA_Dt, '1900-01-01')
                    OR NVL(O.SysNPA_Dt, '1900-01-01') <> NVL(T.SysNPA_Dt, '1900-01-01')
                    OR NVL(O.DbtDt, '1900-01-01') <> NVL(T.DbtDt, '1900-01-01')
                    OR NVL(O.LossDt, '1900-01-01') <> NVL(T.LossDt, '1900-01-01')
                    OR NVL(O.MOC_Dt, '1900-01-01') <> NVL(T.MOC_Dt, '1900-01-01')
                    OR NVL(O.ErosionDt, '1900-01-01') <> NVL(T.ErosionDt, '1900-01-01')
                    OR NVL(O.SMA_Dt, '1900-01-01') <> NVL(T.SMA_Dt, '1900-01-01')
                    OR NVL(O.PNPA_Dt, '1900-01-01') <> NVL(T.PNPA_Dt, '1900-01-01')
                    OR NVL(O.Asset_Norm, '0') <> NVL(T.Asset_Norm, '0')
                    OR NVL(O.FlgDeg, '0') <> NVL(T.FlgDeg, '0')
                    OR NVL(O.FlgUpg, '0') <> NVL(T.FlgUpg, '0')
                    OR NVL(O.FlgMoc, '0') <> NVL(T.FlgMoc, '0')
                    OR NVL(O.FlgSMA, '0') <> NVL(T.FlgSMA, '0')
                    OR NVL(O.FlgProcessing, '0') <> NVL(T.FlgProcessing, '0')
                    OR NVL(O.FlgErosion, '0') <> NVL(T.FlgErosion, '0')
                    OR NVL(O.FlgPNPA, '0') <> NVL(T.FlgPNPA, '0')
                    OR NVL(O.FlgPercolation, '0') <> NVL(T.FlgPercolation, '0')
                    OR NVL(O.FlgInMonth, '0') <> NVL(T.FlgInMonth, '0')
                    OR NVL(O.FlgDirtyRow, '0') <> NVL(T.FlgDirtyRow, '0')
                    OR NVL(O.DegDate, '1900-01-01') <> NVL(T.DegDate, '1900-01-01')
                    OR NVL(O.CommonMocTypeAlt_Key, 0) <> NVL(T.CommonMocTypeAlt_Key, 0) ) );
         MERGE INTO CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
         USING (SELECT O.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
         FROM CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
                JOIN GTT_AdvCustCal B   ON O.EffectiveFromTimeKey <= v_TimeKey
                AND O.EffectiveToTimeKey >= v_TimeKey
                AND O.EffectiveFromTimeKey < v_TimeKey
                AND O.CustomerEntityID = B.CustomerEntityID
                JOIN MAIN_PRO.CUSTOMERCAL T   ON T.CustomerEntityID = O.CustomerEntityID ) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = src.EffectiveToTimeKey;
         DELETE CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
          WHERE ROWID IN 
         ( SELECT O.ROWID
           FROM CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
                  JOIN GTT_AdvCustCal B   ON O.EffectiveFromTimeKey <= v_TimeKey
                  AND O.EffectiveToTimeKey >= v_TimeKey
                  AND O.CustomerEntityID = B.CustomerEntityID
          WHERE  O.EffectiveFromTimeKey = v_TimeKey
                   AND O.EffectiveToTimeKey >= v_TimeKey );
         MERGE INTO CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
         USING (SELECT O.ROWID row_id, T.BranchCode, T.UCIF_ID, T.CustomerEntityID, T.ParentCustomerID, T.RefCustomerID, T.CustSegmentCode, T.SrcAssetClassAlt_Key, T.SysAssetClassAlt_Key, T.SMA_Class_Key, T.PNPA_Class_Key, T.PrvQtrRV, T.CurntQtrRv, T.TotProvision, T.SrcNPA_Dt, T.SysNPA_Dt, T.DbtDt, T.LossDt, T.MOC_Dt, T.ErosionDt, T.SMA_Dt, T.PNPA_Dt, T.Asset_Norm, T.FlgDeg, T.FlgUpg, T.FlgMoc, T.FlgSMA, T.FlgProcessing, T.FlgErosion, T.FlgPNPA, T.FlgPercolation, T.FlgInMonth, T.FlgDirtyRow, T.DegDate, T.EffectiveFromTimeKey, T.EffectiveToTimeKey, T.CommonMocTypeAlt_Key
         FROM CurDat_RBL_MISDB_PROD.ADVCUSTCAL O
                JOIN GTT_AdvCustCal B   ON O.EffectiveFromTimeKey = v_TimeKey
                AND O.EffectiveToTimeKey = v_TimeKey
                AND O.CustomerEntityID = B.CustomerEntityID
                JOIN MAIN_PRO.CUSTOMERCAL T   ON O.CustomerEntityID = T.CustomerEntityID ) src
         ON ( O.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET O.BranchCode = src.BranchCode,
                                      O.UCIF_ID = src.UCIF_ID,
                                      O.CustomerEntityID = src.CustomerEntityID,
                                      O.ParentCustomerID = src.ParentCustomerID,
                                      O.RefCustomerID = src.RefCustomerID,
                                      O.CustSegmentCode = src.CustSegmentCode,
                                      O.SrcAssetClassAlt_Key = src.SrcAssetClassAlt_Key,
                                      O.SysAssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                      O.SMA_Class_Key = src.SMA_Class_Key,
                                      O.PNPA_Class_Key = src.PNPA_Class_Key,
                                      O.PrvQtrRV = src.PrvQtrRV,
                                      O.CurntQtrRv = src.CurntQtrRv,
                                      O.TotProvision = src.TotProvision,
                                      O.SrcNPA_Dt = src.SrcNPA_Dt,
                                      O.SysNPA_Dt = src.SysNPA_Dt,
                                      O.DbtDt = src.DbtDt,
                                      O.LossDt = src.LossDt,
                                      O.MOC_Dt = src.MOC_Dt,
                                      O.ErosionDt = src.ErosionDt,
                                      O.SMA_Dt = src.SMA_Dt,
                                      O.PNPA_Dt = src.PNPA_Dt,
                                      O.Asset_Norm = src.Asset_Norm,
                                      O.FlgDeg = src.FlgDeg,
                                      O.FlgUpg = src.FlgUpg,
                                      O.FlgMoc = src.FlgMoc,
                                      O.FlgSMA = src.FlgSMA,
                                      O.FlgProcessing = src.FlgProcessing,
                                      O.FlgErosion = src.FlgErosion,
                                      O.FlgPNPA = src.FlgPNPA,
                                      O.FlgPercolation = src.FlgPercolation,
                                      O.FlgInMonth = src.FlgInMonth,
                                      O.FlgDirtyRow = src.FlgDirtyRow,
                                      O.DegDate = src.DegDate,
                                      O.EffectiveFromTimeKey = src.EffectiveFromTimeKey,
                                      O.EffectiveToTimeKey = src.EffectiveToTimeKey,
                                      O.CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key;
         INSERT INTO CurDat_RBL_MISDB_PROD.ADVCUSTCAL
           ( BranchCode, UCIF_ID, CustomerEntityID, ParentCustomerID, RefCustomerID, CustSegmentCode, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key )
           ( SELECT T.BranchCode ,
                    T.UCIF_ID ,
                    T.CustomerEntityID ,
                    T.ParentCustomerID ,
                    T.RefCustomerID ,
                    T.CustSegmentCode ,
                    T.SrcAssetClassAlt_Key ,
                    T.SysAssetClassAlt_Key ,
                    T.SMA_Class_Key ,
                    T.PNPA_Class_Key ,
                    T.PrvQtrRV ,
                    T.CurntQtrRv ,
                    T.TotProvision ,
                    T.SrcNPA_Dt ,
                    T.SysNPA_Dt ,
                    T.DbtDt ,
                    T.LossDt ,
                    T.MOC_Dt ,
                    T.ErosionDt ,
                    T.SMA_Dt ,
                    T.PNPA_Dt ,
                    T.Asset_Norm ,
                    T.FlgDeg ,
                    T.FlgUpg ,
                    T.FlgMoc ,
                    T.FlgSMA ,
                    T.FlgProcessing ,
                    T.FlgErosion ,
                    T.FlgPNPA ,
                    T.FlgPercolation ,
                    T.FlgInMonth ,
                    T.FlgDirtyRow ,
                    T.DegDate ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    T.CommonMocTypeAlt_Key 
             FROM GTT_AdvCustCal A
                    JOIN MAIN_PRO.CUSTOMERCAL T   ON A.CustomerEntityID = T.CustomerEntityID );
         INSERT INTO CurDat_RBL_MISDB_PROD.ADVCUSTCAL
           ( BranchCode, UCIF_ID, CustomerEntityID, ParentCustomerID, RefCustomerID, CustSegmentCode, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key )
           ( SELECT BranchCode ,
                    UCIF_ID ,
                    CustomerEntityID ,
                    ParentCustomerID ,
                    RefCustomerID ,
                    CustSegmentCode ,
                    SrcAssetClassAlt_Key ,
                    SysAssetClassAlt_Key ,
                    SMA_Class_Key ,
                    PNPA_Class_Key ,
                    PrvQtrRV ,
                    CurntQtrRv ,
                    TotProvision ,
                    SrcNPA_Dt ,
                    SysNPA_Dt ,
                    DbtDt ,
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
                    v_TimeKey + 1 EffectiveFromTimeKey  ,
                    EffectiveToTimeKey ,
                    CommonMocTypeAlt_Key 
             FROM GTT_AdvCustCal A
              WHERE  EffectiveToTimeKey > v_TimeKey );
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Cust_AccCal_Merge_Moc';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   
    v_SQLERRM :=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Cust_AccCal_Merge_Moc';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUST_ACCCAL_MERGE_MOC" TO "ADF_CDR_RBL_STGDB";
