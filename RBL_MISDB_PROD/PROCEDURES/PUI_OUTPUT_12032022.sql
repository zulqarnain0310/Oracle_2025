--------------------------------------------------------
--  DDL for Procedure PUI_OUTPUT_12032022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" 
AS
   --select * from  PUI_DATA_30112021
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT b.UCIF_ID UCIC  ,
             C.CustomerId ,
             C.CustomerName ,
             B.CustomerAcID ,
             B.ProductCode ,
             aCl1.AssetClassShortName PrevAssetClass  ,
             aCl2.AssetClassShortName CurrentAssetClass  ,
             pc.ProjectCategoryDescription ProjectCategory  ,
             psc.ProjectCategorySubTypeDescription Project_Sub_Category  ,
             ow.ParameterName Projectownersip  ,
             auth.ParameterName ProjectAuthority  ,
             A.OriginalDCCO ,
             A.OriginalProjectCost ,
             A.CostOverRunPer ,
             A.CostOverrun ,
             A.OriginalDebt ,
             A.Debt_EquityRatio ,
             A.ChangeinProjectScope ,
             A.FreshOriginalDCCO ,
             A.RevisedDCCO ,
             A.InitialExtension ,
             A.BeyonControlofPromoters ,
             A.CourtCaseArbitration ,
             A.ChangeinProjectScope ,
             A.CIOReferenceDate ,
             A.CIODCCO ,
             A.TakeOutFinance ,
             AcL3.AssetClassShortName AssetClassSellerBook  ,
             A.NPADateSellerBook ,
             A.Restructuring ,
             A.DelayReasonOther ,
             A.FLG_UPG ,
             A.FLG_DEG ,
             A.DEFAULT_REASON ,
             A.ProjCategory ,
             A.NPA_DATE ,
             A.PUI_ProvPer ,
             A.RestructureDate ,
             A.ActualDCCO ,
             A.ActualDCCO_Date ,
             A.UpgradeDate ,
             A.SecuredProvision PUI_SecuredProvision  ,
             A.UnSecuredProvision PUI_UnSecuredProvision  ,
             A.FLG_DEG PUI_FlgDeg  ,
             A.FLG_UPG PUI_FlgUpg  ,
             SecuredAmt ,
             UnSecuredAmt ,
             BankTotalProvision ,
             RBITotalProvision ,
             NVL(A.SecuredProvision, 0) + NVL(A.UnSecuredProvision, 0) PUI_Provision  ,
             TotalProvision ,
             pps.RM_CreditOfficer 
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
             --INNeR jOIN RBL_PUI_DATA aa
              --	ON b.CustomerAcID=aa.[Account ID]

               LEFT JOIN ProjectCategory pc   ON pc.EffectiveToTimeKey = 49999
               AND pc.ProjectCategoryAltKey = pp.ProjectCategoryAlt_Key
               LEFT JOIN ProjectCategorySubType psc   ON psc.EffectiveToTimeKey = 49999
               AND psc.ProjectCategorySubTypeAltKey = pp.ProjectSubCategoryAlt_key
               LEFT JOIN DimParameter OW   ON OW.EffectiveToTimeKey = 49999
               AND ow.ParameterAlt_Key = pp.ProjectOwnerShipAlt_Key
               AND OW.DimParameterName = 'ProjectOwnership'
               LEFT JOIN DimParameter auth   ON OW.EffectiveToTimeKey = 49999
               AND ow.ParameterAlt_Key = pp.ProjectAuthorityAlt_key
               AND OW.DimParameterName = 'ProjectAuthority' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--order by b.FinalAssetClassAlt_Key

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_OUTPUT_12032022" TO "ADF_CDR_RBL_STGDB";
