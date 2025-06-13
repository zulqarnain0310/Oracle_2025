--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_07062022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_07062022" 
AS
   --Declare @Date date = (select distinct Date_of_data from [DWH_STG].dwh.account_data_finacle)
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
   /*
   truncate table [DWH_STG].dbo.dwhControlTable

   INSERT into [DWH_STG].dbo.dwhControlTable 

   select distinct count(1)SourceCount,'FINACLE CUSTOMERS'SourceSystem 
    from [DWH_STG].dwh.customer_data_finacle
   UNION
   select distinct count(1)SourceCount,'INDUS CUSTOMERS'SourceSystem from [DWH_STG].dwh.customer_data
   UNION
   select distinct count(1),'VISIONPLUS CUSTOMERS' from [DWH_STG].dwh.customer_data_visionplus
   UNION
   select distinct count(1),'ECBF CUSTOMERS' from [DWH_STG].dwh.customer_data_ecbf
   UNION
   select distinct count(1),'GANASEVA CUSTOMERS' from [DWH_STG].dwh.customer_data_ganaseva
   UNION
   select distinct count(1),'MIFIN CUSTOMERS' from [DWH_STG].dwh.customer_data_mifin
   UNION
   select distinct count(1),'FINACLE ACCOUNTS' from [DWH_STG].dwh.account_data_finacle
   UNION
   select distinct count(1),'INDUS ACCOUNTS' from [DWH_STG].dwh.accounts_data
   UNION
   select distinct count(1),'VISIONPLUS ACCOUNTS' from [DWH_STG].dwh.account_data_visionplus
   UNION
   select distinct count(1),'ECBF ACCOUNTS' from [DWH_STG].dwh.accounts_data_ecbf
   UNION
   select distinct count(1),'GANASEVA ACCOUNTS' from [DWH_STG].dwh.account_data_ganaseva
   --select distinct count(1)'MIFIN CUSTOMER' from [DWH_STG].dwh.accounts_data_mifin
   UNION
   select distinct count(1),'MIFIN ACCOUNTS' from [DWH_STG].dwh.accounts_data_mifin
   UNION
   select distinct COUNT(1),'FINACLE SECURITY' FROM [DWH_STG].DWH.collateral_type_master_finacle
   UNION
   select distinct COUNT(1),'ECBF SECURITY' FROM [DWH_STG].DWH.security_data_ecbf
   UNION
   select distinct COUNT(1),'INDUS SECURITY' FROM [DWH_STG].DWH.SECURITY_SOURCESYSTEM02
   UNION
   select distinct COUNT(1),'MIFIN SECURITY' FROM [DWH_STG].DWH.SECURITY_SOURCESYSTEM04
   UNION
   select distinct COUNT(1),'FINACLE TRANSACTION' FROM [DWH_STG].DWH.transaction_data_finacle
   UNION
   select distinct COUNT(1),'FINACLE BILL' FROM [DWH_STG].DWH.bills_data_stg_fin
   UNION
   select distinct COUNT(1),'FINACLE PC' FROM [DWH_STG].DWH.pca_data
   UNION
   select distinct COUNT(1),'Calypso - INVESTIMENTBASICDETAIL'FROM [DWH_STG].dwh.InvestmentBasicDetail
   UNION
   select distinct COUNT(1),'Calypso -INVESTIMENTFINANCIALDETAIL'FROM [DWH_STG].dwh.InvestmentFinancialDetails
   UNION
   select distinct COUNT(1),'Calypso -INVESTIMENTISSUERDETAIL'FROM [DWH_STG].dwh.InvestmentIssuerDetail
   UNION
   select distinct COUNT(1),'Calypso - Derivative'FROM [DWH_STG].dwh.Derivative_Cancelled
   UNION
   select distinct COUNT(1),'GOLDMASTER'FROM [DWH_STG].dwh.MIFINGOLDMASTER

   ORDER BY SourceSystem
   */
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_07062022" TO "ADF_CDR_RBL_STGDB";
