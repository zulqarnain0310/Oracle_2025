--------------------------------------------------------
--  DDL for Procedure RPT_026_21082021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_026_21082021" 
(
  v_DateFrom IN VARCHAR2,
  v_DateTo IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   --    @DateFrom	AS VARCHAR(15)='01/04/2015',
   --    @DateTo		AS VARCHAR(15)='28/07/2021',
   --	  @Cost    AS FLOAT=1
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   v_cursor SYS_REFCURSOR;

BEGIN

   ---------Degrade Report-------------------
   OPEN  v_cursor FOR
      SELECT v_to1 Process_date  ,
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
             AcBuSegmentDescription ,
             AcBuRevisedSegmentCode ,
             ' ' DPD_Max  ,
             UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             NVL(Balance, 0) / v_Cost Balance  ,
             NVL(NetBalance, 0) / v_Cost NetBalance  ,
             NVL(DrawingPower, 0) / v_Cost DrawingPower  ,
             NVL(CurrentLimit, 0) / v_Cost CurrentLimit  ,
             (CASE 
                   WHEN (NVL(Balance, 0) - (NVL(DrawingPower, 0) + NVL(CurrentLimit, 0))) < 0 THEN 0
             ELSE (NVL(Balance, 0) - (NVL(DrawingPower, 0) + NVL(CurrentLimit, 0)))
                END) / v_Cost OverDrawn_Amt  ,
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
             (CASE 
                   WHEN (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0)) < 0 THEN 0
             ELSE (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0))
                END) / v_Cost InterestNotServiced  ,
             ' ' DPD_IntService  ,
             0 CC_OD_Interest_Service  ,
             (CASE 
                   WHEN A.SourceAlt_Key = 1
                     AND SchemeType = 'ODA' THEN NVL(OverdueAmt, 0) / v_Cost
             ELSE 0
                END) OverdueAmt  ,
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
         --INNER JOIN PRO.AccountCal_Hist B     	ON A.CustomerEntityID=B.CustomerEntityID
         --                                       AND A.EffectiveFromTimeKey<=@TimeKey
         --									   AND A.EffectiveToTimeKey>=@TimeKey
         --                                       AND B.EffectiveFromTimeKey<=@TimeKey
         --									   AND B.EffectiveToTimeKey>=@TimeKey
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
       WHERE  A.FlgDeg = 'Y'
                AND SD.Date_ BETWEEN v_From1 AND v_to1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_21082021" TO "ADF_CDR_RBL_STGDB";
