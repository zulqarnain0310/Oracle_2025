--------------------------------------------------------
--  DDL for Procedure SP_FINALACLRFOUTPUT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );

BEGIN

   -----------------------------------------ACL PROCESSING---------------
   --DBCC shrinkfile (log,1024)
   --------DBCC shrinkfile (log,1)
   --------DBCC shrinkfile (log,1)
   --------DBCC shrinkfile (log,1)
   --------DBCC shrinkfile (log,1)
   PRO_RBL_MISDB_PROD.InsertDataforAssetClassficationRBL(v_Timekey) ;
   PRO_RBL_MISDB_PROD.MAINPROECESSFORASSETCLASSFICATION() ;/*
   ---------------------------------------------------ACL OUTPUT ---------------

   IF (select count(*) from ACL_NPA_DATA 
   	where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')) > 0
   	BEGIN
   	delete from ACL_NPA_DATA where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')
   	END

   	INSERT INTO  ACL_NPA_DATA
   SELECT 
         convert(nvarchar,GETDATE() , 105) AS  [Generation Date]
   	  ,  convert(nvarchar,@Date, 105) Process_Date,
   	A.UCIF_ID as UCIC, A.RefCustomerID CustomerID, CustomerName,B.Branchcode,CustomerAcid, b.Facilitytype ,b.ProductCode
   	,ProductName
   	,Balance,DrawingPower	,CurrentLimit,UnserviedInt UnAppliedIntt, ReviewDueDt,CreditSinceDt,b.ContiExcessDt,StockStDt,DebitSinceDt
   	,LastCrDate,PreQtrCredit,PrvQtrInt,CurQtrCredit,CurQtrInt,
   	--IntNotServicedDt	
   	OverdueAmt	,OverDueSinceDt	
   	,SecurityValue,NetBalance,PrincOutStd	,ApprRV,SecuredAmt,UnSecuredAmt,Provsecured	
   	,ProvUnsecured
   	,TotalProvision,RefPeriodOverdue	,RefPeriodOverDrawn	,RefPeriodNoCredit,
   	RefPeriodIntService,RefPeriodStkStatement,RefPeriodReview,PrincOverdue,	PrincOverdueSinceDt,	
   	IntOverdue,	IntOverdueSinceDt,	OtherOverdue,	OtherOverdueSinceDt,DPD_IntService,	DPD_NoCredit,	
   	DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
   	,DPD_OtherOverdueSince,DPD_Max	,InitialNpaDt,	FinalNpaDt,InitialAssetClassAlt_Key
   	,a1.AssetClassShortNameEnum InitialAssetClass
   	,FinalAssetClassAlt_Key ,a2.AssetClassShortNameEnum FialAssetClass
   	,b.DegReason,b.FlgDeg, b.FlgUpg,NPA_Reason,FLGSECURED As SecuredFlag
   	,a.Asset_Norm
   	,b.CD
   	,pd.NPANorms,b.WriteOffAmount
   	,b.ActSegmentCode,ProductSubGroup
   	,SourceName
   	,ProductGroup
   	,PD.SchemeType
   	,CASE WHEN SourceName='FIS' THEN 'FI'
   		  --WHEN SourceName='VisionPlus' THEN 'Credit Card'
   		  WHEN SourceName='VisionPlus' and B.ProductCode in ('777','780') THEN 'Retail'
   		  WHEN SourceName='VisionPlus' and B.ProductCode not in ('777','780') THEN 'Credit Card'
   		else S.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode
   ----SELECT ActSegmentCode,* FROM PRO.ACCOUNTCAL
   ,a.DegDate
   ,REPLACE(isnull(B.MOC_Dt,A.MOC_Dt),',','')MOC_Dt
   ,REPLACE(isnull(B.MOCReason,A.MOCReason),',','')MOCReason
   --into #data
   FROM PRO.CUSTOMERCAL A
   	INNER JOIN PRO.ACCOUNTCAL B
   		ON A.CustomerEntityID=B.CustomerEntityID
       LEFT JOIN DIMSOURCEDB src
   		on b.SourceAlt_Key =src.SourceAlt_Key	
   		and src.EffectiveFromTimeKey <=@Timekey and src.EffectiveToTimeKey >=@Timekey
   	LEFT JOIN DIMPRODUCT PD
   		ON PD.EffectiveToTimeKey=49999
   		AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
   	left join DimAssetClass a1
   		on a1.EffectiveToTimeKey=49999
   		and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
   	left join DimAssetClass a2
   		on a2.EffectiveToTimeKey=49999
   		and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
   	LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
   	and S.EffectiveToTimeKey = 49999
   WHERE B.FinalAssetClassAlt_Key>1
   	--AND isnull(b.WriteOffAmount,0)=0	--	 where B.FlgUpg='U'

   select @Date as DateofData,'ACL_NPA_Data'TableName,count(1)Count from ACL_NPA_DATA where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')

   IF (select count(1) from ACL_UPG_DATA 
   	where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')) > 0
   	BEGIN
   	delete from ACL_UPG_DATA where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y') 
   	 END


   	INSERT INTO ACL_UPG_DATA
   SELECT 
         convert(nvarchar,getdate() , 105) AS  [Generation Date]
   	  ,  convert(nvarchar,@Date, 105) Process_Date,
   	A.UCIF_ID as UCIC, A.RefCustomerID CustomerID, CustomerName,B.Branchcode,CustomerAcid, b.Facilitytype ,b.ProductCode
   	,ProductName
   	,Balance,DrawingPower	,CurrentLimit,UnserviedInt UnAppliedIntt, ReviewDueDt,CreditSinceDt,b.ContiExcessDt,StockStDt,DebitSinceDt
   	,LastCrDate,PreQtrCredit,PrvQtrInt,CurQtrCredit,CurQtrInt,
   	--IntNotServicedDt	
   	OverdueAmt	,OverDueSinceDt	
   	,SecurityValue,NetBalance,PrincOutStd	,ApprRV,SecuredAmt,UnSecuredAmt,Provsecured	
   	,ProvUnsecured
   	,TotalProvision,RefPeriodOverdue	,RefPeriodOverDrawn	,RefPeriodNoCredit,
   	RefPeriodIntService,RefPeriodStkStatement,RefPeriodReview,PrincOverdue,	PrincOverdueSinceDt,	
   	IntOverdue,	IntOverdueSinceDt,	OtherOverdue,	OtherOverdueSinceDt,DPD_IntService,	DPD_NoCredit,	
   	DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
   	,DPD_OtherOverdueSince,DPD_Max	,InitialNpaDt,	FinalNpaDt,InitialAssetClassAlt_Key
   	,a1.AssetClassShortNameEnum InitialAssetClass
   	,FinalAssetClassAlt_Key ,a2.AssetClassShortNameEnum FialAssetClass
   	,b.DegReason,b.FlgDeg, b.FlgUpg,NPA_Reason,FLGSECURED As SecuredFlag
   	,a.Asset_Norm
   	,b.CD
   	,pd.NPANorms,b.WriteOffAmount
   	,b.ActSegmentCode,ProductSubGroup
   	,SourceName
   	,ProductGroup
   	,PD.SchemeType
   	,CASE WHEN SourceName='FIS' THEN 'FI'
   		  --WHEN SourceName='VisionPlus' THEN 'Credit Card'
   		  WHEN SourceName='VisionPlus' and B.ProductCode in ('777','780') THEN 'Retail'
   		  WHEN SourceName='VisionPlus' and B.ProductCode not in ('777','780') THEN 'Credit Card'
   		else S.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode
   		,REPLACE(isnull(B.MOC_Dt,A.MOC_Dt),',','')MOC_Dt
   ,REPLACE(isnull(B.MOCReason,A.MOCReason),',','')MOCReason
   FROM PRO.CUSTOMERCAL A
   	INNER JOIN PRO.ACCOUNTCAL B
   		ON A.CustomerEntityID=B.CustomerEntityID
       LEFT JOIN DIMSOURCEDB src
   		on b.SourceAlt_Key =src.SourceAlt_Key	
   		and src.EffectiveFromTimeKey <=@Timekey and src.EffectiveToTimeKey >=@Timekey
   	LEFT JOIN DIMPRODUCT PD
   		ON PD.EffectiveToTimeKey=49999
   		AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
   	left join DimAssetClass a1
   		on a1.EffectiveToTimeKey=49999
   		and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
   	left join DimAssetClass a2
   		on a2.EffectiveToTimeKey=49999
   		and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
   	LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
   	    and S.EffectiveFromTimeKey <=@Timekey and S.EffectiveToTimeKey >=@Timekey 
   	-- where B.FinalAssetClassAlt_Key>1
   	 where B.InitialAssetClassAlt_Key > 1 and B.FinalAssetClassAlt_Key = 1



   	 select @Date as DateofData,'ACL_UPG_Data'TableName,count(1)Count from ACL_UPG_DATA  
   	 where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')





   IF (select count(1) from INVESTMENT_DATA 
   	where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')) > 0
   	BEGIN
   	delete from INVESTMENT_DATA where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')
   	END
   	INSERT INTO INVESTMENT_DATA
   ----
   ----SELECT convert(nvarchar,@Date, 105) Process_Date,B.BRANCHCODE,ISSUERID,ISSUERNAME,REF_TXN_SYS_CUST_ID,ISSUER_CATEGORY_CODE,UCIFID,PANNO,INVID
   ----,ISIN,I.INSTRUMENTTYPENAME
   ----,INSTRNAME,b.INVESTMENTNATURE,EXPOSURETYPE,MATURITYDT,HOLDINGNATURE,BOOKTYPE,BOOKVALUE,MTMVALUE,INTEREST_DIVIDENDDUEDATE,INTEREST_DIVIDENDDUEAMOUNT,DPD,FLGDEG,DEGREASON,FLGUPG,UPGDATE,TOTALPROVISON,AC.ASSETCLASSSHORTNAME ASSETCLASS

   ----FROM InvestmentIssuerDetail a
   ----	INNER JOIN InvestmentBasicDetail B
   ----		ON A.IssuerEntityId=B.IssuerEntityId
   ----		and a.EffectiveFromTimeKey<=@TIMEKEY and a.EffectiveToTimeKey>=@TIMEKEY
   ----		and b.EffectiveFromTimeKey<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY
   ----	INNER JOIN InvestmentFinancialDetail c

   ----		ON b.InvEntityId=c.InvEntityId
   ----		and c.EffectiveFromTimeKey<=@TIMEKEY and c.EffectiveToTimeKey>=@TIMEKEY
   ----	INNER JOIN DimAssetClass AC
   ----		ON AC.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY
   ----		AND AC.AssetClassAlt_Key=C.FinalAssetClassAlt_Key

   ----	INNER JOIN DimInstrumentType I
   ----		ON I.EffectiveFromTimeKey<=@TIMEKEY AND I.EffectiveToTimeKey>=@TIMEKEY
   ----		AND B.InstrTypeAlt_Key=I.InstrumentTypeAlt_Key
   --	--
   SELECT distinct convert(nvarchar,@Date, 105) Process_Date,B.BRANCHCODE,ISSUERID,ISSUERNAME,REF_TXN_SYS_CUST_ID
   	,ISSUER_CATEGORY_CODE,UCIFID,PANNO,
   	SUBSTRING(INVID,1,charindex('_',INVID)-1) as INVID
   	,b.ISIN,I.INSTRUMENTTYPENAME
   	,INSTRNAME,b.INVESTMENTNATURE,EXPOSURETYPE,MATURITYDT,HOLDINGNATURE,BOOKTYPE,BOOKVALUE,MTMVALUE
   	,INTEREST_DIVIDENDDUEDATE,INTEREST_DIVIDENDDUEAMOUNT,DPD,FLGDEG,DEGREASON,
   	 (CASE WHEN AC.ASSETCLASSSHORTNAME <> 'STD' THEN 'N' ELSE  FLGUPG END) FLGUPG,
   	 (CASE WHEN AC.ASSETCLASSSHORTNAME <> 'STD' THEN NULL ELSE  UPGDATE END) UPGDATE,
   	TOTALPROVISON
   	,AC.ASSETCLASSSHORTNAME ASSETCLASS
   	,C.PartialRedumptionDueDate,c.PartialRedumptionSettledY_N,c.NPIDt
   	,c.BalanceSheetDate
   	,c.ListedShares
   	,c.DPD_BS_Date
   	,c.BookValueINR
   --SELECT A.*
   FROM InvestmentIssuerDetail a
   	INNER JOIN InvestmentBasicDetail B
   		ON A.IssuerEntityId=B.IssuerEntityId
   		and a.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey
   		and b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey
   	INNER JOIN InvestmentFinancialDetail c
   		ON b.InvEntityId=c.InvEntityId
   		and c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey
   	INNER JOIN DimAssetClass AC
   		ON AC.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   		AND AC.AssetClassAlt_Key=C.FinalAssetClassAlt_Key
   	LEFT JOIN DimInstrumentType I
   		ON I.EffectiveFromTimeKey<=@TimeKey AND I.EffectiveToTimeKey>=@TimeKey
   		AND B.InstrTypeAlt_Key=I.InstrumentTypeAlt_Key



   --	--

   --	WHERE ISNULL(B.InvestmentNature,'') <>'EQUITY'	

   --UNION ALL


   --SELECT convert(nvarchar,@Date, 105) Process_Date,B.BRANCHCODE,ISSUERID,ISSUERNAME,REF_TXN_SYS_CUST_ID,ISSUER_CATEGORY_CODE,UCIFID,PANNO,INVID
   --,ISIN,NULL INSTRUMENTTYPENAME
   --,INSTRNAME,b.INVESTMENTNATURE,EXPOSURETYPE,MATURITYDT,HOLDINGNATURE,BOOKTYPE,BOOKVALUE,MTMVALUE,INTEREST_DIVIDENDDUEDATE,INTEREST_DIVIDENDDUEAMOUNT,DPD,FLGDEG,DEGREASON,FLGUPG,UPGDATE,TOTALPROVISON,AC.ASSETCLASSSHORTNAME ASSETCLASS

   ----SELECT A.*
   --FROM InvestmentIssuerDetail a
   --	INNER JOIN InvestmentBasicDetail B
   --		ON A.IssuerEntityId=B.IssuerEntityId
   --		and a.EffectiveFromTimeKey<=@TimeKey and a.EffectiveToTimeKey>=@TimeKey
   --		and b.EffectiveFromTimeKey<=@TimeKey and b.EffectiveToTimeKey>=@TimeKey
   --	INNER JOIN InvestmentFinancialDetail c

   --		ON b.InvEntityId=c.InvEntityId
   --		and c.EffectiveFromTimeKey<=@TimeKey and c.EffectiveToTimeKey>=@TimeKey
   --	INNER JOIN DimAssetClass AC
   --		ON AC.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   --		AND AC.AssetClassAlt_Key=C.FinalAssetClassAlt_Key
   --	WHERE B.InvestmentNature ='EQUITY'	

   --	--


   		select @Date as DateofData,'Investment_Data'TableName,count(1)Count from INVESTMENT_DATA  where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Ext_flg = 'Y')

   */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT" TO "ADF_CDR_RBL_STGDB";
