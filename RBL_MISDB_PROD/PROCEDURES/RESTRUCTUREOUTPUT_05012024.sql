--------------------------------------------------------
--  DDL for Procedure RESTRUCTUREOUTPUT_05012024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" 
--USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[RestructureOutput]    Script Date: 6/6/2022 5:12:40 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

AS
   v_timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  eXT_FLG = 'y' );
   v_dATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_timekey );
   ----------------------------------------------------------------------------------------------------------------------------------------
   v_cursor SYS_REFCURSOR;

BEGIN

   ------------------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_UcifEntityID_9') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UcifEntityID_9 ';
   END IF;
   DELETE FROM tt_UcifEntityID_9;
   UTILS.IDENTITY_RESET('tt_UcifEntityID_9');

   INSERT INTO tt_UcifEntityID_9 ( 
   	SELECT DISTINCT UcifEntityID 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
             JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal_Hist b   ON a.AccountEntityID = b.AccountEntityId
   	 WHERE  a.EffectiveFromTimeKey <= v_timekey
              AND a.EffectiveToTimeKey >= v_timekey
              AND b.EffectiveFromTimeKey <= v_timekey
              AND b.EffectiveToTimeKey >= v_timekey );
   IF utils.object_id('TEMPDB..tt_AccountEntityId_5') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountEntityId_5 ';
   END IF;
   DELETE FROM tt_AccountEntityId_5;
   UTILS.IDENTITY_RESET('tt_AccountEntityId_5');

   INSERT INTO tt_AccountEntityId_5 ( 
   	SELECT DISTINCT AccountEntityId 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
             JOIN tt_UcifEntityID_9 b   ON a.UcifEntityID = b.UcifEntityID
   	 WHERE  a.EffectiveFromTimeKey <= v_timekey
              AND a.EffectiveToTimeKey >= v_timekey );
   ------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_UcifRestructure_5') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UcifRestructure_5 ';
   END IF;
   DELETE FROM tt_UcifRestructure_5;
   UTILS.IDENTITY_RESET('tt_UcifRestructure_5');

   INSERT INTO tt_UcifRestructure_5 SELECT a.RefCustomerID CustomerID  ,
                                           a.CustomerAcID ,
                                           rt.ParameterName TypeOfRestructure  ,
                                           cc.ParameterName Covid_Category  ,
                                           b.RestructureDt ,
                                           pr.AssetClassShortName Pre_Restr_AssetClass  ,
                                           b.PreRestructureNPA_Prov ,
                                           c.PreRestructureNPA_Date ,
                                           ----,ins.AssetClassShortName Previous_AssetClass
                                           --,InitialNpaDt
                                           AcL.AssetClassShortName Current_AssetClass  ,
                                           a.FinalNpaDt CurrentNPA_Date  ,
                                           a.DPD_Max ,
                                           B.DPD_Breach_Date ,
                                           B.ZeroDPD_Date ExtendedExpirePeriod_StartDAte  ,
                                           Res_POS_to_CurrentPOS_Per ,
                                           B.POS_10PerPaidDate ,
                                           b.RestructureStage ,
                                           Ai.AssetClassShortName AssetClass_On_Iinvocation  ,
                                           B.ProvPerOnRestrucure ,
                                           NetBalance ,
                                           b.RestructurePOS ,
                                           B.CurrentPOS ,
                                           a.Balance ,
                                           C.PrincRepayStartDate ,
                                           c.InttRepayStartDate ,
                                           SP_ExpiryDate ,
                                           B.SP_ExpiryExtendedDate ,
                                           b.AddlProvPer RestrProvPer  ,
                                           ProvReleasePer ,
                                           AppliedNormalProvPer ,
                                           FinalProvPer ,
                                           b.PreDegProvPer ,
                                           b.UpgradeDate ,
                                           b.SurvPeriodEndDate ,
                                           DegDurSP_PeriodProvPer ,
                                           RestructureProvision ,
                                           b.SecuredProvision RESTR_SecuredProvision  ,
                                           B.UnSecuredProvision RESTR_UnSecuredProvision  ,
                                           b.FlgDeg RESTR_FlgDeg  ,
                                           b.FlgUpg RESTR_FlgUpg  ,
                                           SecuredAmt ,
                                           UnSecuredAmt ,
                                           BankTotalProvision ,
                                           RBITotalProvision ,
                                           TotalProvision ,
                                           --,cast(case when isnull(cc.Parametershortnameenum,'')='MSME_OLD'
                                           --	then ISNULL(TotalProvision,0)*100/(case when isnull(CurrentPos,0)=0 then 1 else isnull(CurrentPos,0) end)
                                           --	  else   ISNULL(TotalProvision,0)*100/(case when isnull(NetBalance,0)=0 then 1 else isnull(NetBalance,0) end )
                                           --   end  as decimal(5,2))  AppliedProvPer
                                           CASE 
                                                WHEN (NVL(AppliedNormalProvPer, 0) + NVL(FinalProvPer, 0)) > 100 THEN 100
                                           ELSE (NVL(AppliedNormalProvPer, 0) + NVL(FinalProvPer, 0))
                                              END AppliedProvPer  ,
                                           ( SELECT DATE_ 
                                             FROM Automate_Advances 
                                            WHERE  Timekey = v_timekey ) CreatedDate  ,
                                           Asset_Norm ,
                                           SUBSTR(NPA_Reason, 0, 200) NPA_Reason  ,
                                           SUBSTR(a.DegReason, 0, 200) DegReason  ,
                                           a.UCIF_ID UCIC  ,
                                           A.AcOpenDt ,
                                           --,RF.ParameterName RestructureFacility
                                           CASE 
                                                WHEN RF.ParameterName IS NULL THEN 'Linked Account'
                                           ELSE RF.ParameterName
                                              END RestructureFacility  ,
                                           B.FlgMorat ,
                                           B.DPD_MAXFIN ,
                                           B.DPD_MAXNONFIN ,
                                           a.DPD_Overdrawn ,
                                           a.FacilityType ,
                                           A.BranchCode ,
                                           DB.BranchName ,
                                           DP.SchemeType ,
                                           A.ProductCode SchemeCode  ,
                                           DP.ProductName SchemeDescription  ,
                                           A.ActSegmentCode SegCode  ,
                                           DS.AcBuSegmentDescription SegmentDescription  ,
                                           c.InvocationDate ,
                                           c.ConversionDate ,
                                           c.ApprovingAuthAlt_Key RestructureApprovingAuthority  ,
                                           c.CRILIC_Fst_DefaultDate ,
                                           c.FstDefaultReportingBank ,
                                           c.ICA_SignDate ,
                                           M.ParameterName BankingRelation  ,
                                           c.InvestmentGrade ,
                                           dsdb.SourceName ,
                                           c.RestructureAmt ,
                                           CASE 
                                                WHEN DSDB.SourceName = 'FIS' THEN 'FI'
                                                WHEN DSDB.SourceName = 'VisionPlus' THEN 'Credit Card'
                                           ELSE AcBuRevisedSegmentCode
                                              END Account_Segment_Description  ,
                                           CustomerName BorrowerName  ,
                                           c.DateCreated 

        ---SELECT A.FinalAssetClassAlt_Key,A.InitialAssetClassAlt_Key,ACL.AssetClassShortName
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
               JOIN tt_AccountEntityId_5 AE   ON a.AccountEntityID = AE.AccountEntityID
               LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal b   ON a.AccountEntityID = b.AccountEntityId
             ----	AND A.AccountEntityID =2254734

               LEFT JOIN DimProduct pp   ON pp.ProductAlt_Key = a.ProductAlt_Key
               AND pp.EffectiveToTimeKey = 49999
               LEFT JOIN ADVACRESTRUCTUREDETAIL c   ON c.AccountEntityId = a.AccountEntityID
               AND c.EffectiveFromTimeKey <= v_timekey
               AND c.EffectiveToTimeKey >= v_timekey
               LEFT JOIN DimParameter RF   ON RF.EffectiveToTimeKey = 49999
               AND RF.ParameterAlt_Key = c.RestructureFacilityTypeAlt_Key
               AND rF.DimParameterName = 'RestructureFacility'
               LEFT JOIN DimParameter rT   ON rT.EffectiveToTimeKey = 49999
               AND Rt.ParameterAlt_Key = c.RestructureTypeAlt_Key
               AND rt.DimParameterName = 'TypeofRestructuring'
               LEFT JOIN DimParameter cc   ON cc.EffectiveToTimeKey = 49999
               AND cc.ParameterAlt_Key = c.COVID_OTR_CatgAlt_Key
               AND cc.DimParameterName = 'Covid - OTR Category'
               LEFT JOIN DimAssetClass AI   ON ai.EffectiveToTimeKey = 49999
               AND ai.AssetClassAlt_Key = c.AssetClassAlt_KeyOnInvocation
               LEFT JOIN DimAssetClass pr   ON pr.EffectiveToTimeKey = 49999
               AND pr.AssetClassAlt_Key = c.PreRestructureAssetClassAlt_Key
               LEFT JOIN DimAssetClass acl   ON acL.EffectiveToTimeKey = 49999
               AND acl.AssetClassAlt_Key = a.FinalAssetClassAlt_Key
               LEFT JOIN DimAssetClass Ins   ON Ins.EffectiveToTimeKey = 49999
               AND Ins.AssetClassAlt_Key = a.InitialAssetClassAlt_Key
               LEFT JOIN DimProduct DP   ON DP.EffectiveToTimeKey = 49999
               AND DP.ProductCode = a.ProductCode
               LEFT JOIN DimBranch DB   ON DB.EffectiveToTimeKey = 49999
               AND DB.BranchCode = a.BranchCode
               LEFT JOIN DimAcBuSegment DS   ON DS.EffectiveToTimeKey = 49999
               AND DS.AcBuSegmentCode = a.ActSegmentCode
               LEFT JOIN DIMSOURCEDB DSDB   ON A.SourceAlt_Key = DSDB.SourceAlt_Key

               --AND DSDB.EffectiveToTimeKey =49999
               AND ( DSDB.EffectiveFromTimeKey <= v_timekey
               AND DSDB.EffectiveToTimeKey >= v_timekey
             ----inner join RBL_RESTR_dATA ss
              ----	ON ss.RefSystemAcId=a.CustomerACID
              )
               LEFT JOIN CustomerBasicDetail CB   ON a.CustomerEntityID = cb.CustomerEntityId
               AND cb.EffectiveFromTimeKey <= v_timekey
               AND cb.EffectiveToTimeKey >= v_timekey
               LEFT JOIN ( SELECT ParameterAlt_Key ,
                                  ParameterName ,
                                  'BankingRelationship' Tablename  
                           FROM DimParameter 
                            WHERE  DimParameterName = 'BankingRelationship'
                                     AND EffectiveFromTimeKey <= v_TimeKey
                                     AND EffectiveToTimeKey >= v_TimeKey ) M   ON M.ParameterAlt_Key = c.BankingRelationTypeAlt_Key
        ORDER BY 3,
                 4;
   ------------------------------------------------Percolation Code---------------------------------------------
   DELETE FROM tt_TempCust_6;
   UTILS.IDENTITY_RESET('tt_TempCust_6');

   INSERT INTO tt_TempCust_6 SELECT * 
        FROM ( SELECT CustomerID ,
                      TypeOfRestructure ,
                      RestructureDt ,
                      Pre_Restr_AssetClass ,
                      PreRestructureNPA_Date ,
                      ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY DateCreated DESC, RestructureDt DESC  ) RN  
               FROM tt_UcifRestructure_5 
                WHERE  TypeOfRestructure IS NOT NULL ) A
       WHERE  RN = 1;
   --select * from tt_TempCust_6 where  CustomerID='0217081063000247493'
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.TypeOfRestructure, b.RestructureDt, b.Pre_Restr_AssetClass, b.PreRestructureNPA_Date
   FROM A ,tt_UcifRestructure_5 a
          JOIN tt_TempCust_6 b   ON a.CustomerID = b.CustomerID 
    WHERE a.TypeOfRestructure IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.TypeOfRestructure = src.TypeOfRestructure,
                                a.RestructureDt = src.RestructureDt,
                                a.Pre_Restr_AssetClass = src.Pre_Restr_AssetClass,
                                a.PreRestructureNPA_Date = src.PreRestructureNPA_Date;
   --Update         a
   --set            a.TypeOfRestructure=b.TypeOfRestructure,a.RestructureDt=b.RestructureDt,a.Pre_Restr_AssetClass=b.Pre_Restr_AssetClass,
   --	           a.PreRestructureNPA_Date=b.PreRestructureNPA_Date
   --from           #tempewrt a
   --inner join    (select CustomerID,TypeOfRestructure,RestructureDt,Pre_Restr_AssetClass,PreRestructureNPA_Date from #tempewrt where TypeOfRestructure is not null)b
   --on            a.CustomerID=b.CustomerID
   --where         a.TypeOfRestructure is null
   ----where                a.CustomerID='0226011973500000473'
   DELETE FROM tt_TempUcic_5;
   UTILS.IDENTITY_RESET('tt_TempUcic_5');

   INSERT INTO tt_TempUcic_5 SELECT * 
        FROM ( SELECT UCIC ,
                      TypeOfRestructure ,
                      RestructureDt ,
                      Pre_Restr_AssetClass ,
                      PreRestructureNPA_Date ,
                      ROW_NUMBER() OVER ( PARTITION BY UCIC ORDER BY DateCreated DESC, RestructureDt DESC  ) RN  
               FROM tt_UcifRestructure_5 
                WHERE  TypeOfRestructure IS NOT NULL ) A
       WHERE  RN = 1;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.TypeOfRestructure, b.RestructureDt, b.Pre_Restr_AssetClass, b.PreRestructureNPA_Date
   FROM A ,tt_UcifRestructure_5 a
          JOIN tt_TempUcic_5 b   ON a.UCIC = b.UCIC 
    WHERE a.TypeOfRestructure IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.TypeOfRestructure = src.TypeOfRestructure,
                                a.RestructureDt = src.RestructureDt,
                                a.Pre_Restr_AssetClass = src.Pre_Restr_AssetClass,
                                a.PreRestructureNPA_Date = src.PreRestructureNPA_Date;
   ---------------------------------------------------------------------------------------------------------------------------------
   DELETE RestrOutput

    WHERE  UTILS.CONVERT_TO_VARCHAR2(createddate,200) = UTILS.CONVERT_TO_VARCHAR2(( SELECT DATE_ 
                                                                                    FROM Automate_Advances 
                                                                                     WHERE  eXT_FLG = 'y' ),200);
   INSERT INTO RestrOutput
     ( SELECT CustomerID ,
              CustomerAcID ,
              TypeOfRestructure ,
              Covid_Category ,
              RestructureDt ,
              Pre_Restr_AssetClass ,
              PreRestructureNPA_Prov ,
              PreRestructureNPA_Date ,
              Current_AssetClass ,
              CurrentNPA_Date ,
              DPD_Max ,
              DPD_Breach_Date ,
              ExtendedExpirePeriod_StartDAte ,
              Res_POS_to_CurrentPOS_Per ,
              POS_10PerPaidDate ,
              RestructureStage ,
              AssetClass_On_Iinvocation ,
              ProvPerOnRestrucure ,
              NetBalance ,
              RestructurePOS ,
              CurrentPOS ,
              Balance ,
              PrincRepayStartDate ,
              InttRepayStartDate ,
              SP_ExpiryDate ,
              SP_ExpiryExtendedDate ,
              RestrProvPer ,
              ProvReleasePer ,
              AppliedNormalProvPer ,
              FinalProvPer ,
              PreDegProvPer ,
              UpgradeDate ,
              SurvPeriodEndDate ,
              DegDurSP_PeriodProvPer ,
              RestructureProvision ,
              RESTR_SecuredProvision ,
              RESTR_UnSecuredProvision ,
              RESTR_FlgDeg ,
              RESTR_FlgUpg ,
              SecuredAmt ,
              UnSecuredAmt ,
              BankTotalProvision ,
              RBITotalProvision ,
              TotalProvision ,
              AppliedProvPer ,
              CreatedDate ,
              Asset_Norm ,
              NPA_Reason ,
              DegReason ,
              UCIC ,
              AcOpenDt ,
              RestructureFacility ,
              FlgMorat ,
              DPD_MAXFIN ,
              DPD_MAXNONFIN ,
              DPD_Overdrawn ,
              FacilityType ,
              BranchCode ,
              BranchName ,
              SchemeType ,
              SchemeCode ,
              SchemeDescription ,
              SegCode ,
              SegmentDescription ,
              InvocationDate ,
              ConversionDate ,
              RestructureApprovingAuthority ,
              CRILIC_Fst_DefaultDate ,
              FstDefaultReportingBank ,
              ICA_SignDate ,
              BankingRelation ,
              InvestmentGrade ,
              SourceName ,
              RestructureAmt ,
              Account_Segment_Description ,
              BorrowerName 
       FROM tt_UcifRestructure_5  );
   OPEN  v_cursor FOR
      SELECT DISTINCT v_dATE Report_Date  ,
                      SourceSystemName ,
                      BranchCode ,
                      BranchName ,
                      UCIC ,
                      CustomerID ,
                      CustomerAcID ,
                      FacilityType ,
                      AcOpenDt ,
                      RestructureFacility ,
                      TypeOfRestructure ,
                      Covid_Category ,
                      SchemeCode ,
                      SchemeDescription ,
                      SchemeType ,
                      SegCode ,
                      SegmentDescription ,
                      --,FlgMorat
                      RestructureDt ,
                      Pre_Restr_AssetClass ,
                      --,PreRestructureNPA_Prov
                      PreRestructureNPA_Date ,
                      Current_AssetClass ,
                      CurrentNPA_Date ,
                      DPD_Max ,
                      DPD_MAXFIN ,
                      DPD_MAXNONFIN ,
                      DPD_Overdrawn ,
                      DPD_Breach_Date ,
                      ZeroDPD_Date ,
                      Res_POS_to_CurrentPOS_Per ,
                      --,RestructureStage
                      --,AssetClass_On_Iinvocation
                      --,ProvPerOnRestrucure
                      --,NetBalance
                      RestructurePOS ,
                      CurrentPOS ,
                      BALANCE Outstanding_Balance  ,
                      PrincRepayStartDate ,
                      InttRepayStartDate ,
                      SP_ExpiryDate ,
                      SP_ExpiryExtendedDate ,
                      --,PreDegProvPer
                      --,UpgradeDate
                      -------,SurvPeriodEndDate
                      --,DegDurSP_PeriodProvPer
                      --,RESTR_FlgDeg
                      --,RESTR_FlgUpg
                      NPA_Reason ,
                      --,DegReason
                      --,SecuredAmt
                      --,UnSecuredAmt
                      --,RestrProvPer
                      --,ProvReleasePer
                      --,AppliedNormalProvPer
                      --,FinalProvPer RestrFinalProvPer
                      --,RestructureProvision
                      --,RESTR_SecuredProvision
                      --,RESTR_UnSecuredProvision
                      --,BankTotalProvision
                      --,RBITotalProvision
                      --,TotalProvision
                      --,AppliedProvPer
                      --,CreatedDate
                      Asset_Norm ,
                      InvocationDate ,
                      ConversionDate ,
                      RestructureApprovingAuthority ,
                      CRILIC_Fst_DefaultDate ,
                      FstDefaultReportingBank ,
                      ICA_SignDate ,
                      BankingRelation ,
                      InvestmentGrade ,
                      RestructureAmt O_S_as_on_Date_of_Restructure  ,
                      AccountSegmentDescription ,
                      BorrowerName 
        FROM RestrOutput 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(createddate,200) = v_dATE ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTRUCTUREOUTPUT_05012024" TO "ADF_CDR_RBL_STGDB";
