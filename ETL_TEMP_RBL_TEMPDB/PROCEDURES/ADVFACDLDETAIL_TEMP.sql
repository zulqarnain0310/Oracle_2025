--------------------------------------------------------
--  DDL for Procedure ADVFACDLDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
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
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TEmpAdvFacDLDetail ';
   INSERT INTO RBL_TEMPDB.TEmpAdvFacDLDetail
     ( AccountEntityId, Principal, RepayModeAlt_Key, NoOfInstall, InstallAmt, FstInstallDt, LastInstallDt, Tenure_Months, MarginAmt, CommodityAlt_Key, RephaseAlt_Key, RephaseDt, IntServiced, SuspendedInterest, DerecognisedInterest1, DerecognisedInterest2, AdjReasonAlt_Key, LcNo, LcAmt, LcIssuingBankAlt_Key, ResetFrequency, ResetDt, Moratorium, FirstInstallDtInt, ContExcsSinceDt, loanPeriod, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, InstRepaymentDt, ScrCrError, InttRepaymentDt, ScheDuleNo, MocStatus, MocDate, MocTypeAlt_Key, UnAppliedIntt, NxtInstDay, PrplOvduAftrMth, PrplOvduAftrDay, InttOvduAftrDay, InttOvduAftrMth, PrinOvduEndMth, InttOvduEndMth, ScrCrErrorSeq, CoverExpiryDt, d2ktimestamp )
     ( 
       -------------------FINACLE ---
       SELECT ACBD.AccountEntityId AccountEntityId  ,
              A.POSBalance Principal ,---SANCTIONAMT lndality      SanctionedAmount  l_loan

              NULL RepayModeAlt_Key ,--DIST1FRE  lndality   RepaymentFrequencyID l_loan

              NULL NoOfInstall ,---TRM lndality    RepaymentTerm l_loan

              NULL InstallAmt ,---PMTPI lndality   InstallmentAmount l_loan

              NULL FstInstallDt ,---DFP  lndality    InstallmentStartDate l_loan

              NULL LastInstallDt ,--- MDT lndality   MaturityDate  l_loan

              NULL Tenure_Months ,--- TRM lndality   RepaymentTerm l_loan

              NULL MarginAmt  ,
              NULL CommodityAlt_Key  ,
              NULL RephaseAlt_Key  ,
              NULL RephaseDt  ,
              NULL IntServiced  ,
              NULL SuspendedInterest  ,
              NULL DerecognisedInterest1  ,
              NULL DerecognisedInterest2  ,
              NULL AdjReasonAlt_Key  ,
              NULL LcNo  ,
              NULL LcAmt  ,
              NULL LcIssuingBankAlt_Key  ,
              NULL ResetFrequency  ,
              NULL ResetDt  ,
              NULL Moratorium  ,
              NULL FirstInstallDtInt  ,
              NULL ContExcsSinceDt  ,
              NULL loanPeriod  ,
              NULL ClaimType  ,
              NULL ClaimCoverAmt  ,
              NULL ClaimLodgedDt  ,
              NULL ClaimLodgedAmt  ,
              NULL ClaimRecvDt  ,
              NULL ClaimReceivedAmt  ,
              NULL ClaimRate  ,
              ACBD.SystemAcid RefSystemAcid  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL InstRepaymentDt  ,
              NULL ScrCrError  ,
              NULL InttRepaymentDt  ,
              NULL ScheDuleNo  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL MocTypeAlt_Key  ,
              NULL UnAppliedIntt  ,
              NULL NxtInstDay  ,
              NULL PrplOvduAftrMth  ,
              NULL PrplOvduAftrDay  ,
              NULL InttOvduAftrDay  ,
              NULL InttOvduAftrMth  ,
              NULL PrinOvduEndMth  ,
              NULL InttOvduEndMth  ,
              NULL ScrCrErrorSeq  ,
              NULL CoverExpiryDt  ,
              SYSDATE 
       FROM RBL_TEMPDB.TempAdvAcBasicDetail ACBD
              JOIN RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM A   ON A.CustomerAcID = ACBD.CustomerACID
        WHERE  ACBD.FacilityType = 'TL' );


EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACDLDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
