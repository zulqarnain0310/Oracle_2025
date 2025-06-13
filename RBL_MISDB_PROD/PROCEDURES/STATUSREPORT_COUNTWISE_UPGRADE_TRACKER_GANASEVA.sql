--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey - 1 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ - 1 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );

BEGIN

   --Declare @TimeKey AS INT =26298
   IF utils.object_id('tempdb..tt_temp1_43') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_43 ';
   END IF;
   DELETE FROM tt_temp1_43;
   --	 --------------Ganaseva

   --	INSERT INTO tt_temp1_43

   --select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt from ReverseFeedData A

   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

   -- where B.SourceName='Ganaseva'

   -- And A.AssetSubClass='STD'

   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   -- group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_Ganaseva_60') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Ganaseva_60 ';
   END IF;
   DELETE FROM tt_Ganaseva_60;
   UTILS.IDENTITY_RESET('tt_Ganaseva_60');

   INSERT INTO tt_Ganaseva_60 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           ds.SourceAlt_Key ,
           ds.SourceName 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
             JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
             AND B.EffectiveFromTimeKey <= v_Timekey
             AND B.EffectiveToTimeKey >= v_Timekey
             JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
             AND DS.EffectiveFromTimeKey <= v_Timekey
             AND DS.EffectiveToTimeKey >= v_Timekey
             JOIN DimAssetClassMapping DA   ON DA.SrcSysClassCode = B.SourceAssetClass
             AND A.SourceAlt_Key = DA.SourceAlt_Key
             AND DA.EffectiveFromTimeKey <= v_Timekey
             AND DA.EffectiveToTimeKey >= v_Timekey
   	 WHERE  DS.SourceName = 'Ganaseva'
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedDataInsertSync R
                                WHERE  A.CustomerAcID = R.CustomerAcID
                                         AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedData B
                                WHERE  B.AccountID = A.CustomerAcID
                                         AND DateofData = v_Date
                                         AND B.AssetSubClass <> 'STD' )
              AND 
            -- NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and      

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND      
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey )
              AND A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey );
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_Ganaseva_60 a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   ----------------      
   INSERT INTO tt_temp1_43
     ( SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  CNT  
       FROM ( SELECT 'GanasevaUpgrade' TableName  ,
                     AccountID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(UpgradeDate,10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'Ganaseva'
                        AND A.AssetSubClass = 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              --------------Added on 04/04/2022      
              SELECT 'GanasevaUpgrade' TableName  ,
                     CustomerAcID || '|' || '0' || '|' || UTILS.CONVERT_TO_VARCHAR2(NVL(UpgDate, v_date),10,p_style=>103) || '|' || '19718' || '|' || '19718' DataUtility  ,
                     SourceAlt_Key ,
                     SourceName 
              FROM tt_Ganaseva_60 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key = 1 ) A
         GROUP BY SourceAlt_Key,SourceSystemName );
   --select * from tt_temp1_43
   --select * 
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF_Ganaseva a
          JOIN tt_temp1_43 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Upgrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END
                                 = src.CNT;
   UPDATE StatusReport_RF_Ganaseva
      SET Upgrade = 0
    WHERE  Upgrade IS NULL;--update StatusReport
   --set    Upgrade_Status= case when isnull(Upgrade_ACL,0)=isnull(Upgrade_RF,0) then 'True' else 'False' END

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_UPGRADE_TRACKER_GANASEVA" TO "ADF_CDR_RBL_STGDB";
