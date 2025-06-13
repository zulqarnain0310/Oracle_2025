--------------------------------------------------------
--  DDL for Procedure ADVFACCCDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" 
-- =============================================  
 -- Author:  <Author,,Name>  
 -- Create date: <Create Date,,>  
 -- Description: <Description,,>  
 -- =============================================  

AS
   -- SET NOCOUNT ON added to prevent extra result sets from  
   -- interfering with SELECT statements.  
   -- Insert statements for procedure here  
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
-- Add the parameters for the stored procedure here  

BEGIN

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvFacCCDetail ';
   INSERT INTO TempAdvFacCCDetail
     ( AccountEntityId, AdhocDt, AdhocAmt, ContExcsSinceDt
   --,[MarginAmt]  
   , DerecognisedInterest1, DerecognisedInterest2
   --,[AdjReasonAlt_Key]  
    --,[EntityClosureDate]  
    --,[EntityClosureReasonAlt_Key]  
   , ClaimType, ClaimCoverAmt, ClaimLodgedDt, ClaimLodgedAmt, ClaimRecvDt, ClaimReceivedAmt, ClaimRate, RefSystemAcid, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key, AdhocExpiryDate
   --,[AdhocPermittedAlt_key]  
    --,[AdhocAuth_ID]  
    --,[AdhocNormalInterest]  
   , StockStmtDt )
     ( 
       ------------------FINACLE ------------  
       SELECT ACBD.AccountEntityId AccountEntityId  ,
              A.AdhocDate AdhocDt  ,
              A.AdhocAmt AdhocAmt  ,
              a.ContiExcessDate ContExcsSinceDt  ,
              --,NULL [MarginAmt]  
              NULL DerecognisedInterest1  ,
              NULL DerecognisedInterest2  ,
              --,0 AS [AdjReasonAlt_Key]  
              --,NULL [EntityClosureDate]  
              --,0 AS [EntityClosureReasonAlt_Key]  
              NULL ClaimType  ,
              NULL ClaimCoverAmt  ,
              NULL ClaimLodgedDt  ,
              NULL ClaimLodgedAmt  ,
              NULL ClaimRecvDt  ,
              NULL ClaimReceivedAmt  ,
              NULL ClaimRate  ,
              ACBD.SystemAcId RefSystemAcid  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL MocTypeAlt_Key  ,
              NULL AdhocExpiryDate  ,
              --,NULL [AdhocPermittedAlt_key]  
              --,NULL [AdhocAuth_ID]  
              --,NULL [AdhocNormalInterest]  
              A.STOCKSTATEMENTDT 

       --SELECT * FROM RBL_STGDB.dbo.ACCOUNT_ALL_SOURCE_SYSTEM
       FROM TempAdvAcBasicDetail ACBD
              JOIN RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM A   ON A.customeracid = ACBD.CustomerAcid
              LEFT JOIN RBL_MISDB_010922_UAT.DimGLProduct DGP   ON DGP.GLProductAlt_Key = ACBD.GLProductAlt_Key
              AND DGP.EffectiveFromTimeKey <= v_TimeKey
              AND DGP.EffectiveToTimeKey >= v_TimeKey
        WHERE  ACBD.FacilityType IN ( 'OD','CC','CCOD' )
      );/*  
   UNION   

   -------------INDUS----------------  

   SELECT   
               ACBD.AccountEntityId AS [AccountEntityId]  
              ,A.AdhocDate [AdhocDt]  
              ,A.AdhocAmt [AdhocAmt]  
              ,NULL [ContExcsSinceDt]  
              --,NULL [MarginAmt]  
              ,NULL [DerecognisedInterest1]  
              ,NULL [DerecognisedInterest2]  
              --,0 AS [AdjReasonAlt_Key]  
              --,NULL [EntityClosureDate]  
              --,0 AS [EntityClosureReasonAlt_Key]  
              ,NULL [ClaimType]  
              ,NULL [ClaimCoverAmt]  
              ,NULL [ClaimLodgedDt]  
              ,NULL [ClaimLodgedAmt]  
              ,NULL [ClaimRecvDt]  
              ,NULL [ClaimReceivedAmt]  
              ,NULL [ClaimRate]  
              ,ACBD.SystemAcId AS [RefSystemAcid]  
              ,NULL [AuthorisationStatus]  
              ,@vEffectivefrom AS [EffectiveFromTimeKey]  
              ,49999 AS [EffectiveToTimeKey]  
              ,'SSISUSER' AS [CreatedBy]  
              ,GETDATE() AS [DateCreated]  
              ,NULL [ModifiedBy]  
              ,NULL [DateModified]  
              ,NULL [ApprovedBy]  
              ,NULL [DateApproved]  
              ,NULL [MocStatus]  
              ,NULL [MocDate]  
              ,NULL [MocTypeAlt_Key]  
              ,NULL [AdhocExpiryDate]  
              --,NULL [AdhocPermittedAlt_key]  
              --,NULL [AdhocAuth_ID]  
              --,NULL [AdhocNormalInterest]  

   FROM TempAdvAcBasicDetail ACBD  
   INNER JOIN RBL_STGDB.dbo.ACCOUNT_SOURCESYSTEM02_STG A ON A.customeracid=ACBD.CustomerAcid  
   LEFT JOIN RBL_MISDB_010922_UAT.DBO.DimGLProduct DGP ON DGP.GLProductAlt_Key=ACBD.GLProductAlt_Key and DGP.EffectiveFromTimeKey<=@TimeKey AND DGP.EffectiveToTimeKey>=@TimeKey  
   WHERE ACBD.FacilityType IN ('OD' ,'CC','CCOD')  

   UNION   

   --------ECBF -------  

   SELECT   
               ACBD.AccountEntityId AS [AccountEntityId]  
              ,A.AdhocDate [AdhocDt]  
              ,A.AdhocAmt [AdhocAmt]  
              ,NULL [ContExcsSinceDt]  
              --,NULL [MarginAmt]  
              ,NULL [DerecognisedInterest1]  
              ,NULL [DerecognisedInterest2]  
              --,0 AS [AdjReasonAlt_Key]  
              --,NULL [EntityClosureDate]  
              --,0 AS [EntityClosureReasonAlt_Key]  
              ,NULL [ClaimType]  
              ,NULL [ClaimCoverAmt]  
              ,NULL [ClaimLodgedDt]  
              ,NULL [ClaimLodgedAmt]  
              ,NULL [ClaimRecvDt]  
              ,NULL [ClaimReceivedAmt]  
              ,NULL [ClaimRate]  
              ,ACBD.SystemAcId AS [RefSystemAcid]  
              ,NULL [AuthorisationStatus]  
              ,@vEffectivefrom AS [EffectiveFromTimeKey]  
              ,49999 AS [EffectiveToTimeKey]  
              ,'SSISUSER' AS [CreatedBy]  
              ,GETDATE() AS [DateCreated]  
              ,NULL [ModifiedBy]  
              ,NULL [DateModified]  
              ,NULL [ApprovedBy]  
              ,NULL [DateApproved]  
              ,NULL [MocStatus]  
              ,NULL [MocDate]  
              ,NULL [MocTypeAlt_Key]  
              ,NULL [AdhocExpiryDate]  
              --,NULL [AdhocPermittedAlt_key]  
              --,NULL [AdhocAuth_ID]  
              --,NULL [AdhocNormalInterest]  

   FROM TempAdvAcBasicDetail ACBD  
   INNER JOIN RBL_STGDB.dbo.ACCOUNT_SOURCESYSTEM03_STG A ON A.customeracid=ACBD.CustomerAcid  
   LEFT JOIN RBL_MISDB_010922_UAT.DBO.DimGLProduct DGP ON DGP.GLProductAlt_Key=ACBD.GLProductAlt_Key and DGP.EffectiveFromTimeKey<=@TimeKey AND DGP.EffectiveToTimeKey>=@TimeKey  
   WHERE ACBD.FacilityType IN ('OD' ,'CC','CCOD')  

   UNION  

   ------------------MIFIN ------------  

   SELECT   
               ACBD.AccountEntityId AS [AccountEntityId]  
              ,A.AdhocDate [AdhocDt]  
              ,A.AdhocAmt [AdhocAmt]  
              ,NULL [ContExcsSinceDt]  
              --,NULL [MarginAmt]  
              ,NULL [DerecognisedInterest1]  
              ,NULL [DerecognisedInterest2]  
              --,0 AS [AdjReasonAlt_Key]  
              --,NULL [EntityClosureDate]  
              --,0 AS [EntityClosureReasonAlt_Key]  
              ,NULL [ClaimType]  
              ,NULL [ClaimCoverAmt]  
              ,NULL [ClaimLodgedDt]  
              ,NULL [ClaimLodgedAmt]  
              ,NULL [ClaimRecvDt]  
              ,NULL [ClaimReceivedAmt]  
              ,NULL [ClaimRate]  
              ,ACBD.SystemAcId AS [RefSystemAcid]  
              ,NULL [AuthorisationStatus]  
              ,@vEffectivefrom AS [EffectiveFromTimeKey]  
              ,49999 AS [EffectiveToTimeKey]  
              ,'SSISUSER' AS [CreatedBy]  
              ,GETDATE() AS [DateCreated]  
              ,NULL [ModifiedBy]  
              ,NULL [DateModified]  
              ,NULL [ApprovedBy]  
              ,NULL [DateApproved]  
              ,NULL [MocStatus]  
              ,NULL [MocDate]  
              ,NULL [MocTypeAlt_Key]  
              ,NULL [AdhocExpiryDate]  
              --,NULL [AdhocPermittedAlt_key]  
              --,NULL [AdhocAuth_ID]  
              --,NULL [AdhocNormalInterest]  

   FROM TempAdvAcBasicDetail ACBD  
   INNER JOIN RBL_STGDB.dbo.ACCOUNT_SOURCESYSTEM04_STG A ON A.customeracid=ACBD.CustomerAcid  
   LEFT JOIN RBL_MISDB_010922_UAT.DBO.DimGLProduct DGP ON DGP.GLProductAlt_Key=ACBD.GLProductAlt_Key and DGP.EffectiveFromTimeKey<=@TimeKey AND DGP.EffectiveToTimeKey>=@TimeKey  
   WHERE ACBD.FacilityType IN ('OD' ,'CC','CCOD')  

   UNION   

   -------------GANASEVA----------------  

   SELECT   
               ACBD.AccountEntityId AS [AccountEntityId]  
              ,A.AdhocDate [AdhocDt]  
              ,A.AdhocAmt [AdhocAmt]  
              ,NULL [ContExcsSinceDt]  
              --,NULL [MarginAmt]  
              ,NULL [DerecognisedInterest1]  
              ,NULL [DerecognisedInterest2]  
              --,0 AS [AdjReasonAlt_Key]  
              --,NULL [EntityClosureDate]  
              --,0 AS [EntityClosureReasonAlt_Key]  
              ,NULL [ClaimType]  
              ,NULL [ClaimCoverAmt]  
              ,NULL [ClaimLodgedDt]  
              ,NULL [ClaimLodgedAmt]  
              ,NULL [ClaimRecvDt]  
              ,NULL [ClaimReceivedAmt]  
              ,NULL [ClaimRate]  
              ,ACBD.SystemAcId AS [RefSystemAcid]  
              ,NULL [AuthorisationStatus]  
              ,@vEffectivefrom AS [EffectiveFromTimeKey]  
              ,49999 AS [EffectiveToTimeKey]  
              ,'SSISUSER' AS [CreatedBy]  
              ,GETDATE() AS [DateCreated]  
              ,NULL [ModifiedBy]  
              ,NULL [DateModified]  
              ,NULL [ApprovedBy]  
              ,NULL [DateApproved]  
              ,NULL [MocStatus]  
              ,NULL [MocDate]  
              ,NULL [MocTypeAlt_Key]  
              ,NULL [AdhocExpiryDate]  
              --,NULL [AdhocPermittedAlt_key]  
              --,NULL [AdhocAuth_ID]  
              --,NULL [AdhocNormalInterest]  

   FROM TempAdvAcBasicDetail ACBD  
   INNER JOIN RBL_STGDB.dbo.ACCOUNT_SOURCESYSTEM05_STG A ON A.customeracid=ACBD.CustomerAcid  
   LEFT JOIN RBL_MISDB_010922_UAT.DBO.DimGLProduct DGP ON DGP.GLProductAlt_Key=ACBD.GLProductAlt_Key and DGP.EffectiveFromTimeKey<=@TimeKey AND DGP.EffectiveToTimeKey>=@TimeKey  
   WHERE ACBD.FacilityType IN ('OD' ,'CC','CCOD')  

   UNION   

   --------VISION PLUS -------  

   SELECT   
               ACBD.AccountEntityId AS [AccountEntityId]  
              ,A.AdhocDate [AdhocDt]  
              ,A.AdhocAmt [AdhocAmt]  
              ,NULL [ContExcsSinceDt]  
              --,NULL [MarginAmt]  
              ,NULL [DerecognisedInterest1]  
              ,NULL [DerecognisedInterest2]  
              --,0 AS [AdjReasonAlt_Key]  
              --,NULL [EntityClosureDate]  
              --,0 AS [EntityClosureReasonAlt_Key]  
              ,NULL [ClaimType]  
              ,NULL [ClaimCoverAmt]  
              ,NULL [ClaimLodgedDt]  
              ,NULL [ClaimLodgedAmt]  
              ,NULL [ClaimRecvDt]  
              ,NULL [ClaimReceivedAmt]  
              ,NULL [ClaimRate]  
              ,ACBD.SystemAcId AS [RefSystemAcid]  
              ,NULL [AuthorisationStatus]  
              ,@vEffectivefrom AS [EffectiveFromTimeKey]  
              ,49999 AS [EffectiveToTimeKey]  
              ,'SSISUSER' AS [CreatedBy]  
              ,GETDATE() AS [DateCreated]  
              ,NULL [ModifiedBy]  
              ,NULL [DateModified]  
              ,NULL [ApprovedBy]  
              ,NULL [DateApproved]  
              ,NULL [MocStatus]  
              ,NULL [MocDate]  
              ,NULL [MocTypeAlt_Key]  
              ,NULL [AdhocExpiryDate]  
              --,NULL [AdhocPermittedAlt_key]  
              --,NULL [AdhocAuth_ID]  
              --,NULL [AdhocNormalInterest]  

   FROM TempAdvAcBasicDetail ACBD  
   INNER JOIN RBL_STGDB.dbo.ACCOUNT_SOURCESYSTEM06_STG A ON A.customeracid=ACBD.CustomerAcid  
   LEFT JOIN RBL_MISDB_010922_UAT.DBO.DimGLProduct DGP ON DGP.GLProductAlt_Key=ACBD.GLProductAlt_Key and DGP.EffectiveFromTimeKey<=@TimeKey AND DGP.EffectiveToTimeKey>=@TimeKey  
   WHERE ACBD.FacilityType IN ('OD' ,'CC','CCOD')  
   */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVFACCCDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
