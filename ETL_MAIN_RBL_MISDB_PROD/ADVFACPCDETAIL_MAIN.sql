--------------------------------------------------------
--  DDL for Procedure ADVFACPCDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" 
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
   MERGE INTO RBL_TEMPDB.TempAdvFacPCDetail A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvFacPCDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvFacPCDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.AdvFacPCDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvFacPCDetail O
          JOIN RBL_TEMPDB.TempAdvFacPCDetail T   ON O.AccountEntityID = T.AccountEntityID

          --AND O.SourceAlt_Key=T.SourceAlt_Key
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.PCAdvDt, '1990-01-01') <> NVL(T.PCAdvDt, '1990-01-01')
     OR NVL(O.PCAmt, 0) <> NVL(T.PCAmt, 0)
     OR NVL(O.PCDueDt, '1990-01-01') <> NVL(T.PCDueDt, '1990-01-01')
     OR NVL(O.PCDurationDays, 0) <> NVL(T.PCDurationDays, 0)
     OR NVL(O.PCExtendedDueDt, '1990-01-01') <> NVL(T.PCExtendedDueDt, '1990-01-01')
     OR NVL(O.ExtensionReason, 0) <> NVL(T.ExtensionReason, 0)
     OR NVL(O.CurrencyAlt_Key, 0) <> NVL(T.CurrencyAlt_Key, 0)
     OR NVL(O.LcNo, 0) <> NVL(T.LcNo, 0)
     OR NVL(O.LcAmt, 0) <> NVL(T.LcAmt, 0)
     OR NVL(O.LcIssueDt, '1990-01-01') <> NVL(T.LcIssueDt, '1990-01-01')
     OR NVL(O.LcIssuingBank_FirmOrder, 0) <> NVL(T.LcIssuingBank_FirmOrder, 0)
     OR NVL(O.Balance, 0) <> NVL(T.Balance, 0)
     OR NVL(O.BalanceInCurrency, 0) <> NVL(T.BalanceInCurrency, 0)
     OR NVL(O.BalanceInUSD, 0) <> NVL(T.BalanceInUSD, 0)
     OR NVL(O.Overdue, 0) <> NVL(T.Overdue, 0)
     OR NVL(O.CommodityAlt_Key, 0) <> NVL(T.CommodityAlt_Key, 0)
     OR NVL(O.CommodityValue, 0) <> NVL(T.CommodityValue, 0)
     OR NVL(O.CommodityMarketValue, 0) <> NVL(T.CommodityMarketValue, 0)
     OR NVL(O.ShipmentDt, '1990-01-01') <> NVL(T.ShipmentDt, '1990-01-01')
     OR NVL(O.CommercialisationDt, '1990-01-01') <> NVL(T.CommercialisationDt, '1990-01-01')
     OR NVL(O.EcgcPolicyNo, 0) <> NVL(T.EcgcPolicyNo, 0)
     OR NVL(O.CAD, 0) <> NVL(T.CAD, 0)
     OR NVL(O.CADU, 0) <> NVL(T.CADU, 0)
     OR NVL(O.OverDueSinceDt, '1990-01-01') <> NVL(T.OverDueSinceDt, '1990-01-01')
     OR NVL(O.TotalProv, 0) <> NVL(T.TotalProv, 0)
     OR NVL(O.Secured, 0) <> NVL(T.Secured, 0)
     OR NVL(O.Unsecured, 0) <> NVL(T.Unsecured, 0)
     OR NVL(O.Provsecured, 0) <> NVL(T.Provsecured, 0)
     OR NVL(O.ProvUnsecured, 0) <> NVL(T.ProvUnsecured, 0)
     OR NVL(O.ProvDicgc, 0) <> NVL(T.ProvDicgc, 0)
     OR NVL(O.npadt, '1990-01-01') <> NVL(T.npadt, '1990-01-01')
     OR NVL(O.CoverGovGur, 0) <> NVL(T.CoverGovGur, 0)
     OR NVL(O.DerecognisedInterest1, 0) <> NVL(T.DerecognisedInterest1, 0)
     OR NVL(O.DerecognisedInterest2, 0) <> NVL(T.DerecognisedInterest2, 0)
     OR NVL(O.ClaimType, 'AA') <> NVL(T.ClaimType, 'AA')
     OR NVL(O.ClaimCoverAmt, 0) <> NVL(T.ClaimCoverAmt, 0)
     OR NVL(O.ClaimLodgedDt, '1990-01-01') <> NVL(T.ClaimLodgedDt, '1990-01-01')
     OR NVL(O.ClaimLodgedAmt, 0) <> NVL(T.ClaimLodgedAmt, 0)
     OR NVL(O.ClaimRecvDt, '1990-01-01') <> NVL(T.ClaimRecvDt, '1990-01-01')
     OR NVL(O.ClaimReceivedAmt, 0) <> NVL(T.ClaimReceivedAmt, 0)
     OR NVL(O.ClaimRate, 0) <> NVL(T.ClaimRate, 0)
     OR NVL(O.AdjDt, '1990-01-01') <> NVL(T.AdjDt, '1990-01-01')
     OR NVL(O.EntityClosureDate, '1990-01-01') <> NVL(T.EntityClosureDate, '1990-01-01')
     OR NVL(O.EntityClosureReasonAlt_Key, 0) <> NVL(T.EntityClosureReasonAlt_Key, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvFacPCDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvFacPCDetail A
          JOIN RBL_MISDB_PROD.AdvFacPCDetail B   ON B.AccountEntityId = A.AccountEntityId --And A.SourceAlt_Key=B.SourceAlt_Key

    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvFacPCDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvFacPCDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvFacPCDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID --And AA.SourceAlt_Key=BB.SourceAlt_Key

                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.AdvFacPCDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvFacPCDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempAdvFacPCDetail TEMP
          JOIN ( SELECT "TEMPADVFACPCDETAIL".AccountEntityId ,
                        "TEMPADVFACPCDETAIL".PCRefNo ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempAdvFacPCDetail 
                  WHERE  "TEMPADVFACPCDETAIL".EntityKey = 0
                           OR "TEMPADVFACPCDETAIL".EntityKey IS NULL ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId
          AND acct.PCRefNo = temp.PCRefNo 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   INSERT INTO RBL_MISDB_PROD.AdvFacPCDetail
     ( EntityKey, AccountEntityId, PCRefNo, PCAdvDt, PCAmt, PCDueDt, PCDurationDays, PCExtendedDueDt, ExtensionReason, CurrencyAlt_Key, LcNo, LcAmt, LcIssueDt, LcIssuingBank_FirmOrder, Balance, BalanceInCurrency, BalanceInUSD, Overdue, CommodityAlt_Key, CommodityValue, CommodityMarketValue, ShipmentDt, CommercialisationDt, EcgcPolicyNo, CAD, CADU, OverDueSinceDt, TotalProv, Secured, Unsecured, Provsecured, ProvUnsecured, ProvDicgc, npadt, CoverGovGur, DerecognisedInterest1, DerecognisedInterest2, ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, AdjDt, EntityClosureDate, EntityClosureReasonAlt_Key, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, UnAppliedIntt, MocTypeAlt_Key, MocStatus, MocDate, RBI_ExtnPermRefNo, LC_OrderAlt_Key, OrderLC_CurrencyAlt_Key, CountryAlt_Key, LcAmtInCurrenc )
     ( SELECT EntityKey ,
              AccountEntityId ,
              PCRefNo ,
              PCAdvDt ,
              PCAmt ,
              PCDueDt ,
              PCDurationDays ,
              PCExtendedDueDt ,
              ExtensionReason ,
              CurrencyAlt_Key ,
              LcNo ,
              LcAmt ,
              LcIssueDt ,
              LcIssuingBank_FirmOrder ,
              Balance ,
              BalanceInCurrency ,
              BalanceInUSD ,
              Overdue ,
              CommodityAlt_Key ,
              CommodityValue ,
              CommodityMarketValue ,
              ShipmentDt ,
              CommercialisationDt ,
              EcgcPolicyNo ,
              CAD ,
              CADU ,
              OverDueSinceDt ,
              TotalProv ,
              Secured ,
              Unsecured ,
              Provsecured ,
              ProvUnsecured ,
              ProvDicgc ,
              npadt ,
              CoverGovGur ,
              DerecognisedInterest1 ,
              DerecognisedInterest2 ,
              ClaimType ,
              ClaimCoverAmt ,
              ClaimLodgedDt ,
              ClaimLodgedAmt ,
              ClaimRecvDt ,
              ClaimReceivedAmt ,
              ClaimRate ,
              AdjDt ,
              EntityClosureDate ,
              EntityClosureReasonAlt_Key ,
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
              SYSDATE D2Ktimestamp  ,
              UnAppliedIntt ,
              MocTypeAlt_Key ,
              MocStatus ,
              MocDate ,
              RBI_ExtnPermRefNo ,
              LC_OrderAlt_Key ,
              OrderLC_CurrencyAlt_Key ,
              CountryAlt_Key ,
              LcAmtInCurrenc 
       FROM RBL_TEMPDB.TempAdvFacPCDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVFACPCDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
