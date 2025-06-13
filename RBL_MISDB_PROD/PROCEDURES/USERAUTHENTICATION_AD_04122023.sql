--------------------------------------------------------
--  DDL for Procedure USERAUTHENTICATION_AD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_UserLoginID IN VARCHAR2,
  v_LoginPassword IN VARCHAR2 DEFAULT ' ' ,
  v_authType IN CHAR DEFAULT 'DB' ,
  v_AuthSuccess IN CHAR DEFAULT 'N' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_NONUSE NUMBER(5,0);
   v_LoginDate DATE;
   v_Suspended NUMBER(5,0);
   v_PwdChangeDate DATE;
   v_PWDCHNG NUMBER(5,0);
   v_ExpiredUserDay NUMBER(5,0);
   v_DateCreated DATE;
   v_SuspendedUser CHAR(1) := 'N';
   v_UserLogged NUMBER(1,0) := 0;
   v_SystemDate VARCHAR2(10);
   v_LastRequestTime DATE;
   v_LastRequestDiff NUMBER(10,0);---change smallint to int -------added by Prashant -----------27-07-2022--
   ------SELECT  'SUSPEND' AS SUSPEND ,'NOTExpiredUser' AS ExpiredUser
   v_cursor SYS_REFCURSOR;
--DECLARE
--	@UserLoginID varchar(20)='LEGALCHECKER',
--	@LoginPassword varchar(100)='',
--	@authType char(1)='Y'

BEGIN

   IF utils.object_id('Tempdb..##tmpUserInfo') IS NOT NULL THEN

   BEGIN
      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmpUserInfo_2 ';

   END;
   END IF;
   SELECT UTILS.CONVERT_TO_VARCHAR2(sysDay.date_,10,p_style=>103) 

     INTO v_SystemDate
     FROM SysDataMatrix sysData
            JOIN SysDayMatrix sysDay   ON sysData.TimeKey = sysDay.TimeKey
            AND sysData.CurrentStatus = 'C';
   --  SET @TimeKey =(SELECT  TimeKey  FROM    SysDataMatrix_New WHERE  CurrentStatus = 'C' )
   DBMS_OUTPUT.PUT_LINE(01);
   SELECT TimeKey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   SELECT ParameterValue 

     INTO v_NONUSE
     FROM DimUserParameters 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND ShortNameEnum = 'NONUSE';
   DBMS_OUTPUT.PUT_LINE(02);
   SELECT ParameterValue 

     INTO v_PWDCHNG
     FROM DimUserParameters 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND ShortNameEnum = 'PWDCHNG';
   DBMS_OUTPUT.PUT_LINE(0);
   SELECT CurrentLoginDate ,
          PasswordChangeDate ,
          DateCreated ,
          SuspendedUser ,
          UserLogged ,
          LastRequestTime 

     INTO v_LoginDate,
          v_PwdChangeDate,
          v_DateCreated,
          v_SuspendedUser,
          v_UserLogged,
          v_LastRequestTime
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   IF v_LoginDate IS NOT NULL THEN

   BEGIN
      SELECT utils.datediff('D', v_LoginDate, SYSDATE) Days  

        INTO v_Suspended
        FROM DUAL ;

   END;
   ELSE

   BEGIN
      SELECT utils.datediff('D', v_DateCreated, SYSDATE) Days  

        INTO v_Suspended
        FROM DUAL ;

   END;
   END IF;
   IF v_PwdChangeDate IS NOT NULL THEN

   BEGIN
      SELECT utils.datediff('D', v_PwdChangeDate, SYSDATE) Days  

        INTO v_ExpiredUserDay
        FROM DUAL ;

   END;
   ELSE

   BEGIN
      SELECT utils.datediff('D', v_DateCreated, SYSDATE) Days  

        INTO v_ExpiredUserDay
        FROM DUAL ;

   END;
   END IF;
   DBMS_OUTPUT.PUT_LINE(1);
   ----------------Added for user logged update on basis of last request time .05/06/2022
   ----------------------------------------------added for user login who has user logged  is 1--------------added by Prashant -----------27-07-2022--
   IF v_UserLogged = 1 THEN

   BEGIN
      SELECT utils.datediff('MINUTE', v_LastRequestTime, SYSDATE) 

        INTO v_LastRequestDiff
        FROM DUAL ;

   END;
   END IF;
   -----------------------------------------------------END---------------------------------------
   DBMS_OUTPUT.PUT_LINE('@LastRequestDiff');
   DBMS_OUTPUT.PUT_LINE(v_LastRequestDiff);
   DBMS_OUTPUT.PUT_LINE(v_UserLogged);
   IF v_UserLogged = 1 THEN

   BEGIN
      IF v_LastRequestDiff > 20 THEN

       --set Session time out
      BEGIN
         DBMS_OUTPUT.PUT_LINE('userlogged0');
         UPDATE DimUserInfo
            SET Userlogged = 0
          WHERE  UserLoginID = v_UserLoginID;

      END;
      ELSE

      BEGIN
         DBMS_OUTPUT.PUT_LINE('userlogged1');
         UPDATE DimUserInfo
            SET Userlogged = 1
          WHERE  UserLoginID = v_UserLoginID;

      END;
      END IF;

   END;
   END IF;
   ---------------------------------------------------------------------------------
   IF v_AuthSuccess = 'N' THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('Started In AuthSuccess N Mode');
      DBMS_OUTPUT.PUT_LINE(v_Suspended);
      DBMS_OUTPUT.PUT_LINE(v_NONUSE);
      IF v_Suspended > v_NONUSE
        AND v_NONUSE <> 0 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('Mohsin');
         UPDATE DimUserInfo
            SET SuspendedUser = 'Y'
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
           AND EffectiveToTimeKey >= v_TimeKey )
           AND UserLoginID = v_UserLoginID;--AND @authType<> 'AD'				
         OPEN  v_cursor FOR
            SELECT NULL UserLoginID  ,
                   NULL UserName  ,
                   LoginPassword ,
                   NULL UserLocation  ,
                   NULL UserLocationName  ,
                   NULL UserLocationCode  ,
                   UTILS.CONVERT_TO_NUMBER(0,5,0) UserRoleALT_Key  ,
                   UTILS.CONVERT_TO_NUMBER(0,5,0) UserRole_Key  ,
                   NULL PasswordChanged  ,
                   NULL Activate  ,
                   'SUSPEND' SUSPEND  ,
                   'NOTExpiredUser' ExpiredUser  ,
                   UTILS.CONVERT_TO_NUMBER(0,5,0) ExpiredUserDay  ,
                   UTILS.CONVERT_TO_NUMBER(0,5,0) MaxUserLogin  ,
                   UTILS.CONVERT_TO_NUMBER(0,5,0) UserLoginCount  ,
                   NULL RoleDescription  ,
                   NULL AllowLogin  ,
                   NULL MIS_APP_USR_ID  ,
                   NULL MIS_APP_USR_PASS  ,
                   NULL IsChecker  ,
                   NULL IsChecker2  ,
                   NULL UserType  ,
                   NULL UserLogged  ,
                   NULL MobileNo  ,
                   NULL Email_ID  
              FROM DimUserInfo 
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey )
                      AND UserLoginID = v_UserLoginID ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;

      --ELSE IF @ExpiredUserDay>@PWDCHNG  --commented fro removing Expired user condition (as per bank suggestion) -1310202

      --	BEGIN

      --print 'ree'

      --print @ExpiredUserDay

      --	PRINT 4   	         

      --	SELECT  DimUserInfo.UserLoginID as UserLoginID,

      --			DimUserInfo.UserName as UserName,

      --			LoginPassword,

      --			NULL AS UserLocation,

      --			NULL AS UserLocationName,

      --			NULL AS UserLocationCode,

      --			CAST(0 AS SMALLINT) AS UserRoleALT_Key,

      --			CAST(0 AS SMALLINT) AS UserRole_Key,

      --			NULL AS PasswordChanged,

      --			NULL AS Activate,

      --			'NOTSUSPEND' AS SUSPEND,

      --			'ExpiredUser' AS ExpiredUser,	

      --			--CAST(0 AS SMALLINT) AS ExpiredUserDay,

      --		   ISNULL(@PWDCHNG,0)-ISNULL(@ExpiredUserDay,0) AS ExpiredUserDay,

      --			CAST(0 AS SMALLINT) AS MaxUserLogin,

      --			CAST(0 AS SMALLINT) AS UserLoginCount,

      --			NULL AS RoleDescription,

      --			NULL AS AllowLogin,

      --			NULL AS MIS_APP_USR_ID,

      --			NULL AS	MIS_APP_USR_PASS,

      --			NULL IsChecker,

      --			NULL AS UserType

      --			,NULL as UserLogged

      --		FROM DimUserInfo

      --		WHERE (EffectiveFromTimeKey < = @TimeKey AND EffectiveToTimeKey  > = @TimeKey)

      --			AND UserLoginID=@UserLoginID 

      --END

      ----------Checking to User has Expired Or Not 
      ELSE
         IF v_SuspendedUser = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(5);
            DBMS_OUTPUT.PUT_LINE('@SuspendedUser');
            DBMS_OUTPUT.PUT_LINE(v_SuspendedUser);
            OPEN  v_cursor FOR
               SELECT NULL UserLoginID  ,
                      NULL UserName  ,
                      LoginPassword ,
                      NULL UserLocation  ,
                      NULL UserLocationName  ,
                      NULL UserLocationCode  ,
                      UTILS.CONVERT_TO_NUMBER(0,5,0) UserRoleALT_Key  ,
                      UTILS.CONVERT_TO_NUMBER(0,5,0) UserRole_Key  ,
                      NULL PasswordChanged  ,
                      NULL Activate  ,
                      'SUSPEND' SUSPEND  ,
                      'NOTExpiredUser' ExpiredUser  ,
                      UTILS.CONVERT_TO_NUMBER(0,5,0) ExpiredUserDay  ,
                      UTILS.CONVERT_TO_NUMBER(0,5,0) MaxUserLogin  ,
                      UTILS.CONVERT_TO_NUMBER(0,5,0) UserLoginCount  ,
                      NULL RoleDescription  ,
                      NULL AllowLogin  ,
                      NULL MIS_APP_USR_ID  ,
                      NULL MIS_APP_USR_PASS  ,
                      NULL IsChecker  ,
                      NULL IsChecker2  ,
                      NULL UserType  ,
                      NULL UserLogged  ,
                      NULL MobileNo  ,
                      NULL Email_ID  
                 FROM DimUserInfo 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND UserLoginID = v_UserLoginID ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --amol end
         ELSE

         BEGIN
            DBMS_OUTPUT.PUT_LINE('REEMA1');
            DBMS_OUTPUT.PUT_LINE(v_PWDCHNG);
            DBMS_OUTPUT.PUT_LINE(v_ExpiredUserDay);
            OPEN  v_cursor FOR
               SELECT DimUserInfo.UserLoginID UserLoginID  ,
                      DimUserInfo.UserName UserName  ,
                      DimUserInfo.LoginPassword ,
                      DimUserInfo.UserLocation ,
                      CASE 
                           WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                           WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                           WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'
                           WHEN DimUserInfo.UserLocation = 'HO' THEN 'Bank'   END UserLocationName  ,
                      DimUserInfo.UserLocationCode ,
                      DimUserInfo.UserRoleAlt_Key ,
                      --DimUserInfo.IsAdmin,
                      --DimUserInfo.IsAdmin,
                      DimUserRole.UserRole_Key ,
                      DimUserInfo.PasswordChanged ,
                      DimUserInfo.Activate ,
                      'NOTSUSPEND' SUSPEND  ,
                      'NOTExpiredUser' ExpiredUser  ,
                      NVL(v_PWDCHNG, 0) - NVL(v_ExpiredUserDay, 0) ExpiredUserDay  ,
                      NVL(DimMaxLoginAllow.MaxUserLogin, 0) MaxUserLogin  ,
                      NVL(DimMaxLoginAllow.UserLoginCount, 0) UserLoginCount  ,
                      DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                      DimUserInfo.MIS_APP_USR_ID ,
                      DimUserInfo.MIS_APP_USR_PASS ,
                      DimUserInfo.IsChecker ,
                      DimUserInfo.IsChecker2 ,
                      CASE 
                           WHEN DimUserInfo.UserLocation = 'BO' THEN ( SELECT NVL(AllowLogin, 'N') 
                                                                       FROM DimBranch 
                                                                        WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                                                                 AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                                                                 AND BranchCode = DimUserInfo.UserLocationCode )
                           WHEN DimUserInfo.UserLocation = 'RO'
                             AND ( SELECT COUNT(*)  
                                   FROM DimBranch 
                                    WHERE  BranchRegionAlt_Key = DimUserInfo.UserLocationCode
                                             AND ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                             AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                             AND NVL(AllowLogin, 'N') = 'Y' ) > 0 THEN 'Y'
                           WHEN DimUserInfo.UserLocation = 'RO'
                             AND ( SELECT COUNT(*)  
                                   FROM DimBranch 
                                    WHERE  BranchRegionAlt_Key = DimUserInfo.UserLocationCode
                                             AND ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                             AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                             AND NVL(AllowLogin, 'N') = 'Y' ) = 0 THEN 'N'
                           WHEN DimUserInfo.UserLocation = 'HO'
                             AND ( SELECT COUNT(*)  
                                   FROM DimBranch 
                                    WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                             AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                             AND NVL(AllowLogin, 'N') = 'Y' ) > 0 THEN 'Y'
                           WHEN DimUserInfo.UserLocation = 'HO'
                             AND ( SELECT COUNT(*)  
                                   FROM DimBranch 
                                    WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                             AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                             AND NVL(AllowLogin, 'N') = 'Y' ) = 0 THEN 'N'   END AllowLogin  ,
                      CASE 
                           WHEN DimUserInfo.UserType = 'Employee' THEN 'Y'
                      ELSE 'N'
                         END UserType  ,
                      CASE 
                           WHEN UserLogged = 1 THEN 'Y'
                      ELSE 'N'
                         END UserLogged  ,
                      --,'N' as UserLogged
                      SUBSTR(NVL(MobileNo, ' '), 1, 10) MobileNo  ,
                      DimUserInfo.Email_ID ,
                      --,DimDepartment.DepartmentCode 
                      DimUserDeptGroup.DeptGroupCode DepartmentCode  ,
                      v_SystemDate SystemDate  

                 --INTO ##tmpUserInfo
                 FROM DimUserInfo 
                        JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                      --INNER JOIN DimDepartment
                       --ON DimUserInfo.DepartmentId = DimDepartment.DepartmentAlt_Key

                        JOIN DimUserDeptGroup    ON DimUserInfo.DepartmentId = DimUserDeptGroup.DeptGroupId
                        LEFT JOIN DimMaxLoginAllow    ON DimMaxLoginAllow.UserLocation = DimUserInfo.UserLocation
                        AND DimMaxLoginAllow.UserLocationCode = DimUserInfo.UserLocationCode
                WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                         AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                         AND DimUserInfo.UserLoginID = v_UserLoginID
                         AND NVL(SuspendedUser, 'N') = 'N' ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
      END IF;

   END;
   ELSE
   DECLARE
      v_ChangePwdMax NUMBER(10,0) := 0;

   BEGIN
      DBMS_OUTPUT.PUT_LINE(6);
      DBMS_OUTPUT.PUT_LINE('AD Login Fetch');
      OPEN  v_cursor FOR
         SELECT DimUserInfo.UserLoginID UserLoginID  ,
                DimUserInfo.UserName UserName  ,
                DimUserInfo.LoginPassword ,
                DimUserInfo.UserLocation ,
                CASE 
                     WHEN DimUserInfo.UserLocation = 'RO' THEN 'Region'
                     WHEN DimUserInfo.UserLocation = 'ZO' THEN 'Zone'
                     WHEN DimUserInfo.UserLocation = 'BO' THEN 'Branch'
                     WHEN DimUserInfo.UserLocation = 'HO' THEN 'Bank'   END UserLocationName  ,
                DimUserInfo.UserLocationCode ,
                DimUserInfo.UserRoleAlt_Key ,
                --DimUserInfo.IsAdmin,
                --DimUserInfo.IsAdmin,
                DimUserRole.UserRole_Key ,
                DimUserInfo.PasswordChanged ,
                DimUserInfo.Activate ,
                CASE 
                     WHEN SuspendedUser = 'Y' THEN 'SUSPEND'
                ELSE 'NOTSUSPEND'
                   END SUSPEND  ,
                'NOTExpiredUser' ExpiredUser  ,
                NVL(v_PWDCHNG, 0) - NVL(v_ExpiredUserDay, 0) ExpiredUserDay  ,
                NVL(DimMaxLoginAllow.MaxUserLogin, 0) MaxUserLogin  ,
                NVL(DimMaxLoginAllow.UserLoginCount, 0) UserLoginCount  ,
                DimUserRole.UserRoleShortNameEnum RoleDescription  ,
                DimUserInfo.MIS_APP_USR_ID ,
                DimUserInfo.MIS_APP_USR_PASS ,
                DimUserInfo.IsChecker ,
                DimUserInfo.IsChecker2 ,
                CASE 
                     WHEN DimUserInfo.UserLocation = 'BO' THEN ( SELECT NVL(AllowLogin, 'N') 
                                                                 FROM DimBranch 
                                                                  WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                                                           AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                                                           AND BranchCode = DimUserInfo.UserLocationCode )
                     WHEN DimUserInfo.UserLocation = 'RO'
                       AND ( SELECT COUNT(*)  
                             FROM DimBranch 
                              WHERE  BranchRegionAlt_Key = DimUserInfo.UserLocationCode
                                       AND ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                       AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                       AND NVL(AllowLogin, 'N') = 'Y' ) > 0 THEN 'Y'
                     WHEN DimUserInfo.UserLocation = 'RO'
                       AND ( SELECT COUNT(*)  
                             FROM DimBranch 
                              WHERE  BranchRegionAlt_Key = DimUserInfo.UserLocationCode
                                       AND ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                       AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                       AND NVL(AllowLogin, 'N') = 'Y' ) = 0 THEN 'N'
                     WHEN DimUserInfo.UserLocation = 'HO'
                       AND ( SELECT COUNT(*)  
                             FROM DimBranch 
                              WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                       AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                       AND NVL(AllowLogin, 'N') = 'Y' ) > 0 THEN 'Y'
                     WHEN DimUserInfo.UserLocation = 'HO'
                       AND ( SELECT COUNT(*)  
                             FROM DimBranch 
                              WHERE  ( DimBranch.EffectiveFromTimeKey <= v_TimeKey
                                       AND DimBranch.EffectiveToTimeKey >= v_TimeKey )
                                       AND NVL(AllowLogin, 'N') = 'Y' ) = 0 THEN 'N'   END AllowLogin  ,
                CASE 
                     WHEN DimUserInfo.UserType = 'Employee' THEN 'Y'
                ELSE 'N'
                   END UserType  ,
                CASE 
                     WHEN UserLogged = 1 THEN 'Y'
                ELSE 'N'
                   END UserLogged  ,
                --,'N' as UserLogged
                SUBSTR(NVL(MobileNo, ' '), 1, 10) MobileNo  ,
                DimUserInfo.Email_ID ,
                --,DimDepartment.DepartmentCode 
                DimUserDeptGroup.DeptGroupCode DepartmentCode  ,
                v_SystemDate SystemDate  

           --INTO ##tmpUserInfo
           FROM DimUserInfo 
                  JOIN DimUserRole    ON DimUserInfo.UserRoleAlt_Key = DimUserRole.UserRoleAlt_Key
                  JOIN DimUserDeptGroup    ON DimUserInfo.DepartmentId = DimUserDeptGroup.DeptGroupId
                --INNER JOIN DimDepartment
                 --	ON DimUserInfo.DepartmentId = DimDepartment.DepartmentAlt_Key

                  LEFT JOIN DimMaxLoginAllow    ON DimMaxLoginAllow.UserLocation = DimUserInfo.UserLocation
                  AND DimMaxLoginAllow.UserLocationCode = DimUserInfo.UserLocationCode
          WHERE  ( DimUserInfo.EffectiveFromTimeKey <= v_TimeKey
                   AND DimUserInfo.EffectiveToTimeKey >= v_TimeKey )
                   AND DimUserInfo.UserLoginID = v_UserLoginID ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      --AND ISNULL(SuspendedUser,'N')='N'	 				
      --IF @authType = 'AD'				
      --BEGIN
      --	update ##tmpUserInfo set PasswordChanged='Y',	Activate='Y',	SUSPEND='NOTSUSPEND',	ExpiredUser='NOTExpiredUser',	ExpiredUserDay='0' 
      --	--update ##tmpUserInfo set UserType='Employee' where UserType='Y'
      --END
      DBMS_OUTPUT.PUT_LINE(66);
      SELECT ParameterValue 

        INTO v_ChangePwdMax
        FROM DimUserParameters 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND ShortNameEnum = 'PWDCHNG';

   END;
   END IF;
   --SELECT * FROM ##tmpUserInfo
   DBMS_OUTPUT.PUT_LINE(7);
   OPEN  v_cursor FOR
      SELECT ParameterName ,
             ParameterValue 
        FROM SysSolutionParameter 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterValue 
        FROM DimUserParameters 
       WHERE  ParameterType = 'Suspend User after Maximum Unsuccessful Log-On attempts'
                AND ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey ) ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT COUNT(UserLoginID)  UserRegisteredCount  
        FROM DimUserInfo_mod 
       WHERE  CreatedBy = 'self' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--Select ParameterName, ParameterValue from SysSolutionParameter Where ParameterName IN('TierValue','RegionCap','AllowHigherLevelAuth')

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERAUTHENTICATION_AD_04122023" TO "ADF_CDR_RBL_STGDB";
