--------------------------------------------------------
--  DDL for Procedure MOC_VERIFICATION_REPORT_RDM_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey 
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N' );
   v_Mocdate VARCHAR2(200);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT UTILS.CONVERT_TO_VARCHAR2(DATE_,200) 

     INTO v_Mocdate
     FROM SysDayMatrix 
    WHERE  Timekey = v_TimeKey;
   IF ( utils.object_id('TEMPDB..tt_MOC_DATA_52') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MOC_DATA_52 ';
   END IF;
   DELETE FROM tt_MOC_DATA_52;
   UTILS.IDENTITY_RESET('tt_MOC_DATA_52');

   INSERT INTO tt_MOC_DATA_52 ( 
   	SELECT UcifEntityID 
   	  FROM MOC_ChangeDetails A
             JOIN CustomerBasicDetail CBD   ON A.EffectiveFromTimeKey <= v_TimeKey
             AND A.EffectiveToTimeKey >= v_TIMEKEY
             AND CBD.EffectivefromTimeKey <= v_TimeKey
             AND CBD.EffectiveToTimeKey >= v_TIMEKEY
             AND CBD.CustomerEntityId = A.CustomerEntityID
   	 WHERE  MOC_Date = v_Mocdate

   	--and cbd.CustomerId='2074381'
   	GROUP BY UcifEntityID );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_UcifEntityID
      ON tt_MOC_DATA_52 ( UcifEntityID)';
   IF ( utils.object_id('TEMPDB..tt_AccountCal_Hist_15') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_Hist_15 ';
   END IF;
   DELETE FROM tt_AccountCal_Hist_15;
   UTILS.IDENTITY_RESET('tt_AccountCal_Hist_15');

   INSERT INTO tt_AccountCal_Hist_15 ( 
   	SELECT A.UcifEntityID ,
           SourceAlt_Key ,
           CustomerAcID ,
           RefCustomerID ,
           UCIF_ID ,
           FacilityType ,
           InitialNpaDt ,
           InitialAssetClassAlt_Key ,
           FirstDtOfDisb ,
           ProductAlt_Key ,
           Balance ,
           PrincOutStd ,
           PrincOverdue ,
           IntOverdue ,
           DrawingPower ,
           CurrentLimit ,
           ContiExcessDt ,
           StockStDt ,
           DebitSinceDt ,
           LastCrDate ,
           CurQtrCredit ,
           CurQtrInt ,
           InttServiced ,
           IntNotServicedDt ,
           OverDueSinceDt ,
           ReviewDueDt ,
           DFVAmt ,
           GovtGtyAmt ,
           WriteOffAmount ,
           UnAdjSubSidy ,
           Asset_Norm ,
           AddlProvision ,
           PrincOverDueSinceDt ,
           IntOverDueSinceDt ,
           OtherOverDueSinceDt ,
           UnserviedInt ,
           AdvanceRecovery ,
           RePossession ,
           RepossessionDate ,
           RCPending ,
           PaymentPending ,
           WheelCase ,
           RFA ,
           IsNonCooperative ,
           Sarfaesi ,
           SarfaesiDate ,
           WeakAccount ,
           WeakAccountDate ,
           FlgFITL ,
           FlgRestructure ,
           RestructureDate ,
           FlgUnusualBounce ,
           UnusualBounceDate ,
           FlgUnClearedEffect ,
           UnClearedEffectDate ,
           CoverGovGur ,
           DegReason ,
           NetBalance ,
           ApprRV ,
           SecuredAmt ,
           UnSecuredAmt ,
           ProvDFV ,
           Provsecured ,
           ProvUnsecured ,
           ProvCoverGovGur ,
           TotalProvision ,
           BankTotalProvision ,
           RBITotalProvision ,
           FinalNpaDt ,
           UpgDate ,
           FinalAssetClassAlt_Key ,
           NPA_Reason ,
           FlgDeg ,
           FlgUpg ,
           FinalProvisiONPer ,
           FlgSMA ,
           SMA_Dt ,
           SMA_Class ,
           SMA_Reason ,
           FlgPNPA ,
           PNPA_DATE ,
           PNPA_Reason ,
           FlgFraud ,
           FraudDate ,
           MOCReason ,
           ActSegmentCode ,
           CustomerEntityID ,
           EffectiveFromTimekey ,
           FlgMoc 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
             JOIN tt_MOC_DATA_52 B   ON A.UcifEntityID = B.UcifEntityID
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   --select * from tt_AccountCal_Hist_15 where CustomerAcID='809002712795'
   --select * from tt_DimAcBuSegment_7 where AcBuSegmentcode='1326'
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID
      ON tt_AccountCal_Hist_15 ( CustomerACID)';
   -------------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_CustomerCal_HIST_3') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_HIST_3 ';
   END IF;
   DELETE FROM tt_CustomerCal_HIST_3;
   UTILS.IDENTITY_RESET('tt_CustomerCal_HIST_3');

   INSERT INTO tt_CustomerCal_HIST_3 ( 
   	SELECT A.CustomerEntityID ,
           RefCustomerID ,
           CustomerName ,
           PANNo ,
           AadharCardNo ,
           CurntQtrRv ,
           MOCReason ,
           DbtDt ,
           FlgMoc ,
           CustMoveDescription 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
             JOIN tt_MOC_DATA_52 B   ON A.UcifEntityID = B.UcifEntityID
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID
      ON tt_CustomerCal_HIST_3 ( CustomerEntityID)';
   ---------------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_AccountLevelMOC_Mod_3') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountLevelMOC_Mod_3 ';
   END IF;
   DELETE FROM tt_AccountLevelMOC_Mod_3;
   UTILS.IDENTITY_RESET('tt_AccountLevelMOC_Mod_3');

   INSERT INTO tt_AccountLevelMOC_Mod_3 ( 
   	SELECT AccountID ,
           ChangeField ,
           EffectiveFromTimekey ,
           EffectiveToTimekey ,
           CreatedBy ,
           DateCreated ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel ,
           ApprovedBy ,
           DateApproved 
   	  FROM AccountLevelMOC_Mod 
   	 WHERE  MOCDate = v_Mocdate
              AND ChangeField IS NOT NULL );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_AccountID
      ON tt_AccountLevelMOC_Mod_3 ( AccountID)';
   --select * from tt_AccountLevelMOC_Mod_3
   ---------------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_CustomerLevelMOC_Mod_3') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerLevelMOC_Mod_3 ';
   END IF;
   DELETE FROM tt_CustomerLevelMOC_Mod_3;
   UTILS.IDENTITY_RESET('tt_CustomerLevelMOC_Mod_3');

   INSERT INTO tt_CustomerLevelMOC_Mod_3 ( 
   	SELECT Entity_Key ,
           CustomerEntityID ,
           ChangeField ,
           EffectiveFromTimekey ,
           EffectiveToTimekey ,
           CreatedBy ,
           DateCreated ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel ,
           ApprovedBy ,
           DateApproved ,
           AuthorisationStatus 
   	  FROM CustomerLevelMOC_Mod 
   	 WHERE  MOCDate = v_Mocdate
              AND ChangeField IS NOT NULL );
   --and AuthorisationStatus<>'R'
   --select * from tt_CustomerLevelMOC_Mod_3
   --select * from CustomerLevelMOC_Mod where CustomerID='2074381'
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID2
      ON tt_CustomerLevelMOC_Mod_3 ( CustomerEntityID)';
   --select * from tt_CustomerLevelMOC_Mod_3 
   --select * from CustomerLevelMOC_Mod where CustomerID='0215012763000004599'
   --MOCDate='2022-06-30'
   -------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_AccountCal_29') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_29 ';
   END IF;
   DELETE FROM tt_AccountCal_29;
   UTILS.IDENTITY_RESET('tt_AccountCal_29');

   INSERT INTO tt_AccountCal_29 ( 
   	SELECT UcifEntityID ,
           SourceAlt_Key ,
           CustomerAcID ,
           RefCustomerID ,
           UCIF_ID ,
           FacilityType ,
           InitialNpaDt ,
           InitialAssetClassAlt_Key ,
           FirstDtOfDisb ,
           ProductAlt_Key ,
           Balance ,
           PrincOutStd ,
           PrincOverdue ,
           IntOverdue ,
           DrawingPower ,
           CurrentLimit ,
           ContiExcessDt ,
           StockStDt ,
           DebitSinceDt ,
           LastCrDate ,
           CurQtrCredit ,
           CurQtrInt ,
           InttServiced ,
           IntNotServicedDt ,
           OverDueSinceDt ,
           ReviewDueDt ,
           DFVAmt ,
           GovtGtyAmt ,
           WriteOffAmount ,
           UnAdjSubSidy ,
           Asset_Norm ,
           AddlProvision ,
           PrincOverDueSinceDt ,
           IntOverDueSinceDt ,
           OtherOverDueSinceDt ,
           UnserviedInt ,
           AdvanceRecovery ,
           RePossession ,
           RepossessionDate ,
           RCPending ,
           PaymentPending ,
           WheelCase ,
           RFA ,
           IsNonCooperative ,
           Sarfaesi ,
           SarfaesiDate ,
           WeakAccount ,
           WeakAccountDate ,
           FlgFITL ,
           FlgRestructure ,
           RestructureDate ,
           FlgUnusualBounce ,
           UnusualBounceDate ,
           FlgUnClearedEffect ,
           UnClearedEffectDate ,
           CoverGovGur ,
           DegReason ,
           NetBalance ,
           ApprRV ,
           SecuredAmt ,
           UnSecuredAmt ,
           ProvDFV ,
           Provsecured ,
           ProvUnsecured ,
           ProvCoverGovGur ,
           TotalProvision ,
           BankTotalProvision ,
           RBITotalProvision ,
           FinalNpaDt ,
           UpgDate ,
           FinalAssetClassAlt_Key ,
           NPA_Reason ,
           FlgDeg ,
           FlgUpg ,
           FinalProvisiONPer ,
           FlgSMA ,
           SMA_Dt ,
           SMA_Class ,
           SMA_Reason ,
           FlgPNPA ,
           PNPA_DATE ,
           PNPA_Reason ,
           FlgFraud ,
           FraudDate ,
           MOCReason ,
           ActSegmentCode ,
           CustomerEntityID ,
           EffectiveFromTimekey ,
           FlgMoc 
   	  FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID1
      ON tt_AccountCal_29 ( CustomerACID)';
   --------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_CustomerCal_18') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_18 ';
   END IF;
   DELETE FROM tt_CustomerCal_18;
   UTILS.IDENTITY_RESET('tt_CustomerCal_18');

   INSERT INTO tt_CustomerCal_18 ( 
   	SELECT CustomerEntityID ,
           RefCustomerID ,
           CustomerName ,
           PANNo ,
           AadharCardNo ,
           CurntQtrRv ,
           MOCReason ,
           DbtDt ,
           FlgMoc ,
           CustMoveDescription 
   	  FROM PreMoc_RBL_MISDB_PROD.CUSTOMERCAL 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID1
      ON tt_CustomerCal_18 ( CustomerEntityID)';
   ------------------------------------------------------  
   IF ( utils.object_id('TEMPDB..tt_DimAcBuSegment_7') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimAcBuSegment_7 ';
   END IF;
   DELETE FROM tt_DimAcBuSegment_7;
   UTILS.IDENTITY_RESET('tt_DimAcBuSegment_7');

   INSERT INTO tt_DimAcBuSegment_7 SELECT DENSE_RANK() OVER ( PARTITION BY AcBuRevisedSegmentCode ORDER BY AcBuSegmentCode  ) RN  ,
                                          AcBuSegmentCode ,
                                          AcBuRevisedSegmentCode ,
                                          AcBuSegmentDescription 
        FROM DimAcBuSegment 
       WHERE  EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
   ---------------------PreMOC_DATA----------------------  
   IF utils.object_id('Tempdb..tt_Final_15') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_15 ';
   END IF;
   --DECLARE  @TimeKey AS INT=26479
   DELETE FROM tt_Final_15;
   UTILS.IDENTITY_RESET('tt_Final_15');

   INSERT INTO tt_Final_15 SELECT ROW_NUMBER() OVER ( ORDER BY A.UcifEntityId  ) SrNo  ,
                                  'Post Moc' Moc_Status  ,
                                  UTILS.CONVERT_TO_VARCHAR2(G.DATE_,20,p_style=>103) CurrentProcessingDate  ,
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
                                  --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
                                  --,DABS.AcBuSegmentDescription  
                                  --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
                                  CASE 
                                       WHEN SourceName = 'FIS' THEN 'FI'
                                       WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
                                  ELSE DABS.AcBuRevisedSegmentCode
                                     END AcBuSegmentCode  ,
                                  --,DABS.AcBuSegmentDescription  
                                  CASE 
                                       WHEN SourceName = 'FIS' THEN 'FI'
                                       WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
                                  ELSE DABS.AcBuSegmentDescription
                                     END AcBuSegmentDescription  ,
                                  clm.AuthorisationStatus 
        FROM tt_AccountCal_Hist_15 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_AccountLevelMOC_Mod_3 ALM   ON ALM.AccountId = A.CustomerAcID
               LEFT JOIN tt_CustomerCal_HIST_3 F   ON F.CustomerEntityId = A.CustomerEntityId
               LEFT JOIN tt_CustomerLevelMOC_Mod_3 CLM   ON F.CustomerEntityId = CLM.CustomerEntityId
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
               LEFT JOIN tt_DimAcBuSegment_7 DABS   ON A.ActSegmentCode = DABS.AcBuSegmentCode

      --AND DABS.RN=1  
      WHERE  ( A.FlgMoc = 'Y'
               OR F.FlgMoc = 'Y' )
      UNION ALL 

      --select * from #final where reviewerid is null
      SELECT ROW_NUMBER() OVER ( ORDER BY A.UcifEntityId  ) SrNo  ,
             'Pre Moc' Moc_Status  ,
             UTILS.CONVERT_TO_VARCHAR2(G.DATE_,20,p_style=>103) CurrentProcessingDate  ,
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
             --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE DABS.AcBuRevisedSegmentCode
                END AcBuSegmentCode  ,
             --,DABS.AcBuSegmentDescription  
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE DABS.AcBuSegmentDescription
                END AcBuSegmentDescription  ,
             clm.AuthorisationStatus 
        FROM tt_AccountCal_29 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_AccountLevelMOC_Mod_3 ALM   ON ALM.AccountId = A.CustomerAcID
               LEFT JOIN tt_CustomerCal_18 F   ON F.CustomerEntityId = A.CustomerEntityId
               LEFT JOIN tt_CustomerLevelMOC_Mod_3 CLM   ON F.CustomerEntityId = CLM.CustomerEntityId
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
               LEFT JOIN tt_DimAcBuSegment_7 DABS   ON A.ActSegmentCode = DABS.AcBuSegmentCode

      --AND DABS.RN=1  
      WHERE  A.CustomerAcID IN ( SELECT CustomerAcID 
                                 FROM tt_AccountCal_Hist_15 A
                                        LEFT JOIN tt_CustomerCal_HIST_3 C   ON C.CustomerEntityId = A.CustomerEntityId
                                  WHERE  ( A.FlgMoc = 'Y'
                                           OR C.FlgMoc = 'Y' ) )

        ORDER BY CustomerAcID,
                 CustomerID,
                 Moc_Status DESC;
   UPDATE tt_Final_15
      SET MakerID = 'System',
          CheckerID = 'System',
          ReviewerID = 'System'
    WHERE  MakerID IS NULL
     OR CheckerID IS NULL
     OR ReviewerID IS NULL;
   UPDATE tt_Final_15
      SET AuthorisationStatus = 'A'
    WHERE  AuthorisationStatus IS NULL;
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_Final_15 
        ORDER BY CustomerAcID,
                 CustomerID,
                 Moc_Status DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--DROP TABLE tt_AccountCal_Hist_15,tt_CustomerCal_18_Hist,tt_AccountLevelMOC_Mod_3,tt_CustomerLevelMOC_Mod_3,tt_AccountCal_29,tt_CustomerCal_18,tt_DimAcBuSegment_7  
   --select * from tt_DimAcBuSegment_7 

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_VERIFICATION_REPORT_RDM_04122023" TO "ADF_CDR_RBL_STGDB";
