--------------------------------------------------------
--  DDL for Procedure DWHCOUNTCHECKER_03072024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" 
AS
   --Declare @Date date = (select distinct Date_of_data from [dwh_stg].dwh.account_data_finacle)    
   --Declare @Date date = (select cast(getdate()-2 as date))    
   v_AsOnDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) Date_  
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --select @AsOnDate    
   v_Date VARCHAR2(200) := ( SELECT utils.dateadd('DAY', 1, v_AsOnDate) 
     FROM DUAL  );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --select @Date    
   ---------------------------------------------    
   --Declare @AsOnDate date =(select cast(date as date)Date from Automate_Advances where EXT_FLG='Y')    
   --Declare @AsOnDate date =(select distinct date_of_data from DWH_STG.dwh.account_data_finacle)    
   ----select @AsOnDate    
   ----Declare @Date date=(select dateadd(Day,1,@AsOnDate))    
   --Declare @Date date='2022-06-12'    
   --------------------------------    
   --==================================================================================================================    
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE v_Date <> ( SELECT DISTINCT DateOfData 
                         FROM dwh_stg.dwhControlCountTable  );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      UPDATE dwh_stg.dwhControlCountTable
         SET PreviousSourceCount = SourceCount,
             DateOfData = v_Date;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(2);
   IF utils.object_id('TEMPDB..tt_TEMP_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_3 ';
   END IF;
   DELETE FROM tt_TEMP_3;
   INSERT INTO tt_TEMP_3
     ( SourceCount, SourceSystem )
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'FINACLE CUSTOMER' SourceSystem  
       FROM dwh_dwh_stg.customer_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'INDUS CUSTOMER' SourceSystem  
       FROM dwh_dwh_stg.customer_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'VISIONPLUS CUSTOMER' 
       FROM dwh_dwh_stg.customer_data_visionplus 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF CUSTOMER' 
       FROM dwh_dwh_stg.customer_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS CUSTOMER' 
       FROM dwh_dwh_stg.customer_data_FIS 
     UNION 

     --select distinct count(1),'GANASEVA CUSTOMER' from [dwh_stg].dwh.customer_data_ganaseva    
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN CUSTOMER' 
       FROM dwh_dwh_stg.customer_data_mifin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE ACCOUNT' 
       FROM dwh_dwh_stg.account_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'INDUS ACCOUNT' 
       FROM dwh_dwh_stg.accounts_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'VISIONPLUS ACCOUNT' 
       FROM dwh_dwh_stg.account_data_visionplus 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF ACCOUNT' 
       FROM dwh_dwh_stg.accounts_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS ACCOUNT' 
       FROM dwh_dwh_stg.account_data_FIS 
     UNION 

     --select distinct count(1),'GANASEVA ACCOUNT' from [dwh_stg].dwh.account_data_ganaseva    

     --select distinct count(1)'MIFIN CUSTOMER' from dwh.accounts_data_mifin    
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN ACCOUNT' 
       FROM dwh_dwh_stg.accounts_data_mifin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE SECURITY' 
       FROM DWH_dwh_stg.collateral_type_master_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF SECURITY' 
       FROM DWH_dwh_stg.security_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'INDUS SECURITY' 
       FROM DWH_dwh_stg.SECURITY_SOURCESYSTEM02 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN SECURITY' 
       FROM DWH_dwh_stg.SECURITY_SOURCESYSTEM04 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE TRANSACTION' 
       FROM DWH_dwh_stg.transaction_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE BILL' 
       FROM DWH_dwh_stg.bills_data_stg_fin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE PC' 
       FROM DWH_dwh_stg.pca_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso - INVESTIMENTBASICDETAIL' 
       FROM dwh_dwh_stg.InvestmentBasicDetail 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso -INVESTIMENTFINANCIALDETAIL' 
       FROM dwh_dwh_stg.InvestmentFinancialDetails 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso -INVESTIMENTISSUERDETAIL' 
       FROM dwh_dwh_stg.InvestmentIssuerDetail 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso - Derivative' 
       FROM dwh_dwh_stg.Derivative_Cancelled 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'GOLDMASTER' 
       FROM dwh_dwh_stg.MIFINGOLDMASTER 
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
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.SourceCount
   FROM A ,dwh_stg.dwhControlCountTable a
          JOIN tt_TEMP_3 b   ON a.SourceSystem = b.SourceSystem ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SourceCount = src.SourceCount;
   --==================================================================================================================    
   --select ((PreviousSourceCount * 5)/100) from dwhControlCountTable    
   --where SourceSystem='ECBF ACCOUNT'    
   UPDATE dwh_stg.dwhControlCountTable
      SET LessThanSourceCount = PreviousSourceCount - ((PreviousSourceCount * 2) / 100),
          GreaterThanSourceCount = PreviousSourceCount + ((PreviousSourceCount * 2) / 100),
          diff = SourceCount - PreviousSourceCount;
   --where SourceSystem='ECBF ACCOUNT'    
   UPDATE dwh_stg.dwhControlCountTable
      SET CountStatus = CASE 
                             WHEN SourceCount BETWEEN LessThanSourceCount AND GreaterThanSourceCount THEN 'True'
          ELSE 'False'
             END;
   DELETE dwh_stg.dwhControlCountTable_Hist

    WHERE  DateOfData = v_Date;
   INSERT INTO dwh_stg.dwhControlCountTable_Hist
     ( SELECT * 
       FROM dwh_stg.dwhControlCountTable  );
   --IF (select distinct 1 from [dwh_stg]..dwhControlCountTable where CountStatus = 'False' AND SourceSystem != 'FINACLE TRANSACTION' and Diff >50 ) = 1     
   -- BEGIN      
   --RAISERROR('Variance Status get False',16,1);    
   -- END    
   --Else    
   --Begin    
   OPEN  v_cursor FOR
      SELECT SourceSystem ,
             SourceCount ,
             PreviousSourceCount Previous_Day_Count  ,
             LessThanSourceCount A2_Less_Previous_Day  ,
             GreaterThanSourceCount A2_Greater_–_Previous_Day  ,
             CountStatus ,
             UTILS.CONVERT_TO_VARCHAR2(DateOfData,20,p_style=>105) DateOfData  ,
             Diff Diff_CD_PD_  
        FROM dwh_stg.dwhControlCountTable 
        ORDER BY CountStatus,
                 CASE 
                      WHEN diff < 0 THEN diff * (-1)
                 ELSE diff
                    END DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--END    
   /*    
   --order by CountStatus,diff desc    

   --select    
   --('Data Successful as on ' + CONVERT(varchar(20),@Date) ) [Status]    
   --select * from dwhControlTable    

   --IF (select 1 from dwhControlTable where SourceCount = 0 and SourceSystem != 'Calypso - Derivative') = 1     
   --BEGIN      
   --select ('Data has not processed successfully as on ' + CONVERT(varchar(20),@Date) ) [Status]    
   --select * from dwhControlTable     
   --END    
   --ELSE    
   --BEGIN select    
   --('Data Successful as on ' + CONVERT(varchar(20),@Date) ) [Status]    
   --select * from dwhControlTable    
   --END    

   */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKER_03072024" TO "ADF_CDR_RBL_STGDB";
