--------------------------------------------------------
--  DDL for Procedure INCREMENTAL_UPGRADEREPORT_06042024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" 
AS
   --Declare @Date1 varchar(10)=(select convert(varchar(10),DATEADD(dd,-day('2022-01-01')+1,'2022-01-01'),103))
   --Declare @Date2 varchar(10)=(select convert(varchar(10),DATEADD(dd,-day(dateadd(mm,1,'2022-01-01')),dateadd(mm,1,'2022-01-01')),103))
   --Declare @Date1 varchar(10)='01/06/2022'
   --Declare @Date2 varchar(10)='30/06/2022'
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date1 VARCHAR2(10) := (UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('DAY', 1, EOMONTH(v_Date, -1)),10,p_style=>103));
   v_Date2 VARCHAR2(10) := ( SELECT v_Date 
     FROM DUAL  );
   v_DateFrom VARCHAR2(15) := v_Date1;
   v_DateTo VARCHAR2(15) := v_Date2;
   v_Cost FLOAT(53) := 1;
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   v_cursor SYS_REFCURSOR;

BEGIN

   ------------------------Added by Prashant--RDM Optimisation--13032024---------------------------
   IF utils.object_id('TEMPDB..tt_ACL_UPG_DATA1_2') IS NOT NULL THEN
    --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
   ----------------------------Upgrade Report
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACL_UPG_DATA1_2 ';
   END IF;
   DELETE FROM tt_ACL_UPG_DATA1_2;
   UTILS.IDENTITY_RESET('tt_ACL_UPG_DATA1_2');

   INSERT INTO tt_ACL_UPG_DATA1_2 ( 
   	SELECT * 
   	  FROM ACL_UPG_DATA 
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1 );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE UpgradeReport_package_Monthwise ';
   ---------Upgrade Report-------------------
   INSERT INTO UpgradeReport_package_Monthwise
     ( Process_date, UCIC, CustomerID, CustomerName, BranchCode, BranchName, CustomerAcID, SourceName, FacilityType, SchemeType, ProductCode, ProductName, ActSegmentCode, AcBuSegmentDescription, AcBuRevisedSegmentCode, DPD_Max, FinalNpaDt, UpgDate, Balance, NetBalance, DrawingPower, CurrentLimit, OverDrawn_Amt, DPD_Overdrawn, ContiExcessDt, ReviewDueDt, DPD_Renewal, StockStDt, DPD_StockStmt, DebitSinceDt, LastCrDate, DPD_NoCredit, CurQtrCredit, CurQtrInt, InterestNotServiced, DPD_IntService, CC_OD_Interest_Service, OverdueAmt, OverDueSinceDt, DPD_Overdue, PrincOverdue, PrincOverdueSinceDt, DPD_PrincOverdue, IntOverdue, IntOverdueSinceDt, DPD_IntOverdueSince, OtherOverdue, OtherOverdueSinceDt, DPD_OtherOverdueSince, Bill_PC_Overdue_Amount, Overdue_Bill_PC_ID, Bill_PC_Overdue_Date, DPD_Bill_PC, FinalAssetName, NPANorms )
     ( SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
              B.UCIC UCIC  ,
              B.CustomerID CustomerID  ,
              CustomerName ,
              B.BranchCode ,
              BranchName ,
              CustomerAcID ,
              B.SourceName ,
              B.FacilityType ,
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
              A2.AssetClassName FinalAssetName  ,
              --,A.DegReason
              RefPeriodOverdue NPANorms  

       --into UpgradeReport_package
       FROM tt_ACL_UPG_DATA1_2 B
              LEFT JOIN DIMSOURCEDB src   ON B.SourceName = src.SourceName
              AND src.EffectiveToTimeKey = 49999
              LEFT JOIN DimProduct PD   ON PD.ProductCode = B.ProductCode
              AND PD.EffectiveToTimeKey = 49999
              LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
              AND A2.EffectiveToTimeKey = 49999
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
              AND X.EffectiveToTimeKey = 49999
        WHERE  B.InitialAssetClassAlt_Key > 1
                 AND B.FinalAssetClassAlt_Key = 1
                 AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1
                 AND b.CustomerAcid NOT IN ( SELECT ACID 
                                             FROM ExceptionFinalStatusType 
                                              WHERE  EffectiveToTimeKey = 49999
                                                       AND StatusType = 'TWO' )
      );
   UPDATE UpgradeReport_package_Monthwise
      SET dateofdata = REPLACE(process_date, ' ', '/');
   OPEN  v_cursor FOR
      SELECT Process_date ,
             UCIC ,
             CustomerID ,
             CustomerName ,
             BranchCode ,
             BranchName ,
             CustomerAcID ,
             SourceName ,
             FacilityType ,
             SchemeType ,
             ProductCode ,
             ProductName ,
             ActSegmentCode ,
             AcBuSegmentDescription ,
             AcBuRevisedSegmentCode ,
             DPD_Max ,
             --,[FinalNpaDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,200,p_style=>105),10,p_style=>23) FinalNpaDt  ,
             --,[UpgDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(UpgDate,200,p_style=>105),10,p_style=>23) UpgDate  ,
             Balance ,
             NetBalance ,
             DrawingPower ,
             CurrentLimit ,
             OverDrawn_Amt ,
             DPD_Overdrawn ,
             --,[ContiExcessDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(ContiExcessDt,200,p_style=>105),10,p_style=>23) ContiExcessDt  ,
             --,[ReviewDueDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(ReviewDueDt,200,p_style=>105),10,p_style=>23) ReviewDueDt  ,
             DPD_Renewal ,
             --,[StockStDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(StockStDt,200,p_style=>105),10,p_style=>23) StockStDt  ,
             DPD_StockStmt ,
             --,[DebitSinceDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(DebitSinceDt,200,p_style=>105),10,p_style=>23) DebitSinceDt  ,
             --,[LastCrDate]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(LastCrDate,200,p_style=>105),10,p_style=>23) LastCrDate  ,
             DPD_NoCredit ,
             CurQtrCredit ,
             CurQtrInt ,
             InterestNotServiced ,
             DPD_IntService ,
             CC_OD_Interest_Service ,
             OverdueAmt ,
             --,[OverDueSinceDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,200,p_style=>105),10,p_style=>23) OverDueSinceDt  ,
             DPD_Overdue ,
             PrincOverdue ,
             --,[PrincOverdueSinceDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(PrincOverdueSinceDt,200,p_style=>105),10,p_style=>23) PrincOverdueSinceDt  ,
             DPD_PrincOverdue ,
             IntOverdue ,
             --,[IntOverdueSinceDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(IntOverdueSinceDt,200,p_style=>105),10,p_style=>23) IntOverdueSinceDt  ,
             DPD_IntOverdueSince ,
             OtherOverdue ,
             --,[OtherOverdueSinceDt]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OtherOverdueSinceDt,200,p_style=>105),10,p_style=>23) OtherOverdueSinceDt  ,
             DPD_OtherOverdueSince ,
             Bill_PC_Overdue_Amount ,
             Overdue_Bill_PC_ID ,
             --,[Bill/PC Overdue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Bill_PC_Overdue_Date,200,p_style=>105),10,p_style=>23) Bill_PC_Overdue_Date  ,
             DPD_Bill_PC ,
             FinalAssetName ,
             NPANorms 
        FROM UpgradeReport_package_Monthwise  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INCREMENTAL_UPGRADEREPORT_06042024" TO "ADF_CDR_RBL_STGDB";
