--------------------------------------------------------
--  DDL for Procedure INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" 
--USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [PRO].[InsertDataforAssetClassficationRBL_MOC]    Script Date: 1/10/2022 1:53:07 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 --[PRO].[InsertDataforAssetClassficationRBL_MOC] 26298

(
  v_TIMEKEY IN NUMBER
)
AS
   ---declare @timekey int=26298
   v_ProcessingDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM SYSDAYMATRIX 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_SetID NUMBER(10,0) := ( SELECT NVL(MAX(NVL(SETID, 0)) , 0) + 1 
     FROM PRO_RBL_MISDB_PROD.ProcessMonitor 
    WHERE  TimeKey = v_TIMEKEY );

BEGIN

   BEGIN

      BEGIN
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.CUSTOMERCAL ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.ACCOUNTCAL ';
         -------------------- /* Added By Mandeep 11-09-2023  Query Optimization */  ------------------------------------------
         DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_ACCOUNTCAL_34  --SQLDEV: NOT RECOGNIZED
         tt_ACCOUNTCAL_34 TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_CUSTOMERCAL_31  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_ACCOUNTCAL_34;
         UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_34');

         INSERT INTO tt_ACCOUNTCAL_34 ( 
         	SELECT * 
         	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
         	 WHERE  1 = 2 );
         DELETE FROM tt_CUSTOMERCAL_31;
         UTILS.IDENTITY_RESET('tt_CUSTOMERCAL_31');

         INSERT INTO tt_CUSTOMERCAL_31 ( 
         	SELECT * 
         	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL 
         	 WHERE  1 = 2 );
         DELETE PRO_RBL_MISDB_PROD.ProcessMonitor

          WHERE  TIMEKEY = v_TIMEKEY;
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET COMPLETED = 'N',
                COUNT = 0,
                ERRORDESCRIPTION = NULL,
                ERRORDATE = NULL;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.CUSTOMERCAL ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.ACCOUNTCAL ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.AdvAcRestructureCal ';
         ----SET @TIMEKEY= (SELECT TIMEKEY FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)		
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.PUI_CAL ';
         DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_BACKDTD_DATA  --SQLDEV: NOT RECOGNIZED
         tt_BACKDTD_DATA TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_BACKDTD_DATA  --SQLDEV: NOT RECOGNIZED
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Prepare TWO Marking data' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         DELETE FROM tt_BACKDTD_DATA;
         UTILS.IDENTITY_RESET('tt_BACKDTD_DATA');

         INSERT INTO tt_BACKDTD_DATA ( 
         	SELECT UcifEntityID ,
                 a.CustomerID ,
                 a.ACID ,
                 StatusDate ,
                 A.Amount ,
                 StatusType 
         	  FROM ExceptionFinalStatusType A
                   JOIN CustomerBasicDetail cbd   ON CBD.EffectivefromTimeKey <= v_TimeKey
                   AND CBD.EffectiveToTimeKey >= v_TIMEKEY
                   AND cbd.CustomerID = A.CustomerID
         	 WHERE  A.StatusDate <= v_ProcessingDate
                    AND A.EffectiveFromTimeKey >= v_TIMEKEY
                    AND A.EffectiveToTimeKey >= v_TIMEKEY
                    AND A.EffectiveToTimeKey >= A.EffectiveFromTimeKey
                    AND A.StatusType IN ( 'TWO','WO' )

                    AND NVL(A.AuthorisationStatus, 'A') = 'A' );
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'Prepare TWO Marking data';
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Insert Data Into Hist Table for process date' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         INSERT INTO tt_CUSTOMERCAL_31
           ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, RBITotProvision, BankTotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason
         --,DateOfData
         , CustMoveDescription, TotOsCust, MOCTYPE )
           ( SELECT A.BranchCode ,
                    A.UCIF_ID ,
                    A.UcifEntityID ,
                    A.CustomerEntityID ,
                    A.ParentCustomerID ,
                    A.RefCustomerID ,
                    A.SourceSystemCustomerID ,
                    A.CustomerName ,
                    A.CustSegmentCode ,
                    A.ConstitutionAlt_Key ,
                    A.PANNO ,
                    A.AadharCardNO ,
                    A.SrcAssetClassAlt_Key ,
                    A.SysAssetClassAlt_Key ,
                    A.SplCatg1Alt_Key ,
                    A.SplCatg2Alt_Key ,
                    A.SplCatg3Alt_Key ,
                    A.SplCatg4Alt_Key ,
                    A.SMA_Class_Key ,
                    A.PNPA_Class_Key ,
                    A.PrvQtrRV ,
                    A.CurntQtrRv ,
                    0 TotProvision  ,
                    0 RBITotProvision  ,
                    0 BankTotProvision  ,
                    A.SrcNPA_Dt ,
                    A.SysNPA_Dt ,
                    A.DbtDt ,
                    A.DbtDt2 ,
                    A.DbtDt3 ,
                    A.LossDt ,
                    A.MOC_Dt ,
                    A.ErosionDt ,
                    A.SMA_Dt ,
                    A.PNPA_Dt ,
                    A.Asset_Norm ,
                    A.FlgDeg ,
                    A.FlgUpg ,
                    'Y' FlgMoc  ,
                    A.FlgSMA ,
                    A.FlgProcessing ,
                    A.FlgErosion ,
                    A.FlgPNPA ,
                    A.FlgPercolation ,
                    A.FlgInMonth ,
                    A.FlgDirtyRow ,
                    A.DegDate ,
                    v_TIMEKEY EffectiveFromTimeKey  ,
                    v_TIMEKEY EffectiveToTimeKey  ,
                    A.CommonMocTypeAlt_Key ,
                    A.InMonthMark ,
                    A.MocStatusMark ,
                    A.SourceAlt_Key ,
                    A.BankAssetClass ,
                    A.Cust_Expo ,
                    A.MOCReason ,
                    A.AddlProvisionPer ,
                    A.FraudDt ,
                    A.FraudAmount ,
                    A.DegReason ,
                    --,A.DateOfData
                    A.CustMoveDescription ,
                    A.TotOsCust ,
                    A.MOCTYPE 
             FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                    JOIN ( SELECT UcifEntityID 
                           FROM tt_BACKDTD_DATA 
                             GROUP BY UcifEntityID ) B   ON A.UcifEntityID = B.UcifEntityID
              WHERE  EffectiveFromTimeKey <= v_TIMEKEY
                       AND EffectiveToTimeKey >= v_TIMEKEY );
         INSERT INTO tt_ACCOUNTCAL_34
           ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt
         --,DPD_IntService
          --,DPD_NoCredit
          --,DPD_Overdrawn
          --,DPD_Overdue
          --,DPD_Renewal
          --,DPD_StockStmt
          --,DPD_Max
          --,DPD_FinMaxType
         , DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key
         --,DPD_SMA
         , FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt
         --,DPD_PrincOverdue
         , IntOverdue, IntOverdueSinceDt
         --,DPD_IntOverdueSince
         , OtherOverdue, OtherOverdueSinceDt
         --,DPD_OtherOverdueSince
         , RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate
         --,DateOfData
         , DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, AdvanceRecovery, NotionalInttAmt, OriginalBranchcode, PrvAssetClassAlt_Key, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate )
           ( SELECT A.AccountEntityID ,
                    A.UcifEntityID ,
                    A.CustomerEntityID ,
                    A.CustomerAcID ,
                    A.RefCustomerID ,
                    A.SourceSystemCustomerID ,
                    A.UCIF_ID ,
                    A.BranchCode ,
                    A.FacilityType ,
                    A.AcOpenDt ,
                    A.FirstDtOfDisb ,
                    A.ProductAlt_Key ,
                    A.SchemeAlt_key ,
                    A.SubSectorAlt_Key ,
                    A.SplCatg1Alt_Key ,
                    A.SplCatg2Alt_Key ,
                    A.SplCatg3Alt_Key ,
                    A.SplCatg4Alt_Key ,
                    A.SourceAlt_Key ,
                    A.ActSegmentCode ,
                    A.InttRate ,
                    A.Balance ,
                    A.BalanceInCrncy ,
                    A.CurrencyAlt_Key ,
                    A.DrawingPower ,
                    A.CurrentLimit ,
                    A.CurrentLimitDt ,
                    A.ContiExcessDt ,
                    A.StockStDt ,
                    A.DebitSinceDt ,
                    A.LastCrDate ,
                    A.PreQtrCredit ,
                    A.PrvQtrInt ,
                    A.CurQtrCredit ,
                    A.CurQtrInt ,
                    A.InttServiced ,
                    A.IntNotServicedDt ,
                    A.OverdueAmt ,
                    A.OverDueSinceDt ,
                    A.ReviewDueDt ,
                    A.SecurityValue ,
                    A.DFVAmt ,
                    A.GovtGtyAmt ,
                    A.CoverGovGur ,
                    A.WriteOffAmount ,
                    A.UnAdjSubSidy ,
                    A.CreditsinceDt ,
                    --,A.DPD_IntService
                    --,A.DPD_NoCredit
                    --,A.DPD_Overdrawn
                    --,A.DPD_Overdue
                    --,A.DPD_Renewal
                    --,A.DPD_StockStmt
                    --,A.DPD_Max
                    --,A.DPD_FinMaxType
                    A.DegReason ,
                    A.Asset_Norm ,
                    A.REFPeriodMax ,
                    A.RefPeriodOverdue ,
                    A.RefPeriodOverDrawn ,
                    A.RefPeriodNoCredit ,
                    A.RefPeriodIntService ,
                    A.RefPeriodStkStatement ,
                    A.RefPeriodReview ,
                    A.NetBalance ,
                    A.ApprRV ,
                    A.SecuredAmt ,
                    A.UnSecuredAmt ,
                    A.ProvDFV ,
                    0 Provsecured  ,
                    0 ProvUnsecured  ,
                    0 ProvCoverGovGur  ,
                    AddlProvision ,
                    0 TotalProvision  ,
                    0 BankProvsecured  ,
                    0 BankProvUnsecured  ,
                    0 BankTotalProvision  ,
                    0 RBIProvsecured  ,
                    0 RBIProvUnsecured  ,
                    0 RBITotalProvision  ,
                    A.InitialNpaDt ,
                    A.FinalNpaDt ,
                    A.SMA_Dt ,
                    A.UpgDate ,
                    A.InitialAssetClassAlt_Key ,
                    A.FinalAssetClassAlt_Key ,
                    A.ProvisionAlt_Key ,
                    A.PNPA_Reason ,
                    A.SMA_Class ,
                    A.SMA_Reason ,
                    A.FlgMoc ,
                    A.MOC_Dt ,
                    A.CommonMocTypeAlt_Key ,
                    --,A.DPD_SMA
                    A.FlgDeg ,
                    A.FlgDirtyRow ,
                    A.FlgInMonth ,
                    A.FlgSMA ,
                    A.FlgPNPA ,
                    A.FlgUpg ,
                    A.FlgFITL ,
                    A.FlgAbinitio ,
                    A.NPA_Days ,
                    A.RefPeriodOverdueUPG ,
                    A.RefPeriodOverDrawnUPG ,
                    A.RefPeriodNoCreditUPG ,
                    A.RefPeriodIntServiceUPG ,
                    A.RefPeriodStkStatementUPG ,
                    A.RefPeriodReviewUPG ,
                    v_TIMEKEY EffectiveFromTimeKey  ,
                    v_TIMEKEY EffectiveToTimeKey  ,
                    A.AppGovGur ,
                    A.UsedRV ,
                    A.ComputedClaim ,
                    A.UPG_RELAX_MSME ,
                    A.DEG_RELAX_MSME ,
                    A.PNPA_DATE ,
                    A.NPA_Reason ,
                    A.PnpaAssetClassAlt_key ,
                    A.DisbAmount ,
                    A.PrincOutStd ,
                    A.PrincOverdue ,
                    A.PrincOverdueSinceDt ,
                    --,A.DPD_PrincOverdue
                    A.IntOverdue ,
                    A.IntOverdueSinceDt ,
                    --,A.DPD_IntOverdueSince
                    A.OtherOverdue ,
                    A.OtherOverdueSinceDt ,
                    --,A.DPD_OtherOverdueSince
                    A.RelationshipNumber ,
                    A.AccountFlag ,
                    A.CommercialFlag_AltKey ,
                    A.Liability ,
                    A.CD ,
                    A.AccountStatus ,
                    A.AccountBlkCode1 ,
                    A.AccountBlkCode2 ,
                    A.ExposureType ,
                    A.Mtm_Value ,
                    A.BankAssetClass ,
                    A.NpaType ,
                    A.SecApp ,
                    A.BorrowerTypeID ,
                    A.LineCode ,
                    A.ProvPerSecured ,
                    A.ProvPerUnSecured ,
                    A.MOCReason ,
                    A.AddlProvisionPer ,
                    A.FlgINFRA ,
                    A.RepossessionDate ,
                    --,A.DateOfData
                    A.DerecognisedInterest1 ,
                    A.DerecognisedInterest2 ,
                    A.ProductCode ,
                    A.FlgLCBG ,
                    A.unserviedint ,
                    A.AdvanceRecovery ,
                    A.NotionalInttAmt ,
                    A.OriginalBranchcode ,
                    A.PrvAssetClassAlt_Key ,
                    A.FlgSecured ,
                    A.RePossession ,
                    A.RCPending ,
                    A.PaymentPending ,
                    A.WheelCase ,
                    A.CustomerLevelMaxPer ,
                    A.FinalProvisionPer ,
                    A.IsIBPC ,
                    A.IsSecuritised ,
                    A.RFA ,
                    A.IsNonCooperative ,
                    A.Sarfaesi ,
                    A.WeakAccount ,
                    A.PUI ,
                    A.FlgRestructure ,
                    A.RestructureDate ,
                    A.WeakAccountDate ,
                    A.SarfaesiDate ,
                    A.FlgUnusualBounce ,
                    A.UnusualBounceDate ,
                    A.FlgUnClearedEffect ,
                    A.UnClearedEffectDate ,
                    A.FlgFraud ,
                    A.FraudDate 
             FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                    JOIN tt_CUSTOMERCAL_31 B   ON A.CustomerEntityID = B.CustomerEntityID
              WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                       AND A.EffectiveToTimeKey >= v_TIMEKEY );
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'Insert Data Into Hist Table for process date';
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking always NPA account table level where WriteOffAmount>0' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_ProcessingDate
            END AS pos_4, 'NPA DUE TO WRITEOFF MARKING' AS pos_5, b.Amount
         FROM ACL ,tt_ACCOUNTCAL_34 ACL
                JOIN tt_BACKDTD_DATA b   ON ACL.CustomerAcID = b.ACID 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND FinalAssetClassAlt_Key = 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.FinalAssetClassAlt_Key = 2,
                                      ACL.FinalNpaDt = pos_4,
                                      ACL.NPA_Reason = pos_5,
                                      ACL.WriteOffAmount = src.Amount;
         MERGE INTO ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO WRITEOFF MARKING' AS pos_3, b.Amount
         FROM ACL ,tt_ACCOUNTCAL_34 ACL
                JOIN tt_BACKDTD_DATA b   ON ACL.CustomerAcID = b.ACID 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND FinalAssetClassAlt_Key > 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.NPA_Reason = pos_3,
                                      ACL.WriteOffAmount = src.Amount;
         /* CUSTOMER WRITEOFF UPDATE */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO WRITEOFF MARKING' AS pos_3, 2, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_ProcessingDate
            END AS pos_5
         FROM A ,tt_CUSTOMERCAL_31 A
                JOIN tt_BACKDTD_DATA b   ON A.RefCustomerID = B.CustomerID 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET Asset_Norm = 'ALWYS_NPA',
                                      DegReason = pos_3,
                                      A.SysAssetClassAlt_Key = 2,
                                      A.SysNPA_Dt = pos_5;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO WRITEOFF MARKING' AS pos_3
         FROM A ,tt_CUSTOMERCAL_31 A
                JOIN tt_BACKDTD_DATA b   ON A.RefCustomerID = B.CustomerID 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND SysAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET Asset_Norm = 'ALWYS_NPA',
                                      DegReason
                                      --,A.SysNPA_Dt=CASE WHEN StatusDate IS NOT  NULL THEN StatusDate ELSE @ProcessingDate END
                                       = pos_3;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking always NPA account table level where WriteOffAmount>0';
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_BACKDTD" TO "ADF_CDR_RBL_STGDB";
