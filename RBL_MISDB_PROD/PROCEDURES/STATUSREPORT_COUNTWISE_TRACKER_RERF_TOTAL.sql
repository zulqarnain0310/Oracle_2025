--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_RERF ';
   INSERT INTO StatusReport_RERF
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
       ORDER BY SourceAlt_Key;
   --------------Finacle          
   IF utils.object_id('tempdb..tt_temp1_28') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_28 ';
   END IF;
   DELETE FROM tt_temp1_28;
   DBMS_OUTPUT.PUT_LINE('Finacle ');
   IF utils.object_id('TempDB..tt_Finacle_67') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Finacle_67 ';
   END IF;
   DELETE FROM tt_Finacle_67;
   UTILS.IDENTITY_RESET('tt_Finacle_67');

   INSERT INTO tt_Finacle_67 ( 
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
     FROM tt_Finacle_67 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT A.SourceAlt_Key ,
                            SourceName ,
                            CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                            JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON A.CustomerID = C.RefCustomerID
                            AND C.EffectiveFromTimekey <= v_TimeKey
                            AND C.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Finacle'
                               AND A.AssetSubClass <> 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                            JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON A.CustomerID = C.RefCustomerID
                            AND C.EffectiveFromTimekey <= v_TimeKey
                            AND C.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Finacle'
                               AND A.AssetSubClass = 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     --Select 'FinacleDegrade' AS TableName, RefCustomerID +'|'+

                     --Convert(Varchar(10),a.SysNPA_Dt,105)+'|' as DataUtility
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.RefCustomerID 
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

                     --Select  'FinacleDegrade' AS TableName, CustomerID +'|'+Convert(Varchar(10),FinalAssetClassAlt_Key,105)+'|' as DataUtility
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.CustomerID 
                     FROM tt_Finacle_67 A
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
                     FROM tt_Finacle_67 A
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
                     FROM tt_Finacle_67 A
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
   IF utils.object_id('TempDB..tt_Ganaseva_57') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_57 ';
   END IF;
   DELETE FROM tt_Ganaseva_57;
   UTILS.IDENTITY_RESET('tt_Ganaseva_57');

   INSERT INTO tt_Ganaseva_57 ( 
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
     FROM tt_Ganaseva_57 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   ----------------
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT A.SourceAlt_Key ,
                            SourceName ,
                            A.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Ganaseva'
                               AND A.AssetSubClass <> 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     ------Changes for NPADate on 22/04/2022
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.RefCustomerID 
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
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.RefCustomerID 
                     FROM tt_Ganaseva_57 A
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
                     FROM tt_Ganaseva_57 A
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
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            a.CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetClass = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Ganaseva'
                               AND A.AssetSubClass = 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     --------------Added on 04/04/2022
                     SELECT A.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_Ganaseva_57 A
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
   IF utils.object_id('TempDB..tt_ACCOUNTCAL_DPD_25') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_DPD_25 ';
   END IF;
   DELETE FROM tt_ACCOUNTCAL_DPD_25;
   UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_DPD_25');

   INSERT INTO tt_ACCOUNTCAL_DPD_25 ( 
   	SELECT CustomerEntityID ,
           MAX(DPD_Max)  DPD_Max  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	  GROUP BY CustomerEntityID );
   IF utils.object_id('TempDB..tt_ECBF_69') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ECBF_69 ';
   END IF;
   DELETE FROM tt_ECBF_69;
   UTILS.IDENTITY_RESET('tt_ECBF_69');

   INSERT INTO tt_ECBF_69 ( 
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
                    LEFT JOIN tt_ACCOUNTCAL_DPD_25 AD   ON AD.CustomerEntityID = Z.CustomerEntityID
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
     FROM tt_ECBF_69 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT CustomerID ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT CustomerID ,
                                   A.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT A.CustomerID ,
                                          A.SourceAlt_Key ,
                                          b.SourceName 
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
                                     GROUP BY A.ProductName,A.CustomerName,A.CustomerID,E.AssetClassGroup,E.SrcSysClassCode,A.DPD,UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105),UTILS.CONVERT_TO_VARCHAR2(A.DateofData,10,p_style=>105),CustomerID,UCIF_ID,SrcSysClassName,DateofData,a.SourceAlt_Key,b.SourceName ) A ) T
                     UNION 

                     -------------Changes for npadate on 22/04/2022

                     --Select 

                     --SrNo,ProductType,ClientName,ClientCustId,SystemClassification,SystemSubClassification,DPD,

                     --UserClassification

                     --,UserSubClassification,NpaDate,CurrentDate
                     SELECT RefCustomerID ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT RefCustomerID ,
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT A.RefCustomerID ,
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
                                     GROUP BY D.ProductName,a.CustomerName,A.RefCustomerID,E.AssetClassGroup,E.SrcSysClassCode,c.DPD_Max,UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,10,p_style=>105),a.RefCustomerID,a.UCIF_ID,E.SrcSysClassName,a.SourceAlt_Key,SourceName --,Convert(Varchar(10),@Date,105)
                                  ) A ) T
                     UNION 

                     ---------Added on 04/04/2022-----
                     SELECT RefCustomerID ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT RefCustomerID ,
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT RefCustomerID ,
                                          SourceAlt_Key ,
                                          SourceName 
                                   FROM tt_ECBF_69 A
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
                                   FROM tt_ECBF_69 A
                                    WHERE  A.BankAssetClass > 1
                                             AND A.FinalAssetClassAlt_Key > 1
                                             AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                                             OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A ) T
                     UNION 
                     SELECT CustomerID ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM ( SELECT CustomerID ,
                                   a.SourceAlt_Key ,
                                   SourceName 
                            FROM ( SELECT CustomerID ,
                                          a.SourceAlt_Key ,
                                          SourceName 
                                   FROM ReverseFeedData A
                                          JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                          AND B.EffectiveFromTimeKey <= v_TimeKey
                                          AND B.EffectiveToTimeKey >= v_TimeKey
                                          JOIN DimAssetClass E   ON A.AssetSubClass = E.AssetClassShortName
                                          AND E.EffectiveFromTimeKey <= v_TimeKey
                                          AND E.EffectiveToTimeKey >= v_TimeKey

                                   --Inner Join Pro.CustomerCal C ON A.CustomerID=C.RefCustomerID
                                   WHERE  B.SourceName = 'ECBF'
                                            AND A.AssetSubClass = 'STD'
                                            AND A.EffectiveFromTimeKey <= v_TimeKey
                                            AND A.EffectiveToTimeKey >= v_TimeKey
                                     GROUP BY CustomerID,a.SourceAlt_Key,SourceName ) A ) T
                     UNION 

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
                                   FROM tt_ECBF_69 A
                                    WHERE  A.BankAssetClass > 1
                                             AND A.FinalAssetClassAlt_Key = 1 ) A ) T ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------Indus  -----------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_Indus_67') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Indus_67 ';
   END IF;
   DELETE FROM tt_Indus_67;
   UTILS.IDENTITY_RESET('tt_Indus_67');

   INSERT INTO tt_Indus_67 ( 
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
     FROM tt_Indus_67 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT A.SourceAlt_Key ,
                            SourceName ,
                            CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Indus'
                               AND A.AssetSubClass <> 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     ------Changes for NPADate on 22/04/2022

                     --Select RefCustomerID as 'Loan Account Number' ,'SBSTD' as MAIN_STATUS_OF_ACCOUNT,'SBSTD' as SUB_STATUS_OF_ACCOUNT,'CN01' as REASON_CODE,Replace(convert(varchar(20),SysNPA_Dt,106),' ','-') as 'Value Date'
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
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
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_Indus_67 A
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
                     FROM tt_Indus_67 A
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
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetClass = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'Indus'
                               AND A.AssetSubClass = 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     -----------Added on 11/04/2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_Indus_67 A
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
   --------------MiFin            
   IF utils.object_id('TempDB..tt_MiFin_67') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MiFin_67 ';
   END IF;
   DELETE FROM tt_MiFin_67;
   UTILS.IDENTITY_RESET('tt_MiFin_67');

   INSERT INTO tt_MiFin_67 ( 
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
     FROM tt_MiFin_67 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT A.SourceAlt_Key ,
                            SourceName ,
                            CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetClass = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'MiFin'
                               AND A.AssetSubClass <> 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     ------Changes for NPADate on 22/04/2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
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
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_MiFin_67 A
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
                     FROM tt_MiFin_67 A
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
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            CustomerID 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                            JOIN DimAssetClass E   ON A.AssetClass = E.AssetClassAlt_Key
                            AND E.EffectiveFromTimeKey <= v_TimeKey
                            AND E.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'MiFin'
                               AND A.AssetSubClass = 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     -----------Added on 11/04/2022
                     SELECT a.SourceAlt_Key ,
                            SourceName ,
                            RefCustomerID 
                     FROM tt_MiFin_67 A
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
   --------------VisionPlus ----------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_CorporateCustID_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CorporateCustID_8 ';
   END IF;
   DELETE FROM tt_CorporateCustID_8;
   UTILS.IDENTITY_RESET('tt_CorporateCustID_8');

   INSERT INTO tt_CorporateCustID_8 ( 
   	SELECT DISTINCT F.CorporateCustomerID ,
                    a.RefCustomerID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL a
             LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON A.AccountEntityID = F.AccountEntityID
             AND F.EffectiveFromTimekey <= v_TimeKey
             AND F.EffectiveToTimeKey >= v_TimeKey );
   IF utils.object_id('TempDB..#VisionPlus') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_28 ';
   END IF;
   DELETE FROM tt_VisionPlus1_8;
   UTILS.IDENTITY_RESET('tt_VisionPlus1_8');

   INSERT INTO tt_VisionPlus1_8 ( 
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
             LEFT JOIN tt_CorporateCustID_8 CC   ON a.RefCustomerID = CC.RefCustomerID
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
     FROM tt_VisionPlus1_8 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   IF utils.object_id('TempDB..tt_AssetClass_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AssetClass_8 ';
   END IF;
   DELETE FROM tt_AssetClass_8;
   UTILS.IDENTITY_RESET('tt_AssetClass_8');

   INSERT INTO tt_AssetClass_8 ( 
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
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  
       FROM ( SELECT * 
              FROM ( SELECT A.Corporate_Customer_ID CustomerID  ,
                            A.SourceAlt_Key ,
                            SourceName 

                     -- Select 'VisionPlusDataList' as TableName, CustomerID ,CONVERT(varchar,NPADate,103) as ENPADate,'Degrade' [Type] 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'VisionPlus'
                               AND A.AssetSubClass <> 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 
                     SELECT a.Corporate_Customer_ID CustomerID  ,
                            a.SourceAlt_Key ,
                            SourceName 
                     FROM ReverseFeedData A
                            JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                            AND B.EffectiveFromTimeKey <= v_TimeKey
                            AND B.EffectiveToTimeKey >= v_TimeKey
                      WHERE  B.SourceName = 'VisionPlus'
                               AND A.AssetSubClass = 'STD'
                               AND A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                     UNION 

                     -----------Added on 04/04/2022  
                     SELECT CorporateCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM tt_VisionPlus1_8 A
                            JOIN tt_AssetClass_8 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                      WHERE  A.BankAssetClass = 1
                               AND A.FinalAssetClassAlt_Key > 1
                     UNION 
                     SELECT CorporateCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM tt_VisionPlus1_8 A
                            JOIN tt_AssetClass_8 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key = 1
                     UNION 
                     SELECT CorporateCustomerID CustomerID  ,
                            SourceAlt_Key ,
                            SourceName 
                     FROM tt_VisionPlus1_8 A
                            JOIN tt_AssetClass_8 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                      WHERE  A.BankAssetClass > 1
                               AND A.FinalAssetClassAlt_Key > 1
                               AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                               OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A
                GROUP BY CustomerID,SourceAlt_Key,SourceName ) B
         GROUP BY SourceAlt_Key,SourceName );
   --------------MetaGrid----------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_MetaGrid_69') IS NOT NULL THEN
    --  Declare @TimeKey as Int=26460   
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey=@TimeKey)    
   --Declare @TimeKey as Int =(Select distinct TimeKey from Automate_Advances where Timekey =26298 )          
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey =26298 )          
   --Declare @TimeKey AS INT =26298          
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MetaGrid_69 ';
   END IF;
   DELETE FROM tt_MetaGrid_69;
   UTILS.IDENTITY_RESET('tt_MetaGrid_69');

   INSERT INTO tt_MetaGrid_69 ( 
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
     FROM tt_MetaGrid_69 a
            JOIN ReverseFeedData b   ON A.RefCustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   INSERT INTO tt_temp1_28
     ( SELECT SourceAlt_Key ,
              SourceName ,
              COUNT(*)  cnt  
       FROM ( SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     E.SrcSysClassCode ENPA_ASSET_CODE  ,
                     CASE 
                          WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                     ELSE E.SrcSysClassName
                        END ENPA_DESCRIPTION  ,
                     REPLACE(UTILS.CONVERT_TO_VARCHAR2(DateofData,20,p_style=>105), '-', ' ') ENPA_ASSET_CODE_DATE  ,
                     CASE 
                          WHEN A.AssetSubClass <> 'STD' THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,20,p_style=>105), '-', ' ')
                     ELSE NULL
                        END ENPA_D2K_NPA_DATE  ,
                     A.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.AssetClass = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MetaGrid'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              ------Changes for NPADate on 22/04/2022

              --Select A.RefCustomerID as 'CIF ID' ,A.UCIF_ID as 'UCIC',NULL As 'Asset Classification',Replace(convert(varchar(20),A.SysNPA_Dt,105),'-','') as 'ENPA_D2K_NPA_DATE'
              SELECT A.RefCustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     E.SrcSysClassCode ENPA_ASSET_CODE  ,
                     CASE 
                          WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                     ELSE E.SrcSysClassName
                        END ENPA_DESCRIPTION  ,
                     REPLACE(v_Date, '-', ' ') ENPA_ASSET_CODE_DATE  ,
                     CASE 
                          WHEN A.SysAssetClassAlt_Key <> 1 THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.SysNPA_Dt,20,p_style=>105), '-', ' ')
                     ELSE NULL
                        END ENPA_D2K_NPA_DATE  ,
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
              FROM tt_MetaGrid_69 A
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
              FROM tt_MetaGrid_69 A
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
              SELECT A.CustomerID CIF_ID  ,
                     A.UCIF_ID UCIC  ,
                     E.SrcSysClassCode ENPA_ASSET_CODE  ,
                     CASE 
                          WHEN E.AssetClassGroup = 'NPA' THEN 'Non Performing'
                     ELSE E.SrcSysClassName
                        END ENPA_DESCRIPTION  ,
                     REPLACE(v_Date, '-', ' ') ENPA_ASSET_CODE_DATE  ,
                     CASE 
                          WHEN A.AssetClass <> 1 THEN REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,20,p_style=>105), '-', ' ')
                     ELSE NULL
                        END ENPA_D2K_NPA_DATE  ,
                     a.SourceAlt_Key ,
                     SourceName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
                     JOIN DimAssetClass E   ON A.AssetClass = E.AssetClassAlt_Key
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'MetaGrid'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

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
              FROM tt_MetaGrid_69 A
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
   INSERT INTO tt_temp1_28
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
   --select * from tt_temp1_28          
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RERF a
          JOIN tt_temp1_28 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.ACL = src.CNT;
   UPDATE StatusReport_RERF
      SET ACL = 0
    WHERE  ACL IS NULL;
   --update StatusReport          
   --set    Total_RF_ACL_Status= case when Total_ACL_Count=Total_ACL_RF_Count then 'True'          
   --         else 'False' end          
   StatusReport_CountWise_Degrade_Tracker_RERF_TOTAL() ;
   StatusReport_CountWise_Upgrade_Tracker_RERF_TOTAL() ;
   --select replace(convert(varchar(11),@Date,113),'','-') 'RF Count Date'          
   --select  replace(convert(varchar(10),@Date,103),'/','-') 'RF Data file dated'          
   -- update a   
   -- set a.ACL=b.ACL,a.Degrade=b.Degrade,a.Upgrade=b.Upgrade  
   -- from StatusReport_RERF a     
   -- inner join  StatusReport_RF b  
   --on  a.SourceAlt_Key=b.SourceAlt_Key  
   ------------------------------------------------------------------------------------------------------------------------------------
   --update  StatusReport_RERF
   --set ACL='26',Degrade='31',Upgrade='27'
   --where SourceAlt_Key=1
   --update  StatusReport_RERF
   --set ACL='17',Degrade='21',Upgrade='5'
   --where SourceAlt_Key=2
   --update  StatusReport_RERF
   --set ACL='0',Degrade='1',Upgrade='0'
   --where SourceAlt_Key=3
   --update  StatusReport_RERF
   --set ACL='15898',Degrade='8564',Upgrade='123'
   --where SourceAlt_Key=5
   --update  StatusReport_RERF
   --set ACL='2240',Degrade='2460',Upgrade='342'
   --where SourceAlt_Key=6
   --update  StatusReport_RERF
   --set ACL='0',Degrade='1',Upgrade='0'
   --where SourceAlt_Key in (4)
   --update  StatusReport_RERF
   --set ACL='0',Degrade='0',Upgrade='0'
   --where SourceAlt_Key in (7,8)
   ------------------------------------------------------------------------------------------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT SourceName ,
             ACL ,
             Degrade ,
             Upgrade 
        FROM StatusReport_RERF 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_RERF_TOTAL" TO "ADF_CDR_RBL_STGDB";
