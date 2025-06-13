--------------------------------------------------------
--  DDL for Procedure UTILITYLOGDETAILSELECT_28072023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" 
(
  v_UserLoginId IN VARCHAR2 DEFAULT u'' ,
  v_IsChecker IN CHAR DEFAULT u'' 
)
AS
   --PRINT 'Expire Checker'  
   --	UPDATE UtilityLogDetail SET  
   --		AuthorisationStatus='EP'
   --		--ApprovedBy=@UserLoginID,  
   --		--DateApproved=GETDATE()  
   --	WHERE EffectiveToTimeKey=49999
   --	AND (CAST(GETDATE() AS DATE)>ActionExecutionDate AND AuthorisationStatus IN('A'))
   --	AND (ISNULL(ApprovedBy,'')<>'' AND ISNULL(DateApproved,'')<>'')
   --AND (ISNULL(ExecutedBy,'')='' AND ISNULL(DateExecuted,'')='')
   v_cursor SYS_REFCURSOR;
   v_temp NUMBER(1, 0) := 0;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   ------------------------ EXPIRES ALL THE RECORDS WHEN SYSTEM DATE IS EXCEEDING ACTION EXECUTION DATE ------------------------------------------
   --IF EXISTS(SELECT 1 FROM UtilityLogDetail WHERE EffectiveToTimeKey=49999 AND (CAST(GETDATE() AS DATE)>ActionExecutionDate AND AuthorisationStatus IN('NP','MP')))
   --BEGIN
   DBMS_OUTPUT.PUT_LINE('Expire');
   UPDATE UtilityLogDetail
      SET AuthorisationStatus = 'EP'

   --ApprovedBy=@UserLoginID,  

   --DateApproved=GETDATE()  
   WHERE  EffectiveToTimeKey = 49999
     AND ( UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) > ActionExecutionDate
     AND AuthorisationStatus IN ( 'NP','MP','A' )
    )
     AND ( NVL(ExecutedBy, ' ') = ' '
     AND NVL(DateExecuted, ' ') = ' ' );
   --END
   IF ( v_IsChecker = 'Y' ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT ROW_NUMBER() OVER ( ORDER BY DateCreated DESC  ) EntityId  ,
                UtilEntityId UtilityEntityId  ,
                SourceName ,
                CreatedBy RequestorId  ,
                --,CONVERT(VARCHAR(10),DateCreated,103) AS RequestDate 
                (UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108)) RequestDate  ,
                ApprovedBy ApproverId  ,
                --,CONVERT(VARCHAR(10),DateApproved,103) AS ApproveDate
                (UTILS.CONVERT_TO_VARCHAR2(DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateApproved,30,p_style=>108)) ApproveDate  ,
                ExecutedBy ExecuterId  ,
                --,CONVERT(VARCHAR(10),DateExecuted,103) AS ExecuteDate 
                (UTILS.CONVERT_TO_VARCHAR2(DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateExecuted,30,p_style=>108)) ExecuteDate  ,
                CASE 
                     WHEN AuthorisationStatus = 'A' THEN 'AUTHORIZED'
                     WHEN AuthorisationStatus = 'R' THEN 'REJECTED'
                     WHEN AuthorisationStatus = 'EX' THEN 'EXECUTED'
                     WHEN AuthorisationStatus = 'EP' THEN 'EXPIRED'

                     --WHEN  (CAST(ActionExecutionDate AS DATE) < (CAST(GETDATE() AS DATE)) AND AuthorisationStatus in('NP','MP','A')) THEN 'EXPIRED' 
                     WHEN AuthorisationStatus IN ( 'NP','MP' )
                      THEN 'PENDING'
                ELSE NULL
                   END STATUS  ,
                UTILS.CONVERT_TO_VARCHAR2(ActionExecutionDate,10,p_style=>103) ActionExecutionDate  ,
                UtilityReason Reason  ,
                OriginatorName ,
                OriginatorEmpId ,
                UtilityRejectReason ,
                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  

           --FROM UtilityLogDetail WHERE ((ApprovedBy=@UserLoginId OR AuthorisationStatus IN('NP','MP')) AND AuthorisationStatus<>'DP') ORDER BY UtilEntityId DESC
           FROM UtilityLogDetail 
          WHERE  AuthorisationStatus <> 'DP'
           ORDER BY UtilEntityId DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      --PRINT 'Expire Maker'  
      --	UPDATE UtilityLogDetail SET  
      --		AuthorisationStatus='EP'
      --		--ApprovedBy=@UserLoginID,  
      --		--DateApproved=GETDATE()  
      --	WHERE EffectiveToTimeKey=49999
      --	AND (CAST(GETDATE() AS DATE)>ActionExecutionDate AND AuthorisationStatus IN('NP','MP'))
      --	AND (ISNULL(ModifiedBy,CreatedBy)<>'' AND ISNULL(DateModified,DateCreated)<>'')
      --AND (ISNULL(ApprovedBy,'')='' AND ISNULL(DateApproved,'')='')
      --AND (ISNULL(ExecutedBy,'')='' AND ISNULL(DateExecuted,'')='')
      OPEN  v_cursor FOR
         SELECT ROW_NUMBER() OVER ( ORDER BY DateCreated DESC  ) EntityId  ,
                UtilEntityId UtilityEntityId  ,
                SourceName ,
                CreatedBy RequestorId  ,
                --,CONVERT(VARCHAR(10),DateCreated,103) AS RequestDate    
                (UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108)) RequestDate  ,
                ApprovedBy ApproverId  ,
                --,CONVERT(VARCHAR(10),DateApproved,103) AS ApproveDate
                (UTILS.CONVERT_TO_VARCHAR2(DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateApproved,30,p_style=>108)) ApproveDate  ,
                ExecutedBy ExecuterId  ,
                --,CONVERT(VARCHAR(10),DateExecuted,103) AS ExecuteDate 
                (UTILS.CONVERT_TO_VARCHAR2(DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateExecuted,30,p_style=>108)) ExecuteDate  ,
                CASE 
                     WHEN AuthorisationStatus = 'A' THEN 'AUTHORIZED'
                     WHEN AuthorisationStatus = 'R' THEN 'REJECTED'
                     WHEN AuthorisationStatus = 'EX' THEN 'EXECUTED'
                     WHEN AuthorisationStatus = 'EP' THEN 'EXPIRED'

                     --WHEN  (CAST(ActionExecutionDate AS DATE) < (CAST(GETDATE() AS DATE)) AND AuthorisationStatus in('NP','MP','A')) THEN 'EXPIRED' 
                     WHEN AuthorisationStatus IN ( 'NP','MP' )
                      THEN 'PENDING'
                ELSE NULL
                   END STATUS  ,
                UTILS.CONVERT_TO_VARCHAR2(ActionExecutionDate,10,p_style=>103) ActionExecutionDate  ,
                UtilityReason Reason  ,
                OriginatorName ,
                OriginatorEmpId ,
                UtilityRejectReason ,
                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  

           --FROM UtilityLogDetail WHERE (CreatedBy=@UserLoginId AND AuthorisationStatus<>'DP') ORDER BY UtilEntityId DESC
           FROM UtilityLogDetail 
          WHERE  AuthorisationStatus <> 'DP'
           ORDER BY UtilEntityId DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             SourceName ,
             'LogSourceDetail' TableName  
        FROM LogSourceDetails 
       WHERE  SourceName <> 'ACL' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) LiveTimeKeyDate  ,
             'LiveTimeKeyDetails' TableName  
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(date_of_data,10,p_style=>103) DWHFinacleDate  ,
                      'DWHFinacleDate' TableName  
        FROM DWH_DWH_STG.account_data_finacle  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------------------------------------------------------------------------------------------------------------
   IF utils.object_id('tempdb..tt_TEMP_DWH_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_DWH_4 ';
   END IF;
   IF utils.object_id('tempdb..tt_TEMP_DWH_42') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_DWH2_4 ';
   END IF;
   DELETE FROM tt_TEMP_DWH_4;
   UTILS.IDENTITY_RESET('tt_TEMP_DWH_4');

   INSERT INTO tt_TEMP_DWH_4 ( 
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
   DELETE FROM tt_TEMP_DWH2_4;
   UTILS.IDENTITY_RESET('tt_TEMP_DWH2_4');

   INSERT INTO tt_TEMP_DWH2_4 SELECT ROW_NUMBER() OVER ( PARTITION BY DWHSourcesystems ORDER BY DWHSourcesystems, date_of_data  ) RN_Count  ,
                                     DWHSourcesystems ,
                                     UTILS.CONVERT_TO_VARCHAR2(date_of_data,10,p_style=>103) date_of_data  
        FROM tt_TEMP_DWH_4 
        ORDER BY RN_Count DESC;
   OPEN  v_cursor FOR
      SELECT * ,
             CASE 
                  WHEN RN_Count > 1 THEN 'Invalid date of data'   END ErrorMessage  ,
             'DWH_Table_Date_View' TableName  
        FROM tt_TEMP_DWH2_4 
        ORDER BY RN_Count DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);-- where ISNULL(ss,'')<>''
   OPEN  v_cursor FOR
      SELECT * ,
             CASE 
                  WHEN RN_Count > 1 THEN 'Invalid date of data'   END ErrorMessage  ,
             'Invalid_Dateofdata_List' TableName  
        FROM tt_TEMP_DWH2_4 
       WHERE  RN_Count > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------------------------------------------------------------------------------------------------------------
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM PRO_RBL_MISDB_PROD.AclRunningProcessStatus 
                       WHERE  Completed = 'N' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'N' Status  ,
                'ACL Failed' Desc_  ,
                'ACL Status' TableName  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'Y' Status  ,
                'ACL Successfull' Desc_  ,
                'ACL Status' TableName  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT_28072023" TO "ADF_CDR_RBL_STGDB";
