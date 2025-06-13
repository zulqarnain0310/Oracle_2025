--------------------------------------------------------
--  DDL for Procedure PNPA_OUTPUT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PNPA_OUTPUT" 
AS
   v_date VARCHAR2(200) := ( SELECT date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
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
             B.PNPA_DATE ,
             A1.AssetClassShortNameEnum PNPA_AssetClass  ,
             B.PNPA_Reason ,
             b.FlgPNPA ,
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
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'

                  --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                  WHEN SourceName = 'VisionPlus'
                    AND B.ProductCode IN ( '777','780' )
                   THEN 'Retail'
                  WHEN SourceName = 'VisionPlus'
                    AND B.ProductCode NOT IN ( '777','780' )
                   THEN 'Credit Card'
             ELSE S.AcBuRevisedSegmentCode
                END AcBuRevisedSegmentCode  

        ----SELECT ActSegmentCode,* FROM PRO.ACCOUNTCAL

        --into #data

        --SELECT COUNT(1)
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = A.PNPA_Class_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
       WHERE  B.FlgPNPA = 'Y' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_OUTPUT" TO "ADF_CDR_RBL_STGDB";
