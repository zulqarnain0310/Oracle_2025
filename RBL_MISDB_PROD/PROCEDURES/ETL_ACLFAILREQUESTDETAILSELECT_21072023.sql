--------------------------------------------------------
--  DDL for Procedure ETL_ACLFAILREQUESTDETAILSELECT_21072023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" 
-- ========================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<20/07/2023>
 -- DESCRIPTION:			<ETL-ACL FAILURE SCREEN SELECT>
 -- =========================================================

(
  --@UserLoginID	VARCHAR(100)	= '',
  v_OperationFlag IN NUMBER DEFAULT 16 ,
  v_MenuID IN NUMBER DEFAULT 27776 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   IF ( v_OperationFlag IN ( 1,2,3 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT RCA_Id ,
                ETL_ACL_FAILED ,
                UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                ETL_ACLObservation ,
                ETL_ACLErrorInDB ,
                ETL_ACL_RCA ,
                ETL_ACL_Solution ,
                CASE 
                     WHEN AuthorisationStatus = 'A' THEN 'Authorized'
                     WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                     WHEN AuthorisationStatus = '1A' THEN '1Authorized'
                     WHEN AuthorisationStatus = 'NP' THEN 'Pending'
                ELSE NULL
                   END AuthorisationStatus  ,
                CreatedBy ,
                CASE 
                     WHEN UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) IS NULL THEN ' '
                ELSE (UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108))
                   END CreatedDate  ,
                ModifiedBy UpdatedBy  ,
                CASE 
                     WHEN UTILS.CONVERT_TO_VARCHAR2(DateModified,10,p_style=>103) IS NULL THEN ' '
                ELSE (UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>108))
                   END UpdatedDate  ,
                NVL(ModifiedBy, CreatedBy) CrModBy  ,
                NVL(DateModified, DateCreated) CrModDate  ,
                NVL(ApprovedBy, CreatedBy) CrAppBy  ,
                NVL(DateApproved, DateCreated) CrAppDate  ,
                NVL(ApprovedBy, ModifiedBy) ModAppBy  ,
                NVL(DateApproved, DateModified) ModAppDate  
           FROM ETL_ACLFailRequestDetail 
          WHERE  EffectiveToTimeKey = 49999
                   AND NVL(AuthorisationStatus, 'A') = 'A'
         UNION 
         SELECT RCA_Id ,
                ETL_ACL_FAILED ,
                UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                ETL_ACLObservation ,
                ETL_ACLErrorInDB ,
                ETL_ACL_RCA ,
                ETL_ACL_Solution ,
                CASE 
                     WHEN AuthorisationStatus = 'A' THEN 'Authorized'
                     WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                     WHEN AuthorisationStatus = '1A' THEN '1Authorized'
                     WHEN AuthorisationStatus = 'NP' THEN 'Pending'
                ELSE NULL
                   END AuthorisationStatus  ,
                CreatedBy ,
                CASE 
                     WHEN UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) IS NULL THEN ' '
                ELSE (UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108))
                   END CreatedDate  ,
                ModifiedBy UpdatedBy  ,
                CASE 
                     WHEN UTILS.CONVERT_TO_VARCHAR2(DateModified,10,p_style=>103) IS NULL THEN ' '
                ELSE (UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>108))
                   END UpdatedDate  ,
                NVL(ModifiedBy, CreatedBy) CrModBy  ,
                NVL(DateModified, DateCreated) CrModDate  ,
                NVL(ApprovedBy, CreatedBy) CrAppBy  ,
                NVL(DateApproved, DateCreated) CrAppDate  ,
                NVL(ApprovedBy, ModifiedBy) ModAppBy  ,
                NVL(DateApproved, DateModified) ModAppDate  
           FROM ETL_ACLFailRequestDetail_Mod 
          WHERE  EffectiveToTimeKey = 49999
                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A','1D' )

                   AND EntityKey IN ( SELECT MAX(EntityKey)  EntityKey  
                                      FROM ETL_ACLFailRequestDetail_Mod 
                                       WHERE  EffectiveToTimeKey = 49999
                                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A','1D' )

                                        GROUP BY EntityKey )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE
      IF ( v_OperationFlag = 16 ) THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT RCA_Id ,
                   ETL_ACL_FAILED ,
                   UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                   UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                   UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                   ETL_ACLObservation ,
                   ETL_ACLErrorInDB ,
                   ETL_ACL_RCA ,
                   ETL_ACL_Solution ,
                   CASE 
                        WHEN AuthorisationStatus = 'A' THEN 'Authorized'
                        WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                        WHEN AuthorisationStatus = '1A' THEN '1Authorized'
                        WHEN AuthorisationStatus = 'NP' THEN 'Pending'
                   ELSE NULL
                      END AuthorisationStatus  ,
                   CreatedBy ,
                   CASE 
                        WHEN UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) IS NULL THEN ' '
                   ELSE (UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108))
                      END CreatedDate  ,
                   ModifiedBy UpdatedBy  ,
                   CASE 
                        WHEN UTILS.CONVERT_TO_VARCHAR2(DateModified,10,p_style=>103) IS NULL THEN ' '
                   ELSE (UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>108))
                      END UpdatedDate  ,
                   NVL(ModifiedBy, CreatedBy) CrModBy  ,
                   NVL(DateModified, DateCreated) CrModDate  ,
                   NVL(ApprovedBy, CreatedBy) CrAppBy  ,
                   NVL(DateApproved, DateCreated) CrAppDate  ,
                   NVL(ApprovedBy, ModifiedBy) ModAppBy  ,
                   NVL(DateApproved, DateModified) ModAppDate  
              FROM ETL_ACLFailRequestDetail 
             WHERE  EffectiveToTimeKey = 49999
                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE
         IF ( v_OperationFlag = 20 ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT RCA_Id ,
                      ETL_ACL_FAILED ,
                      UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                      UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                      UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                      ETL_ACLObservation ,
                      ETL_ACLErrorInDB ,
                      ETL_ACL_RCA ,
                      ETL_ACL_Solution ,
                      CASE 
                           WHEN AuthorisationStatus = 'A' THEN 'Authorized'
                           WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                           WHEN AuthorisationStatus = '1A' THEN '1Authorized'
                           WHEN AuthorisationStatus = 'NP' THEN 'Pending'
                      ELSE NULL
                         END AuthorisationStatus  ,
                      CreatedBy ,
                      CASE 
                           WHEN UTILS.CONVERT_TO_VARCHAR2(DateCreated,10,p_style=>103) IS NULL THEN ' '
                      ELSE (UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateCreated,30,p_style=>108))
                         END CreatedDate  ,
                      ModifiedBy UpdatedBy  ,
                      CASE 
                           WHEN UTILS.CONVERT_TO_VARCHAR2(DateModified,10,p_style=>103) IS NULL THEN ' '
                      ELSE (UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(DateModified,30,p_style=>108))
                         END UpdatedDate  ,
                      NVL(ModifiedBy, CreatedBy) CrModBy  ,
                      NVL(DateModified, DateCreated) CrModDate  ,
                      NVL(ApprovedBy, CreatedBy) CrAppBy  ,
                      NVL(DateApproved, DateCreated) CrAppDate  ,
                      NVL(ApprovedBy, ModifiedBy) ModAppBy  ,
                      NVL(DateApproved, DateModified) ModAppDate  
                 FROM ETL_ACLFailRequestDetail 
                WHERE  EffectiveToTimeKey = 49999
                         AND AuthorisationStatus IN ( '1A','1D' )
             ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
      END IF;
   END IF;
   OPEN  v_cursor FOR
      SELECT SrNo ,
             ETL_ACLName ,
             'ETL_ACLDetails' TableName  
        FROM ETL_ACLDropDown  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_21072023" TO "ADF_CDR_RBL_STGDB";
