--------------------------------------------------------
--  DDL for Procedure RP_PORTFOLIOAUTHORIZESELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" 
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
                      A.UCIC_ID ,
                      A.CustomerID ,
                      A.PAN_No ,
                      A.CustomerName ,
                      A.BankCode ,
                      UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,20,p_style=>103) BorrowerDefaultDate  ,
                      A.ExposureBucketName ,
                      A.BankingArrangementName ,
                      A.LeadBankName ,
                      A.DefaultStatus ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,20,p_style=>103) RP_ApprovalDate  ,
                      A.RPNatureName ,
                      A.If_Other ,
                      A.ImplementationStatus ,
                      UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,20,p_style=>103) Actual_Impl_Date  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,20,p_style=>103) RP_OutOfDateAllBanksDeadline  ,
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
                      'AutomationRPUpload' TableName  
                 FROM RP_Portfolio_Upload_Mod A
                WHERE  NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
             ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF ( v_OperationFlag = 16 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.CustomerEntityID ,
                      A.UCIC_ID ,
                      A.CustomerID ,
                      A.PAN_No ,
                      A.CustomerName ,
                      A.BankCode ,
                      UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,20,p_style=>103) BorrowerDefaultDate  ,
                      A.ExposureBucketName ,
                      A.BankingArrangementName ,
                      A.LeadBankName ,
                      A.DefaultStatus ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,20,p_style=>103) RP_ApprovalDate  ,
                      A.RPNatureName ,
                      A.If_Other ,
                      A.ImplementationStatus ,
                      UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,20,p_style=>103) Actual_Impl_Date  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,20,p_style=>103) RP_OutOfDateAllBanksDeadline  ,
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
                      'AutomationRPUpload' TableName  
                 FROM RP_Portfolio_Upload_Mod A
                WHERE  NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                         AND a.CreatedBy <> v_UserId ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF ( v_OperationFlag = 20 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT A.CustomerEntityID ,
                      A.UCIC_ID ,
                      A.CustomerID ,
                      A.PAN_No ,
                      A.CustomerName ,
                      A.BankCode ,
                      UTILS.CONVERT_TO_VARCHAR2(A.BorrowerDefaultDate,20,p_style=>103) BorrowerDefaultDate  ,
                      A.ExposureBucketName ,
                      A.BankingArrangementName ,
                      A.LeadBankName ,
                      A.DefaultStatus ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,20,p_style=>103) RP_ApprovalDate  ,
                      A.RPNatureName ,
                      A.If_Other ,
                      A.ImplementationStatus ,
                      UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,20,p_style=>103) Actual_Impl_Date  ,
                      UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,20,p_style=>103) RP_OutOfDateAllBanksDeadline  ,
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
                      'AutomationRPUpload' TableName  
                 FROM RP_Portfolio_Upload_Mod A
                WHERE  NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                         AND a.CreatedBy <> v_UserId ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIOAUTHORIZESELECT_04122023" TO "ADF_CDR_RBL_STGDB";
