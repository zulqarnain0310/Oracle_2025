--------------------------------------------------------
--  DDL for Procedure ACLJOBEXECDWHPIPELINESELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" 
-- ========================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<28/07/2023>
 -- DESCRIPTION:			<DWH PIPELINE DETAIL SELECT>
 -- =========================================================

AS
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('tempdb..tt_TEMP_DWH_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_DWH_2 ';
   END IF;
   IF utils.object_id('tempdb..tt_TEMP_DWH_22') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_DWH2_2 ';
   END IF;
   DELETE FROM tt_TEMP_DWH_2;
   UTILS.IDENTITY_RESET('tt_TEMP_DWH_2');

   INSERT INTO tt_TEMP_DWH_2 ( 
   	SELECT 'Customer_data_finacle' DWHSourcesystems  ,
           date_of_data Date_of_data  
   	  FROM DWH_DWH_STG.customer_data_finacle 
   	UNION 
   	SELECT 'Customer_data' ,
           date_of_data 
   	  FROM DWH_DWH_STG.customer_data 
   	UNION 
   	SELECT 'Customer_data_visionplus' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.customer_data_visionplus 
   	UNION 
   	SELECT 'Customer_data_ecbf' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.customer_data_ecbf 
   	UNION 

   	--select 'Customer_data_ganaseva', (date_of_data) from DWH_STG.DWH.customer_data_ganaseva with(nolock)

   	--union
   	SELECT 'Customer_data_mifin' ,
           (DateOfData) 
   	  FROM DWH_DWH_STG.customer_data_mifin 
   	UNION 
   	SELECT 'Account_data_finacle' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.account_data_finacle 
   	UNION 
   	SELECT 'Accounts_data' ,
           (date_of_data) SourceSystem  
   	  FROM DWH_DWH_STG.accounts_data 
   	UNION 
   	SELECT 'Account_data_visionplus' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.account_data_visionplus 
   	UNION 
   	SELECT 'Accounts_data_ecbf' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.accounts_data_ecbf 
   	UNION 

   	--select 'Account_data_ganaseva', (date_of_data) from DWH_STG.DWH.account_data_ganaseva with(nolock)

   	--union
   	SELECT 'Accounts_data_mifin' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.accounts_data_mifin 
   	UNION 
   	SELECT 'Collateral_type_master_finacle' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.collateral_type_master_finacle 
   	UNION 
   	SELECT 'Security_data_ecbf' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.security_data_ecbf 
   	UNION 
   	SELECT 'SECURITY_SOURCESYSTEM02' ,
           (DateofData) 
   	  FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM02 
   	UNION 
   	SELECT 'SECURITY_SOURCESYSTEM04' ,
           (DateofData) 
   	  FROM DWH_DWH_STG.SECURITY_SOURCESYSTEM04 
   	UNION 
   	SELECT 'Transaction_data_finacle' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.transaction_data_finacle 
   	UNION 
   	SELECT 'bills_data_stg_fin' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.bills_data_stg_fin 
   	UNION 
   	SELECT 'Pca_data' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.pca_data 
   	UNION 
   	SELECT 'InvestmentBasicDetail' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.InvestmentBasicDetail 
   	UNION 
   	SELECT 'InvestmentFinancialDetails' ,
           (DateofData) 
   	  FROM DWH_DWH_STG.InvestmentFinancialDetails 
   	UNION 
   	SELECT 'InvestmentIssuerDetail' ,
           (date_of_data) 
   	  FROM DWH_DWH_STG.InvestmentIssuerDetail 
   	UNION 
   	SELECT 'Derivative_Cancelled' ,
           (Dateofdata) 
   	  FROM DWH_DWH_STG.Derivative_Cancelled 
   	UNION 
   	SELECT 'MIFINGOLDMASTER' ,
           (DateofData) 
   	  FROM DWH_DWH_STG.MIFINGOLDMASTER 
   	UNION 
   	SELECT 'Customer_data_fis' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.customer_data_fis 
   	UNION 
   	SELECT 'Account_data_fis' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.account_data_fis 
   	UNION 
   	SELECT 'Metagrid_account' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.account_data_metagrid 
   	UNION 
   	SELECT 'Metagrid_customer' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.customer_data_metagrid 
   	UNION 
   	SELECT 'Metagrid_security' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.security_data_metagrid 
   	UNION 
   	SELECT 'EIFS_customer' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.customer_data_eifs 
   	UNION 
   	SELECT 'EIFS_account' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.account_data_eifs 
   	UNION 
   	SELECT 'SCF_bills' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.bills_data_stg_scf 
   	UNION 
   	SELECT 'Reversefeed_calypso_Backup' ,
           (Date_of_Data) 
   	  FROM DWH_DWH_STG.reversefeed_calypso 
   	UNION 
   	SELECT 'GSH_Backup' ,
           (dt) 
   	  FROM DWH_DWH_STG.gsh  );
   DELETE FROM tt_TEMP_DWH2_2;
   UTILS.IDENTITY_RESET('tt_TEMP_DWH2_2');

   INSERT INTO tt_TEMP_DWH2_2 SELECT ROW_NUMBER() OVER ( PARTITION BY DWHSourcesystems ORDER BY DWHSourcesystems, date_of_data  ) RN_Count  ,
                                     DWHSourcesystems ,
                                     UTILS.CONVERT_TO_VARCHAR2(date_of_data,10,p_style=>103) date_of_data  
        FROM tt_TEMP_DWH_2 
        ORDER BY RN_Count DESC;
   OPEN  v_cursor FOR
      SELECT * ,
             CASE 
                  WHEN RN_Count > 1 THEN 'Invalid date of data'   END ErrorMessage  ,
             'DWH_Table_Date_View' TableName  
        FROM tt_TEMP_DWH2_2 
        ORDER BY RN_Count DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);-- where ISNULL(ss,'')<>''
   OPEN  v_cursor FOR
      SELECT * ,
             CASE 
                  WHEN RN_Count > 1 THEN 'Invalid date of data'   END ErrorMessage  ,
             'Invalid_Dateofdata_List' TableName  
        FROM tt_TEMP_DWH2_2 
       WHERE  RN_Count > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDWHPIPELINESELECT_04122023" TO "ADF_CDR_RBL_STGDB";
