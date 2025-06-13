--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey );
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE StatusReport ';
   INSERT INTO StatusReport
     ( SourceAlt_Key, SourceName )
     SELECT SourceAlt_Key ,
            SourceName 
       FROM DIMSOURCEDB 
       ORDER BY SourceAlt_Key;
   UPDATE StatusReport
      SET Upgrade_ACL = NULL,
          Upgrade_RF = NULL,
          Upgrade_Status = NULL,
          Degrade_ACL = NULL,
          Degrade_RF = NULL,
          Degrade_Status = NULL;
   IF utils.object_id('tempdb..tt_temp_280') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_280 ';
   END IF;
   DELETE FROM tt_temp_280;
   UTILS.IDENTITY_RESET('tt_temp_280');

   INSERT INTO tt_temp_280 ( 
   	SELECT b.SourceAlt_Key ,
           a.SourceName ,
           COUNT(*)  CNT  

   	  --select		b.SourceAlt_Key,a.SourceName,count(*)
   	  FROM ACL_UPG_DATA a
             JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

   	  GROUP BY b.SourceAlt_Key,a.SourceName );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, CASE 
   WHEN b.CNT IS NULL THEN 0
   ELSE b.CNT
      END AS Upgrade_ACL
   FROM A ,StatusReport a
          JOIN tt_temp_280 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Upgrade_ACL = src.Upgrade_ACL;
   UPDATE StatusReport
      SET Upgrade_ACL = 0
    WHERE  Upgrade_ACL IS NULL;
   StatusReport_CountWise_Upgrade() ;
   IF utils.object_id('tempdb..tt_temp_2803') IS NOT NULL THEN
    --Declare @TimeKey AS INT =26298
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3_7 ';
   END IF;
   DELETE FROM tt_temp3_7;
   UTILS.IDENTITY_RESET('tt_temp3_7');

   INSERT INTO tt_temp3_7 ( 
   	SELECT b.SourceAlt_Key ,
           a.SourceName ,
           COUNT(*)  CNT  

   	  --select count(*),SourceName 
   	  FROM ACL_NPA_DATA a
             JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

              AND InitialAssetClass = 'std'
              AND FialAssetClass <> 'std'
   	  GROUP BY b.SourceAlt_Key,a.SourceName );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, CASE 
   WHEN b.CNT IS NULL THEN 0
   ELSE b.CNT
      END AS Degrade_ACL
   FROM A ,StatusReport a
          JOIN tt_temp3_7 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Degrade_ACL = src.Degrade_ACL;
   UPDATE StatusReport
      SET Degrade_ACL = 0
    WHERE  Degrade_ACL IS NULL;
   StatusReport_CountWise_Degrade() ;
   StatusReport_CountWise_ACLCount() ;
   StatusReport_CountWise_ACL_RF_Count() ;
   StatusReport_CountWise_Report27() ;
   StatusReport_CountWise_Report36() ;
   StatusReport_CountWise_Report26() ;
   StatusReport_CountWise_Report35() ;
   UPDATE StatusReport
      SET Upgrade_Status = CASE 
                                WHEN ( NVL(Upgrade_ACL, 0) = NVL(Upgrade_RF, 0) )
                                  AND ( NVL(Upgrade_Report_27, 0) = NVL(Upgrade_RF, 0) )
                                  AND ( NVL(Upgrade_Report_27, 0) = NVL(Upgrade_Report_36, 0) )
                                  AND ( NVL(Upgrade_RF_Report_36, 0) = NVL(Upgrade_Report_36, 0) ) THEN 'True'
          ELSE 'False'
             END;
   UPDATE StatusReport
      SET Upgrade_Status = CASE 
                                WHEN ( NVL(Degrade_ACL, 0) = NVL(Degrade_RF, 0) )
                                  AND ( NVL(Degrade_Report_26, 0) = NVL(Degrade_RF, 0) )
                                  AND ( NVL(Degrade_Report_26, 0) = NVL(Degrade_Report_35, 0) )
                                  AND ( NVL(Degrade_RF_Report_35, 0) = NVL(Degrade_Report_35, 0) ) THEN 'True'
          ELSE 'False'
             END;
   UPDATE StatusReport
      SET Degrade_Status = CASE 
                                WHEN Upgrade_RF + Degrade_RF = Total_ACL_RF_Count THEN 'True'
          ELSE 'False'
             END,
          Total_RF_ACL_Status = CASE 
                                     WHEN Upgrade_RF + Degrade_RF = Total_ACL_RF_Count THEN 'True'
          ELSE 'False'
             END
    WHERE  SourceAlt_Key = 7;
   OPEN  v_cursor FOR
      SELECT * 
        FROM StatusReport 
        ORDER BY SourceAlt_Key ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE" TO "ADF_CDR_RBL_STGDB";
