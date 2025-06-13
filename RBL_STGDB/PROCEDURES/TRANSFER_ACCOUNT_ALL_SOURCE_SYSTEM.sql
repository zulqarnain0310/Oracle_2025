--------------------------------------------------------
--  DDL for Procedure TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" 
AS
   v_temp NUMBER(1, 0) := 0;

BEGIN


   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM ';
   INSERT INTO RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM
     ( DateofData, SourceSystem, BranchCode, UCIC_ID, CustomerID, CustomerAcID, AcOpenDt, SchemeType, Scheme_ProductCode, AcSegmentCode, FacilityType, GLCode, Sector, PurposeofAdvance, IndustryCode, FirstDtOfDisb, InttRate, BankingArrangement, CurrencyCode, UnhedgedFCYAmount, BalanceOutstandingINR, BalanceInActualAcCurrency, AdvanceRecoveryAmount, CurQtrCredit, CurQtrInt, CurrentLimit, CurrentLimitDate, DrawingPower, AdhocAmt, AdhocDate, AdhocExpiryDate, ContiExcessDate, DebitSinceDate, DFVAmt, GovtGtyAmt, IntNotServicedDate, LastCreditDate, POSBalance, PrincipalOverdueAmt, PrincipalOverDueSinceDt, InterestOverdueAmt, InterestOverDueSinceDt, OthChargesOverdueAmt, OthChangesOverDueSinceDt, Review_RenewDueDt, LimitExpiryDate, StockStatementDt, UnAppliedInterestAmt, TWODate, TWOAmount, AssetClassNorm, ACCategory, SecuredStatus, AssetClassCode, NPADate, DBT_LOSDate, STDProvisionCategory, FraudCommitted, FraudDate, IsIBPCExposure, IsSecurtisedExposure, AcRMName_ID, AcTLName_ID, PUIMarked, RFAMarked, IsNonCoperative, CurrQtrSecurityValue, PrvQtrSecurityValue, CorporateUCICID, CorporateCustomerID, Liability, CD, Bucket, DPD, Accountstatus, AccountBlkCode1, AccountBlkCode2, ChargeoffY_N, ChargeoffType, ChargeoffAmount, ChargeoffDate, PrincipalOS, InterestOs, OtherChargesOS, ST_GSTTaxOS, interest_due, other_dues, penal_due, int_receivable, penal_int_receivable, Accured_Interest, Settlement_Flag, Settlement_Date )
     ( 
       ----SOURCESYSSTEM01
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              Review_RenewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              NULL ,
              Settlement_Flag ,
              Settlement_Date 
       FROM ACCOUNT_SOURCESYSTEM01_STG 
       UNION 

       ----SOURCESYSSTEM02
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              Review_RenewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              NULL ,
              Settlement_Flag ,
              Settlement_Date 
       FROM ACCOUNT_SOURCESYSTEM02_STG 
       UNION 
       ----SOURCESYSSTEM03
       ALL 
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              Review_RenewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              NULL ,
              Settlement_Flag ,
              Settlement_Date 
       FROM ACCOUNT_SOURCESYSTEM03_STG 
       UNION 
       ------SOURCESYSSTEM04
       ALL 
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              Review_RenewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              NULL ,
              Settlement_Flag ,
              Settlement_Date 
       FROM ACCOUNT_SOURCESYSTEM04_STG 
       UNION  /*
       ---------------------SOURCESYSSTEM05
       union all
       SELECT	
       DateofData
       ,SourceSystem
       ,BranchCode
       ,UCIC_ID
       ,CustomerID
       ,CustomerAcID
       ,AcOpenDt
       ,SchemeType
       ,Scheme_ProductCode
       ,AcSegmentCode
       ,FacilityType
       ,GLCode
       ,Sector
       ,PurposeofAdvance
       ,IndustryCode
       ,FirstDtOfDisb
       ,InttRate
       ,BankingArrangement
       ,CurrencyCode
       ,UnhedgedFCYAmount
       ,BalanceOutstandingINR
       ,BalanceInActualAcCurrency
       ,AdvanceRecoveryAmount
       ,CurQtrCredit
       ,CurQtrInt
       ,CurrentLimit
       ,CurrentLimitDate
       ,DrawingPower
       ,AdhocAmt
       ,AdhocDate
       ,AdhocExpiryDate
       ,ContiExcessDate
       ,DebitSinceDate
       ,DFVAmt
       ,GovtGtyAmt
       ,IntNotServicedDate
       ,LastCreditDate
       ,POSBalance
       ,PrincipalOverdueAmt
       ,PrincipalOverDueSinceDt
       ,InterestOverdueAmt
       ,InterestOverDueSinceDt
       ,OthChargesOverdueAmt
       ,OthChangesOverDueSinceDt
       ,Review_RenewDueDt
       ,LimitExpiryDate
       ,StockStatementDt
       ,UnAppliedInterestAmt
       ,TWODate
       ,TWOAmount
       ,AssetClassNorm
       ,ACCategory
       ,SecuredStatus
       ,AssetClassCode
       ,NPADate
       ,DBT_LOSDate
       ,STDProvisionCategory
       ,FraudCommitted
       ,FraudDate
       ,IsIBPCExposure
       ,IsSecurtisedExposure
       ,AcRMName_ID
       ,AcTLName_ID
       ,PUIMarked
       ,RFAMarked
       ,IsNonCoperative
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,interest_due
       ,other_dues
       ,penal_due
       ,int_receivable
       ,penal_int_receivable
       ,NULL
       From ACCOUNT_SOURCESYSTEM05_STG
       */

       ----------------------SOURCESYSSTEM06
       ALL 
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              ReviewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              CorporateUCICID ,
              CorporateCustomerID ,
              Liability ,
              CD ,
              Bucket ,
              DPD ,
              Accountstatus ,
              AccountBlkCode1 ,
              AccountBlkCode2 ,
              ChargeoffY_N ,
              ChargeoffType ,
              ChargeoffAmount ,
              ChargeoffDate ,
              PrincipalOS ,
              InterestOs ,
              OtherChargesOS ,
              ST_GSTTaxOS ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              NULL ,
              NULL Settlement_Flag  ,
              NULL Settlement_Date  
       FROM ACCOUNT_SOURCESYSTEM06_STG 
       UNION 
       ----------------------metagrid
       ALL 
       SELECT Date_of_Data ,
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
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable_adv ,
              penal_int_receivable ,
              Accrued_interest ,
              Settlement_Flag ,
              Settlement_Date 
       FROM metagrid_account_master_STG 
        WHERE  Date_of_Data IN ( SELECT DISTINCT DateofData 
                                 FROM ACCOUNT_SOURCESYSTEM01_STG  )

       UNION 
       ---------------------SOURCESYSSTEM07    Added By- Mandeep For FIS Source Date-11-08-2022 
       ALL 
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              Review_RenewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              CAST(Accrued_interest AS NUMBER(16,2)),
              Settlement_Flag ,
              Settlement_Date 
       FROM ACCOUNT_SOURCESYSTEM07_STG 
       UNION ALL 

       --ADDED BY MANDEEP FOR EIFS
       SELECT DateofData ,
              SourceSystem ,
              BranchCode ,
              UCIC_ID ,
              CustomerID ,
              CustomerAcID ,
              AcOpenDt ,
              SchemeType ,
              Scheme_ProductCode ,
              AcSegmentCode ,
              FacilityType ,
              GLCode ,
              Sector ,
              PurposeofAdvance ,
              IndustryCode ,
              FirstDtOfDisb ,
              InttRate ,
              BankingArrangement ,
              CurrencyCode ,
              UnhedgedFCYAmount ,
              BalanceOutstandingINR ,
              BalanceInActualAcCurrency ,
              AdvanceRecoveryAmount ,
              CurQtrCredit ,
              CurQtrInt ,
              CurrentLimit ,
              CurrentLimitDate ,
              DrawingPower ,
              AdhocAmt ,
              AdhocDate ,
              AdhocExpiryDate ,
              ContiExcessDate ,
              DebitSinceDate ,
              DFVAmt ,
              GovtGtyAmt ,
              IntNotServicedDate ,
              LastCreditDate ,
              POSBalance ,
              PrincipalOverdueAmt ,
              PrincipalOverDueSinceDt ,
              InterestOverdueAmt ,
              InterestOverDueSinceDt ,
              OthChargesOverdueAmt ,
              OthChangesOverDueSinceDt ,
              Review_RenewDueDt ,
              LimitExpiryDate ,
              StockStatementDt ,
              UnAppliedInterestAmt ,
              TWODate ,
              TWOAmount ,
              AssetClassNorm ,
              ACCategory ,
              SecuredStatus ,
              AssetClassCode ,
              NPADate ,
              DBT_LOSDate ,
              STDProvisionCategory ,
              FraudCommitted ,
              FraudDate ,
              IsIBPCExposure ,
              IsSecurtisedExposure ,
              AcRMName_ID ,
              AcTLName_ID ,
              PUIMarked ,
              RFAMarked ,
              IsNonCoperative ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              NULL ,
              interest_due ,
              other_dues ,
              penal_due ,
              int_receivable ,
              penal_int_receivable ,
              accrued_interest ,
              Settlement_Flag ,
              Settlement_Date 
       FROM ACCOUNT_SOURCESYSTEM08_STG  );
   
   /*DELETE DUPLICATES FROM TABLE ACCOUNT_ALL_SOURCE_SYSTEM*/
   DELETE FROM ACCOUNT_ALL_SOURCE_SYSTEM WHERE ROWID NOT IN ( SELECT MIN(ROWID)                        
     FROM ACCOUNT_ALL_SOURCE_SYSTEM GROUP BY SOURCESYSTEM, CUSTOMERACID ) ;
   /*DELETE DUPLICATES FROM TABLE ACCOUNT_ALL_SOURCE_SYSTEM END*/  
       
   ------Raiseerror code to stop job
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM 
                WHERE  SourceSystem = 'FIS'
                         AND ( PrincipalOverDueSinceDt IS NOT NULL
                         AND InterestOverDueSinceDt IS NULL ) ) = 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      utils.raiserror( 0, 'Principle and interest over due date is null' );--IF(
      --select count(1) from DWH_STG.dbo.dwhControlCountTable where CountStatus = 'false' ) > 0
      --BEGIN
      --RAISERROR('Data not came properly',16,1);
      --END

   END;
   END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_STGDB"."TRANSFER_ACCOUNT_ALL_SOURCE_SYSTEM" TO "ADF_CDR_RBL_STGDB";
