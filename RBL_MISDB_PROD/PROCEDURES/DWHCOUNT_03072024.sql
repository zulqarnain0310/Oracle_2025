--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_03072024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_03072024" 
AS
   --Declare @Date date = (select distinct Date_of_data from [DWH_STG].dwh.account_data_finacle)    
   v_AsOnDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) Date_  
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   ----select @AsOnDate    
   v_Date VARCHAR2(200) := ( SELECT utils.dateadd('DAY', 1, v_AsOnDate) 
     FROM DUAL  );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --select @Date    
   ---------------------------------------------------    
   --Declare @AsOnDate date =(select cast(date as date)Date from Automate_Advances where EXT_FLG='Y')    
   --Declare @AsOnDate date =(select distinct date_of_data from DWH_STG.dwh.account_data_finacle)    
   ----select @AsOnDate    
   ----Declare @Date date=(select dateadd(Day,1,@AsOnDate))    
   --Declare @Date date='2022-06-12'    
   ----------------------------    
   EXECUTE IMMEDIATE ' TRUNCATE TABLE DWH_STG.dwhControlTable ';
   INSERT INTO DWH_STG.dwhControlTable
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'FINACLE CUSTOMERS' SourceSystem  
       FROM dwh_DWH_STG.customer_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'INDUS CUSTOMERS' SourceSystem  
       FROM dwh_DWH_STG.customer_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'VISIONPLUS CUSTOMERS' 
       FROM dwh_DWH_STG.customer_data_visionplus 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF CUSTOMERS' 
       FROM dwh_DWH_STG.customer_data_ecbf 
     UNION 

     --select distinct count(1),'GANASEVA CUSTOMERS' from [DWH_STG].dwh.customer_data_ganaseva    
     SELECT DISTINCT COUNT(1)  ,
                     'FIS CUSTOMERS' 
       FROM dwh_DWH_STG.customer_data_fis 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN CUSTOMERS' 
       FROM dwh_DWH_STG.customer_data_mifin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE ACCOUNTS' 
       FROM dwh_DWH_STG.account_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'INDUS ACCOUNTS' 
       FROM dwh_DWH_STG.accounts_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'VISIONPLUS ACCOUNTS' 
       FROM dwh_DWH_STG.account_data_visionplus 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF ACCOUNTS' 
       FROM dwh_DWH_STG.accounts_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS ACCOUNTS' 
       FROM dwh_DWH_STG.account_data_fis 
     UNION 

     --select distinct count(1),'GANASEVA ACCOUNTS' from [DWH_STG].dwh.account_data_ganaseva       
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN ACCOUNTS' 
       FROM dwh_DWH_STG.accounts_data_mifin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE SECURITY' 
       FROM DWH_DWH_STG.collateral_type_master_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF SECURITY' 
       FROM DWH_DWH_STG.security_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'INDUS SECURITY' 
       FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM02 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN SECURITY' 
       FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM04 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE TRANSACTION' 
       FROM DWH_DWH_STG.transaction_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE BILL' 
       FROM DWH_DWH_STG.bills_data_stg_fin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE PC' 
       FROM DWH_DWH_STG.pca_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso - INVESTIMENTBASICDETAIL' 
       FROM dwh_DWH_STG.InvestmentBasicDetail 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso -INVESTIMENTFINANCIALDETAIL' 
       FROM dwh_DWH_STG.InvestmentFinancialDetails 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso -INVESTIMENTISSUERDETAIL' 
       FROM dwh_DWH_STG.InvestmentIssuerDetail 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso - Derivative' 
       FROM dwh_DWH_STG.Derivative_Cancelled 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'GOLDMASTER' 
       FROM dwh_DWH_STG.MIFINGOLDMASTER 
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
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Co Borrower' SourceSystem  
       FROM dwh_DWH_STG.CoborrowerData 
      WHERE  DateofData = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'WriteOffData' SourceSystem  
       FROM dwh_DWH_STG.WriteOffData 
      WHERE  ReportData = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'WriteOffDataSCF' SourceSystem  
       FROM dwh_DWH_STG.WriteOffData_SCF 
      WHERE  ReportData = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'CurrencyMaster' SourceSystem  
       FROM dwh_DWH_STG.Currency_Rate_master 
      WHERE  rate_date = v_Date
       ORDER BY SourceSystem;
   --select    
   --('Data Successful as on ' + CONVERT(varchar(20),@Date) ) [Status]    
   --select * from dwhControlTable    
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(1)  
               FROM ControlTable_DWHCount 
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
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE ( SELECT DISTINCT 1 
                  FROM DWH_STG.dwhControlTable 
                   WHERE  SourceCount = 0
                            AND SourceSystem NOT IN ( 'Calypso - Derivative','WriteOffData','WriteOffDataSCF','CurrencyMaster' )
       ) = 1;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT ('FAILED') Status  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT utils.stuff(( SELECT ',' || SourceSystem 
                                 FROM DWH_STG.dwhControlTable t2
                                  WHERE  t1.Sourcecount = t2.Sourcecount
                                           AND SourceCount = 0
                                           AND SourceSystem != 'Calypso - Derivative' ), 1, 1, ' ') Data_Templates  
              FROM DWH_STG.dwhControlTable t1
             WHERE  SourceCount = 0
                      AND SourceSystem != 'Calypso - Derivative'
              GROUP BY SourceCount ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT SourceSystem Data_Templates  ,
                   SourceCount Data_Counts  
              FROM DWH_STG.dwhControlTable  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT ('SUCCESS') Status  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT ' ' Data_Templates  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         --select SourceSystem as [Data Templates],SourceCount as [Data Counts] from [DWH_STG].dbo.dwhControlTable    
         OPEN  v_cursor FOR
            SELECT a.SourceSystem SourceSystem_DWH  ,
                   a.SourceCount SourceCount_DWH  ,
                   b.SourceSystem SourceSystem_Crismac_ENPA  ,
                   b.SourceCount SourceCount_Crismac_ENPA  ,
                   a.SourceCount - b.SourceCount Difference  
              FROM DWH_Count_status_Daily a
                     JOIN DWH_STG.dwhControlTable b   ON a.SourceSystem = b.SourceSystem
             WHERE  a.DateOfdate = v_Date
              ORDER BY "Difference" DESC ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RBL_MISDB_PROD.DWHCountChecker() ;
         RBL_MISDB_PROD.dwhcount_datewise() ;
         RBL_MISDB_PROD.Condition_Check_mismatches() ;
         RBL_MISDB_PROD.Condition_Check_mismatches_BranchCode() ;
         RBL_MISDB_PROD.Ucic_Mismatch_Check_Conditions() ;

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_03072024" TO "ADF_CDR_RBL_STGDB";
