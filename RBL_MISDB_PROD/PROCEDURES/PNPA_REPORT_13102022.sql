--------------------------------------------------------
--  DDL for Procedure PNPA_REPORT_13102022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PNPA_REPORT_13102022" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_cursor SYS_REFCURSOR;

BEGIN

   IF ( utils.object_id('TEMPDB..tt_UCIF_7') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UCIF_7 ';
   END IF;
   DELETE FROM tt_UCIF_7;
   UTILS.IDENTITY_RESET('tt_UCIF_7');

   INSERT INTO tt_UCIF_7 ( 
   	SELECT DISTINCT UCIF_ID ,
                    UcifEntityID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  FlgPNPA = 'Y'
              AND ProductCode IN ( 'CLIBA','HLIBA','PLIBA','VLIBA','HLCTC','PLCTC','VLCTC','RFLPL','PLSPL','ELHRP','PLODS','PLSOD' )
    );
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
             UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             B.CustomerAcID ,
             b.FacilityType ,
             b.ProductCode ,
             ProductName ,
             Balance ,
             DrawingPower ,
             B.CurrentLimit ,
             ReviewDueDt ,
             b.ContiExcessDt ,
             StockStDt ,
             DebitSinceDt ,
             LastCrDate ,
             CurQtrCredit ,
             CurQtrInt ,
             OverdueAmt ,
             OverDueSinceDt ,
             PrincOutStd ,
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
             PNPA_DATE ,
             a2.AssetClassShortNameEnum PNPA_AssetClass  ,
             REPLACE(PNPA_Reason, ',', ' ') PNPA_Reason  ,
             a.Asset_Norm ,
             b.CD ,
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
             ReferencePeriod AssetClassNorm  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.UcifEntityID = B.UcifEntityID
               JOIN tt_UCIF_7 AB   ON b.UcifEntityID = ab.UcifEntityID
               LEFT JOIN AdvAcBasicDetail Bas   ON B.AccountEntityID = Bas.AccountEntityId
               AND Bas.EffectiveToTimeKey = 49999
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.PnpaAssetClassAlt_key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--WHERE B.FlgPNPA ='Y'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_REPORT_13102022" TO "ADF_CDR_RBL_STGDB";
