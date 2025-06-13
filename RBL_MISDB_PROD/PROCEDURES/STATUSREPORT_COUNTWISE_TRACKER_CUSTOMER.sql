--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_RF_Customer ';
   INSERT INTO StatusReport_RF_Customer
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
       ORDER BY SourceAlt_Key;
   --------------Finacle      
   IF utils.object_id('tempdb..tt_temp1_38') IS NOT NULL THEN
    --Declare @TimeKey as Int=26460  
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey=@TimeKey)  
   --Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where Timekey =26298 )      
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey =26298 )      
   --Declare @TimeKey AS INT =26298      
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_38 ';
   END IF;
   DELETE FROM tt_temp1_38;
   INSERT INTO tt_temp1_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --Select b.SourceAlt_Key,b.SourceName,A.CustomerID      

                     --from ReverseFeedData A      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='Finacle'      

                     -- --And A.AssetSubClass<>'STD'      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      

                     -- UNION      

                     -- Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID      

                     -- from Pro.AccountCal_hist A wITH (NOLOCK)      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='Finacle'      

                     -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1       

                     -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Finacle'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND ( A.SrcAssetClassAlt_Key <> A.SysAssetClassAlt_Key
                               OR A.SrcNPA_Dt <> A.SysNPA_Dt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Ganaseva      
   INSERT INTO tt_temp1_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --   Select b.SourceAlt_Key,b.SourceName,A.CustomerID from ReverseFeedData A      

                     --    Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --    And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --    Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode      

                     --    And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     --     where B.SourceName='Ganaseva'      

                     --     --And A.AssetSubClass<>'STD'      

                     --     AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      

                     --     UNION       

                     --     Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID      

                     --     --Select 'GanasevaAssetClassification' AS TableName, A.UCIF_ID+'|'+Substring(A.RefCustomerID,2,8)+'|'+ E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+ Convert(Varchar(10),'2022-01-16',103) +'|'+ ISNULL(Convert(Varchar(10),A.FinalNpaDt,103),'')  as DataU

                     ----tility       

                     --     from Pro.AccountCal_hist A wITH (NOLOCK)      

                     --    Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --    And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --    Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key      

                     --    And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     --     where B.SourceName='Ganaseva'      

                     --     And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1       

                     --     ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date      

                     --     AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Ganaseva'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND ( A.SrcAssetClassAlt_Key <> A.SysAssetClassAlt_Key
                               OR A.SrcNPA_Dt <> A.SysNPA_Dt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------ECBF      
   INSERT INTO tt_temp1_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --Select b.SourceAlt_Key,b.SourceName,A.CustomerID       

                     --from ReverseFeedData A      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='ECBF'      

                     -- --And A.AssetSubClass<>'STD'      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      

                     -- UNION      

                     -- --Select A.RefCustomerID as CustomerID,A.UCIF_ID as UCIC,E.SrcSysClassCode as Asset_Code,E.SrcSysClassName as Description, Convert(Varchar(10),@Date,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as D2KNpaDate      

                     -- Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID      

                     -- from Pro.AccountCal_hist A wITH (NOLOCK)      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='ECBF'      

                     -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1       

                     -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'ECBF'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
                     FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'ECBF'
                               AND A.SrcAssetClassAlt_Key > 1
                               AND A.SysAssetClassAlt_Key > 1
                               AND ( A.SrcAssetClassAlt_Key <> A.SysAssetClassAlt_Key
                               OR A.SrcNPA_Dt <> A.SysNPA_Dt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Indus      
   INSERT INTO tt_temp1_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --Select b.SourceAlt_Key,b.SourceName,A.CustomerID       

                     --from ReverseFeedData A      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='Indus'      

                     -- --And A.AssetSubClass<>'STD'      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      

                     -- UNION       

                     -- --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as [D2K NPA date],A.RefCustomerID as [Customer ID],A.UCIF_ID as UCIC

                     --Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID      

                     --from Pro.AccountCal_hist A wITH (NOLOCK)      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='Indus'      

                     -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1       

                     -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Indus'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
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
                               AND ( A.SrcAssetClassAlt_Key <> A.SysAssetClassAlt_Key
                               OR A.SrcNPA_Dt <> A.SysNPA_Dt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MiFin      
   INSERT INTO tt_temp1_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --Select b.SourceAlt_Key,b.SourceName,A.CustomerID       

                     --from ReverseFeedData A      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='MiFin'      

                     -- --And A.AssetSubClass<>'STD'      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      

                     -- UNION       

                     -- --Select A.RefCustomerID as CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.FinalNpaDt,106),' ','-'),'')  as D2kNpaDate       

                     --Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID      

                     --from Pro.AccountCal_hist A wITH (NOLOCK)      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='MiFin'      

                     -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1       

                     -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey  
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'MiFin'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
                     FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'MiFin'
                               AND A.InitialAssetClassAlt_Key > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                               OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------VisionPlus      
   INSERT INTO tt_temp1_38
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --Select b.SourceAlt_Key,b.SourceName,A.CustomerID  from ReverseFeedData A      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='VisionPlus'      

                     -- --And A.AssetSubClass<>'STD'      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey      

                     -- UNION      

                     -- --Select'VisionPlusAssetClassification' AS TableName, (A.UCIF_ID+'|'+A.RefCustomerID+'|'+E.SrcSysClassCode+'|'+E.SrcSysClassName+'|'+Convert(Varchar(10),@Date,105))+'|'+ISNULL(Convert(Varchar(10),A.FinalNpaDt,105),'')  as DataUtility      

                     --  Select  b.SourceAlt_Key,b.SourceName,A.RefCustomerID AS CustomerID      

                     --  from Pro.AccountCal_hist A wITH (NOLOCK)      

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key      

                     --And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey      

                     --Inner JOIN DimAssetClass E ON A.FinalAssetClassAlt_Key=E.AssetClassAlt_Key      

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey      

                     -- where B.SourceName='VisionPlus'      

                     -- And A.InitialAssetClassAlt_Key>1 And A.FinalAssetClassAlt_Key>1       

                     -- ANd (A.InitialAssetClassAlt_Key<>A.FinalAssetClassAlt_Key OR A.InitialNpaDt<>A.FinalNpaDt)        ------Added INitial and Final NPA Date      

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey   
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'VisionPlus'

                               --And A.AssetSubClass<>'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT b.SourceAlt_Key ,
                            b.SourceName ,
                            A.RefCustomerID CustomerID  
                     FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'VisionPlus'
                               AND A.SrcAssetClassAlt_Key > 1
                               AND A.SysAssetClassAlt_Key > 1
                               AND ( A.SrcAssetClassAlt_Key <> A.SysAssetClassAlt_Key
                               OR A.SysNPA_Dt <> A.SrcNPA_Dt ------Added INitial and Final NPA Date
                              )
                               AND A.EffectiveFromTimekey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MetaGrid      
   INSERT INTO tt_temp1_38
     ( SELECT A.SourceAlt_Key ,
              B.SourceName ,
              COUNT(*)  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
              AND E.EffectiveFromTimeKey <= v_TimeKey
              AND E.EffectiveToTimeKey >= v_TimeKey
        WHERE  B.SourceName = 'MetaGrid'

                 --And A.AssetSubClass<>'STD'      
                 AND A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY A.SourceAlt_Key,B.SourceName );
   --------------Calypso      
   INSERT INTO tt_temp1_38
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
                 AND A.FinalAssetClassAlt_Key <> A.InitialAssetAlt_key );
   --select * from tt_temp1_38      
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF_Customer a
          JOIN tt_temp1_38 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.ACL = src.CNT;
   UPDATE StatusReport_RF_Customer
      SET ACL = 0
    WHERE  ACL IS NULL;
   --update StatusReport      
   --set    Total_RF_ACL_Status= case when Total_ACL_Count=Total_ACL_RF_Count then 'True'      
   --         else 'False' end      
   RBL_MISDB_PROD.StatusReport_CountWise_Degrade_Tracker_Customer() ;
   RBL_MISDB_PROD.StatusReport_CountWise_Upgrade_Tracker_customer() ;
   --select replace(convert(varchar(11),@Date,113),'','-') 'RF Count Date'      
   --select  replace(convert(varchar(10),@Date,103),'/','-') 'RF Data file dated'
   -- update StatusReport_RF
   --set acl=9,degrade=88,Upgrade=48
   --where SourceAlt_Key=1
   --update StatusReport_RF
   --set acl=2,degrade=20,Upgrade=1
   --where SourceAlt_Key=2
   --update StatusReport_RF
   --set acl=0,degrade=12,Upgrade=0
   --where SourceAlt_Key=3
   --update StatusReport_RF
   --set acl=0,degrade=1,Upgrade=0
   --where SourceAlt_Key=4
   --update StatusReport_RF
   --set acl=3148,degrade=6068,Upgrade=180
   --where SourceAlt_Key=5
   --update StatusReport_RF
   --set acl=128,degrade=2254,Upgrade=518
   --where SourceAlt_Key=6
   --Update a
   --set a.ACL=b.ACL,a.Degrade=b.Degrade,a.Upgrade=b.Upgrade
   --from StatusReport_RF a
   --inner join   StatusReport_RERF b
   --on          a.SourceAlt_Key=b.SourceAlt_Key
   OPEN  v_cursor FOR
      SELECT SourceName ,
             ACL ,
             Degrade ,
             Upgrade 
        FROM StatusReport_RF_Customer 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   RBL_MISDB_PROD.StatusReport_CountWise_Tracker_Only_RERF_Customer() ;
   RBL_MISDB_PROD.StatusReport_CountWise_Tracker_RERF_TOTAL_Customer() ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_CUSTOMER" TO "ADF_CDR_RBL_STGDB";
