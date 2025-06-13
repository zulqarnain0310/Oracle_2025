--------------------------------------------------------
--  DDL for Function ACL_REPORT_FRONTEND_FILE_29082023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" 
(
  v_UserLoginID IN VARCHAR2,
  v_Result OUT NUMBER
)
RETURN NUMBER
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM ACL_Report_Frontend 
                WHERE  UserLoginId = v_UserLoginID ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT UTILS.CONVERT_TO_VARCHAR2(Report_date,10,p_style=>105) Report_date  ,
                UCIC ,
                CIF_ID ,
                Borrower_Name ,
                Branch_Code ,
                Branch_Name ,
                Account_No ,
                Source_System ,
                Facility ,
                Scheme_Type ,
                Scheme_Code ,
                Scheme_Description ,
                Seg_Code ,
                Asset_Norm ,
                Segment_Description ,
                Business_Segment ,
                Account_DPD ,
                CASE 
                     WHEN NVL(NPA_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(NPA_Date,10,p_style=>103)
                   END NPA_Date  ,
                Outstanding ,
                Principal_Outstanding ,
                Drawing_Power ,
                Sanction_Limit ,
                OverDrawn_Amount ,
                DPD_Overdrawn ,
                CASE 
                     WHEN NVL(Limit_DP_Overdrawn_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Limit_DP_Overdrawn_Date,10,p_style=>103)
                   END Limit_DP_Overdrawn_Date  ,
                CASE 
                     WHEN NVL(Limit_Expiry_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Limit_Expiry_Date,10,p_style=>103)
                   END Limit_Expiry_Date  ,
                DPD_Limit_Expiry ,
                CASE 
                     WHEN NVL(Stock_Statement_valuation_date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Stock_Statement_valuation_date,10,p_style=>103)
                   END Stock_Statement_valuation_date  ,
                DPD_Stock_Statement_expiry ,
                CASE 
                     WHEN NVL(Debit_Balance_Since_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Debit_Balance_Since_Date,10,p_style=>103)
                   END Debit_Balance_Since_Date  ,
                CASE 
                     WHEN NVL(Last_Credit_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Last_Credit_Date,10,p_style=>103)
                   END Last_Credit_Date  ,
                DPD_No_Credit ,
                Current_quarter_credit ,
                Current_quarter_interest ,
                Interest_Not_Serviced ,
                DPD_out_of_order ,
                CC_OD_Interest_Service ,
                Overdue_Amount ,
                CASE 
                     WHEN NVL(Overdue_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Overdue_Date,10,p_style=>103)
                   END Overdue_Date  ,
                DPD_Overdue ,
                Principal_Overdue ,
                CASE 
                     WHEN NVL(Principal_Overdue_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Principal_Overdue_Date,10,p_style=>103)
                   END Principal_Overdue_Date  ,
                DPD_Principal_Overdue ,
                Interest_Overdue ,
                CASE 
                     WHEN NVL(Interest_Overdue_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Interest_Overdue_Date,10,p_style=>103)
                   END Interest_Overdue_Date  ,
                DPD_Interest_Overdue ,
                Other_OverDue ,
                CASE 
                     WHEN NVL(Other_OverDue_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Other_OverDue_Date,10,p_style=>103)
                   END Other_OverDue_Date  ,
                DPD_Other_Overdue ,
                Bill_PC_Overdue_Amount ,
                Overdue_Bill_PC_ID ,
                CASE 
                     WHEN NVL(Bill_PC_Overdue_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(Bill_PC_Overdue_Date,10,p_style=>103)
                   END Bill_PC_Overdue_Date  ,
                DPD_Bill_PC ,
                Asset_Classification ,
                Degrade_Reason ,
                NPA_Norms ,
                TWO_Amount ,
                CASE 
                     WHEN NVL(TWO_Date, ' ') = ' ' THEN NULL
                ELSE UTILS.CONVERT_TO_VARCHAR2(TWO_Date,10,p_style=>103)
                   END TWO_Date  ,
                TWO_Flag ,
                FRAUD_Flag ,
                Litigation_Flag ,
                Settlement_Flag ,
                TypeofRestructuring ,
                Restructure_Flag ,
                UserLoginID ,
                (UTILS.CONVERT_TO_VARCHAR2(UploadDate,10,p_style=>105) || ' ' || UTILS.CONVERT_TO_VARCHAR2(UploadDate,30,p_style=>108)) UploadDate  
           FROM ACL_Report_Frontend 
          WHERE  UserLoginId = v_UserLoginID ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      v_Result := 1 ;
      RETURN v_result;

   END;
   ELSE

   BEGIN
      v_Result := 0 ;
      RETURN v_result;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_REPORT_FRONTEND_FILE_29082023" TO "ADF_CDR_RBL_STGDB";
