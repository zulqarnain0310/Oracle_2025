--------------------------------------------------------
--  DDL for Procedure DEGRADEREPORT_IN_PACKAGE_MONTHWISE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" 
AS
   --Declare @Date varchar(10)=(select convert(varchar(10),Date,103) from Automate_Advances where EXT_FLG='Y')
   --Declare @Date1 varchar(10)=(select convert(varchar(10),DATEADD(dd,-day('2022-01-05')+1,'2022-01-05'),103))
   --Declare @Date2 varchar(10)=(select convert(varchar(10),DATEADD(dd,-day(dateadd(mm,1,'2022-01-05')),dateadd(mm,1,'2022-01-05')),103))
   v_Date1 VARCHAR2(10) := '01/06/2022';
   v_Date2 VARCHAR2(10) := '30/06/2022';
   --select @Date1
   --select @Date2
   v_DateFrom VARCHAR2(15) := v_Date1;
   v_DateTo VARCHAR2(15) := v_Date2;
   v_Cost FLOAT(53) := 1;
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );

BEGIN

   --
   ---------------------DEGRADATION  Report----------------------
   ---------------------------======================================DPD CalCULATION  Start===========================================
   IF utils.object_id('TEMPDB..tt_IntNoserviedDt_18') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_IntNoserviedDt_18 ';
   END IF;
   DELETE FROM tt_IntNoserviedDt_18;
   UTILS.IDENTITY_RESET('tt_IntNoserviedDt_18');

   INSERT INTO tt_IntNoserviedDt_18 ( 
   	SELECT DISTINCT CustomerAcID ,
                    IntNotServicedDt ,
                    DegDate 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
             AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
             AND UTILS.CONVERT_TO_VARCHAR2(DegDate,200) IS NOT NULL
             AND IntNotServicedDt IS NOT NULL );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE DegradeReport_package_Monthwise ';
   ---------Degrade Report-------------------
   INSERT INTO DegradeReport_package_Monthwise
     ( SELECT
       --CONVERT(VARCHAR(20),@to1, 103)                  AS  [Process_date] 
        UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
        UCIC UCIC  ,
        CustomerID CustomerID  ,
        REPLACE(CustomerName, ',', ' ') CustomerName  ,
        B.Branchcode ,
        REPLACE(BranchName, ',', ' ') BranchName  ,
        B.CustomerAcid ,
        REPLACE(SourceName, ',', ' ') SourceName  ,
        REPLACE(FacilityType, ',', ' ') FacilityType  ,
        REPLACE(SchemeType, ',', ' ') SchemeType  ,
        REPLACE(ProductCode, ',', ' ') ProductCode  ,
        REPLACE(ProductName, ',', ' ') ProductName  ,
        REPLACE(ActSegmentCode, ',', ' ') ActSegmentCode  ,
        CASE 
             WHEN SourceName = 'Ganaseva' THEN 'FI'
             WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
        ELSE REPLACE(AcBuSegmentDescription, ',', ' ')
           END AcBuSegmentDescription  ,
        CASE 
             WHEN SourceName = 'Ganaseva' THEN 'FI'
             WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
        ELSE REPLACE(B.AcBuRevisedSegmentCode, ',', ' ')
           END AcBuRevisedSegmentCode  ,
        DPD_Max ,
        UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
        NVL(b.Balance, 0) / v_Cost Balance  ,
        NVL(b.NetBalance, 0) / v_Cost NetBalance  ,
        NVL(b.DrawingPower, 0) / v_Cost DrawingPower  ,
        NVL(b.CurrentLimit, 0) / v_Cost CurrentLimit  ,
        (CASE 
              WHEN B.SourceName = 'Finacle'
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
           END) / v_COST OverDrawn_Amt  ,
        DPD_Overdrawn ,
        UTILS.CONVERT_TO_VARCHAR2(ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
        UTILS.CONVERT_TO_VARCHAR2(ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
        DPD_Renewal ,
        UTILS.CONVERT_TO_VARCHAR2(StockStDt,20,p_style=>103) StockStDt  ,
        DPD_StockStmt ,
        UTILS.CONVERT_TO_VARCHAR2(DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
        UTILS.CONVERT_TO_VARCHAR2(LastCrDate,20,p_style=>103) LastCrDate  ,
        DPD_NoCredit ,
        NVL(b.CurQtrCredit, 0) / v_Cost CurQtrCredit  ,
        NVL(b.CurQtrInt, 0) / v_Cost CurQtrInt  ,
        (CASE 
              WHEN (NVL(b.CurQtrInt, 0) - NVL(b.CurQtrCredit, 0)) < 0 THEN 0
        ELSE (NVL(b.CurQtrInt, 0) - NVL(b.CurQtrCredit, 0))
           END) / v_Cost InterestNotServiced  ,
        DPD_IntService ,
        Dt.IntNotServicedDt CC_OD_Interest_Service  ,
        (NVL(b.OverdueAmt, 0) / v_Cost) OverdueAmt  ,
        UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
        DPD_Overdue ,
        NVL(b.PrincOverdue, 0) / v_Cost PrincOverdue  ,
        UTILS.CONVERT_TO_VARCHAR2(PrincOverdueSinceDt,20,p_style=>103) PrincOverdueSinceDt  ,
        DPD_PrincOverDue ,
        NVL(b.IntOverdue, 0) / v_Cost IntOverdue  ,
        UTILS.CONVERT_TO_VARCHAR2(IntOverdueSinceDt,20,p_style=>103) IntOverdueSinceDt  ,
        DPD_IntOverdueSince ,
        NVL(b.OtherOverdue, 0) / v_Cost OtherOverdue  ,
        UTILS.CONVERT_TO_VARCHAR2(OtherOverdueSinceDt,20,p_style=>103) OtherOverdueSinceDt  ,
        DPD_OtherOverdueSince ,
        (CASE 
              WHEN SchemeType = 'FBA' THEN b.OverdueAmt
        ELSE 0
           END) Bill_PC_Overdue_Amount  ,
        ' ' Overdue_Bill_PC_ID  ,
        (CASE 
              WHEN SchemeType = 'FBA' THEN UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,30)
        ELSE ' '
           END) Bill_PC_Overdue_Date  ,
        (CASE 
              WHEN SchemeType = 'FBA' THEN DPD_Overdue
        ELSE 0
           END) DPD_Bill_PC  ,
        REPLACE(A2.AssetClassName, ',', ' ') FinalAssetName  ,
        REPLACE(NVL(B.DegReason, b.NPA_Reason), ',', ' ') DegReason  ,
        RefPeriodOverdue NPANorms  ,
        NULL MOCreason  

       --Into DegradeReport_package
       FROM ACL_NPA_DATA B
              LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
              AND A2.EffectiveToTimeKey = 49999
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN DimBranch X   ON B.Branchcode = X.BranchCode
              AND X.EffectiveToTimeKey = 49999
              LEFT JOIN tt_IntNoserviedDt_18 DT   ON B.CustomerAcid = Dt.CustomerAcID
        WHERE  InitialAssetClassAlt_Key = 1
                 AND FinalAssetClassAlt_Key > 1
                 AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1
                 AND b.CustomerAcid NOT IN ( SELECT ACID 
                                             FROM ExceptionFinalStatusType 
                                              WHERE  EffectiveToTimeKey = 49999
                                                       AND StatusType = 'TWO' )
      );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEGRADEREPORT_IN_PACKAGE_MONTHWISE" TO "ADF_CDR_RBL_STGDB";
