--------------------------------------------------------
--  DDL for Procedure UPDATEPROVISIONKEY_ACCOUNTWISE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" /*=========================================
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
    DECLARE v_SQLERRM varchar(150);
   BEGIN
      DECLARE
         v_EXTDATE VARCHAR2(200);
         v_SubStandard NUMBER(10,0) ;
         v_SubStandardInfrastructure NUMBER(10,0) ;
         v_SubStandardAbinitioUnsecured NUMBER(10,0) ;
         v_DoubtfulI NUMBER(10,0) ;
         v_DoubtfulII NUMBER(10,0) ;
         v_DoubtfulIII NUMBER(10,0) ;
         v_Loss NUMBER(10,0) ;
         /*UPDATE PROISION ALT KEY FOR NPA (SUB) ACCOUNT AS PER SEGMENT UNSCURED - RETAIL, MSME AND MICRO  ON THE BASES OF NPA QTR NO */
         /* prepare NPA Qtr No */
         v_CurQtrDate VARCHAR2(200);
         v_LastQtrDate VARCHAR2(200);
         v_LastToLastQtrDate VARCHAR2(200);
         v_LastToLastToLastQtrDate VARCHAR2(200);
         /*FETCH PREV QTR PROVISION FOR VISION PLUS ACCOUNTS*/
         v_PrvQtrTimeKey NUMBER(5,0) ;
         -----------------------------------------END---------------------------------------------------------
         /* END OF RESTR */
         ----MANDEEP   FOR PRINCIPALOUTSTANDING <=100  BANKER(SITARAM SIR    Mail Date='21-07-2022' )------------------------------------------------------------------------						
         v_PROV NUMBER(10,0) ;

      BEGIN
      
      SELECT PROVISIONALT_KEY INTO v_SubStandard 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_SubStandardInfrastructure 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard Infrastructure'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
         
         SELECT PROVISIONALT_KEY INTO v_SubStandardAbinitioUnsecured
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Sub Standard Ab initio Unsecured'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
         
         SELECT PROVISIONALT_KEY INTO v_DoubtfulI 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-I'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT PROVISIONALT_KEY INTO v_DoubtfulII 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-II'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
         
         SELECT PROVISIONALT_KEY INTO v_DoubtfulIII
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Doubtful-III'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;

         SELECT PROVISIONALT_KEY INTO v_Loss 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  SEGMENT = 'IRAC'
                   AND PROVISIONNAME = 'Loss'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;

         SELECT LastQtrDateKey  INTO v_PrvQtrTimeKey
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TimeKey = v_TimeKey ;
         -----------------------------------------END---------------------------------------------------------
         /* END OF RESTR */
         ----MANDEEP   FOR PRINCIPALOUTSTANDING <=100  BANKER(SITARAM SIR    Mail Date='21-07-2022' )------------------------------------------------------------------------						
         SELECT ProvisionAlt_Key INTO v_PROV 
           FROM RBL_MISDB_PROD.DIMPROVISION_SEG 
          WHERE  ProvisionRule = 'POS<=100'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
      
      
      
         SELECT DATE_ 

           INTO v_EXTDATE
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TimeKey;
         --DECLARE @VisionPlus_SUB_0 INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_SUB_0'	 AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_SUB_1 INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_SUB_1'	 AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_SUB_2 INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_SUB_2'    AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_DB1 INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_DB1'		  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_DB2 INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_DB2'		  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_DB3 INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_DB3'		  AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         --DECLARE @VisionPlus_LOS INT =	(SELECT PROVISIONALT_KEY FROM RBL_MISDB_PROD.DIMPROVISION_SEG WHERE PROVISIONNAME='VisionPlus_LOS'			AND EFFECTIVEFROMTIMEKEY <=@TIMEKEY AND EFFECTIVETOTIMEKEY >=@TIMEKEY)
         UPDATE GTT_ACCOUNTCAL
            SET PROVISIONALT_KEY = 0;
         /*----------------PROVISION ALT KEY ALL NPA ACCOUNTS--------------------------------*/
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN C.AssetClassShortName = 'SUB' THEN v_SubStandard
         WHEN C.AssetClassShortName = 'DB1' THEN v_DoubtfulI
         WHEN C.AssetClassShortName = 'DB2' THEN v_DoubtfulII
         WHEN C.AssetClassShortName = 'DB3' THEN v_DoubtfulIII
         WHEN C.AssetClassShortName = 'LOS' THEN v_Loss
         ELSE 0
            END) AS ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
              --INNER JOIN RBL_MISDB_PROD.DimSourceDB B  ON A.SourceAlt_Key=B.SourceAlt_Key     AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)

                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
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
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, v_SubStandardAbinitioUnsecured
         FROM GTT_ACCOUNTCAL A
              --INNER JOIN RBL_MISDB_PROD.DimSourceDB B  ON A.SourceAlt_Key=B.SourceAlt_Key     AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)

                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
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
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TimeKey;
         v_LastToLastToLastQtrDate := LAST_DAY(utils.dateadd('MM', -3, v_LastToLastQtrDate)) ;
         
         DELETE FROM GTT_AC_NPA_QTR_NO;
         UTILS.IDENTITY_RESET('GTT_AC_NPA_QTR_NO');

         INSERT INTO GTT_AC_NPA_QTR_NO ( AccountEntityID,NPA_QTR_NO,ACBUREVISEDSEGMENTCODE)
         	SELECT AccountEntityID ,
                 CASE 
                      WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastQtrDate) AND v_CurQtrDate THEN 1
                      WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastQtrDate) AND v_LastQtrDate THEN 2
                      WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastToLastQtrDate) AND v_LastToLastQtrDate THEN 3
                 ELSE 4
                    END NPA_QTR_NO  ,
                 seg.AcBuRevisedSegmentCode 
         	  FROM GTT_ACCOUNTCAL A
                   LEFT JOIN RBL_MISDB_PROD.DimAcBuSegment SEG   ON SEG.AcBuSegmentCode = A.ActSegmentCode
                   AND ( SEG.EffectiveFromTimeKey <= v_TimeKey
                   AND SEG.EffectiveToTimeKey >= v_TimeKey )
         	 WHERE  FinalAssetClassAlt_Key > 1 ;
         /* UPDATE DEFAULYT QTR NO. 1 FOR MARK PROVISION ALTKEY OF UNSECURED 25% FOR BEOLOW SEGMENT AND UNSECURED PRODUCTS */
         MERGE INTO GTT_AC_NPA_QTR_NO A 
         USING (SELECT A.ROWID row_id, 1
         FROM GTT_AC_NPA_QTR_NO A 
          WHERE AcBuRevisedSegmentCode IN ( 'Agri-Retail','WCF','Agri-Wholesale','MC','SME','CIB','SCF','FIG' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET NPA_QTR_NO = 1;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, seg.ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
              --inner JOIN DimProduct	dp
               --	on 	(dp.EffectiveFromTimeKey<=@TimeKey AND dp.EffectiveToTimeKey>=@TimeKey)
               --	and dp.ProductAlt_Key=a.ProductAlt_Key
               )
                JOIN RBL_MISDB_PROD.DIMPROVISION_SEG seg   ON ( seg.EffectiveFromTimeKey <= v_TimeKey
                AND seg.EffectiveToTimeKey >= v_TimeKey )
                AND seg.Segment = CASE 
                                       WHEN A.SecApp = 'U' THEN 'UNSECURED' -- dp.ProductSubGroup
                 END
                JOIN GTT_AC_NPA_QTR_NO NP   ON NP.AccountEntityID = A.AccountEntityID
                AND NP.NPA_QTR_NO BETWEEN SEG.LowerDPD AND SEG.UpperDPD 
          WHERE AssetClassShortNameEnum = 'SUB'
           AND SEG.Segment = 'UNSECURED'
           AND C.AssetClassGroup = 'NPA') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /*UPDATE PROISION ALT KEY FOR NPA (DOUBTFUL) ACCOUNT AS PER SEGMENT UNSCURED - RETAIL, MSME AND MICRO  */
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, seg.ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey
              --inner JOIN DimProduct	dp
               --	on 	(dp.EffectiveFromTimeKey<=@TimeKey AND dp.EffectiveToTimeKey>=@TimeKey)
               --	and dp.ProductAlt_Key=a.ProductAlt_Key
               )
                JOIN RBL_MISDB_PROD.DIMPROVISION_SEG seg   ON ( seg.EffectiveFromTimeKey <= v_TimeKey
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
         /* AMAR - ADD ON 17022022  - PROVISION CHANGES */
         /* VISION PLUS CREDIT CARD - PROVISION FOR SUB  ON CD BASES */
         --UPDATE A 
         --	SET A.ProvisionAlt_Key= P.ProvisionAlt_Key
         --FROM PRO.AccountCal A 
         --INNER JOIN RBL_MISDB_PROD.DimSourceDB B 
         --	ON A.SourceAlt_Key=B.SourceAlt_Key
         --	AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
         --INNER JOIN RBL_MISDB_PROD.DimAssetClass C 
         --	ON C.AssetClassAlt_Key=isnull(A.FINALASSETCLASSALT_KEY,1)
         --	AND (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
         --INNER JOIN RBL_MISDB_PROD.DIMPROVISION_SEG P
         --	ON (P.EffectiveFromTimeKey<=@TimeKey AND P.EffectiveToTimeKey>=@TimeKey)
         --	AND P.Segment='CREDIT CARD'
         --	AND P.ProvisionShortNameEnum=C.AssetClassShortNameEnum
         --	AND A.CD BETWEEN LowerDPD AND UpperDPD
         --WHERE B.SourceName='VisionPLUS' and C.AssetClassGroup='NPA'
         --	AND C.AssetClassShortNameEnum='SUB'
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, P.ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                JOIN RBL_MISDB_PROD.DIMPROVISION_SEG P   ON ( P.EffectiveFromTimeKey <= v_TimeKey
                AND P.EffectiveToTimeKey >= v_TimeKey )
                AND P.Segment = 'CREDIT CARD'
                AND ProvisionRule = 'K/W/E/U'
                AND A.AccountBlkCode2 IN ( 'K','W','E','U' )

                AND P.ProvisionShortNameEnum = C.AssetClassShortNameEnum
                AND A.DPD_Max BETWEEN LowerDPD AND UpperDPD 
          WHERE B.SourceName = 'VisionPLUS'
           AND C.AssetClassGroup = 'NPA'
           AND C.AssetClassShortNameEnum = 'SUB') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, P.ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                JOIN RBL_MISDB_PROD.DIMPROVISION_SEG P   ON ( P.EffectiveFromTimeKey <= v_TimeKey
                AND P.EffectiveToTimeKey >= v_TimeKey )
                AND P.Segment = 'CREDIT CARD'
                AND ProvisionRule = 'OTHERS/BLANK'
                AND NVL(A.AccountBlkCode2, ' ') NOT IN ( 'K','W','E','U' )

                AND P.ProvisionShortNameEnum = C.AssetClassShortNameEnum
                AND A.DPD_Max BETWEEN LowerDPD AND UpperDPD 
          WHERE B.SourceName = 'VisionPLUS'
           AND C.AssetClassGroup = 'NPA'
           AND C.AssetClassShortNameEnum = 'SUB') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /* VISION PLUS CREDIT CARD - PROVISION FOR DB1,DB2 AND DB3 */
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, P.ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimSourceDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                JOIN RBL_MISDB_PROD.DIMPROVISION_SEG P   ON ( P.EffectiveFromTimeKey <= v_TimeKey
                AND P.EffectiveToTimeKey >= v_TimeKey )
                AND P.Segment = 'CREDIT CARD'
                AND P.ProvisionShortNameEnum = C.AssetClassShortNameEnum 
          WHERE B.SourceName = 'VisionPLUS'
           AND C.AssetClassGroup = 'NPA'
           AND C.AssetClassSubGroup = 'DOUBTFUL') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         DELETE FROM GTT_PrvQtrProv;
         UTILS.IDENTITY_RESET('GTT_PrvQtrProv');

         INSERT INTO GTT_PrvQtrProv ( 
         	SELECT AccountEntityID ,
                 a.ProvisionAlt_Key ,
                 b.ProvisionSecured 
         	  FROM MAIN_PRO.AccountCal_Hist a
                   JOIN RBL_MISDB_PROD.DIMPROVISION_SEG B   ON A.ProvisionAlt_Key = B.ProvisionAlt_Key
                   AND B.EffectiveFromTimeKey <= v_PrvQtrTimeKey
                   AND B.EffectiveToTimeKey >= v_PrvQtrTimeKey
                   AND a.EffectiveFromTimeKey <= v_PrvQtrTimeKey
                   AND a.EffectiveToTimeKey >= v_PrvQtrTimeKey
                   AND SourceAlt_Key = 6
                   AND a.FinalAssetClassAlt_Key > 1 );
         /* COMPARE CURRENT QTR PROV AND PREV QTR PROVISION */
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.ProvisionSecured < C.ProvisionSecured THEN C.ProvisionAlt_Key
         ELSE A.ProvisionAlt_Key
            END AS ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DIMPROVISION_SEG B   ON B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                AND A.ProvisionAlt_Key = B.ProvisionAlt_Key
                JOIN GTT_PrvQtrProv C   ON A.AccountEntityID = C.AccountEntityID 
          WHERE SourceAlt_Key = 6
           AND a.FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /* AMAR - ADD ON 17022022  - PROVISION CHANGES */
         /* PROVISION FOR STANDARD ACCOUNT */
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, ( SELECT DPS.ProvisionAlt_Key 
           FROM RBL_MISDB_PROD.DimProvision_SegStd DPS
          WHERE  DPS.EffectiveToTimeKey = 49999
                   AND DPS.ProvisionName = 'Other Portfolio' ) AS ProvisionAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = NVL(A.FINALASSETCLASSALT_KEY, 1)
                AND ( C.EffectiveFromTimeKey <= v_TimeKey
                AND C.EffectiveToTimeKey >= v_TimeKey )
                AND A.ProvisionAlt_Key = 0 
          WHERE C.ASSETCLASSGROUP = 'STD') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProvisionAlt_Key = src.ProvisionAlt_Key;
         /*RESTR WORK */
         --UPDATE C
         --		SET ProvisionAlt_Key=0
         --	FROM pro.AdvAcRestructureCal A
         --	INNER JOIN RBL_MISDB_PROD.DimParameter D ON D.EffectiveFromTimeKey <=@timekey AND D.EffectiveToTimeKey>=@timekey 
         --		AND D.ParameterAlt_Key=A.RestructureFacilityTypeAlt_Key
         --		AND D.DimParameterName='RestructureFacility' 
         --		and d.ParameterShortNameEnum='FITL'
         --	INNER JOIN PRO.ACCOUNTCAL C
         --		ON C.AccountEntityID=A.AccountEntityId
         -----------------------------Dated 10-07-2022---for restructured account provision for FITL Accounts----------------------------------------
         MERGE INTO GTT_ACCOUNTCAL C
         USING (SELECT C.ROWID row_id, 0
         FROM CURDAT_RBL_MISDB_PROD.AdvAcRestructureDetail A
                JOIN RBL_MISDB_PROD.DimParameter D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                AND D.EffectiveToTimeKey >= v_TIMEKEY
                AND D.ParameterAlt_Key = A.RestructureFacilityTypeAlt_Key
                AND D.DimParameterName = 'RestructureFacility'
                AND D.ParameterShortNameEnum = 'FITL'
                JOIN GTT_ACCOUNTCAL C   ON C.AccountEntityID = A.AccountEntityId 
          WHERE A.EffectiveFromTimeKey <= v_TIMEKEY
           AND A.EffectiveToTimeKey >= v_TIMEKEY) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET C.ProvisionAlt_Key = 0;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, (CASE 
         WHEN A.FinalAssetClassAlt_Key = 2 THEN v_PROV
         WHEN A.FinalAssetClassAlt_Key IN ( 3,4 )

           AND A.SecApp = 'S' THEN v_PROV
         ELSE A.PROVISIONALT_KEY
            END) AS PROVISIONALT_KEY
         FROM GTT_ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimAssetClass C   ON C.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
                AND C.AssetClassShortName IN ( 'SUB','DB1','DB2' )

          WHERE A.PRINCOUTSTD <= 100
           AND A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PROVISIONALT_KEY = src.PROVISIONALT_KEY;
         ---ALL COUNTS SHOULD BE NPA  IT WILL COVER ONLY(SUBSTANDAR,DOUBTFULL1,DOUBTFULL 2)
         ---SUBSTANDAR-ALL ACCOUNT   DB1- ONLY SECURED  DB2 -ONLY SECURED	
         -------------------------------------------------------------------------------------------------------------------------------------------------
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'UpdateProvisionKey_AccountWise';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
    v_SQLERRM:=SQLERRM;
      -----------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'UpdateProvisionKey_AccountWise';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATEPROVISIONKEY_ACCOUNTWISE" TO "ADF_CDR_RBL_STGDB";
