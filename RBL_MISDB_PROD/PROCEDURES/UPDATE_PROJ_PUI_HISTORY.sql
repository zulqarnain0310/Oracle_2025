--------------------------------------------------------
--  DDL for Procedure UPDATE_PROJ_PUI_HISTORY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" 
--Exec Update_proj_PUI_SearchList @OperationFlag=1

(
  --Declare
  v_AccountID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   OPEN  v_cursor FOR
      SELECT A.CustomerID ,
             A.AccountID ,
             A.ChangeinProjectScope ,
             --,A.ChangeinProjectScopeDESC
             A.FreshOriginalDCCO ,
             A.RevisedDCCO ,
             A.CourtCaseArbitration ,
             -- ,A.CourtCaseArbitrationDESC
             A.ChangeinOwnerShip ,
             -- ,A.ChangeinOwnerShipDESC
             A.CIOReferenceDate ,
             A.CIODCCO ,
             -- ,A.CostOverRunDESC
             A.CostOverRun ,
             A.RevisedProjectCost ,
             A.RevisedDebt ,
             A.RevisedDebt_EquityRatio ,
             A.TakeOutFinance ,
             -- ,A.TakeOutFinanceDESC
             A.AssetClassSellerBook ,
             A.AssetClassSellerBookAlt_key ,
             A.NPADtClsSellBook ,
             A.Restructuring ,
             --,A.RestructuringDESC
             A.AuthorisationStatus ,
             A.EffectiveFromTimeKey ,
             A.EffectiveToTimeKey ,
             A.CreatedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,200) DateCreated  ,
             A.ApprovedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,200) DateApproved  ,
             A.ModifiedBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,200) DateModified  ,
             A.CrModBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.CrModDate,200) CrModDate  ,
             A.CrAppBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.CrAppDate,200) CrAppDate  ,
             A.ModAppBy ,
             UTILS.CONVERT_TO_VARCHAR2(A.ModAppDate,200) ModAppDate  ,
             A.InitialExtenstion ,
             A.ExtnReason_BCP ,
             UTILS.CONVERT_TO_VARCHAR2(A.Npa_date,200) Npa_date  ,
             A.Npa_Reason ,
             A.AssetClassAlt_Key ,
             A.FirstLevelApprovedBy ,
             A.DateApprovedFirstLevel ,
             A.ActualDCCO_Achieved ,
             A.ActualDCCO_Date 
        FROM ( SELECT A.CustomerID ,
                      A.AccountID ,
                      A.ChangeinProjectScope ,
                      -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                      UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                      A.CourtCaseArbitration ,
                      -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                      A.ChangeinOwnerShip ,
                      --  ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                      UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                      -- ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                      A.CostOverRun ,
                      A.RevisedProjectCost ,
                      A.RevisedDebt ,
                      A.RevisedDebt_EquityRatio ,
                      A.TakeOutFinance ,
                      -- ,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
                      CASE 
                           WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                           WHEN A.AssetClassSellerBookAlt_key IS NULL THEN ' '
                      ELSE 'NPA'
                         END AssetClassSellerBook  ,
                      A.AssetClassSellerBookAlt_key ,
                      CASE 
                           WHEN UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) IN ( '01/01/1900',' ' )
                            THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103)
                         END NPADtClsSellBook  ,
                      NVL(C.Restructuring, 'N') Restructuring  ,
                      --,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC
                      NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      A.FirstLevelApprovedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.FirstLevelDateApproved,20,p_style=>103) DateApprovedFirstLevel  ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      A.InitialExtenstion ,
                      --,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
                      A.ExtnReason_BCP ,
                      UTILS.CONVERT_TO_VARCHAR2(C.NPA_DATE,10,p_style=>103) Npa_date  ,
                      C.DEFAULT_REASON Npa_Reason  ,
                      C.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                      A.ActualDCCO_Achieved ,
                      UTILS.CONVERT_TO_VARCHAR2(A.ActualDCCO_Date,10,p_style=>103) ActualDCCO_Date  
               FROM AdvAcPUIDetailSub A
                      JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountID = B.CustomerACID
                      AND B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL C   ON B.AccountEntityId = C.AccountEntityId
                      AND C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey
                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                         AND AccountID = v_AccountID
                         AND NVL(A.AuthorisationStatus, 'A') = 'A'
               UNION 
               SELECT A.CustomerID ,
                      A.AccountID ,
                      A.ChangeinProjectScope ,
                      -- ,case when A.ChangeinProjectScope=1 THEN 'Y' ELSE 'N' END AS ChangeinProjectScopeDESC
                      --,A.FreshOriginalDCCO
                      UTILS.CONVERT_TO_VARCHAR2(A.FreshOriginalDCCO,10,p_style=>103) FreshOriginalDCCO  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RevisedDCCO,10,p_style=>103) RevisedDCCO  ,
                      A.CourtCaseArbitration ,
                      -- ,case when A.CourtCaseArbitration=1 THEN 'Y' ELSE 'N' END AS CourtCaseArbitrationDESC
                      A.ChangeinOwnerShip ,
                      -- ,case when A.ChangeinOwnerShip=1 THEN 'Y' ELSE 'N' END AS ChangeinOwnerShipDESC
                      UTILS.CONVERT_TO_VARCHAR2(A.CIOReferenceDate,10,p_style=>103) CIOReferenceDate  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.CIODCCO,10,p_style=>103) CIODCCO  ,
                      --  ,case when A.CostOverRun=1 THEN 'Y' ELSE 'N' END AS CostOverRunDESC
                      A.CostOverRun ,
                      A.RevisedProjectCost ,
                      A.RevisedDebt ,
                      A.RevisedDebt_EquityRatio ,
                      A.TakeOutFinance ,
                      --,case when A.TakeOutFinance=1 THEN 'Y' ELSE 'N' END AS TakeOutFinanceDESC
                      CASE 
                           WHEN A.AssetClassSellerBookAlt_key = 1 THEN 'STD'
                           WHEN A.AssetClassSellerBookAlt_key IS NULL THEN ' '
                      ELSE 'NPA'
                         END AssetClassSellerBook  ,
                      A.AssetClassSellerBookAlt_key ,
                      --,convert(varchar(10),A.NPADateSellerBook ,103) NPADateSellerBook 
                      CASE 
                           WHEN UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103) IN ( '01/01/1900',' ' )
                            THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(A.NPADateSellerBook,10,p_style=>103)
                         END NPADtClsSellBook  ,
                      NVL(C.Restructuring, 'N') Restructuring  ,
                      --,case when C.Restructuring=1 THEN 'Y' ELSE 'N' END AS RestructuringDESC,
                      NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      A.FirstLevelApprovedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.FirstLevelDateApproved,20,p_style=>103) DateApprovedFirstLevel  ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      A.InitialExtenstion ,
                      --,CASE WHEN A.InitialExtenstion=NULL THEN 'No' else A.InitialExtenstion end InitialExtenstion
                      A.ExtnReason_BCP ,
                      UTILS.CONVERT_TO_VARCHAR2(C.NPA_DATE,10,p_style=>103) Npa_date  ,
                      C.DEFAULT_REASON Npa_Reason  ,
                      C.FinalAssetClassAlt_Key AssetClassAlt_Key  ,
                      A.ActualDCCO_Achieved ,
                      UTILS.CONVERT_TO_VARCHAR2(A.ActualDCCO_Date,10,p_style=>103) ActualDCCO_Date  
               FROM AdvAcPUIDetailSub_mod A
                      JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountID = B.CustomerACID
                      AND B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN PRO_RBL_MISDB_PROD.PUI_CAL C   ON B.AccountEntityId = C.AccountEntityId
                      AND C.EffectiveFromTimeKey <= v_TimeKey
                      AND C.EffectiveToTimeKey >= v_TimeKey
                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                         AND AccountID = v_AccountID

                         -- AND ISNULL(a.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A','FM')
                         AND NVL(a.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
              ) 
             --AND A.EntityKey IN

             --(

             --    SELECT MAX(EntityKey)

             --    FROM AdvAcPUIDetailSub_Mod

             --    WHERE EffectiveFromTimeKey <= @TimeKey

             --          AND EffectiveToTimeKey >= @TimeKey

             --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')

             --    GROUP BY EntityKey

             --)
             A
        GROUP BY A.CustomerID,A.AccountID,A.ChangeinProjectScope
                 -- ,A.ChangeinProjectScopeDESC
                 ,A.FreshOriginalDCCO,A.RevisedDCCO,A.CourtCaseArbitration
                 -- ,A.CourtCaseArbitrationDESC
                 ,A.ChangeinOwnerShip
                 -- ,A.ChangeinOwnerShipDESC
                 ,A.CIOReferenceDate,A.CIODCCO
                 -- ,A.CostOverRunDESC
                 ,A.CostOverRun,A.RevisedProjectCost,A.RevisedDebt,A.RevisedDebt_EquityRatio,A.TakeOutFinance
                 -- ,A.TakeOutFinanceDESC
                 ,A.AssetClassSellerBook,A.AssetClassSellerBookAlt_key,A.NPADtClsSellBook,A.Restructuring
                 --,A.RestructuringDESC,
                 ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.InitialExtenstion,A.ExtnReason_BCP,A.Npa_date,A.Npa_Reason,A.AssetClassAlt_Key,A.FirstLevelApprovedBy,A.DateApprovedFirstLevel,A.ActualDCCO_Achieved,A.ActualDCCO_Date
        ORDER BY a.DateCreated DESC,
                 a.DateModified DESC,
                 a.CrModDate DESC,
                 a.DateApproved DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATE_PROJ_PUI_HISTORY" TO "ADF_CDR_RBL_STGDB";
