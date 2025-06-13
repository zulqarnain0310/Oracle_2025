--------------------------------------------------------
--  DDL for Procedure ACCELERATEDPROVISIONPROCESS_BACKDTD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" 
--USE [UATRestore_RBL_MISDB]        
 --GO        
 --/****** Object:  StoredProcedure [PRO].[AcceleratedProvisionProcess_BackDtd]    Script Date: 4/27/2022 3:07:51 PM ******/        
 --SET ANSI_NULLS ON        
 --GO        
 --SET QUOTED_IDENTIFIER ON        
 --GO        
 ----USE [RBL_MISDB]        
 ----GO        
 ----/****** Object:  StoredProcedure [PRO].[InsertDataforAssetClassficationRBL_MOC]    Script Date: 1/10/2022 1:53:07 PM ******/        
 ----SET ANSI_NULLS ON        
 ----GO        
 ----SET QUOTED_IDENTIFIER ON        
 ----GO        
 --[PRO].[AcceleratedProvisionProcess_BackDtd] 26298        

AS
   v_TIMEKEY NUMBER(10,0) := 0;
   v_ProcessDate1 VARCHAR2(200) ;
   v_ProcessingDate VARCHAR2(200);
   v_SetID NUMBER(10,0) ;

BEGIN
    DECLARE v_SQLERRM VARCHAR(200); 
    BEGIN
    
    SELECT DATE_ INTO v_ProcessDate1
     FROM RBL_MISDB_PROD.SYSDAYMATRIX 
    WHERE  TIMEKEY = v_TIMEKEY ;
   SELECT DATE_ INTO v_ProcessingDate 
     FROM RBL_MISDB_PROD.SYSDAYMATRIX 
    WHERE  TIMEKEY = v_TIMEKEY ;
   SELECT NVL(MAX(NVL(SETID, 0)) , 0) + 1 INTO v_SetID 
     FROM MAIN_PRO.ProcessMonitor 
    WHERE  TimeKey = v_TIMEKEY ;



   --Declare @ProcessDate1 DATE=(Select ProcessingDate from DBO.AcceleratedProVisionProcessinDate)        
   --SET @TIMEKEY=(Select Timekey  FROM RBL_MISDB_PROD.SYSDAYMATRIX WHERE Convert(Date,[Date])=Convert(Date,@ProcessDate1))
   SELECT Timekey 

     INTO v_Timekey
     FROM RBL_MISDB_PROD.SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_MISDB_PROD.AcceleratedProVisionProcessinDate ';
   DBMS_OUTPUT.PUT_LINE('@TIMEKEY');
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   BEGIN

      BEGIN
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.CUSTOMERCAL ';
         ----SET @TIMEKEY= (SELECT TIMEKEY FROM RBL_MISDB_PROD.SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)          
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.ACCOUNTCAL ';
         DELETE MAIN_PRO.ProcessMonitor

          WHERE  TIMEKEY = v_TIMEKEY;
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'AcceleratedProvisionDataPrepare' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         INSERT INTO RBL_MISDB_PROD.AcceleratedProVisionMonitorStatus
           ( UserID, AccProMainSP, AccProStatus, AccProDateTime, ProcessingTime, TimeKey )
           ( SELECT USER ,
                    'AcceleratedProvisionProcess_BackDtd' ,
                    'InProgress' ,
                    v_ProcessingDate ,
                    SYSDATE ,
                    v_TIMEKEY 
               FROM DUAL  );
         MAIN_PRO.AcceleratedProvisionDataPrepare(v_TimeKey => v_TIMEKEY,
                                                            v_BackDtdProcess => 'Y') ;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'AcceleratedProvisionDataPrepare'
           ;
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Insert Data Into Customer Cal Table for process date' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         INSERT INTO MAIN_PRO.CUSTOMERCAL
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
                    A.TotProvision ,
                    A.RBITotProvision ,
                    A.BankTotProvision ,
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
             FROM MAIN_PRO.CustomerCal_Hist A
                    JOIN ( SELECT UcifEntityID 
                           FROM MAIN_PRO.AcceleratedProvCalc 
                             GROUP BY UcifEntityID ) b   ON A.UcifEntityID = b.UcifEntityID
              WHERE  EffectiveFromTimeKey <= v_TIMEKEY
                       AND EffectiveToTimeKey >= v_TIMEKEY );
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'Insert Data Into Customer Cal Table for process date';
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Insert Data Into Account Cal Table for process date' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         INSERT INTO MAIN_PRO.ACCOUNTCAL
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
                    A.Provsecured ,
                    A.ProvUnsecured ,
                    A.ProvCoverGovGur ,
                    A.AddlProvision ,
                    A.TotalProvision ,
                    A.BankProvsecured ,
                    A.BankProvUnsecured ,
                    A.BankTotalProvision ,
                    A.RBIProvsecured ,
                    A.RBIProvUnsecured ,
                    A.RBITotalProvision ,
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
             FROM MAIN_PRO.AccountCal_Hist A
                    JOIN MAIN_PRO.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
              WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                       AND A.EffectiveToTimeKey >= v_TIMEKEY );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.AddlProvision, 0) - NVL(B.AcclrtdAddlprov, 0) AS AddlProvision
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AcceleratedProvCalc_hist B   ON A.AccountEntityID = B.AccountEntityId
                AND B.Timekey = v_TIMEKEY
                AND ( NVL(A.AddlProvision, 0) >= NVL(B.AcclrtdAddlprov, 0) ) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvision = src.AddlProvision;
         DELETE MAIN_PRO.AcceleratedProvCalc_hist

          WHERE  Timekey = v_TIMEKEY;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'Insert Data Into Account Cal Table for process date';
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UpdationTotalProvision' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MAIN_PRO.UpdationTotalProvision_Acclrtd(v_TimeKey => v_TIMEKEY,
                                                           v_ProcessType => 'ACLPROV') ;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UpdationTotalProvision';
         ---------Added by Prashant----17112023------------------------
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET TotalProvision = 0
          WHERE  ( NVL(NetBalance, 0) <= 0
           OR NVL(TotalProvision, 0) <= 0 );
         ------------------------------------------------------------------------
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'InsertDataINTOHIST_TABLE_OPT_BACKDTD' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MAIN_PRO.InsertDataINTOHIST_TABLE_OPT_BACKDTD(v_TIMEKEY => v_TIMEKEY) ;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'InsertDataINTOHIST_TABLE_OPT_BACKDTD';
         UPDATE RBL_MISDB_PROD.AcceleratedProVisionMonitorStatus
            SET AccProStatus = 'Completed'
          WHERE  TIMEKEY = v_TIMEKEY;

      END;
   EXCEPTION
      WHEN OTHERS THEN
    
   DECLARE v_SQLERRM VARCHAR(1000):=SQLERRM;
   BEGIN
   
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONPROCESS_BACKDTD" TO "ADF_CDR_RBL_STGDB";
