--------------------------------------------------------
--  DDL for Function RP_PORTFOLIO_DETAILSINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_PAN_No IN VARCHAR2 DEFAULT ' ' ,
  v_UCIC_ID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_BankingArrangementAlt_Key IN NUMBER DEFAULT 0 ,
  v_BorrowerDefaultDate IN VARCHAR2 DEFAULT NULL ,
  v_LeadBankAlt_Key IN NUMBER DEFAULT 0 ,
  v_DefaultStatusAlt_Key IN NUMBER DEFAULT 0 ,
  v_ExposureBucketAlt_Key IN NUMBER DEFAULT 0 ,
  v_ReferenceDate IN VARCHAR2 DEFAULT NULL ,
  v_ReviewExpiryDate IN VARCHAR2 DEFAULT NULL ,
  v_RP_ApprovalDate IN VARCHAR2 DEFAULT NULL ,
  v_RPNatureAlt_Key IN NUMBER DEFAULT 0 ,
  v_If_Other IN VARCHAR2 DEFAULT ' ' ,
  v_RP_ExpiryDate IN VARCHAR2 DEFAULT NULL ,
  v_RP_ImplDate IN VARCHAR2 DEFAULT NULL ,
  v_RP_ImplStatusAlt_Key IN NUMBER DEFAULT 0 ,
  v_RP_failed IN CHAR DEFAULT NULL ,
  v_Revised_RP_Expiry_Date IN VARCHAR2 DEFAULT NULL ,
  v_Actual_Impl_Date IN VARCHAR2 DEFAULT NULL ,
  v_RP_OutOfDateAllBanksDeadline IN VARCHAR2 DEFAULT NULL ,
  v_IsBankExposure IN CHAR DEFAULT NULL ,
  iv_AssetClassAlt_Key IN NUMBER DEFAULT 0 ,
  v_RiskReviewExpiryDate IN VARCHAR2 DEFAULT NULL ,
  ---------D2k System Common Columns		--
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
   v_AssetClassAlt_Key NUMBER(5,0) := iv_AssetClassAlt_Key;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM ACLProcessInProgressStatus 
                       WHERE  STATUS = 'RUNNING'
                                AND StatusFlag = 'N'
                                AND TimeKey IN ( SELECT MAX(Timekey)  
                                                 FROM ACLProcessInProgressStatus  )
    );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process is In Progress');

   END;

   --IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )

   --BEGIN

   --	PRINT 'ACL Process Completed'
   ELSE
   DECLARE
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
      v_ArrangementName VARCHAR2(100);
      v_AppAvail CHAR;

   BEGIN
      v_ScreenName := 'RPPortfolioMaster' ;
      -------------------------------------------------------------
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  CurrentStatus = 'C';
      v_EffectiveFromTimeKey := v_TimeKey ;
      v_EffectiveToTimeKey := 49999 ;
      ----------------Added for Alt_keys 24/12/2020
      --SET @BankingArrangementAlt_Key =(SELECT  BankingArrangementAlt_Key FROM RP_Portfolio_Details WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
      --SET @LeadBankAlt_Key =(SELECT  LeadBankAlt_Key FROM RP_Portfolio_Details WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
      --SET @ExposureBucketAlt_Key =(SELECT  ExposureBucketAlt_Key FROM RP_Portfolio_Details WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
      --SET @RPNatureAlt_Key =(SELECT  RPNatureAlt_Key FROM RP_Portfolio_Details WHERE CustomerID = @CustomerID AND EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
      SELECT AssetClassAlt_Key 

        INTO v_AssetClassAlt_Key
        FROM RP_Portfolio_Details 
       WHERE  CustomerID = v_CustomerID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
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
                            FROM RP_Portfolio_Details 
                             WHERE  CustomerID = v_CustomerID
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM RP_Portfolio_Details_Mod 
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
            ----		SELECT @CustomerID=NEXT VALUE FOR Seq_@CustomerID
            ----		PRINT @CustomerID
            ----	END
            ---------------------Added on 29/05/2020 for user allocation rights
            /*
            		IF @AccessScopeAlt_Key in (1,2)
            		BEGIN
            		PRINT 'Sunil'

            		IF EXISTS(				                
            					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CustomerID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
            					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CustomerID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
               GOTO RPPortfolioMaster_Insert;
               <<RPPortfolioMaster_Insert_Add>>

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
                    FROM RP_Portfolio_Details 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND CustomerID = v_CustomerID;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM RP_Portfolio_Details 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND CustomerID = v_CustomerID
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE RP_Portfolio_Details
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND CustomerID = v_CustomerID;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE RP_Portfolio_Details_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND CustomerID = v_CustomerID
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  GOTO RPPortfolioMaster_Insert;
                  <<RPPortfolioMaster_Insert_Edit_Delete>>

               END;
               ELSE
                  IF v_OperationFlag = 3
                    AND v_AuthMode = 'N' THEN

                  BEGIN
                     -- DELETE WITHOUT MAKER CHECKER
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE RP_Portfolio_Details
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND CustomerID = v_CustomerID;

                  END;
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE RP_Portfolio_Details_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND CustomerID = v_CustomerID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                        DBMS_OUTPUT.PUT_LINE('Sunil');
                        --		DECLARE @EntityKey as Int 
                        --		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                        --							 FROM RP_Portfolio_Details_Mod 
                        --								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                        --									AND CustomerID=@CustomerID And ISNULL(AuthorisationStatus,'A')='R'
                        --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                        --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                        --------------------------------
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM RP_Portfolio_Details 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND CustomerID = v_CustomerID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE RP_Portfolio_Details
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND CustomerID = v_CustomerID
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     ------------------------------Two level Auth. changes-------------------
                     ELSE
                        IF v_OperationFlag = 21
                          AND v_AuthMode = 'Y' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE RP_Portfolio_Details_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND CustomerID = v_CustomerID
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                           ;
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM RP_Portfolio_Details 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND CustomerID = v_CustomerID );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE RP_Portfolio_Details
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND CustomerID = v_CustomerID
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
                              UPDATE RP_Portfolio_Details_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND CustomerID = v_CustomerID;

                           END;
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE RP_Portfolio_Details_Mod
                                    SET AuthorisationStatus = '1A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  CustomerID = v_CustomerID
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
                                            FROM RP_Portfolio_Details 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND CustomerID = v_CustomerID;
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
                                         FROM RP_Portfolio_Details_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND CustomerID = v_CustomerID
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
                                         FROM RP_Portfolio_Details_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(EntityKey)  

                                         INTO v_ExEntityKey
                                         FROM RP_Portfolio_Details_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND CustomerID = v_CustomerID
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM RP_Portfolio_Details_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       UPDATE RP_Portfolio_Details_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND CustomerID = v_CustomerID
                                         AND AuthorisationStatus = 'A';
                                       DBMS_OUTPUT.PUT_LINE('D');
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE RP_Portfolio_Details_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  CustomerID = v_CustomerID
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM RP_Portfolio_Details 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND CustomerID = v_CustomerID );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE RP_Portfolio_Details
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND CustomerID = v_CustomerID;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE RP_Portfolio_Details_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  CustomerID = v_CustomerID
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
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM RP_Portfolio_Details 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND CustomerID = v_CustomerID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;
                                          --Print 'Vijay'
                                          v_LeadBankAlt_Key1 NUMBER(10,0) := ( SELECT DISTINCT LeadBankAlt_Key 
                                            FROM RP_Portfolio_Details_Mod 
                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                    AND CustomerID = v_CustomerID
                                                    AND AuthorisationStatus IN ( 'MP','NP','DP','A' )
                                           );

                                       BEGIN
                                          v_IsAvailable := 'Y' ;
                                          --SET @AuthorisationStatus='A'
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM RP_Portfolio_Details 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_TimeKey
                                                                       AND CustomerID = v_CustomerID );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN
                                           --BEGIN
                                          ------------------For Lead Bank Alt Key Manage  Added 11-01-2021
                                          --Print'@BankingArrangementAlt_Key'
                                          --Print @BankingArrangementAlt_Key
                                          SELECT ArrangementDescription 

                                            INTO v_ArrangementName
                                            FROM DimBankingArrangement 
                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                    AND BankingArrangementAlt_Key = v_BankingArrangementAlt_Key;
                                          END IF;
                                          --Print 'Vijay1'
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE RP_Portfolio_Details
                                             SET PAN_No = v_PAN_No,
                                                 UCIC_ID = v_UCIC_ID,
                                                 CustomerID = v_CustomerID,
                                                 CustomerName = v_CustomerName,
                                                 BankingArrangementAlt_Key = v_BankingArrangementAlt_Key,
                                                 BorrowerDefaultDate = (CASE 
                                                                             WHEN v_BorrowerDefaultDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_BorrowerDefaultDate,200,p_style=>103)
                                                    END),
                                                 LeadBankAlt_Key = (CASE 
                                                                         WHEN v_ArrangementName <> 'Consortium' THEN v_LeadBankAlt_Key1
                                                 ELSE v_LeadBankAlt_Key
                                                    END),
                                                 DefaultStatusAlt_Key = v_DefaultStatusAlt_Key,
                                                 ExposureBucketAlt_Key = v_ExposureBucketAlt_Key,
                                                 ReferenceDate = (CASE 
                                                                       WHEN v_ReferenceDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_ReferenceDate,200,p_style=>103)
                                                    END),
                                                 ReviewExpiryDate = (CASE 
                                                                          WHEN v_ReviewExpiryDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_ReviewExpiryDate,200,p_style=>103)
                                                    END),
                                                 RP_ApprovalDate = (CASE 
                                                                         WHEN v_RP_ApprovalDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ApprovalDate,200,p_style=>103)
                                                    END),
                                                 RPNatureAlt_Key = v_RPNatureAlt_Key,
                                                 If_Other = v_If_Other,
                                                 RP_ExpiryDate = (CASE 
                                                                       WHEN v_RP_ExpiryDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ExpiryDate,200,p_style=>103)
                                                    END),
                                                 RP_ImplDate = (CASE 
                                                                     WHEN v_RP_ImplDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ImplDate,200,p_style=>103)
                                                    END),
                                                 RP_ImplStatusAlt_Key = v_RP_ImplStatusAlt_Key,
                                                 RP_failed = v_RP_failed,
                                                 Revised_RP_Expiry_Date = (CASE 
                                                                                WHEN v_Revised_RP_Expiry_Date IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_Revised_RP_Expiry_Date,200,p_style=>103)
                                                    END),
                                                 Actual_Impl_Date = (CASE 
                                                                          WHEN v_Actual_Impl_Date IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_Actual_Impl_Date,200,p_style=>103)
                                                    END),
                                                 RP_OutOfDateAllBanksDeadline = (CASE 
                                                                                      WHEN v_RP_OutOfDateAllBanksDeadline IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_OutOfDateAllBanksDeadline,200,p_style=>103)
                                                    END),
                                                 IsBankExposure = v_IsBankExposure,
                                                 AssetClassAlt_Key = v_AssetClassAlt_Key,
                                                 RiskReviewExpiryDate = (CASE 
                                                                              WHEN v_RiskReviewExpiryDate IS NULL THEN NULL
                                                 ELSE UTILS.CONVERT_TO_VARCHAR2(v_RiskReviewExpiryDate,200,p_style=>103)
                                                    END),
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
                                            AND CustomerID = v_CustomerID;

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
                                     DECLARE
                                       v_LeadBankAlt_Key2 NUMBER(10,0) := ( SELECT LeadBankAlt_Key 
                                         FROM RP_Portfolio_Details_Mod 
                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                 AND CustomerID = v_CustomerID
                                                 AND AuthorisationStatus IN ( 'MP','NP','DP' )
                                        );

                                    BEGIN
                                       ------------------For Lead Bank Alt Key Manage  Added 11-01-2021
                                       SELECT ArrangementDescription 

                                         INTO v_ArrangementName
                                         FROM DimBankingArrangement 
                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                 AND BankingArrangementAlt_Key = v_BankingArrangementAlt_Key;
                                       INSERT INTO RP_Portfolio_Details
                                         ( PAN_No, UCIC_ID, CustomerID, CustomerName, BankingArrangementAlt_Key, BorrowerDefaultDate, LeadBankAlt_Key, DefaultStatusAlt_Key, ExposureBucketAlt_Key, ReferenceDate, ReviewExpiryDate, RP_ApprovalDate, RPNatureAlt_Key, If_Other, RP_ExpiryDate, RP_ImplDate, RP_ImplStatusAlt_Key, RP_failed, Revised_RP_Expiry_Date, Actual_Impl_Date, RP_OutOfDateAllBanksDeadline, IsBankExposure, AssetClassAlt_Key, RiskReviewExpiryDate, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                         ( SELECT v_PAN_No ,
                                                  v_UCIC_ID ,
                                                  v_CustomerID ,
                                                  v_CustomerName ,
                                                  v_BankingArrangementAlt_Key ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_BorrowerDefaultDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_BorrowerDefaultDate,20,p_style=>103)
                                                     END) ,
                                                  (CASE 
                                                        WHEN v_ArrangementName <> 'Consortium' THEN v_LeadBankAlt_Key2
                                                  ELSE v_LeadBankAlt_Key
                                                     END) ,
                                                  v_DefaultStatusAlt_Key ,
                                                  v_ExposureBucketAlt_Key ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_ReferenceDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_ReferenceDate,20,p_style=>103)
                                                     END) ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_ReviewExpiryDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_ReviewExpiryDate,20,p_style=>103)
                                                     END) ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_ApprovalDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ApprovalDate,20,p_style=>103)
                                                     END) ,
                                                  v_RPNatureAlt_Key ,
                                                  v_If_Other ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_ExpiryDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ExpiryDate,20,p_style=>103)
                                                     END) ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_ImplDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ImplDate,20,p_style=>103)
                                                     END) ,
                                                  v_RP_ImplStatusAlt_Key ,
                                                  v_RP_failed ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_Revised_RP_Expiry_Date,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_Revised_RP_Expiry_Date,20,p_style=>103)
                                                     END) ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_Actual_Impl_Date,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_Actual_Impl_Date,20,p_style=>103)
                                                     END) ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_OutOfDateAllBanksDeadline,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_OutOfDateAllBanksDeadline,20,p_style=>103)
                                                     END) ,
                                                  v_IsBankExposure ,
                                                  v_AssetClassAlt_Key ,
                                                  (CASE 
                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_RiskReviewExpiryDate,200) = ' ' THEN NULL
                                                  ELSE UTILS.CONVERT_TO_VARCHAR2(v_RiskReviewExpiryDate,20,p_style=>103)
                                                     END) ,
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
                                       UPDATE RP_Portfolio_Details
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND CustomerID = v_CustomerID
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

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
            IF v_AUTHMODE = 'N' THEN

            BEGIN
               v_AuthorisationStatus := 'A' ;
               GOTO RPPORTFOLIOMaster_Insert;
               <<HistoryRecordInUp>>

            END;
            END IF;
            --END 
            DBMS_OUTPUT.PUT_LINE(6);
            v_ErrorHandle := 1 ;
            <<RPPORTFOLIOMaster_Insert>>
            IF v_ErrorHandle = 0 THEN
             DECLARE
               v_LeadBankAlt_Key3 NUMBER(10,0) := ( SELECT LeadBankAlt_Key 
                 FROM RP_Portfolio_Details 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND CustomerID = v_CustomerID );

            BEGIN
               ------------------For Lead Bank Alt Key Manage  Added 11-01-2021
               SELECT ArrangementDescription 

                 INTO v_ArrangementName
                 FROM DimBankingArrangement 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND BankingArrangementAlt_Key = v_BankingArrangementAlt_Key;
               INSERT INTO RP_Portfolio_Details_Mod
                 ( PAN_No, UCIC_ID, CustomerID, CustomerName, BankingArrangementAlt_Key, BorrowerDefaultDate, LeadBankAlt_Key, DefaultStatusAlt_Key, ExposureBucketAlt_Key, ReferenceDate, ReviewExpiryDate, RP_ApprovalDate, RPNatureAlt_Key, If_Other, RP_ExpiryDate, RP_ImplDate, RP_ImplStatusAlt_Key, RP_failed, Revised_RP_Expiry_Date, Actual_Impl_Date, RP_OutOfDateAllBanksDeadline, IsBankExposure, AssetClassAlt_Key, RiskReviewExpiryDate, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                 VALUES ( v_PAN_No, v_UCIC_ID, v_CustomerID, v_CustomerName, v_BankingArrangementAlt_Key, TO_DATE((CASE 
                                                                                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(v_BorrowerDefaultDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_BorrowerDefaultDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), (CASE 
                                            WHEN v_ArrangementName <> 'Consortium' THEN v_LeadBankAlt_Key3
               ELSE v_LeadBankAlt_Key
                  END), v_DefaultStatusAlt_Key, v_ExposureBucketAlt_Key, TO_DATE((CASE 
                                                                                       WHEN UTILS.CONVERT_TO_VARCHAR2(v_ReferenceDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_ReferenceDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), TO_DATE((CASE 
                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(v_ReviewExpiryDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_ReviewExpiryDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), TO_DATE((CASE 
                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_ApprovalDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ApprovalDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), v_RPNatureAlt_Key, v_If_Other, TO_DATE((CASE 
                                                                                   WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_ExpiryDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ExpiryDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), TO_DATE((CASE 
                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_ImplDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_ImplDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), v_RP_ImplStatusAlt_Key, v_RP_failed, TO_DATE((CASE 
                                                                                         WHEN UTILS.CONVERT_TO_VARCHAR2(v_Revised_RP_Expiry_Date,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_Revised_RP_Expiry_Date,20,p_style=>103)
                  END),'dd/mm/yyyy'), TO_DATE((CASE 
                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(v_Actual_Impl_Date,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_Actual_Impl_Date,20,p_style=>103)
                  END),'dd/mm/yyyy'), TO_DATE((CASE 
                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(v_RP_OutOfDateAllBanksDeadline,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_RP_OutOfDateAllBanksDeadline,20,p_style=>103)
                  END),'dd/mm/yyyy'), v_IsBankExposure, v_AssetClassAlt_Key, TO_DATE((CASE 
                                                                                           WHEN UTILS.CONVERT_TO_VARCHAR2(v_RiskReviewExpiryDate,200) = ' ' THEN NULL
               ELSE UTILS.CONVERT_TO_VARCHAR2(v_RiskReviewExpiryDate,20,p_style=>103)
                  END),'dd/mm/yyyy'), v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), CASE 
                                                                                                                                                                  WHEN v_AuthMode = 'Y'
                                                                                                                                                                    OR v_IsAvailable = 'Y' THEN v_ModifiedBy
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
                  END,'dd/mm/yyyy') );
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO RPPORTFOLIOMaster_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO RPPORTFOLIOMaster_Insert_Edit_Delete;

                  END;
                  END IF;
               END IF;

            END;
            END IF;
            -------------------
            DBMS_OUTPUT.PUT_LINE(7);
            utils.commit_transaction;
            --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
            --															AND CustomerID=@CustomerID
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RP_PORTFOLIO_DETAILSINUP" TO "ADF_CDR_RBL_STGDB";
