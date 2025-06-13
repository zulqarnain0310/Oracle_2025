--------------------------------------------------------
--  DDL for Procedure SP_HOSTSYSTEMSTATUSREPORT_UPGRADE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey );
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT v_Date ,
             CASE 
                  WHEN db.SourceName = 'Metagrid' THEN 'MetaGrid'
             ELSE db.SourceName
                END Host_System_Name  ,
             NVL(NPA, 0) NPA  ,
             NVL(STD, 0) STD  ,
             NVL(CR_Zero_Balances, 0) CR_Zero_Balances  ,
             NVL(Closed, 0) Closed  ,
             (SUM(NVL(NPA, 0))  + SUM(NVL(STD, 0))  + SUM(NVL(CR_Zero_Balances, 0))  + SUM(NVL(Closed, 0)) ) Total  
        FROM DIMSOURCEDB DB
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) STD  

                           -----------
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = UTILS.CONVERT_TO_VARCHAR2(B.ProcessDate,200)
                            WHERE  Main_Classification = 'STD'
                                     AND b.FinalAssetClassAlt_Key = 1
                                     AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) A   ON A.Host_System_Name = DB.SourceName
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) NPA  

                           -------------------------
                           FROM ENPA_Host_System_Status_tbl A
                                  LEFT JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND A.Report_Date = B.ProcessDate
                                  JOIN AdvAcBasicDetail C   ON B.CustomerAcID = C.CustomerACID

                                  --and C.EffectiveToTimeKey = 49999
                                  AND c.EffectiveFromTimeKey <= v_TimeKey
                                  AND c.EffectiveToTimeKey >= v_TimeKey
                                  JOIN AdvAcBalanceDetail D   ON C.AccountEntityId = D.AccountEntityId

                                  --and D.EffectiveToTimeKey = 49999
                                  AND D.EffectiveFromTimeKey <= v_TimeKey
                                  AND D.EffectiveToTimeKey >= v_TimeKey
                            WHERE  Main_Classification = 'NPA'
                                     AND NVL(D.SignBalance, 0) > 0
                                     AND NVL(Remarks, ' ') NOT IN ( 'CANCELLED','CLOSED' )

                                     AND b.FinalAssetClassAlt_Key = 1
                                     AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) B   ON DB.SourceName = B.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) CR_Zero_Balances  

                           -------
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND A.Report_Date = B.ProcessDate
                                  JOIN AdvAcBasicDetail C   ON B.CustomerAcID = C.CustomerACID

                                  --and C.EffectiveToTimeKey = 49999
                                  AND c.EffectiveFromTimeKey <= v_TimeKey
                                  AND c.EffectiveToTimeKey >= v_TimeKey
                                  JOIN AdvAcBalanceDetail D   ON C.AccountEntityId = D.AccountEntityId

                                  --and D.EffectiveToTimeKey = 49999
                                  AND D.EffectiveFromTimeKey <= v_TimeKey
                                  AND D.EffectiveToTimeKey >= v_TimeKey
                            WHERE
                           --Host_System_Name = 'Finacle' and 
                            --Main_Classification is NULL
                             Main_Classification = 'NPA'
                               AND NVL(Remarks, ' ') NOT IN ( 'CANCELLED','CLOSED' )

                               AND NVL(D.SignBalance, 0) <= 0
                               AND b.FinalAssetClassAlt_Key = 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) C   ON DB.SourceName = C.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) Closed  

                           ----------------------
                           FROM ENPA_Host_System_Status_tbl A
                                  JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND A.Report_Date = B.ProcessDate
                            WHERE  Main_Classification = 'NPA'
                                     AND NVL(Remarks, ' ') IN ( 'CANCELLED','CLOSED' )

                                     AND b.FinalAssetClassAlt_Key = 1
                                     AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) D   ON DB.SourceName = D.Host_System_Name
       WHERE  DB.SourceName NOT IN ( 'VisionPlus','FIS' )

                AND db.EffectiveToTimeKey = 49999
        GROUP BY DB.SourceName,NPA,STD,CR_Zero_Balances,Closed ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_UPGRADE" TO "ADF_CDR_RBL_STGDB";
