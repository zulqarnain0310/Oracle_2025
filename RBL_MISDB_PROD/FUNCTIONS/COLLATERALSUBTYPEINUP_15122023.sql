--------------------------------------------------------
--  DDL for Function COLLATERALSUBTYPEINUP_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" 
(
  iv_CollateralSubTypeAltKey IN NUMBER DEFAULT 0 ,
  v_CollateralTypeAltKey IN NUMBER DEFAULT 0 ,
  v_CollateralSubTypeID IN VARCHAR2 DEFAULT ' ' ,
  v_CollateralSubType IN VARCHAR2 DEFAULT ' ' ,
  v_CollateralSubTypeDescription IN VARCHAR2 DEFAULT ' ' ,
  --,@ValueExpirationAltKey				INT =0---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
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
   v_CollateralSubTypeAltKey NUMBER(10,0) := iv_CollateralSubTypeAltKey;
   v_AuthorisationStatus CHAR(2) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
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
   v_ScreenName := 'CollateralSubTypeMaster' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   --SET @CollateralSubTypeAltKey = (Select ISNULL(Max(CollateralSubTypeAltKey),0)+1 from DimCollateralSubType)
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
                         FROM DimCollateralSubType 
                          WHERE  CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM DimCollateralSubType_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
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
      END IF;

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         ----ELSE
         ----	BEGIN
         ----	   PRINT 3
         ---		SELECT @CollateralSubTypeAltKey=NEXT VALUE FOR Seq_CollateralSubTypeAltKey
         ----		PRINT @CollateralSubTypeAltKey
         ----	END
         ---------------------Added on 29/05/2020 for user allocation rights
         /*
         		IF @AccessScopeAlt_Key in (1,2)
         		BEGIN
         		PRINT 'Sunil'

         		IF EXISTS(				                
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CollateralSubTypeAltKey AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
         					And IsChecker='N'
         				)	
         				BEGIN
         				   PRINT 2
         					SET @Result=-6
         					RETURN @Result -- USER SHOULD HAVE CHECKER RIGHTS 
         				END
         		END


         		IF @AccessScopeAlt_Key in (3)
         		BEGIN
         		PRINT 'Sunil1'

         		IF EXISTS(				                
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CollateralSubTypeAltKey AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
         					And IsChecker='Y'
         				)	
         				BEGIN
         				   PRINT 2
         					SET @Result=-8
         					RETURN @Result -- USER SHOULD NOT HAVE CHECKER RIGHTS 
         				END
         		END
         		*/
         ----------------------------------------
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
            SELECT NVL(MAX(CollateralSubTypeAltKey) , 0) + 1 

              INTO v_CollateralSubTypeAltKey
              FROM ( SELECT CollateralSubTypeAltKey 
                     FROM DimCollateralSubType 
                     UNION 
                     SELECT CollateralSubTypeAltKey 
                     FROM DimCollateralSubType_Mod  ) A;
            GOTO CollateralSubType_Insert;
            <<CollateralSubType_Insert_Add>>

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
               v_Modifiedby := v_CrModApBy ;
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
                 FROM DimCollateralSubType 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimCollateralSubType_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DimCollateralSubType
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE DimCollateralSubType_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO CollateralSubType_Insert;
               <<CollateralSubType_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE DimCollateralSubType
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;

               END;
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE DimCollateralSubType_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                     DBMS_OUTPUT.PUT_LINE('Sunil');
                     --		DECLARE @EntityKey as Int 
                     --		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                     --							 FROM DimCollateralSubType_Mod 
                     --								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                     --									AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey And ISNULL(AuthorisationStatus,'A')='R'
                     --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                     --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                     --------------------------------
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DimCollateralSubType 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DimCollateralSubType
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
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
                        UPDATE DimCollateralSubType_Mod
                           SET AuthorisationStatus = 'RM'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                          AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;

                     END;
                     ELSE
                        IF v_OperationFlag = 16
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
                                 v_ModifiedBy := v_CrModApBy ;
                                 v_DateModified := SYSDATE ;
                                 SELECT CreatedBy ,
                                        DATECreated 

                                   INTO v_CreatedBy,
                                        v_DateCreated
                                   FROM DimCollateralSubType 
                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey )
                                           AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;

                              END;
                              END IF;

                           END;
                           END IF;
                           ---set parameters and UPDATE mod table in case maker checker enabled
                           IF v_AuthMode = 'Y' THEN
                            DECLARE
                              v_DelStatus CHAR(2);
                              v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                              v_CurEntityKey NUMBER(10,0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('B');
                              DBMS_OUTPUT.PUT_LINE('C');
                              SELECT MAX(EntityKey)  

                                INTO v_ExEntityKey
                                FROM DimCollateralSubType_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;
                              SELECT AuthorisationStatus ,
                                     CreatedBy ,
                                     DATECreated ,
                                     ModifiedBy ,
                                     DateModified 

                                INTO v_DelStatus,
                                     v_CreatedBy,
                                     v_DateCreated,
                                     v_ModifiedBy,
                                     v_DateModified
                                FROM DimCollateralSubType_Mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              SELECT MIN(EntityKey)  

                                INTO v_ExEntityKey
                                FROM DimCollateralSubType_Mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;
                              SELECT EffectiveFromTimeKey 

                                INTO v_CurrRecordFromTimeKey
                                FROM DimCollateralSubType_Mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              UPDATE DimCollateralSubType_Mod
                                 SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                AND AuthorisationStatus = 'A';
                              -------DELETE RECORD AUTHORISE
                              IF v_DelStatus = 'DP' THEN
                               DECLARE
                                 v_temp NUMBER(1, 0) := 0;

                              BEGIN
                                 UPDATE DimCollateralSubType_Mod
                                    SET AuthorisationStatus = 'A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved,
                                        EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                  WHERE  CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                 ;
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM DimCollateralSubType 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    UPDATE DimCollateralSubType
                                       SET AuthorisationStatus = 'A',
                                           ModifiedBy = v_ModifiedBy,
                                           DateModified = v_DateModified,
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved,
                                           EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;

                                 END;
                                 END IF;

                              END;
                               -- END OF DELETE BLOCK
                              ELSE

                               -- OTHER THAN DELETE STATUS
                              BEGIN
                                 UPDATE DimCollateralSubType_Mod
                                    SET AuthorisationStatus = 'A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                   AND AuthorisationStatus IN ( 'NP','MP','RM' )
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
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM DimCollateralSubType 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey );
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
                                                    FROM DimCollateralSubType 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND EffectiveFromTimeKey = v_TimeKey
                                                              AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('BBBB');
                                    UPDATE DimCollateralSubType
                                       SET CollateralTypeAltKey = v_CollateralTypeAltKey,
                                           CollateralSubTypeID = v_CollateralSubTypeID,
                                           CollateralSubType = v_CollateralSubType,
                                           CollateralSubTypeDescription = v_CollateralSubTypeDescription,
                                           ModifiedBy = v_ModifiedBy,
                                           DateModified = v_DateModified,
                                           ApprovedBy = CASE 
                                                             WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                           ELSE NULL
                                              END,
                                           DateApproved = CASE 
                                                               WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                           ELSE NULL
                                              END,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AuthMode = 'Y' THEN 'A'
                                           ELSE NULL
                                              END
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                      AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey;

                                 END;
                                 ELSE

                                 BEGIN
                                    v_IsSCD2 := 'Y' ;

                                 END;
                                 END IF;

                              END;
                              END IF;
                              IF v_IsAvailable = 'N'
                                OR v_IsSCD2 = 'Y' THEN

                              BEGIN
                                 INSERT INTO DimCollateralSubType
                                   ( CollateralSubTypeAltKey, CollateralTypeAltKey, CollateralSubTypeID, CollateralSubType, CollateralSubTypeDescription, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                   ( SELECT v_CollateralSubTypeAltKey ,
                                            v_CollateralTypeAltKey ,
                                            v_CollateralSubTypeID ,
                                            v_CollateralSubType ,
                                            v_CollateralSubTypeDescription ,
                                            CASE 
                                                 WHEN v_AUTHMODE = 'Y' THEN v_AuthorisationStatus
                                            ELSE NULL
                                               END col  ,
                                            v_EffectiveFromTimeKey ,
                                            v_EffectiveToTimeKey ,
                                            v_CreatedBy ,
                                            v_DateCreated ,
                                            CASE 
                                                 WHEN v_AuthMode = 'Y'
                                                   OR v_IsAvailable = 'Y' THEN v_ModifiedBy
                                            ELSE NULL
                                               END col  ,
                                            CASE 
                                                 WHEN v_AuthMode = 'Y'
                                                   OR v_IsAvailable = 'Y' THEN v_DateModified
                                            ELSE NULL
                                               END col  ,
                                            CASE 
                                                 WHEN v_AUTHMODE = 'Y' THEN v_ApprovedBy
                                            ELSE NULL
                                               END col  ,
                                            CASE 
                                                 WHEN v_AUTHMODE = 'Y' THEN v_DateApproved
                                            ELSE NULL
                                               END col  
                                       FROM DUAL  );

                              END;
                              END IF;
                              IF v_IsSCD2 = 'Y' THEN

                              BEGIN
                                 UPDATE DimCollateralSubType
                                    SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                        AuthorisationStatus = CASE 
                                                                   WHEN v_AUTHMODE = 'Y' THEN 'A'
                                        ELSE NULL
                                           END
                                  WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND CollateralSubTypeAltKey = v_CollateralSubTypeAltKey
                                   AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                              END;
                              END IF;

                           END;
                           END IF;
                           IF v_AUTHMODE = 'N' THEN

                           BEGIN
                              v_AuthorisationStatus := 'A' ;
                              GOTO CollateralSubType_Insert;
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
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<CollateralSubType_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO DimCollateralSubType_Mod
              ( CollateralSubTypeAltKey, CollateralTypeAltKey, CollateralSubTypeID, CollateralSubType, CollateralSubTypeDescription, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
              VALUES ( v_CollateralSubTypeAltKey, v_CollateralTypeAltKey, v_CollateralSubTypeID, v_CollateralSubType, v_CollateralSubTypeDescription, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
                                                                                                                                                                                                                                                            WHEN v_AuthMode = 'Y'
                                                                                                                                                                                                                                                              OR v_IsAvailable = 'Y' THEN v_ModifiedBy
            ELSE NULL
               END, CASE 
                         WHEN v_AuthMode = 'Y'
                           OR v_IsAvailable = 'Y' THEN v_DateModified
            ELSE NULL
               END, CASE 
                         WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
            ELSE NULL
               END, CASE 
                         WHEN v_AuthMode = 'Y' THEN v_DateApproved
            ELSE NULL
               END );
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO CollateralSubType_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO CollateralSubType_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         --COMMIT TRANSACTION
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimCollateralSubType WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --														AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALSUBTYPEINUP_15122023" TO "ADF_CDR_RBL_STGDB";
