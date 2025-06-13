--------------------------------------------------------
--  DDL for Procedure DGU_DPD_ACL_REPORT_20042024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" 
--drop proc DGU_PostMOC_ACL_Report

AS
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --(26299)  
   --DECLARE @Date date =   
   --(select Date from Automate_Advances where Timekey = @Timekey)  
   --DECLARE @Timekey int =   
   --(26376)  
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );

BEGIN

   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_dpd2_3  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_dpd2_3;
   UTILS.IDENTITY_RESET('tt_dpd2_3');

   INSERT INTO tt_dpd2_3 ( 
   	SELECT CustomerACID ,
           AccountEntityid ,
           B.SourceSystemCustomerID ,
           B.IntNotServicedDt ,
           ( SELECT Date_ 
             FROM Automate_Advances 
            WHERE  Timekey = v_Timekey ) Process_Date  ,
           A.UCIF_ID ,
           LastCrDate ,
           ContiExcessDt ,
           OverDueSinceDt ,
           ReviewDueDt ,
           StockStDt ,
           PrincOverdueSinceDt ,
           IntOverdueSinceDt ,
           OtherOverdueSinceDt ,
           DebitSinceDt ,
           RefPeriodIntService ,
           RefPeriodNoCredit ,
           RefPeriodOverDrawn ,
           RefPeriodOverdue ,
           RefPeriodReview ,
           RefPeriodStkStatement ,
           A.DegDate ,
           b.EffectiveFromTimeKey ,
           b.EffectiveToTimeKey ,
           B.SourceAlt_Key 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist B
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey
              AND B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_dpd2_3 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0, 0, 0, 0, 0
   FROM A ,tt_dpd2_3 a ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = 0,
                                A.DPD_NoCredit = 0,
                                A.DPD_Overdrawn = 0,
                                A.DPD_Overdue = 0,
                                A.DPD_Renewal = 0,
                                A.DPD_StockStmt = 0,
                                DPD_PrincOverdue = 0,
                                DPD_IntOverdueSince = 0,
                                DPD_OtherOverdueSince = 0;
   --select * from tt_dpd2_3  
   --------  
   IF v_TIMEKEY > 26267 THEN

    ----IMPLEMENTED FROM 2021-12-01   
   BEGIN
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, Process_Date) + 1
      ELSE 0
         END) AS pos_2, CASE 
      WHEN ( DebitSinceDt IS NULL
        OR utils.datediff('DAY', DebitSinceDt, Process_Date) > 90 ) THEN (CASE 
                                                                               WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, Process_Date) + 1
      ELSE 0
         END)
      ELSE 0
         END AS pos_3, (CASE 
      WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, Process_Date) + 1
      ELSE 0
         END) AS pos_4, CASE 
      WHEN v_TIMEKEY > 26372 THEN (CASE 
                                        WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, Process_Date) + 1
      ELSE 0
         END)
      ELSE (CASE 
      WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, Process_Date) + (CASE 
                                                                                                           WHEN SourceAlt_Key = 6 THEN 0
      ELSE 1
         END)
      ELSE 0
         END)
         END AS pos_5, (CASE 
      WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, Process_Date) + 1
      ELSE 0
         END) AS pos_6, (CASE 
      WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, Process_Date) + 1
      ELSE 0
         END) AS pos_7, (CASE 
      WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, Process_Date) + 1
      ELSE 0
         END) AS pos_8, (CASE 
      WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, Process_Date) + 1
      ELSE 0
         END) AS pos_9, (CASE 
      WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, Process_Date) + 1
      ELSE 0
         END) AS pos_10
      FROM A ,tt_dpd2_3 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_IntService
                                   ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)  
                                    = pos_2,
                                   A.DPD_NoCredit = pos_3,
                                   A.DPD_Overdrawn = pos_4,
                                   A.DPD_Overdue
                                   ------ AMAR - CHANGES ON 17032021 AS PER EMAIL BY ASHISH SIR DATED - 17-03-2021 1:59 PM - SUBJECT - Credit Card NPA Computation  --   
                                    = pos_5,
                                   A.DPD_Renewal = pos_6,
                                   A.DPD_StockStmt = pos_7,
                                   A.DPD_PrincOverdue = pos_8,
                                   A.DPD_IntOverdueSince = pos_9,
                                   A.DPD_OtherOverdueSince = pos_10;

   END;
   ELSE

   BEGIN
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, Process_Date)
      ELSE 0
         END) AS pos_2, (CASE 
      WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, Process_Date)
      ELSE 0
         END) AS pos_3, (CASE 
      WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, Process_Date)
      ELSE 0
         END) AS pos_4, (CASE 
      WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, Process_Date)
      ELSE 0
         END) AS pos_5, CASE 
      WHEN ( DebitSinceDt IS NULL
        OR utils.datediff('DAY', DebitSinceDt, Process_Date) > 90 ) THEN (CASE 
                                                                               WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, Process_Date)
      ELSE 0
         END)
      ELSE 0
         END AS pos_6, (CASE 
      WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, Process_Date) + 1
      ELSE 0
         END) AS pos_7, (CASE 
      WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, Process_Date)
      ELSE 0
         END) AS pos_8, (CASE 
      WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, Process_Date)
      ELSE 0
         END) AS pos_9, (CASE 
      WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, Process_Date)
      ELSE 0
         END) AS pos_10
      FROM A ,tt_dpd2_3 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_PrincOverdue = pos_2,
                                   A.DPD_IntOverdueSince = pos_3,
                                   A.DPD_OtherOverdueSince = pos_4,
                                   A.DPD_IntService
                                   ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)  
                                    = pos_5,
                                   A.DPD_NoCredit = pos_6,
                                   A.DPD_Overdrawn = pos_7,
                                   A.DPD_Overdue = pos_8,
                                   A.DPD_Renewal = pos_9,
                                   A.DPD_StockStmt = pos_10;

   END;
   END IF;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_dpd2_3
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_dpd2_3
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   --UPDATE A SET DPD_NoCredit=0 FROM tt_dpd2_3 A   
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_18') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_18 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_18;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_18');

   INSERT INTO tt_TEMPTABLE_18 ( 
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

   	  --FROM PRO.ACCOUNTCAL A inner join pro.CustomerCal B on a.RefCustomerID=b.RefCustomerID  
   	  FROM tt_dpd2_3 A
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
   	 WHERE  ( NVL(DPD_IntService, 0) >= NVL(RefPeriodIntService, 0)
              OR NVL(DPD_NoCredit, 0) >= NVL(RefPeriodNoCredit, 0)
              OR NVL(DPD_Overdrawn, 0) >= NVL(RefPeriodOverDrawn, 0)
              OR NVL(DPD_Overdue, 0) >= NVL(RefPeriodOverdue, 0)
              OR NVL(DPD_Renewal, 0) >= NVL(RefPeriodReview, 0)
              OR NVL(DPD_StockStmt, 0) >= NVL(RefPeriodStkStatement, 0) )
              AND ( NVL(B.FlgProcessing, 'N') = 'N' )
              AND B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey );
   --and A.RefCustomerID<>'0'  
   /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_dpd2_3 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID  
   --WHERE  isnull(B.FlgProcessing,'N')='N'    
   /*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( NVL(A.DPD_IntService, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_IntService, 0)
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdue, 0)
   WHEN ( NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_StockStmt, 0)
   WHEN ( NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(DPD_PrincOverdue, 0)
   WHEN ( NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_IntOverDueSince, 0)
   ELSE NVL(A.DPD_OtherOverDueSince, 0)
      END) AS DPD_Max
   FROM A ,tt_dpd2_3 a
        --INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID  

          JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON C.SourceSystemCustomerID = a.SourceSystemCustomerID 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )
     AND C.EffectiveFromTimeKey <= v_Timekey
     AND C.EffectiveToTimeKey >= v_Timekey) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_MISDB_PROD.DGU_DPD_ACL_Report_Automate ';
   INSERT INTO RBL_MISDB_PROD.DGU_DPD_ACL_Report_Automate
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CIF_ID  ,
              REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
              B.BranchCode Branch_Code  ,
              REPLACE(BranchName, ',', ' ') Branch_Name  ,
              B.CustomerAcID Account_No_  ,
              SourceName Source_System  ,
              B.FacilityType Facility  ,
              SchemeType Scheme_Type  ,
              B.ProductCode Scheme_Code  ,
              ProductName Scheme_Description  ,
              ActSegmentCode Seg_Code  ,
              CASE 
                   WHEN SourceName IN ( 'Ganaseva','FIS' )
                    THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END Segment_Description  ,
              CASE 
                   WHEN SourceName IN ( 'Ganaseva','FIS' )
                    THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuRevisedSegmentCode
                 END Business_Segment  ,
              DPD_Max Account_DPD  ,
              FinalNpaDt NPA_Date  ,
              Balance Outstanding  ,
              NetBalance Principal_Outstanding  ,
              DrawingPower Drawing_Power  ,
              CurrentLimit Sanction_Limit  ,
              CASE 
                   WHEN SourceName = 'Finacle'
                     AND SchemeType = 'ODA' THEN (CASE 
                                                       WHEN (NVL(b.Balance, 0) - (CASE 
                                                                                       WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                                                       ELSE NVL(b.CurrentLimit, 0)
                                                          END)) <= 0 THEN 0
                   ELSE NVL(b.Balance, 0) - (CASE 
                                                  WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                   ELSE NVL(b.CurrentLimit, 0)
                      END)
                      END)
              ELSE 0
                 END OverDrawn_Amount  ,
              DPD_Overdrawn ,
              B.ContiExcessDt Limit_DP_Overdrawn_Date  ,
              B.ReviewDueDt Limit_Expiry_Date  ,
              DPD_Renewal DPD_Limit_Expiry  ,
              B.StockStDt Stock_Statement_valuation_date  ,
              DPD_StockStmt DPD_Stock_Statement_expiry  ,
              b.DebitSinceDt Debit_Balance_Since_Date  ,
              B.LastCrDate Last_Credit_Date  ,
              DPD_NoCredit DPD_No_Credit  ,
              CurQtrCredit Current_quarter_credit  ,
              CurQtrInt Current_quarter_interest  ,
              (CASE 
                    WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
              ELSE (CurQtrInt - CurQtrCredit)
                 END) Interest_Not_Serviced  ,
              DPD_IntService DPD_out_of_order  ,
              B.IntNotServicedDt CC_OD_Interest_Service  ,
              OverdueAmt Overdue_Amount  ,
              B.OverDueSinceDt Overdue_Date  ,
              DPD_Overdue ,
              PrincOverdue Principal_Overdue  ,
              B.PrincOverdueSinceDt Principal_Overdue_Date  ,
              DPD_PrincOverdue DPD_Principal_Overdue  ,
              IntOverdue Interest_Overdue  ,
              B.IntOverdueSinceDt Interest_Overdue_Date  ,
              DPD_IntOverdueSince DPD_Interest_Overdue  ,
              OtherOverdue Other_OverDue  ,
              B.OtherOverdueSinceDt Other_OverDue_Date  ,
              DPD_OtherOverdueSince DPD_Other_Overdue  ,
              (CASE 
                    WHEN SchemeType = 'FBA' THEN OverdueAmt
              ELSE 0
                 END) Bill_PC_Overdue_Amount  ,
              ' ' Overdue_Bill_PC_ID  ,
              (CASE 
                    WHEN SchemeType = 'FBA' THEN B.OverDueSinceDt
              ELSE ' '
                 END) Bill_PC_Overdue_Date  ,
              (CASE 
                    WHEN SchemeType = 'FBA' THEN DPD_Overdue
              ELSE 0
                 END) DPD_Bill_PC  ,
              a2.AssetClassName Asset_Classification  ,
              REPLACE(NVL(A.DegReason, b.NPA_Reason), ',', ' ') Degrade_Reason  ,
              b.REFPERIODOVERDUE NPA_Norms  ,
              v_Date DateOfData  

       --into #ACLReport_16012023_2
       FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
              JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
            --and isnull(b.WriteOffAmount,0)=0  

              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              AND src.EffectiveFromTimeKey <= v_Timekey
              AND src.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
              AND X.EffectiveToTimeKey = 49999
              LEFT JOIN tt_dpd2_3 DPD   ON B.accountentityid = DPD.AccountEntityID
        WHERE  b.EffectiveFromTimeKey <= v_Timekey
                 AND B.EffectiveToTimeKey >= v_Timekey
                 AND A.EffectiveFromTimeKey <= v_Timekey
                 AND A.EffectiveToTimeKey >= v_Timekey
                 AND DPD_Max > 0 );--select * from #ACLReport_16012023_2
   --where [CIF ID]='101057450'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_DPD_ACL_REPORT_20042024" TO "ADF_CDR_RBL_STGDB";
