--------------------------------------------------------
--  DDL for Procedure UTILITYLOGDETAILSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILSELECT" TO "ADF_CDR_RBL_STGDB";
