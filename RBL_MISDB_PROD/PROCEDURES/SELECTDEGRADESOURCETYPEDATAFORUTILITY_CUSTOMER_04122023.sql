--------------------------------------------------------
--  DDL for Procedure SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" 
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
   v_cursor SYS_REFCURSOR;

BEGIN

   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      IF utils.object_id('TempDB..tt_Finacle_31') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_31 ';
      END IF;
      DELETE FROM tt_Finacle_31;
      UTILS.IDENTITY_RESET('tt_Finacle_31');

      INSERT INTO tt_Finacle_31 ( 
      	SELECT A.RefCustomerID CustomerID  ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
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

      	----Inner Join Finacle_uat_data D ON D.Customer_Ac_ID=A.CustomerAcID

      	----Inner Join Finacle_RF_UAT D ON D.Customer_Ac_ID=A.CustomerAcID
      	WHERE  DS.SourceName = 'Finacle'
                AND A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND NOT EXISTS ( SELECT 1 
                                 FROM ReverseFeedDataInsertSync_Customer R
                                  WHERE  B.RefCustomerID = R.CustomerID
                                           AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                           AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                           AND R.ProcessDate = v_PreviousDate )
                AND NOT EXISTS ( SELECT 1 
                                 FROM ReverseFeedData B
                                  WHERE  B.CustomerID = A.RefCustomerID
                                           AND DateofData = v_Date
                                           AND B.AssetSubClass = 'STD' )

                --NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

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
        FROM tt_Finacle_31 a
               JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ---------------------
      /* =================================Added by Prashant to change the Finacle logic=========================== */
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'FinacleDegrade' TableName  ,
                         CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(c.SysNPA_Dt,10,p_style=>105) || '|' DataUtility  
                  FROM ReverseFeedData A
                         JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                         AND B.EffectiveFromTimeKey <= v_TimeKey
                         AND B.EffectiveToTimeKey >= v_TimeKey
                         JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON A.CustomerID = C.RefCustomerID
                         AND C.EffectiveFromTimekey <= v_TimeKey
                         AND C.EffectiveToTimeKey >= v_TimeKey
                   WHERE  B.SourceName = 'Finacle'
                            AND A.AssetSubClass <> 'STD'
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                  UNION 
                  SELECT 'FinacleDegrade' TableName  ,
                         RefCustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(a.SysNPA_Dt,10,p_style=>105) || '|' DataUtility  
                  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                         JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                         AND B.EffectiveFromTimeKey <= v_TimeKey
                         AND B.EffectiveToTimeKey >= v_TimeKey
                         JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                         AND E.EffectiveFromTimeKey <= v_TimeKey
                         AND E.EffectiveToTimeKey >= v_TimeKey
                   WHERE  B.SourceName = 'Finacle'
                            AND A.SrcAssetClassAlt_Key > 1
                            AND A.SysAssetClassAlt_Key > 1
                            AND A.SrcNPA_Dt <> A.SysNPA_Dt
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                  UNION 

                  ---------Added on 04/04/2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalAssetClassAlt_Key,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_31 A
                   WHERE  A.BankAssetClass = 1
                            AND A.FinalAssetClassAlt_Key > 1
                  UNION 

                  -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_31 A
                   WHERE  A.BankAssetClass > 1
                            AND A.FinalAssetClassAlt_Key > 1
                            AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNPADate, ' ')
                            OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) 
                ----------------
                A
           GROUP BY TableName,DataUtility ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   /*================================================ END ======================================================================*/
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Ganaseva_23') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_23 ';
      END IF;
      DELETE FROM tt_Ganaseva_23;
      UTILS.IDENTITY_RESET('tt_Ganaseva_23');

      INSERT INTO tt_Ganaseva_23 ( 
      	SELECT A.RefCustomerID ,
              A.SrcAssetClassAlt_Key ,
              A.SrcNPA_Dt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              a.SysAssetClassAlt_Key ,
              a.SysNPA_Dt ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
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
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.AccountID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass = 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

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
        FROM tt_Ganaseva_23 a
               JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT 'GanasevaDegrade' TableName  ,
                CustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM ReverseFeedData A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimekey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Ganaseva'
                   AND A.AssetSubClass <> 'STD'
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         ------Changes for NPADate on 22/04/2022
         SELECT 'GanasevaDegrade' TableName  ,
                RefCustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Ganaseva'
                   AND A.SrcAssetClassAlt_Key > 1
                   AND A.SysAssetClassAlt_Key > 1
                   AND NVL(A.SysNPA_Dt, ' ') <> NVL(A.SrcNPA_Dt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         ----------Added on 04/04/2022
         SELECT 'GanasevaDegrade' TableName  ,
                refCustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_23 A
          WHERE  A.BankAssetClass = 1
                   AND A.SysAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT 'GanasevaDegrade' TableName  ,
                RefCustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_23 A
          WHERE  A.BankAssetClass > 1
                   AND A.SysAssetClassAlt_Key > 1
                   AND ( NVL(A.SourceNpaDate, ' ') <> NVL(A.SysNPA_Dt, ' ')
                   OR ( A.BankAssetClass <> A.SysAssetClassAlt_Key ) ) ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   -------------------
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------mifin
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MiFin_31') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_31 ';
      END IF;
      DELETE FROM tt_MiFin_31;
      UTILS.IDENTITY_RESET('tt_MiFin_31');

      INSERT INTO tt_MiFin_31 ( 
      	SELECT A.RefCustomerID ,
              A.SysAssetClassAlt_Key ,
              A.SysNPA_Dt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
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
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.RefCustomerID = R.CustomerID
                                            AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                            AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass = 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

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
        FROM tt_MiFin_31 a
               JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT CustomerID ,
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
         SELECT RefCustomerID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Mifin'
                   AND A.SrcAssetClassAlt_Key > 1
                   AND A.SysAssetClassAlt_Key > 1
                   AND NVL(A.SrcNPA_Dt, ' ') <> NVL(A.SysNPA_Dt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT RefCustomerID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_31 A
          WHERE  A.BankAssetClass = 1
                   AND A.SysAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT RefCustomerID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_31 A
          WHERE  A.BankAssetClass > 1
                   AND A.SysAssetClassAlt_Key > 1
                   AND ( NVL(A.SysNPA_Dt, ' ') <> NVL(A.SourceNPADate, ' ')
                   OR ( A.BankAssetClass <> A.SysAssetClassAlt_Key ) ) ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Indus_31') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_31 ';
      END IF;
      DELETE FROM tt_Indus_31;
      UTILS.IDENTITY_RESET('tt_Indus_31');

      INSERT INTO tt_Indus_31 ( 
      	SELECT A.RefCustomerID ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
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
                                            AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass = 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

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
        FROM tt_Indus_31 a
               JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
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
         SELECT RefCustomerID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-') Value_Date  
           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Indus'
                   AND A.SrcAssetClassAlt_Key > 1
                   AND A.SysAssetClassAlt_Key > 1
                   AND NVL(A.SrcNPA_Dt, ' ') <> NVL(A.SysNPA_Dt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT RefCustomerID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_31 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT RefCustomerID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_31 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                   OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      ----------------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD_15') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD_15 ';
      END IF;
      DELETE FROM tt_ACCOUNTCAL_DPD_15;
      UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD_15');

      INSERT INTO tt_ACCOUNTCAL_DPD_15 ( 
      	SELECT CustomerEntityID ,
              MAX(DPD_Max)  DPD_Max  
      	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
      	  GROUP BY CustomerEntityID );
      IF utils.object_id('TempDB..tt_ECBF_33') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_33 ';
      END IF;
      DELETE FROM tt_ECBF_33;
      UTILS.IDENTITY_RESET('tt_ECBF_33');

      INSERT INTO tt_ECBF_33 ( 
      	SELECT RefCustomerID ,
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
      	  FROM ( SELECT A.RefCustomerID ,
                       A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
                       A.SysNPA_Dt FinalNpaDt  ,
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
                       AD.DPD_Max DPD  ,
                       'NPA' UserClassification  ,
                       'SBSTD' UserSubClassification  ,
                       UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105) NpaDate  ,
                       v_Date CurrentDate  
                FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                       JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
                       AND B.EffectiveFromTimeKey <= v_Timekey
                       AND B.EffectiveToTimeKey >= v_Timekey
                       JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
                       AND DS.EffectiveFromTimeKey <= v_Timekey
                       AND DS.EffectiveToTimeKey >= v_Timekey
                       JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                       JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.SysAssetClassAlt_Key
                       AND E.EffectiveFromTimeKey <= v_Timekey
                       AND E.EffectiveToTimeKey >= v_Timekey
                       JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
                       AND A.SourceAlt_Key = DA.SourceAlt_Key
                       AND DA.EffectiveFromTimeKey <= v_Timekey
                       AND DA.EffectiveToTimeKey >= v_Timekey
                       LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
                       AND Z.EffectiveFromTimeKey <= v_Timekey
                       AND Z.EffectiveToTimeKey >= v_Timekey
                       LEFT JOIN tt_ACCOUNTCAL_DPD_15 AD   ON AD.CustomerEntityID = Z.CustomerEntityID
                       JOIN DimProduct DP   ON DP.ProductAlt_Key = Z.ProductAlt_Key
                       AND DP.EffectiveFromTimeKey <= v_Timekey
                       AND DP.EffectiveToTimeKey >= v_Timekey
                 WHERE  DS.SourceName = 'ECBF'
                          AND NOT EXISTS ( SELECT 1 
                                           FROM ReverseFeedDataInsertSync_Customer R
                                            WHERE  A.RefCustomerID = R.CustomerID
                                                     AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                                     AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                                     AND R.ProcessDate = v_PreviousDate )
                          AND NOT EXISTS ( SELECT 1 
                                           FROM ReverseFeedData B
                                            WHERE  B.CustomerID = A.RefCustomerID
                                                     AND DateofData = v_Date
                                                     AND B.AssetSubClass = 'STD' )

                          -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

                          --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                          AND NOT EXISTS ( SELECT 1 
                                           FROM DimProduct Y
                                            WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                                     AND Y.ProductCode = 'RBSNP'
                                                     AND Y.EffectiveFromTimeKey <= v_TimeKey
                                                     AND Y.EffectiveToTimeKey >= v_TimeKey ) ) A
      	  GROUP BY RefCustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_ECBF_33 a
               JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
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
                                A.DPD DPD  ,
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
                           GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) ) A ) T
         UNION 

         -------------Changes for npadate on 22/04/2022
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
                  FROM ( SELECT D.ProductName ProductType  ,
                                A.CustomerName ClientName  ,
                                A.RefCustomerID ClientCustId  ,
                                E.AssetClassGroup SystemClassification  ,
                                CASE 
                                     WHEN E.SrcSysClassCode = 'SS' THEN 'DBT01'
                                     WHEN E.SrcSysClassCode = 'D1' THEN 'DBT01'
                                     WHEN E.SrcSysClassCode = 'D2' THEN 'DBT02'
                                     WHEN E.SrcSysClassCode = 'D3' THEN 'DBT03'
                                     WHEN E.SrcSysClassCode = 'L1' THEN 'LOSS'
                                ELSE E.SrcSysClassCode
                                   END SystemSubClassification  ,
                                c.DPD_Max DPD  ,
                                'NPA' UserClassification  ,
                                'SBSTD' UserSubClassification  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105) NpaDate  ,
                                v_Date CurrentDate  
                         FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                                AND B.EffectiveFromTimekey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                                AND E.EffectiveFromTimekey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                                AND C.EffectiveFromTimekey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimProduct D   ON D.ProductAlt_Key = c.ProductAlt_Key
                                AND D.EffectiveFromTimekey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                          WHERE  B.SourceName = 'ECBF'
                                   AND A.SrcAssetClassAlt_Key > 1
                                   AND A.SysAssetClassAlt_Key > 1
                                   AND NVL(A.SrcNPA_Dt, ' ') <> NVL(A.SysNPA_Dt, ' ')
                                   AND A.EffectiveFromTimekey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY D.ProductName,A.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,c.DPD_Max,UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105 --,Convert(Varchar(10),@Date,105)
                                    ) ) A ) T
         UNION 

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
                         FROM tt_ECBF_33 A
                          WHERE  A.BankAssetClass = 1
                                   AND A.FinalAssetClassAlt_Key > 1 ) A ) T
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
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
                         FROM tt_ECBF_33 A
                          WHERE  A.BankAssetClass > 1
                                   AND A.FinalAssetClassAlt_Key > 1
                                   AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                                   OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MetaGrid' ) THEN

   BEGIN
      ---------MetaGrid
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MetaGrid_33') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_33 ';
      END IF;
      DELETE FROM tt_MetaGrid_33;
      UTILS.IDENTITY_RESET('tt_MetaGrid_33');

      INSERT INTO tt_MetaGrid_33 ( 
      	SELECT A.RefCustomerID ,
              A.RefCustomerID CustomerId  ,
              A.UCIF_ID ,
              A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
              A.SysNPA_Dt FinalNpaDt  ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  
      	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityId
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
                                            AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                            AND R.ProcessDate = v_PreviousDate )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedData B
                                   WHERE  B.CustomerID = A.RefCustomerID
                                            AND DateofData = v_Date
                                            AND B.AssetSubClass = 'STD' )

                 -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

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
        FROM tt_MetaGrid_33 a
               JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
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
         SELECT A.RefCustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'MetaGrid'
                   AND A.SrcAssetClassAlt_Key > 1
                   AND A.SysAssetClassAlt_Key > 1
                   AND NVL(A.SrcNPA_Dt, ' ') <> NVL(A.SysNPA_Dt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_33 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_33 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                   OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--	----------------------
      --	IF (@SourceType ='Calypso')
      --	BEGIN
      --	   ---------Calypso
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
      --	END
      --IF (@SourceType ='SettlementLitigation')
      --	BEGIN
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
      -- END

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
