--------------------------------------------------------
--  DDL for Procedure ACLJOBEXECDETAILSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" 
(
  v_UserLoginId IN VARCHAR2 DEFAULT u'' ,
  v_IsChecker IN CHAR DEFAULT u'' 
)
AS
   v_cursor SYS_REFCURSOR;
--DECLARE 
--	@UserLoginId	VARCHAR(50)	= N'C36601',
--	@IsChecker		CHAR(1)		= N'N'  

BEGIN

   ------------------------ EXPIRES ALL THE RECORDS WHEN SYSTEM DATE IS EXCEEDING ACTION EXECUTION DATE ------------------------------------------
   --IF EXISTS(SELECT 1 FROM ACLJobExecDetail WHERE EffectiveToTimeKey=49999 AND (CAST(GETDATE() AS DATE)>ActionExecutionDate AND AuthorisationStatus IN('NP','MP')))
   --BEGIN
   DBMS_OUTPUT.PUT_LINE('Expire');
   UPDATE ACLJobExecDetail
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
         SELECT ROW_NUMBER() OVER ( ORDER BY ACLJobExecEntityId DESC  ) EntityId  ,
                RCA_ID RcaId  ,
                JobName ,
                JobStepName ACLJobStepNumber  ,
                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                ACLJobExecEntityId ACLJobExecEntityId  ,
                CreatedBy RequestorId  ,
                --,CONVERT(VARCHAR(10),DateCreated,103) AS RequestRaisedDate
                (UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108)) RequestRaisedDate  ,
                ApprovedBy ApproverId  ,
                --,CONVERT(VARCHAR(10),DateApproved,103) AS ApproveDate 
                (UTILS.CONVERT_TO_VARCHAR2(DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateApproved,30,p_style=>108)) ApproveDate  ,
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
                ExecutedBy ExecuterId  ,
                --,CONVERT(VARCHAR(10),DateExecuted,103) AS ExecuteDate 
                (UTILS.CONVERT_TO_VARCHAR2(DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateExecuted,30,p_style=>108)) ExecuteDate  ,
                UTILS.CONVERT_TO_VARCHAR2(ActionExecutionDate,10,p_style=>103) ExecutedDate  ,
                ACLJobExecStatus ,
                Remarks Remarks  ,
                OriginatorName ,
                OriginatorEmpId ,
                ACLExecRejectReason 

           --FROM ACLJobExecDetail WHERE ((ApprovedBy=@UserLoginId OR AuthorisationStatus IN('NP','MP')) AND AuthorisationStatus<>'DP')
           FROM ACLJobExecDetail 
          WHERE  AuthorisationStatus <> 'DP'
           ORDER BY CASE 
                         WHEN AuthorisationStatus IN ( 'NP','MP' )
                          THEN 1   END DESC,
                    ACLJobExecEntityId DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT ROW_NUMBER() OVER ( ORDER BY ACLJobExecEntityId DESC  ) EntityId  ,
                RCA_ID RcaId  ,
                JobName ,
                JobStepName ACLJobStepNumber  ,
                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                ACLJobExecEntityId ACLJobExecEntityId  ,
                CreatedBy RequestorId  ,
                --,CONVERT(VARCHAR(10),DateCreated,103) AS RequestRaisedDate  
                (UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108)) RequestRaisedDate  ,
                ApprovedBy ApproverId  ,
                --,CONVERT(VARCHAR(10),DateApproved,103) AS ApproveDate  
                (UTILS.CONVERT_TO_VARCHAR2(DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateApproved,30,p_style=>108)) ApproveDate  ,
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
                ExecutedBy ExecuterId  ,
                --,CONVERT(VARCHAR(10),DateExecuted,103) AS ExecuteDate
                (UTILS.CONVERT_TO_VARCHAR2(DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateExecuted,30,p_style=>108)) ExecuteDate  ,
                UTILS.CONVERT_TO_VARCHAR2(ActionExecutionDate,10,p_style=>103) ExecutedDate  ,
                ACLJobExecStatus ,
                Remarks Remarks  ,
                OriginatorName ,
                OriginatorEmpId ,
                ACLExecRejectReason 

           --FROM ACLJobExecDetail WHERE (CreatedBy=@UserLoginId AND AuthorisationStatus<>'DP')
           FROM ACLJobExecDetail 
          WHERE  AuthorisationStatus <> 'DP'
           ORDER BY CASE 
                         WHEN AuthorisationStatus IN ( 'NP','MP' )
                          THEN 1   END DESC,
                    ACLJobExecEntityId DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT SrNo JobStatusAlt_Key  ,
             JobExecType ,
             'JobStatus' TableName  
        FROM JobStatusDetail  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT SrNo JobNameAlt_Key  ,
             JobName ,
             'JobNameDetails' TableName  
        FROM ACLAllJobsDetail  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --SELECT ParameterAlt_Key,ParameterName,SourceName,'LogSourceDetail' AS TableName FROM LogSourceDetails  
   --WHERE SourceName <>'ACL'  
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) LiveTimeKeyDate  ,
             'LiveTimeKeyDetails' TableName  
        FROM Automate_Advances 
       WHERE  EXT_FLG = 'Y' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------------- RCA ID DETAILS SHOWN BY SATWAJI AS ON 24/07/2023 AS PER SOHEL'S REQUIREMENT ----------------------------------
   OPEN  v_cursor FOR
      SELECT RcaId ,
             RCAIdStatus ,
             'RCA_Details' TableName  
        FROM ( SELECT RCA_Id RcaId  ,
                      CASE 
                           WHEN NVL(AuthorisationStatus, 'A') = 'A' THEN 'Second Level Authorize'
                           WHEN AuthorisationStatus = 'EP' THEN 'Expired'   END RCAIdStatus  ,
                      ROW_NUMBER() OVER ( ORDER BY EntityKey DESC  ) RN  
               FROM ETL_ACLFailRequestDetail 
                WHERE  EffectiveToTimeKey = 49999 ) A
       WHERE  RN = 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT DISTINCT UTILS.CONVERT_TO_VARCHAR2(date_of_data,10,p_style=>103) DWHFinacleDate  ,
                      'DWHFinacleDate' TableName  
        FROM DWH_STG.account_data_finacle  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILSELECT" TO "ADF_CDR_RBL_STGDB";
