--------------------------------------------------------
--  DDL for Procedure PROVISIONCOMPUTATIONSECUREDACCTPROVWORK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" /*=====================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : ProvisionComputationSecuredAcctProvWork 
EXEC pro.ProvisionComputationSecuredAcctProvWork  @TIMEKEY=25410 
====================================*/
(
  v_TimeKey IN NUMBER
)
AS
   v_ProcDate VARCHAR2(200) ;

BEGIN

    SELECT date_ INTO v_ProcDate
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  timekey = v_timekey ;
    
   DELETE FROM GTT_AcctProvWork;
   UTILS.IDENTITY_RESET('GTT_AcctProvWork');

   INSERT INTO GTT_AcctProvWork ( 
   	SELECT --a.RefCustomerID, a.CustomerAcId,AssetClassAlt_Key,FinalAssetClassAlt_Key,AssetClassShortName,DPD_MAX,C.LowerDPD,C.UpperDPD, c.ProvisionSecured,c.ProvisionUnSecured,c.ProvisionAlt_Key, ProvisionRule  ProvSource
   	 A.CustomerEntityID ,
     A.RefCustomerID CustomerId  ,
     A.AccountEntityID ,
     a.CustomerAcID AccountId  ,
     FinalNpaDt ,
     c.ProvisionAlt_Key BankProvAlt_Key  ,
     DPD_Max CurrDPD  ,
     c.ProvisionName CurrOverdueBucket  ,
     C.ProvisionSecured CurrDayProv  ,
     0 PrevDayDPD  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) PrevDayProv  ,
     UTILS.CONVERT_TO_VARCHAR2(' ',30) PrevOverdueBucket  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) HighestOverdueProv  ,
     UTILS.CONVERT_TO_VARCHAR2(' ',15) NPA_Ageing  ,
     AssetClassShortName AssetClass  ,
     15 NPA_AgeingBasedCurrDayProv  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) HeighestFromOvrdueBucket  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) CustLevelNPA_Prov  ,
     'N' PaymentPending  ,
     --,RCPending WheelCase
     A.WheelCase WheelCase  ,
     RePossession RepoFlagging  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) NoPaymentProv  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) AccountLevel  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) CustomerLevel  ,
     RCPending RC_PendingAboveOneYr  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) AddlProv  ,
     UTILS.CONVERT_TO_NUMBER(0.00,5,2) FinalProv  ,
     FirstDtOfDisb ,
     A.LastCrDate LastCrDt  ,
     A.UcifEntityID ,
     CUST.PANNO 
   	  FROM MAIN_PRO.ACCOUNTCAL A
             JOIN RBL_MISDB_PROD.DimAssetClass B   ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
             AND B.EffectiveFromTimeKey <= v_timekey
             AND B.EffectiveToTimeKey >= v_timekey
             AND a.EffectiveFromTimeKey <= v_timekey
             AND a.EffectiveToTimeKey >= v_timekey
             JOIN MAIN_PRO.CUSTOMERCAL CUST --- ADED THIS JOIN FOR SELECT panno - 01062021
              ON CUST.CustomerEntityID = A.CustomerEntityID
             JOIN RBL_MISDB_PROD.DimProvision_Seg C   ON C.EffectiveFromTimeKey <= v_timekey
             AND C.EffectiveToTimeKey >= v_timekey
             AND A.DPD_Max BETWEEN C.LowerDPD AND C.UpperDPD
             AND B.AssetClassShortName = C.Segment

   	----LEFT JOIN RBL_MISDB_PROD.DimProvision_Seg D

   	----	ON d.EffectiveFromTimeKey <=@timekey AND C.EffectiveToTimeKey>=@timekey

   	----	and d.ProvisionAlt_Key=a.ProvisionAlt_Key
   	WHERE  C.ProvisionRule = 'DPD BASED' );
   --and RefCustomerID in('150003737','150040054')
   /* UPDATE GTT_AcctProvWork MAX ON CUSTOMER LEVEL  01-06-2021 */
   MERGE INTO GTT_AcctProvWork A
   USING (SELECT A.ROWID row_id, B.LastCrDt
   FROM GTT_AcctProvWork A
          JOIN ( SELECT GTT_AcctProvWork.CustomerEntityID ,
                        MAX(GTT_AcctProvWork.LastCrDt)  LastCrDt  
                 FROM GTT_AcctProvWork 
                   GROUP BY GTT_AcctProvWork.CustomerEntityID ) B   ON A.CustomerEntityID = B.CustomerEntityID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.LastCrDt = src.LastCrDt;
   /* UPDATE  PREV DAY PROVISION, DPD AND BUCKET */
   MERGE INTO GTT_AcctProvWork A
   USING (SELECT A.ROWID row_id, b.CustomerLevelMaxPer, c.ProvisionName
   FROM GTT_AcctProvWork a
          JOIN MAIN_PRO.AccountCal_Hist b   ON a.AccountId = b.CustomerAcId
          AND b.EffectiveFromTimeKey <= v_timekey - 1
          AND b.EffectiveToTimeKey >= v_timekey - 1
          JOIN RBL_MISDB_PROD.DimProvision_Seg C   ON b.ProvisionAlt_Key = c.ProvisionAlt_Key
          AND C.EffectiveFromTimeKey <= v_timekey - 1
          AND C.EffectiveToTimeKey >= v_timekey - 1 ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET ---PrevDayDPD=DPD_Max
    A.PrevDayProv = src.CustomerLevelMaxPer,
    A.PrevOverdueBucket = src.ProvisionName;
   /* Highest from Overdue Bucket and last Final Provisio %  */
   MERGE INTO GTT_AcctProvWork a
   USING (SELECT A.ROWID row_id, UTILS.CONVERT_TO_NUMBER(CASE 
   WHEN NVL(CurrDayProv, 0) > NVL(PrevDayProv, 0) THEN NVL(CurrDayProv, 0)
   ELSE NVL(PrevDayProv, 0)
      END,5,2) AS HighestOverdueProv
   FROM GTT_AcctProvWork a ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.HighestOverdueProv = src.HighestOverdueProv;
   --select * FROM GTT_AcctProvWork where AccountEntityID=2 
   /*Step -4  Highest from Overdue Bucket and last Final Provisio %  */
   MERGE INTO GTT_AcctProvWork A
   USING (SELECT A.ROWID row_id, UTILS.CONVERT_TO_NUMBER(CASE 
   WHEN NVL(HighestOverdueProv, 0) > NVL(NPA_AgeingBasedCurrDayProv, 0) THEN NVL(HighestOverdueProv, 0)
   ELSE NVL(NPA_AgeingBasedCurrDayProv, 0)
      END,5,2) AS HeighestFromOvrdueBucket
   FROM GTT_AcctProvWork A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.HeighestFromOvrdueBucket = src.HeighestFromOvrdueBucket;
   /*sTEP 5 Highest Customer Level NPA Provision till Step 5   */
   
      MERGE INTO GTT_AcctProvWork a
      USING (SELECT A.ROWID row_id, B.CustLevelNPA_Prov
      FROM GTT_AcctProvWork a
             JOIN ( SELECT CustomerEntityID ,
                                            MAX(HeighestFromOvrdueBucket)  CustLevelNPA_Prov  
                    FROM GTT_AcctProvWork 
                    GROUP BY CustomerEntityID ) B   
                ON A.CustomerEntityID = B.CustomerEntityID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.CustLevelNPA_Prov = src.CustLevelNPA_Prov
      ;
   /* Update No Payment Flag/6 Months No Paymment */
   ---DECLARE @ProcDate DATE='2021-02-28'
   MERGE INTO GTT_AcctProvWork A
   USING (SELECT A.ROWID row_id, 'Y'
   FROM GTT_AcctProvWork a
          JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
          AND B.EffectiveFromTimeKey <= v_timekey
          AND B.EffectiveToTimeKey >= v_timekey
          JOIN MAIN_PRO.ACCOUNTCAL C   ON C.AccountEntityID = B.AccountEntityId
          AND C.EffectiveFromTimeKey <= v_timekey
          AND C.EffectiveToTimeKey >= v_timekey 
    WHERE A.LastCrDt > A.FinalNpaDt
     AND A.LastCrDt < utils.dateadd('MM', -6, v_ProcDate)
     AND C.FinalAssetClassAlt_Key = 3

     --And ISNULL(C.RCPending,'N')<>'Y'    
     AND NVL(A.RepoFlagging, 'N') <> 'Y') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.PaymentPending = 'Y';
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, B.PaymentPending
   FROM MAIN_PRO.ACCOUNTCAL A
          JOIN GTT_AcctProvWork B   ON A.AccountEntityID = B.AccountEntityID 
    WHERE B.PaymentPending = 'Y') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.PaymentPending = src.PaymentPending;
   /* update no payment provision */
  /* WITH CTE_NOPAYMENT AS ( SELECT CustomerEntityID 
     FROM GTT_AcctProvWork 
    WHERE  PaymentPending = 'N'
     GROUP BY CustomerEntityID ),
   CTE_REPO AS ( SELECT CustomerEntityID 
     FROM GTT_AcctProvWork 
    WHERE  RepoFlagging = 'Y'
     GROUP BY CustomerEntityID ) 
     */
      MERGE INTO GTT_AcctProvWork A
      USING (SELECT A.ROWID row_id, B.ProvisionSecured
      FROM GTT_AcctProvWork A
             JOIN RBL_MISDB_PROD.DimProvision_Seg B   ON B.SEGMENT = 'Excep'
             AND PaymentPending = (CASE 
                                        WHEN B.ProvisionShortNameEnum = 'NO-PAYMENT' THEN 'Y'   END)
             LEFT JOIN ( SELECT CustomerEntityID 
                         FROM GTT_AcctProvWork 
                        WHERE  PaymentPending = 'N'
                    GROUP BY CustomerEntityID ) C   
                ON C.CustomerEntityID = A.CustomerEntityID
             LEFT JOIN ( SELECT CustomerEntityID 
                         FROM GTT_AcctProvWork 
                        WHERE  PaymentPending = 'N'
                    GROUP BY CustomerEntityID )D
                ON D.CustomerEntityID = A.CustomerEntityID 
       WHERE C.CustomerEntityID IS NULL
        AND D.CustomerEntityID IS NULL) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET NoPaymentProv = src.ProvisionSecured
      ;
   /* STEP 6 -  Loan Level Max % %  */
   MERGE INTO GTT_AcctProvWork a 
   USING (SELECT A.ROWID row_id, UTILS.CONVERT_TO_NUMBER(CASE 
   WHEN NVL(CustLevelNPA_Prov, 0) > NVL(NoPaymentProv, 0) THEN NVL(CustLevelNPA_Prov, 0)
   ELSE NVL(NoPaymentProv, 0)
      END,5,2) AS AccountLevel
   FROM GTT_AcctProvWork a ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.AccountLevel = src.AccountLevel;
   /*sTEP 7 Customer Level Max %   */

      MERGE INTO GTT_AcctProvWork a
      USING (SELECT A.ROWID row_id, B.CustomerLevel
      FROM GTT_AcctProvWork a
             JOIN ( SELECT CustomerEntityID ,
                        MAX(AccountLevel)  CustomerLevel  
                        FROM GTT_AcctProvWork 
                        GROUP BY CustomerEntityID )B   
            ON A.CustomerEntityID = B.CustomerEntityID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.CustomerLevel = src.CustomerLevel
      ;
   /* update Additional 30% Provision - for RC Pending*/
   MERGE INTO GTT_AcctProvWork a 
   USING (SELECT A.ROWID row_id, c.ProvisionSecured
   FROM GTT_AcctProvWork A
          JOIN RBL_MISDB_PROD.DimProvision_Seg C   ON C.SEGMENT = 'Excep'
          AND RC_PendingAboveOneYr = (CASE 
                                           WHEN C.ProvisionShortNameEnum = 'RC-PENDING' THEN 'Y'   END)

          --AND DateDiff(y,FirstDtOfDisb,@ProcDate)<1
          AND utils.datediff('YY', FirstDtOfDisb, v_ProcDate) > 1 ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET AddlProv = src.ProvisionSecured;
   /* update Final Provision */
   MERGE INTO GTT_AcctProvWork a 
   USING (SELECT A.ROWID row_id, NVL(AddlProv, 0) + NVL(CustomerLevel, 0) AS FinalProv
   FROM GTT_AcctProvWork A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET FinalProv = src.FinalProv;
   /* UPDATE FIINAL PROVO AS UCIF LEVEL -- 01062021 */
   MERGE INTO GTT_AcctProvWork a 
   USING (SELECT A.ROWID row_id, B.FinalProv
   FROM GTT_AcctProvWork A
          JOIN ( SELECT GTT_AcctProvWork.UcifEntityID ,
                        MAX(GTT_AcctProvWork.FinalProv)  FinalProv  
                 FROM GTT_AcctProvWork 
                   GROUP BY GTT_AcctProvWork.UcifEntityID ) B   ON A.UcifEntityID = B.UcifEntityID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FinalProv = src.FinalProv;
   /* UPDATE FIINAL PROVO AS PAN LEVEL -- 01062021 */
   MERGE INTO GTT_AcctProvWork a 
   USING (SELECT A.ROWID row_id, B.FinalProv
   FROM GTT_AcctProvWork A
          JOIN ( SELECT GTT_AcctProvWork.PANNO ,
                        MAX(GTT_AcctProvWork.FinalProv)  FinalProv  
                 FROM GTT_AcctProvWork 
                  WHERE  GTT_AcctProvWork.PANNO IS NOT NULL
                   GROUP BY GTT_AcctProvWork.PANNO ) B   ON A.PANNO = B.PANNO ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FinalProv = src.FinalProv;
   /* update DATA IN MAIN TABLE*/
   MERGE INTO MAIN_PRO.ACCOUNTCAL A
   USING (SELECT A.ROWID row_id, B.FinalProv, B.CustomerLevel
   FROM MAIN_PRO.ACCOUNTCAL A
          JOIN GTT_AcctProvWork B   ON A.AccountEntityID = B.AccountEntityID
          AND A.EffectiveFromTimeKey <= v_timekey
          AND A.EffectiveToTimeKey >= v_timekey ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FinalProvisionPer = src.FinalProv,
                                A.CustomerLevelMaxPer = src.CustomerLevel;
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET FinalProvisionPer = 100
    WHERE  FinalAssetClassAlt_Key = 6
     AND NVL(FinalProvisionPer, 0) = 0;
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET CustomerLevelMaxPer = 100
    WHERE  FinalAssetClassAlt_Key = 6
     AND NVL(CustomerLevelMaxPer, 0) = 0;
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET FinalProvisionPer = 100
    WHERE  NVL(FinalProvisionPer, 0) > 100;
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET CustomerLevelMaxPer = 100
    WHERE  NVL(CustomerLevelMaxPer, 0) > 100;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."PROVISIONCOMPUTATIONSECUREDACCTPROVWORK" TO "ADF_CDR_RBL_STGDB";
