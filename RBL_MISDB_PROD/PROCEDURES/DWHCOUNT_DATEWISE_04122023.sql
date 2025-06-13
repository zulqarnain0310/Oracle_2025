--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_DATEWISE_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" 
AS
   --Declare @Date date = (select cast(getdate()-2 as date))  
   v_AsOnDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(date_,200) Date_  
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   --select @AsOnDate  
   v_Date VARCHAR2(200) := ( SELECT utils.dateadd('DAY', 1, v_AsOnDate) 
     FROM DUAL  );
   --order by SourceStatus,SourceSystem  
   v_cursor SYS_REFCURSOR;

BEGIN

   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_stg.dwhControlTable_1 ';
   INSERT INTO dwh_stg.dwhControlTable_1
      /*  
     select distinct count(1)SourceCount,'FINACLE CUSTOMER'SourceSystem   
      from [dwh_stg].dwh.customer_data_finacle where date_of_data=@Date  
     UNION  
     select distinct count(1)SourceCount,'INDUS CUSTOMER'SourceSystem from [dwh_stg].dwh.customer_data where date_of_data=@Date  
     UNION  
     select distinct count(1),'VISIONPLUS CUSTOMER' SourceSystem from [dwh_stg].dwh.customer_data_visionplus where date_of_data=@Date  
     UNION  
     select distinct count(1),'ECBF CUSTOMER' SourceSystem from [dwh_stg].dwh.customer_data_ecbf where date_of_data=@Date  
     UNION  
     select distinct count(1),'GANASEVA CUSTOMER' SourceSystem from [dwh_stg].dwh.customer_data_ganaseva where date_of_data=@Date  
     UNION  
     select distinct count(1),'MIFIN CUSTOMER' SourceSystem from [dwh_stg].dwh.customer_data_mifin where dateofdata=@Date  
     UNION  
     select distinct count(1),'FINACLE ACCOUNT' SourceSystem from [dwh_stg].dwh.account_data_finacle where date_of_data=@Date  
     UNION  
     select distinct count(1),'INDUS ACCOUNT' SourceSystem from [dwh_stg].dwh.accounts_data where date_of_data=@Date  
     UNION  
     select distinct count(1),'VISIONPLUS ACCOUNT'SourceSystem from [dwh_stg].dwh.account_data_visionplus where date_of_data=@Date  
     UNION  
     select distinct count(1),'ECBF ACCOUNT'SourceSystem from [dwh_stg].dwh.accounts_data_ecbf where date_of_data=@Date  
     UNION  
     select distinct count(1),'GANASEVA ACCOUNT'SourceSystem from [dwh_stg].dwh.account_data_ganaseva where date_of_data=@Date  
     --select distinct count(1)'MIFIN CUSTOMER' from dwh.accounts_data_mifin  
     UNION  
     select distinct count(1),'MIFIN ACCOUNT'SourceSystem from [dwh_stg].dwh.accounts_data_mifin where date_of_data=@Date  
     UNION  
     select distinct COUNT(1),'FINACLE SECURITY'SourceSystem FROM [dwh_stg].DWH.collateral_type_master_finacle where date_of_data=@Date  
     UNION  
     select distinct COUNT(1),'ECBF SECURITY'SourceSystem FROM [dwh_stg].DWH.security_data_ecbf where date_of_data=@Date  
     UNION  
     select distinct COUNT(1),'INDUS SECURITY'SourceSystem FROM [dwh_stg].DWH.SECURITY_SOURCESYSTEM02 where dateofdata=@Date  
     UNION  
     select distinct COUNT(1),'MIFIN SECURITY'SourceSystem FROM [dwh_stg].DWH.SECURITY_SOURCESYSTEM04 where dateofdata=@Date  
     UNION  
     select distinct COUNT(1),'FINACLE TRANSACTION'SourceSystem FROM [dwh_stg].DWH.transaction_data_finacle where date_of_data=@Date  
     UNION  
     select distinct COUNT(1),'FINACLE BILL'SourceSystem FROM [dwh_stg].DWH.bills_data_stg_fin where [Date of Data]=@Date  
     UNION  
     select distinct COUNT(1),'FINACLE PC'SourceSystem FROM [dwh_stg].DWH.pca_data where [Date of Data]=@Date  
     UNION  
     select distinct COUNT(1),'Calypso - INVESTIMENTBASICDETAIL'SourceSystem FROM [dwh_stg].dwh.InvestmentBasicDetail where date_of_data=@Date  
     UNION  
     select distinct COUNT(1),'Calypso -INVESTIMENTFINANCIALDETAIL'SourceSystem FROM [dwh_stg].dwh.InvestmentFinancialDetails where dateofdata=@Date  
     UNION  
     select distinct COUNT(1),'Calypso -INVESTIMENTISSUERDETAIL'SourceSystem FROM [dwh_stg].dwh.InvestmentIssuerDetail where date_of_data=@Date  
     UNION  
     select distinct COUNT(1),'Calypso - Derivative'SourceSystem FROM [dwh_stg].dwh.Derivative_Cancelled where dateofdata=@Date  
     UNION  
     select distinct COUNT(1),'GOLDMASTER'SourceSystem FROM [dwh_stg].dwh.MIFINGOLDMASTER where dateofdata=@Date  
     UNION */
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'Finacle Interest Date Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Finacle Interest Amount Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Finacle Principal Date Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Finacle Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     --------------------------------GANASEVA-----------------------------------------------------  

     --select distinct count(1),'GANASEVA Interest Date Count'SourceSystem from [dwh_stg].dwh.account_data_ganaseva  

     --where Interest_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'GANASEVA Interest Amount Count'SourceSystem from [dwh_stg].dwh.account_data_ganaseva  

     --where (Interest_Overdue_Amt is not null  or Interest_Overdue_Amt<>0 ) and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'GANASEVA Principal Date Count'SourceSystem from [dwh_stg].dwh.account_data_ganaseva  

     --where Principal_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'GANASEVA Principal Amount Count'SourceSystem from [dwh_stg].dwh.account_data_ganaseva  

     --where (Principal_Overdue_Amt is not null  or Principal_Overdue_Amt<>0 ) and date_of_data=@Date  

     --UNION  

     ------------------------------FIS-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Interest Date Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Interest Amount Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Principal Date Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------Indus-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Interest Date Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Interest Amount Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Principal Date Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------Mifin-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Interest Date Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  Int_due_from_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Interest Amount Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Principal Date Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------VISIONPLUS-----------------------------------------------------  

     --select distinct count(1),'VisionPlus Interest Date Count'SourceSystem from [dwh_stg].dwh.account_data_visionplus  

     --where Interest_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'VisionPlus Interest Amount Count'SourceSystem from [dwh_stg].dwh.account_data_visionplus  

     --where (Interest_Overdue_Amt is not null  or Interest_Overdue_Amt<>0 ) and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'VisionPlus Principal Date Count'SourceSystem from [dwh_stg].dwh.account_data_visionplus  

     --where Principal_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  
     SELECT DISTINCT COUNT(1)  ,
                     'VisionPlus Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.account_data_visionplus 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------ECBF-----------------------------------------------------  

     --select distinct count(1),'ECBF Interest Date Count'SourceSystem from [dwh_stg].dwh.accounts_data_ecbf  

     --where Interest_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF Interest Amount Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_ecbf 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF Principal Date Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_ecbf 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.accounts_data_ecbf 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------EIFS-----------------------------------------------------  

     --select distinct count(1),'ECBF Interest Date Count'SourceSystem from [dwh_stg].dwh.accounts_data_ecbf  

     --where Interest_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'EIFS Interest Amount Count'SourceSystem from [dwh_stg].dwh.Account_data_EIFS  

     --where (Interest_Overdue_Amt is not null  or Interest_Overdue_Amt<>0 ) and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'EIFS Interest Date Count'SourceSystem from [dwh_stg].dwh.Account_data_EIFS  

     --where Interest_Over_Due_Since_Dt is not null and date_of_data=@Date  

     --UNION  

     --select distinct count(1),'EIFS Principal Amount Count'SourceSystem from [dwh_stg].dwh.Account_data_EIFS  

     --where (Principal_Overdue_Amt is not null  or Principal_Overdue_Amt<>0 ) and date_of_data=@Date  
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Interest Amount Count' SourceSystem  
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND NVL(Interest_Overdue_Amt, 0) = 0
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Interest Date Count' SourceSystem  
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Interest_Over_Due_Since_Dt IS NULL
               AND NVL(Interest_Overdue_Amt, 0) > 0
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Principal Amount Count' SourceSystem  
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND NVL(Principal_Overdue_Amt, 0) = 0
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Principal Date Count' SourceSystem  
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Principal_Over_Due_Since_Dt IS NULL
               AND NVL(Principal_Overdue_Amt, 0) > 0
               AND date_of_data = v_Date
       ORDER BY SourceCount;
   --select @Date  
   ---------------------------------------------------  
   --Declare @AsOnDate date =(select distinct date_of_data from DWH_STG.dwh.account_data_finacle)  
   ----select @AsOnDate  
   ----Declare @Date date=(select dateadd(Day,1,@AsOnDate))  
   --Declare @Date date=@AsOnDate  
   ------------------------------------------------  
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_stg.dwhControlTable_1_Hist ';
   INSERT INTO dwh_stg.dwhControlTable_1_Hist
     ( SourceCount, SourceSystem, DateofData )
     ( SELECT SourceCount ,
              SourceSystem ,
              v_Date 
       FROM dwh_stg.dwhControlTable_1  );
   --select SourceSystem,CASE WHEN SourceCount=0 THEN 'FALSE' ELSE 'True' end SourceStatus from [dwh_stg]..dwhControlTable_1  
   --order by SourceStatus,SourceSystem  
   OPEN  v_cursor FOR
      SELECT SourceSystem ,
             CASE 
                  WHEN SourceCount = 0 THEN 'FALSE'
             ELSE 'True'
                END SourceStatus  
        FROM dwh_stg.dwhControlTable_1 
       WHERE  SourceSystem NOT LIKE '%EIFS%'
      UNION 
      SELECT SourceSystem ,
             CASE 
                  WHEN SourceCount = 0 THEN 'True'
             ELSE 'FALSE'
                END SourceStatus  
        FROM dwh_stg.dwhControlTable_1 
       WHERE  SourceSystem LIKE '%EIFS%'
        ORDER BY SourceStatus,
                 SourceSystem ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_04122023" TO "ADF_CDR_RBL_STGDB";
