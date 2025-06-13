--------------------------------------------------------
--  DDL for Procedure TWO_REPORT_POSTMOC_AUTOMATE_02052024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" 
AS
   --DEclare @Timekey int =(select Timekey from PostMOCTimeKey)
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );
   v_CurQtrDate VARCHAR2(200) := ( SELECT CurQtrDate 
     FROM SysDayMatrix 
    WHERE  Timekey IN ( v_timekey )
    );

BEGIN

   IF  --SQLDEV: NOT RECOGNIZED
   IF DPD2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM DPD2;
   UTILS.IDENTITY_RESET('DPD2');

   INSERT INTO DPD2 SELECT CustomerACID ,
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

   EXECUTE IMMEDIATE ' ALTER TABLE DPD2 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0, 0, 0, 0, 0
   FROM A ,DPD2 a ) src
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
      FROM A ,DPD2 A ) src
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
      FROM A ,DPD2 A ) src
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
   UPDATE DPD2
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE DPD2
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE DPD2
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE DPD2
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE DPD2
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE DPD2
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE DPD2
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE DPD2
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE DPD2
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   --UPDATE A SET DPD_NoCredit=0 FROM DPD2 A   
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_145') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_145 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_145;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_145');

   INSERT INTO tt_TEMPTABLE_145 ( 
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
   	  FROM DPD2 A
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
   FROM A ,DPD2 A ) src
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
   FROM A ,DPD2 a
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
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TWO_PostMOC_Reprot_Automate ';
   INSERT INTO TWO_PostMOC_Reprot_Automate
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CIF_ID  ,
              REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
              B.BranchCode Branch_Code  ,
              REPLACE(BranchName, ',', ' ') Branch_Name  ,
              B.CustomerAcID Account_No_  ,
              SourceName Source_System  ,
              --,B.FacilityType as [Facility]  
              SchemeType Scheme_Type  ,
              B.ProductCode Scheme_Code  ,
              REPLACE(ProductName, ',', ' ') Scheme_Description  ,
              ActSegmentCode Seg_Code  ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END Segment_Description  ,
              --,CASE WHEN SourceName='Ganaseva' THEN 'FI'  
              --    WHEN SourceName='VisionPlus' THEN 'Credit Card'  
              --  else AcBuRevisedSegmentCode end [Business Segment]  
              DPD_Max Account_DPD  ,
              --,FinalNpaDt as [NPA Date]  
              Balance Outstanding  ,
              --,ISNULL(PrincOutStd,0) as [Principal Outstanding]  
              --,case when  ISNULL(PrincOutStd,0) < 0 then 0 else isnull(PrincOutStd,0) end as [Principal Outstanding]  
              --,a2.SrcSysClassCode as [Asset Classification]  
              --,zz.AssetClassCode as [Soirce System Status]  
              --,ISNULL(IntOverdue,0)  [interest Dues]  
              ----,ISNULL(penal_due,0)   
              --,'' [Penal Dues]  
              --,ISNULL(OtherOverdue,0)   [Other Dues]  
              --,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]  
              --,ISNULL(penal_int_receivable,0) [penal accured but not due]  
              --,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]  
              --,ISNULL(Balance_FEES,0) [Credit Card other charges]  
              --,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]  
              --,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]  
              ActSegmentCode Account_Segment_Code  ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END Account_Segment_Description  ,
              B.FacilityType Facility  ,
              ProductGroup Nature_of_Facility  ,
              NVL(EF.Amount, 0) Opening_Balance  ,
              (CASE 
                    WHEN NVL(EF.Amount, 0) = 0 THEN NVL(B.PrincOutStd, 0)
              ELSE 0
                 END) Addition  ,
              (CASE 
                    WHEN NVL(EF.Amount, 0) > 0 THEN (CASE 
                                                          WHEN NVL(B.PrincOutStd, 0) - NVL(EF.Amount, 0) < 0 THEN 0
                    ELSE NVL(B.PrincOutStd, 0) - NVL(B.WriteOffAmount, 0)
                       END)
              ELSE 0
                 END) Increase_In_Balance  ,
              ' ' Cash_Recovery  ,
              ' ' Recovery_from_NPA_Sale  ,
              0 Write_off  ,
              NVL(B.PrincOutStd, 0) Closing_Balance_POS ,---As requested by Sitaram sir 14/10/2021  

              (CASE 
                    WHEN NVL(B.WriteOffAmount, 0) - NVL(B.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(B.WriteOffAmount, 0) - NVL(B.PrincOutStd, 0)
                 END) Reduction_in_Balance  ,
              v_CurQtrDate Reporting_Period  ,
              NVL(DPD.DPD_MAX, 0) DPD ,---As requested by Sitaram sir  

              FinalNpaDt NPA_Date ,---As requested by Sitaram sir  

              a2.AssetClassName Asset_Classification  ,
              CASE 
                   WHEN MOC.TwoDate IS NULL THEN EF.StatusDate
              ELSE MOC.TwoDate
                 END Date_of_Technical_Write_off  ,
              SourceName Host_System  ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'

                   --WHEN SourceName='VisionPlus' THEN 'Credit Card'  
                   WHEN SourceName = 'VisionPlus'
                     AND B.ProductCode IN ( '777','780' )
                    THEN 'Retail'
                   WHEN SourceName = 'VisionPlus'
                     AND B.ProductCode NOT IN ( '777','780' )
                    THEN 'Credit Card'
              ELSE AcBuRevisedSegmentCode
                 END Business_Segment  

       --INTO #TEMP4  

       --DROP TABLE #TEMP4  
       FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
              JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
              AND NVL(b.WriteOffAmount, 0) > 0
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
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
              LEFT JOIN RBL_MISDB_PROD.AdvAcOtherFinancialDetail Y   ON Y.AccountEntityId = B.AccountEntityID
              AND Y.EffectiveToTimeKey = 49999
              LEFT JOIN RBL_MISDB_PROD.AdvCreditCardBalanceDetail YZ   ON YZ.AccountEntityID = B.AccountEntityID
              AND YZ.EffectiveToTimeKey = 49999
              LEFT JOIN InvestmentFinancialDetail Z   ON Z.RefInvID = B.CustomerAcID
              AND Z.EffectiveToTimeKey = 49999
              LEFT JOIN MOC_ChangeDetails MOC   ON MOC.AccountEntityID = B.AccountEntityID
              AND MOC.EffectiveFromTimeKey <= v_Timekey
              AND MOC.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN ExceptionFinalStatusType EF   ON EF.ACID = B.CUSTOMERACID
              AND EF.EffectiveFromTimeKey <= v_Timekey
              AND EF.EffectiveToTimeKey >= v_Timekey
              AND StatusType = 'TWO'
              LEFT JOIN ( SELECT DISTINCT CustomerAcid ,
                                          AssetClassCode 
                          FROM RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM  ) ZZ   ON B.CustomerAcID = ZZ.CustomerAcID
              LEFT JOIN DPD2 DPD   ON B.accountentityid = DPD.AccountEntityid
        WHERE  B.FinalAssetClassAlt_Key > 1
                 AND A.EffectiveFromTimeKey <= v_Timekey
                 AND A.EffectiveToTimeKey >= v_Timekey
                 AND B.EffectiveFromTimeKey <= v_Timekey
                 AND B.EffectiveToTimeKey >= v_Timekey );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.StatusDate
   FROM A ,TWO_PostMOC_Reprot_Automate A
          JOIN ExceptionFinalStatusType B   ON A.Account_No = B.ACID
          AND ( ( B.EffectiveFromTimeKey <= v_Timekey
          AND B.EffectiveToTimeKey >= v_Timekey )
          OR ( B.StatusDate <= v_Date
          AND B.EffectiveFromTimeKey >= v_Timekey
          AND B.EffectiveFromTimeKey < B.EffectiveToTimeKey ) )
          AND A.Date_of_Technical_Write_off IS NULL
          AND B.StatusType = 'TWO' ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Date_of_Technical_Write_off = src.StatusDate;--SELECT [Report Date],UCIC,[CIF ID],[Borrower Name] AS CustomerName,[Branch Code],[Branch Name],[Account No.],  
   -- [Scheme Type],[Scheme Code],[Scheme Description],[Account Segment Code] ,[Account Segment Description],   
   -- Facility,[Nature of Facility],[Opening Balance],Addition,[Increase In Balance],[Cash Recovery],[Recovery from NPA Sale],  
   -- [Write-off],[Closing Balance POS],[Reduction in Balance],Reporting_Period,DPD,[NPA Date],[Asset Classification],[Date of Technical Write-off],  
   -- [Host System],[Business Segment]  
   -- FROM TWO_PostMOC_Reprot_Automate 
   --SELECT 21349662724.95-20061874666.10  
   --select sum([Closing Balance POS]) from #TEMP4 WHERE Addition =0  
   --select count(*) from #TEMP4 WHERE Addition =0  
   --SELECT SUM(TwoAmount) FROM MOC_ChangeDetails  
   --WHERE TwoAmount >0  

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWO_REPORT_POSTMOC_AUTOMATE_02052024" TO "ADF_CDR_RBL_STGDB";
