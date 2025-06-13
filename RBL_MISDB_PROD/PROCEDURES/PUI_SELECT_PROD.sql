--------------------------------------------------------
--  DDL for Procedure PUI_SELECT_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUI_SELECT_PROD" 
(
  v_OperationFlag IN NUMBER,
  v_UserId IN VARCHAR2
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         IF ( v_OperationFlag = 2 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.CustomerEntityID ,
                      A.CustomerID ,
                      A.CustomerName ,
                      A.AccountID ,
                      UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                      A.ProjectCat ,
                      A.ProjectDelReason ,
                      A.StandardRestruct ,
                      NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                      A.ApprovedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                      A.ModifiedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      'PUIUpload' TableName  
                 FROM AdvAcProjectDetail_Upload_Mod A
                WHERE  NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
             ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF ( v_OperationFlag = 16 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.CustomerEntityID ,
                      A.CustomerID ,
                      A.CustomerName ,
                      A.AccountID ,
                      UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                      A.ProjectCat ,
                      A.ProjectDelReason ,
                      A.StandardRestruct ,
                      NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                      A.ApprovedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                      A.ModifiedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      'PUIUpload' TableName  
                 FROM AdvAcProjectDetail_Upload_Mod A
                WHERE  NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
             ;
               DBMS_SQL.RETURN_RESULT(v_cursor);--and CreatedBy <> @UserId

         END;
         END IF;
         IF ( v_OperationFlag = 20 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.CustomerEntityID ,
                      A.CustomerID ,
                      A.CustomerName ,
                      A.AccountID ,
                      UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                      A.ProjectCat ,
                      A.ProjectDelReason ,
                      A.StandardRestruct ,
                      --isnull(A.AuthorisationStatus, 'A') 
                      A.AuthorisationStatus ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                      A.ApprovedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                      A.ModifiedBy ,
                      UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      'PUIUpload' TableName  
                 FROM AdvAcProjectDetail_Upload_Mod A
                WHERE  NVL(A.AuthorisationStatus, 'A') IN ( '1A' )
             ;
               DBMS_SQL.RETURN_RESULT(v_cursor);--and CreatedBy <> @UserId

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_SELECT_PROD" TO "ADF_CDR_RBL_STGDB";
