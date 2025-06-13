--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_REPORT27_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date1 VARCHAR2(10) := ( SELECT v_Date 
     FROM DUAL  );
   v_DateFrom VARCHAR2(15) := v_Date1;
   v_DateTo VARCHAR2(15) := v_Date1;
   v_Cost FLOAT(53) := 1;
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );

BEGIN

   --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
   ----------------------------Upgrade Report
   IF utils.object_id('TEMPDB..tt_Temp_131') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_131 ';
   END IF;
   DELETE FROM tt_Temp_131;
   UTILS.IDENTITY_RESET('tt_Temp_131');

   INSERT INTO tt_Temp_131 ( 
   	SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
           B.UCIC UCIC  ,
           B.CustomerID CustomerID  ,
           CustomerName ,
           B.Branchcode ,
           BranchName ,
           CustomerAcID ,
           B.SourceName ,
           B.Facilitytype ,
           B.SchemeType ,
           B.ProductCode ,
           B.ProductName ,
           ActSegmentCode ,
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
           UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
           UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) UpgDate  ,
           NVL(Balance, 0) / v_Cost Balance  ,
           NVL(NetBalance, 0) / v_Cost NetBalance  ,
           NVL(DrawingPower, 0) / v_Cost DrawingPower  ,
           NVL(CurrentLimit, 0) / v_Cost CurrentLimit  ,
           (CASE 
                 WHEN B.SourceName = 'Finacle'
                   AND B.SchemeType = 'ODA' THEN (CASE 
                                                       WHEN (NVL(Balance, 0) - (CASE 
                                                                                     WHEN NVL(DrawingPower, 0) < NVL(CurrentLimit, 0) THEN NVL(DrawingPower, 0)
                                                       ELSE NVL(CurrentLimit, 0)
                                                          END)) <= 0 THEN 0
                 ELSE (CASE 
                            WHEN NVL(DrawingPower, 0) < NVL(CurrentLimit, 0) THEN NVL(DrawingPower, 0)
                 ELSE NVL(CurrentLimit, 0)
                    END)
                    END)
           ELSE 0
              END) / v_COST OverDrawn_Amt  ,
           ' ' DPD_Overdrawn  ,
           UTILS.CONVERT_TO_VARCHAR2(ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
           UTILS.CONVERT_TO_VARCHAR2(ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
           ' ' DPD_Renewal  ,
           UTILS.CONVERT_TO_VARCHAR2(StockStDt,20,p_style=>103) StockStDt  ,
           ' ' DPD_StockStmt  ,
           UTILS.CONVERT_TO_VARCHAR2(DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
           UTILS.CONVERT_TO_VARCHAR2(LastCrDate,20,p_style=>103) LastCrDate  ,
           ' ' DPD_NoCredit  ,
           NVL(CurQtrCredit, 0) / v_Cost CurQtrCredit  ,
           NVL(CurQtrInt, 0) / v_Cost CurQtrInt  ,
           CASE 
                WHEN NVL(Agrischeme, 'N') != 'Y' THEN (CASE 
                                                            WHEN (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0)) < 0 THEN 0
                ELSE (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0))
                   END) / v_Cost
           ELSE 0
              END InterestNotServiced  ,
           ' ' DPD_IntService  ,
           0 CC_OD_Interest_Service  ,
           NVL(OverdueAmt, 0) / v_Cost OverdueAmt  ,
           UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
           ' ' DPD_Overdue  ,
           NVL(PrincOverdue, 0) / v_Cost PrincOverdue  ,
           UTILS.CONVERT_TO_VARCHAR2(PrincOverdueSinceDt,20,p_style=>103) PrincOverdueSinceDt  ,
           ' ' DPD_PrincOverdue  ,
           NVL(IntOverdue, 0) / v_Cost IntOverdue  ,
           UTILS.CONVERT_TO_VARCHAR2(IntOverdueSinceDt,20,p_style=>103) IntOverdueSinceDt  ,
           ' ' DPD_IntOverdueSince  ,
           NVL(OtherOverdue, 0) / v_Cost OtherOverdue  ,
           UTILS.CONVERT_TO_VARCHAR2(OtherOverdueSinceDt,20,p_style=>103) OtherOverdueSinceDt  ,
           ' ' DPD_OtherOverdueSince  ,
           0 Bill_PC_Overdue_Amount  ,
           ' ' Overdue_Bill_PC_ID  ,
           ' ' Bill_PC_Overdue_Date  ,
           ' ' DPD_Bill_PC  ,
           A2.AssetClassName FinalAssetName  ,
           --,A.DegReason
           RefPeriodOverdue NPANorms  
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
   	 WHERE  B.InitialAssetClassAlt_Key > 1
              AND B.FinalAssetClassAlt_Key = 1
              AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1 );
   IF utils.object_id('TEMPDB..tt_Temp_1311') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp1_10 ';
   END IF;
   DELETE FROM tt_Temp1_10;
   UTILS.IDENTITY_RESET('tt_Temp1_10');

   INSERT INTO tt_Temp1_10 ( 
   	SELECT A.SourceName ,
           b.SourceAlt_Key ,
           COUNT(*)  CNT  
   	  FROM tt_Temp_131 a
             JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
   	  GROUP BY a.SourceName,b.SourceAlt_Key );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport a
          JOIN tt_Temp1_10 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Upgrade_Report_27 = src.CNT;
   UPDATE StatusReport
      SET Upgrade_Report_27 = 0
    WHERE  Upgrade_Report_27 IS NULL;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_REPORT27_04122023" TO "ADF_CDR_RBL_STGDB";
