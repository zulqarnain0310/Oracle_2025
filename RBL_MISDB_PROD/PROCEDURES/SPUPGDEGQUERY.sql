--------------------------------------------------------
--  DDL for Procedure SPUPGDEGQUERY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SPUPGDEGQUERY" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_Flg = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
             UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             CustomerAcid ,
             b.FacilityType ,
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
             DPD_IntService ,
             DPD_NoCredit ,
             DPD_Overdrawn ,
             DPD_Overdue ,
             DPD_Renewal ,
             DPD_StockStmt ,
             DPD_PrincOverdue ,
             DPD_IntOverdueSince ,
             DPD_OtherOverdueSince ,
             DPD_Max ,
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
             a.Asset_Norm ,
             b.CD ,
             pd.NPANorms ,
             b.WriteOffAmount ,
             b.ActSegmentCode ,
             ProductSubGroup ,
             SourceName ,
             ProductGroup ,
             PD.SchemeType ,
             S.AcBuRevisedSegmentCode 

        --into #data
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--	 where B.FinalAssetClassAlt_Key>1
   --	 where B.FlgUpg='U'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPUPGDEGQUERY" TO "ADF_CDR_RBL_STGDB";
