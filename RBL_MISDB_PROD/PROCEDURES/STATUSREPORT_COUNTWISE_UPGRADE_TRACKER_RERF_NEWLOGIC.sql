--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" 
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
   IF utils.object_id('tempdb..tt_temp1_68') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_68 ';
   END IF;
   DELETE FROM tt_temp1_68;
   --------------Finacle

   --INSERT INTO tt_temp1_68

   ----Select  'FinacleUpgrade' AS TableName, AccountID +'|'+Convert(Varchar(10),UpgradeDate,105) as DataUtility  

   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A

   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

   -- where B.SourceName='Finacle'

   -- And A.AssetSubClass='STD'

   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   -- group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_Finacle_74') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_74 ';
   END IF;
   DELETE FROM tt_Finacle_74;
   UTILS.IDENTITY_RESET('tt_Finacle_74');

   INSERT INTO tt_Finacle_74 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
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
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass <> 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ---------------------
   INSERT INTO tt_temp1_68
     ( SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  CNT  
       FROM ( SELECT 'FinacleUpgrade' TableName  ,
                     AccountID || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>105) DataUtility  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Finacle'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -------------Added on 04/04/2022
              SELECT 'FinacleUpgrade' TableName  ,
                     CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_date),10,p_style=>105) DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM tt_Finacle_74 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceSystemName );
   --------------Ganaseva
   --Select 'GanasevaUpgrade' AS TableName, AccountID +'|'+'0'+'|'+Convert(Varchar(10),UpgradeDate,103)+'|'+'19718'+'|'+'19718' as DataUtility
   --INSERT INTO tt_temp1_68
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   -- where B.SourceName='Ganaseva'
   -- And A.AssetSubClass='STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   -- group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_Ganaseva_66') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_66 ';
   END IF;
   DELETE FROM tt_Ganaseva_66;
   UTILS.IDENTITY_RESET('tt_Ganaseva_66');

   INSERT INTO tt_Ganaseva_66 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
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
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass <> 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ----------------
   INSERT INTO tt_temp1_68
     ( SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  CNT  
       FROM ( SELECT 'GanasevaUpgrade' TableName  ,
                     AccountID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Ganaseva'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              --------------Added on 04/04/2022
              SELECT 'GanasevaUpgrade' TableName  ,
                     CustomerAcID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_date),10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM tt_Ganaseva_66 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceSystemName );
   ----------------VisionPlus
   -- 	INSERT INTO tt_temp1_68
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   -- where B.SourceName='VisionPlus'
   -- And A.AssetSubClass='STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   -- group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_VisionPlus_36') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_36 ';
   END IF;
   DELETE FROM tt_VisionPlus_36;
   UTILS.IDENTITY_RESET('tt_VisionPlus_36');

   INSERT INTO tt_VisionPlus_36 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
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
   	 WHERE  DS.SourceName = 'VisionPlus'
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedDataInsertSync R
                                WHERE  A.CustomerAcID = R.CustomerAcID
                                         AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                         AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM DimProduct Y
                                WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                         AND Y.ProductCode = 'RBSNP'
                                         AND Y.EffectiveFromTimeKey <= v_TimeKey
                                         AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   INSERT INTO tt_temp1_68
     ( SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  CNT  
       FROM ( SELECT 'VisionPlusDataList' TableName  ,
                     AccountID ,
                     '       ' NPADate  ,
                     'Upgrade' Type  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'VisionPlus'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerAcID ,
                     '       ' NPADate  ,
                     'Upgrade' Type  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM tt_VisionPlus_36 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceSystemName );
   --------------MiFin
   --Select AccountID ,'STD',SubString(Replace(convert(varchar(20),UpgradeDate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),UpgradeDate,106),' ','-')),2) 
   --INSERT INTO tt_temp1_68
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   -- where B.SourceName='MiFin'
   -- And A.AssetSubClass='STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   -- group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_MiFin_74') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_74 ';
   END IF;
   DELETE FROM tt_MiFin_74;
   UTILS.IDENTITY_RESET('tt_MiFin_74');

   INSERT INTO tt_MiFin_74 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
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
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass <> 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ----------------
   INSERT INTO tt_temp1_68
     ( SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  CNT  
       FROM ( SELECT AccountID ,
                     'STD' ACLstatus  ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MiFin'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -----------Added on 11/04/2022
              SELECT CustomerAcid ,
                     'STD' ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgDate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgDate,20,p_style=>106), ' ', '-')), -2, 2) ,
                     SourceAlt_Key ,
                     SourceName 
              FROM tt_MiFin_74 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceSystemName );
   --------------Indus
   --Select AccountID as 'Loan Account Number' ,'STD' as MAIN_STATUS_OF_ACCOUNT,'STD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),UpgradeDate,106),' ','-') as 'Value Date' 
   --INSERT INTO tt_temp1_68
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   -- where B.SourceName='Indus'
   -- And A.AssetSubClass='STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   --       group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_Indus_74') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_74 ';
   END IF;
   DELETE FROM tt_Indus_74;
   UTILS.IDENTITY_RESET('tt_Indus_74');

   INSERT INTO tt_Indus_74 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
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
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass <> 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ----------------
   INSERT INTO tt_temp1_68
     ( SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  CNT  
       FROM ( SELECT AccountID Loan_Account_Number  ,
                     'STD' MAIN_STATUS_OF_ACCOUNT  ,
                     'STD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,20,p_style=>106), ' ', '-') Value_Date  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Indus'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -----------Added on 11/04/2022
              SELECT CustomerAcid Loan_Account_Number  ,
                     'STD' MAIN_STATUS_OF_ACCOUNT  ,
                     'STD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(UpgDate,20,p_style=>106), ' ', '-') Value_Date  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM tt_Indus_74 A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1 ) A
         GROUP BY SourceAlt_Key,SourceSystemName );
   --------------ECBF
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
   --Declare @TimeKey AS INT =(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   --Select 
   --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification
   --,UserSubClassification,NpaDate,CurrentDate
   -- from (
   --Select 
   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,
   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification
   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate
   --from (
   --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification
   --,A.DPD as DPD,E.AssetClassGroup as UserClassification,
   --(Case When A.DPD=0 Then 'DPD0' When A.DPD BETWEEN 1 AND 30 Then 'DPD30' When A.DPD BETWEEN 31 AND 60 Then 'DPD60' 
   --When A.DPD BETWEEN 61 AND 90 Then 'DPD90' When A.DPD BETWEEN 91 AND 180 Then 'DPD180' When A.DPD BETWEEN 181 AND 365 Then 'PD1YR' END )
   -- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate
   --INSERT INTO tt_temp1_68
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt  
   --from ReverseFeedData A
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode
   --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey
   ----Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
   -- where B.SourceName='ECBF'
   -- And A.AssetSubClass='STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   -- group by a.SourceAlt_Key,a.SourceSystemName
   -- Group By 
   -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode 
   --,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105)
   --)A
   --)T
   IF utils.object_id('TempDB..tt_ECBF_76') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_76 ';
   END IF;
   DELETE FROM tt_ECBF_76;
   UTILS.IDENTITY_RESET('tt_ECBF_76');

   INSERT INTO tt_ECBF_76 ( 
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
           CurrentDate ,
           SourceAlt_Key ,
           SourceName 
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
                    v_Date CurrentDate  ,
                    ds.SourceAlt_Key ,
                    ds.SourceName 
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
                                                  AND R.ProcessDate = v_PreviousDate )
                       AND NOT EXISTS ( SELECT 1 
                                        FROM ReverseFeedData B
                                         WHERE  B.AccountID = A.CustomerAcID
                                                  AND DateofData = v_Date
                                                  AND B.AssetSubClass <> 'STD' )
                       AND 
                     -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

                     --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                     NOT EXISTS ( SELECT 1 
                                  FROM DimProduct Y
                                   WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                            AND Y.ProductCode = 'RBSNP'
                                            AND Y.EffectiveFromTimeKey <= v_TimeKey
                                            AND Y.EffectiveToTimeKey >= v_TimeKey ) ) A
   	  GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,SourceAlt_Key,SourceName );
   INSERT INTO tt_temp1_68
     SELECT SourceAlt_Key ,
            SourceName ,
            COUNT(*)  CNT  
       FROM ( SELECT SrNo ,
                     ProductType ,
                     ClientName ,
                     ClientCustId ,
                     SystemClassification ,
                     SystemSubClassification ,
                     DPD ,
                     UserClassification ,
                     UserSubClassification ,
                     NpaDate ,
                     CurrentDate ,
                     SourceAlt_Key ,
                     SourceName 
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
                            CurrentDate ,
                            SourceAlt_Key ,
                            SourceName 
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
     UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) CurrentDate  ,
     b.SourceAlt_Key ,
     b.SourceName 
                            FROM ReverseFeedData A
                                   JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey

                            --Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
                            WHERE  B.SourceName = 'ECBF'
                                     AND A.AssetSubClass = 'STD'
                                     AND A.EffectiveFromTimeKey <= v_TimeKey
                                     AND A.EffectiveToTimeKey >= v_TimeKey
                              GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.UpgradeDate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105),b.SourceAlt_Key,b.SourceName ) A ) T
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
                     CurrentDate ,
                     SourceAlt_Key ,
                     SourceName 
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
                            CurrentDate ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT ProductType ,
                                   ClientName ,
                                   ClientCustId ,
                                   SystemClassification ,
                                   SystemSubClassification ,
                                   DPD ,
                                   UserClassification ,
                                   UserSubClassification ,
                                   NpaDate ,
                                   CurrentDate ,
                                   SourceAlt_Key ,
                                   SourceName 
                            FROM tt_ECBF_76 A
                             WHERE  A.BankAssetClass > 1
                                      AND A.FinalAssetClassAlt_Key = 1 ) A ) T ) A
       GROUP BY SourceAlt_Key,SourceName;
   --------------MetaGrid
   --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL as 'ENPA_D2K_NPA_DATE' 
   --INSERT INTO tt_temp1_68
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt
   --from ReverseFeedData A
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
   -- where B.SourceName='MetaGrid'
   -- And A.AssetSubClass='STD'
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   --  group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_MetaGrid_76') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_76 ';
   END IF;
   DELETE FROM tt_MetaGrid_76;
   UTILS.IDENTITY_RESET('tt_MetaGrid_76');

   INSERT INTO tt_MetaGrid_76 ( 
   	SELECT A.CustomerAcID ,
           A.RefCustomerID CustomerId  ,
           A.UCIF_ID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
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
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass <> 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ----------------
   INSERT INTO tt_temp1_68
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL ENPA_D2K_NPA_DATE  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MetaGrid'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -----------Added on 11/04/2022
              SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL ENPA_D2K_NPA_DATE  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM tt_MetaGrid_76 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceName );
   --------------Calypso
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
   INSERT INTO tt_temp1_68
     ( SELECT 7 SourceAlt_Key  ,
              'Calypso' SourceName  ,
              COUNT(*)  
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
                 AND A.InitialAssetAlt_key <> 1 );
   --select * from tt_temp1_68
   --select * 
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF a
          JOIN tt_temp1_68 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Upgrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END
                                 = src.CNT;
   UPDATE StatusReport_RF
      SET Upgrade = 0
    WHERE  Upgrade IS NULL;--update StatusReport
   --set    Upgrade_Status= case when isnull(Upgrade_ACL,0)=isnull(Upgrade_RF,0) then 'True' else 'False' END

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_RERF_NEWLOGIC" TO "ADF_CDR_RBL_STGDB";
