--------------------------------------------------------
--  DDL for Procedure SP_FINALASSETCLASSCOUNTQUERY_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --------------Finacle
   --------------Indus
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DateofData  ,
             SourceSystemName ,
             COUNT(*)  AssetClassCount  
        FROM ( SELECT 'FinacleAssetClassification' TableName  ,
                      SourceSystemName ,
                      DateofData ,
                      A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                WHERE  B.SourceName = 'Finacle'
               UNION 
               SELECT 'FinacleAssetClassification' TableName  ,
                      SourceName ,
                      MonthLastDate ,
                      A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      JOIN SysDataMatrix F   ON A.EffectiveFromTimeKey = F.TimeKey
                WHERE  B.SourceName = 'Finacle'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key ) A
        GROUP BY DateofData,SourceSystemName
      UNION 
      SELECT UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DateofData  ,
             SourceSystemName ,
             COUNT(*)  IndusAssetcount  
        FROM ( SELECT 'IndusAssetClassification' TableName  ,
                      SourceSystemName ,
                      DateofData ,
                      A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                WHERE  B.SourceName = 'Indus'
               UNION 
               SELECT 'IndusAssetClassification' TableName  ,
                      SourceName ,
                      MonthLastDate ,
                      A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      JOIN SysDataMatrix F   ON A.EffectiveFromTimeKey = F.TimeKey
                WHERE  B.SourceName = 'Indus'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key ) A
        GROUP BY DateofData,SourceSystemName
      UNION 

      --------------MiFiN
      SELECT UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DateofData  ,
             SourceSystemName ,
             COUNT(*)  MiFinAssetcount  
        FROM ( SELECT 'MiFinAssetClassification' TableName  ,
                      SourceSystemName ,
                      DateofData ,
                      A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                WHERE  B.SourceName = 'MiFin'
               UNION 
               SELECT 'MiFinAssetClassification' TableName  ,
                      SourceName ,
                      MonthLastDate ,
                      A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      JOIN SysDataMatrix F   ON A.EffectiveFromTimeKey = F.TimeKey
                WHERE  B.SourceName = 'MiFin'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key ) A
        GROUP BY DateofData,SourceSystemName
      UNION 

      --------------VisionPlus
      SELECT UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DateofData  ,
             SourceSystemName ,
             COUNT(*)  VisionPlusAssetcount  
        FROM ( SELECT 'VisionPlusAssetClassification' TableName  ,
                      SourceSystemName ,
                      DateofData ,
                      A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                WHERE  B.SourceName = 'VisionPlus'
               UNION 
               SELECT 'VisionPlusAssetClassification' TableName  ,
                      SourceName ,
                      MonthLastDate ,
                      A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      JOIN SysDataMatrix F   ON A.EffectiveFromTimeKey = F.TimeKey
                WHERE  B.SourceName = 'VisionPlus'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key ) A
        GROUP BY DateofData,SourceSystemName
      UNION 

      --------------Ganaseva
      SELECT UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DateofData  ,
             SourceSystemName ,
             COUNT(*)  IndusAssetcount  
        FROM ( SELECT 'GanasevaAssetClassification' TableName  ,
                      SourceSystemName ,
                      DateofData ,
                      A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                WHERE  B.SourceName = 'Ganaseva'
               UNION 
               SELECT 'GanasevaAssetClassification' TableName  ,
                      SourceName ,
                      MonthLastDate ,
                      A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      JOIN SysDataMatrix F   ON A.EffectiveFromTimeKey = F.TimeKey
                WHERE  B.SourceName = 'Ganaseva'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key ) A
        GROUP BY DateofData,SourceSystemName
      UNION 

      --------------ECBF
      SELECT UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DateofData  ,
             SourceSystemName ,
             COUNT(*)  ECBFAssetcount  
        FROM ( SELECT 'ECBFAssetClassification' TableName  ,
                      SourceSystemName ,
                      DateofData ,
                      A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') DataUtility  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.AssetSubClass = E.SrcSysClassCode
                WHERE  B.SourceName = 'ECBF'
               UNION 
               SELECT 'ECBFAssetClassification' TableName  ,
                      SourceName ,
                      MonthLastDate ,
                      A.RefCustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(MonthLastDate,10,p_style=>105) || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>105), ' ') DataUtility  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_key
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      JOIN SysDataMatrix F   ON A.EffectiveFromTimeKey = F.TimeKey
                WHERE  B.SourceName = 'ECBF'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key ) A
        GROUP BY DateofData,SourceSystemName
        ORDER BY DateofData,
                 SourceSystemName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT Dateofdata ,
             SourceSystemName ,
             COUNT(1)  DegradeCount  
        FROM ReverseFeedData 
       WHERE  ASSETCLASS > 1
        GROUP BY Dateofdata,SourceSystemName
        ORDER BY Dateofdata,
                 SourceSystemName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT Dateofdata ,
             SourceSystemName ,
             COUNT(1)  UpgradeCount  
        FROM ReverseFeedData 
       WHERE  ASSETCLASS = 1
        GROUP BY Dateofdata,SourceSystemName
        ORDER BY Dateofdata,
                 SourceSystemName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_FINALASSETCLASSCOUNTQUERY_04122023" TO "ADF_CDR_RBL_STGDB";
