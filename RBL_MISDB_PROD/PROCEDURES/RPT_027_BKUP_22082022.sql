--------------------------------------------------------
--  DDL for Procedure RPT_027_BKUP_22082022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" 
(
  -- @TimeKey AS INT,
  v_DateFrom IN VARCHAR2,
  v_DateTo IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   --      --@TimeKey AS INT=25992,
   --@DateFrom	AS VARCHAR(15)='01/04/2015',
   --@DateTo		AS VARCHAR(15)='26/03/2022',
   --	  @Cost    AS FLOAT=1
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   v_cursor SYS_REFCURSOR;

BEGIN

   --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
   ----------------------------Upgrade Report
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
             B.UCIC UCIC  ,
             B.CustomerID CustomerID  ,
             CustomerName ,
             B.Branchcode ,
             BranchName ,
             B.CustomerAcid ,
             B.SourceName ,
             B.Facilitytype ,
             B.SchemeType ,
             B.ProductCode ,
             B.ProductName ,
             B.ActSegmentCode ,
             CASE 
                  WHEN B.SourceName = 'Ganaseva' THEN 'FI'
                  WHEN B.SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END AcBuSegmentDescription  ,
             CASE 
                  WHEN B.SourceName = 'Ganaseva' THEN 'FI'
                  WHEN B.SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE B.AcBuRevisedSegmentCode
                END AcBuRevisedSegmentCode  ,
             ' ' DPD_Max  ,
             UTILS.CONVERT_TO_VARCHAR2(B.FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) UpgDate  ,
             NVL(B.Balance, 0) / v_Cost Balance  ,
             NVL(B.NetBalance, 0) / v_Cost NetBalance  ,
             NVL(B.DrawingPower, 0) / v_Cost DrawingPower  ,
             NVL(B.CurrentLimit, 0) / v_Cost CurrentLimit  ,
             (CASE 
                   WHEN B.SourceName = 'Finacle'
                     AND B.SchemeType = 'ODA' THEN (CASE 
                                                         WHEN (NVL(B.Balance, 0) - (CASE 
                                                                                         WHEN NVL(B.DrawingPower, 0) < NVL(B.CurrentLimit, 0) THEN NVL(B.DrawingPower, 0)
                                                         ELSE NVL(B.CurrentLimit, 0)
                                                            END)) <= 0 THEN 0
                   ELSE (CASE 
                              WHEN NVL(B.DrawingPower, 0) < NVL(B.CurrentLimit, 0) THEN NVL(B.DrawingPower, 0)
                   ELSE NVL(B.CurrentLimit, 0)
                      END)
                      END)
             ELSE 0
                END) / v_COST OverDrawn_Amt  ,
             ' ' DPD_Overdrawn  ,
             UTILS.CONVERT_TO_VARCHAR2(B.ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
             UTILS.CONVERT_TO_VARCHAR2(B.ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
             ' ' DPD_Renewal  ,
             UTILS.CONVERT_TO_VARCHAR2(B.StockStDt,20,p_style=>103) StockStDt  ,
             ' ' DPD_StockStmt  ,
             UTILS.CONVERT_TO_VARCHAR2(B.DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(B.LastCrDate,20,p_style=>103) LastCrDate  ,
             ' ' DPD_NoCredit  ,
             NVL(B.CurQtrCredit, 0) / v_Cost CurQtrCredit  ,
             NVL(B.CurQtrInt, 0) / v_Cost CurQtrInt  ,
             CASE 
                  WHEN NVL(Agrischeme, 'N') != 'Y' THEN (CASE 
                                                              WHEN (NVL(B.CurQtrInt, 0) - NVL(B.CurQtrCredit, 0)) < 0 THEN 0
                  ELSE (NVL(B.CurQtrInt, 0) - NVL(B.CurQtrCredit, 0))
                     END) / v_Cost
             ELSE 0
                END InterestNotServiced  ,
             ' ' DPD_IntService  ,
             0 CC_OD_Interest_Service  ,
             NVL(B.OverdueAmt, 0) / v_Cost OverdueAmt  ,
             UTILS.CONVERT_TO_VARCHAR2(B.OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
             ' ' DPD_Overdue  ,
             NVL(B.PrincOverdue, 0) / v_Cost PrincOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(B.PrincOverdueSinceDt,20,p_style=>103) PrincOverdueSinceDt  ,
             ' ' DPD_PrincOverdue  ,
             NVL(B.IntOverdue, 0) / v_Cost IntOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(B.IntOverdueSinceDt,20,p_style=>103) IntOverdueSinceDt  ,
             ' ' DPD_IntOverdueSince  ,
             NVL(B.OtherOverdue, 0) / v_Cost OtherOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(B.OtherOverdueSinceDt,20,p_style=>103) OtherOverdueSinceDt  ,
             ' ' DPD_OtherOverdueSince  ,
             0 Bill_PC_Overdue_Amount  ,
             ' ' Overdue_Bill_PC_ID  ,
             ' ' Bill_PC_Overdue_Date  ,
             ' ' DPD_Bill_PC  ,
             A2.AssetClassName FinalAssetName  ,
             --,A.DegReason
             B.RefPeriodOverdue NPANorms  ,
             NVL(AC.AccountBlkCode2, ' ') Block_Code_V_  
        FROM ACL_UPG_DATA B
               LEFT JOIN DIMSOURCEDB src   ON B.SourceName = src.SourceName
               AND src.EffectiveToTimeKey = 49999
               LEFT JOIN DimProduct PD   ON PD.ProductCode = B.ProductCode
               AND PD.EffectiveToTimeKey = 49999
               LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
               AND A2.EffectiveToTimeKey = 49999
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999
               LEFT JOIN DimBranch X   ON B.Branchcode = X.BranchCode
               AND X.EffectiveToTimeKey = 49999
               LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist AC   ON B.CustomerAcid = AC.CustomerAcid
               AND AC.EffectiveToTimeKey = 49999
       WHERE  B.InitialAssetClassAlt_Key > 1
                AND B.FinalAssetClassAlt_Key = 1
                AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_BKUP_22082022" TO "ADF_CDR_RBL_STGDB";
