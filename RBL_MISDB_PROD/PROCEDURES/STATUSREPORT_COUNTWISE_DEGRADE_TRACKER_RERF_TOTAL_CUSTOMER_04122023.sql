--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --Declare @TimeKey AS INT=26460
   --Declare @Date as Date =(Select Date from Automate_Advances Where Timekey=@TimeKey)
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );

BEGIN

   IF utils.object_id('tempdb..tt_temp2_38') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_38 ';
   END IF;
   DELETE FROM tt_temp2_38;
   --=================================================Finacle==========================================================================    

   --------------Finacle    

   --Select  'FinacleDegrade' AS TableName, AccountID +'|'+     

   --Case When ISNULL(A.NPADate,'1900-01-01')<ISNULL(C.AcOpenDt,'1900-01-01') Then  Convert(Varchar(10),C.AcOpenDt,105)  Else    

   --  Convert(Varchar(10),NPADate,105) End  as DataUtility     
    /*   
        IF OBJECT_ID('TempDB..tt_Finacle_62') Is Not Null    
      Drop Table tt_Finacle_62    

      Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,    
      DA.AssetClassAlt_Key BankAssetClass,ds.SourceAlt_Key,ds.SourceName    
        INto tt_Finacle_62    
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
   			from          tt_Finacle_62 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date

   */

   --==============================================================    

   --INSERT INTO tt_temp2_38    

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
   IF utils.object_id('TempDB..tt_Finacle_62') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_62 ';
   END IF;
   DELETE FROM tt_Finacle_62;
   UTILS.IDENTITY_RESET('tt_Finacle_62');

   INSERT INTO tt_Finacle_62 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
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
     FROM tt_Finacle_62 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT 'FinacleDegrade' TableName  ,
                     CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(c.SysNPA_Dt,10,p_style=>105) || '|' DataUtility  ,
                     A.SourceAlt_Key ,
                     SourceName 
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
                     RefCustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(a.SysNPA_Dt,10,p_style=>105) || '|' DataUtility  ,
                     a.SourceAlt_Key ,
                     SourceName 
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
                        AND A.EffectiveFromTimekey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              ---------Added on 04/04/2022
              SELECT 'FinacleDegrade' TableName  ,
                     CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalAssetClassAlt_Key,10,p_style=>105) || '|' DataUtility  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_Finacle_62 A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT 'FinacleDegrade' TableName  ,
                     CustomerID || '|' || UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,10,p_style=>105) || '|' DataUtility  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_Finacle_62 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNPADate, ' ')
                        OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) 
            ----------------    
            A
         GROUP BY SourceAlt_Key,SourceName );
   ----------------    
   --=================================================Finacle END==========================================================================    
   --=================================================Ganaseva==========================================================================    
   --===================================================================================================================    
   --   INSERT INTO tt_temp2_38    
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
   --   INSERT INTO tt_temp2_38    
   --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
   -- from ReverseFeedData A    
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   -- where B.SourceName='Ganaseva'    
   -- And A.AssetSubClass<>'STD'    
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   --  group by a.SourceAlt_Key,a.SourceSystemName    
   /*
       IF OBJECT_ID('TempDB..tt_Ganaseva_52') Is Not Null    
      Drop Table tt_Ganaseva_52    

      Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,    
      DA.AssetClassAlt_Key BankAssetClass,ds.SourceAlt_Key,ds.SourceName    
        INto tt_Ganaseva_52    
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
   			from          tt_Ganaseva_52 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date
        */
   ----------------    
   IF utils.object_id('TempDB..tt_Ganaseva_52') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_52 ';
   END IF;
   DELETE FROM tt_Ganaseva_52;
   UTILS.IDENTITY_RESET('tt_Ganaseva_52');

   INSERT INTO tt_Ganaseva_52 ( 
   	SELECT A.RefCustomerID ,
           A.SrcAssetClassAlt_Key ,
           A.SrcNPA_Dt ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           a.SysAssetClassAlt_Key ,
           a.SysNPA_Dt ,
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
     FROM tt_Ganaseva_52 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT 'GanasevaDegrade' TableName  ,
                     CustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Ganaseva'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              ------Changes for NPADate on 22/04/2022
              SELECT 'GanasevaDegrade' TableName  ,
                     RefCustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
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
                     refCustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_Ganaseva_52 A
               WHERE  A.BankAssetClass = 1
                        AND A.SysAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT 'GanasevaDegrade' TableName  ,
                     RefCustomerID || '|' || '1' || '|' || UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_Ganaseva_52 A
               WHERE  A.BankAssetClass > 1
                        AND A.SysAssetClassAlt_Key > 1
                        AND ( NVL(A.SourceNpaDate, ' ') <> NVL(A.SysNPA_Dt, ' ')
                        OR ( A.BankAssetClass <> A.SysAssetClassAlt_Key ) ) ) A
         GROUP BY SourceAlt_Key,SourceName );
   --=================================================Ganaseva END==========================================================================    
   --=================================================Vision Plus==========================================================================    
   ----------------VisionPlus    
   --  INSERT INTO tt_temp2_38    
   --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
   -- from ReverseFeedData A    
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   -- where B.SourceName='VisionPlus'    
   -- And A.AssetSubClass<>'STD'    
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   --  group by a.SourceAlt_Key,a.SourceSystemName    
   /*  
     IF OBJECT_ID('TempDB..tt_VisionPlus_21') Is Not Null      
   Drop Table tt_VisionPlus_21      

   Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,      
   DA.AssetClassAlt_Key BankAssetClass ,ds.SourceAlt_Key,ds.SourceName    
     INto tt_VisionPlus_21      
    from Pro.ACCOUNTCAL A      
   Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID      
   ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey      
   Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key      
   ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey      
   Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key      
      ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey      
   Where DS.SourceName='VisionPlus'    
   ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID    
      And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')    
      And R.ProcessDate=@PreviousDate)    
      AND NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and     
      Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)    


      	Delete        a
   			from          tt_VisionPlus_21 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date
       */
   IF utils.object_id('TempDB..tt_VisionPlus_21') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_21 ';
   END IF;
   DELETE FROM tt_VisionPlus_21;
   UTILS.IDENTITY_RESET('tt_VisionPlus_21');

   INSERT INTO tt_VisionPlus_21 ( 
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
     FROM tt_VisionPlus_21 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
     ( 
       --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
       SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT 'VisionPlusDataList' TableName  ,
                     AccountID ,
                     UTILS.CONVERT_TO_VARCHAR2(NPADate,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'VisionPlus'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -- UNION 

              -- Select 'VisionPlusDataList' as TableName, AccountID ,'       ' as NPADate,'Upgrade' [Type] from ReverseFeedData A

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

              -- where B.SourceName='VisionPlus'

              -- And A.AssetSubClass='STD'

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

              -----------Added on 04/04/2022  
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerID ,
                     UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_VisionPlus_21 A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              --Select 'VisionPlusDataList' as TableName, CustomerID ,'       ' as NPADate,'Upgrade' [Type] from tt_VisionPlus_21 A  

              --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1  

              --UNION
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerID ,
                     UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_VisionPlus_21 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                        OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) C
         GROUP BY SourceAlt_Key,SourceName );
   --=================================================Vision Plus END==========================================================================    
   --=================================================Mifin==========================================================================    
   --------------mifin    
   --Select AccountID ,'NPA',SubString(Replace(convert(varchar(20),NPADate,106),' ','-'),1,7) + Right(Year(Replace(convert(varchar(20),NPADate,106),' ','-')),2)     
   --INSERT INTO tt_temp2_38    
   --   select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
   --from ReverseFeedData A    
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   -- where B.SourceName='MiFin'    
   -- And A.AssetSubClass<>'STD'    
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   --  group by a.SourceAlt_Key,a.SourceSystemName    
   /*
      IF OBJECT_ID('TempDB..tt_MiFin_62') Is Not Null    
      Drop Table tt_MiFin_62    

      Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,    
      DA.AssetClassAlt_Key BankAssetClass,ds.SourceAlt_Key,ds.SourceName    
        INto tt_MiFin_62    
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
   			from          tt_MiFin_62 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date
      */
   IF utils.object_id('TempDB..tt_MiFin_62') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_62 ';
   END IF;
   DELETE FROM tt_MiFin_62;
   UTILS.IDENTITY_RESET('tt_MiFin_62');

   INSERT INTO tt_MiFin_62 ( 
   	SELECT A.RefCustomerID ,
           A.SysAssetClassAlt_Key ,
           A.SysNPA_Dt ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           SourceName 
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
     FROM tt_MiFin_62 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( SELECT CustomerID ,
                     'NPA' AssetClass  ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MiFin'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              ------Changes for NPADate on 22/04/2022
              SELECT RefCustomerID ,
                     'NPA' Assetclass  ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Mifin'
                        AND A.SrcAssetClassAlt_Key > 1
                        AND A.SysAssetClassAlt_Key > 1
                        AND NVL(A.SrcNPA_Dt, ' ') <> NVL(A.SysNPA_Dt, ' ')
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -----------Added on 11/04/2022
              SELECT RefCustomerID ,
                     'NPA' Assetclass  ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_MiFin_62 A
               WHERE  A.BankAssetClass = 1
                        AND A.SysAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT RefCustomerID ,
                     'NPA' Assetclass  ,
                     SUBSTR(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-'), 1, 7) || SUBSTR(utils.year_(REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-')), -2, 2) NPADate  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_MiFin_62 A
               WHERE  A.BankAssetClass > 1
                        AND A.SysAssetClassAlt_Key > 1
                        AND ( NVL(A.SysNPA_Dt, ' ') <> NVL(A.SourceNPADate, ' ')
                        OR ( A.BankAssetClass <> A.SysAssetClassAlt_Key ) ) ) D
         GROUP BY SourceAlt_Key,SourceName );
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
   --   INSERT INTO tt_temp2_38    
   --      select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
   --   from ReverseFeedData A    
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   -- where B.SourceName='Indus'    
   -- And A.AssetSubClass<>'STD'    
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   -- group by a.SourceAlt_Key,a.SourceSystemName    
   /*  
      IF OBJECT_ID('TempDB..tt_Indus_62') Is Not Null    
      Drop Table tt_Indus_62    

      Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,    
      DA.AssetClassAlt_Key BankAssetClass,ds.SourceAlt_Key,ds.SourceName    
        INto tt_Indus_62    
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
   			from          tt_Indus_62 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date

       */
   IF utils.object_id('TempDB..tt_Indus_62') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_62 ';
   END IF;
   DELETE FROM tt_Indus_62;
   UTILS.IDENTITY_RESET('tt_Indus_62');

   INSERT INTO tt_Indus_62 ( 
   	SELECT A.RefCustomerID ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
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
     FROM tt_Indus_62 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
     ( 
       --      select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
       SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( SELECT AccountID Loan_Account_Number  ,
                     'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                     'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(NPADate,20,p_style=>106), ' ', '-') Value_Date  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Indus'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              ------Changes for NPADate on 22/04/2022
              SELECT RefCustomerID Loan_Account_Number  ,
                     'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                     'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(SysNPA_Dt,20,p_style=>106), ' ', '-') Value_Date  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
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
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_Indus_62 A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT RefCustomerID Loan_Account_Number  ,
                     'SBSTD' MAIN_STATUS_OF_ACCOUNT  ,
                     'SBSTD' SUB_STATUS_OF_ACCOUNT  ,
                     'CN01' REASON_CODE  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>106), ' ', '-') Value_Date  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_Indus_62 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                        OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) E
         GROUP BY SourceAlt_Key,SourceName );
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
   --INSERT INTO tt_temp2_38    
   --   select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
   --from ReverseFeedData A    
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode    
   --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey    
   -- where B.SourceName='ECBF'    
   -- And A.AssetSubClass<>'STD'    
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   -- group by a.SourceAlt_Key,a.SourceSystemName    
   -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode     
   --,A.DPD  ,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105)    
   --)A    
   --)T    
   /*
     IF OBJECT_ID('TempDB..tt_ECBF_64') Is Not Null    
      Drop Table tt_ECBF_64    

      Select CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate    
      ,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,    
      DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,SourceAlt_Key,SourceName    
      Into tt_ECBF_64    
      from (    
      Select A.CustomerAcID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,    
      DA.AssetClassAlt_Key BankAssetClass    
        ,DP.ProductName ProductType,C.CustomerName ClientName,A.RefCustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,    
        Case When E.SrcSysClassCode='SS' then 'SBSTD' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02'     
        When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification    
        ,A.DPD_Max as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.FinalNpaDt,105) as NpaDate,Convert(Varchar(10),@Date,105)as CurrentDate,ds.SourceAlt_Key,ds.SourceName    

       from Pro.ACCOUNTCAL A    
      Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID    
      ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey    
      Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key    
      ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey    
      Inner Join DimProduct DP ON DP.ProductAlt_Key=A.ProductAlt_Key    
      ANd DP.EffectiveFromTimeKey<=@Timekey ANd DP.EffectiveToTimeKey>=@Timekey    
      Inner Join Pro.CUSTOMERCAL C ON C.CustomerEntityID=A.CustomerEntityID    
      Inner Join DimAssetClass E ON E.AssetClassAlt_Key=A.FinalAssetClassAlt_Key    
      ANd E.EffectiveFromTimeKey<=@Timekey ANd E.EffectiveToTimeKey>=@Timekey    
      Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key    
      ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey     
      Where DS.SourceName='ECBF'    
      ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID    
      And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')    
      And R.ProcessDate=@PreviousDate)    
      And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And    
      -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and    
      --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND    
      NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and     
      Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)    
      )A    
      Group By CustomerAcID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate    
      ,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,    
      DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,SourceAlt_Key,SourceName    

       	Delete        a
   			from          tt_ECBF_64 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date
      */
   IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD_21') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD_21 ';
   END IF;
   DELETE FROM tt_ACCOUNTCAL_DPD_21;
   UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD_21');

   INSERT INTO tt_ACCOUNTCAL_DPD_21 ( 
   	SELECT CustomerEntityID ,
           MAX(DPD_Max)  DPD_Max  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	  GROUP BY CustomerEntityID );
   IF utils.object_id('TempDB..tt_ECBF_64') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_64 ';
   END IF;
   DELETE FROM tt_ECBF_64;
   UTILS.IDENTITY_RESET('tt_ECBF_64');

   INSERT INTO tt_ECBF_64 ( 
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
           CurrentDate ,
           a.SourceAlt_Key ,
           SourceName 
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
                    v_Date CurrentDate  ,
                    a.SourceAlt_Key ,
                    SourceName 
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
                    LEFT JOIN tt_ACCOUNTCAL_DPD_21 AD   ON AD.CustomerEntityID = Z.CustomerEntityID
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
   	  GROUP BY RefCustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,a.SourceAlt_Key,SourceName );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_ECBF_64 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
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
                            A.SourceAlt_Key ,
                            SourceName 
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
     UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105) CurrentDate  ,
     A.SourceAlt_Key ,
     SourceName 
                            FROM ReverseFeedData A
                                   JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                             WHERE  B.SourceName = 'ECBF'
                                      AND A.AssetSubClass <> 'STD'
                                      AND A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                              GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105),a.SourceAlt_Key,SourceName ) A ) T
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
                            a.SourceAlt_Key ,
                            SourceName 
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
                                   v_Date CurrentDate  ,
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                                   JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                                   AND E.EffectiveFromTimeKey <= v_TimeKey
                                   AND E.EffectiveToTimeKey >= v_TimeKey
                                   JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON C.CustomerEntityID = A.CustomerEntityID
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DimProduct D   ON D.ProductAlt_Key = c.ProductAlt_Key
                                   AND D.EffectiveFromTimeKey <= v_TimeKey
                                   AND D.EffectiveToTimeKey >= v_TimeKey
                             WHERE  B.SourceName = 'ECBF'
                                      AND A.SrcAssetClassAlt_Key > 1
                                      AND A.SysAssetClassAlt_Key > 1
                                      AND NVL(A.SrcNPA_Dt, ' ') <> NVL(A.SysNPA_Dt, ' ')
                                      AND A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                              GROUP BY D.ProductName,a.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,c.DPD_Max,UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105),a.SourceAlt_Key,SourceName --,Convert(Varchar(10),@Date,105)
                           ) A ) T
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
                            a.SourceAlt_Key ,
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
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM tt_ECBF_64 A
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
                            a.SourceAlt_Key ,
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
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM tt_ECBF_64 A
                             WHERE  A.BankAssetClass > 1
                                      AND A.FinalAssetClassAlt_Key > 1
                                      AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                                      OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A ) T ) F
       GROUP BY SourceAlt_Key,SourceName;
   --=================================================ECBF END ==========================================================================    
   --=================================================Metagrid==========================================================================    
   ---------MetaGrid    
   --Select A.CustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),NpaDate,105),'-','') as 'ENPA_D2K_NPA_DATE'     
   --   INSERT INTO tt_temp2_38    
   --      select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
   --from ReverseFeedData A    
   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    
   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    
   -- where B.SourceName='MetaGrid'    
   -- And A.AssetSubClass<>'STD'    
   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
   -- group by a.SourceAlt_Key,a.SourceSystemName    
   /* 
      IF OBJECT_ID('TempDB..tt_MetaGrid_64') Is Not Null    
      Drop Table tt_MetaGrid_64    

      Select A.CustomerAcID,A.RefCustomerId CustomerId,A.UCIF_ID,A.FinalAssetClassAlt_Key,A.FinalNpaDt,B.SourceAssetClass,B.SourceNpaDate,    
      DA.AssetClassAlt_Key BankAssetClass,ds.SourceAlt_Key,ds.SourceName    
        INto tt_MetaGrid_64    
       from Pro.ACCOUNTCAL A    
      Inner Join dbo.AdvAcBalanceDetail B ON A.AccountEntityID=B.AccountEntityID    
      ANd B.EffectiveFromTimeKey<=@Timekey ANd B.EffectiveToTimeKey>=@Timekey    
      Inner Join DIMSOURCEDB DS ON DS.SourceAlt_Key=A.SourceAlt_Key    
      ANd DS.EffectiveFromTimeKey<=@Timekey ANd DS.EffectiveToTimeKey>=@Timekey    
      Inner Join DimAssetClassMapping DA ON DA.SrcSysClassCode=B.SourceAssetClass And A.SourceAlt_Key=DA.SourceAlt_Key    
      ANd DA.EffectiveFromTimeKey<=@Timekey ANd DA.EffectiveToTimeKey>=@Timekey     
      Where DS.SourceName='MetaGrid'    
      ANd Not exists (Select 1 from ReverseFeedDataInsertSync R where A.CustomerAcID=R.CustomerAcID    
      And DA.AssetClassAlt_Key=R.FinalAssetClassAlt_Key And ISNULL(B.SourceNpaDate,'')=ISNULL(R.FinalNpaDt,'')    
      And R.ProcessDate=@PreviousDate)    
      And Not exists (Select 1 from ReverseFeedData B where B.AccountID=A.CustomerAcID and DateofData=@Date ANd B.AssetSubClass='STD')And    
      -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and    
      --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND    
      NOT EXISTS(Select 1 from DimProduct as Y Where Y.ProductAlt_Key=A.ProductAlt_Key and Y.ProductCode='RBSNP' and     
      Y.EffectiveFromTimeKey<=@TimeKey and Y.EffectiveToTimeKey>=@TimeKey)    

       	Delete        a
   			from          tt_MetaGrid_64 a
   			inner join    ReverseFeedData b
   			on            a.CustomerAcID=b.AccountID
   			where         DateofData=@Date
       */
   IF utils.object_id('TempDB..tt_MetaGrid_64') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_64 ';
   END IF;
   DELETE FROM tt_MetaGrid_64;
   UTILS.IDENTITY_RESET('tt_MetaGrid_64');

   INSERT INTO tt_MetaGrid_64 ( 
   	SELECT A.RefCustomerID ,
           A.RefCustomerID CustomerId  ,
           A.UCIF_ID ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           SourceName 
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
     FROM tt_MetaGrid_64 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp2_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  CNT  
       FROM ( SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(NpaDate,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     A.SourceAlt_Key ,
                     SourceName 
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
              SELECT A.RefCustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
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
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_MetaGrid_64 A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     NULL Asset_Classification  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>105), '-', ' ') ENPA_D2K_NPA_DATE  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_MetaGrid_64 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                        OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) G
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
   INSERT INTO tt_temp2_38
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
   FROM A ,StatusReport_RERF_Customer a
          JOIN tt_temp2_38 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Degrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END    
                                 = src.CNT;
   UPDATE StatusReport_RERF_Customer
      SET Degrade = 0
    WHERE  Degrade IS NULL;--update StatusReport_RF    
   --set    Degrade_Status= case when isnull(Degrade_ACL,0)=isnull(Degrade_RF,0) then 'True' else 'False' END    

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_RERF_TOTAL_CUSTOMER_04122023" TO "ADF_CDR_RBL_STGDB";
