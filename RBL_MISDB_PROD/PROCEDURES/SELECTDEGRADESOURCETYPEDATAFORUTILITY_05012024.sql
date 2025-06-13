--------------------------------------------------------
--  DDL for Procedure SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" 
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

   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      --------------Finacle
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Finacle_16') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_16 ';
      END IF;
      DELETE FROM tt_Finacle_16;
      UTILS.IDENTITY_RESET('tt_Finacle_16');

      INSERT INTO tt_Finacle_16 ( 
      	SELECT A.CustomerAcID ,
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
      	 WHERE  DS.SourceName = 'Finacle'
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
                 AND NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_Finacle_16 a
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
                  FROM tt_Finacle_16 A
                   WHERE  A.BankAssetClass = 1
                            AND A.FinalAssetClassAlt_Key > 1
                  UNION 

                  -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_16 A
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
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Ganaseva_10') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_10 ';
      END IF;
      DELETE FROM tt_Ganaseva_10;
      UTILS.IDENTITY_RESET('tt_Ganaseva_10');

      INSERT INTO tt_Ganaseva_10 ( 
      	SELECT A.CustomerAcID ,
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
      	 WHERE  DS.SourceName = 'Ganaseva'
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
        FROM tt_Ganaseva_10 a
               JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
             A
       WHERE  b.DateofData = v_Date );
      ----------------
      OPEN  v_cursor FOR
         SELECT 'GanasevaDegrade' TableName  ,
                AccountID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
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
                CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Ganaseva'
                   AND A.InitialAssetClassAlt_Key > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.InitialNpaDt, ' ') <> NVL(A.FinalNpaDt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         ----------Added on 04/04/2022
         SELECT 'GanasevaDegrade' TableName  ,
                CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_10 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT 'GanasevaDegrade' TableName  ,
                CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_10 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   -------------------
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------mifin
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MiFin_16') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_16 ';
      END IF;
      DELETE FROM tt_MiFin_16;
      UTILS.IDENTITY_RESET('tt_MiFin_16');

      INSERT INTO tt_MiFin_16 ( 
      	SELECT A.CustomerAcID ,
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
      	 WHERE  DS.SourceName = 'MiFin'
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
        FROM tt_MiFin_16 a
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
         SELECT CustomerAcID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Mifin'
                   AND A.InitialAssetClassAlt_Key > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.InitialNpaDt, ' ') <> NVL(A.FinalNpaDt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT CustomerAcID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_16 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT CustomerAcID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_16 A
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
      IF utils.object_id('TempDB..tt_Indus_16') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_16 ';
      END IF;
      DELETE FROM tt_Indus_16;
      UTILS.IDENTITY_RESET('tt_Indus_16');

      INSERT INTO tt_Indus_16 ( 
      	SELECT A.CustomerAcID ,
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
      	 WHERE  DS.SourceName = 'Indus'
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
        FROM tt_Indus_16 a
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
         SELECT CustomerAcID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                  AND B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey
                  JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  B.SourceName = 'Indus'
                   AND A.InitialAssetClassAlt_Key > 1
                   AND A.FinalAssetClassAlt_Key > 1
                   AND NVL(A.InitialNpaDt, ' ') <> NVL(A.FinalNpaDt, ' ')
                   AND A.EffectiveFromTimekey <= v_TimeKey
                   AND A.EffectiveToTimeKey >= v_TimeKey
         UNION 

         -----------Added on 11/04/2022
         SELECT CustomerAcID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_16 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT CustomerAcID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_16 A
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
      IF utils.object_id('TempDB..tt_ECBF_18') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_18 ';
      END IF;
      DELETE FROM tt_ECBF_18;
      UTILS.IDENTITY_RESET('tt_ECBF_18');

      INSERT INTO tt_ECBF_18 ( 
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
                                               AND Y.EffectiveToTimeKey >= v_TimeKey )
                  GROUP BY A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,DA.AssetClassAlt_Key,DP.ProductName,C.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105) ) A
      	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate );
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_ECBF_18 a
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
                                C.CustomerName ClientName  ,
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
                                MAX(A.DPD_Max)  DPD  ,
                                'NPA' UserClassification  ,
                                'SBSTD' UserSubClassification  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105) NpaDate  ,
                                v_Date CurrentDate  
                         FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                                AND B.EffectiveFromTimekey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                                AND E.EffectiveFromTimekey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                                AND C.EffectiveFromTimekey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimProduct D   ON D.ProductAlt_Key = A.ProductAlt_Key
                                AND D.EffectiveFromTimekey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                          WHERE  B.SourceName = 'ECBF'
                                   AND A.InitialAssetClassAlt_Key > 1
                                   AND A.FinalAssetClassAlt_Key > 1
                                   AND NVL(A.InitialNpaDt, ' ') <> NVL(A.FinalNpaDt, ' ')
                                   AND A.EffectiveFromTimekey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY D.ProductName,C.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105 --,Convert(Varchar(10),@Date,105)
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
                         FROM tt_ECBF_18 A
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
                         FROM tt_ECBF_18 A
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
      IF utils.object_id('TempDB..tt_MetaGrid_18') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_18 ';
      END IF;
      DELETE FROM tt_MetaGrid_18;
      UTILS.IDENTITY_RESET('tt_MetaGrid_18');

      INSERT INTO tt_MetaGrid_18 ( 
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
        FROM tt_MetaGrid_18 a
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
         SELECT A.RefCustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                  JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
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
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_18 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_18 A
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
      IF utils.object_id('TempDB..tt_EIFS_15') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_EIFS_15 ';
      END IF;
      DELETE FROM tt_EIFS_15;
      UTILS.IDENTITY_RESET('tt_EIFS_15');

      INSERT INTO tt_EIFS_15 ( 
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
                          AND NOT EXISTS ( SELECT 1 
                                           FROM ReverseFeedDataInsertSync R
                                            WHERE  A.CustomerAcID = R.CustomerAcID
                                                     AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                                     AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                                     AND R.ProcessDate = v_PreviousDate )
                          AND 
                        --And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And
                        NOT EXISTS ( SELECT 1 
                                     FROM DimProduct Y
                                      WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                               AND Y.ProductCode = 'RBSNP'
                                               AND Y.EffectiveFromTimeKey <= v_TimeKey
                                               AND Y.EffectiveToTimeKey >= v_TimeKey ) ) A
      	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemAssetClassification,SystemSubClassification,UserDPD,UserClassification,UserSubClassification,NpaDate,DateOfData,NPAReason,NPACategory,UCIC_ID );
      --Delete        a
      --from          tt_EIFS_15 a
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
                         FROM tt_EIFS_15 A
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
                         FROM tt_EIFS_15 A
                          WHERE  A.BankAssetClass > 1
                                   AND A.FinalAssetClassAlt_Key > 1
                                   AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) A ) T ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_05012024" TO "ADF_CDR_RBL_STGDB";
