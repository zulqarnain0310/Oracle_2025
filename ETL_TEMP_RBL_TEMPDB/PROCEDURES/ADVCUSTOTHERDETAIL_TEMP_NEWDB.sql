--------------------------------------------------------
--  DDL for Procedure ADVCUSTOTHERDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
-- Add the parameters for the stored procedure here

BEGIN

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvCustOtherDetail ';
   INSERT INTO TempAdvCustOtherDetail
     ( CustomerEntityId, OrgCostOfEquip, OrgCostOfPlantMech, DepValPlant, ValLand, IECDno, GroupAlt_Key, CustomerSwiftCode, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, CmaEligible, PFNo, SupperAnnuationBenefit, SupperannuationBenefitValuationDt, BusinessCommenceDt, CancelObtained, TotConsortiumLimitFunded, TotConsortiumLimitNonFunded, UpgradationDate, CustomerExpiredYN, TotWCLimitFunded, Flagged_SubSector, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, AnnualExportTurnover, FMCNumber, IsEmployee, IsPetitioner, UnderLitigation, PermiNatureID, BorrUnitFunct, DtofClosure, NonCoopBorrower, ArbiAgreement, TransThroughUs, CutBackArrangement, BankingArrangement, MemberBanksNo, TotalConsortiumAmt, ROC_CFCReportDate, ROC_ChargeFV, ROC_ChargeFVDt, ROC_ChargeRemark, ROC_Securities, ROC_Cover, ROC_CoveredDt, ChargeFiledWith, FiledDt, EmployeeID, EmployeeType, Designation, Placeofposting, LPersonalConDate, LPersonalConDtls, RecallNoticeDate, RecallNoticeModeID, LegalAuditDate, IrregularityPending, IrregularityRectiDate, FraudAccoStatus, PreSARFAESINoticeDt, FMRNO, FMRDate, GradeScaleAlt_Key, FraudNatureRemark, ROCCoveredCertificateRemark, ReasonsNonCoOperativeBorrower, StatusNonCoOperativeBorrower )
     ( SELECT A.CustomerEntityId ,
              NULL OrgCostOfEquip  ,
              NULL OrgCostOfPlantMech  ,
              NULL DepValPlant  ,
              NULL ValLand  ,
              NULL IECDno  ,
              NULL GroupAlt_Key  ,
              NULL CustomerSwiftCode  ,
              NULL SplCatg1Alt_Key  ,
              NULL SplCatg2Alt_Key  ,
              NULL SplCatg3Alt_Key  ,
              NULL SplCatg4Alt_Key  ,
              NULL CmaEligible  ,
              NULL PFNo  ,
              NULL SupperAnnuationBenefit  ,
              NULL SupperannuationBenefitValuationDt  ,
              NULL BusinessCommenceDt  ,
              NULL CancelObtained  ,
              NULL TotConsortiumLimitFunded  ,
              NULL TotConsortiumLimitNonFunded  ,
              NULL UpgradationDate  ,
              NULL CustomerExpiredYN  ,
              NULL TotWCLimitFunded  ,
              NULL Flagged_SubSector  ,
              A.CustomerId RefCustomerId  ,
              NULL AuthorisationStatus  ,
              A.EffectiveFromTimeKey EffectiveFromTimeKey  ,
              A.EffectiveToTimeKey EffectiveToTimeKey  ,
              A.CreatedBy CreatedBy  ,
              A.DateCreated DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL MocTypeAlt_Key  ,
              NULL AnnualExportTurnover  ,
              NULL FMCNumber  ,
              NULL IsEmployee  ,
              NULL IsPetitioner  ,
              NULL UnderLitigation  ,
              NULL PermiNatureID  ,
              NULL BorrUnitFunct  ,
              NULL DtofClosure  ,
              NULL NonCoopBorrower  ,
              NULL ArbiAgreement  ,
              NULL TransThroughUs  ,
              NULL CutBackArrangement  ,
              NULL BankingArrangement  ,
              NULL MemberBanksNo  ,
              NULL TotalConsortiumAmt  ,
              NULL ROC_CFCReportDate  ,
              NULL ROC_ChargeFV  ,
              NULL ROC_ChargeFVDt  ,
              NULL ROC_ChargeRemark  ,
              NULL ROC_Securities  ,
              NULL ROC_Cover  ,
              NULL ROC_CoveredDt  ,
              NULL ChargeFiledWith  ,
              NULL FiledDt  ,
              NULL EmployeeID  ,
              NULL EmployeeType  ,
              NULL Designation  ,
              NULL Placeofposting  ,
              NULL LPersonalConDate  ,
              NULL LPersonalConDtls  ,
              NULL RecallNoticeDate  ,
              NULL RecallNoticeModeID  ,
              NULL LegalAuditDate  ,
              NULL IrregularityPending  ,
              NULL IrregularityRectiDate  ,
              NULL FraudAccoStatus  ,
              NULL PreSARFAESINoticeDt  ,
              NULL FMRNO  ,
              NULL FMRDate  ,
              NULL GradeScaleAlt_Key  ,
              NULL FraudNatureRemark  ,
              NULL ROCCoveredCertificateRemark  ,
              NULL ReasonsNonCoOperativeBorrower  ,
              NULL StatusNonCoOperativeBorrower  
       FROM TempCustomerBasicDetail A );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
