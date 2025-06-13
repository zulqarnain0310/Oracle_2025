--------------------------------------------------------
--  DDL for Procedure SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" 
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
   -------------Added on 04/04/2022
   v_cursor SYS_REFCURSOR;

BEGIN

   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      --------------Finacle
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Finacle_52') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_52 ';
      END IF;
      DELETE FROM tt_Finacle_52;
      UTILS.IDENTITY_RESET('tt_Finacle_52');

      INSERT INTO tt_Finacle_52 ( 
      	SELECT A.RefCustomerID CustomerID  ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              Z.UpgDate ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustOtherDetail_dummytest B   ON A.CustomerEntityID = B.CustomerEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                AND DS.EffectiveFromTimeKey <= v_Timekey
                AND DS.EffectiveToTimeKey >= v_Timekey
                JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                AND A.SourceAlt_Key = DA.SourceAlt_Key
                AND DA.EffectiveFromTimeKey <= v_Timekey
                AND DA.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                AND Z.EffectiveFromTimeKey <= v_Timekey
                AND Z.EffectiveToTimeKey >= v_Timekey
      	 WHERE  DS.SourceName = 'Finacle'
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass <> 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.RefCustomerID and X.StatusType='TWO' and

                 --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                 AND NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_Finacle_52 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ---------------------
      OPEN  v_cursor FOR
         SELECT 'FinacleUpgrade' TableName  ,
                CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>105) DataUtility  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Finacle'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 
         SELECT 'FinacleUpgrade' TableName  ,
                CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),10,p_style=>105) DataUtility  
           FROM tt_Finacle_52 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ------------------
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Ganaseva_40') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_40 ';
      END IF;
      DELETE FROM tt_Ganaseva_40;
      UTILS.IDENTITY_RESET('tt_Ganaseva_40');

      INSERT INTO tt_Ganaseva_40 ( 
      	SELECT A.RefCustomerID CustomerID  ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              Z.UpgDate ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustOtherDetail_dummytest B   ON A.CustomerEntityID = B.CustomerEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                AND DS.EffectiveFromTimeKey <= v_Timekey
                AND DS.EffectiveToTimeKey >= v_Timekey
                JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                AND A.SourceAlt_Key = DA.SourceAlt_Key
                AND DA.EffectiveFromTimeKey <= v_Timekey
                AND DA.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                AND Z.EffectiveFromTimeKey <= v_Timekey
                AND Z.EffectiveToTimeKey >= v_Timekey
      	 WHERE  DS.SourceName = 'Ganaseva'
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass <> 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.RefCustomerID and X.StatusType='TWO' and

                 --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                 AND NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_Ganaseva_40 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT 'GanasevaUpgrade' TableName  ,
                CustomerID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Ganaseva'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         --------------Added on 04/04/2022
         SELECT 'GanasevaUpgrade' TableName  ,
                CustomerID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_40 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------MiFin
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MiFin_52') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_52 ';
      END IF;
      DELETE FROM tt_MiFin_52;
      UTILS.IDENTITY_RESET('tt_MiFin_52');

      INSERT INTO tt_MiFin_52 ( 
      	SELECT A.RefCustomerID CustomerID  ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              Z.UpgDate ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustOtherDetail_dummytest B   ON A.CustomerEntityID = B.CustomerEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                AND DS.EffectiveFromTimeKey <= v_Timekey
                AND DS.EffectiveToTimeKey >= v_Timekey
                JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                AND A.SourceAlt_Key = DA.SourceAlt_Key
                AND DA.EffectiveFromTimeKey <= v_Timekey
                AND DA.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                AND Z.EffectiveFromTimeKey <= v_Timekey
                AND Z.EffectiveToTimeKey >= v_Timekey
      	 WHERE  DS.SourceName = 'MiFin'
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass <> 'STD' --And
                )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.RefCustomerID and X.StatusType='TWO' and

                 --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                 AND NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_MiFin_52 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT CustomerID ,
                'STD' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MiFin'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT CustomerID ,
                'STD' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_52 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Indus_52') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_52 ';
      END IF;
      DELETE FROM tt_Indus_52;
      UTILS.IDENTITY_RESET('tt_Indus_52');

      INSERT INTO tt_Indus_52 ( 
      	SELECT A.RefCustomerID CustomerID  ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              Z.UpgDate ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustOtherDetail_dummytest B   ON A.CustomerEntityID = B.CustomerEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                AND DS.EffectiveFromTimeKey <= v_Timekey
                AND DS.EffectiveToTimeKey >= v_Timekey
                JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                AND A.SourceAlt_Key = DA.SourceAlt_Key
                AND DA.EffectiveFromTimeKey <= v_Timekey
                AND DA.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                AND Z.EffectiveFromTimeKey <= v_Timekey
                AND Z.EffectiveToTimeKey >= v_Timekey
      	 WHERE  DS.SourceName = 'Indus'
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass <> 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.RefCustomerID and X.StatusType='TWO' and

                 --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                 AND NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_Indus_52 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT CustomerID Loan_Account_Number  ,
                'STD' MAIN_STATUS_OF_ACCOUNT  ,
                'STD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-') Value_Date  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Indus'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT Customerid Loan_Account_Number  ,
                'STD' MAIN_STATUS_OF_ACCOUNT  ,
                'STD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_52 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      ----------------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD_17') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD_17 ';
      END IF;
      DELETE FROM tt_ACCOUNTCAL_DPD_17;
      UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD_17');

      INSERT INTO tt_ACCOUNTCAL_DPD_17 ( 
      	SELECT CustomerEntityID ,
              MAX(DPD_Max)  DPD_Max  
      	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
      	  GROUP BY CustomerEntityID );
      IF utils.object_id('TempDB..tt_ECBF_54') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_54 ';
      END IF;
      DELETE FROM tt_ECBF_54;
      UTILS.IDENTITY_RESET('tt_ECBF_54');

      INSERT INTO tt_ECBF_54 ( 
      	SELECT CustomerID ,
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
      	  FROM ( SELECT A.RefCustomerID CustomerID  ,
                       A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                       A.SysNPA_Dt FinalNpaDt  ,
                       B.SourceAssetClass ,
                       B.SourceNpaDate ,
                       DA.AssetClassAlt_Key BankAssetClass  ,
                       DP.ProductName ProductType  ,
                       A.CustomerName ClientName  ,
                       A.RefCustomerID ClientCustId  ,
                       E.AssetClassGroup SystemClassification  ,
                       (CASE 
                             WHEN E.AssetClassShortName = 'SS' THEN 'SBSTD'
                             WHEN E.AssetClassShortName = 'D1' THEN 'DBT01'
                             WHEN E.AssetClassShortName = 'D2' THEN 'DBT02'
                             WHEN E.AssetClassShortName = 'D3' THEN 'DBT03'
                             WHEN E.AssetClassShortName = 'L1' THEN 'LOSS'
                       ELSE E.AssetClassShortName
                          END) SystemSubClassification  ,
                       AD.DPD_Max DPD  ,
                       'NPA' UserClassification  ,
                       'SBSTD' UserSubClassification  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105) NpaDate  ,
                       v_Date CurrentDate  
                FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                       JOIN RBL_MISDB_PROD.AdvCustOtherDetail_dummytest B   ON A.CustomerEntityID = B.CustomerEntityID
                       AND B.EffectiveFromTimeKey <= v_Timekey
                       AND B.EffectiveToTimeKey >= v_Timekey
                       JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                       AND DS.EffectiveFromTimeKey <= v_Timekey
                       AND DS.EffectiveToTimeKey >= v_Timekey
                       LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                       AND Z.EffectiveFromTimeKey <= v_Timekey
                       AND Z.EffectiveToTimeKey >= v_Timekey
                       JOIN DimProduct DP   ON DP.ProductAlt_Key = Z.ProductAlt_Key
                       AND DP.EffectiveFromTimeKey <= v_Timekey
                       AND DP.EffectiveToTimeKey >= v_Timekey
                       JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                       AND E.EffectiveFromTimeKey <= v_Timekey
                       AND E.EffectiveToTimeKey >= v_Timekey
                       JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                       AND A.SourceAlt_Key = DA.SourceAlt_Key
                       AND DA.EffectiveFromTimeKey <= v_Timekey
                       AND DA.EffectiveToTimeKey >= v_Timekey
                       LEFT JOIN tt_ACCOUNTCAL_DPD_17 AD   ON AD.CustomerEntityID = A.CustomerEntityID
                 WHERE  DS.SourceName = 'ECBF'
                          AND NOT EXISTS ( SELECT 1 
                                           FROM ReverseFeedDataInsertSync_Customer R
                                            WHERE  A.RefCustomerID = R.CustomerID
                                                     AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                                     AND R.ProcessDate = v_PreviousDate )
                          AND NOT EXISTS ( SELECT 1 
                                           FROM ReverseFeedData B
                                            WHERE  B.CustomerID = A.RefCustomerID
                                                     AND DateofData = v_Date
                                                     AND B.AssetSubClass <> 'STD' )

                          -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.RefCustomerID and X.StatusType='TWO' and

                          --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                          AND NOT EXISTS ( SELECT 1 
                                           FROM DimProduct Y
                                            WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                                     AND Y.ProductCode = 'RBSNP'
                                                     AND Y.EffectiveFromTimeKey <= v_TimeKey
                                                     AND Y.EffectiveToTimeKey >= v_TimeKey ) ) A
      	  GROUP BY CustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_ECBF_54 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----
      /*
      				Select 
      		SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
      		,UserSubClassification,NpaDate,CurrentDate

      		 from (
      		Select 
      		ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
      		ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
      		, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate

      		from (
      		Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,
      		'NPA' as SystemClassification,'SBSTD' as SystemSubClassification
      		,A.DPD as DPD, E.AssetClassGroup as UserClassification, 'DPD0' as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
      		  from ReverseFeedData A
      		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
      		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.AssetClassShortName
      		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
      		 where B.SourceName='ECBF'
      		 And A.AssetSubClass='STD'
      		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      		 Group By 
      		 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.AssetClassShortName 
      		,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105)
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
                                'NPA' SystemClassification  ,
                                'SBSTD' SystemSubClassification  ,
                                A.DPD DPD  ,
                                E.AssetClassGroup UserClassification  ,
                                (CASE 
                                      WHEN A.DPD = 0 THEN 'DPD0'
                                      WHEN A.DPD BETWEEN 1 AND 30 THEN 'DPD30'
                                      WHEN A.DPD BETWEEN 31 AND 60 THEN 'DPD60'
                                      WHEN A.DPD BETWEEN 61 AND 90 THEN 'DPD90'
                                      WHEN A.DPD BETWEEN 91 AND 180 THEN 'DPD180'
                                      WHEN A.DPD BETWEEN 181 AND 365 THEN 'PD1YR'   END) UserSubClassification  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.UpgradeDate,10,p_style=>105) NpaDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) CurrentDate  
                         FROM ReverseFeedData A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                                AND B.EffectiveFromTimekey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimAssetClass E   ON A.AssetSubClass = E.AssetClassShortName
                                AND E.EffectiveFromTimekey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey

                         --Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
                         WHERE  B.SourceName = 'ECBF'
                                  AND A.AssetSubClass = 'STD'
                                  AND A.EffectiveFromTimekey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.AssetClassShortName,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.UpgradeDate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) ) A ) T
         UNION 

         ------------Added on 04/04/2022
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
                  FROM ( SELECT ProductType ,
                                ClientName ,
                                ClientCustId ,
                                SystemClassification ,
                                SystemSubClassification ,
                                DPD ,
                                UserClassification ,
                                UserSubClassification ,
                                NpaDate ,
                                CurrentDate 
                         FROM tt_ECBF_54 A
                          WHERE  A.BankAssetClass > 1
                                   AND A.FinalAssetClassAlt_Key = 1 ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ------------------New Source-----------
   IF ( v_SourceType = 'MetaGrid' ) THEN

   BEGIN
      --------------MetaGrid
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MetaGrid_54') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_54 ';
      END IF;
      DELETE FROM tt_MetaGrid_54;
      UTILS.IDENTITY_RESET('tt_MetaGrid_54');

      INSERT INTO tt_MetaGrid_54 ( 
      	SELECT A.RefCustomerID ,
              A.RefCustomerID CustomerId  ,
              Z.UCIF_ID ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              Z.UpgDate ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustOtherDetail_dummytest B   ON A.CustomerEntityID = B.CustomerEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                AND DS.EffectiveFromTimeKey <= v_Timekey
                AND DS.EffectiveToTimeKey >= v_Timekey
                JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                AND A.SourceAlt_Key = DA.SourceAlt_Key
                AND DA.EffectiveFromTimeKey <= v_Timekey
                AND DA.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                AND Z.EffectiveFromTimeKey <= v_Timekey
                AND Z.EffectiveToTimeKey >= v_Timekey
      	 WHERE  DS.SourceName = 'MetaGrid'
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass <> 'STD' --And
                )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.RefCustomerID and X.StatusType='TWO' and

                 --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                 AND NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_MetaGrid_54 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL ENPA_D2K_NPA_DATE  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MetaGrid'
                   AND A.AssetSubClass = 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_54 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   -----------------------------------------------
   IF ( v_SourceType = 'Calypso' ) THEN

   BEGIN
      --------------Calypso
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
                   AND A.FinalAssetClassAlt_Key = 1
                   AND A.InitialAssetAlt_key <> 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_CUSTOMER" TO "ADF_CDR_RBL_STGDB";
