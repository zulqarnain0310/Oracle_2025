--------------------------------------------------------
--  DDL for Procedure USERMODIFICATIONAUXSELECT_NEW_08112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" 
(
  v_UserLoginId IN VARCHAR2,
  iv_UserLocationCode IN VARCHAR2,
  iv_UserLocation IN VARCHAR2,
  v_TimeKey IN NUMBER
)
AS
   v_UserLocation VARCHAR2(2) := iv_UserLocation;
   v_UserLocationCode VARCHAR2(10) := iv_UserLocationCode;
   v_UserRoleAlt_Key NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

 -- Nitin : 21 Dec 2010
BEGIN

   ---------END--------------------------
   --------------SET VALUE---------------
   SELECT UserRoleAlt_Key 

     INTO v_UserRoleAlt_Key
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   DBMS_OUTPUT.PUT_LINE(v_UserRoleAlt_Key);
   SELECT UserLocation 

     INTO v_UserLocation
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   IF v_UserLocation = 'HI' THEN

   BEGIN
      v_UserLocationCode := 0 ;

   END;
   ELSE

   BEGIN
      SELECT UserLocationCode 

        INTO v_UserLocationCode
        FROM DimUserInfo 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND UserLoginID = v_UserLoginID;

   END;
   END IF;
   ------------END-----------------------
   IF v_UserRoleAlt_Key = 1 THEN

    --SUPER ADMIN
   BEGIN
      IF v_UserLocation = 'HO' THEN

       -- OR @UserLocation='' 
      BEGIN
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   DimUserInfo.DesignationAlt_Key ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.UserType ,
                   'Y' IsMainTable  ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND UserLoginID <> (v_UserLoginID) ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   IF v_UserRoleAlt_Key = 2 THEN

    -- ADMIN
   BEGIN
      DBMS_OUTPUT.PUT_LINE(2);
      IF v_UserLocation = 'HO' THEN

       -- OR @UserLocation='' 
      BEGIN
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   DimUserInfo.DesignationAlt_Key ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.UserType ,
                   DimUserInfo.CreatedBy ,
                   'Y' IsMainTable  ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND UserLoginID <> (v_UserLoginID)
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      --AND UserLocationCode IN(SELECT RegionAlt_Key from   Dimregion where RegionAlt_Key=@UserLocationCode )
      IF v_UserLocation = 'ZO' THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   DimUserInfo.DesignationAlt_Key ,
                   'Y' IsMainTable  ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.UserType ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND DimUserInfo.UserLocationCode = v_UserLocationCode
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLocation IN ( 'ZO','RO','BO' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'HI' THEN

       --AMAR 15032011
      BEGIN
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   DimUserInfo.DesignationAlt_Key ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )


                      --AND dimuserinfo.UserLocationCode=@UserLocationCode 
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLocation IN ( 'HI','RI' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'RI' THEN

       --AMAR 15032011
      BEGIN
         DBMS_OUTPUT.PUT_LINE('RI');
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   DimUserInfo.DesignationAlt_Key ,
                   'Y' IsMainTable  ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND DimUserInfo.UserLocationCode = v_UserLocationCode
                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLocation IN ( 'RI' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'RO' THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('RO');
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'Y' IsMainTable  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   DimUserInfo.DesignationAlt_Key ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.UserType ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
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

            UNION 
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   'Y' IsMainTable  ,
                   DimUserInfo.DesignationAlt_Key ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.UserType ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND UserLocationCode IN ( SELECT RegionAlt_Key 
                                                FROM DimRegion 
                                                 WHERE  RegionAlt_Key = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
                      AND UserLocation IN ( 'RO','BO' )
          ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      IF v_UserLocation = 'BO' THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('BO');
         OPEN  v_cursor FOR
            SELECT DimUserInfo.UserLoginID ,
                   DimUserInfo.UserName ,
                   DimUserInfo.LoginPassword ,
                   DimUserInfo.UserLocation ,
                   CASE 
                        WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                        WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                        WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'

                        --when  DimUserInfo.UserLocation = 'HO' then 'Bank'
                        WHEN DimUserInfo.UserLocation = 'HO' THEN 'HO'
                        WHEN DimUserInfo.UserLocation = 'HI' THEN 'HI'
                        WHEN DimUserInfo.UserLocation = 'RI' THEN 'RI'   END UserLocationName  ,
                   NVL(DimUserInfo.UserLocationCode, ' ') UserLocationCode  ,
                   DimUserRole.UserRoleAlt_Key ,
                   DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                   DimUserInfo.Activate ,
                   DimUserInfo.PasswordChanged ,
                   DimUserInfo.IsEmployee ,
                   'NOTSUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   DimUserInfo.IsChecker ,
                   DimUserInfo.EmployeeID ,
                   NVL(DimUserInfo.DeptGroupCode, 'ALL') DeptGroupCode  ,
                   DimUserInfo.Email_ID ,--ad3

                   DimUserInfo.MobileNo ,
                   'Y' IsMainTable  ,
                   DimUserInfo.DesignationAlt_Key ,
                   NVL(isCma, 'N') isCma  ,
                   DimUserInfo.UserType ,
                   DimUserInfo.ProffEntityId ,
                   DimUserInfo.GradeScaleAlt_Key ,
                   DimUserInfo.EmployeeTypeAlt_Key 
              FROM DimUserInfo 
                     JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
             WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                      AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                      AND DimUserInfo.UserRoleAlt_Key IN ( 2,3,4 )

                      AND UserLocationCode IN ( SELECT BranchCode 
                                                FROM DimBranch 
                                                 WHERE  BranchCode = v_UserLocationCode )

                      AND UserLoginID <> (v_UserLoginID)
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERMODIFICATIONAUXSELECT_NEW_08112021" TO "ADF_CDR_RBL_STGDB";
