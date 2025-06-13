--------------------------------------------------------
--  DDL for Procedure METAGRIDACCOUNTMASTER_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --GO
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_MetagridEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempMetagridAccountMAster ';
   INSERT INTO TempMetagridAccountMAster
     ( Accrued_interest, Date_of_Data, Source_System_Name, Branch_Code, Customer_UCIC_ID, Customer_ID, Customer_Ac_ID, Ac_Open_Dt, Scheme_Type, Scheme_Product_Code, Ac_Segment_Code, Facility_Type, GL_Code, Sector, Purpose_of_Advance, Industry_Code, First_Dt_Of_Disb, Intt_Rate, Banking_Arrangement, Currency_Code, Unhedged_FCY_Amount, Balance_Outstanding_INR, Balance_In_Actual_Ac_Currency, Advance_Recovery_Amount, Cur_Qtr_Credit, Cur_Qtr_Int, Current_Limit, Current_Limit_Date, Drawing_Power, Adhoc_Amt, Adhoc_Date, Adhoc_Expiry_Date, Conti_Excess_Date, Debit_Since_Date, DFV_Amt, Govt_Gty_Amt, Int_Not_Serviced_Date, Last_Credit_Date, POS_Balance, Principal_Overdue_Amt, Principal_Over_Due_Since_Dt, Interest_Overdue_Amt, Interest_Over_Due_Since_Dt, Oth_Charges_Overdue_Amt, Oth_Changes_Over_Due_Since_Dt, Review_Due_Dt, Limit_Expiry_Date, Stock_Statement_Dt, UnApplied_Interest_Amt, TWO_Date, TWO_Amount, Asset_Class_Norm, AC_Category, Secured_Status, Asset_Class_Code, NPA_Date, DBT_LOS_Date, STD_Provision_Category, Fraud_Committed, Fraud_Date, IsIBPC_Exposure, IsSecurtised_Exposure, Ac_RM_Name_ID, Ac_TL_Name_ID, PUI_Marked, RFA_Marked, IsNonCoperative, Interest_due, other_dues, penal_due, int_receivable_adv, penal_int_receivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
     ( SELECT Accrued_interest ,
              Date_of_Data ,
              Source_System_Name ,
              Branch_Code ,
              Customer_UCIC_ID ,
              Customer_ID ,
              Customer_Ac_ID ,
              Ac_Open_Dt ,
              Scheme_Type ,
              Scheme_Product_Code ,
              Ac_Segment_Code ,
              Facility_Type ,
              GL_Code ,
              Sector ,
              Purpose_of_Advance ,
              Industry_Code ,
              First_Dt_Of_Disb ,
              Intt_Rate ,
              Banking_Arrangement ,
              Currency_Code ,
              Unhedged_FCY_Amount ,
              Balance_Outstanding_INR ,
              Balance_In_Actual_Ac_Currency ,
              Advance_Recovery_Amount ,
              Cur_Qtr_Credit ,
              Cur_Qtr_Int ,
              Current_Limit ,
              Current_Limit_Date ,
              Drawing_Power ,
              Adhoc_Amt ,
              Adhoc_Date ,
              Adhoc_Expiry_Date ,
              Conti_Excess_Date ,
              Debit_Since_Date ,
              DFV_Amt ,
              Govt_Gty_Amt ,
              Int_Not_Serviced_Date ,
              Last_Credit_Date ,
              POS_Balance ,
              Principal_Overdue_Amt ,
              Principal_Over_Due_Since_Dt ,
              Interest_Overdue_Amt ,
              Interest_Over_Due_Since_Dt ,
              Oth_Charges_Overdue_Amt ,
              Oth_Changes_Over_Due_Since_Dt ,
              Review_Due_Dt ,
              Limit_Expiry_Date ,
              Stock_Statement_Dt ,
              UnApplied_Interest_Amt ,
              TWO_Date ,
              TWO_Amount ,
              Asset_Class_Norm ,
              AC_Category ,
              Secured_Status ,
              Asset_Class_Code ,
              NPA_Date ,
              DBT_LOS_Date ,
              STD_Provision_Category ,
              Fraud_Committed ,
              Fraud_Date ,
              IsIBPC_Exposure ,
              IsSecurtised_Exposure ,
              Ac_RM_Name_ID ,
              Ac_TL_Name_ID ,
              PUI_Marked ,
              RFA_Marked ,
              IsNonCoperative ,
              Interest_due ,
              other_dues ,
              penal_due ,
              int_receivable_adv ,
              penal_int_receivable ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  
       FROM RBL_STGDB.metagrid_account_master_STG A );
   /*********************************************************************************************************/
   /*  Existing Customers Customer Entity ID Update  */
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, MAIN.MetagridEntityId
   FROM TEMP ,RBL_TEMPDB.TempMetagridAccountMaster TEMP
          JOIN RBL_MISDB_010922_UAT.MetagridAccountMaster MAIN   ON TEMP.Customer_Ac_ID = MAIN.Customer_Ac_ID 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.MetagridEntityId = src.MetagridEntityId;
   SELECT MAX(MetagridEntityId)  

     INTO v_MetagridEntityId
     FROM RBL_MISDB_010922_UAT.MetagridAccountMaster ;
   IF v_MetagridEntityId IS NULL THEN

   BEGIN
      v_MetagridEntityId := 0 ;

   END;
   END IF;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, ACCT.MetagridEntityId
   FROM TEMP ,RBL_TEMPDB.TempMetagridAccountMaster TEMP
          JOIN ( SELECT "TEMPMETAGRIDACCOUNTMASTER".Customer_Ac_ID ,
                        (v_MetagridEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                               FROM DUAL  )  )) MetagridEntityId  
                 FROM RBL_TEMPDB.TempMetagridAccountMaster 
                  WHERE  "TEMPMETAGRIDACCOUNTMASTER".MetagridEntityId = 0
                           OR "TEMPMETAGRIDACCOUNTMASTER".MetagridEntityId IS NULL ) ACCT   ON TEMP.Customer_Ac_ID = ACCT.Customer_Ac_ID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.MetagridEntityId = src.MetagridEntityId;--------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
