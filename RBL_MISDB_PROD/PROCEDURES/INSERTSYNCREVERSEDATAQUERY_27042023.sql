--------------------------------------------------------
--  DDL for Procedure INSERTSYNCREVERSEDATAQUERY_27042023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );

BEGIN

   IF utils.object_id('TempDB..tt_Total_7') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Total_7 ';
   END IF;
   DELETE FROM tt_Total_7;
   UTILS.IDENTITY_RESET('tt_Total_7');

   INSERT INTO tt_Total_7 ( 
   	SELECT A.CustomerAcID ,
           DS.SourceName ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
           A.UpgDate ,
           B.SourceAssetClass ,
           B.SourceNpaDate ,
           DA.AssetClassAlt_Key BankAssetClass  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
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
   	 WHERE  
            --NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and    

            --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND    
            NOT EXISTS ( SELECT 1 
                         FROM DimProduct Y
                          WHERE  Y.ProductAlt_Key = A.ProductAlt_Key
                                   AND Y.ProductCode = 'RBSNP'
                                   AND Y.EffectiveFromTimeKey <= v_TimeKey
                                   AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ---------------------    
   DELETE ReverseFeedDataInsertSync

    WHERE  ProcessDate = v_Date;
   ---------------------------    
   INSERT INTO ReverseFeedDataInsertSync
     ( SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              B.SourceName ,
              AccountID CustomerAcID  ,
              AssetClass FinalAssetClassAlt_Key  ,
              NPADate FinalNpaDt  ,
              A.UpgradeDate UpgradeDate  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE
       --B.SourceName='Finacle'    
        --And     
         A.AssetSubClass <> 'STD'
           AND A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey
       UNION 
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              B.SourceName ,
              AccountID CustomerAcID  ,
              AssetClass FinalAssetClassAlt_Key  ,
              NPADate FinalNpaDt  ,
              NVL(A.UpgradeDate, v_Date) UpgradeDate  
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE
       --B.SourceName='Finacle'    
        --And     
         A.AssetSubClass = 'STD'
           AND A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey
       UNION 

       ---------Added on 04/04/2022    
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              A.SourceName ,
              CustomerAcID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              A.UpgDate UpgradeDate  
       FROM tt_Total_7 A
        WHERE  A.BankAssetClass = 1
                 AND A.FinalAssetClassAlt_Key > 1
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync R
                                   WHERE  A.CustomerAcID = R.CustomerAcID
                                            AND R.ProcessDate = v_PreviousDate
                                            AND A.BankAssetClass = R.FinalAssetClassAlt_Key
                                            AND NVL(A.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ') )
       UNION 

       ----------------    
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              A.SourceName ,
              CustomerAcID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              A.UpgDate UpgradeDate  
       FROM tt_Total_7 A
        WHERE  A.BankAssetClass > 1
                 AND A.FinalAssetClassAlt_Key > 1
                 AND NVL(A.SourceNpaDate, ' ') <> NVL(A.FinalNpaDt, ' ')
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync R
                                   WHERE  A.CustomerAcID = R.CustomerAcID
                                            AND R.ProcessDate = v_PreviousDate
                                            AND A.BankAssetClass = R.FinalAssetClassAlt_Key
                                            AND NVL(A.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ') )
       UNION 
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              A.SourceName ,
              CustomerAcID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              NVL(A.UpgDate, v_Date) UpgradeDate  
       FROM tt_Total_7 A
        WHERE  A.BankAssetClass > 1
                 AND A.FinalAssetClassAlt_Key = 1
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync R
                                   WHERE  A.CustomerAcID = R.CustomerAcID
                                            AND R.ProcessDate = v_PreviousDate
                                            AND A.BankAssetClass = R.FinalAssetClassAlt_Key ) );
   WITH CTE AS ( SELECT * ,
                        ROW_NUMBER() OVER ( PARTITION BY PROCESSDATE, CUSTOMERACID, FinalAssetClassAlt_Key ORDER BY PROCESSDATE, CUSTOMERACID, finalnpadt DESC  ) rn  
     FROM ReverseFeedDataInsertSync 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(PROCESSDATE,200) = v_Date ) 
      DELETE cte

       WHERE  rn > 1
      ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_27042023" TO "ADF_CDR_RBL_STGDB";
