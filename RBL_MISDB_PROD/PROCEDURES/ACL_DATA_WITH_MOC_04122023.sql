--------------------------------------------------------
--  DDL for Procedure ACL_DATA_WITH_MOC_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" CREATE PROC "dbo" . "ACL_DATA_WITH_MOC_04122023" AS DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
AS
   IF ACL_DATA_WITH_MOC_30092021  --SQLDEV: NOT RECOGNIZED
   v_Date --(select Date from Automate_Advances where Ext_flg = 'Y')
    VARCHAR2(200) := '2021-09-30';
   v_Timekey NUMBER(10,0) := 26206;-- (select Timekey from Automate_Advances where Ext_flg = 'Y')

BEGIN

   -----------------------------------------ACL PROCESSING---------------
   DELETE FROM ACL_DATA_WITH_MOC_30092021;
   UTILS.IDENTITY_RESET('ACL_DATA_WITH_MOC_30092021');

   INSERT INTO ACL_DATA_WITH_MOC_30092021 SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
                                                 UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
                                                 A.UCIF_ID UCIC  ,
                                                 A.RefCustomerID CustomerID  ,
                                                 CustomerName ,
                                                 B.Branchcode ,
                                                 CustomerAcid ,
                                                 b.Facilitytype ,
                                                 b.ProductCode ,
                                                 ProductName ,
                                                 Balance ,
                                                 DrawingPower ,
                                                 CurrentLimit ,
                                                 UnserviedInt UnAppliedIntt  ,
                                                 ReviewDueDt ,
                                                 CreditSinceDt ,
                                                 b.ContiExcessDt ,
                                                 StockStDt ,
                                                 DebitSinceDt ,
                                                 LastCrDate ,
                                                 PreQtrCredit ,
                                                 PrvQtrInt ,
                                                 CurQtrCredit ,
                                                 CurQtrInt ,
                                                 --IntNotServicedDt	
                                                 OverdueAmt ,
                                                 OverDueSinceDt ,
                                                 SecurityValue ,
                                                 NetBalance ,
                                                 PrincOutStd ,
                                                 ApprRV ,
                                                 SecuredAmt ,
                                                 UnSecuredAmt ,
                                                 Provsecured ,
                                                 ProvUnsecured ,
                                                 TotalProvision ,
                                                 RefPeriodOverdue ,
                                                 RefPeriodOverDrawn ,
                                                 RefPeriodNoCredit ,
                                                 RefPeriodIntService ,
                                                 RefPeriodStkStatement ,
                                                 RefPeriodReview ,
                                                 PrincOverdue ,
                                                 PrincOverdueSinceDt ,
                                                 IntOverdue ,
                                                 IntOverdueSinceDt ,
                                                 OtherOverdue ,
                                                 OtherOverdueSinceDt ,
                                                 --,DPD_IntService,	DPD_NoCredit,	
                                                 --DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	
                                                 --DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
                                                 --,DPD_OtherOverdueSince,DPD_Max	
                                                 InitialNpaDt ,
                                                 FinalNpaDt ,
                                                 InitialAssetClassAlt_Key ,
                                                 a1.AssetClassShortNameEnum InitialAssetClass  ,
                                                 FinalAssetClassAlt_Key ,
                                                 a2.AssetClassShortNameEnum FialAssetClass  ,
                                                 b.DegReason ,
                                                 b.FlgDeg ,
                                                 b.FlgUpg ,
                                                 NPA_Reason ,
                                                 FLGSECURED SecuredFlag  ,
                                                 A.Asset_Norm ,
                                                 b.CD ,
                                                 pd.NPANorms ,
                                                 b.WriteOffAmount ,
                                                 b.ActSegmentCode ,
                                                 ProductSubGroup ,
                                                 SourceName ,
                                                 ProductGroup ,
                                                 PD.SchemeType ,
                                                 CASE 
                                                      WHEN SourceName = 'Ganaseva' THEN 'FI'
                                                      WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
                                                 ELSE S.AcBuRevisedSegmentCode
                                                    END AcBuRevisedSegmentCode  ,
                                                 ----SELECT ActSegmentCode,* FROM PRO.ACCOUNTCAL
                                                 NVL(A.FlgMoc, b.FlgMoc) FlgMoc  ,
                                                 NVL(A.MOCReason, b.MOCReason) MOCReason  ,
                                                 NVL(A.MOC_Dt, b.MOC_Dt) MOC_Dt  ,
                                                 NVL(A.MOCTYPE, b.MOCTYPE) MOCTYPE  ,
                                                 CASE 
                                                      WHEN SecApp = 'S' THEN 'SECURED'
                                                 ELSE 'UNSECURED'
                                                    END SecuredUnsecured  
        FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
               JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
               AND a.EffectiveFromTimeKey = 26206
               AND b.EffectiveToTimeKey = 26206
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               AND SRC.EffectiveFromTimeKey <= v_Timekey
               AND SRC.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN DimProduct PD   ON PD.EffectiveFromTimeKey <= v_TimekeY
               AND PD.EffectiveToTimeKey >= v_Timekey
               AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               AND A1.EffectiveFromTimeKey <= v_Timekey
               AND A1.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               AND A2.EffectiveFromTimeKey <= v_Timekey
               AND A2.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveFromTimeKey <= v_Timekey
               AND S.EffectiveToTimeKey >= v_Timekey
       WHERE  B.FinalAssetClassAlt_Key > 1;--AND isnull(b.WriteOffAmount,0)=0	--	 where B.FlgUpg='U'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACL_DATA_WITH_MOC_04122023" TO "ADF_CDR_RBL_STGDB";
