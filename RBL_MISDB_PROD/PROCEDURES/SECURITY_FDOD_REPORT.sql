--------------------------------------------------------
--  DDL for Procedure SECURITY_FDOD_REPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" 
--USE [RBL_MISDB]

(
  iv_DATE IN VARCHAR2 DEFAULT NULL 
)
AS
   v_DATE VARCHAR2(200) := iv_DATE;
   -------------------------------------------------------------------------------------------------------------------
   v_CurrencyRate NUMBER(8,2) := ( SELECT USD 
     FROM RBL_MISDB.DimCurrencyFinacle 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(DateOfData,200) = v_Date );
   v_cursor SYS_REFCURSOR;

BEGIN

   --======================================================================================================
   -- CREATED BY : MANDEEP SINGH
   -- DATE       : 07-03-2024
   -- PURPOSE    : To track FDOD data monthly 
   -- EXEC       : [dbo].[Security_FDOD_Report] 'date'
   --======================================================================================================
   IF v_DATE IS NULL THEN

   BEGIN
      SELECT DATE_ 

        INTO v_DATE
        FROM RBL_MISDB.AUTOMATE_ADVANCES 
       WHERE  EXT_FLG = 'Y';

   END;
   END IF;
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ACCOUNT_SOURCESYSTEM01_S  --SQLDEV: NOT RECOGNIZED
   tt_ACCOUNT_SOURCESYSTEM01_S TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_SECURITY_SOURCESYSTEM01_  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_ACCOUNT_SOURCESYSTEM01_S;
   UTILS.IDENTITY_RESET('tt_ACCOUNT_SOURCESYSTEM01_S');

   INSERT INTO tt_ACCOUNT_SOURCESYSTEM01_S ( 
   	SELECT * 
   	  FROM DWH_DWH_STG.account_data_finacle_Backup 
   	 WHERE  date_of_data = v_DATE );
   DELETE FROM tt_SECURITY_SOURCESYSTEM01_;
   UTILS.IDENTITY_RESET('tt_SECURITY_SOURCESYSTEM01_');

   INSERT INTO tt_SECURITY_SOURCESYSTEM01_ ( 
   	SELECT * 
   	  FROM DWH_DWH_STG.collateral_type_master_finacle_backup 
   	 WHERE  date_of_data = v_DATE );
   -----------------------------------------------------------------------------------------------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_temp123  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_temp123;
   UTILS.IDENTITY_RESET('tt_temp123');

   INSERT INTO tt_temp123 SELECT DISTINCT Customer_ID ,
                                          apportioned_value Totalapportioned_value  ,
                                          CollateralID ,
                                          CustomerAcID ,
                                          Scheme_ProductCode ,
                                          SecurityCode ,
                                          SecurityValue ,
                                          ValuationExpiryDate ,
                                          Collateral_Type ,
                                          b.BalanceOutstandingINR ,
                                          POSBalance ,
                                          c.BalanceOutstandingINR TotalBalanceOutstandingINR  ,
                                          (b.BalanceOutstandingINR * 100) / c.BalanceOutstandingINR BalanceOutstandingINR_  ,
                                          (apportioned_value * ((b.BalanceOutstandingINR * 100) / c.BalanceOutstandingINR)) / 100 security  ,
                                          Valuationdate 
        FROM ( SELECT Customer_ID ,
                      security_id CollateralID  ,
                      Security_Code SecurityCode  ,
                      Security_Value SecurityValue  ,
                      Valuation_Expiry_Date ValuationExpiryDate  ,
                      Collateral_Type ,
                      SUM(apportioned_value)  apportioned_value  ,
                      Valuation_date Valuationdate  
               FROM tt_SECURITY_SOURCESYSTEM01_ 
                WHERE  Collateral_Type = 'Deposits'
                         AND Security_Code <> 'DSRA'
                         AND NVL(Account_ID, ' ') = ' '
                 GROUP BY Customer_ID,security_id,Security_Code,Security_Value,Valuation_Expiry_Date,Collateral_Type,Valuation_date ) a
               JOIN ( SELECT Customer_ID CustomerID  ,
                             Customer_Ac_ID CustomerAcID  ,
                             Scheme_Product_Code Scheme_ProductCode  ,
                             Balance_Outstanding_INR BalanceOutstandingINR  ,
                             POS_Balance POSBalance  
                      FROM tt_ACCOUNT_SOURCESYSTEM01_S 
                       WHERE  Scheme_Product_Code IN ( SELECT ProductCode 
                                                       FROM RBL_MISDB.DimProduct 
                                                        WHERE  ProductGroup = 'FDSEC' )

                                AND NVL(Balance_Outstanding_INR, 0) > 0 ) B   ON A.Customer_ID = B.CustomerID
               JOIN ( SELECT Customer_ID CustomerID  ,
                             SUM(Balance_Outstanding_INR)  BalanceOutstandingINR  
                      FROM tt_ACCOUNT_SOURCESYSTEM01_S 
                       WHERE  Scheme_Product_Code IN ( SELECT ProductCode 
                                                       FROM RBL_MISDB.DimProduct 
                                                        WHERE  ProductGroup = 'FDSEC' )

                                AND NVL(Balance_Outstanding_INR, 0) > 0
                        GROUP BY Customer_ID ) c   ON C.CustomerID = B.CustomerID
        ORDER BY 
                 --where c.CustomerID='20103947'

                 --group by Customer_ID
                 1;
   -------------------------------------------------------------------------------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_temp456  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_temp456;
   UTILS.IDENTITY_RESET('tt_temp456');

   INSERT INTO tt_temp456 SELECT CustomerID ,
                                 CustomerAcID ,
                                 Scheme_ProductCode ,
                                 BalanceOutstandingINR ,
                                 POSBalance ,
                                 CollateralID ,
                                 SecurityCode ,
                                 SecurityValue ,
                                 ValuationExpiryDate ,
                                 Collateral_Type ,
                                 apportioned_value ,
                                 Valuationdate ,
                                 Sec_Perf_Flg 
        FROM ( SELECT Customer_ID CustomerID  ,
                      Customer_Ac_ID CustomerAcID  ,
                      Scheme_Product_Code Scheme_ProductCode  ,
                      Balance_Outstanding_INR BalanceOutstandingINR  ,
                      POS_Balance POSBalance  
               FROM tt_ACCOUNT_SOURCESYSTEM01_S 
                WHERE  Scheme_Product_Code IN ( SELECT DISTINCT ProductCode 
                                                FROM RBL_MISDB.DimProduct 
                                                 WHERE  ProductGroup = 'FDSEC'
                                                          AND EffectiveToTimeKey = 49999 )

                         AND NVL(Balance_Outstanding_INR, 0) > 0 ) A
               LEFT JOIN ( SELECT ACCOUNT_ID ACCOUNTID  ,
                                  Customer_ID ,
                                  Security_ID CollateralID  ,
                                  Security_Code SecurityCode  ,
                                  Security_Value SecurityValue  ,
                                  Valuation_expiry_date ValuationExpiryDate  ,
                                  Collateral_Type ,
                                  apportioned_value ,
                                  Valuation_date Valuationdate  ,
                                  Sec_Perf_Flg 
                           FROM tt_SECURITY_SOURCESYSTEM01_ 
                            WHERE  Collateral_Type = 'Deposits'
                                     AND Security_Code <> 'DSRA'
                                     AND NVL(Account_ID, ' ') <> ' ' ) B   ON A.CustomerAcID = B.AccountID
        ORDER BY 6;
   ------------------------------------------------------------------------------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_tempwer12  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_tempwer12;
   UTILS.IDENTITY_RESET('tt_tempwer12');

   INSERT INTO tt_tempwer12 ( 
   	SELECT * 
   	  FROM ( SELECT DISTINCT A.CustomerID ,
                             A.CustomerAcID ,
                             A.Scheme_ProductCode ,
                             A.BalanceOutstandingINR ,
                             A.POSBalance ,
                             CASE 
                                  WHEN A.CollateralID IS NULL THEN B.CollateralID
                             ELSE A.CollateralID
                                END CollateralID  ,
                             CASE 
                                  WHEN A.SecurityCode IS NULL THEN B.SecurityCode
                             ELSE A.SecurityCode
                                END SecurityCode  ,
                             CASE 
                                  WHEN A.SecurityValue IS NULL THEN B.SecurityValue
                             ELSE A.SecurityValue
                                END SecurityValue  ,
                             CASE 
                                  WHEN A.ValuationExpiryDate IS NULL THEN B.ValuationExpiryDate
                             ELSE A.ValuationExpiryDate
                                END ValuationExpiryDate  ,
                             CASE 
                                  WHEN A.Collateral_Type IS NULL THEN B.Collateral_Type
                             ELSE A.Collateral_Type
                                END Collateral_Type  ,
                             CASE 
                                  WHEN A.apportioned_value IS NULL THEN B.security
                             ELSE A.apportioned_value
                                END apportioned_value  ,
                             CASE 
                                  WHEN A.Valuationdate IS NULL THEN B.Valuationdate
                             ELSE A.Valuationdate
                                END Valuationdate  ,
                             A.Sec_Perf_Flg 
             FROM tt_temp456 a
                    LEFT JOIN tt_temp123 b   ON a.CustomerID = b.Customer_ID
                    AND a.CustomerAcID = b.CustomerAcID
              WHERE  ( A.CollateralID IS NULL
                       OR B.CollateralID IS NULL )
             UNION 
             SELECT A.CustomerID ,
                    A.CustomerAcID ,
                    A.Scheme_ProductCode ,
                    A.BalanceOutstandingINR ,
                    A.POSBalance ,
                    A.CollateralID ,
                    A.SecurityCode ,
                    A.SecurityValue ,
                    A.ValuationExpiryDate ,
                    A.Collateral_Type ,
                    A.apportioned_value ,
                    A.Valuationdate ,
                    A.Sec_Perf_Flg 
             FROM tt_temp456 a
                    LEFT JOIN tt_temp123 b   ON a.CustomerID = b.Customer_ID
                    AND a.CustomerAcID = b.CustomerAcID
              WHERE  A.CollateralID IS NOT NULL
                       AND B.CollateralID IS NOT NULL
             UNION 
             SELECT A.CustomerID ,
                    A.CustomerAcID ,
                    A.Scheme_ProductCode ,
                    A.BalanceOutstandingINR ,
                    A.POSBalance ,
                    B.CollateralID ,
                    B.SecurityCode ,
                    B.SecurityValue ,
                    B.ValuationExpiryDate ,
                    B.Collateral_Type ,
                    B.security ,
                    B.Valuationdate ,
                    A.Sec_Perf_Flg 
             FROM tt_temp456 a
                    LEFT JOIN tt_temp123 b   ON a.CustomerID = b.Customer_ID
                    AND a.CustomerAcID = b.CustomerAcID
              WHERE  A.CollateralID IS NOT NULL
                       AND B.CollateralID IS NOT NULL ) a );
   /*
   Add solution for missing data in currency table
   */
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Finacle_ODFD_DATA  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_Finacle_ODFD_DATA;
   UTILS.IDENTITY_RESET('tt_Finacle_ODFD_DATA');

   INSERT INTO tt_Finacle_ODFD_DATA ( 
   	SELECT CustomerID ,
           CustomerAcID ,
           Scheme_ProductCode ,
           UTILS.CONVERT_TO_NUMBER(BalanceOutstandingINR,17,2) BalanceOutstandingINR  ,
           UTILS.CONVERT_TO_NUMBER(POSBalance,17,2) POSBalance  ,
           CollateralID ,
           SecurityCode ,
           UTILS.CONVERT_TO_NUMBER(SecurityValue,17,2) SecurityValue  ,
           UTILS.CONVERT_TO_VARCHAR2(ValuationExpiryDate,200) ValuationExpiryDate  ,
           Collateral_Type ,
           CASE 
                WHEN SecurityCode = 'FCNROD' THEN UTILS.CONVERT_TO_NUMBER(apportioned_value,17,2) * v_CurrencyRate
           ELSE UTILS.CONVERT_TO_NUMBER(apportioned_value,17,2)
              END apportioned_value  ,
           Valuationdate ,
           Sec_Perf_Flg 
   	  FROM tt_tempwer12  );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_Finacle_ODFD_DATA  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITY_FDOD_REPORT" TO "ADF_CDR_RBL_STGDB";
