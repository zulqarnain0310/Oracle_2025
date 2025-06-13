--------------------------------------------------------
--  DDL for Function USERUPLOADINSERT_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_XmlDocument IN CLOB DEFAULT ' ' ,
  v_MenuId IN VARCHAR2,
  v_LoginPassword IN VARCHAR2,
  iv_EffectiveFromTimeKey IN NUMBER,
  iv_EffectiveToTimeKey IN NUMBER,
  v_DateCreatedmodified IN DATE,
  v_CreatedModifiedBy IN VARCHAR2,
  iv_TimeKey IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(5,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_Entity_Key NUMBER(10,0);
   v_PasswordChanged CHAR(1);
   v_CurrentLoginDate VARCHAR2(200);--- added by shailesh naik on 10/06/2014

BEGIN

   IF NVL(v_TimeKey, 0) = 0 THEN

   BEGIN
      SELECT TimeKey 

        INTO v_TimeKey
        FROM SysDayMatrix 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) = Date_;

   END;
   END IF;
   IF NVL(v_EffectiveFromTimeKey, 0) = 0 THEN

   BEGIN
      SELECT TimeKey 

        INTO v_EffectiveFromTimeKey
        FROM SysDayMatrix 
       WHERE  UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) = Date_;

   END;
   END IF;
   --SET @TimeKey=(SELECT MAX(TIMEKEY) FROM sysprocessingcycle WHERE Extracted='Y')--ADDED BY MAMTA ON 21 JAN 2020 BECAUSE BYDEFAULT IT WAS PAASING 1 APRIL 2018 TIMEKEY
   v_EffectiveFromTimeKey := v_TimeKey ;--ADDED BY MAMTA ON 21 JAN 2020 BECAUSE BYDEFAULT IT WAS PAASING 1 APRIL 2018 TIMEKEY
   v_EffectiveToTimeKey := 49999 ;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         IF utils.object_id('TEMPDB..tt_UserMasterUploadData_8') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UserMasterUploadData_8 ';
         END IF;
         --Select * from DimUserInfo
         DELETE FROM tt_UserMasterUploadData_8;
         UTILS.IDENTITY_RESET('tt_UserMasterUploadData_8');

         INSERT INTO tt_UserMasterUploadData_8 ( 
         	SELECT /*TODO:SQLDEV*/ c.value('./SrNo[1]','int') /*END:SQLDEV*/ SrNo  ,
                 /*TODO:SQLDEV*/ c.value('./UserID[1]','varchar(20)') /*END:SQLDEV*/ UserID  ,
                 /*TODO:SQLDEV*/ c.value('./UserName[1]','varchar(100)') /*END:SQLDEV*/ UserName  ,
                 /*TODO:SQLDEV*/ c.value('./UserRole[1]','varchar(50)') /*END:SQLDEV*/ UserRole  ,
                 /*TODO:SQLDEV*/ c.value('./UserDepartment[1]','nvarchar(510)') /*END:SQLDEV*/ UserDepartment  ,
                 --,c.value('./ApplicableSolID[1]','varchar(max)')ApplicableSolID
                 /*TODO:SQLDEV*/ c.value('./ApplicableBACID[1]','varchar(max)') /*END:SQLDEV*/ ApplicableBACID  ,
                 /*TODO:SQLDEV*/ c.value('./UserEmailId[1]','varchar(200)') /*END:SQLDEV*/ UserEmailId  ,
                 /*TODO:SQLDEV*/ c.value('./UserMobileNumber[1]','varchar(15)') /*END:SQLDEV*/ UserMobileNumber  ,
                 /*TODO:SQLDEV*/ c.value('./UserExtensionNumber [1]','varchar(15)') /*END:SQLDEV*/ UserExtensionNumber  ,
                 /*TODO:SQLDEV*/ c.value('./IsCheckerYN[1]','varchar(1)') /*END:SQLDEV*/ IsChecker  ,
                 /*TODO:SQLDEV*/ c.value('./IsChecker2YN[1]','varchar(max)') /*END:SQLDEV*/ IsChecker2 ,---Added By Sachin

                 /*TODO:SQLDEV*/ c.value('./IsActiveYN [1]','varchar(1)') /*END:SQLDEV*/ IsActive  ,
                 /*TODO:SQLDEV*/ c.value('./ActionAU[1]','varchar(1)') /*END:SQLDEV*/ Perform  
         	  FROM TABLE(/*TODO:SQLDEV*/ @XmlDocument.nodes('/DataSet/GridData') AS t(c) /*END:SQLDEV*/)  );

         EXECUTE IMMEDIATE ' ALTER TABLE tt_UserMasterUploadData_8 
            ADD ( [CreatedBy VARCHAR2(50) , DateCreated DATE , UserRoleAlt_Key NUMBER(5,0) , DeptGroupCode VARCHAR2(10) , DepartmentId NUMBER(10,0) , ScreenFlag CHAR(1) ] ) ';
         UPDATE tt_UserMasterUploadData_8
            SET ---ApplicableSolID =REPLACE(REPLACE(ApplicableSolID, CHAR(13), ''), CHAR(10), '')
          ApplicableBACID = REPLACE(REPLACE(ApplicableBACID, CHR(13), ' '), CHR(10), ' '),
          UserRole = LTRIM(RTRIM(UserRole));
         MERGE INTO U 
         USING (SELECT U.ROWID row_id, US.CreatedBy, Us.DateCreated
         FROM U ,tt_UserMasterUploadData_8 U
                JOIN DimUserInfo Us   ON ( US.EffectiveFromTimeKey <= v_TimeKey
                AND US.EffectiveToTimeKey >= v_TimeKey )
                AND U.UserID = US.UserLoginID
                AND U.Perform = 'U' ) src
         ON ( U.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET U.CreatedBy = src.CreatedBy,
                                      U.DateCreated = src.DateCreated;
         MERGE INTO U 
         USING (SELECT U.ROWID row_id, v_CreatedModifiedBy, SYSDATE
         FROM U ,tt_UserMasterUploadData_8 U
                JOIN DimUserInfo Us   ON ( US.EffectiveFromTimeKey <= v_TimeKey
                AND US.EffectiveToTimeKey >= v_TimeKey )
                AND U.UserID = US.UserLoginID
                AND U.Perform = 'A' ) src
         ON ( U.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET U.CreatedBy = v_CreatedModifiedBy,
                                      U.DateCreated = SYSDATE;
         MERGE INTO U 
         USING (SELECT U.ROWID row_id, R.UserRoleAlt_Key
         FROM U ,tt_UserMasterUploadData_8 U
                JOIN DimUserRole R   ON R.EffectiveFromTimeKey <= v_TimeKey
                AND R.EffectiveToTimeKey >= v_TimeKey
                AND R.RoleDescription = U.UserRole ) src
         ON ( U.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET U.UserRoleAlt_Key = src.UserRoleAlt_Key;
         MERGE INTO U 
         USING (SELECT U.ROWID row_id, D.DeptGroupId
         FROM U ,tt_UserMasterUploadData_8 U
              --inner join DimDepartment D ON D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
               --and D.DepartmentCode=U.UserDepartment

                JOIN DimUserDeptGroup D   ON D.EffectiveFromTimeKey <= v_TimeKey
                AND D.EffectiveToTimeKey >= v_TimeKey
                AND D.DeptGroupCode = U.UserDepartment ) src
         ON ( U.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET U.DepartmentId = src.DeptGroupId;
         MERGE INTO U 
         USING (SELECT U.ROWID row_id, G.DeptGroupId
         FROM U ,tt_UserMasterUploadData_8 U
              --inner join DimDepartment D ON D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
               --and D.DepartmentCode=U.UserDepartment

                JOIN DimUserDeptGroup G   ON G.EffectiveFromTimeKey <= v_TimeKey
                AND G.EffectiveToTimeKey >= v_TimeKey
                AND G.DeptGroupCode = U.UserDepartment ) src
         ON ( U.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET U.DeptGroupCode = src.DeptGroupId;
         --inner join DimUserDeptGroup G ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey >=@TimeKey)
         --AND G.DeptGroupName =
         --(
         --  Case WHEN U.UserDepartment IN ('BBOG','FNA') THEN U.UserDepartment +  '_' +Cast(U.UserRoleAlt_Key as Varchar(10))
         --  else 'OTHER' +  '_' +Cast(U.UserRoleAlt_Key as Varchar(10)) end
         --)
         MERGE INTO US 
         USING (SELECT US.ROWID row_id, v_EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
         FROM US ,tt_UserMasterUploadData_8 U
                JOIN DimUserInfo Us   ON ( US.EffectiveFromTimeKey <= v_TimeKey
                AND US.EffectiveToTimeKey >= v_TimeKey )
                AND U.UserID = US.UserLoginID
                AND U.Perform = 'U' ) src
         ON ( US.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET US.EffectiveToTimeKey = src.EffectiveToTimeKey;
         INSERT INTO DimUserInfo
           ( UserLoginID, EmployeeID, IsEmployee, UserName, LoginPassword, UserLocation, DeptGroupCode, Activate, IsChecker, EffectiveFromTimeKey, EffectiveToTimeKey
         ----,EntityKey 
         , PasswordChanged
         --------
         , PasswordChangeDate, ChangePwdCnt, UserLocationCode, UserRoleAlt_Key, SuspendedUser, CurrentLoginDate, ResetDate, UserLogged, UserDeletionReasonAlt_Key, SystemLogOut, RBIFLAG, Email_ID --ad4
         , MobileNo, DesignationAlt_Key, IsCma, SecuritQsnAlt_Key, SecurityAns, MenuId, CreatedBy, DateCreated, ModifyBy, DateModified, MIS_APP_USR_ID, MIS_APP_USR_PASS, UserLocationExcel, WorkFlowUserRoleAlt_Key, ApplicableBACID
         ----,ApplicableSolIds
         , DepartmentId, ScreenFlag, IsChecker2 )
           ( SELECT UserID ,
                    UserID ,
                    'Y' ,
                    UserName ,
                    v_LoginPassword ,
                    'HO' ,
                    DeptGroupCode ,
                    IsActive ,
                    IsChecker ,
                    v_EffectiveFromTimeKey ,
                    v_EffectiveToTimeKey ,
                    ----,@Entity_Key 
                    'N' PasswordChanged  ,
                    --------------
                    NULL PasswordChangeDate  ,
                    0 ChangePwdCnt  ,
                    'HO' UserLocationCode  ,
                    UserRoleAlt_Key ,
                    'N' SuspendedUser  ,
                    NULL CurrentLoginDate  ,
                    NULL ResetDate  ,
                    NULL UserLogged  ,
                    NULL UserDeletionReasonAlt_Key  ,
                    NULL SystemLogOut  ,
                    NULL RBIFLAG  ,
                    UserEmailId ,--ad4

                    UserMobileNumber || ',' || UserExtensionNumber ,
                    NULL DesignationAlt_Key  ,
                    NULL IsCma  ,
                    NULL SecuritQsnAlt_Key  ,
                    NULL SecurityAns  ,
                    NULL MenuId  ,
                    --,CreatedBy
                    --,dateCreated
                    v_CreatedModifiedBy ,
                    v_DateCreatedmodified ,
                    CASE 
                         WHEN Perform = 'A' THEN NULL
                    ELSE v_CreatedModifiedBy
                       END col  ,
                    CASE 
                         WHEN Perform = 'A' THEN NULL
                    ELSE v_DateCreatedmodified
                       END col  ,
                    NULL MIS_APP_USR_ID  ,
                    NULL MIS_APP_USR_PASS  ,
                    NULL UserLocationExcel  ,
                    NULL WorkFlowUserRoleAlt_Key  ,
                    ApplicableBACID ,
                    ----,ApplicableSolId
                    DepartmentId ,
                    'U' ,
                    IsChecker2 
             FROM tt_UserMasterUploadData_8  );
         utils.commit_transaction;
         v_Result := 1 ;
         RETURN v_Result;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
      DBMS_OUTPUT.PUT_LINE('Error');
      v_Result := -1 ;
      RETURN -1;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERUPLOADINSERT_NEW" TO "ADF_CDR_RBL_STGDB";
