--------------------------------------------------------
--  DDL for Procedure MOCACCOUNT_26114TOBEDELETED
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" 
AS

BEGIN

   DELETE FROM tt_AA_22;
   UTILS.IDENTITY_RESET('tt_AA_22');

   INSERT INTO tt_AA_22 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectivefromTimeKey = 26115
              AND EffectiveToTimeKey = 26115
              AND RefCustomerID = '0211101762500000330' );
   UPDATE tt_AA_22
      SET EffectiveFromTimeKey = 26114,
          EffectiveToTimeKey = 26114;
   INSERT INTO PRO_RBL_MISDB_PROD.AccountCal_Hist
     ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate, ScreenFlag, ChangeField )
     ( SELECT AccountEntityID ,
              UcifEntityID ,
              CustomerEntityID ,
              CustomerAcID ,
              RefCustomerID ,
              SourceSystemCustomerID ,
              UCIF_ID ,
              BranchCode ,
              FacilityType ,
              AcOpenDt ,
              FirstDtOfDisb ,
              ProductAlt_Key ,
              SchemeAlt_key ,
              SubSectorAlt_Key ,
              SplCatg1Alt_Key ,
              SplCatg2Alt_Key ,
              SplCatg3Alt_Key ,
              SplCatg4Alt_Key ,
              SourceAlt_Key ,
              ActSegmentCode ,
              InttRate ,
              Balance ,
              BalanceInCrncy ,
              CurrencyAlt_Key ,
              DrawingPower ,
              CurrentLimit ,
              CurrentLimitDt ,
              ContiExcessDt ,
              StockStDt ,
              DebitSinceDt ,
              LastCrDate ,
              InttServiced ,
              IntNotServicedDt ,
              OverdueAmt ,
              OverDueSinceDt ,
              ReviewDueDt ,
              SecurityValue ,
              DFVAmt ,
              GovtGtyAmt ,
              CoverGovGur ,
              WriteOffAmount ,
              UnAdjSubSidy ,
              CreditsinceDt ,
              DegReason ,
              Asset_Norm ,
              REFPeriodMax ,
              RefPeriodOverdue ,
              RefPeriodOverDrawn ,
              RefPeriodNoCredit ,
              RefPeriodIntService ,
              RefPeriodStkStatement ,
              RefPeriodReview ,
              NetBalance ,
              ApprRV ,
              SecuredAmt ,
              UnSecuredAmt ,
              ProvDFV ,
              Provsecured ,
              ProvUnsecured ,
              ProvCoverGovGur ,
              AddlProvision ,
              TotalProvision ,
              BankProvsecured ,
              BankProvUnsecured ,
              BankTotalProvision ,
              RBIProvsecured ,
              RBIProvUnsecured ,
              RBITotalProvision ,
              InitialNpaDt ,
              FinalNpaDt ,
              SMA_Dt ,
              UpgDate ,
              InitialAssetClassAlt_Key ,
              FinalAssetClassAlt_Key ,
              ProvisionAlt_Key ,
              PNPA_Reason ,
              SMA_Class ,
              SMA_Reason ,
              FlgMoc ,
              MOC_Dt ,
              CommonMocTypeAlt_Key ,
              FlgDeg ,
              FlgDirtyRow ,
              FlgInMonth ,
              FlgSMA ,
              FlgPNPA ,
              FlgUpg ,
              FlgFITL ,
              FlgAbinitio ,
              NPA_Days ,
              RefPeriodOverdueUPG ,
              RefPeriodOverDrawnUPG ,
              RefPeriodNoCreditUPG ,
              RefPeriodIntServiceUPG ,
              RefPeriodStkStatementUPG ,
              RefPeriodReviewUPG ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              AppGovGur ,
              UsedRV ,
              ComputedClaim ,
              UPG_RELAX_MSME ,
              DEG_RELAX_MSME ,
              PNPA_DATE ,
              NPA_Reason ,
              PnpaAssetClassAlt_key ,
              DisbAmount ,
              PrincOutStd ,
              PrincOverdue ,
              PrincOverdueSinceDt ,
              IntOverdue ,
              IntOverdueSinceDt ,
              OtherOverdue ,
              OtherOverdueSinceDt ,
              RelationshipNumber ,
              AccountFlag ,
              CommercialFlag_AltKey ,
              Liability ,
              CD ,
              AccountStatus ,
              AccountBlkCode1 ,
              AccountBlkCode2 ,
              ExposureType ,
              Mtm_Value ,
              BankAssetClass ,
              NpaType ,
              SecApp ,
              BorrowerTypeID ,
              LineCode ,
              ProvPerSecured ,
              ProvPerUnSecured ,
              MOCReason ,
              AddlProvisionPer ,
              FlgINFRA ,
              RepossessionDate ,
              DerecognisedInterest1 ,
              DerecognisedInterest2 ,
              ProductCode ,
              FlgLCBG ,
              unserviedint ,
              PreQtrCredit ,
              PrvQtrInt ,
              CurQtrCredit ,
              CurQtrInt ,
              OriginalBranchcode ,
              AdvanceRecovery ,
              NotionalInttAmt ,
              PrvAssetClassAlt_Key ,
              MOCTYPE ,
              FlgSecured ,
              RePossession ,
              RCPending ,
              PaymentPending ,
              WheelCase ,
              CustomerLevelMaxPer ,
              FinalProvisionPer ,
              IsIBPC ,
              IsSecuritised ,
              RFA ,
              IsNonCooperative ,
              Sarfaesi ,
              WeakAccount ,
              PUI ,
              FlgRestructure ,
              RestructureDate ,
              WeakAccountDate ,
              SarfaesiDate ,
              FlgUnusualBounce ,
              UnusualBounceDate ,
              FlgUnClearedEffect ,
              UnClearedEffectDate ,
              FlgFraud ,
              FraudDate ,
              ScreenFlag ,
              ChangeField 
       FROM tt_AA_22  );
   -----------------Revert Query
   DELETE PRO_RBL_MISDB_PROD.AccountCal_Hist

    WHERE  EffectiveFromTimeKey = 26114
             AND EffectiveToTimeKey = 26114;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCACCOUNT_26114TOBEDELETED" TO "ADF_CDR_RBL_STGDB";
