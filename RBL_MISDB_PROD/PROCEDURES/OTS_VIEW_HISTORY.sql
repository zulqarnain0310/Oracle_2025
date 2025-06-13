--------------------------------------------------------
--  DDL for Procedure OTS_VIEW_HISTORY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" 
-- [Cust_grid_PUI] '1714222715864042'
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_AccountID IN VARCHAR2
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --declare @ProcessDate Datetime
   --declare @ProcessDateold Datetime
   --Set @ProcessDate =(select DataEffectiveFromDate from SysDataMatrix where CurrentStatus='C')
   --SET @ProcessDateold=@ProcessDate-15

   BEGIN
      OPEN  v_cursor FOR
         SELECT A.RefCustomerAcid AccountId  ,
                A.RefCustomerId CustomerId  ,
                A.AccountEntityId ,
                A.CustomerEntityId ,
                UTILS.CONVERT_TO_VARCHAR2(A.NPA_Date,20,p_style=>103) NPA_Date  ,
                A.ACL_Sttlement ,
                A.Date_Approval_Settlement ,
                A.Approving_Authority ,
                A.Principal_OS ,
                A.Interest_Due_time_Settlement ,
                A.Fees_Charges_Settlement ,
                A.Total_Dues_Settlement ,
                A.Settlement_Amount ,
                A.AmtSacrificePOS ,
                A.AmtWaiverIOS ,
                A.AmtWaiverChgOS ,
                A.TotalAmtSacrifice ,
                A.SettlementFailed ,
                --,A.Actual_Write_Off_Amount
                --,convert(varchar(20),A.Actual_Write_Off_Date,103) Actual_Write_Off_Date
                UTILS.CONVERT_TO_VARCHAR2(A.Account_Closure_Date,20,p_style=>103) Account_Closure_Date  ,
                A.AuthorisationStatus ,
                A.EffectiveFromTimeKey ,
                A.EffectiveToTimeKey ,
                A.CreatedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                A.ModifiedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                A.ApprovedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                A.FirstLevelApprovedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.FirstLevelDateApproved,20,p_style=>103) FirstLevelDateApproved  ,
                A.ChangeFields ,
                A.screenFlag 
           FROM OTS_Details_Mod A
                  JOIN SysDayMatrix S1   ON S1.TimeKey = A.EffectiveFromTimeKey
                  JOIN SysDayMatrix S2   ON S2.TimeKey = A.EffectiveToTimeKey
          WHERE  A.RefCustomerAcid = v_AccountID
                   AND NVL(A.AuthorisationStatus, 'A') = 'A' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--And Convert(date,A.Actual_Write_Off_Date)>=  Convert(Date,@ProcessDateold)
      --and Convert(date,A.Actual_Write_Off_Date)<=  Convert(Date,@ProcessDate)

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_VIEW_HISTORY" TO "ADF_CDR_RBL_STGDB";
