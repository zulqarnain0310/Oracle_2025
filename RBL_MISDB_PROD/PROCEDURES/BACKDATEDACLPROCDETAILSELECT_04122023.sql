--------------------------------------------------------
--  DDL for Procedure BACKDATEDACLPROCDETAILSELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" 
-- =============================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<07/02/2023>
 -- DESCRIPTION:			<BACKDATED ACL PROCESSING DETAIL SELECT>
 -- =============================================================

(
  v_UserLoginId IN VARCHAR2 DEFAULT u'' ,
  v_IsChecker IN CHAR DEFAULT u'' 
)
AS
   v_cursor SYS_REFCURSOR;
--DECLARE
--	@UserLoginId VARCHAR(50) = N'C33228',
--	@IsChecker  CHAR(1)  = N'N'

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   ------------------------ EXPIRES ALL THE RECORDS WHEN SYSTEM DATE IS EXCEEDING ACTION EXECUTION DATE ------------------------------------------
   --IF EXISTS(SELECT 1 FROM BackDatedACLProcDetail WHERE EffectiveToTimeKey=49999 AND (CAST(GETDATE() AS DATE)>ActionExecutionDate AND AuthorisationStatus IN('NP','MP')))
   --BEGIN
   DBMS_OUTPUT.PUT_LINE('Expire');
   UPDATE BackDatedACLProcDetail
      SET AuthorisationStatus = 'EP'

   --ApprovedBy=@UserLoginID,  

   --DateApproved=GETDATE()  
   WHERE  EffectiveToTimeKey = 49999

     --AND (CAST(GETDATE() AS DATE)>ActionExecutionDate 
     AND ( utils.datediff('SECOND', DateCreated, SYSDATE) > 7200 )
     AND AuthorisationStatus IN ( 'NP','MP' )
   ;
   --AND (ISNULL(ApprovedBy,'')='' AND ISNULL(DateApproved,'')='')
   --END
   IF ( v_IsChecker = 'Y' ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT ROW_NUMBER() OVER ( ORDER BY A.BackACLProcEntityId DESC  ) EntityId  ,
                A.BackACLProcEntityId BackACLProcEntityId  ,
                A.CreatedBy RequestorId  ,
                (UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,30,p_style=>108)) RequestRaisedDate  ,
                A.ApprovedBy ApproverId  ,
                (UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,30,p_style=>108)) ApproveDate  ,
                A.ExecutedBy ExecuterId  ,
                (UTILS.CONVERT_TO_VARCHAR2(A.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(A.DateExecuted,30,p_style=>108)) ExecuteDate  ,
                CASE 
                     WHEN A.AuthorisationStatus = 'A' THEN 'AUTHORIZED'
                     WHEN A.AuthorisationStatus = 'R' THEN 'REJECTED'
                     WHEN A.AuthorisationStatus = 'EX' THEN 'EXECUTED'
                     WHEN A.AuthorisationStatus = 'EP' THEN 'EXPIRED'
                     WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                      THEN 'PENDING'
                ELSE NULL
                   END STATUS  ,
                UTILS.CONVERT_TO_VARCHAR2(A.ActionExecutionDate,10,p_style=>103) ActionExecutionDate  ,
                A.BackACLProcStatus ,
                A.Remarks Remarks  ,
                A.OriginatorName ,
                A.OriginatorEmpId ,
                A.BackACLProcRejectReason ,
                --,BTD.TaskName AS TaskName
                A.TaskName 
           FROM BackDatedACLProcDetail A
           ORDER BY 
                    --LEFT JOIN(

                    --			SELECT DISTINCT A.BackACLProcEntityId,A.CreatedBy

                    --			,STUFF((SELECT ', ' + B.TaskName FROM BackdatedTaskDetail B WHERE A.BackACLProcEntityId=B.BackACLProcEntityId ORDER BY B.BackACLProcEntityId FOR XML PATH('')),1,1,'') AS TaskName 

                    --			FROM BackdatedTaskDetail A

                    --		) BTD

                    ----LEFT JOIN (SELECT DISTINCT BackACLProcEntityId,STUFF((SELECT ', ' + TaskName from BackdatedTaskDetail FOR XML PATH('')),1,1,'') AS TaskName FROM  BackdatedTaskDetail) B

                    --ON A.BackACLProcEntityId=BTD.BackACLProcEntityId

                    --WHERE A.ApprovedBy=@UserLoginId OR A.AuthorisationStatus='NP'
                    CASE 
                         WHEN AuthorisationStatus IN ( 'NP','MP' )
                          THEN 1   END DESC,
                    BackACLProcEntityId DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT ROW_NUMBER() OVER ( ORDER BY A.BackACLProcEntityId DESC  ) EntityId  ,
                A.BackACLProcEntityId BackACLProcEntityId  ,
                A.CreatedBy RequestorId  ,
                (UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,30,p_style=>108)) RequestRaisedDate  ,
                A.ApprovedBy ApproverId  ,
                (UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,30,p_style=>108)) ApproveDate  ,
                A.ExecutedBy ExecuterId  ,
                (UTILS.CONVERT_TO_VARCHAR2(A.DateExecuted,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(A.DateExecuted,30,p_style=>108)) ExecuteDate  ,
                CASE 
                     WHEN A.AuthorisationStatus = 'A' THEN 'AUTHORIZED'
                     WHEN A.AuthorisationStatus = 'R' THEN 'REJECTED'
                     WHEN A.AuthorisationStatus = 'EX' THEN 'EXECUTED'
                     WHEN A.AuthorisationStatus = 'EP' THEN 'EXPIRED'
                     WHEN A.AuthorisationStatus IN ( 'NP','MP' )
                      THEN 'PENDING'
                ELSE NULL
                   END STATUS  ,
                UTILS.CONVERT_TO_VARCHAR2(A.ActionExecutionDate,10,p_style=>103) ActionExecutionDate  ,
                A.BackACLProcStatus ,
                A.Remarks Remarks  ,
                A.OriginatorName ,
                A.OriginatorEmpId ,
                A.BackACLProcRejectReason ,
                --,BTD.TaskName AS TaskName
                A.TaskName 
           FROM BackDatedACLProcDetail A
           ORDER BY 
                    --LEFT JOIN(

                    --			SELECT DISTINCT A.BackACLProcEntityId,A.CreatedBy

                    --			,STUFF((SELECT ', ' + B.TaskName FROM BackdatedTaskDetail B WHERE A.BackACLProcEntityId=B.BackACLProcEntityId ORDER BY B.BackACLProcEntityId FOR XML PATH('')),1,1,'') AS TaskName 

                    --			FROM BackdatedTaskDetail A

                    --		) BTD

                    ----LEFT JOIN (SELECT DISTINCT BackACLProcEntityId,STUFF((SELECT ', ' + TaskName from BackdatedTaskDetail FOR XML PATH('')),1,1,'') AS TaskName FROM  BackdatedTaskDetail) B

                    --ON A.BackACLProcEntityId=BTD.BackACLProcEntityId

                    --WHERE A.CreatedBy=@UserLoginId 
                    CASE 
                         WHEN AuthorisationStatus IN ( 'NP','MP' )
                          THEN 1   END DESC,
                    BackACLProcEntityId DESC ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   --SELECT SrNo AS ACLProcStatusAlt_Key,ACLProcStatus,'BackProcDetails' AS TableName FROM ACLProcDetail
   OPEN  v_cursor FOR
      SELECT EntityKey ,
             UserID ,
             BackdatedProcStep ,
             BackdatedProcStatus ,
             UTILS.CONVERT_TO_VARCHAR2(BackdatedProcDateTime,10,p_style=>103) BackdatedProcDateTime  ,
             TimeKey ,
             (UTILS.CONVERT_TO_VARCHAR2(ProcessingStartTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(ProcessingStartTime,30,p_style=>108)) ProcessingStartTime  ,
             (UTILS.CONVERT_TO_VARCHAR2(ProcessingEndTime,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(ProcessingEndTime,30,p_style=>108)) ProcessingEndTime  ,
             BackACLProcEntityId ,
             'Process Status' TableName  
        FROM BackdatedProcMonitorStatus  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
