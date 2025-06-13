--------------------------------------------------------
--  DDL for Procedure SP_SMAOUTPUT_AUTOMATE_REPORT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" 
AS
   v_TIMEKEY NUMBER(10,0) := ( SELECT timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_PROCESSDATE VARCHAR2(200);
   ---------------------------======================================DPD Calculation Start===========================================
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );

BEGIN

   SELECT DATE_ 

     INTO v_PROCESSDATE
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY;---972953
   IF  --SQLDEV: NOT RECOGNIZED
   IF DPD4  --SQLDEV: NOT RECOGNIZED
   DELETE FROM DPD4;
   UTILS.IDENTITY_RESET('DPD4');

   INSERT INTO DPD4 SELECT CustomerACID ,
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
                AND B.EffectiveToTimeKey >= v_Timekey;

   EXECUTE IMMEDIATE ' ALTER TABLE DPD4 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) , DPD_UCIF_ID NUMBER(10,0) ] ) ';
   /*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0, 0, 0, 0, 0
   FROM A ,DPD4 a ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = 0,
                                A.DPD_NoCredit = 0,
                                A.DPD_Overdrawn = 0,
                                A.DPD_Overdue = 0,
                                A.DPD_Renewal = 0,
                                A.DPD_StockStmt = 0,
                                a.DPD_PrincOverdue = 0,
                                a.DPD_IntOverdueSince = 0,
                                a.DPD_OtherOverdueSince = 0;
   --select * from DPD2
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
      FROM A ,DPD4 A ) src
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
      FROM A ,DPD4 A ) src
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
   UPDATE DPD4
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE DPD4
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE DPD4
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE DPD4
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE DPD4
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE DPD4
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE DPD4
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE DPD4
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE DPD4
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   --UPDATE A SET DPD_NoCredit=0 FROM DPD2 A 
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_140') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_140 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_140;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_140');

   INSERT INTO tt_TEMPTABLE_140 ( 
   	SELECT A.CustomerACID ,
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
   	  FROM DPD4 A
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
   FROM A ,DPD4 A ) src
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
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_IntService, 0)
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_Overdue, 0)
   WHEN ( NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_StockStmt, 0)
   WHEN ( NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntOverdueSince, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(DPD_PrincOverdue, 0)
   WHEN ( NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_IntOverdueSince, 0) >= NVL(A.DPD_OtherOverdueSince, 0) ) THEN NVL(A.DPD_IntOverdueSince, 0)
   ELSE NVL(A.DPD_OtherOverdueSince, 0)
      END) AS DPD_Max
   FROM A ,DPD4 a
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
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_UCIF_ID_17  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_UCIF_ID_17;
   UTILS.IDENTITY_RESET('tt_DPD_UCIF_ID_17');

   INSERT INTO tt_DPD_UCIF_ID_17 ( 
   	SELECT UCIF_ID ,
           MAX(DPD_MAX)  DPD_UCIF_ID  
   	  FROM DPD4 
   	  GROUP BY UCIF_ID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.DPD_UCIF_ID
   FROM A ,DPD4 A
          JOIN tt_DPD_UCIF_ID_17 B   ON A.UCIF_ID = B.UCIF_ID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_UCIF_ID = src.DPD_UCIF_ID;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE SMA_OUTPUT_Report_Automate ';
   INSERT INTO SMA_OUTPUT_Report_Automate
     SELECT v_PROCESSDATE CurrentProcessingDate  ,
            ROW_NUMBER() OVER ( ORDER BY A.UcifEntityId  ) SrNo  ,
            ---------RefColumns---------
            A.BranchCode ,
            br.BranchName ,
            br.BranchStateName ,
            H.SourceName ,
            A.RefCustomerID CustomerID  ,
            A.SourceSystemCustomerID SourceSystemCustomerID  ,
            A.UCIF_ID ,
            A.CustomerAcID ,
            F.PANNO ,
            F.CustomerName ,
            F.CustSegmentCode ,
            A.FacilityType ,
            ----Edit--------
            A.ProductCode ,
            C.ProductName ,
            A.ActSegmentCode ,
            CASE 
                 WHEN SourceName = 'Ganaseva' THEN 'FI'
                 WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
            ELSE S.AcBuRevisedSegmentCode
               END AcBuRevisedSegmentCode  ,
            SchemeType ,
            NVL(A.Balance, 0) Balance  ,
            NVL(A.PrincOutStd, 0) PrincOutStd  ,
            NVL(A.PrincOverdue, 0) PrincOverdue  ,
            NVL(A.IntOverdue, 0) IntOverdue  ,
            NVL(A.OtherOverdue, 0) OtherOverdue  ,
            NVL(A.OverdueAmt, 0) OverdueAmt  ,
            NVL(A.CurrentLimit, 0) CurrentLimit  ,
            UTILS.CONVERT_TO_VARCHAR2(A.ContiExcessDt,10,p_style=>103) ContiExcessDt  ,
            UTILS.CONVERT_TO_VARCHAR2(A.StockStDt,10,p_style=>103) StockStDt  ,
            UTILS.CONVERT_TO_VARCHAR2(A.LastCrDate,10,p_style=>103) LastCrDate  ,
            UTILS.CONVERT_TO_VARCHAR2(A.IntNotServicedDt,10,p_style=>103) IntNotServicedDt  ,
            UTILS.CONVERT_TO_VARCHAR2(A.OverDueSinceDt,10,p_style=>103) OverDueSinceDt  ,
            UTILS.CONVERT_TO_VARCHAR2(A.ReviewDueDt,10,p_style=>103) ReviewDueDt  ,
            -------OutPut-----
            DPD.DPD_StockStmt ,
            DPD.DPD_NoCredit ,
            DPD.DPD_IntService ,
            DPD.DPD_Overdrawn ,
            DPD.DPD_Overdue ,
            DPD.DPD_Renewal ,
            DPD.DPD_MAX SMA_DPD  ,
            A.FlgSMA AccountFlgSMA  ,
            A.SMA_Dt AccountSMA_Dt  ,
            A.SMA_Class AccountSMA_AssetClass  ,
            A.SMA_Reason SMA_Reason  ,
            dpd.DPD_UCIF_ID ,
            F.FlgSMA UCICFlgSMA  ,
            F.SMA_Dt UCICSMA_Dt  ,
            --,Case When A.Asset_Norm='ALWYS_STD' then A.SMA_Class Else F.CustMoveDescription End as UCICSMA_AssetStatus
            F.CustMoveDescription UCICSMA_AssetStatus  ,
            CASE 
                 WHEN A.FlgSMA = 'Y' THEN NULL
            ELSE I.MovementFromDate
               END MovementFromDate  ,
            CASE 
                 WHEN A.FlgSMA = 'Y' THEN NULL
            ELSE I.MovementFromStatus
               END MovementFromStatus  ,
            CASE 
                 WHEN A.FlgSMA = 'Y' THEN NULL
            ELSE I.MovementToStatus
               END MovementToStatus  ,
            A.Asset_Norm 

       --INTO SMA_OUTPUT
       FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
              JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
              AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY
              AND C.EffectiveFromTimeKey <= v_TIMEKEY
              AND C.EffectiveToTimeKey >= v_TIMEKEY
              JOIN DimAssetClass D   ON D.AssetClassAlt_Key = A.InitialAssetClassAlt_Key
              AND D.EffectiveFromTimeKey <= v_TIMEKEY
              AND D.EffectiveToTimeKey >= v_TIMEKEY
              JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
              AND E.EffectiveFromTimeKey <= v_TIMEKEY
              AND E.EffectiveToTimeKey >= v_TIMEKEY
              JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist F   ON F.CustomerEntityId = A.CustomerEntityId
              AND F.EffectiveFromTimeKey <= v_TIMEKEY
              AND F.EffectiveToTimeKey >= v_TIMEKEY
              JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey
              JOIN DIMSOURCEDB H   ON H.SourceAlt_Key = A.SourceAlt_Key
              AND H.EffectiveFromTimeKey <= v_TIMEKEY
              AND H.EffectiveToTimeKey >= v_TIMEKEY
              JOIN DPD4 DPD   ON DPD.AccountEntityid = A.AccountEntityID
              LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY I   ON I.CustomerAcID = A.CustomerAcID
              AND I.EffectiveFromTimeKey <= v_TIMEKEY
              AND I.EffectiveToTimeKey >= v_TIMEKEY
              LEFT JOIN DimAcBuSegment S   ON a.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveFromTimeKey <= v_TIMEKEY
              AND S.EffectiveToTimeKey >= v_TIMEKEY
              LEFT JOIN DimBranch BR   ON a.BranchCode = br.BranchCode
              AND br.EffectiveFromTimeKey <= v_TIMEKEY
              AND br.EffectiveToTimeKey >= v_TIMEKEY
      WHERE  A.FinalAssetClassAlt_Key = 1
               AND F.FlgSMA = 'Y'
       ORDER BY A.UcifEntityID,
                A.RefCustomerID;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_AUTOMATE_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
