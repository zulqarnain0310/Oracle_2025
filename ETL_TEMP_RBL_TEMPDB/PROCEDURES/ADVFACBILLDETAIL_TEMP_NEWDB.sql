--------------------------------------------------------
--  DDL for Procedure ADVFACBILLDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --GO
   /*********************************************************************************************************/
   /*  New Customers Account Entity ID Update  */
   v_BillEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvFacBillDetail ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   /*************************************************************************************************************************/
   MERGE INTO BILL 
   USING (SELECT BILL.ROWID row_id, D.SourceAlt_Key
   FROM BILL ,RBL_STGDB.BILL_SOURCESYSTEM_STG BILL
          LEFT JOIN RBL_MISDB_010922_UAT.DIMSOURCEDB D   ON BILL.BillNatureAlt_Key = D.SourceName
          AND D.EffectiveFromTimeKey <= v_TimeKey
          AND D.EffectiveToTimeKey >= v_TimeKey ) src
   ON ( BILL.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET BILL.BillNatureAlt_Key = src.SourceAlt_Key;
   INSERT INTO TempAdvFacBillDetail
     ( AccountEntityId, BillEntityId, BillNo, BillDt, BillAmt, BillRefNo, BillPurDt, AdvAmount, BillDueDt, BillExtendedDueDt, CrystalisationDt, CommercialisationDt, BillNatureAlt_Key, BillAcceptanceDt, UsanceDays, DraweeNo, DraweeBankName, DrawerName, PayeeName, CollectingBankName, CollectingBranchPlace, InterestIncome, Commission, DiscountCharges, DelayedInt, MarginType, MarginAmt, CountryAlt_Key, BillOsReasonAlt_Key, CommodityAlt_Key, LcNo, LcAmt, LcIssuingBankAlt_Key, LcIssuingBank, CurrencyAlt_Key, Balance, BalanceInCurrency, Overdue, DerecognisedInterest1, DerecognisedInterest2, OverDueSinceDt, TotalProv, AdditionalProv, GenericAddlProv, Secured, CoverGovGur, Unsecured, Provsecured, ProvUnsecured, ProvDicgc, npadt, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, ScrCrError, RefSystemAcid, AdjDt, AdjReasonAlt_Key, EntityClosureDate, EntityClosureReasonAlt_Key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, ScrCrErrorSeq, ConsigmentExport )
     ( SELECT A.AccountEntityId AccountEntityId  ,
              0 BillEntityId  ,
              BILL.BillNo BillNo  ,
              BILL.BillDt BillDt  ,
              BILL.BillAmt BillAmt  ,
              BILL.BillRefNo BillRefNo  ,
              BILL.BillPurDt BillPurDt  ,
              BILL.AdvAmount AdvAmount  ,
              BILL.BillDueDt BillDueDt  ,
              BILL.BillExtendedDueDt BillExtendedDueDt  ,
              BILL.CrystalisationDt CrystalisationDt  ,
              BILL.CommercialisationDt CommercialisationDt  ,
              BILL.BillNatureAlt_Key ,
              NULL BillAcceptanceDt  ,
              NULL UsanceDays  ,
              NULL DraweeNo  ,
              NULL DraweeBankName  ,
              NULL DrawerName  ,
              NULL PayeeName  ,
              NULL CollectingBankName  ,
              NULL CollectingBranchPlace  ,
              NULL InterestIncome  ,
              NULL Commission  ,
              NULL DiscountCharges  ,
              NULL DelayedInt  ,
              NULL MarginType  ,
              NULL MarginAmt  ,
              NULL CountryAlt_Key  ,
              BILL.AdjReasonCode BillOsReasonAlt_Key  ,
              NULL CommodityAlt_Key  ,
              BILL.LcNo LcNo  ,
              BILL.LcAmt LcAmt  ,
              BILL.LcIssuingBankCode LcIssuingBankAlt_Key  ,
              BILL.LcIssuingBank LcIssuingBank  ,
              BILL.CurrencyCode CurrencyAlt_Key  ,
              BILL.BalanceInINR Balance  ,
              BILL.BalanceInCurrency BalanceInCurrency  ,
              NULL Overdue  ,
              NULL DerecognisedInterest1  ,
              BILL.DerecognisedInterest DerecognisedInterest2  ,
              NULL OverDueSinceDt  ,
              NULL TotalProv  ,
              NULL AdditionalProv  ,
              NULL GenericAddlProv  ,
              NULL Secured  ,
              NULL CoverGovGur  ,
              NULL Unsecured  ,
              NULL Provsecured  ,
              NULL ProvUnsecured  ,
              NULL ProvDicgc  ,
              BILL.Npadt npadt  ,
              NULL ClaimType  ,
              NULL ClaimCoverAmt  ,
              NULL ClaimLodgedDt  ,
              NULL ClaimLodgedAmt  ,
              NULL ClaimRecvDt  ,
              NULL ClaimReceivedAmt  ,
              NULL ClaimRate  ,
              NULL ScrCrError  ,
              RefSystemAcid RefSystemAcid  ,
              BILL.AdjDt AdjDt  ,
              NULL AdjReasonAlt_Key  ,
              NULL EntityClosureDate  ,
              NULL EntityClosureReasonAlt_Key  ,
              NULL AuthorisationStatus  ,
              v_TimeKey EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey0  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL MocTypeAlt_Key  ,
              NULL ScrCrErrorSeq  ,
              NULL ConsigmentExport  
       FROM RBL_STGDB.BILL_SOURCESYSTEM_STG BILL
              JOIN TempAdvAcBasicDetail A   ON A.SystemACID = BILL.RefSystemAcid
              LEFT JOIN RBL_MISDB_010922_UAT.DimCurrency C   ON BILL.CurrencyCode = C.CurrencyCode
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
        WHERE  A.FacilityType IN ( 'BD','BP','BILL' )
      );
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, MAIN.BillEntityId
   FROM TEMP ,RBL_TEMPDB.TempAdvFacBillDetail TEMP
          JOIN RBL_MISDB_010922_UAT.AdvFacBillDetail MAIN   ON TEMP.AccountEntityId = MAIN.AccountEntityId
          AND TEMP.BILLNO = MAIN.BILLNO
          AND TEMP.BILLREFNO = MAIN.BILLREFNO 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.BillEntityId = src.BillEntityId;
   SELECT MAX(BillEntityId)  

     INTO v_BillEntityId
     FROM RBL_MISDB_010922_UAT.AdvFacBillDetail ;
   IF v_BillEntityId IS NULL THEN

   BEGIN
      v_BillEntityId := 0 ;

   END;
   END IF;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, ACCT.BillEntityId
   FROM TEMP ,RBL_TEMPDB.TempAdvFacBillDetail TEMP
          JOIN ( SELECT "TEMPADVFACBILLDETAIL".AccountEntityId ,
                        "TEMPADVFACBILLDETAIL".BILLNO ,
                        "TEMPADVFACBILLDETAIL".BillRefNo ,
                        (v_BillEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                           FROM DUAL  )  )) BillEntityId  
                 FROM RBL_TEMPDB.TempAdvFacBillDetail 
                  WHERE  "TEMPADVFACBILLDETAIL".BillEntityId = 0
                           OR "TEMPADVFACBILLDETAIL".BillEntityId IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId
          AND TEMP.BILLNO = ACCT.BILLNO
          AND TEMP.BillRefNo = ACCT.BillRefNo ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.BillEntityId = src.BillEntityId;
   ----Updated by mandeep (19-11-2022) for making all column null used to count dpd ----------------------------------------------
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, NULL, NULL
   FROM B ,RBL_TEMPDB.TempAdvFacBillDetail A
          JOIN RBL_TEMPDB.TempAdVAcBalanceDetail B   ON a.ACCOUNTENTITYID = b.AccountEntityId ) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.OverDueSinceDt = NULL,
                                B.LastCrDt = NULL;
   MERGE INTO C 
   USING (SELECT C.ROWID row_id, NULL
   FROM C ,RBL_TEMPDB.TempAdvFacBillDetail A
          JOIN RBL_TEMPDB.TempAdvAcFinancialDetail C   ON A.AccountEntityId = C.AccountEntityId ) src
   ON ( C.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET C.Ac_NextReviewDueDt = NULL;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
