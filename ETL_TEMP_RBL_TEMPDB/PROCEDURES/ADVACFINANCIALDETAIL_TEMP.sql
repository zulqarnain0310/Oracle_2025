--------------------------------------------------------
--  DDL for Procedure ADVACFINANCIALDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Date_ INTO v_DATE
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempAdvAcFinancialDetail ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --------------------------------------------------------------------------------------------------------------------------------------------------
   INSERT INTO RBL_TEMPDB.TempAdvAcFinancialDetail
     ( AccountEntityId, Ac_LastReviewDueDt, Ac_ReviewTypeAlt_key, Ac_ReviewDt, Ac_ReviewAuthAlt_Key, Ac_NextReviewDueDt, DrawingPower, InttRate
   --,IrregularType
    --,IrregularityDt
   , NpaDt, BookDebts, UnDrawnAmt
   --,TotalDI
    --,UnAppliedIntt
    --,LegalExp
   , UnAdjSubSidy, LastInttRealiseDt, MocStatus, MOCReason
   --,WriteOffAmt_HO
    --,InterestRateCodeAlt_Key
    --,WriteOffDt
    --,OD_Dt
   , LimitDisbursed
   --,WriteOffAmt_BR
   , RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocDate, MocTypeAlt_Key, CropDuration, Ac_ReviewAuthLevelAlt_Key, AccountBlkCode2 )
     ( 
       --------------------------------FINACLE-----------------------------------
       SELECT DISTINCT ACBD.AccountEntityId AccountEntityId  ,
                       NULL Ac_LastReviewDueDt  ,
                       0 Ac_ReviewTypeAlt_key  ,
                       NULL Ac_ReviewDt  ,
                       0 Ac_ReviewAuthAlt_Key  ,
                       CASE 
                            WHEN ( REVIEWFLAG = 'Y'
                              OR NVL(ds.SourceShortNameEnum, ' ') = 'ECBF' ) THEN LimitExpiryDate
                       ELSE NULL
                          END Ac_NextReviewDueDt ,--09062021 anar -- suggested by sharma sir limit review date will be update as next revuew date

                       A.DrawingPower + CASE 
                                             WHEN A.AdhocExpiryDate >= v_DATE THEN NVL(AdhocAmt, 0)
                       ELSE 0
                          END DrawingPower ,--WDLMT  lnddalyt

                       A.InttRate InttRate  ,
                       --,NULL AS IrregularType
                       --,NULL AS IrregularityDt
                       NULL ,--A.NPADate AS NpaDt

                       NULL BookDebts  ,
                       NULL UnDrawnAmt  ,
                       --,NULL AS TotalDI
                       --,NULL AS UnAppliedIntt
                       --,NULL AS LegalExp
                       NULL UnAdjSubSidy  ,
                       NULL LastInttRealiseDt  ,
                       NULL MocStatus  ,
                       NULL MOCReason  ,
                       --,NULL AS WriteOffAmt_HO   --LoanStatusID  l_loan for write off indification  n for npa
                       --,NULL AS InterestRateCodeAlt_Key
                       --,NULL AS WriteOffDt
                       --,NULL AS OD_Dt
                       NULL LimitDisbursed ,---  DisbursedAmount  l_loan     tdr for lndality

                       --,NULL AS WriteOffAmt_BR
                       ACBD.RefCustomerId RefCustomerId  ,
                       ACBD.SystemACID RefSystemAcId  ,
                       NULL AuthorisationStatus  ,
                       v_vEffectivefrom EffectiveFromTimeKey  ,
                       49999 EffectiveToTimeKey  ,
                       'SSISUSER' CreatedBy  ,
                       SYSDATE DateCreated  ,
                       NULL ModifiedBy  ,
                       NULL DateModified  ,
                       NULL ApprovedBy  ,
                       NULL DateApproved  ,
                       NULL D2Ktimestamp  ,
                       NULL MocDate  ,
                       NULL MocTypeAlt_Key  ,
                       NULL CropDuration  ,
                       NULL Ac_ReviewAuthLevelAlt_Key  ,
                       AccountBlkCode2 
       FROM RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM A
              LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB DS   ON DS.SourceName = A.SourceSystem
              AND DS.EffectiveFromTimeKey <= v_TimeKey
              AND DS.EffectiveToTimeKey >= v_TimeKey
              JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD   ON A.CustomerAcID = ACBD.CustomerACID ---And DS.SourceAlt_Key=ACBD.SourceAlt_Key

              LEFT JOIN RBL_TEMPDB.TempAdVAcBalanceDetail AABD   ON AABD.AccountEntityId = ACBD.AccountEntityId
              JOIN RBL_MISDB_PROD.DimProduct P   ON P.EffectiveFromTimeKey <= v_TIMEKEY
              AND P.EFFECTIVETOTIMEKEY >= v_TIMEKEY
              AND ACBD.PRODUCTALT_KEY = P.PRODUCTALT_KEY );/*
   UNION

   --------------------------------INDUS-----------------------------------

   	SELECT 
   			ACBD.AccountEntityId AS  AccountEntityId
   			,NULL AS Ac_LastReviewDueDt
   			,0 AS Ac_ReviewTypeAlt_key
   			,NULL AS Ac_ReviewDt
   			,0 AS Ac_ReviewAuthAlt_Key
   			,NULL AS Ac_NextReviewDueDt
   			,NULL AS DrawingPower   --WDLMT  lnddalyt
   			,A.InttRate AS InttRate
   			--,NULL AS IrregularType
   			--,NULL AS IrregularityDt
   			,A.NPADate AS NpaDt
   			,NULL AS BookDebts
   			,NULL AS UnDrawnAmt
   			--,NULL AS TotalDI
   			--,NULL AS UnAppliedIntt
   			--,NULL AS LegalExp
   			,NULL AS UnAdjSubSidy
   			,NULL AS LastInttRealiseDt
   			,NULL AS MocStatus
   			,NULL AS MOCReason
   			--,NULL AS WriteOffAmt_HO   --LoanStatusID  l_loan for write off indification  n for npa
   			--,NULL AS InterestRateCodeAlt_Key
   			--,NULL AS WriteOffDt
   			--,NULL AS OD_Dt
   			,NULL AS LimitDisbursed---  DisbursedAmount  l_loan     tdr for lndality
   			--,NULL AS WriteOffAmt_BR
   			,ACBD.RefCustomerId [RefCustomerId]
   			,ACBD.SystemACID [RefSystemAcId]
   			,NULL AS AuthorisationStatus
   			,@vEffectivefrom AS EffectiveFromTimeKey
   			,49999 AS EffectiveToTimeKey
   			,'SSISUSER' AS CreatedBy
   			,GETDATE() AS DateCreated
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS MocDate
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CropDuration
   			,NULL AS Ac_ReviewAuthLevelAlt_Key
   			FROM RBL_STGDB.DBO.ACCOUNT_SOURCESYSTEM02_STG A
   			INNER JOIN RBL_MISDB_PROD.DBO.DIMSOURCEDB DS ON DS.SourceName=A.SourceSystem
   			AND DS.EffectiveFromTimeKey<=@TimeKey And DS.EffectiveToTimeKey>=@TimeKey
   			INNER JOIN TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

   UNION 

   --------------------------------ECBF-----------------------------------

   	SELECT 
   			ACBD.AccountEntityId AS  AccountEntityId
   			,NULL AS Ac_LastReviewDueDt
   			,0 AS Ac_ReviewTypeAlt_key
   			,NULL AS Ac_ReviewDt
   			,0 AS Ac_ReviewAuthAlt_Key
   			,NULL AS Ac_NextReviewDueDt
   			,NULL AS DrawingPower   --WDLMT  lnddalyt
   			,A.InttRate AS InttRate
   			--,NULL AS IrregularType
   			--,NULL AS IrregularityDt
   			,A.NPADate AS NpaDt
   			,NULL AS BookDebts
   			,NULL AS UnDrawnAmt
   			--,NULL AS TotalDI
   			--,NULL AS UnAppliedIntt
   			--,NULL AS LegalExp
   			,NULL AS UnAdjSubSidy
   			,NULL AS LastInttRealiseDt
   			,NULL AS MocStatus
   			,NULL AS MOCReason
   			--,NULL AS WriteOffAmt_HO   --LoanStatusID  l_loan for write off indification  n for npa
   			--,NULL AS InterestRateCodeAlt_Key
   			--,NULL AS WriteOffDt
   			--,NULL AS OD_Dt
   			,NULL AS LimitDisbursed---  DisbursedAmount  l_loan     tdr for lndality
   			--,NULL AS WriteOffAmt_BR
   			,ACBD.RefCustomerId [RefCustomerId]
   			,ACBD.SystemACID [RefSystemAcId]
   			,NULL AS AuthorisationStatus
   			,@vEffectivefrom AS EffectiveFromTimeKey
   			,49999 AS EffectiveToTimeKey
   			,'SSISUSER' AS CreatedBy
   			,GETDATE() AS DateCreated
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS MocDate
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CropDuration
   			,NULL AS Ac_ReviewAuthLevelAlt_Key
   			FROM RBL_STGDB.DBO.ACCOUNT_SOURCESYSTEM03_STG A
   			INNER JOIN RBL_MISDB_PROD.DBO.DIMSOURCEDB DS ON DS.SourceName=A.SourceSystem
   			AND DS.EffectiveFromTimeKey<=@TimeKey And DS.EffectiveToTimeKey>=@TimeKey
   			INNER JOIN TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

   UNION

   --------------------------------MIFIN-----------------------------------

   	SELECT 
   			ACBD.AccountEntityId AS  AccountEntityId
   			,NULL AS Ac_LastReviewDueDt
   			,0 AS Ac_ReviewTypeAlt_key
   			,NULL AS Ac_ReviewDt
   			,0 AS Ac_ReviewAuthAlt_Key
   			,NULL AS Ac_NextReviewDueDt
   			,NULL AS DrawingPower   --WDLMT  lnddalyt
   			,A.InttRate AS InttRate
   			--,NULL AS IrregularType
   			--,NULL AS IrregularityDt
   			,A.NPADate AS NpaDt
   			,NULL AS BookDebts
   			,NULL AS UnDrawnAmt
   			--,NULL AS TotalDI
   			--,NULL AS UnAppliedIntt
   			--,NULL AS LegalExp
   			,NULL AS UnAdjSubSidy
   			,NULL AS LastInttRealiseDt
   			,NULL AS MocStatus
   			,NULL AS MOCReason
   			--,NULL AS WriteOffAmt_HO   --LoanStatusID  l_loan for write off indification  n for npa
   			--,NULL AS InterestRateCodeAlt_Key
   			--,NULL AS WriteOffDt
   			--,NULL AS OD_Dt
   			,NULL AS LimitDisbursed---  DisbursedAmount  l_loan     tdr for lndality
   			--,NULL AS WriteOffAmt_BR
   			,ACBD.RefCustomerId [RefCustomerId]
   			,ACBD.SystemACID [RefSystemAcId]
   			,NULL AS AuthorisationStatus
   			,@vEffectivefrom AS EffectiveFromTimeKey
   			,49999 AS EffectiveToTimeKey
   			,'SSISUSER' AS CreatedBy
   			,GETDATE() AS DateCreated
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS MocDate
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CropDuration
   			,NULL AS Ac_ReviewAuthLevelAlt_Key
   			FROM RBL_STGDB.DBO.ACCOUNT_SOURCESYSTEM04_STG A
   			INNER JOIN RBL_MISDB_PROD.DBO.DIMSOURCEDB DS ON DS.SourceName=A.SourceSystem
   			AND DS.EffectiveFromTimeKey<=@TimeKey And DS.EffectiveToTimeKey>=@TimeKey
   			INNER JOIN TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

   UNION

   --------------------------------GANASEVA-----------------------------------

   	SELECT 
   			ACBD.AccountEntityId AS  AccountEntityId
   			,NULL AS Ac_LastReviewDueDt
   			,0 AS Ac_ReviewTypeAlt_key
   			,NULL AS Ac_ReviewDt
   			,0 AS Ac_ReviewAuthAlt_Key
   			,NULL AS Ac_NextReviewDueDt
   			,NULL AS DrawingPower   --WDLMT  lnddalyt
   			,A.InttRate AS InttRate
   			--,NULL AS IrregularType
   			--,NULL AS IrregularityDt
   			,A.NPADate AS NpaDt
   			,NULL AS BookDebts
   			,NULL AS UnDrawnAmt
   			--,NULL AS TotalDI
   			--,NULL AS UnAppliedIntt
   			--,NULL AS LegalExp
   			,NULL AS UnAdjSubSidy
   			,NULL AS LastInttRealiseDt
   			,NULL AS MocStatus
   			,NULL AS MOCReason
   			--,NULL AS WriteOffAmt_HO   --LoanStatusID  l_loan for write off indification  n for npa
   			--,NULL AS InterestRateCodeAlt_Key
   			--,NULL AS WriteOffDt
   			--,NULL AS OD_Dt
   			,NULL AS LimitDisbursed---  DisbursedAmount  l_loan     tdr for lndality
   			--,NULL AS WriteOffAmt_BR
   			,ACBD.RefCustomerId [RefCustomerId]
   			,ACBD.SystemACID [RefSystemAcId]
   			,NULL AS AuthorisationStatus
   			,@vEffectivefrom AS EffectiveFromTimeKey
   			,49999 AS EffectiveToTimeKey
   			,'SSISUSER' AS CreatedBy
   			,GETDATE() AS DateCreated
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS MocDate
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CropDuration
   			,NULL AS Ac_ReviewAuthLevelAlt_Key
   			FROM RBL_STGDB.DBO.ACCOUNT_SOURCESYSTEM05_STG A
   			INNER JOIN RBL_MISDB_PROD.DBO.DIMSOURCEDB DS ON DS.SourceName=A.SourceSystem
   			AND DS.EffectiveFromTimeKey<=@TimeKey And DS.EffectiveToTimeKey>=@TimeKey
   			INNER JOIN TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

   UNION 

   --------------------------------VISION PLUS-----------------------------------

   	SELECT 
   			ACBD.AccountEntityId AS  AccountEntityId
   			,NULL AS Ac_LastReviewDueDt
   			,0 AS Ac_ReviewTypeAlt_key
   			,NULL AS Ac_ReviewDt
   			,0 AS Ac_ReviewAuthAlt_Key
   			,NULL AS Ac_NextReviewDueDt
   			,NULL AS DrawingPower   --WDLMT  lnddalyt
   			,A.InttRate AS InttRate
   			--,NULL AS IrregularType
   			--,NULL AS IrregularityDt
   			,A.NPADate AS NpaDt
   			,NULL AS BookDebts
   			,NULL AS UnDrawnAmt
   			--,NULL AS TotalDI
   			--,NULL AS UnAppliedIntt
   			--,NULL AS LegalExp
   			,NULL AS UnAdjSubSidy
   			,NULL AS LastInttRealiseDt
   			,NULL AS MocStatus
   			,NULL AS MOCReason
   			--,NULL AS WriteOffAmt_HO   --LoanStatusID  l_loan for write off indification  n for npa
   			--,NULL AS InterestRateCodeAlt_Key
   			--,NULL AS WriteOffDt
   			--,NULL AS OD_Dt
   			,NULL AS LimitDisbursed---  DisbursedAmount  l_loan     tdr for lndality
   			--,NULL AS WriteOffAmt_BR
   			,ACBD.RefCustomerId [RefCustomerId]
   			,ACBD.SystemACID [RefSystemAcId]
   			,NULL AS AuthorisationStatus
   			,@vEffectivefrom AS EffectiveFromTimeKey
   			,49999 AS EffectiveToTimeKey
   			,'SSISUSER' AS CreatedBy
   			,GETDATE() AS DateCreated
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS MocDate
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CropDuration
   			,NULL AS Ac_ReviewAuthLevelAlt_Key
   			FROM RBL_STGDB.DBO.ACCOUNT_SOURCESYSTEM06_STG A
   			INNER JOIN RBL_MISDB_PROD.DBO.DIMSOURCEDB DS ON DS.SourceName=A.SourceSystem
   			AND DS.EffectiveFromTimeKey<=@TimeKey And DS.EffectiveToTimeKey>=@TimeKey
   			INNER JOIN TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId
   --------------------------------------------------------------------------------------------------------------------------------------------------


   	UPDATE A
   		SET Ac_NextReviewDueDt=NULL
   	FROM  TempAdvAcFinancialDetail A
   		INNER JOIN TempAdvAcBasicDetail B
   			ON A.AccountEntityId=B.AccountEntityId
   		INNER JOIN RBL_MISDB_PROD.DBO.DimProduct C
   			ON C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   			AND B.ProductAlt_Key=C.ProductAlt_Key
   		 WHERE ISNULL(C.REVIEWFLAG,'N')='N'
   */

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACFINANCIALDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
