--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" 
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

   IF utils.object_id('tempdb..tt_temp2_39') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_39 ';
   END IF;
   DELETE FROM tt_temp2_39;

   ----------------VisionPlus

   -- 	INSERT INTO tt_temp2_39

   --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt

   -- from ReverseFeedData A

   --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

   --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

   -- where B.SourceName='VisionPlus'

   -- And A.AssetSubClass<>'STD'

   -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

   --  group by a.SourceAlt_Key,a.SourceSystemName
   IF utils.object_id('TempDB..tt_VisionPlus_22') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_22 ';
   END IF;
   DELETE FROM tt_VisionPlus_22;
   UTILS.IDENTITY_RESET('tt_VisionPlus_22');

   INSERT INTO tt_VisionPlus_22 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
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
   	 WHERE  DS.SourceName = 'VisionPlus'
              AND NOT EXISTS ( SELECT 1 
                               FROM ReverseFeedDataInsertSync R
                                WHERE  A.CustomerAcID = R.CustomerAcID
                                         AND DA.AssetClassAlt_Key = R.FinalAssetClassAlt_Key
                                         AND NVL(B.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ')
                                         AND R.ProcessDate = v_PreviousDate )
              AND NOT EXISTS ( SELECT 1 
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
     FROM tt_VisionPlus_22 a
            JOIN ReverseFeedData b   ON A.CustomerAcID = b.AccountID,
          A
    WHERE  DateofData = v_Date );
   INSERT INTO tt_temp2_39
     ( 
       --    select a.SourceAlt_Key,a.SourceSystemName,count(*) cnt    
       SELECT SourceAlt_Key ,
              SourceSystemName ,
              COUNT(*)  
       FROM ( SELECT 'VisionPlusDataList' TableName  ,
                     AccountID ,
                     UTILS.CONVERT_TO_VARCHAR2(NPADate,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     A.SourceAlt_Key ,
                     A.SourceSystemName 
              FROM ReverseFeedData A
                     JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                     AND B.EffectiveFromTimeKey <= v_TimeKey
                     AND B.EffectiveToTimeKey >= v_TimeKey
               WHERE  B.SourceName = 'VisionPlus'
                        AND A.AssetSubClass <> 'STD'
                        AND A.EffectiveFromTimeKey <= v_TimeKey
                        AND A.EffectiveToTimeKey >= v_TimeKey
              UNION 

              -- UNION     

              -- Select 'VisionPlusDataList' as TableName, AccountID ,'       ' as NPADate,'Upgrade' [Type],a.SourceAlt_Key,a.SourceSystemName    

              -- from ReverseFeedData A    

              --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    

              --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    

              -- where B.SourceName='VisionPlus'    

              -- And A.AssetSubClass='STD'    

              -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    

              -----------Added on 04/04/2022      
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerAcID ,
                     UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM tt_VisionPlus_22 A
               WHERE  A.BankAssetClass = 1
                        AND A.FinalAssetClassAlt_Key > 1
              UNION 

              --UNION       

              --Select 'VisionPlusDataList' as TableName, CustomerAcID ,'       ' as NPADate,'Upgrade' [Type],a.SourceAlt_Key,a.SourceName    

              --from tt_VisionPlus_22 A      

              --where A.BankAssetClass>1 And A.FinalAssetClassAlt_Key=1      
              SELECT 'VisionPlusDataList' TableName  ,
                     CustomerAcID ,
                     UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                     'Degrade' Type  ,
                     a.SourceAlt_Key ,
                     a.SourceName 
              FROM tt_VisionPlus_22 A
               WHERE  A.BankAssetClass > 1
                        AND A.FinalAssetClassAlt_Key > 1
                        AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) C
         GROUP BY SourceAlt_Key,SourceSystemName );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport_RF_VP a
          JOIN tt_temp2_39 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Degrade
                                -- a.Upgrade_Status= case when isnull(a.Upgrade_ACL,0)=isnull(a.Upgrade_RF,0) then 'True' else 'False' END
                                 = src.CNT;
   UPDATE StatusReport_RF_VP
      SET Degrade = 0
    WHERE  Degrade IS NULL;--update StatusReport_RF
   --set    Degrade_Status= case when isnull(Degrade_ACL,0)=isnull(Degrade_RF,0) then 'True' else 'False' END

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_DEGRADE_TRACKER_VISIONPLUS" TO "ADF_CDR_RBL_STGDB";
