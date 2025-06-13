--------------------------------------------------------
--  DDL for Procedure USERCHANGEPASSWORDUPDATE_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" 
(
  v_UserLoginID IN VARCHAR2,
  v_LoginPassword IN VARCHAR2,
  v_PasswordChangeDate IN DATE,
  v_EffectiveFromTimeKey IN NUMBER,--33
  v_EffectiveToTimeKey IN NUMBER,
  v_TimeKey IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
AS
   v_sys_error NUMBER := 0;
   --DECLARE
   --@UserLoginID varchar(20)='FNA123',
   --         @LoginPassword varchar(max)='axis123',
   --         @PasswordChangeDate smalldatetime='2020-01-09 12:18:30.613',
   --         @EffectiveFromTimeKey INT=24928,                         --33
   --		 @EffectiveToTimeKey INT=49999,
   --		 @TimeKey smallint =24928,
   --		 @Result INT=0   
   v_ChangePwdDate DATE;
   v_ChangePwdMax NUMBER(10,0) := 0;
   v_ChangePwd NUMBER(10,0) := 0;
   v_PwdExist VARCHAR2(3) := 'N';
   v_maxKey NUMBER(5,0) := 0;
   v_maxuserEntity NUMBER(5,0) := 0;
   v_CurrentLoginDate VARCHAR2(200);
   v_PwdResetDate DATE;
   --RETURN -12 --- User Login Date is prior. Data will not be Saved. Please Close the Application.
   v_PreventPwd NUMBER(10,0) := 0;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   --SELECT @Timekey=Max(Timekey) from SysProcessingCycle  
   -- WHERE Extracted='Y'  and ProcessType='Full' --and PreMOC_CycleFrozenDate IS NULL  
   SELECT CurrentLoginDate 

     INTO v_CurrentLoginDate
     FROM DimUserInfo 
    WHERE ----(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey) AND 
     UserLoginID = v_UserLoginID;
   DBMS_OUTPUT.PUT_LINE('@CurrentLoginDate');
   DBMS_OUTPUT.PUT_LINE(v_CurrentLoginDate);
   --PRINT 'AALAA'
   IF utils.datediff('DAY', v_CurrentLoginDate, SYSDATE) <> 0 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(-12);

   END;
   END IF;
   SELECT ParameterValue 

     INTO v_PreventPwd
     FROM DimUserParameters 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND ShortNameEnum = 'PWDREUSE';
   SELECT ParameterValue 

     INTO v_ChangePwdMax
     FROM DimUserParameters 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND ShortNameEnum = 'PWDCHNG';
   SELECT ResetDate 

     INTO v_PwdResetDate
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_UserLoginID;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM DimUserInfo 
                       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND UserLoginID = v_UserLoginID );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      ------------------------
      DBMS_OUTPUT.PUT_LINE('exists');
      SELECT PasswordChangeDate 

        INTO v_ChangePwdDate
        FROM DimUserInfo 
       WHERE  UserLoginID = v_UserLoginID
                AND ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey );
      SELECT utils.datediff('D', v_ChangePwdDate, SYSDATE) Days  

        INTO v_ChangePwd
        FROM DUAL ;
      SELECT MAX(SeqNo)  

        INTO v_maxKey
        FROM UserPwdChangeHistory 
       WHERE  UserLoginID = v_UserLoginID
                AND STATUS = 'True';
      IF v_maxKey IS NULL THEN

      BEGIN
         v_maxKey := 0 ;

      END;
      END IF;
      SELECT v_maxKey - MAX(seqno)  userEntity  

        INTO v_maxuserEntity
        FROM UserPwdChangeHistory 
       WHERE  UserLoginID = v_UserLoginID
                AND LoginPassword = v_LoginPassword
                AND STATUS = 'True';
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM UserPwdChangeHistory 
                          WHERE  UserLoginID = v_UserLoginID
                                   AND LoginPassword = v_LoginPassword
                                   AND STATUS = 'True' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_PwdExist := 'Y' ;
         DBMS_OUTPUT.PUT_LINE('PwdExist');
         DBMS_OUTPUT.PUT_LINE(v_PwdExist);

      END;
      END IF;
      ---------------------------
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM UserPwdChangeHistory 
                              WHERE  UserLoginID = v_UserLoginID
                                       AND LoginPassword = v_LoginPassword
                                       AND STATUS = 'True' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('exist 1');
         INSERT INTO UserPwdChangeHistory
           ( UserLoginID, LoginPassword, SeqNo, PwdChangeTime, CreatedBy )
           VALUES ( v_UserLoginID, v_LoginPassword, v_maxKey + 1, SYSDATE, v_UserLoginID );

      END;
      ELSE
         IF v_maxuserEntity < v_PreventPwd - 1
           AND v_PwdExist = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(v_PwdExist);
            DBMS_OUTPUT.PUT_LINE(v_maxuserEntity);
            DBMS_OUTPUT.PUT_LINE(v_PreventPwd);
            ---Password has been reused < no of password restricted for reuse.
            --print -6
            v_Result := -8 ;
            --print @Result
            OPEN  v_cursor FOR
               SELECT v_Result 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            RETURN;

         END;
         ELSE
            IF v_maxuserEntity >= v_PreventPwd THEN

            BEGIN
               INSERT INTO UserPwdChangeHistory
                 ( UserLoginID, LoginPassword, SeqNo, PwdChangeTime, CreatedBy )
                 VALUES ( v_UserLoginID, v_LoginPassword, v_maxKey + 1, SYSDATE, v_UserLoginID );
               v_PwdExist := 'Y' ;

            END;
            ELSE
               v_PwdExist := 'Y' ;
            END IF;
         END IF;
      END IF;
      --IF @maxuserEntity<@PreventPwd AND @PwdExist='Y'
      -- BEGIN
      -- RETURN -6
      --END
      --  else 
      DBMS_OUTPUT.PUT_LINE('@ChangePwd');
      DBMS_OUTPUT.PUT_LINE(v_ChangePwd);
      DBMS_OUTPUT.PUT_LINE('@ChangePwdMax');
      DBMS_OUTPUT.PUT_LINE(v_ChangePwdMax);
      --IF @ChangePwd>@ChangePwdMax --AND @PwdExist='N'  --old
      IF v_ChangePwd > v_ChangePwdMax
        AND v_ChangePwdDate > v_PwdResetDate THEN

      BEGIN
         v_Result := -5 ;
         --print @Result
         OPEN  v_cursor FOR
            SELECT v_Result 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN;

      END;

      --------END---------------
      ELSE

      BEGIN
         --print 'This is Print'
         --print @UserLoginID
         --print @TimeKey
         OPEN  v_cursor FOR
            SELECT * 
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserLoginID
                      AND ( EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey ) ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         UPDATE DimUserInfo
            SET LoginPassword = v_LoginPassword,
                PasswordChanged = 'Y',
                PasswordChangeDate = SYSDATE,
                EffectiveFromTimeKey = v_EffectiveFromTimeKey --33
                ,
                EffectiveToTimeKey = v_EffectiveToTimeKey,
                ChangePwdCnt = v_ChangePwd
          WHERE  UserLoginID = v_UserLoginID
           AND ( EffectiveFromTimeKey <= v_TimeKey
           AND EffectiveToTimeKey >= v_TimeKey );
         v_Result := 1 ;
         --print @Result
         OPEN  v_cursor FOR
            SELECT v_Result 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN;

      END;
      END IF;

   END;
   ELSE
      v_Result := -2 ;
   END IF;
   --print @Result
   OPEN  v_cursor FOR
      SELECT v_Result 
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   RETURN;
   IF v_sys_error <> 0 THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
      DBMS_OUTPUT.PUT_LINE('a1');
      v_Result := -1 ;
      --print @Result
      OPEN  v_cursor FOR
         SELECT v_Result 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN;--  RETURN 1

   END;
   END IF;
   v_sys_error := 0;
   utils.commit_transaction;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCHANGEPASSWORDUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
