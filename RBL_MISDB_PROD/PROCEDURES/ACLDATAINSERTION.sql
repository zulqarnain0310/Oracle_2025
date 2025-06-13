--------------------------------------------------------
--  DDL for Procedure ACLDATAINSERTION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLDATAINSERTION" 
(
  v_DAte IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_Timekey NUMBER(10,0) ;
   v_temp NUMBER(1, 0) := 0;

BEGIN

    SELECT Timekey INTO v_Timekey 
     FROM Automate_Advances 
    WHERE  Date_ = v_Date ;
   ---------------------------------------------------ACL OUTPUT ---------------
   DELETE FROM GTT_DPD;
   UTILS.IDENTITY_RESET('GTT_DPD');

   INSERT INTO GTT_DPD ( CUSTOMERACID,	ACCOUNTENTITYID,	SOURCESYSTEMCUSTOMERID,	INTNOTSERVICEDDT,	PROCESSDATE,	LASTCRDATE,	CONTIEXCESSDT,	OVERDUESINCEDT,	REVIEWDUEDT,	STOCKSTDT,	PRINCOVERDUESINCEDT,	INTOVERDUESINCEDT,	OTHEROVERDUESINCEDT,	REFPERIODINTSERVICE,	REFPERIODNOCREDIT,	REFPERIODOVERDRAWN,	REFPERIODOVERDUE,	REFPERIODREVIEW,	REFPERIODSTKSTATEMENT,	DEGDATE,	EFFECTIVEFROMTIMEKEY)
   	SELECT CustomerACID ,
           AccountEntityid ,
           B.SourceSystemCustomerID ,
           B.IntNotServicedDt ,
           v_Date ProcessDate  ,
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
           b.EffectiveFromTimeKey 
   	  FROM MAIN_PRO.AccountCal_Hist B
             JOIN MAIN_PRO.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey
              AND A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey ;

   EXECUTE IMMEDIATE ' ALTER TABLE GTT_DPD 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   MERGE INTO GTT_DPD A
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, ProcessDate)
   ELSE 0
      END) AS pos_2, (CASE 
   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, ProcessDate)
   ELSE 0
      END) AS pos_3, (CASE 
   WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, ProcessDate)
   ELSE 0
      END) AS pos_4, (CASE 
   WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_5, (CASE 
   WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, ProcessDate)
   ELSE 0
      END) AS pos_6, (CASE 
   WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, ProcessDate)
   ELSE 0
      END) AS pos_7, (CASE 
   WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_8, (CASE 
   WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_9, (CASE 
   WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_10
   FROM GTT_DPD A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = pos_2,
                                A.DPD_NoCredit = pos_3,
                                A.DPD_Overdrawn = pos_4,
                                A.DPD_Overdue = pos_5,
                                A.DPD_Renewal = pos_6,
                                A.DPD_StockStmt = pos_7,
                                A.DPD_PrincOverdue = pos_8,
                                A.DPD_IntOverdueSince = pos_9,
                                A.DPD_OtherOverdueSince = pos_10;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE GTT_DPD
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE GTT_DPD
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO GTT_DPD A
   USING (SELECT A.ROWID row_id, 0
   FROM GTT_DPD A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..GTT_TEMPTABLE') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE ';
   END IF;
   DELETE FROM GTT_TEMPTABLE;
   UTILS.IDENTITY_RESET('GTT_TEMPTABLE');

   INSERT INTO GTT_TEMPTABLE ( 
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
   	  FROM GTT_DPD A
             JOIN MAIN_PRO.CustomerCal_Hist B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
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
   MERGE INTO GTT_DPD A
   USING (SELECT A.ROWID row_id, 0
   FROM GTT_DPD A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID
   --WHERE  isnull(B.FlgProcessing,'N')='N'  
   /*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO GTT_DPD A
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
   FROM GTT_DPD A
          JOIN MAIN_PRO.CustomerCal_Hist C   ON A.SourceSystemCustomerID = C.SourceSystemCustomerID 
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
   ------------------------------------------------=========================END===========================
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM ACL_NPA_DATA 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                                     FROM Automate_Advances 
                                                                                      WHERE  Date_ IN ( v_Date )
                        )
    ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DELETE ACL_NPA_DATA

       WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                            FROM Automate_Advances 
                                                                             WHERE  Date_ IN ( v_Date )
               )
      ;

   END;
   END IF;
   INSERT INTO ACL_NPA_DATA(Generation_Date,	Process_Date,	UCIC,	CustomerID,	CustomerName,	Branchcode,	CustomerAcid,	Facilitytype,	ProductCode,	ProductName,	Balance,	DrawingPower,	CurrentLimit,	UnAppliedIntt,	ReviewDueDt,	CreditSinceDt,	ContiExcessDt,	StockStDt,	DebitSinceDt,	LastCrDate,	PreQtrCredit,	PrvQtrInt,	CurQtrCredit,	CurQtrInt,OverdueAmt,	OverDueSinceDt,	SecurityValue,	NetBalance,	PrincOutStd,	ApprRV,	SecuredAmt,	UnSecuredAmt,	Provsecured,	ProvUnsecured,	TotalProvision,	RefPeriodOverdue,	RefPeriodOverDrawn,	RefPeriodNoCredit,	RefPeriodIntService,	RefPeriodStkStatement,	RefPeriodReview,	PrincOverdue,	PrincOverdueSinceDt,	IntOverdue,	IntOverdueSinceDt,	OtherOverdue,	OtherOverdueSinceDt,	DPD_IntService,	DPD_NoCredit,	DPD_Overdrawn,	DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,	DPD_PrincOverdue,	DPD_IntOverdueSince,	DPD_OtherOverdueSince,	DPD_Max,	InitialNpaDt,	FinalNpaDt,	InitialAssetClassAlt_Key,	InitialAssetClass,	FinalAssetClassAlt_Key,	FialAssetClass,	DegReason,	FlgDeg,	FlgUpg,	NPA_Reason,	SecuredFlag,	Asset_Norm,	CD,	NPANorms,	WriteOffAmount,	ActSegmentCode,	ProductSubGroup,	SourceName,	ProductGroup,	SchemeType,	AcBuRevisedSegmentCode,	DegDate)
     SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
              UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CustomerID  ,
              CustomerName ,
              B.Branchcode ,
              B.CustomerAcid ,
              b.Facilitytype ,
              b.ProductCode ,
              ProductName ,
              Balance ,
              DrawingPower ,
              CurrentLimit ,
              UnserviedInt UnAppliedIntt  ,
              B.ReviewDueDt ,
              CreditSinceDt ,
              b.ContiExcessDt ,
              B.StockStDt ,
              DebitSinceDt ,
              B.LastCrDate ,
              PreQtrCredit ,
              PrvQtrInt ,
              CurQtrCredit ,
              CurQtrInt ,
              --IntNotServicedDt	
              OverdueAmt ,
              B.OverDueSinceDt ,
              SecurityValue ,
              NetBalance ,
              PrincOutStd ,
              ApprRV ,
              SecuredAmt ,
              UnSecuredAmt ,
              Provsecured ,
              ProvUnsecured ,
              TotalProvision ,
              B.RefPeriodOverdue ,
              B.RefPeriodOverDrawn ,
              B.RefPeriodNoCredit ,
              B.RefPeriodIntService ,
              B.RefPeriodStkStatement ,
              B.RefPeriodReview ,
              PrincOverdue ,
              B.PrincOverdueSinceDt ,
              IntOverdue ,
              B.IntOverdueSinceDt ,
              OtherOverdue ,
              B.OtherOverdueSinceDt ,
              DPD_IntService ,
              DPD_NoCredit ,
              DPD_Overdrawn ,
              DPD_Overdue ,
              DPD_Renewal ,
              DPD_StockStmt ,
              DPD_PrincOverdue ,
              DPD_IntOverdueSince ,
              DPD_OtherOverdueSince ,
              DPD_Max ,
              InitialNpaDt ,
              FinalNpaDt ,
              InitialAssetClassAlt_Key ,
              a1.AssetClassShortNameEnum InitialAssetClass  ,
              FinalAssetClassAlt_Key ,
              a2.AssetClassShortNameEnum FialAssetClass  ,
              b.DegReason ,
              b.FlgDeg ,
              b.FlgUpg ,
              NPA_Reason ,
              FLGSECURED SecuredFlag  ,
              A.Asset_Norm ,
              b.CD ,
              pd.NPANorms ,
              b.WriteOffAmount ,
              b.ActSegmentCode ,
              ProductSubGroup ,
              SourceName ,
              ProductGroup ,
              PD.SchemeType ,
              CASE 
                   WHEN SourceName = 'Ganaseva' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE S.AcBuRevisedSegmentCode
                 END AcBuRevisedSegmentCode  ,
              A.DegDate 
       FROM MAIN_PRO.CustomerCal_Hist A
              JOIN MAIN_PRO.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN GTT_DPD DPD   ON DPD.AccountEntityID = b.AccountEntityID
        WHERE  B.FinalAssetClassAlt_Key > 1
                 AND B.EffectiveFromTimeKey <= v_timekey
                 AND B.EffectiveFromTimeKey >= v_Timekey
                 AND A.EffectiveFromTimeKey <= v_timekey
                 AND A.EffectiveFromTimeKey >= v_Timekey ;
   --AND isnull(b.WriteOffAmount,0)=0	--	 where B.FlgUpg='U'
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM ACL_UPG_DATA 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                                     FROM Automate_Advances 
                                                                                      WHERE  Timekey = v_Timekey )
    ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DELETE ACL_UPG_DATA

       WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                            FROM Automate_Advances 
                                                                             WHERE  Timekey = v_Timekey )
      ;

   END;
   END IF;
   INSERT INTO ACL_UPG_DATA( Generation_Date,	Process_Date,	UCIC,	CustomerID,	CustomerName,	Branchcode,	CustomerAcid,	Facilitytype,	ProductCode,	ProductName,	Balance,	DrawingPower,	CurrentLimit,	UnAppliedIntt,	ReviewDueDt,	CreditSinceDt,	ContiExcessDt,	StockStDt,	DebitSinceDt,	LastCrDate,	PreQtrCredit,	PrvQtrInt,	CurQtrCredit,	CurQtrInt,	OverdueAmt,	OverDueSinceDt,	SecurityValue,	NetBalance,	PrincOutStd,	ApprRV,	SecuredAmt,	UnSecuredAmt,	Provsecured,	ProvUnsecured,	TotalProvision,	RefPeriodOverdue,	RefPeriodOverDrawn,	RefPeriodNoCredit,	RefPeriodIntService,	RefPeriodStkStatement,	RefPeriodReview,	PrincOverdue,	PrincOverdueSinceDt,	IntOverdue,	IntOverdueSinceDt,	OtherOverdue,	OtherOverdueSinceDt,	DPD_IntService,	DPD_NoCredit,	DPD_Overdrawn,	DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,	DPD_PrincOverdue,	DPD_IntOverdueSince,	DPD_OtherOverdueSince,	DPD_Max,	InitialNpaDt,	FinalNpaDt,	InitialAssetClassAlt_Key,	InitialAssetClass,	FinalAssetClassAlt_Key,	FialAssetClass,	DegReason,	FlgDeg,	FlgUpg,	NPA_Reason,	SecuredFlag,	Asset_Norm,	CD,	NPANorms,	WriteOffAmount,	ActSegmentCode,	ProductSubGroup,	SourceName,	ProductGroup,	SchemeType,	AcBuRevisedSegmentCode)
     SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
              UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CustomerID  ,
              CustomerName ,
              B.Branchcode ,
              B.CustomerAcid ,
              b.Facilitytype ,
              b.ProductCode ,
              ProductName ,
              Balance ,
              DrawingPower ,
              CurrentLimit ,
              UnserviedInt UnAppliedIntt  ,
              B.ReviewDueDt ,
              CreditSinceDt ,
              b.ContiExcessDt ,
              B.StockStDt ,
              DebitSinceDt ,
              B.LastCrDate ,
              PreQtrCredit ,
              PrvQtrInt ,
              CurQtrCredit ,
              CurQtrInt ,
              --IntNotServicedDt	
              OverdueAmt ,
              B.OverDueSinceDt ,
              SecurityValue ,
              NetBalance ,
              PrincOutStd ,
              ApprRV ,
              SecuredAmt ,
              UnSecuredAmt ,
              Provsecured ,
              ProvUnsecured ,
              TotalProvision ,
              B.RefPeriodOverdue ,
              B.RefPeriodOverDrawn ,
              B.RefPeriodNoCredit ,
              B.RefPeriodIntService ,
              B.RefPeriodStkStatement ,
              B.RefPeriodReview ,
              PrincOverdue ,
              B.PrincOverdueSinceDt ,
              IntOverdue ,
              B.IntOverdueSinceDt ,
              OtherOverdue ,
              B.OtherOverdueSinceDt ,
              DPD_IntService ,
              DPD_NoCredit ,
              DPD_Overdrawn ,
              DPD_Overdue ,
              DPD_Renewal ,
              DPD_StockStmt ,
              DPD_PrincOverdue ,
              DPD_IntOverdueSince ,
              DPD_OtherOverdueSince ,
              DPD_Max ,
              InitialNpaDt ,
              FinalNpaDt ,
              InitialAssetClassAlt_Key ,
              a1.AssetClassShortNameEnum InitialAssetClass  ,
              FinalAssetClassAlt_Key ,
              a2.AssetClassShortNameEnum FialAssetClass  ,
              b.DegReason ,
              b.FlgDeg ,
              b.FlgUpg ,
              NPA_Reason ,
              FLGSECURED SecuredFlag  ,
              A.Asset_Norm ,
              b.CD ,
              pd.NPANorms ,
              b.WriteOffAmount ,
              b.ActSegmentCode ,
              ProductSubGroup ,
              SourceName ,
              ProductGroup ,
              PD.SchemeType ,
              CASE 
                   WHEN SourceName = 'Ganaseva' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE S.AcBuRevisedSegmentCode
                 END AcBuRevisedSegmentCode  
       FROM MAIN_PRO.CustomerCal_Hist A
              JOIN MAIN_PRO.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN GTT_DPD DPD   ON DPD.AccountEntityID = b.AccountEntityID

       -- where B.FinalAssetClassAlt_Key>1
       WHERE  B.InitialAssetClassAlt_Key > 1
                AND B.FinalAssetClassAlt_Key = 1
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLDATAINSERTION" TO "ADF_CDR_RBL_STGDB";
