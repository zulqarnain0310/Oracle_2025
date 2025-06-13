--------------------------------------------------------
--  DDL for Procedure ADVFACBILLDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" 
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
   MERGE INTO RBL_TEMPDB.TempAdvFacBillDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvFacBillDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvFacBillDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.AdvFacBillDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvFacBillDetail O
          JOIN RBL_TEMPDB.TempAdvFacBillDetail T   ON O.AccountEntityID = T.AccountEntityID

          --AND O.SourceAlt_Key=T.SourceAlt_Key
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.npadt, '1990-01-01') <> NVL(T.npadt, '1990-01-01')
     OR NVL(O.OverDueSinceDt, '1990-01-01') <> NVL(T.OverDueSinceDt, '1990-01-01')

     --OR O.UnAppliedIntt		<> T.UnAppliedIntt
     OR NVL(O.Overdue, 0) <> NVL(T.Overdue, 0)
     OR NVL(O.Balance, 0) <> NVL(T.Balance, 0)
     OR NVL(O.BillDueDt, '1990-01-01') <> NVL(T.BillDueDt, '1990-01-01')
     OR NVL(O.BillPurDt, '1990-01-01') <> NVL(T.BillPurDt, '1990-01-01')
     OR NVL(O.BillAmt, 0) <> NVL(T.BillAmt, 0)
     OR NVL(O.BillDt, '1990-01-01') <> NVL(T.BillDt, '1990-01-01')
     OR NVL(O.BillExtendedDueDt, '1990-01-01') <> NVL(T.BillExtendedDueDt, '1990-01-01')
     OR NVL(O.AdvAmount, 0) <> NVL(T.AdvAmount, 0)
     OR NVL(O.DerecognisedInterest2, 0) <> NVL(T.DerecognisedInterest2, 0)
     OR NVL(O.AdjDt, '1990-01-01') <> NVL(T.AdjDt, '1990-01-01')
     OR NVL(O.CrystalisationDt, '1990-01-01') <> NVL(T.CrystalisationDt, '1990-01-01')
     OR NVL(O.OverDueSinceDt, '1990-01-01') <> NVL(T.OverDueSinceDt, '1990-01-01')
     OR NVL(O.BillRefNo, 0) <> NVL(T.BillRefNo, 0)
     OR NVL(O.BillNo, 0) <> NVL(T.BillNo, 0)
     OR NVL(O.LcAmt, 0) <> NVL(T.LcAmt, 0)
     OR NVL(O.Overdue, 0) <> NVL(T.Overdue, 0)
     OR NVL(O.BillNatureAlt_Key, 0) <> NVL(T.BillNatureAlt_Key, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvFacBillDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvFacBillDetail A
          JOIN RBL_MISDB_PROD.AdvFacBillDetail B   ON B.AccountEntityId = A.AccountEntityId --And A.SourceAlt_Key=B.SourceAlt_Key

    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvFacBillDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvFacBillDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvFacBillDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID --And AA.SourceAlt_Key=BB.SourceAlt_Key

                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvFacBillDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacBillDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvFacBillDetail TEMP
          JOIN ( SELECT "TEMPADVFACBILLDETAIL".AccountEntityId ,
                        "TEMPADVFACBILLDETAIL".BillEntityId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvFacBillDetail 
                  WHERE  "TEMPADVFACBILLDETAIL".EntityKey = 0
                           OR "TEMPADVFACBILLDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId
          AND acct.BillEntityId = temp.BillEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   INSERT INTO RBL_MISDB_PROD.AdvFacBillDetail
     ( EntityKey, AccountEntityId
   --[D2KFacilityID]
   , BillNo, BillDt, BillAmt, BillEntityId, BillRefNo, BillPurDt, AdvAmount, BillDueDt, BillExtendedDueDt, CrystalisationDt, CommercialisationDt, BillNatureAlt_Key, BillAcceptanceDt, UsanceDays, DraweeNo, DraweeBankName, DrawerName, PayeeName, CollectingBankName, CollectingBranchPlace, InterestIncome, Commission, DiscountCharges, DelayedInt, MarginType, MarginAmt, CountryAlt_Key, BillOsReasonAlt_Key, CommodityAlt_Key, LcNo, LcAmt, LcIssuingBankAlt_Key, LcIssuingBank, CurrencyAlt_Key, Balance, BalanceInCurrency, Overdue, DerecognisedInterest1, DerecognisedInterest2, OverDueSinceDt, TotalProv, AdditionalProv, GenericAddlProv, Secured, CoverGovGur, Unsecured, Provsecured, ProvUnsecured, ProvDicgc, npadt, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, ScrCrError, RefSystemAcid, AdjDt, AdjReasonAlt_Key, EntityClosureDate, EntityClosureReasonAlt_Key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, ScrCrErrorSeq, ConsigmentExport, OverdueInterest, InterestOverdueDate, ReviewDuedate )
     ( SELECT EntityKey ,
              AccountEntityId ,
              --[D2KFacilityID]
              BillNo ,
              BillDt ,
              BillAmt ,
              EntityKey ,--BillEntityId

              BillRefNo ,
              BillPurDt ,
              AdvAmount ,
              BillDueDt ,
              BillExtendedDueDt ,
              CASE 
                   WHEN BillNatureAlt_Key <> 9 THEN CrystalisationDt
              ELSE NULL
                 END CrystalisationDt  ,
              CommercialisationDt ,
              BillNatureAlt_Key ,
              BillAcceptanceDt ,
              UsanceDays ,
              DraweeNo ,
              DraweeBankName ,
              DrawerName ,
              PayeeName ,
              CollectingBankName ,
              CollectingBranchPlace ,
              InterestIncome ,
              Commission ,
              DiscountCharges ,
              DelayedInt ,
              MarginType ,
              MarginAmt ,
              CountryAlt_Key ,
              BillOsReasonAlt_Key ,
              CommodityAlt_Key ,
              LcNo ,
              LcAmt ,
              LcIssuingBankAlt_Key ,
              LcIssuingBank ,
              CurrencyAlt_Key ,
              Balance ,
              BalanceInCurrency ,
              Overdue ,
              DerecognisedInterest1 ,
              CASE 
                   WHEN BillNatureAlt_Key <> 9 THEN DerecognisedInterest2
              ELSE NULL
                 END DerecognisedInterest2  ,
              OverDueSinceDt ,
              TotalProv ,
              AdditionalProv ,
              GenericAddlProv ,
              Secured ,
              CoverGovGur ,
              Unsecured ,
              Provsecured ,
              ProvUnsecured ,
              ProvDicgc ,
              npadt ,
              ClaimType ,
              ClaimCoverAmt ,
              ClaimLodgedDt ,
              ClaimLodgedAmt ,
              ClaimRecvDt ,
              ClaimReceivedAmt ,
              ClaimRate ,
              ScrCrError ,
              RefSystemAcid ,
              CASE 
                   WHEN BillNatureAlt_Key <> 9 THEN AdjDt
              ELSE NULL
                 END AdjDt  ,
              AdjReasonAlt_Key ,
              EntityClosureDate ,
              EntityClosureReasonAlt_Key ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              SYSDATE D2Ktimestamp  ,
              MocStatus ,
              MocDate ,
              MocTypeAlt_Key ,
              ScrCrErrorSeq ,
              ConsigmentExport ,
              CASE 
                   WHEN BillNatureAlt_Key = 9 THEN DerecognisedInterest2
              ELSE NULL
                 END DerecognisedIntere_A5  ,
              CASE 
                   WHEN BillNatureAlt_Key = 9 THEN AdjDt
              ELSE NULL
                 END Ad_A6  ,
              CASE 
                   WHEN BillNatureAlt_Key = 9 THEN CrystalisationDt
              ELSE NULL
                 END Crystalisatio_A7  
       FROM RBL_TEMPDB.TempAdvFacBillDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACBILLDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
