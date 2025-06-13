--------------------------------------------------------
--  DDL for Function WILFULDEFAULTERINUP_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare
  v_ReportedByAlt_Key IN NUMBER DEFAULT 0 ,
  v_CategoryofBankFIAlt_Key IN NUMBER DEFAULT 0 ,
  v_ReportingBankFIAlt_Key IN NUMBER DEFAULT 0 ,
  v_ReportingBranchAlt_Key IN NUMBER DEFAULT 0 ,
  v_StateUTofBranchAlt_Key IN NUMBER DEFAULT 0 ,
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  v_PartyName IN VARCHAR2 DEFAULT ' ' ,
  v_PAN IN VARCHAR2 DEFAULT ' ' ,
  v_ReportingSerialNo IN NUMBER,
  v_RegisteredOfficeAddress IN VARCHAR2 DEFAULT ' ' ,
  v_OSAmountinlacs IN NUMBER,
  v_WillfulDefaultDate IN VARCHAR2,
  v_SuitFiledorNotAlt_Key IN NUMBER DEFAULT 0 ,
  v_OtherBanksFIInvolvedAlt_Key IN NUMBER DEFAULT 0 ,
  v_NameofOtherBanksFIAlt_Key IN NUMBER DEFAULT 0 ,
  v_CustomerTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_EntityId IN NUMBER DEFAULT 0 ,
  ---------D2k System Common Columns		----@AuthorisationStatus,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID							SMALLINT= 0 , change to Int
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
   v_ScreenName := 'Collateral' ;
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
                         FROM WillfulDefaulters 
                          WHERE  CustomerID = v_CustomerID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM WillfulDefaulters_mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND CustomerID = v_CustomerID
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
         ----		SELECT @GLAlt_Key=NEXT VALUE FOR Seq_GLAlt_Key
         ----		PRINT @GLAlt_Key
         ----	END
         ---------------------Added on 29/05/2020 for user allocation rights
         /*
         		IF @AccessScopeAlt_Key in (1,2)
         		BEGIN
         		PRINT 'Sunil'

         		IF EXISTS(				                
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
            SELECT NVL(MAX(EntityId) , 0) + 1 

              INTO v_Uniq_EntryID
              FROM ( SELECT EntityId 
                     FROM WillfulDefaulters 
                     UNION 
                     SELECT EntityId 
                     FROM WillfulDefaulters_mod  ) A;
            GOTO WillfulDefaulters_Insert;
            <<WillfulDefaulters_Insert_Add>>

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
                 FROM WillfulDefaulters 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND CustomerID = v_CustomerID
                         AND EntityId = v_EntityId;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM WillfulDefaulters_mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND CustomerID = v_CustomerID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )

                            AND EntityId = v_EntityId;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE WillfulDefaulters
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerID = v_CustomerID
                    AND EntityId = v_EntityId;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE WillfulDefaulters_mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerID = v_CustomerID
                    AND EntityId = v_EntityId
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO WillfulDefaulters_Insert;
               <<WillfulDefaulters_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE WillfulDefaulters
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerID = v_CustomerID
                    AND EntityId = v_EntityId;

               END;
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE WillfulDefaulters_mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND CustomerID = v_CustomerID
                       AND EntityId = v_EntityId
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     ---------------Added for Rejection Pop Up Screen  3/31/2020   ----------
                     DBMS_OUTPUT.PUT_LINE('Farha');
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
                                        FROM WillfulDefaulters 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND CustomerID = v_CustomerID
                                                  AND EntityId = v_EntityId );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE WillfulDefaulters
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND CustomerID = v_CustomerID
                          AND EntityId = v_EntityId
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -----------------------Two level Auth. changes----------------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE WillfulDefaulters_mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND CustomerID = v_CustomerID
                          AND EntityId = v_EntityId
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM WillfulDefaulters 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND CustomerID = v_CustomerID
                                                     AND EntityId = v_EntityId );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE WillfulDefaulters
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND CustomerID = v_CustomerID
                             AND EntityId = v_EntityId
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     ---------------------------------------------------------------
                     ELSE
                        IF v_OperationFlag = 18 THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE(18);
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE WillfulDefaulters_mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND CustomerID = v_CustomerID
                             AND EntityId = v_EntityId;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE WillfulDefaulters_mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  CustomerID = v_CustomerID
                                AND EntityId = v_EntityId
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

                           END;
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
                                       v_ModifiedBy := v_CrModApBy ;
                                       v_DateModified := SYSDATE ;
                                       SELECT CreatedBy ,
                                              DATECreated 

                                         INTO v_CreatedBy,
                                              v_DateCreated
                                         FROM WillfulDefaulters 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND CustomerID = v_CustomerID
                                                 AND EntityId = v_EntityId;
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
                                    SELECT MAX(Entity_Key)  

                                      INTO v_ExEntityKey
                                      FROM WillfulDefaulters_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND CustomerID = v_CustomerID
                                              AND EntityId = v_EntityId
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
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
                                      FROM WillfulDefaulters_mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(Entity_Key)  

                                      INTO v_ExEntityKey
                                      FROM WillfulDefaulters_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND CustomerID = v_CustomerID
                                              AND EntityId = v_EntityId
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM WillfulDefaulters_mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    UPDATE WillfulDefaulters_mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND CustomerID = v_CustomerID
                                      AND EntityId = v_EntityId
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE WillfulDefaulters_mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  CustomerID = v_CustomerID
                                         AND EntityId = v_EntityId
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM WillfulDefaulters 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND CustomerID = v_CustomerID
                                                                    AND EntityId = v_EntityId );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE WillfulDefaulters
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND CustomerID = v_CustomerID
                                            AND EntityId = v_EntityId;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE WillfulDefaulters_mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  CustomerID = v_CustomerID
                                         AND EntityId = v_EntityId
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
                                    -----Added on for Popup
                                    v_DirectorName VARCHAR2(100) := ' ';
                                    --@PAN						varchar(10)			='',
                                    v_DIN NUMBER(8,2);
                                    v_DirectorTypeAlt_Key NUMBER(10,0) := 0;

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM WillfulDefaulters 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND CustomerID = v_CustomerID
                                                                 AND EntityId = v_EntityId );
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
                                                          FROM WillfulDefaulters 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND CustomerID = v_CustomerID
                                                                    AND EntityId = v_EntityId );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE WillfulDefaulters
                                             SET ReportedByAlt_Key = v_ReportedByAlt_Key,
                                                 CategoryofBankFIAlt_Key = v_CategoryofBankFIAlt_Key,
                                                 ReportingBankFIAlt_Key = v_ReportingBankFIAlt_Key,
                                                 ReportingBranchAlt_Key = v_ReportingBranchAlt_Key,
                                                 StateUTofBranchAlt_Key = v_StateUTofBranchAlt_Key,
                                                 CustomerID = v_CustomerID,
                                                 PartyName = v_PartyName,
                                                 PAN = v_PAN,
                                                 ReportingSerialNo = v_ReportingSerialNo,
                                                 RegisteredOfficeAddress = v_RegisteredOfficeAddress,
                                                 OSAmountinlacs = v_OSAmountinlacs,
                                                 WillfulDefaultDate = v_WillfulDefaultDate,
                                                 SuitFiledorNotAlt_Key = v_SuitFiledorNotAlt_Key,
                                                 OtherBanksFIInvolvedAlt_Key = v_OtherBanksFIInvolvedAlt_Key,
                                                 NameofOtherBanksFIAlt_Key = v_NameofOtherBanksFIAlt_Key,
                                                 CustomerTypeAlt_Key = v_CustomerTypeAlt_Key,
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
                                            AND CustomerID = v_CustomerID
                                            AND EntityId = v_EntityId;

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
                                       INSERT INTO WillfulDefaulters
                                         ( EntityId, ReportedByAlt_Key, CategoryofBankFIAlt_Key, ReportingBankFIAlt_Key, ReportingBranchAlt_Key, StateUTofBranchAlt_Key, CustomerID, PartyName, PAN, ReportingSerialNo, RegisteredOfficeAddress, OSAmountinlacs, WillfulDefaultDate, SuitFiledorNotAlt_Key, OtherBanksFIInvolvedAlt_Key, NameofOtherBanksFIAlt_Key, CustomerTypeAlt_Key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                         ( SELECT v_EntityId ,
                                                  v_ReportedByAlt_Key ,
                                                  v_CategoryofBankFIAlt_Key ,
                                                  v_ReportingBankFIAlt_Key ,
                                                  v_ReportingBranchAlt_Key ,
                                                  v_StateUTofBranchAlt_Key ,
                                                  v_CustomerID ,
                                                  v_PartyName ,
                                                  v_PAN ,
                                                  v_ReportingSerialNo ,
                                                  v_RegisteredOfficeAddress ,
                                                  v_OSAmountinlacs ,
                                                  v_WillfulDefaultDate ,
                                                  v_SuitFiledorNotAlt_Key ,
                                                  v_OtherBanksFIInvolvedAlt_Key ,
                                                  v_NameofOtherBanksFIAlt_Key ,
                                                  v_CustomerTypeAlt_Key ,
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
                                    WilfulDirectorDetailInsert(v_DirectorName => v_DirectorName,
                                                               v_PAN => v_PAN,
                                                               v_DIN => v_DIN,
                                                               v_DirectorTypeAlt_Key => v_DirectorTypeAlt_Key,
                                                               v_AuthorisationStatus => v_AuthorisationStatus,
                                                               iv_EffectiveFromTimeKey => 
                                                               --@EffectiveFromTimeK	=	@EffectiveFromTimeK	,

                                                               --@EffectiveToTimeKey	=	@EffectiveToTimeKey	,
                                                               v_CreatedBy,
                                                               iv_EffectiveToTimeKey => v_DateCreated,
                                                               v_CreatedBy => v_ModifiedBy,
                                                               v_DateCreated => v_DateModified,
                                                               v_ModifiedBy => v_ApprovedBy,
                                                               v_DateModified => v_DateApproved) ;
                                    -----------------Added on 13-03-2021--------Need some clarify with poonam
                                    ------------------------------------------------------
                                    --declare 
                                    ----@CollateralID								int=0		
                                    --@CollateralValueatSanctioninRs				decimal(18,2)
                                    --,@CollateralValueasonNPAdateinRs			decimal(18,2)
                                    --,@CollateralValueatthetimeoflastreviewinRs	decimal(18,2)
                                    --,@ValuationSourceNameAlt_Key				int=0
                                    --,@SourceName								varchar(30)
                                    --,@ValuationDate								Date
                                    --,@LatestCollateralValueinRs					decimal(18,2)
                                    --,@ExpiryBusinessRule						varchar(30)=''
                                    --,@Periodinmonth								int=0
                                    --,@ValueExpirationDate						Date
                                    --EXEC CollateralValueInsert  @CustomerID=@CustomerID
                                    --							,@CollateralValueatSanctioninRs=@CollateralValueatSanctioninRs
                                    --							,@CollateralValueasonNPAdateinRs=@CollateralValueasonNPAdateinRs
                                    --							,@CollateralValueatthetimeoflastreviewinRs=@CollateralValueatthetimeoflastreviewinRs
                                    --							--,@ValuationSourceNameAlt_Key=@ValuationSourceNameAlt_Key
                                    --							--,@SourceName=@SourceName
                                    --							,@ValuationDate=@ValuationDate
                                    --							,@LatestCollateralValueinRs=@LatestCollateralValueinRs
                                    --							,@ExpiryBusinessRule=@ExpiryBusinessRule
                                    --							,@Periodinmonth=@Periodinmonth
                                    --							,@ValueExpirationDate=@ValueExpirationDate
                                    --							,@AuthorisationStatus=@AuthorisationStatus
                                    --							,@EffectiveFromTimeKey=@EffectiveFromTimeKey
                                    --							,@EffectiveToTimeKey=@EffectiveToTimeKey
                                    --							,@CreatedBy	=@CreatedBy	
                                    --							 ,@DateCreated	=@DateCreated
                                    --							 ,@ModifiedBy=@ModifiedBy	
                                    --							 ,@DateModified	=@DateModified
                                    --							 ,@ApprovedBy=@ApprovedBy	
                                    --							 ,@DateApproved	=@DateApproved
                                    --	Declare
                                    --	--@CollateralID	int	=0
                                    --	@CustomeroftheBankAlt_Key	int=0
                                    --	--,@CollateralID	varchar(16)=''
                                    --	--,@CustomerID	varchar(50)=''
                                    --	,@OtherOwnerName	varchar(50)=''
                                    --	,@PAN	varchar(10)=''
                                    --	,@OtherOwnerRelationshipAlt_Key	int=0
                                    --	,@IfRelationselectAlt_Key	int=0
                                    --	,@AddressType	varchar(200)=''
                                    --	,@Category	varchar(200)=''
                                    --	,@AddressLine1	varchar(200)=''
                                    --	,@AddressLine2	varchar(200)=''
                                    --	,@AddressLine3	varchar(200)=''
                                    --	,@City	varchar(200)=''
                                    --	,@PinCode	varchar(6)=''
                                    --	,@Country	varchar(100)=''
                                    --	,@State	varchar(100)=''
                                    --	,@District	varchar	(100)=''
                                    --	,@STDCodeO	varchar	(100)=''
                                    --	,@PhoneNumberO	varchar(10)=''
                                    --	,@STDCodeR	varchar(100)=''
                                    --	,@PhoneNumberR	varchar(10)=''
                                    --	,@FaxNumber	varchar(20)=''
                                    --	,@MobileNO	varchar(15)=''
                                    --	Exec CollateralOwnerInsert
                                    --				@CustomerID=@CustomerID								
                                    --				,@CustomeroftheBankAlt_Key=@CustomeroftheBankAlt_Key
                                    --				--,@AccountID=@AccountID
                                    --				,@CustomerID=@CustomerID
                                    --				,@OtherOwnerName=@OtherOwnerName
                                    --				,@PAN=@PAN
                                    --				,@OtherOwnerRelationshipAlt_Key=@OtherOwnerRelationshipAlt_Key
                                    --				,@IfRelationselectAlt_Key=@IfRelationselectAlt_Key
                                    --				--,@AddressType=@AddressType
                                    --				--,@Category=@Category
                                    --				--,@AddressLine1=@AddressLine1
                                    --				--,@AddressLine2=@AddressLine2
                                    --				--,@AddressLine3=@AddressLine3
                                    --				--,@City=@City
                                    --				--,@PinCode=@PinCode
                                    --				--,@Country=@Country
                                    --				--,@State=@State
                                    --				--,@District=@District
                                    --				--,@STDCodeO=@STDCodeO
                                    --				--,@PhoneNumberO=@PhoneNumberO
                                    --				--,@STDCodeR=@STDCodeR
                                    --				--,@PhoneNumberR=@PhoneNumberR
                                    --				--,@FaxNumber=@FaxNumber
                                    --				--,@MobileNO=@MobileNO
                                    --				,@AuthorisationStatus=@AuthorisationStatus
                                    --				,@EffectiveFromTimeKey=@EffectiveFromTimeKey	
                                    --				,@EffectiveToTimeKey=@EffectiveToTimeKey	
                                    --				,@CreatedBy=@CreatedBy				
                                    --				,@DateCreated=@DateCreated			
                                    --				,@ModifiedBy=@ModifiedBy			
                                    --				,@DateModified=@DateModified			
                                    --				,@ApprovedBy=@ApprovedBy			
                                    --				,@DateApproved=@DateApproved	
                                    --			exec CollateralOwnerAddressInsert
                                    --			@CustomerID=@CustomerID	
                                    --			,@AddressType=@AddressType
                                    --				,@Category=@Category
                                    --				,@AddressLine1=@AddressLine1
                                    --				,@AddressLine2=@AddressLine2
                                    --				,@AddressLine3=@AddressLine3
                                    --				,@City=@City
                                    --				,@PinCode=@PinCode
                                    --				,@Country=@Country
                                    --				,@State=@State
                                    --				,@District=@District
                                    --				,@STDCodeO=@STDCodeO
                                    --				,@PhoneNumberO=@PhoneNumberO
                                    --				,@STDCodeR=@STDCodeR
                                    --				,@PhoneNumberR=@PhoneNumberR
                                    --				,@FaxNumber=@FaxNumber
                                    --				,@MobileNO=@MobileNO
                                    --				,@AuthorisationStatus=@AuthorisationStatus
                                    --				,@EffectiveFromTimeKey=@EffectiveFromTimeKey	
                                    --				,@EffectiveToTimeKey=@EffectiveToTimeKey	
                                    --				,@CreatedBy=@CreatedBy				
                                    --				,@DateCreated=@DateCreated			
                                    --				,@ModifiedBy=@ModifiedBy			
                                    --				,@DateModified=@DateModified			
                                    --				,@ApprovedBy=@ApprovedBy			
                                    --				,@DateApproved=@DateApproved			
                                    ----------------------------------------------------------------------------------------------------
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE WillfulDefaulters
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND CustomerID = v_CustomerID
                                         AND EntityId = v_EntityId
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO WillfulDefaulters_Insert;
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
         <<WillfulDefaulters_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO WillfulDefaulters_mod
              ( EntityId, ReportedByAlt_Key, CategoryofBankFIAlt_Key, ReportingBankFIAlt_Key, ReportingBranchAlt_Key, StateUTofBranchAlt_Key, CustomerID, PartyName, PAN, ReportingSerialNo, RegisteredOfficeAddress, OSAmountinlacs, WillfulDefaultDate, SuitFiledorNotAlt_Key, OtherBanksFIInvolvedAlt_Key, NameofOtherBanksFIAlt_Key, CustomerTypeAlt_Key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
              VALUES ( CASE 
                            WHEN v_OperationFlag = 1 THEN v_Uniq_EntryID
            ELSE v_EntityId
               END, v_ReportedByAlt_Key, v_CategoryofBankFIAlt_Key, v_ReportingBankFIAlt_Key, v_ReportingBranchAlt_Key, v_StateUTofBranchAlt_Key, v_CustomerID, v_PartyName, v_PAN, v_ReportingSerialNo, v_RegisteredOfficeAddress, v_OSAmountinlacs, v_WillfulDefaultDate, v_SuitFiledorNotAlt_Key, v_OtherBanksFIInvolvedAlt_Key, v_NameofOtherBanksFIAlt_Key, v_CustomerTypeAlt_Key, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               GOTO WillfulDefaulters_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO WillfulDefaulters_Insert_Edit_Delete;

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERINUP_15122023" TO "ADF_CDR_RBL_STGDB";
