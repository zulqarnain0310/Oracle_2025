--------------------------------------------------------
--  DDL for Procedure ADVCUSTRELATIONSHIP_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" 
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
   MERGE INTO RBL_TEMPDB.TempAdvCustRelationship A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvCustRelationship A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvCustRelationship B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerEntityId = A.CustomerEntityId
                                 AND B.RelationEntityId = A.RelationEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
   MERGE INTO RBL_MISDB_PROD.AdvCustRelationship O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvCustRelationship O
          JOIN RBL_TEMPDB.TempAdvCustRelationship T   ON O.CustomerEntityId = T.CustomerEntityId
          AND O.RelationEntityId = T.RelationEntityId
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.CustomerEntityId, 0) <> NVL(T.CustomerEntityId, 0)
     OR NVL(O.RelationEntityId, 0) <> NVL(T.RelationEntityId, 0)
     OR NVL(O.SalutationAlt_Key, 0) <> NVL(T.SalutationAlt_Key, 0)
     OR NVL(O.Name, 0) <> NVL(T.Name, 0)
     OR NVL(O.ConstitutionAlt_Key, 0) <> NVL(T.ConstitutionAlt_Key, 0)
     OR NVL(O.OccupationAlt_Key, 0) <> NVL(T.OccupationAlt_Key, 0)
     OR NVL(O.ReligionAlt_Key, 0) <> NVL(T.ReligionAlt_Key, 0)
     OR NVL(O.CasteAlt_Key, 0) <> NVL(T.CasteAlt_Key, 0)
     OR NVL(O.FarmerCatAlt_Key, 0) <> NVL(T.FarmerCatAlt_Key, 0)
     OR NVL(O.MaritalStatusAlt_Key, 0) <> NVL(T.MaritalStatusAlt_Key, 0)
     OR NVL(O.NetWorth, 0) <> NVL(T.NetWorth, 0)
     OR NVL(O.DateofBirth, '1990-01-01') <> NVL(T.DateofBirth, '1990-01-01')
     OR NVL(O.Qualification1Alt_Key, 0) <> NVL(T.Qualification1Alt_Key, 0)
     OR NVL(O.Qualification2Alt_Key, 0) <> NVL(T.Qualification2Alt_Key, 0)
     OR NVL(O.Qualification3Alt_Key, 0) <> NVL(T.Qualification3Alt_Key, 0)
     OR NVL(O.Qualification4Alt_Key, 0) <> NVL(T.Qualification4Alt_Key, 0)
     OR NVL(O.MobileNo, 0) <> NVL(T.MobileNo, 0)
     OR NVL(O.Email, 0) <> NVL(T.Email, 0)
     OR NVL(O.VoterID, 0) <> NVL(T.VoterID, 0)
     OR NVL(O.RationCardNo, 0) <> NVL(T.RationCardNo, 0)
     OR NVL(O.AadhaarId, 0) <> NVL(T.AadhaarId, 0)
     OR NVL(O.NPR_Id, 0) <> NVL(T.NPR_Id, 0)
     OR NVL(O.PassportNo, 0) <> NVL(T.PassportNo, 0)
     OR NVL(O.PassportIssueDt, '1990-01-01') <> NVL(T.PassportIssueDt, '1990-01-01')
     OR NVL(O.PassportExpiryDt, '1990-01-01') <> NVL(T.PassportExpiryDt, '1990-01-01')
     OR NVL(O.PassportIssueLocation, 0) <> NVL(T.PassportIssueLocation, 0)
     OR NVL(O.DL_No, 0) <> NVL(T.DL_No, 0)
     OR NVL(O.DL_IssueDate, '1990-01-01') <> NVL(T.DL_IssueDate, '1990-01-01')
     OR NVL(O.DL_ExpiryDate, '1990-01-01') <> NVL(T.DL_ExpiryDate, '1990-01-01')
     OR NVL(O.DL_IssueLocation, 0) <> NVL(T.DL_IssueLocation, 0)
     OR NVL(O.BusiEntity_NationalityTypeAlt_Key, 0) <> NVL(T.BusiEntity_NationalityTypeAlt_Key, 0)
     OR NVL(O.NationalityCountryAlt_Key, 0) <> NVL(T.NationalityCountryAlt_Key, 0)
     OR NVL(O.PAN, 0) <> NVL(T.PAN, 0)
     OR NVL(O.TAN, 0) <> NVL(T.TAN, 0)
     OR NVL(O.TIN, 0) <> NVL(T.TIN, 0)
     OR NVL(O.RegistrationNo, 0) <> NVL(T.RegistrationNo, 0)
     OR NVL(O.DIN, 0) <> NVL(T.DIN, 0)
     OR NVL(O.CIN, 0) <> NVL(T.CIN, 0)
     OR NVL(O.ServiceTax, 0) <> NVL(T.ServiceTax, 0)
     OR NVL(O.OtherID, 0) <> NVL(T.OtherID, 0)
     OR NVL(O.OtherIdType, 0) <> NVL(T.OtherIdType, 0)
     OR NVL(O.RegistrationAuth, 0) <> NVL(T.RegistrationAuth, 0)
     OR NVL(O.RegistrationAuthLocation, 0) <> NVL(T.RegistrationAuthLocation, 0)
     OR NVL(O.PrevFinYearSales, 0) <> NVL(T.PrevFinYearSales, 0)
     OR NVL(O.EmployeeCount, 0) <> NVL(T.EmployeeCount, 0)
     OR NVL(O.SalesFigFinYr, '1990-01-01') <> NVL(T.SalesFigFinYr, '1990-01-01')
     OR NVL(O.Designation_ContactPeroson, 0) <> NVL(T.Designation_ContactPeroson, 0)
     OR NVL(O.IncorporationDate, '1990-01-01') <> NVL(T.IncorporationDate, '1990-01-01')
     OR NVL(O.BusinessCategoryAlt_Key, 0) <> NVL(T.BusinessCategoryAlt_Key, 0)
     OR NVL(O.BusinessIndustryTypeAlt_Key, 0) <> NVL(T.BusinessIndustryTypeAlt_Key, 0)
     OR NVL(O.SharePercent, 0) <> NVL(T.SharePercent, 0)
     OR NVL(O.RetirementDate, '1990-01-01') <> NVL(T.RetirementDate, '1990-01-01')
     OR NVL(O.ProfessionArea, 0) <> NVL(T.ProfessionArea, 0)
     OR NVL(O.ExistingCustomer, 0) <> NVL(T.ExistingCustomer, 0)
     OR NVL(O.RefCustomerId, 0) <> NVL(T.RefCustomerId, 0)
     OR NVL(O.BecomNRI_Dt, '1990-01-01') <> NVL(T.BecomNRI_Dt, '1990-01-01')
     OR NVL(O.AuthSignStartDt, '1990-01-01') <> NVL(T.AuthSignStartDt, '1990-01-01')
     OR NVL(O.AuthSignEndDt, '1990-01-01') <> NVL(T.AuthSignEndDt, '1990-01-01')
     OR NVL(O.ScrCrErrorSeq, 0) <> NVL(T.ScrCrErrorSeq, 0)
     OR NVL(O.NetWorthDate, '1990-01-01') <> NVL(T.NetWorthDate, '1990-01-01')
     OR NVL(O.AdvNetWorth, 0) <> NVL(T.AdvNetWorth, 0)
     OR NVL(O.DefendentExpire, 0) <> NVL(T.DefendentExpire, 0)
     OR NVL(O.DefendentExpireDt, '1990-01-01') <> NVL(T.DefendentExpireDt, '1990-01-01')
     --OR NVL(O.PPhoto,'') <> NVL(T.PPhoto, '')
     OR O.PPhoto NOT LIKE T.PPhoto
     OR NVL(O.PPhotoDt, '1990-01-01') <> NVL(T.PPhotoDt, '1990-01-01')
     OR NVL(O.PPhotoURL, 0) <> NVL(T.PPhotoURL, 0)
     OR NVL(O.ActionStatus, 0) <> NVL(T.ActionStatus, 0)
     OR NVL(O.DirectorDebarred, 0) <> NVL(T.DirectorDebarred, 0)
     OR NVL(O.LEI, 0) <> NVL(T.LEI, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvCustRelationship A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvCustRelationship A
          JOIN RBL_MISDB_PROD.AdvCustRelationship B   ON B.CustomerEntityId = A.CustomerEntityId 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvCustRelationship AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvCustRelationship AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvCustRelationship BB
                       WHERE  AA.CustomerEntityId = BB.CustomerEntityId
                                AND AA.RelationEntityId = BB.RelationEntityId
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   /********************************************************************************************************/
   INSERT INTO RBL_MISDB_PROD.AdvCustRelationship
     ( EntityKey, CustomerEntityId, RelationEntityId, SalutationAlt_Key, Name, ConstitutionAlt_Key, OccupationAlt_Key, ReligionAlt_Key, CasteAlt_Key, FarmerCatAlt_Key, MaritalStatusAlt_Key, NetWorth, DateofBirth, Qualification1Alt_Key, Qualification2Alt_Key, Qualification3Alt_Key, Qualification4Alt_Key, MobileNo, Email, VoterID, RationCardNo, AadhaarId, NPR_Id, PassportNo, PassportIssueDt, PassportExpiryDt, PassportIssueLocation, DL_No, DL_IssueDate, DL_ExpiryDate, DL_IssueLocation, BusiEntity_NationalityTypeAlt_Key, NationalityCountryAlt_Key, PAN, TAN, TIN, RegistrationNo, DIN, CIN, ServiceTax, OtherID, OtherIdType, RegistrationAuth, RegistrationAuthLocation, PrevFinYearSales, EmployeeCount, SalesFigFinYr, Designation_ContactPeroson, IncorporationDate, BusinessCategoryAlt_Key, BusinessIndustryTypeAlt_Key, SharePercent, RetirementDate, ProfessionArea, ExistingCustomer, ScrCrError, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
   -- ,[D2Ktimestamp]
   , CIBILPGId, Initial_, BecomNRI_Dt, AuthSignStartDt, AuthSignEndDt, ScrCrErrorSeq, NetWorthDate, AdvNetWorth, DefendentExpire, DefendentExpireDt, PPhoto, PPhotoDt, PPhotoURL, ActionStatus, DirectorDebarred, LEI )
     ( SELECT EntityKey ,
              CustomerEntityId ,
              RelationEntityId ,
              SalutationAlt_Key ,
              NAME ,
              ConstitutionAlt_Key ,
              OccupationAlt_Key ,
              ReligionAlt_Key ,
              CasteAlt_Key ,
              FarmerCatAlt_Key ,
              MaritalStatusAlt_Key ,
              NetWorth ,
              DateofBirth ,
              Qualification1Alt_Key ,
              Qualification2Alt_Key ,
              Qualification3Alt_Key ,
              Qualification4Alt_Key ,
              MobileNo ,
              Email ,
              VoterID ,
              RationCardNo ,
              AadhaarId ,
              NPR_Id ,
              PassportNo ,
              PassportIssueDt ,
              PassportExpiryDt ,
              PassportIssueLocation ,
              DL_No ,
              DL_IssueDate ,
              DL_ExpiryDate ,
              DL_IssueLocation ,
              BusiEntity_NationalityTypeAlt_Key ,
              NationalityCountryAlt_Key ,
              PAN ,
              TAN ,
              TIN ,
              RegistrationNo ,
              DIN ,
              CIN ,
              ServiceTax ,
              OtherID ,
              OtherIdType ,
              RegistrationAuth ,
              RegistrationAuthLocation ,
              PrevFinYearSales ,
              EmployeeCount ,
              SalesFigFinYr ,
              Designation_ContactPeroson ,
              IncorporationDate ,
              BusinessCategoryAlt_Key ,
              BusinessIndustryTypeAlt_Key ,
              SharePercent ,
              RetirementDate ,
              ProfessionArea ,
              ExistingCustomer ,
              ScrCrError ,
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
              --,D2Ktimestamp
              CIBILPGId ,
              Initial_ ,
              BecomNRI_Dt ,
              AuthSignStartDt ,
              AuthSignEndDt ,
              ScrCrErrorSeq ,
              NetWorthDate ,
              AdvNetWorth ,
              DefendentExpire ,
              DefendentExpireDt ,
              PPhoto ,
              PPhotoDt ,
              PPhotoURL ,
              ActionStatus ,
              DirectorDebarred ,
              LEI 
       FROM RBL_TEMPDB.TempAdvCustRelationship T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );
   MERGE INTO RBL_MISDB_PROD.AdvCustRelationship A
   USING (SELECT A.ROWID row_id, B.UCIF_ID, B.UCIFEntityID
   FROM RBL_MISDB_PROD.AdvCustRelationship A
          LEFT JOIN RBL_MISDB_PROD.CustomerBasicDetail B   ON A.CustomerEntityid = B.CustomerEntityID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.UCIF_ID = src.UCIF_ID,
                                A.UCIFEntityID = src.UCIFEntityID;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVCUSTRELATIONSHIP_MAIN" TO "ADF_CDR_RBL_STGDB";
