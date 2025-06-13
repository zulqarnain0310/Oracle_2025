--------------------------------------------------------
--  DDL for Procedure INTERESTREVERSALREPORT_HISTDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" 
AS
   v_Timekey NUMBER(10,0) := 26364;
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
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_49') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_49 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_49;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_49');

   INSERT INTO tt_TEMPTABLE_49 ( 
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
             REPLACE(ProductName, ',', ' ') Scheme_Description  ,
             ActSegmentCode Seg_Code  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END Segment_Description  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'

                  -- WHEN SourceName='VisionPlus' THEN 'Credit Card'
                  WHEN SourceName = 'VisionPlus'
                    AND B.ProductCode IN ( '777','780' )
                   THEN 'Retail'
                  WHEN SourceName = 'VisionPlus'
                    AND B.ProductCode NOT IN ( '777','780' )
                   THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             DPD_Max Account_DPD  ,
             FinalNpaDt NPA_Date  ,
             Balance Outstanding  ,
             --,ISNULL(PrincOutStd,0) as [Principal Outstanding]
             CASE 
                  WHEN NVL(PrincOutStd, 0) < 0 THEN 0
             ELSE NVL(PrincOutStd, 0)
                END Principal_Outstanding  ,
             a2.SrcSysClassCode Asset_Classification  ,
             zz.SourceAssetClass Soirce_System_Status  ,
             NVL(IntOverdue, 0) interest_Dues  ,
             --,ISNULL(penal_due,0)	
             ' ' Penal_Dues  ,
             NVL(OtherOverdue, 0) Other_Dues  ,
             (NVL(int_receivable_adv, 0) + NVL(Accrued_interest, 0)) interest_accured_but_not_due  ,
             NVL(penal_int_receivable, 0) penal_accured_but_not_due  ,
             NVL(Balance_INT, 0) Credit_Card_interest_Outstanding  ,
             NVL(Balance_FEES, 0) Credit_Card_other_charges  ,
             NVL(Balance_GST, 0) Credit_Card_GST_ST_Outstanding  ,
             NVL(Interest_DividendDueAmount, 0) Interest_Dividend_on_Bond_Debentures  
        FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
               JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
               AND NVL(b.WriteOffAmount, 0) = 0
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
               AND Y.EffectiveFromTimeKey <= v_Timekey
               AND Y.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN RBL_MISDB_PROD.AdvCreditCardBalanceDetail YZ   ON YZ.AccountEntityID = B.AccountEntityID
               AND YZ.EffectiveFromTimeKey <= v_Timekey
               AND YZ.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN InvestmentFinancialDetail Z   ON Z.RefInvID = B.CustomerAcID
               AND Z.EffectiveFromTimeKey <= v_Timekey
               AND Z.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN ( SELECT DISTINCT RefSystemAcId ,
                                           SourceAssetClass 
                           FROM RBL_MISDB_PROD.AdvAcBalanceDetail 
                            WHERE  EffectiveFromTimeKey <= v_Timekey
                                     AND EffectiveToTimeKey >= v_Timekey ) ZZ   ON B.CustomerAcID = ZZ.RefSystemAcId
               LEFT JOIN DPD DPD   ON B.accountentityid = DPD.AccountEntityid
       WHERE  B.FinalAssetClassAlt_Key > 1
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--UNION
   --select  convert(nvarchar,@Date , 105) AS  [Report Date] 
   --,A.UCIF_ID as UCIC
   --,A.RefCustomerID as [CIF ID]
   --,REPLACE(CustomerName,',','') as [Borrower Name]
   --,B.BranchCode as [Branch Code]
   --,REPLACE(BranchName,',','') as [Branch Name]
   --,B.CustomerAcID as [Account No.]
   --,SourceName as [Source System]
   --,B.FacilityType as [Facility]
   --,SchemeType as [Scheme Type]
   --,B.ProductCode AS [Scheme Code]
   --,REPLACE(ProductName,',','') as [Scheme Description]
   --,ActSegmentCode as [Seg Code]
   --,CASE WHEN SourceName='Ganaseva' THEN 'FI'
   --		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
   --		else AcBuSegmentDescription end [Segment Description]
   --,CASE WHEN SourceName='Ganaseva' THEN 'FI'
   --		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
   --		else AcBuRevisedSegmentCode end [Business Segment]
   --,DPD_Max as [Account DPD]
   --,FinalNpaDt as [NPA Date]
   --,Balance AS [Outstanding]
   --,ISNULL(PrincOutStd,0) as [Principal Outstanding]
   --,zz.AssetClassCode as [Asset Classification]
   --,a2.SrcSysClassCode as	[Soirce System Status]
   --,ISNULL(IntOverdue,0)		[interest Dues]
   ----,ISNULL(penal_due,0)	
   --,'' [Penal Dues]
   --,ISNULL(OtherOverdue,0)			[Other Dues]
   --,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
   --,ISNULL(penal_int_receivable,0) [penal accured but not due]
   --,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
   --,ISNULL(Balance_FEES,0) [Credit Card other charges]
   --,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
   --,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
   --FROM PRO.CUSTOMERCAL A with (nolock)
   --INNER JOIN PRO.ACCOUNTCAL B with (nolock)
   --	ON A.CustomerEntityID=B.CustomerEntityID
   --LEFT JOIN DIMSOURCEDB src
   --	on b.SourceAlt_Key =src.SourceAlt_Key	
   --LEFT JOIN DIMPRODUCT PD
   --	ON PD.EffectiveToTimeKey=49999
   --	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
   --left join DimAssetClass a1
   --	on a1.EffectiveToTimeKey=49999
   --	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
   --left join DimAssetClass a2
   --	on a2.EffectiveToTimeKey=49999
   --	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
   --LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
   --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
   --LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
   --INNER JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
   --LEFT JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
   --LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [RBL_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
   --where  B.FinalAssetClassAlt_Key>1  
   --and (ISNULL(Balance_INT,0) > 0 OR 
   --ISNULL(Balance_FEES,0) > 0 OR
   --ISNULL(Balance_GST,0) > 0)
   --UNION
   --select  convert(nvarchar,@Date , 105) AS  [Report Date] 
   --,A.UCIF_ID as UCIC
   --,A.RefCustomerID as [CIF ID]
   --,REPLACE(CustomerName,',','') as [Borrower Name]
   --,B.BranchCode as [Branch Code]
   --,REPLACE(BranchName,',','') as [Branch Name]
   --,B.CustomerAcID as [Account No.]
   --,SourceName as [Source System]
   --,B.FacilityType as [Facility]
   --,SchemeType as [Scheme Type]
   --,B.ProductCode AS [Scheme Code]
   --,REPLACE(ProductName,',','') as [Scheme Description]
   --,ActSegmentCode as [Seg Code]
   --,CASE WHEN SourceName='Ganaseva' THEN 'FI'
   --		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
   --		else AcBuSegmentDescription end [Segment Description]
   --,CASE WHEN SourceName='Ganaseva' THEN 'FI'
   --		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
   --		else AcBuRevisedSegmentCode end [Business Segment]
   --,DPD_Max as [Account DPD]
   --,FinalNpaDt as [NPA Date]
   --,Balance AS [Outstanding]
   --,ISNULL(PrincOutStd,0) as [Principal Outstanding]
   --,zz.AssetClassCode as [Asset Classification]
   --,a2.SrcSysClassCode as	[Soirce System Status]
   --,ISNULL(IntOverdue,0)		[interest Dues]
   ----,ISNULL(penal_due,0)	
   --,'' [Penal Dues]
   --,ISNULL(OtherOverdue,0)			[Other Dues]
   --,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
   --,ISNULL(penal_int_receivable,0) [penal accured but not due]
   --,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
   --,ISNULL(Balance_FEES,0) [Credit Card other charges]
   --,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
   --,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
   --FROM PRO.CUSTOMERCAL A with (nolock)
   --INNER JOIN PRO.ACCOUNTCAL B with (nolock)
   --	ON A.CustomerEntityID=B.CustomerEntityID
   --LEFT JOIN DIMSOURCEDB src
   --	on b.SourceAlt_Key =src.SourceAlt_Key	
   --LEFT JOIN DIMPRODUCT PD
   --	ON PD.EffectiveToTimeKey=49999
   --	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
   --left join DimAssetClass a1
   --	on a1.EffectiveToTimeKey=49999
   --	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
   --left join DimAssetClass a2
   --	on a2.EffectiveToTimeKey=49999
   --	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
   --LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
   --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
   --LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
   --LEFT JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
   --INNER JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
   --LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [RBL_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
   --where  B.FinalAssetClassAlt_Key>1  
   --and ISNULL(Interest_DividendDueAmount,0) > 0 

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT_HISTDATA" TO "ADF_CDR_RBL_STGDB";
