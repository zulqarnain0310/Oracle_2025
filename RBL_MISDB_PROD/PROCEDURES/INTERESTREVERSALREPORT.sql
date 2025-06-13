--------------------------------------------------------
--  DDL for Procedure INTERESTREVERSALREPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Date_ = v_Date );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE InterestReversal_Automate ';
   INSERT INTO InterestReversal_Automate
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
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

                   --WHEN SourceName='VisionPlus' THEN 'Credit Card'
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
                   WHEN NVL(PrincOutStd, 0) <= 0 THEN 0
              ELSE PrincOutStd
                 END Principal_Outstanding  ,
              a2.SrcSysClassCode Asset_Classification  ,
              zz.AssetClassCode Soirce_System_Status  ,
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
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
              AND NVL(b.WriteOffAmount, 0) = 0
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              AND ( src.EffectiveFromTimeKey <= v_Timekey
              AND src.EffectiveToTimeKey >= v_TimeKey )
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.ProductAlt_Key
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
              AND X.EffectiveToTimeKey = 49999
              LEFT JOIN RBL_MISDB_PROD.AdvAcOtherFinancialDetail Y   ON Y.AccountEntityId = B.AccountEntityID
              AND Y.EffectiveToTimeKey = 49999
              LEFT JOIN RBL_MISDB_PROD.AdvCreditCardBalanceDetail YZ   ON YZ.AccountEntityID = B.AccountEntityID
              AND YZ.EffectiveToTimeKey = 49999
              LEFT JOIN InvestmentFinancialDetail Z   ON Z.RefInvID = B.CustomerAcID
              AND Z.EffectiveToTimeKey = 49999
              LEFT JOIN ( SELECT DISTINCT CustomerAcid ,
                                          AssetClassCode 
                          FROM RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM  ) ZZ   ON B.CustomerAcID = ZZ.CustomerAcID
              LEFT JOIN ExceptionFinalStatusType EF   ON b.CustomerAcID = ef.ACID
              AND EF.StatusType = 'TWO'
              AND ef.EffectiveFromTimeKey <= v_TIMEKEY
              AND ef.EffectiveToTimeKey >= v_TIMEKEY
        WHERE  B.FinalAssetClassAlt_Key > 1
                 AND ef.ACID IS NULL );
   OPEN  v_cursor FOR
      SELECT Report_Date ,
             UCIC ,
             CIF_ID ,
             Borrower_Name ,
             Branch_Code ,
             Branch_Name ,
             Account_No ,
             Source_System ,
             Facility ,
             Scheme_Type ,
             Scheme_Code ,
             Scheme_Description ,
             Seg_Code ,
             Segment_Description ,
             Business_Segment ,
             Account_DPD ,
             --,[NPA Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(NPA_Date,200,p_style=>105),10,p_style=>23) NPA_Date  ,
             Outstanding ,
             Principal_Outstanding ,
             Asset_Classification ,
             Soirce_System_Status ,
             interest_Dues ,
             Penal_Dues ,
             Other_Dues ,
             interest_accured_but_not_due ,
             penal_accured_but_not_due ,
             Credit_Card_interest_Outstanding ,
             Credit_Card_other_charges ,
             Credit_Card_GST_ST_Outstanding ,
             Interest_Dividend_on_Bond_Debentures 
        FROM InterestReversal_Automate  ;
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
   --,CASE WHEN SourceName='FIS' THEN 'FI'
   --		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
   --		else AcBuSegmentDescription end [Segment Description]
   --,CASE WHEN SourceName='FIS' THEN 'FI'
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
   --  AND (src.EffectiveFromTimeKey<=@Timekey AND src.EffectiveToTimeKey>=@TimeKey)
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
   --,CASE WHEN SourceName='FIS' THEN 'FI'
   --		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
   --		else AcBuSegmentDescription end [Segment Description]
   --,CASE WHEN SourceName='FIS' THEN 'FI'
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
   --  AND (src.EffectiveFromTimeKey<=@Timekey AND src.EffectiveToTimeKey>=@TimeKey)
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERESTREVERSALREPORT" TO "ADF_CDR_RBL_STGDB";
