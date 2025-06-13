--------------------------------------------------------
--  DDL for Procedure INSERTSYNCREVERSEDATAQUERY_CUSTOMER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" 
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

   IF utils.object_id('TempDB..tt_Total_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Total_8 ';
   END IF;
   DELETE FROM tt_Total_8;
   UTILS.IDENTITY_RESET('tt_Total_8');

   INSERT INTO tt_Total_8 ( 
   	SELECT A.RefCustomerID CustomerID  ,
           DS.SourceName ,
           A.SysAssetClassAlt_Key FinalAssetClassAlt_Key  ,
           A.SysNPA_Dt FinalNpaDt  ,
           (CASE 
                 WHEN B.SourceAssetClass IS NULL
                   AND B.SourceNpaDate IS NULL
                   AND DS.SourceAlt_Key = 6 THEN 'STD'
           ELSE B.SourceAssetClass
              END) SourceAssetClass  ,
           (CASE 
                 WHEN B.SourceAssetClass = 'STD'
                   AND B.SourceNpaDate IS NOT NULL THEN NULL
           ELSE B.SourceNpaDate
              END) SourceNpaDate  ,
           DA.AssetClassAlt_Key BankAssetClass  ,
           Z.UpgDate UpgradeDate  
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CustomerEntityID
             AND B.EffectiveFromTimeKey <= v_Timekey
             AND B.EffectiveToTimeKey >= v_Timekey
             JOIN DIMSOURCEDB DS   ON DS.SourceAlt_Key = A.SourceAlt_Key
             AND DS.EffectiveFromTimeKey <= v_Timekey
             AND DS.EffectiveToTimeKey >= v_Timekey
             JOIN DimAssetClassMapping_Customer DA   ON DA.AssetClassShortName = B.SourceAssetClass
             AND A.SourceAlt_Key = DA.SourceAlt_Key
             AND DA.EffectiveFromTimeKey <= v_Timekey
             AND DA.EffectiveToTimeKey >= v_Timekey
             JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL Z   ON A.CustomerEntityID = Z.CustomerEntityID
             AND Z.EffectiveFromTimeKey <= v_Timekey
             AND Z.EffectiveToTimeKey >= v_Timekey
   	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
              AND A.EffectiveToTimeKey >= v_TimeKey

              --NOT EXISTS(Select 1 from ExceptionFinalStatusType as X where X.ACID=A.CustomerAcID and X.StatusType='TWO' and    

              --X.EffectiveFromTimeKey<=@TimeKey and X.EffectiveToTimeKey>=@TimeKey) AND    
              AND NOT EXISTS ( SELECT 1 
                               FROM DimProduct Y
                                WHERE  Y.ProductAlt_Key = Z.ProductAlt_Key
                                         AND Y.ProductCode = 'RBSNP'
                                         AND Y.EffectiveFromTimeKey <= v_TimeKey
                                         AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ---------------------    
   DELETE ReverseFeedDataInsertSync_Customer

    WHERE  ProcessDate = v_Date;
   ---------------------------    
   INSERT INTO ReverseFeedDataInsertSync_Customer
     ( SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              B.SourceName ,
              CustomerID ,
              MAX(AssetClass)  FinalAssetClassAlt_Key  ,
              NPADate FinalNpaDt  ,
              A.UpgradeDate 
       FROM ReverseFeedData A
              JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
        WHERE
       --B.SourceName='Finacle'    
        --And     
        --A.AssetSubClass<>'STD'    
         A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey
         GROUP BY CustomerID,NPADate,B.SourceName,a.UpgradeDate
       UNION 

       -- UNION    

       --Select  @Date AS ProcessDate,Cast(Getdate() as Date) as RunDate,B.SourceName ,AccountID CustomerAcID,AssetClass as FinalAssetClassAlt_Key,NPADate FinalNpaDt,    

       --isnull(A.UpgradeDate,@Date) UpgradeDate from ReverseFeedData A    

       --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key    

       --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey    

       -- where     

       -- --B.SourceName='Finacle'    

       -- --And     

       -- A.AssetSubClass='STD'    

       -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey    

       ---------Added on 04/04/2022    
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              A.SourceName ,
              CustomerID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              ' ' UpgradeDate  
       FROM tt_Total_8 A
        WHERE  A.BankAssetClass = 1
                 AND A.FinalAssetClassAlt_Key > 1
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.CustomerID = R.CustomerID
                                            AND R.ProcessDate = v_PreviousDate
                                            AND A.BankAssetClass = R.FinalAssetClassAlt_Key
                                            AND NVL(A.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ') )
       UNION 

       ----------------    
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              A.SourceName ,
              CustomerID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              ' ' UpgradeDate  
       FROM tt_Total_8 A
        WHERE  A.BankAssetClass > 1
                 AND A.FinalAssetClassAlt_Key > 1

                 --And ISNULL(A.SourceNpaDate,'')<>ISNULL(A.FinalNpaDt,'')
                 AND ( NVL(A.SourceNpaDate, ' ') <> NVL(A.FinalNpaDt, ' ')
                 OR ( A.BankAssetClass <> A.FinalAssetClassAlt_Key ) )
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.CustomerID = R.CustomerID
                                            AND R.ProcessDate = v_PreviousDate
                                            AND A.BankAssetClass = R.FinalAssetClassAlt_Key
                                            AND NVL(A.SourceNpaDate, ' ') = NVL(R.FinalNpaDt, ' ') )
       UNION 
       SELECT v_Date ProcessDate  ,
              UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) RunDate  ,
              A.SourceName ,
              CustomerID ,
              FinalAssetClassAlt_Key ,
              FinalNpaDt ,
              UpgradeDate 
       FROM tt_Total_8 A
        WHERE  A.BankAssetClass > 1
                 AND A.FinalAssetClassAlt_Key = 1
                 AND NOT EXISTS ( SELECT 1 
                                  FROM ReverseFeedDataInsertSync_Customer R
                                   WHERE  A.CustomerID = R.CustomerID
                                            AND R.ProcessDate = v_PreviousDate
                                            AND A.BankAssetClass = R.FinalAssetClassAlt_Key ) );
   WITH CTE AS ( SELECT * ,
                        ROW_NUMBER() OVER ( PARTITION BY PROCESSDATE, SourceName, CUSTOMERID, FinalAssetClassAlt_Key ORDER BY PROCESSDATE, CUSTOMERID, finalnpadt DESC  ) rn  
     FROM ReverseFeedDataInsertSync_Customer 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(PROCESSDATE,200) = v_Date ) 
      DELETE cte

       WHERE  rn > 1
      ;
   RBL_MISDB_PROD.Customer_ReRf_Recor() ;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INSERTSYNCREVERSEDATAQUERY_CUSTOMER" TO "ADF_CDR_RBL_STGDB";
