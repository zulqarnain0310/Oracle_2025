--------------------------------------------------------
--  DDL for Procedure SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey - 1 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey );
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

                           ----------------------
                           FROM ENPA_Host_System_Status_tbl_VisionPlus A
                                  JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = UTILS.CONVERT_TO_VARCHAR2(B.ProcessDate,200)
                            WHERE
                           --Host_System_Name = 'Finacle' and
                             Main_Classification = 'NPA'
                               AND B.FinalAssetClassAlt_Key > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) A   ON A.Host_System_Name = DB.SourceName
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) STD  

                           -----------------------------
                           FROM ENPA_Host_System_Status_tbl_VisionPlus A
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
                             Main_Classification = 'STD'
                               AND NVL(D.SignBalance, 0) != 0
                               AND Closed_Date IS NULL
                               AND B.FinalAssetClassAlt_Key > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) B   ON DB.SourceName = B.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) CR_Zero_Balances  

                           --------------------------
                           FROM ENPA_Host_System_Status_tbl_VisionPlus A
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
                             Main_Classification = 'STD'
                               AND NVL(Remarks, ' ') NOT IN ( 'CANCELLED','CLOSED' )

                               AND NVL(D.SignBalance, 0) = 0
                               AND B.FinalAssetClassAlt_Key > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) C   ON DB.SourceName = C.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) Closed  

                           -------------------------------------------------
                           FROM ENPA_Host_System_Status_tbl_VisionPlus A
                                  JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND A.Report_Date = B.ProcessDate
                            WHERE  Main_Classification = 'STD'
                                     AND Closed_Date IS NOT NULL
                                     AND B.FinalAssetClassAlt_Key > 1
                                     AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) D   ON DB.SourceName = D.Host_System_Name
       WHERE  DB.SourceName = 'VisionPlus'
        GROUP BY DB.SourceName,NPA,STD,CR_Zero_Balances,Closed ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_VISIONPLUS" TO "ADF_CDR_RBL_STGDB";
