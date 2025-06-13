--------------------------------------------------------
--  DDL for Procedure SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" 
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
         SELECT 'FinacleAssetClassification' TableName  ,
                A.CustomerID || '|' || A.UCIF_ID || '|' || E.AssetClassShortNameEnum || '|' || E.AssetClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105) || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105) DataUtility  
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
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Ganaseva' ) THEN

   BEGIN
      --------------Ganaseva
      OPEN  v_cursor FOR
         SELECT 'GanasevaAssetClassification' TableName  ,
                A.UCIF_ID || '|' || A.CustomerID || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>103) || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DataUtility  
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
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'ECBF' ) THEN

   BEGIN
      --------------ECBF
      OPEN  v_cursor FOR
         SELECT A.CustomerID CustomerID  ,
                A.UCIF_ID UCIC  ,
                E.SrcSysClassCode Asset_Code  ,
                E.SrcSysClassName DESCRIPTION  ,
                UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105) Asset_Code_Date  ,
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
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'Indus' ) THEN

   BEGIN
      --------------Indus
      OPEN  v_cursor FOR
         SELECT E.AssetClassShortNameEnum asset_code  ,
                E.SrcSysClassName DESCRIPTION  ,
                UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105) asset_code_date  ,
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
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   IF ( v_SourceType = 'MiFin' ) THEN

   BEGIN
      --------------MiFin
      OPEN  v_cursor FOR
         SELECT A.CustomerID ,
                A.UCIF_ID ,
                E.AssetClassShortNameEnum ,
                E.AssetClassName ,
                REPLACE(UTILS.CONVERT_TO_VARCHAR2(A.NPADate,20,p_style=>106), ' ', '-') Asset_Code_Date  ,
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
                   AND A.EffectiveToTimeKey >= v_TimeKey ;
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
                  UNION ALL 
                  SELECT 'VisionPlusAssetClassification' TableName  ,
                         (A.UCIF_ID || '|' || A.CustomerID || '|' || E.SrcSysClassCode || '|' || E.SrcSysClassName || '|' || UTILS.CONVERT_TO_VARCHAR2(A.NPADate,10,p_style=>105) || '|' || UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>105)) DataUtility  
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SELECTASSETCLASSIFICATIONSOURCETYPEDATAFORUTILITY_09072021" TO "ADF_CDR_RBL_STGDB";
