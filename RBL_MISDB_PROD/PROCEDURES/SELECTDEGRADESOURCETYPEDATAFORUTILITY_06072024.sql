--------------------------------------------------------
--  DDL for Procedure SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" 
(
  v_SourceType IN VARCHAR2
)
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
   ---------------------
   /* =================================Added by Prashant to change the Finacle logic=========================== */
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('TempDB..tt_ReverseFeedDataInsertSyn_9') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ReverseFeedDataInsertSyn_9 ';
   END IF;
   DELETE FROM tt_ReverseFeedDataInsertSyn_9;
   UTILS.IDENTITY_RESET('tt_ReverseFeedDataInsertSyn_9');

   INSERT INTO tt_ReverseFeedDataInsertSyn_9 ( 
   	SELECT * 
   	  FROM ReverseFeedDataInsertSync 
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date );
   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      --------------Finacle
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Finacle_17') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_17 ';
      END IF;
      DELETE FROM tt_Finacle_17;
      UTILS.IDENTITY_RESET('tt_Finacle_17');

      INSERT INTO tt_Finacle_17 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_ReverseFeedDataInsertSyn_9 RC   ON A.CustomerAcID = RC.CustomerAcID
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
      	 WHERE  DS.SourceName = 'Finacle'
                 AND RC.SourceName = 'Finacle' );
      --ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
      --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
      --And R.ProcessDate=@PreviousDate)
      --And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')AND
      --NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
      --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_Finacle_17 a
               JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
             A
       WHERE  b.DateofData = v_Date );
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'FinacleDegrade' TableName  ,
                         AccountID || '|' || CASE 
                                                  WHEN NVL(NPADate, '1900-01-01') < NVL(AcOpenDt, '1900-01-01') THEN UTILS.CONVERT_TO_VARCHAR2(AcOpenDt,10,p_style=>105) || '|' || UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>105)
                         ELSE UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>105) || '|'
                            END DataUtility  
                  FROM ReverseFeedData A
                         JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                         AND B.EffectiveFromTimeKey <= v_TimeKey
                         AND B.EffectiveToTimeKey >= v_TimeKey
                         JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON A.AccountID = C.CustomerAcID
                         AND C.EffectiveFromTimekey <= v_TimeKey
                         AND C.EffectiveToTimeKey >= v_TimeKey
                   WHERE  B.SourceName = 'Finacle'
                            AND A.AssetSubClass <> 'STD'
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                  UNION 

                  -------Added on 04/04/2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_17 A
                   WHERE  A.BankAssetClass = 1
                            AND A.FinalAssetClassAlt_Key > 1
                  UNION 

                  -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_17 A
                   WHERE  A.BankAssetClass > 1
                            AND A.FinalAssetClassAlt_Key > 1
                            AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) 
                ----------------
                A
           GROUP BY TableName,DataUtility ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   /*================================================ END ======================================================================*/
   /*
   	  IF (@SourceType ='Ganaseva')
   	BEGIN
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

   		 Select 'GanasevaDegrade' AS TableName, AccountID +'|'+'1'+'|'+Convert(Varchar(10),NPADate,103)+'|'+'19718'+'|'+'19718' as DataUtility from ReverseFeedData A
   		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   		 where B.SourceName='Ganaseva'
   		 And A.AssetSubClass<>'STD'
   		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   		  ------Changes for NPADate on 22/04/2022

   		 union

   Select 'GanasevaDegrade' AS TableName, CustomerAcID +'|'+'1'+'|'+Convert(Varchar(10),FinalNpaDt,103)+'|'+'19718'+'|'+'19718' as DataUtility
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

   		 Select 'GanasevaDegrade' AS TableName, CustomerAcID +'|'+'1'+'|'+Convert(Varchar(10),FinalNpaDt,103)+'|'+'19718'+'|'+'19718' as DataUtility from #Ganaseva A
   		 where A.BankAssetClass=1 And A.FinalAssetClassAlt_Key>1

   		 -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
   		 UNION

   		 Select 'GanasevaDegrade' AS TableName, CustomerAcID +'|'+'1'+'|'+Convert(Varchar(10),FinalNpaDt,103)+'|'+'19718'+'|'+'19718' as DataUtility from #Ganaseva A
   		 where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key>1
   		 And ISNULL(A.FinalNpaDt,'')<>ISNULL(A.SourceNpaDate,'')

   		 -------------------

   	END
   	*/
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------mifin
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MiFin_17') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_17 ';
      END IF;
      DELETE FROM tt_MiFin_17;
      UTILS.IDENTITY_RESET('tt_MiFin_17');

      INSERT INTO tt_MiFin_17 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_ReverseFeedDataInsertSyn_9 RC   ON A.CustomerAcID = RC.CustomerAcID
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
      	 WHERE  DS.SourceName = 'MiFin'
                 AND RC.SourceName = 'MiFin' );
      --ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
      --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
      --And R.ProcessDate=@PreviousDate)
      --And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
      ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
      ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
      --NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
      --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_MiFin_17 a
               JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT AccountID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MiFin'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         ------Changes for NPADate on 22/04/2022

         --		 union

         --Select CustomerAcID ,'NPA',SubString(Replace(convert(varchar(20),FinalNpaDt,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),FinalNpaDt,106),' ','-')),2)

         -- from Pro.AccountCal_hist A wITH (NOLOCK)

         --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

         --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

         --			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

         --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

         --			 where B.SourceName='Mifin'

         --			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 

         --			 ANd  ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')     

         --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

         -----------Added on 11/04/2022
         SELECT CustomerAcID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_17 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT CustomerAcID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_17 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Indus_17') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_17 ';
      END IF;
      DELETE FROM tt_Indus_17;
      UTILS.IDENTITY_RESET('tt_Indus_17');

      INSERT INTO tt_Indus_17 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_ReverseFeedDataInsertSyn_9 RC   ON A.CustomerAcID = RC.CustomerAcID
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
      	 WHERE  DS.SourceName = 'Indus'
                 AND RC.SourceName = 'Indus' );
      --ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
      --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
      --And R.ProcessDate=@PreviousDate)
      --And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
      ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
      ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
      --NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
      --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_Indus_17 a
               JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) from ReverseFeedData A
      --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      -- where B.SourceName='MiFin'
      -- And A.AssetSubClass<>'STD'
      -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      OPEN  v_cursor FOR
         SELECT AccountID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-') Value_Date  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Indus'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         ------Changes for NPADate on 22/04/2022

         --		 union

         --Select CustomerAcID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),FinalNpaDt,106),' ','-') as 'Value Date'

         -- from Pro.AccountCal_hist A wITH (NOLOCK)

         --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

         --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

         --			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

         --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

         --			 where B.SourceName='Indus'

         --			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 

         --			 ANd  ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')     

         --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

         -----------Added on 11/04/2022
         SELECT CustomerAcID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_17 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT CustomerAcID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_17 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      ----------------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_ECBF_19') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_19 ';
      END IF;
      DELETE FROM tt_ECBF_19;
      UTILS.IDENTITY_RESET('tt_ECBF_19');

      INSERT INTO tt_ECBF_19 ( 
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
                       MAX(A.DPD_Max)  DPD  ,
                       'NPA' UserClassification  ,
                       'SBSTD' UserSubClassification  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105) NpaDate  ,
                       v_Date CurrentDate  
                FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                       JOIN tt_ReverseFeedDataInsertSyn_9 RC   ON A.CustomerAcID = RC.CustomerAcID
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
                          AND RC.SourceName = 'ECBF'

                --ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID

                --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')

                --And R.ProcessDate=@PreviousDate)

                --And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And

                ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

                ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND

                --NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 

                --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
                GROUP BY A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,DA.AssetClassAlt_Key,DP.ProductName,C.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105) ) A
      	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_ECBF_19 a
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

      		*/
      OPEN  v_cursor FOR
         SELECT SrNo ,
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
           FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ClientCustId  ) SrNo  ,
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
                  FROM ( SELECT A.ProductName ProductType  ,
                                A.CustomerName ClientName  ,
                                A.CustomerID ClientCustId  ,
                                E.AssetClassGroup SystemClassification  ,
                                CASE 
                                     WHEN E.SrcSysClassCode = 'SS' THEN 'DBT01'
                                     WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                                     WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                                     WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                                     WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                                ELSE E.SrcSysClassCode
                                   END SystemSubClassification  ,
                                MAX(A.DPD)  DPD  ,
                                'NPA' UserClassification  ,
                                'SBSTD' UserSubClassification  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105) NpaDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) CurrentDate  
                         FROM ReverseFeedData A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                                AND B.EffectiveFromTimekey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                                AND E.EffectiveFromTimekey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                          WHERE  B.SourceName = 'ECBF'
                                   AND A.AssetSubClass <> 'STD'
                                   AND A.EffectiveFromTimekey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) ) A ) T
         UNION 

         -------------Changes for npadate on 22/04/2022

         --Union

         --Select 

         --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification

         --,UserSubClassification,NpaDate,CurrentDate

         -- from (

         --Select 

         --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

         --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

         --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

         --from (

         --Select DISTINCT D.ProductName ProductType,C.CustomerName ClientName,A.RefCustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,

         --Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 

         --When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification

         --,max(A.DPD_Max) as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.FinalNpaDt,105) as NpaDate,Convert(Varchar(10),@Date,105)as CurrentDate

         --  from Pro.AccountCal A

         --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

         --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

         --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

         --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

         --Inner Join Pro.CustomerCal C ON C.CustomerEntityID=A.CustomerEntityID

         --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

         --Inner Join DimProduct D ON D.ProductAlt_Key=A.ProductAlt_Key

         --And D.EffectiveFromTimekey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey

         -- where B.SourceName='ECBF'

         -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1

         -- And ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')

         -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

         -- Group By 

         -- D.ProductName ,C.CustomerName ,A.RefCustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 

         -- ,Convert(Varchar(10),A.FinalNpaDt,105)--,Convert(Varchar(10),@Date,105)

         --)A

         --)T

         ---------Added on 04/04/2022-----
         SELECT SrNo ,
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
           FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ClientCustId  ) SrNo  ,
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
                  FROM ( SELECT DISTINCT ProductType ,
                                         ClientName ,
                                         ClientCustId ,
                                         SystemClassification ,
                                         SystemSubClassification ,
                                         DPD ,
                                         UserClassification ,
                                         UserSubClassification ,
                                         NpaDate ,
                                         CurrentDate 
                         FROM tt_ECBF_19 A
                          WHERE  A.BankAssetClass = 1
                                   AND A.FinalAssetClassAlt_Key > 1 ) A ) T
         UNION 

         -----Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT SrNo ,
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
           FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ClientCustId  ) SrNo  ,
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
                  FROM ( SELECT DISTINCT ProductType ,
                                         ClientName ,
                                         ClientCustId ,
                                         SystemClassification ,
                                         SystemSubClassification ,
                                         DPD ,
                                         UserClassification ,
                                         UserSubClassification ,
                                         NpaDate ,
                                         CurrentDate 
                         FROM tt_ECBF_19 A
                          WHERE  A.BankAssetClass > 1
                                   AND A.FinalAssetClassAlt_Key > 1
                                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MetaGrid' ) THEN

   BEGIN
      ---------MetaGrid
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MetaGrid_19') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_19 ';
      END IF;
      DELETE FROM tt_MetaGrid_19;
      UTILS.IDENTITY_RESET('tt_MetaGrid_19');

      INSERT INTO tt_MetaGrid_19 ( 
      	SELECT A.CustomerAcID ,
              A.RefCustomerID CustomerId  ,
              A.UCIF_ID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_ReverseFeedDataInsertSyn_9 RC   ON A.CustomerAcID = RC.CustomerAcID
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
                 AND RC.SourceName = 'MetaGrid' );
      --ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID
      --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')
      --And R.ProcessDate=@PreviousDate)
      --And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
      ---- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and
      ----X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
      --NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 
      --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_MetaGrid_19 a
               JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(NpaDate,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MetaGrid'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         ------Changes for NPADate on 22/04/2022

         --		 union

         --Select A.RefCustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),A.FinalNpaDt,105),'-','') as 'ENPA_D2K_NPA_DATE'

         -- from Pro.AccountCal_hist A wITH (NOLOCK)

         --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

         --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

         --			Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key

         --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

         --			 where B.SourceName='MetaGrid'

         --			 And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1 

         --			 ANd  ISNULL(A.InitialNpaDt,'')<>ISNULL(A.FinalNpaDt,'')     

         --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

         -----------Added on 11/04/2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_19 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_19 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ----------------------
   IF ( v_SourceType = 'Calypso' ) THEN

   BEGIN
      ---------Calypso
      OPEN  v_cursor FOR
         SELECT 'AMEND' Action  ,
                D.CP_EXTERNAL_REF External_Reference  ,
                D.COUNTERPARTY_SHORTNAME ShortName  ,
                D.COUNTERPARTY_FULLNAME LongName  ,
                D.COUNTERPARTY_COUNTRY Country  ,
                D.CP_FINANCIAL Financial  ,
                D.CP_PARENT Parent  ,
                D.CP_HOLIDAY HolidayCode  ,
                D.CP_COMMENT Comment_  ,
                D.COUNTERPARTY_ROLE1 Roles_Role  ,
                D.COUNTERPARTY_ROLE2 Roles__A11  ,
                D.COUNTERPARTY_ROLE3 Roles__A12  ,
                D.COUNTERPARTY_ROLE4 Roles__A13  ,
                D.COUNTERPARTY_ROLE5 Roles__A14  ,
                D.CP_STATUS Status  ,
                'ALL' Attribute_Role  ,
                'ALL' Attribute_ProcessingOrg  ,
                'CIF_Id' Attribute_AttributeName  ,
                D.CIF_ID Attribute_AttributeValue  ,
                'ALL' Attribute_Role  ,
                'ALL' Attribute_ProcessingOrg  ,
                'UCIC' Attribute_AttributeName  ,
                D.ucic_id Attribute_AttributeV_A23  ,
                'ALL' Attribute_Role  ,
                'ALL' Attribute_ProcessingOrg  ,
                'ENPA_D2K_NPA_DATE' Attribute_AttributeName  ,
                CASE 
                     WHEN A.NPIDt IS NULL THEN NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20), ' ')
                ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPIDt,20,p_style=>105)
                   END Attribute_AttributeV_A27  
           FROM RBL_MISDB_PROD.InvestmentFinancialDetail A
                  JOIN RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId
                  AND B.EffectiveFromTimeKey <= v_Timekey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN RBL_MISDB_PROD.InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
                  AND C.EffectiveFromTimeKey <= v_Timekey
                  AND C.EffectiveToTimeKey >= v_TimeKey
                  JOIN ReversefeedCalypso D   ON D.issuerId = C.IssuerID
                  AND D.EffectiveFromTimeKey <= v_Timekey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_Timekey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND A.FinalAssetClassAlt_Key <> 1
                   AND A.InitialAssetAlt_key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'SettlementLitigation' ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'SettlementLitigation' TableName  ,
                         'ACCOUNT_NO|Date|Flag' DataUtility  
                    FROM DUAL 
                  UNION 
                  SELECT 'SettlementLitigation' TableName  ,
                         ACID || '|' || UTILS.CONVERT_TO_VARCHAR2(DateOfData,10,p_style=>105) || '|' || AcctFlag DataUtility  
                  FROM ( SELECT A.ACID ,
                                UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) DateOfData  ,
                                'L' AcctFlag  
                         FROM ExceptionFinalStatusType a
                                LEFT JOIN RF_Settlement_Litigation b   ON a.ACID = b.AccountId
                                AND b.EffectiveFromTimeKey <= v_timekey
                                AND b.EffectiveToTimeKey >= v_timekey
                                AND b.AcctFlag = 'L'
                                JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON C.CustomerACID = A.ACID
                                AND C.EffectiveFromTimeKey <= v_timekey
                                AND C.EffectiveToTimeKey >= v_timekey
                                JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = c.SourceAlt_Key
                                AND D.EffectiveFromTimeKey <= v_timekey
                                AND D.EffectiveToTimeKey >= v_timekey
                          WHERE  a.StatusType = 'Litigation'
                                   AND b.AccountId IS NULL
                                   AND a.EffectiveFromTimeKey <= v_timekey
                                   AND a.EffectiveToTimeKey >= v_timekey
                                   AND D.SourceName = 'Finacle'
                                   AND c.FacilityType IN ( 'CC','OD' )

                         UNION 
                         SELECT A.ACID AccountId  ,
                                UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) DateOfData  ,
                                'S' AcctFlag  
                         FROM ExceptionFinalStatusType a -----OTS_Details a

                                LEFT JOIN RF_Settlement_Litigation b   ON a.ACID = b.AccountId
                                AND b.EffectiveFromTimeKey <= v_timekey
                                AND b.EffectiveToTimeKey >= v_timekey
                                AND b.AcctFlag = 'S'
                                JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON C.CustomerACID = A.ACID
                                AND C.EffectiveFromTimeKey <= v_timekey
                                AND C.EffectiveToTimeKey >= v_timekey
                                JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = c.SourceAlt_Key
                                AND D.EffectiveFromTimeKey <= v_timekey
                                AND D.EffectiveToTimeKey >= v_timekey
                          WHERE  a.StatusType = 'Settlement'
                                   AND b.AccountId IS NULL
                                   AND a.EffectiveFromTimeKey <= v_timekey
                                   AND a.EffectiveToTimeKey >= v_timekey
                                   AND D.SourceName = 'Finacle'
                                   AND c.FacilityType IN ( 'CC','OD' )
                        ) A ) B
           ORDER BY 2 DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ------------------------------------FOR EIFS ADDED BY MANDEEP SINGH 26-09-2022------------------------------------------------------
   IF ( v_SourceType = 'EIFS' ) THEN
    DECLARE
      v_SourceAlt_Key NUMBER(5,0) := ( SELECT SourceAlt_Key 
        FROM DIMSOURCEDB 
       WHERE  SourceName = 'EIFS'
                AND EffectiveToTimeKey = 49999 );

   BEGIN
      IF utils.object_id('TempDB..tt_EIFS_16') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_EIFS_16 ';
      END IF;
      DELETE FROM tt_EIFS_16;
      UTILS.IDENTITY_RESET('tt_EIFS_16');

      INSERT INTO tt_EIFS_16 ( 
      	SELECT CustomerAcID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              SourceAssetClass ,
              SourceNpaDate ,
              BankAssetClass ,
              ProductType ,
              ClientName ,
              ClientCustId ,
              SystemAssetClassification ,
              SystemSubClassification ,
              UserDPD ,
              UserClassification ,
              UserSubClassification ,
              NpaDate ,
              DateOfData ,
              NPAReason ,
              NPACategory ,
              UCIC_ID 
      	  FROM ( SELECT A.CustomerAcID ,
                       A.FinalAssetClassAlt_Key ,
                       A.FinalNpaDt ,
                       B.SourceAssetClass ,
                       B.SourceNpaDate ,
                       DA.AssetClassAlt_Key BankAssetClass  ,
                       DP.ProductName ProductType  ,
                       C.CustomerName ClientName  ,
                       A.RefCustomerID ClientCustId  ,
                       E.AssetClassGroup SystemAssetClassification  ,
                       CASE 
                            WHEN E.SrcSysClassCode = 'SS' THEN 'SBSTD'
                            WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                            WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                            WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                            WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                       ELSE E.SrcSysClassCode
                          END SystemSubClassification  ,
                       A.DPD_Max UserDPD  ,
                       'NPA' UserClassification  ,
                       'SBSTD' UserSubClassification  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105) NpaDate  ,
                       v_Date DateOfData  ,
                       CASE 
                            WHEN a.NPA_Reason IS NULL THEN 'D2K'
                       ELSE a.NPA_Reason
                          END NPAReason  ,
                       'Auto' NPACategory  ,
                       a.UCIF_ID UCIC_ID  
                FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                       JOIN tt_ReverseFeedDataInsertSyn_9 RC   ON A.CustomerAcID = RC.CustomerAcID
                       JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
                       AND B.EffectiveFromTimeKey <= v_Timekey
                       AND B.EffectiveToTimeKey >= v_Timekey
                       JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                       AND DS.EffectiveFromTimeKey <= v_Timekey
                       AND DS.EffectiveToTimeKey >= v_Timekey
                       AND DS.SourceAlt_Key = v_SourceAlt_Key
                       JOIN DimProduct DP   ON DP.ProductAlt_Key = A.ProductAlt_Key
                       AND DP.EffectiveFromTimeKey <= v_Timekey
                       AND DP.EffectiveToTimeKey >= v_Timekey
                       AND DP.ProductCode IN ( SELECT ProductCode 
                                               FROM DimProduct 
                                                WHERE  SourceAlt_Key = v_SourceAlt_Key )

                       JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                       JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
                       AND E.EffectiveFromTimeKey <= v_Timekey
                       AND E.EffectiveToTimeKey >= v_Timekey
                       JOIN DimAssetClassMapping DA   ON DA.SrcSysClassCode = B.SourceAssetClass
                       AND A.SourceAlt_Key = DA.SourceAlt_Key
                       AND DA.EffectiveFromTimeKey <= v_Timekey
                       AND DA.EffectiveToTimeKey >= v_Timekey
                 WHERE  DS.SourceName = 'EIFS'
                          AND RC.SourceName = 'EIFS' ) 
              --ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID

              --And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')

              --And R.ProcessDate=@PreviousDate) AND

              ----And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And

              --NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and 

              --Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)
              A
      	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemAssetClassification,SystemSubClassification,UserDPD,UserClassification,UserSubClassification,NpaDate,DateOfData,NPAReason,NPACategory,UCIC_ID );
      --Delete        a
      --from          tt_EIFS_16 a
      --inner join    ReverseFeedData b
      --on            a.CustomerAcID=b.AccountID
      --where         b.DateofData=@Date
      ------
      OPEN  v_cursor FOR
         SELECT
         --SrNo,
          ClientName DealerName  ,
          UCIC_ID ,
          CustomerID ,
          SystemAssetClassification ,
          SystemSubClassification ,
          UserClassification ,
          UserSubClassification ,
          UserDPD ,
          UTILS.CONVERT_TO_VARCHAR2(NpaDate,30,p_style=>110) NpaDate  ,
          UTILS.CONVERT_TO_VARCHAR2(DateOfData,30,p_style=>110) DateOfData  ,
          NPAReason ,
          NPACategory 
           FROM ( SELECT
                  --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
                   ClientName ,
                   UCIC_ID ,
                   CustomerID ,
                   SystemAssetClassification ,
                   SystemSubClassification ,
                   UserDPD ,
                   UserClassification ,
                   UserSubClassification ,
                   NpaDate ,
                   DateOfData ,
                   NPAReason ,
                   NPACategory 
                  FROM ( SELECT --ProductType,
                          ClientName ,
                          UCIC_ID ,
                          ClientCustId CustomerID  ,
                          SystemAssetClassification ,
                          SystemSubClassification ,
                          UserDPD ,
                          UserClassification ,
                          UserSubClassification ,
                          NpaDate ,
                          DateOfData ,
                          NPAReason ,
                          NPACategory 
                         FROM tt_EIFS_16 A
                          WHERE  A.BankAssetClass = 1
                                   AND A.FinalAssetClassAlt_Key > 1 ) A ) T
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT
         --SrNo,ProductType,
          ClientName DealerName  ,
          UCIC_ID ,
          CustomerID ,
          SystemAssetClassification ,
          SystemSubClassification ,
          UserClassification ,
          UserSubClassification ,
          UserDPD ,
          UTILS.CONVERT_TO_VARCHAR2(NpaDate,30,p_style=>110) NpaDate  ,
          UTILS.CONVERT_TO_VARCHAR2(DateOfData,30,p_style=>110) DateOfData  ,
          NPAReason ,
          NPACategory 
           FROM ( SELECT
                  --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,		ProductType,
                   ClientName ,
                   UCIC_ID ,
                   CustomerID ,
                   SystemAssetClassification ,
                   SystemSubClassification ,
                   --, DPD, 
                   UserClassification ,
                   UserSubClassification ,
                   UserDPD ,
                   NpaDate ,
                   DateOfData ,
                   NPAReason ,
                   NPACategory 
                  FROM ( SELECT --ProductType,
                          ClientName ,
                          UCIC_ID ,
                          ClientCustId CustomerID  ,
                          SystemAssetClassification ,
                          SystemSubClassification ,
                          UserClassification ,
                          UserSubClassification ,
                          UserDPD ,
                          NpaDate ,
                          DateOfData ,
                          NPAReason ,
                          NPACategory 
                         FROM tt_EIFS_16 A
                          WHERE  A.BankAssetClass > 1
                                   AND A.FinalAssetClassAlt_Key > 1
                                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_06072024" TO "ADF_CDR_RBL_STGDB";
