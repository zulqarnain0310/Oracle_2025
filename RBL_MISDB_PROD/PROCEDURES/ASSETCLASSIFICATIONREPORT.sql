--------------------------------------------------------
--  DDL for Procedure ASSETCLASSIFICATIONREPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" 
AS
   v_Date VARCHAR2(200) ;
   v_LastQtrDateKey NUMBER(10,0) ;
   v_cursor SYS_REFCURSOR;

BEGIN
   SELECT Date_ INTO v_Date
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' ;
   SELECT LastQtrDateKey INTO v_LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' );


   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_date  ,
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
             DPD_Max ,
             FinalNpaDt ,
             Balance ,
             NetBalance ,
             DrawingPower ,
             CurrentLimit ,
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
                END) OverDrawn_Amt  ,
             DPD_Overdrawn ,
             ContiExcessDt ,
             ReviewDueDt ,
             DPD_Renewal ,
             StockStDt ,
             DPD_StockStmt ,
             DebitSinceDt ,
             LastCrDate ,
             DPD_NoCredit ,
             CurQtrCredit ,
             CurQtrInt ,
             (CASE 
                   WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
             ELSE (CurQtrInt - CurQtrCredit)
                END) InterestNotServiced  ,
             DPD_IntService ,
             NULL CC_OD_Interest_Service  ,
             OverdueAmt ,
             OverDueSinceDt ,
             DPD_Overdue ,
             PrincOverdue ,
             PrincOverdueSinceDt ,
             DPD_PrincOverdue ,
             IntOverdue ,
             IntOverdueSinceDt ,
             DPD_IntOverdueSince ,
             OtherOverdue ,
             OtherOverdueSinceDt ,
             DPD_OtherOverdueSince ,
             NULL Bill_PC_Overdue_Amount  ,
             NULL Overdue_Bill_PC_ID  ,
             NULL Bill_PC_Overdue_Date  ,
             NULL DPD_Bill_PC  ,
             a2.AssetClassName FinalAssetName  ,
             A.DegReason ,
             NPANorms 
        FROM MAIN_PRO.CUSTOMERCAL A
               JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
       WHERE  RefPeriodOverdue NOT IN ( 181,366 )

                AND B.FinalAssetClassAlt_Key > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ASSETCLASSIFICATIONREPORT" TO "ADF_CDR_RBL_STGDB";
