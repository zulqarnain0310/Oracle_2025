--------------------------------------------------------
--  DDL for Procedure BILLALLSOURCESYSTEM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_TEMPDB"."BILLALLSOURCESYSTEM" 
AS

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_STGDB.BILL_SOURCESYSTEM_STG ';
   INSERT INTO RBL_STGDB.BILL_SOURCESYSTEM_STG
     ( DateofData, RefSystemAcid, BillDt, BillAmt, BillRefNo, SubBillReNo, BillPurDt, AdvAmount, BillDueDt, BillExtendedDueDt, CrystalisationDt, CommercialisationDt, CurrencyCode, BalanceInINR, BalanceInCurrency, UnAppliedIntt, AdjDt, AdjReasonCode, BillUnderLC_YN, BillProductCode, LcNo, LcAmt, LcIssuingBankCode, LcIssuingBank, BillNatureCode, RefSystemAcid_UCIC, RefSystemAcid_CIF_ID, BillNo, Npadt, DerecognisedInterest, CurrencyAlt_Key, AdjReasonAlt_Key, LcIssuingBankAlt_Key, BillNatureAlt_Key )
     ( SELECT DateofData ,
              AccountID RefSystemAcid  ,
              BillDt ,
              BillAmt ,
              BillRefNo ,
              SubBillReNo ,
              BillPurDt ,
              AdvAmount ,
              BillDueDt ,
              BillExtendedDueDt ,
              CrystalisationDt ,
              CommercialisationDt ,
              CurrencyCode ,
              BalanceInINR ,
              BalanceInCurrency ,
              UnAppliedIntt ,
              AdjDt ,
              AdjReasonCode ,
              BillUnderLC_YN ,
              BillProductCode ,
              LcNo ,
              LcAmt ,
              LcIssuingBankCode ,
              LcIssuingBank ,
              BillNatureCode ,
              RefSystemAcid_UCIC ,
              RefSystemAcid_CIF_ID ,
              BillNo ,
              Npadt ,
              DerecognisedInterest ,
              CurrencyAlt_Key ,
              AdjReasonAlt_Key ,
              LcIssuingBankAlt_Key ,
              'Finacle' 
       FROM RBL_STGDB.BILL_SOURCESYSTEM_STG_FINACLE 
       UNION 
       SELECT DateofData ,
              AccountID RefSystemAcid  ,
              BillDt ,
              BillAmt ,
              BillRefNo ,
              SubBillReNo ,
              BillPurDt ,
              AdvAmount ,
              BillDueDt ,
              BillExtendedDueDt ,
              CrystalisationDt ,
              CommercialisationDt ,
              CurrencyCode ,
              BalanceInINR ,
              BalanceInCurrency ,
              UnAppliedIntt ,
              AdjDt ,
              AdjReasonCode ,
              BillUnderLC_YN ,
              BillProductCode ,
              LcNo ,
              LcAmt ,
              LcIssuingBankCode ,
              LcIssuingBank ,
              BillNatureCode ,
              RefSystemAcid_UCIC ,
              RefSystemAcid_CIF_ID ,
              BillNo ,
              Npadt ,
              DerecognisedInterest ,
              CurrencyAlt_Key ,
              AdjReasonAlt_Key ,
              LcIssuingBankAlt_Key ,
              'SCF' 
       FROM RBL_STGDB.BILL_SOURCESYSTEM_STG_SCF  );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."BILLALLSOURCESYSTEM" TO "ADF_CDR_RBL_STGDB";
