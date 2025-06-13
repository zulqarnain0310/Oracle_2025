--------------------------------------------------------
--  DDL for Procedure UPDATEDATAINHISTTABLE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPDATEDATAINHISTTABLE" 
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN

   MERGE INTO RBL_MISDB_PROD.MOC_ChangeDetails A
   USING (SELECT A.ROWID row_id, B.SysAssetClassAlt_Key, B.SysNPA_Dt
   FROM RBL_MISDB_PROD.MOC_ChangeDetails A
          JOIN MAIN_PRO.CUSTOMERCAL B   ON B.EffectiveFromTimeKey <= v_TIMEKEY
          AND b.EffectiveToTimeKey >= v_TIMEKEY
          AND a.CustomerEntityID = b.CustomerEntityID 
    WHERE NVL(B.MOCTYPE, ' ') = 'Manual') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                A.NPA_Date = src.SysNPA_Dt;
                                
   MERGE INTO MAIN_PRO.CustomerCal_Hist B 
   USING (SELECT B.ROWID row_id, A.BranchCode, A.UCIF_ID, A.UcifEntityID, A.CustomerEntityID, A.ParentCustomerID, A.RefCustomerID, A.SourceSystemCustomerID, A.CustomerName, A.CustSegmentCode, A.ConstitutionAlt_Key, A.PANNO, A.AadharCardNO, A.SrcAssetClassAlt_Key, A.SysAssetClassAlt_Key, A.SplCatg1Alt_Key, A.SplCatg2Alt_Key, A.SplCatg3Alt_Key, A.SplCatg4Alt_Key, A.SMA_Class_Key, A.PNPA_Class_Key, A.PrvQtrRV, A.CurntQtrRv, A.TotProvision, A.RBITotProvision, A.BankTotProvision, A.SrcNPA_Dt, A.SysNPA_Dt, A.DbtDt, A.DbtDt2, A.DbtDt3, A.LossDt, A.MOC_Dt, A.ErosionDt, A.SMA_Dt, A.PNPA_Dt, A.Asset_Norm, A.FlgDeg, A.FlgUpg, A.FlgMoc, A.FlgSMA, A.FlgProcessing, A.FlgErosion, A.FlgPNPA, A.FlgPercolation, A.FlgInMonth, A.FlgDirtyRow, A.DegDate, A.EffectiveFromTimeKey, A.EffectiveToTimeKey, A.CommonMocTypeAlt_Key, A.InMonthMark, A.MocStatusMark, A.SourceAlt_Key, A.BankAssetClass, A.Cust_Expo, A.MOCReason, A.AddlProvisionPer, A.FraudDt, A.FraudAmount, A.DegReason
   --,B.DateOfData	=	A.DateOfData
   , A.CustMoveDescription, A.TotOsCust
   --,B.MOCTYPE	=	A.MOCTYPE

   FROM MAIN_PRO.CUSTOMERCAL A
          JOIN MAIN_PRO.CustomerCal_Hist B   ON b.EffectiveFromTimeKey = v_TIMEKEY
          AND b.EffectiveToTimeKey = v_TIMEKEY
          AND a.CustomerEntityID = b.CustomerEntityID ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.BranchCode = src.BranchCode,
                                B.UCIF_ID = src.UCIF_ID,
                                B.UcifEntityID = src.UcifEntityID,
                                B.CustomerEntityID = src.CustomerEntityID,
                                B.ParentCustomerID = src.ParentCustomerID,
                                B.RefCustomerID = src.RefCustomerID,
                                B.SourceSystemCustomerID = src.SourceSystemCustomerID,
                                B.CustomerName = src.CustomerName,
                                B.CustSegmentCode = src.CustSegmentCode,
                                B.ConstitutionAlt_Key = src.ConstitutionAlt_Key,
                                B.PANNO = src.PANNO,
                                B.AadharCardNO = src.AadharCardNO,
                                B.SrcAssetClassAlt_Key = src.SrcAssetClassAlt_Key,
                                B.SysAssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                B.SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                B.SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                B.SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                B.SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                B.SMA_Class_Key = src.SMA_Class_Key,
                                B.PNPA_Class_Key = src.PNPA_Class_Key,
                                B.PrvQtrRV = src.PrvQtrRV,
                                B.CurntQtrRv = src.CurntQtrRv,
                                B.TotProvision = src.TotProvision,
                                B.RBITotProvision = src.RBITotProvision,
                                B.BankTotProvision = src.BankTotProvision,
                                B.SrcNPA_Dt = src.SrcNPA_Dt,
                                B.SysNPA_Dt = src.SysNPA_Dt,
                                B.DbtDt = src.DbtDt,
                                B.DbtDt2 = src.DbtDt2,
                                B.DbtDt3 = src.DbtDt3,
                                B.LossDt = src.LossDt,
                                B.MOC_Dt = src.MOC_Dt,
                                B.ErosionDt = src.ErosionDt,
                                B.SMA_Dt = src.SMA_Dt,
                                B.PNPA_Dt = src.PNPA_Dt,
                                B.Asset_Norm = src.Asset_Norm,
                                B.FlgDeg = src.FlgDeg,
                                B.FlgUpg = src.FlgUpg,
                                B.FlgMoc = src.FlgMoc,
                                B.FlgSMA = src.FlgSMA,
                                B.FlgProcessing = src.FlgProcessing,
                                B.FlgErosion = src.FlgErosion,
                                B.FlgPNPA = src.FlgPNPA,
                                B.FlgPercolation = src.FlgPercolation,
                                B.FlgInMonth = src.FlgInMonth,
                                B.FlgDirtyRow = src.FlgDirtyRow,
                                B.DegDate = src.DegDate,
                                B.EffectiveFromTimeKey = src.EffectiveFromTimeKey,
                                B.EffectiveToTimeKey = src.EffectiveToTimeKey,
                                B.CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                B.InMonthMark = src.InMonthMark,
                                B.MocStatusMark = src.MocStatusMark,
                                B.SourceAlt_Key = src.SourceAlt_Key,
                                B.BankAssetClass = src.BankAssetClass,
                                B.Cust_Expo = src.Cust_Expo,
                                B.MOCReason = src.MOCReason,
                                B.AddlProvisionPer = src.AddlProvisionPer,
                                B.FraudDt = src.FraudDt,
                                B.FraudAmount = src.FraudAmount,
                                B.DegReason = src.DegReason,
                                B.CustMoveDescription = src.CustMoveDescription,
                                B.TotOsCust = src.TotOsCust;
                                
   MERGE INTO MAIN_PRO.AccountCal_Hist B 
   USING (SELECT B.ROWID row_id, A.AccountEntityID, A.UcifEntityID, A.CustomerEntityID, A.CustomerAcID, A.RefCustomerID, A.SourceSystemCustomerID, A.UCIF_ID, A.BranchCode, A.FacilityType, A.AcOpenDt, A.FirstDtOfDisb, A.ProductAlt_Key, A.SchemeAlt_key, A.SubSectorAlt_Key, A.SplCatg1Alt_Key, A.SplCatg2Alt_Key, A.SplCatg3Alt_Key, A.SplCatg4Alt_Key, A.SourceAlt_Key, A.ActSegmentCode, A.InttRate, A.Balance, A.BalanceInCrncy, A.CurrencyAlt_Key, A.DrawingPower, A.CurrentLimit, A.CurrentLimitDt, A.ContiExcessDt, A.StockStDt, A.DebitSinceDt, A.LastCrDate, A.PreQtrCredit, A.PrvQtrInt, A.CurQtrCredit, A.CurQtrInt, A.InttServiced, A.IntNotServicedDt, A.OverdueAmt, A.OverDueSinceDt, A.ReviewDueDt, A.SecurityValue, A.DFVAmt, A.GovtGtyAmt, A.CoverGovGur, A.WriteOffAmount, A.UnAdjSubSidy, A.CreditsinceDt
   , A.DegReason, A.Asset_Norm, A.REFPeriodMax, A.RefPeriodOverdue, A.RefPeriodOverDrawn, A.RefPeriodNoCredit, A.RefPeriodIntService, A.RefPeriodStkStatement, A.RefPeriodReview, A.NetBalance, A.ApprRV, A.SecuredAmt, A.UnSecuredAmt, A.ProvDFV, A.Provsecured, A.ProvUnsecured, A.ProvCoverGovGur, A.AddlProvision, A.TotalProvision, A.BankProvsecured, A.BankProvUnsecured, A.BankTotalProvision, A.RBIProvsecured, A.RBIProvUnsecured, A.RBITotalProvision, A.InitialNpaDt, A.FinalNpaDt, A.SMA_Dt, A.UpgDate, A.InitialAssetClassAlt_Key, A.FinalAssetClassAlt_Key, A.ProvisionAlt_Key, A.PNPA_Reason, A.SMA_Class, A.SMA_Reason, A.FlgMoc, A.MOC_Dt, A.CommonMocTypeAlt_Key
   , A.FlgDeg, A.FlgDirtyRow, A.FlgInMonth, A.FlgSMA, A.FlgPNPA, A.FlgUpg, A.FlgFITL, A.FlgAbinitio, A.NPA_Days, A.RefPeriodOverdueUPG, A.RefPeriodOverDrawnUPG, A.RefPeriodNoCreditUPG, A.RefPeriodIntServiceUPG, A.RefPeriodStkStatementUPG, A.RefPeriodReviewUPG, A.EffectiveFromTimeKey, A.EffectiveToTimeKey, A.AppGovGur, A.UsedRV, A.ComputedClaim, A.UPG_RELAX_MSME, A.DEG_RELAX_MSME, A.PNPA_DATE, A.NPA_Reason, A.PnpaAssetClassAlt_key, A.DisbAmount, A.PrincOutStd, A.PrincOverdue, A.PrincOverdueSinceDt
   , A.IntOverdue, A.IntOverdueSinceDt
   , A.OtherOverdue, A.OtherOverdueSinceDt
   , A.RelationshipNumber, A.AccountFlag, A.CommercialFlag_AltKey, A.Liability, A.CD, A.AccountStatus, A.AccountBlkCode1, A.AccountBlkCode2, A.ExposureType, A.Mtm_Value, A.BankAssetClass, A.NpaType, A.SecApp, A.BorrowerTypeID, A.LineCode, A.ProvPerSecured, A.ProvPerUnSecured, A.MOCReason, A.AddlProvisionPer, A.FlgINFRA, A.RepossessionDate
   , A.DerecognisedInterest1, A.DerecognisedInterest2, A.ProductCode, A.FlgLCBG, A.UnserviedInt, A.AdvanceRecovery, A.NotionalInttAmt, A.OriginalBranchcode, A.PrvAssetClassAlt_Key, A.MOCTYPE, A.FlgSecured
   FROM MAIN_PRO.ACCOUNTCAL A
          JOIN MAIN_PRO.AccountCal_Hist B   ON b.EffectiveFromTimeKey = v_TIMEKEY
          AND b.EffectiveToTimeKey = v_TIMEKEY
          AND a.AccountEntityID = b.AccountEntityID ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.AccountEntityID = src.AccountEntityID,
                                B.UcifEntityID = src.UcifEntityID,
                                B.CustomerEntityID = src.CustomerEntityID,
                                B.CustomerAcID = src.CustomerAcID,
                                B.RefCustomerID = src.RefCustomerID,
                                B.SourceSystemCustomerID = src.SourceSystemCustomerID,
                                B.UCIF_ID = src.UCIF_ID,
                                B.BranchCode = src.BranchCode,
                                B.FacilityType = src.FacilityType,
                                B.AcOpenDt = src.AcOpenDt,
                                B.FirstDtOfDisb = src.FirstDtOfDisb,
                                B.ProductAlt_Key = src.ProductAlt_Key,
                                B.SchemeAlt_key = src.SchemeAlt_key,
                                B.SubSectorAlt_Key = src.SubSectorAlt_Key,
                                B.SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                B.SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                B.SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                B.SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                B.SourceAlt_Key = src.SourceAlt_Key,
                                B.ActSegmentCode = src.ActSegmentCode,
                                B.InttRate = src.InttRate,
                                B.Balance = src.Balance,
                                B.BalanceInCrncy = src.BalanceInCrncy,
                                B.CurrencyAlt_Key = src.CurrencyAlt_Key,
                                B.DrawingPower = src.DrawingPower,
                                B.CurrentLimit = src.CurrentLimit,
                                B.CurrentLimitDt = src.CurrentLimitDt,
                                B.ContiExcessDt = src.ContiExcessDt,
                                B.StockStDt = src.StockStDt,
                                B.DebitSinceDt = src.DebitSinceDt,
                                B.LastCrDate = src.LastCrDate,
                                B.PreQtrCredit = src.PreQtrCredit,
                                B.PrvQtrInt = src.PrvQtrInt,
                                B.CurQtrCredit = src.CurQtrCredit,
                                B.CurQtrInt = src.CurQtrInt,
                                B.InttServiced = src.InttServiced,
                                B.IntNotServicedDt = src.IntNotServicedDt,
                                B.OverdueAmt = src.OverdueAmt,
                                B.OverDueSinceDt = src.OverDueSinceDt,
                                B.ReviewDueDt = src.ReviewDueDt,
                                B.SecurityValue = src.SecurityValue,
                                B.DFVAmt = src.DFVAmt,
                                B.GovtGtyAmt = src.GovtGtyAmt,
                                B.CoverGovGur = src.CoverGovGur,
                                B.WriteOffAmount = src.WriteOffAmount,
                                B.UnAdjSubSidy = src.UnAdjSubSidy,
                                B.CreditsinceDt = src.CreditsinceDt,
                                B.DegReason = src.DegReason,
                                B.Asset_Norm = src.Asset_Norm,
                                B.REFPeriodMax = src.REFPeriodMax,
                                B.RefPeriodOverdue = src.RefPeriodOverdue,
                                B.RefPeriodOverDrawn = src.RefPeriodOverDrawn,
                                B.RefPeriodNoCredit = src.RefPeriodNoCredit,
                                B.RefPeriodIntService = src.RefPeriodIntService,
                                B.RefPeriodStkStatement = src.RefPeriodStkStatement,
                                B.RefPeriodReview = src.RefPeriodReview,
                                B.NetBalance = src.NetBalance,
                                B.ApprRV = src.ApprRV,
                                B.SecuredAmt = src.SecuredAmt,
                                B.UnSecuredAmt = src.UnSecuredAmt,
                                B.ProvDFV = src.ProvDFV,
                                B.Provsecured = src.Provsecured,
                                B.ProvUnsecured = src.ProvUnsecured,
                                B.ProvCoverGovGur = src.ProvCoverGovGur,
                                B.AddlProvision = src.AddlProvision,
                                B.TotalProvision = src.TotalProvision,
                                B.BankProvsecured = src.BankProvsecured,
                                B.BankProvUnsecured = src.BankProvUnsecured,
                                B.BankTotalProvision = src.BankTotalProvision,
                                B.RBIProvsecured = src.RBIProvsecured,
                                B.RBIProvUnsecured = src.RBIProvUnsecured,
                                B.RBITotalProvision = src.RBITotalProvision,
                                B.InitialNpaDt = src.InitialNpaDt,
                                B.FinalNpaDt = src.FinalNpaDt,
                                B.SMA_Dt = src.SMA_Dt,
                                B.UpgDate = src.UpgDate,
                                B.InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                B.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                B.ProvisionAlt_Key = src.ProvisionAlt_Key,
                                B.PNPA_Reason = src.PNPA_Reason,
                                B.SMA_Class = src.SMA_Class,
                                B.SMA_Reason = src.SMA_Reason,
                                B.FlgMoc = src.FlgMoc,
                                B.MOC_Dt = src.MOC_Dt,
                                B.CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                B.FlgDeg = src.FlgDeg,
                                B.FlgDirtyRow = src.FlgDirtyRow,
                                B.FlgInMonth = src.FlgInMonth,
                                B.FlgSMA = src.FlgSMA,
                                B.FlgPNPA = src.FlgPNPA,
                                B.FlgUpg = src.FlgUpg,
                                B.FlgFITL = src.FlgFITL,
                                B.FlgAbinitio = src.FlgAbinitio,
                                B.NPA_Days = src.NPA_Days,
                                B.RefPeriodOverdueUPG = src.RefPeriodOverdueUPG,
                                B.RefPeriodOverDrawnUPG = src.RefPeriodOverDrawnUPG,
                                B.RefPeriodNoCreditUPG = src.RefPeriodNoCreditUPG,
                                B.RefPeriodIntServiceUPG = src.RefPeriodIntServiceUPG,
                                B.RefPeriodStkStatementUPG = src.RefPeriodStkStatementUPG,
                                B.RefPeriodReviewUPG = src.RefPeriodReviewUPG,
                                B.EffectiveFromTimeKey = src.EffectiveFromTimeKey,
                                B.EffectiveToTimeKey = src.EffectiveToTimeKey,
                                B.AppGovGur = src.AppGovGur,
                                B.UsedRV = src.UsedRV,
                                B.ComputedClaim = src.ComputedClaim,
                                B.UPG_RELAX_MSME = src.UPG_RELAX_MSME,
                                B.DEG_RELAX_MSME = src.DEG_RELAX_MSME,
                                B.PNPA_DATE = src.PNPA_DATE,
                                B.NPA_Reason = src.NPA_Reason,
                                B.PnpaAssetClassAlt_key = src.PnpaAssetClassAlt_key,
                                B.DisbAmount = src.DisbAmount,
                                B.PrincOutStd = src.PrincOutStd,
                                B.PrincOverdue = src.PrincOverdue,
                                B.PrincOverdueSinceDt = src.PrincOverdueSinceDt,
                                B.IntOverdue = src.IntOverdue,
                                B.IntOverdueSinceDt = src.IntOverdueSinceDt,
                                B.OtherOverdue = src.OtherOverdue,
                                B.OtherOverdueSinceDt = src.OtherOverdueSinceDt,
                                B.RelationshipNumber = src.RelationshipNumber,
                                B.AccountFlag = src.AccountFlag,
                                B.CommercialFlag_AltKey = src.CommercialFlag_AltKey,
                                B.Liability = src.Liability,
                                B.CD = src.CD,
                                B.AccountStatus = src.AccountStatus,
                                B.AccountBlkCode1 = src.AccountBlkCode1,
                                B.AccountBlkCode2 = src.AccountBlkCode2,
                                B.ExposureType = src.ExposureType,
                                B.Mtm_Value = src.Mtm_Value,
                                B.BankAssetClass = src.BankAssetClass,
                                B.NpaType = src.NpaType,
                                B.SecApp = src.SecApp,
                                B.BorrowerTypeID = src.BorrowerTypeID,
                                B.LineCode = src.LineCode,
                                B.ProvPerSecured = src.ProvPerSecured,
                                B.ProvPerUnSecured = src.ProvPerUnSecured,
                                B.MOCReason = src.MOCReason,
                                B.AddlProvisionPer = src.AddlProvisionPer,
                                B.FlgINFRA = src.FlgINFRA,
                                B.RepossessionDate = src.RepossessionDate,
                                B.DerecognisedInterest1 = src.DerecognisedInterest1,
                                B.DerecognisedInterest2 = src.DerecognisedInterest2,
                                B.ProductCode = src.ProductCode,
                                B.FlgLCBG = src.FlgLCBG,
                                B.unserviedint = src.UnserviedInt,
                                B.AdvanceRecovery = src.AdvanceRecovery,
                                B.NotionalInttAmt = src.NotionalInttAmt,
                                B.OriginalBranchcode = src.OriginalBranchcode,
                                B.PrvAssetClassAlt_Key = src.PrvAssetClassAlt_Key,
                                B.MOCTYPE = src.MOCTYPE,
                                B.FlgSecured = src.FlgSecured;--ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_IntService 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_NoCredit 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Overdrawn 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Overdue 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Renewal 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_StockStmt 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_Max  
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_FinMaxType 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_SMA  
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_PrincOverdue 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_IntOverdueSince 
   --ALTER TABLE PRO.ACCOUNTCAL DROP COLUMN DPD_OtherOverdueSince 

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEDATAINHISTTABLE" TO "ADF_CDR_RBL_STGDB";
