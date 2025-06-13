--------------------------------------------------------
--  DDL for Procedure DWHCOUNTCHECKE_P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" 
AS
   v_AsOnDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) Date_  
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --select @AsOnDate    
   v_Date VARCHAR2(200) := ( SELECT utils.dateadd('DAY', 1, v_AsOnDate) 
     FROM DUAL  );
   --IF (select distinct 1 from [dwh_stg]..dwhControlCountTable where CountStatus = 'False' AND SourceSystem != 'FINACLE TRANSACTION' and Diff >50 ) = 1     
   -- BEGIN      
   --RAISERROR('Variance Status get False',16,1);    
   -- END    
   --Else    
   --Begin    
   v_cursor SYS_REFCURSOR;

BEGIN

   --select @Date    
   --==================================================================================================================    
   --IF @Date<>(select distinct DateOfData from [dwh_stg]..dwhControlCountTable)    
   --Begin    
   --print 1    
   --Update [dwh_stg]..dwhControlCountTable    
   --set    PreviousSourceCount=SourceCount,DateOfData=@Date    
   --END    
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.SourceCount, v_Date
   FROM A ,dwh_stg.dwhControlCountTable A
          JOIN dwh_stg.dwhControlCountTable_Hist B   ON A.SourceSystem = B.SourceSystem 
    WHERE B.DateOfData = v_AsOnDate) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.PreviousSourceCount = src.SourceCount,
                                A.DateOfData = v_Date;
   DBMS_OUTPUT.PUT_LINE(2);
   IF utils.object_id('TEMPDB..tt_TEMP') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP ';
   END IF;
   DELETE FROM tt_TEMP;
   INSERT INTO tt_TEMP
     ( SourceCount, SourceSystem, SourceTableAlt_Key )
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'FINACLE CUSTOMERS' SourceSystem  ,
                     1 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'INDUS CUSTOMERS' SourceSystem  ,
                     2 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'VISIONPLUS CUSTOMERS' ,
                     6 
       FROM dwh_DWH_STG.customer_data_visionplus 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF CUSTOMERS' ,
                     3 
       FROM dwh_DWH_STG.customer_data_ecbf 
     UNION 

     --select distinct count(1),'GANASEVA CUSTOMERS' from [DWH_STG].dwh.customer_data_ganaseva    
     SELECT DISTINCT COUNT(1)  ,
                     'FIS CUSTOMERS' ,
                     5 
       FROM dwh_DWH_STG.customer_data_fis 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN CUSTOMERS' ,
                     4 
       FROM dwh_DWH_STG.customer_data_mifin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE ACCOUNTS' ,
                     1 
       FROM dwh_DWH_STG.account_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'INDUS ACCOUNTS' ,
                     2 
       FROM dwh_DWH_STG.accounts_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'VISIONPLUS ACCOUNTS' ,
                     6 
       FROM dwh_DWH_STG.account_data_visionplus 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF ACCOUNTS' ,
                     3 
       FROM dwh_DWH_STG.accounts_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS ACCOUNTS' ,
                     5 
       FROM dwh_DWH_STG.account_data_fis 
     UNION 

     --select distinct count(1),'GANASEVA ACCOUNTS' from [DWH_STG].dwh.account_data_ganaseva       
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN ACCOUNTS' ,
                     4 
       FROM dwh_DWH_STG.accounts_data_mifin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE SECURITY' ,
                     1 
       FROM DWH_DWH_STG.collateral_type_master_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF SECURITY' ,
                     3 
       FROM DWH_DWH_STG.security_data_ecbf 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'INDUS SECURITY' ,
                     2 
       FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM02 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'MIFIN SECURITY' ,
                     4 
       FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM04 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE TRANSACTION' ,
                     1 
       FROM DWH_DWH_STG.transaction_data_finacle 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE BILL' ,
                     1 
       FROM DWH_DWH_STG.bills_data_stg_fin 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FINACLE PC' ,
                     1 
       FROM DWH_DWH_STG.pca_data 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso - INVESTIMENTBASICDETAIL' ,
                     7 
       FROM dwh_DWH_STG.InvestmentBasicDetail 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso -INVESTIMENTFINANCIALDETAIL' ,
                     7 
       FROM dwh_DWH_STG.InvestmentFinancialDetails 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso -INVESTIMENTISSUERDETAIL' ,
                     7 
       FROM dwh_DWH_STG.InvestmentIssuerDetail 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Calypso - Derivative' ,
                     7 
       FROM dwh_DWH_STG.Derivative_Cancelled 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'GOLDMASTER' ,
                     100 
       FROM dwh_DWH_STG.MIFINGOLDMASTER 
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS ACCOUNTS' SourceSystem  ,
                     11 
       FROM dwh_DWH_STG.Account_data_EIFS 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS CUSTOMERS' SourceSystem  ,
                     11 
       FROM dwh_DWH_STG.Customer_data_EIFS 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'METAGRID ACCOUNTS' SourceSystem  ,
                     8 
       FROM dwh_DWH_STG.account_data_metagrid 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'METAGRID CUSTOMERS' SourceSystem  ,
                     8 
       FROM dwh_DWH_STG.customer_data_metagrid 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'METAGRID SECURITY' SourceSystem  ,
                     8 
       FROM dwh_DWH_STG.security_data_metagrid 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Reversefeed Calypso' ,
                     7 SourceSystem  
       FROM dwh_DWH_STG.reversefeed_calypso 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'SCF BILL' SourceSystem  ,
                     9 
       FROM dwh_DWH_STG.Bills_data_STG_SCF 
      WHERE  Date_of_Data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Co Borrower' SourceSystem  ,
                     100 
       FROM dwh_DWH_STG.CoborrowerData 
      WHERE  DateofData = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'WriteOffData' SourceSystem  ,
                     100 
       FROM dwh_DWH_STG.WriteOffData 
      WHERE  ReportData = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'WriteOffDataSCF' SourceSystem  ,
                     9 
       FROM dwh_DWH_STG.WriteOffData_SCF 
      WHERE  ReportData = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'CurrencyMaster' SourceSystem  ,
                     100 
       FROM dwh_DWH_STG.Currency_Rate_master 
      WHERE  rate_date = v_Date
       ORDER BY SourceSystem;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.SourceCount
   FROM A ,dwh_stg.dwhControlCountTable a
          JOIN tt_TEMP b   ON a.SourceSystem = b.SourceSystem ) src
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
   OPEN  v_cursor FOR
      SELECT A.SourceSystem ,
             A.SourceCount ,
             PreviousSourceCount Previous_Day_Count  ,
             LessThanSourceCount A2_Less_Previous_Day  ,
             GreaterThanSourceCount A2_Greater_–_Previous_Day  ,
             CountStatus ,
             UTILS.CONVERT_TO_VARCHAR2(DateOfData,20,p_style=>105) DateOfData  ,
             Diff Diff_CD_PD_  
        FROM dwh_stg.dwhControlCountTable a
               JOIN tt_TEMP b   ON a.SourceSystem = b.SourceSystem
               JOIN RBL_MISDB_PROD.DIMSOURCEDB c   ON b.SourceTableAlt_Key = c.SourceAlt_Key
               AND c.EffectiveToTimeKey = 49999
       WHERE  c.Active_Inactive = 'Y'
                AND v_Date BETWEEN c.StartDate AND c.EndDate
        ORDER BY CountStatus,
                 CASE 
                      WHEN diff < 0 THEN diff * (-1)
                 ELSE diff
                    END DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNTCHECKE_P" TO "ADF_CDR_RBL_STGDB";
