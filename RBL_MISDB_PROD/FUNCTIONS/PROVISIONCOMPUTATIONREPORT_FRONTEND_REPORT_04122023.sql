--------------------------------------------------------
--  DDL for Function PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" 
(
  v_UserLoginID IN VARCHAR2,
  v_rptDate IN VARCHAR2,
  iv_Timekey IN NUMBER,
  v_Result OUT NUMBER
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );
   v_temp NUMBER(1, 0) := 0;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE ProvisionCompuatationReportFrontendProcess ';
   INSERT INTO ProvisionCompuatationReportFrontendProcess
     VALUES ( '1', 'InProgress', SYSDATE );
   --set @Timekey=@Timekey
   SELECT Timekey 

     INTO v_Timekey
     FROM Automate_Advances 
    WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(v_rptDate,200,p_style=>105);
   --DECLARE @Timekey int =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')
   --Drop table if exists #temp
   --Create table  #temp
   --(
   --AccountID Varchar(30),
   --CustomerID Varchar(30),
   --UcicID Varchar(30)
   --)
   --------------------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_ADVACRESTRUCTUREDETAIL_14') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ADVACRESTRUCTUREDETAIL_14 ';
   END IF;
   DELETE FROM tt_ADVACRESTRUCTUREDETAIL_14;
   UTILS.IDENTITY_RESET('tt_ADVACRESTRUCTUREDETAIL_14');

   INSERT INTO tt_ADVACRESTRUCTUREDETAIL_14 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY RefSystemAcId ORDER BY RefSystemAcId, EffectiveFromTimeKey DESC, EntityKey DESC  ) rn  
               FROM ADVACRESTRUCTUREDETAIL RES
                WHERE  RES.EffectiveFromTimeKey <= v_Timekey
                         AND RES.EffectiveToTimeKey >= v_Timekey ) aa
       WHERE  rn = 1;
   ------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_PrevQtrDataAccountWise_12') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrDataAccountWise_12 ';
   END IF;
   DELETE FROM tt_PrevQtrDataAccountWise_12;
   UTILS.IDENTITY_RESET('tt_PrevQtrDataAccountWise_12');

   INSERT INTO tt_PrevQtrDataAccountWise_12 ( 
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
              AND A.EffectiveToTimeKey >= v_LastQtrDateKey );
   DELETE FROM tt_AccountEntityID_2;
   --and B.FinalAssetClassAlt_Key>1 
   -------------------------------------------------------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_AccountEntityID_2  --SQLDEV: NOT RECOGNIZED
   -----------------------------------------------------------------------------------------------------
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM SAG_ProvComp_SuccessDetails 
                WHERE  NVL(AC_ID, ' ') <> ' ' ) >= 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      IF utils.object_id('TEMPDB..tt_TEMP11_2') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP11_2 ';
      END IF;
      --insert into  tt_AccountEntityID_2
      --Select       distinct top 1000000  AccountEntityId  
      --from         AdvAcBasicDetail a
      --inner join   #temp b
      --on           a.CustomerACID=b.AccountID
      --where        EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey>=@Timekey
      DELETE FROM tt_TEMP11_2;
      UTILS.IDENTITY_RESET('tt_TEMP11_2');

      INSERT INTO tt_TEMP11_2 ( 
      	SELECT DISTINCT B.UcifEntityID 
      	  FROM AdvAcBasicDetail a
                JOIN CustomerBasicDetail b   ON a.CustomerEntityId = b.CustomerEntityId
                JOIN SAG_ProvComp_SuccessDetails c   ON A.CustomerACID = C.AC_ID
      	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
                 AND A.EffectiveToTimeKey >= v_Timekey
                 AND B.EffectiveFromTimeKey <= v_Timekey
                 AND B.EffectiveToTimeKey >= v_Timekey
                 AND C.UserLoginID = v_UserLoginID );
      INSERT INTO tt_AccountEntityID_2
        ( SELECT DISTINCT AccountEntityId 
          FROM AdvAcBasicDetail a
                 JOIN CustomerBasicDetail b   ON a.CustomerEntityId = b.CustomerEntityId
                 JOIN tt_TEMP11_2 c   ON b.UcifEntityID = c.UcifEntityID
           WHERE  a.EffectiveFromTimeKey <= v_Timekey
                    AND a.EffectiveToTimeKey >= v_Timekey
                    AND b.EffectiveFromTimeKey <= v_Timekey
                    AND b.EffectiveToTimeKey >= v_Timekey );

   END;
   END IF;
   ---------------------------------------------------------------------------------------------------
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM SAG_ProvComp_SuccessDetails 
                WHERE  NVL(CustID, ' ') <> ' ' ) >= 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      IF utils.object_id('TEMPDB..tt_TEMP12_2') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP12_2 ';
      END IF;
      --insert into  tt_AccountEntityID_2
      --Select       distinct top 1000000  AccountEntityId  
      --from         AdvAcBasicDetail a
      --inner join   #temp b
      --on           a.RefCustomerId=b.CustomerID
      --where        EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey>=@Timekey
      DELETE FROM tt_TEMP12_2;
      UTILS.IDENTITY_RESET('tt_TEMP12_2');

      INSERT INTO tt_TEMP12_2 ( 
      	SELECT DISTINCT a.UcifEntityID 
      	  FROM CustomerBasicDetail a
                JOIN SAG_ProvComp_SuccessDetails b   ON a.CustomerId = b.CustID
      	 WHERE  a.EffectiveFromTimeKey <= v_Timekey
                 AND a.EffectiveToTimeKey >= v_Timekey
                 AND b.UserLoginID = v_UserLoginID );
      INSERT INTO tt_AccountEntityID_2
        ( SELECT DISTINCT AccountEntityId 
          FROM AdvAcBasicDetail a
                 JOIN CustomerBasicDetail b   ON a.CustomerEntityId = b.CustomerEntityId
                 JOIN tt_TEMP12_2 c   ON b.UcifEntityID = c.UcifEntityID
           WHERE  a.EffectiveFromTimeKey <= v_Timekey
                    AND a.EffectiveToTimeKey >= v_Timekey
                    AND b.EffectiveFromTimeKey <= v_Timekey
                    AND b.EffectiveToTimeKey >= v_Timekey );

   END;
   END IF;
   ---------------------------------------------------------------------------------------------------
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM SAG_ProvComp_SuccessDetails 
                WHERE  NVL(UCIC, ' ') <> ' ' ) >= 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      INSERT INTO tt_AccountEntityID_2
        ( SELECT DISTINCT AccountEntityId 
          FROM AdvAcBasicDetail a
                 JOIN CustomerBasicDetail b   ON a.CustomerEntityId = b.CustomerEntityId
                 JOIN SAG_ProvComp_SuccessDetails c   ON b.UCIF_ID = c.UCIC
           WHERE  a.EffectiveFromTimeKey <= v_Timekey
                    AND a.EffectiveToTimeKey >= v_Timekey
                    AND b.EffectiveFromTimeKey <= v_Timekey
                    AND b.EffectiveToTimeKey >= v_Timekey
                    AND c.UserLoginID = v_UserLoginID );

   END;
   END IF;
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
   --DECLARE @Timekey int =(select timekey from PostMOCTimeKey) 
   --DECLARE @Timekey int =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')
   --DECLARE @Timekey int =   
   --(26376)  
   IF ( utils.object_id('TEMPDB..tt_PrevQtrData_20') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrData_20 ';
   END IF;
   DELETE FROM tt_PrevQtrData_20;
   UTILS.IDENTITY_RESET('tt_PrevQtrData_20');

   INSERT INTO tt_PrevQtrData_20 ( 
   	SELECT B.ACCOUNTENTITYID ,
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
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist B
             JOIN tt_AccountEntityID_2 c   ON B.AccountEntityID = c.AccountEntityID
   	 WHERE  EffectiveFromTimeKey <= v_LastQtrDateKey
              AND EffectiveToTimeKey >= v_LastQtrDateKey );
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD2_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD2_2;
   UTILS.IDENTITY_RESET('tt_DPD2_2');

   INSERT INTO tt_DPD2_2 ( 
   	SELECT CustomerACID ,
           B.AccountEntityid ,
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
             JOIN tt_AccountEntityID_2 c   ON B.AccountEntityID = c.AccountEntityID
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey
              AND B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD2_2 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0, 0, 0, 0, 0
   FROM A ,tt_DPD2_2 a ) src
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
   --select * from tt_DPD2_2  
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
      FROM A ,tt_DPD2_2 A ) src
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
      FROM A ,tt_DPD2_2 A ) src
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
   UPDATE tt_DPD2_2
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_DPD2_2
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   --UPDATE A SET DPD_NoCredit=0 FROM tt_DPD2_2 A   
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_104') IS NOT NULL THEN
    --Truncate table  ProvisionComputationCSVUpload
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_104 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_104;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_104');

   INSERT INTO tt_TEMPTABLE_104 ( 
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
   	  FROM tt_DPD2_2 A
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
   FROM A ,tt_DPD2_2 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID  
   --WHERE  isnull(B.FlgProcessing,'N')='N'    
   /*----------------FIND MAX DPD---------------------------------------*/
   --  UPDATE   A SET A.DPD_Max=   	GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL(DPD_StockStmt,0),ISNULL(DPD_Renewal,0),isnull(DPD_Overdue,0),
   --isnull(DPD_PrincOverdue,0),isnull(DPD_IntOverdueSince,0),isnull(DPD_OtherOverdueSince,0),isnull(DPD_IntService,0),isnull(DPD_NoCredit,0))
   --a.DPD_Max,
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, MAX(CASE 
            WHEN ( NVL(DPD_Overdrawn, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_Overdrawn, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_Overdrawn, 0)
            WHEN ( NVL(DPD_StockStmt, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_StockStmt, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_StockStmt, 0)
            WHEN ( NVL(DPD_Renewal, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_Renewal, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_Renewal, 0)
            WHEN ( NVL(DPD_Overdue, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_Overdue, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_Overdue, 0)
            WHEN ( NVL(DPD_PrincOverdue, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_PrincOverdue, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_PrincOverdue, 0)
            WHEN ( NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_IntOverdueSince, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_IntOverdueSince, 0)
            WHEN ( NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_IntService, 0)
              AND NVL(DPD_OtherOverdueSince, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_OtherOverdueSince, 0)
            WHEN ( NVL(DPD_IntService, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_IntService, 0) >= NVL(DPD_NoCredit, 0) ) THEN NVL(DPD_IntService, 0)
            WHEN ( NVL(DPD_NoCredit, 0) >= NVL(DPD_Overdrawn, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_StockStmt, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_Renewal, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_Overdue, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_PrincOverdue, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_IntOverdueSince, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_OtherOverdueSince, 0)
              AND NVL(DPD_NoCredit, 0) >= NVL(DPD_IntService, 0) ) THEN NVL(DPD_NoCredit, 0)
   ELSE NVL(DPD_IntNotServicedDt, 0)
      END)  AS DPD_MAX
   FROM A ,tt_DPD2_2 a ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_MAX = src.DPD_MAX;
   /* 
     UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.
   DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)   
     AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_PrincOverdue,0)   
     AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_IntOverDueSince,0)   
     AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_OtherOverDueSince,0))   
     THEN isnull(A.DPD_IntService,0)  
                WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0)   
                AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0)   
                AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0)   
                AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0)   
                AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)  
                AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_PrincOverdue,0)   
              AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntOverDueSince,0)   
              AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_OtherOverDueSince,0))   
                 THEN   isnull(A.DPD_NoCredit ,0)  
                WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  
   			 AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) 
   			 AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)  
                AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_PrincOverdue,0)   
              AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_IntOverDueSince,0)   
              AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_OtherOverDueSince,0)) THEN  isnull(A.DPD_Overdrawn,0)  
                WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  
   			 AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  
   			 AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)  
                AND isnull(A.DPD_Renewal,0)>=isnull(A.DPD_PrincOverdue,0)   
              AND isnull(A.DPD_Renewal,0)>=isnull(A.DPD_IntOverDueSince,0)   
              AND isnull(A.DPD_Renewal,0)>=isnull(A.DPD_OtherOverDueSince,0)) THEN isnull(A.DPD_Renewal,0)  
                WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  
   			 AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  
   			 AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0)  
                AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_PrincOverdue,0)   
              AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_IntOverDueSince,0)   
              AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(A.DPD_Overdue,0)  
                WHEN (isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_NoCredit,0)      
                AND isnull(A.DPD_StockStmt,0)>=   isnull(A.DPD_IntService,0)    
                AND  isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_Overdrawn,0)    
                AND  isnull(A.DPD_StockStmt,0)>=   isnull(A.DPD_Renewal,0)    
                AND isnull(A.DPD_StockStmt ,0)>=isnull(A.DPD_Overdue ,0)  
                AND isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_PrincOverdue,0)   
              AND isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_IntOverDueSince,0)   
              AND isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(A.DPD_StockStmt,0)  
                WHEN (isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_NoCredit,0)      
                AND isnull(A.DPD_PrincOverdue,0)>=   isnull(A.DPD_IntService,0)    
                AND  isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_Overdrawn,0)    
                AND  isnull(A.DPD_PrincOverdue,0)>=   isnull(A.DPD_Renewal,0)    
                AND isnull(A.DPD_PrincOverdue ,0)>=isnull(A.DPD_StockStmt ,0)  
                AND isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_Overdue,0)   
              AND isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_IntOverDueSince,0)   
              AND isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(DPD_PrincOverdue,0)  
                WHEN (isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_NoCredit,0)      
                AND isnull(A.DPD_IntOverDueSince,0)>=   isnull(A.DPD_IntService,0)    
                AND  isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_Overdrawn,0)    
                AND  isnull(A.DPD_IntOverDueSince,0)>=   isnull(A.DPD_Renewal,0)    
                AND isnull(A.DPD_IntOverDueSince ,0)>=isnull(A.DPD_StockStmt ,0)  
                AND isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_Overdue,0)   
              AND isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_PrincOverdue,0)   
              AND isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(A.DPD_IntOverDueSince,0)  
                ELSE isnull(A.DPD_OtherOverDueSince,0) END)   

     FROM  tt_DPD2_2 a   
     --INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID  
     INNER JOIN PRO.CustomerCal_Hist C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID  
     WHERE  (isnull(C.FlgProcessing,'N')='N')   
     AND   
     (isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0  OR isnull(A.DPD_Renewal,0) >0 OR  
     isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)  
     and C.EffectiveFromTimeKey <= @Timekey and C.EffectiveToTimeKey >= @Timekey  
     */
   DELETE ProvisionComputation_Report_Frontend

    WHERE  UserLoginID = v_UserLoginID;
   --Truncate table [ProvisionComputation_Report_Frontend]
   INSERT INTO ProvisionComputation_Report_Frontend
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
                 WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
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
            B.AccountBlkCode2 Block_Code_V_  ,
            B.Addlprovision Additional_Provision  ,
            EXPS.StatusType StatusType_1  ,
            -------PREV QTR DATA  
            A3.AssetClassName PREV_QTR_Asset_Classification  ,
            PREV.Addlprovision PREV_QTR_Additional_Provision  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.Provsecured / NULLIF(PREV.SecuredAmt, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.ProvUnsecured / NULLIF(PREV.UnSecuredAmt, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionUnSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.TotalProvision / NULLIF(PREV.NetBalance, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionTotal_  ,
            Dimp.ParameterName TypeOfRestructure  ,
            EXPS.StatusType ,
            b.Asset_Norm ,
            CASE 
                 WHEN A.FlgErosion <> 'Y' THEN NULL
            ELSE (CASE 
                       WHEN A.SysAssetClassAlt_Key = 6 THEN 'Erosion Loss'
            ELSE 'Erosion D_1'
               END)
               END Erosion_Testing  ,
            CASE 
                 WHEN EXPS.StatusType LIKE '%Litigation%' THEN 'Y'
            ELSE 'N'
               END Litigation_Flg  ,
            CASE 
                 WHEN EXPS.StatusType LIKE '%Settlement%' THEN 'Y'
            ELSE 'N'
               END Settlement_Flg  ,
            CASE 
                 WHEN EXPS.StatusType LIKE '%TWO%' THEN 'Y'
            ELSE 'N'
               END TWO_Flg  ,
            CASE 
                 WHEN EXPS.StatusType LIKE '%TWO%' THEN EXPS.StatusDate
            ELSE NULL
               END TWO_Date  ,
            CASE 
                 WHEN EXPS.StatusType LIKE '%TWO%' THEN EXPS.Amount
            ELSE NULL
               END TWO_Amount  ,
            v_UserLoginID ,
            SYSDATE UploadDate  

       --into #prashant3112 --drop table #prashant3112  
       FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
              JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
            --AND ISNULL(B.WriteOffAmount,0)=0  

              JOIN tt_AccountEntityID_2 c   ON B.AccountEntityID = c.AccountEntityID
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
              LEFT JOIN tt_PrevQtrDataAccountWise_12 Y   ON A.CustomerEntityID = Y.CustomerEntityID
              LEFT JOIN tt_DPD2_2 DPD   ON B.AccountEntityID = DPD.AccountEntityID
              LEFT JOIN tt_PrevQtrData_20 prev   ON B.AccountEntityID = PREV.ACCOUNTENTITYID
              LEFT JOIN DimAssetClass a3   ON a3.EffectiveToTimeKey = 49999
              AND a3.AssetClassAlt_Key = prev.FinalAssetClassAlt_Key
              LEFT JOIN ( 
                          --LEFT JOIN ExceptionFinalStatusType    EXPS    ON EXPS.ACID=B.CustomerAcID  AND EXPS.EffectiveToTimeKey=49999  
                          SELECT DISTINCT SourceAlt_Key ,
                                          CustomerID ,
                                          ACID ,
                                          EffectiveToTimeKey ,
                                          EffectiveFromTimeKey ,
                                          StatusDate ,
                                          Amount ,
                                          utils.stuff(( SELECT ', ' || B.StatusType 
                                                        FROM ExceptionFinalStatusType B
                                                         WHERE  B.EffectiveFromTimeKey <= v_Timekey
                                                                  AND b.EffectiveToTimeKey >= v_Timekey
       AND B.ACID = A.ACID
                                                          ORDER BY B.ACID ), 1, 1, ' ') StatusType  
                          FROM ExceptionFinalStatusType A
                           WHERE  A.EffectiveFromTimeKey <= v_Timekey
                                    AND A.EffectiveToTimeKey >= v_Timekey ) EXPS   ON EXPS.ACID = B.CustomerAcID
              AND EXPS.EffectiveFromTimeKey <= v_Timekey
              AND EXPS.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN tt_ADVACRESTRUCTUREDETAIL_14 RES   ON RES.AccountEntityId = B.AccountEntityID
              AND RES.EffectiveFromTimeKey <= v_Timekey
              AND RES.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN ( SELECT ParameterAlt_Key ,
                                 ParameterName 
                          FROM DimParameter 
                           WHERE  DimParameterName = 'TypeofRestructuring'
                                    AND EffectiveFromTimeKey <= v_Timekey
                                    AND EffectiveToTimeKey >= v_Timekey ) DIMP   ON DIMP.ParameterAlt_Key = RES.RestructureTypeAlt_Key
      WHERE --B.FinalAssetClassAlt_Key>1   and 
       b.EffectiveFromTimeKey <= v_Timekey
         AND B.EffectiveToTimeKey >= v_Timekey
         AND A.EffectiveFromTimeKey <= v_Timekey
         AND A.EffectiveToTimeKey >= v_Timekey;
   --select count(*) UploadCount from SAG_ProvComp_SuccessDetails
   --where UserLoginId=@UserLoginID
   EXECUTE IMMEDIATE ' TRUNCATE TABLE ProvisionCompuatationReportFrontendProcess ';
   v_Result := 1 ;
   RETURN v_Result;--select * from #prashant3112

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_FRONTEND_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
