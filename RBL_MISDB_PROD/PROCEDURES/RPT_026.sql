--------------------------------------------------------
--  DDL for Procedure RPT_026
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_026" 
(
  v_DateFrom IN VARCHAR2,
  v_DateTo IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   --    @DateFrom	AS VARCHAR(15)='01/10/2021',
   --    @DateTo		AS VARCHAR(15)='26/03/2022',
   --	  @Cost    AS FLOAT=1
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   v_cursor SYS_REFCURSOR;

BEGIN

   --
   ---------------------DEGRADATION  Report----------------------
   ---------------------------======================================DPD CalCULATION  Start===========================================
   IF ( utils.object_id('TEMPDB..tt_IntNoserviedDt_3') IS NOT NULL ) THEN
    -----------------------------------------Prashant 07-04-2022 as per Sitaram and Guarav sir------------------------------------------
   --and isnull(b.WriteOffAmount,0)=0
   -------------------------------------------------------------------------------------------------------
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_IntNoserviedDt_3 ';
   END IF;
   --select distinct CustomerAcID,IntNotServicedDt,DegDate,AccountBlkCode2
   --into tt_IntNoserviedDt_3
   --from Pro.ACCOUNTCAL_hist  A
   --INNER JOIN Pro.CustomerCal_Hist B 
   --ON A.CustomerEntityID = B.CustomerEntityID
   --AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
   --and cast(DegDate as date) is not NULL
   --and IntNotServicedDt is not NULL
   --=================================Added by Prashant 14-04-2022====================
   DELETE FROM tt_IntNoserviedDt_3;
   UTILS.IDENTITY_RESET('tt_IntNoserviedDt_3');

   INSERT INTO tt_IntNoserviedDt_3 SELECT CustomerAcID ,
                                          IntNotServicedDt ,
                                          DegDate ,
                                          AccountBlkCode2 
        FROM ( SELECT DISTINCT CustomerAcID ,
                               IntNotServicedDt ,
                               DegDate ,
                               AccountBlkCode2 ,
                               ROW_NUMBER() OVER ( PARTITION BY CustomerAcID ORDER BY CustomerAcID, DegDate DESC  ) rn  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
                      AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
                      AND UTILS.CONVERT_TO_VARCHAR2(DegDate,200) IS NOT NULL
                      AND IntNotServicedDt IS NOT NULL ) a
       WHERE  rn = 1;
   --====================================================
   ---------Degrade Report-------------------
   OPEN  v_cursor FOR
      SELECT --CONVERT(VARCHAR(20),@to1, 103)                  AS  [Process_date] 
             UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
             UCIC UCIC  ,
             CustomerID CustomerID  ,
             CustomerName ,
             B.Branchcode ,
             BranchName ,
             B.CustomerAcid ,
             SourceName ,
             FacilityType ,
             SchemeType ,
             ProductCode ,
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
                    AND ProductCode IN ( '777','780' )
                   THEN 'Retail'
                  WHEN SourceName = 'VisionPlus'
                    AND ProductCode NOT IN ( '777','780' )
                   THEN 'Credit Card'
             ELSE B.AcBuRevisedSegmentCode
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
             --,A2.AssetClassName                                    AS FinalAssetName
             a2.AssetClassSubGroup FinalAssetName ,---added by Prashant---02052024---

             REPLACE(NVL(B.DegReason, b.NPA_Reason), ',', ' ') DegReason  ,
             RefPeriodOverdue NPANorms  ,
             NULL MOCreason  ,
             ------added on 26/03/2022
             NVL(dt.AccountBlkCode2, ' ') Block_Code_V_  
        FROM ACL_NPA_DATA B
               LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
               AND A2.EffectiveToTimeKey = 49999
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999
               LEFT JOIN DimBranch X   ON B.Branchcode = X.BranchCode
               AND X.EffectiveToTimeKey = 49999
               LEFT JOIN tt_IntNoserviedDt_3 DT   ON B.CustomerAcid = Dt.CustomerAcID
       WHERE  InitialAssetClassAlt_Key = 1
                AND FinalAssetClassAlt_Key > 1
                AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_IntNoserviedDt_3 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026" TO "ADF_CDR_RBL_STGDB";
