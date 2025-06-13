--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   -- Declare @TimeKey as Int=26460  
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey=@TimeKey)     
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );

BEGIN

   IF utils.object_id('tempdb..tt_temp2_42') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_42
    --=================================================Finacle==========================================================================          
     --------------Finacle          
     --Select  'FinacleDegrade' AS TableName, AccountID +'|'+           
     --Case When ISNULL(A.NPADate,'1900-01-01')<ISNULL(C.AcOpenDt,'1900-01-01') Then  Convert(Varchar(10),C.AcOpenDt,105)  Else          
     --  Convert(Varchar(10),NPADate,105) End  as DataUtility           
     --  IF OBJECT_ID('TempDB..#Finacle') Is Not Null          
     --Drop Table #Finacle          
     ';
   END IF;
   DELETE FROM tt_temp2_42;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE Finacle_Deg_RERF ';
   INSERT INTO Finacle_Deg_RERF
     ( SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  ,
              ds.SourceAlt_Key ,
              ds.SourceName 

       --  INto #Finacle          
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
     FROM Finacle_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   --==============================================================          
   --INSERT INTO tt_temp2_42          
   --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   --  from ReverseFeedData A        --- As per Bank Revised mail on 05-01-2022            
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   --Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID          
   --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='Finacle'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   -- group by a.SourceAlt_Key,a.SourceSystemName          
   INSERT INTO tt_temp2_42
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( 
              --Select 'FinacleDegrade' AS TableName, AccountID +'|'+          

              --Case When ISNULL(NPADate,'1900-01-01')<ISNULL(AcOpenDt,'1900-01-01')          

              --Then Convert(Varchar(10),AcOpenDt,105)+'|'+ Convert(Varchar(10),NPADate,105) Else          

              --Convert(Varchar(10),NPADate,105)+'|' End as DataUtility,b.SourceAlt_Key,b.SourceName          

              --from ReverseFeedData A          

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              --Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID          

              --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey          

              --where B.SourceName='Finacle'          

              --And A.AssetSubClass<>'STD'          

              --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey           

              --union          
              SELECT 'FinacleDegrade' TableName  ,
                     customeracid || '|' || UTILS.CONVERT_TO_VARCHAR2(a.FinalNpaDt,10,p_style=>105) || '|' DataUtility  ,
                     b.SourceAlt_Key ,
                     SourceName 
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
                        AND A.EffectiveFromTimekey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -------Added on 04/04/2022          
              SELECT 'FinacleDegrade' TableName  ,
                     CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM Finacle_Deg_RERF A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022          
              SELECT 'FinacleDegrade' TableName  ,
                     CustomerAcID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM Finacle_Deg_RERF A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) 
            ----------------          
            A
         GROUP BY SourceAlt_Key,SourceName );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE Ganaseva_Deg_RERF ';
   INSERT INTO Ganaseva_Deg_RERF
     ( SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  ,
              ds.SourceAlt_Key ,
              ds.SourceName 

       --INto Ganaseva_Deg_RERF          
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
     FROM Ganaseva_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   ----------------     
   INSERT INTO tt_temp2_42
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( 
              -- Select 'GanasevaDegrade' AS TableName, AccountID +'|'+'1'+'|'+Convert(Varchar(10),NPADate,103)+'|'+'19718'+'|'+'19718' as DataUtility,a.SourceAlt_Key,          

              -- a.SourceSystemName          

              -- from ReverseFeedData A          

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              -- where B.SourceName='Ganaseva'          

              -- And A.AssetSubClass<>'STD'          

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              --  ------Changes for NPADate on 22/04/2022          

              -- union          
              SELECT 'GanasevaDegrade' TableName  ,
                     CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     a.SourceAlt_Key ,
                     b.SourceName 
              FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
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
                     CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM Ganaseva_Deg_RERF A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022          
              SELECT 'GanasevaDegrade' TableName  ,
                     CustomerAcID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM Ganaseva_Deg_RERF A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) A
         GROUP BY SourceAlt_Key,SourceName );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE VisionPlus_Deg_RERF ';
   INSERT INTO VisionPlus_Deg_RERF
     ( SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  ,
              ds.SourceAlt_Key ,
              ds.SourceName 

       --INto #VisionPlus            
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
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM VisionPlus_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   INSERT INTO tt_temp2_42
     ( 
       --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
       SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( 
              --Select 'VisionPlusDataList' as TableName, AccountID ,CONVERT(varchar,NPADate,103) as NPADate,'Degrade' [Type] ,a.SourceAlt_Key,a.SourceSystemName          

              --from ReverseFeedData A          

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              -- where B.SourceName='VisionPlus'          

              -- And A.AssetSubClass<>'STD'          

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              -- UNION           

              -- Select 'VisionPlusDataList' as TableName, AccountID ,'       ' as NPADate,'Upgrade' [Type],a.SourceAlt_Key,a.SourceSystemName          

              -- from ReverseFeedData A          

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              -- where B.SourceName='VisionPlus'          

              -- And A.AssetSubClass='STD'          

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              -----------Added on 04/04/2022            

              --UNION            
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerAcID ,
                     UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM VisionPlus_Deg_RERF A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              --UNION             

              --Select 'VisionPlusDataList' as TableName, CustomerAcID ,'       ' as NPADate,'Upgrade' [Type],a.SourceAlt_Key,a.SourceName          

              --from #VisionPlus A            

              --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1            
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerAcID ,
                     UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM VisionPlus_Deg_RERF A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) C
         GROUP BY SourceAlt_Key,SourceName );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE MiFin_Deg_RERF ';
   INSERT INTO MiFin_Deg_RERF
     ( SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  ,
              ds.SourceAlt_Key ,
              ds.SourceName 

       --INto #MiFin          
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
     FROM MiFin_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   INSERT INTO tt_temp2_42
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select AccountID ,'NPA'ACLStatus,SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2)NPADate          

              --,a.SourceAlt_Key,a.SourceSystemName          

              --from ReverseFeedData A          

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              -- where B.SourceName='MiFin'          

              -- And A.AssetSubClass<>'STD'          

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              ------Changes for NPADate on 22/04/2022          

              --union          
              SELECT CustomerAcID ,
                     'NPA' Assetclass  ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                     b.SourceAlt_Key ,
                     b.SourceName 
              FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
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
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM MiFin_Deg_RERF A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022          
              SELECT CustomerAcID ,
                     'NPA' ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNPADt,20,p_style=>106), ' ', '-')), -2, 2) ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM MiFin_Deg_RERF A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) D
         GROUP BY SourceAlt_Key,SourceName );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE Indus_Deg_RERF ';
   INSERT INTO Indus_Deg_RERF
     ( SELECT A.CustomerAcID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  ,
              ds.SourceAlt_Key ,
              ds.SourceName 

       --INto #Indus          
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
     FROM Indus_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   INSERT INTO tt_temp2_42
     ( 
       --      select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
       SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              --Select AccountID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),NPADate,106),' ','-') as 'Value Date' ,a.SourceAlt_Key,a.SourceSystemName          

              --from ReverseFeedData A          

              -- Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              -- And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              --  where B.SourceName='Indus'          

              --  And A.AssetSubClass<>'STD'          

              --  AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              ------Changes for NPADate on 22/04/2022          

              --union          
              SELECT CustomerAcID Loan_Account_Number  ,
                     'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                     'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  ,
                     b.SourceAlt_Key ,
                     b.SourceName 
              FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
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
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM Indus_Deg_RERF A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022          
              SELECT CustomerAcID Loan_Account_Number  ,
                     'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                     'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM Indus_Deg_RERF A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) E
         GROUP BY SourceAlt_Key,SourceName );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE ECBF_Deg_RERF ';
   INSERT INTO ECBF_Deg_RERF
     ( SELECT CustomerAcID ,
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

       --Into #ECBF          
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
         GROUP BY CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,SourceAlt_Key,SourceName );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM ECBF_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   INSERT INTO tt_temp2_42
     SELECT SourceAlt_Key ,
            SourceName ,
            COUNT(*)  CNT  
       FROM ( 
              --  Select           

              --  SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification          

              --  ,UserSubClassification,NpaDate,CurrentDate,SourceAlt_Key,SourceSystemName          

              --   from (          

              --  Select           

              --  ROW_NUMBER()Over(Order By ClientCustId)as SrNo,          

              --  ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification          

              --  , DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,SourceAlt_Key,SourceSystemName          

              --  from (          

              --  Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,          

              --  Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02'           

              --  When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification          

              --  ,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate,a.SourceAlt_Key,a.SourceSystemName          

              --    from ReverseFeedData A          

              --  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --  And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              --  Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode          

              --  And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey          

              --   where B.SourceName='ECBF'          

              --   And A.AssetSubClass<>'STD'          

              --   AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              --Group By           

              --   A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode           

              --  ,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105),a.SourceAlt_Key,a.SourceSystemName          

              --  )A          

              --  )T          

              --  Union          
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
     v_Date CurrentDate  ,
     b.SourceAlt_Key ,
     b.SourceName 
                            FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                                   JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimProduct D   ON D.ProductAlt_Key = A.ProductAlt_Key
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                             WHERE  B.SourceName = 'ECBF'
                                      AND A.InitialAssetClassAlt_Key > 1
                                      AND A.FinalAssetClassAlt_Key > 1
                                      AND NVL(A.InitialNpaDt, ' ') <> NVL(A.FinalNpaDt, ' ')
                                      AND A.EffectiveFromTimekey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                              GROUP BY D.ProductName,C.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD_Max,UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105),b.SourceAlt_Key,b.SourceName ) 
                          --,Convert(Varchar(10),@Date,105),SourceAlt_Key,SourceName          
                          A ) T
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
                            FROM ECBF_Deg_RERF A
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
                            FROM ECBF_Deg_RERF A
                             WHERE  A.BankAssetClass > 1
                                      AND A.FinalAssetClassAlt_Key > 1
                                      AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) A ) T ) F
       GROUP BY SourceAlt_Key,SourceName;
   ----------------          
   --=================================================Finacle END==========================================================================          
   --=================================================Ganaseva==========================================================================          
   --===================================================================================================================          
   --   INSERT INTO tt_temp2_42          
   --   select SourceAlt_Key,SourceSystemName,sum(cnt) cnt from (          
   --Select  a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   --from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   --Inner JOIN Pro.AccountCal_Hist C ON A.AccountID=C.CustomerAcID          
   --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey          
   --where B.SourceName='Finacle'          
   --And A.AssetSubClass<>'STD'          
   --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey           
   --group by a.SourceAlt_Key,a.SourceSystemName          
   --union          
   ----select * from DIMSOURCEDB          
   --Select a.SourceAlt_Key,b.SourceName,count(*) cnt          
   -- from Pro.AccountCal_hist A wITH (NOLOCK)          
   --   Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --   And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey          
   --   Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key          
   --   And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey          
   --    where B.SourceName='Finacle'          
   --    And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1           
   --    ANd  A.InitialNpaDt<>A.FinalNpaDt               
   --    AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   --    group by a.SourceAlt_Key,b.SourceName          
   --)A Group by SourceAlt_Key,SourceSystemName          
   --====================================================================================================================          
   --------------Ganaseva          
   --Select 'GanasevaDegrade' AS TableName, AccountID +'|'+'1'+'|'+Convert(Varchar(10),NPADate,103)+'|'+'19718'+'|'+'19718' as DataUtility           
   --   INSERT INTO tt_temp2_42          
   --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   -- from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='Ganaseva'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   --  group by a.SourceAlt_Key,a.SourceSystemName          
   -- IF OBJECT_ID('TempDB..#Ganaseva') Is Not Null          
   --Drop Table #Ganaseva          
   --=================================================Ganaseva END==========================================================================          
   --=================================================Vision Plus==========================================================================          
   ----------------VisionPlus          
   --  INSERT INTO tt_temp2_42          
   --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   -- from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='VisionPlus'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   --  group by a.SourceAlt_Key,a.SourceSystemName          
   --  IF OBJECT_ID('TempDB..#VisionPlus') Is Not Null            
   --Drop Table #VisionPlus            
   --=================================================Vision Plus END==========================================================================          
   --=================================================Mifin==========================================================================          
   --------------mifin          
   --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2)           
   --INSERT INTO tt_temp2_42          
   --   select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   --from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='MiFin'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   --  group by a.SourceAlt_Key,a.SourceSystemName          
   --IF OBJECT_ID('TempDB..#MiFin') Is Not Null          
   --Drop Table #MiFin          
   --=================================================Minfin END==========================================================================          
   --=================================================Indus==========================================================================          
   --------------Indus          
   --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2) from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='MiFin'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   --Select AccountID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),NPADate,106),' ','-') as 'Value Date'           
   --   INSERT INTO tt_temp2_42          
   --      select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   --   from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='Indus'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   -- group by a.SourceAlt_Key,a.SourceSystemName          
   --IF OBJECT_ID('TempDB..#Indus') Is Not Null          
   --Drop Table #Indus          
   --=================================================Indus END==========================================================================          
   --=================================================ECBF==========================================================================          
   --------------ECBF          
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
   --Select           
   --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification          
   --,UserSubClassification,NpaDate,CurrentDate          
   -- from (          
   --Select           
   --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,          
   --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification          
   --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate          
   --from (          
   --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,          
   --Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02'           
   --When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification          
   --,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate          
   --INSERT INTO tt_temp2_42          
   --   select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   --from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode          
   --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='ECBF'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey        -- group by a.SourceAlt_Key,a.SourceSystemName          
   -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode           
   --,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)     
   --)A          
   --)T          
   --IF OBJECT_ID('TempDB..#ECBF') Is Not Null          
   -- Drop Table #ECBF          
   --=================================================ECBF END ==========================================================================          
   --=================================================Metagrid==========================================================================          
   ---------MetaGrid          
   --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),NpaDate,105),'-','') as 'ENPA_D2K_NPA_DATE'           
   --   INSERT INTO tt_temp2_42          
   --      select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt          
   --from ReverseFeedData A          
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          
   -- where B.SourceName='MetaGrid'          
   -- And A.AssetSubClass<>'STD'          
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          
   -- group by a.SourceAlt_Key,a.SourceSystemName          
   --IF OBJECT_ID('TempDB..#MetaGrid') Is Not Null          
   --Drop Table #MetaGrid          
   EXECUTE IMMEDIATE ' TRUNCATE TABLE MetaGrid_Deg_RERF ';
   INSERT INTO MetaGrid_Deg_RERF
     ( SELECT A.CustomerAcID ,
              A.RefCustomerID CustomerId  ,
              A.UCIF_ID ,
              A.FinalAssetClassAlt_Key ,
              A.FinalNpaDt ,
              B.SourceAssetClass ,
              B.SourceNpaDate ,
              DA.AssetClassAlt_Key BankAssetClass  ,
              ds.SourceAlt_Key ,
              ds.SourceName 

       --INto #MetaGrid          
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
     FROM MetaGrid_Deg_RERF a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   INSERT INTO tt_temp2_42
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( 
              -- Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),NpaDate,105),'-','') as 'ENPA_D2K_NPA_DATE'          

              -- ,a.SourceAlt_Key,a.SourceSystemName          

              -- from ReverseFeedData A          

              --  Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key          

              --  And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey          

              --   where B.SourceName='MetaGrid'          

              --   And A.AssetSubClass<>'STD'          

              --   AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey          

              --------Changes for NPADate on 22/04/2022          

              --  union          
              SELECT A.RefCustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     b.SourceAlt_Key ,
                     b.SourceName 
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
              SELECT A.CustomerId CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM MetaGrid_Deg_RERF A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022          
              SELECT A.CustomerId CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM MetaGrid_Deg_RERF A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) G
         GROUP BY SourceAlt_Key,SourceName );
   --=================================================Metagrid END==========================================================================          
   --=================================================Calypso==========================================================================          
   ---------Calypso          
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
   INSERT INTO tt_temp2_42
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
                 AND A.FinalAssetClassAlt_Key <> 1
                 AND A.InitialAssetAlt_key = 1 );
   --=================================================Calypso END==========================================================================          
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_Only_RERF a
          JOIN tt_temp2_42 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Degrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END          
                                 = src.CNT;
   UPDATE StatusReport_Only_RERF
      SET Degrade = 0
    WHERE  Degrade IS NULL;--update StatusReport_RF          
   --set    Degrade_Status= case when isnull(Degrade_ACL,0)=isnull(Degrade_RF,0) then 'True' else 'False' END       

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_ONLY_RERF" TO "ADF_CDR_RBL_STGDB";
