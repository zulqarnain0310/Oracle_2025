--------------------------------------------------------
--  DDL for Procedure ADVCUSTOTHERDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200);
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
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' 
   TRUNCATE TABLE RBL_TEMPDB.TempAdvCustOtherDetail ';
   INSERT INTO RBL_TEMPDB.TempAdvCustOtherDetail
     ( CustomerEntityId, OrgCostOfEquip, OrgCostOfPlantMech, DepValPlant, ValLand, IECDno, GroupAlt_Key, CustomerSwiftCode, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, CmaEligible, PFNo, SupperAnnuationBenefit, SupperannuationBenefitValuationDt, BusinessCommenceDt, CancelObtained, TotConsortiumLimitFunded, TotConsortiumLimitNonFunded, UpgradationDate, CustomerExpiredYN, TotWCLimitFunded, Flagged_SubSector, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, AnnualExportTurnover, FMCNumber, IsEmployee, IsPetitioner, UnderLitigation, PermiNatureID, BorrUnitFunct, DtofClosure, NonCoopBorrower, ArbiAgreement, TransThroughUs, CutBackArrangement, BankingArrangement, MemberBanksNo, TotalConsortiumAmt, ROC_CFCReportDate, ROC_ChargeFV, ROC_ChargeFVDt, ROC_ChargeRemark, ROC_Securities, ROC_Cover, ROC_CoveredDt, ChargeFiledWith, FiledDt, EmployeeID, EmployeeType, Designation, Placeofposting, LPersonalConDate, LPersonalConDtls, RecallNoticeDate, RecallNoticeModeID, LegalAuditDate, IrregularityPending, IrregularityRectiDate, FraudAccoStatus, PreSARFAESINoticeDt, FMRNO, FMRDate, GradeScaleAlt_Key, FraudNatureRemark, ROCCoveredCertificateRemark, ReasonsNonCoOperativeBorrower, StatusNonCoOperativeBorrower, SourceAssetClass, SourceNpaDate )
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
              NULL StatusNonCoOperativeBorrower  ,
              ACC1.AssetClass ,
              ACC1.NPADate 
       FROM RBL_TEMPDB.TempCustomerBasicDetail A
              JOIN RBL_STGDB.CUSTOMER_ALL_SOURCE_SYSTEM ACC1   ON ACC1.CustomerID = A.CustomerId
            --INNER JOIN RBL_TEMPDB.DBO.TempAdvAcBasicDetail ACBD ON  ACC1.CustomerAcID=ACBD.CustomerACID  

              LEFT JOIN RBL_MISDB_PROD.DimAssetClassMapping_Customer DA   ON ACC1.AssetClass = DA.AssetClassShortName
              AND A.SourceSystemAlt_Key = DA.SourceAlt_Key ----Added on 11-05-2022 as discussed with amar sir 

              AND DA.EffectiveFromTimeKey <= v_TimeKey
              AND DA.EffectiveToTimeKey >= v_TimeKey );

            /* DELETE DUPLICATES FROM RBL_TEMPDB.TempAdvCustOtherDetail*/
            DELETE FROM RBL_TEMPDB.TempAdvCustOtherDetail
            WHERE rowid not in
            (SELECT MIN(rowid)
            FROM RBL_TEMPDB.TempAdvCustOtherDetail
            GROUP BY CustomerEntityid);


EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTOTHERDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
