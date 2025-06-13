--------------------------------------------------------
--  DDL for Procedure PUI_OUTPUT_24012023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --select * from  PUI_DATA_30112021
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
              pc.ProjectCategoryDescription ProjectCategory  ,
              psc.ProjectCategorySubTypeDescription Project_Sub_Category  ,
              ow.ParameterName Projectownersip  ,
              auth.ParameterName ProjectAuthority  ,
              A.OriginalDCCO ,
              A.OriginalProjectCost ,
              --,a.CostOverRunPer
              A.CostOverrun ,
              A.OriginalDebt ,
              --,A.Debt_EquityRatio
              A.ChangeinProjectScope ,
              A.FreshOriginalDCCO ,
              A.RevisedDCCO ,
              --,A.InitialExtension
              --,A.BeyonControlofPromoters
              --,A.CourtCaseArbitration
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
              --,A.SecuredProvision  PUI_SecuredProvision	
              --,a.UnSecuredProvision PUI_UnSecuredProvision	
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
                   WHEN DSDB.SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuRevisedSegmentCode
                 END Business_Segment_Description  
       FROM PRO_RBL_MISDB_PROD.PUI_CAL A
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL b   ON a.AccountEntityID = B.AccountEntityID
              JOIN AdvAcPUIDetailMain pp   ON pp.EffectiveToTimeKey = 49999
              AND pp.AccountEntityId = a.AccountEntityId
              JOIN AdvAcPUIDetailSub pps   ON pps.EffectiveToTimeKey = 49999
              AND pps.AccountEntityId = a.AccountEntityId
              JOIN CustomerBasicDetail c   ON c.CustomerEntityId = B.CustomerEntityID
              JOIN DimAssetClass Acl1   ON aCl1.EffectiveToTimeKey = 49999
              AND aCl1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              JOIN DimAssetClass Acl2   ON aCl2.EffectiveToTimeKey = 49999
              AND aCl2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAssetClass Acl3   ON aCl3.EffectiveToTimeKey = 49999
              AND aCl3.AssetClassAlt_Key = a.AssetClassSellerBookAlt_key
              LEFT JOIN ProjectCategory pc   ON pc.EffectiveToTimeKey = 49999
              AND pc.ProjectCategoryAltKey = pp.ProjectCategoryAlt_Key
              LEFT JOIN ProjectCategorySubType psc   ON psc.EffectiveToTimeKey = 49999
              AND psc.ProjectCategorySubTypeAltKey = pp.ProjectSubCategoryAlt_key
              LEFT JOIN DimParameter OW   ON OW.EffectiveToTimeKey = 49999
              AND ow.ParameterAlt_Key = pp.ProjectOwnerShipAlt_Key
              AND OW.DimParameterName = 'ProjectOwnership'
              LEFT JOIN DimParameter auth   ON auth.EffectiveToTimeKey = 49999
              AND auth.ParameterAlt_Key = pp.ProjectAuthorityAlt_key
              AND auth.DimParameterName = 'ProjectAuthority'
              LEFT JOIN DimProduct DP   ON DP.EffectiveToTimeKey = 49999
              AND DP.ProductCode = B.ProductCode
              LEFT JOIN DimBranch DB   ON DB.EffectiveToTimeKey = 49999
              AND DB.BranchCode = B.BranchCode
              LEFT JOIN DimAcBuSegment DS   ON DS.EffectiveToTimeKey = 49999
              AND DS.AcBuSegmentCode = B.ActSegmentCode
              LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail RD   ON RD.AccountEntityId = a.AccountEntityId
              AND RD.EffectiveToTimeKey = 49999
              LEFT JOIN DIMSOURCEDB DSDB   ON b.SourceAlt_Key = DSDB.SourceAlt_Key
              AND DSDB.EffectiveToTimeKey = 49999 );
   OPEN  v_cursor FOR
      SELECT * 
        FROM PUI_Report_Automate  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_24012023" TO "ADF_CDR_RBL_STGDB";
