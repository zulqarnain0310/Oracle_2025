--------------------------------------------------------
--  DDL for Procedure SP_SMA_REPORT_INANDOUTDEFAULT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" /*==============================                      
Author : Prashant Baperkar              
CREATE DATE : 13-02-2024                      
MODIFY DATE : 13-02-2024                     
DESCRIPTION : NEW SMA Report                     
[dbo].[SP_SMA_Report_InAndOutDefault]                       
=========================================*/
AS
   ---------------------------------------Overdue Bill & PC Start--------------------------------------------------------
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' )
    );
   v_PROCESSDATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_PrvDayTimekey NUMBER(10,0) := ( SELECT timekey - 1 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

 --accountwise
BEGIN

   -----------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempACCOUNTCAL') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempACCOUNTCAL ';
   END IF;
   DELETE FROM tt_TempACCOUNTCAL;
   UTILS.IDENTITY_RESET('tt_TempACCOUNTCAL');

   INSERT INTO tt_TempACCOUNTCAL ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  FinalAssetClassAlt_Key = 1

              --and           Balance >= 0 
              AND ProductCode <> 'RBSNP' );
   ---------------------added by Prashant----30092024----------------------------------
   IF utils.object_id('TEMPDB..tt_SMA_Classification_Hist') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SMA_Classification_Hist ';
   END IF;
   DELETE FROM tt_SMA_Classification_Hist;
   UTILS.IDENTITY_RESET('tt_SMA_Classification_Hist');

   INSERT INTO tt_SMA_Classification_Hist ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.SMA_Classification_Hist 
   	 WHERE  timekey = v_PrvDayTimekey );
   ---------------------added by Prashant----28062024----------------------------------
   IF utils.object_id('TEMPDB..tt_TempACCOUNTCAL_UCIF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempACCOUNTCAL_UCIF ';
   END IF;
   DELETE FROM tt_TempACCOUNTCAL_UCIF;
   UTILS.IDENTITY_RESET('tt_TempACCOUNTCAL_UCIF');

   INSERT INTO tt_TempACCOUNTCAL_UCIF ( 
   	SELECT DISTINCT UCIF_ID 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  FinalAssetClassAlt_Key > 1 );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_TempACCOUNTCAL a
            JOIN tt_TempACCOUNTCAL_UCIF b   ON A.UCIF_ID = B.UCIF_ID,
          A );
   --WHERE         A.Balance <=0
   UPDATE tt_TempACCOUNTCAL
      SET UCIF_ID = RefCustomerID
    WHERE  NVL(UCIF_ID, ' ') = ' ';
   DELETE FROM tt_Tempucifid4;
   UTILS.IDENTITY_RESET('tt_Tempucifid4');

   INSERT INTO tt_Tempucifid4 ( 
   	SELECT UCIF_ID ,
           MAX(DPD_Max)  DPD_Max  
   	  FROM tt_TempACCOUNTCAL 
   	 WHERE  FinalAssetClassAlt_Key = 1
   	  GROUP BY UCIF_ID

   	   HAVING MAX(dpd_max)  > 0 );
   --Update tt_TempACCOUNTCAL
   --set    FlgSMA='N',DPD_SMA=0,SMA_Class='STD',SMA_Dt=Null,SMA_Reason=Null,
   --DPD_Max=0,DPD_IntOverdueSince=0,DPD_IntService=0,DPD_NoCredit=0,
   --DPD_OtherOverdueSince=0,DPD_Overdrawn=0,DPD_PrincOverdue=0,
   --DPD_Renewal=0,DPD_StockStmt=0,DPD_Overdue=0
   --where  isnull(Balance,0)<=0 and isnull(PrincOutStd,0)<=0
   ----------------------------------- end -------------------------------------------------
   --IF OBJECT_ID('TEMPDB..tt_Tempucifid4') IS NOT NULL  
   --   DROP TABLE    tt_Tempucifid4 
   --select UcifEntityID,Max(DPD_Max)DPD_Max
   --into tt_Tempucifid4
   --from pro.ACCOUNTCAL
   --where  FinalAssetClassAlt_Key=1
   --group by UcifEntityID
   --	IF OBJECT_ID('TEMPDB..tt_TempACCOUNTCAL') IS NOT NULL  
   --   DROP TABLE    tt_TempACCOUNTCAL 
   --select A.* into tt_TempACCOUNTCAL 
   --from          pro.ACCOUNTCAL A with(nolock)
   --inner join    tt_Tempucifid4 B
   --ON            A.UcifEntityID=B.UcifEntityID
   --where         FinalAssetClassAlt_Key=1 AND B.DPD_Max >0
   ----and           Balance > 0  --This condition is commented on 28062024 by Prashant------
   --and ProductCode<>'RBSNP'
   --IF OBJECT_ID('TEMPDB..tt_TempACCOUNTCAL') IS NOT NULL  
   --   DROP TABLE    tt_TempACCOUNTCAL 
   --select * into tt_TempACCOUNTCAL 
   --from          pro.ACCOUNTCAL with(nolock)
   --where         FinalAssetClassAlt_Key=1
   ----and           Balance > 0  --This condition is commented on 28062024 by Prashant------
   --and ProductCode<>'RBSNP'
   ----and           DPD_MAX>0
   ---------------------added by Prashant----28062024----------------------------------
   --IF OBJECT_ID('TEMPDB..tt_TempACCOUNTCAL_UCIF') IS NOT NULL  
   --   DROP TABLE    tt_TempACCOUNTCAL_UCIF
   --select distinct UCIF_ID 
   --into          tt_TempACCOUNTCAL_UCIF
   --from          pro.ACCOUNTCAL 
   --where         FinalAssetClassAlt_Key >1
   --Delete        A
   --from          tt_TempACCOUNTCAL a
   --inner join    tt_TempACCOUNTCAL_UCIF b
   --ON            A.UCIF_ID=B.UCIF_ID
   --WHERE         A.Balance <=0
   ----------------------------------- end -------------------------------------------------
   UPDATE tt_TempACCOUNTCAL
      SET SMA_REASON = CASE 
                            WHEN FACILITYTYPE IN ( 'CC','OD','bill' )

                              AND NVL(DPD_OVERDUE, 0) = NVL(DPD_MAX, 0) THEN 'DEGRADE BY OVERDUE'
          ELSE SMA_REASON
             END
    WHERE  SMA_REASON = 'OTHER';
   -------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_ACCOUNT_MOVEMENT_HISTORY_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNT_MOVEMENT_HISTORY_8 ';
   END IF;
   DELETE FROM tt_ACCOUNT_MOVEMENT_HISTORY_8;
   UTILS.IDENTITY_RESET('tt_ACCOUNT_MOVEMENT_HISTORY_8');

   INSERT INTO tt_ACCOUNT_MOVEMENT_HISTORY_8 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY I
   	 WHERE  I.EffectiveFromTimeKey <= v_TIMEKEY
              AND I.EffectiveToTimeKey >= v_TIMEKEY );
   -------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Temp_ACCOUNT_MOVEMENT_HI') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_ACCOUNT_MOVEMENT_HI ';
   END IF;
   DELETE FROM tt_Temp_ACCOUNT_MOVEMENT_HI;
   UTILS.IDENTITY_RESET('tt_Temp_ACCOUNT_MOVEMENT_HI');

   INSERT INTO tt_Temp_ACCOUNT_MOVEMENT_HI ( 
   	SELECT b.CustomerAcID ,
           MAX(MovementFromDate)  MovementFromDate1  
   	  FROM tt_TempACCOUNTCAL b
             LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a   ON a.CustomerAcID = b.CustomerACID
             AND a.FinalAssetClassAlt_Key = 1
             AND a.MovementFromStatus = 'STD'
             AND a.MovementToStatus IN ( 'SMA_0','SMA_1','SMA_2' )


   	--and          b.SMA_Class in ('SMA_0','SMA_1','SMA_2')
   	GROUP BY b.CustomerAcID );
   IF utils.object_id('TEMPDB..tt_Temp_ACCOUNT_MOVEMENT_HI_1') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_ACCOUNT_MOVEMENT_HI_2 ';
   END IF;
   DELETE FROM tt_Temp_ACCOUNT_MOVEMENT_HI_2;
   UTILS.IDENTITY_RESET('tt_Temp_ACCOUNT_MOVEMENT_HI_2');

   INSERT INTO tt_Temp_ACCOUNT_MOVEMENT_HI_2 ( 
   	SELECT c.CustomerAcID ,
           MIN(A.MovementFromDate)  MovementFromDate  
   	  FROM tt_TempACCOUNTCAL b
             JOIN PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a   ON a.CustomerAcID = b.CustomerACID
             JOIN tt_Temp_ACCOUNT_MOVEMENT_HI c   ON c.CustomerAcID = b.CustomerACID
             AND a.FinalAssetClassAlt_Key = 1

             --and          a.MovementFromStatus='STD'
             AND a.MovementToStatus IN ( 'SMA_0','SMA_1','SMA_2' )


   	--Where        b.SMA_Class in ('SMA_0','SMA_1','SMA_2')
   	WHERE  c.MovementFromDate1 IS NULL
   	  GROUP BY c.CustomerAcID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate
   FROM A ,tt_Temp_ACCOUNT_MOVEMENT_HI a
          JOIN tt_Temp_ACCOUNT_MOVEMENT_HI_2 b   ON a.CustomerAcID = b.CustomerACID 
    WHERE a.MovementFromDate1 IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.MovementFromDate1 = src.MovementFromDate;
   -------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Temp_ACCOUNT_MOVEMENT_HI_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_ACCOUNT_MOVEMENT_HI_3 ';
   END IF;
   DELETE FROM tt_Temp_ACCOUNT_MOVEMENT_HI_3;
   UTILS.IDENTITY_RESET('tt_Temp_ACCOUNT_MOVEMENT_HI_3');

   INSERT INTO tt_Temp_ACCOUNT_MOVEMENT_HI_3 ( 
   	SELECT A.CustomerAcID ,
           MAX(MovementFromDate)  MovementFromDate_CCOD  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a
             JOIN tt_TempACCOUNTCAL b   ON a.CustomerAcID = b.CustomerACID
   	 WHERE  a.FinalAssetClassAlt_Key = 1
              AND a.MovementFromStatus IN ( 'STD','SMA_0' )

              AND a.MovementToStatus IN ( 'SMA_1','SMA_2' )

              AND b.SourceAlt_Key <> 6
              AND b.FacilityType IN ( 'CC','OD' )

              AND NVL(b.DPD_Overdrawn, 0) >= 31

   	--and          b.SMA_Class in ('SMA_0','SMA_1','SMA_2')
   	GROUP BY a.CustomerAcID );
   -----------------------------Added on 02082024------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Temp_ACCOUNT_MOVEMENT_HI_3_30') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_ACCOUNT_MOVEMENT_HI_4 ';
   END IF;
   DELETE FROM tt_Temp_ACCOUNT_MOVEMENT_HI_4;
   UTILS.IDENTITY_RESET('tt_Temp_ACCOUNT_MOVEMENT_HI_4');

   INSERT INTO tt_Temp_ACCOUNT_MOVEMENT_HI_4 ( 
   	SELECT CustomerAcID ,
           MAX(MovementFromDate_CCOD_30)  MovementFromDate_CCOD_30  
   	  FROM ( SELECT B.CustomerAcID ,
                    CASE 
                         WHEN MovementToStatus IN ( 'SMA_1','SMA_2' )
                          THEN MovementFromDate
                    ELSE NULL
                       END MovementFromDate_CCOD_30  
             FROM tt_TempACCOUNTCAL B
                    LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a   ON a.CustomerAcID = b.CustomerACID
                    AND a.FinalAssetClassAlt_Key = 1
                    AND a.MovementFromDate < v_Date

             --and          a.MovementFromStatus in ('STD','SMA_0')

             --and          a.MovementToStatus in ('SMA_1','SMA_2')
             WHERE  b.SourceAlt_Key <> 6
                      AND b.FacilityType IN ( 'CC','OD' )

                      AND NVL(b.DPD_Overdrawn, 0) <= 30 ) 
           --AND          B.CustomerAcID='609000706871'
           A
   	  GROUP BY CustomerAcID );
   -------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempMaxEntityKey') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempMaxEntityKey ';
   END IF;
   DELETE FROM tt_TempMaxEntityKey;
   UTILS.IDENTITY_RESET('tt_TempMaxEntityKey');

   INSERT INTO tt_TempMaxEntityKey ( 
   	SELECT A.CustomerAcID ,
           MAX(A.EntityKey)  EntityKey  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a
             JOIN tt_TempACCOUNTCAL b   ON a.CustomerAcID = b.CustomerACID
   	 WHERE  A.FinalAssetClassAlt_Key = 1
              AND A.MovementFromStatus <> A.MovementToStatus
   	  GROUP BY a.CustomerAcID );
   IF utils.object_id('TEMPDB..tt_Temp_ACCOUNT_MOVEMENT_HI_5') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_ACCOUNT_MOVEMENT_HI_5 ';
   END IF;
   DELETE FROM tt_Temp_ACCOUNT_MOVEMENT_HI_5;
   UTILS.IDENTITY_RESET('tt_Temp_ACCOUNT_MOVEMENT_HI_5');

   INSERT INTO tt_Temp_ACCOUNT_MOVEMENT_HI_5 ( 
   	SELECT A.CustomerAcID ,
           MovementFromStatus ,
           MovementToStatus ,
           MovementFromDate ,
           MovementToDate 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a
             JOIN tt_TempMaxEntityKey b   ON a.EntityKey = b.EntityKey );
   ------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Accountcal_hist_dpd') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Accountcal_hist_dpd ';
   END IF;
   DELETE FROM tt_Accountcal_hist_dpd;
   UTILS.IDENTITY_RESET('tt_Accountcal_hist_dpd');

   INSERT INTO tt_Accountcal_hist_dpd ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.Accountcal_hist_DPD 
   	 WHERE  TimeKey = v_TIMEKEY );
   -----------------------------------------------------------------------------------------------------------
   --	IF OBJECT_ID('TEMPDB..#ALL_CUSTOMER_EXPOSURE_DETAIL') IS NOT NULL  
   --    DROP TABLE #ALL_CUSTOMER_EXPOSURE_DETAIL 
   --select * INTO #ALL_CUSTOMER_EXPOSURE_DETAIL
   --from          ALL_CUSTOMER_EXPOSURE_DETAIL
   --where         EffectiveFromTimeKey <= @Timekey
   --and           EffectiveToTimeKey >= @Timekey
   ------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempDPD_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempDPD_2 ';
   END IF;
   DELETE FROM tt_TempDPD_2;
   UTILS.IDENTITY_RESET('tt_TempDPD_2');

   INSERT INTO tt_TempDPD_2 ( 
   	SELECT b.UcifEntityID ,
           b.UCIF_ID ,
           b.CustomerEntityID ,
           b.RefCustomerID ,
           b.CustomerAcID ,
           b.Asset_Norm ,
           b.Balance ,
           b.PrincOutStd ,
           A.* 
   	  FROM tt_TempACCOUNTCAL b
             LEFT JOIN tt_Accountcal_hist_dpd a   ON a.AccountEntityid = b.AccountEntityID
             AND a.TimeKey = v_Timekey );
   --where         b.FinalAssetClassAlt_Key=1
   --Update tt_TempDPD_2
   --set    
   --DPD_Max=0,DPD_IntOverdueSince=0,DPD_IntService=0,DPD_NoCredit=0,
   --DPD_OtherOverdueSince=0,DPD_Overdrawn=0,DPD_PrincOverdue=0,
   --DPD_Renewal=0,DPD_StockStmt=0,DPD_Overdue=0
   --where  isnull(Balance,0)<=0 and isnull(PrincOutStd,0)<=0

   EXECUTE IMMEDIATE ' ALTER TABLE tt_TempDPD_2 
      ADD ( [DPD_UCIF_ID NUMBER(10,0) , MAX_DPD_1 NUMBER(10,0) ] ) ';
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdue, 0)
   WHEN ( NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_StockStmt, 0)
   WHEN ( NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(DPD_PrincOverdue, 0)
   WHEN ( NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_IntOverDueSince, 0)
   ELSE NVL(A.DPD_OtherOverDueSince, 0)
      END) AS MAX_DPD_1
   FROM A ,tt_TempDPD_2 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET MAX_DPD_1 = src.MAX_DPD_1;
   ---------------------------------------------------------------------------------------------------------
   ----/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_TempDPD_2
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) <= 0;
   --UPDATE A SET DPD_Overdrawn=0 FROM tt_TempDPD_2 A where ISNULL(DPD_Overdrawn,0)<=30
   --UPDATE tt_TempDPD_2 SET DPD_Overdrawn=0 WHERE ISNULL(DPD_Overdrawn,0)<=30
   UPDATE tt_TempDPD_2
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) <= 0;
   UPDATE tt_TempDPD_2
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) <= 0;
   ----	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   --UPDATE A SET A.DPD_Max=0
   -- FROM tt_TempDPD_2 A 
   --update a set DPD_Overdrawn=0,DPD_Overdue=0,DPD_IntService=0,DPD_NoCredit=0,DPD_Renewal=0
   --FROM tt_TempDPD_2 A where Asset_Norm='ALWYS_STD'
   ----		/*----------------FIND MAX DPD---------------------------------------*/
   --UPDATE   A SET A.DPD_Max= (CASE WHEN isnull(A.DPD_Overdrawn,0)>isnull(A.DPD_Overdue,0)
   --									THEN isnull(A.DPD_Overdrawn,0)
   --								ELSE isnull(A.DPD_Overdue,0)
   --							END)
   --FROM  tt_TempDPD_2 a 
   --WHERE  (isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0)
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_UCIF_ID_19  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_UCIF_ID_19;
   UTILS.IDENTITY_RESET('tt_DPD_UCIF_ID_19');

   INSERT INTO tt_DPD_UCIF_ID_19 ( 
   	SELECT UCIF_ID ,
           MAX(DPD_MAX)  DPD_UCIF_ID  
   	  FROM tt_TempDPD_2 
   	  GROUP BY UCIF_ID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.DPD_UCIF_ID
   FROM A ,tt_TempDPD_2 A
          JOIN tt_DPD_UCIF_ID_19 B   ON A.UCIF_ID = B.UCIF_ID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_UCIF_ID = src.DPD_UCIF_ID;
   ------------------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..#TEMP') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_34 ';
   END IF;
   DELETE FROM tt_TEMP_34;
   UTILS.IDENTITY_RESET('tt_TEMP_34');

   INSERT INTO tt_TEMP_34 ( 
   	SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
           A.UCIF_ID UCIC  ,
           A.RefCustomerID CIF_ID  ,
           REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
           B.BranchCode Branch_Code  ,
           REPLACE(BranchName, ',', ' ') Branch_Name  ,
           CustomerAcID Account_No_  ,
           SourceName Source_System  ,
           B.FacilityType Facility  ,
           SchemeType Scheme_Type  ,
           B.ProductCode Scheme_Code  ,
           ProductName Scheme_Description  ,
           ActSegmentCode Seg_Code  ,
           B.Asset_Norm ,
           CASE 
                WHEN SourceName = 'FIS' THEN 'FI'
                WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
           ELSE AcBuSegmentDescription
              END Segment_Description  ,
           CASE 
                WHEN SourceName = 'FIS' THEN 'FI'

                --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode IN ( '777','780' )
                 THEN 'Retail'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode NOT IN ( '777','780' )
                 THEN 'Credit Card'
           ELSE AcBuRevisedSegmentCode
              END Business_Segment  ,
           DPD_Max Account_DPD  ,
           --,FinalNpaDt as [NPA Date]
           Balance Outstanding  ,
           --,NetBalance as [Principal Outstanding]
           PrincOutStd Principal_Outstanding  ,
           DrawingPower Drawing_Power  ,
           CurrentLimit Sanction_Limit  ,
           CASE 
                WHEN SourceName = 'Finacle'
                  AND SchemeType = 'ODA' THEN (CASE 
                                                    WHEN (NVL(b.Balance, 0) - (CASE 
                                                                                    WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                                                    ELSE NVL(b.CurrentLimit, 0)
                                                       END)) <= 0 THEN 0
                ELSE NVL(b.Balance, 0) - (CASE 
                                               WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                ELSE NVL(b.CurrentLimit, 0)
                   END)
                   END)
           ELSE 0
              END OverDrawn_Amount  ,
           DPD_Overdrawn ,
           UTILS.CONVERT_TO_NVARCHAR2(ContiExcessDt,30,p_style=>105) Limit_DP_Overdrawn_Date  ,
           UTILS.CONVERT_TO_NVARCHAR2(ReviewDueDt,30,p_style=>105) Limit_Expiry_Date  ,
           DPD_Renewal DPD_Limit_Expiry  ,
           UTILS.CONVERT_TO_NVARCHAR2(StockStDt,30,p_style=>105) Stock_Statement_valuation_date  ,
           DPD_StockStmt DPD_Stock_Statement_expiry  ,
           UTILS.CONVERT_TO_NVARCHAR2(DebitSinceDt,30,p_style=>105) Debit_Balance_Since_Date  ,
           UTILS.CONVERT_TO_NVARCHAR2(LastCrDate,30,p_style=>105) Last_Credit_Date  ,
           DPD_NoCredit DPD_No_Credit  ,
           CurQtrCredit Current_quarter_credit  ,
           CurQtrInt Current_quarter_interest  ,
           (CASE 
                 WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
           ELSE (CurQtrInt - CurQtrCredit)
              END) Interest_Not_Serviced  ,
           DPD_IntService DPD_out_of_order  ,
           UTILS.CONVERT_TO_NVARCHAR2(IntNotServicedDt,30,p_style=>105) CC_OD_Interest_Service  ,
           OverdueAmt Overdue_Amount  ,
           UTILS.CONVERT_TO_NVARCHAR2(OverDueSinceDt,30,p_style=>105) Overdue_Date  ,
           DPD_Overdue ,
           PrincOverdue Principal_Overdue  ,
           UTILS.CONVERT_TO_NVARCHAR2(PrincOverdueSinceDt,30,p_style=>105) Principal_Overdue_Date  ,
           DPD_PrincOverdue DPD_Principal_Overdue  ,
           IntOverdue Interest_Overdue  ,
           UTILS.CONVERT_TO_NVARCHAR2(IntOverdueSinceDt,30,p_style=>105) Interest_Overdue_Date  ,
           DPD_IntOverdueSince DPD_Interest_Overdue  ,
           OtherOverdue Other_OverDue  ,
           UTILS.CONVERT_TO_NVARCHAR2(OtherOverdueSinceDt,30,p_style=>105) Other_OverDue_Date  ,
           DPD_OtherOverdueSince DPD_Other_Overdue  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN OverdueAmt
           ELSE 0
              END) Bill_PC_Overdue_Amount  ,
           ' ' Overdue_Bill_PC_ID  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN UTILS.CONVERT_TO_NVARCHAR2(OverDueSinceDt,30,p_style=>105)
           ELSE ' '
              END) Bill_PC_Overdue_Date  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN DPD_Overdue
           ELSE 0
              END) DPD_Bill_PC  ,
           a2.AssetClassName Asset_Classification  ,
           --,REPLACE(isnull(A.DegReason,b.NPA_Reason),',','') as [Degrade Reason]
           b.REFPERIODOVERDUE NPA_Norms  
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN tt_TempACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
           --and isnull(b.WriteOffAmount,0)=0

             LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
             AND ( src.EffectiveFromTimeKey <= v_Timekey
             AND src.EffectiveToTimeKey >= v_TimeKey )
             LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
             AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
             LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
             AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
             LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
             AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
             LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
             AND S.EffectiveToTimeKey = 49999
             LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
             AND X.EffectiveToTimeKey = 49999
   	 WHERE  B.FinalAssetClassAlt_Key = 1
              AND B.SourceAlt_Key IN ( 1,3 )

              AND b.DPD_Max > 0
              AND Balance > 0 );
   DELETE tt_TEMP_34

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91

             --AND           GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0)-60,ISNULL([DPD_Stock Statement expiry],0)-90,ISNULL([DPD_Limit Expiry],0)-90) <=0
             AND NVL(DPD_Overdrawn, 0) <= 0
             AND NVL(DPD_No_Credit, 0) - 60 <= 0
             AND NVL(DPD_Stock_Statement_expiry, 0) - 90 <= 0
             AND NVL(DPD_Limit_Expiry, 0) - 90 <= 0;
   DELETE tt_TEMP_34

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91
             AND ( DPD_Stock_Statement_expiry <= 90
             AND DPD_Limit_Expiry <= 90
             AND NVL(DPD_No_Credit, 0) <= 60 )
             AND ( NVL(DPD_Overdrawn, 0) = 0
             AND NVL(DPD_Interest_Overdue, 0) = 0
             AND NVL(DPD_Other_Overdue, 0) = 0
             AND NVL(DPD_Overdrawn, 0) = 0
             AND NVL(DPD_Overdue, 0) = 0
             AND NVL(DPD_Principal_Overdue, 0) = 0 );
   IF utils.object_id('TEMPDB..tt_TEMP_343') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3_4 ';
   END IF;
   DELETE FROM tt_temp3_4;
   UTILS.IDENTITY_RESET('tt_temp3_4');

   INSERT INTO tt_temp3_4 SELECT RefSystemAcid ,
                                 OverDueSinceDt ,
                                 BillRefNo ,
                                 BillDueDt ,
                                 BillExtendedDueDt ,
                                 Balance ,
                                 CASE 
                                      WHEN NVL(BillDueDt, '1190-01-01') > NVL(BillExtendedDueDt, '1190-01-01') THEN BillDueDt
                                 ELSE BillExtendedDueDt
                                    END BillOverdueDt  ,
                                 CASE 
                                      WHEN CASE 
                                                WHEN NVL(BillDueDt, '1190-01-01') > NVL(BillExtendedDueDt, '1190-01-01') THEN BillDueDt
                                      ELSE BillExtendedDueDt
                                         END IS NOT NULL THEN utils.datediff('DAY', CASE 
                                                                                         WHEN NVL(BillDueDt, '1190-01-01') > NVL(BillExtendedDueDt, '1190-01-01') THEN BillDueDt
                                                                             ELSE BillExtendedDueDt
                                                                                END, v_Date) + 1
                                 ELSE 0
                                    END DPD_Overdue  
        FROM AdvFacBillDetail 

      --where RefSystemAcid='0070AACB0100029'
      WHERE  EffectiveFromTimeKey <= v_Timekey
               AND EffectiveToTimeKey >= v_Timekey
               AND NVL(BALANCE, 0) > 0
               AND (CASE 
                         WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
             ELSE BillExtendedDueDt
                END) <= v_Date
        ORDER BY BillDueDt;
   IF utils.object_id('TEMPDB..tt_PC_OVERDUE_39') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PC_OVERDUE_39 ';
   END IF;
   DELETE FROM tt_PC_OVERDUE_39;
   UTILS.IDENTITY_RESET('tt_PC_OVERDUE_39');

   INSERT INTO tt_PC_OVERDUE_39 ( 
   	SELECT RefSystemAcid ,
           OverDueSinceDt ,
           PCRefNo ,
           PCDueDt ,
           PCExtendedDueDt ,
           BALANCE ,
           CASE 
                WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
           ELSE PCExtendedDueDt
              END PCOVERDUEDUEDT  ,
           CASE 
                WHEN (CASE 
                           WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                ELSE PCExtendedDueDt
                   END) IS NOT NULL THEN utils.datediff('DAY', (CASE 
                                                                     WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                                                        ELSE PCExtendedDueDt
                                                           END), v_Date) + 1
           ELSE 0
              END DPD_Overdue  
   	  FROM RBL_MISDB_PROD.AdvFacPCDetail 
   	 WHERE  EFFECTIVEFROMTIMEKEY <= v_Timekey
              AND EFFECTIVETOTIMEKEY >= v_Timekey
              AND NVL(BALANCE, 0) > 0
              AND (CASE 
                        WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
            ELSE PCExtendedDueDt
               END) <= v_Date );
   ------------------------------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Final_Output_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_Output_2 ';
   END IF;
   DELETE FROM tt_Final_Output_2;
   UTILS.IDENTITY_RESET('tt_Final_Output_2');

   INSERT INTO tt_Final_Output_2 ( 
   	SELECT * 
   	  FROM ( SELECT A."Report date" ,
                    UCIC ,
                    CIF_ID ,
                    Borrower_Name ,
                    Branch_Code ,
                    Branch_Name ,
                    Account_No_ ,
                    Source_System ,
                    Facility ,
                    Scheme_Type ,
                    Scheme_Code ,
                    Scheme_Description ,
                    Seg_Code ,
                    Asset_Norm ,
                    Segment_Description ,
                    Business_Segment ,
                    Account_DPD ,
                    Outstanding ,
                    Principal_Outstanding ,
                    Drawing_Power ,
                    Sanction_Limit ,
                    OverDrawn_Amount ,
                    DPD_Overdrawn ,
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END DPD_Limit_Expiry  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END DPD_Stock_Statement_expiry  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN 0
                    ELSE A."Overdue Amount"
                       END Overdue_Amount  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."Overdue Date"
                       END Overdue_Date  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN 0
                    ELSE A."Interest Overdue"
                       END Interest_Overdue  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."Interest Overdue Date"
                       END Interest_Overdue_Date  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."DPD_Interest Overdue"
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    CASE 
                         WHEN NVL(b.Balance, 0) = 0 THEN Bill_PC_Overdue_Amount
                    ELSE Balance
                       END Bill_PC_Overdue_Amount  ,
                    CASE 
                         WHEN NVL(BillRefNo, ' ') = ' ' THEN Overdue_Bill_PC_ID
                    ELSE BillRefNo
                       END Overdue_Bill_PC_ID  ,
                    CASE 
                         WHEN NVL(BillOverdueDt, '1900-01-01') = '1900-01-01' THEN Bill_PC_Overdue_Date
                    ELSE BillOverdueDt
                       END Bill_PC_Overdue_Date  ,
                    CASE 
                         WHEN NVL(b.dpd_Overdue, 0) = 0 THEN DPD_Bill_PC
                    ELSE b.dpd_Overdue
                       END DPD_Bill_PC  ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_34 a
                    LEFT JOIN tt_temp3_4 b   ON a.Account_No_ = b.RefSystemAcid
              WHERE  Scheme_Type = 'fba'
             UNION ALL 
             SELECT a.Report_date ,
                    UCIC ,
                    CIF_ID ,
                    Borrower_Name ,
                    Branch_Code ,
                    Branch_Name ,
                    Account_No_ ,
                    Source_System ,
                    Facility ,
                    Scheme_Type ,
                    Scheme_Code ,
                    Scheme_Description ,
                    Seg_Code ,
                    Asset_Norm ,
                    Segment_Description ,
                    Business_Segment ,
                    Account_DPD ,
                    Outstanding ,
                    Principal_Outstanding ,
                    Drawing_Power ,
                    Sanction_Limit ,
                    OverDrawn_Amount ,
                    DPD_Overdrawn ,
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END col  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END col  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Overdue_Amount
                       END Overdue_Amount  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Overdue_Date
                       END Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Interest_Overdue
                       END Interest_Overdue  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Interest_Overdue_Date
                       END Interest_Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Interest_Overdue
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    CASE 
                         WHEN NVL(b.Balance, 0) = 0 THEN Bill_PC_Overdue_Amount
                    ELSE Balance
                       END Bill_PC_Overdue_Amount  ,
                    CASE 
                         WHEN NVL(PCRefNo, ' ') = ' ' THEN Overdue_Bill_PC_ID
                    ELSE PCRefNo
                       END Overdue_Bill_PC_ID  ,
                    CASE 
                         WHEN NVL(PCOVERDUEDUEDT, '1900-01-01') = '1900-01-01' THEN Bill_PC_Overdue_Date
                    ELSE PCOVERDUEDUEDT
                       END Bill_PC_Overdue_Date  ,
                    CASE 
                         WHEN NVL(b.dpd_Overdue, 0) = 0 THEN DPD_Bill_PC
                    ELSE b.dpd_Overdue
                       END DPD_Bill_PC  ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_34 a
                    LEFT JOIN tt_PC_OVERDUE_39 b   ON a.Account_No_ = b.RefSystemAcid
              WHERE  Scheme_Type = 'PCA'
             UNION ALL 
             SELECT a.Report_date ,
                    UCIC ,
                    CIF_ID ,
                    Borrower_Name ,
                    Branch_Code ,
                    Branch_Name ,
                    Account_No_ ,
                    Source_System ,
                    Facility ,
                    Scheme_Type ,
                    Scheme_Code ,
                    Scheme_Description ,
                    Seg_Code ,
                    Asset_Norm ,
                    Segment_Description ,
                    Business_Segment ,
                    Account_DPD ,
                    Outstanding ,
                    Principal_Outstanding ,
                    Drawing_Power ,
                    Sanction_Limit ,
                    OverDrawn_Amount ,
                    DPD_Overdrawn ,
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END col  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END col  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Overdue_Amount
                       END Overdue_Amount  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Overdue_Date
                       END Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Interest_Overdue
                       END Interest_Overdue  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Interest_Overdue_Date
                       END Interest_Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Interest_Overdue
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    Bill_PC_Overdue_Amount ,
                    Overdue_Bill_PC_ID ,
                    Bill_PC_Overdue_Date ,
                    DPD_Bill_PC ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_34 a
              WHERE  ( Scheme_Type NOT IN ( 'PCA','FBA' )

                       OR Scheme_Type IS NULL ) ) BB );
   IF utils.object_id('TEMPDB..#TEMPSCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPSCF_2 ';
   END IF;
   DELETE FROM tt_TEMPSCF_2;
   UTILS.IDENTITY_RESET('tt_TEMPSCF_2');

   INSERT INTO tt_TEMPSCF_2 ( 
   	SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
           A.UCIF_ID UCIC  ,
           A.RefCustomerID CIF_ID  ,
           REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
           B.BranchCode Branch_Code  ,
           REPLACE(BranchName, ',', ' ') Branch_Name  ,
           CustomerAcID Account_No_  ,
           SourceName Source_System  ,
           B.FacilityType Facility  ,
           SchemeType Scheme_Type  ,
           B.ProductCode Scheme_Code  ,
           ProductName Scheme_Description  ,
           ActSegmentCode Seg_Code  ,
           B.Asset_Norm ,
           CASE 
                WHEN SourceName = 'FIS' THEN 'FI'
                WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
           ELSE AcBuSegmentDescription
              END Segment_Description  ,
           CASE 
                WHEN SourceName = 'FIS' THEN 'FI'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode IN ( '777','780' )
                 THEN 'Retail'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode NOT IN ( '777','780' )
                 THEN 'Credit Card'
           ELSE AcBuRevisedSegmentCode
              END Business_Segment  ,
           DPD_Max Account_DPD  ,
           b.Balance Outstanding  ,
           PrincOutStd Principal_Outstanding  ,
           DrawingPower Drawing_Power  ,
           CurrentLimit Sanction_Limit  ,
           CASE 
                WHEN SourceName = 'Finacle'
                  AND SchemeType = 'ODA' THEN (CASE 
                                                    WHEN (NVL(b.Balance, 0) - (CASE 
                                                                                    WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                                                    ELSE NVL(b.CurrentLimit, 0)
                                                       END)) <= 0 THEN 0
                ELSE NVL(b.Balance, 0) - (CASE 
                                               WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                ELSE NVL(b.CurrentLimit, 0)
                   END)
                   END)
           ELSE 0
              END OverDrawn_Amount  ,
           DPD_Overdrawn ,
           UTILS.CONVERT_TO_NVARCHAR2(ContiExcessDt,30,p_style=>105) Limit_DP_Overdrawn_Date  ,
           UTILS.CONVERT_TO_NVARCHAR2(ReviewDueDt,30,p_style=>105) Limit_Expiry_Date  ,
           DPD_Renewal DPD_Limit_Expiry  ,
           UTILS.CONVERT_TO_NVARCHAR2(StockStDt,30,p_style=>105) Stock_Statement_valuation_date  ,
           DPD_StockStmt DPD_Stock_Statement_expiry  ,
           UTILS.CONVERT_TO_NVARCHAR2(DebitSinceDt,30,p_style=>105) Debit_Balance_Since_Date  ,
           UTILS.CONVERT_TO_NVARCHAR2(LastCrDate,30,p_style=>105) Last_Credit_Date  ,
           DPD_NoCredit DPD_No_Credit  ,
           CurQtrCredit Current_quarter_credit  ,
           CurQtrInt Current_quarter_interest  ,
           (CASE 
                 WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
           ELSE (CurQtrInt - CurQtrCredit)
              END) Interest_Not_Serviced  ,
           DPD_IntService DPD_out_of_order  ,
           UTILS.CONVERT_TO_NVARCHAR2(IntNotServicedDt,30,p_style=>105) CC_OD_Interest_Service  ,
           OverdueAmt Overdue_Amount  ,
           UTILS.CONVERT_TO_NVARCHAR2(b.OverDueSinceDt,30,p_style=>105) Overdue_Date  ,
           DPD_Overdue ,
           PrincOverdue Principal_Overdue  ,
           UTILS.CONVERT_TO_NVARCHAR2(PrincOverdueSinceDt,30,p_style=>105) Principal_Overdue_Date  ,
           DPD_PrincOverdue DPD_Principal_Overdue  ,
           IntOverdue Interest_Overdue  ,
           UTILS.CONVERT_TO_NVARCHAR2(IntOverdueSinceDt,30,p_style=>105) Interest_Overdue_Date  ,
           DPD_IntOverdueSince DPD_Interest_Overdue  ,
           OtherOverdue Other_OverDue  ,
           UTILS.CONVERT_TO_NVARCHAR2(OtherOverdueSinceDt,30,p_style=>105) Other_OverDue_Date  ,
           DPD_OtherOverdueSince DPD_Other_Overdue  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN OverdueAmt
           ELSE 0
              END) Bill_PC_Overdue_Amount  ,
           ' ' Overdue_Bill_PC_ID  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN UTILS.CONVERT_TO_NVARCHAR2(b.OverDueSinceDt,30,p_style=>105)
           ELSE ' '
              END) Bill_PC_Overdue_Date  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN DPD_Overdue
           ELSE 0
              END) DPD_Bill_PC  ,
           a2.AssetClassName Asset_Classification  ,
           b.REFPERIODOVERDUE NPA_Norms  
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN tt_TempACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
           --and isnull(b.WriteOffAmount,0)=0

             JOIN CurDat_RBL_MISDB_PROD.AdvFacBillDetail FB   ON b.AccountEntityID = FB.AccountEntityId
             AND FB.BillNatureAlt_Key = 9
             LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
             AND ( src.EffectiveFromTimeKey <= v_Timekey
             AND src.EffectiveToTimeKey >= v_TimeKey )
             LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
             AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
             LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
             AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
             LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
             AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
             LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
             AND S.EffectiveToTimeKey = 49999
             LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
             AND X.EffectiveToTimeKey = 49999
   	 WHERE  B.FinalAssetClassAlt_Key = 1
              AND B.SourceAlt_Key = 1
              AND b.DPD_Max > 0
              AND b.Balance > 0 );
   DELETE tt_TEMPSCF_2

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91

             --AND           GREATEST(ISNULL(DPD_Overdue,0),ISNULL([DPD_Limit Expiry],0)-90) <=0

             --AND           ISNULL(DPD_Overdue,0) <=0 and ISNULL([DPD_Limit Expiry],0)-90 <=0
             AND CASE 
                      WHEN NVL(DPD_Overdue, 0) > (NVL(DPD_Limit_Expiry, 0) - 90) THEN NVL(DPD_Overdue, 0)
           ELSE (NVL(DPD_Limit_Expiry, 0) - 90)
              END <= 0;
   ---------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_343SCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3SCF_2 ';
   END IF;
   DELETE FROM tt_temp3SCF_2;
   UTILS.IDENTITY_RESET('tt_temp3SCF_2');

   INSERT INTO tt_temp3SCF_2 SELECT RefSystemAcid ,
                                    OverDueSinceDt ,
                                    BillRefNo ,
                                    BillDueDt ,
                                    BillExtendedDueDt ,
                                    Balance ,
                                    CASE 
                                         WHEN NVL(BillDueDt, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
                                    ELSE InterestOverdueDate
                                       END BillOverdueDt  ,
                                    CASE 
                                         WHEN CASE 
                                                   WHEN NVL(BillDueDt, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
                                         ELSE InterestOverdueDate
                                            END IS NOT NULL THEN utils.datediff('DAY', CASE 
                                                                                            WHEN NVL(BillDueDt, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
                                                                                ELSE InterestOverdueDate
                                                                                   END, v_Date) + 1
                                    ELSE 0
                                       END DPD_Overdue  ,
                                    ReviewDuedate ,
                                    OverdueInterest OverdueInterest1  ,
                                    InterestOverdueDate InterestOverdueDate1  ,
                                    BillDueDt princOverDueDate  ,
                                    Balance - OverdueInterest princOverDue_Amount  
        FROM AdvFacBillDetail 

      --where RefSystemAcid='0070AACB0100029'
      WHERE  EffectiveFromTimeKey <= v_Timekey
               AND EffectiveToTimeKey >= v_Timekey
               AND NVL(BALANCE, 0) > 0
               AND BillNatureAlt_Key = 9
               AND (CASE 
                         WHEN NVL(BILLDUEDT, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
             ELSE InterestOverdueDate
                END) <= v_Date
        ORDER BY BillDueDt;
   -----------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Final_Output_2SCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_OutputSCF_2 ';
   END IF;
   DELETE FROM tt_Final_OutputSCF_2;
   UTILS.IDENTITY_RESET('tt_Final_OutputSCF_2');

   INSERT INTO tt_Final_OutputSCF_2 ( 
   	SELECT DISTINCT A."Report date" ,
                    UCIC ,
                    CIF_ID ,
                    Borrower_Name ,
                    Branch_Code ,
                    Branch_Name ,
                    Account_No_ ,
                    'SCF' Source_System  ,
                    Facility ,
                    Scheme_Type ,
                    Scheme_Code ,
                    Scheme_Description ,
                    Seg_Code ,
                    Asset_Norm ,
                    Segment_Description ,
                    Business_Segment ,
                    Account_DPD ,
                    Outstanding ,
                    Principal_Outstanding ,
                    Drawing_Power ,
                    Sanction_Limit ,
                    OverDrawn_Amount ,
                    DPD_Overdrawn ,
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END DPD_Limit_Expiry  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END DPD_Stock_Statement_expiry  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    A."Overdue Amount" ,
                    A."Overdue Date" ,
                    A.DPD_Overdue ,
                    b.princOverDue_Amount Principal_Overdue  ,
                    b.princOverDueDate Principal_Overdue_Date  ,
                    CASE 
                         WHEN CASE 
                                   WHEN B.princOverDueDate IS NOT NULL THEN utils.datediff('DAY', princOverDueDate, v_Date) + 1
                         ELSE 0
                            END < 0 THEN 0
                    ELSE CASE 
                              WHEN B.princOverDueDate IS NOT NULL THEN utils.datediff('DAY', princOverDueDate, v_Date) + 1
                    ELSE 0
                       END
                       END DPD_Principal_Overdue  ,
                    OverdueInterest1 Interest_Overdue  ,
                    InterestOverdueDate1 Interest_Overdue_Date  ,
                    CASE 
                         WHEN CASE 
                                   WHEN B.InterestOverdueDate1 IS NOT NULL THEN utils.datediff('DAY', InterestOverdueDate1, v_Date) + 1
                         ELSE 0
                            END < 0 THEN 0
                    ELSE CASE 
                              WHEN B.InterestOverdueDate1 IS NOT NULL THEN utils.datediff('DAY', InterestOverdueDate1, v_Date) + 1
                    ELSE 0
                       END
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    CASE 
                         WHEN NVL(b.Balance, 0) = 0 THEN Bill_PC_Overdue_Amount
                    ELSE Balance
                       END Bill_PC_Overdue_Amount  ,
                    CASE 
                         WHEN NVL(BillRefNo, ' ') = ' ' THEN Overdue_Bill_PC_ID
                    ELSE BillRefNo
                       END Overdue_Bill_PC_ID  ,
                    CASE 
                         WHEN NVL(BillOverdueDt, '1900-01-01') = '1900-01-01' THEN Bill_PC_Overdue_Date
                    ELSE BillOverdueDt
                       END Bill_PC_Overdue_Date  ,
                    CASE 
                         WHEN NVL(b.dpd_Overdue, 0) = 0 THEN DPD_Bill_PC
                    ELSE b.dpd_Overdue
                       END DPD_Bill_PC  ,
                    Asset_Classification ,
                    NPA_Norms 
   	  FROM tt_TEMPSCF_2 a
             LEFT JOIN tt_temp3SCF_2 b   ON a.Account_No_ = b.RefSystemAcid );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'SCF'
   FROM A ,tt_Final_Output_2 a
          JOIN CurDat_RBL_MISDB_PROD.AdvFacBillDetail b   ON a.Account_No_ = b.RefSystemAcid 
    WHERE b.BillNatureAlt_Key = 9) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Source_System = 'SCF';
   -----------------------------------------------------------------------------------------------------------------------------
   DELETE FROM tt_OverdueReportPhase2;
   UTILS.IDENTITY_RESET('tt_OverdueReportPhase2');

   INSERT INTO tt_OverdueReportPhase2 ( 
   	SELECT * 
   	  FROM OverdueReportPhase2 
   	 WHERE  1 = 2 );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_OverdueReportPhase2 ';
   INSERT INTO tt_OverdueReportPhase2
     ( SELECT Report_date ,
              UCIC ,
              CIF_ID ,
              Borrower_Name ,
              Branch_Code ,
              Branch_Name ,
              Account_No_ ,
              Source_System ,
              Facility ,
              Scheme_Type ,
              Scheme_Code ,
              Scheme_Description ,
              Seg_Code ,
              A.Asset_Norm ,
              Segment_Description ,
              Business_Segment ,
              --GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0),ISNULL([DPD_Stock Statement expiry],0),ISNULL([DPD_Limit Expiry],0),isnull(DPD_Overdue,0),
              --  isnull([DPD_Principal Overdue],0),isnull([DPD_Interest Overdue],0),isnull([DPD_Other Overdue],0)) [Account DPD]
              b.MAX_DPD_1 Account_DPD  ,
              Outstanding ,
              Principal_Outstanding ,
              Drawing_Power ,
              Sanction_Limit ,
              OverDrawn_Amount ,
              A.DPD_Overdrawn ,
              CASE 
                   WHEN ( Limit_DP_Overdrawn_Date IS NULL
                     OR Limit_DP_Overdrawn_Date = '01-01-1900' ) THEN ' '
              ELSE Limit_DP_Overdrawn_Date
                 END Limit_DP_Overdrawn_Date  ,
              CASE 
                   WHEN ( Limit_Expiry_Date IS NULL
                     OR Limit_Expiry_Date = '01-01-1900' ) THEN ' '
              ELSE Limit_Expiry_Date
                 END Limit_Expiry_Date  ,
              DPD_Limit_Expiry ,
              CASE 
                   WHEN ( Stock_Statement_valuation_date IS NULL
                     OR Stock_Statement_valuation_date = '01-01-1900' ) THEN ' '
              ELSE Stock_Statement_valuation_date
                 END Stock_Statement_valuation_date  ,
              DPD_Stock_Statement_expiry ,
              CASE 
                   WHEN ( Debit_Balance_Since_Date IS NULL
                     OR Debit_Balance_Since_Date = '01-01-1900' ) THEN ' '
              ELSE Debit_Balance_Since_Date
                 END Debit_Balance_Since_Date  ,
              CASE 
                   WHEN ( Last_Credit_Date IS NULL
                     OR Last_Credit_Date = '01-01-1900' ) THEN ' '
              ELSE Last_Credit_Date
                 END Last_Credit_Date  ,
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              Overdue_Amount ,
              CASE 
                   WHEN ( Overdue_Date IS NULL
                     OR Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              A.DPD_Overdue ,
              Principal_Overdue ,
              CASE 
                   WHEN ( Principal_Overdue_Date IS NULL
                     OR Principal_Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Principal_Overdue_Date
                 END Principal_Overdue_Date  ,
              DPD_Principal_Overdue ,
              Interest_Overdue ,
              CASE 
                   WHEN ( Interest_Overdue_Date IS NULL
                     OR Interest_Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Interest_Overdue_Date
                 END Interest_Overdue_Date  ,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN ( Other_OverDue_Date IS NULL
                     OR Other_OverDue_Date = '01-01-1900' ) THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              Bill_PC_Overdue_Amount ,
              Overdue_Bill_PC_ID ,
              CASE 
                   WHEN UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105) = '01-01-1900' THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105)
                 END Bill_PC_Overdue_Date  ,
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_Final_Output_2 a
              JOIN tt_TempDPD_2 b   ON a.Account_No_ = b.CustomerAcID

       --where GREATEST(ISNULL(a.DPD_Overdrawn,0),ISNULL(a.[DPD_No Credit],0),ISNULL(a.[DPD_Stock Statement expiry],0),ISNULL(a.[DPD_Limit Expiry],0),isnull(a.DPD_Overdue,0),

       -- isnull(a.[DPD_Principal Overdue],0),isnull(a.[DPD_Interest Overdue],0),isnull(a.[DPD_Other Overdue],0))>0
       WHERE  b.MAX_DPD_1 > 0
       UNION 
       SELECT Report_date ,
              UCIC ,
              CIF_ID ,
              Borrower_Name ,
              Branch_Code ,
              Branch_Name ,
              Account_No_ ,
              'SCF' Source_System  ,
              Facility ,
              Scheme_Type ,
              Scheme_Code ,
              Scheme_Description ,
              Seg_Code ,
              a.Asset_Norm ,
              Segment_Description ,
              Business_Segment ,
              b.MAX_DPD_1 Account_DPD  ,
              Outstanding ,
              Principal_Outstanding ,
              Drawing_Power ,
              Sanction_Limit ,
              OverDrawn_Amount ,
              a.DPD_Overdrawn ,
              CASE 
                   WHEN ( Limit_DP_Overdrawn_Date IS NULL
                     OR Limit_DP_Overdrawn_Date = '01-01-1900' ) THEN ' '
              ELSE Limit_DP_Overdrawn_Date
                 END Limit_DP_Overdrawn_Date  ,
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Limit_Expiry_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Limit_Expiry_Date,30,p_style=>105) = '01-01-1900' ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Limit_Expiry_Date,30,p_style=>105)
                 END Limit_Expiry_Date  ,
              DPD_Limit_Expiry ,
              CASE 
                   WHEN ( Stock_Statement_valuation_date IS NULL
                     OR Stock_Statement_valuation_date = '01-01-1900' ) THEN ' '
              ELSE Stock_Statement_valuation_date
                 END Stock_Statement_valuation_date  ,
              DPD_Stock_Statement_expiry ,
              CASE 
                   WHEN ( Debit_Balance_Since_Date IS NULL
                     OR Debit_Balance_Since_Date = '01-01-1900' ) THEN ' '
              ELSE Debit_Balance_Since_Date
                 END Debit_Balance_Since_Date  ,
              CASE 
                   WHEN ( Last_Credit_Date IS NULL
                     OR Last_Credit_Date = '01-01-1900' ) THEN ' '
              ELSE Last_Credit_Date
                 END Last_Credit_Date  ,
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END + CASE 
                            WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Overdue_Amount  ,
              CASE 
                   WHEN ( Overdue_Date IS NULL
                     OR Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              a.DPD_Overdue ,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END Principal_Overdue  ,
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Principal_Overdue_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Principal_Overdue_Date,30,p_style=>105) = '01-01-1900'
                     OR Principal_Overdue_Date > v_DATE ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Principal_Overdue_Date,30,p_style=>105)
                 END Principal_Overdue_Date  ,
              DPD_Principal_Overdue ,
              CASE 
                   WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Interest_Overdue  ,
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105) = '01-01-1900'
                     OR Interest_Overdue_Date > v_DATE ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105)
                 END Interest_Overdue_Date  ,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN ( Other_OverDue_Date IS NULL
                     OR Other_OverDue_Date = '01-01-1900' ) THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END + CASE 
                            WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Bill_PC_Overdue_Amount  ,
              Overdue_Bill_PC_ID ,
              CASE 
                   WHEN UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105) = '01-01-1900' THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105)
                 END Bill_PC_Overdue_Date  ,
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_Final_OutputSCF_2 a
              LEFT JOIN tt_TempDPD_2 b   ON a.Account_No_ = b.CustomerAcID );
   ------------------------------------------------------------------------------------------------------------------
   UPDATE tt_OverdueReportPhase2
      SET Limit_Expiry_Date = NULL
    WHERE  ( Limit_Expiry_Date = '1900-01-01'
     OR Limit_Expiry_Date = ' ' );
   UPDATE tt_OverdueReportPhase2
      SET Stock_Statement_valuation_date = NULL
    WHERE  ( Stock_Statement_valuation_date = '1900-01-01'
     OR Stock_Statement_valuation_date = ' ' );
   UPDATE tt_OverdueReportPhase2
      SET Debit_Balance_Since_Date = NULL
    WHERE  ( Debit_Balance_Since_Date = '1900-01-01'
     OR Debit_Balance_Since_Date = ' ' );
   UPDATE tt_OverdueReportPhase2
      SET Overdue_Date = NULL
    WHERE  ( Overdue_Date = '1900-01-01'
     OR Overdue_Date = ' ' );
   UPDATE tt_OverdueReportPhase2
      SET Principal_Overdue_Date = NULL
    WHERE  ( Principal_Overdue_Date = '1900-01-01'
     OR Principal_Overdue_Date = ' ' );
   UPDATE tt_OverdueReportPhase2
      SET Interest_Overdue_Date = NULL
    WHERE  ( Interest_Overdue_Date = '1900-01-01'
     OR Interest_Overdue_Date = ' ' );
   UPDATE tt_OverdueReportPhase2
      SET Bill_PC_Overdue_Date = NULL
    WHERE  ( Bill_PC_Overdue_Date = '1900-01-01'
     OR Bill_PC_Overdue_Date = ' ' );
   ---------------------------------------Overdue Bill & PC END--------------------------------------------------------
   ---------------------------------------Investment Start--------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempInvestment_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempInvestment_2 ';
   END IF;
   DELETE FROM tt_TempInvestment_2;
   UTILS.IDENTITY_RESET('tt_TempInvestment_2');

   INSERT INTO tt_TempInvestment_2 ( 
   	SELECT DISTINCT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
                    B.BRANCHCODE ,
                    ISSUERID ,
                    ISSUERNAME ,
                    REF_TXN_SYS_CUST_ID ,
                    ISSUER_CATEGORY_CODE ,
                    UCIFID ,
                    PANNO ,
                    --SUBSTRING(INVID,1,charindex('_',INVID)-1) as INVID
                    CASE 
                         WHEN INVID LIKE '%/_%' THEN SUBSTR(INVID, 1, INSTR(INVID, '_') - 1)
                    ELSE INVID
                       END INVID  ,
                    b.ISIN ,
                    I.InstrumentTypeName ,
                    INSTRNAME ,
                    b.INVESTMENTNATURE ,
                    EXPOSURETYPE ,
                    MATURITYDT ,
                    HOLDINGNATURE ,
                    BOOKTYPE ,
                    BOOKVALUE ,
                    MTMVALUE ,
                    INTEREST_DIVIDENDDUEDATE ,
                    INTEREST_DIVIDENDDUEAMOUNT ,
                    DPD ,
                    FLGDEG ,
                    DEGREASON ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN 'N'
                    ELSE FLGUPG
                       END) FLGUPG  ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN NULL
                    ELSE UPGDATE
                       END) UPGDATE  ,
                    TOTALPROVISON ,
                    AC.AssetClassShortName ASSETCLASS  ,
                    C.PartialRedumptionDueDate ,
                    c.PartialRedumptionSettledY_N ,
                    c.NPIDt ,
                    c.BalanceSheetDate ,
                    c.ListedShares ,
                    c.DPD_BS_Date ,
                    c.BookValueINR ,
                    C.DPD_DivOverdue ,
                    C.DPD_Maturity ,
                    C.PartialRedumptionDPD 
   	  FROM InvestmentIssuerDetail a
             JOIN InvestmentBasicDetail B   ON A.IssuerEntityId = B.IssuerEntityId
             AND a.EffectiveFromTimeKey <= v_TimeKey
             AND a.EffectiveToTimeKey >= v_TimeKey
             AND b.EffectiveFromTimeKey <= v_TimeKey
             AND b.EffectiveToTimeKey >= v_TimeKey
             JOIN InvestmentFinancialDetail c   ON b.InvEntityId = c.InvEntityId
             AND c.EffectiveFromTimeKey <= v_TimeKey
             AND c.EffectiveToTimeKey >= v_TimeKey
             JOIN DimAssetClass AC   ON AC.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey
             AND AC.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
             LEFT JOIN DimInstrumentType I   ON I.EffectiveFromTimeKey <= v_TimeKey
             AND I.EffectiveToTimeKey >= v_TimeKey
             AND B.InstrTypeAlt_Key = I.InstrumentTypeAlt_Key
   	 WHERE  c.FinalAssetClassAlt_Key = 1 );
   ----------------------------------------------------------------------
   ---------------------------------------------------------------------------
   UPDATE tt_TempInvestment_2
      SET DPD = CASE 
                     WHEN NVL(DPD_DivOverdue, 0) >= NVL(DPD_Maturity, 0)
                       AND NVL(DPD_DivOverdue, 0) >= NVL(PartialRedumptionDPD, 0) 
                     --and ISNULL(DPD_DivOverdue,0)>=ISNULL(DPD_BS_Date,0)
                     THEN NVL(DPD_DivOverdue, 0)
                     WHEN NVL(DPD_Maturity, 0) >= NVL(DPD_DivOverdue, 0)
                       AND NVL(DPD_Maturity, 0) >= NVL(PartialRedumptionDPD, 0) 
                     --and ISNULL(DPD_Maturity,0)>=ISNULL(DPD_BS_Date,0)
                     THEN NVL(DPD_Maturity, 0)

          --WHEN ISNULL(DPD_BS_Date,0)>=ISNULL(DPD_DivOverdue,0) 

          --      and ISNULL(DPD_BS_Date,0)>=ISNULL(PartialRedumptionDPD,0) 

          --      and ISNULL(DPD_BS_Date,0)>=ISNULL(DPD_Maturity,0)

          --THEN ISNULL(DPD_BS_Date,0)
          ELSE NVL(PartialRedumptionDPD, 0)
             END;
   ---------------------------------------Investment END--------------------------------------------------------
   ---------------------------------------In & Out Default Start -----------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Accountcal_hist_dpd_prev') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Accountcal_hist_dpd_prev ';
   END IF;
   DELETE FROM tt_Accountcal_hist_dpd_prev;
   UTILS.IDENTITY_RESET('tt_Accountcal_hist_dpd_prev');

   INSERT INTO tt_Accountcal_hist_dpd_prev ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.Accountcal_hist_DPD 
   	 WHERE  TimeKey = v_PrvDayTimekey );
   IF utils.object_id('TEMPDB..tt_TempDefault') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempDefault ';
   END IF;
   DELETE FROM tt_TempDefault;
   UTILS.IDENTITY_RESET('tt_TempDefault');

   INSERT INTO tt_TempDefault ( 
   	SELECT A.AccountEntityID ,
           SMA_Class ,
           SMA_Dt ,
           FlgSMA ,
           DPD_SMA ,
           SMA_Reason ,
           b.DPD_MAX ,
           b.DPD_IntOverdueSince ,
           b.DPD_IntService ,
           b.DPD_NoCredit ,
           b.DPD_OtherOverdueSince ,
           b.DPD_Overdrawn ,
           b.DPD_PrincOverdue ,
           b.DPD_Overdue 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist a
             LEFT JOIN tt_Accountcal_hist_dpd_prev b   ON a.AccountEntityID = b.AccountEntityid
             AND b.TimeKey = v_PrvDayTimekey
   	 WHERE  a.EffectiveFromTimeKey <= v_PrvDayTimekey
              AND a.EffectiveToTimeKey >= v_PrvDayTimekey
              AND a.FinalAssetClassAlt_Key = 1 );
   UPDATE tt_TempDefault
      SET DPD_MAX = 0
    WHERE  DPD_MAX IS NULL;
   UPDATE tt_TempDefault
      SET DPD_IntOverdueSince = 0
    WHERE  DPD_IntOverdueSince IS NULL;
   UPDATE tt_TempDefault
      SET DPD_IntService = 0
    WHERE  DPD_IntService IS NULL;
   UPDATE tt_TempDefault
      SET DPD_NoCredit = 0
    WHERE  DPD_NoCredit IS NULL;
   UPDATE tt_TempDefault
      SET DPD_OtherOverdueSince = 0
    WHERE  DPD_OtherOverdueSince IS NULL;
   UPDATE tt_TempDefault
      SET DPD_Overdrawn = 0
    WHERE  DPD_Overdrawn IS NULL;
   UPDATE tt_TempDefault
      SET DPD_PrincOverdue = 0
    WHERE  DPD_PrincOverdue IS NULL;
   UPDATE tt_TempDefault
      SET DPD_Overdue = 0
    WHERE  DPD_Overdue IS NULL;

   EXECUTE IMMEDIATE ' ALTER TABLE tt_TempACCOUNTCAL 
      MODIFY ( SMA_Class VARCHAR2(20)  ) ';
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'FDOD'
   FROM A ,tt_TempACCOUNTCAL a
          JOIN DimProduct b   ON a.ProductAlt_Key = b.ProductAlt_Key 
    WHERE a.FinalAssetClassAlt_Key = 1
     AND b.ProductGroup = 'FDSEC') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SMA_Class = 'FDOD';
   UPDATE tt_TempACCOUNTCAL
      SET SMA_Class = 'Agri-Loan'
    WHERE  FinalAssetClassAlt_Key = 1
     AND RefPeriodOverdue > 91;
   UPDATE tt_TempACCOUNTCAL
      SET DPD_SMA = 0
    WHERE  FinalAssetClassAlt_Key = 1
     AND NVL(DPD_SMA, 0) = 0;
   -------------------------------------------------------------------------------

   EXECUTE IMMEDIATE ' ALTER TABLE tt_TempACCOUNTCAL 
      ADD ( In_Default VARCHAR2(10)  ) ';

   EXECUTE IMMEDIATE ' ALTER TABLE tt_TempACCOUNTCAL 
      ADD ( Out_Default VARCHAR2(10)  ) ';
   -----------------------------InDefault----------------------------------------------
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'Y'
   FROM A ,tt_TempACCOUNTCAL a
          JOIN tt_TempDefault b   ON a.AccountEntityID = b.AccountEntityID 
    WHERE a.SMA_Class IN ( 'SMA_0','SMA_1','SMA_2' )

     AND B.SMA_Class = 'STD') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.In_Default = 'Y';
   -----------------------------OutDefault----------------------------------------------
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'Y'
   FROM A ,tt_TempACCOUNTCAL a
          JOIN tt_TempDefault b   ON a.AccountEntityID = b.AccountEntityID 
    WHERE B.SMA_Class IN ( 'SMA_0','SMA_1','SMA_2' )

     AND A.SMA_Class = 'STD') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Out_Default = 'Y';
   -------------------------------------------------------------------------------------------------------------
   UPDATE tt_TempACCOUNTCAL
      SET SMA_Class = 'STD'
    WHERE  FinalAssetClassAlt_Key = 1
     AND SourceAlt_Key <> 6
     AND FacilityType IN ( 'CC','OD' )

     AND DPD_Overdrawn <= 30
     AND SMA_Class IN ( 'SMA_0','SMA_1','SMA_2' )
   ;
   ------------------------------------------------------------------------------------------------------
   --Truncate table SMA_OUTPUT
   --Insert into SMA_OUTPUT
   IF utils.object_id('TEMPDB..tt_Temp_SMA_Main_Table_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_SMA_Main_Table_2 ';
   END IF;
   DELETE FROM tt_Temp_SMA_Main_Table_2;
   UTILS.IDENTITY_RESET('tt_Temp_SMA_Main_Table_2');

   INSERT INTO tt_Temp_SMA_Main_Table_2 ( 
   	SELECT * 
   	  FROM ( SELECT v_PROCESSDATE Report_Date  ,
                    --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
                    ---------RefColumns---------
                    A.UCIF_ID UCIC  ,
                    A.RefCustomerID CIF_ID  ,
                    F.CustomerName Borrower_Name  ,
                    A.BranchCode Branch_Code  ,
                    br.BranchName Branch_Name  ,
                    br.BranchStateName BranchStateName  ,
                    br.BranchRegion Region  ,
                    A.CustomerAcID Account_No_  ,
                    F.PANNO PAN  ,
                    H.SourceName Source_System  ,
                    A.FacilityType Facility  ,
                    SchemeType Scheme_Type  ,
                    A.ProductCode Scheme_Code  ,
                    C.ProductName Scheme_Description  ,
                    A.ActSegmentCode Seg_Code  ,
                    CASE 
                         WHEN SourceName = 'FIS' THEN 'FI'

                         -- WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                         WHEN SourceName = 'VisionPlus' --and a.ProductCode not in ('777','780') 
                          THEN 'Credit Card'
                    ELSE AcBuSegmentDescription
                       END Segment_Description  ,
                    CASE 
                         WHEN SourceName = 'FIS' THEN 'FI'
                         WHEN SourceName = 'VisionPlus'
                           AND A.ProductCode IN ( '777','780' )
                          THEN 'Retail'
                         WHEN SourceName = 'VisionPlus'
                           AND A.ProductCode NOT IN ( '777','780' )
                          THEN 'Credit Card'
                    ELSE AcBuRevisedSegmentCode
                       END Business_Segment  ,
                    CASE 
                         WHEN AcBuRevisedSegmentCode IN ( 'Retail','WCF','Agri-Retail','FI','MSME','Credit Card' )
                          THEN 'Retail'
                         WHEN AcBuRevisedSegmentCode IN ( 'CIB','FIG','Agri-Wholesale','MC','CB','SCF','SME','Treasury' )
                          THEN 'Wholesale'
                    ELSE AcBuRevisedSegmentCode
                       END Wholesale_Retail  ,
                    CASE 
                         WHEN NVL(A.Balance, 0) <= 0 THEN 0
                    ELSE NVL(A.Balance, 0)
                       END Balance_Outstanding  ,
                    CASE 
                         WHEN NVL(A.PrincOutStd, 0) <= 0 THEN 0
                    ELSE NVL(A.PrincOutStd, 0)
                       END Principal_Outstanding  ,
                    A.DrawingPower Drawing_Power  ,
                    NVL(A.CurrentLimit, 0) Sanction_Limit  ,
                    CASE 
                         WHEN SourceName = 'Finacle'
                           AND SchemeType = 'ODA' THEN (CASE 
                                                             WHEN (NVL(A.Balance, 0) - (CASE 
                                                                                             WHEN NVL(A.DrawingPower, 0) < NVL(A.CurrentLimit, 0) THEN NVL(A.DrawingPower, 0)
                                                             ELSE NVL(A.CurrentLimit, 0)
                                                                END)) <= 0 THEN 0
                         ELSE NVL(A.Balance, 0) - (CASE 
                                                        WHEN NVL(A.DrawingPower, 0) < NVL(A.CurrentLimit, 0) THEN NVL(A.DrawingPower, 0)
                         ELSE NVL(A.CurrentLimit, 0)
                            END)
                            END)
                    ELSE 0
                       END OverDrawn_Amount  ,
                    NVL(DPD.DPD_Overdrawn, 0) DPD_Overdrawn  ,
                    --,a.ContiExcessDt as [Limit/DP Overdrawn Date]
                    UTILS.CONVERT_TO_VARCHAR2(A.ContiExcessDt,10,p_style=>103) Limit_DP_Overdrawn_Date  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN NVL(OP2.Overdue_Amount, 0)
                    ELSE NVL(A.OverdueAmt, 0)
                       END Overdue_Amount  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(OP2.Overdue_Date,10,p_style=>103)
                    ELSE UTILS.CONVERT_TO_VARCHAR2(A.OverDueSinceDt,10,p_style=>103)
                       END OverDueSinceDt  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN NVL(OP2.DPD_Overdue, 0)
                    ELSE NVL(DPD.DPD_Overdue, 0)
                       END DPD_Overdue  ,
                    OP2.Bill_PC_Overdue_Amount ,
                    OP2.Overdue_Bill_PC_ID ,
                    --,[Bill/PC Overdue Date]
                    UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OP2.Bill_PC_Overdue_Date,200,p_style=>105),10,p_style=>23) Bill_PC_Overdue_Date  ,
                    OP2.DPD_Bill_PC ,
                    NULL INTEREST_DIVIDENDDUEDATE  ,
                    NULL INTEREST_DIVIDENDDUEAMOUNT  ,
                    NULL DPD  ,
                    NULL PartialRedumptionDueDate  ,
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN 0
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN 0
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 31 THEN DPD.DPD_Overdrawn
                    ELSE NVL(DPD.DPD_Overdue, 0)
                       END SMA_DPD  ,
                    --,A.FlgSMA AS AccountFlgSMA
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN 'N'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN 'N'

                    --when a.SourceAlt_Key<>6 and a.FacilityType in ('CC','OD') and 

                    -- isnull(DPD.DPD_Overdrawn,0) >=31 then A.FlgSMA
                    ELSE NVL(A.FlgSMA, 'N')
                       END AccountFlgSMA  ,
                    --,A.SMA_Dt AS AccountSMA_Dt
                    MS.MovementFromDate AccountSMA_Dt  ,
                    CASE 
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND SMA_Class NOT IN ( 'FDOD','Agri-Loan' ----Added by Prashant---28062024------
                          )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN 'STD'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND SMA_Class NOT IN ( 'FDOD','Agri-Loan' ----Added by Prashant---28062024------
                          )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 31
                           AND NVL(DPD.DPD_Overdrawn, 0) <= 60 THEN 'SMA_1'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND SMA_Class NOT IN ( 'FDOD','Agri-Loan' ----Added by Prashant---28062024------
                          )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 61
                           AND NVL(DPD.DPD_Overdrawn, 0) <= 90 THEN 'SMA_2'
                    ELSE A.SMA_Class
                       END AccountSMA_AssetClass  ,
                    --,A.SMA_Reason AS SMA_Reason
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN NULL
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL
                    ELSE A.SMA_Reason
                       END SMA_Reason  ,
                    --,isnull(dpd.DPD_UCIF_ID,0) DPD_UCIF_ID
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN 0
                    ELSE NVL(DPD.DPD_UCIF_ID, 0)
                       END DPD_UCIF_ID  ,
                    --,F.FlgSMA AS UCICFlgSMA
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN 'N'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN 'N'

                    --when a.SourceAlt_Key<>6 and a.FacilityType in ('CC','OD') and 

                    -- isnull(DPD.DPD_Overdrawn,0) >=31 then A.FlgSMA
                    ELSE NVL(A.FlgSMA, 'N')
                       END UCICFlgSMA  ,
                    --,F.SMA_Dt AS UCICSMA_Dt
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN NULL
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL

                    --when a.SourceAlt_Key<>6 and a.FacilityType in ('CC','OD') and 

                    -- isnull(DPD.DPD_Overdrawn,0) >=31 then A.FlgSMA
                    ELSE NVL(MS.MovementFromDate, NULL)
                       END UCICSMA_Dt  ,
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN SMA_Class
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN 'STD'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND SMA_Class NOT IN ( 'FDOD','Agri-Loan' ----Added by Prashant---28062024------
                          )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 31
                           AND NVL(DPD.DPD_Overdrawn, 0) <= 60 THEN 'SMA_1'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND SMA_Class NOT IN ( 'FDOD','Agri-Loan' ----Added by Prashant---28062024------
                          )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 61
                           AND NVL(DPD.DPD_Overdrawn, 0) <= 90 THEN 'SMA_2'
                    ELSE A.SMA_Class
                       END UCICSMA_AssetStatus  ,
                    --,F.SMA_Dt AS [SMA Classification Date]
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN NULL
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL

                         --when a.SourceAlt_Key<>6 and a.FacilityType in ('CC','OD') and 

                         -- isnull(DPD.DPD_Overdrawn,0) >=31 then A.FlgSMA

                         --else isnull(a.SMA_Dt,null) end as [First Time SMA Classification Date]
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 31 THEN mco.MovementFromDate_CCOD
                    ELSE NVL(MD.MovementFromDate1, NULL)
                       END First_Time_SMA_Classification_Date  ,
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN 'N'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN 'N'
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 31
                           AND v_PROCESSDATE = mco.MovementFromDate_CCOD THEN 'Y'
                    ELSE NVL(In_Default, 'N')
                       END in_default_Y_N_  ,
                    --,case when SMA_Class in ('FDOD','Agri-Loan') then 'N'
                    --      when a.SourceAlt_Key<>6 and a.FacilityType in ('CC','OD') and 
                    --	   isnull(DPD.DPD_Overdrawn,0) <=30 then 'N' 
                    --	   when isnull(MD.MovementFromDate1,'1900-01-01')='1900-01-01'
                    --	   then 'N'
                    --	   else 'Y' end As [in_default (Y/N)]
                    --,A.SMA_Dt [in_default date]
                    --,MD.MovementFromDate1 AS [in_default date]
                    CASE 
                         WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                          THEN NULL
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) >= 31 THEN mco.MovementFromDate_CCOD
                         WHEN A.SourceAlt_Key <> 6
                           AND A.FacilityType IN ( 'CC','OD' )

                           AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN mco30.MovementFromDate_CCOD_30
                    ELSE NVL(MD.MovementFromDate1, NULL)
                       END in_default_date  ,
                    NVL(Out_Default, 'N') out_of_default_Y_N_  ,
                    CASE 
                         WHEN Out_Default = 'Y' THEN v_PROCESSDATE
                    ELSE NULL
                       END out_of_default_date  ,
                    --,Case When A.FlgSMA='Y' then NULL Else I.MovementFromDate End as MovementFromDate
                    --,Case When A.FlgSMA='Y' then NULL Else I.MovementFromStatus End as MovementFromStatus
                    --,Case When A.FlgSMA='Y' then NULL Else I.MovementToStatus End as MovementToStatus
                    CASE -- When A.FlgSMA='Y'  then NULL

                     WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                      THEN NULL
                     WHEN A.SourceAlt_Key <> 6
                       AND A.FacilityType IN ( 'CC','OD' )

                       AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL
                    ELSE I.MovementFromDate
                       END MovementFromDate  ,
                    CASE --When A.FlgSMA='Y' then NULL 

                     WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                      THEN NULL
                     WHEN A.SourceAlt_Key <> 6
                       AND A.FacilityType IN ( 'CC','OD' )

                       AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL
                    ELSE I.MovementFromStatus
                       END MovementFromStatus  ,
                    CASE --When A.FlgSMA='Y' then NULL 

                     WHEN SMA_Class IN ( 'FDOD','Agri-Loan' )
                      THEN NULL
                     WHEN A.SourceAlt_Key <> 6
                       AND A.FacilityType IN ( 'CC','OD' )

                       AND NVL(DPD.DPD_Overdrawn, 0) <= 30 THEN NULL
                    ELSE I.MovementToStatus
                       END MovementToStatus  ,
                    A.Asset_Norm ,
                    A.REFPERIODOVERDUE NPA_Norms  ,
                    --,CE.CREDIT_FB_EXPOSURE [Credit_FB Exposure]
                    --,CE.CREDIT_NFB_EXPOSURE [Credit_NFB Exposure]
                    --,CE.NON_SLR [Non-SLR]
                    --,CE.[LER_O/s] [LER]
                    --,CE.GROSS_TOTAL_EXPOSURE [Total Exposure]
                    --,case when CE.GROSS_TOTAL_EXPOSURE >=50000000 then 'Y' else 'N' end [Exposure 5crore & above_Flag]
                    CASE 
                         WHEN SMA_Class = 'FDOD' THEN 'Y'
                    ELSE 'N'
                       END FDOD_Flag  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(OP2.Limit_Expiry_Date,10,p_style=>103)
                    ELSE UTILS.CONVERT_TO_VARCHAR2(A.ReviewDueDt,10,p_style=>103)
                       END Limit_Expiry_Date  ,
                    NVL(DPD.DPD_Renewal, 0) DPD_Limit_Expiry  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.StockStDt,10,p_style=>103) Stock_Statement_valuation_date  ,
                    NVL(DPD.DPD_StockStmt, 0) DPD_Stock_Statement_expiry  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.DebitSinceDt,10,p_style=>103) Debit_Balance_Since_Date  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.LastCrDate,10,p_style=>103) Last_Credit_Date  ,
                    NVL(DPD.DPD_NoCredit, 0) DPD_No_Credit  ,
                    A.CurQtrCredit Current_quarter_credit  ,
                    A.CurQtrInt Current_quarter_interest  ,
                    (CASE 
                          WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
                    ELSE (CurQtrInt - CurQtrCredit)
                       END) Interest_Not_Serviced  ,
                    NVL(DPD.DPD_IntService, 0) DPD_out_of_order  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.IntNotServicedDt,10,p_style=>103) CC_OD_Interest_Service_Date  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN NVL(OP2.Principal_Overdue, 0)
                    ELSE NVL(A.PrincOverdue, 0)
                       END Principal_Overdue  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(OP2.Principal_Overdue_Date,10,p_style=>103)
                    ELSE UTILS.CONVERT_TO_VARCHAR2(A.PrincOverdueSinceDt,10,p_style=>103)
                       END Principal_Overdue_Date  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN NVL(OP2.DPD_Principal_Overdue, 0)
                    ELSE NVL(DPD.DPD_PrincOverdue, 0)
                       END DPD_Principal_Overdue  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN NVL(OP2.Interest_Overdue, 0)
                    ELSE NVL(A.IntOverdue, 0)
                       END Interest_Overdue  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(OP2.Interest_Overdue_Date,10,p_style=>103)
                    ELSE UTILS.CONVERT_TO_VARCHAR2(A.IntOverdueSinceDt,10,p_style=>103)
                       END Interest_Overdue_Date  ,
                    CASE 
                         WHEN op2.Account_No_ IS NOT NULL THEN NVL(OP2.DPD_Interest_Overdue, 0)
                    ELSE NVL(DPD.DPD_IntOverdueSince, 0)
                       END DPD_Interest_Overdue  ,
                    NVL(A.OtherOverdue, 0) Other_Overdue  ,
                    UTILS.CONVERT_TO_VARCHAR2(A.OtherOverdueSinceDt,10,p_style=>103) Other_OverDue_Date  ,
                    NVL(DPD.DPD_OtherOverdueSince, 0) DPD_Other_Overdue  

             --From Pro.AccountCal_hist A
             FROM tt_TempACCOUNTCAL A
                    JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
                    AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND C.EffectiveFromTimeKey <= v_TIMEKEY
                    AND C.EffectiveToTimeKey >= v_TIMEKEY
                    JOIN DimAssetClass D   ON D.AssetClassAlt_Key = A.InitialAssetClassAlt_Key
                    AND D.EffectiveFromTimeKey <= v_TIMEKEY
                    AND D.EffectiveToTimeKey >= v_TIMEKEY
                    JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
                    AND E.EffectiveFromTimeKey <= v_TIMEKEY
                    AND E.EffectiveToTimeKey >= v_TIMEKEY
                  --INNER JOIN Pro.CustomerCal_hist F On F.CustomerEntityId=A.CustomerEntityId

                    JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL F   ON F.CustomerEntityID = A.CustomerEntityId
                    AND F.EffectiveFromTimeKey <= v_TIMEKEY
                    AND F.EffectiveToTimeKey >= v_TIMEKEY
                    JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey
                    JOIN DIMSOURCEDB H   ON H.SourceAlt_Key = A.SourceAlt_Key
                    AND H.EffectiveFromTimeKey <= v_TIMEKEY
                    AND H.EffectiveToTimeKey >= v_TIMEKEY
                    LEFT JOIN tt_TempDPD_2 DPD   ON DPD.AccountEntityID = A.AccountEntityID
                    LEFT JOIN tt_ACCOUNT_MOVEMENT_HISTORY_8 I   ON I.CustomerAcID = A.CustomerAcID
                    AND I.EffectiveFromTimeKey <= v_TIMEKEY
                    AND I.EffectiveToTimeKey >= v_TIMEKEY
                    LEFT JOIN DimAcBuSegment S   ON a.ActSegmentCode = S.AcBuSegmentCode
                    AND S.EffectiveFromTimeKey <= v_TIMEKEY
                    AND S.EffectiveToTimeKey >= v_TIMEKEY
                    LEFT JOIN DimBranch BR   ON a.BranchCode = br.BranchCode
                    AND br.EffectiveFromTimeKey <= v_TIMEKEY
                    AND br.EffectiveToTimeKey >= v_TIMEKEY
                    LEFT JOIN tt_OverdueReportPhase2 OP2   ON OP2.Account_No_ = A.CustomerAcID
                  --left join  #ALL_CUSTOMER_EXPOSURE_DETAIL CE
                   --On         CE.CustomerEntityId=F.CustomerEntityID
                   --and        CE.EffectiveFromTimeKey<=@TIMEKEY AND CE.EffectiveToTimeKey>=@TIMEKEY

                    LEFT JOIN tt_Temp_ACCOUNT_MOVEMENT_HI MD   ON MD.CustomerAcID = A.CustomerAcID
                    LEFT JOIN tt_Temp_ACCOUNT_MOVEMENT_HI_5 MS   ON MS.CustomerAcID = A.CustomerAcID
                    AND A.SMA_Class = MS.MovementToStatus
                    LEFT JOIN tt_Temp_ACCOUNT_MOVEMENT_HI_3 MCO   ON MCO.CustomerAcID = A.CustomerAcID
                    LEFT JOIN tt_Temp_ACCOUNT_MOVEMENT_HI_4 MCO30   ON MCO30.CustomerAcID = A.CustomerAcID
              WHERE  A.FinalAssetClassAlt_Key = 1
                       AND ( a.DPD_Max >= 0
                       OR a.Out_Default = 'Y' )
             UNION 

             --AND F.FlgSMA='Y'

             --order by A.UcifEntityID,A.RefCustomerID

             --select * from investment_data
             SELECT v_PROCESSDATE Report_Date  ,
                    --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
                    ---------RefColumns---------
                    UCIFID UCIF_ID  ,
                    --,REF_TXN_SYS_CUST_ID as CustomerID
                    IssuerID CustomerID  ,
                    IssuerName CustomerName  ,
                    a.BRANCHCODE ,
                    c.BranchName ,
                    c.BranchStateName ,
                    c.BranchRegion ,
                    INVID CustomerAcID  ,
                    PANNO ,
                    'Calypso' SourceName  ,
                    NULL FacilityType  ,
                    NULL SchemeType  ,
                    NULL ProductCode  ,
                    NULL ProductName  ,
                    NULL Seg_Code  ,
                    --,CASE WHEN SourceName='FIS' THEN 'FI'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
                    --		else AcBuSegmentDescription end as [Segment Description]
                    NULL Segment_Description  ,
                    --,CASE WHEN SourceName='FIS' THEN 'FI'  
                    --	WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
                    --  else AcBuRevisedSegmentCode end [Business Segment] 
                    NULL Business_Segment  ,
                    --,CASE WHEN AcBuRevisedSegmentCode in ('Retail','WCF','Agri-Retail','FI','MSME','SCF','Credit Card')
                    --THEN 'Retail'  
                    --	WHEN AcBuRevisedSegmentCode in ('CIB','FIG','Agri-Wholesale','MC','CB','SME','Treasury')
                    --THEN 'Wholesale' 
                    --  else AcBuRevisedSegmentCode end [Wholesale / Retail] 
                    NULL Wholesale_Retail  ,
                    NVL(BookValue, 0) + NVL(Interest_DividendDueAmount, 0) Balance  ,
                    NVL(BookValue, 0) PrincOutStd  ,
                    NULL DrawingPower  ,
                    NULL CurrentLimit  ,
                    --,CASE WHEN SourceName = 'Finacle' AND SchemeType ='ODA' THEN (
                    --		CASE WHEN (ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
                    --											THEN			ISNULL(a.DrawingPower,0) 
                    --											ELSE ISNULL(a.CurrentLimit,0)  
                    --											END 
                    --										)
                    --				  )<=0
                    --		THEN	0	 
                    --		ELSE  
                    --		ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
                    --											THEN			ISNULL(a.DrawingPower,0) 
                    --											ELSE ISNULL(a.CurrentLimit,0)  
                    --											END 
                    --										)
                    --END) ELSE 0 END
                    NULL OverDrawn_Amount  ,
                    0 DPD_Overdrawn  ,
                    --,a.ContiExcessDt as [Limit/DP Overdrawn Date]
                    NULL Limit_DP_Overdrawn_Date  ,
                    NULL OverdueAmt  ,
                    NULL OverDueSinceDt  ,
                    0 DPD_Overdue  ,
                    NULL Bill_PC_Overdue_Amount  ,
                    NULL Overdue_Bill_PC_ID  ,
                    --,[Bill/PC Overdue Date]
                    NULL Bill_PC_Overdue_Date  ,
                    0 DPD_Bill_PC  ,
                    INTEREST_DIVIDENDDUEDATE ,
                    NVL(INTEREST_DIVIDENDDUEAMOUNT, 0) INTEREST_DIVIDENDDUEAMOUNT  ,
                    NVL(DPD, 0) inv_DPD  ,
                    PartialRedumptionDueDate ,
                    NVL(DPD, 0) SMA_DPD  ,
                    --,'N' AS AccountFlgSMA
                    CASE 
                         WHEN DPD BETWEEN 1 AND 90 THEN 'Y'
                    ELSE 'N'
                       END AccountFlgSMA  ,
                    NULL AccountSMA_Dt  ,
                    --,null AS AccountSMA_AssetClass
                    CASE 
                         WHEN DPD = 0 THEN 'STD'
                         WHEN DPD BETWEEN 1 AND 30 THEN 'SMA_0'
                         WHEN DPD BETWEEN 31 AND 60 THEN 'SMA_1'
                         WHEN DPD BETWEEN 61 AND 90 THEN 'SMA_2'   END AccountSMA_AssetClass  ,
                    NULL SMA_Reason  ,
                    NVL(DPD, 0) DPD_UCIF_ID  ,
                    --,'N' AS UCICFlgSMA
                    CASE 
                         WHEN DPD BETWEEN 1 AND 90 THEN 'Y'
                    ELSE 'N'
                       END UCICFlgSMA  ,
                    NULL UCICSMA_Dt  ,
                    --,null AS UCICSMA_AssetStatus
                    CASE 
                         WHEN DPD = 0 THEN 'STD'
                         WHEN DPD BETWEEN 1 AND 30 THEN 'SMA_0'
                         WHEN DPD BETWEEN 31 AND 60 THEN 'SMA_1'
                         WHEN DPD BETWEEN 61 AND 90 THEN 'SMA_2'   END UCICSMA_AssetStatus  ,
                    NULL First_Time_SMA_Classification_Date  ,
                    'N' in_default_Y_N_  ,
                    NULL in_default_date  ,
                    'N' out_of_default_Y_N_  ,
                    NULL out_of_default_date  ,
                    NULL MovementFromDate  ,
                    NULL MovementFromStatus  ,
                    NULL MovementToStatus  ,
                    NULL Asset_Norm  ,
                    NULL NPA_Norms  ,
                    --,null as [Credit_FB Exposure]
                    --,null as [Credit_NFB Exposure]
                    --,null as [Non-SLR]
                    --,null as [LER]
                    --,null as [Total Exposure]
                    --,null as [Exposure 5crore & above_Flag]
                    NULL FDOD_Flag  ,
                    NULL Limit_Expiry_Date  ,
                    NULL DPD_Limit_Expiry  ,
                    NULL Stock_Statement_valuation_date  ,
                    0 DPD_StockStmt  ,
                    NULL Debit_Balance_Since_Date  ,
                    NULL Last_Credit_Date  ,
                    0 DPD_NoCredit  ,
                    NULL Current_quarter_credit  ,
                    NULL Current_quarter_interest  ,
                    NULL Interest_Not_Serviced  ,
                    0 DPD_out_of_order  ,
                    NULL CC_OD_Interest_Service  ,
                    NULL PrincOverdue  ,
                    NULL Principal_Overdue_Date  ,
                    0 DPD_Principal_Overdue  ,
                    NULL IntOverdue  ,
                    NULL Interest_Overdue_Date  ,
                    0 DPD_Interest_Overdue  ,
                    NULL OtherOverdue  ,
                    NULL Other_OverDue_Date  ,
                    0 DPD_Other_Overdue  
             FROM tt_TempInvestment_2 a
                    LEFT JOIN CustomerBasicDetail b   ON a.Ref_Txn_Sys_Cust_ID = b.CustomerId
                    AND b.EffectiveFromTimeKey <= v_Timekey
                    AND b.EffectiveToTimeKey >= v_Timekey
                    LEFT JOIN DimBranch c   ON a.BranchCode = c.BranchCode
                    AND c.EffectiveFromTimeKey <= v_Timekey
                    AND c.EffectiveToTimeKey >= v_Timekey
             UNION 

             --where       isnull(BookValue,0) + isnull(Interest_DividendDueAmount,0) > 0 --This condition is commented on 28062024 by Prashant------

             -----------------derivative-------------------------------

             --select * from investment_data
             SELECT v_PROCESSDATE Report_Date  ,
                    --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
                    ---------RefColumns---------
                    UCIC_ID UCIF_ID  ,
                    --,REF_TXN_SYS_CUST_ID as CustomerID
                    a.CustomerID CustomerID  ,
                    a.CustomerName CustomerName  ,
                    a.BRANCHCODE ,
                    c.BranchName ,
                    c.BranchStateName ,
                    c.BranchRegion ,
                    CustomerACID CustomerAcID  ,
                    NULL PANNO  ,
                    'Calypso' SourceName  ,
                    NULL FacilityType  ,
                    NULL SchemeType  ,
                    NULL ProductCode  ,
                    NULL ProductName  ,
                    NULL Seg_Code  ,
                    --,CASE WHEN SourceName='FIS' THEN 'FI'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
                    --		else AcBuSegmentDescription end as [Segment Description]
                    NULL Segment_Description  ,
                    --,CASE WHEN SourceName='FIS' THEN 'FI'  
                    --	WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
                    --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
                    --  else AcBuRevisedSegmentCode end [Business Segment] 
                    NULL Business_Segment  ,
                    --,CASE WHEN AcBuRevisedSegmentCode in ('Retail','WCF','Agri-Retail','FI','MSME','SCF','Credit Card')
                    --THEN 'Retail'  
                    --	WHEN AcBuRevisedSegmentCode in ('CIB','FIG','Agri-Wholesale','MC','CB','SME','Treasury')
                    --THEN 'Wholesale' 
                    --  else AcBuRevisedSegmentCode end [Wholesale / Retail] 
                    NULL Wholesale_Retail  ,
                    NVL(OsAmt, 0) Balance  ,
                    NVL(POS, 0) PrincOutStd  ,
                    NULL DrawingPower  ,
                    NULL CurrentLimit  ,
                    --,CASE WHEN SourceName = 'Finacle' AND SchemeType ='ODA' THEN (
                    --		CASE WHEN (ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
                    --											THEN			ISNULL(a.DrawingPower,0) 
                    --											ELSE ISNULL(a.CurrentLimit,0)  
                    --											END 
                    --										)
                    --				  )<=0
                    --		THEN	0	 
                    --		ELSE  
                    --		ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
                    --											THEN			ISNULL(a.DrawingPower,0) 
                    --											ELSE ISNULL(a.CurrentLimit,0)  
                    --											END 
                    --										)
                    --END) ELSE 0 END
                    NULL OverDrawn_Amount  ,
                    0 DPD_Overdrawn  ,
                    --,a.ContiExcessDt as [Limit/DP Overdrawn Date]
                    NULL Limit_DP_Overdrawn_Date  ,
                    NULL OverdueAmt  ,
                    NULL OverDueSinceDt  ,
                    0 DPD_Overdue  ,
                    NULL Bill_PC_Overdue_Amount  ,
                    NULL Overdue_Bill_PC_ID  ,
                    --,[Bill/PC Overdue Date]
                    NULL Bill_PC_Overdue_Date  ,
                    0 DPD_Bill_PC  ,
                    NULL INTEREST_DIVIDENDDUEDATE  ,
                    0 INTEREST_DIVIDENDDUEAMOUNT  ,
                    NVL(DPD, 0) inv_DPD  ,
                    NULL PartialRedumptionDueDate  ,
                    A.DPD SMA_DPD  ,
                    --,'N' AS AccountFlgSMA
                    CASE 
                         WHEN A.DPD BETWEEN 1 AND 90 THEN 'Y'
                    ELSE 'N'
                       END AccountFlgSMA  ,
                    NULL AccountSMA_Dt  ,
                    --,null AS AccountSMA_AssetClass
                    CASE 
                         WHEN A.DPD = 0 THEN 'STD'
                         WHEN A.DPD BETWEEN 1 AND 30 THEN 'SMA_0'
                         WHEN A.DPD BETWEEN 31 AND 60 THEN 'SMA_1'
                         WHEN A.DPD BETWEEN 61 AND 90 THEN 'SMA_2'   END AccountSMA_AssetClass  ,
                    NULL SMA_Reason  ,
                    NVL(DPD, 0) DPD_UCIF_ID  ,
                    --,'N' AS UCICFlgSMA
                    CASE 
                         WHEN A.DPD BETWEEN 1 AND 90 THEN 'Y'
                    ELSE 'N'
                       END UCICFlgSMA  ,
                    NULL UCICSMA_Dt  ,
                    --,null AS UCICSMA_AssetStatus
                    CASE 
                         WHEN A.DPD = 0 THEN 'STD'
                         WHEN A.DPD BETWEEN 1 AND 30 THEN 'SMA_0'
                         WHEN A.DPD BETWEEN 31 AND 60 THEN 'SMA_1'
                         WHEN A.DPD BETWEEN 61 AND 90 THEN 'SMA_2'   END UCICSMA_AssetStatus  ,
                    NULL First_Time_SMA_Classification_Date  ,
                    'N' in_default_Y_N_  ,
                    NULL in_default_date  ,
                    'N' out_of_default_Y_N_  ,
                    NULL out_of_default_date  ,
                    NULL MovementFromDate  ,
                    NULL MovementFromStatus  ,
                    NULL MovementToStatus  ,
                    NULL Asset_Norm  ,
                    NULL NPA_Norms  ,
                    --,null as [Credit_FB Exposure]
                    --,null as [Credit_NFB Exposure]
                    --,null as [Non-SLR]
                    --,null as [LER]
                    --,null as [Total Exposure]
                    --,null as [Exposure 5crore & above_Flag]
                    NULL FDOD_Flag  ,
                    NULL Limit_Expiry_Date  ,
                    NULL DPD_Limit_Expiry  ,
                    NULL Stock_Statement_valuation_date  ,
                    0 DPD_StockStmt  ,
                    NULL Debit_Balance_Since_Date  ,
                    NULL Last_Credit_Date  ,
                    0 DPD_NoCredit  ,
                    NULL Current_quarter_credit  ,
                    NULL Current_quarter_interest  ,
                    NULL Interest_Not_Serviced  ,
                    0 DPD_out_of_order  ,
                    NULL CC_OD_Interest_Service  ,
                    NULL PrincOverdue  ,
                    NULL Principal_Overdue_Date  ,
                    0 DPD_Principal_Overdue  ,
                    NULL IntOverdue  ,
                    NULL Interest_Overdue_Date  ,
                    0 DPD_Interest_Overdue  ,
                    NULL OtherOverdue  ,
                    NULL Other_OverDue_Date  ,
                    0 DPD_Other_Overdue  
             FROM CurDat_RBL_MISDB_PROD.DerivativeDetail a
                    LEFT JOIN CustomerBasicDetail b   ON a.CustomerID = b.CustomerId
                    AND b.EffectiveFromTimeKey <= v_Timekey
                    AND b.EffectiveToTimeKey >= v_Timekey
                    LEFT JOIN DimBranch c   ON a.BranchCode = c.BranchCode
                    AND c.EffectiveFromTimeKey <= v_Timekey
                    AND c.EffectiveToTimeKey >= v_Timekey
              WHERE  a.EffectiveToTimeKey = 49999
                       AND a.FinalAssetClassAlt_Key = 1 ) a );
   ------------------------------------------------------------------------------------
   UPDATE tt_Temp_SMA_Main_Table_2
      SET AccountSMA_Dt = NULL,
          UCICSMA_Dt = NULL

   --where AccountSMA_AssetClass in ('FDOD','Agri-Loan')
   WHERE  ( AccountSMA_AssetClass IN ( 'FDOD','Agri-Loan' )

     OR AccountSMA_AssetClass = 'STD' );
   -----------------------------------------------------------------------------------
   -----------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..#tt_Temp_SMA_Main_Table_2_final') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_SMA_Main_Table_fina_2 ';
   END IF;
   DELETE FROM tt_Temp_SMA_Main_Table_fina_2;
   UTILS.IDENTITY_RESET('tt_Temp_SMA_Main_Table_fina_2');

   INSERT INTO tt_Temp_SMA_Main_Table_fina_2 ( 
   	SELECT Report_Date ,
           UCIC ,
           CIF_ID ,
           Borrower_Name ,
           Branch_Code ,
           Branch_Name ,
           BranchStateName ,
           Region ,
           Account_No_ ,
           PAN ,
           Source_System ,
           Facility ,
           Scheme_Type ,
           Scheme_Code ,
           Scheme_Description ,
           Seg_Code ,
           Segment_Description ,
           Business_Segment ,
           Wholesale_Retail ,
           Balance_Outstanding ,
           Principal_Outstanding ,
           Drawing_Power ,
           Sanction_Limit ,
           OverDrawn_Amount ,
           DPD_Overdrawn ,
           --cast([Limit/DP Overdrawn Date] as date)[Limit/DP Overdrawn Date],	
           UTILS.CONVERT_TO_VARCHAR2(Limit_DP_Overdrawn_Date,200,p_style=>105) Limit_DP_Overdrawn_Date  ,
           Overdue_Amount ,
           UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,200,p_style=>105) OverDueSinceDt  ,
           DPD_Overdue ,
           Bill_PC_Overdue_Amount ,
           Overdue_Bill_PC_ID ,
           UTILS.CONVERT_TO_VARCHAR2(Bill_PC_Overdue_Date,200) Bill_PC_Overdue_Date  ,
           DPD_Bill_PC ,
           INTEREST_DIVIDENDDUEDATE ,
           INTEREST_DIVIDENDDUEAMOUNT ,
           DPD ,
           UTILS.CONVERT_TO_VARCHAR2(PartialRedumptionDueDate,200) PartialRedumptionDueDate  ,
           SMA_DPD ,
           AccountFlgSMA ,
           UTILS.CONVERT_TO_VARCHAR2(AccountSMA_Dt,200) AccountSMA_Dt  ,
           AccountSMA_AssetClass ,
           SMA_Reason ,
           DPD_UCIF_ID ,
           NVL(UCICFlgSMA, 'N') UCICFlgSMA  ,
           UTILS.CONVERT_TO_VARCHAR2(UCICSMA_Dt,200) UCICSMA_Dt  ,
           UCICSMA_AssetStatus ,
           UTILS.CONVERT_TO_VARCHAR2(First_Time_SMA_Classification_Date,200) First_Time_SMA_Classification_Date  ,
           NVL(in_default_Y_N_, 'N') in_default_Y_N_  ,
           UTILS.CONVERT_TO_VARCHAR2(in_default_date,200) in_default_date  ,
           NVL(out_of_default_Y_N_, 'N') out_of_default_Y_N_  ,
           UTILS.CONVERT_TO_VARCHAR2(out_of_default_date,200) out_of_default_date  ,
           UTILS.CONVERT_TO_VARCHAR2(MovementFromDate,200) MovementFromDate  ,
           MovementFromStatus ,
           MovementToStatus ,
           Asset_Norm ,
           NPA_Norms ,
           FDOD_Flag ,
           --cast([Limit Expiry Date]  as date)[Limit Expiry Date],	
           UTILS.CONVERT_TO_VARCHAR2(Limit_Expiry_Date,200,p_style=>105) Limit_Expiry_Date  ,
           DPD_Limit_Expiry ,
           UTILS.CONVERT_TO_VARCHAR2(Stock_Statement_valuation_date,200,p_style=>105) Stock_Statement_valuation_date  ,
           DPD_Stock_Statement_expiry ,
           UTILS.CONVERT_TO_VARCHAR2(Debit_Balance_Since_Date,200,p_style=>105) Debit_Balance_Since_Date  ,
           UTILS.CONVERT_TO_VARCHAR2(Last_Credit_Date,200,p_style=>105) Last_Credit_Date  ,
           DPD_No_Credit ,
           Current_quarter_credit ,
           Current_quarter_interest ,
           Interest_Not_Serviced ,
           DPD_out_of_order ,
           UTILS.CONVERT_TO_VARCHAR2(CC_OD_Interest_Service_Date,200,p_style=>105) CC_OD_Interest_Service_Date  ,
           Principal_Overdue ,
           UTILS.CONVERT_TO_VARCHAR2(Principal_Overdue_Date,200,p_style=>105) Principal_Overdue_Date  ,
           DPD_Principal_Overdue ,
           Interest_Overdue ,
           UTILS.CONVERT_TO_VARCHAR2(Interest_Overdue_Date,200,p_style=>105) Interest_Overdue_Date  ,
           DPD_Interest_Overdue ,
           Other_Overdue ,
           UTILS.CONVERT_TO_VARCHAR2(Other_OverDue_Date,200,p_style=>105) Other_OverDue_Date  ,
           DPD_Other_Overdue 

   	  --select convert(date,[Other OverDue Date]  ,105) 
   	  FROM tt_Temp_SMA_Main_Table_2 --WHERE [out_of_default (Y/N)]='Y'


   	--where (SMA_DPD >0 or [Source System]='Calypso' 

   	--or AccountSMA_AssetClass in ('FDOD','Agri-Loan') or [out_of_default (Y/N)]='Y')
   	WHERE  ( SMA_DPD >= 0
             OR Source_System = 'Calypso'
             OR out_of_default_Y_N_ = 'Y'
             OR AccountSMA_AssetClass IN ( 'FDOD','Agri-Loan' )

             OR ( Facility IN ( 'CC','OD' )

             AND Source_System <> 'Visionplus'
             AND SMA_DPD = 0 ) ) );
   --and DPD_Overdrawn>0   ----Added by prashant--29062024----
   --or  (Asset_Norm ='alwys_std' and AccountSMA_AssetClass in ('FDOD','Agri-Loan'))
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET AccountSMA_AssetClass = 'Agri-Loan'
    WHERE  NPA_Norms > 91
     AND AccountSMA_AssetClass <> 'Agri-Loan';
   DELETE tt_Temp_SMA_Main_Table_fina_2

    WHERE  ( Asset_Norm = 'alwys_std'
             AND AccountSMA_AssetClass NOT IN ( 'FDOD','Agri-Loan' )
            );
   --------------------------------------------------------------------------------------------
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate1
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN tt_Temp_ACCOUNT_MOVEMENT_HI B   ON A.Account_No_ = B.CustomerAcID 
    WHERE A.First_Time_SMA_Classification_Date IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.First_Time_SMA_Classification_Date = src.MovementFromDate1;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate1
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN tt_Temp_ACCOUNT_MOVEMENT_HI B   ON A.Account_No_ = B.CustomerAcID 
    WHERE A.in_default_date IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.in_default_date = src.MovementFromDate1;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate_CCOD_30
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN tt_Temp_ACCOUNT_MOVEMENT_HI_4 B   ON A.Account_No_ = B.CustomerAcID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.First_Time_SMA_Classification_Date = src.MovementFromDate_CCOD_30;
   ------------06052024 START------------------------
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET First_Time_SMA_Classification_Date = NULL,
          in_default_date = NULL
    WHERE  AccountSMA_AssetClass IN ( 'Agri-Loan','FDOD' )
   ;
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET UCIC = CIF_ID
    WHERE  ( UCIC = ' '
     OR UCIC IS NULL );
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET in_default_Y_N_ = 'N'
    WHERE  OverDueSinceDt > AccountSMA_Dt;
   IF utils.object_id('TEMPDB..tt_Temp_AccountSMA_Dt') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_AccountSMA_Dt ';
   END IF;
   DELETE FROM tt_Temp_AccountSMA_Dt;
   UTILS.IDENTITY_RESET('tt_Temp_AccountSMA_Dt');

   INSERT INTO tt_Temp_AccountSMA_Dt ( 
   	SELECT DISTINCT Account_No_ 
   	  FROM tt_Temp_SMA_Main_Table_fina_2 
   	 WHERE  AccountSMA_Dt IS NULL
              AND AccountFlgSMA = 'Y' );
   IF utils.object_id('TEMPDB..tt_TempMaxEntityKey_AccountSMA_Dt') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempMaxEntityKey_Account ';
   END IF;
   DELETE FROM tt_TempMaxEntityKey_Account;
   UTILS.IDENTITY_RESET('tt_TempMaxEntityKey_Account');

   INSERT INTO tt_TempMaxEntityKey_Account ( 
   	SELECT A.CustomerAcID ,
           MAX(A.EntityKey)  EntityKey  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a
             JOIN tt_Temp_AccountSMA_Dt b   ON a.CustomerAcID = b.Account_No_
   	 WHERE  A.FinalAssetClassAlt_Key = 1
              AND MovementToStatus IN ( 'STD','SMA_0','SMA_1','SMA_2' )

   	  GROUP BY a.CustomerAcID );
   IF utils.object_id('TEMPDB..tt_Temp_ACCOUNT_MOVEMENT_HI_5_AccountSMA_Dt') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_ACCOUNT_MOVEMENT_HI_6 ';
   END IF;
   DELETE FROM tt_Temp_ACCOUNT_MOVEMENT_HI_6;
   UTILS.IDENTITY_RESET('tt_Temp_ACCOUNT_MOVEMENT_HI_6');

   INSERT INTO tt_Temp_ACCOUNT_MOVEMENT_HI_6 ( 
   	SELECT A.CustomerAcID ,
           MovementFromStatus ,
           MovementToStatus ,
           MovementFromDate ,
           MovementToDate 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY a
             JOIN tt_TempMaxEntityKey_Account b   ON a.EntityKey = b.EntityKey );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
          JOIN tt_Temp_ACCOUNT_MOVEMENT_HI_6 b   ON a.Account_No_ = b.CustomerAcID 
    WHERE a.AccountSMA_Dt IS NULL
     AND a.AccountFlgSMA = 'Y') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.AccountSMA_Dt = src.MovementFromDate;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, A.AccountSMA_Dt
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 a 
    WHERE a.in_default_date IS NULL
     AND a.AccountFlgSMA = 'Y') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.in_default_date = src.AccountSMA_Dt;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, AccountSMA_Dt
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 a 
    WHERE First_Time_SMA_Classification_Date IS NULL
     AND a.AccountFlgSMA = 'Y') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.First_Time_SMA_Classification_Date = AccountSMA_Dt;
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET AccountFlgSMA = 'N',
          SMA_DPD = 0,
          AccountSMA_AssetClass = 'STD',
          AccountSMA_Dt = NULL,
          SMA_Reason = NULL
    WHERE  NVL(Balance_Outstanding, 0) <= 0
     AND NVL(Principal_Outstanding, 0) <= 0;
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET AccountSMA_AssetClass = 'Agri-Loan'
    WHERE  NPA_Norms > 91;
   --------------------06052024 END-------------------------
   -------------------CCOD Patch------------start--------------------------------------------
   --Update #tt_Temp_SMA_Main_Table_2_final
   --set [in_default date]=null,[First Time SMA Classification Date]=null
   --where Facility in ('CC','OD')
   --AND isnull([Source System],'')<>'Visionplus'
   --and isnull(AccountSMA_AssetClass,'') not in ('Agri-Loan','FDOD')
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET in_default_Y_N_ = 'N',
          out_of_default_Y_N_ = 'N',
          out_of_default_date = NULL
    WHERE  Facility IN ( 'CC','OD' )

     AND NVL(Source_System, ' ') <> 'Visionplus'
     AND NVL(AccountSMA_AssetClass, ' ') NOT IN ( 'Agri-Loan','FDOD' )
   ;
   ----Drop table if exists Pro.CCOD_SMA
   --insert  into   Pro.CCOD_SMA
   -- select        a.AccountEntityID,a.CustomerAcID,b.MovementFromDate,b.MovementFromStatus,
   --			   b.MovementToStatus ,b.MovementToDate
   --				,b.EffectiveFromTimeKey,b.effectivetotimekey
   --from           pro.AccountCal A
   -- INNER JOIN    PRO.ACCOUNT_MOVEMENT_HISTORY B
   -- ON            A.CustomerAcID=B.CustomerAcID
   -- --where         b.EffectiveToTimeKey=49999
   -- where           a.SourceAlt_Key<>6
   -- and           FacilityType in ('CC','OD')
   -- --and           b.MovementToStatus<>'STD'
   -- and           a.RefPeriodOverdue<=91
   -- and           b.FinalAssetClassAlt_Key=1
   --Update  Pro.CCOD_SMA
   --set     MovementToStatus='STD'
   --WHERE   MovementToStatus='SMA_0'
   --Update  Pro.CCOD_SMA
   --set     MovementFromStatus='STD'
   --WHERE   MovementFromStatus='SMA_0'
   --Update  Pro.CCOD_SMA
   --set     EffectiveFromTimeKey=@Timekey-1,MovementFromDate=dateadd(day,-1,@Date)
   --WHERE   EffectiveFromTimeKey=@Timekey
   --Update        a
   --set           a.MovementToStatus='STD'
   --FROM          Pro.CCOD_SMA A
   --INNER JOIN    PRO.Accountcal_hist_DPD B
   --ON            A.AccountEntityID=B.AccountEntityid
   --WHERE         B.TimeKey=@Timekey-1
   --AND           B.DPD_Overdrawn <=30
   --AND           A.EffectiveFromTimeKey <= @Timekey-1 AND A.EffectiveToTimeKey >=@Timekey-1
   ---------------sma ccod data moving into temp table------------------------------------------
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE v_Timekey @Timekey > ( SELECT MAX ( EffectiveFromTimeKey ) FROM Pro . CCOD_SMA ) BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED > ( SELECT MAX(EffectiveFromTimeKey)  
                                                                                                                                                FROM PRO_RBL_MISDB_PROD.CCOD_SMA  );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      IF tt_CCOD_SMA_2  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_CCOD_SMA_2;
      UTILS.IDENTITY_RESET('tt_CCOD_SMA_2');

      INSERT INTO tt_CCOD_SMA_2 ( 
      	SELECT B.AccountEntityID ,
              A."Account No." customeracid  ,
              NVL(c.MovementToStatus, 'STD') MovementFromStatus  ,
              A.AccountSMA_AssetClass MovementToStatus  ,
              ( SELECT Date_ 
                FROM Automate_Advances 
               WHERE  Ext_flg = 'Y' ) MovementFromDate  ,
              ( SELECT Timekey 
                FROM Automate_Advances 
               WHERE  Ext_flg = 'Y' ) effectivefromtimekey  ,
              49999 effectivetotimekey  
      	  FROM tt_Temp_SMA_Main_Table_fina_2 A
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.Account_No_ = B.CustomerAcID
                LEFT JOIN PRO_RBL_MISDB_PROD.CCOD_SMA c   ON A.Account_No_ = c.CustomerAcID
                AND c.effectivetotimekey = 49999
      	 WHERE  Source_System <> 'Visionplus'
                 AND Facility IN ( 'CC','OD' )

                 AND a.AccountSMA_AssetClass NOT IN ( 'Agri-Loan','FDOD' )
       );
      --AND           A.AccountSMA_AssetClass IN ('SMA_1','SMA_2')        
      --previous day and current data are same then data is delete from temp table
      DELETE A
       WHERE ROWID IN 
      ( SELECT A.ROWID
        FROM tt_CCOD_SMA_2 A
               JOIN PRO_RBL_MISDB_PROD.CCOD_SMA B   ON A.Customeracid = B.Customeracid,
             A
       WHERE  b.effectivetotimekey = 49999
                AND A.MovementToStatus = B.MovementToStatus );
      --mismatch data are expired from ccod main table
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, v_timekey - 1 AS effectivetotimekey
      FROM A ,PRO_RBL_MISDB_PROD.CCOD_SMA A
             JOIN tt_CCOD_SMA_2 B   ON A.Customeracid = B.Customeracid 
       WHERE A.effectivetotimekey = 49999
        AND NVL(A.MovementToStatus, ' ') <> NVL(B.MovementToStatus, ' ')) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET a.effectivetotimekey = src.effectivetotimekey;
      --insert mismatch data inserted into ccod main table
      INSERT INTO PRO_RBL_MISDB_PROD.CCOD_SMA
        ( AccountEntityID, CustomerAcID, MovementFromDate, MovementFromStatus, MovementToStatus, MovementToDate, EffectiveFromTimeKey, effectivetotimekey )
        ( SELECT AccountEntityID ,
                 Customeracid ,
                 MovementFromDate ,
                 MovementFromStatus ,
                 MovementToStatus ,
                 v_date ,
                 v_Timekey ,
                 49999 
          FROM tt_CCOD_SMA_2  );

   END;
   END IF;
   ----------------------------------------------------------------------------------------
   --outofdefault flag and date are updated
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'Y', v_Date
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN PRO_RBL_MISDB_PROD.CCOD_SMA B   ON A.Account_No_ = B.Customeracid 
    WHERE A.Source_System <> 'Visionplus'
     AND A.Facility IN ( 'CC','OD' )

     AND B.effectiveFROMtimekey = v_Timekey
     AND b.MovementToStatus = 'STD'

     -------added by Prashant--19092024----------
     AND NVL(b.MovementFromStatus, ' ') <> NVL(b.MovementToStatus, ' ')) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.out_of_default_Y_N_ = 'Y',
                                A.out_of_default_date = v_Date;
   --getting indefault date data
   DELETE FROM tt_CCOD_INDEFAULT_2;
   UTILS.IDENTITY_RESET('tt_CCOD_INDEFAULT_2');

   INSERT INTO tt_CCOD_INDEFAULT_2 ( 
   	SELECT CustomerAcID ,
           MAX(MovementFromDate)  MovementFromDateCCOD_IN  
   	  FROM PRO_RBL_MISDB_PROD.CCOD_SMA b
   	 WHERE  B.MovementFromStatus = 'STD'
              AND B.MovementToStatus IN ( 'SMA_1','SMA_2' )

   	  GROUP BY CustomerAcID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDateCCOD_IN, CASE 
   WHEN b.MovementFromDateCCOD_IN = v_date THEN 'Y'
   ELSE 'N'
      END AS pos_3, b.MovementFromDateCCOD_IN
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN tt_CCOD_INDEFAULT_2 b   ON A.Account_No_ = B.Customeracid ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.in_default_date = src.MovementFromDateCCOD_IN,
                                a.in_default_Y_N_ = pos_3,
                                A.First_Time_SMA_Classification_Date = src.MovementFromDateCCOD_IN;
   -----------------------------------------------------------------
   DELETE FROM tt_CCOD_ACCOUNT_SMA_2;
   UTILS.IDENTITY_RESET('tt_CCOD_ACCOUNT_SMA_2');

   INSERT INTO tt_CCOD_ACCOUNT_SMA_2 ( 
   	SELECT CustomerAcID ,
           MAX(MovementFromDate)  MovementFromDate_ACCSMA  
   	  FROM PRO_RBL_MISDB_PROD.CCOD_SMA b
   	 WHERE  B.MovementToStatus IN ( 'SMA_1','SMA_2' )

              AND MovementFromStatus <> MovementToStatus
   	  GROUP BY CustomerAcID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate_ACCSMA
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN tt_CCOD_ACCOUNT_SMA_2 b   ON A.Account_No_ = B.Customeracid ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.AccountSMA_Dt = src.MovementFromDate_ACCSMA;
   ---------------------------------------------------------------------
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate, b.MovementFromStatus, b.MovementToStatus
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
          JOIN PRO_RBL_MISDB_PROD.CCOD_SMA b   ON A.Account_No_ = B.Customeracid 
    WHERE b.EffectiveFromTimeKey <= v_TIMEKEY
     AND b.effectivetotimekey >= v_TIMEKEY) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.MovementFromDate = src.MovementFromDate,
                                a.MovementFromStatus = src.MovementFromStatus,
                                a.MovementToStatus = src.MovementToStatus;
   ---------------------------------------------------------------------
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET AccountSMA_Dt = NULL,
          UCICSMA_Dt = NULL
    WHERE  ( AccountSMA_AssetClass IN ( 'FDOD','Agri-Loan' )

     OR AccountSMA_AssetClass = 'STD' );
   -------------------CCOD Patch------------END---------------------------------------------
   -- Update   #tt_Temp_SMA_Main_Table_2_final
   -- set      MovementFromStatus=null,
   --	   MovementToStatus=null,
   --	   MovementFromDate=null
   --Update       A
   --set          a.MovementFromDate=b.MovementFromDate,a.MovementFromStatus=b.MovementFromStatus,a.MovementToStatus=b.MovementToStatus
   --from         #tt_Temp_SMA_Main_Table_2_final a
   --inner join   tt_ACCOUNT_MOVEMENT_HISTORY_8 b
   -- on          a.[Account No.]=b.CustomerACID
   --inner join   curdat.AdvAcBasicDetail c
   --on           c.CustomerAcID=b.CustomerACID
   --where        b.MovementFromDate=@Date
   --and          isnull(b.MovementFromStatus,'')<>isnull(b.MovementToStatus,'')
   --and          isnull(c.FacilityType,'') not in ('CC','OD')
   --and          c.SourceAlt_Key<>6
   -- Update       A
   --set          a.MovementFromDate=b.MovementFromDate,a.MovementFromStatus=b.MovementFromStatus,a.MovementToStatus=b.MovementToStatus
   --from         #tt_Temp_SMA_Main_Table_2_final a
   --inner join   Pro.CCOD_SMA b
   -- on          a.[Account No.]=b.CustomerACID
   --inner join   curdat.AdvAcBasicDetail c
   --on           c.CustomerAcID=b.CustomerACID
   --where        b.MovementFromDate=@Date
   --and          isnull(b.MovementFromStatus,'')<>isnull(b.MovementToStatus,'')
   --and          isnull(c.FacilityType,'')  in ('CC','OD')
   /*
    Update   #tt_Temp_SMA_Main_Table_2_final
     set      MovementFromStatus=null,
   		   MovementToStatus=null,
   		   MovementFromDate=null

   drop table if exists #CUSTOMER_MOVEMENT_HISTORY
   select * into #CUSTOMER_MOVEMENT_HISTORY
   from     pro.CUSTOMER_MOVEMENT_HISTORY
   where    EffectiveFromTimeKey <=@Timekey and EffectiveToTimeKey >=@Timekey
   and      isnull(MovementFromStatus,'')<>isnull(MovementToStatus,'')
   and      MovementFromDate=@Date
   and      SysAssetClassAlt_Key=1


    Update       A
    set          a.MovementFromDate=@Date,a.MovementFromStatus=b.MovementFromStatus,
   			  a.MovementToStatus=isnull(b.MovementToStatus,'STD')
    from         #tt_Temp_SMA_Main_Table_2_final a
    inner join   #CUSTOMER_MOVEMENT_HISTORY b
     on          a.[CIF ID]=b.RefCustomerID
    inner join   curdat.AdvAcBasicDetail c
    on           c.CustomerAcID=a.[Account No.]
    where        b.MovementFromDate=@Date
    and          isnull(b.MovementFromStatus,'')<>isnull(b.MovementToStatus,'')
    and          isnull(c.FacilityType,'') not in ('CC','OD')


    Update       A
    set          a.MovementFromDate=@Date,a.MovementFromStatus=b.MovementFromStatus,
   			  a.MovementToStatus=isnull(b.MovementToStatus,'STD')
    from         #tt_Temp_SMA_Main_Table_2_final a
    inner join   #CUSTOMER_MOVEMENT_HISTORY b
    on           a.[CIF ID]=b.RefCustomerID
    inner join   curdat.AdvAcBasicDetail c
    on           c.CustomerAcID=a.[Account No.]
    where        b.MovementFromDate=@Date
    and          isnull(b.MovementFromStatus,'')<>isnull(b.MovementToStatus,'')
    and          isnull(c.FacilityType,'')  in ('CC','OD')
    and          c.SourceAlt_Key<>6
    and          isnull(b.MovementFromStatus,'')<>'SMA_0'
    AND          isnull(b.MovementToStatus,'')<>'SMA_0'
    */
   --------------------------------Added by Prashant------------------------------------------------------------------------
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, NVL(b.MovementToStatus, 'STD') AS pos_2, CASE 
   WHEN A.UCICSMA_AssetStatus IN ( 'FDOD','Agri-Loan' )
    THEN 'STD'
   ELSE A.UCICSMA_AssetStatus
      END AS pos_3
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
          LEFT JOIN tt_SMA_Classification_Hist b   ON a.UCIC = b.UCIF_ID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.MovementFromStatus = pos_2,
                                a.MovementToStatus = pos_3;
   -------------------------------------------------------------------------------------------------------------------
   -- select distinct UCIC 
   -- into   #Temp_movementfrom
   -- from   #tt_Temp_SMA_Main_Table_2_final
   -- where  MovementFromDate=@Date
   -- and    isnull(MovementFromStatus,'')<>isnull(MovementToStatus,'')
   --Update        A
   --set           a.MovementFromDate=null,MovementFromStatus=null,MovementToStatus=null
   --from          #tt_Temp_SMA_Main_Table_2_final a
   --left join     #Temp_movementfrom b
   --on            a.UCIC=b.UCIC
   --where         b.UCIC is null
   --Update  #tt_Temp_SMA_Main_Table_2_final
   --set     MovementFromDate=@Date,MovementToStatus='STD'
   --where   [out_of_default date]=@Date 
   --Update  #tt_Temp_SMA_Main_Table_2_final
   --set     MovementFromDate=@Date,MovementFromStatus='STD'
   --where   [in_default date]=@Date 
   -------------------------------------------------------------------------------------
   WITH CTE_UCIC AS ( SELECT A.UCIC ,
                             MAX(SMA_DPD)  DPD_UCIF_ID  ,
                             MAX(CASE 
                                      WHEN NVL(UCICFlgSMA, 'N') = 'Y' THEN 1
                                 ELSE 0
                                    END)  UCICFlgSMA  ,
                             UTILS.CONVERT_TO_VARCHAR2(MAX(CASE 
                                                                WHEN AccountSMA_AssetClass = 'SMA_2' THEN '00006'
                                                                WHEN AccountSMA_AssetClass = 'SMA_1' THEN '00005'
                                                                WHEN AccountSMA_AssetClass = 'SMA_0' THEN '00004'
                                                                WHEN AccountSMA_AssetClass = 'STD' THEN '00003'
                                                                WHEN AccountSMA_AssetClass = 'FDOD' THEN '00002'
                                                                WHEN AccountSMA_AssetClass = 'Agri-Loan' THEN '00001'   END) ,20) UCIC_Assetclass  ,
                             MIN(AccountSMA_Dt)  UCICSMA_Dt  ,
                             MIN(First_Time_SMA_Classification_Date)  First_Time_SMA_Classification_Date  ,
                             MIN(in_default_date)  in_default_date  ,
                             MIN(MovementFromDate)  MovementFromDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(MAX(CASE 
                                                                WHEN MovementFromStatus = 'SMA_2' THEN '00006'
                                                                WHEN MovementFromStatus = 'SMA_1' THEN '00005'
                                                                WHEN MovementFromStatus = 'SMA_0' THEN '00004'
                                                                WHEN MovementFromStatus = 'STD' THEN '00003'
                                                                WHEN MovementFromStatus = 'FDOD' THEN '00002'
                                                                WHEN MovementFromStatus = 'Agri-Loan' THEN '00001'   END) ,20) MovementFromStatus  ,
                             UTILS.CONVERT_TO_VARCHAR2(MAX(CASE 
                                                                WHEN MovementToStatus = 'SMA_2' THEN '00006'
                                                                WHEN MovementToStatus = 'SMA_1' THEN '00005'
                                                                WHEN MovementToStatus = 'SMA_0' THEN '00004'
                                                                WHEN MovementToStatus = 'STD' THEN '00003'
                                                                WHEN MovementToStatus = 'FDOD' THEN '00002'
                                                                WHEN MovementToStatus = 'Agri-Loan' THEN '00001'   END) ,20) MovementToStatus  ,
                             MAX(CASE 
                                      WHEN NVL(in_default_Y_N_, 'N') = 'Y' THEN 1
                                 ELSE 0
                                    END)  in_default_Y_N_  ,
                             MAX(CASE 
                                      WHEN NVL(out_of_default_Y_N_, 'N') = 'Y' THEN 1
                                 ELSE 0
                                    END)  out_of_default_Y_N_  ,
                             MIN(out_of_default_date)  out_of_default_date  
     FROM tt_Temp_SMA_Main_Table_fina_2 a
    WHERE  AccountSMA_AssetClass <> 'STD' ----added by Swapna with Prashant--14052024


   --inner join      tt_TEMP_34_ucic_fdod_agri b

   --on              a.UCIC=b.UCIC
   GROUP BY A.UCIC
            --)select * from  CTE_UCIC
    ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN b.UCICFlgSMA = 1 THEN 'Y'
      ELSE 'N'
         END) AS pos_2, b.DPD_UCIF_ID, (CASE 
      WHEN UCIC_Assetclass = '00006' THEN 'SMA_2'
      WHEN UCIC_Assetclass = '00005' THEN 'SMA_1'
      WHEN UCIC_Assetclass = '00004' THEN 'SMA_0'
      ELSE A.AccountSMA_AssetClass
         END) AS pos_4, b.UCICSMA_Dt, b.in_default_date, b.First_Time_SMA_Classification_Date, b.MovementFromDate, (CASE 
      WHEN b.MovementFromStatus = '00006' THEN 'SMA_2'
      WHEN b.MovementFromStatus = '00005' THEN 'SMA_1'
      WHEN b.MovementFromStatus = '00004' THEN 'SMA_0'
      WHEN b.MovementFromStatus = '00003' THEN 'STD'
      WHEN b.MovementFromStatus = '00002' THEN 'STD'
      WHEN b.MovementFromStatus = '00001' THEN 'STD'
      ELSE A.MovementFromStatus
         END) AS pos_9, (CASE 
      WHEN b.MovementToStatus = '00006' THEN 'SMA_2'
      WHEN b.MovementToStatus = '00005' THEN 'SMA_1'
      WHEN b.MovementToStatus = '00004' THEN 'SMA_0'
      WHEN b.MovementToStatus = '00003' THEN 'STD'
      WHEN b.MovementToStatus = '00002' THEN 'STD'
      WHEN b.MovementToStatus = '00001' THEN 'STD'
      ELSE A.MovementToStatus
         END) AS pos_10, (CASE 
      WHEN b.in_default_Y_N_ = 1 THEN 'Y'
      ELSE 'N'
         END) AS pos_11, (CASE 
      WHEN b.out_of_default_Y_N_ = 1 THEN 'Y'
      ELSE 'N'
         END) AS pos_12, b.out_of_default_date
      FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
             JOIN CTE_UCIC b   ON A.UCIC = b.ucic ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET a.UCICFlgSMA = pos_2,
                                   a.DPD_UCIF_ID = src.DPD_UCIF_ID,
                                   a.UCICSMA_AssetStatus = pos_4,
                                   a.UCICSMA_Dt = src.UCICSMA_Dt,
                                   a.in_default_date = src.in_default_date,
                                   a.First_Time_SMA_Classification_Date = src.First_Time_SMA_Classification_Date,
                                   a.MovementFromDate = src.MovementFromDate,
                                   a.MovementFromStatus = pos_9,
                                   a.MovementToStatus = pos_10,
                                   a.in_default_Y_N_ = pos_11,
                                   a.out_of_default_Y_N_ = pos_12,
                                   a.out_of_default_date = src.out_of_default_date
      ;
   ---------------------------------------------------------------------------------------------------------
   --;With CTE_UCIC_1 AS
   --(
   --select a.UCIC,MAX(SMA_DPD)DPD_UCIF_ID,max(case when MovementToStatus='STD' THEN 1 ELSE 0 END)MovementToStatus
   --from            #tt_Temp_SMA_Main_Table_2_final a
   --group by a.UCIC
   --)
   --Update      a
   --set          a.MovementToStatus=case when UCICSMA_AssetStatus<>'STD' then null else 'STD' end
   --from         #tt_Temp_SMA_Main_Table_2_final a
   --inner join   CTE_UCIC_1 b
   --on           a.UCIC=b.ucic
   --where        b.MovementToStatus=1
   --Update  #tt_Temp_SMA_Main_Table_2_final
   --set     MovementFromStatus=null,MovementFromDate=null
   --where   UCICSMA_AssetStatus<>'STD'
   WITH CTE_UCIC_1 AS ( SELECT A.UCIC ,
                               MIN(First_Time_SMA_Classification_Date)  First_Time_SMA_Classification_Date  ,
                               MIN(in_default_date)  in_default_date  ,
                               MIN(MovementFromDate)  MovementFromDate  ,
                               UTILS.CONVERT_TO_VARCHAR2(MAX(CASE 
                                                                  WHEN MovementFromStatus = 'SMA_2' THEN '00006'
                                                                  WHEN MovementFromStatus = 'SMA_1' THEN '00005'
                                                                  WHEN MovementFromStatus = 'SMA_0' THEN '00004'
                                                                  WHEN MovementFromStatus = 'STD' THEN '00003'
                                                                  WHEN MovementFromStatus = 'FDOD' THEN '00002'
                                                                  WHEN MovementFromStatus = 'Agri-Loan' THEN '00001'   END) ,20) MovementFromStatus  ,
                               UTILS.CONVERT_TO_VARCHAR2(MAX(CASE 
                                                                  WHEN MovementToStatus = 'SMA_2' THEN '00006'
                                                                  WHEN MovementToStatus = 'SMA_1' THEN '00005'
                                                                  WHEN MovementToStatus = 'SMA_0' THEN '00004'
                                                                  WHEN MovementToStatus = 'STD' THEN '00003'
                                                                  WHEN MovementToStatus = 'FDOD' THEN '00002'
                                                                  WHEN MovementToStatus = 'Agri-Loan' THEN '00001'   END) ,20) MovementToStatus  ,
                               MIN(out_of_default_date)  out_of_default_date  ,
                               MAX(CASE 
                                        WHEN NVL(in_default_Y_N_, 'N') = 'Y' THEN 1
                                   ELSE 0
                                      END)  in_default_Y_N_  ,
                               MAX(CASE 
                                        WHEN NVL(out_of_default_Y_N_, 'N') = 'Y' THEN 1
                                   ELSE 0
                                      END)  out_of_default_Y_N_  ,
                               MAX(CASE 
                                        WHEN NVL(UCICFlgSMA, 'N') = 'Y' THEN 1
                                   ELSE 0
                                      END)  UCICFlgSMA  ,
                               UTILS.CONVERT_TO_VARCHAR2(MAX(CASE 
                                                                  WHEN AccountSMA_AssetClass = 'SMA_2' THEN '00006'
                                                                  WHEN AccountSMA_AssetClass = 'SMA_1' THEN '00005'
                                                                  WHEN AccountSMA_AssetClass = 'SMA_0' THEN '00004'
                                                                  WHEN AccountSMA_AssetClass = 'STD' THEN '00003'
                                                                  WHEN AccountSMA_AssetClass = 'FDOD' THEN '00002'
                                                                  WHEN AccountSMA_AssetClass = 'Agri-Loan' THEN '00001'   END) ,20) UCIC_Assetclass  ,
                               MAX(SMA_DPD)  DPD_UCIF_ID  ,
                               MIN(AccountSMA_Dt)  UCICSMA_Dt  
     FROM tt_Temp_SMA_Main_Table_fina_2 a
     GROUP BY A.UCIC ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, b.in_default_date, b.First_Time_SMA_Classification_Date, b.MovementFromDate, (CASE 
      WHEN b.MovementFromStatus = '00006' THEN 'SMA_2'
      WHEN b.MovementFromStatus = '00005' THEN 'SMA_1'
      WHEN b.MovementFromStatus = '00004' THEN 'SMA_0'
      WHEN b.MovementFromStatus = '00003' THEN 'STD'
      WHEN b.MovementFromStatus = '00002' THEN 'STD'
      WHEN b.MovementFromStatus = '00001' THEN 'STD'
      ELSE A.MovementFromStatus
         END) AS pos_5, (CASE 
      WHEN b.MovementToStatus = '00006' THEN 'SMA_2'
      WHEN b.MovementToStatus = '00005' THEN 'SMA_1'
      WHEN b.MovementToStatus = '00004' THEN 'SMA_0'
      WHEN b.MovementToStatus = '00003' THEN 'STD'
      WHEN b.MovementToStatus = '00002' THEN 'STD'
      WHEN b.MovementToStatus = '00001' THEN 'STD'
      ELSE A.MovementToStatus
         END) AS pos_6, b.out_of_default_date, (CASE 
      WHEN b.in_default_Y_N_ = 1 THEN 'Y'
      ELSE 'N'
         END) AS pos_8, (CASE 
      WHEN b.out_of_default_Y_N_ = 1 THEN 'Y'
      ELSE 'N'
         END) AS pos_9, (CASE 
      WHEN b.UCICFlgSMA = 1 THEN 'Y'
      ELSE 'N'
         END) AS pos_10, b.DPD_UCIF_ID, (CASE 
      WHEN UCIC_Assetclass = '00006' THEN 'SMA_2'
      WHEN UCIC_Assetclass = '00005' THEN 'SMA_1'
      WHEN UCIC_Assetclass = '00004' THEN 'SMA_0'
      ELSE A.AccountSMA_AssetClass
         END) AS pos_12, b.UCICSMA_Dt
      FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
             JOIN CTE_UCIC_1 b   ON A.UCIC = b.ucic ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET a.in_default_date = src.in_default_date,
                                   a.First_Time_SMA_Classification_Date = src.First_Time_SMA_Classification_Date,
                                   a.MovementFromDate = src.MovementFromDate,
                                   a.MovementFromStatus = pos_5,
                                   a.MovementToStatus = pos_6,
                                   a.out_of_default_date = src.out_of_default_date,
                                   a.in_default_Y_N_ = pos_8,
                                   a.out_of_default_Y_N_ = pos_9,
                                   a.UCICFlgSMA = pos_10,
                                   a.DPD_UCIF_ID = src.DPD_UCIF_ID,
                                   a.UCICSMA_AssetStatus = pos_12,
                                   a.UCICSMA_Dt = src.UCICSMA_Dt
      ;
   --where        b.MovementToStatus=1
   ------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_PERCOLATION_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_PERCOLATION_8 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_PERCOLATION_8;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_PERCOLATION_8');

   INSERT INTO tt_TEMPTABLE_PERCOLATION_8 SELECT A.UCIC ,
                                                 A."CIF ID" ,
                                                 A."Account No." ,
                                                 A.SMA_Reason 
        FROM tt_Temp_SMA_Main_Table_fina_2 A
       WHERE  A.SMA_Reason IS NOT NULL
        ORDER BY A.UCIC,
                 A.CIF_ID,
                 A.Account_No_;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'Link By AccountId' || ' ' || B.Account_No_ AS SMA_Reason
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 A
          JOIN tt_TEMPTABLE_PERCOLATION_8 B   ON A.UCIC = B.UCIC 
    WHERE A.SMA_Reason IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SMA_Reason = src.SMA_Reason;
   ---------------------------------------------------------------------------------------------
   --	Update  #tt_Temp_SMA_Main_Table_2_final
   --set     [out_of_default date]=null
   --where   [out_of_default date] is not null
   --and     UCICSMA_AssetStatus<>'STD'
   --Update  #tt_Temp_SMA_Main_Table_2_final
   --set     [out_of_default (Y/N)]='N'
   --where   [out_of_default (Y/N)]='Y'
   --and     UCICSMA_AssetStatus<>'STD'
   --Update  #tt_Temp_SMA_Main_Table_2_final
   --set     [in_default (Y/N)]='N'
   --where   cast(@Date as date) > [in_default date]
   -----------------------Added by Prashant--------07072024---------------------------
   --Delete from #tt_Temp_SMA_Main_Table_2_final
   --where DPD_UCIF_ID=0 and [out_of_default (Y/N)]='N'
   --and AccountSMA_AssetClass not in ('Agri-Loan','FDOD') and isnull(UCICFlgSMA,'N')='N'
   --and UCIC not in (select UCIC from tt_Tempucifid4)
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_Temp_SMA_Main_Table_fina_2 a
            LEFT JOIN tt_Tempucifid4 b   ON A.UCIC = b.UCIF_ID,
          A
    WHERE  DPD_UCIF_ID = 0
             AND out_of_default_Y_N_ = 'N'
             AND AccountSMA_AssetClass NOT IN ( 'Agri-Loan','FDOD' )

             AND NVL(UCICFlgSMA, 'N') = 'N'
             AND A."Source System" <> 'calypso'
             AND b.UCIF_ID IS NULL );
   --and UCIC not in (select UCIC from tt_Tempucifid4)
   WITH CTE_UCIC_4 AS ( SELECT A.UCIC ,
                               MAX(SMA_DPD)  DPD_UCIF_ID  
     FROM tt_Temp_SMA_Main_Table_fina_2 a
     GROUP BY A.UCIC ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, b.DPD_UCIF_ID
      FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
             JOIN CTE_UCIC_4 b   ON A.UCIC = b.ucic ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET a.DPD_UCIF_ID = src.DPD_UCIF_ID
      ;
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET in_default_Y_N_ = 'N',
          in_default_date = NULL,
          out_of_default_Y_N_ = 'N',
          out_of_default_date = NULL,
          MovementFromDate = NULL;
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET in_default_Y_N_ = 'Y',
          in_default_date = v_Date,
          First_Time_SMA_Classification_Date = v_Date
    WHERE  MovementFromStatus = 'STD'
     AND MovementToStatus IN ( 'SMA_0','SMA_1','SMA_2' )
   ;
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET out_of_default_Y_N_ = 'Y',
          out_of_default_date = v_Date
    WHERE  MovementFromStatus IN ( 'SMA_0','SMA_1','SMA_2' )

     AND MovementToStatus = 'STD';
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET MovementFromDate = v_Date
    WHERE  NVL(MovementFromStatus, ' ') <> NVL(MovementToStatus, ' ');
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET in_default_date = First_Time_SMA_Classification_Date
    WHERE  NVL(in_default_date, '1900-01-01') <> v_Date;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.in_default_date, b.in_default_date
   FROM A ,tt_Temp_SMA_Main_Table_fina_2 a
          JOIN tt_SMA_Classification_Hist b   ON a.UCIC = b.UCIF_ID 
    WHERE a.First_Time_SMA_Classification_Date IS NULL
     AND b.in_default_date IS NOT NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.First_Time_SMA_Classification_Date = src.in_default_date,
                                a.in_default_date = src.in_default_date;
   ----------------------------------------------------------------------------------------------------------
   DELETE PRO_RBL_MISDB_PROD.SMA_Classification_Hist

    WHERE  Timekey = v_Timekey;
   INSERT INTO PRO_RBL_MISDB_PROD.SMA_Classification_Hist
     ( SELECT DISTINCT UCIC ,
                       v_Timekey ,
                       A."in_default date" ,
                       A."out_of_default date" ,
                       --CASE WHEN B.MovementToStatus IN ('Agri-Loan','FDOD') THEN 'STD' ELSE B.MovementToStatus END as MovementFromStatus
                       CASE 
                            WHEN MovementFromStatus IN ( 'Agri-Loan','FDOD' )
                             THEN 'STD'
                       ELSE MovementFromStatus
                          END MovementFromStatus  ,
                       CASE 
                            WHEN A."UCICSMA_AssetStatus" IN ( 'Agri-Loan','FDOD' )
                             THEN 'STD'
                       ELSE A."UCICSMA_AssetStatus"
                          END MovementToStatus  ,
                       A."MovementFromDate" 
       FROM tt_Temp_SMA_Main_Table_fina_2 A );
   --INNER JOIN     tt_SMA_Classification_Hist B
   --ON             A.UCIC=B.UCIF_ID
   --Group by       [UCIC]
   ------------------------------------------------------------------------------------------------------------------------------------
   UPDATE tt_Temp_SMA_Main_Table_fina_2
      SET MovementFromStatus = NULL,
          MovementToStatus = NULL
    WHERE  NVL(MovementFromDate, '1900-01-01') <> v_Date;
   /*

   Update  #tt_Temp_SMA_Main_Table_2_final
   set   [in_default date]=[First Time SMA Classification Date]
   where isnull([First Time SMA Classification Date],'1900-01-01')<>isnull([in_default date],'1900-01-01')

   Update  #tt_Temp_SMA_Main_Table_2_final
   set     MovementFromDate=@Date,MovementToStatus='STD',[out_of_default (Y/N)]='Y'
   where   [out_of_default date]=@Date 

   Update  #tt_Temp_SMA_Main_Table_2_final
   set     MovementFromDate=@Date,MovementFromStatus='STD',[in_default (Y/N)]='Y'
   where   [in_default date]=@Date 

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementFromDate=null,MovementFromStatus=NULL,MovementToStatus=null
   where UCICSMA_AssetStatus in ('FDOD','Agri-Loan')

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementFromDate=null,MovementFromStatus=NULL,MovementToStatus=null
   where isnull([in_default date],'')<>@Date 
   and isnull(MovementFromStatus,'')=isnull(MovementToStatus,'')
   and isnull(MovementFromStatus,'')<>'STD'

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementFromDate=null,MovementFromStatus=NULL,MovementToStatus=null
   where isnull([out_of_default date],'')<>@Date 
   and isnull(MovementFromStatus,'')=isnull(MovementToStatus,'')
   and isnull(MovementToStatus,'')<>'STD'

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementFromDate=null,MovementFromStatus=NULL,MovementToStatus=null
   where isnull([in_default date],'')<>@Date 
   and isnull(MovementFromStatus,'')='STD'
   and isnull(MovementToStatus,'')<>'STD'

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementFromDate=null,MovementFromStatus=NULL,MovementToStatus=null
   where isnull([out_of_default date],'')<>@Date 
   and isnull(MovementFromStatus,'')<>'STD'
   and isnull(MovementToStatus,'')='STD'

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementFromDate=@Date
   where isnull(MovementFromDate,'')<>@Date
   and isnull(MovementFromDate,'')<>''

   Update #tt_Temp_SMA_Main_Table_2_final
   set MovementToStatus=UCICSMA_AssetStatus
   where MovementToStatus is null
   and MovementFromDate is not null


   ;With CTE_UCIC_2 AS
   (
   select        a.UCIC,

   			  max(case when isnull([in_default (Y/N)],'N')='Y' THEN 1 ELSE 0 END) as [in_default (Y/N)],
   			max(case when isnull([out_of_default (Y/N)],'N')='Y' THEN 1 ELSE 0 END) as [out_of_default (Y/N)]

   from            #tt_Temp_SMA_Main_Table_2_final a
   group by a.UCIC
   )
   Update      a
   set         
   			   a.[in_default (Y/N)]=(case when b.[in_default (Y/N)]=1 then 'Y' else 'N' end),
   			  a.[out_of_default (Y/N)]=(case when b.[out_of_default (Y/N)]=1 then 'Y' else 'N' end)

   from         #tt_Temp_SMA_Main_Table_2_final a
   inner join   CTE_UCIC_2 b
   on           a.UCIC=b.ucic
   */
   ---------------------------------------------For other than Visionplus Output----------------------------------------
   OPEN  v_cursor FOR
      SELECT Report_Date ,
             UCIC ,
             CIF_ID ,
             Borrower_Name ,
             Branch_Code ,
             Branch_Name ,
             BranchStateName ,
             Region ,
             Account_No_ ,
             PAN ,
             Source_System ,
             Facility ,
             Scheme_Type ,
             Scheme_Code ,
             Scheme_Description ,
             Seg_Code ,
             Segment_Description ,
             Business_Segment ,
             Wholesale_Retail ,
             Balance_Outstanding ,
             Principal_Outstanding ,
             Drawing_Power ,
             Sanction_Limit ,
             OverDrawn_Amount ,
             DPD_Overdrawn ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Limit_DP_Overdrawn_Date,200,p_style=>105),10,p_style=>23) Limit_DP_Overdrawn_Date  ,
             Overdue_Amount ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,200,p_style=>105),10,p_style=>23) OverDueSinceDt  ,
             DPD_Overdue ,
             Bill_PC_Overdue_Amount ,
             Overdue_Bill_PC_ID ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Bill_PC_Overdue_Date,200,p_style=>105),10,p_style=>23) Bill_PC_Overdue_Date  ,
             DPD_Bill_PC ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(INTEREST_DIVIDENDDUEDATE,200,p_style=>105),10,p_style=>23) INTEREST_DIVIDENDDUEDATE  ,
             INTEREST_DIVIDENDDUEAMOUNT ,
             DPD ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(PartialRedumptionDueDate,200,p_style=>105),10,p_style=>23) PartialRedumptionDueDate  ,
             SMA_DPD ,
             AccountFlgSMA ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(AccountSMA_Dt,200,p_style=>105),10,p_style=>23) AccountSMA_Dt  ,
             AccountSMA_AssetClass ,
             SMA_Reason ,
             DPD_UCIF_ID ,
             UCICFlgSMA ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(UCICSMA_Dt,200,p_style=>105),10,p_style=>23) UCICSMA_Dt  ,
             UCICSMA_AssetStatus ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(First_Time_SMA_Classification_Date,200,p_style=>105),10,p_style=>23) First_Time_SMA_Classification_Date  ,
             in_default_Y_N_ ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(in_default_date,200,p_style=>105),10,p_style=>23) in_default_date  ,
             out_of_default_Y_N_ ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(out_of_default_date,200,p_style=>105),10,p_style=>23) out_of_default_date  ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(MovementFromDate,200,p_style=>105),10,p_style=>23) MovementFromDate  ,
             MovementFromStatus ,
             MovementToStatus ,
             Asset_Norm ,
             NPA_Norms ,
             FDOD_Flag ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Limit_Expiry_Date,200,p_style=>105),10,p_style=>23) Limit_Expiry_Date  ,
             DPD_Limit_Expiry ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Stock_Statement_valuation_date,200,p_style=>105),10,p_style=>23) Stock_Statement_valuation_date  ,
             DPD_Stock_Statement_expiry ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Debit_Balance_Since_Date,200,p_style=>105),10,p_style=>23) Debit_Balance_Since_Date  ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Last_Credit_Date,200,p_style=>105),10,p_style=>23) Last_Credit_Date  ,
             DPD_No_Credit ,
             Current_quarter_credit ,
             Current_quarter_interest ,
             Interest_Not_Serviced ,
             DPD_out_of_order ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(CC_OD_Interest_Service_Date,200,p_style=>105),10,p_style=>23) CC_OD_Interest_Service_Date  ,
             Principal_Overdue ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Principal_Overdue_Date,200,p_style=>105),10,p_style=>23) Principal_Overdue_Date  ,
             DPD_Principal_Overdue ,
             Interest_Overdue ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Interest_Overdue_Date,200,p_style=>105),10,p_style=>23) Interest_Overdue_Date  ,
             DPD_Interest_Overdue ,
             Other_Overdue ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Other_OverDue_Date,200,p_style=>105),10,p_style=>23) Other_OverDue_Date  ,
             DPD_Other_Overdue 
        FROM tt_Temp_SMA_Main_Table_fina_2 
       WHERE  Source_System <> 'VisionPlus' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --and  ( AccountSMA_AssetClass in ('Agri-Loan','FDOD')
   --or DPD_UCIF_ID >0)
   --------------------------------------------------------------------
   ---------------------------------------------For Visionplus Output------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT Report_Date ,
             UCIC ,
             CIF_ID ,
             Borrower_Name ,
             Branch_Code ,
             Branch_Name ,
             BranchStateName ,
             Region ,
             Account_No_ ,
             PAN ,
             Source_System ,
             Facility ,
             Scheme_Type ,
             Scheme_Code ,
             Scheme_Description ,
             Seg_Code ,
             Segment_Description ,
             Business_Segment ,
             Wholesale_Retail ,
             Balance_Outstanding ,
             Principal_Outstanding ,
             Drawing_Power ,
             Sanction_Limit ,
             OverDrawn_Amount ,
             DPD_Overdrawn ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Limit_DP_Overdrawn_Date,200,p_style=>105),10,p_style=>23) Limit_DP_Overdrawn_Date  ,
             Overdue_Amount ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,200,p_style=>105),10,p_style=>23) OverDueSinceDt  ,
             DPD_Overdue ,
             Bill_PC_Overdue_Amount ,
             Overdue_Bill_PC_ID ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Bill_PC_Overdue_Date,200,p_style=>105),10,p_style=>23) Bill_PC_Overdue_Date  ,
             DPD_Bill_PC ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(INTEREST_DIVIDENDDUEDATE,200,p_style=>105),10,p_style=>23) INTEREST_DIVIDENDDUEDATE  ,
             INTEREST_DIVIDENDDUEAMOUNT ,
             DPD ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(PartialRedumptionDueDate,200,p_style=>105),10,p_style=>23) PartialRedumptionDueDate  ,
             SMA_DPD ,
             AccountFlgSMA ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(AccountSMA_Dt,200,p_style=>105),10,p_style=>23) AccountSMA_Dt  ,
             AccountSMA_AssetClass ,
             SMA_Reason ,
             DPD_UCIF_ID ,
             UCICFlgSMA ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(UCICSMA_Dt,200,p_style=>105),10,p_style=>23) UCICSMA_Dt  ,
             UCICSMA_AssetStatus ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(First_Time_SMA_Classification_Date,200,p_style=>105),10,p_style=>23) First_Time_SMA_Classification_Date  ,
             in_default_Y_N_ ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(in_default_date,200,p_style=>105),10,p_style=>23) in_default_date  ,
             out_of_default_Y_N_ ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(out_of_default_date,200,p_style=>105),10,p_style=>23) out_of_default_date  ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(MovementFromDate,200,p_style=>105),10,p_style=>23) MovementFromDate  ,
             MovementFromStatus ,
             MovementToStatus ,
             Asset_Norm ,
             NPA_Norms ,
             FDOD_Flag ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Limit_Expiry_Date,200,p_style=>105),10,p_style=>23) Limit_Expiry_Date  ,
             DPD_Limit_Expiry ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Stock_Statement_valuation_date,200,p_style=>105),10,p_style=>23) Stock_Statement_valuation_date  ,
             DPD_Stock_Statement_expiry ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Debit_Balance_Since_Date,200,p_style=>105),10,p_style=>23) Debit_Balance_Since_Date  ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Last_Credit_Date,200,p_style=>105),10,p_style=>23) Last_Credit_Date  ,
             DPD_No_Credit ,
             Current_quarter_credit ,
             Current_quarter_interest ,
             Interest_Not_Serviced ,
             DPD_out_of_order ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(CC_OD_Interest_Service_Date,200,p_style=>105),10,p_style=>23) CC_OD_Interest_Service_Date  ,
             Principal_Overdue ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Principal_Overdue_Date,200,p_style=>105),10,p_style=>23) Principal_Overdue_Date  ,
             DPD_Principal_Overdue ,
             Interest_Overdue ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Interest_Overdue_Date,200,p_style=>105),10,p_style=>23) Interest_Overdue_Date  ,
             DPD_Interest_Overdue ,
             Other_Overdue ,
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Other_OverDue_Date,200,p_style=>105),10,p_style=>23) Other_OverDue_Date  ,
             DPD_Other_Overdue 
        FROM tt_Temp_SMA_Main_Table_fina_2 
       WHERE  Source_System = 'VisionPlus' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--and  ( AccountSMA_AssetClass in ('Agri-Loan','FDOD')
   --or DPD_UCIF_ID >0 )
   ---------------------------------------SMA Report END-------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT" TO "ADF_CDR_RBL_STGDB";
