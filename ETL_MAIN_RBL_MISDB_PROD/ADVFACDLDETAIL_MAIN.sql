--------------------------------------------------------
--  DDL for Procedure ADVFACDLDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   /*  New Customers EntityKey ID Update  */
   v_EntityKey NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvFacDLDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvFacDLDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.ADVFACDLDETAIL B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.ADVFACDLDETAIL O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.ADVFACDLDETAIL O
          JOIN RBL_TEMPDB.TempAdvFacDLDetail T   ON O.AccountEntityID = T.AccountEntityID

          --AND O.SourceAlt_Key=T.SourceAlt_Key
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.Principal, 0) <> NVL(T.Principal, 0)
     OR NVL(O.RepayModeAlt_Key, 0) <> NVL(T.RepayModeAlt_Key, 0)
     OR NVL(O.NoOfInstall, 0) <> NVL(T.NoOfInstall, 0)
     OR NVL(O.InstallAmt, 0) <> NVL(T.InstallAmt, 0)
     OR NVL(O.FstInstallDt, '1900-01-01') <> NVL(T.FstInstallDt, '1900-01-01')
     OR NVL(O.LastInstallDt, '1900-01-01') <> NVL(T.LastInstallDt, '1900-01-01')
     OR NVL(O.Tenure_Months, 0) <> NVL(T.Tenure_Months, 0)
     OR NVL(O.MarginAmt, 0) <> NVL(T.MarginAmt, 0)
     OR NVL(O.CommodityAlt_Key, 0) <> NVL(T.CommodityAlt_Key, 0)
     OR NVL(O.RephaseAlt_Key, 0) <> NVL(T.RephaseAlt_Key, 0)
     OR NVL(O.RephaseDt, '1900-01-01') <> NVL(T.RephaseDt, '1900-01-01')
     OR NVL(O.IntServiced, 0) <> NVL(T.IntServiced, 0)
     OR NVL(O.SuspendedInterest, 0) <> NVL(T.SuspendedInterest, 0)
     OR NVL(O.DerecognisedInterest1, 0) <> NVL(T.DerecognisedInterest1, 0)
     OR NVL(O.DerecognisedInterest2, 0) <> NVL(T.DerecognisedInterest2, 0)
     OR NVL(O.AdjReasonAlt_Key, 0) <> NVL(T.AdjReasonAlt_Key, 0)
     OR NVL(O.LcNo, 'AA') <> NVL(T.LcNo, 'AA')
     OR NVL(O.LcAmt, 0) <> NVL(T.LcAmt, 0)
     OR NVL(O.LcIssuingBankAlt_Key, 0) <> NVL(T.LcIssuingBankAlt_Key, 0)
     OR NVL(O.ResetFrequency, 0) <> NVL(T.ResetFrequency, 0)
     OR NVL(O.ResetDt, '1900-01-01') <> NVL(T.ResetDt, '1900-01-01')
     OR NVL(O.Moratorium, 0) <> NVL(T.Moratorium, 0)
     OR NVL(O.FirstInstallDtInt, '1900-01-01') <> NVL(T.FirstInstallDtInt, '1900-01-01')
     OR NVL(O.ContExcsSinceDt, '1900-01-01') <> NVL(T.ContExcsSinceDt, '1900-01-01')
     OR NVL(O.loanPeriod, 0) <> NVL(T.loanPeriod, 0)
     OR NVL(O.ClaimType, 'AA') <> NVL(T.ClaimType, 'AA')
     OR NVL(O.ClaimCoverAmt, 0) <> NVL(T.ClaimCoverAmt, 0)
     OR NVL(O.ClaimLodgedDt, '1900-01-01') <> NVL(T.ClaimLodgedDt, '1900-01-01')
     OR NVL(O.ClaimLodgedAmt, 0) <> NVL(T.ClaimLodgedAmt, 0)
     OR NVL(O.ClaimRecvDt, '1900-01-01') <> NVL(T.ClaimRecvDt, '1900-01-01')
     OR NVL(O.ClaimReceivedAmt, 0) <> NVL(T.ClaimReceivedAmt, 0)
     OR NVL(O.ClaimRate, 0) <> NVL(T.ClaimRate, 0)
     OR NVL(O.InttRepaymentDt, '1900-01-01') <> NVL(T.InttRepaymentDt, '1900-01-01')
     OR NVL(O.ScheDuleNo, 0) <> NVL(T.ScheDuleNo, 0)
     OR NVL(O.NxtInstDay, 0) <> NVL(T.NxtInstDay, 0)
     OR NVL(O.PrplOvduAftrMth, 0) <> NVL(T.PrplOvduAftrMth, 0)
     OR NVL(O.PrplOvduAftrDay, 0) <> NVL(T.PrplOvduAftrDay, 0)
     OR NVL(O.InttOvduAftrDay, 0) <> NVL(T.InttOvduAftrDay, 0)
     OR NVL(O.InttOvduAftrMth, 0) <> NVL(T.InttOvduAftrMth, 0)
     OR NVL(O.PrinOvduEndMth, 'A') <> NVL(T.PrinOvduEndMth, 'A') )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvFacDLDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvFacDLDetail A
          JOIN RBL_MISDB_PROD.ADVFACDLDETAIL B   ON B.AccountEntityId = A.AccountEntityId --And A.SourceAlt_Key=B.SourceAlt_Key

    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.ADVFACDLDETAIL AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.ADVFACDLDETAIL AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvFacDLDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID --And AA.SourceAlt_Key=BB.SourceAlt_Key

                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.ADVFACDLDETAIL ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacDLDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvFacDLDetail TEMP
          JOIN ( SELECT "TEMPADVFACDLDETAIL".AccountEntityId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvFacDLDetail 
                  WHERE  "TEMPADVFACDLDETAIL".EntityKey = 0
                           OR "TEMPADVFACDLDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   ------------------------------
   INSERT INTO RBL_MISDB_PROD.ADVFACDLDETAIL
     ( ENTITYKEY, AccountEntityId, Principal, RepayModeAlt_Key, NoOfInstall, InstallAmt, FstInstallDt, LastInstallDt, Tenure_Months, MarginAmt, CommodityAlt_Key, RephaseAlt_Key, RephaseDt, IntServiced, SuspendedInterest, DerecognisedInterest1, DerecognisedInterest2, AdjReasonAlt_Key, LcNo, LcAmt, LcIssuingBankAlt_Key, ResetFrequency, ResetDt, Moratorium, FirstInstallDtInt, ContExcsSinceDt, loanPeriod, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, InstRepaymentDt, ScrCrError, InttRepaymentDt, ScheDuleNo, MocStatus, MocDate, MocTypeAlt_Key, UnAppliedIntt, NxtInstDay, PrplOvduAftrMth, PrplOvduAftrDay, InttOvduAftrDay, InttOvduAftrMth, PrinOvduEndMth, InttOvduEndMth, ScrCrErrorSeq, CoverExpiryDt )
     ( SELECT ENTITYKEY ,
              AccountEntityId ,
              Principal ,
              RepayModeAlt_Key ,
              NoOfInstall ,
              InstallAmt ,
              FstInstallDt ,
              LastInstallDt ,
              Tenure_Months ,
              MarginAmt ,
              CommodityAlt_Key ,
              RephaseAlt_Key ,
              RephaseDt ,
              IntServiced ,
              SuspendedInterest ,
              DerecognisedInterest1 ,
              DerecognisedInterest2 ,
              AdjReasonAlt_Key ,
              LcNo ,
              LcAmt ,
              LcIssuingBankAlt_Key ,
              ResetFrequency ,
              ResetDt ,
              Moratorium ,
              FirstInstallDtInt ,
              ContExcsSinceDt ,
              loanPeriod ,
              ClaimType ,
              ClaimCoverAmt ,
              ClaimLodgedDt ,
              ClaimLodgedAmt ,
              ClaimRecvDt ,
              ClaimReceivedAmt ,
              ClaimRate ,
              RefSystemAcid ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              D2Ktimestamp ,
              InstRepaymentDt ,
              ScrCrError ,
              InttRepaymentDt ,
              ScheDuleNo ,
              MocStatus ,
              MocDate ,
              MocTypeAlt_Key ,
              UnAppliedIntt ,
              NxtInstDay ,
              PrplOvduAftrMth ,
              PrplOvduAftrDay ,
              InttOvduAftrDay ,
              InttOvduAftrMth ,
              PrinOvduEndMth ,
              InttOvduEndMth ,
              ScrCrErrorSeq ,
              CoverExpiryDt 
       FROM RBL_TEMPDB.TempAdvFacDLDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACDLDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
