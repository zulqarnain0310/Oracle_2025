--------------------------------------------------------
--  DDL for Procedure RPT_028
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_028" 
(
  v_TimeKey IN NUMBER,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   --      @TimeKey AS INT=25992,
   --	  @Cost    AS FLOAT=1
   v_Date VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey );
   -------------------------------------Asset Classification
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT v_Date Process_date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             BranchName ,
             CustomerAcID ,
             SourceName ,
             B.FacilityType ,
             SchemeType ,
             B.ProductCode ,
             ProductName ,
             ActSegmentCode ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END AcBuSegmentDescription  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'

                  --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                  WHEN SourceName = 'VisionPlus'
                    AND B.ProductCode IN ( '777','780' )
                   THEN 'Retail'
                  WHEN SourceName = 'VisionPlus'
                    AND B.ProductCode NOT IN ( '777','780' )
                   THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END AcBuRevisedSegmentCode  ,
             DPD_Max ,
             UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             NVL(Balance, 0) / v_Cost Balance  ,
             NVL(NetBalance, 0) / v_Cost NetBalance  ,
             NVL(DrawingPower, 0) / v_Cost DrawingPower  ,
             NVL(CurrentLimit, 0) / v_Cost CurrentLimit  ,
             (CASE 
                   WHEN A.SourceAlt_Key = 1
                     AND SchemeType = 'ODA' THEN (CASE 
                                                       WHEN (NVL(b.Balance, 0) - (CASE 
                                                                                       WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                                                       ELSE NVL(b.CurrentLimit, 0)
                                                          END)) <= 0 THEN 0
                   ELSE (CASE 
                              WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                   ELSE NVL(b.CurrentLimit, 0)
                      END)
                      END)
             ELSE 0
                END) / v_Cost OverDrawn_Amt  ,
             DPD_Overdrawn ,
             UTILS.CONVERT_TO_VARCHAR2(ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
             UTILS.CONVERT_TO_VARCHAR2(ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
             DPD_Renewal ,
             UTILS.CONVERT_TO_VARCHAR2(StockStDt,20,p_style=>103) StockStDt  ,
             DPD_StockStmt ,
             UTILS.CONVERT_TO_VARCHAR2(DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(LastCrDate,20,p_style=>103) LastCrDate  ,
             DPD_NoCredit ,
             NVL(CurQtrCredit, 0) / v_Cost CurQtrCredit  ,
             NVL(CurQtrInt, 0) / v_Cost CurQtrInt  ,
             (CASE 
                   WHEN (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0)) < 0 THEN 0
             ELSE (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0))
                END) / v_Cost InterestNotServiced  ,
             DPD_IntService ,
             IntNotServicedDt CC_OD_Interest_Service  ,
             NVL(OverdueAmt, 0) / v_Cost OverdueAmt  ,
             UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
             DPD_Overdue ,
             NVL(PrincOverdue, 0) / v_Cost PrincOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(PrincOverdueSinceDt,20,p_style=>103) PrincOverdueSinceDt  ,
             DPD_PrincOverdue ,
             NVL(IntOverdue, 0) / v_Cost IntOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(IntOverdueSinceDt,20,p_style=>103) IntOverdueSinceDt  ,
             DPD_IntOverdueSince ,
             NVL(OtherOverdue, 0) / v_Cost OtherOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(OtherOverdueSinceDt,20,p_style=>103) OtherOverdueSinceDt  ,
             DPD_OtherOverdueSince ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN OverdueAmt
             ELSE 0
                END) Bill_PC_Overdue_Amount  ,
             ' ' Overdue_Bill_PC_ID  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN OverDueSinceDt
             ELSE ' '
                END) Bill_PC_Overdue_Date  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN DPD_Overdue
             ELSE 0
                END) DPD_Bill_PC  ,
             --,A2.AssetClassName                                    AS FinalAssetName
             a2.AssetClassSubGroup FinalAssetName ,---added by Prashant---02052024---

             A.DegReason ,
             NPANorms ,
             CASE 
                  WHEN MC.MOC_Reason IS NOT NULL
                    AND MCD.MOC_Reason IS NOT NULL THEN 'Y'
             ELSE 'N'
                END MOC_Flag  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 29999
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
               AND X.EffectiveToTimeKey = 49999
             ----

               LEFT JOIN MOC_ChangeDetails MC   ON a.CustomerEntityID = mc.CustomerEntityID
               AND mc.EffectiveFromTimeKey <= v_Timekey
               AND mc.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN MOC_ChangeDetails MCD   ON b.AccountEntityID = MCD.AccountEntityID
               AND MCD.EffectiveFromTimeKey <= v_Timekey
               AND MCD.EffectiveToTimeKey >= v_Timekey
       WHERE  B.FinalAssetClassAlt_Key > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_028" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_028" TO "ADF_CDR_RBL_STGDB";
