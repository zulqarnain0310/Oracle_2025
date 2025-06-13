--------------------------------------------------------
--  DDL for Procedure GETVISIONPLUSDATA_05012024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" 
AS
   --Declare @TimeKey AS INT =26090--(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
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

   OPEN  v_cursor FOR
      SELECT TableName ,
             CustomerAcID ,
             NPADate ,
             Type 
        FROM ( SELECT 'VisionPlusDataList' TableName  ,
                      CustomerAcID ,
                      UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                      'Degrade' Type  
               FROM ReverseFeedDataInsertSync 
                WHERE  FinalAssetClassAlt_Key <> 1
                         AND ProcessDate = v_Date
                         AND SourceName = 'VisionPlus'
               UNION 
               SELECT 'VisionPlusDataList' TableName  ,
                      CustomerAcID ,
                      UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                      'Upgrade' Type  
               FROM ReverseFeedDataInsertSync 
                WHERE  FinalAssetClassAlt_Key = 1
                         AND ProcessDate = v_Date
                         AND SourceName = 'VisionPlus' ) B ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------------------------------------------------------------------------------------------
   IF utils.object_id('TempDB..tt_CorporateCustID_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CorporateCustID_3 ';
   END IF;
   DELETE FROM tt_CorporateCustID_3;
   UTILS.IDENTITY_RESET('tt_CorporateCustID_3');

   INSERT INTO tt_CorporateCustID_3 ( 
   	SELECT DISTINCT F.CorporateCustomerID ,
                    a.RefCustomerID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL a
             LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON A.AccountEntityID = F.AccountEntityID
             AND F.EffectiveFromTimekey <= v_TimeKey
             AND F.EffectiveToTimeKey >= v_TimeKey );
   IF utils.object_id('TempDB..#VisionPlus') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_3 ';
   END IF;
   DELETE FROM tt_VisionPlus1_3;
   UTILS.IDENTITY_RESET('tt_VisionPlus1_3');

   INSERT INTO tt_VisionPlus1_3 ( 
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
           CorporateCustomerID 
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
             LEFT JOIN tt_CorporateCustID_3 CC   ON a.RefCustomerID = CC.RefCustomerID
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
     FROM tt_VisionPlus1_3 a
            JOIN ReverseFeedData b   ON A.CustomerID = b.CustomerID,
          A
    WHERE  b.DateofData = v_Date );
   IF utils.object_id('TempDB..tt_AssetClass_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AssetClass_3 ';
   END IF;
   DELETE FROM tt_AssetClass_3;
   UTILS.IDENTITY_RESET('tt_AssetClass_3');

   INSERT INTO tt_AssetClass_3 ( 
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
   DELETE FROM tt_temp_155;
   UTILS.IDENTITY_RESET('tt_temp_155');

   INSERT INTO tt_temp_155 SELECT 'VisionPlusDataList' TableName  ,
                                  CustomerID ,
                                  AssetSubClass AssetCode  ,
                                  AssetCodeDate ,
                                  ENPADate ,
                                  'AssetClassification' Type  ,
                                  Customer_ID 
        FROM ( SELECT a.Corporate_Customer_ID CustomerID  ,
                      CASE 
                           WHEN LENGTH(A.AssetSubClass) = 3 THEN A.AssetSubClass
                      ELSE A.AssetSubClass || ' '
                         END AssetSubClass  ,
                      UTILS.CONVERT_TO_VARCHAR2(DateofData,30,p_style=>103) AssetCodeDate  ,
                      CASE 
                           WHEN NPADate IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(NPADate,30,p_style=>103)
                      ELSE '       '
                         END ENPADate  ,
                      A.CustomerID Customer_ID  

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
                      CASE 
                           WHEN LENGTH(A.AssetSubClass) = 3 THEN A.AssetSubClass
                      ELSE A.AssetSubClass || ' '
                         END AssetSubClass  ,
                      UTILS.CONVERT_TO_VARCHAR2(DateofData,30,p_style=>103) AssetCodeDate  ,
                      CASE 
                           WHEN NPADate IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(NPADate,30,p_style=>103)
                      ELSE '       '
                         END ENPADate  ,
                      A.CustomerID Customer_ID  
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
               SELECT a.CorporateCustomerID CustomerID  ,
                      CASE 
                           WHEN LENGTH(b.AssetSubClass) = 3 THEN b.AssetSubClass
                      ELSE b.AssetSubClass || ' '
                         END AssetSubClass  ,
                      v_Date AssetCodeDate  ,
                      CASE 
                           WHEN FinalNpaDt IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103)
                      ELSE '       '
                         END ENPADate  ,
                      A.CustomerID Customer_ID  
               FROM tt_VisionPlus1_3 A
                      JOIN tt_AssetClass_3 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                WHERE  A.BankAssetClass = 1
                         AND A.FinalAssetClassAlt_Key > 1
               UNION 
               SELECT a.CorporateCustomerID CustomerID  ,
                      CASE 
                           WHEN LENGTH(b.AssetSubClass) = 3 THEN b.AssetSubClass
                      ELSE b.AssetSubClass || ' '
                         END AssetSubClass  ,
                      v_Date AssetCodeDate  ,
                      CASE 
                           WHEN FinalNpaDt IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103)
                      ELSE '       '
                         END ENPADate  ,
                      A.CustomerID Customer_ID  
               FROM tt_VisionPlus1_3 A
                      JOIN tt_AssetClass_3 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                WHERE  A.BankAssetClass > 1
                         AND A.FinalAssetClassAlt_Key = 1
               UNION 
               SELECT a.CorporateCustomerID CustomerID  ,
                      CASE 
                           WHEN LENGTH(b.AssetSubClass) = 3 THEN b.AssetSubClass
                      ELSE b.AssetSubClass || ' '
                         END AssetSubClass  ,
                      v_Date AssetCodeDate  ,
                      CASE 
                           WHEN FinalNpaDt IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103)
                      ELSE '       '
                         END ENPADate  ,
                      A.CustomerID Customer_ID  
               FROM tt_VisionPlus1_3 A
                      JOIN tt_AssetClass_3 b   ON a.FinalAssetClassAlt_Key = b.AssetClassAlt_key
                WHERE  A.BankAssetClass > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND ( NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ')
                         OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) ) ) A
        ORDER BY 2;
   OPEN  v_cursor FOR
      SELECT A.TableName ,
             A.CustomerID ,
             A.AssetCode ,
             A.AssetCodeDate ,
             A.ENPADate ,
             A."TYPE" 
        FROM tt_temp_155 a
               JOIN ReverseFeedDataInsertSync_Customer B   ON a.Customer_ID = B.CustomerID
               AND B.ProcessDate = v_Date
               AND SourceName = 'VisionPlus'
       WHERE  A.CustomerID IS NOT NULL ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_05012024" TO "ADF_CDR_RBL_STGDB";
