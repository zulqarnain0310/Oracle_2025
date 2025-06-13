--------------------------------------------------------
--  DDL for Procedure RP_LENDERAUTHORIZESELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" 
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
                      A.LenderName ,
                      (CASE 
                            WHEN UTILS.CONVERT_TO_VARCHAR2(A.InDefaultDate,200) = ' ' THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,20,p_style=>103)
                         END) InDefaultDate  ,
                      (CASE 
                            WHEN UTILS.CONVERT_TO_VARCHAR2(A.OutOfDefaultDate,200) = ' ' THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,20,p_style=>103)
                         END) OutOfDefaultDate  ,
                      NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      'LenderDataUpload' TableName  
                 FROM RP_Lender_Upload_Mod A
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
                      A.LenderName ,
                      (CASE 
                            WHEN UTILS.CONVERT_TO_VARCHAR2(A.InDefaultDate,200) = ' ' THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,20,p_style=>103)
                         END) InDefaultDate  ,
                      (CASE 
                            WHEN UTILS.CONVERT_TO_VARCHAR2(A.OutOfDefaultDate,200) = ' ' THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,20,p_style=>103)
                         END) OutOfDefaultDate  ,
                      NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      'LenderDataUpload' TableName  
                 FROM RP_Lender_Upload_Mod A
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
                      A.LenderName ,
                      (CASE 
                            WHEN UTILS.CONVERT_TO_VARCHAR2(A.InDefaultDate,200) = ' ' THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,20,p_style=>103)
                         END) InDefaultDate  ,
                      (CASE 
                            WHEN UTILS.CONVERT_TO_VARCHAR2(A.OutOfDefaultDate,200) = ' ' THEN NULL
                      ELSE UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,20,p_style=>103)
                         END) OutOfDefaultDate  ,
                      --isnull(A.AuthorisationStatus, 'A') 
                      A.AuthorisationStatus ,
                      A.EffectiveFromTimeKey ,
                      A.EffectiveToTimeKey ,
                      A.CreatedBy ,
                      A.DateCreated ,
                      A.ApprovedBy ,
                      A.DateApproved ,
                      A.ModifiedBy ,
                      A.DateModified ,
                      NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                      NVL(A.DateModified, A.DateCreated) CrModDate  ,
                      NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                      NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                      NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                      NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                      'LenderDataUpload' TableName  
                 FROM RP_Lender_Upload_Mod A
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_LENDERAUTHORIZESELECT_04122023" TO "ADF_CDR_RBL_STGDB";
