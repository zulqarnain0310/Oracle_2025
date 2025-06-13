--------------------------------------------------------
--  DDL for Procedure ETL_ACLFAILREQUESTDETAILSELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" 
-- ========================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<20/07/2023>
 -- DESCRIPTION:			<ETL-ACL FAILURE SCREEN SELECT>
 -- =========================================================

(
  v_UserLoginID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 16 ,
  v_MenuID IN NUMBER DEFAULT 27776 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   BEGIN

      BEGIN
         --------- IMPLEMENT LOGIC BY SATWAJI AS ON 24/07/2023 AS EXPIRES ALL THE RECORDS WHEN AUTHORIZED DATE EXCEEDS 24 HOURS  --------------
         DBMS_OUTPUT.PUT_LINE('Expire in Main Table');
         UPDATE ETL_ACLFailRequestDetail
            SET AuthorisationStatus = 'EP'
          WHERE  EffectiveToTimeKey = 49999
           AND ( utils.datediff('SECOND', DateCreated, SYSDATE) > 86400 )

           --AND (DATEDIFF(HOUR,DateApproved,GETDATE())>24)
           AND NVL(AuthorisationStatus, 'A') = 'A';
         DBMS_OUTPUT.PUT_LINE('Expire in Mod Table');
         UPDATE ETL_ACLFailRequestDetail_Mod
            SET AuthorisationStatus = 'EP'
          WHERE  EffectiveToTimeKey = 49999
           AND ( utils.datediff('SECOND', DateCreated, SYSDATE) > 86400 )

           --AND (DATEDIFF(HOUR,DateApproved,GETDATE())>24)
           AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','A','1A','1D' )
         ;
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_131') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_131 ';
            END IF;
            DELETE FROM tt_temp_131;
            UTILS.IDENTITY_RESET('tt_temp_131');

            INSERT INTO tt_temp_131 ( 
            	SELECT A.RCA_Id ,
                    A.ETL_ACL_FAILED ,
                    A.ACLFailuerdate ,
                    A.Processingdate ,
                    A.DateofData ,
                    A.ETL_ACLObservation ,
                    A.ETL_ACLErrorInDB ,
                    A.ETL_ACL_RCA ,
                    A.ETL_ACL_Solution ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT RCA_Id ,
                             ETL_ACL_FAILED ,
                             UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                             UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                             UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                             ETL_ACLObservation ,
                             ETL_ACLErrorInDB ,
                             ETL_ACL_RCA ,
                             ETL_ACL_Solution ,
                             CASE 
                                  WHEN NVL(AuthorisationStatus, 'A') = 'A' THEN 'Second Level Authorized'
                                  WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                                  WHEN AuthorisationStatus IN ( '1A','1D' )
                                   THEN 'First Level Authorized'
                                  WHEN AuthorisationStatus = 'EP' THEN 'Expired'
                                  WHEN AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus  ,
                             --,CASE WHEN ISNULL(AuthorisationStatus, 'A') AuthorisationStatus
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             CreatedBy ,
                             DateCreated ,
                             ModifiedBy ,
                             DateModified ,
                             ApprovedBy ,
                             DateApproved ,
                             NVL(ModifiedBy, CreatedBy) CrModBy  ,
                             NVL(DateModified, DateCreated) CrModDate  ,
                             NVL(ApprovedByFirstLevel, CreatedBy) CrAppBy  ,
                             NVL(DateApprovedFirstLevel, DateCreated) CrAppDate  ,
                             NVL(ApprovedByFirstLevel, ModifiedBy) ModAppBy  ,
                             NVL(DateApprovedFirstLevel, DateModified) ModAppDate  
                      FROM ETL_ACLFailRequestDetail 
                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND NVL(AuthorisationStatus, 'A') IN ( 'A','EP' )

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
                                  WHEN NVL(AuthorisationStatus, 'A') = 'A' THEN 'Second Level Authorized'
                                  WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                                  WHEN AuthorisationStatus IN ( '1A','1D' )
                                   THEN 'First Level Authorized'
                                  WHEN AuthorisationStatus = 'EP' THEN 'Expired'
                                  WHEN AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                   THEN 'Pending'
                             ELSE NULL
                                END AuthorisationStatus  ,
                             --,ISNULL(AuthorisationStatus, 'A') AuthorisationStatus
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             CreatedBy ,
                             DateCreated ,
                             ModifiedBy ,
                             DateModified ,
                             ApprovedBy ,
                             DateApproved ,
                             NVL(ModifiedBy, CreatedBy) CrModBy  ,
                             NVL(DateModified, DateCreated) CrModDate  ,
                             NVL(ApprovedByFirstLevel, CreatedBy) CrAppBy  ,
                             NVL(DateApprovedFirstLevel, DateCreated) CrAppDate  ,
                             NVL(ApprovedByFirstLevel, ModifiedBy) ModAppBy  ,
                             NVL(DateApprovedFirstLevel, DateModified) ModAppDate  
                      FROM ETL_ACLFailRequestDetail_Mod 
                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND EntityKey IN ( SELECT MAX(EntityKey)  
                                                   FROM ETL_ACLFailRequestDetail_Mod 
                                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                             AND EffectiveToTimeKey >= v_TimeKey )
                                                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A','1D','EP' )

                                                     GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.RCA_Id,A.ETL_ACL_FAILED,A.ACLFailuerdate,A.Processingdate,A.DateofData,A.ETL_ACLObservation,A.ETL_ACLErrorInDB,A.ETL_ACL_RCA,A.ETL_ACL_Solution,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RCA_Id  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'ETL_ACLFailRequestDetails' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_131 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_13116') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_101 ';
               END IF;
               DELETE FROM tt_temp16_101;
               UTILS.IDENTITY_RESET('tt_temp16_101');

               INSERT INTO tt_temp16_101 ( 
               	SELECT A.RCA_Id ,
                       A.ETL_ACL_FAILED ,
                       A.ACLFailuerdate ,
                       A.Processingdate ,
                       A.DateofData ,
                       A.ETL_ACLObservation ,
                       A.ETL_ACLErrorInDB ,
                       A.ETL_ACL_RCA ,
                       A.ETL_ACL_Solution ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT RCA_Id ,
                                ETL_ACL_FAILED ,
                                UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                                UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                                UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                                ETL_ACLObservation ,
                                ETL_ACLErrorInDB ,
                                ETL_ACL_RCA ,
                                ETL_ACL_Solution ,
                                CASE 
                                     WHEN NVL(AuthorisationStatus, 'A') = 'A' THEN 'Second Level Authorized'
                                     WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                                     WHEN AuthorisationStatus IN ( '1A','1D' )
                                      THEN 'First Level Authorized'
                                     WHEN AuthorisationStatus = 'EP' THEN 'Expired'
                                     WHEN AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                      THEN 'Pending'
                                ELSE NULL
                                   END AuthorisationStatus  ,
                                --,ISNULL(AuthorisationStatus, 'A') AuthorisationStatus
                                EffectiveFromTimeKey ,
                                EffectiveToTimeKey ,
                                CreatedBy ,
                                DateCreated ,
                                ModifiedBy ,
                                DateModified ,
                                ApprovedBy ,
                                DateApproved ,
                                NVL(ModifiedBy, CreatedBy) CrModBy  ,
                                NVL(DateModified, DateCreated) CrModDate  ,
                                NVL(ApprovedByFirstLevel, CreatedBy) CrAppBy  ,
                                NVL(DateApprovedFirstLevel, DateCreated) CrAppDate  ,
                                NVL(ApprovedByFirstLevel, ModifiedBy) ModAppBy  ,
                                NVL(DateApprovedFirstLevel, DateModified) ModAppDate  
                         FROM ETL_ACLFailRequestDetail_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND NVL(ModifiedBy, CreatedBy) <> v_UserLoginId
                                   AND EntityKey IN ( SELECT MAX(EntityKey)  
                                                      FROM ETL_ACLFailRequestDetail_Mod 
                                                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey )
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                        GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.RCA_Id,A.ETL_ACL_FAILED,A.ACLFailuerdate,A.Processingdate,A.DateofData,A.ETL_ACLObservation,A.ETL_ACLErrorInDB,A.ETL_ACL_RCA,A.ETL_ACL_Solution,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RCA_Id  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'ETL_ACLFailRequestDetails' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_101 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize);
            ELSE
               IF ( v_OperationFlag IN ( 20 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_13120') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_66 ';
                  END IF;
                  DELETE FROM tt_temp20_66;
                  UTILS.IDENTITY_RESET('tt_temp20_66');

                  INSERT INTO tt_temp20_66 ( 
                  	SELECT A.RCA_Id ,
                          A.ETL_ACL_FAILED ,
                          A.ACLFailuerdate ,
                          A.Processingdate ,
                          A.DateofData ,
                          A.ETL_ACLObservation ,
                          A.ETL_ACLErrorInDB ,
                          A.ETL_ACL_RCA ,
                          A.ETL_ACL_Solution ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT RCA_Id ,
                                   ETL_ACL_FAILED ,
                                   UTILS.CONVERT_TO_VARCHAR2(ACLFailuerdate,10,p_style=>103) ACLFailuerdate  ,
                                   UTILS.CONVERT_TO_VARCHAR2(Processingdate,10,p_style=>103) Processingdate  ,
                                   UTILS.CONVERT_TO_VARCHAR2(DateofData,10,p_style=>103) DateofData  ,
                                   ETL_ACLObservation ,
                                   ETL_ACLErrorInDB ,
                                   ETL_ACL_RCA ,
                                   ETL_ACL_Solution ,
                                   CASE 
                                        WHEN NVL(AuthorisationStatus, 'A') = 'A' THEN 'Second Level Authorized'
                                        WHEN AuthorisationStatus = 'R' THEN 'Rejected'
                                        WHEN AuthorisationStatus IN ( '1A','1D' )
                                         THEN 'First Level Authorized'
                                        WHEN AuthorisationStatus = 'EP' THEN 'Expired'
                                        WHEN AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                         THEN 'Pending'
                                   ELSE NULL
                                      END AuthorisationStatus  ,
                                   --,ISNULL(AuthorisationStatus, 'A') AuthorisationStatus
                                   EffectiveFromTimeKey ,
                                   EffectiveToTimeKey ,
                                   CreatedBy ,
                                   DateCreated ,
                                   ModifiedBy ,
                                   DateModified ,
                                   ApprovedBy ,
                                   DateApproved ,
                                   NVL(ModifiedBy, CreatedBy) CrModBy  ,
                                   NVL(DateModified, DateCreated) CrModDate  ,
                                   NVL(ApprovedByFirstLevel, CreatedBy) CrAppBy  ,
                                   NVL(DateApprovedFirstLevel, DateCreated) CrAppDate  ,
                                   NVL(ApprovedByFirstLevel, ModifiedBy) ModAppBy  ,
                                   NVL(DateApprovedFirstLevel, DateModified) ModAppDate  
                            FROM ETL_ACLFailRequestDetail_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND NVL(NVL(ApprovedByFirstLevel, ' '), NVL(ModifiedBy, ' ')) <> v_UserLoginId
                                      AND NVL(ModifiedBy, CreatedBy) <> v_UserLoginId
                                      AND EntityKey IN ( SELECT MAX(EntityKey)  
                                                         FROM ETL_ACLFailRequestDetail_Mod 
                                                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey )

                                                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                                                                   AND (CASE 
                                                                             WHEN v_AuthLevel = 2
                                                                               AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
                  	 THEN 1
                  	WHEN v_AuthLevel = 1
                  	  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
                  	 THEN 1
                                                                 ELSE 0
                                                                    END) = 1
                                                           GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.RCA_Id,A.ETL_ACL_FAILED,A.ACLFailuerdate,A.Processingdate,A.DateofData,A.ETL_ACLObservation,A.ETL_ACLErrorInDB,A.ETL_ACL_RCA,A.ETL_ACL_Solution,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY RCA_Id  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'ETL_ACLFailRequestDetails' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_66 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner
                       ORDER BY DataPointOwner.DateCreated DESC ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;
            END IF;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize);
         OPEN  v_cursor FOR
            SELECT SrNo ,
                   ETL_ACLName ,
                   'ETL_ACLDetails' TableName  
              FROM ETL_ACLDropDown  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         OPEN  v_cursor FOR
            SELECT (UTILS.CONVERT_TO_VARCHAR2(Date_,10,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(Date_,30,p_style=>108)) ETLACLFailureDate  ,
                   ErrorDescription ErrorInDB  ,
                   'ErrorDetails' TableName  
              FROM ( SELECT * ,
                            ROW_NUMBER() OVER ( ORDER BY Date_ DESC, ID DESC  ) RN  
                     FROM RBL_STGDB.PackageErrorLogs  ) A
             WHERE  RN = 1 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETL_ACLFAILREQUESTDETAILSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
