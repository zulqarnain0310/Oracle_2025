--------------------------------------------------------
--  DDL for Procedure UPDATIONTOTALPROVISION_RESTR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" /*==============================          
Author : TRILOKI KHANNA   
CREATE DATE : 27-11-2019          
MODIFY DATE : 27-11-2019         
DESCRIPTION : UPDATE TOTAL PROVISION          
--EXEC [pro].[UpdationTotalProvision] @TimeKey =25410            
=========================================*/
(
  v_TimeKey IN NUMBER
)
AS

BEGIN
DECLARE v_SQLERRM VARCHAR(1000);
   BEGIN
      DECLARE
         v_vEffectivefrom NUMBER(10,0);
         v_vEffectiveto NUMBER(10,0);
         v_DATE VARCHAR2(200) ;

      BEGIN
      
      SELECT Date_ INTO v_DATE
           FROM RBL_MISDB_PROD.Automate_Advances 
          WHERE  EXT_FLG = 'Y' ;
      
         SELECT TimeKey 

           INTO v_vEffectiveFrom
           FROM RBL_MISDB_PROD.Automate_Advances 
          WHERE  EXT_FLG = 'Y';
         SELECT Timekey - 1 

           INTO v_vEffectiveto
           FROM RBL_MISDB_PROD.Automate_Advances 
          WHERE  EXT_FLG = 'Y';
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET TOTALPROVISION = 0,
                BANKTOTALPROVISION = 0,
                RBITOTALPROVISION = 0;
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET TOTPROVISION = 0,
                BANKTOTPROVISION = 0,
                RBITOTPROVISION = 0;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, (NVL(A.Provsecured, 0) + NVL(A.ProvUnsecured, 0) + (NVL(A.AddlProvision, 0)) + NVL(A.ProvCoverGovGur, 0) + NVL(A.ProvDFV, 0)) AS pos_2, (NVL(A.BankProvsecured, 0) + NVL(A.BankProvUnsecured, 0) + (NVL(A.AddlProvision, 0)) + NVL(A.ProvCoverGovGur, 0) + NVL(A.ProvDFV, 0)) AS pos_3, (NVL(A.RBIProvsecured, 0) + NVL(A.RBIProvUnsecured, 0) + (NVL(A.AddlProvision, 0)) + NVL(A.ProvCoverGovGur, 0) + NVL(A.ProvDFV, 0)) AS pos_4
         FROM MAIN_PRO.ACCOUNTCAL A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TOTALPROVISION = pos_2,
                                      BANKTOTALPROVISION = pos_3,
                                      RBITOTALPROVISION = pos_4;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET TOTALPROVISION = BALANCE
          WHERE  NVL(TOTALPROVISION, 0) > BALANCE
           AND NVL(BALANCE, 0) > 0;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET BANKTOTALPROVISION = BALANCE
          WHERE  NVL(BANKTOTALPROVISION, 0) > BALANCE
           AND NVL(BALANCE, 0) > 0;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET RBITOTALPROVISION = BALANCE
          WHERE  NVL(RBITOTALPROVISION, 0) > BALANCE
           AND NVL(BALANCE, 0) > 0;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, RBITOTALPROVISION, RBIPROVSECURED, RBIPROVUNSECURED, ADDLPROVISION, PROVCOVERGOVGUR, PROVDFV
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE NVL(A.RBITotalProvision, 0) > NVL(A.BankTotalProvision, 0)) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TOTALPROVISION = RBITOTALPROVISION,
                                      PROVSECURED = RBIPROVSECURED,
                                      PROVUNSECURED = RBIPROVUNSECURED,
                                      ADDLPROVISION = ADDLPROVISION,
                                      PROVCOVERGOVGUR = PROVCOVERGOVGUR,
                                      PROVDFV = PROVDFV;
         /* RESTRUCTURE PROV WORK */
         --Select * 
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, b.FinalAssetClassAlt_Key, B.InitialAssetClassAlt_Key, CASE 
         WHEN B.FinalAssetClassAlt_Key = 1 THEN SP.ProvisionSecured
         ELSE np.ProvisionSecured
            END AS pos_4, b.FinalNpaDt, A.RestructureStage || (CASE 
         WHEN B.FinalAssetClassAlt_Key > 1
           AND SUBSTR(RestructureStage, -3, 3) = 'STD' THEN '-NPA'
         WHEN B.FinalAssetClassAlt_Key = 1
           AND SUBSTR(RestructureStage, -3, 3) = 'NPA' THEN '-STD'
         ELSE ' '
            END) AS pos_6, CASE 
         WHEN B.UpgDate IS NOT NULL THEN B.UpgDate
         ELSE A.UpgradeDate
            END AS pos_7, CASE 
         WHEN B.UpgDate IS NOT NULL THEN utils.dateadd('YY', 1, b.UpgDate)
         ELSE CAST(A.SurvPeriodEndDate AS DATE)
            END AS pos_8
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                LEFT JOIN RBL_MISDB_PROD.DimProvision_SegStd SP   ON SP.EffectiveFromTimeKey <= v_TimeKey
                AND SP.EffectiveToTimeKey >= v_TimeKey
                AND SP.ProvisionAlt_Key = B.ProvisionAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimProvision_Seg NP   ON NP.EffectiveFromTimeKey <= v_TimeKey
                AND NP.EffectiveToTimeKey >= v_TimeKey
                AND NP.ProvisionAlt_Key = B.ProvisionAlt_Key 
          WHERE A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      A.InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                      A.AppliedNormalProvPer = pos_4,
                                      A.FinalNpaDt = src.FinalNpaDt,
                                      A.RestructureStage = pos_6,
                                      A.UpgradeDate = pos_7,
                                      A.SurvPeriodEndDate = pos_8;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 'STD-STD-NPA-STD' AS RestructureStage
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE RestructureStage = 'STD-STD-NPA-STD-NPA-STD') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RestructureStage = src.RestructureStage;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 'NPA-STD-NPA-STD' AS RestructureStage
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE RestructureStage = 'NPA-STD-NPA-STD-NPA-STD') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RestructureStage = src.RestructureStage;
         /* 1- RESOLUTION FRAMEWORK - CALCUCATE PROV  */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN NVL(PreRestructureAssetClassAlt_Key, 0) > 1 THEN NVL(PreRestructureNPA_Prov, 0)
         ELSE 10
            END) AS AddlProvPer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'COVID_OTR_RF','COVID_OTR_RF_2' )

          WHERE FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer = src.AddlProvPer;
         ---and RestructureStage in('NPA-STD','STD-STD') 
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN E.ParameterShortNameEnum = 'Personal' THEN CASE 
                                                              WHEN Res_POS_to_CurrentPOS_Per <= 30 THEN AddlProvPer / 2
         ELSE AddlProvPer
            END
         WHEN E.ParameterShortNameEnum = 'Other'
           AND SP_ExpiryDate < v_DATE THEN CASE 
                                                WHEN Res_POS_to_CurrentPOS_Per <= 30 THEN AddlProvPer / 2
         ELSE AddlProvPer
            END   END AS ProvReleasePer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'COVID_OTR_RF','COVID_OTR_RF_2' )

                JOIN RBL_MISDB_PROD.DimParameter E   ON E.EffectiveFromTimeKey <= v_timekey
                AND E.EffectiveToTimeKey >= v_timekey
                AND E.ParameterAlt_Key = A.COVID_OTR_CatgAlt_Key
                AND E.DimParameterName = 'Covid - OTR Category' 
          WHERE FinalAssetClassAlt_Key = 1
           AND NVL(Res_POS_to_CurrentPOS_Per, 0) >= 20) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvReleasePer --AND D.ParameterShortNameEnum ='COVID_OTR_RF'
                                       = src.ProvReleasePer;
         ---and RestructureStage in('NPA-STD','STD-STD') 
         /* 1- MSME_OLD AND MSME_COVID FRAMEWORK  */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN FinalAssetClassAlt_Key > 1 THEN 5
         WHEN A.FinalAssetClassAlt_Key = 1
           AND NVL(PreRestructureAssetClassAlt_Key, 0) > 1 THEN NVL(PreRestructureNPA_Prov, 0) + 5
         WHEN A.FinalAssetClassAlt_Key = 1
           AND NVL(PreRestructureAssetClassAlt_Key, 0) = 1 THEN (CASE 
                                                                      WHEN FlgMorat = 'Y' THEN 15
         ELSE 5
            END)   END) AS AddlProvPer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'MSME_COVID','MSME_OLD' )
               ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer -- CURRENT NPA
                                       -- CURRENT STD -PRE RESTR NPA
                                       -- CURRENT STD AND PRE RESTR NPA
                                       = src.AddlProvPer;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN A.FinalAssetClassAlt_Key = 1
           AND NVL(PreRestructureAssetClassAlt_Key, 0) > 1 THEN NVL(PreRestructureNPA_Prov, 0) + 10
         ELSE 10
            END) AS AddlProvPer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'MSME_COVID_RF2' )
               ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer -- CURRENT STD -PRE RESTR NPA
                                       = src.AddlProvPer;
         --UPDATE A SET
         --		AddlProvPer= (CASE WHEN ParameterShortNameEnum='MSME_COVID_RF2' THEN 10 ELSE 5 END )
         --					+(CASE WHEN  A.FinalAssetClassAlt_Key=1 AND isnull(PreRestructureAssetClassAlt_Key,0)>1 
         --							THEN isnull(PreRestructureNPA_Prov,0) 
         --						  WHEN  A.FinalAssetClassAlt_Key>1 
         --								THEN 0 --ppliedNormalProvPer
         --							ELSE 0 
         --						END)
         --FROM PRO.AdvAcRestructureCal A
         --INNER JOIN RBL_MISDB_PROD.DimParameter D ON D.EffectiveFromTimeKey <=@timekey AND D.EffectiveToTimeKey>=@timekey 
         --	AND D.ParameterAlt_Key=A.RestructureTypeAlt_Key
         --	AND D.DimParameterName='TypeofRestructuring' 
         --	AND d.ParameterShortNameEnum IN('MSME_COVID','MSME_OLD','MSME_COVID_RF2')
         ---WHERE --DPD_Breach_Date IS NULL OR DPD_Breach_Date>SP_ExpiryDate
         --FinalAssetClassAlt_Key=1
         /* RELEASE */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, AddlProvPer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'MSME_COVID','MSME_OLD' )

          WHERE ( DPD_Breach_Date IS NULL
           AND SP_ExpiryDate < v_DATE )
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvReleasePer = AddlProvPer;-----???
         ------/* MSME_COVID_RF2 */	
         ------UPDATE A SET
         ------		AddlProvPer=10 +isnull(AppliedNormalProvPer,0)
         ------FROM PRO.AdvAcRestructureCal A
         ------INNER JOIN RBL_MISDB_PROD.DimParameter D ON D.EffectiveFromTimeKey <=@timekey AND D.EffectiveToTimeKey>=@timekey 
         ------	AND D.ParameterAlt_Key=A.RestructureTypeAlt_Key
         ------	AND D.DimParameterName='TypeofRestructuring' 
         ------	AND d.ParameterShortNameEnum IN('MSME_COVID_RF2')
         /* RELASE MSME_COVID_RF2 */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, AddlProvPer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'MSME_COVID_RF2' )

          WHERE ( DPD_Breach_Date IS NULL
           AND SP_ExpiryDate < v_DATE )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvReleasePer = AddlProvPer;
         /* PRUDENTIAL */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 15
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'PRUDENTIAL' )

          WHERE ( ( DPD_Breach_Date IS NOT NULL
           AND SP_ExpiryDate >= v_DATE )
           OR POS_10PerPaidDate IS NULL )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer = 15;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 5
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'PRUDENTIAL' )

          WHERE SurvPeriodEndDate > v_DATE
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer = 5;
         /* IRAC / OTHER */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 5
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.ADVACRESTRUCTUREDETAIL B   ON B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                AND A.AccountEntityId = B.AccountEntityId
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum IN ( 'IRAC','OTHER' )

          WHERE FinalAssetClassAlt_Key = 1
           AND A.SurvPeriodEndDate IS NOT NULL
           AND A.SurvPeriodEndDate >= v_DATE) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer = 5;
         --??? DCCO  CONDITION
         /* CALCULATE FINAL PROVISION PERCENTAGE */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, (NVL(AddlProvPer, 0) - NVL(ProvReleasePer, 0)) - (CASE 
         WHEN ( NVL(D.ParameterShortNameEnum, ' ') = 'PRUDENTIAL'
           AND A.FinalAssetClassAlt_Key > 1 )
           OR ( NVL(D.ParameterShortNameEnum, ' ') IN ( 'MSME_COVID','MSME_OLD','MSME_COVID_RF2' )

           AND FinalAssetClassAlt_Key <> 1 ) THEN 0
         ELSE NVL(AppliedNormalProvPer, 0)
            END) AS FinalProvPer
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalProvPer = src.FinalProvPer;
         --UPDATE A SET FinalProvPer=(isnull(AddlProvPer,0)-isnull(ProvReleasePer,0))-ISNULL(AppliedNormalProvPer,0)
         --	FROM pro.AdvAcRestructureCal A
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 100
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE FinalProvPer >= 100) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FinalProvPer = 100;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 0
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE FinalProvPer <= 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FinalProvPer = 0;
         /* FOR RESTR FACILITY - FITL  THEN NO PROVISION WILL COMPUTED - AS PEPR EMAIL DTD 23-09-2021 OBS POINT MO.17(LAS OBS) IN ATTACHED EXCEL FILE */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureFacilityTypeAlt_Key
                AND D.DimParameterName = 'RestructureFacility'
                AND D.ParameterShortNameEnum = 'FITL' ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AddlProvPer = 0,
                                      A.ProvReleasePer = 0,
                                      A.FinalProvPer = 0;
         /*  CALCULATE RESTRUCTURE PROVISION */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, NVL(B.SecuredAmt, 0) * NVL((FinalProvPer), 0) / 100 AS pos_2, NVL(B.UnSecuredAmt, 0) * NVL((FinalProvPer), 0) / 100 AS pos_3
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND NVL(D.ParameterShortNameEnum, ' ') <> 'MSME_OLD' ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SecuredProvision = pos_2,
                                      A.UnSecuredProvision = pos_3;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, NVL(SecuredProvision, 0) + NVL(UnSecuredProvision, 0) AS RestructureProvision
         FROM MAIN_PRO.AdvAcRestructureCal A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RestructureProvision = src.RestructureProvision;
         /* IN CASE OF MSME OLD PROVISION CALCULATION ON CURRENT POS  */
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, NVL(RestructureProvision, 0) + NVL(A.CurrentPOS, 0) * NVL((FinalProvPer), 0) / 100 AS RestructureProvision
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND NVL(D.ParameterShortNameEnum, ' ') = 'MSME_OLD' ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RestructureProvision = src.RestructureProvision;
         /* ADD RESTRUCTURE PROVIISION IN TOTAL PROVIISION */
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(TotalProvision, 0) + NVL(RestructureProvision, 0) AS TotalProvision
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AdvAcRestructureCal B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvision = src.TotalProvision;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET TOTALPROVISION = NetBalance
          WHERE  NVL(TOTALPROVISION, 0) > NetBalance
           AND NVL(NetBalance, 0) > 0;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, 'N'
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_tIMEKEY
                AND D.EffectiveToTimeKey >= v_tIMEKEY
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND A.FlgDeg = 'Y' 
          WHERE D.DimParameterName = 'TypeofRestructuring'
           AND ParameterShortNameEnum NOT IN ( 'PRUDENTIAL','IRAC','OTHER' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgDeg = 'N';
         /* END OF RESTRUCTURE */
         /* PUI PROVISION WORK */
         /* PROVISION */
         MERGE INTO MAIN_PRO.PUI_CAL A
         USING (SELECT A.ROWID row_id, b.FinalAssetClassAlt_Key
         FROM MAIN_PRO.PUI_CAL A
                JOIN MAIN_PRO.ACCOUNTCAL b   ON a.AccountEntityId = b.AccountEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         MERGE INTO MAIN_PRO.PUI_CAL A
         USING (SELECT A.ROWID row_id, (5 - NVL(p.ProvisionSecured, 0)) AS PUI_ProvPer
         FROM MAIN_PRO.PUI_CAL A
                JOIN MAIN_PRO.ACCOUNTCAL b   ON a.AccountEntityId = b.AccountEntityID
                LEFT JOIN RBL_MISDB_PROD.DimProvision_SegStd p   ON ( p.EffectiveFromTimeKey <= v_TimeKey
                AND p.EffectiveToTimeKey >= v_TimeKey )
                AND P.ProvisionAlt_Key = b.ProvisionAlt_Key 
          WHERE RESTRUCTURING = 'Y'
           AND utils.dateadd('YY', 2, a.RestructureDate) >= v_DATE
           AND a.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET PUI_ProvPer = src.PUI_ProvPer;
         MERGE INTO MAIN_PRO.PUI_CAL A
         USING (SELECT A.ROWID row_id, NVL(B.SecuredAmt, 0) * NVL((PUI_ProvPer), 0) / 100 AS pos_2, NVL(B.UnSecuredAmt, 0) * NVL((PUI_ProvPer), 0) / 100 AS pos_3
         FROM MAIN_PRO.PUI_CAL A
                JOIN MAIN_PRO.ACCOUNTCAL b   ON a.AccountEntityId = b.AccountEntityID 
          WHERE NVL(PUI_ProvPer, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SecuredProvision = pos_2,
                                      A.UnSecuredProvision = pos_3;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(TotalProvision, 0) + (NVL(b.SecuredProvision, 0) + NVL(b.UnSecuredProvision, 0)) AS TotalProvision
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.PUI_CAL B   ON A.AccountEntityID = B.AccountEntityId 
          WHERE NVL(PUI_ProvPer, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvision = src.TotalProvision;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET TOTALPROVISION = NetBalance
          WHERE  NVL(TOTALPROVISION, 0) > NetBalance
           AND NVL(NetBalance, 0) > 0;
         /* END OF PUI PROV WORK */
         IF utils.object_id('TEMPDB..tt_TOTALPROVCUST_3') IS NOT NULL THEN
          ------DELETE  FROM  CURDAT.AdvCustNPAdetail WHERE EffectiveFromTimeKey<=@TIMEKEY and EffectiveToTimeKey>=@TIMEKEY
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TOTALPROVCUST_3 ';
         END IF;
         DELETE FROM tt_TOTALPROVCUST_3;
         UTILS.IDENTITY_RESET('tt_TOTALPROVCUST_3');

         INSERT INTO tt_TOTALPROVCUST_3 ( 
         	SELECT CUSTOMERENTITYID ,
                 SUM(NVL(TOTALPROVISION, 0))  TOTALPROVISION  ,
                 SUM(NVL(BANKTOTALPROVISION, 0))  BANKTOTPROVISION  ,
                 SUM(NVL(RBITOTALPROVISION, 0))  RBITOTPROVISION  
         	  FROM MAIN_PRO.ACCOUNTCAL 
         	  GROUP BY CUSTOMERENTITYID );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, B.TOTALPROVISION, B.BANKTOTPROVISION, B.RBITOTPROVISION
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN tt_TOTALPROVCUST_3 B   ON A.CustomerEntityID = B.CUSTOMERENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TOTPROVISION = src.TOTALPROVISION,
                                      A.BANKTOTPROVISION = src.BANKTOTPROVISION,
                                      A.RBITOTPROVISION = src.RBITOTPROVISION;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TOTALPROVCUST_3 ';
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'UpdationTotalProvision';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   v_SQLERRM:=SQLERRM;
      -----------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'UpdationTotalProvision';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATIONTOTALPROVISION_RESTR" TO "ADF_CDR_RBL_STGDB";
