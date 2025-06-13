--------------------------------------------------------
--  DDL for Procedure SP_SMAOUTPUT_1_04112023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" 
AS
   v_TIMEKEY NUMBER(10,0) := ( SELECT timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'y' );
   --DECLARE @TIMEKEY INT='26479'
   --select * from Automate_Advances where date='2022-06-30'
   v_PROCESSDATE VARCHAR2(200);

 --accountwise
BEGIN

   SELECT DATE_ 

     INTO v_PROCESSDATE
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY;---972953
   ---------------------------======================================DPD Calculation Start===========================================
   --Drop table if exists   tt_DPD_49 
   IF utils.object_id('TEMPDB..tt_DPD_49') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_49 ';
   END IF;
   DELETE FROM tt_DPD_49;
   UTILS.IDENTITY_RESET('tt_DPD_49');

   INSERT INTO tt_DPD_49 ( 
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
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_49 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_MAX NUMBER(10,0) , DPD_UCIF_ID NUMBER(10,0) ] ) ';
   ----/*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   --UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)			   
   --             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
   --			 ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)
   --			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)   ELSE 0 END) 
   --			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)
   --			 ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)       ELSE 0 END)
   --FROM tt_DPD_49 A 
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
   FROM tt_DPD_49 A 

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
   FROM tt_DPD_49 A 

   end

   */
   -----------------------------------
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
      FROM A ,tt_DPD_49 A ) src
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
      FROM A ,tt_DPD_49 A ) src
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
   /* AMAR --DEBIT SINCE DATE DPD CALCULATION AND UPDATE IN DPD_Overdrawn AS DISCUSSED WITH SHARMA SIR AND  TRILOKI SIR ON 31082021 */
   /*   amar --commented as per call by Ashish Sir on 02092021

   UPDATE A SET A.DPD_Overdrawn= (CASE WHEN   A.DebitSinceDt IS NOT NULL    THEN DATEDIFF(DAY,A.DebitSinceDt,  @ProcessDate) + 1    ELSE 0 END) 
   FROM PRO.AccountCal A
   	INNER JOIN DimProduct B
   		ON (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY)
   		AND A.ProductAlt_Key=B.ProductAlt_Key
   	WHERE B.SchemeType='ODA'
   		AND ISNULL(A.CurrentLimit,0)=0 and ContiExcessDt IS 
   		*/
   --------
   -----------------------------
   ----/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_DPD_49
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD_49
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD_49
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD_49
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD_49
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD_49
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_49 A 
    WHERE NVL(DPD_Overdrawn, 0) <= 30) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Overdrawn = 0;
   ----	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_49 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0
   FROM A ,tt_DPD_49 A 
    WHERE Asset_Norm = 'ALWYS_STD') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Overdrawn = 0,
                                A.DPD_Overdue = 0,
                                A.DPD_IntService = 0,
                                A.DPD_NoCredit = 0,
                                A.DPD_Renewal = 0;
   ----		/*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN NVL(A.DPD_Overdrawn, 0) > NVL(A.DPD_Overdue, 0) THEN NVL(A.DPD_Overdrawn, 0)
   ELSE NVL(A.DPD_Overdue, 0)
      END) AS DPD_Max
   FROM A ,tt_DPD_49 a 
    WHERE ( NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0 )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   --UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)
   --								   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)
   --								   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)
   --								   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)
   --								   WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)
   --								   ELSE isnull(A.DPD_StockStmt,0) END) 
   --FROM  tt_DPD_49 a 
   --WHERE  
   --(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
   --isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_49_UCIF_ID  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_UCIF_ID_12;
   UTILS.IDENTITY_RESET('tt_DPD_UCIF_ID_12');

   INSERT INTO tt_DPD_UCIF_ID_12 ( 
   	SELECT UCIF_ID ,
           MAX(DPD_MAX)  DPD_UCIF_ID  
   	  FROM tt_DPD_49 
   	  GROUP BY UCIF_ID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.DPD_UCIF_ID
   FROM A ,tt_DPD_49 A
          JOIN tt_DPD_UCIF_ID_12 B   ON A.UCIF_ID = B.UCIF_ID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_UCIF_ID = src.DPD_UCIF_ID;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE SMA_OUTPUT ';
   INSERT INTO SMA_OUTPUT
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
                 WHEN SourceName = 'FIS' THEN 'FI'
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
              JOIN tt_DPD_49 DPD   ON DPD.AccountEntityID = A.AccountEntityID
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMAOUTPUT_1_04112023" TO "ADF_CDR_RBL_STGDB";
