--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_DATEWISE_P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" 
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
     SELECT DISTINCT COUNT(1)  SourceCount  ,
                     'Finacle Interest Date Count' SourceSystem  ,
                     1 SourceTableAlt_Key  
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Finacle Interest Amount Count' SourceSystem  ,
                     1 
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Finacle Principal Date Count' SourceSystem  ,
                     1 
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Finacle Principal Amount Count' SourceSystem  ,
                     1 
       FROM dwh_dwh_stg.account_data_finacle 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------FIS-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Interest Date Count' SourceSystem  ,
                     5 
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Interest Amount Count' SourceSystem  ,
                     5 
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Principal Date Count' SourceSystem  ,
                     5 
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'FIS Principal Amount Count' SourceSystem  ,
                     5 
       FROM dwh_dwh_stg.account_data_fis 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------Indus-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Interest Date Count' SourceSystem  ,
                     2 
       FROM dwh_dwh_stg.accounts_data 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Interest Amount Count' SourceSystem  ,
                     2 
       FROM dwh_dwh_stg.accounts_data 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Principal Date Count' SourceSystem  ,
                     2 
       FROM dwh_dwh_stg.accounts_data 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Indus Principal Amount Count' SourceSystem  ,
                     2 
       FROM dwh_dwh_stg.accounts_data 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------Mifin-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Interest Date Count' SourceSystem  ,
                     4 
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  Int_due_from_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Interest Amount Count' SourceSystem  ,
                     4 
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Principal Date Count' SourceSystem  ,
                     4 
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'Mifin Principal Amount Count' SourceSystem  ,
                     4 
       FROM dwh_dwh_stg.accounts_data_mifin 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------VISIONPLUS-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'VisionPlus Principal Amount Count' SourceSystem  ,
                     6 
       FROM dwh_dwh_stg.account_data_visionplus 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------ECBF-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF Interest Amount Count' SourceSystem  ,
                     3 
       FROM dwh_dwh_stg.accounts_data_ecbf 
      WHERE  ( Interest_Overdue_Amt IS NOT NULL
               OR Interest_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF Principal Date Count' SourceSystem  ,
                     3 
       FROM dwh_dwh_stg.accounts_data_ecbf 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'ECBF Principal Amount Count' SourceSystem  ,
                     3 
       FROM dwh_dwh_stg.accounts_data_ecbf 
      WHERE  ( Principal_Overdue_Amt IS NOT NULL
               OR Principal_Overdue_Amt <> 0 )
               AND date_of_data = v_Date
     UNION 

     ------------------------------EIFS-----------------------------------------------------  
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Interest Amount Count' SourceSystem  ,
                     11 
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Interest_Over_Due_Since_Dt IS NOT NULL
               AND NVL(Interest_Overdue_Amt, 0) = 0
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Interest Date Count' SourceSystem  ,
                     11 
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Interest_Over_Due_Since_Dt IS NULL
               AND NVL(Interest_Overdue_Amt, 0) > 0
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Principal Amount Count' SourceSystem  ,
                     11 
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Principal_Over_Due_Since_Dt IS NOT NULL
               AND NVL(Principal_Overdue_Amt, 0) = 0
               AND date_of_data = v_Date
     UNION 
     SELECT DISTINCT COUNT(1)  ,
                     'EIFS Principal Date Count' SourceSystem  ,
                     11 
       FROM dwh_dwh_stg.Account_data_EIFS 
      WHERE  Principal_Over_Due_Since_Dt IS NULL
               AND NVL(Principal_Overdue_Amt, 0) > 0
               AND date_of_data = v_Date
       ORDER BY SourceCount;
   --select @Date  
   EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_stg.dwhControlTable_1_Hist ';
   INSERT INTO dwh_stg.dwhControlTable_1_Hist
     ( SourceCount, SourceSystem, DateofData, SourceTableAlt_Key )
     ( SELECT SourceCount ,
              SourceSystem ,
              v_Date ,
              SourceTableAlt_Key 
       FROM dwh_stg.dwhControlTable_1  );
   OPEN  v_cursor FOR
      SELECT SourceSystem ,
             CASE 
                  WHEN SourceCount = 0 THEN 'FALSE'
             ELSE 'True'
                END SourceStatus  
        FROM dwh_stg.dwhControlTable_1 a
               JOIN RBL_MISDB_PROD.DIMSOURCEDB b   ON A.SourceTableAlt_Key = b.SourceAlt_Key
               AND b.EffectiveToTimeKey = 49999
       WHERE  SourceSystem NOT LIKE '%EIFS%'
                AND b.Active_Inactive = 'Y'
                AND v_Date BETWEEN b.startdate AND b.enddate
      UNION 
      SELECT SourceSystem ,
             CASE 
                  WHEN SourceCount = 0 THEN 'True'
             ELSE 'FALSE'
                END SourceStatus  
        FROM dwh_stg.dwhControlTable_1 a
               JOIN RBL_MISDB_PROD.DIMSOURCEDB b   ON A.SourceTableAlt_Key = b.SourceAlt_Key
               AND b.EffectiveToTimeKey = 49999
       WHERE  SourceSystem LIKE '%EIFS%'
                AND b.Active_Inactive = 'Y'
                AND v_Date BETWEEN b.startdate AND b.enddate
        ORDER BY SourceStatus,
                 SourceSystem ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_DATEWISE_P" TO "ADF_CDR_RBL_STGDB";
