--------------------------------------------------------
--  DDL for Procedure REPORTFORMATQUERY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."REPORTFORMATQUERY" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   ---------Degrade Report-------------------
   --select convert(nvarchar,@Date , 105) AS  [Process_date] 
   --,A.UCIF_ID as UCIC
   --,A.RefCustomerID as CustomerID
   --,CustomerName
   --,B.BranchCode
   --,BranchName
   --,CustomerAcID
   --,SourceName
   --,B.FacilityType
   --,SchemeType
   --,B.ProductCode
   --,ProductName
   --,ActSegmentCode
   --,AcBuSegmentDescription
   --,AcBuRevisedSegmentCode
   --,DPD_Max
   --,FinalNpaDt
   --,Balance
   --,NetBalance
   --,DrawingPower
   --,CurrentLimit
   --,(CASE WHEN (Balance -(DrawingPower+CurrentLimit)) < 0 then 0 else(Balance -(DrawingPower+CurrentLimit)) END)OverDrawn_Amt
   --,DPD_Overdrawn
   --,ContiExcessDt
   --,ReviewDueDt
   --,DPD_Renewal
   --,StockStDt
   --,DPD_StockStmt
   --,DebitSinceDt
   --,LastCrDate
   --,DPD_NoCredit
   --,CurQtrCredit
   --,CurQtrInt
   --,(CASE WHEN (CurQtrInt -CurQtrCredit) < 0 then 0 else(CurQtrInt -CurQtrCredit) END) [InterestNotServiced]
   --,DPD_IntService
   --,NULL [CC/OD Interest Service]
   --,OverdueAmt
   --,OverDueSinceDt
   --,DPD_Overdue
   --,PrincOverdue
   --,PrincOverdueSinceDt
   --,DPD_PrincOverdue
   --,IntOverdue
   --,IntOverdueSinceDt
   --,DPD_IntOverdueSince
   --,OtherOverdue
   --,OtherOverdueSinceDt
   --,DPD_OtherOverdueSince
   --,NULL [Bill/PC Overdue Amount]
   --,NULL [Overdue Bill/PC ID]
   --,NULL [Bill/PC Overdue Date]
   --,NULL [DPD Bill/PC]
   --,a2.AssetClassName as FinalAssetName
   --,A.DegReason
   --,NPANorms
   --FROM PRO.CUSTOMERCAL A
   --INNER JOIN PRO.ACCOUNTCAL B
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
   --LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
   --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode
   --	 where B.FinalAssetClassAlt_Key>1
   ----	 where B.FlgUpg='U'
   ------------------------------Upgrade Report
   --select convert(nvarchar,@Date , 105) AS  [Process_date] 
   --,A.UCIF_ID as UCIC
   --,A.RefCustomerID as CustomerID
   --,CustomerName
   --,B.BranchCode
   --,BranchName
   --,CustomerAcID
   --,SourceName
   --,B.FacilityType
   --,SchemeType
   --,B.ProductCode
   --,ProductName
   --,ActSegmentCode
   --,AcBuSegmentDescription
   --,AcBuRevisedSegmentCode
   --,DPD_Max
   --,FinalNpaDt
   --,UpgDate as UpgradeDate
   --,Balance
   --,NetBalance
   --,DrawingPower
   --,CurrentLimit
   --,(CASE WHEN (Balance -(DrawingPower+CurrentLimit)) < 0 then 0 else(Balance -(DrawingPower+CurrentLimit)) END)OverDrawn_Amt
   --,DPD_Overdrawn
   --,ContiExcessDt
   --,ReviewDueDt
   --,DPD_Renewal
   --,StockStDt
   --,DPD_StockStmt
   --,DebitSinceDt
   --,LastCrDate
   --,DPD_NoCredit
   --,CurQtrCredit
   --,CurQtrInt
   --,(CASE WHEN (CurQtrInt -CurQtrCredit) < 0 then 0 else(CurQtrInt -CurQtrCredit) END) [InterestNotServiced]
   --,DPD_IntService
   --,NULL [CC/OD OverDue Interest]
   --,OverdueAmt
   --,OverDueSinceDt
   --,DPD_Overdue
   --,PrincOverdue
   --,PrincOverdueSinceDt
   --,DPD_PrincOverdue
   --,IntOverdue
   --,IntOverdueSinceDt
   --,DPD_IntOverdueSince
   --,OtherOverdue
   --,OtherOverdueSinceDt
   --,DPD_OtherOverdueSince
   --,NULL [Bill/PC Overdue Amount]
   --,NULL [Overdue Bill/PC ID]
   --,NULL [Bill/PC Overdue Date]
   --,NULL [DPD Bill/PC]
   --,a2.AssetClassName as FinalAssetName
   --,NPANorms
   --FROM PRO.CUSTOMERCAL A
   --INNER JOIN PRO.ACCOUNTCAL B
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
   --LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
   --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode
   --where B.FlgUpg='U'
   ---------------------------------------------Asset Classification
   --select TOP 1 convert(nvarchar,@Date , 105) AS  [Process_date] 
   --,A.UCIF_ID as UCIC
   --,A.RefCustomerID as CustomerID
   --,CustomerName
   --,B.BranchCode
   --,BranchName
   --,CustomerAcID
   --,SourceName
   --,B.FacilityType
   --,SchemeType
   --,B.ProductCode
   --,ProductName
   --,ActSegmentCode
   --,AcBuSegmentDescription
   --,AcBuRevisedSegmentCode
   --,DPD_Max
   --,FinalNpaDt
   --,Balance
   --,NetBalance
   --,DrawingPower
   --,CurrentLimit
   --,(CASE WHEN (Balance -(DrawingPower+CurrentLimit)) < 0 then 0 else(Balance -(DrawingPower+CurrentLimit)) END)OverDrawn_Amt
   --,DPD_Overdrawn
   --,ContiExcessDt
   --,ReviewDueDt
   --,DPD_Renewal
   --,StockStDt
   --,DPD_StockStmt
   --,DebitSinceDt
   --,LastCrDate
   --,DPD_NoCredit
   --,CurQtrCredit
   --,CurQtrInt
   --,(CASE WHEN (CurQtrInt -CurQtrCredit) < 0 then 0 else(CurQtrInt -CurQtrCredit) END) [InterestNotServiced]
   --,DPD_IntService
   --,NULL [CC/OD Interest Service]
   --,OverdueAmt
   --,OverDueSinceDt
   --,DPD_Overdue
   --,PrincOverdue
   --,PrincOverdueSinceDt
   --,DPD_PrincOverdue
   --,IntOverdue
   --,IntOverdueSinceDt
   --,DPD_IntOverdueSince
   --,OtherOverdue
   --,OtherOverdueSinceDt
   --,DPD_OtherOverdueSince
   --,NULL [Bill/PC Overdue Amount]
   --,NULL [Overdue Bill/PC ID]
   --,NULL [Bill/PC Overdue Date]
   --,NULL [DPD Bill/PC]
   --,a2.AssetClassName as FinalAssetName
   --,A.DegReason
   --,NPANorms
   --FROM PRO.CUSTOMERCAL A
   --INNER JOIN PRO.ACCOUNTCAL B
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
   --LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
   --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode
   --	WHERE RefPeriodOverdue not in (181,366)
   --	AND B.FinalAssetClassAlt_Key>1
   --------	 where B.FlgUpg='U'
   -----------------------------------Provision
   --select   convert(nvarchar,@Date , 105) AS  [Process_date] 
   --,A.UCIF_ID as UCIC
   --,A.RefCustomerID as CustomerID
   --,CustomerName
   --,B.BranchCode
   --,BranchName
   --,CustomerAcID
   --,SourceName
   --,B.FacilityType
   --,SchemeType
   --,B.ProductCode
   --,ProductName
   --,ActSegmentCode
   --,AcBuSegmentDescription
   --,AcBuRevisedSegmentCode
   --,DPD_Max
   --,(CASE  WHEN A.SourceAlt_Key = 6 then 'CD' else NULL END) [Cycle Past due]
   --,FinalNpaDt
   --,a2.AssetClassName as FinalAssetName
   --,NPANorms
   --,B.NetBalance
   --,SecurityValue
   --,ApprRV
   --,B.SecuredAmt
   --,B.UnSecuredAmt
   --,B.TotalProvision
   --,B.Provsecured
   --,B.ProvUnsecured
   --,(B.NetBalance-B.TotalProvision)[Net NPA]
   --,(B.Provsecured/NULLIF(B.SecuredAmt,0))*100 [ProvisionSecured%]
   --,(B.ProvUnsecured/NULLIF(B.UnSecuredAmt,0))*100 [ProvisionUnSecured%]
   --,(B.TotalProvision/NULLIF(B.NetBalance,0))*100 [ProvisionTotal%]
   --,y.NetBalance [Prev. Qtr. Balance Outstanding]
   --,y.SecuredAmt	[Prev. Qtr. Secured Outstanding],
   --y.UnSecuredAmt	[Prev. Qtr. Unsecured Outstanding],
   --y.TotalProvision	[Prev. Qtr.Provision Total],
   --y.Provsecured	[Prev. Qtr.Provision Secured]
   --,y.ProvUnsecured	[Prev. Qtr. Provision Unsecured]
   --,y.NetNPA	[Prev. Qtr. Net NPA]
   --,CASE WHEN (B.NetBalance - Y.netBalance) < 0 then 0 ELSE (B.NetBalance - Y.netBalance) END NPAIncrease
   --,CASE WHEN (B.NetBalance - Y.netBalance) >= 0 then 0 ELSE (B.NetBalance - Y.netBalance) END NPADecrease
   --,CASE WHEN (B.TotalProvision - Y.TotalProvision) < 0 then 0 ELSE (B.TotalProvision - Y.TotalProvision) END ProvisionIncrease
   --,CASE WHEN (B.TotalProvision - Y.TotalProvision) >= 0 then 0 ELSE (B.TotalProvision - Y.TotalProvision) END ProvisionDecrease
   --,CASE WHEN ((B.NetBalance-B.TotalProvision) - y.NetNPA) < 0 then 0 ELSE ((B.NetBalance-B.TotalProvision) - y.NetNPA) END NetNPAIncrease
   --,CASE WHEN ((B.NetBalance-B.TotalProvision) - y.NetNPA) >= 0 then 0 ELSE ((B.NetBalance-B.TotalProvision) - y.NetNPA) END NetNPAnDecrease
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
   --LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
   --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode
   --LEFT JOIN (
   --select A. CustomerEntityID,NetBalance,SecuredAmt,UnSecuredAmt,TotalProvision,Provsecured,ProvUnsecured,(NetBalance-totalprovision)NetNPA
   --FROM PRO.CUSTOMERCAL A with (nolock)
   --INNER JOIN PRO.ACCOUNTCAL B with (nolock)
   --	ON A.CustomerEntityID=B.CustomerEntityID
   --	WHERE B.EffectiveFromTimeKey <= @LastQtrDateKey AND b.EffectiveToTimeKey >=  @LastQtrDateKey)Y 
   --	ON A.CustomerEntityID = Y.CustomerEntityID
   --WHERE B.FinalAssetClassAlt_Key>1
   ----	---------------------------------Interest Reversal---------------------------------
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             BranchName ,
             CustomerAcID ,
             SourceName ,
             B.FacilityType ,
             SchemeType ,
             B.ProductCode ,
             ProductName ,
             ActSegmentCode ,
             AcBuSegmentDescription ,
             AcBuRevisedSegmentCode ,
             DPD_Max ,
             FinalNpaDt ,
             Balance ,
             NetBalance ,
             a2.AssetClassName FinalassetClass  ,
             AssetClass Asset_Class_Code  ,
             IntOverdue interest_Due  ,
             NULL Penal_Due  ,
             OtherOverdue Other_Dues  ,
             NULL interest_receivable_accured_interest  ,
             NULL penal_int_receivable  ,
             NULL interest_Outstanding  ,
             NULL Other_Charges_outstanding  ,
             NULL GST_Service_Tax_Outstanding  ,
             NULL Interest_Dividend_Overdue_Amount  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
       WHERE  B.FinalAssetClassAlt_Key > 1 
        FETCH FIRST 1 ROWS ONLY ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REPORTFORMATQUERY" TO "ADF_CDR_RBL_STGDB";
