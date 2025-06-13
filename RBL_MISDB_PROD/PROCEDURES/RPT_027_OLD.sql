--------------------------------------------------------
--  DDL for Procedure RPT_027_OLD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_027_OLD" 
--exec [dbo].[Rpt-027] '18/08/2021','18/08/2021',1

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
   v_cursor SYS_REFCURSOR;

BEGIN

   --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
   ----------------------------Upgrade Report
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(SD.Date_,20,p_style=>103) Report_Date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CIF_ID  ,
             CustomerName Borrower_Name  ,
             B.BranchCode Branch_Code  ,
             BranchName Branch_Name  ,
             CustomerAcID Account_No_  ,
             SourceName Source_system  ,
             B.FacilityType Facility  ,
             SchemeType Scheme_type  ,
             B.ProductCode Scheme_code  ,
             ProductName Scheme_description  ,
             ActSegmentCode Seg_Code  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END Segment_Description  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             ' ' Account_DPD  ,
             UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) NPA_date  ,
             UTILS.CONVERT_TO_VARCHAR2(B.UpgDate,20,p_style=>103) Upgrade_date  ,
             NVL(Balance, 0) / v_Cost Outstanding  ,
             NVL(NetBalance, 0) / v_Cost Principal_outstanding  ,
             NVL(DrawingPower, 0) / v_Cost Drawing_Power  ,
             NVL(CurrentLimit, 0) / v_Cost Sanction_Limit  ,
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
                END) / v_COST Overdrawn_Amount  ,
             ' ' DPD_Overdrawn  ,
             UTILS.CONVERT_TO_VARCHAR2(ContiExcessDt,20,p_style=>103) Limit_DP_Overdrawn_date  ,
             UTILS.CONVERT_TO_VARCHAR2(ReviewDueDt,20,p_style=>103) Limit_expiry_date  ,
             ' ' DPD_limit_expiry  ,
             UTILS.CONVERT_TO_VARCHAR2(StockStDt,20,p_style=>103) Stock_Statement_valuation_date  ,
             ' ' DPD_Stock_Statement_expiry  ,
             UTILS.CONVERT_TO_VARCHAR2(DebitSinceDt,20,p_style=>103) Debit_Balance_Since_date  ,
             UTILS.CONVERT_TO_VARCHAR2(LastCrDate,20,p_style=>103) Last_Credit_Date  ,
             ' ' DPD_No_Credit  ,
             NVL(CurQtrCredit, 0) / v_Cost Current_quarter_credit  ,
             NVL(CurQtrInt, 0) / v_Cost Current_quarter_interest  ,
             CASE 
                  WHEN NVL(Agrischeme, 'N') != 'Y' THEN (CASE 
                                                              WHEN (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0)) < 0 THEN 0
                  ELSE (NVL(CurQtrInt, 0) - NVL(CurQtrCredit, 0))
                     END) / v_Cost
             ELSE 0
                END Interest_not_serviced  ,
             ' ' DPD_out_of_order  ,
             0 CC_OD_Overdue_Interest  ,
             NVL(OverdueAmt, 0) / v_Cost Overdue_Ammount  ,
             UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,20,p_style=>103) OverDue_date  ,
             ' ' DPD_Ovedue  ,
             NVL(PrincOverdue, 0) / v_Cost Principal_overdue  ,
             UTILS.CONVERT_TO_VARCHAR2(PrincOverdueSinceDt,20,p_style=>103) Principal_overdue_date  ,
             ' ' DPD_Principal_Overdue  ,
             NVL(IntOverdue, 0) / v_Cost Intersest_overdue  ,
             UTILS.CONVERT_TO_VARCHAR2(IntOverdueSinceDt,20,p_style=>103) Interest_Overdue_date  ,
             ' ' DPD_interest_overdue  ,
             NVL(OtherOverdue, 0) / v_Cost Other_Overdue  ,
             UTILS.CONVERT_TO_VARCHAR2(OtherOverdueSinceDt,20,p_style=>103) Other_overdue_date  ,
             ' ' DPD_Other_overdue  ,
             0 Bill_PC_Overdue_Amount  ,
             ' ' Overdue_Bill_PC_ID  ,
             ' ' Bill_PC_Overdue_Date  ,
             ' ' DPD_Bill_PC  ,
             A2.AssetClassName Asset_Classification  ,
             RefPeriodOverdue NPA_norms  
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_027_OLD" TO "ADF_CDR_RBL_STGDB";
