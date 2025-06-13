--------------------------------------------------------
--  DDL for Procedure ACLMAINRUNPROCESSFORDUMMY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."ACLMAINRUNPROCESSFORDUMMY" 
(
  v_Date IN VARCHAR2,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
AS
   v_TimeKey NUMBER(10,0);
   v_ProcessingDate VARCHAR2(200);
   v_PROCESSMONTH VARCHAR2(200) ;

BEGIN
     SELECT TimeKey INTO v_TimeKey
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = CASE 
                                                       WHEN NVL(v_Date, ' ') = ' ' THEN '2020-09-30'
           ELSE UTILS.CONVERT_TO_VARCHAR2(v_Date,200)
              END ;
    SELECT DATE_ INTO v_ProcessingDate
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY ;
   SELECT date_ INTO v_PROCESSMONTH 
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  TimeKey = v_TIMEKEY ;

   ----------------
   UPDATE RBL_MISDB_PROD.Automate_Advances
      SET EXT_FLG = 'N'
    WHERE  EXT_FLG = 'Y';
   UPDATE RBL_MISDB_PROD.Automate_Advances
      SET EXT_FLG = 'Y'
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(v_Date,200);
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET EffectiveFromTimeKey = v_TimeKey,
          EffectiveToTimekey = v_TimeKey;
   UPDATE MAIN_PRO.CUSTOMERCAL
      SET EffectiveFromTimeKey = v_TimeKey,
          EffectiveToTimekey = v_TimeKey;
   ------------
   UPDATE MAIN_PRO.AclRunningProcessStatus
      SET Completed = 'N'
    WHERE  id > 1;
   UPDATE MAIN_PRO.CUSTOMERCAL
      SET ASSET_NORM = 'NORMAL';
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET ASSET_NORM = 'NORMAL';
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET UpgDate = NULL;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
   WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
   ELSE FinalNpaDt
      END AS pos_4, 'NPA DUE TO Inherent Weakness Account' AS pos_5, 'Y'
   FROM MAIN_PRO.ACCOUNTCAL A 
    WHERE A.WeakAccount = 'Y'
     AND FinalAssetClassAlt_Key = 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.FinalAssetClassAlt_Key = 2,
                                A.FinalNpaDt = pos_4,
                                A.NPA_Reason = pos_5,
                                A.WeakAccount = 'Y';
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
   --,A.FinalAssetClassAlt_Key=2
    --,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
   , 'NPA DUE TO Inherent Weakness Account' AS pos_3, 'Y'
   FROM MAIN_PRO.ACCOUNTCAL A 
    WHERE A.WeakAccount = 'Y'
     AND FinalAssetClassAlt_Key > 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.NPA_Reason = pos_3,
                                A.WeakAccount = 'Y';
   MERGE INTO MAIN_PRO.CUSTOMERCAL A
   USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
   FROM MAIN_PRO.CUSTOMERCAL a
          JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
    WHERE b.WeakAccount = 'Y') src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                a.SysNPA_Dt = src.FinalNpaDt,
                                a.DegReason = src.NPA_Reason,
                                a.Asset_Norm = src.Asset_Norm;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A 
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
   WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
   ELSE FinalNpaDt
      END AS pos_4, 'NPA DUE TO SARFAESI  Account' AS pos_5
   FROM MAIN_PRO.ACCOUNTCAL A 
    WHERE A.Sarfaesi = 'Y'
     AND FinalAssetClassAlt_Key = 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.FinalAssetClassAlt_Key = 2,
                                A.FinalNpaDt = pos_4,
                                A.NPA_Reason = pos_5;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A 
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
   --  ,A.FinalAssetClassAlt_Key=2
    --,A.FinalNpaDt=CASE WHEN FinalNpaDt is NULL then @PROCESSINGDATE else  FinalNpaDt end
   , 'NPA DUE TO SARFAESI  Account' AS pos_3
   FROM MAIN_PRO.ACCOUNTCAL A 
    WHERE A.Sarfaesi = 'Y'
     AND FinalAssetClassAlt_Key > 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.NPA_Reason = pos_3;
   MERGE INTO MAIN_PRO.CUSTOMERCAL a
   USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
   FROM MAIN_PRO.CUSTOMERCAL a
          JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
    WHERE b.Sarfaesi = 'Y') src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                a.SysNPA_Dt = src.FinalNpaDt,
                                a.DegReason = src.NPA_Reason,
                                a.Asset_Norm = src.Asset_Norm;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
   WHEN REPOSSESSIONDATE IS NULL THEN v_PROCESSINGDATE
   ELSE REPOSSESSIONDATE
      END AS pos_4, 'NPA DUE TO RePossession  Account' AS pos_5
   FROM MAIN_PRO.ACCOUNTCAL A 
    WHERE A.RePossession = 'Y'
     AND FinalAssetClassAlt_Key = 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.FinalAssetClassAlt_Key = 2,
                                A.FinalNpaDt = pos_4,
                                A.NPA_Reason = pos_5;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A 
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
   -- ,A.FinalAssetClassAlt_Key=2
    --,A.FinalNpaDt=CASE WHEN REPOSSESSIONDATE is NULL then @PROCESSINGDATE else  REPOSSESSIONDATE end
   , 'NPA DUE TO RePossession  Account' AS pos_3
   FROM MAIN_PRO.ACCOUNTCAL A 
    WHERE A.RePossession = 'Y'
     AND FinalAssetClassAlt_Key > 1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.NPA_Reason = pos_3;
   MERGE INTO MAIN_PRO.CUSTOMERCAL a
   USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
   FROM MAIN_PRO.CUSTOMERCAL a
          JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
    WHERE b.RePossession = 'Y') src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                a.SysNPA_Dt = src.FinalNpaDt,
                                a.DegReason = src.NPA_Reason,
                                a.Asset_Norm = src.Asset_Norm;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 6, CASE 
   WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
   ELSE FinalNpaDt
      END AS pos_4, 'NPA DUE TO FRAUD MARKING' AS pos_5
   FROM MAIN_PRO.ACCOUNTCAL A
          JOIN MAIN_PRO.CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
    WHERE A.SplCatg1Alt_Key = 870) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.FinalAssetClassAlt_Key = 6,
                                A.FinalNpaDt = pos_4,
                                A.NPA_Reason = pos_5;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 6, CASE 
   WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
   ELSE FinalNpaDt
      END AS pos_4, 'NPA DUE TO FRAUD MARKING' AS pos_5, 870
   FROM MAIN_PRO.ACCOUNTCAL A
          JOIN MAIN_PRO.CUSTOMERCAL B   ON A.RefCustomerID = B.RefCustomerID 
    WHERE B.SplCatg1Alt_Key = 870) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                A.FinalAssetClassAlt_Key = 6,
                                A.FinalNpaDt = pos_4,
                                A.NPA_Reason = pos_5,
                                A.SplCatg1Alt_Key = 870;
   MERGE INTO MAIN_PRO.CUSTOMERCAL a
   USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
   FROM MAIN_PRO.CUSTOMERCAL a
          JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
    WHERE B.SplCatg1Alt_Key = 870) src
   ON ( a.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                a.SysNPA_Dt = src.FinalNpaDt,
                                a.DegReason = src.NPA_Reason,
                                a.Asset_Norm = src.Asset_Norm;
   MERGE INTO MAIN_PRO.ACCOUNTCAL B 
   USING (SELECT B.ROWID row_id, 'S'
   FROM MAIN_PRO.CUSTOMERCAL A
          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
    WHERE NVL(CurntQtrRv, 0) > 0) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET SecApp = 'S';
   MERGE INTO MAIN_PRO.ACCOUNTCAL B
   USING (SELECT B.ROWID row_id, 'D'
   FROM MAIN_PRO.CUSTOMERCAL A
          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID 
    WHERE NVL(CurntQtrRv, 0) > 0) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET FlgSecured = 'D';
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'D'
   FROM MAIN_PRO.ACCOUNTCAL  A
    WHERE A.securityvalue > 0) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET FlgSecured = 'D';
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET NETBALANCE = BALANCE;

 
      MERGE INTO MAIN_PRO.ACCOUNTCAL A
      USING (SELECT D.ROWID row_id, CASE 
      WHEN ((D.NETBALANCE / A.TOTOSFUNDED) * b.CurntQtrRv) > D.NETBALANCE THEN D.NETBALANCE
      ELSE ((D.NETBALANCE / A.TOTOSFUNDED) * b.CurntQtrRv)
         END AS SecurityValue
      FROM ( SELECT B.REFCUSTOMERID ,
                                        SUM(NVL(A.BALANCE, 0))  TOTOSFUNDED  
            FROM MAIN_PRO.ACCOUNTCAL A
            JOIN MAIN_PRO.CUSTOMERCAL B   ON A.CUSTOMERENTITYID = B.CUSTOMERENTITYID
            WHERE  A.BALANCE > 0
             AND b.CurntQtrRv > 0
            GROUP BY B.REFCUSTOMERID ) A
            JOIN MAIN_PRO.CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID
             JOIN MAIN_PRO.ACCOUNTCAL D   ON D.RefCustomerID = B.RefCustomerID 
       WHERE b.CurntQtrRv > 0) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.SecurityValue = src.SecurityValue
      ;
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET InttServiced = 'Y',
          INTNOTSERVICEDDT = NULL;
   IF ( v_PROCESSMONTH = LAST_DAY(v_PROCESSMONTH) ) THEN

   BEGIN
      MERGE INTO MAIN_PRO.ACCOUNTCAL A
      USING (SELECT A.ROWID row_id, 'N', utils.dateadd('DAY', -90, v_PROCESSINGDATE) AS pos_3
      FROM MAIN_PRO.ACCOUNTCAL A
             JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key 
       WHERE NVL(A.Balance, 0) > 0
        AND NVL(A.CurQtrCredit, 0) < NVL(A.CurQtrInt, 0)
        AND A.FacilityType IN ( 'CC','OD' )

        AND ( utils.dateadd('DAY', 90, A.FirstDtOfDisb) < v_PROCESSINGDATE
        AND A.FirstDtOfDisb IS NOT NULL
        AND Asset_Norm <> 'ALWYS_STD' )
        AND C.EffectiveFromTimeKey <= v_timekey
        AND C.EffectiveToTimeKey >= v_timekey
        AND NVL(C.ProductSubGroup, 'N') NOT IN ( 'Agri Busi','Agri TL','KCC' )
      ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                   A.INTNOTSERVICEDDT = pos_3;
      MERGE INTO MAIN_PRO.ACCOUNTCAL A
      USING (SELECT A.ROWID row_id, 'N', NULL
      FROM MAIN_PRO.ACCOUNTCAL A
             JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key 
       WHERE A.FacilityType IN ( 'CC','OD' )

        AND ( utils.dateadd('DAY', 90, A.DebitSinceDt) > v_PROCESSINGDATE
        AND A.DebitSinceDt IS NOT NULL
        AND Asset_Norm <> 'ALWYS_STD' )
        AND C.EffectiveFromTimeKey <= v_timekey
        AND C.EffectiveToTimeKey >= v_timekey
        AND NVL(C.ProductSubGroup, 'N') NOT IN ( 'Agri Busi','Agri TL','KCC' )

        AND InttServiced = 'N') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                   INTNOTSERVICEDDT = NULL;

   END;
   END IF;
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, 'N', utils.dateadd('DAY', -366, v_PROCESSINGDATE) AS pos_3
   FROM MAIN_PRO.ACCOUNTCAL A
          JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key 
    WHERE NVL(A.Balance, 0) > 0
     AND NVL(A.CurQtrCredit, 0) < NVL(A.CurQtrInt, 0)

     --AND  FacilityType IN('CC','OD')
     AND utils.dateadd('DAY', 90, A.FirstDtOfDisb) < v_PROCESSINGDATE
     AND A.FirstDtOfDisb IS NOT NULL
     AND Asset_Norm <> 'ALWYS_STD'

     --AND DATEADD(DAY,90,A.DebitSinceDt)<@PROCESSINGDATE AND A.DebitSinceDt IS NOT NULL AND Asset_Norm<>'ALWYS_STD' 
     AND C.EffectiveFromTimeKey <= v_timekey
     AND C.EffectiveToTimeKey >= v_timekey
     AND NVL(C.ProductSubGroup, 'N') IN ( 'Agri Busi','Agri TL','KCC' )
   ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                A.INTNOTSERVICEDDT = pos_3;
   MAIN_PRO.Reference_Period_Calculation(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.DPD_Calculation(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Marking_InMonthMark_Customer_Account_level(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Marking_FlgDeg_Degreason(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.MaxDPD_ReferencePeriod_Calculation(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.NPA_Date_Calculation(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Update_AssetClass(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.NPA_Erosion_Aging(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Final_AssetClass_Npadate(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Upgrade_Customer_Account(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.SMA_MARKING(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Marking_FlgPNPA(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.Marking_NPA_Reason_NPAAccount(v_TIMEKEY => v_TimeKey) ;
   MAIN_PRO.UpdateProvisionKey_AccountWise(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.UpdateNetBalance_AccountWise(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.GovtGuarAppropriation(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.SecurityAppropriation(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.UpdateUsedRV(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.ProvisionComputationSecuredAcctProvWork(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.ProvisionComputationSecured(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.GovtGurCoverAmount(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.UpdationProvisionComputationUnSecured(v_TimeKey => v_TimeKey) ;
   MAIN_PRO.UpdationTotalProvision(v_TimeKey => v_TimeKey) ;
   v_Result := 1 ;
   

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
