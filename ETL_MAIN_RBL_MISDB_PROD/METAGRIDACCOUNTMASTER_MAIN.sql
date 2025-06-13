--------------------------------------------------------
--  DDL for Procedure METAGRIDACCOUNTMASTER_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempMetagridAccountMaster A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempMetagridAccountMaster A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.MetagridAccountMaster B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND A.Customer_Ac_ID = B.Customer_Ac_ID )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.MetagridAccountMaster O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.MetagridAccountMaster O
          JOIN RBL_TEMPDB.TempMetagridAccountMaster T   ON O.Customer_Ac_ID = T.Customer_Ac_ID
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.Branch_Code, 0) <> NVL(t.Branch_Code, 0)
     OR NVL(O.Customer_UCIC_ID, 0) <> NVL(t.Customer_UCIC_ID, 0)
     OR NVL(O.Customer_ID, 0) <> NVL(t.Customer_ID, 0)
     OR NVL(O.Customer_Ac_ID, 0) <> NVL(t.Customer_Ac_ID, 0)
     OR NVL(O.Ac_Open_Dt, '1900-01-01') <> NVL(T.Ac_Open_Dt, '1900-01-01')
     OR NVL(O.Scheme_Type, 0) <> NVL(t.Scheme_Type, 0)
     OR NVL(O.Scheme_Product_Code, 0) <> NVL(t.Scheme_Product_Code, 0)
     OR NVL(O.Ac_Segment_Code, 0) <> NVL(t.Ac_Segment_Code, 0)
     OR NVL(O.Facility_Type, 0) <> NVL(t.Facility_Type, 0)
     OR NVL(O.GL_Code, 0) <> NVL(t.GL_Code, 0)
     OR NVL(O.Sector, 0) <> NVL(t.Sector, 0)
     OR NVL(O.Purpose_of_Advance, 0) <> NVL(t.Purpose_of_Advance, 0)
     OR NVL(O.Industry_Code, 0) <> NVL(t.Industry_Code, 0)
     OR NVL(O.First_Dt_Of_Disb, '1900-01-01') <> NVL(t.First_Dt_Of_Disb, '1900-01-01')
     OR NVL(O.Intt_Rate, 0) <> NVL(t.Intt_Rate, 0)
     OR NVL(O.Banking_Arrangement, 0) <> NVL(t.Banking_Arrangement, 0)
     OR NVL(O.Currency_Code, 0) <> NVL(t.Currency_Code, 0)
     OR NVL(O.Unhedged_FCY_Amount, 0) <> NVL(t.Unhedged_FCY_Amount, 0)
     OR NVL(O.Balance_Outstanding_INR, 0) <> NVL(t.Balance_Outstanding_INR, 0)
     OR NVL(O.Balance_In_Actual_Ac_Currency, 0) <> NVL(t.Balance_In_Actual_Ac_Currency, 0)
     OR NVL(O.Advance_Recovery_Amount, 0) <> NVL(t.Advance_Recovery_Amount, 0)
     OR NVL(O.Cur_Qtr_Credit, 0) <> NVL(t.Cur_Qtr_Credit, 0)
     OR NVL(O.Cur_Qtr_Int, 0) <> NVL(t.Cur_Qtr_Int, 0)
     OR NVL(O.Current_Limit, 0) <> NVL(t.Current_Limit, 0)
     OR NVL(O.Current_Limit_Date, '1900-01-01') <> NVL(t.Current_Limit_Date, '1900-01-01')
     OR NVL(O.Drawing_Power, 0) <> NVL(t.Drawing_Power, 0)
     OR NVL(O.Adhoc_Amt, 0) <> NVL(t.Adhoc_Amt, 0)
     OR NVL(O.Adhoc_Date, '1900-01-01') <> NVL(t.Adhoc_Date, '1900-01-01')
     OR NVL(O.Adhoc_Expiry_Date, '1900-01-01') <> NVL(t.Adhoc_Expiry_Date, '1900-01-01')
     OR NVL(O.Conti_Excess_Date, '1900-01-01') <> NVL(t.Conti_Excess_Date, '1900-01-01')
     OR NVL(O.Debit_Since_Date, '1900-01-01') <> NVL(t.Debit_Since_Date, '1900-01-01')
     OR NVL(O.DFV_Amt, 0) <> NVL(t.DFV_Amt, 0)
     OR NVL(O.Govt_Gty_Amt, 0) <> NVL(t.Govt_Gty_Amt, 0)
     OR NVL(O.Int_Not_Serviced_Date, '1900-01-01') <> NVL(t.Int_Not_Serviced_Date, '1900-01-01')
     OR NVL(O.Last_Credit_Date, '1900-01-01') <> NVL(t.Last_Credit_Date, '1900-01-01')
     OR NVL(O.POS_Balance, 0) <> NVL(t.POS_Balance, 0)
     OR NVL(O.Principal_Overdue_Amt, 0) <> NVL(t.Principal_Overdue_Amt, 0)
     OR NVL(O.Principal_Over_Due_Since_Dt, '1900-01-01') <> NVL(t.Principal_Over_Due_Since_Dt, '1900-01-01')
     OR NVL(O.Interest_Overdue_Amt, 0) <> NVL(t.Interest_Overdue_Amt, 0)
     OR NVL(O.Interest_Over_Due_Since_Dt, '1900-01-01') <> NVL(t.Interest_Over_Due_Since_Dt, '1900-01-01')
     OR NVL(O.Oth_Charges_Overdue_Amt, 0) <> NVL(O.Oth_Charges_Overdue_Amt, 0)
     OR NVL(O.Oth_Changes_Over_Due_Since_Dt, '1900-01-01') <> NVL(t.Oth_Changes_Over_Due_Since_Dt, '1900-01-01')
     OR NVL(O.Review_Due_Dt, '1900-01-01') <> NVL(t.Review_Due_Dt, '1900-01-01')
     OR NVL(O.Limit_Expiry_Date, '1900-01-01') <> NVL(t.Limit_Expiry_Date, '1900-01-01')
     OR NVL(O.Stock_Statement_Dt, '1900-01-01') <> NVL(t.Stock_Statement_Dt, '1900-01-01')
     OR NVL(O.UnApplied_Interest_Amt, 0) <> NVL(t.UnApplied_Interest_Amt, 0)
     OR NVL(O.TWO_Date, '1900-01-01') <> NVL(t.TWO_Date, '1900-01-01')
     OR NVL(O.TWO_Amount, 0) <> NVL(t.TWO_Amount, 0)
     OR NVL(O.Asset_Class_Norm, 0) <> NVL(t.Asset_Class_Norm, 0)
     OR NVL(O.AC_Category, 0) <> NVL(t.AC_Category, 0)
     OR NVL(O.Secured_Status, 0) <> NVL(t.Secured_Status, 0)
     OR NVL(O.Asset_Class_Code, 0) <> NVL(t.Asset_Class_Code, 0)
     OR NVL(O.NPA_Date, '1900-01-01') <> NVL(t.NPA_Date, '1900-01-01')
     OR NVL(O.DBT_LOS_Date, '1900-01-01') <> NVL(t.DBT_LOS_Date, '1900-01-01')
     OR NVL(O.STD_Provision_Category, 0) <> NVL(t.STD_Provision_Category, 0)
     OR NVL(O.Fraud_Committed, 0) <> NVL(t.Fraud_Committed, 0)
     OR NVL(O.Fraud_Date, '1900-01-01') <> NVL(t.Fraud_Date, '1900-01-01')
     OR NVL(O.IsIBPC_Exposure, 0) <> NVL(t.IsIBPC_Exposure, 0)
     OR NVL(O.IsSecurtised_Exposure, 0) <> NVL(t.IsSecurtised_Exposure, 0)
     OR NVL(O.Ac_RM_Name_ID, 0) <> NVL(t.Ac_RM_Name_ID, 0)
     OR NVL(O.Ac_TL_Name_ID, 0) <> NVL(t.Ac_TL_Name_ID, 0)
     OR NVL(O.PUI_Marked, 0) <> NVL(t.PUI_Marked, 0)
     OR NVL(O.RFA_Marked, 0) <> NVL(t.RFA_Marked, 0)
     OR NVL(O.IsNonCoperative, 0) <> NVL(t.IsNonCoperative, 0)
     OR NVL(O.Interest_due, 0) <> NVL(t.Interest_due, 0)
     OR NVL(O.other_dues, 0) <> NVL(t.other_dues, 0)
     OR NVL(O.penal_due, 0) <> NVL(t.penal_due, 0)
     OR NVL(O.int_receivable_adv, 0) <> NVL(t.int_receivable_adv, 0)
     OR NVL(O.penal_int_receivable, 0) <> NVL(t.penal_int_receivable, 0)
     OR NVL(O.Accrued_interest, 0) <> NVL(t.Accrued_interest, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempInvestmentIssuerDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempInvestmentIssuerDetail A
          JOIN RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.IssuerID = B.IssuerID 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.MetagridAccountMaster AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.MetagridAccountMaster AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempMetagridAccountMaster BB
                       WHERE  AA.Customer_Ac_ID = BB.Customer_Ac_ID
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   INSERT INTO RBL_MISDB_PROD.MetagridAccountMaster
     ( Date_of_Data, Source_System_Name, Branch_Code, Customer_UCIC_ID, Customer_ID, Customer_Ac_ID, Ac_Open_Dt, Scheme_Type, Scheme_Product_Code, Ac_Segment_Code, Facility_Type, GL_Code, Sector, Purpose_of_Advance, Industry_Code, First_Dt_Of_Disb, Intt_Rate, Banking_Arrangement, Currency_Code, Unhedged_FCY_Amount, Balance_Outstanding_INR, Balance_In_Actual_Ac_Currency, Advance_Recovery_Amount, Cur_Qtr_Credit, Cur_Qtr_Int, Current_Limit, Current_Limit_Date, Drawing_Power, Adhoc_Amt, Adhoc_Date, Adhoc_Expiry_Date, Conti_Excess_Date, Debit_Since_Date, DFV_Amt, Govt_Gty_Amt, Int_Not_Serviced_Date, Last_Credit_Date, POS_Balance, Principal_Overdue_Amt, Principal_Over_Due_Since_Dt, Interest_Overdue_Amt, Interest_Over_Due_Since_Dt, Oth_Charges_Overdue_Amt, Oth_Changes_Over_Due_Since_Dt, Review_Due_Dt, Limit_Expiry_Date, Stock_Statement_Dt, UnApplied_Interest_Amt, TWO_Date, TWO_Amount, Asset_Class_Norm, AC_Category, Secured_Status, Asset_Class_Code, NPA_Date, DBT_LOS_Date, STD_Provision_Category, Fraud_Committed, Fraud_Date, IsIBPC_Exposure, IsSecurtised_Exposure, Ac_RM_Name_ID, Ac_TL_Name_ID, PUI_Marked, RFA_Marked, IsNonCoperative, Interest_due, other_dues, penal_due, int_receivable_adv, penal_int_receivable, Accrued_interest, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MetagridEntityId )
     ( SELECT Date_of_Data ,
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
              Accrued_interest ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              MetagridEntityId 
       FROM RBL_TEMPDB.TempMetagridAccountMaster T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."METAGRIDACCOUNTMASTER_MAIN" TO "ADF_CDR_RBL_STGDB";
