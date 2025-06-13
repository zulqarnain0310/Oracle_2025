--------------------------------------------------------
--  DDL for Procedure DPD_CALCULATION_HISTDATA_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" 
--select * from Automate_Advances where Timekey=26298

AS
   v_Timekey NUMBER(10,0) := (26298);
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   IF  --SQLDEV: NOT RECOGNIZED
   IF DPD  --SQLDEV: NOT RECOGNIZED
   DELETE FROM DPD;
   UTILS.IDENTITY_RESET('DPD');

   INSERT INTO DPD SELECT CustomerACID ,
                          AccountEntityid ,
                          B.SourceSystemCustomerID ,
                          B.IntNotServicedDt ,
                          ( SELECT Date_ 
                            FROM Automate_Advances 
                           WHERE  Timekey = v_Timekey ) Process_Date  ,
                          LastCrDate ,
                          ContiExcessDt ,
                          OverDueSinceDt ,
                          ReviewDueDt ,
                          StockStDt ,
                          PrincOverdueSinceDt ,
                          IntOverdueSinceDt ,
                          OtherOverdueSinceDt ,
                          RefPeriodIntService ,
                          RefPeriodNoCredit ,
                          RefPeriodOverDrawn ,
                          RefPeriodOverdue ,
                          RefPeriodReview ,
                          RefPeriodStkStatement ,
                          A.DegDate ,
                          b.EffectiveFromTimeKey ,
                          b.EffectiveToTimeKey 
        FROM PRO_RBL_MISDB_PROD.AccountCal_Hist B
               JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
       WHERE  A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey;

   EXECUTE IMMEDIATE ' ALTER TABLE DPD 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   --------
   IF v_TIMEKEY > 26267 THEN

   BEGIN
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, Process_Date) + 1
      ELSE 0
         END) AS pos_2, (CASE 
      WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, Process_Date) + 1
      ELSE 0
         END) AS pos_3, (CASE 
      WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, Process_Date) + 1
      ELSE 0
         END) AS pos_4
      FROM A ,DPD A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_PrincOverdue = pos_2,
                                   A.DPD_IntOverdueSince = pos_3,
                                   A.DPD_OtherOverdueSince = pos_4;

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
         END) AS pos_4
      FROM A ,DPD A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_PrincOverdue = pos_2,
                                   A.DPD_IntOverdueSince = pos_3,
                                   A.DPD_OtherOverdueSince = pos_4;

   END;
   END IF;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE DPD
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE DPD
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE DPD
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE DPD
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE DPD
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE DPD
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE DPD
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE DPD
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE DPD
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,DPD A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_45') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_45 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_45;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_45');

   INSERT INTO tt_TEMPTABLE_45 ( 
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
   	  FROM DPD A
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
   FROM A ,DPD A ) src
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
   FROM A ,DPD a
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
      SELECT c.Process_Date DateofData  ,
             A.UCIF_ID ,
             A.RefCustomerID CustomerID  ,
             A.CustomerAcID AccountID  ,
             c.DPD_Renewal ReviewRenewalDPD  ,
             c.DPD_StockStmt StockStatementDPD  ,
             c.DPD_NoCredit NoCreditDPD  ,
             dpd_overdrawn ContinuousExcessDPD  ,
             dpd_overdue OverdueDPD  ,
             A.DebitSinceDt ,
             c.DPD_PrincOverdue PrincipleOverdue  ,
             c.DPD_IntOverdueSince InterestOverdue  ,
             c.DPD_IntService OutofOrderDPD  
        FROM PRO_RBL_MISDB_PROD.AccountCal_Hist a
               JOIN AccountForDPD b   ON a.CustomerAcID = b.account_no
               JOIN DPD c   ON a.CustomerAcID = c.CustomerACID
               AND C.EffectiveFromTimeKey <= v_Timekey
               AND C.EffectiveToTimeKey >= v_Timekey
       WHERE  a.EffectiveFromTimeKey <= v_Timekey
                AND a.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DPD_CALCULATION_HISTDATA_04122023" TO "ADF_CDR_RBL_STGDB";
