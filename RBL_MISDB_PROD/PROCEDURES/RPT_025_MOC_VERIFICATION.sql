--------------------------------------------------------
--  DDL for Procedure RPT_025_MOC_VERIFICATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" 
(
  v_TimeKey IN NUMBER
)
AS
   --DECLARE  @TimeKey AS INT=26267
   v_Mocdate VARCHAR2(200);
   --select * from tt_Final_29 order by CustomerAcID,CustomerID,Moc_Status DESC
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) 

     INTO v_Mocdate
     FROM SysDayMatrix 
    WHERE  Timekey = v_TimeKey;
   --select @Mocdate
   IF ( utils.object_id('TEMPDB..tt_AccountCal_Hist_32') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_Hist_32 ';
   END IF;
   DELETE FROM tt_AccountCal_Hist_32;
   UTILS.IDENTITY_RESET('tt_AccountCal_Hist_32');

   INSERT INTO tt_AccountCal_Hist_32 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID
      ON tt_AccountCal_Hist_32 ( CustomerACID)';
   -------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_CustomerCal_HIST_20') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_HIST_20 ';
   END IF;
   DELETE FROM tt_CustomerCal_HIST_20;
   UTILS.IDENTITY_RESET('tt_CustomerCal_HIST_20');

   INSERT INTO tt_CustomerCal_HIST_20 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID
      ON tt_CustomerCal_HIST_20 ( CustomerEntityID)';
   ---------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_AccountLevelMOC_Mod_20') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountLevelMOC_Mod_20 ';
   END IF;
   DELETE FROM tt_AccountLevelMOC_Mod_20;
   UTILS.IDENTITY_RESET('tt_AccountLevelMOC_Mod_20');

   INSERT INTO tt_AccountLevelMOC_Mod_20 ( 
   	SELECT * 
   	  FROM AccountLevelMOC_Mod 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND ChangeField IS NOT NULL );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_AccountID
      ON tt_AccountLevelMOC_Mod_20 ( AccountID)';
   ---------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_CustomerLevelMOC_Mod_19') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerLevelMOC_Mod_19 ';
   END IF;
   DELETE FROM tt_CustomerLevelMOC_Mod_19;
   UTILS.IDENTITY_RESET('tt_CustomerLevelMOC_Mod_19');

   INSERT INTO tt_CustomerLevelMOC_Mod_19 ( 
   	SELECT * 
   	  FROM CustomerLevelMOC_Mod 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND ChangeField IS NOT NULL );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID2
      ON tt_CustomerLevelMOC_Mod_19 ( CustomerEntityID)';
   -------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_AccountCal_49') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_49 ';
   END IF;
   DELETE FROM tt_AccountCal_49;
   UTILS.IDENTITY_RESET('tt_AccountCal_49');

   INSERT INTO tt_AccountCal_49 ( 
   	SELECT * 
   	  FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID1
      ON tt_AccountCal_49 ( CustomerACID)';
   --------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_CustomerCal_38') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_38 ';
   END IF;
   DELETE FROM tt_CustomerCal_38;
   UTILS.IDENTITY_RESET('tt_CustomerCal_38');

   INSERT INTO tt_CustomerCal_38 ( 
   	SELECT * 
   	  FROM PreMoc_RBL_MISDB_PROD.CUSTOMERCAL 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID1
      ON tt_CustomerCal_38 ( CustomerEntityID)';
   ------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_DimAcBuSegment_21') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimAcBuSegment_21 ';
   END IF;
   DELETE FROM tt_DimAcBuSegment_21;
   UTILS.IDENTITY_RESET('tt_DimAcBuSegment_21');

   INSERT INTO tt_DimAcBuSegment_21 SELECT DENSE_RANK() OVER ( PARTITION BY AcBuRevisedSegmentCode ORDER BY AcBuSegmentCode  ) RN  ,
                                           AcBuSegmentCode ,
                                           AcBuRevisedSegmentCode ,
                                           AcBuSegmentDescription 
        FROM DimAcBuSegment 
       WHERE  EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
   ---------------------PreMOC_DATA----------------------
   IF utils.object_id('Tempdb..tt_Final_29') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_29 ';
   END IF;
   DELETE FROM tt_Final_29;
   UTILS.IDENTITY_RESET('tt_Final_29');

   INSERT INTO tt_Final_29 SELECT 'Post Moc' Moc_Status  ,
                                  UTILS.CONVERT_TO_VARCHAR2(G.DATE_,20,p_style=>103) CurrentProcessingDate  ,
                                  ROW_NUMBER() OVER ( ORDER BY A.UcifEntityId  ) SrNo  ,
                                  ---------RefColumns---------
                                  H.SourceName ,
                                  A.CustomerAcID ,
                                  A.RefCustomerID CustomerID  ,
                                  F.CustomerName ,
                                  A.UCIF_ID ,
                                  A.FacilityType ,
                                  NVL(F.PANNo, ' ') PANNo  ,
                                  F.AadharCardNo ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.InitialNpaDt,20,p_style=>103) InitialNpaDt  ,
                                  A.InitialAssetClassAlt_Key ,
                                  D.AssetClassName InitalAssetClassName  ,
                                  ----Edit--------
                                  UTILS.CONVERT_TO_VARCHAR2(A.FirstDtOfDisb,20,p_style=>103) FirstDtOfDisb  ,
                                  A.ProductAlt_Key ,
                                  C.ProductName ,
                                  NVL(A.Balance, 0) Balance  ,
                                  NVL(A.PrincOutStd, 0) PrincOutStd  ,
                                  NVL(A.PrincOverdue, 0) PrincOverdue  ,
                                  NVL(A.IntOverdue, 0) IntOverdue  ,
                                  NVL(A.DrawingPower, 0) DrawingPower  ,
                                  NVL(A.CurrentLimit, 0) CurrentLimit  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.StockStDt,20,p_style=>103) StockStDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.LastCrDate,20,p_style=>103) LastCrDate  ,
                                  NVL(A.CurQtrCredit, 0) CurQtrCredit  ,
                                  NVL(A.CurQtrInt, 0) CurQtrInt  ,
                                  A.InttServiced ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.IntNotServicedDt,20,p_style=>103) IntNotServicedDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
                                  NVL(F.CurntQtrRv, 0) SecurityValue  ,
                                  NVL(A.DFVAmt, 0) DFVAmt  ,
                                  NVL(A.GovtGtyAmt, 0) GovtGtyAmt  ,
                                  NVL(A.WriteOffAmount, 0) WriteOffAmount  ,
                                  NVL(A.UnAdjSubSidy, 0) UnAdjSubSidy  ,
                                  A.Asset_Norm ,
                                  NVL(A.AddlProvision, 0) AddlProvision  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.PrincOverDueSinceDt,20,p_style=>103) PrincOverDueSinceDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.IntOverDueSinceDt,20,p_style=>103) IntOverDueSinceDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.OtherOverDueSinceDt,20,p_style=>103) OtherOverDueSinceDt  ,
                                  NVL(A.UnserviedInt, 0) UnserviedInt  ,
                                  NVL(A.AdvanceRecovery, 0) AdvanceRecovery  ,
                                  A.RePossession ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.RepossessionDate,20,p_style=>103) RepossessionDate  ,
                                  A.RCPending ,
                                  A.PaymentPending ,
                                  A.WheelCase ,
                                  A.RFA ,
                                  A.IsNonCooperative ,
                                  A.Sarfaesi ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.SarfaesiDate,20,p_style=>103) SarfaesiDate  ,
                                  A.WeakAccount InherentWeakness  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.WeakAccountDate,20,p_style=>103) InherentWeaknessDate  ,
                                  A.FlgFITL ,
                                  A.FlgRestructure ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.RestructureDate,20,p_style=>103) RestructureDate  ,
                                  A.FlgUnusualBounce ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.UnusualBounceDate,20,p_style=>103) UnusualBounceDate  ,
                                  A.FlgUnClearedEffect ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.UnClearedEffectDate,20,p_style=>103) UnClearedEffectDate  ,
                                  -------OutPut-----
                                  NVL(A.CoverGovGur, 0) CoverGovGur  ,
                                  A.DegReason ,
                                  NVL(A.NetBalance, 0) NetBalance  ,
                                  NVL(A.ApprRV, 0) ApprRV  ,
                                  NVL(A.SecuredAmt, 0) SecuredAmt  ,
                                  NVL(A.UnSecuredAmt, 0) UnSecuredAmt  ,
                                  NVL(A.ProvDFV, 0) ProvDFV  ,
                                  NVL(A.Provsecured, 0) Provsecured  ,
                                  NVL(A.ProvUnsecured, 0) ProvUnsecured  ,
                                  NVL(A.ProvCoverGovGur, 0) ProvCoverGovGur  ,
                                  NVL(A.TotalProvision, 0) TotalProvision  ,
                                  NVL(A.BankTotalProvision, 0) BankTotalProvision  ,
                                  NVL(A.RBITotalProvision, 0) RBITotalProvision  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(F.DbtDt,20,p_style=>103) DoubtfulDt  ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.UpgDate,20,p_style=>103) UpgDate  ,
                                  A.FinalAssetClassAlt_Key ,
                                  E.AssetClassName FinalAssetClassName  ,
                                  A.NPA_Reason ,
                                  A.FlgDeg ,
                                  A.FlgUpg ,
                                  A.FinalProvisiONPer ,
                                  A.FlgSMA ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.SMA_Dt,20,p_style=>103) SMA_Dt  ,
                                  A.SMA_Class ,
                                  A.SMA_Reason ,
                                  A.FlgPNPA ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.PNPA_DATE,20,p_style=>103) PNPA_DATE  ,
                                  A.PNPA_Reason ,
                                  F.CustMoveDescription CustSMAStatus  ,
                                  --,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt
                                  v_Mocdate MOC_Dt  ,
                                  A.FlgFraud ,
                                  UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,20,p_style=>103) FraudDate  ,
                                  COALESCE(ALM.CreatedBy, CLM.CreatedBy, MOC.Createdby) MakerID  ,
                                  NVL(ALM.DateCreated, CLM.DateCreated) MakerDate  ,
                                  NVL(ALM.ApprovedByFirstLevel, CLM.ApprovedByFirstLevel) CheckerID  ,
                                  NVL(ALM.DateApprovedFirstLevel, CLM.DateApprovedFirstLevel) CheckerDate  ,
                                  NVL(ALM.ApprovedBy, CLM.ApprovedBy) ReviewerID  ,
                                  NVL(ALM.DateApproved, CLM.DateApproved) ReviewerDate  ,
                                  NVL(A.MOCReason, F.MOCReason) MOCReason  ,
                                  DABS.AcBuRevisedSegmentCode AcBuSegmentCode  ,
                                  DABS.AcBuSegmentDescription 
        FROM tt_AccountCal_Hist_32 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_AccountLevelMOC_Mod_20 ALM   ON ALM.AccountId = A.CustomerAcID
               LEFT JOIN tt_CustomerCal_HIST_20 F   ON F.CustomerEntityId = A.CustomerEntityId
               LEFT JOIN tt_CustomerLevelMOC_Mod_19 CLM   ON F.CustomerEntityId = CLM.CustomerEntityId
               LEFT JOIN MOC_ChangeDetails MOC   ON MOC.CustomerEntityId = CLM.CustomerEntityId
               AND MOC.EffectiveFromTimeKey <= v_TimeKey
               AND MOC.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass D   ON D.AssetClassAlt_Key = A.InitialAssetClassAlt_Key
               AND D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
               AND E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey
               JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey
               JOIN DIMSOURCEDB H   ON H.SourceAlt_Key = A.SourceAlt_Key
               AND H.EffectiveFromTimeKey <= v_TimeKey
               AND H.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_DimAcBuSegment_21 DABS   ON A.ActSegmentCode = DABS.AcBuRevisedSegmentCode
               AND DABS.RN = 1
       WHERE  ( A.FlgMoc = 'Y'
                OR F.FlgMoc = 'Y' )
      UNION ALL 
      SELECT 'Pre Moc' Moc_Status  ,
             UTILS.CONVERT_TO_VARCHAR2(G.DATE_,20,p_style=>103) CurrentProcessingDate  ,
             ROW_NUMBER() OVER ( ORDER BY A.UcifEntityId  ) SrNo  ,
             ---------RefColumns---------
             H.SourceName ,
             A.CustomerAcID ,
             A.RefCustomerID CustomerID  ,
             F.CustomerName ,
             A.UCIF_ID ,
             A.FacilityType ,
             NVL(F.PANNo, ' ') PANNo  ,
             F.AadharCardNo ,
             UTILS.CONVERT_TO_VARCHAR2(A.InitialNpaDt,20,p_style=>103) InitialNpaDt  ,
             A.InitialAssetClassAlt_Key ,
             D.AssetClassName InitalAssetClassName  ,
             ----Edit--------
             UTILS.CONVERT_TO_VARCHAR2(A.FirstDtOfDisb,20,p_style=>103) FirstDtOfDisb  ,
             A.ProductAlt_Key ,
             C.ProductName ,
             NVL(A.Balance, 0) Balance  ,
             NVL(A.PrincOutStd, 0) PrincOutStd  ,
             NVL(A.PrincOverdue, 0) PrincOverdue  ,
             NVL(A.IntOverdue, 0) IntOverdue  ,
             NVL(A.DrawingPower, 0) DrawingPower  ,
             NVL(A.CurrentLimit, 0) CurrentLimit  ,
             UTILS.CONVERT_TO_VARCHAR2(A.ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.StockStDt,20,p_style=>103) StockStDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.LastCrDate,20,p_style=>103) LastCrDate  ,
             NVL(A.CurQtrCredit, 0) CurQtrCredit  ,
             NVL(A.CurQtrInt, 0) CurQtrInt  ,
             A.InttServiced ,
             UTILS.CONVERT_TO_VARCHAR2(A.IntNotServicedDt,20,p_style=>103) IntNotServicedDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
             NVL(F.CurntQtrRv, 0) SecurityValue  ,
             NVL(A.DFVAmt, 0) DFVAmt  ,
             NVL(A.GovtGtyAmt, 0) GovtGtyAmt  ,
             NVL(A.WriteOffAmount, 0) WriteOffAmount  ,
             NVL(A.UnAdjSubSidy, 0) UnAdjSubSidy  ,
             A.Asset_Norm ,
             NVL(A.AddlProvision, 0) AddlProvision  ,
             UTILS.CONVERT_TO_VARCHAR2(A.PrincOverDueSinceDt,20,p_style=>103) PrincOverDueSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.IntOverDueSinceDt,20,p_style=>103) IntOverDueSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.OtherOverDueSinceDt,20,p_style=>103) OtherOverDueSinceDt  ,
             NVL(A.UnserviedInt, 0) UnserviedInt  ,
             NVL(A.AdvanceRecovery, 0) AdvanceRecovery  ,
             A.RePossession ,
             UTILS.CONVERT_TO_VARCHAR2(A.RepossessionDate,20,p_style=>103) RepossessionDate  ,
             A.RCPending ,
             A.PaymentPending ,
             A.WheelCase ,
             A.RFA ,
             A.IsNonCooperative ,
             A.Sarfaesi ,
             UTILS.CONVERT_TO_VARCHAR2(A.SarfaesiDate,20,p_style=>103) SarfaesiDate  ,
             A.WeakAccount InherentWeakness  ,
             UTILS.CONVERT_TO_VARCHAR2(A.WeakAccountDate,20,p_style=>103) InherentWeaknessDate  ,
             A.FlgFITL ,
             A.FlgRestructure ,
             UTILS.CONVERT_TO_VARCHAR2(A.RestructureDate,20,p_style=>103) RestructureDate  ,
             A.FlgUnusualBounce ,
             UTILS.CONVERT_TO_VARCHAR2(A.UnusualBounceDate,20,p_style=>103) UnusualBounceDate  ,
             A.FlgUnClearedEffect ,
             UTILS.CONVERT_TO_VARCHAR2(A.UnClearedEffectDate,20,p_style=>103) UnClearedEffectDate  ,
             -------OutPut-----
             NVL(A.CoverGovGur, 0) CoverGovGur  ,
             A.DegReason ,
             NVL(A.NetBalance, 0) NetBalance  ,
             NVL(A.ApprRV, 0) ApprRV  ,
             NVL(A.SecuredAmt, 0) SecuredAmt  ,
             NVL(A.UnSecuredAmt, 0) UnSecuredAmt  ,
             NVL(A.ProvDFV, 0) ProvDFV  ,
             NVL(A.Provsecured, 0) Provsecured  ,
             NVL(A.ProvUnsecured, 0) ProvUnsecured  ,
             NVL(A.ProvCoverGovGur, 0) ProvCoverGovGur  ,
             NVL(A.TotalProvision, 0) TotalProvision  ,
             NVL(A.BankTotalProvision, 0) BankTotalProvision  ,
             NVL(A.RBITotalProvision, 0) RBITotalProvision  ,
             UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             UTILS.CONVERT_TO_VARCHAR2(F.DbtDt,20,p_style=>103) DoubtfulDt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.UpgDate,20,p_style=>103) UpgDate  ,
             A.FinalAssetClassAlt_Key ,
             E.AssetClassName FinalAssetClassName  ,
             A.NPA_Reason ,
             A.FlgDeg ,
             A.FlgUpg ,
             A.FinalProvisiONPer ,
             A.FlgSMA ,
             UTILS.CONVERT_TO_VARCHAR2(A.SMA_Dt,20,p_style=>103) SMA_Dt  ,
             A.SMA_Class ,
             A.SMA_Reason ,
             A.FlgPNPA ,
             UTILS.CONVERT_TO_VARCHAR2(A.PNPA_DATE,20,p_style=>103) PNPA_DATE  ,
             A.PNPA_Reason ,
             F.CustMoveDescription CustSMAStatus  ,
             --,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt
             v_Mocdate MOC_Dt  ,
             A.FlgFraud ,
             UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,20,p_style=>103) FraudDate  ,
             COALESCE(ALM.CreatedBy, CLM.CreatedBy, MOC.createdBy) MakerID  ,
             NVL(ALM.DateCreated, CLM.DateCreated) MakerDate  ,
             NVL(ALM.ApprovedByFirstLevel, CLM.ApprovedByFirstLevel) CheckerID  ,
             NVL(ALM.DateApprovedFirstLevel, CLM.DateApprovedFirstLevel) CheckerDate  ,
             NVL(ALM.ApprovedBy, CLM.ApprovedBy) ReviewerID  ,
             NVL(ALM.DateApproved, CLM.DateApproved) ReviewerDate  ,
             NVL(A.MOCReason, F.MOCReason) MOCReason  ,
             DABS.AcBuRevisedSegmentCode AcBuSegmentCode  ,
             DABS.AcBuSegmentDescription 
        FROM tt_AccountCal_49 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_AccountLevelMOC_Mod_20 ALM   ON ALM.AccountId = A.CustomerAcID
               LEFT JOIN tt_CustomerCal_38 F   ON F.CustomerEntityId = A.CustomerEntityId
               LEFT JOIN tt_CustomerLevelMOC_Mod_19 CLM   ON F.CustomerEntityId = CLM.CustomerEntityId
               LEFT JOIN MOC_ChangeDetails MOC   ON MOC.CustomerEntityId = CLM.CustomerEntityId
               AND MOC.EffectiveFromTimeKey <= v_TimeKey
               AND MOC.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass D   ON D.AssetClassAlt_Key = A.InitialAssetClassAlt_Key
               AND D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey
               JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
               AND E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey
               JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey
               JOIN DIMSOURCEDB H   ON H.SourceAlt_Key = A.SourceAlt_Key
               AND H.EffectiveFromTimeKey <= v_TimeKey
               AND H.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_DimAcBuSegment_21 DABS   ON A.ActSegmentCode = DABS.AcBuRevisedSegmentCode
               AND DABS.RN = 1
       WHERE  A.CustomerAcID IN ( SELECT CustomerAcID 
                                  FROM tt_AccountCal_Hist_32 A
                                         LEFT JOIN tt_CustomerCal_HIST_20 C   ON C.CustomerEntityId = A.CustomerEntityId
                                   WHERE  ( A.FlgMoc = 'Y'
                                            OR C.FlgMoc = 'Y' ) )

        ORDER BY CustomerAcID,
                 CustomerID,
                 Moc_Status DESC;
   UPDATE tt_Final_29
      SET MakerID = 'System',
          CheckerID = 'System',
          ReviewerID = 'System'
    WHERE  MakerID IS NULL
     OR CheckerID IS NULL
     OR ReviewerID IS NULL;
   OPEN  v_cursor FOR
      SELECT ROW_NUMBER() OVER ( PARTITION BY CurrentProcessingDate ORDER BY CustomerID  ) Sr_No_  ,
             Moc_Status MOC_Status  ,
             CurrentProcessingDate Processing_Date  ,
             UCIF_ID UCIC  ,
             CustomerID Customer_ID  ,
             CustomerName Customer_Name  ,
             CustomerAcID Account_ID  ,
             FacilityType Facility_Type  ,
             PANNo PAN  ,
             InitialNpaDt Initial_NPA_Date  ,
             InitalAssetClassName Asset_Class  ,
             PrincOutStd POS_in_Rs_  ,
             SecurityValue Security_Value  ,
             DFVAmt DFV_Amount  ,
             WriteOffAmount Write_Off_Amt_in_Rs_  ,
             AddlProvision Additional_Provision  ,
             UnserviedInt UnServiced_Interest_in_Rs  ,
             RCPending RC_Pending  ,
             PaymentPending Payment_Pending  ,
             WheelCase WheelCase  ,
             RFA RFA  ,
             IsNonCooperative IsNonCooperative  ,
             FlgFraud Fraud  ,
             FraudDate Fraud_Date  ,
             FlgFITL FITL  ,
             FlgRestructure Restructure  ,
             RestructureDate Restructure_Date  ,
             NetBalance Net_Balance  ,
             ApprRV Appropriated_Realisable_Value  ,
             SecuredAmt Secured_Amt_in_Rs  ,
             UnSecuredAmt UnSecured_Amt_in_Rs_  ,
             Provsecured Provision_Secured  ,
             ProvUnsecured Provision_Unsecured  ,
             TotalProvision Total_Provision  ,
             BankTotalProvision Bank_Total_Provision  ,
             RBITotalProvision RBI_Total_Provision  ,
             FinalNpaDt Final_NPA_Date  ,
             MOC_Dt MOC_Date  ,
             MakerID Operator_Maker_ID  ,
             MakerDate Operator_Maker_Date  ,
             CheckerID A1st_Level_Approver_Checker_ID  ,
             CheckerDate A1st_Level_Approver_Checker_Date  ,
             ReviewerID A2nd_Level_Approver_Reviewer_Id  ,
             ReviewerDate A2nd_Level_Approver_Reviewer_Date  ,
             MOCReason MOC_Reason  
        FROM tt_Final_29 
        ORDER BY 3 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_Hist_32 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_HIST_20 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountLevelMOC_Mod_20 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerLevelMOC_Mod_19 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_49 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_38 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimAcBuSegment_21 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_MOC_VERIFICATION" TO "ADF_CDR_RBL_STGDB";
