--------------------------------------------------------
--  DDL for Procedure MARKING_FLGDEG_DEGREASON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : MARKING OF FLGDEG AND DEG REASON 
 --EXEC [Pro].[Marking_FlgDeg_Degreason] @TIMEKEY=25140
=============================================*/
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
   BEGIN
      DECLARE
         v_ProcessDate VARCHAR2(200);
        V_DysOfDelay int;
      BEGIN
      
          SELECT DATE_ INTO v_ProcessDate 
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TimeKey = v_TIMEKEY;
         /*---------------INTIAL LEVEL FLG DEG SET N------------------------------------------*/
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'N'
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( NVL(B.FlgProcessing, 'N') = 'N' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = 'N';
         /*---------------UPDATE DEG FLAG AT CUSTOMER LEVEL------------------------------------*/
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, 'N'
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( NVL(B.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FlgDeg = 'N';
         /*---------------UPDATE DEG FLAG AT ACCOUNT LEVEL-----------------------------------------*/
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN NVL(A.DPD_INTSERVICE, 0) >= A.REFPERIODINTSERVICE THEN 'Y'
         WHEN NVL(A.DPD_OVERDRAWN, 0) >= A.REFPERIODOVERDRAWN THEN 'Y'
         WHEN NVL(A.DPD_NOCREDIT, 0) >= A.REFPERIODNOCREDIT THEN 'Y'
         WHEN NVL(A.DPD_OVERDUE, 0) >= A.REFPERIODOVERDUE THEN 'Y'
         WHEN NVL(A.DPD_STOCKSTMT, 0) >= A.REFPERIODSTKSTATEMENT THEN 'Y'
         WHEN NVL(A.DPD_RENEWAL, 0) >= A.REFPERIODREVIEW THEN 'Y'
         ELSE 'N'
            END) AS FLGDEG
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( a.FinalAssetClassAlt_Key IN ( SELECT AssetClassAlt_Key 
                                                FROM RBL_MISDB_PROD.DimAssetClass 
                                                 WHERE  AssetClassShortNameEnum IN ( 'STD' )

                                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                                          AND EffectiveToTimeKey >= v_TIMEKEY )
          )
           AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )
           AND ( B.FlgProcessing = 'N' )
           AND NVL(InMonthMark, 'N') = 'Y'
           AND NVL(B.FlgMoc, 'N') = 'N'
           AND NVL(A.Balance, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = src.FLGDEG;
         /* LOAN BUYOUT DPD CALCULATION */
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y', CASE 
         WHEN NVL(B.DPD_Seller, 0) >= A.REFPERIODOVERDUE THEN 'NPA Due to Virtual DPD'   END AS pos_3
         FROM GTT_ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID 
          WHERE NVL(A.DPD_OVERDUE, 0) >= A.REFPERIODOVERDUE
           AND A.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = 'Y',
                                      A.DegReason --------WHEN  PeakDPD>=A.REFPERIODOVERDUE THEN 'NPA due to Months Peak DPD'
                                       = pos_3;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y', 'NPA with Seller' AS pos_3, 'ALWYS_NPA'
         FROM GTT_ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID 
          WHERE B.NPA_ClassSeller = 'Y'
           AND A.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGDEG = 'Y',
                                      A.DegReason = pos_3,
                                      A.Asset_Norm = 'ALWYS_NPA';
         MERGE INTO MAIN_PRO.BuyoutUploadDetailsCal B
         USING (SELECT B.ROWID row_id, CASE 
         WHEN NVL(A.DPD_OVERDUE, 0) >= A.REFPERIODOVERDUE THEN 'NPA_VDPD'
         WHEN B.NPA_ClassSeller = 'Y' THEN 'NPA_SELLER'
         ELSE B.NPA_Flag
            END AS NPA_FLAG
         FROM GTT_ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID 
          WHERE NVL(A.DPD_OVERDUE, 0) >= A.REFPERIODOVERDUE
           AND A.FinalAssetClassAlt_Key = 1) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.NPA_FLAG = src.NPA_FLAG;
         /* END OF LOAN BUYOUT CODE */
         /* RESTRUCTURE DEGRADE */
         /* UPDATE DPD_Breach_Date FOR 'RESOLUTION'  */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, v_ProcessDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN GTT_ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE DPD_Breach_Date IS NULL
           AND D.ParameterShortNameEnum IN ( 'COVID_OTR_RF','COVID_OTR_RF_2' )

           AND ( ( FacilityType NOT IN ( 'CC','OD' )

           AND NVL(DPD_MaxFin, 0) > 30 )
           OR ( FacilityType IN ( 'CC','OD' )

           AND NVL(B.DPD_Overdrawn, 0) > 60 ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_Breach_Date = v_ProcessDate,
                                      A.ZeroDPD_Date = NULL,
                                      A.SP_ExpiryExtendedDate = NULL;
         /* update DPD_Breach_Date -  'MSME_OLD','MSME_COVID' */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, v_ProcessDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN GTT_ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE DPD_Breach_Date IS NULL
           AND D.ParameterShortNameEnum IN ( 'MSME_OLD','MSME_COVID','MSME_COVID_RF2' )

           AND ( NVL(DPD_MaxNonFin, 0) >= 90
           OR NVL(DPD_MaxFin, 0) > 30 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_Breach_Date = v_ProcessDate,
                                      A.ZeroDPD_Date = NULL,
                                      A.SP_ExpiryExtendedDate = NULL;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, v_ProcessDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN GTT_ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE DPD_Breach_Date IS NOT NULL
           AND D.ParameterShortNameEnum IN ( 'MSME_OLD','MSME_COVID','MSME_COVID_RF2' )

           AND ( NVL(DPD_MaxNonFin, 0) < 90
           AND NVL(DPD_MaxFin, 0) <= 30 )
           AND ZeroDPD_Date IS NULL
           AND (CASE 
                     WHEN NVL(SP_ExpiryDate, '1900-01-01') >= NVL(SP_ExpiryExtendedDate, '1900-01-01') THEN SP_ExpiryDate
         ELSE SP_ExpiryExtendedDate
            END) > v_ProcessDate) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ZeroDPD_Date = v_ProcessDate,
                                      A.DPD_Breach_Date = NULL;
         ----------------------------------------------------------------------------------------------------------------------------------------------
         ------------------------------------------------------------------------------------------------------------------------------------
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, utils.dateadd('YY', 1, ZeroDPD_Date) AS SP_ExpiryExtendedDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN GTT_ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE ZeroDPD_Date IS NOT NULL
           AND SP_ExpiryExtendedDate IS NULL
           AND D.ParameterShortNameEnum IN ( 'MSME_OLD','MSME_COVID','MSME_COVID_RF2' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate;
         /* update DPD_Breach_Date -  'PRUDENTIAL','IRAC','OTHER' */
         
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, v_ProcessDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN GTT_ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE DPD_Breach_Date IS NULL
           AND D.ParameterShortNameEnum IN ( 'PRUDENTIAL','IRAC','OTHER' )

           AND ( ( FacilityType NOT IN ( 'CC','OD' )

           AND NVL(DPD_MaxFin, 0) > 0 )
           OR ( ( FacilityType IN ( 'CC','OD' )

           AND ( NVL(DPD_MaxFin, 0) >= 30
           OR NVL(DPD_MaxNonFin, 0) >= 90 ) ) ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_Breach_Date = v_ProcessDate,
                                        A.ZeroDPD_Date = NULL,
                                        A.SP_ExpiryExtendedDate = NULL;
         /*  RESOLUTION  COVID- PERAONl AND OTHERS */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 'Y'
         , CASE 
         WHEN Res_POS_to_CurrentPOS_Per <= 30 THEN 'Restructured slippage'
         ELSE ' '
            END AS pos_3
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                JOIN RBL_MISDB_PROD.DimParameter E   ON E.EffectiveFromTimeKey <= v_timekey
                AND E.EffectiveToTimeKey >= v_timekey
                AND E.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key
                AND E.DimParameterName = 'Covid - OTR Category'
                JOIN GTT_ACCOUNTCAL ac   ON a.AccountEntityId = ac.AccountEntityID 
          WHERE D.ParameterShortNameEnum IN ( 'COVID_OTR_RF','OVID_OTR_RF_2' )

           AND A.FinalAssetClassAlt_Key = 1
           AND ( ( E.ParameterShortNameEnum = 'PERSONAL'
           AND ac.FlgDeg = 'Y' )
           OR ( E.ParameterShortNameEnum = 'OTHER'
           AND DPD_Breach_Date IS NOT NULL
           AND SP_ExpiryDate > v_ProcessDate ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgDeg = 'Y',
                                      A.DegReason = pos_3;
         /* 'MSME_OLD','MSME_COVID' */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                JOIN GTT_ACCOUNTCAL AC   ON A.AccountEntityId = AC.AccountEntityId
                AND ac.FlgDeg = 'Y' 
          WHERE D.DimParameterName = 'TypeofRestructuring'
           AND ParameterShortNameEnum IN ( 'MSME_OLD','MSME_COVID','MSME_COVID_RF2' )

           AND A.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgDeg= 'Y';
         
         /*  'IRAC' ,'OTHER','PRUDENTIAL' */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key 
          WHERE D.DimParameterName = 'TypeofRestructuring'
           AND ParameterShortNameEnum IN ( 'IRAC','OTHER','PRUDENTIAL' )

           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgDeg= 'Y';

         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.FlgDeg
         FROM GTT_ACCOUNTCAL A
                JOIN MAIN_PRO.AdvAcRestructureCal B   ON A.AccountEntityID = B.AccountEntityId 
          WHERE B.FlgDeg = 'Y'
           AND a.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgDeg= src.FlgDeg;
         ---FinnalDCCO_Date   - Original DCCO, CIO DCCO and FreshDCCO
         v_DysOfDelay:=90;
         MERGE INTO MAIN_PRO.PUI_CAL A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN ( utils.datediff('DD', FinnalDCCO_Date, v_ProcessDate) > v_DysOfDelay
           AND RevisedDCCO IS NULL ) THEN 'Original DCCO/ CIO_DCCO is Crossed'
         WHEN ( FinnalDCCO_Date < v_ProcessDate
           AND RevisedDCCO IS NOT NULL
           AND utils.datediff('DD', RevisedDCCO, v_ProcessDate) > 90 ) THEN 'Revised DCCO is crossed'
         WHEN ( RevisedDCCO IS NOT NULL
           AND CostOverrun = 'Y'
           AND ( ( NVL(CostOverRunPer, 0) > 10 )
           OR ( NVL(RevisedDebt, 0) > NVL(OriginalDebt, 0) ) )
           AND ( utils.dateadd('YY', (CASE 
                                           WHEN ProjCategory = 'Infra' THEN 2
                               ELSE 1
                                  END), FinnalDCCO_Date) > RevisedDCCO
           AND utils.dateadd('YY', (CASE 
                                         WHEN ProjCategory = 'Infra' THEN 4
                             ELSE 2
                                END), FinnalDCCO_Date) < RevisedDCCO ) ) THEN 'Cost Overrun or Revised DE Ratio is more than Permissible Limits'
         WHEN ( TakeOutFinance = 'Y'
           AND AssetClassSellerBookAlt_key > 1 ) THEN 'The account is NPA in sellers book'   END AS DEFAULT_REASON
         FROM MAIN_PRO.PUI_CAL A 
          WHERE FinalAssetClassAlt_Key = 1
           AND ActualDCCO_Date IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET DEFAULT_REASON /* 1. The original DCCO or CIO_DCCO whichever is higher is passed more than -90- days and revised DCCO is blank and Actual DCCO is blank. The NPA reason in this case will be “Original DCCO/ CIO_DCCO is Crossed” (Put case to find which date is applicable)*/ /*2. Original DCCO is passed and revised DCCO is also passed more than -90 days and Actual DCCO is blank. The NPA reason in this case will be “Revised DCCO is crossed” */ /*3. In case of Revised DCCO is not blank and Cost Overrun % is more than 10% or Revised DE ratio is higher than Original DE ratio, the NPA Reason in this case would be “Cost Overrun or Revised DE Ration is more than Permissible Limits”   */
                                      -- add condition for infra 2/4 and non infra 1/2 yr and non 
                                       = src.DEFAULT_REASON;
         MERGE INTO MAIN_PRO.PUI_CAL A 
         USING (SELECT A.ROWID row_id, 'Y', v_ProcessDate
         FROM MAIN_PRO.PUI_CAL A 
          WHERE ( BeyonControlofPromoters = 'Y'
           OR CourtCaseArbitration = 'Y' )
           AND RevisedDCCO <= utils.dateadd('YY', (CASE 
                                                        WHEN ProjCategory = 'Infra' THEN 2
                                            ELSE 1
                                               END), FinnalDCCO_Date)) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET RESTRUCTURING = 'Y',
                                      RestructureDate = v_ProcessDate;
         MERGE INTO MAIN_PRO.PUI_CAL A 
         USING (SELECT A.ROWID row_id, 'Y', v_ProcessDate
         FROM MAIN_PRO.PUI_CAL A 
          WHERE NVL(DEFAULT_REASON, ' ') <> ' ') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLG_DEG = 'Y',
                                      A.NPA_DATE = v_ProcessDate;
         /* END  OF PUI WORK*/
         /* ------------------------UPDATE DEG FLAG AT CUSTOMER LEVEL----------------------------------*/
         MERGE INTO GTT_CUSTOMERCAL B  
         USING (SELECT B.ROWID row_id, 'Y'
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE A.FlgDeg = 'Y'
           AND ( B.FlgProcessing = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FlgDeg = 'Y';
         /*---------------------ASSIGNE DEG REASON------------------------------------------------------*/
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.DegReason, ' ') || 'DEGRADE BY INT NOT SERVICED' AS DegReason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'Y'
           AND ( A.DPD_INTSERVICE >= A.REFPERIODINTSERVICE ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.DegReason, ' ') || ', DEGRADE BY CONTI EXCESS' AS DegReason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'Y'
           AND A.DPD_OVERDRAWN >= A.REFPERIODOVERDRAWN )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.DegReason, ' ') || ', DEGRADE BY NO CREDIT' AS DegReason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'Y'
           AND A.DPD_NOCREDIT >= A.REFPERIODNOCREDIT )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.DegReason, ' ') || ', DEGRADE BY STOCK STATEMENT' AS DegReason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'Y'
           AND A.DPD_STOCKSTMT >= A.REFPERIODSTKSTATEMENT )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.DEGREASON, ' ') || ', DEGRADE BY REVIEW DUE DATE' AS DEGREASON
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'Y'
           AND A.DPD_RENEWAL >= A.REFPERIODREVIEW )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(A.DegReason, ' ') || ', DEGRADE BY OVERDUE' AS DegReason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'Y'
           AND A.DPD_OVERDUE >= A.REFPERIODOVERDUE )
           AND NVL(a.DegReason, ' ') NOT LIKE '%NPA Due to Virtual DPD%'
           AND NVL(A.DegReason, ' ') NOT LIKE '%NPA with Seller%') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;-- Buyout changes
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.DegReason
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'N' )
           AND B.DegReason IS NOT NULL
           AND A.FinalAssetClassAlt_Key > 1
           AND A.DegReason IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Marking_FlgDeg_Degreason';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      -----------------Added for DashBoard 04-03-2021
      V_SQLERRM:=SQLERRM;
      
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Marking_FlgDeg_Degreason';

   END;END;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."MARKING_FLGDEG_DEGREASON" TO "ADF_CDR_RBL_STGDB";
