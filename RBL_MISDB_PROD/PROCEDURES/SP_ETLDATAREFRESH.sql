--------------------------------------------------------
--  DDL for Procedure SP_ETLDATAREFRESH
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_Flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Ext_Flg = 'Y' );

BEGIN

   DELETE CustomerBasicDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE CustomerBasicDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvAcBasicDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvAcBasicDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AcDailyTxnDetail

    WHERE  TxnDate = v_Date;
   DELETE AdvAcBalanceDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvAcBalanceDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvAcFinancialDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvAcFinancialDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal_RBL

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal_RBL
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE PRO_RBL_MISDB_PROD.ContExcsSinceDtDebitAccountCal

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE PRO_RBL_MISDB_PROD.ContExcsSinceDtDebitAccountCal
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvAcOtherDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvAcOtherDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvAcOtherFinancialDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvAcOtherFinancialDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvAcRelations

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvAcRelations
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvFacCreditCardDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvFacCreditCardDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvCreditCardBalanceDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvCreditCardBalanceDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   --delete from AdvCustCommunicationDetail where EffectiveFromTimeKey = @Timekey
   --update  AdvCustCommunicationDetail  set EffectiveToTimeKey = 49999 where EffectiveToTimeKey = @Timekey-1
   DELETE AdvCustNPADetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvCustNPADetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvCustOtherDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvCustOtherDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvCustRelationship

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvCustRelationship
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvFacBillDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvFacBillDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE ADVFACCCDETAIL

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE ADVFACCCDETAIL
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE ADVFACDLDETAIL

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE ADVFACDLDETAIL
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvFacPCDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvFacPCDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvSecurityDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvSecurityDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE AdvSecurityValueDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE AdvSecurityValueDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE InvestmentBasicDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE InvestmentBasicDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE InvestmentIssuerDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE InvestmentIssuerDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE InvestmentFinancialDetail

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE InvestmentFinancialDetail
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;
   DELETE MIFINGOLDMASTER

    WHERE  DateofData = v_Date;
   DELETE ReversefeedCalypso

    WHERE  EffectiveFromTimeKey = v_Timekey;
   UPDATE ReversefeedCalypso
      SET EffectiveToTimeKey = 49999
    WHERE  EffectiveToTimeKey = v_Timekey - 1;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_ETLDATAREFRESH" TO "ADF_CDR_RBL_STGDB";
