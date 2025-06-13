--------------------------------------------------------
--  DDL for Function USERCREATIONINSERT_NEW_BACKUP_11022022
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" 
(
  v_UserLoginID IN VARCHAR2,
  v_EmployeeID IN VARCHAR2,
  v_IsEmployee IN CHAR,
  v_UserName IN VARCHAR2,
  v_LoginPassword IN VARCHAR2,
  v_UserLocation IN VARCHAR2,
  v_UserLocationCode IN VARCHAR2,
  v_UserRoleAlt_Key IN NUMBER,
  v_DeptGroupCode IN VARCHAR2,
  v_DepartmentId IN VARCHAR2,
  v_ApplicableSolIds IN VARCHAR2,
  v_ApplicableBACID IN VARCHAR2,
  v_DateCreatedmodified IN DATE,
  v_CreatedModifiedBy IN VARCHAR2,
  v_Activate IN CHAR,
  v_IsChecker IN CHAR,
  v_IsChecker2 IN VARCHAR2,
  v_WorkFlowUserRoleAlt_Key IN NUMBER,
  v_DesignationAlt_Key IN NUMBER,
  v_IsCma IN CHAR,
  v_MobileNo IN VARCHAR2,
  v_Email_ID IN VARCHAR2,
  v_SecuritQsnAlt_Key IN NUMBER,
  v_SecurityAns IN VARCHAR2,
  v_MenuId IN VARCHAR2,
  iv_EffectiveFromTimeKey IN NUMBER,
  iv_EffectiveToTimeKey IN NUMBER,
  v_Flag IN NUMBER,
  v_TimeKey IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_sys_error NUMBER := 0;
   --declare 
   --@UserLoginID	varchar(20)='User2', 
   --		@EmployeeID varchar(20)='User2',			
   --		@IsEmployee char(1),				
   --		@UserName	varchar(50)='',
   --		@LoginPassword	varchar(max)='',
   --		@UserLocation	varchar	(10),
   --		@UserLocationCode	varchar	(10),
   --		@UserRoleAlt_Key	smallint=2,
   --		@DeptGroupCode varchar(10),
   --		@DepartmentId  VARCHAR(200),
   --		@ApplicableSolIds varchar(max),
   --		@ApplicableBACID varchar(max)='ALL BACID',
   --		@DateCreatedmodified smalldatetime='2019-12-27 16:18:29.490',
   --		@CreatedModifiedBy	varchar	(20)='fnasuperadmin',
   --		@Activate char(1)='N',
   --		@IsChecker char(1)='N',
   --		@WorkFlowUserRoleAlt_Key smallint,
   --		@DesignationAlt_Key int,
   --		@IsCma char(1),
   --		@MobileNo varchar(50)=9855474444,
   --		@Email_ID VARCHAR(200)='prince@axisbank.com',
   --		@SecuritQsnAlt_Key SMALLINT,
   --		@SecurityAns VARCHAR(100),
   --		@MenuId VARCHAR(1000),
   --		@EffectiveFromTimeKey INT=24928,                       
   --		@EffectiveToTimeKey INT=49999 ,              
   --		@Flag  INT=2,
   --		@TimeKey SMALLINT,
   --		@Result INT=0 
   v_Entity_Key NUMBER(10,0);
   v_PasswordChanged CHAR(1);
   v_CurrentLoginDate --- added by shailesh naik on 10/06/2014
    VARCHAR2(200);
   v_DeptCode VARCHAR2(100);
   v_cursor SYS_REFCURSOR;

BEGIN

   --SELECT @Timekey=Max(Timekey) from SysProcessingCycle  
   --WHERE Extracted='Y' --and ProcessType='Full' --commentedon 20 dec 2019 as per discussed with ravish 
   --Select
   --@DeptCode=
   --Case when DepartmentCode IN ('BBOG','FNA') THEN DepartmentCode + '_' +Cast(@UserRoleAlt_Key as Varchar(10))
   --else 'OTHER' +  '_' +Cast(@UserRoleAlt_Key as Varchar(10))  end
   --from DimDepartment where DepartmentAlt_Key=@DepartmentId
   --AND (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   --print @DeptCode
   --Select @DeptGroupCode=DeptGroupId
   --from DimUserDeptGroup where
   --(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
   --AND DeptGroupName=@DeptCode
   DBMS_OUTPUT.PUT_LINE('@DeptGroupCode');
   DBMS_OUTPUT.PUT_LINE(v_DeptGroupCode);
   ----IF ISNULL(@TimeKey,0)=0
   ----BEGIN
   ----    Select @TimeKey=TimeKey from SysDayMatrix where [Date]=Cast(Getdate() as date)
   ----END
   ----IF ISNULL(@EffectiveFromTimeKey,0)=0
   ----BEGIN
   ----    Select @EffectiveFromTimeKey=TimeKey from SysDayMatrix where [Date]=Cast(Getdate() as date)
   ----END
   v_EffectiveToTimeKey := 49999 ;
   --Select @EffectiveFromTimeKey=TimeKey from SysDayMatrix where [Date]=Cast(Getdate() as date)
   SELECT TimeKey 

     INTO v_EffectiveFromTimeKey
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey;
   IF ( v_Flag IN ( 1 )
    ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      --	print 'flag1'
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT UserLoginID 
                         FROM DimUserInfo 
                          WHERE  UserLoginID = v_UserLoginID
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         --print '-6'
         v_Result := -6 ;
         DBMS_OUTPUT.PUT_LINE(v_Result);
         OPEN  v_cursor FOR
            SELECT v_Result 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN 0;

      END;
      END IF;

   END;
   END IF;
   --SQL Server BEGIN TRANSACTION;
   utils.incrementTrancount;
   BEGIN

      BEGIN
         IF v_Flag <> 3 THEN
          DECLARE
            v_IsAvailabve CHAR(1) := 'N';
            v_IsSCD2 CHAR(1) := 'N';
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT UserLoginID 
                               FROM DimUserInfo 
                                WHERE  UserLoginID = v_UserLoginID
                                         AND EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               v_IsAvailabve := 'Y' ;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT UserLoginID 
                                  FROM DimUserInfo 
                                   WHERE  UserLoginID = v_UserLoginID
                                            AND EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('DIM');
                  UPDATE DimUserInfo
                     SET UserLoginID = v_UserLoginID,
                         UserName = v_UserName,
                         UserLocation = v_UserLocation,
                         UserLocationCode = v_UserLocationCode,
                         UserRoleAlt_Key = v_UserRoleAlt_Key,
                         LoginPassword = v_LoginPassword,
                         IsChecker = v_IsChecker,
                         IsChecker2 = v_IsChecker2,
                         Activate = v_Activate,
                         DeptGroupCode = v_DeptGroupCode,
                         WorkFlowUserRoleAlt_Key = v_WorkFlowUserRoleAlt_Key,
                         Email_ID = v_Email_ID --ad4
                         ,
                         MobileNo = v_MobileNo,
                         DesignationAlt_Key = v_DesignationAlt_Key,
                         IsCma = v_isCma,
                         ApplicableBACID = v_ApplicableBACID
                         ----ApplicableSolIds	=@ApplicableSolIds,
                         ,
                         DepartmentId = v_DepartmentId,
                         ScreenFlag = 'S'
                   WHERE  UserLoginID = v_UserLoginID
                    AND EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey
                    AND EffectiveFromTimeKey = v_EffectiveFromTimeKey;

               END;

               --ELSE IF  EXISTS (SELECT UserLoginID from  DimUserInfo WHERE UserLoginID= @UserLoginID 

               --	AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

               --BEGIN

               --	UPDATE DimUserInfo 

               --	SET EffectiveToTimeKey=@TimeKey-1

               --	WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey

               --	AND UserLoginID=@UserLoginID

               --END
               ELSE

               BEGIN
                  v_IsSCD2 := 'Y' ;

               END;
               END IF;

            END;
            END IF;
            IF ( v_IsSCD2 = 'Y' ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('INSERT');
               INSERT INTO DimUserInfo
                 ( UserLoginID, EmployeeID, IsEmployee, UserName, LoginPassword, UserLocation, DeptGroupCode, Activate, IsChecker, IsChecker2, EffectiveFromTimeKey, EffectiveToTimeKey
               ----,EntityKey 
               , PasswordChanged
               --------
               , PasswordChangeDate, ChangePwdCnt, UserLocationCode, UserRoleAlt_Key, SuspendedUser, CurrentLoginDate, ResetDate, UserLogged, UserDeletionReasonAlt_Key, SystemLogOut, RBIFLAG, Email_ID --ad4
               , MobileNo, DesignationAlt_Key, IsCma, SecuritQsnAlt_Key, SecurityAns, MenuId, CreatedBy, DateCreated, ModifyBy, DateModified, MIS_APP_USR_ID, MIS_APP_USR_PASS, UserLocationExcel, WorkFlowUserRoleAlt_Key, ApplicableBACID
               ----,ApplicableSolIds
               , DepartmentId, ScreenFlag )
                 ( SELECT v_UserLoginID ,
                          v_EmployeeID ,
                          v_IsEmployee ,
                          v_UserName ,
                          v_LoginPassword ,
                          v_UserLocation ,
                          v_DeptGroupCode ,
                          v_Activate ,
                          v_IsChecker ,
                          v_IsChecker2 ,
                          v_EffectiveFromTimeKey ,
                          v_EffectiveToTimeKey ,
                          ----,@Entity_Key 
                          PasswordChanged ,
                          --------------
                          PasswordChangeDate ,
                          ChangePwdCnt ,
                          v_UserLocationCode ,
                          v_UserRoleAlt_Key ,
                          SuspendedUser ,
                          CurrentLoginDate ,
                          ResetDate ,
                          UserLogged ,
                          UserDeletionReasonAlt_Key ,
                          SystemLogOut ,
                          RBIFLAG ,
                          v_Email_ID ,--ad4

                          v_MobileNo ,
                          v_DesignationAlt_Key ,
                          v_IsCma ,
                          v_SecuritQsnAlt_Key ,
                          v_SecurityAns ,
                          v_MenuId ,
                          CASE 
                               WHEN v_IsAvailabve = 'N' THEN v_CreatedModifiedBy
                          ELSE CreatedBy
                             END col  ,
                          CASE 
                               WHEN v_IsAvailabve = 'N' THEN v_DateCreatedmodified
                          ELSE DateCreated
                             END col  ,
                          CASE 
                               WHEN v_IsAvailabve = 'N' THEN NULL
                          ELSE v_CreatedModifiedBy
                             END col  ,
                          CASE 
                               WHEN v_IsAvailabve = 'N' THEN NULL
                          ELSE v_DateCreatedmodified
                             END col  ,
                          MIS_APP_USR_ID ,
                          MIS_APP_USR_PASS ,
                          UserLocationExcel ,
                          v_WorkFlowUserRoleAlt_Key ,
                          v_ApplicableBACID ,
                          ----,@ApplicableSolIds
                          v_DepartmentId ,
                          'S' 
                   FROM DimUserInfo 
                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND UserLoginID = v_UserLoginID );
               UPDATE DimUserInfo
                  SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND EffectiveFromTimeKey < v_EffectiveFromTimeKey
                 AND UserLoginID = v_UserLoginID;

            END;
            END IF;
            IF v_IsAvailabve = 'N' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('else insert');
               INSERT INTO DimUserInfo
                 ( UserLoginID, EmployeeID, IsEmployee, UserName, LoginPassword, UserLocation, DeptGroupCode, Activate, IsChecker, IsChecker2, EffectiveFromTimeKey, EffectiveToTimeKey
               ----,EntityKey 
               , PasswordChanged, PasswordChangeDate, ChangePwdCnt, UserLocationCode, UserRoleAlt_Key, SuspendedUser, CurrentLoginDate, ResetDate, UserLogged, UserDeletionReasonAlt_Key, SystemLogOut, RBIFLAG, Email_ID --ad4
               , MobileNo, DesignationAlt_Key, isCma, SecuritQsnAlt_Key, SecurityAns, MenuId, CreatedBy, DateCreated, ModifyBy, DateModified, MIS_APP_USR_ID, MIS_APP_USR_PASS, UserLocationExcel, WorkFlowUserRoleAlt_Key, ApplicableBACID
               ----,ApplicableSolIds
               , DepartmentId, ScreenFlag )
                 VALUES ( v_UserLoginID, v_EmployeeID, v_IsEmployee, v_UserName, v_LoginPassword, v_UserLocation, v_DeptGroupCode, v_Activate, v_IsChecker, v_IsChecker2, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, 
               ------,@Entity_Key 
               'N', NULL, 0, v_UserLocationCode, v_UserRoleAlt_Key, 'N', NULL --CurrentLoginDate
               , NULL --ResetDate
               , 0, NULL, NULL, NULL, NULLIF(v_Email_ID, ' ' --ad4
               ), v_MobileNo, v_DesignationAlt_Key, v_isCma, v_SecuritQsnAlt_Key, v_SecurityAns, v_MenuId, CASE 
                                                                                                                WHEN v_IsAvailabve = 'N' THEN v_CreatedModifiedBy
               ELSE NULL
                  END, TO_DATE(CASE 
                                    WHEN v_IsAvailabve = 'N' THEN v_DateCreatedmodified
               ELSE NULL
                  END,'dd/mm/yyyy'), CASE 
                                          WHEN v_IsAvailabve = 'N' THEN NULL
               ELSE v_CreatedModifiedBy
                  END, TO_DATE(CASE 
                                    WHEN v_IsAvailabve = 'N' THEN NULL
               ELSE v_DateCreatedmodified
                  END,'dd/mm/yyyy'), NULL, NULL, NULL, v_WorkFlowUserRoleAlt_Key, v_ApplicableBACID, 
               ----,@ApplicableSolIds
               v_DepartmentId, 'S' );

            END;
            END IF;

         END;
         ELSE
            IF v_FLAG = 3 THEN

            BEGIN
               UPDATE DimUserInfo
                  SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                      DateApproved = SYSDATE,
                      ModifyBy = v_CreatedModifiedBy
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND UserLoginID = v_UserLoginID;

            END;
            END IF;
         END IF;
         --------SELECT * FROM DimUserInfo
         --------WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
         --------	AND UserLoginID=@UserLoginID
         UPDATE DimUserInfo
            SET PasswordChanged = 'Y'
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
           AND EffectiveToTimeKey >= v_TimeKey )
           AND UserLoginID = v_UserLoginID;
         utils.commit_transaction;
         --------------End      -----------
         IF v_FLAG = 3 THEN

         BEGIN
            v_Result := 0 ;
            RETURN 0;

         END;
         ELSE

         BEGIN
            v_Result := 1 ;
            RETURN 1;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      IF v_sys_error <> 0 THEN

      BEGIN
         ROLLBACK;
         utils.resetTrancount;
         DBMS_OUTPUT.PUT_LINE('Error');
         OPEN  v_cursor FOR
            SELECT SQLERRM 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         v_Result := -1 ;
         RETURN -1;

      END;
      END IF;
      v_sys_error := 0;

   END;END;
   v_sys_error := 0;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
