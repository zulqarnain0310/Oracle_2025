--------------------------------------------------------
--  DDL for Procedure METAGRIDACCOUNTMASTER_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" 
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
   v_DATE VARCHAR2(200) ;
   --GO
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_MetagridEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempMetagridAccountMAster ';
   INSERT INTO RBL_TEMPDB.TempMetagridAccountMAster
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
   MERGE INTO RBL_TEMPDB.TempMetagridAccountMAster TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.MetagridEntityId
   FROM RBL_TEMPDB.TempMetagridAccountMAster TEMP
          JOIN RBL_MISDB_PROD.MetagridAccountMaster MAIN   ON TEMP.Customer_Ac_ID = MAIN.Customer_Ac_ID 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.MetagridEntityId = src.MetagridEntityId;
   SELECT MAX(MetagridEntityId)  

     INTO v_MetagridEntityId
     FROM RBL_MISDB_PROD.MetagridAccountMaster ;
   IF v_MetagridEntityId IS NULL THEN

   BEGIN
      v_MetagridEntityId := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempMetagridAccountMAster TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.MetagridEntityId
   FROM RBL_TEMPDB.TempMetagridAccountMAster TEMP
          JOIN ( SELECT A.Customer_Ac_ID ,
                        (v_MetagridEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                               FROM DUAL  )  )) MetagridEntityId  
                 FROM RBL_TEMPDB.TempMetagridAccountMAster A
                  WHERE  A.MetagridEntityId = 0
                           OR A.MetagridEntityId IS NULL ) ACCT   ON TEMP.Customer_Ac_ID = ACCT.Customer_Ac_ID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.MetagridEntityId = src.MetagridEntityId;--------------------------------------------------

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDACCOUNTMASTER_TEMP" TO "ADF_CDR_RBL_STGDB";
