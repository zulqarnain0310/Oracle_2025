--------------------------------------------------------
--  DDL for Procedure ACLFAILUREDETAIL_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" 
(
  v_StartDate IN VARCHAR2 DEFAULT ' ' ,
  v_EndDate IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT ACLFailEntityId ,
             COALESCE(UTILS.CONVERT_TO_VARCHAR2(RCA_ID,10), ' ') RcaId  ,
             UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
             ACLFailuerReason ,
             OriginatorName ,
             OriginatorEmpId ,
             CASE 
                  WHEN ModeOfCommunication IS NULL THEN ' '
             ELSE ModeOfCommunication
                END ModeOfCommunication  ,
             --,CONVERT(VARCHAR,IntimationTime,8) AS IntimationTime
             CASE 
                  WHEN IntimationTime IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(IntimationTime,5,p_style=>108)
                END IntimationTime  ,
             D2KUserName ,
             D2KUserEmpId ,
             CASE 
                  WHEN D2KInformedDate IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(D2KInformedDate,10,p_style=>103)
                END D2KInformedDate  ,
             CASE 
                  WHEN ACLIssueResolvedDate IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(ACLIssueResolvedDate,10,p_style=>103)
                END ACLIssueResolvedDate  ,
             --,ACLIssueResolvedTime  
             CASE 
                  WHEN ACLIssueResolvedTime IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(ACLIssueResolvedTime,5,p_style=>108)
                END ACLIssueResolvedTime  ,
             --,CONVERT(VARCHAR,ETLStartTime,8) AS ETLStartTime 
             CASE 
                  WHEN ETLStartTime IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(ETLStartTime,5,p_style=>108)
                END ETLStartTime  ,
             ETLStatus ,
             --,CONVERT(VARCHAR,ETLEndTime,8) AS ETLEndTime  
             CASE 
                  WHEN ETLEndTime IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(ETLEndTime,5,p_style=>108)
                END ETLEndTime  ,
             CreatedBy ,
             CASE 
                  WHEN UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) IS NULL THEN ' '
             ELSE (UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108))
                END CreatedDate  ,
             --,CASE WHEN CONVERT(VARCHAR(10),DateCreated,103) IS NULL THEN '' ELSE CONVERT(VARCHAR(10),DateCreated,103) END AS CreatedDate
             --,ModifiedBy AS UpdatedBy
             CASE 
                  WHEN UTILS.CONVERT_TO_VARCHAR2(DateModified,10,p_style=>103) IS NULL THEN ' '
             ELSE (UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>108))
                END UpdatedDate  ,
             --,CASE WHEN CONVERT(VARCHAR(10),DateModified,103) IS NULL THEN '' ELSE CONVERT(VARCHAR(10),DateModified,103) END AS UpdatedDate
             SourceName ,
             ETLSolution 
        FROM ACLFailureDetail 
        ORDER BY EntityKey DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             SourceName ,
             'LogSource' 
        FROM LogSourceDetails  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT * 
        FROM ModeOfCommunication 
        ORDER BY EntityKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --Select * from UsersToAssignedACLFailureTask Order by EntityKey
   OPEN  v_cursor FOR
      SELECT ROW_NUMBER() OVER ( ORDER BY A.UserName  ) EntityKey  ,
             A.UserLoginID UserId  ,
             A.UserName ,
             'UserNameDetails' TableName  
        FROM DimUserInfo A
               JOIN DimUserDeptGroup B   ON A.DeptGroupCode = DeptGroupId
               AND B.EffectiveToTimeKey = 49999
       WHERE  A.EffectiveToTimeKey = 49999
                AND A.Activate = 'Y'
                AND B.DeptGroupCode = 'IT' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   
   OPEN  v_cursor FOR
      SELECT ID ,
             MachineName ,
             A.JobName ,
             CASE 
                  WHEN NVL(A.StepName, ' ') = ' ' THEN ' '
             ELSE A.StepName
                END JobStepName  ,
             PackageName ,
             TaskName ,
             ErrorCode ,
             ErrorDescription ,
             CASE 
                  WHEN UTILS.CONVERT_TO_VARCHAR2(JobStartTime,10,p_style=>103) IS NULL THEN ' '
             ELSE (UTILS.CONVERT_TO_VARCHAR2(JobStartTime,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(JobStartTime,30,p_style=>108))
                END JobStartTime  ,
             CASE 
                  WHEN UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) IS NULL THEN ' '
             ELSE (UTILS.CONVERT_TO_VARCHAR2(Date_,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(Date_,30,p_style=>108))
                END PackageErrorDate  ,
             CASE 
                  WHEN UTILS.CONVERT_TO_VARCHAR2(ReportingDate,10,p_style=>103) IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(ReportingDate,10,p_style=>103)
                END ReportingDate  ,
             CASE 
                  WHEN UTILS.CONVERT_TO_VARCHAR2(ProcessDate,10,p_style=>103) IS NULL THEN ' '
             ELSE UTILS.CONVERT_TO_VARCHAR2(ProcessDate,10,p_style=>103)
                END DateofData  ,
             'ACLFailureReport' TableName  
        FROM RBL_STGDB.PackageErrorLogs A
        ORDER BY 
                 --LEFT JOIN #JobStartTimeTemp B

                 --ON A.JobName=B.JobName

                 --AND RN=1
                 1 DESC ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                              FROM DUAL  )  ) EntityKey  ,
             RCA_Id RcaId  
        FROM ETL_ACLFailRequestDetail 
       WHERE  EffectiveToTimeKey = 49999
        ORDER BY RCA_Id ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAIL_SELECT" TO "ADF_CDR_RBL_STGDB";
