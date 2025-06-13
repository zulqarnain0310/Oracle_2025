--------------------------------------------------------
--  DDL for Procedure SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" 
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

   --Declare @TimeKey AS INT =26298
   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
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
      IF utils.object_id('TempDB..tt_Finacle_27') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_27 ';
      END IF;
      DELETE FROM tt_Finacle_27;
      UTILS.IDENTITY_RESET('tt_Finacle_27');

      INSERT INTO tt_Finacle_27 ( 
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

      	----Inner Join Finacle_uat_data D ON D.Customer_Ac_ID=A.CustomerAcID

      	----Inner Join Finacle_RF_UAT D ON D.Customer_Ac_ID=A.CustomerAcID
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
                AND 
              --NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

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
        FROM tt_Finacle_27 a
               JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
             A
       WHERE  b.DateofData = v_Date );
      ---------------------
      /* =================================Added by Prashant to change the Finacle logic=========================== */
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
                  SELECT 'FinacleDegrade' TableName  ,
                         customeracid || '|' || UTILS.CONVERT_TO_VARCHAR2(a.FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                         JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                         AND B.EffectiveFromTimeKey <= v_TimeKey
                         AND B.EffectiveToTimeKey >= v_TimeKey
                         JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                         AND E.EffectiveFromTimeKey <= v_TimeKey
                         AND E.EffectiveToTimeKey >= v_TimeKey
                   WHERE  B.SourceName = 'Finacle'
                            AND A.InitialAssetClassAlt_Key > 1
                            AND A.FinalAssetClassAlt_Key > 1
                            AND A.InitialNpaDt <> A.FinalNpaDt
                            AND A.EffectiveFromTimeKey <= v_TimeKey
                            AND A.EffectiveToTimeKey >= v_TimeKey
                  UNION 

                  ---------Added on 04/04/2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_27 A
                   WHERE  A.BankAssetClass = 1
                            AND A.FinalAssetClassAlt_Key > 1
                  UNION 

                  -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                  SELECT 'FinacleDegrade' TableName  ,
                         CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  
                  FROM tt_Finacle_27 A
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
      IF utils.object_id('TempDB..tt_Ganaseva_19') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_19 ';
      END IF;
      DELETE FROM tt_Ganaseva_19;
      UTILS.IDENTITY_RESET('tt_Ganaseva_19');

      INSERT INTO tt_Ganaseva_19 ( 
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
        FROM tt_Ganaseva_19 a
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
           FROM tt_Ganaseva_19 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT 'GanasevaDegrade' TableName  ,
                CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_19 A
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
      IF utils.object_id('TempDB..tt_MiFin_27') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_27 ';
      END IF;
      DELETE FROM tt_MiFin_27;
      UTILS.IDENTITY_RESET('tt_MiFin_27');

      INSERT INTO tt_MiFin_27 ( 
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
        FROM tt_MiFin_27 a
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
           FROM tt_MiFin_27 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT CustomerAcID ,
                'NPA' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_27 A
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
      IF utils.object_id('TempDB..tt_Indus_27') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_27 ';
      END IF;
      DELETE FROM tt_Indus_27;
      UTILS.IDENTITY_RESET('tt_Indus_27');

      INSERT INTO tt_Indus_27 ( 
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
        FROM tt_Indus_27 a
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
           FROM tt_Indus_27 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT CustomerAcID Loan_Account_Number  ,
                'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_27 A
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
      IF utils.object_id('TempDB..tt_ECBF_29') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_29 ';
      END IF;
      DELETE FROM tt_ECBF_29;
      UTILS.IDENTITY_RESET('tt_ECBF_29');

      INSERT INTO tt_ECBF_29 ( 
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
        FROM tt_ECBF_29 a
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
                                A.DPD_Max DPD  ,
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
                           GROUP BY D.ProductName,C.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD_Max,UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105 --,Convert(Varchar(10),@Date,105)
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
                         FROM tt_ECBF_29 A
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
                         FROM tt_ECBF_29 A
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
      IF utils.object_id('TempDB..tt_MetaGrid_29') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_29 ';
      END IF;
      DELETE FROM tt_MetaGrid_29;
      UTILS.IDENTITY_RESET('tt_MetaGrid_29');

      INSERT INTO tt_MetaGrid_29 ( 
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
        FROM tt_MetaGrid_29 a
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
           FROM tt_MetaGrid_29 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1
         UNION 

         -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
         SELECT A.CustomerID CIF_ID  ,
                A.UCIF_ID UCIC  ,
                NULL Asset_Classification  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  
           FROM tt_MetaGrid_29 A
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTDEGRADESOURCETYPEDATAFORUTILITY_28102022" TO "ADF_CDR_RBL_STGDB";
