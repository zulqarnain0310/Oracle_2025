--------------------------------------------------------
--  DDL for Procedure HOSTSYSTEM_RERF_GENERATION_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );

BEGIN

   --Declare @TimeKey AS INT =26298
   --------------Finacle
   --Select  'FinacleDegrade' AS TableName, AccountID +'|'+ 
   --Case When ISNULL(A.NPADate,'1900-01-01')<ISNULL(C.AcOpenDt,'1900-01-01') Then  Convert(Varchar(10),C.AcOpenDt,105)  Else
   --  Convert(Varchar(10),NPADate,105) End  as DataUtility from ReverseFeedData A								--- As per Bank Revised mail on 05-01-2022  
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   --Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID
   --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   -- where B.SourceName='Finacle'
   -- And A.AssetSubClass<>'STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   --------------Finacle
   ----------Added on 04/04/2022
   /*	
   			IF OBJECT_ID('TempDB..#Finacle') Is Not Null
   			Drop Table #Finacle

   			Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,
   			DA.AssetClassAlt_Key BankAssetClass
   				 INto #Finacle
   			 from Pro.ACCOUNTCAL A
   			Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID
   			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
   			Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key
   			ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey
   			Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key
   			ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey
   			----Inner Join Finacle_uat_data D ON D.Customer_Ac_ID=A.CustomerAcID
   			----Inner Join Finacle_RF_UAT D ON D.Customer_Ac_ID=A.CustomerAcID
   			Where DS.SourceName='Finacle'
   			ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
   			And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
   			And R.ProcessDate=@PreviousDate)
   			And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')AND
   			--NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
   			--X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
   			NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
   			Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)

   			Delete        a
   			from          #Finacle a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         b.DateofData=@Date

          			---------------------

   		-- =================================Added by Prashant to change the Finacle logic=========================== --

   		Truncate table  Finacle_Host_System_RERF

   		insert into  Finacle_Host_System_RERF
   			select *  from (
   Select 'FinacleDegrade' AS TableName, AccountID,AccountID +'|'+
   Case When ISNULL(NPADate,'1900-01-01')<ISNULL(AcOpenDt,'1900-01-01')
   Then Convert(Varchar(10),AcOpenDt,105)+'|'+ Convert(Varchar(10),NPADate,105) Else
   Convert(Varchar(10),NPADate,105)+'|' End as DataUtility
   from ReverseFeedData A
   Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID
   And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   where B.SourceName='Finacle'
   And A.AssetSubClass<>'STD'
   AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey 

   union

   Select 'FinacleDegrade' AS TableName,customeracid, customeracid +'|'+
   Convert(Varchar(10),a.FinalNpaDt,105)+'|' as DataUtility
    from Pro.AccountCal_hist A wITH (NOLOCK)
   			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
   			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
   			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
   			 where B.SourceName='Finacle'
   			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
   			 ANd  A.InitialNpaDt<>A.FinalNpaDt     
   			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   ---------Added on 04/04/2022
   		 UNION

   		 Select  'FinacleDegrade' AS TableName,customeracid, CustomerAcID +'|'+Convert(Varchar(10),FinalNpaDt,105)+'|' as DataUtility 
   		 from #Finacle A
   		 where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1

   		 -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
   		 UNION

   		 Select  'FinacleDegrade' AS TableName,customeracid, CustomerAcID +'|'+Convert(Varchar(10),FinalNpaDt,105)+'|' as DataUtility 
   		 from #Finacle A
   		 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
   		 ANd ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')


   		 ----------------

   )A Group By TableName,DataUtility,AccountID



   --================================================ END ======================================================================--




   	    --------------Ganaseva
   		----------Added on 04/04/2022

   			IF OBJECT_ID('TempDB..#Ganaseva') Is Not Null
   			Drop Table #Ganaseva

   			Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,
   			DA.AssetClassAlt_Key BankAssetClass
   				 INto #Ganaseva
   			 from Pro.ACCOUNTCAL A
   			Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID
   			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
   			Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key
   			ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey
   			Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key
   			ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey 
   			Where DS.SourceName='Ganaseva'
   			ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
   			And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
   			And R.ProcessDate=@PreviousDate)
   			And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
   			-- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
   			--X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
   			NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
   			Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)


   			Delete        a
   			from          #Ganaseva a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         b.DateofData=@Date
   			----------------

   			Truncate table  Ganaseva_Host_System_RERF

   			Insert into  Ganaseva_Host_System_RERF
   			select *  from (
   		 Select 'GanasevaDegrade' AS TableName,AccountID, AccountID +'|'+'1'+'|'+Convert(Varchar(10),NPADate,103)+'|'+'19718'+'|'+'19718' as DataUtility from ReverseFeedData A
   		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   		 where B.SourceName='Ganaseva'
   		 And A.AssetSubClass<>'STD'
   		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   		  ------Changes for NPADate on 22/04/2022

   		 union

   Select 'GanasevaDegrade' AS TableName,CustomerAcID, CustomerAcID +'|'+'1'+'|'+Convert(Varchar(10),FinalNpaDt,103)+'|'+'19718'+'|'+'19718' as DataUtility
    from Pro.AccountCal_hist A wITH (NOLOCK)
   			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
   			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
   			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
   			 where B.SourceName='Ganaseva'
   			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
   			 ANd  ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')     
   			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey


   		 ----------Added on 04/04/2022
   		 UNION

   		 Select 'GanasevaDegrade' AS TableName,CustomerAcID, CustomerAcID +'|'+'1'+'|'+Convert(Varchar(10),FinalNpaDt,103)+'|'+'19718'+'|'+'19718' as DataUtility from #Ganaseva A
   		 where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1

   		 -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
   		 UNION

   		 Select 'GanasevaDegrade' AS TableName,CustomerAcID, CustomerAcID +'|'+'1'+'|'+Convert(Varchar(10),FinalNpaDt,103)+'|'+'19718'+'|'+'19718' as DataUtility from #Ganaseva A
   		 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
   		 And ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')
   		 )A
   		 -------------------



   	     --------------mifin
   		 ----------Added on 04/04/2022

   			IF OBJECT_ID('TempDB..#MiFin') Is Not Null
   			Drop Table #MiFin

   			Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,
   			DA.AssetClassAlt_Key BankAssetClass
   				 INto #MiFin
   			 from Pro.ACCOUNTCAL A
   			Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID
   			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
   			Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key
   			ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey
   			Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key
   			ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey 
   			Where DS.SourceName='MiFin'
   			ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
   			And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
   			And R.ProcessDate=@PreviousDate)
   			And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
   			-- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
   			--X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
   			NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
   			Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)

   			Delete        a
   			from          #MiFin a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         b.DateofData=@Date
   			----------------

   			Truncate table   MiFin_Host_System_RERF
   			insert into   MiFin_Host_System_RERF
   			select *  from (
   		Select AccountID ,'NPA' Assetclass,SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) Npadate from ReverseFeedData A
   		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   		 where B.SourceName='MiFin'
   		 And A.AssetSubClass<>'STD'
   		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   		 ------Changes for NPADate on 22/04/2022

   		 union

   Select CustomerAcID ,'NPA',SubString(Replace(convert(varchar(20),FinalNpaDt,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),FinalNpaDt,106),' ','-')),2)
    from Pro.AccountCal_hist A wITH (NOLOCK)
   			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
   			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
   			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
   			 where B.SourceName='Mifin'
   			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
   			 ANd  ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')     
   			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey


   		 -----------Added on 11/04/2022
   		 UNION

   		 Select CustomerAcID ,'NPA',SubString(Replace(convert(varchar(20),FinalNPADt,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),FinalNPADt,106),' ','-')),2) 
   		 from #MiFin A
   		 where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1
   		 -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
   		 UNION

   		 Select CustomerAcID ,'NPA',SubString(Replace(convert(varchar(20),FinalNPADt,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),FinalNPADt,106),' ','-')),2) 
   		 from #MiFin A
   		 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
   		 And ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')
   )A


   	     --------------Indus
   		 ----------Added on 04/04/2022



   			IF OBJECT_ID('TempDB..#Indus') Is Not Null
   			Drop Table #Indus

   			Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,
   			DA.AssetClassAlt_Key BankAssetClass
   				 INto #Indus
   			 from Pro.ACCOUNTCAL A
   			Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID
   			ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey
   			Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key
   			ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey
   			Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key
   			ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey 
   			Where DS.SourceName='Indus'
   			ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
   			And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
   			And R.ProcessDate=@PreviousDate)
   			And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
   			-- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
   			--X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
   			NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
   			Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)


   			Delete        a
   			from          #Indus a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         b.DateofData=@Date
   			----------------


   		--Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) from ReverseFeedData A
   		--Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   		--And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   		-- where B.SourceName='MiFin'
   		-- And A.AssetSubClass<>'STD'
   		-- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   		Truncate table   Indus_Host_System_RERF
   		insert into  Indus_Host_System_RERF
   		select *  from (
   		Select AccountID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,
   		Replace(convert(varchar(20),NPADate,106),' ','-') as 'Value Date' from ReverseFeedData A
   			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   			 where B.SourceName='Indus'
   			 And A.AssetSubClass<>'STD'
   			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   			 ------Changes for NPADate on 22/04/2022

   		 union

   Select CustomerAcID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),FinalNpaDt,106),' ','-') as 'Value Date'
    from Pro.AccountCal_hist A wITH (NOLOCK)
   			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey
   			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
   			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey
   			 where B.SourceName='Indus'
   			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 
   			 ANd  ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')     
   			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey


   			 -----------Added on 11/04/2022
   		 UNION

   		 Select CustomerAcID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),FinalNpaDt,106),' ','-') as 'Value Date'
   		 from #Indus A
   		 where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1
   		 -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
   		 UNION

   		 Select CustomerAcID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),FinalNpaDt,106),' ','-') as 'Value Date'
   		 from #Indus A
   		 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
   		 And ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')
   )A

   	*/
   --	 	Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   --Declare @Date as Date =(Select Date from Automate_Advances Where EXT_FLG='Y')
   --Declare @PreviousDate AS Date =(Select Date from Automate_Advances Where Timekey=@TimeKey-2)
   IF utils.object_id('TempDB..tt_ECBF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF ';
   END IF;
   DELETE FROM tt_ECBF;
   UTILS.IDENTITY_RESET('tt_ECBF');

   INSERT INTO tt_ECBF ( 
   	SELECT CustomerAcID ,
           FinalAssetClassAlt_Key ,
           FinalNpaDt ,
           SourceAssetClass ,
           SourceNpaDate ,
           BankAssetClass ,
           ProductType ,
           ClientName ,
           ClientCustId ,
           SystemClassification ,
           SystemSubClassification ,
           DPD ,
           UserClassification ,
           UserSubClassification ,
           NpaDate ,
           CurrentDate 
   	  FROM ( SELECT A.CustomerAcID ,
                    A.FinalAssetClassAlt_Key ,
                    A.FinalNpaDt ,
                    B.SourceAssetClass ,
                    B.SourceNpaDate ,
                    DA.AssetClassAlt_Key BankAssetClass  ,
                    DP.ProductName ProductType  ,
                    C.CustomerName ClientName  ,
                    A.RefCustomerID ClientCustId  ,
                    E.AssetClassGroup SystemClassification  ,
                    CASE 
                         WHEN E.SrcSysClassCode = 'SS' THEN 'SBSTD'
                         WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                         WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                         WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                         WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                    ELSE E.SrcSysClassCode
                       END SystemSubClassification  ,
                    A.DPD_Max DPD  ,
                    'NPA' UserClassification  ,
                    'SBSTD' UserSubClassification  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105) NpaDate  ,
                    v_Date CurrentDate  
             FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                    JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
                    AND B.EffectiveFromTimeKey <= v_Timekey
                    AND B.EffectiveToTimeKey >= v_Timekey
                    JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                    AND DS.EffectiveFromTimeKey <= v_Timekey
                    AND DS.EffectiveToTimeKey >= v_Timekey
                    JOIN DimProduct DP   ON DP.ProductAlt_Key = A.ProductAlt_Key
                    AND DP.EffectiveFromTimeKey <= v_Timekey
                    AND DP.EffectiveToTimeKey >= v_Timekey
                    JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                    JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
                    AND E.EffectiveFromTimeKey <= v_Timekey
                    AND E.EffectiveToTimeKey >= v_Timekey
                    JOIN DimAssetClassMapping DA   ON DA.SrcSysClassCode = B.SourceAssetClass
                    AND A.SourceAlt_Key = DA.SourceAlt_Key
                    AND DA.EffectiveFromTimeKey <= v_Timekey
                    AND DA.EffectiveToTimeKey >= v_Timekey
              WHERE  DS.SourceName = 'ECBF'
                       AND NOT EXISTS ( SELECT 1 
                                        FROM ReverseFeedDataInsertSync R
                                         WHERE  A.CustomerAcID = R.CustomerAcID
                                                  AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                                  AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                                  AND R.ProcessDate = v_PreviousDate )
                       AND NOT EXISTS ( SELECT 1 
                                        FROM ReverseFeedData B
                                         WHERE  B.AccountID = A.CustomerAcID
                                                  AND DateofData = v_Date
                                                  AND B.AssetSubClass = 'STD' )
                       AND 
                     -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

                     --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                     NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) ) A
   	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_ECBF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  b.DateofData = v_Date );
   ------
   /*

   			Select 
   			SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   			,UserSubClassification,ValueDate,CurrentDate from ( Select ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
   			ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   			, DPD, UserClassification, UserSubClassification, ValueDate, CurrentDate
   			from (
   			Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,E.SrcSysClassCode as SystemSubClassification
   			,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as ValueDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
   			  from ReverseFeedData A
   			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   			And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   			Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
   			And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
   			 where B.SourceName='ECBF'
   			 And A.AssetSubClass<>'STD'
   			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   			 Group By 
   			 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
   			,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)
   			)A
   			)T



   		Truncate table  ECBF_Host_System_RERF
   		insert into  ECBF_Host_System_RERF
   		Select 
   		AccountID,SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   		,UserSubClassification,NpaDate,CurrentDate

   		 from (
   		Select 
   		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,AccountID,
   		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

   		from (
   		Select a.AccountID,A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,
   		Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 
   		When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification
   		,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
   		  from ReverseFeedData A
   		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
   		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
   		 where B.SourceName='ECBF'
   		 And A.AssetSubClass<>'STD'
   		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   		 Group By 
   		 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
   		,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105),AccountID
   		)A
   		)T
   		-------------Changes for npadate on 22/04/2022

   		Union

   		Select AccountID,
   		SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   		,UserSubClassification,NpaDate,CurrentDate

   		 from (
   		Select 
   		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,AccountID,
   		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

   		from (
   		Select CustomerAcID AccountID , D.ProductName ProductType,C.CustomerName ClientName,A.RefCustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,
   		Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 
   		When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification
   		,A.DPD_Max as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.FinalNpaDt,105) as NpaDate,Convert(Varchar(10),@Date,105)as CurrentDate
   		  from Pro.AccountCal A
   		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   		Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
   		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
   		Inner Join Pro.CustomerCal C ON C.CustomerEntityID=A.CustomerEntityID
   		And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   		Inner Join DimProduct D ON D.ProductAlt_Key=A.ProductAlt_Key
   		And D.EffectiveFromTimekey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey
   		 where B.SourceName='ECBF'
   		 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1
   		 And ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')
   		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   		 Group By 
   		 D.ProductName ,C.CustomerName ,A.RefCustomerID ,E.AssetClassGroup ,E.SrcSysClassCode ,CustomerAcID
   		,A.DPD_Max  ,Convert(Varchar(10),A.FinalNpaDt,105)--,Convert(Varchar(10),@Date,105)
   		)A
   		)T


   		---------Added on 04/04/2022-----
   		UNION


   		Select AccountID,
   		SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   		,UserSubClassification,NpaDate,CurrentDate

   		 from (
   		Select 
   		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,AccountID,
   		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

   		from (
   		Select CustomerAcID AccountID, ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
   		  from tt_ECBF A
   		where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1

   		)A
   		)T

   		-------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

   		UNION


   		Select AccountID,
   		SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   		,UserSubClassification,NpaDate,CurrentDate

   		 from (
   		Select 
   		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,AccountID,
   		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

   		from (
   		Select customeracid AccountID,ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
   		  from tt_ECBF A
   		where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
   		And ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')

   		)A
   		)T

   */
   ---------MetaGrid
   ----------Added on 04/04/2022
   --   Declare @TimeKey AS INT =(Select TimeKey-1 from Automate_Advances where EXT_FLG='Y')
   --Declare @Date as Date =(Select Date from Automate_Advances Where Timekey=@TimeKey)
   --Declare @PreviousDate AS Date =(Select Date from Automate_Advances Where Timekey=26463-2)
   IF utils.object_id('TempDB..tt_MetaGrid') IS NOT NULL THEN
    ----------------
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid ';
   END IF;
   DELETE FROM tt_MetaGrid;
   UTILS.IDENTITY_RESET('tt_MetaGrid');

   INSERT INTO tt_MetaGrid ( 
   	SELECT A.CustomerAcID ,
           A.RefCustomerID CustomerId  ,
           A.UCIF_ID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
             AND B.EffectiveFromTimeKey <= v_Timekey
             AND B.EffectiveToTimeKey >= v_Timekey
             JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
             AND DS.EffectiveFromTimeKey <= v_Timekey
             AND DS.EffectiveToTimeKey >= v_Timekey
             JOIN DimAssetClassMapping DA   ON DA.SrcSysClassCode = B.SourceAssetClass
             AND A.SourceAlt_Key = DA.SourceAlt_Key
             AND DA.EffectiveFromTimeKey <= v_Timekey
             AND DA.EffectiveToTimeKey >= v_Timekey
   	 WHERE  DS.SourceName = 'MetaGrid'
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedDataInsertSync R
                                WHERE  A.CustomerAcID = R.CustomerAcID
                                         AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                         AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass = 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_MetaGrid a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  b.DateofData = v_Date );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE Metagrid_Host_System_RERF ';
   INSERT INTO Metagrid_Host_System_RERF
     ( SELECT * 
       FROM ( SELECT A.AccountID ,
                     A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(NpaDate,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MetaGrid'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              ------Changes for NPADate on 22/04/2022
              SELECT a.CustomerAcID ,
                     A.RefCustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
              FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MetaGrid'
                        AND A.InitialAssetClassAlt_Key > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.InitialNpaDt, ' ') <> NVL(A.FinalNpaDt, ' ')
                        AND A.EffectiveFromTimekey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -----------Added on 11/04/2022
              SELECT a.CustomerAcID ,
                     A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
              FROM tt_MetaGrid A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT a.CustomerAcID ,
                     A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
              FROM tt_MetaGrid A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) a );---------Calypso
   --Select 
   --'AMEND' as [Action]
   --,D.CP_EXTERNAL_REF as [External Reference]
   --,D.COUNTERPARTY_SHORTNAME as [ShortName]
   --,D.COUNTERPARTY_FULLNAME as [LongName]
   --,D.COUNTERPARTY_COUNTRY as [Country]
   --,D.CP_FINANCIAL as [Financial]
   --,D.CP_PARENT  as [Parent]       
   --,D.CP_HOLIDAY as [HolidayCode]
   --,D.CP_COMMENT as [Comment]
   --,D.COUNTERPARTY_ROLE1 as [Roles.Role]
   --,D.COUNTERPARTY_ROLE2 as [Roles.Role]
   --,D.COUNTERPARTY_ROLE3 as [Roles.Role]
   --,D.COUNTERPARTY_ROLE4 as [Roles.Role]
   --,D.COUNTERPARTY_ROLE5 as [Roles.Role]
   --,D.CP_STATUS  as [Status]
   --,'ALL' as [Attribute.Role]
   --,'ALL'  as [Attribute.ProcessingOrg]
   --,'CIF_Id' as [Attribute.AttributeName]
   --,D.CIF_ID as [Attribute.AttributeValue]
   --,'ALL' as [Attribute.Role]
   --,'ALL' as [Attribute.ProcessingOrg]
   --,'UCIC' as [Attribute.AttributeName]
   --,D.ucic_id as [Attribute.AttributeValue]
   --,'ALL' as [Attribute.Role]
   --,'ALL' as [Attribute.ProcessingOrg]
   --,'ENPA_D2K_NPA_DATE' as [Attribute.AttributeName]
   --,Case When A.NPIDt is null then ISNULL(Cast(A.NPIDt as varchar(20)),'') else Convert(varchar(20),A.NPIDt,105) end  as [Attribute.AttributeValue]
   -- from dbo.InvestmentFinancialDetail A
   --Inner Join dbo.investmentbasicdetail B ON A.InvEntityId=B.InvEntityId
   --AND B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@TimeKey
   --Inner Join dbo.InvestmentIssuerDetail C ON C.IssuerEntityId=B.IssuerEntityId
   --AND C.EffectiveFromTimeKey<=@Timekey And C.EffectiveToTimeKey>=@TimeKey
   --Inner Join ReverseFeedCalypso D ON D.issuerId=C.IssuerID
   --AND D.EffectiveFromTimeKey<=@Timekey And D.EffectiveToTimeKey>=@TimeKey
   --Inner Join DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key
   --AND E.EffectiveFromTimeKey<=@Timekey And E.EffectiveToTimeKey>=@TimeKey
   --Where  A.EffectiveFromTimeKey<=@Timekey And A.EffectiveToTimeKey>=@TimeKey
   --AND A.FinalAssetClassAlt_Key<>1 And  A.InitialAssetAlt_key=1
   --Select * from (
   --SELECT 'SettlementLitigation' as TableName,'ACCOUNT_NO|Date|Flag' as DataUtility
   --UNION
   --Select 'SettlementLitigation' as TableName,ACID+'|'+Convert(Varchar(10),DateOfData,105)+'|'+AcctFlag as DataUtility from (
   -- select A.ACID,cast(getdate()  as date)DateOfData,'L' as AcctFlag
   -- from			ExceptionFinalStatusType a
   -- left join      RF_Settlement_Litigation b
   -- on             a.ACID=b.AccountId
   -- and            b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   -- and            b.AcctFlag='L'
   -- INNER JOIN     DBO.AdvAcBasicDetail C
   -- ON             C.CustomerACID=A.ACID
   -- and            C.EffectiveFromTimeKey <=@timekey and C.EffectiveToTimeKey >=@timekey
   -- inner join     DIMSOURCEDB d
   -- on             d.SourceAlt_Key=c.SourceAlt_Key
   --  and           d.EffectiveFromTimeKey <=@timekey and d.EffectiveToTimeKey >=@timekey
   -- where          a.StatusType='Litigation'
   -- and            b.AccountId is null
   -- and            a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   -- and            d.SourceName='Finacle' and c.FacilityType in ('CC','OD')
   -- UNION
   -- select         A.Acid AccountId,cast(getdate()  as date)DateOfData,'S' as AcctFlag
   -- from			 ExceptionFinalStatusType a               -----OTS_Details a
   -- left join      RF_Settlement_Litigation b
   -- on             a.Acid=b.AccountId
   -- and            b.EffectiveFromTimeKey <=@timekey and b.EffectiveToTimeKey >=@timekey
   -- and            b.AcctFlag='S'
   -- INNER JOIN     DBO.AdvAcBasicDetail C
   -- ON             C.CustomerACID=A.Acid
   -- and            C.EffectiveFromTimeKey <=@timekey and C.EffectiveToTimeKey >=@timekey
   -- inner join     DIMSOURCEDB d
   -- on             d.SourceAlt_Key=c.SourceAlt_Key
   -- and            d.EffectiveFromTimeKey <=@timekey and d.EffectiveToTimeKey >=@timekey
   -- where          a.StatusType='Settlement'
   -- and            b.AccountId is null
   -- and            a.EffectiveFromTimeKey <=@timekey and a.EffectiveToTimeKey >=@timekey
   -- and            d.SourceName='Finacle' and c.FacilityType in ('CC','OD')
   -- )A
   -- )B
   --  Order by 2 Desc

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEM_RERF_GENERATION_DATA" TO "ADF_CDR_RBL_STGDB";
