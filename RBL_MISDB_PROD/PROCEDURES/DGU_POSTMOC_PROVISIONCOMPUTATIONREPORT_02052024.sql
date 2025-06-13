--------------------------------------------------------
--  DDL for Procedure DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" 
AS
   --DECLARE @Timekey int =(select timekey from PostMOCTimeKey) 
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N' );
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

   --------------------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_ADVACRESTRUCTUREDETAIL_2') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ADVACRESTRUCTUREDETAIL_2 ';
   END IF;
   DELETE FROM tt_ADVACRESTRUCTUREDETAIL_2;
   UTILS.IDENTITY_RESET('tt_ADVACRESTRUCTUREDETAIL_2');

   INSERT INTO tt_ADVACRESTRUCTUREDETAIL_2 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY RefSystemAcId ORDER BY RefSystemAcId, EffectiveFromTimeKey DESC, EntityKey DESC  ) rn  
               FROM ADVACRESTRUCTUREDETAIL RES
                WHERE  RES.EffectiveFromTimeKey <= v_Timekey
                         AND RES.EffectiveToTimeKey >= v_Timekey ) aa
       WHERE  rn = 1;
   ------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_PrevQtrDataAccountWise_2') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrDataAccountWise_2 ';
   END IF;
   DELETE FROM tt_PrevQtrDataAccountWise_2;
   UTILS.IDENTITY_RESET('tt_PrevQtrDataAccountWise_2');

   INSERT INTO tt_PrevQtrDataAccountWise_2 ( 
   	SELECT A.CustomerEntityID ,
           b.AccountEntityID ,
           NetBalance ,
           SecuredAmt ,
           UnSecuredAmt ,
           TotalProvision ,
           Provsecured ,
           CustomerAcID ,
           ProvUnsecured ,
           NVL(NetBalance, 0) - NVL(totalprovision, 0) NetNPA  
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
             JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  B.EffectiveFromTimeKey <= v_LastQtrDateKey
              AND b.EffectiveToTimeKey >= v_LastQtrDateKey
              AND A.EffectiveFromTimeKey <= v_LastQtrDateKey
              AND A.EffectiveToTimeKey >= v_LastQtrDateKey
              AND B.FinalAssetClassAlt_Key > 1 );
   -------------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_PrevQtrData_2') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrData_2 ';
   END IF;
   DELETE FROM tt_PrevQtrData_2;
   UTILS.IDENTITY_RESET('tt_PrevQtrData_2');

   INSERT INTO tt_PrevQtrData_2 ( 
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
   IF tt_dpd2_19  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_dpd2_19;
   UTILS.IDENTITY_RESET('tt_dpd2_19');

   INSERT INTO tt_dpd2_19 ( 
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

   EXECUTE IMMEDIATE ' ALTER TABLE tt_dpd2_19 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0, 0, 0, 0, 0
   FROM A ,tt_dpd2_19 a ) src
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
   --select * from tt_dpd2_19  
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
      FROM A ,tt_dpd2_19 A ) src
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
      FROM A ,tt_dpd2_19 A ) src
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
   UPDATE tt_dpd2_19
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_dpd2_19
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   --UPDATE A SET DPD_NoCredit=0 FROM tt_dpd2_19 A   
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_34') IS NOT NULL THEN
    --DECLARE @Timekey int =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')
   --DECLARE @Timekey int =   
   --(26376)  
   --DECLARE @Date date =  (select Date from Automate_Advances where Timekey = @Timekey)  
   --DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (@Timekey))  
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_34 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_34;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_34');

   INSERT INTO tt_TEMPTABLE_34 ( 
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
   	  FROM tt_dpd2_19 A
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
   FROM A ,tt_dpd2_19 A ) src
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
   FROM A ,tt_dpd2_19 a
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
   EXECUTE IMMEDIATE ' TRUNCATE TABLE ProvisionComputation_PostMOC_Automate ';
   INSERT INTO ProvisionComputation_PostMOC_Automate
     SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
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
            CASE 
                 WHEN B.SecApp = 'S' THEN 'SECURED'
            ELSE 'UNSECURED'
               END Secured_Unsecured  ,
            ActSegmentCode Seg_Code  ,
            (CASE 
                  WHEN SourceName IN ( 'Ganaseva','FIS' )
                   THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
            ELSE AcBuSegmentDescription
               END) Segment_Description  ,
            CASE 
                 WHEN SourceName IN ( 'Ganaseva','FIS' )
                  THEN 'FI'

                 --WHEN SourceName='VisionPlus' THEN 'Credit Card'  
                 WHEN SourceName = 'VisionPlus'
                   AND B.ProductCode IN ( '777','780' )
                  THEN 'Retail'
                 WHEN SourceName = 'VisionPlus'
                   AND B.ProductCode NOT IN ( '777','780' )
                  THEN 'Credit Card'
            ELSE AcBuRevisedSegmentCode
               END Business_Segment  ,
            DPD_Max Account_DPD  ,
            --,CD [Cycle Past due]  
            FinalNpaDt NPA_Date  ,
            A2.AssetClassName Asset_Classification  ,
            B.REFPERIODOVERDUE NPA_Norms ,--NPANorms as [NPA Norms]   

            B.NetBalance Balance_Outstanding  ,
            CurntQtrRv Customer_Security_Value  ,
            -----,SecurityValue as [Account Security Value]   -- TO BE REMOVED  
            ApprRV Security_Value_Appropriated  ,
            B.SecuredAmt Secured_Outstanding  ,
            B.UnSecuredAmt Unsecured_Outstanding  ,
            B.TotalProvision Provision_Total  ,
            B.Provsecured Provision_Secured  ,
            B.ProvUnsecured Provision_Unsecured  ,
            NVL((B.NetBalance - B.TotalProvision), 0) Net_NPA  ,
            UTILS.CONVERT_TO_NUMBER((NVL((B.Provsecured / NULLIF(B.SecuredAmt, 0)) * 100, 0)),5,2) ProvisionSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((B.ProvUnsecured / NULLIF(B.UnSecuredAmt, 0)) * 100, 0)),5,2) ProvisionUnSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((B.TotalProvision / NULLIF(B.NetBalance, 0)) * 100, 0)),5,2) ProvisionTotal_  ,
            NVL(Y.NetBalance, 0) Prev_Qtr_Balance_Outstanding  ,
            NVL(Y.SecuredAmt, 0) Prev_Qtr_Secured_Outstanding  ,
            NVL(Y.UnSecuredAmt, 0) Prev_Qtr_Unsecured_Outstanding  ,
            NVL(Y.TotalProvision, 0) Prev_Qtr_Provision_Total  ,
            NVL(Y.Provsecured, 0) Prev_Qtr_Provision_Secured  ,
            NVL(Y.ProvUnsecured, 0) Prev_Qtr_Provision_Unsecured  ,
            NVL(Y.NetNPA, 0) Prev_Qtr_Net_NPA  ,
            ----Remove column 28042022  
            /*  
            ,CASE WHEN ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) < 0   
               then 0   
              ELSE ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0)   
             END NPAIncrease  
            ,CASE WHEN ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) >= 0 then 0   
            ELSE ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) END NPADecrease  
            ,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) < 0 then 0   
            ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionIncrease  
            ,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) >= 0 then 0   
            ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionDecrease  
            ,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - y.NetNPA),0) < 0 then 0   
            ELSE ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) END NetNPAIncrease  
            ,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) >= 0 then 0 ELSE ISNULL(((B.NetBalance-B.TotalProvision) - ISNULL(y.NetNPA,0)),0) END NetNPAnDecrease  

            */
            B.AccountBlkCode2 Block_Code_V_  ,
            B.Addlprovision Additional_Provision  ,
            EXPS.StatusType StatusType_1  ,
            -------PREV QTR DATA  
            A3.AssetClassName PREV_QTR_Asset_Classification  ,
            PREV.Addlprovision PREV_QTR_Additional_Provision  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.Provsecured / NULLIF(PREV.SecuredAmt, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.ProvUnsecured / NULLIF(PREV.UnSecuredAmt, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionUnSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.TotalProvision / NULLIF(PREV.NetBalance, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionTotal_  ,
            Dimp.ParameterName TypeofRestructring  ,
            EXPS.StatusType 
       FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
              JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
              AND NVL(B.WriteOffAmount, 0) = 0
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
              LEFT JOIN tt_PrevQtrDataAccountWise_2 Y   ON A.CustomerEntityID = Y.CustomerEntityID
              AND b.CustomerAcID = Y.CustomerAcID
              LEFT JOIN tt_dpd2_19 DPD   ON B.AccountEntityID = DPD.AccountEntityID
              LEFT JOIN tt_PrevQtrData_2 prev   ON B.AccountEntityID = PREV.ACCOUNTENTITYID
              LEFT JOIN DimAssetClass a3   ON a3.EffectiveToTimeKey = 49999
              AND a3.AssetClassAlt_Key = prev.FinalAssetClassAlt_Key
              LEFT JOIN ( 
                          --LEFT JOIN ExceptionFinalStatusType    EXPS    ON EXPS.ACID=B.CustomerAcID  AND EXPS.EffectiveToTimeKey=49999  
                          SELECT DISTINCT SourceAlt_Key ,
                                          CustomerID ,
                                          ACID ,
                                          EffectiveToTimeKey ,
                                          utils.stuff(( SELECT ', ' || B.StatusType 
                                                        FROM ExceptionFinalStatusType B
                                                         WHERE  B.EffectiveToTimeKey = 49999
                                                                  AND B.ACID = A.ACID
                                                          ORDER BY B.ACID ), 1, 1, ' ') StatusType  
                          FROM ExceptionFinalStatusType A
                           WHERE  A.EffectiveToTimeKey = 49999 ) EXPS   ON EXPS.ACID = B.CustomerAcID
              AND EXPS.EffectiveToTimeKey = 49999
              LEFT JOIN tt_ADVACRESTRUCTUREDETAIL_2 RES   ON RES.AccountEntityId = B.AccountEntityID
              AND RES.EffectiveFromTimeKey <= v_Timekey
              AND RES.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN ( SELECT ParameterAlt_Key ,
                                 ParameterName 
                          FROM DimParameter 
                           WHERE  DimParameterName = 'TypeofRestructuring'
                                    AND EffectiveFromTimeKey <= v_Timekey
                                    AND EffectiveToTimeKey >= v_Timekey ) DIMP   ON DIMP.ParameterAlt_Key = RES.RestructureTypeAlt_Key
      WHERE  B.FinalAssetClassAlt_Key > 1
               AND b.EffectiveFromTimeKey <= v_Timekey
               AND B.EffectiveToTimeKey >= v_Timekey
               AND A.EffectiveFromTimeKey <= v_Timekey
               AND A.EffectiveToTimeKey >= v_Timekey;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_POSTMOC_PROVISIONCOMPUTATIONREPORT_02052024" TO "ADF_CDR_RBL_STGDB";
