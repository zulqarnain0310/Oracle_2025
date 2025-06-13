--------------------------------------------------------
--  DDL for Procedure ADVFACPCDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   v_vEFFECTIVEFROM NUMBER(5,0) := ( SELECT Timekey 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
-- Add the parameters for the stored procedure here

BEGIN

   ----TRUNCATE TABLE [MISDB_31052018].[CURDAT].[AdvFacPCDetail]
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvFacPCDetail ';--[dbo].[TempAdvFacPCDetail]
   INSERT INTO TempAdvFacPCDetail
     ( AccountEntityId, PCRefNo, PCAdvDt, PCAmt, PCDueDt, PCDurationDays, PCExtendedDueDt, ExtensionReason, CurrencyAlt_Key, LcNo, LcAmt, LcIssueDt, LcIssuingBank_FirmOrder, Balance, BalanceInCurrency, BalanceInUSD, Overdue, CommodityAlt_Key, CommodityValue, CommodityMarketValue, ShipmentDt, CommercialisationDt, EcgcPolicyNo, CAD, CADU, OverDueSinceDt, TotalProv, Secured, Unsecured, Provsecured, ProvUnsecured, ProvDicgc, npadt, CoverGovGur, DerecognisedInterest1, DerecognisedInterest2, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, AdjDt, EntityClosureDate, EntityClosureReasonAlt_Key, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, UnAppliedIntt, MocTypeAlt_Key, MocStatus, MocDate, RBI_ExtnPermRefNo, LC_OrderAlt_Key, OrderLC_CurrencyAlt_Key, CountryAlt_Key, LcAmtInCurrenc, PcEntityId, Ischanged )
     ( SELECT DISTINCT AccountID AccountEntityId  ,
                       PCRefNo PCRefNo  ,
                       PCAdvDt PCAdvDt  ,
                       PCAmt PCAmt  ,
                       PCDueDt PCDueDt  ,
                       PCDurationDays PCDurationDays  ,
                       PCExtendedDueDt PCExtendedDueDt  ,
                       ExtensionReason ExtensionReason  ,
                       CC.CurrencyAlt_Key CurrencyAlt_Key  ,
                       LcNo LcNo  ,
                       LcAmt LcAmt  ,
                       LcIssueDt LcIssueDt  ,
                       LcIssuingBank_FirmOrder LcIssuingBank_FirmOrder  ,
                       BalanceInINR Balance  ,
                       BalanceInCurrency BalanceInCurrency  ,
                       BalanceInUSD BalanceInUSD  ,
                       OverdueAmt Overdue  ,
                       NULL CommodityAlt_Key  ,
                       NULL CommodityValue  ,
                       NULL CommodityMarketValue  ,
                       NULL ShipmentDt  ,
                       NULL CommercialisationDt  ,
                       NULL EcgcPolicyNo  ,
                       NULL CAD  ,
                       NULL CADU  ,
                       NULL OverDueSinceDt  ,
                       NULL TotalProv  ,
                       NULL Secured  ,
                       NULL Unsecured  ,
                       NULL Provsecured  ,
                       NULL ProvUnsecured  ,
                       NULL ProvDicgc  ,
                       Npadt npadt  ,
                       NULL CoverGovGur  ,
                       NULL DerecognisedInterest1  ,
                       NULL DerecognisedInterest2  ,
                       NULL ClaimType  ,
                       NULL ClaimCoverAmt  ,
                       NULL ClaimLodgedDt  ,
                       NULL ClaimLodgedAmt  ,
                       NULL ClaimRecvDt  ,
                       NULL ClaimReceivedAmt  ,
                       NULL ClaimRate  ,
                       NULL AdjDt  ,
                       EntityClosureDate EntityClosureDate  ,
                       0 ,--EntityClosureReasonCode	EntityClosureReasonAlt_Key

                       RefSystemAcid RefSystemAcid  ,
                       NULL AuthorisationStatus  ,
                       v_vEFFECTIVEFROM EffectiveFromTimeKey  ,
                       49999 EffectiveToTimeKey  ,
                       'SSISUSER' CreatedBy  ,
                       SYSDATE DateCreated  ,
                       NULL ModifiedBy  ,
                       NULL DateModified  ,
                       NULL ApprovedBy  ,
                       NULL DateApproved  ,
                       UnAppliedIntt UnAppliedIntt  ,
                       NULL MocTypeAlt_Key  ,
                       NULL MocStatus  ,
                       NULL MocDate  ,
                       NULL RBI_ExtnPermRefNo  ,
                       NULL LC_OrderAlt_Key  ,
                       NULL OrderLC_CurrencyAlt_Key  ,
                       NULL CountryAlt_Key  ,
                       NULL LcAmtInCurrenc  ,
                       NULL PcEntityId  ,
                       NULL Ischanged  
       FROM TempADVACBASICDETAIL AA
              JOIN RBL_STGDB.PC_SOURCESYSTEM_STG PC   ON PC.AccountID = AA.CustomerAcid
              LEFT JOIN RBL_MISDB_010922_UAT.DimCurrency cc   ON cc.CurrencyCode = PC.CurrencyCode );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
