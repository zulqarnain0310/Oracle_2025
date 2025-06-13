--------------------------------------------------------
--  DDL for Procedure SUSPENDEDUSERAUXSELECT_08112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" 
(
  v_UserLoginID IN VARCHAR2,
  iv_TimeKey IN NUMBER
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   --DECLARE @UserLoginID varchar(20) ='FNASUPERADMIN',
   --  @TimeKey INT  =25567
   ---------Variable Declaration--------
   v_UserRole_Key NUMBER(10,0);
   v_UserLocationCode VARCHAR2(10);
   v_UserLocation VARCHAR2(10);
   v_DepartmentCode VARCHAR2(20);
   v_DepartmentAlt_Key NUMBER(10,0);
   --IF @UserLocation='HO'-- OR @UserLocation='' 
   --BEGIN
   v_cursor SYS_REFCURSOR;

BEGIN

   --SELECT @Timekey=Max(Timekey) from SysProcessingCycle  
   --  WHERE Extracted='Y' ---and ProcessType='Full' --and PreMOC_CycleFrozenDate IS NULL  
   IF NVL(v_TimeKey, 0) = 0 THEN

   BEGIN
      --Select @TimeKey=TimeKey from SysDayMatrix where [Date]=Cast(Getdate() as Date)
      SELECT ( SELECT Timekey 
               FROM SysDataMatrix 
                WHERE  CurrentStatus = 'C' ) 

        INTO v_Timekey
        FROM DUAL ;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   DBMS_OUTPUT.PUT_LINE('Amol');
   ---------END--------------------------
   --------------SET VALUE---------------
   SELECT UserRoleAlt_Key 

     INTO v_UserRole_Key
     FROM DimUserInfo 
    WHERE  UserLoginID = v_UserLoginID
             AND ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey );
   DBMS_OUTPUT.PUT_LINE('Amol1');
   SELECT NVL(UserLocation, 'HO') 

     INTO v_UserLocation
     FROM DimUserInfo 
    WHERE  UserLoginID = v_UserLoginID
             AND ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey );
   DBMS_OUTPUT.PUT_LINE('Amol2');
   IF NVL(v_UserLocation, ' ') = ' ' THEN

   BEGIN
      v_UserLocation := 'HO' ;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(v_UserLocation);
   DBMS_OUTPUT.PUT_LINE(v_UserRole_Key);
   SELECT DEP.DeptGroupCode ,
          DEP.DeptGroupId 

     INTO v_DepartmentCode,
          v_DepartmentAlt_Key
     FROM DimUserInfo INFO
          --INNER JOIN DimDepartment	DEP

            JOIN DimUserDeptGroup DEP   ON INFO.EffectiveFromTimeKey <= v_Timekey
            AND INFO.EffectiveToTimeKey >= v_Timekey
            AND DEP.EffectiveFromTimeKey <= v_Timekey
            AND DEP.EffectiveToTimeKey >= v_Timekey
            AND UserLoginID = v_UserLoginId
            AND INFO.DepartmentId = DEP.DeptGroupId;
   DBMS_OUTPUT.PUT_LINE(v_DepartmentCode);
   IF v_UserLocation <> 'HI' THEN

   BEGIN
      SELECT UserLocationCode 

        INTO v_UserLocationCode
        FROM DimUserInfo 
       WHERE  UserLoginID = v_UserLoginID
                AND ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey );

   END;
   END IF;
   ------------END-----------------------
   IF v_UserRole_Key = 1 THEN

    --SUPER ADMIN
   BEGIN
      OPEN  v_cursor FOR
         SELECT UserLoginID ,
                UserName ,
                UserLocation ,
                UserLocationCode ,
                DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                DimUserRole.UserRole_Key ,
                D.DeptGroupCode DepartmentName  ,
                ApplicableSolIds ApplicableSOL  ,
                UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
           FROM DimUserInfo 
                  JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                  JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  AND D.DeptGroupId = DimUserInfo.DepartmentId
                  AND (CASE 
                            WHEN v_DepartmentCode IN ( 'FNA' )
                             THEN 1
                            WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                  JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                Userid 
                         FROM UserLoginHistory 
                          WHERE  LoginSucceeded = 'W'
                           GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
          WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                   AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                   AND UserLoginID <> (v_UserLoginID)
                   AND SuspendedUser = 'Y' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   -- END
   IF v_UserRole_Key = 2 THEN

    -- ADMIN
   BEGIN
      IF v_UserLocation = 'HO' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode DepartmentName  ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                   --Inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                     JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupId = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND UserLoginID <> (v_UserLoginID)
                      AND SuspendedUser = 'Y'
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'ZO' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode DepartmentName  ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                   --Inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                     JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupId = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' --dimuserinfo.UserRole_Key IN(2,3,4) 
                     )

                      AND DimUserInfo.UserLocationCode = v_UserLocationCode
                      AND UserLoginID <> (v_UserLoginID)
                      AND SuspendedUser = 'Y'
                      AND UserLocation IN ( 'ZO','RO','BO' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'HI' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode DepartmentName  ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                     JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupId = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' )


                      --AND dimuserinfo.UserLocationCode=@UserLocationCode 
                      AND UserLoginID <> (v_UserLoginID)
                      AND SuspendedUser = 'Y'
                      AND UserLocation IN ( 'HI','RI' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'RI' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode DepartmentName  ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                     JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupId = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' )

                      AND DimUserInfo.UserLocationCode = v_UserLocationCode
                      AND UserLoginID <> (v_UserLoginID)
                      AND SuspendedUser = 'Y'
                      AND UserLocation IN ( 'RI' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'RO' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                   --Inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                     JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupID = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' )

                      AND UserLocationCode IN ( SELECT BranchCode 
                                                FROM DimBranch 
                                                       JOIN DimRegion    ON DimBranch.BranchRegionAlt_Key = DimRegion.RegionAlt_Key
                                                 WHERE  DimRegion.RegionAlt_Key = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLocation IN ( 'RO','BO' )

            UNION ALL 
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode DepartmentName  ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                   --Inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                     JOIN Dimdeptgroupcode D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupID = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' )

                      AND UserLocationCode IN ( SELECT RegionAlt_Key 
                                                FROM DimRegion 
                                                 WHERE  RegionAlt_Key = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
                      AND SuspendedUser = 'Y'
                      AND UserLocation IN ( 'RO','BO' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'BO' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRole_Key ,
                   D.DeptGroupCode DepartmentName  ,
                   ApplicableSolIds ApplicableSOL  ,
                   UTILS.CONVERT_TO_VARCHAR2(K.SuspensionDate,10,p_style=>103) SuspensionDate  
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                   --Inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey

                     JOIN DimDeptGroupCode D   ON D.EffectiveFromTimeKey <= v_TimeKey
                     AND D.EffectiveToTimeKey >= v_TimeKey
                     AND D.DeptGroupId = DimUserInfo.DepartmentId
                     AND (CASE 
                               WHEN v_DepartmentCode IN ( 'FNA' )
                                THEN 1
                               WHEN v_DepartmentAlt_Key = DepartmentId THEN 1   END) = 1
                     JOIN ( SELECT MAX(loginTime)  SuspensionDate  ,
                                   Userid 
                            FROM UserLoginHistory 
                             WHERE  LoginSucceeded = 'W'
                              GROUP BY Userid ) K   ON K.UserID = DimUserInfo.UserLoginID
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserRole.UserRoleShortNameEnum IN ( 'ADMIN','OPERATOR','VIEWER' )

                      AND UserLocationCode IN ( SELECT BranchCode 
                                                FROM DimBranch 
                                                 WHERE  BranchCode = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
                      AND SuspendedUser = 'Y'
                      AND UserLocation IN ( 'BO' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SUSPENDEDUSERAUXSELECT_08112021" TO "ADF_CDR_RBL_STGDB";
