--------------------------------------------------------
--  DDL for Procedure DGU_UPGRADEREPORT_IN_PACKAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" 
AS
   v_Date VARCHAR2(10) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date1 VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --Declare @Date varchar(10)='02/02/2022'--'28/01/2022'
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_DateFrom VARCHAR2(15) := v_Date;
   v_DateTo VARCHAR2(15) := v_Date;
   v_Cost FLOAT(53) := 1;
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );

BEGIN

   --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
   ----------------------------Upgrade Report
   EXECUTE IMMEDIATE ' TRUNCATE TABLE DGU_UpgradeReport_package ';
   ---------Upgrade Report-------------------
   INSERT INTO DGU_UpgradeReport_package
     ( SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
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
                   WHEN B.SourceName = 'FIS' THEN 'FI'
                   WHEN B.SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END AcBuSegmentDescription  ,
              CASE 
                   WHEN B.SourceName = 'FIS' THEN 'FI'
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
              --,A2.AssetClassName                                    AS FinalAssetName
              a2.AssetClassSubGroup FinalAssetName ,---added by Prashant---02052024---

              --,A.DegReason
              RefPeriodOverdue NPANorms  ,
              v_Date1 

       --into UpgradeReport_package
       FROM ACL_UPG_DATA B
              LEFT JOIN DIMSOURCEDB src   ON B.SourceName = src.SourceName

              --AND src.EffectiveToTimeKey=49999
              AND ( src.EffectiveFromTimeKey <= v_Timekey
              AND src.EffectiveToTimeKey >= v_TimeKey )
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
                 AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1 );--and b.CustomerAcid not in (select ACID from ExceptionFinalStatusType where  EffectiveToTimeKey=49999
   --									   and StatusType='TWO' )

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DGU_UPGRADEREPORT_IN_PACKAGE" TO "ADF_CDR_RBL_STGDB";
