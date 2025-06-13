--------------------------------------------------------
--  DDL for Procedure GETVISIONPLUSDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETVISIONPLUSDATA" 
AS
   --Declare @TimeKey AS INT =26090--(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );
   /*
    IF OBJECT_ID('TempDB..#ReverseFeedDataInsertSync_Customer') Is Not Null
   			Drop Table #ReverseFeedDataInsertSync_Customer

    select * into #ReverseFeedDataInsertSync_Customer from ReverseFeedDataInsertSync_Customer
    where cast(ProcessDate as date)=@Date


   Select  TableName, CustomerAcID , NPADate, [Type] from 
   (
   Select 'VisionPlusDataList' as TableName, CustomerAcID ,CONVERT(varchar,FinalNpaDt,103) as NPADate,'Degrade' [Type]
   from ReverseFeedDataInsertSync WHERE FinalAssetClassAlt_Key<>1
   and ProcessDate=@Date AND SourceName='VisionPlus'
   UNION

   Select 'VisionPlusDataList' as TableName, CustomerAcID ,CONVERT(varchar,FinalNpaDt,103) as NPADate,'Upgrade' [Type]
   from ReverseFeedDataInsertSync WHERE FinalAssetClassAlt_Key=1
   and ProcessDate=@Date and  SourceName='VisionPlus'
   )B

   ---------------------------------------------------------------------------------------------


    IF OBJECT_ID('TempDB..#CorporateCustID') Is Not Null  
   Drop Table #CorporateCustID  

   select distinct F.CorporateCustomerID,a.RefCustomerID into #CorporateCustID	 from pro.accountcal a
   left join curdat.AdvFacCreditCardDetail F
   ON        A.AccountEntityID=F.AccountEntityID
   And F.EffectiveFromTimekey<=@TimeKey AND F.EffectiveToTimeKey>=@TimeKey


    IF OBJECT_ID('TempDB..#VisionPlus1') Is Not Null  
   Drop Table #VisionPlus1  

   Select A.RefCustomerID CustomerID,A.SysAssetClassAlt_Key FinalAssetClassAlt_Key,A.SysNPA_Dt FinalNpaDt,
   (CASE WHEN B.SourceAssetClass IS NULL AND B.SourceNpaDate IS NULL THEN 'STD' ELSE B.SourceAssetClass END)SourceAssetClass  ,
   (CASE WHEN B.SourceAssetClass='STD' AND  B.SourceNpaDate IS NOT NULL THEN NULL ELSE  B.SourceNpaDate END)SourceNpaDate ,  
   DA.AssetClassAlt_Key BankAssetClass  ,CorporateCustomerID
     INto #VisionPlus1  
    from Pro.CUSTOMERCAL A  
   Inner join  #ReverseFeedDataInsertSync_Customer RC on A.RefCustomerID=RC.CustomerID
   Inner Join CURDAT.AdvCustOtherDetail B ON A.CustomerEntityID=B.CustomerEntityID  
   ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey  
   Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key  
   ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey  
   Inner Join DimAssetClassMapping_Customer DA ON DA.AssetClassShortName=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key  
      ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey 
   inner JOIN PRO.ACCOUNTCAL Z ON A.RefCustomerID=Z.RefCustomerID
   left join  #CorporateCustID CC ON a.RefCustomerID=CC.RefCustomerID
   Where DS.SourceName='VisionPlus'
   and  RC.SourceName='VisionPlus'
   --ANd Not exists (Select 1 from ReverseFeedDataInsertSync_Customer R where A.RefCustomerID=R.CustomerID
   --			And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
   --			And R.ProcessDate=@PreviousDate)
   --			AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=Z.ProductAlt_Key and Y.ProductCode='RBSNP' and 
   --			Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)

   			Delete        a
   			from          #VisionPlus1 a
   			inner join    ReverseFeedData b
   			on            a.CustomerID=b.CustomerID
   			where         b.DateofData=@Date

    IF OBJECT_ID('TempDB..#AssetClass') Is Not Null  
   Drop Table #AssetClass  

   select distinct assetsubclass,case when assetsubclass='STD' then 1 
   								   when assetsubclass='SS' then 2
   									when assetsubclass='d1' then 3
   									when assetsubclass='d2' then 4
   									when assetsubclass='d3' then 5
   									when assetsubclass='l1' then 6 end AssetClassAlt_key
   									into #AssetClass from ReverseFeedData where SourceSystemName='VisionPlus'



    Select 'VisionPlusDataList' as TableName, CustomerID ,AssetSubClass as AssetCode,AssetCodeDate,ENPADate,'AssetClassification' [Type], 
    [Customer_ID] into #temp
    from (
    Select a.Corporate_Customer_ID CustomerID ,Case When Len(A.AssetSubClass)=3 then A.AssetSubClass else A.AssetSubClass+' ' End AssetSubClass,
    Convert(Varchar,DateofData,103) as AssetCodeDate,Case when NPADate is not null then Convert(Varchar,NPADate,103) else '       ' ENd as ENPADate
     ,A.CustomerID [Customer_ID]
    -- Select 'VisionPlusDataList' as TableName, CustomerID ,CONVERT(varchar,NPADate,103) as ENPADate,'Degrade' [Type] 
   from ReverseFeedData A
   Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
    where B.SourceName='VisionPlus'
    And A.AssetSubClass<>'STD'
    AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

    UNION 

     Select a.Corporate_Customer_ID CustomerID ,Case When Len(A.AssetSubClass)=3 then A.AssetSubClass else A.AssetSubClass+' ' End AssetSubClass,
    Convert(Varchar,DateofData,103) as AssetCodeDate,Case when NPADate is not null then Convert(Varchar,NPADate,103) else '       ' ENd as ENPADate
     ,A.CustomerID [Customer_ID]
    from ReverseFeedData A
   Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
    where B.SourceName='VisionPlus'
    And A.AssetSubClass='STD'
    AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

    -----------Added on 04/04/2022  

    UNION  


    Select a.CorporateCustomerID CustomerID ,Case When Len(b.AssetSubClass)=3 then b.AssetSubClass else b.AssetSubClass+' ' End AssetSubClass,
    Convert(Varchar,@Date,103) as AssetCodeDate,Case when FinalNpaDt is not null then Convert(Varchar,FinalNpaDt,103) else '       ' ENd as ENPADate
     ,A.CustomerID [Customer_ID]
   from #VisionPlus1 A  
   inner join  #AssetClass b
   on          a.FinalAssetClassAlt_Key=b.AssetClassAlt_key
    where A.BankAssetClass=1 ANd A.FinalAssetClassAlt_Key>1  

    UNION   

    Select a.CorporateCustomerID CustomerID ,Case When Len(b.AssetSubClass)=3 then b.AssetSubClass else b.AssetSubClass+' ' End AssetSubClass,
    Convert(Varchar,@Date,103) as AssetCodeDate,Case when FinalNpaDt is not null then Convert(Varchar,FinalNpaDt,103) else '       ' ENd as ENPADate 
    ,A.customerid [Customer_ID]
    from #VisionPlus1 A  
    inner join  #AssetClass b
   on          a.FinalAssetClassAlt_Key=b.AssetClassAlt_key
    where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1  

    UNION


    Select a.CorporateCustomerID CustomerID ,Case When Len(b.AssetSubClass)=3 then b.AssetSubClass else b.AssetSubClass+' ' End AssetSubClass,
    Convert(Varchar,@Date,103) as AssetCodeDate,Case when FinalNpaDt is not null then Convert(Varchar,FinalNpaDt,103) else '       ' ENd as ENPADate 
     ,A.CustomerID [Customer_ID]
   from #VisionPlus1 A  
   inner join  #AssetClass b
   on          a.FinalAssetClassAlt_Key=b.AssetClassAlt_key
    where A.BankAssetClass>1 ANd A.FinalAssetClassAlt_Key>1  
    And (ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')  OR (A.BankAssetClass<> A.FinalAssetClassAlt_Key))
    )A
    Order by 2



    select A.TableName, A.CustomerID ,A.AssetCode,A.AssetCodeDate,A.ENPADate,A.[TYPE] 
    from #temp a
    inner join ReverseFeedDataInsertSync_Customer B
    on a.Customer_ID=B.CustomerID
    and B.ProcessDate=@Date
    and SourceName='VisionPlus'
    where 
    A.CustomerID  is not null

    */
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT * 
        FROM VisionPlus_28022024  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT * 
        FROM VisionPlus_28022024_2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA" TO "ADF_CDR_RBL_STGDB";
