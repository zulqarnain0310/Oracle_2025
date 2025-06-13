--------------------------------------------------------
--  DDL for Procedure SMA_INVESTMENT_REPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" 
AS
   ---------------------------------------Overdue Bill & PC Start--------------------------------------------------------
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' )
    );
   v_PROCESSDATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_PrvDayTimekey NUMBER(10,0) := ( SELECT timekey - 1 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   ---------------------------------------Investment Start--------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempInvestment') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempInvestment ';
   END IF;
   DELETE FROM tt_TempInvestment;
   UTILS.IDENTITY_RESET('tt_TempInvestment');

   INSERT INTO tt_TempInvestment ( 
   	SELECT DISTINCT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
                    B.BRANCHCODE ,
                    ISSUERID ,
                    ISSUERNAME ,
                    REF_TXN_SYS_CUST_ID ,
                    ISSUER_CATEGORY_CODE ,
                    UCIFID ,
                    PANNO ,
                    --SUBSTRING(INVID,1,charindex('_',INVID)-1) as INVID
                    CASE 
                         WHEN INVID LIKE '%/_%' THEN SUBSTR(INVID, 1, INSTR(INVID, '_') - 1)
                    ELSE INVID
                       END INVID  ,
                    b.ISIN ,
                    I.InstrumentTypeName ,
                    INSTRNAME ,
                    b.INVESTMENTNATURE ,
                    EXPOSURETYPE ,
                    MATURITYDT ,
                    HOLDINGNATURE ,
                    BOOKTYPE ,
                    BOOKVALUE ,
                    MTMVALUE ,
                    INTEREST_DIVIDENDDUEDATE ,
                    INTEREST_DIVIDENDDUEAMOUNT ,
                    DPD ,
                    FLGDEG ,
                    DEGREASON ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN 'N'
                    ELSE FLGUPG
                       END) FLGUPG  ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN NULL
                    ELSE UPGDATE
                       END) UPGDATE  ,
                    TOTALPROVISON ,
                    AC.AssetClassShortName ASSETCLASS  ,
                    C.PartialRedumptionDueDate ,
                    c.PartialRedumptionSettledY_N ,
                    c.NPIDt ,
                    c.BalanceSheetDate ,
                    c.ListedShares ,
                    c.DPD_BS_Date ,
                    c.BookValueINR ,
                    C.DPD_DivOverdue ,
                    C.DPD_Maturity ,
                    C.PartialRedumptionDPD 
   	  FROM InvestmentIssuerDetail a
             JOIN InvestmentBasicDetail B   ON A.IssuerEntityId = B.IssuerEntityId
             AND a.EffectiveFromTimeKey <= v_TimeKey
             AND a.EffectiveToTimeKey >= v_TimeKey
             AND b.EffectiveFromTimeKey <= v_TimeKey
             AND b.EffectiveToTimeKey >= v_TimeKey
             JOIN InvestmentFinancialDetail c   ON b.InvEntityId = c.InvEntityId
             AND c.EffectiveFromTimeKey <= v_TimeKey
             AND c.EffectiveToTimeKey >= v_TimeKey
             JOIN DimAssetClass AC   ON AC.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey
             AND AC.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
             LEFT JOIN DimInstrumentType I   ON I.EffectiveFromTimeKey <= v_TimeKey
             AND I.EffectiveToTimeKey >= v_TimeKey
             AND B.InstrTypeAlt_Key = I.InstrumentTypeAlt_Key
   	 WHERE  c.FinalAssetClassAlt_Key = 1 );
   UPDATE tt_TempInvestment
      SET DPD = CASE 
                     WHEN NVL(DPD_DivOverdue, 0) >= NVL(DPD_Maturity, 0)
                       AND NVL(DPD_DivOverdue, 0) >= NVL(PartialRedumptionDPD, 0) 
                     --and ISNULL(DPD_DivOverdue,0)>=ISNULL(DPD_BS_Date,0)
                     THEN NVL(DPD_DivOverdue, 0)
                     WHEN NVL(DPD_Maturity, 0) >= NVL(DPD_DivOverdue, 0)
                       AND NVL(DPD_Maturity, 0) >= NVL(PartialRedumptionDPD, 0) 
                     --and ISNULL(DPD_Maturity,0)>=ISNULL(DPD_BS_Date,0)
                     THEN NVL(DPD_Maturity, 0)

          --WHEN ISNULL(DPD_BS_Date,0)>=ISNULL(DPD_DivOverdue,0) 

          --      and ISNULL(DPD_BS_Date,0)>=ISNULL(PartialRedumptionDPD,0) 

          --      and ISNULL(DPD_BS_Date,0)>=ISNULL(DPD_Maturity,0)

          --THEN ISNULL(DPD_BS_Date,0)
          ELSE NVL(PartialRedumptionDPD, 0)
             END;
   IF utils.object_id('TEMPDB..tt_Temp_SMA_Main_Table') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_SMA_Main_Table ';
   END IF;
   DELETE FROM tt_Temp_SMA_Main_Table;
   UTILS.IDENTITY_RESET('tt_Temp_SMA_Main_Table');

   INSERT INTO tt_Temp_SMA_Main_Table ( 
   	SELECT * 
   	  FROM ( 
             --select * from investment_data
             SELECT v_PROCESSDATE Report_Date  ,
                    --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
                    ---------RefColumns---------
                    UCIFID UCIF_ID  ,
                    REF_TXN_SYS_CUST_ID CustomerID  ,
                    b.CustomerName ,
                    A.BRANCHCODE ,
                    c.BranchName ,
                    c.BranchStateName ,
                    c.BranchRegion ,
                    INVID CustomerAcID  ,
                    PANNO ,
                    'Calypso' SourceName  ,
                    NULL FacilityType  ,
                    NULL SchemeType  ,
                    NULL ProductCode  ,
                    NULL ProductName  ,
                    NULL Seg_Code  ,
                    --,CASE WHEN SourceName='FIS' THEN 'FI'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
                    --		else AcBuSegmentDescription end as [Segment Description]
                    NULL Segment_Description  ,
                    --,CASE WHEN SourceName='FIS' THEN 'FI'  
                    --	WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
                    --  else AcBuRevisedSegmentCode end [Business Segment] 
                    NULL Business_Segment  ,
                    --,CASE WHEN AcBuRevisedSegmentCode in ('Retail','WCF','Agri-Retail','FI','MSME','SCF','Credit Card')
                    --THEN 'Retail'  
                    --	WHEN AcBuRevisedSegmentCode in ('CIB','FIG','Agri-Wholesale','MC','CB','SME','Treasury')
                    --THEN 'Wholesale' 
                    --  else AcBuRevisedSegmentCode end [Wholesale / Retail] 
                    NULL Wholesale_Retail  ,
                    NULL Balance  ,
                    NULL PrincOutStd  ,
                    NULL DrawingPower  ,
                    NULL CurrentLimit  ,
                    --,CASE WHEN SourceName = 'Finacle' AND SchemeType ='ODA' THEN (
                    --		CASE WHEN (ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
                    --											THEN			ISNULL(a.DrawingPower,0) 
                    --											ELSE ISNULL(a.CurrentLimit,0)  
                    --											END 
                    --										)
                    --				  )<=0
                    --		THEN	0	 
                    --		ELSE  
                    --		ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
                    --											THEN			ISNULL(a.DrawingPower,0) 
                    --											ELSE ISNULL(a.CurrentLimit,0)  
                    --											END 
                    --										)
                    --END) ELSE 0 END
                    NULL OverDrawn_Amount  ,
                    0 DPD_Overdrawn  ,
                    --,a.ContiExcessDt as [Limit/DP Overdrawn Date]
                    NULL Limit_DP_Overdrawn_Date  ,
                    NULL OverdueAmt  ,
                    NULL OverDueSinceDt  ,
                    0 DPD_Overdue  ,
                    NULL Bill_PC_Overdue_Amount  ,
                    NULL Overdue_Bill_PC_ID  ,
                    --,[Bill/PC Overdue Date]
                    NULL Bill_PC_Overdue_Date  ,
                    0 DPD_Bill_PC  ,
                    INTEREST_DIVIDENDDUEDATE ,
                    NVL(INTEREST_DIVIDENDDUEAMOUNT, 0) INTEREST_DIVIDENDDUEAMOUNT  ,
                    NVL(DPD, 0) inv_DPD  ,
                    PartialRedumptionDueDate ,
                    0 SMA_DPD  ,
                    NULL AccountFlgSMA  ,
                    NULL AccountSMA_Dt  ,
                    NULL AccountSMA_AssetClass  ,
                    NULL SMA_Reason  ,
                    0 DPD_UCIF_ID  ,
                    NULL UCICFlgSMA  ,
                    NULL UCICSMA_Dt  ,
                    NULL UCICSMA_AssetStatus  ,
                    NULL SMA_Classification_Date  ,
                    NULL in_default_Y_N_  ,
                    NULL in_default_date  ,
                    NULL out_of_default_Y_N_  ,
                    NULL out_of_default_date  ,
                    NULL MovementFromDate  ,
                    NULL MovementFromStatus  ,
                    NULL MovementToStatus  ,
                    NULL Asset_Norm  ,
                    NULL NPA_Norms  ,
                    NULL Credit_FB_Exposure  ,
                    NULL Credit_NFB_Exposure  ,
                    NULL Non_SLR  ,
                    NULL LER  ,
                    NULL Total_Exposure  ,
                    NULL Exposure_5crore_above_Flag  ,
                    NULL FDOD_Flag  ,
                    NULL Limit_Expiry_Date  ,
                    NULL DPD_Limit_Expiry  ,
                    NULL Stock_Statement_valuation_date  ,
                    0 DPD_StockStmt  ,
                    NULL Debit_Balance_Since_Date  ,
                    NULL Last_Credit_Date  ,
                    0 DPD_NoCredit  ,
                    NULL Current_quarter_credit  ,
                    NULL Current_quarter_interest  ,
                    NULL Interest_Not_Serviced  ,
                    0 DPD_out_of_order  ,
                    NULL CC_OD_Interest_Service  ,
                    NULL PrincOverdue  ,
                    NULL Principal_Overdue_Date  ,
                    0 DPD_Principal_Overdue  ,
                    NULL IntOverdue  ,
                    NULL Interest_Overdue_Date  ,
                    0 DPD_Interest_Overdue  ,
                    NULL OtherOverdue  ,
                    NULL Other_OverDue_Date  ,
                    0 DPD_Other_Overdue  
             FROM tt_TempInvestment a
                    JOIN CustomerBasicDetail b   ON a.Ref_Txn_Sys_Cust_ID = b.CustomerId
                    LEFT JOIN DimBranch c   ON a.BranchCode = c.BranchCode
                    AND c.EffectiveFromTimeKey <= v_Timekey
                    AND c.EffectiveToTimeKey >= v_Timekey
              WHERE  b.EffectiveFromTimeKey <= v_Timekey
                       AND b.EffectiveToTimeKey >= v_Timekey ) a );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_Temp_SMA_Main_Table  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select 
   -- replace(CurrentProcessingDate,'/','-') CurrentProcessingDate
   --,SrNo
   --,BranchCode
   --,BranchName
   --,BranchStateName
   --,SourceName
   --,CustomerID
   --,SourceSystemCustomerID
   --,UCIF_ID
   --,CustomerAcID
   --,PANNO
   --,CustomerName
   --,CustSegmentCode
   --,FacilityType
   --,ProductCode
   --,ProductName
   --,ActSegmentCode
   --,AcBuRevisedSegmentCode
   --,SchemeType
   --,Balance
   --,PrincOutStd
   --,PrincOverdue
   --,IntOverdue
   --,OtherOverdue
   --,OverdueAmt
   --,CurrentLimit
   ----,ContiExcessDt
   --,convert(nvarchar(10),convert(date,ContiExcessDt , 105),23) as ContiExcessDt
   ----,StockStDt
   --,convert(nvarchar(10),convert(date,StockStDt , 105),23) as StockStDt
   ----,LastCrDate
   --,convert(nvarchar(10),convert(date,LastCrDate , 105),23) as LastCrDate
   ----,IntNotServicedDt
   --,convert(nvarchar(10),convert(date,IntNotServicedDt , 105),23) as IntNotServicedDt
   ----,OverDueSinceDt
   --,convert(nvarchar(10),convert(date,OverDueSinceDt , 105),23) as OverDueSinceDt
   ----,ReviewDueDt
   --,convert(nvarchar(10),convert(date,ReviewDueDt , 105),23) as ReviewDueDt
   --,DPD_StockStmt
   --,DPD_NoCredit
   --,DPD_IntService
   --,DPD_Overdrawn
   --,DPD_Overdue
   --,DPD_Renewal
   --,SMA_DPD
   --,AccountFlgSMA
   ----,AccountSMA_Dt
   --,convert(nvarchar(10),convert(date,AccountSMA_Dt , 105),23) as AccountSMA_Dt
   --,AccountSMA_AssetClass
   --,SMA_Reason
   --,DPD_UCIF_ID
   --,UCICFlgSMA
   ----,UCICSMA_Dt
   --,convert(nvarchar(10),convert(date,UCICSMA_Dt , 105),23) as UCICSMA_Dt
   --,UCICSMA_AssetStatus
   ----,MovementFromDate
   --,convert(nvarchar(10),convert(date,MovementFromDate , 105),23) as MovementFromDate
   --,MovementFromStatus
   --,MovementToStatus
   --,Asset_Norm
   --from SMA_OUTPUT
   ---------------------------------------SMA Report END-------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMA_INVESTMENT_REPORT" TO "ADF_CDR_RBL_STGDB";
