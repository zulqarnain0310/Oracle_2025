--------------------------------------------------------
--  DDL for Procedure ADVSECURITYDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" 
-- =============================================  
 -- Author:  <Author,,Name>  
 -- Create date: <Create Date,,>  
 -- Description: <Description,,>  
 -- =============================================  

AS
   -- -- SET NOCOUNT ON added to prevent extra result sets from  [RBL_MISDB]
   -- -- interfering with SELECT statements.  
   -- SET NOCOUNT ON;  
   -- Insert statements for procedure here  
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --GO
   /*********************************************************************************************************/
   /*  New Customers Account Entity ID Update  */
   v_SecurityEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here  

BEGIN

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --DECLARE @PrvTimeKey  Int SET @PrvTimeKey=(SELECT TimeKey-1 FROM [RBL_MISDB_010922_UAT].[dbo].Automate_Advances WHERE EXT_FLG='Y')  
   -- Update [RBL_MISDB_010922_UAT].CurDat.AdvSecurityDetail  set EffectiveToTimeKey=@PrvTimeKey where EffectiveToTimeKey=49999
   --Update  [RBL_MISDB_010922_UAT].curdat.AdvSecurityValueDetail set EffectiveToTimeKey=@PrvTimeKey where EffectiveToTimeKey=49999
   ---------------------------------------------------------------------------------------------------------------------------------------------------   
   /* FINACLE COLLATEAL WORK*/
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_RBL_SECURITY_CAL_6  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_RBL_SECURITY_CAL_6;
   UTILS.IDENTITY_RESET('tt_RBL_SECURITY_CAL_6');

   INSERT INTO tt_RBL_SECURITY_CAL_6 ( 
   	SELECT * ,
           apportioned_value MainSecurityValue  ,
           CASE 
                WHEN COLLATERAL_TYPE = 'Immovable Property' THEN 0
           ELSE apportioned_value
              END SecValue_Final  ,
           'N' FLG_MULTI_CUST_COLLID  ,
           UTILS.CONVERT_TO_VARCHAR2('',200) ValuationExpiryDate_new  

   	  ---SELECT distinct COLLATERAL_TYPE
   	  FROM RBL_STGDB.SECURITY_SOURCESYSTEM01_STG  );----where Stock_Audit_Date is not null and COLLATERAL_TYPE<>'Immovable Property'
   DELETE tt_RBL_SECURITY_CAL_6

    WHERE  NVL(COLLATERAL_TYPE, ' ') IN ( 'NA (will not be considered for secur',' ' )
   ;
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_RBL_SECURITY_CAL_6 a
            JOIN ETL_TEMP_RBL_STGDB.Finacle_ODFD_DATA b   ON a.CollateralID = b.CollateralID,
          A
    WHERE  a.Collateral_Type = 'Deposits'
             AND a.SecurityCode <> 'DSRA' );
   /* UPDATE FLAG FLG_MULTI_CUST_COLLID - MULTIPLE CUSTOMER IN CollateralID OR SINGLE CUSTOMER IN CollateralID  FOR  COLLATERAL_TYPE='Immovable Property'*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, CASE 
   WHEN COUNTS > 1 THEN 'Y'
   ELSE 'N'
      END AS FLG_MULTI_CUST_COLLID
   FROM A ,tt_RBL_SECURITY_CAL_6 A
          JOIN ( SELECT tt_RBL_SECURITY_CAL_6.CollateralID ,
                        COUNT(DISTINCT tt_RBL_SECURITY_CAL_6.CUSTOMER_ID)  COUNTS  
                 FROM tt_RBL_SECURITY_CAL_6 
                  WHERE  tt_RBL_SECURITY_CAL_6.COLLATERAL_TYPE = 'Immovable Property'
                           AND tt_RBL_SECURITY_CAL_6.ValuationExpiryDate > v_date
                   GROUP BY tt_RBL_SECURITY_CAL_6.CollateralID ) B   ON A.CollateralID = B.CollateralID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.FLG_MULTI_CUST_COLLID = src.FLG_MULTI_CUST_COLLID;
   WITH CTE_A AS ( SELECT CUSTOMER_ID ,
                          SecValue_Final ,
                          CollateralID ,
                          SecurityValue ,
                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
     FROM tt_RBL_SECURITY_CAL_6 
    WHERE  COLLATERAL_TYPE = 'Immovable Property'
             AND FLG_MULTI_CUST_COLLID = 'N'
             AND ValuationExpiryDate > v_date ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, SecurityValue
      FROM A ,CTE_A A 
       WHERE A.RID = 1) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET SecValue_Final = SecurityValue
      ;
   /* CASE -3 FOR MULTIPLE CUSTOMER IN CollateralID*/
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_CALC_6  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_CALC_6;
   UTILS.IDENTITY_RESET('tt_CALC_6');

   INSERT INTO tt_CALC_6 ( 
   	SELECT CUSTOMER_ID ,
           A.CollateralID ,
           MAX(UTILS.CONVERT_TO_NUMBER(SecurityValue,16,2))  SecurityValue  ,
           SUM(UTILS.CONVERT_TO_NUMBER(apportioned_value,16,2))  apportioned_value_CUST  ,
           B.apportioned_value_SRN ,
           UTILS.CONVERT_TO_NUMBER(0.00,7,4) CALC_PER  ,
           SecValue_Final 
   	  FROM tt_RBL_SECURITY_CAL_6 A
             JOIN ( SELECT CollateralID ,
                           SUM(UTILS.CONVERT_TO_NUMBER(apportioned_value,16,2))  apportioned_value_SRN  
                    FROM tt_RBL_SECURITY_CAL_6 
                     WHERE  FLG_MULTI_CUST_COLLID = 'Y'
                      GROUP BY CollateralID ) B   ON A.CollateralID = B.CollateralID
   	 WHERE  FLG_MULTI_CUST_COLLID = 'Y'
              AND ValuationExpiryDate > v_date
   	  GROUP BY A.CollateralID,CUSTOMER_ID,B.apportioned_value_SRN,SecValue_Final );
   UPDATE tt_CALC_6
      SET CALC_PER = (apportioned_value_CUST * 100) / apportioned_value_SRN;
   WITH CTE_PER_DIFF_ADJ AS ( SELECT * ,
                                     ROW_NUMBER() OVER ( PARTITION BY CollateralID ORDER BY CollateralID, CALC_PER  ) RID  
     FROM tt_CALC_6  ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CALC_PER + B.CALC_PER_DIFF AS CALC_PER
      FROM A ,CTE_PER_DIFF_ADJ A
             JOIN ( SELECT CollateralID ,
                           100 - SUM(CALC_PER)  CALC_PER_DIFF  
                    FROM tt_CALC_6 
                      GROUP BY CollateralID ) B   ON A.CollateralID = B.CollateralID 
       WHERE A.RID = 1) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.CALC_PER = src.CALC_PER
      ;
   UPDATE tt_CALC_6
      SET SecValue_Final = (SecurityValue * CALC_PER) / 100;
   WITH CTE_A AS ( SELECT CUSTOMER_ID ,
                          SecValue_Final ,
                          CollateralID ,
                          SecurityValue ,
                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
     FROM tt_RBL_SECURITY_CAL_6 
    WHERE  COLLATERAL_TYPE = 'Immovable Property'
             AND FLG_MULTI_CUST_COLLID = 'Y'
             AND ValuationExpiryDate > v_date ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, B.SecValue_Final
      FROM A ,CTE_A A
             JOIN tt_CALC_6 B   ON A.Customer_ID = B.Customer_ID
             AND A.CollateralID = B.CollateralID 
       WHERE A.RID = 1) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET SecValue_Final = src.SecValue_Final
      ;
   WITH CTE_A AS ( SELECT CUSTOMER_ID ,
                          SecValue_Final ,
                          CollateralID ,
                          SecurityValue ,
                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
     FROM tt_RBL_SECURITY_CAL_6 
    WHERE  ValuationExpiryDate > v_date
             AND COLLATERAL_TYPE IN ( 'Deposits','Insurance/NSC/KVP/IVP','Shares/MF/Gold','Movable FA' )
    ),
   CTE_B AS ( SELECT Customer_ID ,
                     CollateralID ,
                     SUM(SecValue_Final)  SecValue_Final  
     FROM tt_RBL_SECURITY_CAL_6 
    WHERE  ValuationExpiryDate > v_date
             AND COLLATERAL_TYPE IN ( 'Deposits','Insurance/NSC/KVP/IVP','Shares/MF/Gold','Movable FA' )

     GROUP BY Customer_ID,CollateralID ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN A.RID = 1 THEN B.SecValue_Final
      ELSE 0
         END AS SecValue_Final
      FROM A ,CTE_A A
             JOIN CTE_B B   ON A.CollateralID = B.CollateralID
             AND A.CUSTOMER_ID = B.CUSTOMER_ID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.SecValue_Final = src.SecValue_Final
      ;
   /* CLEANED DATA OUTPUT */
   /* STOCK DATA WORK */
   --select *  from tt_RBL_SECURITY_CAL_6_STOCK where SecValue_Final>0 and ValuationExpiryDate>='2022-03-19'
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_RBL_SECURITY_CAL_6_STOCK  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_RBL_SECURITY_CAL_STOCK_6;
   UTILS.IDENTITY_RESET('tt_RBL_SECURITY_CAL_STOCK_6');

   INSERT INTO tt_RBL_SECURITY_CAL_STOCK_6 ( 
   	SELECT * ,
           UTILS.CONVERT_TO_VARCHAR2('',200) stock_audit_date_new  ,
           UTILS.CONVERT_TO_NUMBER(0,16,2) Cust_OS  
   	  FROM tt_RBL_SECURITY_CAL_6 
   	 WHERE  Collateral_Type = 'Stock and Book Debt' );
   UPDATE tt_RBL_SECURITY_CAL_STOCK_6
      SET SecValue_Final = 0;
   ---select *  from tt_RBL_SECURITY_CAL_6_STOCK   where stock_audit_date
   ---		select * from tt_RBL_SECURITY_CAL_6_STOCK where Cust_OS<50000000 and ValuationExpiryDate>=@Date
   WITH CUST_OS AS ( SELECT A.RefCustomerId ,
                            SUM(BALANCE)  BALANCE  
     FROM RBL_TEMPDB.TempAdvAcBasicDetail A
            JOIN RBL_TEMPDB.TempAdVAcBalanceDetail B   ON A.AccountEntityId = B.AccountEntityId
     GROUP BY A.RefCustomerId ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, B.BALANCE
      FROM A ,tt_RBL_SECURITY_CAL_STOCK_6 A
             JOIN CUST_OS B   ON A.Customer_ID = B.RefCustomerId ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.Cust_OS = src.BALANCE
      ;
   /* UPDATE VALUATION EXPIRY DATE IN PROPER FORMAT*/
   UPDATE tt_RBL_SECURITY_CAL_STOCK_6
      SET ValuationExpiryDate_new = ValuationExpiryDate;--CAST(ValuationExpiryDate AS DATE) WHERE ValuationExpiryDate IS NOT NULL
   UPDATE tt_RBL_SECURITY_CAL_STOCK_6
      SET stock_audit_date_new = UTILS.CONVERT_TO_VARCHAR2(SUBSTR(stock_audit_date, 0, 10),200)
    WHERE  stock_audit_date IS NOT NULL
     AND NVL(CUST_OS, 0) >= 50000000;
   /* DELETE RECORDS WHERE STOCK AUDIT DATE IS NOT PRESENT*/
   --DELETE tt_RBL_SECURITY_CAL_6_STOCK WHERE stock_audit_date IS NULL and ISNULL(CUST_OS,0)>=50000000
   /* UPDATE VALUEATION EXPIRY DATE FOR OS 5CR AND ABOVE CUSTOMER*/
   UPDATE tt_RBL_SECURITY_CAL_STOCK_6
      SET ValuationExpiryDate_new = CASE 
                                         WHEN stock_audit_date_new IS NULL THEN NULL
                                         WHEN utils.dateadd('YY', 1, stock_audit_date_new) < ValuationExpiryDate_new THEN utils.dateadd('YY', 1, stock_audit_date_new)
          ELSE ValuationExpiryDate_new
             END
    WHERE  NVL(CUST_OS, 0) >= 50000000;
   /* DELETE RECORDS FOR VALUATION EXPIRY DATE IS NULL  OR LESS THAN PROCESS DATE */
   ---DELETE tt_RBL_SECURITY_CAL_6_STOCK WHERE  (ValuationExpiryDate_new<'2022-03-22' )
   --or ValuationExpiryDate_new is null )
   ----		SELECT * FROM tt_RBL_SECURITY_CAL_6_STOCK WHERE Customer_ID ='2098381'
   WITH CTE_A AS ( SELECT CUSTOMER_ID ,
                          SecValue_Final ,
                          CollateralID ,
                          ROW_NUMBER() OVER ( PARTITION BY CUSTOMER_ID, CollateralID ORDER BY Customer_ID, CollateralID, SecurityValue  ) RID  
     FROM tt_RBL_SECURITY_CAL_STOCK_6 
    WHERE  ( NVL(CUST_OS, 0) >= 50000000
             AND ValuationExpiryDate_new >= v_Date )
             OR ( NVL(CUST_OS, 0) < 50000000
             AND ValuationExpiryDate_new > v_Date ) ) 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, B.apportioned_value
      FROM A ,CTE_A A
             JOIN ( SELECT Customer_ID ,
                           CollateralID ,
                           SUM(UTILS.CONVERT_TO_NUMBER(apportioned_value,16,2))  apportioned_value  
                    FROM tt_RBL_SECURITY_CAL_STOCK_6 
                     WHERE  ValuationExpiryDate_new > v_Date
                      GROUP BY Customer_ID,CollateralID ) B   ON A.Customer_ID = B.Customer_ID
             AND A.CollateralID = B.CollateralID
             AND A.RID = 1 ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET SecValue_Final = src.apportioned_value
      ;
   ----ALTER TABLE tt_RBL_SECURITY_CAL_6 add ValuationExpiryDate_new date
   UPDATE tt_RBL_SECURITY_CAL_6
      SET SecValue_Final = 0
    WHERE  ( ValuationExpiryDate <= v_Date
     OR ( SecurityValue = 0
     OR NVL(ValuationExpiryDate, ' ') = ' ' ) )
     AND SecValue_Final > 0;
   UPDATE tt_RBL_SECURITY_CAL_6
      SET ValuationExpiryDate_new = ValuationExpiryDate;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_STGDB.FINACLE_COLLATERAL_DATA ';
   INSERT INTO RBL_STGDB.FINACLE_COLLATERAL_DATA
     ( CUSTOMER_ID, COLLATERALID, SECURITYCODE, VALUATIONDATE, ValuationExpiryDate_new, MainSecurityValue, SecValue_Final )
     ( SELECT CUSTOMER_ID ,
              COLLATERALID ,
              SECURITYCODE ,
              VALUATIONDATE ,
              ValuationExpiryDate_new ,
              SUM(MainSecurityValue)  MainSecurityValue  ,
              SUM(SecValue_Final)  SecValue_Final  
       FROM ( SELECT CUSTOMER_ID ,
                     COLLATERALID ,
                     SECURITYCODE ,
                     VALUATIONDATE ,
                     ValuationExpiryDate_new ,
                     MainSecurityValue ,
                     SecValue_Final 
              FROM tt_RBL_SECURITY_CAL_STOCK_6 
              UNION ALL 
              SELECT CUSTOMER_ID ,
                     COLLATERALID ,
                     SECURITYCODE ,
                     VALUATIONDATE ,
                     ValuationExpiryDate_new ,
                     MainSecurityValue ,
                     SecValue_Final 
              FROM tt_RBL_SECURITY_CAL_6 
               WHERE  COLLATERAL_TYPE NOT IN ( 'Stock and Book Debt' )
             ) SEC
         GROUP BY CUSTOMER_ID,COLLATERALID,SECURITYCODE,VALUATIONDATE,ValuationExpiryDate_new );
   --select * from tt_RBL_SECURITY_CAL_6
   --select * from  tt_RBL_SECURITY_CAL_6_STOCK where ValuationExpiryDate_new<=@Date
   /* END OF FINACLE COLLATERAL WORK*/
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvSecurityDetail ';
   INSERT INTO TempAdvSecurityDetail
     ( AccountEntityId, CustomerEntityId, SecurityType, CollateralType, SecurityAlt_Key, SecurityEntityID, Security_RefNo, SecurityNature, SecurityChargeTypeAlt_Key, CurrencyAlt_Key, EntryType, ScrCrError, InwardNo, Limitnode_Flag, RefCustomerId, RefSystemAcId, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, MocTypeAlt_Key, MocStatus, MocDate, SecurityParticular, OwnerTypeAlt_Key, AssetOwnerName, ValueAtSanctionTime, BranchLastInspecDate, SatisfactionNo, SatisfactionDate, BankShare, ActionTakenRemark, SecCharge, CollateralID )
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
              CollateralID 

       ---select * 
       FROM RBL_STGDB.Security_All_Source_System A
              JOIN TempAdvAcBasicDetail B   ON A.AccountID = B.CustomerAcid
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
              62 CurrencyAlt_Key  ,
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
              CollateralID 

       ---select * 
       FROM RBL_STGDB.FINACLE_COLLATERAL_DATA A
              JOIN TempCustomerBasicDetail B   ON A.CUSTOMER_ID = B.CustomerId
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
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
              62 CurrencyAlt_Key  ,
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
              CollateralID 

       ---select * 
       FROM RBL_STGDB.Finacle_ODFD_DATA A
              JOIN TempAdvAcBasicDetail B   ON A.CustomerAcID = B.CustomerAcID
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey );
   DELETE RBL_TEMPDB.tempadvsecuritydetail

    WHERE  CollateralID IS NULL;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, MAIN.SecurityEntityId
   FROM TEMP ,RBL_TEMPDB.tempadvsecuritydetail TEMP
          JOIN RBL_MISDB_010922_UAT.AdvSecurityDetail MAIN   ON (CASE 
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
     FROM RBL_MISDB_010922_UAT.AdvSecurityDetail ;
   IF v_SecurityEntityId IS NULL THEN

   BEGIN
      v_SecurityEntityId := 0 ;

   END;
   END IF;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, ACCT.SecurityEntityId
   FROM TEMP ,RBL_TEMPDB.tempadvsecuritydetail TEMP
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
