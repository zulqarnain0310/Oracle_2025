--------------------------------------------------------
--  DDL for Procedure DWHCOUNT_P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DWHCOUNT_P" 
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
                                  WHEN SourceSystem = 'EXT_D2k_CoBorrower' THEN 'Co Borrower'
                                  WHEN SourceSystem = 'EXT_D2k_WriteOffData' THEN 'WriteOffData'
                                  WHEN SourceSystem = 'EXT_D2k_WriteOffDataSCF' THEN 'WriteOffDataSCF'
                                  WHEN SourceSystem = 'EXT_D2k_CurrencyMaster' THEN 'CurrencyMaster'
             ELSE SourceSystem
                END);
      DELETE DWH_Count_status_Daily

       WHERE  SourceSystem LIKE '%EXT_%';
      EXECUTE IMMEDIATE ' TRUNCATE TABLE DWH_STG.dwhControlTable ';
      INSERT INTO DWH_STG.dwhControlTable
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
      SELECT COUNT(1)  

        INTO v_Count
        FROM dwh_DWH_STG.MIFINGOLDMASTER 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(DateofData,200) = v_Date;
      IF v_Count = 0 THEN

      BEGIN
         --------------------------------------------------------------------------------------
         -----------------------------------------------------------------------------------------
         --Declare @Date date = cast(getdate()-1 as date)  
         EXECUTE IMMEDIATE ' TRUNCATE TABLE dwh_DWH_STG.MIFINGOLDMASTER ';
         --insert into [DWH_STG].dwh.MIFINGOLDMASTER(DateofData,CaratMarket,Rate)  
         --select @Date,CaratMarket,Rate from [DWH_STG].dwh.MIFINGOLDMASTER_Backup  
         --where DateofData=cast(getdate()-2 as date)  
         DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_MIFINGOLDMASTER  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_MIFINGOLDMASTER;
         UTILS.IDENTITY_RESET('tt_MIFINGOLDMASTER');

         INSERT INTO tt_MIFINGOLDMASTER ( 
         	SELECT CaratMarket ,
                 MAX(DateofData)  DateofData  
         	  FROM dwh_DWH_STG.MIFINGOLDMASTER_Backup 
         	  GROUP BY CaratMarket );
         INSERT INTO dwh_DWH_STG.MIFINGOLDMASTER
           ( SELECT A.* 
             FROM dwh_DWH_STG.MIFINGOLDMASTER_Backup a
                    JOIN tt_MIFINGOLDMASTER b   ON a.CaratMarket = b.CaratMarket
                    AND a.DateofData = b.DateofData );
         OPEN  v_cursor FOR
            SELECT 'Data has been successfully inserted into [DWH_STG].dwh.MIFINGOLDMASTER Table' 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      -------------------------------1st SP END------------------------------------------ 
      --IF (select distinct 1 from [DWH_STG].dbo.dwhControlTable     
      --where SourceCount = 0 and 
      --SourceSystem not in ( 'Calypso - Derivative','WriteOffData','WriteOffDataSCF','CurrencyMaster')) = 1  
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE ( SELECT 1 
                  FROM DWH_STG.dwhControlTable A
                         JOIN DIMSOURCEDB B   ON A.SourceTableAlt_Key = B.SourceAlt_Key
                   WHERE  A.SourceCount = 0
                            AND B.Active_Inactive = 'Y'
                            AND A.SourceTableAlt_Key <> 100
                            AND b.EffectiveToTimeKey = 49999 ) = 1;
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
            SELECT ' ' Data_Templates  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT ' ' Data_Templates  ,
                   ' ' Data_Counts  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;

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
                     JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON b.SourceTableAlt_Key = C.SourceAlt_Key
                     AND C.EffectiveToTimeKey = 49999
             WHERE  a.DateOfdate = v_Date
                      AND C.Active_Inactive = 'Y'
                      AND v_Date BETWEEN c.StartDate AND c.EndDate
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DWHCOUNT_P" TO "ADF_CDR_RBL_STGDB";
