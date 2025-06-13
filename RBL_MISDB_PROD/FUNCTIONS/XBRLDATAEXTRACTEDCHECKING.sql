--------------------------------------------------------
--  DDL for Function XBRLDATAEXTRACTEDCHECKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" 
-- =============================================
 -- Author:		<Shailesh Naik>
 -- Create date: <12/07/14>
 -- Description:	<for checking Data exist or not>
 -- =============================================

(
  v_ReportId IN VARCHAR2,
  v_TimeKey IN NUMBER,
  v_ReportingStatus IN CHAR
)
RETURN RBL_MISDB_PROD.XBRLDataExtractedChecking_pkg.tt_v_Result_2_type PIPELINED
AS
   v_FlagValue CHAR(2) := 'Y';
   v_temp NUMBER(1, 0) := 0;
   v_temp_1 SYS_REFCURSOR;
   v_temp_2 TT_V_RESULT_2%ROWTYPE;

BEGIN
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM XBRLInstanceDocument 
                       WHERE  TimeKey = v_TimeKey
                                AND ReportId = v_reportId
                                AND DelSta = 'UNKNOWN'
                                AND (CASE 
                                          WHEN v_ReportingStatus = 'P'
                                            AND ReportStatus IN ( 'P','F','RF' )

                                            AND FrozenStatus = 'Y' THEN 1

                                          --check if final or revised final is frozen and Reporting Status Selected in Provisional
                                          WHEN v_ReportingStatus IN ( 'F' )

                                            AND ReportStatus IN ( 'F','RF' )

                                            AND FrozenStatus = 'Y' THEN 1
                                          WHEN v_ReportingStatus IN ( 'RF' )

                                            AND ReportStatus IN ( 'RF' )

                                            AND FrozenStatus = 'Y' THEN 1   END) = 
                              --- if reporting status is selected as Final or revised final
                              1 );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      v_FlagValue := 'F' ;--- already freezed

   END;
   END IF;
   IF v_ReportId = 'NRDCSR' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM XBRL.RBI_118_NRD_CSR_Mod 
                          WHERE  TimeKey = v_TimeKey
                                   AND AuthorisationStatus IN ( 'NP','MP' )

                                   AND ReportStatus = v_ReportingStatus
                                   AND RecordStatus = 'C' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_FlagValue := 'Y' ;

      END;
      ELSE

      BEGIN
         v_FlagValue := 'N' ;

      END;
      END IF;

   END;
   END IF;
   IF v_ReportId = 'RLE' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM XBRL.RBI_24_DSBO_IV_A_Mod 
                          WHERE  TimeKey = v_TimeKey
                                   AND AuthorisationStatus IN ( 'NP','MP' )

                                   AND ReportStatus = v_ReportingStatus
                                   AND RecordStatus = 'C' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_FlagValue := 'Y' ;

      END;
      ELSE

      BEGIN
         v_FlagValue := 'N' ;

      END;
      END IF;

   END;
   END IF;
   IF v_ReportId = 'ROP' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM XBRL.RBI_26_DSBO_VI_Mod 
                          WHERE  TimeKey = v_TimeKey
                                   AND AuthorisationStatus IN ( 'NP','MP' )

                                   AND ReportStatus = v_ReportingStatus
                                   AND RecordStatus = 'C' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_FlagValue := 'Y' ;

      END;
      ELSE

      BEGIN
         v_FlagValue := 'N' ;

      END;
      END IF;

   END;
   END IF;
   INSERT INTO tt_v_Result_2
     VALUES ( v_FlagValue, 'Xbrldataextracted' );
   OPEN v_temp_1 FOR
      SELECT * 
        FROM tt_v_Result_2;

   LOOP
      FETCH v_temp_1 INTO v_temp_2;
      EXIT WHEN v_temp_1%NOTFOUND;
      PIPE ROW ( v_temp_2 );
   END LOOP;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."XBRLDATAEXTRACTEDCHECKING" TO "ADF_CDR_RBL_STGDB";
