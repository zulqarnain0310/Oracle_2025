--------------------------------------------------------
--  DDL for Procedure SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT v_Date ,
             DB.SourceName Host_System_Name  ,
             NVL(NPA, 0) NPA  ,
             NVL(STD, 0) STD  ,
             NVL(CR_Zero_Balances, 0) CR_Zero_Balances  ,
             NVL(Closed, 0) Closed  ,
             (SUM(NVL(NPA, 0))  + SUM(NVL(STD, 0))  + SUM(NVL(CR_Zero_Balances, 0))  + SUM(NVL(Closed, 0)) ) Total  
        FROM DIMSOURCEDB DB
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) NPA  
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedData B   ON A.Account_No = B.AccountID
                                  AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = UTILS.CONVERT_TO_VARCHAR2(B.DateofData,200)
                            WHERE
                           --Host_System_Name = 'Finacle' and
                             Main_Classification = 'NPA'
                               AND B.AssetClass > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) A   ON A.Host_System_Name = DB.SourceName
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) STD  
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedData B   ON A.Account_No = B.AccountID
                                  AND A.Report_Date = B.DateofData
                                  JOIN AdvAcBasicDetail C   ON B.AccountID = C.CustomerACID
                                  AND C.EffectiveToTimeKey = 49999
                                  JOIN AdvAcBalanceDetail D   ON C.AccountEntityId = D.AccountEntityId
                                  AND D.EffectiveToTimeKey = 49999
                            WHERE
                           --Host_System_Name = 'Finacle' and
                             Main_Classification = 'STD'
                               AND NVL(D.SignBalance, 0) != 0
                               AND Closed_Date IS NULL
                               AND B.AssetClass > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) B   ON DB.SourceName = B.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) CR_Zero_Balances  
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedData B   ON A.Account_No = B.AccountID
                                  AND A.Report_Date = B.DateofData
                                  JOIN AdvAcBasicDetail C   ON B.AccountID = C.CustomerACID
                                  AND C.EffectiveToTimeKey = 49999
                                  JOIN AdvAcBalanceDetail D   ON C.AccountEntityId = D.AccountEntityId
                                  AND D.EffectiveToTimeKey = 49999
                            WHERE
                           --Host_System_Name = 'Finacle' and 
                            --Main_Classification is NULL
                             Main_Classification = 'STD'
                               AND NVL(D.SignBalance, 0) = 0
                               AND B.AssetClass > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) C   ON DB.SourceName = C.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) Closed  
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedData B   ON A.Account_No = B.AccountID
                                  AND A.Report_Date = B.DateofData
                            WHERE  Main_Classification = 'STD'
                                     AND Closed_Date IS NOT NULL
                                     AND B.AssetClass > 1
                                     AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) D   ON DB.SourceName = D.Host_System_Name
       WHERE  DB.SourceName != 'VisionPlus'
        GROUP BY DB.SourceName,NPA,STD,CR_Zero_Balances,Closed ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_03022022_OLD" TO "ADF_CDR_RBL_STGDB";
