--------------------------------------------------------
--  DDL for Procedure ACCOUNTSOURCETOSTAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."ACCOUNTSOURCETOSTAGE" 
AS
   --commit tran
   v_cursor SYS_REFCURSOR;


------------------------------------Finacle Account------------------------------------------------------------------------------------
BEGIN
   BEGIN
      DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         --begin tran
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'AccountSourceToStageDB'
                                   AND TableName = 'ACCOUNT_SOURCESYSTEM01_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'AccountSourceToStageDB'
                              AND TableName = 'ACCOUNT_SOURCESYSTEM01_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Prashant');
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'AccountSourceToStageDB'
                      AND TableName = 'ACCOUNT_SOURCESYSTEM01_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'AccountSourceToStageDB' ,
                       'ACCOUNT_SOURCESYSTEM01_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE ACCOUNT_SOURCESYSTEM01_STG ';
            INSERT INTO RBL_STGDB.ACCOUNT_SOURCESYSTEM01_STG
              ( DateofData, SourceSystem, BranchCode, UCIC_ID, CustomerID, CustomerAcID, AcOpenDt, SchemeType, Scheme_ProductCode, AcSegmentCode, FacilityType, GLCode, Sector, PurposeofAdvance, IndustryCode, FirstDtOfDisb, InttRate, BankingArrangement, CurrencyCode, UnhedgedFCYAmount, BalanceOutstandingINR, BalanceInActualAcCurrency, AdvanceRecoveryAmount, CurQtrCredit, CurQtrInt, CurrentLimit, CurrentLimitDate, DrawingPower, AdhocAmt, AdhocDate, AdhocExpiryDate, ContiExcessDate, DebitSinceDate, DFVAmt, GovtGtyAmt, IntNotServicedDate, LastCreditDate, POSBalance, PrincipalOverdueAmt, PrincipalOverDueSinceDt, InterestOverdueAmt, InterestOverDueSinceDt, OthChargesOverdueAmt, OthChangesOverDueSinceDt, Review_RenewDueDt, LimitExpiryDate, StockStatementDt, UnAppliedInterestAmt, TWODate, TWOAmount, AssetClassNorm, ACCategory, SecuredStatus, AssetClassCode, NPADate, DBT_LOSDate, STDProvisionCategory, FraudCommitted, FraudDate, IsIBPCExposure, IsSecurtisedExposure, AcRMName_ID, AcTLName_ID, PUIMarked, RFAMarked, IsNonCoperative, interest_due, other_dues, penal_due, int_receivable, penal_int_receivable, Settlement_Flag, Settlement_Date )
              ( SELECT date_of_data ,
                       Source_system ,
                       branch_code ,
                       ucic ,
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
                       Ad_hoc_Amt ,
                       Ad_hoc_Date ,
                       Ad_hoc_Expiry_Date ,
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
                       Oth_Charges_Over_Due_Since_Dt ,
                       Review_Renew_Due_Dt ,
                       Limit_Expiry_Date ,
                       Stock_Statement_Dt ,
                       Un_Applied_Interest_Amt ,
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
                       interest_due ,
                       other_dues ,
                       penal_due ,
                       int_receivable ,
                       penal_int_receivable ,
                       Settlement_Flag ,
                       Settlement_Date 
                FROM DWH_STG.account_data_finacle  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'ACCOUNT_SOURCESYSTEM01_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.account_data_finacle  );
                
            MERGE INTO RBL_STGDB.TABLE_AUDIT 
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM01_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'ACCOUNT_SOURCESYSTEM01_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( RBL_STGDB.TABLE_AUDIT.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'ACCOUNT_SOURCESYSTEM01_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------ECBF Account------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'AccountSourceToStageDB'
                                   AND TableName = 'ACCOUNT_SOURCESYSTEM03_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'AccountSourceToStageDB'
                              AND TableName = 'ACCOUNT_SOURCESYSTEM03_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'AccountSourceToStageDB'
                      AND TableName = 'ACCOUNT_SOURCESYSTEM03_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'AccountSourceToStageDB' ,
                       'ACCOUNT_SOURCESYSTEM03_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE ACCOUNT_SOURCESYSTEM03_STG ';
            INSERT INTO RBL_STGDB.ACCOUNT_SOURCESYSTEM03_STG
              ( DateofData, SourceSystem, BranchCode, UCIC_ID, CustomerID, CustomerAcID, AcOpenDt, SchemeType, Scheme_ProductCode, AcSegmentCode, FacilityType, GLCode, Sector, PurposeofAdvance, IndustryCode, FirstDtOfDisb, InttRate, BankingArrangement, CurrencyCode, UnhedgedFCYAmount, BalanceOutstandingINR, BalanceInActualAcCurrency, AdvanceRecoveryAmount, CurQtrCredit, CurQtrInt, CurrentLimit, CurrentLimitDate, DrawingPower, AdhocAmt, AdhocDate, AdhocExpiryDate, ContiExcessDate, DebitSinceDate, DFVAmt, GovtGtyAmt, IntNotServicedDate, LastCreditDate, POSBalance, PrincipalOverdueAmt, PrincipalOverDueSinceDt, InterestOverdueAmt, InterestOverDueSinceDt, OthChargesOverdueAmt, OthChangesOverDueSinceDt, Review_RenewDueDt, LimitExpiryDate, StockStatementDt, UnAppliedInterestAmt, TWODate, TWOAmount, AssetClassNorm, ACCategory, SecuredStatus, AssetClassCode, NPADate, DBT_LOSDate, STDProvisionCategory, FraudCommitted, FraudDate, IsIBPCExposure, IsSecurtisedExposure, AcRMName_ID, AcTLName_ID, PUIMarked, RFAMarked, IsNonCoperative, interest_due, other_dues, penal_due, int_receivable, penal_int_receivable, Settlement_Flag, Settlement_Date )
              ( SELECT date_of_data ,
                       Source_system ,
                       branch_code ,
                       ucic ,
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
                       Ad_hoc_Amt ,
                       Ad_hoc_Date ,
                       Ad_hoc_Expiry_Date ,
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
                       Oth_Charges_Over_Due_Since_Dt ,
                       Review_Renew_Due_Dt ,
                       Limit_Expiry_Date ,
                       Stock_Statement_Dt ,
                       NULL UnAppliedInterestAmt  ,
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
                       interest_due ,
                       other_dues ,
                       penal_due ,
                       int_receivable ,
                       penal_int_receivable ,
                       Settlement_Flag ,
                       Settlement_Date 
                FROM DWH_STG.accounts_data_ecbf  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'ACCOUNT_SOURCESYSTEM03_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.accounts_data_ecbf  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM03_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'ACCOUNT_SOURCESYSTEM03_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM03_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM03_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'ACCOUNT_SOURCESYSTEM03_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------VP Account------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'AccountSourceToStageDB'
                                   AND TableName = 'ACCOUNT_SOURCESYSTEM06_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'AccountSourceToStageDB'
                              AND TableName = 'ACCOUNT_SOURCESYSTEM06_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'AccountSourceToStageDB'
                      AND TableName = 'ACCOUNT_SOURCESYSTEM06_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'AccountSourceToStageDB' ,
                       'ACCOUNT_SOURCESYSTEM06_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE ACCOUNT_SOURCESYSTEM06_STG ';
            INSERT INTO RBL_STGDB.ACCOUNT_SOURCESYSTEM06_STG
              ( DateofData, SourceSystem, BranchCode, UCIC_ID, CustomerID, CustomerAcID, AcOpenDt, SchemeType, Scheme_ProductCode, AcSegmentCode, FacilityType, GLCode, Sector, PurposeofAdvance, IndustryCode, FirstDtOfDisb, InttRate, BankingArrangement, CurrencyCode, UnhedgedFCYAmount, BalanceOutstandingINR, BalanceInActualAcCurrency, AdvanceRecoveryAmount, CurQtrCredit, CurQtrInt, CurrentLimit, CurrentLimitDate, DrawingPower, AdhocAmt, AdhocDate, AdhocExpiryDate, ContiExcessDate, DebitSinceDate, DFVAmt, GovtGtyAmt, IntNotServicedDate, LastCreditDate, POSBalance, PrincipalOverdueAmt, PrincipalOverDueSinceDt, InterestOverdueAmt, InterestOverDueSinceDt, OthChargesOverdueAmt, OthChangesOverDueSinceDt, ReviewDueDt, LimitExpiryDate, StockStatementDt, UnAppliedInterestAmt, TWODate, TWOAmount, AssetClassNorm, ACCategory, SecuredStatus, AssetClassCode, NPADate, DBT_LOSDate, STDProvisionCategory, FraudCommitted, FraudDate, IsIBPCExposure, IsSecurtisedExposure, AcRMName_ID, AcTLName_ID, PUIMarked, RFAMarked, IsNonCoperative, CorporateUCICID, CorporateCustomerID, Liability, CD, Bucket, DPD, Accountstatus, AccountBlkCode1, AccountBlkCode2, ChargeoffY_N, ChargeoffType, ChargeoffAmount, ChargeoffDate, PrincipalOS, InterestOs, OtherChargesOS, ST_GSTTaxOS, interest_due, other_dues, penal_due, int_receivable, penal_int_receivable, Settlement_Flag, Settlement_Date )
              ( SELECT date_of_data ,
                       source_system_name ,
                       branch_code ,
                       UCIC ,
                       customer_id ,
                       customer_ac_id ,
                       Ac_Open_Dt ,
                       scheme_type ,
                       scheme_code ,
                       ac_segment_code ,
                       facility_type ,
                       gl_code ,
                       Sector ,
                       --,Purpose_of_Advance
                       SUBSTR(Purpose_of_Advance, 1, 10) ,
                       Industry_Code ,
                       First_Dt_Of_Disb ,
                       intt_rate ,
                       Banking_Arrangement ,
                       currency_code ,
                       Unhedged_FCY_Amount ,
                       balance_outstanding_inr ,
                       balance_actual_ac_currency ,
                       Advance_Recovery_Amount ,
                       cur_qtr_credit ,
                       cur_qtr_int ,
                       current_limit ,
                       Current_Limit_Date ,
                       drawing_power ,
                       adhoc_amt ,
                       adhoc_date ,
                       adhoc_expiry_date ,
                       Conti_Excess_Date ,
                       Debit_Since_Date ,
                       dfv_amt ,
                       govt_gty_amt ,
                       Int_Not_Serviced_Date ,
                       Last_Credit_Date ,
                       pos_balance ,
                       Principal_Overdue_Amt ,
                       Principal_Over_Due_Since_Dt ,
                       Interest_Overdue_Amt ,
                       Interest_Over_Due_Since_Dt ,
                       Oth_Charges_Overdue_Amt ,
                       Oth_Changes_Over_Due_Since_Dt ,
                       review_due_dt ,
                       Limit_Expiry_Date ,
                       Stock_Statement_Dt ,
                       Un_Applied_Interest_Amt ,
                       TWO_Date ,
                       two_amount ,
                       asset_class_norm ,
                       ac_category ,
                       secured_status ,
                       Asset_Class_Code ,
                       NPA_Date ,
                       DBT_LOS_Date ,
                       STD_Provision_Category ,
                       fraud_committed ,
                       fraud_date ,
                       IsIBPC_exposure ,
                       IsSecurtised_Exposure ,
                       Ac_RM_Name_ID ,
                       Ac_TL_Name_ID ,
                       PUI_Marked ,
                       RFA_Marked ,
                       IsNonCoperative ,
                       Corporate_UCIC_ID ,
                       Corporate_Customer_ID ,
                       Liability ,
                       cd ,
                       bucket ,
                       dpd ,
                       Accountstatus ,
                       AccountBlkCode1 ,
                       AccountBlkCode2 ,
                       Charge_off_flag ,
                       Charge_off_Type ,
                       Charge_off_Amount ,
                       Charge_off_Date ,
                       Principal_Outstanding ,
                       Interest_Outstanding ,
                       Other_Charges_Outstanding ,
                       GST_Service_Tax_Outstanding ,
                       interest_due ,
                       other_dues ,
                       penal_due ,
                       int_receivable ,
                       penal_int_receivable ,
                       Settlement_Flag ,
                       Settlement_Date 
                FROM DWH_STG.account_data_visionplus  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'ACCOUNT_SOURCESYSTEM06_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.account_data_visionplus  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM06_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'ACCOUNT_SOURCESYSTEM06_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM06_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM06_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'ACCOUNT_SOURCESYSTEM06_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------FIS Account------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'AccountSourceToStageDB'
                                   AND TableName = 'ACCOUNT_SOURCESYSTEM07_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'AccountSourceToStageDB'
                              AND TableName = 'ACCOUNT_SOURCESYSTEM07_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'AccountSourceToStageDB'
                      AND TableName = 'ACCOUNT_SOURCESYSTEM07_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'AccountSourceToStageDB' ,
                       'ACCOUNT_SOURCESYSTEM07_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE ACCOUNT_SOURCESYSTEM07_STG ';
            INSERT INTO RBL_STGDB.ACCOUNT_SOURCESYSTEM07_STG
              ( DateofData, SourceSystem, BranchCode, UCIC_ID, CustomerID, CustomerAcID, AcOpenDt, SchemeType, Scheme_ProductCode, AcSegmentCode, FacilityType, GLCode, Sector, PurposeofAdvance, IndustryCode, FirstDtOfDisb, InttRate, BankingArrangement, CurrencyCode, UnhedgedFCYAmount, BalanceOutstandingINR, BalanceInActualAcCurrency, AdvanceRecoveryAmount, CurQtrCredit, CurQtrInt, CurrentLimit, CurrentLimitDate, DrawingPower, AdhocAmt, AdhocDate, AdhocExpiryDate, ContiExcessDate, DebitSinceDate, DFVAmt, GovtGtyAmt, IntNotServicedDate, LastCreditDate, POSBalance, PrincipalOverdueAmt, PrincipalOverDueSinceDt, InterestOverdueAmt, InterestOverDueSinceDt, OthChargesOverdueAmt, OthChangesOverDueSinceDt, Review_RenewDueDt, LimitExpiryDate, StockStatementDt, UnAppliedInterestAmt, TWODate, TWOAmount, AssetClassNorm, ACCategory, SecuredStatus, AssetClassCode, NPADate, DBT_LOSDate, STDProvisionCategory, FraudCommitted, FraudDate, IsIBPCExposure, IsSecurtisedExposure, AcRMName_ID, AcTLName_ID, PUIMarked, RFAMarked, IsNonCoperative, interest_due, other_dues, penal_due, int_receivable, penal_int_receivable, Accrued_interest, Settlement_flag, Settlement_Date, Restructuring, Restructure_type, Restructure_date, Litigation_Flag, Litigation_Date )
              ( SELECT date_of_data ,
                       Source_system ,
                       branch_code ,
                       ucic ,
                       Customer_ID ,
                       Customer_Ac_ID ,
                       Ac_Open_Dt ,
                       Scheme_Type ,
                       Scheme_Product_Code ,
                       Ac_Segment_Code ,
                       Facility_Type ,
                       gl_sub_head_code ,
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
                       Ad_hoc_Amt ,
                       Ad_hoc_Date ,
                       Ad_hoc_Expiry_Date ,
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
                       Oth_Charges_Over_Due_Since_Dt ,
                       Review_Renew_Due_Dt ,
                       Limit_Expiry_Date ,
                       Stock_Statement_Dt ,
                       Un_Applied_Interest_Amt ,
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
                       Settlement_flag ,
                       Settlement_Date ,
                       Restructuring ,
                       Restructure_type ,
                       Restructure_date ,
                       Litigation_Flag ,
                       Litigation_Date 
                FROM DWH_STG.account_data_fis  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'ACCOUNT_SOURCESYSTEM07_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.account_data_fis  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM07_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'ACCOUNT_SOURCESYSTEM07_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM07_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM07_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'ACCOUNT_SOURCESYSTEM07_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------EIFS Account------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'AccountSourceToStageDB'
                                   AND TableName = 'ACCOUNT_SOURCESYSTEM08_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'AccountSourceToStageDB'
                              AND TableName = 'ACCOUNT_SOURCESYSTEM08_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'AccountSourceToStageDB'
                      AND TableName = 'ACCOUNT_SOURCESYSTEM08_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'AccountSourceToStageDB' ,
                       'ACCOUNT_SOURCESYSTEM08_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE ACCOUNT_SOURCESYSTEM08_STG ';
            INSERT INTO RBL_STGDB.ACCOUNT_SOURCESYSTEM08_STG
              ( DateofData, SourceSystem, BranchCode, UCIC_ID, CustomerID, CustomerAcID, AcOpenDt, SchemeType, Scheme_ProductCode, AcSegmentCode, FacilityType, GLCode, Sector, PurposeofAdvance, IndustryCode, FirstDtOfDisb, InttRate, BankingArrangement, CurrencyCode, UnhedgedFCYAmount, BalanceOutstandingINR, BalanceInActualAcCurrency, AdvanceRecoveryAmount, CurQtrCredit, CurQtrInt, CurrentLimit, CurrentLimitDate, DrawingPower, AdhocAmt, AdhocDate, AdhocExpiryDate, ContiExcessDate, DebitSinceDate, DFVAmt, GovtGtyAmt, IntNotServicedDate, LastCreditDate, POSBalance, PrincipalOverdueAmt, PrincipalOverDueSinceDt, InterestOverdueAmt, InterestOverDueSinceDt, OthChargesOverdueAmt, OthChangesOverDueSinceDt, Review_RenewDueDt, LimitExpiryDate, StockStatementDt, UnAppliedInterestAmt, TWODate, TWOAmount, AssetClassNorm, ACCategory, SecuredStatus, AssetClassCode, NPADate, DBT_LOSDate, STDProvisionCategory, FraudCommitted, FraudDate, IsIBPCExposure, IsSecurtisedExposure, AcRMName_ID, AcTLName_ID, PUIMarked, RFAMarked, IsNonCoperative, interest_due, other_dues, penal_due, int_receivable, penal_int_receivable, accrued_interest, Un_Applied_Interest_Amt, Settlement_Flag, Settlement_Date )
              ( SELECT Date_of_Data ,
                       Source_System ,
                       Branch_Code ,
                       UCIC ,
                       Customer_ID ,
                       Customer_AC_ID ,
                       Ac_open_Dt ,
                       SchemeType ,
                       Scheme_Product_Code ,
                       Ac_Segment_Code ,
                       Facility_Type ,
                       GL_Code ,
                       Sector ,
                       --,Purpose_of_advance
                       SUBSTR(Purpose_of_advance, 1, 10) ,
                       industry_code ,
                       First_Dt_Of_Disb ,
                       INT_Rate ,
                       banking_Arrangement ,
                       currency_Code ,
                       Unhedged_FCY_Amount ,
                       Balance_Outstanding_INR ,
                       Balance_In_Actual_Ac_Currency ,
                       Advance_Recovery_Amount ,
                       Cur_Qtr_Credit ,
                       Cur_Qtr_Int ,
                       Current_Limit ,
                       Current_Limit_Date ,
                       Drawing_Power ,
                       Ad_hoc_Amt ,
                       Ad_hoc_Date ,
                       Ad_hoc_Expiry_Date ,
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
                       Oth_Charges_Over_Due_Since_Dt ,
                       Review_Renew_Due_Dt ,
                       Limit_Expiry_Date ,
                       Stock_Statement_Dt ,
                       Un_Applied_Interest_Amt ,
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
                       interest_due ,
                       other_dues ,
                       penal_due ,
                       int_receivable ,
                       penal_int_receivable ,
                       accrued_interest ,
                       NULL Un_Applied_Interest_Amt  ,
                       Settlement_Flag ,
                       Settlement_Date 
                FROM DWH_STG.Account_data_EIFS  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'ACCOUNT_SOURCESYSTEM08_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.Account_data_EIFS  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM08_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'ACCOUNT_SOURCESYSTEM08_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM08_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'AccountSourceToStageDB'
              AND TableName = 'ACCOUNT_SOURCESYSTEM08_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'ACCOUNT_SOURCESYSTEM08_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;

      END;
   
END;
EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
        WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
