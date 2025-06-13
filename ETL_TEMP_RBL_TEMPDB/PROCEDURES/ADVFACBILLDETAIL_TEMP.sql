--------------------------------------------------------
--  DDL for Procedure ADVFACBILLDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
   --GO
   /*********************************************************************************************************/
   /*  New Customers Account Entity ID Update  */
   v_BillEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Date_ INTO v_DATE
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempAdvFacBillDetail ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   /*************************************************************************************************************************/
   INSERT INTO RBL_TEMPDB.TempAdvFacBillDetail
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
              NULL BillNatureAlt_Key  ,
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
              JOIN RBL_TEMPDB.TempAdvAcBasicDetail A   ON A.SystemACID = BILL.RefSystemAcid
              LEFT JOIN RBL_MISDB_PROD.DimCurrency C   ON BILL.CurrencyCode = C.CurrencyCode
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
        WHERE  A.FacilityType IN ( 'BD','BP','BILL' )
      );
   MERGE INTO RBL_TEMPDB.TempAdvFacBillDetail 
   USING (SELECT RBL_TEMPDB.TempAdvFacBillDetail.ROWID row_id, D.SourceAlt_Key
   FROM RBL_TEMPDB.TempAdvFacBillDetail ,RBL_STGDB.BILL_SOURCESYSTEM_STG BILL
          LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB D   ON BILL.BillNatureAlt_Key = D.SourceName
          AND D.EffectiveFromTimeKey <= v_TimeKey
          AND D.EffectiveToTimeKey >= v_TimeKey ) src
   ON ( RBL_TEMPDB.TempAdvFacBillDetail.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET BillNatureAlt_Key = src.SourceAlt_Key;
   MERGE INTO RBL_TEMPDB.TempAdvFacBillDetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.BillEntityId
   FROM RBL_TEMPDB.TempAdvFacBillDetail TEMP
          JOIN CURDAT_RBL_MISDB_PROD.AdvFacBillDetail MAIN   ON TEMP.AccountEntityId = MAIN.AccountEntityId
          AND TEMP.BILLNO = MAIN.BILLNO
          AND TEMP.BILLREFNO = MAIN.BILLREFNO 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.BillEntityId = src.BillEntityId;
   
   SELECT MAX(BillEntityId)
     INTO v_BillEntityId
     FROM RBL_MISDB_PROD.AdvFacBillDetail ;
   IF v_BillEntityId IS NULL THEN

   BEGIN
      v_BillEntityId := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacBillDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.BillEntityId
   FROM RBL_TEMPDB.TempAdvFacBillDetail TEMP
          JOIN ( SELECT A.AccountEntityId ,
                        A.BILLNO ,
                        A.BillRefNo ,
                        (v_BillEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                           FROM DUAL  )  )) BillEntityId  
                 FROM RBL_TEMPDB.TempAdvFacBillDetail A
                  WHERE  A.BillEntityId = 0
                           OR A.BillEntityId IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId
          AND TEMP.BILLNO = ACCT.BILLNO
          AND TEMP.BillRefNo = ACCT.BillRefNo ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.BillEntityId = src.BillEntityId;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACBILLDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
