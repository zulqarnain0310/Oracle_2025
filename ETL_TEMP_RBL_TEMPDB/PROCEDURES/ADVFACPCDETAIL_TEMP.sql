--------------------------------------------------------
--  DDL for Procedure ADVFACPCDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   v_vEFFECTIVEFROM NUMBER(5,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Timekey INTO v_vEFFECTIVEFROM
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   ----TRUNCATE TABLE [MISDB_31052018].[CURDAT].[AdvFacPCDetail]
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempAdvFacPCDetail ';--[dbo].[RBL_TEMPDB.TempAdvFacPCDetail]
   INSERT INTO RBL_TEMPDB.TempAdvFacPCDetail
     ( AccountEntityId, PCRefNo, PCAdvDt, PCAmt, PCDueDt, PCDurationDays, PCExtendedDueDt, ExtensionReason, CurrencyAlt_Key, LcNo, LcAmt, LcIssueDt, LcIssuingBank_FirmOrder, Balance, BalanceInCurrency, BalanceInUSD, Overdue, CommodityAlt_Key, CommodityValue, CommodityMarketValue, ShipmentDt, CommercialisationDt, EcgcPolicyNo, CAD, CADU, OverDueSinceDt, TotalProv, Secured, Unsecured, Provsecured, ProvUnsecured, ProvDicgc, npadt, CoverGovGur, DerecognisedInterest1, DerecognisedInterest2, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, AdjDt, EntityClosureDate, EntityClosureReasonAlt_Key, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, UnAppliedIntt, MocTypeAlt_Key, MocStatus, MocDate, RBI_ExtnPermRefNo, LC_OrderAlt_Key, OrderLC_CurrencyAlt_Key, CountryAlt_Key, LcAmtInCurrenc, PcEntityId, Ischanged )
     ( SELECT DISTINCT AccountEntityId ,
                       PCRefNo PCRefNo  ,
                       PCAdvDt PCAdvDt  ,
                       PCAmt PCAmt  ,
                       PCDueDt PCDueDt  ,
                       PCDurationDays PCDurationDays  ,
                       PCExtendedDueDt PCExtendedDueDt  ,
                       ExtensionReason ExtensionReason  ,
                       CC.CurrencyAlt_Key CurrencyAlt_Key  ,
                       NULL LcNo  ,
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
       FROM RBL_TEMPDB.TempADVACBASICDETAIL AA
              JOIN RBL_STGDB.PC_SOURCESYSTEM_STG PC   ON PC.REFSYSTEMACID = AA.CustomerAcid
              LEFT JOIN RBL_MISDB_PROD.DimCurrency cc   ON cc.CurrencyCode = PC.CurrencyCode );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACPCDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
