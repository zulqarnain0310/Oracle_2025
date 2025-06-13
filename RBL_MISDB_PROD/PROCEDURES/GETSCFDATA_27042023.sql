--------------------------------------------------------
--  DDL for Procedure GETSCFDATA_27042023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETSCFDATA_27042023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --SET @TIMEKEY=26388
   v_Date VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) 
     FROM DUAL  );
   v_ReportDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --SET @ReportDate='2022-03-31'
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );
   v_cursor SYS_REFCURSOR;

BEGIN

   --IF OBJECT_ID('TempDB..#SCF') Is Not Null  
   --Drop Table		#SCF 
   --Select			'SCF' AS [SourceSystemName],
   --                 @ReportDate [DateOfData],
   --			     A.UCIF_ID AS [Ucic_Id], 
   --				 A.RefCustomerID as [CIF_ID], 
   --                 CustomerAcID as [FacilityAccountNumber],
   --				 pc.CustomerName [CustName],
   --				 CASE WHEN A.FinalAssetClassAlt_Key=1 THEN 'STD'ELSE 'NPA' END [AssetClass],
   --				 CASE WHEN A.[FinalAssetClassAlt_Key]=1 THEN 'STANDARD'
   --                      WHEN A.[FinalAssetClassAlt_Key]=2 THEN 'SUB STANDARD'
   --	                  WHEN A.[FinalAssetClassAlt_Key]=3 THEN 'DOUBTFUL-I'
   --	                  WHEN A.[FinalAssetClassAlt_Key]=4 THEN 'DOUBTFUL-II'
   --	                  WHEN A.[FinalAssetClassAlt_Key]=5 THEN 'DOUBTFUL-II'
   --	                  WHEN A.[FinalAssetClassAlt_Key]=6 THEN 'LOSS' END [AssetSubClass],
   --				 CASE WHEN A.FinalAssetClassAlt_Key<>1 THEN A.FinalNpaDt ELSE NULL END [NPADate],
   --				 CASE WHEN A.FinalAssetClassAlt_Key=1 THEN NULL ELSE NPA_Reason END [RemarkReason],
   --				 A.InitialAssetClassAlt_Key AS [BankAssetClass],
   --				 A.FinalAssetClassAlt_Key AS [FinalAssetClassAlt_Key],
   --				 A.InitialNpaDt [SourceNpaDate]
   -- INTO			 #SCF  
   -- from			PRO.CUSTOMERCAL PC 
   -- INNER JOIN     Pro.ACCOUNTCAL A
   --ON PC.CustomerEntityID=A.CustomerEntityID
   --ANd				 A.EffectiveFromTimeKey<=@Timekey ANd A.EffectiveToTimeKey>=@Timekey 
   --Inner Join		 [CurDat].[AdvFacBillDetail] B ON A.AccountEntityID=B.AccountEntityID  
   --ANd				 B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey 
   --AND              B.BillNatureAlt_Key=9
   --Inner Join		DIMSOURCEDB DS ON DS.SourceAlt_Key=B.BillNatureAlt_Key  
   --ANd				DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey  
   --AND             DS.SourceAlt_Key=9
   --Where	
   --PC.EffectiveFromTimeKey<=@Timekey ANd PC.EffectiveToTimeKey>=@Timekey AND
   --EXISTS  (Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode in ('VFVEN','DLFIN')
   --               and Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
   -- ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.CustomerAcID=R.CustomerID
   --			And A.FinalAssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(A.FinalNpaDt,'')=ISNULL(R.FinalNpaDt,'')
   --			And R.ProcessDate=@PreviousDate)
   --			Delete        a
   --			from          #SCF a
   --			inner join    ReverseFeedData b
   --			on            a.[FacilityAccountNumber]=b.AccountID
   OPEN  v_cursor FOR
      SELECT 'SCF' Source_System_Name  ,
             v_ReportDate Date_of_Data_DD_MM_YYYY_  ,
             PC.UCIF_ID UCIC_ID  ,
             PC.CustomerName Cust_Name  ,
             PC.RefCustomerID CIF_ID  ,
             A.AccountID Facility_Account_Number  ,
             (CASE 
                   WHEN A.AssetClass = 1 THEN 'STD'
             ELSE 'NPA'
                END) Asset_Class  ,
             CASE 
                  WHEN A.AssetClass = 1 THEN 'STANDARD'
                  WHEN A.AssetClass = 2 THEN 'SUB STANDARD'
                  WHEN A.AssetClass = 3 THEN 'DOUBTFUL-I'
                  WHEN A.AssetClass = 4 THEN 'DOUBTFUL-II'
                  WHEN A.AssetClass = 5 THEN 'DOUBTFUL-II'
                  WHEN A.AssetClass = 6 THEN 'LOSS'   END Asset_SubClass  ,
             UTILS.CONVERT_TO_VARCHAR2(b.FinalNpaDt,10,p_style=>105) NPA_STD_Date_DD_MM_YYYY_  ,
             B.NPA_Reason 
             --CASE WHEN A.AssetClass=1 THEN NULL ELSE CONCAT(REPLACE(B.DegReason,',',''),(CASE WHEN B.DegReason IS NOT NULL THEN ','ELSE '' END),B.NPA_Reason) END
             Remark_Reason  
        FROM ReverseFeedData A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.AccountID = B.CustomerAcID
               AND B.EffectiveFromTimeKey <= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey
               AND A.DateofData = v_ReportDate
               AND A.SourceAlt_Key = 1
               AND B.SourceAlt_Key = 1
               JOIN RBL_MISDB_PROD.AdvFacBillDetail AF   ON B.AccountEntityID = AF.AccountEntityId
               AND AF.EffectiveFromTimekey <= v_TimeKey
               AND AF.EffectiveToTimeKey >= v_TimeKey
               JOIN DIMSOURCEDB C   ON AF.BillNatureAlt_Key = C.SourceAlt_Key
               AND C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL PC   ON PC.CustomerEntityID = B.CustomerEntityID
               AND PC.EffectiveFromTimeKey <= v_TimeKey
               AND PC.EffectiveToTimeKey >= v_TimeKey
       WHERE  A.DateofData = v_ReportDate ;
      DBMS_SQL.RETURN_RESULT(v_cursor);/*
   Select DISTINCT ('SCF'+'|'+convert(varchar,@ReportDate,105)+'|'+A.UCIF_ID +'|'+PC.CustomerName +'|'+ CustomerID + '|'+ AccountID +'|'+
   (CASE WHEN A.AssetClass=1 THEN 'STD' ELSE 'NPA' END)+'|'+
   	 CASE WHEN A.AssetClass=1 THEN 'STANDARD'
                         WHEN A.AssetClass=2 THEN 'SUB STANDARD'
   	                  WHEN A.AssetClass=3 THEN 'DOUBTFUL-I'
   	                  WHEN A.AssetClass=4 THEN 'DOUBTFUL-II'
   	                  WHEN A.AssetClass=5 THEN 'DOUBTFUL-II'
   	                  WHEN A.AssetClass=6 THEN 'LOSS' END 
   +'|'+ Convert(Varchar(10),NPADate,105)+ '|' 
   +CASE WHEN A.AssetClass=1 THEN NULL ELSE B.NPA_Reason END) DATA
   FROM  ReverseFeedData A
   INNER JOIN PRO.ACCOUNTCAL B ON A.AccountID=B.CustomerAcID 
    AND B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   INNER JOIN curdat.AdvFacBillDetail AF
   ON B.AccountEntityID=AF.AccountEntityId AND AF.EffectiveFromTimekey<=@TimeKey AND AF.EffectiveToTimeKey>=@TimeKey
   Inner JOIN DIMSOURCEDB C ON AF.BillNatureAlt_Key=C.SourceAlt_key
   And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   LEFT JOIN PRO.CUSTOMERCAL PC ON 
   PC.CustomerEntityID=B.CustomerEntityID
   AND PC.EffectiveFromTimekey<=@TimeKey AND PC.EffectiveToTimeKey>=@TimeKey
    where C.SourceName='SCF'
    And A.AssetSubClass<>'STD'
    AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

    UNION 


   Select DISTINCT ('SCF'+'|'+convert(varchar,@ReportDate,105)+'|'+A.UCIF_ID +'|'+PC.CustomerName +'|'+ CustomerID + '|'+ AccountID +'|'+
   (CASE WHEN A.AssetClass=1 THEN 'STD' ELSE 'NPA' END)+'|'+
   	 CASE WHEN A.AssetClass=1 THEN 'STANDARD'
                         WHEN A.AssetClass=2 THEN 'SUB STANDARD'
   	                  WHEN A.AssetClass=3 THEN 'DOUBTFUL-I'
   	                  WHEN A.AssetClass=4 THEN 'DOUBTFUL-II'
   	                  WHEN A.AssetClass=5 THEN 'DOUBTFUL-II'
   	                  WHEN A.AssetClass=6 THEN 'LOSS' END 
   +'|'+ Convert(Varchar(10),NPADate,105)+ '|' 
   +CASE WHEN A.AssetClass=1 THEN NULL ELSE B.NPA_Reason END) DATA
   FROM  ReverseFeedData A
   INNER JOIN PRO.ACCOUNTCAL B ON A.AccountID=B.CustomerAcID 
    AND B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   INNER JOIN curdat.AdvFacBillDetail AF
   ON B.AccountEntityID=AF.AccountEntityId AND AF.EffectiveFromTimekey<=@TimeKey AND AF.EffectiveToTimeKey>=@TimeKey
   Inner JOIN DIMSOURCEDB C ON AF.BillNatureAlt_Key=C.SourceAlt_key
   And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   LEFT JOIN PRO.CUSTOMERCAL PC ON 
   PC.CustomerEntityID=B.CustomerEntityID
   AND PC.EffectiveFromTimekey<=@TimeKey AND PC.EffectiveToTimeKey>=@TimeKey
    where C.SourceName='SCF'
    And A.AssetSubClass='STD'
    AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
    */
   -----------Added on 04/04/2022  
   -- UNION  
   --Select 
   --[SourceSystemName] as [Source System Name],
   --convert(varchar,'2022-03-31',105)as [Date of Data(DD-MM-YYYY)] ,
   --[Ucic_Id] as [UCIC_ID],
   --[CustName] AS [Cust Name],
   --[CIF_ID] AS [CIF ID] ,
   --[FacilityAccountNumber] [Facility Account Number],
   --[AssetClass] [Asset Class],
   --[AssetSubClass] as [Asset SubClass] ,
   --CAST(NPADate AS NVARCHAR(10)) [NPA/STD Date(DD-MM-YYYY)],
   --Replace(RemarkReason,',','')[Remark/Reason]
   --from #SCF  A
   --where A.BankAssetClass=1 ANd A.FinalAssetClassAlt_Key>1  
   -- UNION   
   --Select  
   --[SourceSystemName] as [Source System Name],
   --convert(varchar,'2022-03-31',105)as [Date of Data(DD-MM-YYYY)] ,
   --[Ucic_Id] as [UCIC_ID],
   --[CustName] AS [Cust Name],
   --[CIF_ID] AS [CIF ID] ,
   --[FacilityAccountNumber] [Facility Account Number],
   --[AssetClass] [Asset Class],
   --[AssetSubClass] as [Asset SubClass] ,
   --CAST(NPADate AS NVARCHAR(10)) [NPA/STD Date(DD-MM-YYYY)],
   --Replace(RemarkReason,',','') [Remark/Reason]
   --from #SCF  A
   -- where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1  
   -- UNION
   --Select 
   --[SourceSystemName] as [Source System Name],
   --convert(varchar,'2022-03-31',105)as [Date of Data(DD-MM-YYYY)] ,
   --[Ucic_Id] as [UCIC_ID],
   --[CustName] AS [Cust Name],
   --[CIF_ID] AS [CIF ID] ,
   --[FacilityAccountNumber] [Facility Account Number],
   --[AssetClass] [Asset Class],
   --[AssetSubClass] as [Asset SubClass] ,
   --CAST(NPADate AS NVARCHAR(10)) [NPA/STD Date(DD-MM-YYYY)],
   --Replace(RemarkReason,',','') [Remark/Reason]
   --from #SCF  A
   -- where A.BankAssetClass>1 ANd A.FinalAssetClassAlt_Key>1  
   -- And ISNULL(A.NPADate,'')<>ISNULL(A.SourceNpaDate,'')

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETSCFDATA_27042023" TO "ADF_CDR_RBL_STGDB";
