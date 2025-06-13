--------------------------------------------------------
--  DDL for Function USERPARAMETERSINSERTUPDATE_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  iv_CreatedBy IN VARCHAR2 DEFAULT NULL ,
  v_CreatedDate IN VARCHAR2 DEFAULT NULL ,
  v_NONUSE IN NUMBER DEFAULT 0 ,
  v_PWDCHNG IN NUMBER DEFAULT 0 ,
  v_PWDLEN IN NUMBER DEFAULT 0 ,
  v_PWDNUM IN NUMBER DEFAULT 0 ,
  v_PWDREUSE IN NUMBER DEFAULT 0 ,
  v_UNLOGON IN NUMBER DEFAULT 0 ,
  v_USERIDALP IN NUMBER DEFAULT 0 ,
  v_USERIDLEN IN NUMBER DEFAULT 0 ,
  v_USERIDLENMAX IN NUMBER DEFAULT 0 ,
  v_PWDLENMAX IN NUMBER DEFAULT 0 ,
  v_PWDALPHAMIN IN NUMBER DEFAULT 0 ,
  v_USERSHOMAX IN NUMBER DEFAULT 0 ,
  v_USERSROMAX IN NUMBER DEFAULT 0 ,
  v_USERSBOMAX IN NUMBER DEFAULT 0 ,
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
   --Declare
   v_CreatedBy VARCHAR2(20) := iv_CreatedBy;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   --,@CreatedBy					VARCHAR(20)		= NULL
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
   v_CurrentLoginDate VARCHAR2(200);--- added by shailesh naik on 10/06/2014
   * INTO ##temp2 FROM ( SELECT * FROM ( SELECT * FROM tt_temp1_76 ) T UNPIVOT (  --SQLDEV: NOT RECOGNIZED
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'GLProductCodeMaster' ;
   -------------------------------------------------------------
   --SET @CreatedDate=NULL
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
   --SET @AuthMode=CASE WHEN @AuthMode in('S','H','A') THEN 'Y' else 'N' END
   SELECT CurrentLoginDate 

     INTO v_CurrentLoginDate
     FROM DimUserInfo 
    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey )
             AND UserLoginID = v_CreatedBy;
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
   ----IF @OperationFlag=1  --- add
   ----BEGIN
   ----PRINT 1
   ----	-----CHECK DUPLICATE
   ----	IF EXISTS(				                
   ----				SELECT  1 FROM DimUserParameters WHERE  ShortNameEnum IN('NONUSE','UNLOGON')
   ----				--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
   ----				AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
   ----				UNION
   ----				SELECT  1 FROM DimUserParameters_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
   ----														AND  ShortNameEnum IN('NONUSE','UNLOGON')
   ----														--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
   ----														AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
   ----			)	
   ----			BEGIN
   ----			   PRINT 2
   ----				SET @Result=-4
   ----				RETURN @Result -- USER ALEADY EXISTS
   ----			END
   ----	ELSE
   ----		BEGIN
   ----		   PRINT 3
   ----				 SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
   ----											(Select UserLoginID from DimUserParameters
   ----											 UNION 
   ----											 Select UserLoginID from DimUserParameters_Mod
   ----											)A)
   ----		END
   ----END
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
         --SET TEMP.ShortNameEnum IN('NONUSE','UNLOGON')
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
            ----						(Select UserLoginID from DimUserParameters
            ----						 UNION 
            ----						 Select UserLoginID from DimUserParameters_Mod
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
                 FROM DimUserParameters 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                 FETCH FIRST 1 ROWS ONLY;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimUserParameters_mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )

                    FETCH FIRST 1 ROWS ONLY;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DimUserParameters
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                  ;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE DimUserParameters_mod
                     SET AuthorisationStatus = 'FM',
                         ModifyBy = v_ModifyBy,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                  UPDATE DimUserParameters
                     SET ModifyBy = v_ModifyBy,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                  ;

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
                     UPDATE DimUserParameters_mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DimUserParameters 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                      );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DimUserParameters
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                        UPDATE DimUserParameters_mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                                           FROM DimUserParameters 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                         );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimUserParameters
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                           UPDATE DimUserParameters_mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                           ;

                        END;

                        --------NEW ADD------------------

                        --ELSE IF @OperationFlag=16

                        --	BEGIN

                        --	SET @ApprovedBy	   = @CrModApBy 

                        --	SET @DateApproved  = GETDATE()

                        --	UPDATE DimUserParameters_Mod

                        --					SET AuthorisationStatus ='1A'

                        --						,ApprovedBy=@ApprovedBy

                        --						,DateApproved=@DateApproved

                        --						WHERE ShortNameEnum IN('NONUSE','UNLOGON')

                        --						AND AuthorisationStatus in('NP','MP','DP','RM')

                        --	END

                        ------------------------------

                        --------NEW ADD------------------
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('Sachin16');
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimUserParameters_mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedByFirstLevel = v_ApprovedBy,
                                     DateApprovedFirstLevel = v_DateApproved
                               WHERE  AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

                           END;

                           --WHERE UserLoginID=@CreatedBy

                           --AND AuthorisationStatus in('NP','MP','DP','RM')

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
                                         FROM DimUserParameters 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                       ;
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
                                      FROM DimUserParameters_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                                      FROM DimUserParameters_mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM DimUserParameters_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM DimUserParameters_mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE DimUserParameters_mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE DimUserParameters_mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimUserParameters 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                        );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE DimUserParameters
                                             SET AuthorisationStatus = 'A',
                                                 ModifyBy = v_ModifyBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                          ;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE DimUserParameters_mod
                                          SET AuthorisationStatus = '1A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                                    --				(Select UserLoginID from DimUserParameters
                                    --				 UNION 
                                    --				 Select UserLoginID from DimUserParameters_Mod
                                    --				)A)
                                    ----------------------------------------------
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM DimUserParameters 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                     );
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
                                                          FROM DimUserParameters 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                        );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN


                                       --AND EffectiveFromTimeKey=@EffectiveFromTimeKey 
                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          MERGE INTO A 
                                          USING (SELECT A.ROWID row_id, B.ShortNameEnum, B.ParameterType, b.ParameterValue, B.MinValue, B.MaxValue, CASE 
                                          WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                          ELSE NULL
                                             END AS pos_7, CASE 
                                          WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                          ELSE NULL
                                             END AS pos_8, CASE 
                                          WHEN v_AuthMode = 'Y' THEN 'A'
                                          ELSE NULL
                                             END AS pos_9
                                          FROM A ,DimUserParameters A
                                                 JOIN DimUserParameters_mod B   ON A.SeqNo = B.SeqNo 
                                           WHERE ( A.EffectiveFromTimeKey <= v_TimeKey
                                            AND A.EffectiveToTimeKey >= v_TimeKey )
                                            AND B.ShortNameEnum IN ( 'NONUSE','UNLOGON' )

                                            AND B.EntityKey IN ( SELECT MAX(EntityKey)  
                                                                 FROM DimUserParameters_mod 
                                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                                           AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                                   GROUP BY ShortNameEnum )
                                          ) src
                                          ON ( A.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET A.ShortNameEnum = src.ShortNameEnum,
                                                                       A.ParameterType = src.ParameterType,
                                                                       A.ParameterValue = src.ParameterValue,
                                                                       A.MinValue = src.MinValue,
                                                                       A.MaxValue = src.MaxValue,
                                                                       ApprovedBy = pos_7,
                                                                       DateApproved = pos_8,
                                                                       AuthorisationStatus = pos_9;
                                          UPDATE DimUserParameters_mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
                                       --Alter TAble DimUserParameters
                                       --ADD Remark Varchar(max) Null
                                       INSERT INTO DimUserParameters
                                         ( ShortNameEnum, ParameterType, ParameterValue, SeqNo, MinValue, MaxValue, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, DateCreated, CreatedBy, ModifyBy, DateModified, Remark )
                                         ( SELECT ShortNameEnum ,
                                                  ParameterType ,
                                                  ParameterValue ,
                                                  SeqNo ,
                                                  MinValue ,
                                                  MaxValue ,
                                                  AuthorisationStatus ,
                                                  EffectiveFromTimeKey ,
                                                  EffectiveToTimeKey ,
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
                                                  Remark 
                                           FROM DimUserParameters_mod 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_TimeKey )
                                                     AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                          );
                                       UPDATE DimUserParameters
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND EffectiveFromTimeKey < v_EffectiveFromTimeKey
                                         AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
                                       ;

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE DimUserParameters
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )

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
            IF utils.object_id('Tempdb..tt_temp1_76') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_76 ';
            END IF;
            DELETE FROM tt_temp1_76;
            INSERT INTO tt_temp1_76
              ( NONUSE, PWDCHNG, PWDLEN, PWDNUM, PWDREUSE, UNLOGON, USERIDALP, USERIDLEN, USERIDLENMAX, PWDLENMAX, PWDALPHAMIN, USERSHOMAX, USERSROMAX, USERSBOMAX )
              ( SELECT v_NONUSE ,
                       v_PWDCHNG ,
                       v_PWDLEN ,
                       v_PWDNUM ,
                       v_PWDREUSE ,
                       v_UNLOGON ,
                       v_USERIDALP ,
                       v_USERIDLEN ,
                       v_USERIDLENMAX ,
                       v_PWDLENMAX ,
                       v_PWDALPHAMIN ,
                       v_USERSHOMAX ,
                       v_USERSROMAX ,
                       v_USERSBOMAX 
                  FROM DUAL  );
            IF utils.object_id('Tempdb..##temp2') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_49 ';
            END IF;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT * 
                        FROM tt_temp1_76  ) T ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            --PRINT 
            ( FOR ParameterName IN ( NONUSE , PWDCHNG , PWDLEN , PWDNUM , PWDREUSE , UNLOGON , USERIDALP , USERIDLEN , USERIDLENMAX , PWDLENMAX , PWDALPHAMIN , USERSHOMAX , USERSROMAX , USERSBOMAX ) ) P ) A  --SQLDEV: NOT RECOGNIZED
            DBMS_OUTPUT.PUT_LINE('@CreatedDate');
            DBMS_OUTPUT.PUT_LINE(v_CreatedDate);
            INSERT INTO DimUserParameters_mod
              ( ShortNameEnum, ParameterType, ParameterValue, SeqNo, MinValue, MaxValue, AuthorisationStatus, DateCreated, CreatedBy, EffectiveFromTimeKey, EffectiveToTimeKey, ModifyBy, DateModified, Remark )
              ( SELECT ShortNameEnum ,
                       ParameterType ,
                       B.ParameterValue ,
                       SeqNo ,
                       MinValue ,
                       MaxValue ,
                       v_AuthorisationStatus ,
                       UTILS.CONVERT_TO_DATETIME(v_CreatedDate) DateCreated  ,
                       v_CreatedBy ,
                       v_EffectiveFromTimeKey ,
                       v_EffectiveToTimeKey ,
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
                       v_Remark 
                FROM DimUserParameters A
                       LEFT JOIN tt_temp2_49 B   ON B.ParameterName = A.ShortNameEnum
                 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND ShortNameEnum IN ( 'NONUSE','UNLOGON' )
               );
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERSINSERTUPDATE_04122023" TO "ADF_CDR_RBL_STGDB";
