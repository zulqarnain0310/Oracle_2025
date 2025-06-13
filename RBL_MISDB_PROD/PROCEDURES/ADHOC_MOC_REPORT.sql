--------------------------------------------------------
--  DDL for Procedure ADHOC_MOC_REPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" --'01/01/2021','15/04/2023'

(
  iv_FromDate IN VARCHAR2,
  iv_ToDate IN VARCHAR2
)
AS
   v_FromDate VARCHAR2(10) := iv_FromDate;
   v_ToDate VARCHAR2(10) := iv_ToDate;
   --SrNo int,
   --5
   --10
   --15
   --20
   --25
   --30
   --35
   --40
   --45
   --50
   --55
   --60
   -------OutPut-----  		,
   --65
   --70
   --75
   --80
   --85
   --90
   --95
   --100
   --105
   v_timekey NUMBER(10,0);
   v_counter NUMBER(10,0);
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;--SrNo,
         v_Process_Date VARCHAR2(200) ;
BEGIN

   --Declare @FromDate Varchar(10)= '01/01/2021'
   --Declare @ToDate Varchar(10)= '15/04/2023'
   v_FromDate := UTILS.CONVERT_TO_VARCHAR2(v_FromDate,200,p_style=>105) ;
   v_ToDate := UTILS.CONVERT_TO_VARCHAR2(v_ToDate,200,p_style=>105) ;
   IF utils.object_id('TEMPDB..tt_TEMP1') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP1 ';
   END IF;
   --select Timekey,date,ROW_NUMBER() over (order by Timekey) rn INTO tt_TEMP1 from Automate_Advances
   --where date >=@FromDate and date <=@ToDate
   --order by 1
   DELETE FROM tt_TEMP1;
   UTILS.IDENTITY_RESET('tt_TEMP1');

   INSERT INTO tt_TEMP1 SELECT Timekey ,
                               date_ ,
                               ROW_NUMBER() OVER ( ORDER BY Timekey  ) rn  
        FROM Automate_Advances a
               JOIN AdhocACL_ChangeDetails b   ON a.Timekey = b.EffectiveFromTimeKey
       WHERE  UTILS.CONVERT_TO_VARCHAR2(b.DateCreated,200) >= v_FromDate
                AND UTILS.CONVERT_TO_VARCHAR2(b.DateCreated,200) <= v_ToDate
        ORDER BY 1;
   IF utils.object_id('TEMPDB..GTT_ADHOC_MOC') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_ADHOC_MOC ';
   END IF;
   DELETE FROM GTT_ADHOC_MOC;
   v_counter := 1 ;
   LOOP
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE ( v_counter <= ( SELECT MAX(rn)  
                                 FROM tt_TEMP1  ) );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp != 1 THEN
         EXIT;
      END IF;


         SELECT date_ INTO v_Process_Date
           FROM tt_TEMP1 
          WHERE  rn = v_counter ;

      BEGIN
         SELECT timekey 

           INTO v_timekey
           FROM tt_TEMP1 
          WHERE  rn = v_counter;
         --------------------------------------------------------------------------------------------------
         --Declare @TimeKey int=26477
         --set @TimeKey=@TimeKey+1
         IF ( utils.object_id('TEMPDB..tt_DimAcBuSegment') IS NOT NULL ) THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimAcBuSegment ';
         END IF;
         DELETE FROM tt_DimAcBuSegment;
         UTILS.IDENTITY_RESET('tt_DimAcBuSegment');

         INSERT INTO tt_DimAcBuSegment SELECT DENSE_RANK() OVER ( PARTITION BY AcBuRevisedSegmentCode ORDER BY AcBuSegmentCode  ) RN  ,
                                              AcBuSegmentCode ,
                                              AcBuRevisedSegmentCode ,
                                              AcBuSegmentDescription 
              FROM DimAcBuSegment 
             WHERE  EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey;
         INSERT INTO GTT_ADHOC_MOC
           SELECT 
                  --ROW_NUMBER()OVER(ORDER BY A.UcifEntityId)                        AS SrNo 
                  'Post Moc' Moc_Status  ,
                  UTILS.CONVERT_TO_VARCHAR2(G.Date_,20,p_style=>103) CurrentProcessingDate  ,
                  --,ROW_NUMBER()OVER(ORDER BY A.UcifEntityId)                        AS SrNo  
                  ---------RefColumns---------  
                  H.SourceName ,
                  A.CustomerAcID ,--5

                  A.RefCustomerID CustomerID  ,
                  B.CustomerName ,
                  A.UCIF_ID ,
                  A.FacilityType ,
                  NVL(B.PANNo, ' ') PANNo ,--10

                  B.AadharCardNo ,
                  UTILS.CONVERT_TO_VARCHAR2(A.InitialNpaDt,20,p_style=>103) InitialNpaDt  ,
                  A.InitialAssetClassAlt_Key ,
                  --,DA.AssetClassName                                                 AS InitalAssetClassName  
                  DA.AssetClassSubGroup InitalAssetClassName ,---added by Prashant---02052024---  

                  ----Edit--------  
                  UTILS.CONVERT_TO_VARCHAR2(A.FirstDtOfDisb,20,p_style=>103) FirstDtOfDisb ,--15 

                  A.ProductAlt_Key ,
                  DP.ProductName ,
                  NVL(A.Balance, 0) Balance  ,
                  NVL(A.PrincOutStd, 0) PrincOutStd  ,
                  NVL(A.PrincOverdue, 0) PrincOverdue ,--20

                  NVL(A.IntOverdue, 0) IntOverdue  ,
                  NVL(A.DrawingPower, 0) DrawingPower  ,
                  NVL(A.CurrentLimit, 0) CurrentLimit  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.StockStDt,20,p_style=>103) StockStDt ,--25

                  UTILS.CONVERT_TO_VARCHAR2(A.DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.LastCrDate,20,p_style=>103) LastCrDate  ,
                  NVL(A.CurQtrCredit, 0) CurQtrCredit  ,
                  NVL(A.CurQtrInt, 0) CurQtrInt  ,
                  A.InttServiced ,--30

                  UTILS.CONVERT_TO_VARCHAR2(A.IntNotServicedDt,20,p_style=>103) IntNotServicedDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
                  NVL(B.CurntQtrRv, 0) SecurityValue  ,
                  NVL(A.DFVAmt, 0) DFVAmt ,--35 

                  NVL(A.GovtGtyAmt, 0) GovtGtyAmt  ,
                  NVL(A.WriteOffAmount, 0) WriteOffAmount  ,
                  NVL(A.UnAdjSubSidy, 0) UnAdjSubSidy  ,
                  A.Asset_Norm ,
                  NVL(A.AddlProvision, 0) AddlProvision ,--40 

                  UTILS.CONVERT_TO_VARCHAR2(A.PrincOverDueSinceDt,20,p_style=>103) PrincOverDueSinceDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.IntOverDueSinceDt,20,p_style=>103) IntOverDueSinceDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.OtherOverDueSinceDt,20,p_style=>103) OtherOverDueSinceDt  ,
                  NVL(A.UnserviedInt, 0) UnserviedInt  ,
                  NVL(A.AdvanceRecovery, 0) AdvanceRecovery ,--45

                  A.RePossession ,
                  UTILS.CONVERT_TO_VARCHAR2(A.RepossessionDate,20,p_style=>103) RepossessionDate  ,
                  A.RCPending ,
                  A.PaymentPending ,
                  A.WheelCase ,--50

                  A.RFA ,
                  A.IsNonCooperative ,
                  A.Sarfaesi ,
                  UTILS.CONVERT_TO_VARCHAR2(A.SarfaesiDate,20,p_style=>103) SarfaesiDate  ,
                  A.WeakAccount InherentWeakness ,--55 

                  UTILS.CONVERT_TO_VARCHAR2(A.WeakAccountDate,20,p_style=>103) InherentWeaknessDate  ,
                  A.FlgFITL ,
                  A.FlgRestructure ,
                  UTILS.CONVERT_TO_VARCHAR2(A.RestructureDate,20,p_style=>103) RestructureDate  ,
                  A.FlgUnusualBounce ,--60

                  UTILS.CONVERT_TO_VARCHAR2(A.UnusualBounceDate,20,p_style=>103) UnusualBounceDate  ,
                  A.FlgUnClearedEffect ,
                  UTILS.CONVERT_TO_VARCHAR2(A.UnClearedEffectDate,20,p_style=>103) UnClearedEffectDate  ,
                  -------OutPut-----  
                  NVL(A.CoverGovGur, 0) CoverGovGur  ,
                  A.DegReason ,--65

                  NVL(A.NetBalance, 0) NetBalance  ,
                  NVL(A.ApprRV, 0) ApprRV  ,
                  NVL(A.SecuredAmt, 0) SecuredAmt  ,
                  NVL(A.UnSecuredAmt, 0) UnSecuredAmt  ,
                  NVL(A.ProvDFV, 0) ProvDFV ,--70

                  NVL(A.Provsecured, 0) Provsecured  ,
                  NVL(A.ProvUnsecured, 0) ProvUnsecured  ,
                  NVL(A.ProvCoverGovGur, 0) ProvCoverGovGur  ,
                  NVL(A.TotalProvision, 0) TotalProvision  ,
                  NVL(A.BankTotalProvision, 0) BankTotalProvision ,--75

                  NVL(A.RBITotalProvision, 0) RBITotalProvision  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(B.DbtDt,20,p_style=>103) DoubtfulDt  ,
                  UTILS.CONVERT_TO_VARCHAR2(A.UpgDate,20,p_style=>103) UpgDate  ,
                  A.FinalAssetClassAlt_Key ,--80

                  --,DA1.AssetClassName                                                 AS FinalAssetClassName  
                  DA1.AssetClassSubGroup FinalAssetClassName ,---added by Prashant---02052024---

                  A.NPA_Reason ,
                  A.FlgDeg ,
                  A.FlgUpg ,
                  A.FinalProvisiONPer ,--85

                  A.FlgSMA ,
                  UTILS.CONVERT_TO_VARCHAR2(A.SMA_Dt,20,p_style=>103) SMA_Dt  ,
                  A.SMA_Class ,
                  A.SMA_Reason ,
                  A.FlgPNPA ,--90

                  UTILS.CONVERT_TO_VARCHAR2(A.PNPA_DATE,20,p_style=>103) PNPA_DATE  ,
                  A.PNPA_Reason ,
                  B.CustMoveDescription CustSMAStatus  ,
                  --,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt  
                  UTILS.CONVERT_TO_VARCHAR2(G.Date_,20,p_style=>103) MOC_Dt  ,
                  A.FlgFraud ,--95

                  UTILS.CONVERT_TO_VARCHAR2(A.FraudDate,20,p_style=>103) FraudDate  ,
                  AC.CreatedBy MakerID  ,
                  --,AC.DateCreated                         AS MakerDate 
                  (UTILS.CONVERT_TO_VARCHAR2(AC.DateCreated,10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(AC.DateCreated,30,p_style=>108)) MakerDate  ,
                  AC.FirstLevelApprovedBy CheckerID  ,
                  --,AC.FirstLevelDateApproved     AS CheckerDate  --100
                  (UTILS.CONVERT_TO_VARCHAR2(AC.FirstLevelDateApproved,10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(AC.FirstLevelDateApproved,30,p_style=>108)) CheckerDate  ,
                  AC.ApprovedBy ReviewerID  ,
                  --,AC.DateApproved                   AS ReviewerDate  
                  (UTILS.CONVERT_TO_VARCHAR2(AC.DateApproved,10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(AC.DateApproved,30,p_style=>108)) ReviewerDate  ,
                  DR.ParameterName MOCReason  ,
                  --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
                  --,DABS.AcBuSegmentDescription  --105
                  CASE 
                       WHEN SourceName = 'FIS' THEN 'FI'

                       --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                       WHEN SourceName = 'VisionPlus'
                         AND A.ProductCode IN ( '777','780' )
                        THEN 'Retail'
                       WHEN SourceName = 'VisionPlus'
                         AND A.ProductCode NOT IN ( '777','780' )
                        THEN 'Credit Card'
                  ELSE DABS.AcBuRevisedSegmentCode
                     END AcBuSegmentCode  ,
                  --,DABS.AcBuSegmentDescription  
                  CASE 
                       WHEN SourceName = 'FIS' THEN 'FI'
                       WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
                  ELSE DABS.AcBuSegmentDescription
                     END AcBuSegmentDescription  

             --into GTT_ADHOC_MOC
             FROM MAIN_PRO.AccountCal_Hist a
                    JOIN MAIN_PRO.CustomerCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
                    JOIN AdhocACL_ChangeDetails AC   ON AC.CustomerEntityId = B.CustomerEntityID
                    AND AC.EffectiveFromTimeKey <= v_TimeKey
                    AND AC.EffectiveToTimeKey >= v_TimeKey
                    LEFT JOIN SysDayMatrix G   ON AC.EffectiveFromTimeKey = G.TimeKey
                    LEFT JOIN DIMSOURCEDB H   ON A.SourceAlt_Key = H.SourceAlt_Key
                    LEFT JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = A.InitialAssetClassAlt_Key
                    AND DA.EffectiveToTimeKey = 49999
                    LEFT JOIN DimAssetClass DA1   ON DA1.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
                    AND DA1.EffectiveToTimeKey = 49999
                    LEFT JOIN DimProduct DP   ON DP.ProductAlt_Key = A.ProductAlt_Key
                    AND DP.EffectiveToTimeKey = 49999
                    LEFT JOIN tt_DimAcBuSegment DABS   ON A.ActSegmentCode = DABS.AcBuSegmentCode
                  --AND DABS.RN=1  

                    LEFT JOIN DimParameter DR   ON DR.ParameterAlt_Key = AC.Reason
                    AND DR.DimParameterName = 'DimMoRreason'
                    AND DR.EffectiveToTimeKey = 49999
            WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                     AND A.EffectiveToTimeKey >= v_TimeKey
             ORDER BY 2;
         v_counter := v_counter + 1 ;

      END;
   END LOOP;
   -------------- REMOVING STARTING AND ENDING COMMAS IN REASONS COLUMNS BY SATWAJI AS ON 15/04/2023 -------------------------
   OPEN  v_cursor FOR
      SELECT Moc_Status ,
             CurrentProcessingDate ,
             SourceName ,
             CustomerAcID ,
             CustomerID ,
             CustomerName ,
             UCIF_ID ,
             FacilityType ,
             PANNo ,
             AadharCardNo ,
             InitialNpaDt ,
             InitialAssetClassAlt_Key ,
             InitalAssetClassName ,
             FirstDtOfDisb ,
             ProductAlt_Key ,
             ProductName ,
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
             SecurityValue ,
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
             InherentWeakness ,
             InherentWeaknessDate ,
             FlgFITL ,
             FlgRestructure ,
             RestructureDate ,
             FlgUnusualBounce ,
             UnusualBounceDate ,
             FlgUnClearedEffect ,
             UnClearedEffectDate ,
             CoverGovGur ,
             CASE 
                  WHEN SUBSTR(DegReason, 0, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(DegReason, ',', ' & '), -LENGTH(DegReason) - 1, LENGTH(DegReason) - 1))
                  WHEN SUBSTR(DegReason, -1, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(DegReason, ',', ' & '), 0, LENGTH(DegReason) - 1))
             ELSE REPLACE(DegReason, ',', ' & ')
                END DegReason  ,
             --,DegReason
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
             DoubtfulDt ,
             UpgDate ,
             FinalAssetClassAlt_Key ,
             FinalAssetClassName ,
             CASE 
                  WHEN SUBSTR(NPA_Reason, 0, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(NPA_Reason, ',', ' & '), -LENGTH(NPA_Reason) - 1, LENGTH(NPA_Reason) - 1))
                  WHEN SUBSTR(NPA_Reason, -1, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(NPA_Reason, ',', ' & '), 0, LENGTH(NPA_Reason) - 1))
             ELSE REPLACE(NPA_Reason, ',', ' & ')
                END NPA_Reason  ,
             --NPA_Reason
             FlgDeg ,
             FlgUpg ,
             FinalProvisiONPer ,
             FlgSMA ,
             SMA_Dt ,
             SMA_Class ,
             CASE 
                  WHEN SUBSTR(SMA_Reason, 0, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(SMA_Reason, ',', ' & '), -LENGTH(SMA_Reason) - 1, LENGTH(SMA_Reason) - 1))
                  WHEN SUBSTR(SMA_Reason, -1, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(SMA_Reason, ',', ' & '), 0, LENGTH(SMA_Reason) - 1))
             ELSE REPLACE(TRIM(SMA_Reason), ',', ' & ')
                END SMA_Reason  ,
             --SMA_Reason
             FlgPNPA ,
             PNPA_DATE ,
             CASE 
                  WHEN SUBSTR(PNPA_Reason, 0, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(PNPA_Reason, ',', ' & '), -LENGTH(PNPA_Reason) - 1, LENGTH(PNPA_Reason) - 1))
                  WHEN SUBSTR(PNPA_Reason, -1, 1) LIKE ', ' THEN TRIM(SUBSTR(REPLACE(PNPA_Reason, ',', ' & '), 0, LENGTH(PNPA_Reason) - 1))
             ELSE REPLACE(TRIM(PNPA_Reason), ',', ' & ')
                END PNPA_Reason  ,
             --PNPA_Reason
             CustSMAStatus ,
             MOC_Dt ,
             FlgFraud ,
             FraudDate ,
             MakerID ,
             MakerDate ,
             CheckerID ,
             CheckerDate ,
             ReviewerID ,
             ReviewerDate ,
             CASE 
                  WHEN SUBSTR(MOCReason, 0, 1) = ', ' THEN TRIM(SUBSTR(REPLACE(MOCReason, ',', ' & '), -LENGTH(MOCReason) - 1, LENGTH(MOCReason) - 1))
                  WHEN SUBSTR(MOCReason, -1, 1) = ', ' THEN TRIM(SUBSTR(REPLACE(MOCReason, ',', ' & '), 0, LENGTH(MOCReason) - 1))
             ELSE REPLACE(TRIM(MOCReason), ',', ' & ')
                END MOCReason  ,
             --MOCReason
             AcBuSegmentCode ,
             AcBuSegmentDescription 
        FROM GTT_ADHOC_MOC 
        ORDER BY UCIF_ID,
                 CustomerID,
                 CustomerAcID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOC_MOC_REPORT" TO "ADF_CDR_RBL_STGDB";
