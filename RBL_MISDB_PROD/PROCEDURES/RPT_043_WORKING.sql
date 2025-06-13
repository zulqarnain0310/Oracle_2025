--------------------------------------------------------
--  DDL for Procedure RPT_043_WORKING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_043_WORKING" 
--USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[Rpt-043_working]    Script Date: 7/7/2022 2:59:48 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

(
  v_Timekey IN NUMBER
)
AS
   --DECLARE @TIMEKEY INT=26449  
   v_cursor SYS_REFCURSOR;

BEGIN

   DECLARE
      --DECLARE @TIMEKEY INT=(select timekey from Automate_Advances where Ext_flg = 'y')  
      --select * from SysDayMatrix where date='2022-05-31'
      v_PROCESSDATE VARCHAR2(200);
   --select * from sys.database_files;  
   -----SMAOUTPut UCIF Id Wise -------   

   BEGIN
      OPEN  v_cursor FOR
         SELECT timekey 
           FROM Automate_Advances 
          WHERE  Ext_flg = 'y' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      SELECT DATE_ 

        INTO v_PROCESSDATE
        FROM SysDayMatrix 
       WHERE  TIMEKEY = v_TIMEKEY;---972953  
      ---------------------------======================================DPD Calculation Start===========================================  
      IF utils.object_id('TEMPDB..tt_accountcal_hist') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_accountcal_hist ';
      END IF;
      DELETE FROM tt_accountcal_hist;
      UTILS.IDENTITY_RESET('tt_accountcal_hist');

      INSERT INTO tt_accountcal_hist ( 
      	SELECT * 
      	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
      	 WHERE  EffectiveFromTimeKey <= v_TIMEKEY
                 AND EffectiveToTimeKey >= v_TIMEKEY );
      --Drop table if exists   tt_DPD_33   
      IF utils.object_id('TEMPDB..tt_DPD_33') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_33 ';
      END IF;
      IF utils.object_id('TEMPDB..tt_A_37') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_37 ';
      END IF;
      DELETE FROM tt_DPD_33;
      UTILS.IDENTITY_RESET('tt_DPD_33');

      INSERT INTO tt_DPD_33 ( 
      	SELECT AccountEntityID ,
              UcifEntityID ,
              CustomerEntityID ,
              CustomerAcID ,
              RefCustomerID ,
              SourceSystemCustomerID ,
              UCIF_ID ,
              IntNotServicedDt ,
              LastCrDate ,
              ContiExcessDt ,
              OverDueSinceDt ,
              ReviewDueDt ,
              StockStDt ,
              RefPeriodIntService ,
              RefPeriodNoCredit ,
              RefPeriodOverDrawn ,
              RefPeriodOverdue ,
              RefPeriodReview ,
              RefPeriodStkStatement ,
              SourceAlt_Key ,
              DebitSinceDt ,
              Asset_Norm 
      	  FROM tt_accountcal_hist 
      	 WHERE  EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey );
      --and RefCustomerID='10105993'  
      --And UcifEntityID=2408867 
      --and UCIF_ID='RBL001858036'

      EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_33 
         ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_MAX NUMBER(10,0) , DPD_UCIF_ID NUMBER(10,0) ] ) ';
      ----/*---------- CALCULATED ALL DPD---------------------------------------------------------*/  
      --UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)        
      --             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)  
      --    ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)  
      --    ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)   ELSE 0 END)   
      --    ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)  
      --    ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)       ELSE 0 END)  
      --FROM tt_DPD_33 A   
      /*
      if @TIMEKEY >26267  
      begin  
      UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)        
      ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)  
                   ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>90)  
                 THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+1 ELSE 0 END)  
               ELSE 0 END  

          ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)   
          ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)   
          ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)  
          ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate) +1     ELSE 0 END)  
      FROM tt_DPD_33 A   

      end  
      else  
      begin  

      UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)        
      ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)  
                   ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>90)  
                 THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)  ELSE 0 END)  
               ELSE 0 END  

          ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)   
          ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)  ELSE 0 END)   
          ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)  
          ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)     ELSE 0 END)  
      FROM tt_DPD_33 A   

      end  
       */
      --------------------------------------------------------------
      IF v_TIMEKEY > 26267 THEN

       ----IMPLEMENTED FROM 2021-12-01 
      BEGIN
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN v_TIMEKEY > 26384 THEN (CASE 
                                           WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_ProcessDate) + 2
         ELSE 0
            END)
         ELSE (CASE 
         WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_ProcessDate) + 1
         ELSE 0
            END)
            END AS pos_2, CASE 
         WHEN ( DebitSinceDt IS NULL
           OR utils.datediff('DAY', DebitSinceDt, v_ProcessDate) > 90 ) THEN (CASE 
                                                                                   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_ProcessDate) + 1
         ELSE 0
            END)
         ELSE 0
            END AS pos_3, (CASE 
         WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_ProcessDate) + 1
         ELSE 0
            END) AS pos_4, CASE 
         WHEN v_TIMEKEY > 26372 THEN (CASE 
                                           WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_ProcessDate) + 1
         ELSE 0
            END)
         ELSE (CASE 
         WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_ProcessDate) + (CASE 
                                                                                                               WHEN SourceAlt_Key = 6 THEN 0
         ELSE 1
            END)
         ELSE 0
            END)
            END AS pos_5, (CASE 
         WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_ProcessDate) + 1
         ELSE 0
            END) AS pos_6, (CASE 
         WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_ProcessDate) + 1
         ELSE 0
            END) AS pos_7
         FROM A ,tt_DPD_33 A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_IntService --28032022 amar - implemmented 90 days summation ccod credit and intt logic
                                       ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
                                       = pos_2,
                                      A.DPD_NoCredit = pos_3,
                                      A.DPD_Overdrawn = pos_4,
                                      A.DPD_Overdue
                                      ------ AMAR - CHANGES ON 17032021 AS PER EMAIL BY ASHISH SIR DATED - 17-03-2021 1:59 PM - SUBJECT - Credit Card NPA Computation  -- 
                                       = pos_5,
                                      A.DPD_Renewal = pos_6,
                                      A.DPD_StockStmt = pos_7;

      END;
      ELSE

      BEGIN
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_ProcessDate)
         ELSE 0
            END) AS pos_2, CASE 
         WHEN ( DebitSinceDt IS NULL
           OR utils.datediff('DAY', DebitSinceDt, v_ProcessDate) > 90 ) THEN (CASE 
                                                                                   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_ProcessDate)
         ELSE 0
            END)
         ELSE 0
            END AS pos_3, (CASE 
         WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_ProcessDate) + 1
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
         FROM A ,tt_DPD_33 A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DPD_IntService
                                      ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
                                       = pos_2,
                                      A.DPD_NoCredit = pos_3,
                                      A.DPD_Overdrawn = pos_4,
                                      A.DPD_Overdue = pos_5,
                                      A.DPD_Renewal = pos_6,
                                      A.DPD_StockStmt = pos_7;

      END;
      END IF;
      -------------------------------------------------------------
      ----/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/  
      UPDATE tt_DPD_33
         SET DPD_IntService = 0
       WHERE  NVL(DPD_IntService, 0) < 0;
      UPDATE tt_DPD_33
         SET DPD_NoCredit = 0
       WHERE  NVL(DPD_NoCredit, 0) < 0;
      UPDATE tt_DPD_33
         SET DPD_Overdrawn = 0
       WHERE  NVL(DPD_Overdrawn, 0) < 0;
      UPDATE tt_DPD_33
         SET DPD_Overdue = 0
       WHERE  NVL(DPD_Overdue, 0) < 0;
      UPDATE tt_DPD_33
         SET DPD_Renewal = 0
       WHERE  NVL(DPD_Renewal, 0) < 0;
      UPDATE tt_DPD_33
         SET DPD_StockStmt = 0
       WHERE  NVL(DPD_StockStmt, 0) < 0;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, 0
      FROM A ,tt_DPD_33 A 
       WHERE NVL(DPD_Overdrawn, 0) <= 30) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_Overdrawn = 0;
      ---- /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/  
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, 0
      FROM A ,tt_DPD_33 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0
      FROM A ,tt_DPD_33 A 
       WHERE Asset_Norm = 'ALWYS_STD') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_Overdrawn = 0,
                                   A.DPD_Overdue = 0,
                                   A.DPD_IntService = 0,
                                   A.DPD_NoCredit = 0,
                                   A.DPD_Renewal = 0;
      ----  /*----------------FIND MAX DPD---------------------------------------*/  
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN NVL(A.DPD_Overdrawn, 0) > NVL(A.DPD_Overdue, 0) THEN NVL(A.DPD_Overdrawn, 0)
      ELSE NVL(A.DPD_Overdue, 0)
         END) AS DPD_Max
      FROM A ,tt_DPD_33 a 
       WHERE ( NVL(A.DPD_Overdrawn, 0) > 0
        OR NVL(A.DPD_Overdue, 0) > 0 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
      --UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(
      --A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)  
      --           WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isn
      --ull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)  
      --           WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isn
      --ull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)  
      --           WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND is
      --null(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)  
      --           WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND is
      --null(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)  
      --           ELSE isnull(A.DPD_StockStmt,0) END)   
      --FROM  tt_DPD_33 a   
      --WHERE    
      --(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0  OR isnull(A.DPD_Renewal,0) >0 OR  
      --isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)  
      TABLE IF  --SQLDEV: NOT RECOGNIZED
      IF tt_DPD_33_UCIF_ID  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_DPD_UCIF_ID_4;
      UTILS.IDENTITY_RESET('tt_DPD_UCIF_ID_4');

      INSERT INTO tt_DPD_UCIF_ID_4 ( 
      	SELECT UCIF_ID ,
              MAX(DPD_MAX)  DPD_UCIF_ID  
      	  FROM tt_DPD_33 
      	  GROUP BY UCIF_ID );
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, B.DPD_UCIF_ID
      FROM A ,tt_DPD_33 A
             JOIN tt_DPD_UCIF_ID_4 B   ON A.UCIF_ID = B.UCIF_ID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_UCIF_ID = src.DPD_UCIF_ID;
      -----------------------------------------------------------------
      DELETE FROM tt_A_37;
      UTILS.IDENTITY_RESET('tt_A_37');

      INSERT INTO tt_A_37 ( 
      	SELECT 'a' CurrentProcessingDate  ,
              --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo  
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
              DPD.DPD_UCIF_ID ,
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
              A.Asset_Norm ,
              A.REFPeriodMax AssetRefPeriod  

      	  --select 
      	  FROM tt_accountcal_hist A
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
                JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist F   ON F.UcifEntityID = A.UcifEntityID

                --INNER JOIN Pro.CustomerCal_hist F On F.CustomerEntityID=A.CustomerEntityID  
                AND F.EffectiveFromTimeKey <= v_TIMEKEY
                AND F.EffectiveToTimeKey >= v_TIMEKEY
                JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey
                JOIN DIMSOURCEDB H   ON H.SourceAlt_Key = A.SourceAlt_Key
                AND H.EffectiveFromTimeKey <= v_TIMEKEY
                AND H.EffectiveToTimeKey >= v_TIMEKEY
                JOIN tt_DPD_33 DPD   ON DPD.AccountEntityID = A.AccountEntityID
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
                 AND F.FlgSMA = 'Y' );

   END;
   --and A.UCIF_ID='RBL001858036'
   --and A.RefCustomerID='10105993'  
   --And A.UcifEntityID=2408867  
   --order by A.UcifEntityID,A.RefCustomerID  
   IF utils.object_id('tEMPDB..tt_B') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_B ';
   END IF;
   --SELECT * FROM tt_A_37

   --Select sum(balance) Balance,UCIF_ID,Max(balance)  MaxBal,bRANCHCODE

   ----into tt_B 

   --from tt_A_37

   --group by UCIF_ID,bRANCHCODE
   IF utils.object_id('Tempdb..tt_B') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_B ';
   END IF;
   IF utils.object_id('Tempdb..tt_BALANCE') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BALANCE ';
   END IF;
   --Declare @BAL decimal(30,2)
   --set @Bal=(
   DELETE FROM tt_BALANCE;
   UTILS.IDENTITY_RESET('tt_BALANCE');

   INSERT INTO tt_BALANCE ( 
   	SELECT SUM(Balance)  BALAN  ,
           UCIF_ID 
   	  FROM tt_A_37 
   	  GROUP BY UCIF_ID );
   DELETE FROM tt_B;
   UTILS.IDENTITY_RESET('tt_B');

   INSERT INTO tt_B ( 
   	SELECT CurrentProcessingDate ,
           BranchCode ,
           BranchName ,
           BranchStateName ,
           UCIF_ID ,
           PANNO ,
           CustomerName ,
           ActSegmentCode ,
           AcBuRevisedSegmentCode ,
           NULL Balance  ,
           UCICFlgSMA ,
           UCICSMA_Dt ,
           UCICSMA_AssetStatus ,
           NULL MovementFromDate  ,
           NULL MovementFromStatus  ,
           CustomerID ,
           NULL MovementToStatus  ,
           SMA_DPD 
   	  FROM tt_A_37 
   	 WHERE  balance IN ( SELECT MAX(balance)  
                         FROM tt_A_37 
                           GROUP BY UCIF_ID )

   	  GROUP BY CurrentProcessingDate,BranchCode,BranchName,BranchStateName,UCIF_ID,PANNO,CustomerName,ActSegmentCode,AcBuRevisedSegmentCode,UCICFlgSMA,UCICSMA_Dt,UCICSMA_AssetStatus,SMA_DPD,CustomerID );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_B 
      ADD ( [TL_DPD NUMBER(10,0) , OD_DPD NUMBER(10,0) , CC_DPD NUMBER(10,0) , BILL_DPD NUMBER(10,0) , PC_DPD NUMBER(10,0) , WCDL_DPD NUMBER(10,0) , BG_InvokedDPD NUMBER(10,0) , LC_DPD NUMBER(10,0) , Other_DPD NUMBER(10,0) ] ) ';
   IF utils.object_id('tempdb..tt_DP') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DP ';
   END IF;
   DELETE FROM tt_DP;
   UTILS.IDENTITY_RESET('tt_DP');

   INSERT INTO tt_DP ( 
   	SELECT (SMA_DPD) DPD  ,
           FACILITYTYPE ,
           UCIF_ID 
   	  FROM tt_A_37 A );
   --Group BY FACILITYTYPE,UCIF_ID
   IF utils.object_id('tempdb..tt_F_DPD') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_F_DPD ';
   END IF;
   DELETE FROM tt_F_DPD;
   UTILS.IDENTITY_RESET('tt_F_DPD');

   INSERT INTO tt_F_DPD ( 
   	SELECT MAX(DPD)  DPD  ,
           UCIF_ID 
   	  FROM tt_DP 
   	  GROUP BY UCIF_ID );--where UCIF_ID='RBL001858036'
   --select * from tt_F_DPD where UCIF_ID='RBL001858036'
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.DPD
   FROM B ,tt_B B
          JOIN tt_DP A   ON A.UCIF_ID = B.UCIF_ID 
    WHERE A.FacilityType = 'TL') src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.TL_DPD = src.DPD;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.DPD
   FROM B ,tt_B B
          JOIN tt_DP A   ON A.UCIF_ID = B.UCIF_ID 
    WHERE A.FacilityType = 'BILL') src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.BILL_DPD = src.DPD;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.DPD
   FROM B ,tt_B B
          JOIN tt_DP A   ON A.UCIF_ID = B.UCIF_ID 
    WHERE A.FacilityType = 'PC') src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.PC_DPD = src.DPD;
   --Update B
   --SET DL_DPD=A.DPD 
   --FROM tt_B B
   --INNER JOIN tt_DP A  ON A.UCIF_ID=B.UCIF_ID
   --WHERE A.FacilityType='DL'
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.DPD
   FROM B ,tt_B B
          JOIN tt_DP A   ON A.UCIF_ID = B.UCIF_ID 
    WHERE A.FacilityType = 'CC') src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.CC_DPD = src.DPD;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.DPD
   FROM B ,tt_B B
          JOIN tt_DP A   ON A.UCIF_ID = B.UCIF_ID 
    WHERE A.FacilityType = 'OD') src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.OD_DPD = src.DPD;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.Balan
   FROM A ,tt_BALANCE B
          JOIN tt_B A   ON A.UCIF_ID = B.UCIF_ID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Balance = src.Balan;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.DPD
   FROM B ,tt_B B
          JOIN tt_F_DPD A   ON A.UCIF_ID = B.UCIF_ID ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.SMA_DPD = src.DPD;
   ----select MAX(DPD) from tt_DP where UCIF_ID='RBL001858036'
   MERGE INTO b 
   USING (SELECT b.ROWID row_id, A.CustMoveDescription
   FROM b ,tt_B b
          JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist a   ON a.UCIF_ID = b.UCIF_ID 
    WHERE a.EffectiveFromTimeKey <= v_timekey - 1
     AND a.EffectiveToTimeKey >= v_TIMEKEY - 1) src
   ON ( b.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET b.UCIC_Level_Previous_Status = src.CustMoveDescription;
   OPEN  v_cursor FOR
      SELECT CurrentProcessingDate ,
             BranchCode ,
             BranchName ,
             BranchStateName ,
             UCIF_ID ,
             PANNO ,
             CustomerName ,
             CustomerID ,
             ActSegmentCode CustSegmentCode  ,
             AcBuRevisedSegmentCode BusinessSegment  ,
             NULL RM_Code_Name  ,
             NULL UCIC_Exposure  ,
             Balance Balance_AS_UCIC_Level  ,
             NULL NFB_OS  ,
             TL_DPD ,
             OD_DPD ,
             CC_DPD ,
             BILL_DPD ,
             PC_DPD ,
             WCDL_DPD ,
             BG_InvokedDPD ,
             LC_DPD ,
             Other_DPD ,
             SMA_DPD MAX_DPD  ,
             UCICFlgSMA ,
             UCICSMA_Dt ,
             UCICSMA_AssetStatus ,
             UCICSMA_Dt Previous_Status_Satrt_Date  ,
             NULL UCIC_Level_Previous_Status --UCICSMA_AssetStatus


        --,MovementFromDate

        --,MovementFromStatus

        --,MovementToStatus
        FROM tt_B --where  UCIF_ID='RBL001858036'
               ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select * from tt_B where UCIF_ID='RBL001858036'
   --RM Code & Name	UCIC Exposure	Balance on UCIF Level		TL DPD	OD DPD	CC DPD	BILL DPD	PC DPD	WCDL DPD	BG Invoked DPD	
   --LC DPD	Other DPD	Max DPD	UCICFlgSMA	UCICSMA_Dt	UCICSMA_AssetStatus
   --MovementFromDate	MovementFromStatus	MovementToStatus
   --from tt_A_37

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_043_WORKING" TO "ADF_CDR_RBL_STGDB";
