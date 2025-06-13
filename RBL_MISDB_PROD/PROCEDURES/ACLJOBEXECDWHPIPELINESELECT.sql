--------------------------------------------------------
--  DDL for Procedure ACLJOBEXECDWHPIPELINESELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" 
-- ========================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<28/07/2023>
 -- DESCRIPTION:			<DWH PIPELINE DETAIL SELECT>
 -- =========================================================

AS
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('tempdb..GTT_TEMP_DWH') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP_DWH ';
   END IF;
   IF utils.object_id('tempdb..GTT_TEMP_DWH2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP_DWH2 ';
   END IF;
   DELETE FROM GTT_TEMP_DWH;
   UTILS.IDENTITY_RESET('GTT_TEMP_DWH');

   INSERT INTO GTT_TEMP_DWH ( 
   	SELECT 'Customer_data_finacle' DWHSourcesystems  ,
           date_of_data Date_of_data  
   	  FROM DWH_STG.customer_data_finacle 
   	UNION 
--   	SELECT 'Customer_data' ,
--           date_of_data 
--          FROM DWH_STG.customer_data 
--   	UNION 
   	SELECT 'Customer_data_visionplus' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.customer_data_visionplus 
   	UNION 
   	SELECT 'Customer_data_ecbf' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.customer_data_ecbf 
   	UNION 

   	--select 'Customer_data_ganaseva', CAST(date_of_data AS VARCHAR2(20)) from DWH_STG.DWH.customer_data_ganaseva with(nolock)

   	--union
--   	SELECT 'Customer_data_mifin' ,
--           (DateOfData) 
--   	  FROM DWH_STG.customer_data_mifin 
--   	UNION 
   	SELECT 'Account_data_finacle' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.account_data_finacle 
   	UNION 
--   	SELECT 'Accounts_data' ,
--           CAST(date_of_data AS VARCHAR2(20)) SourceSystem  
--   	  FROM DWH_STG.accounts_data 
--   	UNION 
   	SELECT 'Account_data_visionplus' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.account_data_visionplus 
   	UNION 
   	SELECT 'Accounts_data_ecbf' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.accounts_data_ecbf 
   	UNION 

   	--select 'Account_data_ganaseva', CAST(date_of_data AS VARCHAR2(20)) from DWH_STG.DWH.account_data_ganaseva with(nolock)

   	--union
--   	SELECT 'Accounts_data_mifin' ,
--           CAST(date_of_data AS VARCHAR2(20)) 
--   	  FROM DWH_STG.accounts_data_mifin 
--   	UNION 
   	SELECT 'Collateral_type_master_finacle' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.collateral_type_master_finacle 
   	UNION 
   	SELECT 'Security_data_ecbf' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.security_data_ecbf 
--   	UNION 
--   	SELECT 'SECURITY_SOURCESYSTEM02' ,
--           (DateofData) 
--   	  FROM DWH_STG.SECURITY_SOURCESYSTEM02 
--   	UNION 
--   	SELECT 'SECURITY_SOURCESYSTEM04' ,
--           (DateofData) 
--   	  FROM DWH_STG.SECURITY_SOURCESYSTEM04 
/*   	UNION 
   	SELECT 'Transaction_data_finacle' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.transaction_data_finacle 
--   	UNION 
--   	SELECT 'bills_data_stg_fin' ,
--           CAST(date_of_data AS VARCHAR2(20)) 
--   	  FROM DWH_STG.bills_data_stg_fin 
--   	UNION 
--   	SELECT 'Pca_data' ,
--           CAST(date_of_data AS VARCHAR2(20)) 
--   	  FROM DWH_STG.pca_data 
   	UNION 
   	SELECT 'InvestmentBasicDetail' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.InvestmentBasicDetail 
   	UNION 
   	SELECT 'InvestmentFinancialDetails' ,
           (DateofData) 
   	  FROM DWH_STG.InvestmentFinancialDetails 
   	UNION 
   	SELECT 'InvestmentIssuerDetail' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.InvestmentIssuerDetail 
   	UNION 
   	SELECT 'Derivative_Cancelled' ,
           (Dateofdata) 
   	  FROM DWH_STG.Derivative_Cancelled 
   	UNION 
   	SELECT 'MIFINGOLDMASTER' ,
           (DateofData) 
   	  FROM DWH_STG.MIFINGOLDMASTER 
   	UNION 
   	SELECT 'Customer_data_fis' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.customer_data_fis 
   	UNION 
   	SELECT 'Account_data_fis' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.account_data_fis 
   	UNION 
   	SELECT 'Metagrid_account' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.account_data_metagrid 
   	UNION 
   	SELECT 'Metagrid_customer' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.customer_data_metagrid 
   	UNION 
   	SELECT 'Metagrid_security' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.security_data_metagrid 
   	UNION 
   	SELECT 'EIFS_customer' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.customer_data_eifs 
   	UNION 
   	SELECT 'EIFS_account' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.account_data_eifs 
   	UNION 
   	SELECT 'SCF_bills' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.bills_data_stg_scf 
   	UNION 
   	SELECT 'Reversefeed_calypso_Backup' ,
           CAST(date_of_data AS VARCHAR2(20)) 
   	  FROM DWH_STG.reversefeed_calypso 
   	UNION 
   	SELECT 'GSH_Backup' ,
           (dt) 
   	  FROM DWH_STG.gsh  );
   DELETE FROM GTT_TEMP_DWH2;
   UTILS.IDENTITY_RESET('GTT_TEMP_DWH2')
   */
   );

   INSERT INTO GTT_TEMP_DWH2 SELECT ROW_NUMBER() OVER ( PARTITION BY DWHSourcesystems ORDER BY DWHSourcesystems, date_of_data  ) RN_Count  ,
                                   DWHSourcesystems ,
                                   UTILS.CONVERT_TO_VARCHAR2(date_of_data,10,p_style=>103) date_of_data  
        FROM GTT_TEMP_DWH 
        ORDER BY RN_Count DESC;
   OPEN  v_cursor FOR
      SELECT RN_COUNT,DWHSOURCESYSTEMS,DATE_OF_DATA,
             CASE 
                  WHEN RN_Count > 1 THEN 'Invalid date of data'   END ErrorMessage  ,
             'DWH_Table_Date_View' TableName  
        FROM GTT_TEMP_DWH2 
        ORDER BY RN_Count DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);-- where ISNULL(ss,'')<>''
   OPEN  v_cursor FOR
      SELECT RN_COUNT,DWHSOURCESYSTEMS,DATE_OF_DATA,
             CASE 
                  WHEN RN_Count > 1 THEN 'Invalid date of data'   END ErrorMessage  ,
             'Invalid_Dateofdata_List' TableName  
        FROM GTT_TEMP_DWH2 
       WHERE  RN_Count > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT" TO "ADF_CDR_RBL_STGDB";
