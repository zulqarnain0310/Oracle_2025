--------------------------------------------------------
--  DDL for Procedure INVESTMENTDERIVATIVEPROVISIONCAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" 
----/*=========================================
 ---- AUTHER : TRILOKI KHANNA
 ---- CREATE DATE : 27-11-2019
 ---- MODIFY DATE : 27-11-2019
 ---- DESCRIPTION : UPDATE InvestmentDataProcessing
 ---- --EXEC [PRO].[InvestmentDataProcessing] @TIMEKEY=26053
 ----=============================================*/

(
  v_TIMEKEY IN NUMBER
)
AS
/*=========================================
-- AUTHOR : TRILOKI KHANNA
-- CREATE DATE : 09-04-2021
-- MODIFY DATE : 09-04-2021
-- DESCRIPTION : Test Case Cover in This SP

--=============================================*/

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
    V_Table_exists NUMBER(10);
   BEGIN

      BEGIN
         --DECLARE @TIMEKEY INT=@TimeKey
         ----/*----------------PROVISION ALT KEY ALL  ACCOUNTS--------------------------------*/
         /*  INVESTMENT  */
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 0
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
          WHERE ( A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET PROVISIONALT_KEY = 0;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, D.ProvisionAlt_Key
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY )
                JOIN RBL_MISDB_PROD.DimProvision_Seg D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY

                --AND A.DPD BETWEEN d.LowerDPD AND d.UpperDPD
                AND c.AssetClassShortName = D.PROVISIONSHORTNAMEENUM 
          WHERE C.ASSETCLASSGROUP = 'NPA'
           AND ( A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY )
           AND D.SEGMENT = 'IRAC') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key
                                      ----SELECT *
                                       = src.ProvisionAlt_Key;
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN NVL(B.ASSETCLASSSHORTNAMEENUM, 'STD') = 'LOS' THEN BookValueINR
         ELSE (NVL(A.BookValueINR, 0) * NVL(C.PROVISIONUNSECURED, 0) / 100)
            END) AS TotalProvison
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass B   ON B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.FinalAssetClassAlt_Key, 1) = B.ASSETCLASSALT_KEY
                JOIN RBL_MISDB_PROD.DimProvision_Seg C   ON C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.PROVISIONALT_KEY, 1) = C.PROVISIONALT_KEY 
          WHERE FinalAssetClassAlt_Key > 1
           AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvison = src.TotalProvison;
         /* STD PROVISION ALTKEY */
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, D.ProvisionAlt_Key
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY )
                JOIN RBL_MISDB_PROD.DimProvision_SegSTD D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY
                AND D.ProvisionName = 'Other Portfolio' 
          WHERE C.ASSETCLASSGROUP = 'STD'
           AND ( A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key
                                      ----SELECT *
                                       = src.ProvisionAlt_Key;
         /* STD PROVISION maount */
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN NVL(B.ASSETCLASSSHORTNAMEENUM, 'STD') = 'LOS' THEN BookValueINR
         ELSE (NVL(A.BookValueINR, 0) * NVL(C.PROVISIONUNSECURED, 0) / 100)
            END) AS TotalProvison
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass B   ON B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.FinalAssetClassAlt_Key, 1) = B.ASSETCLASSALT_KEY
                JOIN RBL_MISDB_PROD.DimProvision_SegSTD C   ON C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.PROVISIONALT_KEY, 1) = C.PROVISIONALT_KEY 
          WHERE FinalAssetClassAlt_Key = 1
           AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvison = src.TotalProvison;
         ----/*----------------PROVISION ALT KEY ALL  ACCOUNTS--------------------------------*/
         /* DERIVATIVE */
         MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, 0
         FROM CURDAT_RBL_MISDB_PROD.DerivativeDetail A 
          WHERE ( A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PROVISIONALT_KEY = 0;
         /* NPA PROVISION ALTKEY */
         MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A
         USING (SELECT A.ROWID row_id, D.ProvisionAlt_Key
         FROM CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY )
                JOIN RBL_MISDB_PROD.DimProvision_Seg D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY

                --AND A.DPD BETWEEN d.LowerDPD AND d.UpperDPDS
                AND c.AssetClassShortName = D.PROVISIONSHORTNAMEENUM 
          WHERE C.ASSETCLASSGROUP = 'NPA'
           AND ( A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY )
           AND D.SEGMENT = 'IRAC') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key
                                      ----SELECT *
                                       = src.ProvisionAlt_Key;
         /* NPA PROVISION maount */
         MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN NVL(B.ASSETCLASSSHORTNAMEENUM, 'STD') = 'LOS' THEN POS
         ELSE (NVL(A.POS, 0) * NVL(C.PROVISIONUNSECURED, 0) / 100)
            END) AS TotalProvison
         FROM CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass B   ON B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.FinalAssetClassAlt_Key, 1) = B.ASSETCLASSALT_KEY
                JOIN RBL_MISDB_PROD.DimProvision_Seg C   ON C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.PROVISIONALT_KEY, 1) = C.PROVISIONALT_KEY 
          WHERE FinalAssetClassAlt_Key > 1
           AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvison = src.TotalProvison;
         /* STD PROVISION ALTKEY */
         MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A
         USING (SELECT A.ROWID row_id, D.ProvisionAlt_Key
         FROM CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY )
                JOIN RBL_MISDB_PROD.DimProvision_SegSTD D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY
                AND D.ProvisionName = 'Other Portfolio' 
          WHERE C.ASSETCLASSGROUP = 'STD'
           AND ( A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key
                                      ----SELECT *
                                       = src.ProvisionAlt_Key;
         /* STD PROVISION maount */
         MERGE INTO CURDAT_RBL_MISDB_PROD.DerivativeDetail A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN NVL(B.ASSETCLASSSHORTNAMEENUM, 'STD') = 'LOS' THEN POS
         ELSE (NVL(A.POS, 0) * NVL(C.PROVISIONUNSECURED, 0) / 100)
            END) AS TotalProvison
         FROM CURDAT_RBL_MISDB_PROD.DerivativeDetail A
                JOIN RBL_MISDB_PROD.DimAssetClass B   ON B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.FinalAssetClassAlt_Key, 1) = B.ASSETCLASSALT_KEY
                JOIN RBL_MISDB_PROD.DimProvision_SegSTD C   ON C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                AND NVL(A.PROVISIONALT_KEY, 1) = C.PROVISIONALT_KEY 
          WHERE FinalAssetClassAlt_Key = 1
           AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvison = src.TotalProvison;
         -----------------------MOC-------------------------
         UPDATE CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail
            SET TotalProvison = TotalProvison + NVL(AddlProvision, 0)
          WHERE  EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND NVL(AddlProvision, 0) > 0;
         UPDATE CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail
            SET TotalProvison = TotalProvison + (BookValueINR * (NVL(AddlProvisionPer, 0) / 100))
          WHERE  EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND NVL(AddlProvisionPer, 0) > 0;
         UPDATE CURDAT_RBL_MISDB_PROD.DerivativeDetail
            SET TotalProvison = TotalProvison + NVL(AddlProvision, 0)
          WHERE  EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND NVL(AddlProvision, 0) > 0;
         UPDATE CURDAT_RBL_MISDB_PROD.DerivativeDetail
            SET TotalProvison = TotalProvison + (POS * (NVL(AddlProvisionPer, 0) / 100))
          WHERE  EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND NVL(AddlProvisionPer, 0) > 0;
         --------------------------------------------------------------------------
         UPDATE CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail
            SET TotalProvison = 0,
                ProvisionAlt_Key = NULL
          WHERE  EffectiveFromTimeKey <= v_TIMEKEY
           AND EffectiveToTimeKey >= v_TIMEKEY
           AND FinalAssetClassAlt_Key = 1;
         /* WROTE OFF CHAGNES - UPDATE TOTAL PROVISION 0 20092023 */
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, 0
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail B   ON A.RefIssuerID = B.IssuerID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType C   ON C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                AND C.ACID = A.RefInvID
                AND C.StatusType IN ( 'TWO','WO','WriteOff' )

                AND C.SourceAlt_key = 7 ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.TotalProvison = 0;
         --------------Added for DashBoard 04-03-2021
         UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
            SET CompletedCount = CompletedCount + 1
          WHERE  BandName = 'ASSET CLASSIFICATION';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   V_SQLERRM:=SQLERRM;
      UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'InvestmentDataProcessing';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INVESTMENTDERIVATIVEPROVISIONCAL" TO "ADF_CDR_RBL_STGDB";
