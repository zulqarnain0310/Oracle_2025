--------------------------------------------------------
--  DDL for Procedure GETVISIONPLUSDATA_10062022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" 
AS
   --Declare @TimeKey AS INT =26090--(Select TimeKey from Automate_Advances where EXT_FLG='Y')
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_PreviousDate VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey - 2 );
   v_cursor SYS_REFCURSOR;

BEGIN

   --------------VisionPlus
   ----------Added on 04/04/2022  
   IF utils.object_id('TempDB..tt_VisionPlus_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_VisionPlus_4 ';
   END IF;
   DELETE FROM tt_VisionPlus_4;
   UTILS.IDENTITY_RESET('tt_VisionPlus_4');

   INSERT INTO tt_VisionPlus_4 ( 
   	SELECT A.CustomerAcID ,
           A.FinalAssetClassAlt_Key ,
           A.FinalNpaDt ,
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
                                         AND Y.EffectiveToTimeKey >= v_TimeKey ) );
   ----------------------------  
   OPEN  v_cursor FOR
      SELECT * 
        FROM ( SELECT 'VisionPlusDataList' TableName  ,
                      AccountID ,
                      UTILS.CONVERT_TO_VARCHAR2(NPADate,30,p_style=>103) NPADate  ,
                      'Degrade' Type  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                      AND B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey
                WHERE  B.SourceName = 'VisionPlus'
                         AND A.AssetSubClass <> 'STD'
                         AND A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
               UNION 
               SELECT 'VisionPlusDataList' TableName  ,
                      AccountID ,
                      '       ' NPADate  ,
                      'Upgrade' Type  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                      AND B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey
                WHERE  B.SourceName = 'VisionPlus'
                         AND A.AssetSubClass = 'STD'
                         AND A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
               UNION 

               -----------Added on 04/04/2022  
               SELECT 'VisionPlusDataList' TableName  ,
                      CustomerAcID ,
                      UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                      'Degrade' Type  
               FROM tt_VisionPlus_4 A
                WHERE  A.BankAssetClass = 1
                         AND A.FinalAssetClassAlt_Key > 1
               UNION 
               SELECT 'VisionPlusDataList' TableName  ,
                      CustomerAcID ,
                      '       ' NPADate  ,
                      'Upgrade' Type  
               FROM tt_VisionPlus_4 A
                WHERE  A.BankAssetClass > 1
                         AND A.FinalAssetClassAlt_Key = 1
               UNION 
               SELECT 'VisionPlusDataList' TableName  ,
                      CustomerAcID ,
                      UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,30,p_style=>103) NPADate  ,
                      'Degrade' Type  
               FROM tt_VisionPlus_4 A
                WHERE  A.BankAssetClass > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND NVL(A.FinalNpaDt, ' ') <> NVL(A.SourceNpaDate, ' ') ) 
             --------------------------------------------------------------  

             -- UNION 

             -- Select 'VisionPlusDataList' as TableName, CustomerID ,AssetSubClass as AssetCode,'AssetClassification' [Type] from (

             -- Select  CustomerID ,Case When Len(A.AssetSubClass)=3 then A.AssetSubClass else A.AssetSubClass+' ' End AssetSubClass from ReverseFeedData A

             --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

             --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

             -- where B.SourceName='VisionPlus'

             -- --And A.AssetSubClass='STD'

             -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

             -- Group By CustomerID ,A.AssetSubClass

             -- UNION

             -- Select  CustomerID ,Convert(Varchar,DateofData,103) as AssetCodeDate from ReverseFeedData A

             --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

             --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

             -- where B.SourceName='VisionPlus'

             -- --And A.AssetSubClass='STD'

             -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

             -- Group By CustomerID ,A.DateofData

             -- UNION

             -- Select  CustomerID ,Case when NPADate is not null then Convert(Varchar,NPADate,103) else '       ' ENd as ENPADate from ReverseFeedData A

             --Inner JOIN DIMSOURCEDB B ON A.SourceAlt_Key=B.SourceAlt_key

             --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey

             -- where B.SourceName='VisionPlus'

             -- --And A.AssetSubClass='STD'

             -- AND A.EffectiveFromTimekey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey

             -- Group By CustomerID ,A.NPADate

             -- )A
             T
        ORDER BY 4 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT 'VisionPlusDataList' TableName  ,
             CustomerID ,
             AssetSubClass AssetCode  ,
             AssetCodeDate ,
             ENPADate ,
             'AssetClassification' Type  
        FROM ( SELECT a.Corporate_Customer_ID CustomerID  ,
                      CASE 
                           WHEN LENGTH(A.AssetSubClass) = 3 THEN A.AssetSubClass
                      ELSE A.AssetSubClass || ' '
                         END AssetSubClass  ,
                      UTILS.CONVERT_TO_VARCHAR2(DateofData,30,p_style=>103) AssetCodeDate  ,
                      CASE 
                           WHEN NPADate IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(NPADate,30,p_style=>103)
                      ELSE '       '
                         END ENPADate  
               FROM ReverseFeedData A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                      AND B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey
                WHERE  B.SourceName = 'VisionPlus'

                         --And A.AssetSubClass='STD'
                         AND A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey
                 GROUP BY Corporate_Customer_ID,A.AssetSubClass,DateofData,NPADate
               UNION 
               SELECT F.CorporateCustomerID CustomerID  ,
                      CASE 
                           WHEN LENGTH(E.SrcSysClassCode) = 3 THEN E.SrcSysClassCode
                      ELSE E.SrcSysClassCode || ' '
                         END AssetSubClass  ,
                      v_Date AssetCodeDate  ,
                      CASE 
                           WHEN A.FinalNpaDt IS NOT NULL THEN UTILS.CONVERT_TO_VARCHAR2(A.FinalNpaDt,10,p_style=>103)
                      ELSE '       '
                         END ENPADate  
               FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                      AND B.EffectiveFromTimeKey <= v_TimeKey
                      AND B.EffectiveToTimeKey >= v_TimeKey
                      JOIN DimAssetClass E   ON A.FinalAssetClassAlt_Key = E.AssetClassAlt_Key
                      AND E.EffectiveFromTimeKey <= v_TimeKey
                      AND E.EffectiveToTimeKey >= v_TimeKey
                      LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON A.AccountEntityID = F.AccountEntityID
                      AND F.EffectiveFromTimekey <= v_TimeKey
                      AND F.EffectiveToTimeKey >= v_TimeKey
                WHERE  B.SourceName = 'VisionPlus'
                         AND A.InitialAssetClassAlt_Key > 1
                         AND A.FinalAssetClassAlt_Key > 1
                         AND ( A.InitialAssetClassAlt_Key <> A.FinalAssetClassAlt_Key
                         OR A.InitialNpaDt <> A.FinalNpaDt ------Added INitial and Final NPA Date
                        )
                         AND A.EffectiveFromTimeKey <= v_TimeKey
                         AND A.EffectiveToTimeKey >= v_TimeKey ) A
        ORDER BY 2 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETVISIONPLUSDATA_10062022" TO "ADF_CDR_RBL_STGDB";
