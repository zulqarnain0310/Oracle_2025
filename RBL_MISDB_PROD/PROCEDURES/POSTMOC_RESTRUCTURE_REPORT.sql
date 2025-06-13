--------------------------------------------------------
--  DDL for Procedure POSTMOC_RESTRUCTURE_REPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" 
AS
   --======================================================================================================
   -- CREATED BY : MANDEEP SINGH
   -- DATE       : 07-03-2024
   -- PURPOSE    : PostMOC_Restructure_Report
   -- EXEC       : PostMOC_Restructure_Report 
   --======================================================================================================
   v_DATE VARCHAR2(200) := ( SELECT MonthLastDate 
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N' );
   v_cursor SYS_REFCURSOR;

BEGIN

   ------------------------------------------------------------------------------------------------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ACCOUNTCAL_52  --SQLDEV: NOT RECOGNIZED
   tt_ACCOUNTCAL_52 TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ADVACRESTRUCTURECAL_2  --SQLDEV: NOT RECOGNIZED
   tt_ADVACRESTRUCTURECAL_2 TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_CUSTOMERCAL_53  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_ACCOUNTCAL_52;
   UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_52');

   INSERT INTO tt_ACCOUNTCAL_52 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
   DELETE FROM tt_ADVACRESTRUCTURECAL_2;
   UTILS.IDENTITY_RESET('tt_ADVACRESTRUCTURECAL_2');

   INSERT INTO tt_ADVACRESTRUCTURECAL_2 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AdvAcRestructureCal_Hist 
   	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
   DELETE FROM tt_CUSTOMERCAL_53;
   UTILS.IDENTITY_RESET('tt_CUSTOMERCAL_53');

   INSERT INTO tt_CUSTOMERCAL_53 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
   	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
              AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
   -------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_UcifEntityID_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UcifEntityID_6 ';
   END IF;
   DELETE FROM tt_UcifEntityID_6;
   UTILS.IDENTITY_RESET('tt_UcifEntityID_6');

   INSERT INTO tt_UcifEntityID_6 ( 
   	SELECT DISTINCT UcifEntityID 
   	  FROM tt_ACCOUNTCAL_52 A
             JOIN tt_ADVACRESTRUCTURECAL_2 b   ON a.AccountEntityID = b.AccountEntityId );
   IF utils.object_id('TEMPDB..tt_AccountEntityId_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountEntityId_2 ';
   END IF;
   DELETE FROM tt_AccountEntityId_2;
   UTILS.IDENTITY_RESET('tt_AccountEntityId_2');

   INSERT INTO tt_AccountEntityId_2 ( 
   	SELECT DISTINCT AccountEntityId 
   	  FROM tt_ACCOUNTCAL_52 A
             JOIN tt_UcifEntityID_6 b   ON a.UcifEntityID = b.UcifEntityID );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_ACCOUNTCAL_52 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) , DPD_FinMaxType NUMBER(10,0) ] ) ';
   UPDATE tt_ACCOUNTCAL_52
      SET IntNotServicedDt = NULL
    WHERE  ( IntNotServicedDt = '1900-01-01'
     OR IntNotServicedDt = '01/01/1900' );
   UPDATE tt_ACCOUNTCAL_52
      SET LastCrDate = NULL
    WHERE  ( LastCrDate = '1900-01-01'
     OR LastCrDate = '01/01/1900' );
   UPDATE tt_ACCOUNTCAL_52
      SET ContiExcessDt = NULL
    WHERE  ( ContiExcessDt = '1900-01-01'
     OR ContiExcessDt = '01/01/1900' );
   UPDATE tt_ACCOUNTCAL_52
      SET OverDueSinceDt = NULL
    WHERE  ( OverDueSinceDt = '1900-01-01'
     OR OverDueSinceDt = '01/01/1900' );
   UPDATE tt_ACCOUNTCAL_52
      SET ReviewDueDt = NULL
    WHERE  ( ReviewDueDt = '1900-01-01'
     OR ReviewDueDt = '01/01/1900' );
   UPDATE tt_ACCOUNTCAL_52
      SET StockStDt = NULL
    WHERE  ( StockStDt = '1900-01-01'
     OR StockStDt = '01/01/1900' );
   /*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0, 0, 0, 0, 0
   FROM A ,tt_ACCOUNTCAL_52 A ) src
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
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   IF v_TIMEKEY > 26267 THEN

    ----IMPLEMENTED FROM 2021-12-01 
   BEGIN
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN v_TIMEKEY > 26384 THEN (CASE 
                                        WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_date) + 2
      ELSE 0
         END)
      ELSE (CASE 
      WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_date) + 1
      ELSE 0
         END)
         END AS pos_2, CASE 
      WHEN ( DebitSinceDt IS NULL
        OR utils.datediff('DAY', DebitSinceDt, v_date) > 90 ) THEN (CASE 
                                                                         WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_date) + 1
      ELSE 0
         END)
      ELSE 0
         END AS pos_3, (CASE 
      WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_date) + 1
      ELSE 0
         END) AS pos_4, CASE 
      WHEN v_TIMEKEY > 26372 THEN (CASE 
                                        WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_date) + 1
      ELSE 0
         END)
      ELSE (CASE 
      WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_date) + (CASE 
                                                                                                     WHEN SourceAlt_Key = 6 THEN 0
      ELSE 1
         END)
      ELSE 0
         END)
         END AS pos_5, (CASE 
      WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_date) + 1
      ELSE 0
         END) AS pos_6, (CASE 
      WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_date) + 1
      ELSE 0
         END) AS pos_7
      FROM A ,tt_ACCOUNTCAL_52 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_IntService --28032022 amar - implemmented 90 days summation ccod credit and intt logic
                                    ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @date)       ELSE 0 END)
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
      WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_date)
      ELSE 0
         END) AS pos_2, CASE 
      WHEN ( DebitSinceDt IS NULL
        OR utils.datediff('DAY', DebitSinceDt, v_date) > 90 ) THEN (CASE 
                                                                         WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_date)
      ELSE 0
         END)
      ELSE 0
         END AS pos_3, (CASE 
      WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_date) + 1
      ELSE 0
         END) AS pos_4, (CASE 
      WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_date)
      ELSE 0
         END) AS pos_5, (CASE 
      WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_date)
      ELSE 0
         END) AS pos_6, (CASE 
      WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_date)
      ELSE 0
         END) AS pos_7
      FROM A ,tt_ACCOUNTCAL_52 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_IntService
                                   ---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @date)       ELSE 0 END)
                                    = pos_2,
                                   A.DPD_NoCredit = pos_3,
                                   A.DPD_Overdrawn = pos_4,
                                   A.DPD_Overdue = pos_5,
                                   A.DPD_Renewal = pos_6,
                                   A.DPD_StockStmt = pos_7;

   END;
   END IF;
   --------
   IF v_TIMEKEY > 26267 THEN

   BEGIN
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, v_date) + 1
      ELSE 0
         END) AS pos_2, (CASE 
      WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, v_date) + 1
      ELSE 0
         END) AS pos_3, (CASE 
      WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, v_date) + 1
      ELSE 0
         END) AS pos_4
      FROM A ,tt_ACCOUNTCAL_52 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_PrincOverdue = pos_2,
                                   A.DPD_IntOverdueSince = pos_3,
                                   A.DPD_OtherOverdueSince = pos_4;

   END;
   ELSE

   BEGIN
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, v_date)
      ELSE 0
         END) AS pos_2, (CASE 
      WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, v_date)
      ELSE 0
         END) AS pos_3, (CASE 
      WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, v_date)
      ELSE 0
         END) AS pos_4
      FROM A ,tt_ACCOUNTCAL_52 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_PrincOverdue = pos_2,
                                   A.DPD_IntOverdueSince = pos_3,
                                   A.DPD_OtherOverdueSince = pos_4;

   END;
   END IF;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_ACCOUNTCAL_52
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   -------------------------------------------------------------------------------------------------------------
   /* RESTR WORK */
   WITH CTE_FIN_DPD AS ( SELECT AccountEntityID ,
                                DPD_IntService DPD  
     FROM tt_ACCOUNTCAL_52 
    WHERE  NVL(DPD_IntService, 0) > 0
   UNION ALL 
   SELECT AccountEntityID ,
          DPD_NoCredit DPD  
     FROM tt_ACCOUNTCAL_52 
    WHERE  NVL(DPD_NoCredit, 0) > 0
   UNION ALL 
   SELECT AccountEntityID ,
          DPD_Overdrawn DPD  
     FROM tt_ACCOUNTCAL_52 
    WHERE  NVL(DPD_Overdrawn, 0) > 0
   UNION ALL 
   SELECT AccountEntityID ,
          DPD_Overdue DPD  
     FROM tt_ACCOUNTCAL_52 
    WHERE  NVL(DPD_Overdue, 0) > 0 ) 
      MERGE INTO B 
      USING (SELECT B.ROWID row_id, A.DPD_MaxFin
      FROM B ,( SELECT AccountEntityID ,
                       MAX(DPD)  DPD_MaxFin  
                FROM CTE_FIN_DPD 
                  GROUP BY AccountEntityID ) a
             JOIN tt_ADVACRESTRUCTURECAL_2 B   ON A.AccountEntityID = B.AccountEntityId ) src
      ON ( B.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.DPD_MaxFin = src.DPD_MaxFin
      ;
   WITH CTE_NONFIN_DPD AS ( SELECT AccountEntityID ,
                                   DPD_StockStmt DPD  
     FROM tt_ACCOUNTCAL_52 
    WHERE  NVL(DPD_StockStmt, 0) > 0
   UNION ALL 
   SELECT AccountEntityID ,
          DPD_Renewal DPD  
     FROM tt_ACCOUNTCAL_52 
    WHERE  NVL(DPD_Renewal, 0) > 0 ) 
      MERGE INTO B 
      USING (SELECT B.ROWID row_id, A.DPD_MaxNonFin
      FROM B ,( SELECT AccountEntityID ,
                       MAX(DPD)  DPD_MaxNonFin  
                FROM CTE_NONFIN_DPD 
                  GROUP BY AccountEntityID ) a
             JOIN tt_ADVACRESTRUCTURECAL_2 B   ON A.AccountEntityID = B.AccountEntityId ) src
      ON ( B.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.DPD_MaxNonFin = src.DPD_MaxNonFin
      ;
   UPDATE tt_ADVACRESTRUCTURECAL_2
      SET DPD_MaxNonFin = 0
    WHERE  DPD_MaxNonFin IS NULL;
   UPDATE tt_ADVACRESTRUCTURECAL_2
      SET DPD_MaxFin = 0
    WHERE  DPD_MaxNonFin IS NULL;
   ------------------------------------------------------------------------------------------------------------
   /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_ACCOUNTCAL_52 A ) src
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
   FROM A ,tt_ACCOUNTCAL_52 a
          JOIN tt_CUSTOMERCAL_53 C   ON C.SourceSystemCustomerID = a.SourceSystemCustomerID 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   --------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_UcifRestructure_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UcifRestructure_2 ';
   END IF;
   DELETE FROM tt_UcifRestructure_2;
   UTILS.IDENTITY_RESET('tt_UcifRestructure_2');

   INSERT INTO tt_UcifRestructure_2 SELECT A.RefCustomerID CustomerID  ,
                                           A.CustomerAcID ,
                                           rt.ParameterName TypeOfRestructure  ,
                                           cc.ParameterName Covid_Category  ,
                                           b.RestructureDt ,
                                           pr.AssetClassShortName Pre_Restr_AssetClass  ,
                                           b.PreRestructureNPA_Prov ,
                                           c.PreRestructureNPA_Date ,
                                           ----,ins.AssetClassShortName Previous_AssetClass
                                           --,InitialNpaDt
                                           AcL.AssetClassShortName Current_AssetClass  ,
                                           A.FinalNpaDt CurrentNPA_Date  ,
                                           A.DPD_Max ,
                                           B.DPD_Breach_Date ,
                                           B.ZeroDPD_Date ZeroDPD_Date  ,
                                           Res_POS_to_CurrentPOS_Per ,
                                           B.POS_10PerPaidDate ,
                                           b.RestructureStage ,
                                           Ai.AssetClassShortName AssetClass_On_Iinvocation  ,
                                           B.ProvPerOnRestrucure ,
                                           NetBalance ,
                                           b.RestructurePOS ,
                                           CASE 
                                                WHEN A.PrincOutStd > 0 THEN A.PrincOutStd
                                           ELSE 0
                                              END CurrentPOS ,--B.CurrentPOS	

                                           A.Balance ,
                                           C.PrincRepayStartDate ,
                                           c.InttRepayStartDate ,
                                           SP_ExpiryDate ,
                                           B.SP_ExpiryExtendedDate ,
                                           b.AddlProvPer RestrProvPer  ,
                                           ProvReleasePer ,
                                           AppliedNormalProvPer ,
                                           FinalProvPer ,
                                           b.PreDegProvPer ,
                                           b.UpgradeDate ,
                                           b.SurvPeriodEndDate ,
                                           DegDurSP_PeriodProvPer ,
                                           RestructureProvision ,
                                           b.SecuredProvision RESTR_SecuredProvision  ,
                                           B.UnSecuredProvision RESTR_UnSecuredProvision  ,
                                           b.FlgDeg RESTR_FlgDeg  ,
                                           b.FlgUpg RESTR_FlgUpg  ,
                                           SecuredAmt ,
                                           UnSecuredAmt ,
                                           BankTotalProvision ,
                                           RBITotalProvision ,
                                           TotalProvision ,
                                           CASE 
                                                WHEN (NVL(AppliedNormalProvPer, 0) + NVL(FinalProvPer, 0)) > 100 THEN 100
                                           ELSE (NVL(AppliedNormalProvPer, 0) + NVL(FinalProvPer, 0))
                                              END AppliedProvPer  ,
                                           ( SELECT MonthLastDate 
                                             FROM SysDataMatrix 
                                            WHERE  MOC_Initialised = 'Y'
                                                     AND NVL(MOC_Frozen, 'N') = 'N' ) CreatedDate  ,
                                           Asset_Norm ,
                                           SUBSTR(NPA_Reason, 0, 200) NPA_Reason  ,
                                           SUBSTR(A.DegReason, 0, 200) DegReason  ,
                                           A.UCIF_ID UCIC  ,
                                           A.AcOpenDt ,
                                           CASE 
                                                WHEN RF.ParameterName IS NULL THEN 'Linked Account'
                                           ELSE RF.ParameterName
                                              END RestructureFacility  ,
                                           B.FlgMorat ,
                                           B.DPD_MAXFIN ,
                                           B.DPD_MAXNONFIN ,
                                           A.DPD_Overdrawn ,
                                           A.FacilityType ,
                                           A.BranchCode ,
                                           DB.BranchName ,
                                           DP.SchemeType ,
                                           A.ProductCode SchemeCode  ,
                                           DP.ProductName SchemeDescription  ,
                                           A.ActSegmentCode SegCode  ,
                                           DS.AcBuSegmentDescription SegmentDescription  ,
                                           c.InvocationDate ,
                                           c.ConversionDate ,
                                           c.ApprovingAuthAlt_Key RestructureApprovingAuthority  ,
                                           c.CRILIC_Fst_DefaultDate ,
                                           c.FstDefaultReportingBank ,
                                           c.ICA_SignDate ,
                                           M.ParameterName BankingRelation  ,
                                           c.InvestmentGrade ,
                                           dsdb.SourceName ,
                                           c.RestructureAmt ,
                                           --,CASE WHEN DSDB.SourceName in ('Ganaseva','FIS') THEN 'FI'
                                           --		  WHEN DSDB.SourceName='VisionPlus'  and DP.ProductCode  in ('777','780')  THEN 'Retail'
                                           --		   WHEN DSDB.SourceName='VisionPlus'  and DP.ProductCode  not in ('777','780')  THEN 'Credit Card'
                                           --		else AcBuRevisedSegmentCode end AccountSegmentDescription
                                           CASE 
                                                WHEN DSDB.SourceName = 'FIS' THEN 'FI'
                                                WHEN DSDB.SourceName = 'VisionPlus' THEN 'Credit Card'
                                           ELSE AcBuSegmentDescription
                                              END Segment_Code_description  ,
                                           CASE 
                                                WHEN DSDB.SourceName IN ( 'Ganaseva','FIS' )
                                                 THEN 'FI'
                                                WHEN DSDB.SourceName = 'VisionPlus'
                                                  AND DP.ProductCode IN ( '777','780' )
                                                 THEN 'Retail'
                                                WHEN DSDB.SourceName = 'VisionPlus'
                                                  AND DP.ProductCode NOT IN ( '777','780' )
                                                 THEN 'Credit Card'
                                           ELSE AcBuRevisedSegmentCode
                                              END Business_Segment  ,
                                           CustomerName BorrowerName  ,
                                           c.DateCreated ,
                                           A.AccountEntityID ,
                                           Ex.StatusType StatusType  
        FROM tt_ACCOUNTCAL_52 A
               JOIN tt_AccountEntityId_2 AE   ON a.AccountEntityID = AE.AccountEntityID
               LEFT JOIN tt_ADVACRESTRUCTURECAL_2 b   ON a.AccountEntityID = b.AccountEntityId
               AND b.EffectiveFromTimeKey <= v_timekey
               AND b.EffectiveToTimeKey >= v_timekey
             ----	AND A.AccountEntityID =2254734

               LEFT JOIN ADVACRESTRUCTUREDETAIL c   ON c.AccountEntityId = a.AccountEntityID
               AND c.EffectiveFromTimeKey <= v_timekey
               AND c.EffectiveToTimeKey >= v_timekey
               LEFT JOIN DimParameter RF   ON rf.EffectiveFromTimeKey <= v_timekey
               AND rf.EffectiveToTimeKey >= v_timekey
               AND RF.ParameterAlt_Key = c.RestructureFacilityTypeAlt_Key
               AND rF.DimParameterName = 'RestructureFacility'
               LEFT JOIN DimParameter rT   ON rT.EffectiveFromTimeKey <= v_timekey
               AND rT.EffectiveToTimeKey >= v_timekey
               AND Rt.ParameterAlt_Key = c.RestructureTypeAlt_Key
               AND rt.DimParameterName = 'TypeofRestructuring'
               LEFT JOIN DimParameter cc   ON cc.EffectiveFromTimeKey <= v_timekey
               AND cc.EffectiveToTimeKey >= v_timekey
               AND cc.ParameterAlt_Key = c.COVID_OTR_CatgAlt_Key
               AND cc.DimParameterName = 'Covid - OTR Category'
               LEFT JOIN DimAssetClass AI   ON ai.EffectiveFromTimeKey <= v_timekey
               AND ai.EffectiveToTimeKey >= v_timekey
               AND ai.AssetClassAlt_Key = c.AssetClassAlt_KeyOnInvocation
               LEFT JOIN DimAssetClass pr   ON pr.EffectiveFromTimeKey <= v_timekey
               AND pr.EffectiveToTimeKey >= v_timekey
               AND pr.AssetClassAlt_Key = c.PreRestructureAssetClassAlt_Key
               LEFT JOIN DimAssetClass acl   ON acl.EffectiveFromTimeKey <= v_timekey
               AND acl.EffectiveToTimeKey >= v_timekey
               AND acl.AssetClassAlt_Key = a.FinalAssetClassAlt_Key
               LEFT JOIN DimAssetClass Ins   ON ins.EffectiveFromTimeKey <= v_timekey
               AND ins.EffectiveToTimeKey >= v_timekey
               AND Ins.AssetClassAlt_Key = a.InitialAssetClassAlt_Key
               LEFT JOIN DimProduct DP   ON DP.EffectiveFromTimeKey <= v_timekey
               AND DP.EffectiveToTimeKey >= v_timekey
               AND DP.ProductCode = a.ProductCode
               LEFT JOIN DimBranch DB   ON DB.EffectiveFromTimeKey <= v_timekey
               AND DB.EffectiveToTimeKey >= v_timekey
               AND DB.BranchCode = a.BranchCode
               LEFT JOIN DimAcBuSegment DS   ON DS.EffectiveFromTimeKey <= v_timekey
               AND DS.EffectiveToTimeKey >= v_timekey
               AND DS.AcBuSegmentCode = a.ActSegmentCode
               LEFT JOIN DIMSOURCEDB DSDB   ON A.SourceAlt_Key = DSDB.SourceAlt_Key

               --AND DSDB.EffectiveToTimeKey =49999
               AND ( DSDB.EffectiveFromTimeKey <= v_timekey
               AND DSDB.EffectiveToTimeKey >= v_timekey )
               LEFT JOIN CustomerBasicDetail CB   ON a.CustomerEntityID = cb.CustomerEntityId
               AND cb.EffectiveFromTimeKey <= v_timekey
               AND cb.EffectiveToTimeKey >= v_timekey
               LEFT JOIN ExceptionFinalStatusType Ex   ON Ex.ACID = A.CustomerAcID
               AND NVL(Ex.StatusType, ' ') = 'TWO'
               AND Ex.EffectiveFromTimeKey <= v_timekey
               AND Ex.EffectiveToTimeKey >= v_timekey
               LEFT JOIN ( SELECT ParameterAlt_Key ,
                                  ParameterName ,
                                  'BankingRelationship' Tablename  
                           FROM DimParameter 
                            WHERE  DimParameterName = 'BankingRelationship'
                                     AND EffectiveFromTimeKey <= v_TimeKey
                                     AND EffectiveToTimeKey >= v_TimeKey ) M   ON M.ParameterAlt_Key = c.BankingRelationTypeAlt_Key
       WHERE  a.EffectiveFromTimeKey <= v_timekey
                AND a.EffectiveToTimeKey >= v_timekey
        ORDER BY 3,
                 4;
   -----------------------------------------------------------------------------------------------------------
   --select * 
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.PrincOutStd
   FROM A ,tt_UcifRestructure_2 a
          JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist b   ON a.AccountEntityID = b.AccountEntityID 
    WHERE b.EffectiveFromTimeKey <= v_timekey
     AND b.EffectiveToTimeKey >= v_timekey
     AND a.RestructureFacility = 'Linked Account') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.CurrentPOS = src.PrincOutStd;
   ------------------------------------------------Percolation Code---------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TempCust_3  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_TempCust_3;
   UTILS.IDENTITY_RESET('tt_TempCust_3');

   INSERT INTO tt_TempCust_3 SELECT * 
        FROM ( SELECT CustomerID ,
                      TypeOfRestructure ,
                      RestructureDt ,
                      Pre_Restr_AssetClass ,
                      PreRestructureNPA_Date ,
                      ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY DateCreated DESC, RestructureDt DESC  ) RN  
               FROM tt_UcifRestructure_2 
                WHERE  TypeOfRestructure IS NOT NULL ) A
       WHERE  RN = 1;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.TypeOfRestructure, b.RestructureDt, b.Pre_Restr_AssetClass, b.PreRestructureNPA_Date
   FROM A ,tt_UcifRestructure_2 a
          JOIN tt_TempCust_3 b   ON a.CustomerID = b.CustomerID 
    WHERE a.TypeOfRestructure IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.TypeOfRestructure = src.TypeOfRestructure,
                                a.RestructureDt = src.RestructureDt,
                                a.Pre_Restr_AssetClass = src.Pre_Restr_AssetClass,
                                a.PreRestructureNPA_Date = src.PreRestructureNPA_Date;
   DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TempUcic_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_TempUcic_2;
   UTILS.IDENTITY_RESET('tt_TempUcic_2');

   INSERT INTO tt_TempUcic_2 SELECT * 
        FROM ( SELECT UCIC ,
                      TypeOfRestructure ,
                      RestructureDt ,
                      Pre_Restr_AssetClass ,
                      PreRestructureNPA_Date ,
                      ROW_NUMBER() OVER ( PARTITION BY UCIC ORDER BY DateCreated DESC, RestructureDt DESC  ) RN  
               FROM tt_UcifRestructure_2 
                WHERE  TypeOfRestructure IS NOT NULL ) A
       WHERE  RN = 1;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.TypeOfRestructure, b.RestructureDt, b.Pre_Restr_AssetClass, b.PreRestructureNPA_Date
   FROM A ,tt_UcifRestructure_2 a
          JOIN tt_TempUcic_2 b   ON a.UCIC = b.UCIC 
    WHERE a.TypeOfRestructure IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.TypeOfRestructure = src.TypeOfRestructure,
                                a.RestructureDt = src.RestructureDt,
                                a.Pre_Restr_AssetClass = src.Pre_Restr_AssetClass,
                                a.PreRestructureNPA_Date = src.PreRestructureNPA_Date;
   ---------------------------------------------------------------------------------------------------------------------------------
   DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
   --select * into tt_DGU_Restructure_Report_2 from DGU_Restructure_Report where 1=2
   --alter table tt_DGU_Restructure_Report_2 add  StatusType varchar(50)
   IF tt_DGU_Restructure_Report_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DGU_Restructure_Report_2;
   UTILS.IDENTITY_RESET('tt_DGU_Restructure_Report_2');

   INSERT INTO tt_DGU_Restructure_Report_2 ( 
   	SELECT DISTINCT ( SELECT MonthLastDate 
                      FROM SysDataMatrix 
                     WHERE  MOC_Initialised = 'Y'
                              AND NVL(MOC_Frozen, 'N') = 'N' ) Report_Date  ,
                    SourceName SourceSystemName  ,
                    BranchCode ,
                    BranchName ,
                    UCIC ,
                    CustomerID ,
                    CustomerAcID ,
                    FacilityType ,
                    UTILS.CONVERT_TO_VARCHAR2(AcOpenDt,30) AcOpenDt ,--   Changed on 29/06/2024 by kapil previously --> convert(nvarchar(10),convert(date,AcOpenDt , 105),23) as AcOpenDt,  

                    RestructureFacility ,
                    TypeOfRestructure ,
                    Covid_Category ,
                    SchemeCode ,
                    SchemeDescription ,
                    SchemeType ,
                    SegCode ,
                    SegmentDescription ,
                    UTILS.CONVERT_TO_VARCHAR2(RestructureDt,30) RestructureDt ,--  Changed on 29/06/2024 by kapil previously --> convert(nvarchar(10),convert(date,RestructureDt , 105),23) as RestructureDt,

                    Pre_Restr_AssetClass ,
                    UTILS.CONVERT_TO_VARCHAR2(PreRestructureNPA_Date,30) PreRestructureNPA_Date ,-- Changed on 29/06/2024 by kapil previously -->  convert(nvarchar(10),convert(date,PreRestructureNPA_Date , 105),23) as PreRestructureNPA_Date,

                    Current_AssetClass ,
                    UTILS.CONVERT_TO_VARCHAR2(CurrentNPA_Date,30) CurrentNPA_Date ,-- Changed on 29/06/2024 by kapil previously -->--convert(nvarchar(10),convert(date,CurrentNPA_Date , 105),23) as CurrentNPA_Date,

                    DPD_Max ,
                    DPD_MAXFIN ,
                    DPD_MAXNONFIN ,
                    DPD_Overdrawn ,
                    UTILS.CONVERT_TO_VARCHAR2(DPD_Breach_Date,30) DPD_Breach_Date ,-- Changed on 29/06/2024 by kapil previously -->--convert(nvarchar(10),convert(date,DPD_Breach_Date , 105),23) as DPD_Breach_Date,

                    UTILS.CONVERT_TO_VARCHAR2(ZeroDPD_Date,30) ZeroDPD_Date ,-- Changed on 29/06/2024 by kapil previously -->convert(nvarchar(10),convert(date,ZeroDPD_Date , 105),23) as ZeroDPD_Date,

                    Res_POS_to_CurrentPOS_Per ,
                    RestructurePOS ,
                    CASE 
                         WHEN CurrentPOS > 0 THEN CurrentPOS
                    ELSE 0
                       END CurrentPOS  ,
                    BALANCE Outstanding_Balance  ,
                    UTILS.CONVERT_TO_VARCHAR2(PrincRepayStartDate,30) PrincRepayStartDate ,-- Changed on 29/06/2024 by kapil previously --convert(nvarchar(10),convert(date,PrincRepayStartDate , 105),23) as PrincRepayStartDate,

                    UTILS.CONVERT_TO_VARCHAR2(InttRepayStartDate,30) InttRepayStartDate ,-- Changed on 29/06/2024 by kapil previously --convert(nvarchar(10),convert(date,InttRepayStartDate , 105),23) as  InttRepayStartDate,

                    UTILS.CONVERT_TO_VARCHAR2(SP_ExpiryDate,30) SP_ExpiryDate ,-- Changed on 29/06/2024 by kapil previously --convert(nvarchar(10),convert(date,SP_ExpiryDate , 105),23) as       SP_ExpiryDate,

                    UTILS.CONVERT_TO_VARCHAR2(SP_ExpiryExtendedDate,30) SP_ExpiryExtendedDate ,-- Changed on 29/06/2024 by kapil previously --convert(nvarchar(10),convert(date,SP_ExpiryExtendedDate , 105),23) as SP_ExpiryExtendedDate,

                    NPA_Reason ,
                    Asset_Norm ,
                    UTILS.CONVERT_TO_VARCHAR2(InvocationDate,30) InvocationDate ,-- Changed on 29/06/2024 by kapil previously-- convert(nvarchar(10),convert(date,InvocationDate , 105),23) as InvocationDate,

                    UTILS.CONVERT_TO_VARCHAR2(ConversionDate,30) ConversionDate ,-- Changed on 29/06/2024 by kapil previously-- convert(nvarchar(10),convert(date,ConversionDate , 105),23) as ConversionDate,

                    RestructureApprovingAuthority ,
                    UTILS.CONVERT_TO_VARCHAR2(CRILIC_Fst_DefaultDate,30) CRILIC_Fst_DefaultDate ,-- Changed on 29/06/2024 by kapil previously-- convert(nvarchar(10),convert(date,CRILIC_Fst_DefaultDate , 105),23) as CRILIC_Fst_DefaultDate,

                    FstDefaultReportingBank ,
                    UTILS.CONVERT_TO_VARCHAR2(ICA_SignDate,30) CA_SignDate ,-- Changed on 29/06/2024 by kapil previously-- convert(nvarchar(10),convert(date,ICA_SignDate , 105),23) as ICA_SignDate,

                    --BankingRelation,                                                           -- Changed on 29/06/2024 by kapil previously it was Uncommented
                    --InvestmentGrade,															 -- Changed on 29/06/2024 by kapil previously it was Uncommented
                    --RestructureAmt [O/S as on Date of Restructure],							 -- Changed on 29/06/2024 by kapil previously it was Uncommented
                    --[Segment Code description],												 -- Changed on 29/06/2024 by kapil previously it was Uncommented
                    --[Business Segment],														 -- Changed on 29/06/2024 by kapil previously it was Uncommented
                    BorrowerName ,
                    StatusType 
   	  FROM tt_UcifRestructure_2  );
   ----------------------------------------------------------------------------------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_DGU_Restructure_Report_2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."POSTMOC_RESTRUCTURE_REPORT" TO "ADF_CDR_RBL_STGDB";
