--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --Declare @TimeKey as Int=26460     
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey=@TimeKey)       
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );

BEGIN

   --Declare @TimeKey AS INT =26298            
   IF utils.object_id('tempdb..tt_temp1_67') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_67 ';
   END IF;
   DELETE FROM tt_temp1_67;
   --------------Finacle            

   --INSERT INTO tt_temp1_67            

   ----Select  'FinacleUpgrade' AS TableName, AccountID +'|'+Convert(Varchar(10),UpgradeDate,105) as DataUtility              

   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A            

   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

   -- where B.SourceName='Finacle'            

   -- And A.AssetSubClass='STD'            

   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

   -- group by a.SourceAlt_Key,a.SourceSystemName            

   -- IF OBJECT_ID('TempDB..tt_Finacle_73') Is Not Null            

   --Drop Table tt_Finacle_73            
   IF utils.object_id('TempDB..tt_Finacle_73') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_73 ';
   END IF;
   DELETE FROM tt_Finacle_73;
   UTILS.IDENTITY_RESET('tt_Finacle_73');

   INSERT INTO tt_Finacle_73 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           Z.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           SourceName 
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
     FROM tt_Finacle_73 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_67
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select  'FinacleUpgrade' AS TableName, AccountID +'|'+Convert(Varchar(10),UpgradeDate,105) as DataUtility,a.SourceAlt_Key,a.SourceSystemName            

              --from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              -- where B.SourceName='Finacle'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              -------------Added on 04/04/2022            

              --UNION            
              SELECT DISTINCT 'FinacleUpgrade' TableName  ,
                              CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),10,p_style=>105) DataUtility  ,
                              SourceAlt_Key ,
                              SourceName 
              FROM tt_Finacle_73 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) 
            --Select  'FinacleUpgrade' AS TableName, CustomerAcID +'|'+Convert(Varchar(10),isnull(UpgDate,@date),105) as DataUtility,SourceAlt_Key,SourceName            

            --from Finacle_Upg_RERF A            

            --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1            
            A
         GROUP BY SourceAlt_Key,SourceName );
   --------------Ganaseva            
   --Select 'GanasevaUpgrade' AS TableName, AccountID +'|'+'0'+'|'+Convert(Varchar(10),UpgradeDate,103)+'|'+'19718'+'|'+'19718' as DataUtility            
   --INSERT INTO tt_temp1_67            
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A            
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            
   -- where B.SourceName='Ganaseva'   -- And A.AssetSubClass='STD'            
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            
   -- group by a.SourceAlt_Key,a.SourceSystemName            
   --IF OBJECT_ID('TempDB..tt_Ganaseva_65') Is Not Null            
   --  Drop Table tt_Ganaseva_65            
   IF utils.object_id('TempDB..tt_Ganaseva_65') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_65 ';
   END IF;
   DELETE FROM tt_Ganaseva_65;
   UTILS.IDENTITY_RESET('tt_Ganaseva_65');

   INSERT INTO tt_Ganaseva_65 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           Z.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           SourceName 
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
     FROM tt_Ganaseva_65 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   ---------------- 
   ----------------            
   INSERT INTO tt_temp1_67
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select 'GanasevaUpgrade' AS TableName, AccountID +'|'+'0'+'|'+Convert(Varchar(10),UpgradeDate,103)+'|'+'19718'+'|'+'19718' as DataUtility            

              --,a.SourceAlt_Key,a.SourceSystemName            

              --from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              -- where B.SourceName='Ganaseva'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              --------------Added on 04/04/2022            

              --UNION            

              --Select 'GanasevaUpgrade' AS TableName, CustomerAcID +'|'+'0'+'|'+Convert(Varchar(10),isnull(UpgDate,@date),103)+'|'+'19718'+'|'+'19718' as DataUtility            

              --,SourceAlt_Key,SourceName            

              --from Ganaseva_Upg_RERF A            

              --Where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1        
              SELECT DISTINCT 'GanasevaUpgrade' TableName  ,
                              CustomerID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                              SourceAlt_Key ,
                              SourceName 
              FROM tt_Ganaseva_65 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceName );
   ----------------VisionPlus            
   --  INSERT INTO tt_temp1_67            
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A            
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            
   -- where B.SourceName='VisionPlus'       
   -- And A.AssetSubClass='STD'            
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            
   -- group by a.SourceAlt_Key,a.SourceSystemName            
   -- IF OBJECT_ID('TempDB..tt_VisionPlus_35') Is Not Null              
   --Drop Table tt_VisionPlus_35              
   IF utils.object_id('TempDB..tt_VisionPlus_35') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_35 ';
   END IF;
   DELETE FROM tt_VisionPlus_35;
   UTILS.IDENTITY_RESET('tt_VisionPlus_35');

   INSERT INTO tt_VisionPlus_35 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           (CASE 
                 WHEN B.SourceAssetClass IS NULL
                   AND B.SourceNpaDate IS NULL THEN 'STD'
           ELSE B.SourceAssetClass
              END) SourceAssetClass  ,
           (CASE 
                 WHEN B.SourceAssetClass = 'STD'
                   AND B.SourceNpaDate IS NOT NULL THEN NULL
           ELSE B.SourceNpaDate
              END) SourceNpaDate  ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           A.SourceAlt_Key ,
           SourceName 
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
             LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.RefCustomerID = Z.RefCustomerID
   	 WHERE  DS.SourceName = 'VisionPlus'
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedDataInsertSync_Customer R
                                WHERE  A.RefCustomerID = R.CustomerID
                                         AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                         AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM DimProduct Y
                                WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                         AND Y.ProductCode = 'RBSNP'
                                         AND Y.EffectiveFromTimeKey <= v_TimeKey
                                         AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_VisionPlus_35 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_67
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --    Select 'VisionPlusDataList' as TableName, AccountID ,'       ' as NPADate,'Upgrade' [Type],a.SourceAlt_Key,a.SourceSystemName            

              -- from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              -- where B.SourceName='VisionPlus'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              -- UNION               
              SELECT DISTINCT 'VisionPlusDataList' TableName  ,
                              CustomerID ,
                              '       ' NPADate  ,
                              'Upgrade' Type  ,
                              SourceAlt_Key ,
                              SourceName 
              FROM tt_VisionPlus_35 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceName );
   --------------MiFin            
   --Select AccountID ,'STD',SubString(Replace(convert(varchar(20),UpgradeDate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),UpgradeDate,106),' ','-')),2)             
   --INSERT INTO tt_temp1_67            
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A            
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            
   -- where B.SourceName='MiFin'            
   -- And A.AssetSubClass='STD'            
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            
   -- group by a.SourceAlt_Key,a.SourceSystemName            
   --IF OBJECT_ID('TempDB..tt_MiFin_73') Is Not Null            
   --  Drop Table tt_MiFin_73            
   IF utils.object_id('TempDB..tt_MiFin_73') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_73 ';
   END IF;
   DELETE FROM tt_MiFin_73;
   UTILS.IDENTITY_RESET('tt_MiFin_73');

   INSERT INTO tt_MiFin_73 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           Z.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           A.SourceAlt_Key ,
           SourceName 
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
     FROM tt_MiFin_73 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   ----------------            
   INSERT INTO tt_temp1_67
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select AccountID ,'STD' ACLstatus,SubString(Replace(convert(varchar(20),UpgradeDate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),UpgradeDate,106),' ','-')),2)NPADate            

              --,a.SourceAlt_Key,a.SourceSystemName            

              --from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              -- where B.SourceName='MiFin'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              -- -----------Added on 11/04/2022            

              --  UNION            

              --Select CustomerAcid ,'STD' Assectclsee,SubString(Replace(convert(varchar(20),UpgDate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),

              --UpgDate,106),' ','-')),2) UpgDate            

              --,SourceAlt_Key,SourceName            

              --from MiFin_Upg_RERF A            

              --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1          
              SELECT DISTINCT CustomerID ,
                              'STD' Assetclass  ,
                              SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                              SourceAlt_Key ,
                              SourceName 
              FROM tt_MiFin_73 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceName );
   --------------Indus            
   --Select AccountID as 'Loan Account Number' ,'STD' as MAIN_STATUS_OF_ACCOUNT,'STD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),UpgradeDate,106),' ','-') as 'Value Date'             
   --INSERT INTO tt_temp1_67            
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A            
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            
   -- where B.SourceName='Indus'            
   -- And A.AssetSubClass='STD'            
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            
   --       group by a.SourceAlt_Key,a.SourceSystemName            
   --IF OBJECT_ID('TempDB..tt_Indus_73') Is Not Null            
   -- Drop Table tt_Indus_73            
   IF utils.object_id('TempDB..tt_Indus_73') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_73 ';
   END IF;
   DELETE FROM tt_Indus_73;
   UTILS.IDENTITY_RESET('tt_Indus_73');

   INSERT INTO tt_Indus_73 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           Z.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           SourceName 
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
     FROM tt_Indus_73 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   ----------------            
   INSERT INTO tt_temp1_67
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select AccountID as 'Loan Account Number' ,'STD' as MAIN_STATUS_OF_ACCOUNT,'STD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),UpgradeDate,106),' ','-') as 'Value Date',a.SourceAlt_Key,a.SourceSystemName            

              --from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              -- where B.SourceName='Indus'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              -- -----------Added on 11/04/2022            

              -- UNION            

              --Select CustomerAcid as 'Loan Account Number' ,'STD' as MAIN_STATUS_OF_ACCOUNT,'STD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),UpgDate,106),' ','-') as 'Value Date',SourceAlt_Key,SourceName            

              --from Indus_Upg_RERF A            

              --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1    
              SELECT DISTINCT Customerid Loan_Account_Number  ,
                              'STD' MAIN_STATUS_OF_ACCOUNT  ,
                              'STD' SUB_STATUS_OF_ACCOUNT  ,
                              'CN01' REASON_CODE  ,
                              REPLACE(UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_Date),20,p_style=>106), ' ', '-') Value_Date  ,
                              SourceAlt_Key ,
                              SourceName 
              FROM tt_Indus_73 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceName );
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
   --INSERT INTO tt_temp1_67            
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
   --IF OBJECT_ID('TempDB..tt_ECBF_75') Is Not Null            
   --  Drop Table tt_ECBF_75            
   IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD_30') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD_30 ';
   END IF;
   DELETE FROM tt_ACCOUNTCAL_DPD_30;
   UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD_30');

   INSERT INTO tt_ACCOUNTCAL_DPD_30 ( 
   	SELECT CustomerEntityID ,
           MAX(DPD_Max)  DPD_Max  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	  GROUP BY CustomerEntityID );
   IF utils.object_id('TempDB..tt_ECBF_75') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_75 ';
   END IF;
   DELETE FROM tt_ECBF_75;
   UTILS.IDENTITY_RESET('tt_ECBF_75');

   INSERT INTO tt_ECBF_75 ( 
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
           CurrentDate ,
           a.SourceAlt_Key ,
           SourceName 
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
                    v_Date CurrentDate  ,
                    a.SourceAlt_Key ,
                    SourceName 
             FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                    JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
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
                    LEFT JOIN tt_ACCOUNTCAL_DPD_30 AD   ON AD.CustomerEntityID = A.CustomerEntityID
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
   	  GROUP BY CustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,a.SourceAlt_Key,SourceName );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_ECBF_75 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_67
     SELECT SourceAlt_Key ,
            SourceName ,
            COUNT(*)  CNT  
       FROM ( 
              --Select             

              --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification            

              --,UserSubClassification,NpaDate,CurrentDate,SourceAlt_Key,SourceName            

              -- from (            

              --Select             

              --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,            

              --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification            

              --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,SourceAlt_Key,SourceName            

              --from (            

              --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification            

              --,A.DPD as DPD,E.AssetClassGroup as UserClassification,            

              --(Case When A.DPD=0 Then 'DPD0' When A.DPD BETWEEN 1 AND 30 Then 'DPD30' When A.DPD BETWEEN 31 AND 60 Then 'DPD60'             

              --When A.DPD BETWEEN 61 AND 90 Then 'DPD90' When A.DPD BETWEEN 91 AND 180 Then 'DPD180' When A.DPD BETWEEN 181 AND 365 Then 'PD1YR' END )            

              -- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate,            

              -- b.SourceAlt_Key,b.SourceName            

              --  from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode            

              --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey            

              ----Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID            

              -- where B.SourceName='ECBF'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              -- Group By             

              -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode             

              --,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105),b.SourceAlt_Key,b.SourceName            

              --)A            

              --)T            

              --------------Added on 04/04/2022            

              --UNION            
              SELECT DISTINCT SrNo ,
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
                            A.SourceAlt_Key ,
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
                                   A.SourceAlt_Key ,
                                   SourceName 
                            FROM tt_ECBF_75 A
                             WHERE  A.BankAssetClass > 1
                                      AND A.FinalAssetClassAlt_Key = 1 ) A ) T ) A
       GROUP BY SourceAlt_Key,SourceName;
   --------------MetaGrid            
   --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL as 'ENPA_D2K_NPA_DATE'             
   --INSERT INTO tt_temp1_67            
   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt            
   --from ReverseFeedData A            
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            
   -- where B.SourceName='MetaGrid'            
   -- And A.AssetSubClass='STD'            
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            
   --  group by a.SourceAlt_Key,a.SourceSystemName            
   --IF OBJECT_ID('TempDB..tt_MetaGrid_75') Is Not Null            
   -- Drop Table tt_MetaGrid_75            
   IF utils.object_id('TempDB..tt_MetaGrid_75') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_75 ';
   END IF;
   DELETE FROM tt_MetaGrid_75;
   UTILS.IDENTITY_RESET('tt_MetaGrid_75');

   INSERT INTO tt_MetaGrid_75 ( 
   	SELECT A.RefCustomerID ,
           A.RefCustomerID CustomerId  ,
           Z.UCIF_ID ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           Z.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           SourceName 
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
     FROM tt_MetaGrid_75 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   ----------------            
   INSERT INTO tt_temp1_67
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL as 'ENPA_D2K_NPA_DATE',a.SourceAlt_Key,SourceName            

              --from ReverseFeedData A            

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key            

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey            

              -- where B.SourceName='MetaGrid'            

              -- And A.AssetSubClass='STD'            

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey            

              -----------Added on 11/04/2022            

              --UNION            
              SELECT DISTINCT A.CustomerID CIF_ID  ,
                              A.UCIF_ID UCIC  ,
                              NULL ENPA_D2K_NPA_DATE  ,
                              SourceAlt_Key ,
                              SourceName 
              FROM tt_MetaGrid_75 A
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
   INSERT INTO tt_temp1_67
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
   --select * from tt_temp1_67            
   --select *             
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_Only_RERF_Customer a
          JOIN tt_temp1_67 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Upgrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END            
                                 = src.CNT;
   UPDATE StatusReport_Only_RERF_Customer
      SET Upgrade = 0
    WHERE  Upgrade IS NULL;--update StatusReport            
   --set    Upgrade_Status= case when isnull(Upgrade_ACL,0)=isnull(Upgrade_RF,0) then 'True' else 'False' END            

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_ONLY_RERF_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
