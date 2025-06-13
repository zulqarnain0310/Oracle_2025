--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_TRACKER_BKP03032023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(Date_,200) 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   -------------------------- Calypso ACL COUNT START --------------------------------------------------------------
   v_CalypsoACLCount NUMBER(10,0);
   -------------------------- Calypso ACL COUNT END --------------------------------------------------------------
   -------------------------- Calypso DEGRADE COUNT START --------------------------------------------------------------
   v_CalypsoDegradeCount NUMBER(10,0);
   -------------------------- Calypso DEGRADE COUNT END --------------------------------------------------------------
   -------------------------- Calypso UPGRADE COUNT START --------------------------------------------------------------
   v_CalypsoUpgradeCount NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_RF ';
   INSERT INTO StatusReport_RF
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
      WHERE  EffectiveToTimeKey = 49999
       ORDER BY SourceAlt_Key;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_Only_RERF ';
   INSERT INTO StatusReport_Only_RERF
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
      WHERE  EffectiveToTimeKey = 49999
       ORDER BY SourceAlt_Key;
   --DECLARE @TimeKey INT=26545,@Date DATE='2022-09-04'
   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport_RERF ';
   INSERT INTO StatusReport_RERF
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
      WHERE  EffectiveToTimeKey = 49999
       ORDER BY SourceAlt_Key;
   ----------------------------------------------------ACL Count---------------------------------------------------------------------------------
   MERGE INTO b 
   USING (SELECT b.ROWID row_id, A.CNT
   FROM b ,( SELECT ReverseFeedData.SourceAlt_Key ,
                    ReverseFeedData.SourceSystemName ,
                    COUNT(DISTINCT ReverseFeedData.CustomerID)  CNT  
             FROM ReverseFeedData 
              WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
               GROUP BY ReverseFeedData.SourceAlt_Key,ReverseFeedData.SourceSystemName ) a
          JOIN StatusReport_RF b   ON A.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( b.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET b.ACL = src.CNT;
   UPDATE StatusReport_RF
      SET ACL = ( SELECT COUNT(DISTINCT ReverseFeedData.CustomerID)  CNT  
                  FROM ReverseFeedData 
                   WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                            AND ReverseFeedData.SourceAlt_Key = 3 )
    WHERE  SourceAlt_Key = 3;
   MERGE INTO bb 
   USING (SELECT bb.ROWID row_id, aa.CNT
   FROM bb ,( SELECT b.SourceAlt_Key ,
                     A.SourceName ,
                     COUNT(DISTINCT A.CustomerID)  CNT  
              FROM ( SELECT ReverseFeedDataInsertSync_Customer.SourceName ,
                            ReverseFeedDataInsertSync_Customer.CustomerID 
                     FROM ReverseFeedDataInsertSync_Customer 
                      WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync_Customer.ProcessDate,200) = v_Date
                     MINUS 
                     SELECT ReverseFeedData.SourceSystemName ,
                            ReverseFeedData.CustomerID 
                     FROM ReverseFeedData 
                      WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date ) A
                     JOIN DIMSOURCEDB b   ON A.SourceName = b.SourceName
                GROUP BY A.SourceAlt_Key,A.SourceName ) AA
          JOIN StatusReport_Only_RERF BB   ON aa.SourceAlt_Key = bb.SourceAlt_Key ) src
   ON ( bb.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET bb.ACL = src.CNT;
   UPDATE StatusReport_Only_RERF
      SET ACL = ( SELECT COUNT(DISTINCT A.CustomerID)  CNT  
                  FROM ( SELECT ReverseFeedDataInsertSync_Customer.SourceName ,
                                ReverseFeedDataInsertSync_Customer.CustomerID 
                         FROM ReverseFeedDataInsertSync_Customer 
                          WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync_Customer.ProcessDate,200) = v_Date
                                   AND ReverseFeedDataInsertSync_Customer.SourceName = 'ECBF'
                         MINUS 
                         SELECT ReverseFeedData.SourceSystemName ,
                                ReverseFeedData.CustomerID 
                         FROM ReverseFeedData 
                          WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                                   AND ReverseFeedData.SourceAlt_Key = 3 ) A
                         JOIN DIMSOURCEDB b   ON A.SourceName = b.SourceName )
    WHERE  SourceAlt_Key = 3;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.CNT
   FROM B ,( SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(DISTINCT CustomerID)  CNT  
             FROM ReverseFeedDataInsertSync_Customer a
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date
               GROUP BY SourceAlt_Key,a.SourceName ) A
          JOIN StatusReport_RERF B   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.ACL = src.CNT;
   UPDATE StatusReport_RERF
      SET ACL = ( SELECT COUNT(DISTINCT ReverseFeedDataInsertSync_Customer.CustomerID)  CNT  
                  FROM ReverseFeedDataInsertSync_Customer 
                   WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync_Customer.ProcessDate,200) = v_Date
                            AND ReverseFeedDataInsertSync_Customer.SourceName = 'ECBF' )
    WHERE  SourceAlt_Key = 3;
   --------------------------------------------------------Degrade Count--------------------------------------------
   MERGE INTO b 
   USING (SELECT b.ROWID row_id, A.CNT
   FROM b ,( SELECT ReverseFeedData.SourceAlt_Key ,
                    ReverseFeedData.SourceSystemName ,
                    COUNT(*)  CNT  
             FROM ReverseFeedData 
              WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                       AND ReverseFeedData.AssetClass > 1
               GROUP BY ReverseFeedData.SourceAlt_Key,ReverseFeedData.SourceSystemName ) a
          JOIN StatusReport_RF b   ON A.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( b.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET b.Degrade = src.CNT;
   UPDATE StatusReport_RF
      SET Degrade = ( SELECT COUNT(DISTINCT B.RefCustomerID)  
                      FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                             JOIN ( SELECT ReverseFeedData.AccountID 
                                    FROM ReverseFeedData 
                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                                              AND ReverseFeedData.SourceAlt_Key = 3
                                              AND ReverseFeedData.AssetClass > 1 ) B   ON A.CustomerAcID = B.AccountID
                       WHERE  a.EffectiveFromTimeKey <= v_TimeKey
                                AND a.EffectiveToTimeKey >= v_TimeKey )
    WHERE  SourceAlt_Key = 3;
   MERGE INTO bb 
   USING (SELECT bb.ROWID row_id, aa.CNT
   FROM bb ,( SELECT b.SourceAlt_Key ,
                     A.SourceName ,
                     COUNT(*)  CNT  
              FROM ( SELECT ReverseFeedDataInsertSync.SourceName ,
                            ReverseFeedDataInsertSync.CustomerAcID 
                     FROM ReverseFeedDataInsertSync 
                      WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync.ProcessDate,200) = v_Date
                               AND ReverseFeedDataInsertSync.FinalAssetClassAlt_Key > 1
                     MINUS 
                     SELECT ReverseFeedData.SourceSystemName ,
                            ReverseFeedData.AccountID 
                     FROM ReverseFeedData 
                      WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                               AND ReverseFeedData.AssetClass > 1 ) A
                     JOIN DIMSOURCEDB b   ON A.SourceName = b.SourceName
                GROUP BY A.SourceAlt_Key,A.SourceName ) AA
          JOIN StatusReport_Only_RERF BB   ON aa.SourceAlt_Key = bb.SourceAlt_Key ) src
   ON ( bb.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET bb.Degrade = src.CNT;
   UPDATE StatusReport_Only_RERF
      SET Degrade = ( SELECT COUNT(DISTINCT B.RefCustomerID)  CNT  
                      FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                             JOIN ( SELECT ReverseFeedDataInsertSync.CustomerAcID 
                                    FROM ReverseFeedDataInsertSync 
                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync.ProcessDate,200) = v_Date
                                              AND ReverseFeedDataInsertSync.SourceName = 'ECBF'
                                              AND ReverseFeedDataInsertSync.FinalAssetClassAlt_Key > 1
                                    MINUS 
                                    SELECT ReverseFeedData.AccountID CustomerAcID  
                                    FROM ReverseFeedData 
                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                                              AND ReverseFeedData.SourceSystemName = 'ECBF'
                                              AND ReverseFeedData.AssetClass > 1 ) B   ON A.CustomerAcID = B.CustomerAcID
                       WHERE  a.EffectiveFromTimeKey <= v_TimeKey
                                AND a.EffectiveToTimeKey >= v_TimeKey )
    WHERE  SourceAlt_Key = 3;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.CNT
   FROM B ,( SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ReverseFeedDataInsertSync a
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date
                       AND FinalAssetClassAlt_Key > 1
               GROUP BY SourceAlt_Key,a.SourceName ) A
          JOIN StatusReport_RERF B   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.Degrade = src.CNT;
   UPDATE StatusReport_RERF
      SET Degrade = ( SELECT COUNT(DISTINCT B.RefCustomerID)  CNT  
                      FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                             JOIN ( SELECT DISTINCT ReverseFeedDataInsertSync.CustomerAcID 
                                    FROM ReverseFeedDataInsertSync 
                                     WHERE  ReverseFeedDataInsertSync.SourceName = 'ECBF'
                                              AND ReverseFeedDataInsertSync.ProcessDate = v_Date
                                              AND ReverseFeedDataInsertSync.FinalAssetClassAlt_Key > 1 ) B   ON A.CustomerAcID = B.CustomerAcID
                       WHERE  a.EffectiveFromTimeKey <= v_TimeKey
                                AND a.EffectiveToTimeKey >= v_TimeKey )
    WHERE  SourceAlt_Key = 3;
   ---------------------------------------------------Upgrade Count-------------------------------------------------------------------------
   MERGE INTO b 
   USING (SELECT b.ROWID row_id, A.CNT
   FROM b ,( SELECT ReverseFeedData.SourceAlt_Key ,
                    ReverseFeedData.SourceSystemName ,
                    COUNT(*)  CNT  
             FROM ReverseFeedData 
              WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                       AND ReverseFeedData.AssetClass = 1
               GROUP BY ReverseFeedData.SourceAlt_Key,ReverseFeedData.SourceSystemName ) a
          JOIN StatusReport_RF b   ON A.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( b.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET b.Upgrade = src.CNT;
   UPDATE StatusReport_RF
      SET Upgrade = ( SELECT COUNT(DISTINCT B.RefCustomerID)  
                      FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                             JOIN ( SELECT ReverseFeedData.AccountID 
                                    FROM ReverseFeedData 
                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                                              AND ReverseFeedData.SourceAlt_Key = 3
                                              AND ReverseFeedData.AssetClass = 1 ) B   ON A.CustomerAcID = B.AccountID
                       WHERE  a.EffectiveFromTimeKey <= v_TimeKey
                                AND a.EffectiveToTimeKey >= v_TimeKey )
    WHERE  SourceAlt_Key = 3;
   MERGE INTO bb 
   USING (SELECT bb.ROWID row_id, aa.CNT
   FROM bb ,( SELECT b.SourceAlt_Key ,
                     A.SourceName ,
                     COUNT(*)  CNT  
              FROM ( SELECT ReverseFeedDataInsertSync.SourceName ,
                            ReverseFeedDataInsertSync.CustomerAcID 
                     FROM ReverseFeedDataInsertSync 
                      WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync.ProcessDate,200) = v_Date
                               AND ReverseFeedDataInsertSync.FinalAssetClassAlt_Key = 1
                     MINUS 
                     SELECT ReverseFeedData.SourceSystemName ,
                            ReverseFeedData.AccountID 
                     FROM ReverseFeedData 
                      WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                               AND ReverseFeedData.AssetClass = 1 ) A
                     JOIN DIMSOURCEDB b   ON A.SourceName = b.SourceName
                GROUP BY A.SourceAlt_Key,A.SourceName ) AA
          JOIN StatusReport_Only_RERF BB   ON aa.SourceAlt_Key = bb.SourceAlt_Key ) src
   ON ( bb.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET bb.Upgrade = src.CNT;
   UPDATE StatusReport_Only_RERF
      SET Upgrade = ( SELECT COUNT(DISTINCT A.RefCustomerID)  CNT  
                      FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                             JOIN ( SELECT ReverseFeedDataInsertSync.CustomerAcID 
                                    FROM ReverseFeedDataInsertSync 
                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedDataInsertSync.ProcessDate,200) = v_Date
                                              AND ReverseFeedDataInsertSync.SourceName = 'ECBF'
                                              AND ReverseFeedDataInsertSync.FinalAssetClassAlt_Key = 1
                                    MINUS 
                                    SELECT ReverseFeedData.AccountID CustomerAcID  
                                    FROM ReverseFeedData 
                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(ReverseFeedData.DateofData,200) = v_Date
                                              AND ReverseFeedData.SourceSystemName = 'ECBF'
                                              AND ReverseFeedData.AssetClass = 1 ) B   ON A.CustomerAcID = B.CustomerAcID
                       WHERE  a.EffectiveFromTimeKey <= v_TimeKey
                                AND a.EffectiveToTimeKey >= v_TimeKey )
    WHERE  SourceAlt_Key = 3;
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, A.CNT
   FROM B ,( SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ReverseFeedDataInsertSync a
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDate,200) = v_Date
                       AND FinalAssetClassAlt_Key = 1
               GROUP BY SourceAlt_Key,a.SourceName ) A
          JOIN StatusReport_RERF B   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.Upgrade = src.CNT;
   UPDATE StatusReport_RERF
      SET Upgrade = ( SELECT COUNT(DISTINCT B.RefCustomerID)  
                      FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                             JOIN ( SELECT ReverseFeedDataInsertSync.CustomerAcID ,
                                           ReverseFeedDataInsertSync.FinalAssetClassAlt_Key 
                                    FROM ReverseFeedDataInsertSync 
                                     WHERE  ReverseFeedDataInsertSync.SourceName = 'ECBF'
                                              AND ReverseFeedDataInsertSync.ProcessDate = v_Date
                                              AND ReverseFeedDataInsertSync.FinalAssetClassAlt_Key = 1 ) B   ON A.CustomerAcID = B.CustomerAcID
                       WHERE  a.EffectiveFromTimeKey <= v_TimeKey
                                AND a.EffectiveToTimeKey >= v_TimeKey )
    WHERE  SourceAlt_Key = 3;
   SELECT COUNT(*)  

     INTO v_CalypsoACLCount
     FROM RBL_MISDB_PROD.InvestmentFinancialDetail A
            JOIN RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId
            AND B.EffectiveFromTimeKey <= v_Timekey
            AND B.EffectiveToTimeKey >= v_Timekey
            JOIN RBL_MISDB_PROD.InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
            AND C.EffectiveFromTimeKey <= v_Timekey
            AND C.EffectiveToTimeKey >= v_Timekey
            JOIN ReversefeedCalypso D   ON D.issuerId = C.IssuerID
            AND D.EffectiveFromTimeKey <= v_Timekey
            AND D.EffectiveToTimeKey >= v_Timekey
            JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
            AND E.EffectiveFromTimeKey <= v_Timekey
            AND E.EffectiveToTimeKey >= v_Timekey
    WHERE  A.EffectiveFromTimeKey <= v_Timekey
             AND A.EffectiveToTimeKey >= v_Timekey
             AND A.FinalAssetClassAlt_Key <> A.InitialAssetAlt_key;
   --PRINT @CalypsoACLCount
   UPDATE StatusReport_RF
      SET ACL = v_CalypsoACLCount
    WHERE  SourceName = 'Calypso';
   UPDATE StatusReport_RERF
      SET ACL = v_CalypsoACLCount
    WHERE  SourceName = 'Calypso';
   SELECT COUNT(*)  

     INTO v_CalypsoDegradeCount
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
             AND A.InitialAssetAlt_key = 1;
   UPDATE StatusReport_RF
      SET Degrade = v_CalypsoDegradeCount
    WHERE  SourceName = 'Calypso';
   UPDATE StatusReport_RERF
      SET Degrade = v_CalypsoDegradeCount
    WHERE  SourceName = 'Calypso';
   SELECT COUNT(*)  

     INTO v_CalypsoUpgradeCount
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
             AND A.FinalAssetClassAlt_Key = 1
             AND A.InitialAssetAlt_key <> 1;
   UPDATE StatusReport_RF
      SET Upgrade = v_CalypsoUpgradeCount
    WHERE  SourceName = 'Calypso';
   UPDATE StatusReport_RERF
      SET Upgrade = v_CalypsoUpgradeCount
    WHERE  SourceName = 'Calypso';
   -------------------------- Calypso UPGRADE COUNT END --------------------------------------------------------------
   --------------------------------------------------------------------------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT REPLACE(v_Date, ' ', '-') RF_Count_Date  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT REPLACE(v_Date, '/', '-') RF_Data_file_dated  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT CASE 
                  WHEN SourceName = 'Metagrid' THEN 'MetaGrid'
             ELSE SourceName
                END SourceName  ,
             NVL(ACL, 0) ACL  ,
             NVL(Degrade, 0) Degrade  ,
             NVL(Upgrade, 0) Upgrade  
        FROM StatusReport_RF 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT CASE 
                  WHEN SourceName = 'Metagrid' THEN 'MetaGrid'
             ELSE SourceName
                END SourceName  ,
             NVL(ACL, 0) ACL  ,
             NVL(Degrade, 0) Degrade  ,
             NVL(Upgrade, 0) Upgrade  
        FROM StatusReport_Only_RERF 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT CASE 
                  WHEN SourceName = 'Metagrid' THEN 'MetaGrid'
             ELSE SourceName
                END SourceName  ,
             NVL(ACL, 0) ACL  ,
             NVL(Degrade, 0) Degrade  ,
             NVL(Upgrade, 0) Upgrade  
        FROM StatusReport_RERF 
        ORDER BY Degrade DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_TRACKER_BKP03032023" TO "ADF_CDR_RBL_STGDB";
