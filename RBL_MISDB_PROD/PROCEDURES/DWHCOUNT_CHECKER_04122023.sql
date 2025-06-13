--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_CHECKER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" 
AS
   --Declare @Date date = (select cast(getdate()-1 as date))  
   v_AsOnDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) Date_  
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --Declare @AsOnDate date =(select distinct date_of_data from DWH_STG.dwh.account_data_finacle)  
   --select @AsOnDate  
   v_Date VARCHAR2(200) := ( SELECT utils.dateadd('DAY', 1, v_AsOnDate) 
     FROM DUAL  );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @Date date=@AsOnDate  
   --select @Date  
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM ControlTable_DWHCount_Status 
                WHERE  dateofdata = v_Date
                         AND Status_Flag = 'Y' ) <> 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      utils.raiserror( 0, 'Status Flag Not Updated' );

   END;
   ELSE
   DECLARE
      -- ===================================GoldMaster=============================================  
      v_Count NUMBER(10,0);
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      EXECUTE IMMEDIATE ' TRUNCATE TABLE DWH_Count_status_Daily ';
      INSERT INTO DWH_Count_status_Daily
        ( SELECT * 
          FROM DWH_Count_status 
           WHERE  DateOfdate = v_Date );
      UPDATE DWH_Count_status_Daily 
         SET SourceSystem = (CASE 
                                  WHEN SourceSystem = 'EXT_Calypso_D2k_Final_Queries_Derivative_Cancelled' THEN 'Calypso - Derivative'
                                  WHEN SourceSystem = 'EXT_Calypso_D2k_Final_Queries_InvestmentBasicDetail' THEN 'Calypso - INVESTIMENTBASICDETAIL'
                                  WHEN SourceSystem = 'EXT_Calypso_D2k_Final_Queries_InvestmentFinancialDetails' THEN 'Calypso -INVESTIMENTFINANCIALDETAIL'
                                  WHEN SourceSystem = 'EXT_Calypso_D2k_Final_Queries_InvestmentIssuerDetail' THEN 'Calypso -INVESTIMENTISSUERDETAIL'
                                  WHEN SourceSystem = 'EXT_ECBF_D2K_Accounts' THEN 'ECBF ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_ECBF_D2K_Customers' THEN 'ECBF CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_ECBF_D2K_Security' THEN 'ECBF SECURITY'
                                  WHEN SourceSystem = 'EXT_D2K_Finacle_queries_AZV2_9' THEN 'FINACLE ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_Bills_Final_Query' THEN 'FINACLE BILL'
                                  WHEN SourceSystem = 'EXT_D2k_Finacle_Customer' THEN 'FINACLE CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_PCA_Query_Final' THEN 'FINACLE PC'
                                  WHEN SourceSystem = 'EXT_D2k_Finacle_Collateral_New' THEN 'FINACLE SECURITY'
                                  WHEN SourceSystem = 'EXT_D2k_Finacle_Transactions' THEN 'FINACLE TRANSACTION'

                                  --when SourceSystem='EXT_D2K_Ganaseva_V5_Account' then 'GANASEVA ACCOUNTS'  

                                  --when SourceSystem='EXT_D2K_Ganaseva_V5_Customer' then 'GANASEVA CUSTOMERS'  
                                  WHEN SourceSystem = 'EXT_D2K_FIS_V5_Account' THEN 'FIS ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_D2K_FIS_V5_Customer' THEN 'FIS CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_MIFIN_D2K_Final_Per_Gram_Gold_Rate' THEN 'GOLDMASTER'
                                  WHEN SourceSystem = 'EXT_Indus_D2K_Final_Accounts' THEN 'INDUS ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_Indus_D2K_Final_Customers' THEN 'INDUS CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_Indus_D2K_Final_Security' THEN 'INDUS SECURITY'
                                  WHEN SourceSystem = 'EXT_MIFIN_D2K_Final' THEN 'MIFIN ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_MIFIN_D2K_Final_Customers' THEN 'MIFIN CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_MIFIN_D2K_Final_Security' THEN 'MIFIN SECURITY'
                                  WHEN SourceSystem = 'EXT_VisionPlus_CC_PROD_Account_Master' THEN 'VISIONPLUS ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_VisionPlus_CC_PROD_Customer_Master' THEN 'VISIONPLUS CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_D2K_TAF_Account_Master' THEN 'EIFS ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_D2K_TAF_Customer_Master' THEN 'EIFS CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_metagrid_account_master_d2k' THEN 'METAGRID ACCOUNTS'
                                  WHEN SourceSystem = 'EXT_metagrid_customer_master_d2k' THEN 'METAGRID CUSTOMERS'
                                  WHEN SourceSystem = 'EXT_metagrid_Security_d2k' THEN 'METAGRID SECURITY'
                                  WHEN SourceSystem = 'EXT_Calypso_D2k_Final_Queries_reversefile' THEN 'Reversefeed Calypso'
                                  WHEN SourceSystem = 'EXT_D2k_scf_bills' THEN 'SCF BILL'
             ELSE SourceSystem
                END);
      DELETE DWH_Count_status_Daily

       WHERE  SourceSystem LIKE '%EXT_%';
      EXECUTE IMMEDIATE ' TRUNCATE TABLE DWH_STG.dwhControlTable ';
      INSERT INTO DWH_STG.dwhControlTable
        SELECT DISTINCT COUNT(1)  SourceCount  ,
                        'FINACLE CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data_finacle 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  SourceCount  ,
                        'INDUS CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'VISIONPLUS CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data_visionplus 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'ECBF CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data_ecbf 
         WHERE  date_of_data = v_Date
        UNION 

        --select distinct count(1),'GANASEVA CUSTOMERS' SourceSystem from [DWH_STG].dwh.customer_data_ganaseva where date_of_data=@Date 
        SELECT DISTINCT COUNT(1)  ,
                        'FIS CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data_fis 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'MIFIN CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data_mifin 
         WHERE  dateofdata = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'FINACLE ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.account_data_finacle 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'INDUS ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.accounts_data 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'VISIONPLUS ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.account_data_visionplus 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'ECBF ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.accounts_data_ecbf 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'FIS ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.account_data_fis 
         WHERE  date_of_data = v_Date
        UNION 

        --select distinct count(1),'GANASEVA ACCOUNTS'SourceSystem from [DWH_STG].dwh.account_data_ganaseva where date_of_data=@Date  

        --select distinct count(1)'MIFIN CUSTOMER' from [DWH_STG].dwh.accounts_data_mifin  
        SELECT DISTINCT COUNT(1)  ,
                        'MIFIN ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.accounts_data_mifin 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'FINACLE SECURITY' SourceSystem  
          FROM DWH_DWH_STG.collateral_type_master_finacle 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'ECBF SECURITY' SourceSystem  
          FROM DWH_DWH_STG.security_data_ecbf 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'INDUS SECURITY' SourceSystem  
          FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM02 
         WHERE  dateofdata = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'MIFIN SECURITY' SourceSystem  
          FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM04 
         WHERE  dateofdata = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'FINACLE TRANSACTION' SourceSystem  
          FROM DWH_DWH_STG.transaction_data_finacle 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'FINACLE BILL' SourceSystem  
          FROM DWH_DWH_STG.bills_data_stg_fin 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'FINACLE PC' SourceSystem  
          FROM DWH_DWH_STG.pca_data 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'Calypso - INVESTIMENTBASICDETAIL' SourceSystem  
          FROM dwh_DWH_STG.InvestmentBasicDetail 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'Calypso -INVESTIMENTFINANCIALDETAIL' SourceSystem  
          FROM dwh_DWH_STG.InvestmentFinancialDetails 
         WHERE  dateofdata = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'Calypso -INVESTIMENTISSUERDETAIL' SourceSystem  
          FROM dwh_DWH_STG.InvestmentIssuerDetail 
         WHERE  date_of_data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'Calypso - Derivative' SourceSystem  
          FROM dwh_DWH_STG.Derivative_Cancelled 
         WHERE  dateofdata = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'GOLDMASTER' SourceSystem  
          FROM dwh_DWH_STG.MIFINGOLDMASTER 
         WHERE  dateofdata = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'EIFS ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.Account_data_EIFS 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'EIFS CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.Customer_data_EIFS 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'METAGRID ACCOUNTS' SourceSystem  
          FROM dwh_DWH_STG.account_data_metagrid 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'METAGRID CUSTOMERS' SourceSystem  
          FROM dwh_DWH_STG.customer_data_metagrid 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'METAGRID SECURITY' SourceSystem  
          FROM dwh_DWH_STG.security_data_metagrid 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'Reversefeed Calypso' SourceSystem  
          FROM dwh_DWH_STG.reversefeed_calypso 
         WHERE  Date_of_Data = v_Date
        UNION 
        SELECT DISTINCT COUNT(1)  ,
                        'SCF BILL' SourceSystem  
          FROM dwh_DWH_STG.Bills_data_STG_SCF 
         WHERE  Date_of_Data = v_Date
          ORDER BY SourceCount;
      SELECT COUNT(1)  

        INTO v_Count
        FROM dwh_DWH_STG.MIFINGOLDMASTER ;
      IF v_Count = 0 THEN

      BEGIN
         --Declare @Date date = cast(getdate()-1 as date)  
         INSERT INTO dwh_DWH_STG.MIFINGOLDMASTER
           ( DateofData, CaratMarket, Rate )
           ( SELECT v_Date ,
                    CaratMarket ,
                    Rate 
             FROM dwh_DWH_STG.MIFINGOLDMASTER_Backup 
              WHERE  DateofData = UTILS.CONVERT_TO_VARCHAR2(SYSDATE - 2,200) );
         OPEN  v_cursor FOR
            SELECT 'Data has been successfully inserted into [DWH_STG].dwh.MIFINGOLDMASTER Table' 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --SELECT * FROM [DWH_STG]..dwhControlTable  
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE ( SELECT DISTINCT 1 
                  FROM DWH_STG.dwhControlTable 
                   WHERE  SourceCount = 0
                            AND SourceSystem != 'Calypso - Derivative' ) = 1;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         utils.raiserror( 0, 'Source Count Is zero' );

      END;
      ELSE

      BEGIN
         EXECUTE IMMEDIATE ' TRUNCATE TABLE ControlTable_DWHCount ';
         INSERT INTO ControlTable_DWHCount
           VALUES ( v_Date, 'Y' );--select a.SourceSystem as [SourceSystem-DWH],  
         --a.SourceCount as [SourceCount-DWH],  
         --b.SourceSystem as [SourceSystem-Crismac ENPA],  
         --b.SourceCount as [SourceCount-Crismac ENPA],  
         --a.SourceCount-b.SourceCount [Difference]  
         --from    DWH_Count_status a  
         --inner join    [DWH_STG]..dwhControlTable b  
         --on            a.SourceSystem=b.SourceSystem  
         --where         a.DateOfdate=@Date  
         --ORDER BY [Difference] DESC  
         --Exec [dbo].[DWHCountChecker]  
         --Exec [dbo].[dwhcount_datewise]  
         --Declare @Date date = (select distinct Date_of_data from [DWH_STG].dwh.account_data_finacle)  
         --truncate table [DWH_STG].dbo.dwhControlTable  
         --INSERT into [DWH_STG].dbo.dwhControlTable   
         --select distinct count(1)SourceCount,'FINACLE CUSTOMERS'SourceSystem   
         -- from [DWH_STG].dwh.customer_data_finacle  
         --UNION  
         --select distinct count(1)SourceCount,'INDUS CUSTOMERS'SourceSystem from [DWH_STG].dwh.customer_data  
         --UNION  
         --select distinct count(1),'VISIONPLUS CUSTOMERS' from [DWH_STG].dwh.customer_data_visionplus  
         --UNION  
         --select distinct count(1),'ECBF CUSTOMERS' from [DWH_STG].dwh.customer_data_ecbf  
         --UNION  
         --select distinct count(1),'GANASEVA CUSTOMERS' from [DWH_STG].dwh.customer_data_ganaseva  
         --UNION  
         --select distinct count(1),'MIFIN CUSTOMERS' from [DWH_STG].dwh.customer_data_mifin  
         --UNION  
         --select distinct count(1),'FINACLE ACCOUNTS' from [DWH_STG].dwh.account_data_finacle  
         --UNION  
         --select distinct count(1),'INDUS ACCOUNTS' from [DWH_STG].dwh.accounts_data  
         --UNION  
         --select distinct count(1),'VISIONPLUS ACCOUNTS' from [DWH_STG].dwh.account_data_visionplus  
         --UNION  
         --select distinct count(1),'ECBF ACCOUNTS' from [DWH_STG].dwh.accounts_data_ecbf  
         --UNION  
         --select distinct count(1),'GANASEVA ACCOUNTS' from [DWH_STG].dwh.account_data_ganaseva  
         ----select distinct count(1)'MIFIN CUSTOMER' from [DWH_STG].dwh.accounts_data_mifin  
         --UNION  
         --select distinct count(1),'MIFIN ACCOUNTS' from [DWH_STG].dwh.accounts_data_mifin  
         --UNION  
         --select distinct COUNT(1),'FINACLE SECURITY' FROM [DWH_STG].DWH.collateral_type_master_finacle  
         --UNION  
         --select distinct COUNT(1),'ECBF SECURITY' FROM [DWH_STG].DWH.security_data_ecbf  
         --UNION  
         --select distinct COUNT(1),'INDUS SECURITY' FROM [DWH_STG].DWH.SECURITY_SOURCESYSTEM02  
         --UNION  
         --select distinct COUNT(1),'MIFIN SECURITY' FROM [DWH_STG].DWH.SECURITY_SOURCESYSTEM04  
         --UNION  
         --select distinct COUNT(1),'FINACLE TRANSACTION' FROM [DWH_STG].DWH.transaction_data_finacle  
         --UNION  
         --select distinct COUNT(1),'FINACLE BILL' FROM [DWH_STG].DWH.bills_data_stg_fin  
         --UNION  
         --select distinct COUNT(1),'FINACLE PC' FROM [DWH_STG].DWH.pca_data  
         --UNION  
         --select distinct COUNT(1),'Calypso - INVESTIMENTBASICDETAIL'FROM [DWH_STG].dwh.InvestmentBasicDetail  
         --UNION  
         --select distinct COUNT(1),'Calypso -INVESTIMENTFINANCIALDETAIL'FROM [DWH_STG].dwh.InvestmentFinancialDetails  
         --UNION  
         --select distinct COUNT(1),'Calypso -INVESTIMENTISSUERDETAIL'FROM [DWH_STG].dwh.InvestmentIssuerDetail  
         --UNION  
         --select distinct COUNT(1),'Calypso - Derivative'FROM [DWH_STG].dwh.Derivative_Cancelled  
         --UNION  
         --select distinct COUNT(1),'GOLDMASTER'FROM [DWH_STG].dwh.MIFINGOLDMASTER  
         --ORDER BY SourceSystem  
         ----select  
         ----('Data Successful as on ' + CONVERT(varchar(20),@Date) ) [Status]  
         ----select * from dwhControlTable  
         --IF (select distinct 1 from [DWH_STG].dbo.dwhControlTable   
         --where SourceCount = 0 and SourceSystem != 'Calypso - Derivative') = 1   
         --BEGIN    
         --select ('FAILED') [Status]  
         --select STUFF( (select','+SourceSystem   
         --    from [DWH_STG].dbo.dwhControlTable t2  
         --    where t1.Sourcecount = t2.Sourcecount  
         --    and SourceCount = 0   
         --    and SourceSystem != 'Calypso - Derivative'  
         --    FOR XML path('')),1,1,'')  
         --as [Data Templates]   
         --from [DWH_STG].dbo.dwhControlTable t1  
         --where SourceCount = 0   
         --and SourceSystem != 'Calypso - Derivative'  
         --group by SourceCount  
         --select SourceSystem as [Data Templates],SourceCount as [Data Counts] from [DWH_STG].dbo.dwhControlTable   
         --END  
         --ELSE  
         --BEGIN   
         --select  
         --('SUCCESS') [Status]  
         --select '' as [Data Templates]   
         --select SourceSystem as [Data Templates],SourceCount as [Data Counts] from [DWH_STG].dbo.dwhControlTable  
         --END  

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_CHECKER_04122023" TO "ADF_CDR_RBL_STGDB";
