--------------------------------------------------------
--  DDL for Procedure RPT_027_08112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_027_08112021" 
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
   --@DateTo		AS VARCHAR(15)='28/07/2021',
   --	  @Cost    AS FLOAT=1
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
   ----------------------------Upgrade Report
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(SD.Date_,20,p_style=>103) Process_date  ,
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
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END AcBuSegmentDescription  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END AcBuRevisedSegmentCode  ,
             ' ' DPD_Max  ,
             UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             UTILS.CONVERT_TO_VARCHAR2(B.UpgDate,20,p_style=>103) UpgDate  ,
             NVL(Balance, 0) / v_Cost Balance  ,
             NVL(NetBalance, 0) / v_Cost NetBalance  ,
             NVL(DrawingPower, 0) / v_Cost DrawingPower  ,
             NVL(CurrentLimit, 0) / v_Cost CurrentLimit  ,
             (CASE 
                   WHEN A.SourceAlt_Key = 1
                     AND SchemeType = 'ODA' THEN (CASE 
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
             A.DegReason ,
             RefPeriodOverdue NPANorms  
        FROM
        --PRO.CustomerCal_Hist A
         --INNER JOIN PRO.AccountCal_Hist B                ON A.CustomerEntityID=B.CustomerEntityID
         --                                              AND A.EffectiveFromTimeKey<=@TimeKey
         --									          AND A.EffectiveToTimeKey>=@TimeKey
         --                                              AND B.EffectiveFromTimeKey<=@TimeKey
         --									          AND B.EffectiveToTimeKey>=@TimeKey
       PRO_RBL_MISDB_PROD.AccountCal_Hist B
         JOIN SysDayMatrix SD   ON B.EffectiveFromTimeKey = SD.TimeKey
         JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.EffectiveFromTimeKey = SD.TimeKey
         AND A.CustomerEntityID = B.CustomerEntityID
         LEFT JOIN DIMSOURCEDB src   ON B.SourceAlt_Key = src.SourceAlt_Key
         AND src.EffectiveToTimeKey = 49999
         LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = B.PRODUCTALT_KEY
         AND PD.EffectiveToTimeKey = 49999
         LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
         AND A2.EffectiveToTimeKey = 49999
         LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
         AND S.EffectiveToTimeKey = 49999
         LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
         AND X.EffectiveToTimeKey = 49999
       WHERE  B.FlgUpg = 'U'
                AND UTILS.CONVERT_TO_VARCHAR2(SD.Date_,200) BETWEEN v_From1 AND v_to1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_08112021" TO "ADF_CDR_RBL_STGDB";
