--------------------------------------------------------
--  DDL for Procedure PUI_OUTPUT_04112023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" 
AS
   --select * from  PUI_DATA_30112021
   v_Date VARCHAR2(200) := ( SELECT DATE_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );

BEGIN

   --PRINT @Date
   --PRINT @Timekey
   --IF OBJECT_ID('TEMPDB..#PUI_Report_Automate') IS NOT NULL
   --		DROP TABLE #PUI_Report_Automate
   EXECUTE IMMEDIATE ' TRUNCATE TABLE PUI_Report_Automate ';
   INSERT INTO PUI_Report_Automate
     ( SELECT b.UCIF_ID UCIC  ,
              C.CustomerId ,
              C.CustomerName ,
              B.CustomerAcID ,
              --,B.ProductCode
              B.BranchCode ,
              DB.BranchName ,
              DP.SchemeType ,
              B.ProductCode SchemeCode  ,
              DP.ProductName SchemeDescription  ,
              B.ActSegmentCode SegCode  ,
              DS.AcBuSegmentDescription SegmentDescription  ,
              --,aCl1.AssetClassShortName PrevAssetClass
              aCl2.AssetClassShortName CurrentAssetClass  ,
              pcr.ProjectCategoryDescription ProjectCategory  ,
              psc.ProjectCategorySubTypeDescription Project_Sub_Category  ,
              ow.ParameterName Projectownersip  ,
              auth.ParameterName ProjectAuthority  ,
              NVL(A.OriginalDCCO, PP.OriginalDCCO) OriginalDCCO  ,
              NVL(A.OriginalProjectCost, pp.OriginalProjectCost) OriginalProjectCost  ,
              --,a.CostOverRunPer
              A.CostOverrun ,
              NVL(A.OriginalDebt, pp.OriginalDebt) OriginalDebt  ,
              --,A.Debt_EquityRatio
              A.ChangeinProjectScope ,
              A.FreshOriginalDCCO ,
              A.RevisedDCCO ,
              --,A.InitialExtensiON
              --,A.BeyONCONtrolofPromoters
              --,A.CourtCaseArbitratiON
              --,a.ChangeinProjectScope
              A.CIOReferenceDate ,
              A.CIODCCO ,
              A.TakeOutFinance ,
              AcL3.AssetClassShortName AssetClassSellerBook  ,
              A.NPADateSellerBook ,
              --,A.Restructuring
              CASE 
                   WHEN RD.RestructureDt IS NULL THEN 'N'
              ELSE 'Y'
                 END Restructuring  ,
              --,A.DelayReasonOther
              --,A.FLG_UPG
              --,A.FLG_DEG
              --,A.DEFAULT_REASON
              --,A.ProjCategory
              A.NPA_DATE ,
              --,A.PUI_ProvPer
              --,A.RestructureDate
              RD.RestructureDt ,
              A.ActualDCCO ,
              A.ActualDCCO_Date ,
              --,A.UpgradeDate
              --,A.SecuredProvisiON  PUI_SecuredProvision
              --,a.UnSecuredProvisiON PUI_UnSecuredProvision
              --,A.FLG_DEG PUI_FlgDeg	
              --,A.FLG_UPG PUI_FlgUpg	
              --,SecuredAmt	
              --,UnSecuredAmt	
              --,BankTotalProvision	
              --,RBITotalProvision	
              --,isnull(A.SecuredProvision,0)+isnull(a.UnSecuredProvision,0) PUI_Provision	
              --,TotalProvision
              pps.RM_CreditOfficer ,
              A.DelayReasonChangeinOwnership ChangeinOwnership  ,
              CASE 
                   WHEN DSDB.SourceName = 'FIS' THEN 'FI'
                   WHEN DSDB.SourceName = 'VisiONPlus' THEN 'Credit Card'
              ELSE AcBuRevisedSegmentCode
                 END Business_Segment_Description  

       --INTO		#PUI_Report_Automate
       FROM AdvAcPUIDetailMain pp
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL b   ON pp.AccountEntityId = B.AccountEntityID
              LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL A   ON A.AccountEntityId = b.AccountEntityID
              LEFT JOIN AdvAcPUIDetailSub pps   ON pps.EffectiveFromTimeKey <= v_Timekey
              AND pps.EffectiveToTimeKey >= v_Timekey
              AND pps.AccountEntityId = pp.AccountEntityId
              JOIN CustomerBasicDetail c   ON c.CustomerEntityId = B.CustomerEntityID
              AND C.EffectiveFromTimeKey <= v_Timekey
              AND c.EffectiveToTimeKey >= v_Timekey
              JOIN DimAssetClass Acl1   ON Acl1.EffectiveFromTimeKey <= v_Timekey
              AND Acl1.EffectiveToTimeKey >= v_Timekey
              AND aCl1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              JOIN DimAssetClass Acl2   ON Acl2.EffectiveFromTimeKey <= v_Timekey
              AND Acl2.EffectiveToTimeKey >= v_Timekey
              AND aCl2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAssetClass Acl3   ON Acl3.EffectiveFromTimeKey <= v_Timekey
              AND Acl3.EffectiveToTimeKey >= v_Timekey
              AND aCl3.AssetClassAlt_Key = a.AssetClassSellerBookAlt_key
            --INNeR jOIN RBL_PUI_DATA aa
             --	ON b.CustomerAcID=aa.[Account ID]

              LEFT JOIN ProjectCategory pcr   ON pcr.EffectiveFromTimeKey <= v_Timekey
              AND pcr.EffectiveToTimeKey >= v_Timekey
              AND pcr.ProjectCategoryAltKey = pp.ProjectCategoryAlt_Key
              LEFT JOIN ProjectCategorySubType psc   ON psc.EffectiveFromTimeKey <= v_Timekey
              AND psc.EffectiveToTimeKey >= v_Timekey
              AND psc.ProjectCategorySubTypeAltKey = pp.ProjectSubCategoryAlt_key
              LEFT JOIN DimParameter OW   ON OW.EffectiveFromTimeKey <= v_Timekey
              AND OW.EffectiveToTimeKey >= v_Timekey
              AND ow.ParameterAlt_Key = pp.ProjectOwnerShipAlt_Key
              AND OW.DimParameterName = 'ProjectOwnership'
              LEFT JOIN DimParameter auth   ON auth.EffectiveFromTimeKey <= v_Timekey
              AND auth.EffectiveToTimeKey >= v_Timekey
              AND auth.ParameterAlt_Key = pp.ProjectAuthorityAlt_key
              AND auth.DimParameterName = 'ProjectAuthority'
              LEFT JOIN DimProduct DP   ON DP.EffectiveFromTimeKey <= v_Timekey
              AND DP.EffectiveToTimeKey >= v_Timekey
              AND DP.ProductCode = B.ProductCode
              LEFT JOIN DimBranch DB   ON DB.EffectiveFromTimeKey <= v_Timekey
              AND DB.EffectiveToTimeKey >= v_Timekey
              AND DB.BranchCode = B.BranchCode
              LEFT JOIN DimAcBuSegment DS   ON DS.EffectiveFromTimeKey <= v_Timekey
              AND DS.EffectiveToTimeKey >= v_Timekey
              AND DS.AcBuSegmentCode = B.ActSegmentCode
              LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail RD   ON RD.AccountEntityId = pp.AccountEntityId
              AND RD.EffectiveFromTimeKey <= v_Timekey
              AND RD.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DIMSOURCEDB DSDB   ON b.SourceAlt_Key = DSDB.SourceAlt_Key
              AND DSDB.EffectiveFromTimeKey <= v_Timekey
              AND DSDB.EffectiveToTimeKey >= v_Timekey
        WHERE  pp.EffectiveFromTimeKey <= v_Timekey
                 AND pp.EffectiveToTimeKey >= v_Timekey );--select * from #PUI_Report_Automate

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_04112023" TO "ADF_CDR_RBL_STGDB";
