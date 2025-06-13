--------------------------------------------------------
--  DDL for Procedure SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" 
-- dbo.SelectAssetClassificationSourceTypeDataForUtility 'MiFin'

(
  v_SourceType IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @TimeKey AS INT =26090--(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   IF ( v_SourceType = 'Finacle' ) THEN

   BEGIN
      --------------Finacle
      DBMS_OUTPUT.PUT_LINE('Finacle ');
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'FinacleAssetClassification' TableName  ,
                         A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DataUtility  
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
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           GROUP BY TableName,DataUtility ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'GanasevaAssetClassification' TableName  ,
                         A.UCIF_ID || '|' || SUBSTR(A.CustomerID, 2, 8) || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>103), ' ') || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DataUtility  
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
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           GROUP BY TableName,DataUtility ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT A.CustomerID CustomerID  ,
                         A.UCIF_ID UCIC  ,
                         E.SrcSysClassCode Asset_Code  ,
                         E.SrcSysClassName DESCRIPTION  ,
                         NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') Asset_Code_Date  ,
                         UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) D2KNpaDate  
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
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           GROUP BY CustomerID,UCIC,Asset_Code,DESCRIPTION,Asset_Code_Date,D2KNpaDate ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT E.AssetClassShortNameEnum asset_code  ,
                         E.SrcSysClassName DESCRIPTION  ,
                         NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') asset_code_date  ,
                         UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) D2K_NPA_date  ,
                         A.CustomerID Customer_ID  ,
                         A.UCIF_ID UCIC  
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
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           GROUP BY Asset_Code,DESCRIPTION,Asset_Code_Date,D2K_NPA_date,Customer_ID,UCIC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------MiFin
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT A.CustomerID ,
                         A.UCIF_ID ,
                         E.AssetClassShortNameEnum ,
                         E.AssetClassName ,
                         NVL(REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,20,p_style=>106), ' ', '-'), ' ') Asset_Code_Date  ,
                         REPLACE(UTILS.CONVERT_TO_VARCHAR2(DateofData,20,p_style=>106), ' ', '-') D2kNpaDate  
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
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           GROUP BY CustomerID,UCIF_ID,AssetClassShortNameEnum,AssetClassName,Asset_Code_Date,D2kNpaDate ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'VisionPlus' ) THEN

   BEGIN
      --------------VisionPlus
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT 'VisionPlusAssetClassification' TableName  ,
                         ('UCIC' || '|' || 'CIF ID' || '|' || 'asset_code' || '|' || 'description' || '|' || 'asset_code_date' || '|' || 'D2K NPA date') DataUtility  
                    FROM DUAL 
                  UNION 
                  SELECT 'VisionPlusAssetClassification' TableName  ,
                         (A.UCIF_ID || '|' || A.CustomerID || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105), ' ') || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105)) DataUtility  
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
                            AND A.EffectiveToTimeKey >= v_TimeKey ) A
           ORDER BY 2 DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021_NEW" TO "ADF_CDR_RBL_STGDB";
