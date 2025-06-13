--------------------------------------------------------
--  DDL for Procedure REVERSEFEEDDATA_ACLRERF_SELECT_27042023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(Date_,200) 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --DECLARE @TimeKey INT=26505,@Date DATE='2022-07-26'
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT * 
        FROM ( 
               --SELECT CONVERT(VARCHAR(10),DateofData,103) DateofData,CustomerID,AccountId,SourceSystemName,ReverseFeedType,AssetClass,CONVERT(VARCHAR(10),NPADate,103) NPADate,CONVERT(VARCHAR(10),UpgradeDate,103) UpgradeDate,AssetType FROM
               SELECT A.DateofData ,
                      A.CustomerID ,
                      NULL AccountId  ,
                      A.SourceSystemName ,
                      'NORMAL' ReverseFeedType  ,
                      B.AssetClassShortName AssetClass  ,
                      A.NPADate ,
                      CASE 
                           WHEN ( B.AssetClassShortName = 'STD'
                             AND NVL(A.NPADate, ' ') = ' '
                             AND NVL(A.UpgradeDate, ' ') = ' ' ) THEN v_Date
                      ELSE A.UpgradeDate
                         END UpgradeDate  ,
                      'ACL' AssetType  
               FROM ReverseFeedData A
                      LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassAlt_Key
                      AND ( B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey )
                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey )
                         AND UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date
               UNION 
               SELECT A.ProcessDate DateofData  ,
                      A.CustomerID ,
                      NULL AccountId  ,
                      A.SourceName SourceSystemName  ,
                      'RERF' ReverseFeedType  ,
                      B.AssetClassShortName AssetClass  ,
                      A.FinalNpaDt NPADate  ,
                      CASE 
                           WHEN ( B.AssetClassShortName = 'STD'
                             AND NVL(A.FinalNpaDt, ' ') = ' '
                             AND NVL(A.UpgradeDate, ' ') = ' ' ) THEN v_Date
                      ELSE A.UpgradeDate
                         END UpgradeDate  ,
                      'ACL' AssetType  
               FROM ReverseFeedDataInsertSync_Customer A
                      LEFT JOIN DimAssetClass B   ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
                      AND ( B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey )
                WHERE  UTILS.CONVERT_TO_VARCHAR2(A.ProcessDate,200) = v_Date
                         AND A.CustomerID NOT IN ( SELECT CustomerId 
                                                   FROM ReverseFeedData 
                                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                             AND EffectiveToTimeKey >= v_TimeKey )
                                                             AND UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date )

               UNION 
               SELECT A.DateofData ,
                      A.CustomerID ,
                      A.AccountID ,
                      A.SourceSystemName ,
                      'NORMAL' ReverseFeedType  ,
                      B.AssetClassShortName AssetClass  ,
                      A.NPADate ,
                      CASE 
                           WHEN ( B.AssetClassShortName = 'STD'
                             AND NVL(A.NPADate, ' ') = ' '
                             AND NVL(A.UpgradeDate, ' ') = ' ' ) THEN v_Date
                      ELSE A.UpgradeDate
                         END UpgradeDate  ,
                      'DEGRADE' AssetType  
               FROM ReverseFeedData A
                      LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassAlt_Key
                      AND ( B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey )
                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey )
                         AND UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date
                         AND A.AssetClass > 1
               UNION 
               SELECT DISTINCT A.ProcessDate DateofData  ,
                               C.RefCustomerId CustomerId  ,
                               A.CustomerAcID AccountId  ,
                               A.SourceName SourceSystemName  ,
                               'RERF' ReverseFeedType  ,
                               B.AssetClassShortName AssetClass  ,
                               A.FinalNpaDt NPADate  ,
                               CASE 
                                    WHEN ( B.AssetClassShortName = 'STD'
                                      AND NVL(A.FinalNpaDt, ' ') = ' '
                                      AND NVL(A.UpgradeDate, ' ') = ' ' ) THEN v_Date
                               ELSE A.UpgradeDate
                                  END UpgradeDate  ,
                               'DEGRADE' AssetType  
               FROM ReverseFeedDataInsertSync A
                      LEFT JOIN DimAssetClass B   ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
                      AND ( B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey )
                      LEFT JOIN AdvAcBasicDetail C   ON A.CustomerAcID = C.CustomerACID
                      AND ( C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey )
                WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date
                         AND A.FinalAssetClassAlt_Key > 1
                         AND A.CustomerAcID NOT IN ( SELECT AccountID 
                                                     FROM ReverseFeedData 
                                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey )
                                                               AND UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date
                                                               AND AssetClass > 1 )

               UNION 
               SELECT A.DateofData ,
                      A.CustomerID ,
                      A.AccountID ,
                      A.SourceSystemName ,
                      'NORMAL' ReverseFeedType  ,
                      B.AssetClassShortName AssetClass  ,
                      A.NPADate ,
                      CASE 
                           WHEN ( B.AssetClassShortName = 'STD'
                             AND NVL(A.NPADate, ' ') = ' '
                             AND NVL(A.UpgradeDate, ' ') = ' ' ) THEN v_Date
                      ELSE A.UpgradeDate
                         END UpgradeDate  ,
                      'UPGRADE' AssetType  
               FROM ReverseFeedData A
                      LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassAlt_Key
                      AND ( B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey )
                WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey )
                         AND UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date
                         AND A.AssetClass = 1
               UNION 
               SELECT DISTINCT A.ProcessDate DateofData  ,
                               C.RefCustomerId CustomerId  ,
                               A.CustomerAcID AccountId  ,
                               A.SourceName SourceSystemName  ,
                               'RERF' ReverseFeedType  ,
                               B.AssetClassShortName AssetClass  ,
                               A.FinalNpaDt NPADate  ,
                               CASE 
                                    WHEN ( B.AssetClassShortName = 'STD'
                                      AND NVL(A.FinalNpaDt, ' ') = ' '
                                      AND NVL(A.UpgradeDate, ' ') = ' ' ) THEN v_Date
                               ELSE A.UpgradeDate
                                  END UpgradeDate  ,
                               'UPGRADE' AssetType  
               FROM ReverseFeedDataInsertSync A
                      LEFT JOIN DimAssetClass B   ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
                      AND ( B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey )
                      LEFT JOIN AdvAcBasicDetail C   ON A.CustomerAcID = C.CustomerACID
                      AND ( C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey )
                WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date
                         AND A.FinalAssetClassAlt_Key = 1
                         AND A.CustomerAcID NOT IN ( SELECT AccountID 
                                                     FROM ReverseFeedData 
                                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey )
                                                               AND UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date
                                                               AND AssetClass = 1 )
              ) A
        ORDER BY 9 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATA_ACLRERF_SELECT_27042023" TO "ADF_CDR_RBL_STGDB";
