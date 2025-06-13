--------------------------------------------------------
--  DDL for Procedure SP_HOSTSYSTEMSTATUSREPORT_GANASEVA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" 
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
                           FROM ENPA_Host_System_Status_tbl_Ganaseva A
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
                           FROM ENPA_Host_System_Status_tbl_Ganaseva A
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

                               -------------------------added by Prashant on 18-04-2022 Nimish and Vivek-----------------------------------
                               AND NVL(Remarks, ' ') NOT IN ( 'CANCELLED','CLOSED','DEATHPRECLOSED','PRECLOSED' )


                               -------------------------------------------------------------------------------------------------------------------
                               AND B.FinalAssetClassAlt_Key > 1
                               AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) B   ON DB.SourceName = B.Host_System_Name
               LEFT JOIN ( SELECT Report_Date ,
                                  Host_System_Name ,
                                  NVL(COUNT(DISTINCT Account_No) , 0) CR_Zero_Balances  
                           FROM ENPA_Host_System_Status_tbl_Ganaseva A
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
                           FROM ENPA_Host_System_Status_tbl_Ganaseva A
                                  JOIN ReverseFeedDataInsertSync B   ON A.Account_No = B.CustomerAcID
                                  AND A.Report_Date = B.ProcessDate
                            WHERE  Main_Classification = 'STD'

                                     --AND		Closed_Date is not NULL

                                     --AND isnull(Remarks,'')  in ('CANCELLED','CLOSED')

                                     -------------------------added by Prashant on 18-04-2022 Nimish and Vivek-----------------------------------
                                     AND NVL(Remarks, ' ') IN ( 'CANCELLED','CLOSED','DEATHPRECLOSED','PRECLOSED' )


                                     -------------------------------------------------------------------------------------------------------------------
                                     AND B.FinalAssetClassAlt_Key > 1
                                     AND UTILS.CONVERT_TO_VARCHAR2(A.Report_Date,200) = v_Date
                             GROUP BY Report_Date,Host_System_Name ) D   ON DB.SourceName = D.Host_System_Name
       WHERE  DB.SourceName = 'Ganaseva'
        GROUP BY DB.SourceName,NPA,STD,CR_Zero_Balances,Closed ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_HOSTSYSTEMSTATUSREPORT_GANASEVA" TO "ADF_CDR_RBL_STGDB";
