--------------------------------------------------------
--  DDL for Procedure GETFISDATA_24102022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETFISDATA_24102022" 
AS
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

   --------------FIS
   ----------Added on 04/04/2022  
   IF utils.object_id('TempDB..tt_FIS_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FIS_6 ';
   END IF;
   DELETE FROM tt_FIS_6;
   UTILS.IDENTITY_RESET('tt_FIS_6');

   INSERT INTO tt_FIS_6 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           A.CustomerAcID AccountID  ,
           A.FinalAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.FinalNpaDt NPADate  ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
             AND B.EffectiveFromTimeKey <= v_Timekey
             AND B.EffectiveToTimeKey >= v_Timekey
             JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
             AND DS.EffectiveFromTimeKey <= v_Timekey
             AND DS.EffectiveToTimeKey >= v_Timekey
             AND DS.SourceAlt_Key = 5
             JOIN DimAssetClassMapping DA   ON DA.SrcSysClassCode = B.SourceAssetClass
             AND A.SourceAlt_Key = DA.SourceAlt_Key
             AND DA.EffectiveFromTimeKey <= v_Timekey
             AND DA.EffectiveToTimeKey >= v_Timekey
   	 WHERE  DS.SourceName = 'FIS'
              AND NOT EXISTS ( SELECT * 
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
     FROM tt_FIS_6 a
            JOIN ReverseFeedData b   ON A.AccountID = b.AccountID,
          A
    WHERE  b.DateofData = v_Date );
   ----------------------------  
   --SELECT * from ReverseFeedData where sourcealt_key=5 order by dateofdata desc select * from dimsourcedb
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TEMP_25  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_TEMP_25;
   UTILS.IDENTITY_RESET('tt_TEMP_25');

   INSERT INTO tt_TEMP_25 ( 
   	SELECT * 
   	  FROM ( SELECT (UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_NUMBER(SUBSTR(CustomerID, 2, 50),18),30) || '|' || AccountID || '|' || CASE 
                                                                                                                                            WHEN AssetClass = 1 THEN '01/01/1900'
                    ELSE NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103), ' ')
                       END || '|' || CASE 
                                          WHEN AssetClass = 1 THEN '0'
                                          WHEN AssetClass = 2 THEN '4'
                                          WHEN AssetClass = 3 THEN '5'
                                          WHEN AssetClass = 4 THEN '6'
                                          WHEN AssetClass = 5 THEN '7'
                                          WHEN AssetClass = 6 THEN '8'
                                          WHEN AssetClass = 7 THEN '9'
                    ELSE '10'
                       END) DATA  
             FROM ReverseFeedData A
                    JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
              WHERE  B.SourceName = 'FIS'
                       AND A.AssetSubClass <> 'STD'
                       AND A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
             UNION 
             SELECT (UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_NUMBER(SUBSTR(CustomerID, 2, 50),18),30) || '|' || AccountID || '|' || CASE 
                                                                                                                                            WHEN AssetClass = 1 THEN '01/01/1900'
                    ELSE NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103), '   ')
                       END || '|' || CASE 
                                          WHEN AssetClass = 1 THEN '0'
                                          WHEN AssetClass = 2 THEN '4'
                                          WHEN AssetClass = 3 THEN '5'
                                          WHEN AssetClass = 4 THEN '6'
                                          WHEN AssetClass = 5 THEN '7'
                                          WHEN AssetClass = 6 THEN '8'
                                          WHEN AssetClass = 7 THEN '9'
                    ELSE '10'
                       END) DATA  
             FROM ReverseFeedData A
                    JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                    AND B.EffectiveFromTimeKey <= v_TimeKey
                    AND B.EffectiveToTimeKey >= v_TimeKey
              WHERE  B.SourceName = 'FIS'
                       AND A.AssetSubClass = 'STD'
                       AND A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
             UNION 

             -----------Added on 04/04/2022  
             SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_NUMBER(SUBSTR(CustomerID, 2, 50),18),30) || '|' || AccountID || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103), '   ') || '|' || UTILS.CONVERT_TO_VARCHAR2(A.FinalAssetClassAlt_Key,30) 
             FROM tt_FIS_6 A
              WHERE  A.BankAssetClass = 1
                       AND A.FinalAssetClassAlt_Key > 1
             UNION 
             SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_NUMBER(SUBSTR(CustomerID, 2, 50),18),30) || '|' || AccountID || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103), '   ') || '|' || UTILS.CONVERT_TO_VARCHAR2(A.FinalAssetClassAlt_Key,30) 
             FROM tt_FIS_6 A
              WHERE  A.BankAssetClass > 1
                       AND A.FinalAssetClassAlt_Key = 1
             UNION 
             SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_NUMBER(SUBSTR(CustomerID, 2, 50),18),30) || '|' || AccountID || '|' || NVL(UTILS.CONVERT_TO_VARCHAR2(NPADate,10,p_style=>103), '   ') || '|' || UTILS.CONVERT_TO_VARCHAR2(A.FinalAssetClassAlt_Key,30) 
             FROM tt_FIS_6 A
              WHERE  A.BankAssetClass > 1
                       AND A.FinalAssetClassAlt_Key > 1
                       AND NVL(A.NPADate, ' ') <> NVL(A.SourceNpaDate, ' ') ) T );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_TEMP_25  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETFISDATA_24102022" TO "ADF_CDR_RBL_STGDB";
