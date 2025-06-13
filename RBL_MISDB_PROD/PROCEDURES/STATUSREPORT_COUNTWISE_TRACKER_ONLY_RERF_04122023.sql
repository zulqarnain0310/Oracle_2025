--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --Declare @TimeKey as Int=26460    
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );
   --select replace(convert(varchar(11),@Date,113),'','-') 'RF Count Date'            
   --select  replace(convert(varchar(10),@Date,103),'/','-') 'RF Data file dated'   
   --update StatusReport_Only_RERF            
   --set    ACL=0   ,Degrade=0,Upgrade=0        
   ----------------------------------------------------------------------------------------------------------------------------------
   --update  StatusReport_Only_RERF
   --set ACL='21',Degrade='29',Upgrade='22'
   --where SourceAlt_Key=1
   --update  StatusReport_Only_RERF
   --set ACL='15',Degrade='21',Upgrade='3'
   --where SourceAlt_Key=2
   --update  StatusReport_Only_RERF
   --set ACL='0',Degrade='1',Upgrade='0'
   --where SourceAlt_Key=3
   --update  StatusReport_Only_RERF
   --set ACL='11219',Degrade='3927',Upgrade='81'
   --where SourceAlt_Key=5
   --update  StatusReport_Only_RERF
   --set ACL='1931',Degrade='2328',Upgrade='89'
   --where SourceAlt_Key=6
   --update  StatusReport_Only_RERF
   --set ACL='0',Degrade='1',Upgrade='0'
   --where SourceAlt_Key in (4)
   --update  StatusReport_Only_RERF
   --set ACL='0',Degrade='0',Upgrade='0'
   --where SourceAlt_Key in (7,8)
   ------------------------------------------------------------------------------------------------------------------------------------------
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_Only_RERF ';
   INSERT INTO StatusReport_Only_RERF
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
       ORDER BY SourceAlt_Key;
   --------------Finacle            
   IF utils.object_id('tempdb..tt_temp1_50') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_50 ';
   END IF;
   DELETE FROM tt_temp1_50;
   DBMS_OUTPUT.PUT_LINE('Finacle ');
   IF utils.object_id('TempDB..tt_Finacle_70') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_70 ';
   END IF;
   DELETE FROM tt_Finacle_70;
   UTILS.IDENTITY_RESET('tt_Finacle_70');

   INSERT INTO tt_Finacle_70 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           Z.UpgDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           a.SourceAlt_Key ,
           a.UCIF_ID 
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
                                        AND DateofData = v_Date )

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
     FROM tt_Finacle_70 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     -- Select 'FinacleAssetClassification' AS TableName,

                     --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                     --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as DataUtility,

                     --A.SourceAlt_Key,SourceName,CustomerID

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN Pro.CustomerCal_Hist C ON A.CustomerID=C.RefCustomerID

                     --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

                     --where B.SourceName='Finacle'

                     --And A.AssetSubClass<>'STD'

                     --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey 

                     --union

                     --Select 'FinacleAssetClassification' AS TableName,

                     --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                     --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),isnull(A.UpgradeDate,@date),105),'')  as DataUtility

                     --,A.SourceAlt_Key,SourceName,CustomerID

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN Pro.CustomerCal_Hist C ON A.CustomerID=C.RefCustomerID

                     --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

                     --where B.SourceName='Finacle'

                     --And A.AssetSubClass='STD'

                     --AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey 

                     --Union

                     --Select 'FinacleDegrade' AS TableName, RefCustomerID +'|'+

                     --Convert(Varchar(10),a.SysNPA_Dt,105)+'|' as DataUtility

                     --Select A.SourceAlt_Key,SourceName,a.RefCustomerID CustomerID

                     -- from Pro.CustomerCal_hist A wITH (NOLOCK)

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Finacle'

                     --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

                     --			 ANd  A.SrcNPA_Dt<>A.SysNPA_Dt     

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -----------Added on 04/04/2022

                     --		 UNION

                     --Select  'FinacleDegrade' AS TableName, CustomerID +'|'+Convert(Varchar(10),FinalAssetClassAlt_Key,105)+'|' as DataUtility
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            A.CustomerID 
                     FROM tt_Finacle_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass = 1
                               AND A.FinalAssetClassAlt_Key > 1
                     UNION 

                     -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022

                     --Select  'FinacleDegrade' AS TableName, CustomerID +'|'+Convert(Varchar(10),FinalNpaDt,105)+'|' as DataUtility 
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.CustomerID 
                     FROM tt_Finacle_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNPADate, ' ')
                               OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) )
                     UNION 

                     --Select  'FinacleUpgrade' AS TableName, CustomerID +'|'+Convert(Varchar(10),isnull(UpgDate,@Date),105) as DataUtility 
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.CustomerID 
                     FROM tt_Finacle_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key = 1 ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Ganaseva---------------------------------------------------------------------------------------------------------------        
   IF utils.object_id('TempDB..tt_Ganaseva_61') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_61 ';
   END IF;
   DELETE FROM tt_Ganaseva_61;
   UTILS.IDENTITY_RESET('tt_Ganaseva_61');

   INSERT INTO tt_Ganaseva_61 ( 
   	SELECT A.RefCustomerID ,
           A.SrcAssetClassAlt_Key ,
           A.SrcNPA_Dt ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           a.SysAssetClassAlt_Key ,
           a.SysNPA_Dt ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           z.UpgDate ,
           a.UCIF_ID ,
           a.SourceAlt_Key 
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
                                         AND DateofData = v_Date )

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
     FROM tt_Ganaseva_61 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   ----------------
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     -- Select 'GanasevaAssetClassification' AS TableName,

                     --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                     --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),isnull(A.NPADate,@date),105),'')  as DataUtility,

                     --A.SourceAlt_Key,SourceName,a.CustomerID

                     --		 from ReverseFeedData A

                     --		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --		Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --		 where B.SourceName='Ganaseva'

                     --		 And A.AssetSubClass<>'STD'

                     --		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     --		  ------Changes for NPADate on 22/04/2022

                     --		 union

                     --		 Select 

                     --A.SourceAlt_Key,SourceName,a.RefCustomerID CustomerID

                     -- from Pro.CustomerCal_hist A wITH (NOLOCK)

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Ganaseva'

                     --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

                     --			 ANd  ISNULL(A.SysNPA_Dt,'')<>ISNULL(A.SrcNPA_Dt,'')     

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     --		 ----------Added on 04/04/2022

                     --		 UNION
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            A.RefCustomerID CustomerID  
                     FROM tt_Ganaseva_61 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass = 1
                               AND A.SysAssetClassAlt_Key > 1
                     UNION 

                     -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.RefCustomerID 
                     FROM tt_Ganaseva_61 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.SysAssetClassAlt_Key > 1
                               AND ( NVL(A.SourceNpaDate, ' ') <> NVL(A.SysNPA_Dt, ' ')
                               OR ( A.BankAssetClass <> A.SysAssetClassAlt_Key ) )
                     UNION 

                     --union

                     --		 			 Select 'GanasevaAssetClassification' AS TableName,

                     --A.CustomerID+'|'+A.UCIF_ID +'|'+ E.AssetClassShortNameEnum+'|'+E.AssetClassName+'|'+

                     --Convert(Varchar(10),@Date,105) +'|'+ ISNULL(Convert(Varchar(10),isnull(A.UpgradeDate,@date),105),'')  as DataUtility,

                     --A.SourceAlt_Key,SourceName,a.CustomerID

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --	 where B.SourceName='Ganaseva'

                     --	 And A.AssetSubClass='STD'

                     --	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     --------------Added on 04/04/2022
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_Ganaseva_61 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.SysAssetClassAlt_Key = 1 ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------ECBF  ----------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD_28') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD_28 ';
   END IF;
   DELETE FROM tt_ACCOUNTCAL_DPD_28;
   UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD_28');

   INSERT INTO tt_ACCOUNTCAL_DPD_28 ( 
   	SELECT CustomerEntityID ,
           MAX(DPD_Max)  DPD_Max  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	  GROUP BY CustomerEntityID );
   IF utils.object_id('TempDB..tt_ECBF_72') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_72 ';
   END IF;
   DELETE FROM tt_ECBF_72;
   UTILS.IDENTITY_RESET('tt_ECBF_72');

   INSERT INTO tt_ECBF_72 ( 
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
           UCIF_ID ,
           SrcSysClassName ,
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
                    a.UCIF_ID ,
                    E.SrcSysClassName ,
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
                    LEFT JOIN tt_ACCOUNTCAL_DPD_28 AD   ON AD.CustomerEntityID = Z.CustomerEntityID
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
                                                  AND DateofData = v_Date )

                       -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and

                       --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND
                       AND NOT EXISTS ( SELECT 1 
                                        FROM DimProduct Y
                                         WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                                  AND Y.ProductCode = 'RBSNP'
                                                  AND Y.EffectiveFromTimeKey <= v_TimeKey
                                                  AND Y.EffectiveToTimeKey >= v_TimeKey ) ) A
   	  GROUP BY RefCustomerID,FinalAssetClassAlt_Key,FinalNpaDt,SourceAssetClass,SourceNpaDate,BankAssetClass,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,UserClassification,UserSubClassification,NpaDate,CurrentDate,UCIF_ID,SrcSysClassName,a.SourceAlt_Key,SourceName );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_ECBF_72 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --  Select CustomerID as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                     --Convert(Varchar(10),DateofData,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate,

                     --SourceAlt_Key,SourceName

                     -- from (

                     --Select 

                     --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                     --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                     --, DPD , UserClassification, UserSubClassification, NpaDate, CurrentDate,CustomerID,UCIF_ID,SrcSysClassName

                     --,DateofData,a.SourceAlt_Key,SourceName

                     --from (

                     --Select A.ProductName ProductType,

                     --A.CustomerName ClientName,A.CustomerID as ClientCustId,E.AssetClassGroup as SystemClassification,

                     --Case When E.SrcSysClassCode='SS' then 'DBT01' When E.SrcSysClassCode='D1' then 'DBT01'  When E.SrcSysClassCode='D2' then 'DBT02' 

                     --When E.SrcSysClassCode='D3' then 'DBT03' When E.SrcSysClassCode='L1' then 'LOSS' Else E.SrcSysClassCode End as SystemSubClassification

                     --,A.DPD as DPD,'NPA' as UserClassification,'SBSTD' as UserSubClassification,Convert(Varchar(10),A.NPADate,105) as NpaDate,

                     --Convert(Varchar(10),A.DateofData,105)as CurrentDate,CustomerID,UCIF_ID,E.SrcSysClassName,DateofData,

                     --a.SourceAlt_Key,b.SourceName

                     --  from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='ECBF'

                     -- And A.AssetSubClass<>'STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -- Group By A.ProductName ,

                     -- A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.SrcSysClassCode ,A.DPD  

                     --,Convert(Varchar(10),A.NPADate,105),Convert(Varchar(10),A.DateofData,105),CustomerID,UCIF_ID,SrcSysClassName

                     --,DateofData,a.SourceAlt_Key,b.SourceName

                     --)A

                     --)T

                     -------------Changes for npadate on 22/04/2022

                     --Union

                     --Select 

                     --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,

                     --UserClassification

                     --,UserSubClassification,NpaDate,CurrentDate

                     --Select RefCustomerID as CustomerID

                     --,SourceAlt_Key,SourceName

                     -- from (

                     --Select 

                     -- RefCustomerID 

                     --,a.SourceAlt_Key,SourceName

                     --from (

                     --Select A.RefCustomerID 

                     --,a.SourceAlt_Key,SourceName

                     --  from Pro.CUSTOMERCAL A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                     --Inner Join Pro.Accountcal C ON C.CustomerEntityID=A.CustomerEntityID

                     --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

                     --Inner Join DimProduct D ON D.ProductAlt_Key=c.ProductAlt_Key

                     --And D.EffectiveFromTimekey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='ECBF'

                     -- And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1

                     -- And ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -- Group By 

                     -- A.RefCustomerID ,a.SourceAlt_Key,SourceName--,Convert(Varchar(10),@Date,105)

                     --)A

                     --)T

                     -----------Added on 04/04/2022-----

                     --UNION
                     SELECT RefCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT RefCustomerID ,
                                   A.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT RefCustomerID ,
                                          SourceAlt_Key ,
                                          SourceName 
                                   FROM tt_ECBF_72 A
                                    WHERE  A.BankAssetClass = 1
                                             AND A.FinalAssetClassAlt_Key > 1 ) A ) T
                     UNION 

                     -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                     SELECT RefCustomerID ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT RefCustomerID ,
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT RefCustomerID ,
                                          a.SourceAlt_Key ,
                                          SourceName 
                                   FROM tt_ECBF_72 A
                                    WHERE  A.BankAssetClass > 1
                                             AND A.FinalAssetClassAlt_Key > 1
                                             AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                                             OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A ) T
                     UNION 

                     --Union

                     --Select ClientCustId as CustomerID,UCIF_ID as UCIC,SystemSubClassification  as Asset_Code,SrcSysClassName as Description,

                     --Convert(Varchar(10),CurrentDate,105) as Asset_Code_Date,ISNULL(Convert(Varchar(10),NPADate,105),'')  as D2KNpaDate

                     --,SourceAlt_Key,SourceName

                     -- from (

                     --Select 

                     --ROW_NUMBER()Over(Order By ClientCustId)as SrNo,

                     --ProductType,ClientName, ClientCustId,SystemClassification,SystemSubClassification

                     --, DPD, UserClassification, UserSubClassification, NpaDate, CurrentDate,UCIF_ID,SrcSysClassName

                     --,a.SourceAlt_Key,SourceName

                     --from (

                     --Select A.ProductName ProductType,A.CustomerName ClientName,A.CustomerID as ClientCustId,'NPA' as SystemClassification,'SBSTD' as SystemSubClassification

                     --,A.DPD as DPD,E.AssetClassGroup as UserClassification,

                     --(Case When A.DPD=0 Then 'DPD0' When A.DPD BETWEEN 1 AND 30 Then 'DPD30' When A.DPD BETWEEN 31 AND 60 Then 'DPD60' 

                     --When A.DPD BETWEEN 61 AND 90 Then 'DPD90' When A.DPD BETWEEN 91 AND 180 Then 'DPD180' When A.DPD BETWEEN 181 AND 365 Then 'PD1YR' END )

                     -- as UserSubClassification,Convert(Varchar(10),A.UpgradeDate,105) as NpaDate,Convert(Varchar(10),A.DateofData,105)as CurrentDate,

                     -- UCIF_ID,e.SrcSysClassName,a.SourceAlt_Key,SourceName

                     --  from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.AssetClassShortName

                     --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

                     ----Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID

                     -- where B.SourceName='ECBF'

                     -- And A.AssetSubClass='STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -- Group By 

                     -- A.ProductName ,A.CustomerName ,A.CustomerID ,E.AssetClassGroup ,E.AssetClassShortName 

                     --,A.DPD  ,Convert(Varchar(10),A.UpgradeDate,105),Convert(Varchar(10),A.DateofData,105),UCIF_ID,SrcSysClassName

                     --,a.SourceAlt_Key,SourceName

                     --)A

                     --)T

                     ------------Added on 04/04/2022
                     SELECT RefCustomerID ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT RefCustomerID ,
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT RefCustomerID ,
                                          a.SourceAlt_Key ,
                                          SourceName 
                                   FROM tt_ECBF_72 A
                                    WHERE  A.BankAssetClass > 1
                                             AND A.FinalAssetClassAlt_Key = 1 ) A ) T ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Indus  -----------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_Indus_70') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_70 ';
   END IF;
   DELETE FROM tt_Indus_70;
   UTILS.IDENTITY_RESET('tt_Indus_70');

   INSERT INTO tt_Indus_70 ( 
   	SELECT A.RefCustomerID ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           UpgDate ,
           a.SourceAlt_Key ,
           a.UCIF_ID 
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
                                         AND DateofData = v_Date )

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
     FROM tt_Indus_70 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),DateofData,105) as asset_code_date,

                     --ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as [D2K NPA date],A.CustomerID as [Customer ID],A.UCIF_ID as UCIC

                     --,a.SourceAlt_Key,SourceName,CustomerID

                     --from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetSubClass=E.SrcSysClassCode

                     --	And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='Indus'

                     -- And A.AssetSubClass<>'STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     ------Changes for NPADate on 22/04/2022

                     --union

                     --Select RefCustomerID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),SysNPA_Dt,106),' ','-') as 'Value Date'

                     --Select a.SourceAlt_Key,SourceName,

                     --			RefCustomerID CustomerID

                     -- from Pro.CustomerCal_Hist A wITH (NOLOCK)

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Indus'

                     --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

                     --			 ANd  ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')     

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     --			 -----------Added on 11/04/2022

                     --		 UNION
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID CustomerID  
                     FROM tt_Indus_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass = 1
                               AND A.FinalAssetClassAlt_Key > 1
                     UNION 

                     -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_Indus_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                               OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) )
                     UNION 

                     -- Union

                     --Select E.AssetClassShortNameEnum as asset_code,E.SrcSysClassName as description,Convert(Varchar(10),@Date,105) as asset_code_date,

                     --	ISNULL(Convert(Varchar(10),A.NPADate,105),'')  as [D2K NPA date],A.CustomerID as [Customer ID],A.UCIF_ID as UCIC 

                     --	,a.SourceAlt_Key,SourceName,CustomerID

                     --	from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON  A.AssetClass=E.AssetClassAlt_Key

                     --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='Indus'

                     -- And A.AssetSubClass='STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -----------Added on 11/04/2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_Indus_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key = 1 ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MiFin -------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_MiFin_70') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_70 ';
   END IF;
   DELETE FROM tt_MiFin_70;
   UTILS.IDENTITY_RESET('tt_MiFin_70');

   INSERT INTO tt_MiFin_70 ( 
   	SELECT A.RefCustomerID ,
           A.SysAssetClassAlt_Key ,
           A.SysNPA_Dt ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           UpgDate ,
           a.SourceAlt_Key ,
           a.UCIF_ID 
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
                                         AND DateofData = v_Date )

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
     FROM tt_MiFin_70 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( 
                     --   Select A.CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),DateofData,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.NPADate,106),' ','-'),'')  as D2kNpaDate

                     --,a.SourceAlt_Key,SourceName

                     --		from ReverseFeedData A

                     --	Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --	And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --	Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --	 where B.SourceName='MiFin'

                     --	 And A.AssetSubClass<>'STD'

                     --	 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     ------Changes for NPADate on 22/04/2022

                     --union

                     --Select a.SourceAlt_Key,SourceName,RefCustomerID CustomerID

                     --			from Pro.CUSTOMERCAL A wITH (NOLOCK)

                     --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

                     --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

                     --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     --			 where B.SourceName='Mifin'

                     --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

                     --			 ANd  ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')     

                     --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -----------Added on 11/04/2022

                     --UNION
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID CustomerID  
                     FROM tt_MiFin_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass = 1
                               AND A.SysAssetClassAlt_Key > 1
                     UNION 

                     -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_MiFin_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.SysAssetClassAlt_Key > 1
                               AND ( NVL(A.SysNPA_Dt, ' ') <> NVL(A.SourceNPADate, ' ')
                               OR ( A.BankAssetClass <> A.SysAssetClassAlt_Key ) )
                     UNION 

                     --	 UNION

                     --	 	Select A.CustomerID,A.UCIF_ID,E.AssetClassShortNameEnum,E.AssetClassName,Replace(convert(varchar(20),@Date,106),' ','-') as Asset_Code_Date,ISNULL(Replace(convert(varchar(20),A.NPADate,106),' ','-'),'')  as D2kNpaDate

                     --		,a.SourceAlt_Key,SourceName

                     --		from ReverseFeedData A

                     --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

                     --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

                     --Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

                     --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

                     -- where B.SourceName='MiFin'

                     -- And A.AssetSubClass='STD'

                     -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

                     -----------Added on 11/04/2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_MiFin_70 A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.SysAssetClassAlt_Key = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  A.BankAssetClass > 1
                               AND A.SysAssetClassAlt_Key = 1 ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------VisionPlus ---------------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_CorporateCustID_9') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CorporateCustID_9 ';
   END IF;
   DELETE FROM tt_CorporateCustID_9;
   UTILS.IDENTITY_RESET('tt_CorporateCustID_9');

   INSERT INTO tt_CorporateCustID_9 ( 
   	SELECT DISTINCT F.CorporateCustomerID ,
                    a.RefCustomerID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL a
             LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON A.AccountEntityID = F.AccountEntityID
             AND F.EffectiveFromTimekey <= v_TimeKey
             AND F.EffectiveToTimeKey >= v_TimeKey );
   IF utils.object_id('TempDB..#VisionPlus') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_31 ';
   END IF;
   DELETE FROM tt_VisionPlus1_9;
   UTILS.IDENTITY_RESET('tt_VisionPlus1_9');

   INSERT INTO tt_VisionPlus1_9 ( 
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
           CorporateCustomerID ,
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
             LEFT JOIN tt_CorporateCustID_9 CC   ON a.RefCustomerID = CC.RefCustomerID
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
     FROM tt_VisionPlus1_9 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   IF utils.object_id('TempDB..tt_AssetClass_9') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AssetClass_9 ';
   END IF;
   DELETE FROM tt_AssetClass_9;
   UTILS.IDENTITY_RESET('tt_AssetClass_9');

   INSERT INTO tt_AssetClass_9 ( 
   	SELECT assetsubclass ,
           CASE 
                WHEN assetsubclass = 'STD' THEN 1
                WHEN assetsubclass = 'SS' THEN 2
                WHEN assetsubclass = 'd1' THEN 3
                WHEN assetsubclass = 'd2' THEN 4
                WHEN assetsubclass = 'd3' THEN 5
                WHEN assetsubclass = 'l1' THEN 6   END AssetClassAlt_key  
   	  FROM ReverseFeedData 
   	 WHERE  SourceSystemName = 'VisionPlus' );
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT CorporateCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM tt_VisionPlus1_9 A
                            JOIN tt_AssetClass_9 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                      WHERE  A.BankAssetClass = 1
                               AND A.FinalAssetClassAlt_Key > 1
                     UNION 
                     SELECT CorporateCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM tt_VisionPlus1_9 A
                            JOIN tt_AssetClass_9 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key = 1
                     UNION 
                     SELECT CorporateCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM tt_VisionPlus1_9 A
                            JOIN tt_AssetClass_9 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                               OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MetaGrid----------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_MetaGrid_72') IS NOT NULL THEN
    --Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where Timekey =26298 )            
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey =26298 )            
   --Declare @TimeKey AS INT =26298            
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_72 ';
   END IF;
   DELETE FROM tt_MetaGrid_72;
   UTILS.IDENTITY_RESET('tt_MetaGrid_72');

   INSERT INTO tt_MetaGrid_72 ( 
   	SELECT A.RefCustomerID ,
           A.RefCustomerID CustomerId  ,
           A.UCIF_ID ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           A.SourceAlt_Key 
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
                                         AND DateofData = v_Date )

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
     FROM tt_MetaGrid_72 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_50
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  cnt  
       FROM ( 
              --   Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',

              --			Replace(convert(varchar(20),DateofData,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.AssetSubClass<>'STD' Then Replace(convert(varchar(20),A.NPADate,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'

              --		,a.SourceAlt_Key,SourceName

              --		from ReverseFeedData A

              --		Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

              --		And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

              --		Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

              --		And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

              --		 where B.SourceName='MetaGrid'

              --		 And A.AssetSubClass<>'STD'

              --		 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

              --------Changes for NPADate on 22/04/2022

              --	 union

              --Select A.RefCustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),A.SysNPA_Dt,105),'-','') as 'ENPA_D2K_NPA_DATE'

              --Select A.RefCustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',

              --				Replace(convert(varchar(20),@Date,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.SysAssetClassAlt_Key<>1 Then Replace(convert(varchar(20),A.SysNPA_Dt,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'

              --			,a.SourceAlt_Key,SourceName

              -- from Pro.CustomerCal_Hist A wITH (NOLOCK)

              --			Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

              --			And B.EffectiveFromTimeKey<=@TimeKey And B.EffectiveToTimeKey>=@TimeKey

              --			Inner JOIN DimAssetClass E ON A.SysAssetClassAlt_Key=E.AssetClassAlt_Key

              --			And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

              --			 where B.SourceName='MetaGrid'

              --			 And A.SrcAssetClassAlt_Key>1 And A.SysAssetClassAlt_Key>1 

              --			 ANd  ISNULL(A.SrcNPA_Dt,'')<>ISNULL(A.SysNPA_Dt,'')     

              --			 AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

              --			 -----------Added on 11/04/2022

              --			 UNION
              SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     E.SrcSysClassCode ENPA_ASSET_CODE  ,
                     CASE 
                          WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                     ELSE E.SrcSysClassName
                        END ENPA_DESCRIPTION  ,
                     REPLACE(v_Date, '-', ' ') ENPA_ASSET_CODE_DATE  ,
                     CASE 
                          WHEN A.FinalAssetClassAlt_Key <> 1 THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ')
                     ELSE NULL
                        END ENPA_D2K_NPA_DATE  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM tt_MetaGrid_72 A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              -------Added on 20/04/2022  This code is implemented for NPA date change for same asset class - Dated 20 April 2022
              SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     E.SrcSysClassCode ENPA_ASSET_CODE  ,
                     CASE 
                          WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                     ELSE E.SrcSysClassName
                        END ENPA_DESCRIPTION  ,
                     REPLACE(v_Date, '-', ' ') ENPA_ASSET_CODE_DATE  ,
                     CASE 
                          WHEN A.FinalAssetClassAlt_Key <> 1 THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ')
                     ELSE NULL
                        END ENPA_D2K_NPA_DATE  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_MetaGrid_72 A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                        OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) )
              UNION 

              --	 UNION

              --	 	Select A.CustomerID as 'CIF ID',A.UCIF_ID as 'UCIC',E.SrcSysClassCode as 'ENPA_ASSET_CODE',Case When E.AssetClassGroup='NPA' Then 'Non Performing' Else E.SrcSysClassName END as 'ENPA_DESCRIPTION',

              --		Replace(convert(varchar(20),@Date,105),'-','')  as 'ENPA_ASSET_CODE_DATE',Case When A.AssetClass<>1 Then Replace(convert(varchar(20),A.NPADate,105),'-','') Else Null End as 'ENPA_D2K_NPA_DATE'

              --	 ,a.SourceAlt_Key,SourceName

              --	 from ReverseFeedData A

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

              --Inner JOIN DimAssetClass E ON A.AssetClass=E.AssetClassAlt_Key

              --	And E.EffectiveFromTimeKey<=@TimeKey And E.EffectiveToTimeKey>=@TimeKey

              -- where B.SourceName='MetaGrid'

              -- And A.AssetSubClass='STD'

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

              -----------Added on 11/04/2022
              SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     E.SrcSysClassCode ENPA_ASSET_CODE  ,
                     CASE 
                          WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                     ELSE E.SrcSysClassName
                        END ENPA_DESCRIPTION  ,
                     REPLACE(v_Date, '-', ' ') ENPA_ASSET_CODE_DATE  ,
                     CASE 
                          WHEN A.FinalAssetClassAlt_Key <> 1 THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,20,p_style=>105), '-', ' ')
                     ELSE NULL
                        END ENPA_D2K_NPA_DATE  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM tt_MetaGrid_72 A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceName );
   --------------Calypso            
   INSERT INTO tt_temp1_50
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
   --select * from tt_temp1_50            
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_Only_RERF a
          JOIN tt_temp1_50 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.ACL = src.CNT;
   UPDATE StatusReport_Only_RERF
      SET ACL = 0
    WHERE  ACL IS NULL;
   --update StatusReport            
   --set    Total_RF_ACL_Status= case when Total_ACL_Count=Total_ACL_RF_Count then 'True'            
   --         else 'False' end            
   StatusReport_CountWise_Degrade_Tracker_only_RERF() ;
   StatusReport_CountWise_Upgrade_Tracker_Only_RERF() ;
   OPEN  v_cursor FOR
      SELECT SourceName ,
             ACL ,
             Degrade ,
             Upgrade 
        FROM StatusReport_Only_RERF 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_ONLY_RERF_04122023" TO "ADF_CDR_RBL_STGDB";
