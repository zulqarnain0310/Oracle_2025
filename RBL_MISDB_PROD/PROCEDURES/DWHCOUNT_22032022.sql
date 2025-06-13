--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_22032022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_22032022" 
AS
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_of_data 
     FROM dwh_DWH_STG.account_data_finacle  );
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

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
     SELECT DISTINCT COUNT(1)  ,
                     'GANASEVA CUSTOMERS' 
       FROM dwh_DWH_STG.customer_data_ganaseva 
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
                     'GANASEVA ACCOUNTS' 
       FROM dwh_DWH_STG.account_data_ganaseva 
     UNION 

     --select distinct count(1)'MIFIN CUSTOMER' from [DWH_STG].dwh.accounts_data_mifin
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
       ORDER BY SourceSystem;
   --select
   --('Data Successful as on ' + CONVERT(varchar(20),@Date) ) [Status]
   --select * from dwhControlTable
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
      OPEN  v_cursor FOR
         SELECT SourceSystem Data_Templates  ,
                SourceCount Data_Counts  
           FROM DWH_STG.dwhControlTable  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_22032022" TO "ADF_CDR_RBL_STGDB";
