--------------------------------------------------------
--  DDL for Procedure SP_RFACLMISMATCHREPORT_1_07012022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" 
(
  v_Date IN VARCHAR2
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT 'Ganaseva' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'Ganaseva'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
      UNION 
      SELECT 'Finacle ' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'Finacle'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
      UNION 
      SELECT 'ECBF' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'ECBF'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
      UNION 
      SELECT 'INDUS' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'INDUS'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
      UNION 
      SELECT 'MIFIN' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'MIFIN'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date
      UNION 
      SELECT 'VISIONPLUS' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'VISIONPLUS'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'Calypso' Flag  ,
             InitialAssetClassAlt_Key ,
             FinalAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalNpaDt ,
             * 
        FROM ACL_NPA_DATA A
       WHERE  SourceName = 'Calypso'
                AND InitialAssetClassAlt_Key > 1
                AND FinalAssetClassAlt_Key > 1
                AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                OR A.InitialNpaDt <> A.FinalNpaDt )
                AND InitialNpaDt <> FinalNpaDt
                AND UTILS.CONVERT_TO_VARCHAR2(process_Date,200,p_style=>105) = v_Date ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_RFACLMISMATCHREPORT_1_07012022" TO "ADF_CDR_RBL_STGDB";
