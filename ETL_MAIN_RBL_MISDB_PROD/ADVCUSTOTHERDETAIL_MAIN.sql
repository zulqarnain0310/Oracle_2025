--------------------------------------------------------
--  DDL for Procedure ADVCUSTOTHERDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   v_EntityKey NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvCustOtherDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvCustOtherDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvCustOtherDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerEntityId = A.CustomerEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
   --------------------------------------------------------------------------------
   MERGE INTO RBL_MISDB_PROD.AdvCustOtherDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvCustOtherDetail O
          JOIN RBL_TEMPDB.TempAdvCustOtherDetail T   ON O.CustomerEntityId = T.CustomerEntityId
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.OrgCostOfEquip, 0) <> NVL(T.OrgCostOfEquip, 0)
     OR NVL(O.OrgCostOfPlantMech, 0) <> NVL(T.OrgCostOfPlantMech, 0)
     OR NVL(O.DepValPlant, 0) <> NVL(T.DepValPlant, 0)
     OR NVL(O.ValLand, 0) <> NVL(T.ValLand, 0)
     OR NVL(O.IECDno, 0) <> NVL(T.IECDno, 0)
     OR NVL(O.GroupAlt_Key, 0) <> NVL(T.GroupAlt_Key, 0)
     OR NVL(O.CustomerSwiftCode, 0) <> NVL(T.CustomerSwiftCode, 0)
     OR NVL(O.SplCatg1Alt_Key, 0) <> NVL(T.SplCatg1Alt_Key, 0)
     OR NVL(O.SplCatg2Alt_Key, 0) <> NVL(T.SplCatg2Alt_Key, 0)
     OR NVL(O.SplCatg3Alt_Key, 0) <> NVL(T.SplCatg3Alt_Key, 0)
     OR NVL(O.SplCatg4Alt_Key, 0) <> NVL(T.SplCatg4Alt_Key, 0)
     OR NVL(O.CmaEligible, 0) <> NVL(T.CmaEligible, 0)
     OR NVL(O.PFNo, 0) <> NVL(T.PFNo, 0)
     OR NVL(O.SupperAnnuationBenefit, 0) <> NVL(T.SupperAnnuationBenefit, 0)
     OR NVL(O.SupperannuationBenefitValuationDt, '1990-01-01') <> NVL(T.SupperannuationBenefitValuationDt, '1990-01-01')
     OR NVL(O.BusinessCommenceDt, '1990-01-01') <> NVL(T.BusinessCommenceDt, '1990-01-01')
     OR NVL(O.CancelObtained, 0) <> NVL(T.CancelObtained, 0)
     OR NVL(O.TotConsortiumLimitFunded, 0) <> NVL(T.TotConsortiumLimitFunded, 0)
     OR NVL(O.TotConsortiumLimitNonFunded, 0) <> NVL(T.TotConsortiumLimitNonFunded, 0)
     OR NVL(O.UpgradationDate, '1990-01-01') <> NVL(T.UpgradationDate, '1990-01-01')
     OR NVL(O.CustomerExpiredYN, 0) <> NVL(T.CustomerExpiredYN, 0)
     OR NVL(O.TotWCLimitFunded, 0) <> NVL(T.TotWCLimitFunded, 0)
     OR NVL(O.Flagged_SubSector, 0) <> NVL(T.Flagged_SubSector, 0)
     OR NVL(O.RefCustomerId, 0) <> NVL(T.RefCustomerId, 0)
     OR NVL(O.MocStatus, 0) <> NVL(T.MocStatus, 0)
     OR NVL(O.MocDate, '1990-01-01') <> NVL(T.MocDate, '1990-01-01')
     OR NVL(O.MocTypeAlt_Key, 0) <> NVL(T.MocTypeAlt_Key, 0)
     OR NVL(O.AnnualExportTurnover, 0) <> NVL(T.AnnualExportTurnover, 0)
     OR NVL(O.FMCNumber, 0) <> NVL(T.FMCNumber, 0)
     OR NVL(O.IsEmployee, 0) <> NVL(T.IsEmployee, 0)
     OR NVL(O.IsPetitioner, 0) <> NVL(T.IsPetitioner, 0)
     OR NVL(O.UnderLitigation, 0) <> NVL(T.UnderLitigation, 0)
     OR NVL(O.PermiNatureID, 0) <> NVL(T.PermiNatureID, 0)
     OR NVL(O.BorrUnitFunct, 0) <> NVL(T.BorrUnitFunct, 0)
     OR NVL(O.DtofClosure, '1990-01-01') <> NVL(T.DtofClosure, '1990-01-01')
     OR NVL(O.NonCoopBorrower, 0) <> NVL(T.NonCoopBorrower, 0)
     OR NVL(O.ArbiAgreement, 0) <> NVL(T.ArbiAgreement, 0)
     OR NVL(O.TransThroughUs, 0) <> NVL(T.TransThroughUs, 0)
     OR NVL(O.CutBackArrangement, 0) <> NVL(T.CutBackArrangement, 0)
     OR NVL(O.BankingArrangement, 0) <> NVL(T.BankingArrangement, 0)
     OR NVL(O.MemberBanksNo, 0) <> NVL(T.MemberBanksNo, 0)
     OR NVL(O.TotalConsortiumAmt, 0) <> NVL(T.TotalConsortiumAmt, 0)
     OR NVL(O.ROC_CFCReportDate, '1990-01-01') <> NVL(T.ROC_CFCReportDate, '1990-01-01')
     OR NVL(O.ROC_ChargeFV, 0) <> NVL(T.ROC_ChargeFV, 0)
     OR NVL(O.ROC_ChargeFVDt, '1990-01-01') <> NVL(T.ROC_ChargeFVDt, '1990-01-01')
     OR NVL(O.ROC_ChargeRemark, 0) <> NVL(T.ROC_ChargeRemark, 0)
     OR NVL(O.ROC_Securities, 0) <> NVL(T.ROC_Securities, 0)
     OR NVL(O.ROC_Cover, 0) <> NVL(T.ROC_Cover, 0)
     OR NVL(O.ROC_CoveredDt, '1990-01-01') <> NVL(T.ROC_CoveredDt, '1990-01-01')
     OR NVL(O.ChargeFiledWith, 0) <> NVL(T.ChargeFiledWith, 0)
     OR NVL(O.FiledDt, '1990-01-01') <> NVL(T.FiledDt, '1990-01-01')
     OR NVL(O.EmployeeID, 0) <> NVL(T.EmployeeID, 0)
     OR NVL(O.EmployeeType, 0) <> NVL(T.EmployeeType, 0)
     OR NVL(O.Designation, 0) <> NVL(T.Designation, 0)
     OR NVL(O.Placeofposting, 0) <> NVL(T.Placeofposting, 0)
     OR NVL(O.LPersonalConDate, '1990-01-01') <> NVL(T.LPersonalConDate, '1990-01-01')
     OR NVL(O.LPersonalConDtls, 0) <> NVL(T.LPersonalConDtls, 0)
     OR NVL(O.RecallNoticeDate, '1990-01-01') <> NVL(T.RecallNoticeDate, '1990-01-01')
     OR NVL(O.RecallNoticeModeID, 0) <> NVL(T.RecallNoticeModeID, 0)
     OR NVL(O.LegalAuditDate, '1990-01-01') <> NVL(T.LegalAuditDate, '1990-01-01')
     OR NVL(O.IrregularityPending, 0) <> NVL(T.IrregularityPending, 0)
     OR NVL(O.IrregularityRectiDate, '1990-01-01') <> NVL(T.IrregularityRectiDate, '1990-01-01')
     OR NVL(O.FraudAccoStatus, 0) <> NVL(T.FraudAccoStatus, 0)
     OR NVL(O.PreSARFAESINoticeDt, '1990-01-01') <> NVL(T.PreSARFAESINoticeDt, '1990-01-01')
     OR NVL(O.FMRNO, 0) <> NVL(T.FMRNO, 0)
     OR NVL(O.FMRDate, '1990-01-01') <> NVL(T.FMRDate, '1990-01-01')
     OR NVL(O.GradeScaleAlt_Key, 0) <> NVL(T.GradeScaleAlt_Key, 0)
     OR NVL(O.FraudNatureRemark, 0) <> NVL(T.FraudNatureRemark, 0)
     OR NVL(O.ROCCoveredCertificateRemark, 0) <> NVL(T.ROCCoveredCertificateRemark, 0)
     OR NVL(O.ReasonsNonCoOperativeBorrower, 0) <> NVL(T.ReasonsNonCoOperativeBorrower, 0)
     OR NVL(O.StatusNonCoOperativeBorrower, 0) <> NVL(T.StatusNonCoOperativeBorrower, 0)
     OR NVL(O.SourceAssetClass, 0) <> NVL(T.SourceAssetClass, 0)
     OR NVL(O.SourceNpaDate, '1990-01-01') <> NVL(T.SourceNpaDate, '1990-01-01') )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   MERGE INTO RBL_TEMPDB.TempAdvCustOtherDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvCustOtherDetail A
          JOIN RBL_MISDB_PROD.AdvCustOtherDetail B   ON B.CustomerEntityId = A.CustomerEntityId 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvCustOtherDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvCustOtherDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvCustOtherDetail BB
                       WHERE  AA.CustomerEntityId = BB.CustomerEntityId
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvCustOtherDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvCustOtherDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.Customer_Key
   FROM RBL_TEMPDB.TempAdvCustOtherDetail TEMP
          JOIN ( SELECT "TEMPADVCUSTOTHERDETAIL".CUSTOMERENTITYID ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) Customer_Key  
                 FROM RBL_TEMPDB.TempAdvCustOtherDetail 
                  WHERE  "TEMPADVCUSTOTHERDETAIL".EntityKey = 0
                           OR "TEMPADVCUSTOTHERDETAIL".EntityKey IS NULL ) ACCT   ON Temp.CustomerEntityId = ACCT.CustomerEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.Customer_Key;
   INSERT INTO RBL_MISDB_PROD.AdvCustOtherDetail
     ( EntityKey, CustomerEntityId, OrgCostOfEquip, OrgCostOfPlantMech, DepValPlant, ValLand, IECDno, GroupAlt_Key, CustomerSwiftCode, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, CmaEligible, PFNo, SupperAnnuationBenefit, SupperannuationBenefitValuationDt, BusinessCommenceDt, CancelObtained, TotConsortiumLimitFunded, TotConsortiumLimitNonFunded, UpgradationDate, CustomerExpiredYN, TotWCLimitFunded, Flagged_SubSector, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, AnnualExportTurnover, FMCNumber, IsEmployee, IsPetitioner, UnderLitigation, PermiNatureID, BorrUnitFunct, DtofClosure, NonCoopBorrower, ArbiAgreement, TransThroughUs, CutBackArrangement, BankingArrangement, MemberBanksNo, TotalConsortiumAmt, ROC_CFCReportDate, ROC_ChargeFV, ROC_ChargeFVDt, ROC_ChargeRemark, ROC_Securities, ROC_Cover, ROC_CoveredDt, ChargeFiledWith, FiledDt, EmployeeID, EmployeeType, Designation, Placeofposting, LPersonalConDate, LPersonalConDtls, RecallNoticeDate, RecallNoticeModeID, LegalAuditDate, IrregularityPending, IrregularityRectiDate, FraudAccoStatus, PreSARFAESINoticeDt, FMRNO, FMRDate, GradeScaleAlt_Key, FraudNatureRemark, ROCCoveredCertificateRemark, ReasonsNonCoOperativeBorrower, StatusNonCoOperativeBorrower, SourceAssetClass, SourceNpaDate )
     ( SELECT EntityKey ,
              CustomerEntityId ,
              OrgCostOfEquip ,
              OrgCostOfPlantMech ,
              DepValPlant ,
              ValLand ,
              IECDno ,
              GroupAlt_Key ,
              CustomerSwiftCode ,
              SplCatg1Alt_Key ,
              SplCatg2Alt_Key ,
              SplCatg3Alt_Key ,
              SplCatg4Alt_Key ,
              CmaEligible ,
              PFNo ,
              SupperAnnuationBenefit ,
              SupperannuationBenefitValuationDt ,
              BusinessCommenceDt ,
              CancelObtained ,
              TotConsortiumLimitFunded ,
              TotConsortiumLimitNonFunded ,
              UpgradationDate ,
              CustomerExpiredYN ,
              TotWCLimitFunded ,
              Flagged_SubSector ,
              RefCustomerId ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              SYSDATE D2Ktimestamp  ,
              MocStatus ,
              MocDate ,
              MocTypeAlt_Key ,
              AnnualExportTurnover ,
              FMCNumber ,
              IsEmployee ,
              IsPetitioner ,
              UnderLitigation ,
              PermiNatureID ,
              BorrUnitFunct ,
              DtofClosure ,
              NonCoopBorrower ,
              ArbiAgreement ,
              TransThroughUs ,
              CutBackArrangement ,
              BankingArrangement ,
              MemberBanksNo ,
              TotalConsortiumAmt ,
              ROC_CFCReportDate ,
              ROC_ChargeFV ,
              ROC_ChargeFVDt ,
              ROC_ChargeRemark ,
              ROC_Securities ,
              ROC_Cover ,
              ROC_CoveredDt ,
              ChargeFiledWith ,
              FiledDt ,
              EmployeeID ,
              EmployeeType ,
              Designation ,
              Placeofposting ,
              LPersonalConDate ,
              LPersonalConDtls ,
              RecallNoticeDate ,
              RecallNoticeModeID ,
              LegalAuditDate ,
              IrregularityPending ,
              IrregularityRectiDate ,
              FraudAccoStatus ,
              PreSARFAESINoticeDt ,
              FMRNO ,
              FMRDate ,
              GradeScaleAlt_Key ,
              FraudNatureRemark ,
              ROCCoveredCertificateRemark ,
              ReasonsNonCoOperativeBorrower ,
              StatusNonCoOperativeBorrower ,
              SourceAssetClass ,
              SourceNpaDate 
       FROM RBL_TEMPDB.TempAdvCustOtherDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTOTHERDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
