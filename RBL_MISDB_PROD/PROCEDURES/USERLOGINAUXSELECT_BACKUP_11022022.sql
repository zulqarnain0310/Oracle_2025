--------------------------------------------------------
--  DDL for Procedure USERLOGINAUXSELECT_BACKUP_11022022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" 
(
  v_UserLoginID IN VARCHAR2,
  iv_TimeKey IN NUMBER
)
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   ---------Variable Declaration--------
   v_UserRole_Key NUMBER(10,0);
   v_UserLocationCode VARCHAR2(10);
   v_UserLocation VARCHAR2(10);
   v_cursor SYS_REFCURSOR;

BEGIN

   IF NVL(v_TimeKey, 0) = 0 THEN

   BEGIN
      SELECT TimeKey 

        INTO v_TimeKey
        FROM SysDayMatrix 
       WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(v_TimeKey);
   DBMS_OUTPUT.PUT_LINE('Mohsin');
   ---------END--------------------------
   --------------SET VALUE---------------
   SELECT UserRoleAlt_Key 

     INTO v_UserRole_Key
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   SELECT UserLocation 

     INTO v_UserLocation
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   DBMS_OUTPUT.PUT_LINE(v_UserRole_Key);
   DBMS_OUTPUT.PUT_LINE(v_UserLocation);
   IF v_UserLocation <> 'HI' THEN

   BEGIN
      SELECT UserLocationCode 

        INTO v_UserLocationCode
        FROM DimUserInfo 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND UserLoginID = v_UserLoginID;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(v_UserRole_Key);
   DBMS_OUTPUT.PUT_LINE(v_UserLocation);
   ------------END-----------------------
   IF v_UserRole_Key = 1 THEN

    --SUPER ADMIN
   BEGIN
      IF v_UserLocation = 'HO' THEN

       -- OR @UserLocation='' 
      BEGIN
         OPEN  v_cursor FOR
            SELECT UserLoginID ,
                   UserName ,
                   UserLocation ,
                   UserLocationCode ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserRole.UserRoleAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )
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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND DimUserInfo.UserLocationCode = v_UserLocationCode
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1
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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )


                      --AND dimuserinfo.UserLocationCode=@UserLocationCode 
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1
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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND DimUserInfo.UserLocationCode = v_UserLocationCode
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1
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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND UserLocationCode IN ( SELECT RegionAlt_Key 
                                                FROM DimRegion 
                                                 WHERE  RegionAlt_Key = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1
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
                   DimUserRole.UserRole_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND UserLocationCode IN ( SELECT BranchCode 
                                                FROM DimBranch 
                                                 WHERE  BranchCode = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLogged = 1
                      AND UserLocation IN ( 'BO' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);--------------

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERLOGINAUXSELECT_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
