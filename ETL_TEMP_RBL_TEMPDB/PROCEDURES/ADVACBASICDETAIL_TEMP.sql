--------------------------------------------------------
--  DDL for Procedure ADVACBASICDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVACBASICDETAIL_TEMP" 
   
AS  

    V_vEffectivefrom  Int ;
    V_TimeKey  Int ;
    V_DATE DATE ;
    V_AccountEntityId INT;

BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  

    -- Insert statements for procedure here  
    SELECT TimeKey INTO V_vEffectiveFrom FROM RBL_MISDB_PROD.Automate_Advances WHERE EXT_FLG='Y';  
    SELECT TimeKey INTO V_TimeKey FROM RBL_MISDB_PROD.Automate_Advances WHERE EXT_FLG='Y';
    SELECT Date_ INTO V_DATE FROM RBL_MISDB_PROD.Automate_Advances WHERE EXT_FLG='Y';

---------------------------------------------------------------------------------------------------------------------------------------------------   

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ETL_TEMP_RBL_TEMPDB.TempAdvAcBasicDetail';  


      INSERT INTO RBL_TEMPDB.TempAdvAcBasicDetail  
           (BranchCode  
   ,AccountEntityId  
   ,CustomerEntityId  
   ,SystemACID  
   ,CustomerACID  
   ,GLAlt_Key  
   ,ProductAlt_Key  
   ,GLProductAlt_Key  
   ,FacilityType  
   ,SectorAlt_Key  
   ,SubSectorAlt_Key  
   ,ActivityAlt_Key  
   ,IndustryAlt_Key  
   ,SchemeAlt_Key  
   ,DistrictAlt_Key  
   ,AreaAlt_Key  
   ,VillageAlt_Key  
   ,StateAlt_Key  
   ,CurrencyAlt_Key  
   ,OriginalSanctionAuthAlt_Key  
   ,OriginalLimitRefNo  
   ,OriginalLimit  
   ,OriginalLimitDt  
   ,DtofFirstDisb  
   ,FlagReliefWavier  
   ,UnderLineActivityAlt_Key  
   ,MicroCredit  
   ,segmentcode  
   ,ScrCrError  
   ,AdjDt  
   ,AdjReasonAlt_Key  
   ,MarginType  
   ,Pref_InttRate  
   ,CurrentLimitRefNo  
   ,GuaranteeCoverAlt_Key  
   ,AccountName  
   ,AssetClass  
   ,JointAccount  
   ,LastDisbDt  
   ,ScrCrErrorBackup  
   ,AccountOpenDate  
   ,Ac_LADDt  
   ,Ac_DocumentDt  
   ,CurrentLimit  
   ,InttTypeAlt_Key  
   ,InttRateLoadFactor  
   ,Margin  
   ,CurrentLimitDt  
   ,Ac_DueDt  
   ,DrawingPowerAlt_Key  
   ,RefCustomerId  
   ,AuthorisationStatus  
   ,EffectiveFromTimeKey  
   ,EffectiveToTimeKey  
   ,CreatedBy  
   ,DateCreated  
   ,ModifiedBy  
   ,DateModified  
   ,ApprovedBy  
   ,DateApproved  
   ,D2Ktimestamp  
   ,MocStatus  
   ,MocDate  
   ,MocTypeAlt_Key  
   ,IsLAD  
   ,FincaleBasedIndustryAlt_key  
   ,AcCategoryAlt_Key  
   ,OriginalSanctionAuthLevelAlt_Key  
   ,AcTypeAlt_Key  
   ,ScrCrErrorSeq  
   ,BSRUNID  
   ,AdditionalProv  
   ,AclattestDevelopment  
   ,SourceAlt_Key  
   ,LoanSeries  
   ,LoanRefNo  
   ,SecuritizationCode  
   ,Full_Disb  
   ,OriginalBranchcode  
   ,ProjectCost  
   ,FlgSecured  
   ,ReferencePeriod  
   )  

   -------------    FINACLE  ---------  
   SELECT   A.BranchCode  
   ,0 AccountEntityId  
   ,0 CustomerEntityId  
   ,A.CustomerACID SystemACID  
   ,A.CustomerACID CustomerACID  
   ,B.GLAlt_Key  
   ,C.ProductAlt_Key  
   ,DG.GLProductAlt_Key GLProductAlt_Key  
   ,CASE WHEN SOURCESYSTEM='ECBF' AND  C.FacilityType IS NULL THEN 'TL' ELSE C.FacilityType  END  FacilityType  
   ,NULL SectorAlt_Key  
   ,E.SubSectorAlt_Key  
   ,NVL(DA.ActivityAlt_Key,9999) ActivityAlt_Key  
   ,F.IndustryAlt_Key  
   ,NULL SchemeAlt_Key  
   ,NULL DistrictAlt_Key  
   ,NULL AreaAlt_Key  
   ,NULL VillageAlt_Key  
   ,NULL StateAlt_Key  
   ,G.CurrencyAlt_Key  
   ,NULL OriginalSanctionAuthAlt_Key  
   ,NULL OriginalLimitRefNo  
   ,NULL OriginalLimit  
   ,NULL OriginalLimitDt  
   ,A.FirstDtOfDisb DtofFirstDisb    
   ,NULL FlagReliefWavier  
   ,NULL UnderLineActivityAlt_Key  
   ,NULL MicroCredit  
   ,AcSegmentCode segmentcode  
   ,NULL ScrCrError  
   ,NULL AdjDt  
   ,NULL AdjReasonAlt_Key  
   ,NULL MarginType  
   ,NULL Pref_InttRate  
   ,NULL CurrentLimitRefNo  
   ,NULL GuaranteeCoverAlt_Key  
   ,NULL AccountName  
   ,NULL AssetClass  
   ,NULL JointAccount  
   ,NULL LastDisbDt  
   ,NULL ScrCrErrorBackup  
   ,A.AcOpenDt AccountOpenDate  
   ,NULL Ac_LADDt  
   ,NULL Ac_DocumentDt  
   ,A.CurrentLimit+CASE WHEN A.AdhocExpiryDate>=V_DATE THEN NVL(AdhocAmt,0) ELSE 0 END   CurrentLimit  
   ,NULL InttTypeAlt_Key  
   ,NULL InttRateLoadFactor  
   ,NULL Margin  
   ,NULL CurrentLimitDt  
   ,NULL Ac_DueDt  
   ,NULL DrawingPowerAlt_Key  
   ,A.CustomerID RefCustomerId  
   ,NULL AuthorisationStatus  
   ,V_vEffectivefrom EffectiveFromTimeKey  
   ,49999 EffectiveToTimeKey  
   ,'SSISUSER' CreatedBy  
   ,sysdate() DateCreated  
   ,NULL ModifiedBy  
   ,NULL DateModified  
   ,NULL ApprovedBy  
   ,NULL DateApproved  
   ,NULL D2Ktimestamp  
   ,NULL MocStatus  
   ,NULL MocDate  
   ,NULL MocTypeAlt_Key  
   ,CASE WHEN C.ProductGroup='FDSEC' THEN 1 ELSE NULL END IsLAD  
   ,NULL FincaleBasedIndustryAlt_key  
   ,NULL AcCategoryAlt_Key  
   ,NULL OriginalSanctionAuthLevelAlt_Key  
   ,NULL AcTypeAlt_Key  
   ,NULL ScrCrErrorSeq  
   ,NULL BSRUNID  
   ,NULL AdditionalProv  
   ,NULL AclattestDevelopment  
   ,S.SourceAlt_Key SourceAlt_Key  
   ,NULL LoanSeries  
   ,NULL LoanRefNo  
   ,NULL SecuritizationCode  
   ,NULL Full_Disb  
   ,NULL OriginalBranchcode  
   ,NULL ProjectCost  
   ,NULL SecuredStatus  
   ,CASE  WHEN A.AssetClassNorm IS NULL THEN 91  
     WHEN CAST(A.AssetClassNorm AS INT) IN(90,365,180,60)   
      THEN  CAST(A.AssetClassNorm AS INT) +1   
    ELSE CAST(A.AssetClassNorm AS INT) END  
 FROM   RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM A---- WHERE ISNUMERIC(AssetClassNorm)=0    
 LEFT JOIN  RBL_MISDB_PROD.DimGL B ON A.GLCode=B.GLCode  
     AND B.EffectiveFromTimeKey<=V_TimeKey AND B.EffectiveToTimeKey>=V_TimeKey  
 LEFT JOIN  RBL_MISDB_PROD.DimProduct C   
     ON C.ProductCode=A.Scheme_ProductCode    
     AND C.EffectiveFromTimeKey<=V_TimeKey AND C.EffectiveToTimeKey>=V_TimeKey  
 LEFT JOIN  RBL_MISDB_PROD.DimActivity D ON D.SrcSysActivityCode=A.PurposeofAdvance  
     AND D.EffectiveFromTimeKey<=V_TimeKey AND D.EffectiveToTimeKey>=V_TimeKey  
 LEFT JOIN  RBL_MISDB_PROD.DimSubSector E ON E.SubSectorName=A.Sector  
     AND E.EffectiveFromTimeKey<=V_TimeKey AND E.EffectiveToTimeKey>=V_TimeKey  
 LEFT JOIN  RBL_MISDB_PROD.DimIndustry F ON F.SrcSysIndustryCode=A.IndustryCode  
     AND F.EffectiveFromTimeKey<=V_TimeKey AND F.EffectiveToTimeKey>=V_TimeKey  
 LEFT JOIN  RBL_MISDB_PROD.DimCurrency G ON G.SrcSysCurrencyCode=A.CurrencyCode  
     AND G.EffectiveFromTimeKey<=V_TimeKey AND G.EffectiveToTimeKey>=V_TimeKey  
 LEFT JOIN  RBL_MISDB_PROD.DIMSOURCEDB S ON S.SourceName=A.SourceSystem  
     AND S.EffectiveFromTimeKey<=V_TimeKey AND S.EffectiveToTimeKey>=V_TimeKey  
---------------------ADDED BY PRASHANT----------17022024---------------------------------------
 LEFT JOIN RBL_MISDB_PROD.DimActivityMapping DA 
   ON (DA.EffectiveFromTimeKey<=V_TimeKey and DA.EffectiveToTimeKey>=V_TimeKey)  
   AND rtrim(ltrim(DA.SrcSysActivityName))=rtrim(ltrim(A.PurposeofAdvance))
 LEFT JOIN RBL_MISDB_PROD.DimGLProduct DG
   ON        DG.ProductCode=C.ProductCode
   AND       DG.GLCode=A.GLCode
   AND      (DG.EffectiveFromTimeKey<=V_TimeKey and DG.EffectiveToTimeKey>=V_TimeKey) ;

---------------------END---------------------------------------

 /* UPDAE SECURED AND UNSECURED FLAG */  
 UPDATE RBL_TEMPDB.TempAdvAcBasicDetail  
  SET FlgSecured=NULL  ;

 MERGE INTO  RBL_TEMPDB.TempAdvAcBasicDetail A 
 USING (SELECT A.ROWID ROW_ID,B.SecuredStatus ,AcBuRevisedSegmentCode,C.AcBuSegmentShortNameEnum,E.SourceShortNameEnum,segmentcode,D.Agrischeme,D.ProductSubGroup
 FROM RBL_TEMPDB.TempAdvAcBasicDetail A  
  INNER JOIN RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM b  
   ON A.CUSTOMERACID=b.CUSTOMERACID  
  LEFT JOIN RBL_MISDB_PROD.DimAcBuSegment C  
   ON (C.EffectiveFromTimeKey<=V_TimeKey and C.EffectiveToTimeKey>=V_TimeKey)  
   AND A.segmentcode =C.AcBuSegmentCode  
  LEFT JOIN RBL_MISDB_PROD.DIMPRODUCT D  
   ON (D.EffectiveFromTimeKey<=V_TimeKey and D.EffectiveToTimeKey>=V_TimeKey)  
   AND A.ProductAlt_Key =D.ProductAlt_Key  
  LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB E  
   ON (E.EffectiveFromTimeKey<=V_TimeKey and E.EffectiveToTimeKey>=V_TimeKey)  
   AND E.SourceAlt_Key=A.SourceAlt_Key )SRC
   ON (A.ROWID=SRC.ROW_ID)
WHEN MATCHED THEN UPDATE SET A.FlgSecured= CASE WHEN SRC.AcBuRevisedSegmentCode IN('AGRI-WHOLESALE','MC','SME','CIB','SCF','FIG')  
                                     THEN SRC.SecuredStatus  
                                    WHEN SRC.AcBuSegmentShortNameEnum ='FI' OR SRC.SourceShortNameEnum='VisionPlus'   
                                      THEN 'U'  
                                    WHEN  SRC.segmentcode IN('1410','1411') AND SRC.Agrischeme ='Y' AND SRC.ProductSubGroup='SECURED'  
                                      THEN 'S'  
                                    WHEN SRC.ProductSubGroup='SECURED' OR  SRC.SourceShortNameEnum='MIFIN'  
                                      THEN 'S'   
                                    ELSE 'U' END  ;



 ----------------------------------------Added by Prashant mail dated 28-09-2022 as per Ashish Sir--------------------------------------------------------------


   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
    USING (SELECT A.ROWID ROW_ID
    FROM          RBL_TEMPDB.TempAdvAcBasicDetail A
    INNER JOIN    RBL_MISDB_PROD.DimProduct B
   ON            A.ProductAlt_Key=B.ProductAlt_Key
   AND(B.EffectiveFromTimeKey<=V_TimeKey AND B.EffectiveToTimeKey>=V_TimeKey)-- ADDED LIVE TIMEKEY CONDITION BY SATWAJI AS ON 22/11/2022
   WHERE         B.ProductCode IN ('RVLMQ','RVTRC','RVTRL','RVXMQ','RVXPS','RVFCV','RVTR1','RVTR2','RVTRA','RVTRN','RVUTF','RVUMQ','RVEMQ','RVTIM','RVTIH','RVEQU')
   )SRC
   ON (A.ROWID=SRC.ROW_ID)
   WHEN MATCHED THEN UPDATE SET A.FlgSecured='S';
   
 ----------------------------------------------------------------------------------------------------------------------------

  ----------------------------------------Added by Satwaji mail dated 10-11-2022 as per Aniruddha Sir --------------------------------------------------------------


   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID ROW_ID
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
   INNER JOIN    RBL_MISDB_PROD.DimProduct B
   ON            A.ProductAlt_Key=B.ProductAlt_Key
   AND(B.EffectiveFromTimeKey<=V_TimeKey AND B.EffectiveToTimeKey>=V_TimeKey)
   WHERE         B.ProductCode IN ('ECLMS','ECLLP','ECLWC','ECLLR')
    )SRC
      ON (A.ROWID=SRC.ROW_ID)
   WHEN MATCHED THEN UPDATE SET A.FlgSecured='S';


   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID ROW_ID
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
   INNER JOIN    RBL_MISDB_PROD.DimProduct B
   ON            A.ProductAlt_Key=B.ProductAlt_Key
   AND(B.EffectiveFromTimeKey<=V_TimeKey AND B.EffectiveToTimeKey>=V_TimeKey)
   WHERE         B.ProductCode IN ('ECLTL','ECLSL','ECLBL','BILREGECLS','SBLREGECLS')
    )SRC
      ON (A.ROWID=SRC.ROW_ID)
   WHEN MATCHED THEN UPDATE SET A.FlgSecured='S';


   ----- Added by Mandeep for EIFS Source 

   
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID ROW_ID
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
   INNER JOIN    RBL_MISDB_PROD.DimProduct B
   ON            A.ProductAlt_Key=B.ProductAlt_Key
   AND(B.EffectiveFromTimeKey<=V_TimeKey AND B.EffectiveToTimeKey>=V_TimeKey)
   WHERE         B.ProductCode IN ('RVF')
    )SRC
      ON (A.ROWID=SRC.ROW_ID)
   WHEN MATCHED THEN UPDATE SET A.FlgSecured='U';   

     ----------------------------------------Added by Prashant mail dated 20-12-2022 as per Aniruddha Sir --------------------------------------------------------------

   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID ROW_ID
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
   INNER JOIN    RBL_MISDB_PROD.DimProduct B
   ON            A.ProductAlt_Key=B.ProductAlt_Key
   AND(B.EffectiveFromTimeKey<=V_TimeKey AND B.EffectiveToTimeKey>=V_TimeKey)
    WHERE         B.ProductCode IN ('SECI1','SECI2','HLDAI','SECO1','SECIN','SECSR','ALSR','ALLIB','ALII','ALBAJ',
                                    'HLBAJ','SECBA','ALHDF','HLHDF','SECHD','LAGOI')
    )SRC
      ON (A.ROWID=SRC.ROW_ID)
   WHEN MATCHED THEN UPDATE SET A.FlgSecured='S';   


   ------------------------------------------------------------------------------------------------------
     ----------------------------------------Added by Prashant mail dated 28-06-2023 as per Ashish Sir --------------------------------------------------------------
   
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID ROW_ID
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
    INNER JOIN RBL_MISDB_PROD.DIMPRODUCT B
        ON A.PRODUCTALT_KEY=B.PRODUCTALT_KEY
            AND (B.EFFECTIVEFROMTIMEKEY<=V_TIMEKEY AND B.EFFECTIVETOTIMEKEY>=V_TIMEKEY)
    WHERE         B.ProductCode IN ('TWOVL')
    )SRC
    ON (A.ROWID=SRC.ROW_ID)
    WHEN MATCHED THEN UPDATE SET A.FlgSecured='S'
    ;            
   ------------------------------------------------------------------------------------------------------





/*  Existing Customers Account Entity ID Update  */  
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID ROW_ID,M.AccountEntityId 
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
    INNER JOIN RBL_MISDB_PROD.AdvAcBasicDetail M
        ON A.CustomerAcId=M.CustomerAcId
        WHERE M.EffectiveToTimeKey=49999
    )SRC
    ON (A.ROWID=SRC.ROW_ID)
    WHEN MATCHED THEN UPDATE SET A.AccountEntityId=SRC.AccountEntityId 
    ;          
--GO  
/*********************************************************************************************************/  
/*  New Customers Account Entity ID Update  */  

SELECT MAX(AccountEntityId) INTO V_AccountEntityId FROM  RBL_MISDB_PROD.AdvAcBasicDetail;
IF NVL(V_AccountEntityId,0)=0 
THEN
BEGIN  
V_AccountEntityId:=0  ;
END;
END IF;

 EXECUTE IMMEDIATE 'TRUNCATE TABLE GTT_ACENT';
 INSERT INTO GTT_ACENT 
 (
  SELECT CustomerAcId,(V_AccountEntityId + ROW_NUMBER() OVER(ORDER BY (AccountEntityId)))  
   FROM RBL_TEMPDB.TempAdvAcBasicDetail  
   WHERE AccountEntityId=0 OR AccountEntityId IS NULL  
);


MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail TEMP  
USING (SELECT TEMP.ROWID ROW_ID,ACCT.AccountEntityId
 FROM RBL_TEMPDB.TempAdvAcBasicDetail TEMP  
INNER JOIN GTT_ACENT ACCT ON TEMP.CustomerAcId=ACCT.CustomerAcId 
)SRC
ON (TEMP.AccountEntityId=SRC.AccountEntityId)
WHEN MATCHED THEN UPDATE SET TEMP.AccountEntityId=SRC.AccountEntityId  
;


/*********************************************************************************************************/  

 ---------------------------------------------Added by Prashant-----FITL Issue Given By Ashish Sir----01092022--------------------------------------- 

MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
USING(SELECT A.ROWID ROW_ID
FROM        RBL_TEMPDB.TempAdvAcBasicDetail A 
INNER JOIN  CURDAT_RBL_MISDB_PROD.AdvAcRestructureDetail B
ON          A.AccountEntityId=B.AccountEntityId
AND         B.EffectiveToTimeKey=49999
WHERE       B.RestructureFacilityTypeAlt_Key=3
)SRC
ON (A.ROWID=SRC.ROW_ID)
WHEN MATCHED THEN UPDATE SET A.FlgSecured='U'
;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
