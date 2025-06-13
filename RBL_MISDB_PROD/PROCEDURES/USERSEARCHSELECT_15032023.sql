--------------------------------------------------------
--  DDL for Procedure USERSEARCHSELECT_15032023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" 
--USE YES_MISDB
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_UserLoginID IN VARCHAR2,
  v_UserName IN VARCHAR2,
  v_ExtensionNo IN VARCHAR2,
  v_ApplicableSOLID IN VARCHAR2,
  v_UserDepartment IN VARCHAR2,
  v_UserRole IN VARCHAR2,
  v_Email_ID IN VARCHAR2,
  v_MobileNo IN VARCHAR2,
  v_IsChecker IN CHAR,
  --,@IsChecker2 Varchar(1)
  v_IsActive IN CHAR,
  iv_TimeKey IN NUMBER,
  v_ApplicableBacid IN VARCHAR2 DEFAULT ' ' ,
  v_LoginID IN VARCHAR2,
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14551 
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_cursor SYS_REFCURSOR;
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551

BEGIN

   --Declare @TimeKey AS INT
   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   --Declare @Authlevel InT
   --select @Authlevel=AuthLevel from SysCRisMacMenu  
   -- where MenuId=@MenuID
   IF utils.object_id('TEMPDB..tt_Dept_ALTKEY_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Dept_ALTKEY_4 ';
   END IF;
   DELETE FROM tt_Dept_ALTKEY_4;
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   IF NVL(v_UserDepartment, ' ') <> ' ' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('Dp');
      INSERT INTO tt_Dept_ALTKEY_4
        ( SELECT Items Dept_ALTKEY  
          FROM TABLE(SPLIT(v_UserDepartment, ','))  );

   END;

   --SELECT * FROM tt_Dept_ALTKEY_4
   ELSE

   BEGIN
      DBMS_OUTPUT.PUT_LINE('AB');
      INSERT INTO tt_Dept_ALTKEY_4
        ( SELECT deptgroupid Dept_ALTKEY  

          --FROM dimdepartment A
          FROM DimUserDeptGroup A
                 LEFT JOIN DimUserInfo B   ON A.DeptGroupId = B.DeptGroupCode
                 AND b.EffectiveFromTimeKey <= v_TimeKey
                 AND b.EffectiveToTimeKey >= v_TimeKey
           WHERE  B.UserLoginID = v_UserLoginID
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey );

   END;
   END IF;
   IF utils.object_id('TEMPDB..tt_BACID_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BACID_4 ';
   END IF;
   DELETE FROM tt_BACID_4;
   DBMS_OUTPUT.PUT_LINE('TABLE CREATED');
   IF NVL(v_ApplicableBacid, ' ') <> ' ' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      INSERT INTO tt_BACID_4
        ( SELECT Items BACID  
          FROM TABLE(SPLIT(v_ApplicableBacid, ','))  );

   END;

   ----SELECT * FROM tt_BACID_4
   ELSE

   BEGIN
      DBMS_OUTPUT.PUT_LINE(2);
      INSERT INTO tt_BACID_4
        ( SELECT BACID 
          FROM DimDepttoBacid 
           WHERE  DepartmentAlt_Key = 10 );

   END;
   END IF;
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SachinTest');
            IF utils.object_id('TempDB..tt_temp_306') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_306 ';
            END IF;
            DELETE FROM tt_temp_306;
            UTILS.IDENTITY_RESET('tt_temp_306');

            INSERT INTO tt_temp_306 ( 
            	SELECT A.UserLoginID ,
                    A.UserName ,
                    A.UserRole ,
                    A.RoleDescription ,
                    A.DepartmentId ,
                    A.DeptGroupCode ,
                    A.UserDepartment ,
                    A.ApplicableSOLID ,
                    A.ApplicableBACID ,
                    A.Email_ID ,
                    A.MobileNo ,
                    A.ExtensionNo ,
                    A.MobileNo1 ,
                    A.IsChecker ,
                    A.IsChecker2 ,
                    A.IsActive ,
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
                    A.ModAppDate ,
                    A.DesignationAlt_Key ,
                    A.Designation 
            	  FROM ( SELECT U.UserLoginID ,
                             U.UserName ,
                             U.UserRoleAlt_Key UserRole  ,
                             R.RoleDescription ,
                             U.DepartmentId ,
                             U.DeptGroupCode ,
                             D.DeptGroupCode UserDepartment  ,
                             CASE ---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  

                              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL SOL ID'
                             ELSE U.ApplicableSolIds
                                END ApplicableSOLID  ,
                             ----,'' AS ApplicableSOLID
                             CASE ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 

                              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL BACID'
                             ELSE U.ApplicableBACID
                                END ApplicableBACID  ,
                             U.Email_ID ,
                             SUBSTR(NVL(U.MobileNo, ' '), 1, 10) MobileNo  ,
                             SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) ExtensionNo  ,
                             U.MobileNo MobileNo1  ,
                             U.IsChecker ,
                             U.IsChecker2 ,
                             U.Activate IsActive  ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.CreatedBy) CrAppBy  ,
                             NVL(U.DateApproved, U.DateCreated) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             U.DesignationAlt_Key ,
                             Z.ParameterName Designation  

                      --select *
                      FROM DimUserInfo U
                           --LEFT JOIN DimDepartment D ON

                             LEFT JOIN DimUserDeptGroup D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey )
                             AND ( u.EffectiveFromTimeKey <= v_TimeKey
                             AND u.EffectiveToTimeKey >= v_TimeKey )
                             AND D.DeptGroupId = U.DeptGroupCode
                             LEFT JOIN DimUserRole R   ON ( R.EffectiveFromTimeKey <= v_TimeKey
                             AND R.EffectiveToTimeKey >= v_TimeKey )
                             AND ( u.EffectiveFromTimeKey <= v_TimeKey
                             AND U.EffectiveToTimeKey >= v_TimeKey )
                             AND R.UserRoleAlt_Key = U.UserRoleAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'DimUserDesignation' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_Timekey
                                                   AND EffectiveToTimeKey >= v_Timekey
            	  AND DimParameterName = 'DimUserDesignation' ) Z   ON Z.ParameterAlt_Key = U.DesignationAlt_Key
                       WHERE  ( U.UserLoginID LIKE CASE 
                                                        WHEN v_UserLoginID <> ' ' THEN '%' || v_UserLoginID || '%'
                              ELSE U.UserLoginID
                                 END )
                                AND ( NVL(U.UserName, ' ') LIKE CASE 
                                                                     WHEN v_UserName <> ' ' THEN '%' || v_UserName || '%'
                              ELSE NVL(U.UserName, ' ')
                                 END )
                                AND ( SUBSTR(NVL(U.MobileNo, ' '), 1, 10) LIKE CASE 
                                                                                    WHEN v_MobileNo <> ' ' THEN '%' || v_MobileNo || '%'
                              ELSE SUBSTR(NVL(U.MobileNo, ' '), 1, 10)
                                 END )
                                AND ( SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) LIKE CASE 
                                                                                                               WHEN v_ExtensionNo <> ' ' THEN '%' || v_ExtensionNo || '%'
                              ELSE SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' ')))
                                 END )

                                --AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM tt_Dept_ALTKEY_4))

                                -------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
                                AND ( U.UserRoleAlt_Key = CASE 
                                                               WHEN v_UserRole <> ' ' THEN v_UserRole
                              ELSE U.UserRoleAlt_Key
                                 END )
                                AND ( NVL(U.Email_ID, ' ') LIKE CASE 
                                                                     WHEN v_Email_ID <> ' ' THEN '%' || v_Email_ID || '%'
                              ELSE NVL(U.Email_ID, ' ')
                                 END )
                                AND ( NVL(U.IsChecker, ' ') LIKE CASE 
                                                                      WHEN v_IsChecker <> ' ' THEN v_IsChecker
                              ELSE U.IsChecker
                                 END )

                                --AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
                                AND ( NVL(U.Activate, ' ') LIKE CASE 
                                                                     WHEN v_IsActive <> ' ' THEN v_IsActive
                              ELSE U.Activate
                                 END )

                                ----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end

                                --AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM tt_BACID_4))
                                AND U.UserLoginID <> v_LoginID
                                AND U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(U.AuthorisationStatus, 'A') = 'A'
                      UNION 

                      --select * into DimGLProduct_Mod from DimGLProduct

                      --alter table DimGLProduct_Mod

                      --add  Remark varchar(max)

                      --,Change varchar(max)
                      SELECT U.UserLoginID ,
                             U.UserName ,
                             U.UserRoleAlt_Key UserRole  ,
                             R.RoleDescription ,
                             U.DepartmentId ,
                             U.DeptGroupCode ,
                             D.DeptGroupCode UserDepartment  ,
                             CASE ---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  

                              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL SOL ID'
                             ELSE U.ApplicableSolIds
                                END ApplicableSOLID  ,
                             ----,'' AS ApplicableSOLID
                             CASE ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 

                              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL BACID'
                             ELSE U.ApplicableBACID
                                END ApplicableBACID  ,
                             U.Email_ID ,
                             SUBSTR(NVL(U.MobileNo, ' '), 1, 10) MobileNo  ,
                             SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) ExtensionNo  ,
                             U.MobileNo ,
                             U.IsChecker ,
                             U.IsChecker2 ,
                             U.Activate IsActive  ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(U.DateApproved, U.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             U.DesignationAlt_Key ,
                             Z.ParameterName Designation  

                      --select *
                      FROM DimUserInfo_mod U
                           --LEFT JOIN DimDepartment D ON

                             LEFT JOIN DimUserDeptGroup D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey )
                             AND ( u.EffectiveFromTimeKey <= v_TimeKey
                             AND u.EffectiveToTimeKey >= v_TimeKey )
                             AND D.DeptGroupId = U.DeptGroupCode
                             LEFT JOIN DimUserRole R   ON ( R.EffectiveFromTimeKey <= v_TimeKey
                             AND R.EffectiveToTimeKey >= v_TimeKey )
                             AND ( u.EffectiveFromTimeKey <= v_TimeKey
                             AND U.EffectiveToTimeKey >= v_TimeKey )
                             AND R.UserRoleAlt_Key = U.UserRoleAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'DimUserDesignation' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_Timekey
                                                   AND EffectiveToTimeKey >= v_Timekey
                                                   AND DimParameterName = 'DimUserDesignation' ) Z   ON Z.ParameterAlt_Key = U.DesignationAlt_Key
                       WHERE  ( U.UserLoginID LIKE CASE 
                                                        WHEN v_UserLoginID <> ' ' THEN '%' || v_UserLoginID || '%'
                              ELSE U.UserLoginID
                                 END )
                                AND ( NVL(U.UserName, ' ') LIKE CASE 
                                                                     WHEN v_UserName <> ' ' THEN '%' || v_UserName || '%'
                              ELSE NVL(U.UserName, ' ')
                                 END )
                                AND ( SUBSTR(NVL(U.MobileNo, ' '), 1, 10) LIKE CASE 
                                                                                    WHEN v_MobileNo <> ' ' THEN '%' || v_MobileNo || '%'
                              ELSE SUBSTR(NVL(U.MobileNo, ' '), 1, 10)
                                 END )
                                AND ( SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) LIKE CASE 
                                                                                                               WHEN v_ExtensionNo <> ' ' THEN '%' || v_ExtensionNo || '%'
                              ELSE SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' ')))
                                 END )

                                --AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM tt_Dept_ALTKEY_4))

                                -------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
                                AND ( U.UserRoleAlt_Key = CASE 
                                                               WHEN v_UserRole <> ' ' THEN v_UserRole
                              ELSE U.UserRoleAlt_Key
                                 END )
                                AND ( NVL(U.Email_ID, ' ') LIKE CASE 
                                                                     WHEN v_Email_ID <> ' ' THEN '%' || v_Email_ID || '%'
                              ELSE NVL(U.Email_ID, ' ')
                                 END )
                                AND ( NVL(U.IsChecker, ' ') LIKE CASE 
                                                                      WHEN v_IsChecker <> ' ' THEN v_IsChecker
                              ELSE U.IsChecker
                                 END )

                                --AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
                                AND ( NVL(U.Activate, ' ') LIKE CASE 
                                                                     WHEN v_IsActive <> ' ' THEN v_IsActive
                              ELSE U.Activate
                                 END )

                                ----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end

                                --AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM tt_BACID_4))
                                AND U.UserLoginID <> v_LoginID
                                AND U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(U.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserInfo_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.UserLoginID,A.UserName,A.UserRole,A.RoleDescription,A.DepartmentId,A.DeptGroupCode,A.UserDepartment,A.ApplicableSOLID,A.ApplicableBACID,A.Email_ID,A.MobileNo,A.ExtensionNo,A.MobileNo1,A.IsChecker,A.IsChecker2,A.IsActive,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.DesignationAlt_Key,A.Designation );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY UserLoginID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               * 

                        --'QuickSearchTable' TableName, 
                        FROM ( SELECT * 
                               FROM tt_temp_306 A ) 
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
               IF utils.object_id('TempDB..tt_temp_30616') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_249 ';
               END IF;
               DELETE FROM tt_temp16_249;
               UTILS.IDENTITY_RESET('tt_temp16_249');

               INSERT INTO tt_temp16_249 ( 
               	SELECT A.UserLoginID ,
                       A.UserName ,
                       A.UserRole ,
                       A.RoleDescription ,
                       A.DepartmentId ,
                       A.DeptGroupCode ,
                       A.UserDepartment ,
                       A.ApplicableSOLID ,
                       A.ApplicableBACID ,
                       A.Email_ID ,
                       A.MobileNo ,
                       A.ExtensionNo ,
                       A.MobileNo1 ,
                       A.IsChecker ,
                       A.IsChecker2 ,
                       A.IsActive ,
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
                       A.ModAppDate ,
                       A.DesignationAlt_Key ,
                       A.Designation 
               	  FROM ( SELECT U.UserLoginID ,
                                U.UserName ,
                                U.UserRoleAlt_Key UserRole  ,
                                R.RoleDescription ,
                                U.DepartmentId ,
                                U.DeptGroupCode ,
                                D.DeptGroupCode UserDepartment  ,
                                CASE ---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  

                                 WHEN D.DeptGroupCode = 'FNA' THEN 'ALL SOL ID'
                                ELSE U.ApplicableSolIds
                                   END ApplicableSOLID  ,
                                ----,'' AS ApplicableSOLID
                                CASE ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 

                                 WHEN D.DeptGroupCode = 'FNA' THEN 'ALL BACID'
                                ELSE U.ApplicableBACID
                                   END ApplicableBACID  ,
                                U.Email_ID ,
                                SUBSTR(NVL(U.MobileNo, ' '), 1, 10) MobileNo  ,
                                SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) ExtensionNo  ,
                                U.MobileNo MobileNo1  ,
                                U.IsChecker ,
                                U.IsChecker2 ,
                                U.Activate IsActive  ,
                                --,'QuickSearchTable' as TableName
                                NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                U.EffectiveFromTimeKey ,
                                U.EffectiveToTimeKey ,
                                U.CreatedBy ,
                                U.DateCreated ,
                                U.ApprovedBy ,
                                U.DateApproved ,
                                U.ModifyBy ,
                                U.DateModified ,
                                NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                                NVL(U.DateModified, U.DateCreated) CrModDate  ,
                                NVL(U.ApprovedBy, U.ApprovedByFirstLevel) CrAppBy  ,
                                NVL(U.DateApproved, U.DateApprovedFirstLevel) CrAppDate  ,
                                NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                                NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                                U.DesignationAlt_Key ,
                                Z.ParameterName Designation  

                         --select *
                         FROM DimUserInfo_mod U
                              --LEFT JOIN DimDepartment D ON

                                LEFT JOIN DimUserDeptGroup D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
                                AND D.EffectiveToTimeKey >= v_TimeKey )
                                AND ( u.EffectiveFromTimeKey <= v_TimeKey
                                AND u.EffectiveToTimeKey >= v_TimeKey )
                                AND D.DeptGroupId = U.DeptGroupCode
                                LEFT JOIN DimUserRole R   ON ( R.EffectiveFromTimeKey <= v_TimeKey
                                AND R.EffectiveToTimeKey >= v_TimeKey )
                                AND ( u.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey )
                                AND R.UserRoleAlt_Key = U.UserRoleAlt_Key
                                LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                   ParameterName ,
                                                   'DimUserDesignation' TableName  
                                            FROM DimParameter 
                                             WHERE  EffectiveFromTimeKey <= v_Timekey
                                                      AND EffectiveToTimeKey >= v_Timekey
                                                      AND DimParameterName = 'DimUserDesignation' ) Z   ON Z.ParameterAlt_Key = U.DesignationAlt_Key
                          WHERE  ( U.UserLoginID LIKE CASE 
                                                           WHEN v_UserLoginID <> ' ' THEN '%' || v_UserLoginID || '%'
                                 ELSE U.UserLoginID
                                    END )
                                   AND ( NVL(U.UserName, ' ') LIKE CASE 
                                                                        WHEN v_UserName <> ' ' THEN '%' || v_UserName || '%'
                                 ELSE NVL(U.UserName, ' ')
                                    END )
                                   AND ( SUBSTR(NVL(U.MobileNo, ' '), 1, 10) LIKE CASE 
                                                                                       WHEN v_MobileNo <> ' ' THEN '%' || v_MobileNo || '%'
                                 ELSE SUBSTR(NVL(U.MobileNo, ' '), 1, 10)
                                    END )
                                   AND ( SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) LIKE CASE 
                                                                                                                  WHEN v_ExtensionNo <> ' ' THEN '%' || v_ExtensionNo || '%'
                                 ELSE SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' ')))
                                    END )

                                   --AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM tt_Dept_ALTKEY_4))

                                   -------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
                                   AND ( U.UserRoleAlt_Key = CASE 
                                                                  WHEN v_UserRole <> ' ' THEN v_UserRole
                                 ELSE U.UserRoleAlt_Key
                                    END )
                                   AND ( NVL(U.Email_ID, ' ') LIKE CASE 
                                                                        WHEN v_Email_ID <> ' ' THEN '%' || v_Email_ID || '%'
                                 ELSE NVL(U.Email_ID, ' ')
                                    END )
                                   AND ( NVL(U.IsChecker, ' ') LIKE CASE 
                                                                         WHEN v_IsChecker <> ' ' THEN v_IsChecker
                                 ELSE U.IsChecker
                                    END )

                                   --AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
                                   AND ( NVL(U.Activate, ' ') LIKE CASE 
                                                                        WHEN v_IsActive <> ' ' THEN v_IsActive
                                 ELSE U.Activate
                                    END )

                                   ----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end

                                   --AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM tt_BACID_4))
                                   AND U.UserLoginID <> v_LoginID
                                   AND U.EffectiveFromTimeKey <= v_TimeKey
                                   AND U.EffectiveToTimeKey >= v_TimeKey
                                   AND U.ScreenFlag <> 'U'
                                   AND NVL(U.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                   AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimUserInfo_mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.UserLoginID,A.UserName,A.UserRole,A.RoleDescription,A.DepartmentId,A.DeptGroupCode,A.UserDepartment,A.ApplicableSOLID,A.ApplicableBACID,A.Email_ID,A.MobileNo,A.ExtensionNo,A.MobileNo1,A.IsChecker,A.IsChecker2,A.IsActive,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.DesignationAlt_Key,A.Designation );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY UserLoginID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  * 

                           --'QuickSearchTable' TableName, 
                           FROM ( SELECT * 
                                  FROM tt_temp16_249 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize)
         IF ( v_OperationFlag IN ( 20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_30620') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_214 ';
            END IF;
            DELETE FROM tt_temp20_214;
            UTILS.IDENTITY_RESET('tt_temp20_214');

            INSERT INTO tt_temp20_214 ( 
            	SELECT A.UserLoginID ,
                    A.UserName ,
                    A.UserRole ,
                    A.RoleDescription ,
                    A.DepartmentId ,
                    A.DeptGroupCode ,
                    A.UserDepartment ,
                    A.ApplicableSOLID ,
                    A.ApplicableBACID ,
                    A.Email_ID ,
                    A.MobileNo ,
                    A.ExtensionNo ,
                    A.MobileNo1 ,
                    A.IsChecker ,
                    A.IsChecker2 ,
                    A.IsActive ,
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
                    A.ModAppDate ,
                    A.DesignationAlt_Key ,
                    A.Designation 
            	  FROM ( SELECT U.UserLoginID ,
                             U.UserName ,
                             U.UserRoleAlt_Key UserRole  ,
                             R.RoleDescription ,
                             U.DepartmentId ,
                             U.DeptGroupCode ,
                             D.DeptGroupCode UserDepartment  ,
                             CASE ---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  

                              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL SOL ID'
                             ELSE U.ApplicableSolIds
                                END ApplicableSOLID  ,
                             ----,'' AS ApplicableSOLID
                             CASE ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 

                              WHEN D.DeptGroupCode = 'FNA' THEN 'ALL BACID'
                             ELSE U.ApplicableBACID
                                END ApplicableBACID  ,
                             U.Email_ID ,
                             SUBSTR(NVL(U.MobileNo, ' '), 1, 10) MobileNo  ,
                             SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) ExtensionNo  ,
                             U.MobileNo MobileNo1  ,
                             U.IsChecker ,
                             U.IsChecker2 ,
                             U.Activate IsActive  ,
                             --,'QuickSearchTable' as TableName
                             NVL(U.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             U.EffectiveFromTimeKey ,
                             U.EffectiveToTimeKey ,
                             U.CreatedBy ,
                             U.DateCreated ,
                             U.ApprovedBy ,
                             U.DateApproved ,
                             U.ModifyBy ,
                             U.DateModified ,
                             NVL(U.ModifyBy, U.CreatedBy) CrModBy  ,
                             NVL(U.DateModified, U.DateCreated) CrModDate  ,
                             NVL(U.ApprovedBy, U.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(U.DateApproved, U.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(U.ApprovedBy, U.ModifyBy) ModAppBy  ,
                             NVL(U.DateApproved, U.DateModified) ModAppDate  ,
                             U.DesignationAlt_Key ,
                             Z.ParameterName Designation  

                      --select *
                      FROM DimUserInfo_mod U
                           --LEFT JOIN DimDepartment D ON

                             LEFT JOIN DimUserDeptGroup D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
                             AND D.EffectiveToTimeKey >= v_TimeKey )
                             AND ( u.EffectiveFromTimeKey <= v_TimeKey
                             AND u.EffectiveToTimeKey >= v_TimeKey )
                             AND D.DeptGroupId = U.DeptGroupCode
                             LEFT JOIN DimUserRole R   ON ( R.EffectiveFromTimeKey <= v_TimeKey
                             AND R.EffectiveToTimeKey >= v_TimeKey )
                             AND ( u.EffectiveFromTimeKey <= v_TimeKey
                             AND U.EffectiveToTimeKey >= v_TimeKey )
                             AND R.UserRoleAlt_Key = U.UserRoleAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'DimUserDesignation' TableName  
                                         FROM DimParameter 
                                          WHERE  EffectiveFromTimeKey <= v_Timekey
                                                   AND EffectiveToTimeKey >= v_Timekey
                                                   AND DimParameterName = 'DimUserDesignation' ) Z   ON Z.ParameterAlt_Key = U.DesignationAlt_Key
                       WHERE  ( U.UserLoginID LIKE CASE 
                                                        WHEN v_UserLoginID <> ' ' THEN '%' || v_UserLoginID || '%'
                              ELSE U.UserLoginID
                                 END )
                                AND ( NVL(U.UserName, ' ') LIKE CASE 
                                                                     WHEN v_UserName <> ' ' THEN '%' || v_UserName || '%'
                              ELSE NVL(U.UserName, ' ')
                                 END )
                                AND ( SUBSTR(NVL(U.MobileNo, ' '), 1, 10) LIKE CASE 
                                                                                    WHEN v_MobileNo <> ' ' THEN '%' || v_MobileNo || '%'
                              ELSE SUBSTR(NVL(U.MobileNo, ' '), 1, 10)
                                 END )
                                AND ( SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' '))) LIKE CASE 
                                                                                                               WHEN v_ExtensionNo <> ' ' THEN '%' || v_ExtensionNo || '%'
                              ELSE SUBSTR(NVL(U.MobileNo, ' '), 12, LENGTH(NVL(U.MobileNo, ' ')))
                                 END )

                                --AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM tt_Dept_ALTKEY_4))

                                -------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
                                AND ( U.UserRoleAlt_Key = CASE 
                                                               WHEN v_UserRole <> ' ' THEN v_UserRole
                              ELSE U.UserRoleAlt_Key
                                 END )
                                AND ( NVL(U.Email_ID, ' ') LIKE CASE 
                                                                     WHEN v_Email_ID <> ' ' THEN '%' || v_Email_ID || '%'
                              ELSE NVL(U.Email_ID, ' ')
                                 END )
                                AND ( NVL(U.IsChecker, ' ') LIKE CASE 
                                                                      WHEN v_IsChecker <> ' ' THEN v_IsChecker
                              ELSE U.IsChecker
                                 END )

                                --AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
                                AND ( NVL(U.Activate, ' ') LIKE CASE 
                                                                     WHEN v_IsActive <> ' ' THEN v_IsActive
                              ELSE U.Activate
                                 END )

                                ----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end

                                --AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM tt_BACID_4))
                                AND U.UserLoginID <> v_LoginID
                                AND U.EffectiveFromTimeKey <= v_TimeKey
                                AND U.EffectiveToTimeKey >= v_TimeKey
                                AND U.ScreenFlag <> 'U'
                                AND NVL(U.AuthorisationStatus, 'A') IN ( '1A' )

                                AND U.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimUserInfo_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.UserLoginID,A.UserName,A.UserRole,A.RoleDescription,A.DepartmentId,A.DeptGroupCode,A.UserDepartment,A.ApplicableSOLID,A.ApplicableBACID,A.Email_ID,A.MobileNo,A.ExtensionNo,A.MobileNo1,A.IsChecker,A.IsChecker2,A.IsActive,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifyBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.DesignationAlt_Key,A.Designation );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY UserLoginID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               * 

                        --'CollateralSubTypeMaster' TableName, 
                        FROM ( SELECT * 
                               FROM tt_temp20_214 A ) 
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
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERSEARCHSELECT_15032023" TO "ADF_CDR_RBL_STGDB";
