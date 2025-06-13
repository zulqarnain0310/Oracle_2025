--------------------------------------------------------
--  DDL for Procedure SUSPENDEDUSERAUXSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" 
--Select Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --UserParameterParameterisedMasterData 16
 --USE YES_MISDB
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_UserLoginID IN VARCHAR2,
  iv_TimeKey IN NUMBER,
  v_OperationFlag IN NUMBER DEFAULT 20 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   --Declare @TimeKey AS INT
   v_DeptGroupCode VARCHAR2(10) := ' ';
   v_cursor SYS_REFCURSOR;
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551

BEGIN

   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   SELECT DeptGroupCode 

     INTO v_DeptGroupCode
     FROM DimUserInfo 
    WHERE  UserLoginID = v_UserLoginID;
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SachinTest');
            IF utils.object_id('TempDB..tt_temp_287') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_287 ';
            END IF;
            DELETE FROM tt_temp_287;
            UTILS.IDENTITY_RESET('tt_temp_287');

            INSERT INTO tt_temp_287 ( 
            	SELECT A.UserLoginID ,
                    A.UserName ,
                    A.UserLocation ,
                    A.UserLocationCode ,
                    A.RoleDescription ,
                    A.UserRole_Key ,
                    A.DepartmentName ,
                    A.ApplicableSOL ,
                    A.SuspensionDate ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifyBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT UserLoginID ,
                             UserName ,
                             UserLocation ,
                             UserLocationCode ,
                             B.UserRoleShortNameEnum RoleDescription  ,
                             B.UserRole_Key ,
                             D.DeptGroupCode DepartmentName  ,
                             ApplicableSolIds ApplicableSOL  ,
                             UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  ,
                             --Convert(Date,Getdate()) SuspensionDate,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifyBy ,
                             A.DateModified ,
                             NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifyBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM DimUserInfo A
                             JOIN DimUserRole B   ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
                           --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                             JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             AND D.DeptGroupId = A.DeptGroupCode
                             LEFT JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
            	Userid 
                                         FROM UserLoginHistory 
                                          WHERE  LoginSucceeded = 'W'
                                           GROUP BY Userid ) K   ON K.UserID = A.UserLoginID
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND SuspendedUser = 'Y'

                                --AND ShortNameEnum in('NONUSE','UNLOGON')
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                AND A.DeptGroupCode = v_DeptGroupCode
                                AND UserLoginID NOT IN ( SELECT UserLoginID 
                                                         FROM DimUserInfo_mod A
                                                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'MP','1A' )
                               )

                      UNION 
                      SELECT UserLoginID ,
                             UserName ,
                             UserLocation ,
                             UserLocationCode ,
                             B.UserRoleShortNameEnum RoleDescription  ,
                             B.UserRole_Key ,
                             D.DeptGroupCode DepartmentName  ,
                             ApplicableSolIds ApplicableSOL  ,
                             UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  ,
                             --Convert(Date,Getdate()) SuspensionDate,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifyBy ,
                             A.DateModified ,
                             NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(A.DateApproved, A.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifyBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM DimUserInfo_mod A
                             JOIN DimUserRole B   ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
                           --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                             JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             AND D.DeptGroupId = A.DeptGroupCode
                             LEFT JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                                Userid 
                                         FROM UserLoginHistory 
                                          WHERE  LoginSucceeded = 'W'
                                           GROUP BY Userid ) K   ON K.UserID = A.UserLoginID
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND SuspendedUser = 'Y'

                                --AND ShortNameEnum in('NONUSE','UNLOGON')
                                AND A.DeptGroupCode = v_DeptGroupCode
                                AND NVL(A.AuthorisationStatus, 'A') IN ( 'DP','RM' )

                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserInfo_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'DP','RM' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.UserLoginID,A.UserName,A.UserLocation,A.UserLocationCode,A.RoleDescription,A.UserRole_Key,A.DepartmentName,A.ApplicableSOL,A.SuspensionDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY UserLoginID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               * 

                        --'UserPolicyTable' TableName, 
                        FROM ( SELECT * 
                               FROM tt_temp_287 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_28716') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_232 ';
               END IF;
               DBMS_OUTPUT.PUT_LINE('Sac16');
               DELETE FROM tt_temp16_232;
               UTILS.IDENTITY_RESET('tt_temp16_232');

               INSERT INTO tt_temp16_232 ( 
               	SELECT A.UserLoginID ,
                       A.UserName ,
                       A.UserLocation ,
                       A.UserLocationCode ,
                       A.RoleDescription ,
                       A.UserRole_Key ,
                       A.DepartmentName ,
                       A.ApplicableSOL ,
                       A.SuspensionDate ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifyBy ,
                       A.DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT UserLoginID ,
                                UserName ,
                                UserLocation ,
                                UserLocationCode ,
                                B.UserRoleShortNameEnum RoleDescription  ,
                                B.UserRole_Key ,
                                D.DeptGroupCode DepartmentName  ,
                                ApplicableSolIds ApplicableSOL  ,
                                UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  ,
                                --Convert(Date,Getdate()) SuspensionDate,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifyBy ,
                                A.DateModified ,
                                NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.ApprovedByFirstLevel) CrAppBy  ,
                                NVL(A.DateApproved, A.DateApprovedFirstLevel) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifyBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModified) ModAppDate  
                         FROM DimUserInfo_mod A
                                JOIN DimUserRole B   ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
                              --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                                JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey
                                AND D.DeptGroupId = A.DeptGroupCode
                                LEFT JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                                   Userid 
                                            FROM UserLoginHistory 
                                             WHERE  LoginSucceeded = 'W'
                                              GROUP BY Userid ) K   ON K.UserID = A.UserLoginID
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND SuspendedUser = 'Y'
                                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                   AND A.DeptGroupCode = v_DeptGroupCode
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimUserInfo_mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.UserLoginID,A.UserName,A.UserLocation,A.UserLocationCode,A.RoleDescription,A.UserRole_Key,A.DepartmentName,A.ApplicableSOL,A.SuspensionDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY UserLoginID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  * 

                           --'UserPolicyTable' TableName, 
                           FROM ( SELECT * 
                                  FROM tt_temp16_232 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         IF ( v_OperationFlag IN ( 20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_28720') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_197 ';
            END IF;
            DELETE FROM tt_temp20_197;
            UTILS.IDENTITY_RESET('tt_temp20_197');

            INSERT INTO tt_temp20_197 ( 
            	SELECT A.UserLoginID ,
                    A.UserName ,
                    A.UserLocation ,
                    A.UserLocationCode ,
                    A.RoleDescription ,
                    A.UserRole_Key ,
                    A.DepartmentName ,
                    A.ApplicableSOL ,
                    A.SuspensionDate ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifyBy ,
                    A.DateModified ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT UserLoginID ,
                             UserName ,
                             UserLocation ,
                             UserLocationCode ,
                             B.UserRoleShortNameEnum RoleDescription  ,
                             B.UserRole_Key ,
                             D.DeptGroupCode DepartmentName  ,
                             ApplicableSolIds ApplicableSOL  ,
                             UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  ,
                             --Convert(Date,Getdate()) SuspensionDate,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifyBy ,
                             A.DateModified ,
                             NVL(A.ModifyBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(A.DateApproved, A.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifyBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM DimUserInfo_mod A
                             JOIN DimUserRole B   ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
                           --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                             JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey
                             AND D.DeptGroupId = A.DeptGroupCode
                             LEFT JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                                Userid 
                                         FROM UserLoginHistory 
                                          WHERE  LoginSucceeded = 'W'
                                           GROUP BY Userid ) K   ON K.UserID = A.UserLoginID
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                AND SuspendedUser = 'Y'
                                AND A.DeptGroupCode = v_DeptGroupCode
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserInfo_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.UserLoginID,A.UserName,A.UserLocation,A.UserLocationCode,A.RoleDescription,A.UserRole_Key,A.DepartmentName,A.ApplicableSOL,A.SuspensionDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY UserLoginID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               * 

                        --'UserPolicyTable' TableName, 
                        FROM ( SELECT * 
                               FROM tt_temp20_197 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT" TO "ADF_CDR_RBL_STGDB";
