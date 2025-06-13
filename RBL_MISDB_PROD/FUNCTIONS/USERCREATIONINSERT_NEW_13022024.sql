--------------------------------------------------------
--  DDL for Function USERCREATIONINSERT_NEW_13022024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" 
(
  --Declare
  v_UserLoginID IN VARCHAR2 DEFAULT ' ' ,
  v_EmployeeID IN VARCHAR2 DEFAULT ' ' ,
  v_IsEmployee IN CHAR DEFAULT ' ' ,
  v_UserName IN VARCHAR2 DEFAULT ' ' ,
  v_LoginPassword IN VARCHAR2 DEFAULT ' ' ,
  v_UserLocation IN VARCHAR2 DEFAULT ' ' ,
  v_UserLocationCode IN VARCHAR2 DEFAULT ' ' ,
  v_UserRoleAlt_Key IN NUMBER DEFAULT 0 ,
  v_DeptGroupCode IN VARCHAR2 DEFAULT ' ' ,
  v_DepartmentId IN VARCHAR2 DEFAULT ' ' ,
  v_ApplicableSolIds IN VARCHAR2 DEFAULT ' ' ,
  v_ApplicableBACID IN VARCHAR2 DEFAULT ' ' ,
  v_DateCreatedmodified IN DATE DEFAULT NULL ,
  v_CreatedModifyBy IN VARCHAR2 DEFAULT NULL ,
  v_Activate IN CHAR DEFAULT ' ' ,
  v_IsChecker IN CHAR DEFAULT ' ' ,
  v_IsChecker2 IN VARCHAR2 DEFAULT ' ' ,
  v_WorkFlowUserRoleAlt_Key IN NUMBER DEFAULT 0 ,
  v_DesignationAlt_Key IN NUMBER DEFAULT 0 ,
  v_IsCma IN CHAR DEFAULT ' ' ,
  v_MobileNo IN VARCHAR2 DEFAULT ' ' ,
  v_Email_ID IN VARCHAR2 DEFAULT ' ' ,
  v_SecuritQsnAlt_Key IN NUMBER,
  v_SecurityAns IN VARCHAR2,
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
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'GLProductCodeMaster' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
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
            v_CreatedBy := v_CreatedModifyBy ;
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
               --SET @CreatedBy= @CreatedModifyBy
               --SET @DateCreated = GETDATE()
               v_ModifyBy := v_CreatedModifyBy ;
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
               ---FIND CREATED BY FROM MOD TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
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
                  v_ModifyBy := v_CreatedModifyBy ;
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
                     v_ApprovedBy := v_CreatedModifyBy ;
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
                        v_ApprovedBy := v_CreatedModifyBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimUserInfo_mod
                           SET AuthorisationStatus = 'R',
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved,
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
                        --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CreatedModifyBy
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
                           v_ApprovedBy := v_CreatedModifyBy ;
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
                              v_ApprovedBy := v_CreatedModifyBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimUserInfo_mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedByFirstLevel = v_ApprovedBy,
                                     DateApprovedFirstLevel = v_DateApproved

                              --,DateApprovedFirstLevel=Convert(Date,@DateApproved)
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
                                       v_CreatedBy := v_CreatedModifyBy ;
                                       v_DateCreated := SYSDATE ;

                                    END;
                                    ELSE

                                    BEGIN
                                       v_ModifyBy := v_CreatedModifyBy ;
                                       v_DateModified := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM DimUserInfo 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND UserLoginID = v_UserLoginID;
                                       v_ApprovedBy := v_CreatedModifyBy ;
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
                                    v_ApprovedBy := v_CreatedModifyBy ;
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
                                    DBMS_OUTPUT.PUT_LINE('RAHUL');
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
                                       DBMS_OUTPUT.PUT_LINE('SAC10');
                                       --Select 'DimUserInfo_Mod_Before',AuthorisationStatus,* from DimUserInfo_Mod
                                       --            Where UserLoginID='dummyuser45'
                                       UPDATE DimUserInfo_mod
                                          SET AuthorisationStatus = '1A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  UserLoginID = v_UserLoginID
                                         AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 --Select 'DimUserInfo_Mod_After',AuthorisationStatus,* from DimUserInfo_Mod
                                 --        Where UserLoginID='dummyuser45'
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
                                    DBMS_OUTPUT.PUT_LINE('@TimeKey');
                                    DBMS_OUTPUT.PUT_LINE(v_TimeKey);
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
                                       --SET @AuthorisationStatus='A'
                                       --AND EffectiveFromTimeKey=@EffectiveFromTimeKey
                                       --DECLARE @DesignationAlt_Key2 INT=
                                       --								(
                                       --									Select DesignationAlt_Key FROM DimUserInfo_mod 
                                       --									WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
                                       --									AND UserLoginID=@UserLoginID 
                                       --									AND EntityKey IN
                                       --									(
                                       --									    SELECT MAX(EntityKey)
                                       --									    FROM DimUserInfo_mod
                                       --									    WHERE EffectiveFromTimeKey <= @TimeKey
                                       --									          AND EffectiveToTimeKey >= @TimeKey
                                       --											   AND UserLoginID=@UserLoginID
                                       --									          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A','1D','A')
                                       --									    GROUP BY UserLoginID
                                       --									)
                                       --								)
                                       ---------- IMPLEMENT LOGIC TO UPDATE DESIGNATION IN MAIN TABLE BY SATWAJI AS ON 18/04/2023 -------------------------------------------------
                                       v_DesignationName VARCHAR2(100) := ( SELECT ParameterName 
                                         FROM DimParameter 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND DimParameterName = 'DimUserDesignation'
                                                 AND ParameterAlt_Key = ( SELECT DesignationAlt_Key 
                                                                          FROM DimUserInfo_mod 
                                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                                    AND UserLoginID = v_UserLoginID
                                                                                    AND EntityKey IN ( SELECT MAX(EntityKey)  
                                                                                                       FROM DimUserInfo_mod 
                                                                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                                                                 AND UserLoginID = v_UserLoginID
                                                                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A','1D','A' )

                                                                                                         GROUP BY UserLoginID )
                                                ) );
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       v_IsAvailable := 'Y' ;
                                       DBMS_OUTPUT.PUT_LINE('Sac1');
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimUserInfo 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND UserLoginID = v_UserLoginID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          DBMS_OUTPUT.PUT_LINE('Sac2');
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
                                                 ScreenFlag = 'S',
                                                 ModifyBy = v_ModifyBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = CASE 
                                                                   WHEN v_AuthMode = 'Y' THEN v_CreatedModifyBy
                                                 ELSE NULL
                                                    END,
                                                 DateApproved = CASE 
                                                                     WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                 ELSE NULL
                                                    END,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AuthMode = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END,
                                                 Designation = v_DesignationName
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND UserLoginID = v_UserLoginID;
                                          UPDATE DimUserInfo_mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  UserLoginID = v_UserLoginID
                                            AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                          ;

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
                                       DBMS_OUTPUT.PUT_LINE('Sachin20');
                                       UPDATE DimUserInfo
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND EffectiveFromTimeKey < v_EffectiveFromTimeKey
                                         AND UserLoginID = v_UserLoginID;
                                       INSERT INTO DimUserInfo
                                         ( UserLoginID, EmployeeID, IsEmployee, UserName, LoginPassword, UserLocation, DeptGroupCode, Activate, IsChecker, IsChecker2, EffectiveFromTimeKey, EffectiveToTimeKey
                                       ----,EntityKey 
                                       , PasswordChanged
                                       --------
                                       , PasswordChangeDate, ChangePwdCnt, UserLocationCode, UserRoleAlt_Key, SuspendedUser, CurrentLoginDate, ResetDate, UserLogged, UserDeletionReasonAlt_Key, SystemLogOut, RBIFLAG, Email_ID --ad4
                                       , MobileNo, DesignationAlt_Key, IsCma, SecuritQsnAlt_Key, SecurityAns, MenuId, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, MIS_APP_USR_ID, MIS_APP_USR_PASS, UserLocationExcel, WorkFlowUserRoleAlt_Key, ApplicableBACID
                                       ----,ApplicableSolIds
                                       , DepartmentId, ScreenFlag, AuthorisationStatus, Designation )
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
                                                  MIS_APP_USR_ID ,
                                                  MIS_APP_USR_PASS ,
                                                  UserLocationExcel ,
                                                  v_WorkFlowUserRoleAlt_Key ,
                                                  v_ApplicableBACID ,
                                                  ----,@ApplicableSolIds
                                                  v_DepartmentId ,
                                                  'S' ,
                                                  'A' ,
                                                  Designation 
                                           FROM DimUserInfo_mod 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                     AND UserLoginID = v_UserLoginID
                                                     AND AuthorisationStatus IN ( '1A' )
                                          );
                                       UPDATE DimUserInfo_mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  UserLoginID = v_UserLoginID
                                         AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ;

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
            INSERT INTO DimUserInfo_mod
              ( UserLoginID, EmployeeID, IsEmployee, UserName, LoginPassword, UserLocation, DeptGroupCode, Activate, IsChecker, IsChecker2, EffectiveFromTimeKey, EffectiveToTimeKey
            ----,EntityKey 
            , PasswordChanged, PasswordChangeDate, ChangePwdCnt, UserLocationCode, UserRoleAlt_Key, SuspendedUser, CurrentLoginDate, ResetDate, UserLogged, UserDeletionReasonAlt_Key, SystemLogOut, RBIFLAG, Email_ID --ad4
            , MobileNo, DesignationAlt_Key, isCma, SecuritQsnAlt_Key, SecurityAns, MenuId, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, MIS_APP_USR_ID, MIS_APP_USR_PASS, UserLocationExcel, WorkFlowUserRoleAlt_Key, ApplicableBACID
            ----,ApplicableSolIds
            , DepartmentId, ScreenFlag, AuthorisationStatus )
              VALUES ( v_UserLoginID, v_EmployeeID, v_IsEmployee, v_UserName, v_LoginPassword, v_UserLocation, v_DeptGroupCode, v_Activate, v_IsChecker, v_IsChecker2, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, 
            ------,@Entity_Key 
            'Y', NULL, 0, v_UserLocationCode, v_UserRoleAlt_Key, 'N', NULL --CurrentLoginDate
            , NULL --ResetDate
            , 0, NULL, NULL, NULL, NULLIF(v_Email_ID, ' ' --ad4
            ), v_MobileNo, v_DesignationAlt_Key, v_isCma, v_SecuritQsnAlt_Key, v_SecurityAns, v_MenuId, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), CASE 
                                                                                                                                                               WHEN v_AuthMode = 'Y'
                                                                                                                                                                 OR v_IsAvailable = 'Y' THEN v_ModifyBy
            ELSE NULL
               END, TO_DATE(CASE 
                                 WHEN v_AuthMode = 'Y'
                                   OR v_IsAvailable = 'Y' THEN v_DateModified
            ELSE NULL
               END,'dd/mm/yyyy'), CASE 
                                       WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
            ELSE NULL
               END, TO_DATE(CASE 
                                 WHEN v_AuthMode = 'Y' THEN v_DateApproved
            ELSE NULL
               END,'dd/mm/yyyy'), NULL, NULL, NULL, v_WorkFlowUserRoleAlt_Key, v_ApplicableBACID, 
            ----,@ApplicableSolIds
            v_DepartmentId, 'S', v_AuthorisationStatus );
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, Dp.ParameterName
            FROM A ,DimUserInfo_mod A
                   LEFT JOIN ( SELECT DimParameter.ParameterAlt_Key ,
                                      DimParameter.ParameterName 
                               FROM DimParameter 
                                WHERE  DimParameter.DimParameterName = 'DimUserDesignation' ) DP   ON A.DesignationAlt_Key = DP.ParameterAlt_Key 
             WHERE A.EffectiveFromTimeKey <= v_TimeKey
              AND A.EffectiveToTimeKey >= v_TimeKey) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Designation
                                         --select DesignationAlt_Key,DP.ParameterName, *
                                          = src.ParameterName;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERCREATIONINSERT_NEW_13022024" TO "ADF_CDR_RBL_STGDB";
