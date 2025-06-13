--------------------------------------------------------
--  DDL for Procedure ADVACOTHERFINANCIALDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" 
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
    WHERE  EXT_FLG = 'Y' ;
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempAdvAcOtherFinancialDetail ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --------------------------------------------------------------------------------------------------------------------------------------------------
   INSERT INTO RBL_TEMPDB.TempAdvAcOtherFinancialDetail
     ( AccountEntityId, RefSystemAcId, int_receivable_adv, penal_int_receivable, Accrued_interest, penal_due, Interest_due, other_dues, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp )
     ( 
       --------------------------------FINACLE-----------------------------------
       SELECT ACBD.AccountEntityId AccountEntityId  ,
              ACBD.SystemACID RefSystemAcId  ,
              int_receivable ,
              penal_int_receivable ,
              Accured_Interest ,
              penal_due ,
              Interest_due ,
              other_dues ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  
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
   			INNER JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN RBL_TEMPDB.TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

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
   			INNER JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN RBL_TEMPDB.TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

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
   			INNER JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN RBL_TEMPDB.TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

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
   			INNER JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN RBL_TEMPDB.TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId

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
   			INNER JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD ON A.CustomerAcID=ACBD.CustomerACID And DS.SourceAlt_Key=ACBD.SourceAlt_Key
   			LEFT JOIN RBL_TEMPDB.TempAdVAcBalanceDetail AABD  on AABD.AccountEntityId=ACBD.AccountEntityId
   --------------------------------------------------------------------------------------------------------------------------------------------------


   	UPDATE A
   		SET Ac_NextReviewDueDt=NULL
   	FROM  TempAdvAcFinancialDetail A
   		INNER JOIN RBL_TEMPDB.TempAdvAcBasicDetail B
   			ON A.AccountEntityId=B.AccountEntityId
   		INNER JOIN RBL_MISDB_PROD.DBO.DimProduct C
   			ON C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
   			AND B.ProductAlt_Key=C.ProductAlt_Key
   		 WHERE ISNULL(C.REVIEWFLAG,'N')='N'
   */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVACOTHERFINANCIALDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
