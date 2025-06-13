--------------------------------------------------------
--  DDL for Procedure PNPA_AGRI_REPORT_05012024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" 
AS
   v_TIMEKEY NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_ProcessDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PNPAProcessDate --change from 30 to 180
    VARCHAR2(200) := utils.dateadd('DD', 180, v_ProcessDate);
   v_PNPA_DAYS NUMBER(10,0) := utils.datediff('DAY', v_PROCESSDATE, v_PNPAProcessDate);
   v_cursor SYS_REFCURSOR;

BEGIN

   /*--------------------INTIAL LEVEL FlgPNPA SET N-------------------------------------------- */
   IF utils.object_id('TEMPDB..tt_ACCOUNTCAL_50') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNTCAL_50 ';
   END IF;
   IF utils.object_id('TEMPDB..tt_CUSTOMERCAL_51') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CUSTOMERCAL_51 ';
   END IF;
   DELETE FROM tt_ACCOUNTCAL_50;
   UTILS.IDENTITY_RESET('tt_ACCOUNTCAL_50');

   INSERT INTO tt_ACCOUNTCAL_50 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  SourceAlt_Key IN ( 1,3 )
    );
   DELETE FROM tt_CUSTOMERCAL_51;
   UTILS.IDENTITY_RESET('tt_CUSTOMERCAL_51');

   INSERT INTO tt_CUSTOMERCAL_51 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL 
   	 WHERE  SourceAlt_Key IN ( 1,3 )
    );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'N', NULL, NULL, NULL
   FROM A ,tt_ACCOUNTCAL_50 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FlgPNPA = 'N',
                                PNPA_DATE = NULL,
                                PnpaAssetClassAlt_key = NULL,
                                PNPA_Reason = NULL;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'N', NULL, NULL
   FROM A ,tt_CUSTOMERCAL_51 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FlgPNPA = 'N',
                                PNPA_Dt = NULL,
                                PNPA_Class_Key = NULL;
   /*---------------UPDATE FlgPNPA FLAG AT ACCOUNT LEVEL----------------------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( (A.DPD_INTSERVICE + v_PNPA_DAYS) >= A.REFPERIODINTSERVICE ) THEN 'Y'
   WHEN ( (A.DPD_NOCREDIT + v_PNPA_DAYS) >= A.REFPERIODNOCREDIT ) THEN 'Y'
   WHEN ( (A.DPD_OVERDUE + v_PNPA_DAYS) >= A.REFPERIODOVERDUE ) THEN 'Y'
   WHEN ( (A.DPD_STOCKSTMT + v_PNPA_DAYS) >= A.REFPERIODSTKSTATEMENT ) THEN 'Y'
   WHEN ( (A.DPD_RENEWAL + v_PNPA_DAYS) >= A.RefPeriodReview ) THEN 'Y'
   WHEN ( (A.DPD_Overdrawn + v_PNPA_DAYS) >= A.REFPERIODOVERDRAWN ) THEN 'Y'
   ELSE 'N'
      END) AS FlgPNPA
   FROM A ,tt_ACCOUNTCAL_50 A
          JOIN tt_CUSTOMERCAL_51 B   ON A.RefCustomerID = B.RefCustomerID 
    WHERE ( a.FinalAssetClassAlt_Key IN ( SELECT AssetClassAlt_Key 
                                          FROM DimAssetClass 
                                           WHERE  AssetClassShortNameEnum IN ( 'STD' )

                                                    AND EffectiveFromTimeKey <= v_TIMEKEY
                                                    AND EffectiveToTimeKey >= v_TIMEKEY )
    )
     AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )
     AND ( NVL(B.FlgProcessing, 'N') = 'N' )
     AND NVL(A.FLGMOC, 'N') <> 'Y'
     AND NVL(A.BALANCE, 0) > 0
     AND NVL(DPD_Max, 0) > 0) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FlgPNPA = src.FlgPNPA;
   DELETE FROM tt_PNPA_REASON_DATE_8;
   --and isnull(REFPeriodMax,0) >=180
   --select FlgPNPA,BALANCE,* from tt_ACCOUNTCAL_50 where AccountEntityID=16724163
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_PNPA_REASON_DATE_8  --SQLDEV: NOT RECOGNIZED
   INSERT INTO tt_PNPA_REASON_DATE_8
     ( SELECT A.AccountEntityID ,
              utils.dateadd('DAY', -(A.DPD_INTSERVICE + v_PNPA_DAYS - NVL(A.REFPERIODINTSERVICE, 0)), v_PNPAProcessDate) PNPA_DATE  ,
              'DEGRADE BY INT NOT SERVICED' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
        WHERE  ( A.FlgPNPA = 'Y'
                 AND ( (A.DPD_INTSERVICE + v_PNPA_DAYS) >= NVL(REFPERIODINTSERVICE, 0) ) )
       UNION 
       SELECT A.ACCOUNTENTITYID ,
              utils.dateadd('DAY', -(A.DPD_OVERDRAWN + v_PNPA_DAYS - NVL(REFPERIODOVERDRAWN, 0)), v_PNPAProcessDate) PNPA_DATE  ,
              'DEGRADE BY CONTI EXCESS' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
        WHERE  ( A.FlgPNPA = 'Y'
                 AND ( (A.DPD_OVERDRAWN + v_PNPA_DAYS) >= NVL(REFPERIODOVERDRAWN, 0) ) )
       UNION ALL 
       SELECT A.ACCOUNTENTITYID ,
              utils.dateadd('DAY', -(A.DPD_NOCREDIT + v_PNPA_DAYS - NVL(RefPeriodNoCredit, 0)), v_PNPAProcessDate) PNPA_DATE  ,
              'DEGRADE BY NO CREDIT' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
        WHERE  ( A.FlgPNPA = 'Y'
                 AND (A.DPD_NOCREDIT + v_PNPA_DAYS) >= NVL(RefPeriodNoCredit, 0) )
       UNION ALL 
       SELECT A.ACCOUNTENTITYID ,
              utils.dateadd('DAY', -(A.DPD_OVERDUE + v_PNPA_DAYS - NVL(RefPeriodOverdue, 0)), v_PNPAProcessDate) PNPA_DATE  ,
              'DEGRADE BY OVERDUE' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
        WHERE  ( A.FlgPNPA = 'Y'
                 AND ( (A.DPD_OVERDUE + v_PNPA_DAYS) >= NVL(RefPeriodOverdue, 0) ) )
       UNION ALL 
       SELECT A.ACCOUNTENTITYID ,
              utils.dateadd('DAY', -(A.DPD_OVERDUE + v_PNPA_DAYS - NVL(RefPeriodOverdue, 0)), v_PNPAProcessDate) PNPA_DATE  ,
              'DEGRADE BY DEBIT BALANCE' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
              JOIN DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
              AND ( C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey )
        WHERE  ( A.FlgPNPA = 'Y'
                 AND ( (A.DPD_OVERDUE + v_PNPA_DAYS) >= NVL(RefPeriodOverdue, 0) ) )
                 AND A.DebitSinceDt IS NOT NULL
                 AND NVL(C.SrcSysProductCode, 'N') = 'SAVING'
       UNION ALL 
       SELECT A.ACCOUNTENTITYID ,
              utils.dateadd('DAY', -(A.DPD_STOCKSTMT + v_PNPA_DAYS - NVL(RefPeriodStkStatement, 0)), v_PNPAProcessDate) PNPA_DATE  ,
              ' DEGRADE BY STOCK STATEMENT' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
        WHERE  ( A.FlgPNPA = 'Y'
                 AND (A.DPD_STOCKSTMT + v_PNPA_DAYS) >= NVL(RefPeriodStkStatement, 0) )
       UNION ALL 
       SELECT A.ACCOUNTENTITYID ,
              utils.dateadd('DAY', -(A.DPD_RENEWAL + v_PNPA_DAYS - NVL(RefPeriodReview, 0)), v_PNPAPROCESSDATE) PNPA_DATE  ,
              ' DEGRADE BY REVIEW DUE DATE' PNPA_Reason  
       FROM tt_ACCOUNTCAL_50 A
        WHERE  ( A.FlgPNPA = 'Y'
                 AND (A.DPD_RENEWAL + v_PNPA_DAYS) >= NVL(RefPeriodReview, 0) ) );
   WITH CTE_PNPA AS ( SELECT AccountEntityID ,
                             MIN(PNPA_DATE)  PNPA_DATE  ,
                             STRING_AGG(PNPA_Reason, ',') PNPA_Reason  
     FROM tt_PNPA_REASON_DATE_8 
     GROUP BY AccountEntityID ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, B.PNPA_DATE, B.PNPA_Reason
      FROM A ,tt_ACCOUNTCAL_50 a
             JOIN CTE_PNPA B   ON A.AccountEntityID = b.AccountEntityID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.PNPA_DATE = src.PNPA_DATE,
                                   A.PNPA_Reason = src.PNPA_Reason
      ;
   /*-------------------UPDATE PNPA FLAG AT CUSTOMER LEVEL------------------------------------------*/
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, 'Y'
   FROM B ,tt_ACCOUNTCAL_50 A
          JOIN tt_CUSTOMERCAL_51 B   ON A.CustomerEntityID = B.CustomerEntityID 
    WHERE A.FlgPNPA = 'Y'
     AND ( B.FlgProcessing = 'N' )) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.FlgPNPA = 'Y';
   IF utils.object_id('TEMPDB..tt_TEMPTABLEPNPA_14') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLEPNPA_14 ';
   END IF;
   DELETE FROM tt_TEMPTABLEPNPA_14;
   UTILS.IDENTITY_RESET('tt_TEMPTABLEPNPA_14');

   INSERT INTO tt_TEMPTABLEPNPA_14 ( 
   	SELECT A.CustomerEntityID ,
           MIN(A.PNPA_DATE)  PNPA_DATE  ,
           ( SELECT AssetClassAlt_Key 
             FROM DimAssetClass 
              WHERE  AssetClassShortName = 'SUB'
                       AND EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey ) PNPA_Class_Key  
   	  FROM tt_ACCOUNTCAL_50 A
             JOIN tt_CUSTOMERCAL_51 B   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  B.FLGPNPA = 'Y'
              AND ( B.FLGPROCESSING = 'N' )
   	  GROUP BY A.CustomerEntityID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.PNPA_DATE, 'Y', b.PNPA_Class_Key
   FROM A ,tt_CUSTOMERCAL_51 A
          JOIN tt_TEMPTABLEPNPA_14 B   ON A.CustomerEntityID = B.CustomerEntityID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.PNPA_DT = src.PNPA_DATE,
                                A.FlgPNPA = 'Y',
                                a.PNPA_Class_Key = src.PNPA_Class_Key;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.PNPA_Dt, 'Y', b.PNPA_Class_Key
   FROM A ,tt_ACCOUNTCAL_50 a
          JOIN tt_CUSTOMERCAL_51 b   ON a.CustomerEntityID = b.CustomerEntityID
          AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )
          AND b.FlgPNPA = 'Y' ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.PNPA_DATE = src.PNPA_Dt,
                                a.FlgPNPA = 'Y',
                                a.PnpaAssetClassAlt_key = src.PNPA_Class_Key;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'Link By AccountId' || ' ' || B.CustomerAcID AS PNPA_Reason
   FROM A ,tt_ACCOUNTCAL_50 A
          JOIN tt_ACCOUNTCAL_50 B   ON A.CustomerEntityID = B.CustomerEntityID
          AND A.FlgPNPA = 'Y'
          AND A.FlgPNPA = 'Y'

          --AND A.CustomerEntityID= 1376663
          AND A.PNPA_Reason IS NULL
          AND B.PNPA_Reason IS NOT NULL
          AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' ) ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.PNPA_Reason
                                --SELECT A.PNPA_Reason,B.PNPA_Reason, *  
                                 = src.PNPA_Reason;
   /*-------------------UPDATE PNPA FLAG AT UCIF LEVEL------------------------------------------*/
   MERGE INTO B 
   USING (SELECT B.ROWID row_id, 'Y'
   FROM B ,tt_ACCOUNTCAL_50 A
          JOIN tt_CUSTOMERCAL_51 B   ON A.UcifEntityID = B.UcifEntityID 
    WHERE A.FlgPNPA = 'Y'
     AND ( B.FlgProcessing = 'N' )) src
   ON ( B.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET B.FlgPNPA = 'Y';
   IF utils.object_id('TEMPDB..tt_CTE_CUSTOMERWISEBALANCEP_14') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CTE_CUSTOMERWISEBALANCEP_14 ';
   END IF;
   DELETE FROM tt_CTE_CUSTOMERWISEBALANCEP_14;
   UTILS.IDENTITY_RESET('tt_CTE_CUSTOMERWISEBALANCEP_14');

   INSERT INTO tt_CTE_CUSTOMERWISEBALANCEP_14 ( 
   	SELECT A.UcifEntityID ,
           MIN(A.PNPA_DATE)  PNPA_DATE  ,
           ( SELECT AssetClassAlt_Key 
             FROM DimAssetClass 
              WHERE  AssetClassShortName = 'SUB'
                       AND EffectiveFromTimeKey <= v_TIMEKEY
                       AND EffectiveToTimeKey >= v_TIMEKEY ) PNPA_Class_Key  
   	  FROM tt_ACCOUNTCAL_50 A
             JOIN tt_CUSTOMERCAL_51 B   ON A.UcifEntityID = B.UcifEntityID
   	 WHERE  B.FLGPNPA = 'Y'
              AND ( B.FLGPROCESSING = 'N' )
   	  GROUP BY A.UcifEntityID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.PNPA_DATE, 'Y', b.PNPA_Class_Key
   FROM A ,tt_CUSTOMERCAL_51 A
          JOIN tt_CTE_CUSTOMERWISEBALANCEP_14 B   ON A.UcifEntityID = B.UcifEntityID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.PNPA_DT = src.PNPA_DATE,
                                A.FlgPNPA = 'Y',
                                a.PNPA_Class_Key = src.PNPA_Class_Key;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.PNPA_DATE, 'Y', b.PNPA_Class_Key
   FROM A ,tt_ACCOUNTCAL_50 a
          JOIN tt_CTE_CUSTOMERWISEBALANCEP_14 b   ON a.UcifEntityID = b.UcifEntityID
          AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' ) ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.PNPA_DATE = src.PNPA_DATE,
                                a.FlgPNPA = 'Y',
                                a.PnpaAssetClassAlt_key = src.PNPA_Class_Key;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'PERCOLATION BY UCIF ' || ' ' || B.UCIF_ID AS PNPA_Reason
   FROM A ,tt_ACCOUNTCAL_50 a
          JOIN tt_ACCOUNTCAL_50 b   ON a.UcifEntityID = b.UcifEntityID 
    WHERE b.FlgPNPA = 'Y'
     AND A.FlgPNPA = 'Y'
     AND A.PNPA_Reason IS NULL
     AND B.PNPA_Reason IS NOT NULL
     AND ( NVL(A.Asset_Norm, 'NORMAL') <> 'ALWYS_STD' )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.PNPA_Reason = src.PNPA_Reason;
   --------------------------------------------------------------------------------------------------------------------------------------------------------------
   --	Declare @Date date = (select Date from Automate_Advances where Ext_flg = 'Y')
   --Declare @Timekey int = (select Timekey from Automate_Advances where Ext_flg = 'Y')
   IF ( utils.object_id('TEMPDB..tt_UCIF_4') IS NOT NULL ) THEN
    --select distinct UCIF_ID,UcifEntityID into tt_UCIF_4 from tt_ACCOUNTCAL_50
   --where	FlgPNPA ='Y'  and ProductCode in ('CLIBA',	'HLIBA',	'PLIBA',	'VLIBA',	'HLCTC',	'PLCTC',	'VLCTC',	'RFLPL',	
   --										  'PLSPL',	'ELHRP',	'PLODS',	'PLSOD')
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UCIF_4 ';
   END IF;
   DELETE FROM tt_UCIF_4;
   UTILS.IDENTITY_RESET('tt_UCIF_4');

   INSERT INTO tt_UCIF_4 ( 
   	SELECT DISTINCT UCIF_ID ,
                    UcifEntityID 
   	  FROM tt_ACCOUNTCAL_50 
   	 WHERE  FlgPNPA = 'Y' );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_MISDB_PROD.AGRI_PNPA_REPORT_AUTOMATE ';
   INSERT INTO RBL_MISDB_PROD.AGRI_PNPA_REPORT_AUTOMATE
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(SYSDATE,30,p_style=>105) Generation_Date  ,
              UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
              A.UCIF_ID UCIC  ,
              A.RefCustomerID CustomerID  ,
              CustomerName ,
              B.Branchcode ,
              B.CustomerAcid ,
              b.Facilitytype ,
              b.ProductCode ,
              ProductName ,
              Balance ,
              DrawingPower ,
              B.CurrentLimit ,
              ReviewDueDt ,
              b.ContiExcessDt ,
              StockStDt ,
              DebitSinceDt ,
              LastCrDate ,
              CurQtrCredit ,
              CurQtrInt ,
              OverdueAmt ,
              OverDueSinceDt ,
              PrincOutStd ,
              PrincOverdue ,
              PrincOverdueSinceDt ,
              IntOverdue ,
              IntOverdueSinceDt ,
              OtherOverdue ,
              OtherOverdueSinceDt ,
              DPD_IntService ,
              DPD_NoCredit ,
              DPD_Overdrawn ,
              DPD_Overdue ,
              DPD_Renewal ,
              DPD_StockStmt ,
              DPD_PrincOverdue ,
              DPD_IntOverdueSince ,
              DPD_OtherOverdueSince ,
              DPD_Max ,
              PNPA_DATE ,
              a2.AssetClassShortNameEnum PNPA_AssetClass  ,
              REPLACE(PNPA_Reason, ',', ' ') PNPA_Reason  ,
              A.Asset_Norm ,
              b.CD ,
              b.ActSegmentCode ,
              ProductSubGroup ,
              SourceName ,
              ProductGroup ,
              PD.SchemeType ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE S.AcBuRevisedSegmentCode
                 END AcBuRevisedSegmentCode  ,
              ReferencePeriod AssetClassNorm  
       FROM tt_CUSTOMERCAL_51 A
              JOIN tt_ACCOUNTCAL_50 B   ON A.UcifEntityID = B.UcifEntityID
              JOIN tt_UCIF_4 AB   ON b.UcifEntityID = ab.UcifEntityID
              LEFT JOIN AdvAcBasicDetail Bas   ON B.AccountEntityID = Bas.AccountEntityId
              AND Bas.EffectiveFromTimeKey <= v_TIMEKEY
              AND Bas.EffectiveToTimeKey >= v_TIMEKEY
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              AND src.EffectiveFromTimeKey <= v_TIMEKEY
              AND src.EffectiveToTimeKey >= v_TIMEKEY
              LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = b.PRODUCTALT_KEY
              AND PD.EffectiveFromTimeKey <= v_TIMEKEY
              AND PD.EffectiveToTimeKey >= v_TIMEKEY
              LEFT JOIN DimAssetClass a2   ON a2.AssetClassAlt_Key = b.PnpaAssetClassAlt_key
              AND a2.EffectiveFromTimeKey <= v_TIMEKEY
              AND a2.EffectiveToTimeKey >= v_TIMEKEY
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveFromTimeKey <= v_TIMEKEY
              AND S.EffectiveToTimeKey >= v_TIMEKEY
        WHERE  b.Asset_Norm <> 'ALWYS_STD'
                 AND b.FinalAssetClassAlt_Key = 1

                 --and ReferencePeriod >= '180'  --and PNPA_Reason is not null
                 AND NVL(DPD_Max, 0) > 0
                 AND ( SourceName = 'ECBF'
                 OR ( ActSegmentCode IN ( '1402','1410' )

                 AND SourceName = 'Finacle' ) ) );
   OPEN  v_cursor FOR
      SELECT * 
        FROM RBL_MISDB_PROD.AGRI_PNPA_REPORT_AUTOMATE  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select * from tt_ACCOUNTCAL_50
   --where FlgPNPA='Y'
   --and REFPeriodMax >=180
   --select distinct PNPA_Reason from #temp
   --where PNPA_Reason=''

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PNPA_AGRI_REPORT_05012024" TO "ADF_CDR_RBL_STGDB";
