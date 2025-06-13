--------------------------------------------------------
--  DDL for Procedure RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" 
(
  v_Timekey IN NUMBER
)
AS
   ------------------------
   v_cursor SYS_REFCURSOR;

BEGIN

   DECLARE
      --DECLARE @TIMEKEY INT = 26388
      v_ProcessDate VARCHAR2(200) := ( SELECT DATE_ 
        FROM SysDayMatrix 
       WHERE  TIMEKEY = v_TimeKey );
      v_CurrentDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(DATE_,200) 
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' );
      v_BackDtdProcess CHAR(1);
      v_CurQtrDate VARCHAR2(200);
      v_LastQtrDate VARCHAR2(200);
      v_LastToLastQtrDate VARCHAR2(200);
      v_LastToLastToLastQtrDate VARCHAR2(200);
   -----Acceleratede provision report
   --select * from SysDayMatrix where date='2022-03-31'

   BEGIN
      v_BackDtdProcess := CASE 
                               WHEN v_ProcessDate < v_CurrentDate THEN 'Y'
      ELSE 'N'
         END ;
      SELECT CurQtrDate ,
             LastQtrDate ,
             LastToLastQtrDate 

        INTO v_CurQtrDate,
             v_LastQtrDate,
             v_LastToLastQtrDate
        FROM SysDayMatrix 
       WHERE  TIMEKEY = v_TimeKey;
      v_LastToLastToLastQtrDate := EOMONTH(utils.dateadd('MM', -3, v_LastToLastQtrDate)) ;
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_ACCT_NPA_QTR_NO_REPORT_4  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_ACCT_NPA_QTR_NO_REPORT_4;
      UTILS.IDENTITY_RESET('tt_ACCT_NPA_QTR_NO_REPORT_4');

      INSERT INTO tt_ACCT_NPA_QTR_NO_REPORT_4 ( 
      	SELECT A.UcifEntityID ,
              A.CustomerEntityID ,
              A.AccountEntityID ,--,FinalAssetClassAlt_Key

              PROV.ProvisionAlt_Key ,
              ProvisionSecured ,
              ProvisionUnSecured ,
              Prov.Segment ,
              ProvisionRule ,
              LowerDPD ,
              UpperDPD ,
              CASE 
                   WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastQtrDate) AND v_CurQtrDate THEN 'Q1'
                   WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastQtrDate) AND v_LastQtrDate THEN 'Q2'
                   WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastToLastQtrDate) AND v_LastToLastQtrDate THEN 'Q3'
              ELSE 'Q4'
                 END NPA_QTR_NO  ,
              Seg.AcBuRevisedSegmentCode ,
              CASE 
                   WHEN SecApp = 'S' THEN 'Secured'
              ELSE 'UnSecured'
                 END SecuredUnsecured  ,
              A.SourceAlt_Key ,
              A.ActSegmentCode ,
              --,A.ProvisionAlt_Key
              A.ProductCode ,
              A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.RefCustomerID ,
              A.FacilityType ,
              A.FlgSecured ,
              A.FinalNpaDt ,
              A.REFPeriodMax NPA_Norms  ,
              A.SecuredAmt ,
              A.UnSecuredAmt ,
              A.NetBalance ,
              A.Provsecured ,
              A.ProvUnsecured ,
              A.AddlProvision ,
              A.TotalProvision ,
              A.AddlProvisionPer 
      	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                LEFT JOIN DimAcBuSegment SEG   ON SEG.AcBuSegmentCode = A.ActSegmentCode
                AND ( SEG.EffectiveFromTimeKey <= v_TimeKey
                AND SEG.EffectiveToTimeKey >= v_TimeKey )
                JOIN DimProvision_Seg prov   ON PROV.EffectiveFromTimeKey <= v_TimeKey
                AND Prov.EffectiveToTimeKey >= v_TimeKey
                AND Prov.ProvisionAlt_Key = A.ProvisionAlt_Key
      	 WHERE  FinalAssetClassAlt_Key > 1
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimekey >= v_TimeKey );
      DELETE FROM tt_ACCT_NPA_QTR_NO_Account_4;
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_ACCT_NPA_QTR_NO_Account_4  --SQLDEV: NOT RECOGNIZED
      --select * from tt_ACCT_NPA_QTR_NO_REPORT_4
      INSERT INTO tt_ACCT_NPA_QTR_NO_Account_4
        ( 
          --select * from tt_ACCT_NPA_QTR_NO_Account_4    
          SELECT B.AccountEntityId ,
                 CASE 
                      WHEN NVL(AdditionalProvAcct, 0) > 0 THEN 'ACCT'
                 ELSE 'CUSTUCIF'
                    END ProvTypes  
          FROM AcceleratedProvision A
                 JOIN AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID
                 AND b.EffectiveFromTimeKey <= v_TimeKey
                 AND b.EffectiveToTimeKey >= v_TimeKey
                 JOIN CustomerBasicDetail C   ON C.CustomerEntityId = B.CustomerEntityId
                 AND c.EffectiveFromTimeKey <= v_TimeKey
                 AND c.EffectiveToTimeKey >= v_TimeKey
                 JOIN tt_ACCT_NPA_QTR_NO_REPORT_4 D   ON D.AccountEntityID = b.AccountEntityId
           WHERE  EffectiveDate <= v_ProcessDate
                    AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND v_BackDtdProcess = 'Y' )
                    OR ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND v_BackDtdProcess = 'N' ) )
          UNION 
          SELECT b.AccountEntityId ,
                 'Bucket' ProvTypes  
          FROM BucketWiseAcceleratedProvision A
                 JOIN tt_ACCT_NPA_QTR_NO_REPORT_4 b   ON A.SegmentName = B.AcBuRevisedSegmentCode
                 AND A.Secured_Unsecured = B.SecuredUnsecured
                 AND NVL(A.AssetClassNameAlt_key, B.FinalAssetClassAlt_Key) = b.FinalAssetClassAlt_Key
                 AND NVL(A.BucketExceptCC, B.NPA_QTR_NO) = B.NPA_QTR_NO
           WHERE  A.SegmentName <> 'CREDIT CARD'
                    AND EffectiveDate <= v_ProcessDate
                    AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND v_BackDtdProcess = 'Y' )
                    OR ( A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND v_BackDtdProcess = 'N' ) )
          UNION 
          SELECT b.AccountEntityId ,
                 'Bucket' ProvTypes  
          FROM BucketWiseAcceleratedProvision A
                 JOIN tt_ACCT_NPA_QTR_NO_REPORT_4 b   ON A.SegmentName = B.AcBuRevisedSegmentCode
                 AND A.Secured_Unsecured = B.SecuredUnsecured
                 AND A.AssetClassNameAlt_key = b.FinalAssetClassAlt_Key
                 AND A.BucketCreditCard = CASE 
                                               WHEN B.ProvisionRule = 'K/W/E/U'
                                                 AND B.LowerDPD = 0
                                                 AND UpperDPD = 89 THEN 'DPD 0-89 - bc2'
                                               WHEN B.ProvisionRule = 'OTHERS/BLANK'
                                                 AND B.LowerDPD = 0
                                                 AND UpperDPD = 89 THEN 'DPD 0-89 - Other'
                                               WHEN B.ProvisionRule IN ( 'K/W/E/U' )

                                                 AND B.LowerDPD = 90
                                                 AND UpperDPD = 179 THEN 'DPD 90'
                                               WHEN B.ProvisionRule IN ( 'OTHERS/BLANK' )

                                                 AND B.LowerDPD = 90
                                                 AND UpperDPD = 179 THEN 'DPD 90 - Other'   END

          --WHEN B.ProvisionRule in('OTHERS/BLANK','K/W/E/U') AND B.LowerDPD=180 AND UpperDPD=9999 THEN 'DPD 180+'            
          WHERE  A.SegmentName = 'CREDIT CARD'
                   AND B.Segment = 'CREDIT CARD'
                   AND EffectiveDate <= v_ProcessDate
                   AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND v_BackDtdProcess = 'Y' )
                   OR ( A.EffectiveFromTimeKey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND v_BackDtdProcess = 'N' ) ) );

   END;
   --SELECT * FROM tt_ACCT_NPA_QTR_NO_Account_4
   --select * from tt_ACCT_NPA_QTR_NO_REPORT_4
   ---------------------------======================================From Date DPD CalCULATION  Start===========================================
   IF utils.object_id('tempdb..tt_DPD_29') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_29 ';
   END IF;
   DELETE FROM tt_DPD_29;
   UTILS.IDENTITY_RESET('tt_DPD_29');

   INSERT INTO tt_DPD_29 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND FinalAssetClassAlt_Key > 1 );
   --AND RefCustomerID=@CustomerID
   IF utils.object_id('tempdb..tt_CustomerCal_Hist_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CustomerCal_Hist_2 ';
   END IF;
   DELETE FROM tt_CustomerCal_Hist_2;
   UTILS.IDENTITY_RESET('tt_CustomerCal_Hist_2');

   INSERT INTO tt_CustomerCal_Hist_2 ( 
   	SELECT A.* 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A

   	--INNER JOIN tt_DPD_29 B

   	--ON A.CustomerEntityID=B.CustomerEntityID

   	--AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   	WHERE  A.EffectiveFromTimeKey <= v_TimeKey
             AND A.EffectiveToTimeKey >= v_TimeKey
             AND SysAssetClassAlt_Key > 1 );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_29 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   --select * from tt_DPD_29
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_ProcessDate)
   ELSE 0
      END) AS pos_2, (CASE 
   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_ProcessDate)
   ELSE 0
      END) AS pos_3, (CASE 
   WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_ProcessDate)
   ELSE 0
      END) AS pos_4, (CASE 
   WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_ProcessDate)
   ELSE 0
      END) AS pos_5, (CASE 
   WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_ProcessDate)
   ELSE 0
      END) AS pos_6, (CASE 
   WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_ProcessDate)
   ELSE 0
      END) AS pos_7
   FROM A ,tt_DPD_29 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = pos_2,
                                A.DPD_NoCredit = pos_3,
                                A.DPD_Overdrawn = pos_4,
                                A.DPD_Overdue = pos_5,
                                A.DPD_Renewal = pos_6,
                                A.DPD_StockStmt = pos_7;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_DPD_29
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD_29
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD_29
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD_29
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD_29
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD_29
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_29 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_128') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_128 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_128;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_128');

   INSERT INTO tt_TEMPTABLE_128 ( 
   	SELECT A.CustomerAcID ,
           CASE 
                WHEN NVL(A.DPD_IntService, 0) >= NVL(A.RefPeriodIntService, 0) THEN A.DPD_IntService
           ELSE 0
              END DPD_IntService  ,
           CASE 
                WHEN NVL(A.DPD_NoCredit, 0) >= NVL(A.RefPeriodNoCredit, 0) THEN A.DPD_NoCredit
           ELSE 0
              END DPD_NoCredit  ,
           CASE 
                WHEN NVL(A.DPD_Overdrawn, 0) >= NVL(A.RefPeriodOverDrawn, 0) THEN A.DPD_Overdrawn
           ELSE 0
              END DPD_Overdrawn  ,
           CASE 
                WHEN NVL(A.DPD_Overdue, 0) >= NVL(A.RefPeriodOverdue, 0) THEN A.DPD_Overdue
           ELSE 0
              END DPD_Overdue  ,
           CASE 
                WHEN NVL(A.DPD_Renewal, 0) >= NVL(A.RefPeriodReview, 0) THEN A.DPD_Renewal
           ELSE 0
              END DPD_Renewal  ,
           CASE 
                WHEN NVL(A.DPD_StockStmt, 0) >= NVL(A.RefPeriodStkStatement, 0) THEN A.DPD_StockStmt
           ELSE 0
              END DPD_StockStmt  
   	  FROM tt_DPD_29 A
             JOIN tt_CustomerCal_Hist_2 B   ON A.CustomerEntityID = B.CustomerEntityID
             AND B.EffectiveFromTimeKey <= v_TimeKey
             AND B.EffectiveToTimeKey >= v_TimeKey
   	 WHERE  ( NVL(DPD_IntService, 0) >= NVL(RefPeriodIntService, 0)
              OR NVL(DPD_NoCredit, 0) >= NVL(RefPeriodNoCredit, 0)
              OR NVL(DPD_Overdrawn, 0) >= NVL(RefPeriodOverDrawn, 0)
              OR NVL(DPD_Overdue, 0) >= NVL(RefPeriodOverdue, 0)
              OR NVL(DPD_Renewal, 0) >= NVL(RefPeriodReview, 0)
              OR NVL(DPD_StockStmt, 0) >= NVL(RefPeriodStkStatement, 0) )
              AND ( NVL(B.FlgProcessing, 'N') = 'N' ) );
   /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_29 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   /*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( NVL(A.DPD_IntService, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_IntService, 0)
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Overdue, 0)
   ELSE NVL(A.DPD_StockStmt, 0)
      END) AS DPD_Max
   FROM A ,tt_DPD_29 A
          JOIN tt_CustomerCal_Hist_2 C   ON C.CustomerEntityID = A.CustomerEntityID
          AND C.EffectiveFromTimeKey <= v_TimeKey
          AND C.EffectiveToTimeKey >= v_TimeKey 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   OPEN  v_cursor FOR
      SELECT CCL.UCIF_ID ,
             ACL.RefCustomerID ,
             CCL.CustomerName ,
             ACL.CustomerAcID ,
             DS.SourceName ,
             ACL.FacilityType ,
             DPRD.SchemeType ,
             ACL.ProductCode SchemeCode  ,
             dprd.ProductName SchemeDescreption  ,
             CASE 
                  WHEN ACL.FlgSecured = 'S' THEN 'Secured'
             ELSE 'UnSecured'
                END SecuredUnsecured  ,
             ACL.ActSegmentCode ,
             DSEG.AcBuSegmentDescription ,
             DSEG.AcBuRevisedSegmentCode ,
             --,ACL.FinalAssetClassAlt_Key
             DA.AssetClassName ,
             ACL.FinalNpaDt ,
             --,ACL.REFPeriodMax AS NPA_Norms
             ACL.NPA_Norms ,
             ACL.SecuredAmt ,
             ACL.UnSecuredAmt ,
             ACL.NetBalance ,
             ACL.Provsecured ,
             ACL.ProvUnsecured ,
             ACL.AddlProvision ,
             ACL.TotalProvision ,
             DPROV.ProvisionSecured ,
             DPROV.ProvisionUnSecured ,
             ACL.AddlProvisionPer ,
             CASE 
                  WHEN NVL(ACL.NetBalance, 0) > 0 THEN UTILS.CONVERT_TO_NUMBER(((ACL.TotalProvision * 100) / ACL.NetBalance),16,2)
             ELSE 0
                END TotalProvisionPer  ,
             CASE 
                  WHEN c.AcceProDuration = 1 THEN 'Accelerated Provision Through-out'
                  WHEN c.AcceProDuration = 2 THEN 'Accelerated Provision till IRAC'
             ELSE NULL
                END AcceleratedProvisionDuration  ,
             c.BucketExceptCC BucketAllExceptCC  ,
             c.BucketCreditCard ,
             ANA.ProvTypes ,
             DPD.DPD_MAX 

        --FROM PRO.ACCOUNTCAL ACL with (nolock)

        --INNER JOIN PRO.CUSTOMERCAL CCL

        --	ON ACL.CustomerEntityID=CCL.CustomerEntityID

        --select * from sysdaymatrix where timekey=26357
        FROM tt_ACCT_NPA_QTR_NO_REPORT_4 ACL
               JOIN tt_ACCT_NPA_QTR_NO_Account_4 ANA   ON ACL.AccountEntityID = ANA.AccountEntityId
               JOIN tt_CustomerCal_Hist_2 CCL   ON ACL.CustomerEntityID = CCL.CustomerEntityID
               AND CCL.EffectiveFromTimeKey <= v_Timekey
               AND CCL.EffectiveToTimeKey >= v_Timekey
               JOIN DIMSOURCEDB DS   ON ACL.SourceAlt_Key = DS.SourceAlt_Key
               AND DS.EffectiveFromTimeKey <= v_Timekey
               AND DS.EffectiveToTimeKey >= v_Timekey
               JOIN DimAcBuSegment DSEG   ON DSEG.AcBuSegmentCode = ACL.ActSegmentCode
               AND DSEG.EffectiveToTimeKey = 49999
               JOIN DimProvision_Seg DPROV   ON DPROV.ProvisionAlt_Key = ACL.ProvisionAlt_Key
               AND DPROV.EffectiveFromTimeKey <= v_Timekey
               AND DPROV.EffectiveToTimeKey >= v_Timekey
               JOIN DimProduct DPRD   ON DPRD.ProductCode = ACL.ProductCode
               AND DPRD.EffectiveFromTimeKey <= v_Timekey
               AND DPRD.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN AcceleratedProvision b   ON ACL.CustomerAcID = b.AccountId
               AND ( ( B.EffectiveFromTimeKey >= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey
               AND v_BackDtdProcess = 'Y' )
               OR ( B.EffectiveFromTimeKey <= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey
               AND v_BackDtdProcess = 'N' ) )
               LEFT JOIN BucketWiseAcceleratedProvision c   ON c.SegmentName = b.SegmentNameAlt_key
               AND c.Secured_Unsecured = b.Secured_Unsecured
               AND c.AssetClassNameAlt_key = b.AssetClassNameAlt_key
               AND ( ( C.EffectiveFromTimeKey >= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               AND v_BackDtdProcess = 'Y' )
               OR ( C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               AND v_BackDtdProcess = 'N' ) )
               LEFT JOIN DimAssetClass DA   ON DA.AssetClassAlt_Key = ACL.FinalAssetClassAlt_Key
               AND DA.EffectiveToTimeKey = 49999
               LEFT JOIN tt_DPD_29 DPD   ON DPD.AccountEntityID = ACL.AccountEntityID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select * from tt_ACCT_NPA_QTR_NO_Account_4

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_041_ACCELERATEDE_PROVISION_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
