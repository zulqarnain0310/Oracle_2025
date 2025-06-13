--------------------------------------------------------
--  DDL for Procedure ADVCUSTRELATIONSHIP_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' DELETE FROM RBL_TEMPDB.TempAdvCustRelationship ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   INSERT INTO RBL_TEMPDB.TempAdvCustRelationship
     ( CustomerEntityId, RelationEntityId, SalutationAlt_Key, NAME, ConstitutionAlt_Key, OccupationAlt_Key, ReligionAlt_Key, CasteAlt_Key, FarmerCatAlt_Key, MaritalStatusAlt_Key, NetWorth, DateofBirth, Qualification1Alt_Key, Qualification2Alt_Key, Qualification3Alt_Key, Qualification4Alt_Key, MobileNo, Email, VoterID, RationCardNo, AadhaarId, NPR_Id, PassportNo, PassportIssueDt, PassportExpiryDt, PassportIssueLocation, DL_No, DL_IssueDate, DL_ExpiryDate, DL_IssueLocation, BusiEntity_NationalityTypeAlt_Key, NationalityCountryAlt_Key, PAN, TAN, TIN, RegistrationNo, DIN, CIN, ServiceTax, OtherID, OtherIdType, RegistrationAuth, RegistrationAuthLocation, PrevFinYearSales, EmployeeCount, SalesFigFinYr, Designation_ContactPeroson, IncorporationDate, BusinessCategoryAlt_Key, BusinessIndustryTypeAlt_Key, SharePercent, RetirementDate, ProfessionArea, ExistingCustomer, RefCustomerId, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, CIBILPGId, LEI )
     ( SELECT TCBD.CustomerEntityId ,
              RelationEntityId RelationEntityId  ,
              TCBD.CustSalutationAlt_Key ,
              TCBD.customername ,
              TCBD.ConstitutionAlt_Key ,
              TCBD.OccupationAlt_Key ,
              TCBD.ReligionAlt_Key ,
              TCBD.CasteAlt_Key ,
              TCBD.FarmerCatAlt_Key ,
              TCBD.MaritalStatusAlt_Key ,
              NULL NetWorth  ,
              NULL DateofBirth  ,
              NULL Qualification1Alt_Key  ,
              NULL Qualification2Alt_Key  ,
              NULL Qualification3Alt_Key  ,
              NULL Qualification4Alt_Key  ,
              NULL MobileNo  ,
              NULL Email  ,
              NULL VoterID  ,
              NULL RationCardNo  ,
              NULL AadhaarId  ,
              NULL NPR_Id  ,
              NULL PassportNo  ,
              NULL PassportIssueDt  ,
              NULL PassportExpiryDt  ,
              NULL PassportIssueLocation  ,
              NULL DL_No  ,
              NULL DL_IssueDate  ,
              NULL DL_ExpiryDate  ,
              NULL DL_IssueLocation  ,
              NULL BusiEntity_NationalityTypeAlt_Key  ,
              NULL NationalityCountryAlt_Key  ,
              NULL PAN  ,
              NULL TAN  ,
              NULL TIN  ,
              NULL RegistrationNo  ,
              NULL DIN  ,
              NULL CIN  ,
              NULL ServiceTax  ,
              NULL OtherID  ,
              NULL OtherIdType  ,
              NULL RegistrationAuth  ,
              NULL RegistrationAuthLocation  ,
              NULL PrevFinYearSales  ,
              NULL EmployeeCount  ,
              NULL SalesFigFinYr  ,
              NULL Designation_ContactPeroson  ,
              NULL IncorporationDate  ,
              NULL BusinessCategoryAlt_Key  ,
              NULL BusinessIndustryTypeAlt_Key  ,
              NULL SharePercent  ,
              NULL RetirementDate  ,
              NULL ProfessionArea  ,
              (CASE 
                    WHEN TCBD.CustomerEntityId IS NOT NULL THEN 'Y'
              ELSE 'N'
                 END) ExistingCustomer  ,
              TAAR.CustomerId ,
              v_vEffectivefrom ,
              49999 ,
              'SSISUSER' ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) ,
              NULL CIBILPGId  ,
              NULL LEI  
       FROM ( SELECT DISTINCT RefCustomerID CustomerId  ,
                              RelationEntityId 
              FROM RBL_TEMPDB.TempAdvAcRelations  ) TAAR
              LEFT JOIN RBL_TEMPDB.TempCustomerBasicDetail TCBD   ON TAAR.CustomerId = TCBD.CustomerID
              --JOIN RBL_STGDB.CUSTOMERRELATION_SOURCESYSTEM_STG CR   ON CR.CustomerID = TAAR.CustomerID
              --LEFT JOIN RBL_STGDB.CUSTOMERADDRESS_SOURCESYSTEM_STG CA   ON CA.CustomerID = CR.CustomerID
              );
   ---==============UPDATE  CUSTOMERNAME WHERE NAME IS BLANK---==============
   MERGE INTO RBL_TEMPDB.TempAdvCustRelationship A
   USING (SELECT A.ROWID row_id, CUSTOMERNAME
   FROM RBL_TEMPDB.TempAdvCustRelationship A
          JOIN RBL_TEMPDB.TempCUSTOMERBASICDETAIL B   ON A.REFCUSTOMERID = B.CUSTOMERID 
    WHERE NAME IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.NAME = CUSTOMERNAME;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTRELATIONSHIP_TEMP" TO "ADF_CDR_RBL_STGDB";
