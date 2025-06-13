--------------------------------------------------------
--  DDL for Procedure UPGRADEREPORT_IN_PACKAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" 
AS
   v_Date VARCHAR2(10) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) 
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
   v_cursor SYS_REFCURSOR;

BEGIN

   ------------------------Added by Prashant---05042024-----------------------------------
   --IF OBJECT_ID ('TEMPDB..#ACCOUNTCAL') is not null
   --drop table #ACCOUNTCAL
   --select * into  #ACCOUNTCAL
   --from           pro.ACCOUNTCAL
   --where          InitialAssetClassAlt_Key >1 and FinalAssetClassAlt_Key=1
   ------------------------END-----------------------------------
   --DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)  
   ----------------------------Upgrade Report  
   EXECUTE IMMEDIATE ' TRUNCATE TABLE UpgradeReport_package ';
   ---------Upgrade Report-------------------  
   INSERT INTO UpgradeReport_package
     ( SELECT UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) Process_date  ,
              B.UCIC UCIC  ,
              B.CustomerID CustomerID  ,
              CustomerName ,
              B.Branchcode ,
              BranchName ,
              b.CustomerAcid ,
              B.SourceName ,
              B.Facilitytype ,
              B.SchemeType ,
              B.ProductCode ,
              B.ProductName ,
              b.ActSegmentCode ,
              CASE 
                   WHEN B.SourceName = 'FIS' THEN 'FI'
                   WHEN B.SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END AcBuSegmentDescription  ,
              --,CASE WHEN B.SourceName='FIS' THEN 'FI'  
              --    WHEN B.SourceName='VisionPlus' THEN 'Credit Card'  
              --	 --WHEN b.SourceName='VisionPlus' and b.ProductCode in ('777','780') THEN 'Retail'
              --	 --WHEN b.SourceName='VisionPlus' and b.ProductCode not in ('777','780') THEN 'Credit Card'
              --  else B.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode 
              CASE 
                   WHEN B.SourceName = 'FIS' THEN 'FI'

                   --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                   WHEN B.SourceName = 'VisionPlus'
                     AND B.ProductCode IN ( '777','780' )
                    THEN 'Retail'
                   WHEN B.SourceName = 'VisionPlus'
                     AND B.ProductCode NOT IN ( '777','780' )
                    THEN 'Credit Card'
              ELSE REPLACE(B.AcBuRevisedSegmentCode, ',', ' ')
                 END AcBuRevisedSegmentCode  ,
              b.DPD_Max DPD_Max ,---Added by Prashant---05042024------

              UTILS.CONVERT_TO_VARCHAR2(b.FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
              UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105),20,p_style=>103) UpgDate  ,
              NVL(b.Balance, 0) / v_Cost Balance  ,
              NVL(b.NetBalance, 0) / v_Cost NetBalance  ,
              NVL(b.DrawingPower, 0) / v_Cost DrawingPower  ,
              NVL(b.CurrentLimit, 0) / v_Cost CurrentLimit  ,
              (CASE 
                    WHEN B.SourceName = 'Finacle'
                      AND B.SchemeType = 'ODA' THEN (CASE 
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
              --,''                                          AS DPD_Overdrawn
              b.DPD_Overdrawn DPD_Overdrawn ,---Added by Prashant---20042024------

              UTILS.CONVERT_TO_VARCHAR2(b.ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
              UTILS.CONVERT_TO_VARCHAR2(b.ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
              --,''                                          AS DPD_Renewal  
              b.DPD_Renewal DPD_Renewal ,---Added by Prashant---20042024------

              UTILS.CONVERT_TO_VARCHAR2(b.StockStDt,20,p_style=>103) StockStDt  ,
              --,''                                          AS DPD_StockStmt
              b.DPD_StockStmt DPD_StockStmt ,---Added by Prashant---20042024------

              UTILS.CONVERT_TO_VARCHAR2(b.DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
              UTILS.CONVERT_TO_VARCHAR2(b.LastCrDate,20,p_style=>103) LastCrDate  ,
              --,''                                          AS DPD_NoCredit
              b.DPD_NoCredit DPD_NoCredit ,---Added by Prashant---20042024------

              NVL(b.CurQtrCredit, 0) / v_Cost CurQtrCredit  ,
              NVL(b.CurQtrInt, 0) / v_Cost CurQtrInt  ,
              CASE 
                   WHEN NVL(Agrischeme, 'N') != 'Y' THEN (CASE 
                                                               WHEN (NVL(b.CurQtrInt, 0) - NVL(b.CurQtrCredit, 0)) < 0 THEN 0
                   ELSE (NVL(b.CurQtrInt, 0) - NVL(b.CurQtrCredit, 0))
                      END) / v_Cost
              ELSE 0
                 END InterestNotServiced  ,
              --,''                                          AS DPD_IntService
              b.DPD_IntService DPD_IntService ,---Added by Prashant---20042024------

              0 CC_OD_Interest_Service  ,
              NVL(b.OverdueAmt, 0) / v_Cost OverdueAmt  ,
              UTILS.CONVERT_TO_VARCHAR2(b.OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
              --,''                                          AS DPD_Overdue
              b.DPD_Overdue DPD_Overdue ,---Added by Prashant---20042024------

              NVL(b.PrincOverdue, 0) / v_Cost PrincOverdue  ,
              UTILS.CONVERT_TO_VARCHAR2(b.PrincOverdueSinceDt,20,p_style=>103) PrincOverdueSinceDt  ,
              --,''                                                   AS DPD_PrincOverdue
              b.DPD_PrincOverdue DPD_PrincOverdue ,---Added by Prashant---20042024------

              NVL(b.IntOverdue, 0) / v_Cost IntOverdue  ,
              UTILS.CONVERT_TO_VARCHAR2(b.IntOverdueSinceDt,20,p_style=>103) IntOverdueSinceDt  ,
              --,''                                                   AS DPD_IntOverdueSince  
              b.DPD_IntOverdueSince DPD_IntOverdueSince ,---Added by Prashant---20042024------

              NVL(b.OtherOverdue, 0) / v_Cost OtherOverdue  ,
              UTILS.CONVERT_TO_VARCHAR2(b.OtherOverdueSinceDt,20,p_style=>103) OtherOverdueSinceDt  ,
              --,''                                                   AS  DPD_OtherOverdueSince
              b.DPD_OtherOverdueSince DPD_OtherOverdueSince ,---Added by Prashant---20042024------

              0 Bill_PC_Overdue_Amount  ,
              ' ' Overdue_Bill_PC_ID  ,
              ' ' Bill_PC_Overdue_Date  ,
              ' ' DPD_Bill_PC  ,
              --,A2.AssetClassName                                    AS FinalAssetName  
              a2.AssetClassSubGroup FinalAssetName ,---added by Prashant---02052024---

              --,A.DegReason  
              b.RefPeriodOverdue NPANorms  

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

       --Left join #ACCOUNTCAL DPD         on B.CustomerAcid=dpd.CustomerAcID ---Added by Prashant---05042024------
       WHERE  B.InitialAssetClassAlt_Key > 1
                AND B.FinalAssetClassAlt_Key = 1
                AND UTILS.CONVERT_TO_VARCHAR2(Process_date,200,p_style=>105) BETWEEN v_From1 AND v_to1
                AND b.CustomerAcid NOT IN ( SELECT ACID 
                                            FROM ExceptionFinalStatusType 
                                             WHERE  EffectiveToTimeKey = 49999
                                                      AND StatusType = 'TWO' )
      );
   OPEN  v_cursor FOR
      SELECT REPLACE(Process_date, '/', '-') Process_date  ,
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
        FROM UpgradeReport_package  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPGRADEREPORT_IN_PACKAGE" TO "ADF_CDR_RBL_STGDB";
