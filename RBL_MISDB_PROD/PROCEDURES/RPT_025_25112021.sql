--------------------------------------------------------
--  DDL for Procedure RPT_025_25112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_025_25112021" 
(
  v_TimeKey IN NUMBER
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --DECLARE  @TimeKey AS INT=26176
   IF ( utils.object_id('TEMPDB..tt_AccountCal_Hist_29') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_Hist_29 ';
   END IF;
   DELETE FROM tt_AccountCal_Hist_29;
   UTILS.IDENTITY_RESET('tt_AccountCal_Hist_29');

   INSERT INTO tt_AccountCal_Hist_29 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey = v_TimeKey
              AND EffectiveToTimeKey = v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID
      ON tt_AccountCal_Hist_29 ( CustomerACID)';
   -------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_CustomerCal_HIST_17') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_HIST_17 ';
   END IF;
   DELETE FROM tt_CustomerCal_HIST_17;
   UTILS.IDENTITY_RESET('tt_CustomerCal_HIST_17');

   INSERT INTO tt_CustomerCal_HIST_17 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
   	 WHERE  EffectiveFromTimeKey = v_TimeKey
              AND EffectiveToTimeKey = v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID
      ON tt_CustomerCal_HIST_17 ( CustomerEntityID)';
   ---------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_AccountLevelMOC_Mod_17') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountLevelMOC_Mod_17 ';
   END IF;
   DELETE FROM tt_AccountLevelMOC_Mod_17;
   UTILS.IDENTITY_RESET('tt_AccountLevelMOC_Mod_17');

   INSERT INTO tt_AccountLevelMOC_Mod_17 ( 
   	SELECT * 
   	  FROM AccountLevelMOC_Mod 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND ChangeField IS NOT NULL );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_AccountID
      ON tt_AccountLevelMOC_Mod_17 ( AccountID)';
   ---------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_CustomerLevelMOC_Mod_17') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerLevelMOC_Mod_17 ';
   END IF;
   DELETE FROM tt_CustomerLevelMOC_Mod_17;
   UTILS.IDENTITY_RESET('tt_CustomerLevelMOC_Mod_17');

   INSERT INTO tt_CustomerLevelMOC_Mod_17 ( 
   	SELECT * 
   	  FROM CustomerLevelMOC_Mod 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND ChangeField IS NOT NULL );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID2
      ON tt_CustomerLevelMOC_Mod_17 ( CustomerEntityID)';
   -------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_AccountCal_46') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_46 ';
   END IF;
   DELETE FROM tt_AccountCal_46;
   UTILS.IDENTITY_RESET('tt_AccountCal_46');

   INSERT INTO tt_AccountCal_46 ( 
   	SELECT * 
   	  FROM PreMoc_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerACID1
      ON tt_AccountCal_46 ( CustomerACID)';
   --------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_CustomerCal_35') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_35 ';
   END IF;
   DELETE FROM tt_CustomerCal_35;
   UTILS.IDENTITY_RESET('tt_CustomerCal_35');

   INSERT INTO tt_CustomerCal_35 ( 
   	SELECT * 
   	  FROM PreMoc_RBL_MISDB_PROD.CUSTOMERCAL 
   	 WHERE  EffectiveFromTimeKey = v_TimeKey
              AND EffectiveToTimeKey = v_TimeKey );
   EXECUTE IMMEDIATE ' CREATE INDEX INX_CustomerEntityID1
      ON tt_CustomerCal_35 ( CustomerEntityID)';
   ---------------------PreMOC_DATA----------------------
   OPEN  v_cursor FOR
      SELECT 'Post Moc' Moc_Status  ,
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
             UTILS.CONVERT_TO_VARCHAR2(A.MOC_Dt,20,p_style=>103) MOC_Dt  ,
             A.FlgFraud ,
             UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,20,p_style=>103) FraudDate  ,
             NVL(ALM.CreatedBy, CLM.CreatedBy) MakerID  ,
             NVL(ALM.DateCreated, CLM.DateCreated) MakerDate  ,
             NVL(ALM.ApprovedByFirstLevel, CLM.ApprovedByFirstLevel) CheckerID  ,
             NVL(ALM.DateApprovedFirstLevel, CLM.DateApprovedFirstLevel) CheckerDate  ,
             NVL(ALM.ApprovedBy, CLM.ApprovedBy) ReviewerID  ,
             NVL(ALM.DateApproved, CLM.DateApproved) ReviewerDate  ,
             NVL(A.MOCReason, F.MOCReason) MOCReason  ,
             DABS.AcBuSegmentCode ,
             DABS.AcBuSegmentDescription 
        FROM tt_AccountCal_Hist_29 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_AccountLevelMOC_Mod_17 ALM   ON ALM.AccountId = A.CustomerAcID
               LEFT JOIN tt_CustomerCal_HIST_17 F   ON F.CustomerEntityId = A.CustomerEntityId
               LEFT JOIN tt_CustomerLevelMOC_Mod_17 CLM   ON F.CustomerEntityId = CLM.CustomerEntityId
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
               LEFT JOIN DimAcBuSegment DABS   ON A.ActSegmentCode = DABS.AcBuRevisedSegmentCode
               AND DABS.EffectiveFromTimeKey <= v_TimeKey
               AND DABS.EffectiveToTimeKey >= v_TimeKey
       WHERE  A.FlgMoc = 'Y'
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
             UTILS.CONVERT_TO_VARCHAR2(A.MOC_Dt,20,p_style=>103) MOC_Dt  ,
             A.FlgFraud ,
             UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,20,p_style=>103) FraudDate  ,
             NVL(ALM.CreatedBy, CLM.CreatedBy) MakerID  ,
             NVL(ALM.DateCreated, CLM.DateCreated) MakerDate  ,
             NVL(ALM.ApprovedByFirstLevel, CLM.ApprovedByFirstLevel) CheckerID  ,
             NVL(ALM.DateApprovedFirstLevel, CLM.DateApprovedFirstLevel) CheckerDate  ,
             NVL(ALM.ApprovedBy, CLM.ApprovedBy) ReviewerID  ,
             NVL(ALM.DateApproved, CLM.DateApproved) ReviewerDate  ,
             NVL(A.MOCReason, F.MOCReason) MOCReason  ,
             DABS.AcBuSegmentCode ,
             DABS.AcBuSegmentDescription 
        FROM tt_AccountCal_46 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_AccountLevelMOC_Mod_17 ALM   ON ALM.AccountId = A.CustomerAcID
               LEFT JOIN tt_CustomerCal_35 F   ON F.CustomerEntityId = A.CustomerEntityId
               LEFT JOIN tt_CustomerLevelMOC_Mod_17 CLM   ON F.CustomerEntityId = CLM.CustomerEntityId
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
               LEFT JOIN DimAcBuSegment DABS   ON A.ActSegmentCode = DABS.AcBuRevisedSegmentCode
               AND DABS.EffectiveFromTimeKey <= v_TimeKey
               AND DABS.EffectiveToTimeKey >= v_TimeKey
       WHERE  A.CustomerAcID IN ( SELECT CustomerAcID 
                                  FROM tt_AccountCal_Hist_29 
                                   WHERE  FlgMoc = 'Y' )

        ORDER BY CustomerAcID,
                 CustomerID,
                 Moc_Status DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_Hist_29 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_HIST_17 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountLevelMOC_Mod_17 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerLevelMOC_Mod_17 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountCal_46 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_35 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_025_25112021" TO "ADF_CDR_RBL_STGDB";
