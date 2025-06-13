--------------------------------------------------------
--  DDL for Procedure ADVSECURITYDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" 
AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200);
   --GO
   /*********************************************************************************************************/
   /*  New Customers Account Entity ID Update  */
   v_SecurityEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here  

BEGIN

     SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
        WHERE  EXT_FLG = 'Y' ;

   SELECT TimeKey 
     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   /* FINACLE COLLATEAL WORK*/
   DELETE FROM GTT_RBL_SECURITY_CAL;
   UTILS.IDENTITY_RESET('GTT_RBL_SECURITY_CAL');

   INSERT INTO GTT_RBL_SECURITY_CAL ( 
   	SELECT DATEOFDATA	,SOURCESYSTEM	,ACCOUNTID	,COLLATERALID	,SECURITYCODE	,SECURITYVALUE	,VALUATIONDATE	,SECURITYCHARGESTATUS	,VALUATIONEXPIRYDATE	,STOCK_AUDIT_DATE	,CUSTOMER_ID	,COLLATERAL_TYPE	,VALUATION_SOURCE	,APPORTIONED_VALUE	,SEC_PERF_FLG	,TYPE_OF_CURRENCY
           ,apportioned_value   
           ,CASE 
                WHEN COLLATERAL_TYPE = 'Immovable Property' THEN 0
           ELSE apportioned_value
              END 
           ,'N' 
           ,UTILS.CONVERT_TO_VARCHAR2('',200) 
   	  FROM RBL_STGDB.SECURITY_SOURCESYSTEM01_STG  );----where Stock_Audit_Date is not null and COLLATERAL_TYPE<>'Immovable Property'
   DELETE GTT_RBL_SECURITY_CAL

    WHERE  NVL(COLLATERAL_TYPE, ' ') IN ( 'NA (will not be considered for secur',' ' )
   ;
   DELETE FROM GTT_RBL_SECURITY_CAL A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM GTT_RBL_SECURITY_CAL a
            JOIN RBL_STGDB.Finacle_ODFD_DATA b   ON a.CollateralID = b.CollateralID
    WHERE  a.Collateral_Type = 'Deposits'
             AND a.SecurityCode <> 'DSRA' );
   /* UPDATE FLAG FLG_MULTI_CUST_COLLID - MULTIPLE CUSTOMER IN CollateralID OR SINGLE CUSTOMER IN CollateralID  FOR  COLLATERAL_TYPE='Immovable Property'*/
   MERGE INTO GTT_RBL_SECURITY_CAL A
   USING (SELECT A.ROWID row_id, CASE 
   WHEN COUNTS > 1 THEN 'Y'
   ELSE 'N'
      END AS FLG_MULTI_CUST_COLLID
   FROM GTT_RBL_SECURITY_CAL A
          JOIN ( SELECT GTT_RBL_SECURITY_CAL.CollateralID ,
                        COUNT(DISTINCT GTT_RBL_SECURITY_CAL.CUSTOMER_ID)  COUNTS  
                 FROM GTT_RBL_SECURITY_CAL 
                  WHERE  GTT_RBL_SECURITY_CAL.COLLATERAL_TYPE = 'Immovable Property'
                           AND GTT_RBL_SECURITY_CAL.ValuationExpiryDate > v_date
                   GROUP BY GTT_RBL_SECURITY_CAL.CollateralID ) B   ON A.CollateralID = B.CollateralID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FLG_MULTI_CUST_COLLID = src.FLG_MULTI_CUST_COLLID;
   
      MERGE INTO GTT_RBL_SECURITY_CAL A 
      USING (SELECT A.ROWID row_id, SecurityValue
      FROM (
                SELECT CUSTOMER_ID ,
                                      SecValue_Final ,
                                      CollateralID ,
                                      SecurityValue ,
                                      ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
                 FROM GTT_RBL_SECURITY_CAL 
                WHERE  COLLATERAL_TYPE = 'Immovable Property'
                         AND FLG_MULTI_CUST_COLLID = 'N'
                         AND ValuationExpiryDate > v_date 
            ) A 
       WHERE A.RID = 1) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET SecValue_Final = SecurityValue
      ;
   /* CASE -3 FOR MULTIPLE CUSTOMER IN CollateralID*/
   DELETE FROM GTT_CALC;
   UTILS.IDENTITY_RESET('GTT_CALC');

   INSERT INTO GTT_CALC ( 
   	SELECT CUSTOMER_ID ,
           A.CollateralID ,
           MAX(UTILS.CONVERT_TO_NUMBER(SecurityValue,16,2))  SecurityValue  ,
           SUM(UTILS.CONVERT_TO_NUMBER(apportioned_value,16,2))  apportioned_value_CUST  ,
           B.apportioned_value_SRN ,
           UTILS.CONVERT_TO_NUMBER(0.00,7,4) CALC_PER  ,
           SecValue_Final ,
           Sec_Perf_Flg 
   	  FROM GTT_RBL_SECURITY_CAL A
             JOIN ( SELECT CollateralID ,
                           SUM(UTILS.CONVERT_TO_NUMBER(apportioned_value,16,2))  apportioned_value_SRN  
                    FROM GTT_RBL_SECURITY_CAL 
                     WHERE  FLG_MULTI_CUST_COLLID = 'Y'
                      GROUP BY CollateralID ) B   ON A.CollateralID = B.CollateralID
   	 WHERE  FLG_MULTI_CUST_COLLID = 'Y'
              AND ValuationExpiryDate > v_date
   	  GROUP BY A.CollateralID,CUSTOMER_ID,B.apportioned_value_SRN,SecValue_Final,Sec_Perf_Flg );
   UPDATE GTT_CALC
      SET CALC_PER = (apportioned_value_CUST * 100) / apportioned_value_SRN;
   INSERT INTO CTE_PER_DIFF_ADJ
    SELECT CUSTOMER_ID	,COLLATERALID	,SECURITYVALUE	,APPORTIONED_VALUE_CUST	,APPORTIONED_VALUE_SRN	
            ,CALC_PER	,SECVALUE_FINAL	,SEC_PERF_FLG,ROW_NUMBER() OVER ( PARTITION BY CollateralID ORDER BY CollateralID, CALC_PER  )
     FROM GTT_CALC  ; 
      MERGE INTO CTE_PER_DIFF_ADJ A
      USING (SELECT A.ROWID row_id, CALC_PER + B.CALC_PER_DIFF AS CALC_PER
      FROM CTE_PER_DIFF_ADJ A
             JOIN ( SELECT CollateralID ,
                           100 - SUM(CALC_PER)  CALC_PER_DIFF  
                    FROM GTT_CALC 
                      GROUP BY CollateralID ) B   ON A.CollateralID = B.CollateralID 
       WHERE A.RID = 1) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.CALC_PER = src.CALC_PER
      ;
   UPDATE GTT_CALC
      SET SecValue_Final = (SecurityValue * CALC_PER) / 100;
      MERGE INTO GTT_RBL_SECURITY_CAL A 
      USING (SELECT A.ROWID row_id, B.SecValue_Final
      FROM (
                SELECT CUSTOMER_ID ,
                                          SecValue_Final ,
                                          CollateralID ,
                                          SecurityValue ,
                                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
                     FROM GTT_RBL_SECURITY_CAL 
                    WHERE  COLLATERAL_TYPE = 'Immovable Property'
                             AND FLG_MULTI_CUST_COLLID = 'Y'
                             AND ValuationExpiryDate > v_date 
             ) A
             JOIN GTT_CALC B   ON A.Customer_ID = B.Customer_ID
             AND A.CollateralID = B.CollateralID 
       WHERE A.RID = 1) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET SecValue_Final = src.SecValue_Final
      ;
   INSERT INTO GTT_CTE_A 
    ( SELECT CUSTOMER_ID ,
                          SecValue_Final ,
                          CollateralID ,
                          SecurityValue ,
                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
     FROM GTT_RBL_SECURITY_CAL 
    WHERE  ValuationExpiryDate > v_date
             AND COLLATERAL_TYPE IN ( 'Deposits','Insurance/NSC/KVP/IVP','Shares/MF/Gold','Movable FA' )
             );
             
   INSERT INTO GTT_CTE_B 
   ( SELECT Customer_ID ,
                     CollateralID ,
                     SUM(SecValue_Final)  SecValue_Final  
     FROM GTT_RBL_SECURITY_CAL 
    WHERE  ValuationExpiryDate > v_date
             AND COLLATERAL_TYPE IN ( 'Deposits','Insurance/NSC/KVP/IVP','Shares/MF/Gold','Movable FA' )
     GROUP BY Customer_ID,CollateralID ) ;
     
      MERGE INTO GTT_CTE_A A
      USING (SELECT A.ROWID row_id, CASE 
      WHEN A.RID = 1 THEN B.SecValue_Final
      ELSE 0
         END AS SecValue_Final
      FROM GTT_CTE_A A
             JOIN GTT_CTE_B B   ON A.CollateralID = B.CollateralID
             AND A.CUSTOMER_ID = B.CUSTOMER_ID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.SecValue_Final = src.SecValue_Final
      ;
   /* CLEANED DATA OUTPUT */
   /* STOCK DATA WORK */
   --select *  from GTT_RBL_SECURITY_CAL_STOCK where SecValue_Final>0 and ValuationExpiryDate>='2022-03-19'
   DELETE FROM GTT_RBL_SECURITY_CAL_STOCK;
   UTILS.IDENTITY_RESET('GTT_RBL_SECURITY_CAL_STOCK');

   INSERT INTO GTT_RBL_SECURITY_CAL_STOCK ( 
   	SELECT DATEOFDATA	,SOURCESYSTEM	,ACCOUNTID	,COLLATERALID	,SECURITYCODE	,SECURITYVALUE	,VALUATIONDATE	,SECURITYCHARGESTATUS	,VALUATIONEXPIRYDATE	,STOCK_AUDIT_DATE	,CUSTOMER_ID	,COLLATERAL_TYPE	,VALUATION_SOURCE	,APPORTIONED_VALUE	,SEC_PERF_FLG	,TYPE_OF_CURRENCY	,MAINSECURITYVALUE	,SECVALUE_FINAL	,FLG_MULTI_CUST_COLLID	,VALUATIONEXPIRYDATE_NEW ,
           UTILS.CONVERT_TO_VARCHAR2('',200) stock_audit_date_new  ,
           UTILS.CONVERT_TO_NUMBER(0,16,2) Cust_OS  
   	  FROM GTT_RBL_SECURITY_CAL 
   	 WHERE  Collateral_Type = 'Stock and Book Debt' );
   UPDATE GTT_RBL_SECURITY_CAL_STOCK
      SET SecValue_Final = 0;
   ---select *  from GTT_RBL_SECURITY_CAL_STOCK   where stock_audit_date
   ---		select * from GTT_RBL_SECURITY_CAL_STOCK where Cust_OS<50000000 and ValuationExpiryDate>=@Date
   
      MERGE INTO GTT_RBL_SECURITY_CAL_STOCK A
      USING (SELECT A.ROWID row_id, B.BALANCE
      FROM GTT_RBL_SECURITY_CAL_STOCK A
             JOIN (
                    SELECT A.RefCustomerId ,
                                                SUM(BALANCE)  BALANCE  
                         FROM RBL_TEMPDB.TempAdvAcBasicDetail A
                                JOIN RBL_TEMPDB.TempAdVAcBalanceDetail B   ON A.AccountEntityId = B.AccountEntityId
                         GROUP BY A.RefCustomerId             
             ) B   
             ON A.Customer_ID = B.RefCustomerId ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.Cust_OS = src.BALANCE
      ;
   /* UPDATE VALUATION EXPIRY DATE IN PROPER FORMAT*/
   UPDATE GTT_RBL_SECURITY_CAL_STOCK
      SET ValuationExpiryDate_new = ValuationExpiryDate;--CAST(ValuationExpiryDate AS DATE) WHERE ValuationExpiryDate IS NOT NULL
   UPDATE GTT_RBL_SECURITY_CAL_STOCK
      SET stock_audit_date_new = UTILS.CONVERT_TO_VARCHAR2(SUBSTR(stock_audit_date, 0, 10),200)
    WHERE  stock_audit_date IS NOT NULL
     AND NVL(CUST_OS, 0) >= 50000000;
   /* DELETE RECORDS WHERE STOCK AUDIT DATE IS NOT PRESENT*/
   --DELETE GTT_RBL_SECURITY_CAL_STOCK WHERE stock_audit_date IS NULL and ISNULL(CUST_OS,0)>=50000000
   /* UPDATE VALUEATION EXPIRY DATE FOR OS 5CR AND ABOVE CUSTOMER*/
   UPDATE GTT_RBL_SECURITY_CAL_STOCK
      SET ValuationExpiryDate_new = CASE 
                                         WHEN stock_audit_date_new IS NULL THEN NULL
                                         WHEN utils.dateadd('YY', 1, stock_audit_date_new) < ValuationExpiryDate_new THEN utils.dateadd('YY', 1, stock_audit_date_new)
          ELSE TO_DATE(ValuationExpiryDate_new,'YYYY-MM-DD')
             END
    WHERE  NVL(CUST_OS, 0) >= 50000000;
   /* DELETE RECORDS FOR VALUATION EXPIRY DATE IS NULL  OR LESS THAN PROCESS DATE */
   ---DELETE GTT_RBL_SECURITY_CAL_STOCK WHERE  (ValuationExpiryDate_new<'2022-03-22' )
   --or ValuationExpiryDate_new is null )
   ----		SELECT * FROM GTT_RBL_SECURITY_CAL_STOCK WHERE Customer_ID ='2098381'
   
      MERGE INTO GTT_RBL_SECURITY_CAL_STOCK A 
      USING (SELECT A.ROWID row_id, B.apportioned_value
      FROM (
                SELECT CUSTOMER_ID ,
                                          SecValue_Final ,
                                          CollateralID ,
                                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
                     FROM GTT_RBL_SECURITY_CAL_STOCK 
                    WHERE  ( NVL(CUST_OS, 0) >= 50000000
                             AND ValuationExpiryDate_new >= v_Date )
                             OR ( NVL(CUST_OS, 0) < 50000000
                             AND ValuationExpiryDate_new > v_Date )      
      ) A
             JOIN ( SELECT Customer_ID ,
                           CollateralID ,
                           SUM(UTILS.CONVERT_TO_NUMBER(apportioned_value,16,2))  apportioned_value  
                    FROM GTT_RBL_SECURITY_CAL_STOCK 
                     WHERE  ValuationExpiryDate_new > v_Date
                      GROUP BY Customer_ID,CollateralID ) B   ON A.Customer_ID = B.Customer_ID
             AND A.CollateralID = B.CollateralID
             AND A.RID = 1 ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET SecValue_Final = src.apportioned_value
      ;
   ----ALTER TABLE GTT_RBL_SECURITY_CAL add ValuationExpiryDate_new date
   UPDATE GTT_RBL_SECURITY_CAL
      SET SecValue_Final = 0
    WHERE  ( ValuationExpiryDate <= v_Date
     OR ( SecurityValue = 0
     OR NVL(ValuationExpiryDate, ' ') = ' ' ) )
     AND SecValue_Final > 0;
   UPDATE GTT_RBL_SECURITY_CAL
      SET ValuationExpiryDate_new = ValuationExpiryDate;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_STGDB.FINACLE_COLLATERAL_DATA ';
   INSERT INTO RBL_STGDB.FINACLE_COLLATERAL_DATA
     ( CUSTOMER_ID, COLLATERALID, SECURITYCODE, VALUATIONDATE, ValuationExpiryDate_new, MainSecurityValue, SecValue_Final, Sec_Perf_Flg, Currency_Code )
     ( SELECT CUSTOMER_ID ,
              COLLATERALID ,
              SECURITYCODE ,
              VALUATIONDATE ,
              ValuationExpiryDate_new ,
              SUM(MainSecurityValue)  MainSecurityValue  ,
              SUM(SecValue_Final)  SecValue_Final  ,
              Sec_Perf_Flg ,
              Type_Of_Currency 
       FROM ( SELECT CUSTOMER_ID ,
                     COLLATERALID ,
                     SECURITYCODE ,
                     VALUATIONDATE ,
                     ValuationExpiryDate_new ,
                     MainSecurityValue ,
                     SecValue_Final ,
                     Sec_Perf_Flg ,
                     Type_Of_Currency 
              FROM GTT_RBL_SECURITY_CAL_STOCK 
              UNION ALL 
              SELECT CUSTOMER_ID ,
                     COLLATERALID ,
                     SECURITYCODE ,
                     VALUATIONDATE ,
                     ValuationExpiryDate_new ,
                     MainSecurityValue ,
                     SecValue_Final ,
                     Sec_Perf_Flg ,
                     Type_Of_Currency 
              FROM GTT_RBL_SECURITY_CAL 
               WHERE  COLLATERAL_TYPE NOT IN ( 'Stock and Book Debt' )
             ) SEC
         GROUP BY CUSTOMER_ID,COLLATERALID,SECURITYCODE,VALUATIONDATE,ValuationExpiryDate_new,Sec_Perf_Flg,Type_Of_Currency );
   --select * from GTT_RBL_SECURITY_CAL
   --select * from  GTT_RBL_SECURITY_CAL_STOCK where ValuationExpiryDate_new<=@Date
   /* END OF FINACLE COLLATERAL WORK*/
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvSecurityDetail ';
   INSERT INTO RBL_TEMPDB.TempAdvSecurityDetail
     ( AccountEntityId, CustomerEntityId, SecurityType, CollateralType, SecurityAlt_Key, SecurityEntityID, Security_RefNo, SecurityNature, SecurityChargeTypeAlt_Key, CurrencyAlt_Key, EntryType, ScrCrError, InwardNo, Limitnode_Flag, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocTypeAlt_Key, MocStatus, MocDate, SecurityParticular, OwnerTypeAlt_Key, AssetOwnerName, ValueAtSanctionTime, BranchLastInspecDate, SatisfactionNo, SatisfactionDate, BankShare, ActionTakenRemark, SecCharge, CollateralID, Sec_Perf_Flg )
     ( 
       -------------    mifin  ---------  
       SELECT B.AccountEntityId ,
              B.CustomerEntityId ,
              'P' SecurityType  ,
              NULL CollateralType  ,
              999 SecurityAlt_Key  ,
              0 SecurityEntityID  ,
              NULL Security_RefNo  ,
              NULL SecurityNature  ,
              NULL SecurityChargeTypeAlt_Key  ,
              NULL CurrencyAlt_Key  ,
              NULL EntryType  ,
              NULL ScrCrError  ,
              NULL InwardNo  ,
              NULL Limitnode_Flag  ,
              B.RefCustomerId ,
              B.SystemAcId ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              NULL MocTypeAlt_Key  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL SecurityParticular  ,
              NULL OwnerTypeAlt_Key  ,
              NULL AssetOwnerName  ,
              NULL ValueAtSanctionTime  ,
              NULL BranchLastInspecDate  ,
              NULL SatisfactionNo  ,
              NULL SatisfactionDate  ,
              NULL BankShare  ,
              NULL ActionTakenRemark  ,
              NULL SecCharge  ,
              CollateralID ,
              NULL 

       ---select * 
       FROM RBL_STGDB.Security_All_Source_System A
              JOIN RBL_TEMPDB.TempAdvAcBasicDetail B   ON A.AccountID = B.CustomerAcid
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
       UNION 

       ----FINACLE COLLATERAL DATE

       -------------    FINACLE  ---------  
       SELECT NULL AccountEntityId  ,
              B.CustomerEntityId ,
              'C' SecurityType  ,
              'C' CollateralType  ,
              999 SecurityAlt_Key  ,
              0 SecurityEntityID  ,
              NULL Security_RefNo  ,
              NULL SecurityNature  ,
              NULL SecurityChargeTypeAlt_Key  ,
              DC.CurrencyAlt_Key CurrencyAlt_Key  ,
              NULL EntryType  ,
              NULL ScrCrError  ,
              NULL InwardNo  ,
              NULL Limitnode_Flag  ,
              B.CustomerId ,
              NULL SystemAcId  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              NULL MocTypeAlt_Key  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL SecurityParticular  ,
              NULL OwnerTypeAlt_Key  ,
              NULL AssetOwnerName  ,
              NULL ValueAtSanctionTime  ,
              NULL BranchLastInspecDate  ,
              NULL SatisfactionNo  ,
              NULL SatisfactionDate  ,
              NULL BankShare  ,
              NULL ActionTakenRemark  ,
              NULL SecCharge  ,
              CollateralID ,
              A.Sec_Perf_Flg 

       ---select * 
       FROM RBL_STGDB.FINACLE_COLLATERAL_DATA A
              JOIN RBL_TEMPDB.TempCustomerBasicDetail B   ON A.CUSTOMER_ID = B.CustomerId
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_MISDB_PROD.DimCurrency DC   ON A.Currency_Code = DC.CurrencyCode
              AND DC.EffectiveFromTimeKey <= v_TimeKey
              AND DC.EffectiveToTimeKey >= v_TimeKey
       UNION ALL 

       -------------    FINACLE  ---------  
       SELECT AccountEntityId ,
              B.CustomerEntityId ,
              'P' SecurityType  ,
              NULL CollateralType  ,
              999 SecurityAlt_Key  ,
              0 SecurityEntityID  ,
              NULL Security_RefNo  ,
              NULL SecurityNature  ,
              NULL SecurityChargeTypeAlt_Key  ,
              DC.CurrencyAlt_Key CurrencyAlt_Key  ,
              NULL EntryType  ,
              NULL ScrCrError  ,
              NULL InwardNo  ,
              NULL Limitnode_Flag  ,
              B.RefCustomerId ,
              SystemAcId ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              NULL MocTypeAlt_Key  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL SecurityParticular  ,
              NULL OwnerTypeAlt_Key  ,
              NULL AssetOwnerName  ,
              NULL ValueAtSanctionTime  ,
              NULL BranchLastInspecDate  ,
              NULL SatisfactionNo  ,
              NULL SatisfactionDate  ,
              NULL BankShare  ,
              NULL ActionTakenRemark  ,
              NULL SecCharge  ,
              CollateralID ,
              A.Sec_Perf_Flg 

       ---select * 
       FROM RBL_STGDB.Finacle_ODFD_DATA A
              JOIN RBL_TEMPDB.TempAdvAcBasicDetail B   ON A.CustomerAcID = B.CustomerAcID
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_MISDB_PROD.DimCurrency DC   ON A.Currency_Code = DC.CurrencyCode
              AND DC.EffectiveFromTimeKey <= v_TimeKey
              AND DC.EffectiveToTimeKey >= v_TimeKey );
   DELETE RBL_TEMPDB.tempadvsecuritydetail

    WHERE  CollateralID IS NULL;
   MERGE INTO RBL_TEMPDB.tempadvsecuritydetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.SecurityEntityId
   FROM RBL_TEMPDB.tempadvsecuritydetail TEMP
          JOIN RBL_MISDB_PROD.AdvSecurityDetail MAIN   ON (CASE 
                                                                WHEN TEMP.SecurityType = 'P' THEN TEMP.AccountEntityId
        ELSE TEMP.CustomerEntityId
           END) = CASE 
                       WHEN MAIN.SecurityType = 'P' THEN MAIN.AccountEntityId
        ELSE MAIN.CustomerEntityId
           END
          AND TEMP.CollateralId = MAIN.CollateralId 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.SecurityEntityId = src.SecurityEntityId;
   SELECT MAX(SecurityEntityId)  

     INTO v_SecurityEntityId
     FROM RBL_MISDB_PROD.AdvSecurityDetail ;
   IF v_SecurityEntityId IS NULL THEN

   BEGIN
      v_SecurityEntityId := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.tempadvsecuritydetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.SecurityEntityId
   FROM RBL_TEMPDB.tempadvsecuritydetail TEMP
          JOIN ( SELECT "TEMPADVSECURITYDETAIL".CustomerEntityId ,
                        "TEMPADVSECURITYDETAIL".AccountEntityId ,
                        "TEMPADVSECURITYDETAIL".CollateralId ,
                        "TEMPADVSECURITYDETAIL".SecurityType ,
                        (v_SecurityEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                               FROM DUAL  )  )) SecurityEntityId  
                 FROM RBL_TEMPDB.tempadvsecuritydetail 
                  WHERE  "TEMPADVSECURITYDETAIL".SecurityEntityId = 0
                           OR "TEMPADVSECURITYDETAIL".SecurityEntityId IS NULL ) ACCT   ON (CASE 
                                                                                                 WHEN TEMP.SecurityType = 'P' THEN TEMP.AccountEntityId
        ELSE TEMP.CustomerEntityId
           END) = CASE 
                       WHEN ACCT.SecurityType = 'P' THEN ACCT.AccountEntityId
        ELSE ACCT.CustomerEntityId
           END
          AND TEMP.CollateralId = ACCT.CollateralId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.SecurityEntityId = src.SecurityEntityId;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
