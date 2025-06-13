--------------------------------------------------------
--  DDL for Procedure ADVACBASICDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   -------------------------------
   /*  New Customers Ac Key ID Update  */
   v_Ac_Key NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.AdvAcBasicDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.AccountEntityId = A.AccountEntityId
                                 AND A.SourceAlt_Key = B.SourceAlt_Key )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';
   MERGE INTO RBL_MISDB_PROD.AdvAcBasicDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvAcBasicDetail O
          JOIN RBL_TEMPDB.TempAdvAcBasicDetail T   ON O.AccountEntityID = T.AccountEntityID
          AND O.SourceAlt_Key = T.SourceAlt_Key
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.BranchCode, 0) <> NVL(T.BranchCode, 0)
     OR NVL(O.GLAlt_Key, 0) <> NVL(T.GLAlt_Key, 0)
     OR NVL(O.ProductAlt_Key, 0) <> NVL(T.ProductAlt_Key, 0)
     OR NVL(O.GLProductAlt_Key, 0) <> NVL(T.GLProductAlt_Key, 0)
     OR NVL(O.FacilityType, 0) <> NVL(T.FacilityType, 0)
     OR NVL(O.SubSectorAlt_Key, 0) <> NVL(T.SubSectorAlt_Key, 0)
     OR NVL(O.ActivityAlt_Key, 0) <> NVL(T.ActivityAlt_Key, 0)
     OR NVL(O.IndustryAlt_Key, 0) <> NVL(T.IndustryAlt_Key, 0)
     OR NVL(O.SchemeAlt_Key, 0) <> NVL(T.SchemeAlt_Key, 0)
     OR NVL(O.DistrictAlt_Key, 0) <> NVL(T.DistrictAlt_Key, 0)
     OR NVL(O.AreaAlt_Key, 0) <> NVL(T.AreaAlt_Key, 0)
     OR NVL(O.VillageAlt_Key, 0) <> NVL(T.VillageAlt_Key, 0)
     OR NVL(O.StateAlt_Key, 0) <> NVL(T.StateAlt_Key, 0)
     OR NVL(O.CurrencyAlt_Key, 0) <> NVL(T.CurrencyAlt_Key, 0)
     OR NVL(O.OriginalSanctionAuthAlt_Key, 0) <> NVL(T.OriginalSanctionAuthAlt_Key, 0)
     OR NVL(O.OriginalLimitRefNo, 0) <> NVL(T.OriginalLimitRefNo, 0)
     OR NVL(O.OriginalLimit, 0) <> NVL(T.OriginalLimit, 0)
     OR NVL(O.OriginalLimitDt, '1990-01-01') <> NVL(T.OriginalLimitDt, '1990-01-01')
     OR NVL(O.DtofFirstDisb, '1990-01-01') <> NVL(T.DtofFirstDisb, '1990-01-01')
     OR NVL(O.AdjDt, '1990-01-01') <> NVL(T.AdjDt, '1990-01-01')
     OR NVL(O.MarginType, 0) <> NVL(T.MarginType, 0)
     OR NVL(O.CurrentLimitRefNo, 0) <> NVL(T.CurrentLimitRefNo, 0)
     OR NVL(O.AccountName, 0) <> NVL(T.AccountName, 0)
     OR NVL(O.LastDisbDt, '1990-01-01') <> NVL(T.LastDisbDt, '1990-01-01')
     OR NVL(O.Ac_LADDt, '1990-01-01') <> NVL(T.Ac_LADDt, '1990-01-01')
     OR NVL(O.Ac_DocumentDt, '1990-01-01') <> NVL(T.Ac_DocumentDt, '1990-01-01')
     OR NVL(O.CurrentLimit, 0) <> NVL(T.CurrentLimit, 0)
     OR NVL(O.InttTypeAlt_Key, 0) <> NVL(T.InttTypeAlt_Key, 0)
     OR NVL(O.CurrentLimitDt, '1990-01-01') <> NVL(T.CurrentLimitDt, '1990-01-01')
     OR NVL(O.Ac_DueDt, '1990-01-01') <> NVL(T.Ac_DueDt, '1990-01-01')
     OR NVL(O.DrawingPowerAlt_Key, 0) <> NVL(T.DrawingPowerAlt_Key, 0)
     OR NVL(O.RefCustomerId, 'AA') <> NVL(T.RefCustomerId, 'AA')
     OR NVL(O.FincaleBasedIndustryAlt_key, 0) <> NVL(T.FincaleBasedIndustryAlt_Key, 0)
     OR NVL(O.ISLAD, 0) <> NVL(T.ISLAD, 0)
     OR NVL(O.ISLAD, 0) <> NVL(T.ISLAD, 0)
     OR NVL(O.segmentcode, 0) <> NVL(T.segmentcode, 0)
     OR NVL(O.ReferencePeriod, 0) <> NVL(T.ReferencePeriod, 0)
     OR NVL(O.FlgSecured, 0) <> NVL(T.FlgSecured, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   --OR ISNULL(O.CustomerACID,'AA') <> ISNULL(T.CustomerACID,'AA')
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempAdvAcBasicDetail A
          JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON B.AccountEntityId = A.AccountEntityId
          AND A.SourceAlt_Key = B.SourceAlt_Key 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.AdvAcBasicDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.AdvAcBasicDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempAdvAcBasicDetail BB
                       WHERE  AA.AccountEntityID = BB.AccountEntityID
                                AND AA.SourceAlt_Key = BB.SourceAlt_Key
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(Ac_Key)  

     INTO v_Ac_Key
     FROM RBL_MISDB_PROD.AdvAcBasicDetail ;
   IF v_Ac_Key IS NULL THEN

   BEGIN
      v_Ac_Key := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.Ac_Key
   FROM RBL_TEMPDB.TempAdvAcBasicDetail TEMP
          JOIN ( SELECT "TEMPADVACBASICDETAIL".CustomerAcId ,
                        (v_Ac_Key + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                     FROM DUAL  )  )) Ac_Key  
                 FROM RBL_TEMPDB.TempAdvAcBasicDetail 
                  WHERE  "TEMPADVACBASICDETAIL".Ac_Key = 0
                           OR "TEMPADVACBASICDETAIL".Ac_Key IS NULL ) ACCT   ON TEMP.CustomerAcId = ACCT.CustomerAcId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.Ac_Key = src.Ac_Key;
   /***************************************************************************************************************/
   /***************************************************************************************************************/
   INSERT INTO RBL_MISDB_PROD.AdvAcBasicDetail
     ( Ac_Key, BranchCode, AccountEntityId, CustomerEntityId, SystemACID, CustomerACID, GLAlt_Key, ProductAlt_Key, GLProductAlt_Key, FacilityType, SectorAlt_Key, SubSectorAlt_Key, ActivityAlt_Key, IndustryAlt_Key, SchemeAlt_Key, DistrictAlt_Key, AreaAlt_Key, VillageAlt_Key, StateAlt_Key, CurrencyAlt_Key, OriginalSanctionAuthAlt_Key, OriginalLimitRefNo, OriginalLimit, OriginalLimitDt, DtofFirstDisb, FlagReliefWavier, UnderLineActivityAlt_Key, MicroCredit, segmentcode, ScrCrError, AdjDt, AdjReasonAlt_Key, MarginType, Pref_InttRate, CurrentLimitRefNo, GuaranteeCoverAlt_Key, AccountName, AssetClass, JointAccount, LastDisbDt, ScrCrErrorBackup, AccountOpenDate, Ac_LADDt, Ac_DocumentDt, CurrentLimit, InttTypeAlt_Key, InttRateLoadFactor, Margin, CurrentLimitDt, Ac_DueDt, DrawingPowerAlt_Key, RefCustomerId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocStatus, MocDate, MocTypeAlt_Key, IsLAD, FincaleBasedIndustryAlt_key, AcCategoryAlt_Key, OriginalSanctionAuthLevelAlt_Key, AcTypeAlt_Key, ScrCrErrorSeq, BSRUNID, AdditionalProv, AclattestDevelopment, SourceAlt_Key, LoanSeries, LoanRefNo, SecuritizationCode, Full_Disb, OriginalBranchcode, ProjectCost, FlgSecured, ReferencePeriod )
     ( SELECT Ac_Key ,
              BranchCode ,
              AccountEntityId ,
              CustomerEntityId ,
              SystemACID ,
              CustomerACID ,
              GLAlt_Key ,
              ProductAlt_Key ,
              GLProductAlt_Key ,
              FacilityType ,
              SectorAlt_Key ,
              SubSectorAlt_Key ,
              ActivityAlt_Key ,
              IndustryAlt_Key ,
              SchemeAlt_Key ,
              DistrictAlt_Key ,
              AreaAlt_Key ,
              VillageAlt_Key ,
              StateAlt_Key ,
              CurrencyAlt_Key ,
              OriginalSanctionAuthAlt_Key ,
              OriginalLimitRefNo ,
              OriginalLimit ,
              OriginalLimitDt ,
              DtofFirstDisb ,
              FlagReliefWavier ,
              UnderLineActivityAlt_Key ,
              MicroCredit ,
              segmentcode ,
              ScrCrError ,
              AdjDt ,
              AdjReasonAlt_Key ,
              MarginType ,
              Pref_InttRate ,
              CurrentLimitRefNo ,
              GuaranteeCoverAlt_Key ,
              AccountName ,
              AssetClass ,
              JointAccount ,
              LastDisbDt ,
              ScrCrErrorBackup ,
              AccountOpenDate ,
              Ac_LADDt ,
              Ac_DocumentDt ,
              CurrentLimit ,
              InttTypeAlt_Key ,
              InttRateLoadFactor ,
              Margin ,
              CurrentLimitDt ,
              Ac_DueDt ,
              DrawingPowerAlt_Key ,
              RefCustomerId ,
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
              IsLAD ,
              FincaleBasedIndustryAlt_key ,
              AcCategoryAlt_Key ,
              OriginalSanctionAuthLevelAlt_Key ,
              AcTypeAlt_Key ,
              ScrCrErrorSeq ,
              BSRUNID ,
              AdditionalProv ,
              AclattestDevelopment ,
              SourceAlt_Key ,
              LoanSeries ,
              LoanRefNo ,
              SecuritizationCode ,
              Full_Disb ,
              OriginalBranchcode ,
              ProjectCost ,
              FlgSecured ,
              ReferencePeriod 
       FROM RBL_TEMPDB.TempAdvAcBasicDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);

END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."ADVACBASICDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
