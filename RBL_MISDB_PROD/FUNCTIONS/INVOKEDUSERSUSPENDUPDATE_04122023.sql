--------------------------------------------------------
--  DDL for Function INVOKEDUSERSUSPENDUPDATE_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_UserLoginID IN VARCHAR2,
  v_LoginPassword IN VARCHAR2,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifyBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_UserRole_Key NUMBER(10,0);
   v_UserLocationCode VARCHAR2(10);
   v_UserLocation VARCHAR2(10);
   v_DepartmentCode VARCHAR2(20);
   v_DepartmentAlt_Key NUMBER(10,0);
   v_UserName VARCHAR2(20);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'GLProductCodeMaster' ;
   -------------------------------------------------------------
   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
   DBMS_OUTPUT.PUT_LINE('A');
   SELECT ParameterValue 

     INTO v_AppAvail
     FROM SysSolutionParameter 
    WHERE  Parameter_Key = 6;
   IF ( v_AppAvail = 'N' ) THEN

   BEGIN
      v_Result := -11 ;
      RETURN v_Result;

   END;
   END IF;
   --IF Object_id('Tempdb..#Temp') Is Not Null
   --Drop Table #Temp
   --IF Object_id('Tempdb..#final') Is Not Null
   --Drop Table #final
   --Create table #Temp
   --(ProductCode Varchar(20)
   --,SourceAlt_Key Varchar(20)
   --,ProductDescription Varchar(500)
   --)
   --Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)
   --Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
   --SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
   --							FROM  (SELECT 
   --											CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
   --											ProductCode,ProductDescription
   --											from #Temp
   --									) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
   --)A 
   --ALTER TABLE #FINAL ADD UserLoginID INT
   IF v_OperationFlag = 1 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

    --- add
   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      -----CHECK DUPLICATE
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM DimUserInfo 
                          WHERE  UserLoginID = v_UserLoginID

                                   --AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM DimUserInfo_mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND UserLoginID = v_UserLoginID

                                   --AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE(2);
         v_Result := -4 ;
         RETURN v_Result;-- USER ALEADY EXISTS

      END;
      ELSE

      BEGIN
         DBMS_OUTPUT.PUT_LINE(3);

      END;
      END IF;

   END;
   END IF;
   --SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
   --						(Select UserLoginID from DimUserInfo
   --						 UNION 
   --						 Select UserLoginID from DimUserInfo_Mod
   --						)A)
   IF v_OperationFlag = 2 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         --UPDATE TEMP 
         --SET TEMP.UserLoginID=@UserLoginID
         --	FROM #final TEMP
         --select * from #final
         --select * from TEMP
         -----
         DBMS_OUTPUT.PUT_LINE(3);
         --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK 
         IF v_OperationFlag = 1
           AND v_AuthMode = 'Y' THEN

          -- ADD
         BEGIN
            DBMS_OUTPUT.PUT_LINE('Add');
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_AuthorisationStatus := 'NP' ;
            ----SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
            ----						(Select UserLoginID from DimUserInfo
            ----						 UNION 
            ----						 Select UserLoginID from DimUserInfo_Mod
            ----						)A)
            GOTO GLCodeMaster_Insert;
            <<GLCodeMaster_Insert_Add>>

         END;
         ELSE
            IF ( v_OperationFlag = 2
              OR v_OperationFlag = 3 )
              AND v_AuthMode = 'Y' THEN

             --EDIT AND DELETE
            BEGIN
               DBMS_OUTPUT.PUT_LINE(4);
               v_CreatedBy := v_CrModApBy ;
               v_DateCreated := SYSDATE ;
               v_ModifyBy := v_CrModApBy ;
               v_DateModified := SYSDATE ;
               DBMS_OUTPUT.PUT_LINE(5);
               IF v_OperationFlag = 2 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Edit');
                  v_AuthorisationStatus := 'MP' ;

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('DELETE');
                  v_AuthorisationStatus := 'DP' ;

               END;
               END IF;
               ---FIND CREATED BY FROM MAIN TABLE
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM DimUserInfo 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND UserLoginID = v_UserLoginID;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimUserInfo_mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND UserLoginID = v_UserLoginID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DimUserInfo
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UserLoginID = v_UserLoginID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE DimUserInfo_mod
                     SET AuthorisationStatus = 'FM',
                         ModifyBy = v_ModifyBy,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UserLoginID = v_UserLoginID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO GLCodeMaster_Insert;
               <<GLCodeMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_ModifyBy := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE DimUserInfo
                     SET ModifyBy = v_ModifyBy,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UserLoginID = v_UserLoginID;

               END;

               ----------------------------------NEW ADD FIRST LVL AUTH------------------
               ELSE
                  IF v_OperationFlag = 21
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE DimUserInfo_mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND UserLoginID = v_UserLoginID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DimUserInfo 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND UserLoginID = v_UserLoginID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DimUserInfo
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UserLoginID = v_UserLoginID
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -------------------------------------------------------------------------
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimUserInfo_mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UserLoginID = v_UserLoginID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                        DBMS_OUTPUT.PUT_LINE('Sunil');
                        --		DECLARE @EntityKey as Int 
                        --SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                        --					 FROM DimGL_Mod 
                        --						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                        --							AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
                        --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                        --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                        --------------------------------
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM DimUserInfo 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND UserLoginID = v_UserLoginID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimUserInfo
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND UserLoginID = v_UserLoginID
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;
                     ELSE
                        IF v_OperationFlag = 18 THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE(18);
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE DimUserInfo_mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND UserLoginID = v_UserLoginID;

                        END;

                        --------NEW ADD------------------
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimUserInfo_mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedByFirstLevel = v_ApprovedBy,
                                     DateApprovedFirstLevel = UTILS.CONVERT_TO_VARCHAR2(v_DateApproved,200)
                               WHERE  UserLoginID = v_UserLoginID
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

                           END;

                           ------------------------------
                           ELSE
                              IF v_OperationFlag = 20
                                OR v_AuthMode = 'N' THEN

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('Authorise');
                                 -------set parameter for  maker checker disabled
                                 IF v_AuthMode = 'N' THEN

                                 BEGIN
                                    IF v_OperationFlag = 1 THEN

                                    BEGIN
                                       v_CreatedBy := v_CrModApBy ;
                                       v_DateCreated := SYSDATE ;

                                    END;
                                    ELSE

                                    BEGIN
                                       v_ModifyBy := v_CrModApBy ;
                                       v_DateModified := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM DimUserInfo 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND UserLoginID = v_UserLoginID;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 ---set parameters and UPDATE mod table in case maker checker enabled
                                 IF v_AuthMode = 'Y' THEN
                                  DECLARE
                                    v_DelStatus CHAR(2) := ' ';
                                    v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                                    v_CurEntityKey NUMBER(10,0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('B');
                                    DBMS_OUTPUT.PUT_LINE('C');
                                    SELECT MAX(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM DimUserInfo_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND UserLoginID = v_UserLoginID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifyBy ,
                                           DateModified 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifyBy,
                                           v_DateModified
                                      FROM DimUserInfo_mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM DimUserInfo_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND UserLoginID = v_UserLoginID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM DimUserInfo_mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE DimUserInfo_mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND UserLoginID = v_UserLoginID
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE DimUserInfo_mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  UserLoginID = v_UserLoginID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
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

                                       BEGIN
                                          UPDATE DimUserInfo
                                             SET AuthorisationStatus = 'A',
                                                 ModifyBy = v_ModifyBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND UserLoginID = v_UserLoginID;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('SAC1');
                                       UPDATE DimUserInfo_mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  UserLoginID = v_UserLoginID
                                         AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_DelStatus <> 'DP'
                                   OR v_AuthMode = 'N' THEN
                                  DECLARE
                                    v_IsAvailable CHAR(1) := 'N';
                                    v_IsSCD2 CHAR(1) := 'N';
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                                    -----------------------------new addby anuj /Jayadev 26052021 ----
                                    -- SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
                                    --				(Select UserLoginID from DimUserInfo
                                    --				 UNION 
                                    --				 Select UserLoginID from DimUserInfo_Mod
                                    --				)A)
                                    ----------------------------------------------
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
                                       v_IsAvailable := 'Y' ;
                                       --SET @AuthorisationStatus='A'
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

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE DimUserInfo
                                             SET SuspendedUser = 'N',
                                                 ScreenFlag = 'S',
                                                 ApprovedBy = CASE 
                                                                   WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                                 ELSE NULL
                                                    END,
                                                 DateApproved = CASE 
                                                                     WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                 ELSE NULL
                                                    END,
                                                 AuthorisationStatus = 'A'
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND UserLoginID = v_UserLoginID;

                                       END;
                                       ELSE

                                       BEGIN
                                          v_IsSCD2 := 'Y' ;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    --select @IsAvailable,@IsSCD2
                                    IF v_IsAvailable = 'N'
                                      OR v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       SELECT UserRoleAlt_Key 

                                         INTO v_UserRole_Key
                                         FROM DimUserInfo 
                                        WHERE  UserLoginID = v_UserLoginID
                                                 AND ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey );
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
                                                AND INFO.DeptGroupCode = DEP.DeptGroupId;
                                       SELECT UserName 

                                         INTO v_UserName
                                         FROM DimUserInfo 
                                        WHERE  UserLoginID = v_UserLoginID
                                                 AND ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey );
                                       INSERT INTO DimUserInfo
                                         ( UserLoginID, UserName, EffectiveFromTimeKey, EffectiveToTimeKey, LoginPassword, UserRoleAlt_Key, DeptGroupCode, SuspendedUser, PasswordChanged, Activate, CurrentLoginDate, MenuId, AuthorisationStatus, CreatedBy, DateCreated, ModifyBy, DateModified, ChangePwdCnt, EmployeeID, IsEmployee, IsChecker, Email_ID, DepartmentID, ScreenFlag, IsChecker2 )
                                         ( SELECT v_UserLoginID ,
                                                  v_UserName ,
                                                  v_EffectiveFromTimeKey ,
                                                  v_EffectiveToTimeKey ,
                                                  v_LoginPassword ,
                                                  v_UserRole_Key ,
                                                  v_DepartmentAlt_Key ,
                                                  --------------
                                                  'N' ,
                                                  'N' ,
                                                  'Y' ,
                                                  SYSDATE ,
                                                  v_MenuId ,
                                                  'A' ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y'
                                                         OR v_IsAvailable = 'Y' THEN v_ModifyBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y'
                                                         OR v_IsAvailable = 'Y' THEN v_DateModified
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                  ELSE NULL
                                                     END col  ,
                                                  ChangePwdCnt ,
                                                  EmployeeID ,
                                                  IsEmployee ,
                                                  IsChecker ,
                                                  Email_ID ,
                                                  DepartmentID ,
                                                  ScreenFlag ,
                                                  IsChecker2 
                                           FROM DimUserInfo 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                     AND UserLoginID = v_UserLoginID );
                                       UPDATE UserLoginHistory
                                          SET LoginSucceeded = 'Y'
                                        WHERE  UserID = v_UserLoginID
                                         AND LoginSucceeded = 'W';
                                       UPDATE DimUserInfo
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND EffectiveFromTimeKey < v_EffectiveFromTimeKey
                                         AND UserLoginID = v_UserLoginID;

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE DimUserInfo
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND UserLoginID = v_UserLoginID
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO GLCodeMaster_Insert;
                                    <<HistoryRecordInUp>>

                                 END;
                                 END IF;

                              END;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<GLCodeMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            -----------------------------------------------------------
            --	IF Object_id('Tempdb..#Temp') Is Not Null
            --Drop Table #Temp
            --	IF Object_id('Tempdb..#final') Is Not Null
            --Drop Table #final
            --Create table #Temp
            --(ProductCode Varchar(20)
            --,SourceAlt_Key Varchar(20)
            --,ProductDescription Varchar(500)
            --)
            --Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)
            --Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
            --SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
            --                            FROM  (SELECT 
            --                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
            --											ProductCode,ProductDescription
            --                                            from #Temp
            --                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
            --)A 
            --ALTER TABLE #FINAL ADD UserLoginID INT
            --IF @OperationFlag=1 
            --BEGIN
            --UPDATE TEMP 
            --SET TEMP.UserLoginID=ACCT.UserLoginID
            -- FROM #final TEMP
            --INNER JOIN (SELECT SourceAlt_Key,(@UserLoginID + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) UserLoginID
            --			FROM #final
            --			WHERE UserLoginID=0 OR UserLoginID IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
            --END
            --IF @OperationFlag=2 
            --BEGIN
            --UPDATE TEMP 
            --SET TEMP.UserLoginID=@UserLoginID
            -- FROM #final TEMP
            --END
            --------------------------------------------------
            SELECT UserRoleAlt_Key 

              INTO v_UserRole_Key
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserLoginID
                      AND ( EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey );
            SELECT UserName 

              INTO v_UserName
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserLoginID
                      AND ( EffectiveFromTimeKey <= v_TimeKey
                      AND EffectiveToTimeKey >= v_TimeKey );
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
                     AND INFO.DeptGroupCode = DEP.DeptGroupId;
            DBMS_OUTPUT.PUT_LINE('@DepartmentCode');
            DBMS_OUTPUT.PUT_LINE(v_DepartmentCode);
            DBMS_OUTPUT.PUT_LINE('@UserRole_Key');
            DBMS_OUTPUT.PUT_LINE(v_UserRole_Key);
            DBMS_OUTPUT.PUT_LINE('@DepartmentAlt_Key');
            DBMS_OUTPUT.PUT_LINE(v_DepartmentAlt_Key);
            INSERT INTO DimUserInfo_mod
              ( UserLoginID, UserName, EffectiveFromTimeKey, EffectiveToTimeKey, LoginPassword, UserRoleAlt_Key, DeptGroupCode, AuthorisationStatus, SuspendedUser, MenuId, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, ChangePwdCnt, EmployeeID, IsEmployee, IsChecker, Email_ID, DepartmentID, ScreenFlag, IsChecker2 )
              ( SELECT v_UserLoginID ,
                       v_UserName ,
                       v_EffectiveFromTimeKey ,
                       v_EffectiveToTimeKey ,
                       v_LoginPassword ,
                       v_UserRole_Key ,
                       v_DepartmentAlt_Key ,
                       v_AuthorisationStatus ,
                       'Y' ,
                       v_MenuId ,
                       v_CreatedBy ,
                       v_DateCreated ,
                       CASE 
                            WHEN v_AuthMode = 'Y'
                              OR v_IsAvailable = 'Y' THEN v_ModifyBy
                       ELSE NULL
                          END col  ,
                       CASE 
                            WHEN v_AuthMode = 'Y'
                              OR v_IsAvailable = 'Y' THEN v_DateModified
                       ELSE NULL
                          END col  ,
                       CASE 
                            WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                       ELSE NULL
                          END col  ,
                       CASE 
                            WHEN v_AuthMode = 'Y' THEN v_DateApproved
                       ELSE NULL
                          END col  ,
                       ChangePwdCnt ,
                       EmployeeID ,
                       IsEmployee ,
                       IsChecker ,
                       Email_ID ,
                       DepartmentID ,
                       ScreenFlag ,
                       IsChecker2 
                FROM DimUserInfo 
                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UserLoginID = v_UserLoginID );
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO GLCodeMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO GLCodeMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --															AND GLAlt_Key=@GLAlt_Key
         IF v_OperationFlag = 3 THEN

         BEGIN
            v_Result := 0 ;

         END;
         ELSE

         BEGIN
            v_Result := 1 ;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
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
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN -1;---------

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVOKEDUSERSUSPENDUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
