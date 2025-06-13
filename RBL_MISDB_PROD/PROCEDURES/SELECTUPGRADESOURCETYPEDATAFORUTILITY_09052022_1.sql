--------------------------------------------------------
--  DDL for Procedure SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" 
--dbo.SelectUpgradeSourceTypeDataForUtility 'Finacle'

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
   -------------Added on 04/04/2022
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @TimeKey AS INT =26298
   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      --------------Finacle
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Finacle_42') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_42 ';
      END IF;
      DELETE FROM tt_Finacle_42;
      UTILS.IDENTITY_RESET('tt_Finacle_42');

      INSERT INTO tt_Finacle_42 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              A.UpgDate ,
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
      	 WHERE  DS.SourceName = 'Finacle' );
      ---------------------
      OPEN  v_cursor FOR
         SELECT 'FinacleUpgrade' TableName  ,
                AccountID || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>105) DataUtility  
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
                CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgDate,10,p_style=>105) DataUtility  
           FROM tt_Finacle_42 A
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
      IF utils.object_id('TempDB..tt_Ganaseva_31') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_31 ';
      END IF;
      DELETE FROM tt_Ganaseva_31;
      UTILS.IDENTITY_RESET('tt_Ganaseva_31');

      INSERT INTO tt_Ganaseva_31 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              A.UpgDate ,
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
      	 WHERE  DS.SourceName = 'Ganaseva' );
      ----------------
      OPEN  v_cursor FOR
         SELECT 'GanasevaUpgrade' TableName  ,
                AccountID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
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
                CustomerAcID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgDate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  
           FROM tt_Ganaseva_31 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------MiFin
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_MiFin_42') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_42 ';
      END IF;
      DELETE FROM tt_MiFin_42;
      UTILS.IDENTITY_RESET('tt_MiFin_42');

      INSERT INTO tt_MiFin_42 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              A.UpgDate ,
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
      	 WHERE  DS.SourceName = 'MiFin' );
      ----------------
      OPEN  v_cursor FOR
         SELECT AccountID ,
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
         SELECT CustomerAcid ,
                'STD' ,
                SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgDate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgDate,20,p_style=>106), ' ', '-')), -2, 2) 
           FROM tt_MiFin_42 A
          WHERE  A.BankAssetClass > 1
                   AND A.FinalAssetClassAlt_Key = 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      ----------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_Indus_42') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_42 ';
      END IF;
      DELETE FROM tt_Indus_42;
      UTILS.IDENTITY_RESET('tt_Indus_42');

      INSERT INTO tt_Indus_42 ( 
      	SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              A.UpgDate ,
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
      	 WHERE  DS.SourceName = 'Indus' );
      ----------------
      OPEN  v_cursor FOR
         SELECT AccountID Loan_Account_Number  ,
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
         SELECT CustomerAcid Loan_Account_Number  ,
                'STD' MAIN_STATUS_OF_ACCOUNT  ,
                'STD' SUB_STATUS_OF_ACCOUNT  ,
                'CN01' REASON_CODE  ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgDate,20,p_style=>106), ' ', '-') Value_Date  
           FROM tt_Indus_42 A
          WHERE  A.BankAssetClass = 1
                   AND A.FinalAssetClassAlt_Key > 1 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      ----------------Added on 04/04/2022
      IF utils.object_id('TempDB..tt_ECBF_44') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_44 ';
      END IF;
      DELETE FROM tt_ECBF_44;
      UTILS.IDENTITY_RESET('tt_ECBF_44');

      INSERT INTO tt_ECBF_44 ( 
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
                 WHERE  DS.SourceName = 'ECBF' ) A
      	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate );
      ------
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
      		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
      		And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
      		 where B.SourceName='ECBF'
      		 And A.AssetSubClass='STD'
      		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      		 Group By 
      		 A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
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
                                JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                                AND E.EffectiveFromTimekey <= v_TimeKey
                                AND E.EffectiveToTimeKey >= v_TimeKey

                         --Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
                         WHERE  B.SourceName = 'ECBF'
                                  AND A.AssetSubClass = 'STD'
                                  AND A.EffectiveFromTimekey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey
                           GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.UpgradeDate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) ) A ) T
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
                         FROM tt_ECBF_44 A
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
      IF utils.object_id('TempDB..tt_MetaGrid_44') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_44 ';
      END IF;
      DELETE FROM tt_MetaGrid_44;
      UTILS.IDENTITY_RESET('tt_MetaGrid_44');

      INSERT INTO tt_MetaGrid_44 ( 
      	SELECT A.CustomerAcID ,
              A.RefCustomerID CustomerId  ,
              A.UCIF_ID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              A.UpgDate ,
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
      	 WHERE  DS.SourceName = 'MetaGrid' );
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
           FROM tt_MetaGrid_44 A
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTUPGRADESOURCETYPEDATAFORUTILITY_09052022_1" TO "ADF_CDR_RBL_STGDB";
