--------------------------------------------------------
--  DDL for Procedure SP_FINALACLRFOUTPUT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   -----------------------------------------ACL PROCESSING---------------
   --DBCC shrinkfile (log,1024)
   --------DBCC shrinkfile (log,1)
   --------DBCC shrinkfile (log,1)
   --------DBCC shrinkfile (log,1)
   --------DBCC shrinkfile (log,1)
   PRO_RBL_MISDB_PROD.InsertDataforAssetClassficationRBL(v_Timekey) ;
   PRO_RBL_MISDB_PROD.MAINPROECESSFORASSETCLASSFICATION() ;
   ---------------------------------------------------ACL OUTPUT ---------------
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM ACL_NPA_DATA 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                                     FROM Automate_Advances 
                                                                                      WHERE  Ext_flg = 'Y' )
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
                                                                             WHERE  Ext_flg = 'Y' )
      ;

   END;
   END IF;
   INSERT INTO ACL_NPA_DATA
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
              UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CustomerID  ,
              CustomerName ,
              B.BranchCode ,
              CustomerAcid ,
              b.FacilityType ,
              b.ProductCode ,
              ProductName ,
              Balance ,
              DrawingPower ,
              CurrentLimit ,
              UnserviedInt UnAppliedIntt  ,
              ReviewDueDt ,
              CreditSinceDt ,
              b.ContiExcessDt ,
              StockStDt ,
              DebitSinceDt ,
              LastCrDate ,
              PreQtrCredit ,
              PrvQtrInt ,
              CurQtrCredit ,
              CurQtrInt ,
              --IntNotServicedDt	
              OverdueAmt ,
              OverDueSinceDt ,
              SecurityValue ,
              NetBalance ,
              PrincOutStd ,
              ApprRV ,
              SecuredAmt ,
              UnSecuredAmt ,
              Provsecured ,
              ProvUnsecured ,
              TotalProvision ,
              RefPeriodOverdue ,
              RefPeriodOverDrawn ,
              RefPeriodNoCredit ,
              RefPeriodIntService ,
              RefPeriodStkStatement ,
              RefPeriodReview ,
              PrincOverdue ,
              PrincOverdueSinceDt ,
              IntOverdue ,
              IntOverdueSinceDt ,
              OtherOverdue ,
              OtherOverdueSinceDt ,
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
              a.Asset_Norm ,
              b.CD ,
              pd.NPANorms ,
              b.WriteOffAmount ,
              b.ActSegmentCode ,
              ProductSubGroup ,
              SourceName ,
              ProductGroup ,
              PD.SchemeType ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE S.AcBuRevisedSegmentCode
                 END AcBuRevisedSegmentCode  ,
              ----SELECT ActSegmentCode,* FROM PRO.ACCOUNTCAL
              a.DegDate ,
              REPLACE(NVL(B.MOC_Dt, A.MOC_Dt), ',', ' ') MOC_Dt  ,
              REPLACE(NVL(B.MOCReason, A.MOCReason), ',', ' ') MOCReason  

       --into #data
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              AND src.EffectiveFromTimeKey <= v_Timekey
              AND src.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.ProductAlt_Key
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
        WHERE  B.FinalAssetClassAlt_Key > 1 );
   --AND isnull(b.WriteOffAmount,0)=0	--	 where B.FlgUpg='U'
   OPEN  v_cursor FOR
      SELECT v_Date DateofData  ,
             'ACL_NPA_Data' TableName  ,
             COUNT(1)  COUNT  
        FROM ACL_NPA_DATA 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                            FROM Automate_Advances 
                                                                             WHERE  Ext_flg = 'Y' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM ACL_UPG_DATA 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                                     FROM Automate_Advances 
                                                                                      WHERE  Ext_flg = 'Y' )
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
                                                                             WHERE  Ext_flg = 'Y' )
      ;

   END;
   END IF;
   INSERT INTO ACL_UPG_DATA
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
              UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CustomerID  ,
              CustomerName ,
              B.BranchCode ,
              CustomerAcid ,
              b.FacilityType ,
              b.ProductCode ,
              ProductName ,
              Balance ,
              DrawingPower ,
              CurrentLimit ,
              UnserviedInt UnAppliedIntt  ,
              ReviewDueDt ,
              CreditSinceDt ,
              b.ContiExcessDt ,
              StockStDt ,
              DebitSinceDt ,
              LastCrDate ,
              PreQtrCredit ,
              PrvQtrInt ,
              CurQtrCredit ,
              CurQtrInt ,
              --IntNotServicedDt	
              OverdueAmt ,
              OverDueSinceDt ,
              SecurityValue ,
              NetBalance ,
              PrincOutStd ,
              ApprRV ,
              SecuredAmt ,
              UnSecuredAmt ,
              Provsecured ,
              ProvUnsecured ,
              TotalProvision ,
              RefPeriodOverdue ,
              RefPeriodOverDrawn ,
              RefPeriodNoCredit ,
              RefPeriodIntService ,
              RefPeriodStkStatement ,
              RefPeriodReview ,
              PrincOverdue ,
              PrincOverdueSinceDt ,
              IntOverdue ,
              IntOverdueSinceDt ,
              OtherOverdue ,
              OtherOverdueSinceDt ,
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
              a.Asset_Norm ,
              b.CD ,
              pd.NPANorms ,
              b.WriteOffAmount ,
              b.ActSegmentCode ,
              ProductSubGroup ,
              SourceName ,
              ProductGroup ,
              PD.SchemeType ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE S.AcBuRevisedSegmentCode
                 END AcBuRevisedSegmentCode  ,
              REPLACE(NVL(B.MOC_Dt, A.MOC_Dt), ',', ' ') MOC_Dt  ,
              REPLACE(NVL(B.MOCReason, A.MOCReason), ',', ' ') MOCReason  
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              AND src.EffectiveFromTimeKey <= v_Timekey
              AND src.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.ProductAlt_Key
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveFromTimeKey <= v_Timekey
              AND S.EffectiveToTimeKey >= v_Timekey

       -- where B.FinalAssetClassAlt_Key>1
       WHERE  B.InitialAssetClassAlt_Key > 1
                AND B.FinalAssetClassAlt_Key = 1 );
   OPEN  v_cursor FOR
      SELECT v_Date DateofData  ,
             'ACL_UPG_Data' TableName  ,
             COUNT(1)  COUNT  
        FROM ACL_UPG_DATA 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                            FROM Automate_Advances 
                                                                             WHERE  Ext_flg = 'Y' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM INVESTMENT_DATA 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                                     FROM Automate_Advances 
                                                                                      WHERE  Ext_flg = 'Y' )
    ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DELETE INVESTMENT_DATA

       WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                            FROM Automate_Advances 
                                                                             WHERE  Ext_flg = 'Y' )
      ;

   END;
   END IF;
   INSERT INTO INVESTMENT_DATA
     ( 
       --/*

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

       --	*/
       SELECT DISTINCT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
                       B.BRANCHCODE ,
                       ISSUERID ,
                       ISSUERNAME ,
                       REF_TXN_SYS_CUST_ID ,
                       ISSUER_CATEGORY_CODE ,
                       UCIFID ,
                       PANNO ,
                       INVID ,
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
                       c.BookValueINR 

       --SELECT A.*
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
              AND B.InstrTypeAlt_Key = I.InstrumentTypeAlt_Key );
   --	/*
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
   --	*/
   OPEN  v_cursor FOR
      SELECT v_Date DateofData  ,
             'Investment_Data' TableName  ,
             COUNT(1)  COUNT  
        FROM INVESTMENT_DATA 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200,p_style=>105) 
                                                                            FROM Automate_Advances 
                                                                             WHERE  Ext_flg = 'Y' )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALACLRFOUTPUT_04122023" TO "ADF_CDR_RBL_STGDB";
