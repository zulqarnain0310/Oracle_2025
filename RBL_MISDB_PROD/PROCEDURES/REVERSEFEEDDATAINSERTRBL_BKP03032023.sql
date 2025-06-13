--------------------------------------------------------
--  DDL for Procedure REVERSEFEEDDATAINSERTRBL_BKP03032023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_temp NUMBER(1, 0) := 0;

BEGIN

   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
                WHERE  EffectiveFromTimeKey = v_TimeKey ) > 0
     AND ( SELECT COUNT(1)  
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
            WHERE  EffectiveFromTimeKey = v_TimeKey ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DELETE ReverseFeedData

       WHERE  EffectiveFromTimekey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      INSERT INTO ReverseFeedData
        ( DateofData, BranchCode, CustomerID, AccountID, AssetClass, AssetSubClass, NPADate, SourceAlt_Key, SourceSystemName, EffectiveFromTimeKey, EffectiveToTimeKey, UpgradeDate, UCIF_ID, ProductName, DPD, CustomerName, Corporate_Customer_ID )
        ( SELECT v_Date DateofData  ,
                 A.BranchCode ,
                 A.RefCustomerID ,
                 A.CustomerAcID ,
                 A.FinalAssetClassAlt_Key ,
                 B.SrcSysClassCode ,
                 A.FinalNpaDt ,
                 A.SourceAlt_Key ,
                 C.SourceName ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.UpgDate ,
                 A.UCIF_ID ,
                 E.ProductName ,
                 A.DPD_Max ,
                 D.CustomerName ,
                 CASE 
                      WHEN a.SourceAlt_Key = 6 THEN F.CorporateCustomerID
                 ELSE NULL
                    END Corporate_Customer_ID  
          FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                 JOIN DimAssetClass B   ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey
                 JOIN DIMSOURCEDB C   ON A.SourceAlt_Key = C.SourceAlt_Key
                 AND C.EffectiveFromTimeKey <= v_TimeKey
                 AND C.EffectiveToTimeKey >= v_TimeKey
                 JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL D   ON A.CustomerEntityID = D.CustomerEntityID
                 JOIN DimProduct E   ON E.ProductAlt_Key = A.ProductAlt_Key
                 AND E.EffectiveFromTimeKey <= v_TimeKey
                 AND E.EffectiveToTimeKey >= v_TimeKey
                 LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON A.AccountEntityID = F.AccountEntityID
                 AND F.EffectiveFromTimekey <= v_TimeKey
                 AND F.EffectiveToTimeKey >= v_TimeKey
           WHERE  A.InitialAssetClassAlt_Key = 1
                    AND A.FinalAssetClassAlt_Key > 1
          UNION 
          SELECT v_Date DateofData  ,
                 A.BranchCode ,
                 A.RefCustomerID ,
                 A.CustomerAcID ,
                 A.FinalAssetClassAlt_Key ,
                 B.SrcSysClassCode ,
                 A.FinalNpaDt ,
                 A.SourceAlt_Key ,
                 C.SourceName ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.UpgDate ,
                 A.UCIF_ID ,
                 E.ProductName ,
                 A.DPD_Max ,
                 D.CustomerName ,
                 CASE 
                      WHEN a.SourceAlt_Key = 6 THEN F.CorporateCustomerID
                 ELSE NULL
                    END Corporate_Customer_ID  
          FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                 JOIN DimAssetClass B   ON A.FinalAssetClassAlt_Key = B.AssetClassAlt_Key
                 AND B.EffectiveFromTimeKey <= v_TimeKey
                 AND B.EffectiveToTimeKey >= v_TimeKey
                 JOIN DIMSOURCEDB C   ON A.SourceAlt_Key = C.SourceAlt_Key
                 AND C.EffectiveFromTimeKey <= v_TimeKey
                 AND C.EffectiveToTimeKey >= v_TimeKey
                 JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL D   ON A.CustomerEntityID = D.CustomerEntityID
                 JOIN DimProduct E   ON E.ProductAlt_Key = A.ProductAlt_Key
                 AND E.EffectiveFromTimeKey <= v_TimeKey
                 AND E.EffectiveToTimeKey >= v_TimeKey
                 LEFT JOIN CurDat_RBL_MISDB_PROD.AdvFacCreditCardDetail F   ON A.AccountEntityID = F.AccountEntityID
                 AND F.EffectiveFromTimekey <= v_TimeKey
                 AND F.EffectiveToTimeKey >= v_TimeKey
           WHERE  A.InitialAssetClassAlt_Key > 1
                    AND A.FinalAssetClassAlt_Key = 1 );
      -------------------ADDED BY SUDESH 26122021
      --update Reversefeeddata set NPADate = DateofData 
      --where assetclass = 2 
      --and NPADate is NULL and cast(dateofData as date) = @Date
      --=============Added By Mandeep FOR SCF to show count in alert mail ============================================
      INSERT INTO ReverseFeedData
        ( DateofData, BranchCode, CustomerID, AccountID, AssetClass, AssetSubClass, NPADate, NPAReason, LoanSeries, LoanRefNo, FundID, NPAStatus, LoanRating, OrgNPAStatus, OrgLoanRating, SourceAlt_Key, SourceSystemName, EffectiveFromTimeKey, EffectiveToTimeKey, UpgradeDate, UCIF_ID, ProductName, DPD, CustomerName, Corporate_Customer_ID )
        ( SELECT A.DateofData ,
                 A.BranchCode ,
                 A.CustomerID ,
                 A.AccountID ,
                 A.AssetClass ,
                 A.AssetSubClass ,
                 A.NPADate ,
                 A.NPAReason ,
                 A.LoanSeries ,
                 A.LoanRefNo ,
                 A.FundID ,
                 A.NPAStatus ,
                 A.LoanRating ,
                 A.OrgNPAStatus ,
                 A.OrgLoanRating ,
                 9 ,
                 'SCF' ,
                 A.EffectiveFromTimeKey ,
                 A.EffectiveToTimeKey ,
                 A.UpgradeDate ,
                 A.UCIF_ID ,
                 A.ProductName ,
                 A.DPD ,
                 A.CustomerName ,
                 A.Corporate_Customer_ID 
          FROM ReverseFeedData A
                 JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.AccountID = B.CustomerAcID
                 AND B.ProductAlt_Key IN ( SELECT DISTINCT ProductAlt_Key 
                                           FROM DimProduct 
                                            WHERE  ProductCode IN ( 'DLFIN','VFVEN' )

                                                     AND EffectiveToTimeKey = 49999 )

           WHERE  A.DateofData = v_Date );
      UPDATE ReverseFeedData
         SET UpgradeDate = DateofData
       WHERE  assetclass = 1
        AND UpgradeDate IS NULL
        AND UTILS.CONVERT_TO_VARCHAR2(dateofData,200) = v_Date;--UNION ALL
      --Select  @Date as DateofData,A.BranchCode,A.RefCustomerID,A.CustomerACid,A.FinalAssetClassAlt_Key,B.SrcSysClassCode, A.FinalNPADt,A.SourceAlt_Key,C.SourceName,A.EffectiveFromTimeKey,A.EffectiveToTimeKey
      --,A.UpgDate,A.UCIF_ID,E.ProductName,A.DPD_Max,D.CustomerName
      -- from Pro.ACCOUNTCAL A
      --Inner Join DimAssetClass B On A.FinalAssetClassAlt_Key=B.AssetClassAlt_key
      --And B.EffectiveFromTimekey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      --Inner JOIN DIMSOURCEDB C ON A.SourceAlt_Key=C.SourceAlt_key
      --And C.EffectiveFromTimekey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey
      --Inner JOIN Pro.CustomerCal D ON A.CustomerEntityID=D.CustomerEntityID
      --Inner Join DimProduct E ON E.ProductAlt_Key=A.ProductAlt_key
      --And E.EffectiveFromTimekey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey 
      --where A.InitialAssetClassAlt_Key>1 AND A.FinalAssetClassAlt_Key<>FinalAssetClassAlt_Key

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."REVERSEFEEDDATAINSERTRBL_BKP03032023" TO "ADF_CDR_RBL_STGDB";
