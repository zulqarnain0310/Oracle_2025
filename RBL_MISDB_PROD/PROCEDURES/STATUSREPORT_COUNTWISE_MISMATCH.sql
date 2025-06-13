--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_MISMATCH
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );

BEGIN

   --Declare @Date date='2022-01-23'
   IF utils.object_id('Tempdb..tt_TEMP_37') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_37 ';
   END IF;
   DELETE FROM tt_TEMP_37;
   UTILS.IDENTITY_RESET('tt_TEMP_37');

   INSERT INTO tt_TEMP_37 ( 
   	SELECT * 
   	  FROM ( 
             --select  'Ganaseva' as Flag,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  * 
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'Ganaseva'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName
             UNION 

             --select 'Finacle ' as Flag, InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  *
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'Finacle'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName
             UNION 

             --select  'ECBF' as Flag,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  * 
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'ECBF'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName
             UNION 

             --select  'INDUS' as Flag,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  * 
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'INDUS'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName
             UNION 

             --select  'MIFIN' as Flag,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  * 
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'MIFIN'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName
             UNION 

             --select  'VISIONPLUS' as Flag,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  * 
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'VISIONPLUS'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName
             UNION 

             --select  'Calypso' as Flag,InitialAssetClassAlt_Key,FinalAssetClassAlt_Key,InitialNpaDt,FinalNpaDt,  * 
             SELECT b.SourceAlt_Key ,
                    a.SourceName ,
                    COUNT(*)  CNT  
             FROM ACL_NPA_DATA A
                    JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
              WHERE  a.SourceName = 'Calypso'
                       AND InitialAssetClassAlt_Key > 1
                       AND FinalAssetClassAlt_Key > 1
                       AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                       OR A.InitialNpaDt <> A.FinalNpaDt )
                       AND InitialNpaDt <> FinalNpaDt
                       AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
               GROUP BY b.SourceAlt_Key,a.SourceName ) A );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, CNT
   FROM A ,StatusReport a
          JOIN tt_TEMP_37 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET Mismatch_In_NPA = CNT;
   UPDATE StatusReport
      SET Mismatch_In_NPA = 0
    WHERE  Mismatch_In_NPA IS NULL;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_MISMATCH" TO "ADF_CDR_RBL_STGDB";
