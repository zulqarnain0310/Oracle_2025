--------------------------------------------------------
--  DDL for Procedure RERF_HISTDATA_REPORT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" 
AS
   v_Timekey NUMBER(10,0) := (26455);
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_HostDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(SYSDATE - 2,200) 
     FROM DUAL  );
   --(26376)  
   --DECLARE @Date date =  (select Date from Automate_Advances where Timekey = @Timekey)  
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );
   --(C.flgdeg='Y' OR c.InitialNpaDt<>c.FinalNpaDt ) AND A.AssetClassAlt_Key<>C.FinalAssetClassAlt_Key 
   v_cursor SYS_REFCURSOR;

BEGIN

   IF ( utils.object_id('TEMPDB..tt_PrevQtrData_26') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrData_26 ';
   END IF;
   DELETE FROM tt_PrevQtrData_26;
   UTILS.IDENTITY_RESET('tt_PrevQtrData_26');

   INSERT INTO tt_PrevQtrData_26 ( 
   	SELECT ACCOUNTENTITYID ,
           CUSTOMERACID ,
           SecuredAmt ,
           UnSecuredAmt ,
           TotalProvision ,
           Provsecured ,
           ProvUnsecured ,
           Addlprovision ,
           NetBalance ,
           FinalAssetClassAlt_Key ----,*  


   	  ----MAX(EffectiveToTimeKey)  
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_LastQtrDateKey
              AND EffectiveToTimeKey >= v_LastQtrDateKey );
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
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_114') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_114 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_114;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_114');

   INSERT INTO tt_TEMPTABLE_114 ( 
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
   OPEN  v_cursor FOR
      SELECT v_Date CriSMacReportDate  ,
             v_HostDate HostSystemReportDate  ,
             D.UCIF_ID UCICNO  ,
             D.CustomerID CIFNO  ,
             B.CustomerACID AccountNo  ,
             D.CustomerName BorrowerName  ,
             H.SourceName ,
             I.AcBuSegmentDescription BusinessSegment  ,
             DP.DPD_Max AccountDPD  ,
             C.REFPeriodMax NPANorm  ,
             A.PrincipalBalance PrincipleBalanceCrisMac  ,
             A.PrincipalBalance PrincipleBalanceHost  ,
             A.SourceNpaDate HostSystemNPADate  ,
             --,G.SourceNpaDate as CIFLevelHostSystemNPADAte,
             C.FinalNPADt CrisMacNPADt  ,
             A.SourceAssetClass HostAssetClass  ,
             --,G.SourceAssetClass as CIFLevelAssetClass,
             F.SrcSysClassCode CrisMacAssetCLass  
        FROM AdvAcBalanceDetail A
               JOIN AdvAcBasicDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey )
               AND ( A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey )
               AND A.accountentityid = B.accountentityid
               JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey )
               AND A.accountentityid = C.accountentityid
               JOIN CustomerBasicDetail D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey )
               AND D.customerid = B.RefcustomerID
               JOIN AdvCustOtherDetail G   ON ( G.EffectiveFromTimeKey <= v_TimeKey
               AND G.EffectiveToTimeKey >= v_TimeKey )
               AND G.RefcustomerID = D.CUstomerID
               JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist E   ON ( E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey )
               AND E.customerEntityID = C.CustomerEntityID
               JOIN DimAssetClass F   ON ( F.EffectiveFromTimeKey <= v_TimeKey
               AND F.EffectiveToTimeKey >= v_TimeKey )
               AND F.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
               JOIN DIMSOURCEDB H   ON ( H.EffectiveFromTimeKey <= v_TimeKey
               AND H.EffectiveToTimeKey >= v_TimeKey )
               AND H.sourceAlt_Key = B.SourceAlt_Key
               JOIN DimAcBuSegment I   ON ( I.EffectiveFromTimeKey <= v_TimeKey
               AND I.EffectiveToTimeKey >= v_TimeKey )
               AND I.AcBuSegmentCode = B.segmentcode
             --Below join is added by Swati

               JOIN DimAssetClassMapping J   ON ( J.EffectiveFromTimeKey <= v_TimeKey
               AND J.EffectiveToTimeKey >= v_TimeKey )
               AND A.SourceAssetClass = J.SrcSysClassCode
               AND B.SourceAlt_Key = j.SourceAlt_Key
               LEFT JOIN DPD2 DP   ON ( DP.EffectiveFromTimeKey <= v_TimeKey
               AND DP.EffectiveToTimeKey >= v_TimeKey )
               AND c.CustomerAcID = dp.CustomerACID
       WHERE  ( C.InitialAssetClassAlt_Key = 1
                AND C.FinalAssetClassAlt_Key > 1 )
                OR ( J.AssetClassAlt_Key = 1
                AND C.FinalAssetClassAlt_Key > 1 )
                OR ( C.InitialAssetClassAlt_Key > 1
                AND C.FinalAssetClassAlt_Key > 1
                AND NVL(C.InitialNpaDt, ' ') <> NVL(C.FinalNpaDt, ' ') )
      UNION 
      SELECT v_Date CriSMacReportDate  ,
             v_HostDate HostSystemReportDate  ,
             D.UCIF_ID UCICNO  ,
             D.CustomerID CIFNO  ,
             B.CustomerACID AccountNo  ,
             D.CustomerName BorrowerName  ,
             H.SourceName ,
             I.AcBuSegmentDescription BusinessSegment  ,
             dp.DPD_MAX AccountDPD  ,
             C.REFPeriodMax NPANorm  ,
             A.PrincipalBalance PrincipleBalanceCrisMac  ,
             A.PrincipalBalance PrincipleBalanceHost  ,
             A.SourceNpaDate HostSystemNPADate  ,
             --,G.SourceNpaDate as CIFLevelHostSystemNPADAte,
             C.FinalNPADt CrisMacNPADt  ,
             A.SourceAssetClass HostAssetClass  ,
             --,G.SourceAssetClass as CIFLevelAssetClass,
             F.SrcSysClassCode CrisMacAssetCLass  
        FROM AdvAcBalanceDetail A
               JOIN AdvAcBasicDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey )
               AND ( A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey )
               AND A.accountentityid = B.accountentityid
               JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey )
               AND A.accountentityid = C.accountentityid
               JOIN CustomerBasicDetail D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey )
               AND D.customerid = B.RefcustomerID
               JOIN AdvCustOtherDetail G   ON ( G.EffectiveFromTimeKey <= v_TimeKey
               AND G.EffectiveToTimeKey >= v_TimeKey )
               AND G.RefcustomerID = D.CUstomerID
               JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist E   ON ( E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey )
               AND E.customerEntityID = C.CustomerEntityID
               JOIN DimAssetClass F   ON ( F.EffectiveFromTimeKey <= v_TimeKey
               AND F.EffectiveToTimeKey >= v_TimeKey )
               AND F.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
               JOIN DIMSOURCEDB H   ON ( H.EffectiveFromTimeKey <= v_TimeKey
               AND H.EffectiveToTimeKey >= v_TimeKey )
               AND H.sourceAlt_Key = B.SourceAlt_Key
               JOIN DimAcBuSegment I   ON ( I.EffectiveFromTimeKey <= v_TimeKey
               AND I.EffectiveToTimeKey >= v_TimeKey )
               AND I.AcBuSegmentCode = B.segmentcode
             --Below join is added by Swati

               JOIN DimAssetClassMapping J   ON ( J.EffectiveFromTimeKey <= v_TimeKey
               AND J.EffectiveToTimeKey >= v_TimeKey )
               AND A.SourceAssetClass = J.SrcSysClassCode
               AND B.SourceAlt_Key = j.SourceAlt_Key
               LEFT JOIN DPD2 DP   ON ( DP.EffectiveFromTimeKey <= v_TimeKey
               AND DP.EffectiveToTimeKey >= v_TimeKey )
               AND c.CustomerAcID = dp.CustomerACID
       WHERE  ( C.InitialAssetClassAlt_Key > 1
                AND C.FinalAssetClassAlt_Key = 1 )
                OR ( J.AssetClassAlt_Key > 1
                AND C.FinalAssetClassAlt_Key = 1 ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RERF_HISTDATA_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
