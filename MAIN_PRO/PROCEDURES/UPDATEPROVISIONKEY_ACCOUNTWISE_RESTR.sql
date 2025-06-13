--------------------------------------------------------
--  DDL for Procedure UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" /*=========================================
AUTHER : TRILOKI KHANNA
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : UPDATE PROVISION ALT KEY AT ARCCOUNT LEVEL
EXEC [PRO].[UpdateProvisionKey_AccountWise]  @TimeKey=25140
==============================================*/
(
  v_TimeKey IN NUMBER
)
AS

BEGIN

   BEGIN
      DECLARE
         v_EXTDATE VARCHAR2(200);
         v_SubStandard NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_SubStandardInfrastructure NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard Infrastructure'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_SubStandardAbinitioUnsecured NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard Ab initio Unsecured'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_DoubtfulI NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-I'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_DoubtfulII NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-II'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_DoubtfulIII NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-III'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_Loss NUMBER(10,0) := ( SELECT PROVISIONALT_KEY 
           FROM DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Loss'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         /*UPDATE PROISION ALT KEY FOR NPA (SUB) ACCOUNT AS PER SEGMENT UNSCURED - RETAIL, MSME AND MICRO  ON THE BASES OF NPA QTR NO */
         /* prepare NPA Qtr No */
         v_CurQtrDate VARCHAR2(200);
         v_LastQtrDate VARCHAR2(200);
         v_LastToLastQtrDate VARCHAR2(200);
         v_LastToLastToLastQtrDate VARCHAR2(200);

      BEGIN
         SELECT DATE_ 

           INTO v_EXTDATE
           FROM SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TimeKey;
         --DECLARE @VisionPlus_SUB_0 INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_SUB_0'	 AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_SUB_1 INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_SUB_1'	 AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_SUB_2 INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_SUB_2'    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_DB1 INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_DB1'		  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_DB2 INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_DB2'		  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_DB3 INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_DB3'		  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_LOS INT =	(SELECT PROVISIONALT_KEY FROM DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_LOS'			AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         UPDATE PRO_RBL_MISDB_PROD.ACCOUNTCAL
            SET PROVISIONALT_KEY = 0;
         /*----------------PROVISION ALT KEY ALL NPA ACCOUNTS--------------------------------*/
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN C.AssetClassShortName = 'SUB' THEN v_SubStandard
         WHEN C.AssetClassShortName = 'DB1' THEN v_DoubtfulI
         WHEN C.AssetClassShortName = 'DB2' THEN v_DoubtfulII
         WHEN C.AssetClassShortName = 'DB3' THEN v_DoubtfulIII
         WHEN C.AssetClassShortName = 'LOS' THEN v_Loss
         ELSE 0
            END) AS ProvisionAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
              --INNER JOIN DimSourceDB B  ON A.SourceAlt_Key=B.SourceAlt_Key     AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)

                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
              --inner JOIN DimProduct	dp
               --		on 	(dp.EffectiveFromTimeKey<=@TimeKey AND dp.EffectiveToTimeKey>=@TimeKey)
               --		and dp.ProductAlt_Key=a.ProductAlt_Key
               ) 
          WHERE C.ASSETCLASSGROUP = 'NPA'
           AND ( SecApp = 'S'
           OR AssetClassShortName = 'LOS' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key --15.0000/15.0000
                                       --25.0000/25.0000
                                       --40.0000/40.0000
                                       --100.0000/100.0000
                                       --100.0000/100.0000
                                       = src.ProvisionAlt_Key;
         --WHERE  C.ASSETCLASSGROUP='NPA' and (ProductSubGroup ='SECURED' OR AssetClassShortName='LOS')
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, v_SubStandardAbinitioUnsecured
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
              --INNER JOIN DimSourceDB B  ON A.SourceAlt_Key=B.SourceAlt_Key     AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)

                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey ) 
          WHERE C.ASSETCLASSGROUP = 'NPA'
           AND C.AssetClassShortName IN ( 'SUB' )

           AND A.FlgAbinitio = 'Y') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PROVISIONALT_KEY = v_SubStandardAbinitioUnsecured;
         SELECT CurQtrDate ,
                LastQtrDate ,
                LastToLastQtrDate 

           INTO v_CurQtrDate,
                v_LastQtrDate,
                v_LastToLastQtrDate
           FROM SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TimeKey;
         v_LastToLastToLastQtrDate := EOMONTH(utils.dateadd('MM', -3, v_LastToLastQtrDate)) ;
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_AC_NPA_QTR_NO_7  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_AC_NPA_QTR_NO_7;
         UTILS.IDENTITY_RESET('tt_AC_NPA_QTR_NO_7');

         INSERT INTO tt_AC_NPA_QTR_NO_7 ( 
         	SELECT AccountEntityID ,
                 CASE 
                      WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastQtrDate) AND v_CurQtrDate THEN 1
                      WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastQtrDate) AND v_LastQtrDate THEN 2
                      WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastToLastQtrDate) AND v_LastToLastQtrDate THEN 3
                 ELSE 4
                    END NPA_QTR_NO  ,
                 seg.AcBuRevisedSegmentCode 
         	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                   LEFT JOIN DimAcBuSegment SEG   ON SEG.AcBuSegmentCode = A.ActSegmentCode
                   AND ( SEG.EffectiveFromTimeKey <= v_TimeKey
                   AND SEG.EffectiveToTimeKey >= v_TimeKey )
         	 WHERE  FinalAssetClassAlt_Key > 1 );
         /* UPDATE DEFAULYT QTR NO. 1 FOR MARK PROVISION ALTKEY OF UNSECURED 25% FOR BEOLOW SEGMENT AND UNSECURED PRODUCTS */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 1
         FROM A ,tt_AC_NPA_QTR_NO_7 A 
          WHERE AcBuRevisedSegmentCode IN ( 'Agri-Retail','WCF','Agri-Wholesale','MC','SME','CIB','SCF','FIG' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPA_QTR_NO = 1;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, seg.ProvisionAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
              --inner JOIN DimProduct	dp
               --	on 	(dp.EffectiveFromTimeKey<=@TimeKey AND dp.EffectiveToTimeKey>=@TimeKey)
               --	and dp.ProductAlt_Key=a.ProductAlt_Key
               )
                JOIN DimProvision_Seg seg   ON ( seg.EffectiveFromTimeKey <= v_TimeKey
                AND seg.EffectiveToTimeKey >= v_TimeKey )
                AND seg.Segment = CASE 
                                       WHEN A.SecApp = 'U' THEN 'UNSECURED' -- dp.ProductSubGroup
                 END
                JOIN tt_AC_NPA_QTR_NO_7 NP   ON NP.AccountEntityID = A.AccountEntityID
                AND NP.NPA_QTR_NO BETWEEN SEG.LowerDPD AND SEG.UpperDPD 
          WHERE AssetClassShortNameEnum = 'SUB'
           AND SEG.Segment = 'UNSECURED'
           AND C.AssetClassGroup = 'NPA') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /*UPDATE PROISION ALT KEY FOR NPA (DOUBTFUL) ACCOUNT AS PER SEGMENT UNSCURED - RETAIL, MSME AND MICRO  */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, seg.ProvisionAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
              --inner JOIN DimProduct	dp
               --	on 	(dp.EffectiveFromTimeKey<=@TimeKey AND dp.EffectiveToTimeKey>=@TimeKey)
               --	and dp.ProductAlt_Key=a.ProductAlt_Key
               )
                JOIN DimProvision_Seg seg   ON ( seg.EffectiveFromTimeKey <= v_TimeKey
                AND seg.EffectiveToTimeKey >= v_TimeKey )
                AND seg.Segment = CASE 
                                       WHEN A.SecApp = 'U' THEN 'UNSECURED'   END
                AND SEG.ProvisionShortNameEnum = C.AssetClassShortNameEnum 
          WHERE AssetClassShortNameEnum IN ( 'DB1','DB2','DB3' ---AssetClassShortNameEnum ='SUB' Change by Triloki 30/08/2021
          )

           AND SEG.Segment = 'UNSECURED') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /* VISION PLUS CREDIT CARD - PROVISION FOR SUB  ON CD BASES */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, P.ProvisionAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                JOIN DimProvision_Seg P   ON ( P.EffectiveFromTimeKey <= v_TimeKey
                AND P.EffectiveToTimeKey >= v_TimeKey )
                AND P.Segment = 'CREDIT CARD'
                AND P.ProvisionShortNameEnum = C.AssetClassShortNameEnum
                AND A.CD BETWEEN LowerDPD AND UpperDPD 
          WHERE B.SourceName = 'VisionPLUS'
           AND C.AssetClassGroup = 'NPA'
           AND C.AssetClassShortNameEnum = 'SUB') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /* VISION PLUS CREDIT CARD - PROVISION FOR DB1,DB2 AND DB3 */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, P.ProvisionAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FinalAssetClassAlt_Key, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                JOIN DimProvision_Seg P   ON ( P.EffectiveFromTimeKey <= v_TimeKey
                AND P.EffectiveToTimeKey >= v_TimeKey )
                AND P.Segment = 'CREDIT CARD'
                AND P.ProvisionShortNameEnum = C.AssetClassShortNameEnum 
          WHERE B.SourceName = 'VisionPLUS'
           AND C.AssetClassGroup = 'NPA'
           AND C.AssetClassSubGroup = 'DOUBTFUL') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /* PROVISION FOR STANDARD ACCOUNT */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, ( SELECT DIMPROVISION_SEGSTD.ProvisionAlt_Key 
           FROM DimProvision_SegStd 
          WHERE  DIMPROVISION_SEGSTD.EffectiveToTimeKey = 49999
                   AND DIMPROVISION_SEGSTD.ProvisionName = 'Other Portfolio' ) AS ProvisionAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                AND A.ProvisionAlt_Key = 0 
          WHERE C.ASSETCLASSGROUP = 'STD') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /*RESTR WORK */
         MERGE INTO C 
         USING (SELECT C.ROWID row_id, 0
         FROM C ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A
                JOIN DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureFacilityTypeAlt_Key
                AND D.DimParameterName = 'RestructureFacility'
                AND D.ParameterShortNameEnum = 'FITL'
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON C.AccountEntityID = A.AccountEntityId ) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ProvisionAlt_Key = 0;
         /* END OF RESTR */
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'UpdateProvisionKey_AccountWise';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      -----------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
      UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'UpdateProvisionKey_AccountWise';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE_RESTR" TO "ADF_CDR_RBL_STGDB";
