--------------------------------------------------------
--  DDL for Function EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" 
-- =============================================
 -- Author:				<Amar>
 -- Create date:			<03/03/2017>
 -- Description:			<AdvFacBillDetail Table Insert/ Update>
 -- =============================================

(
  --@AccountID			INT				= 0	
  v_DegrationAlt_Key IN NUMBER DEFAULT 0 ,
  v_SourceAlt_Key IN NUMBER DEFAULT 0 ,
  v_AccountID IN VARCHAR2 DEFAULT NULL ,
  v_CustomerID IN VARCHAR2 DEFAULT NULL ,
  v_FlagAlt_Key IN VARCHAR2 DEFAULT NULL ,
  v_Date IN VARCHAR2 DEFAULT NULL ,
  v_Amount IN NUMBER,
  v_MarkingAlt_Key IN NUMBER,
  -- ,@AuthorisationStatus		char(5)		=null-- ,@Remark				varchar(200)	=null
  v_ChangeFields IN VARCHAR2 DEFAULT NULL ,
  iv_ErrorHandle IN NUMBER DEFAULT 0 ,
  iv_ExEntityKey IN NUMBER DEFAULT 0 ,
  --,@EffectiveFromTimeKey--,@EffectiveToTimeKey--,@CreatedBy--,@DateCreated--,@ModifiedBy--,@DateModified--,@ApprovedBy-- ,@DateApproved-- ,@D2Ktimestamp---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_IsMOC IN CHAR DEFAULT 'N' ,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_BranchCode IN VARCHAR2 DEFAULT NULL ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL 
)
RETURN NUMBER
AS
   v_ExEntityKey NUMBER(10,0) := iv_ExEntityKey;
   v_ErrorHandle NUMBER(10,0) := iv_ErrorHandle;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

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
      v_AuthorisationStatus VARCHAR2(2) := NULL;
      v_CreatedBy VARCHAR2(20) := NULL;
      v_DateCreated DATE := NULL;
      v_ModifiedBy VARCHAR2(20) := NULL;
      v_DateModified DATE := NULL;
      v_ApprovedBy VARCHAR2(20) := NULL;
      v_DateApproved DATE := NULL;

   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      IF v_OperationFlag = 1 THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

       --- add
      BEGIN
         DBMS_OUTPUT.PUT_LINE(1);
         -----CHECK DUPLICATE BILL NO AT BRANCH LEVEL
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RBL_MISDB_PROD.ExceptionalDegrationDetail 
                             WHERE  AccountId = v_AccountID
                                      AND FlagAlt_Key = v_FlagAlt_Key
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                            UNION 
                            SELECT 1 
                            FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND AccountId = v_AccountID
                                      AND FlagAlt_Key = v_FlagAlt_Key
                                      AND AuthorisationStatus IN ( 'NP','MP','DP','A','RM' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            v_Result := -4 ;
            RETURN v_Result;-- CUSTOMERID ALEADY EXISTS

         END;
         END IF;

      END;
      END IF;
      BEGIN

         BEGIN
            --SQL Server BEGIN TRANSACTION;
            utils.incrementTrancount;
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
               GOTO ExceptionalDegrationDetail_Insert;
               <<ExceptionalDegrationDetail_Insert_Add>>

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
                    FROM RBL_MISDB_PROD.ExceptionalDegrationDetail 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND AccountID = v_AccountID
                            AND FlagAlt_Key = v_FlagAlt_Key;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND AccountID = v_AccountID
                               AND FlagAlt_Key = v_FlagAlt_Key
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE RBL_MISDB_PROD.ExceptionalDegrationDetail
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AccountID = v_AccountID
                       AND FlagAlt_Key = v_FlagAlt_Key;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE ExceptionalDegrationDetail_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AccountID = v_AccountID
                       AND FlagAlt_Key = v_FlagAlt_Key
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  --GOTO AdvFacBillDetail_Insert
                  --AdvFacBillDetail_Insert_Edit_Delete:
                  GOTO ExceptionalDegrationDetail_Insert;
                  <<ExceptionalDegrationDetail_Insert_Edit_Delete>>

               END;
               ELSE
                  IF v_OperationFlag = 3
                    AND v_AuthMode = 'N' THEN

                  BEGIN
                     -- DELETE WITHOUT MAKER CHECKER
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE ExceptionalDegrationDetail
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AccountID = v_AccountID
                       AND FlagAlt_Key = v_FlagAlt_Key;

                  END;

                  ---------------------------------------------------------------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE ExceptionalDegrationDetail_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountID = v_AccountID
                          AND FlagAlt_Key = v_FlagAlt_Key
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM ExceptionalDegrationDetail 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AccountID = v_AccountID
                                                     AND FlagAlt_Key = v_FlagAlt_Key );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE ExceptionalDegrationDetail
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AccountID = v_AccountID
                             AND FlagAlt_Key = v_FlagAlt_Key
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     -----------------------------------------------------------------------
                     ELSE
                        IF v_OperationFlag = 17
                          AND v_AuthMode = 'Y' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE ExceptionalDegrationDetail_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AccountID = v_AccountID
                             AND FlagAlt_Key = v_FlagAlt_Key
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM ExceptionalDegrationDetail 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND AccountID = v_AccountID );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE ExceptionalDegrationDetail
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AccountID = v_AccountID
                                AND FlagAlt_Key = v_FlagAlt_Key
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
                              UPDATE ExceptionalDegrationDetail_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND AccountId = v_AccountID
                                AND FlagAlt_Key = v_FlagAlt_Key;

                           END;

                           --------------------------------------------------------
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE ExceptionalDegrationDetail_Mod
                                    SET AuthorisationStatus = '1A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  AccountId = v_AccountID
                                   AND FlagAlt_Key = v_FlagAlt_Key
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                 ;

                              END;

                              --------------------------------------------------------
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
                                            FROM RBL_MISDB_PROD.ExceptionalDegrationDetail 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND AccountID = v_AccountID
                                                    AND FlagAlt_Key = v_FlagAlt_Key;
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
                                         FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND AccountID = v_AccountID
                                                 AND FlagAlt_Key = v_FlagAlt_Key
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
                                         FROM ExceptionalDegrationDetail_Mod 
                                        WHERE  Entity_Key = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(Entity_Key)  

                                         INTO v_ExEntityKey
                                         FROM ExceptionalDegrationDetail_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND AccountID = v_AccountID
                                                 AND FlagAlt_Key = v_FlagAlt_Key
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM ExceptionalDegrationDetail_Mod 
                                        WHERE  Entity_Key = v_ExEntityKey;
                                       UPDATE ExceptionalDegrationDetail_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND AccountID = v_AccountID
                                         AND FlagAlt_Key = v_FlagAlt_Key
                                         AND AuthorisationStatus = 'A';
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE ExceptionalDegrationDetail_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  AccountID = v_AccountID
                                            AND FlagAlt_Key = v_FlagAlt_Key
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM ExceptionalDegrationDetail 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND AccountID = v_AccountID
                                                                       AND FlagAlt_Key = v_FlagAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE ExceptionalDegrationDetail
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND AccountID = v_AccountID
                                               AND FlagAlt_Key = v_FlagAlt_Key;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE ExceptionalDegrationDetail_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  AccountID = v_AccountID
                                            AND FlagAlt_Key = v_FlagAlt_Key
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
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM ExceptionalDegrationDetail 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AccountID = v_AccountID
                                                                    AND FlagAlt_Key = v_FlagAlt_Key );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          v_IsAvailable := 'Y' ;
                                          v_AuthorisationStatus := 'A' ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM ExceptionalDegrationDetail 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_TimeKey
                                                                       AND AccountID = v_AccountID
                                                                       AND FlagAlt_Key = v_FlagAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             DBMS_OUTPUT.PUT_LINE('BBBB');
                                             UPDATE ExceptionalDegrationDetail
                                                SET DegrationAlt_Key = v_DegrationAlt_Key,
                                                    SourceAlt_Key = v_SourceAlt_Key,
                                                    AccountID = v_AccountID,
                                                    CustomerID = v_CustomerID,
                                                    FlagAlt_Key = v_FlagAlt_Key,
                                                    Date_ = v_Date
                                                    --,Date= convert(varchar(20),@Date,103)
                                                     --,AuthorisationStatus= @AuthorisationStatus
                                                     --,EffectiveFromTimeKey= @EffectiveFromTimeKey
                                                     --,EffectiveToTimeKey= @EffectiveToTimeKey
                                                     --,CreatedBy= @CreatedBy
                                                     --,DateCreated=@DateCreated
                                                    ,
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
                                               AND AccountID = v_AccountID
                                               AND FlagAlt_Key = v_FlagAlt_Key;

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
                                          INSERT INTO ExceptionalDegrationDetail --Entity_Key

                                            ( DegrationAlt_Key, SourceAlt_Key, AccountID, CustomerID, FlagAlt_Key, Date_, MarkingAlt_Key, Amount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )

                                            -- ,D2Ktimestamp
                                            VALUES ( v_DegrationAlt_Key, v_SourceAlt_Key, v_AccountID, v_CustomerID, v_FlagAlt_Key, v_Date, 
                                          --,convert(varchar(20),@Date,103)
                                          v_MarkingAlt_Key, v_Amount, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
                                                                                                                                                                            WHEN v_AuthMode = 'Y'
                                                                                                                                                                              OR v_IsAvailable = 'Y' THEN v_ModifiedBy
                                          ELSE NULL
                                             END, CASE 
                                                       WHEN v_AuthMode = 'Y'
                                                         OR v_IsAvailable = 'Y' THEN v_DateModified
                                          ELSE NULL
                                             END, CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_ApprovedBy
                                          ELSE NULL
                                             END, CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_DateApproved
                                          ELSE NULL
                                             END );

                                       END;
                                       END IF;
                                       -- ,@D2Ktimestamp
                                       INSERT INTO ExceptionFinalStatusType --Entity_Key

                                         ( SourceAlt_Key, CustomerID, ACID, StatusType ------
                                       , StatusDate, Amount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved )
                                         ( 
                                           -- ,D2Ktimestamp
                                           SELECT v_SourceAlt_Key ,
                                                  v_CustomerID ,
                                                  v_AccountID ,
                                                  A.ParameterName Marking  ,
                                                  SYSDATE ,
                                                  v_Amount ,
                                                  v_AuthorisationStatus ,
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

                                           -- ,@D2Ktimestamp
                                           FROM DimParameter A
                                            WHERE  DimParameterName = 'UploadFLagType'

                                                     --AND ParameterAlt_Key= @MarkingAlt_Key
                                                     AND ParameterAlt_Key = v_FlagAlt_Key );
                                       /*Adding Flag ---------- 02-04-2021*/
                                       IF ( v_MarkingAlt_Key = 20 ) THEN

                                       BEGIN
                                          IF utils.object_id('TempDB..tt_Flags_26') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Flags_26 ';
                                          END IF;
                                          DELETE FROM tt_Flags_26;
                                          UTILS.IDENTITY_RESET('tt_Flags_26');

                                          INSERT INTO tt_Flags_26 ( 
                                          	SELECT A.AccountID ,
                                                  B.SplCatShortNameEnum 
                                          	  FROM ExceptionalDegrationDetail_Mod A
                                                    JOIN ( SELECT B.ParameterAlt_Key ,
                                                                  A.SplCatShortNameEnum 
                                          	  FROM DimAcSplCategory A
                                                    JOIN DimParameter B   ON A.SplCatName = B.ParameterName
                                                    AND B.EffectiveToTimeKey = 49999
                                          	 WHERE  A.SplCatGroup = 'SplFlags'
                                                     AND A.EffectiveToTimeKey = 49999
                                                     AND B.DimParameterName = 'uploadflagtype' ) B   ON A.FlagAlt_Key = B.ParameterAlt_Key
                                          	 WHERE  A.EffectiveToTimeKey = 49999
                                                     AND A.MarkingAlt_Key = 20
                                                     AND A.Entity_Key = ( SELECT MAX(Entity_Key)  
                                                                          FROM ExceptionalDegrationDetail_Mod 
                                                                           WHERE  AccountID = v_AccountID
                                                                                    AND FlagAlt_Key = v_FlagAlt_Key ) );
                                          MERGE INTO A 
                                          USING (SELECT A.ROWID row_id, CASE 
                                          WHEN NVL(A.SplFlag, ' ') = ' ' THEN B.SplCatShortNameEnum
                                          ELSE A.SplFlag || ',' || B.SplCatShortNameEnum
                                             END AS SplFlag
                                          FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                                                 JOIN tt_Flags_26 B   ON A.RefSystemAcId = B.AccountID 
                                           WHERE A.EffectiveToTimeKey = 49999) src
                                          ON ( A.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET A.SplFlag --'IBPC'     
                                                                        = src.SplFlag;

                                       END;
                                       END IF;
                                       ---------------------
                                       -----------Remove------------------------
                                       -------
                                       IF ( v_MarkingAlt_Key = 10 ) THEN
                                        DECLARE
                                          v_ParameterName VARCHAR2(100);

                                       BEGIN
                                          MERGE INTO B 
                                          USING (SELECT B.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                                          FROM B ,ExceptionalDegrationDetail_Mod A
                                                 JOIN AccountFlaggingDetails B   ON A.AccountID = B.ACID
                                                 AND B.EffectiveFromTimeKey <= v_timekey
                                                 AND B.EffectiveToTimeKey >= v_Timekey 
                                           WHERE A.EffectiveFromTimeKey <= v_timekey
                                            AND A.EffectiveToTimeKey >= v_Timekey
                                            AND A.Entity_Key = ( SELECT MAX(Entity_Key)  
                                                                 FROM ExceptionalDegrationDetail_Mod 
                                                                  WHERE  AccountID = v_AccountID
                                                                           AND FlagAlt_Key = v_FlagAlt_Key )
                                            AND A.MarkingAlt_Key = 10
                                            AND B.UploadTypeParameterAlt_Key = v_FlagAlt_Key) src
                                          ON ( B.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                                          MERGE INTO B 
                                          USING (SELECT B.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                                          FROM B ,ExceptionalDegrationDetail_Mod A
                                                 JOIN ExceptionalDegrationDetail B   ON A.AccountID = B.AccountID
                                                 AND B.EffectiveFromTimeKey <= v_timekey
                                                 AND B.EffectiveToTimeKey >= v_Timekey 
                                           WHERE A.EffectiveFromTimeKey <= v_timekey
                                            AND A.EffectiveToTimeKey >= v_Timekey
                                            AND A.Entity_Key = ( SELECT MAX(Entity_Key)  
                                                                 FROM ExceptionalDegrationDetail_Mod 
                                                                  WHERE  AccountID = v_AccountID
                                                                           AND FlagAlt_Key = v_FlagAlt_Key )
                                            AND A.MarkingAlt_Key = 10) src
                                          ON ( B.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                                          SELECT ParameterName 

                                            INTO v_ParameterName
                                            FROM DimParameter 
                                           WHERE  DimParameterName = 'uploadflagtype'
                                                    AND EffectiveToTimeKey = 49999
                                                    AND ParameterAlt_Key = ( SELECT DISTINCT FlagAlt_Key 
                                                                             FROM ExceptionalDegrationDetail_Mod 
                                                                              WHERE  AccountID = v_AccountID
                                                                                       AND MarkingAlt_Key = 10
                                                                                       AND Entity_Key = ( SELECT MAX(Entity_Key)  
                                                                                                          FROM ExceptionalDegrationDetail_Mod 
                                                                                                           WHERE  AccountID = v_AccountID
                                                                                                                    AND FlagAlt_Key = v_FlagAlt_Key ) );
                                          MERGE INTO B 
                                          USING (SELECT B.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                                          FROM B ,ExceptionalDegrationDetail_Mod A
                                                 JOIN ExceptionFinalStatusType B   ON A.AccountID = B.ACID
                                                 AND B.EffectiveFromTimeKey <= v_timekey
                                                 AND B.EffectiveToTimeKey >= v_Timekey 
                                           WHERE A.EffectiveFromTimeKey <= v_timekey
                                            AND A.EffectiveToTimeKey >= v_Timekey
                                            AND A.Entity_Key = ( SELECT MAX(Entity_Key)  
                                                                 FROM ExceptionalDegrationDetail_Mod 
                                                                  WHERE  AccountID = v_AccountID
                                                                           AND FlagAlt_Key = v_FlagAlt_Key )
                                            AND B.StatusType = v_ParameterName) src
                                          ON ( B.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                                          IF utils.object_id('TempDB..tt_Flags_261') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Flags1_26 ';
                                          END IF;
                                          DELETE FROM tt_Flags1_26;
                                          UTILS.IDENTITY_RESET('tt_Flags1_26');

                                          INSERT INTO tt_Flags1_26 ( 
                                          	SELECT A.AccountID ,
                                                  B.SplCatShortNameEnum 
                                          	  FROM ExceptionalDegrationDetail_Mod A
                                                    JOIN ( SELECT B.ParameterAlt_Key ,
                                                                  A.SplCatShortNameEnum 
                                                           FROM DimAcSplCategory A
                                                                  JOIN DimParameter B   ON A.SplCatName = B.ParameterName
                                                                  AND B.EffectiveToTimeKey = 49999
                                                            WHERE  A.SplCatGroup = 'SplFlags'
                                                                     AND A.EffectiveToTimeKey = 49999
                                                                     AND B.DimParameterName = 'uploadflagtype' ) B   ON A.FlagAlt_Key = B.ParameterAlt_Key
                                          	 WHERE  A.EffectiveToTimeKey = 49999
                                                     AND A.MarkingAlt_Key = 10
                                                     AND A.Entity_Key = ( SELECT MAX(Entity_Key)  
                                                                          FROM ExceptionalDegrationDetail_Mod 
                                                                           WHERE  AccountID = v_AccountID
                                                                                    AND FlagAlt_Key = v_FlagAlt_Key ) );
                                          IF utils.object_id('TempDB..tt_Temp_80') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_80 ';
                                          END IF;
                                          DELETE FROM tt_Temp_80;
                                          UTILS.IDENTITY_RESET('tt_Temp_80');

                                          INSERT INTO tt_Temp_80 ( 
                                          	SELECT A.AccountentityID ,
                                                  A.SplFlag 
                                          	  FROM CurDat_RBL_MISDB_PROD.AdvAcOtherDetail A
                                                    JOIN tt_Flags1_26 B   ON A.RefSystemAcId = B.AccountID
                                          	 WHERE  A.EffectiveToTimeKey = 49999 );
                                          --Select * from tt_Temp_80
                                          IF utils.object_id('TEMPDB..tt_SplitValue_28') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue_28 ';
                                          END IF;
                                          DELETE FROM tt_SplitValue_28;
                                          UTILS.IDENTITY_RESET('tt_SplitValue_28');

                                          INSERT INTO tt_SplitValue_28 ( 
                                          	SELECT AccountentityID ,
                                                  a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
                                          	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(SplFlag, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                                                           AccountentityID 
                                                    FROM tt_Temp_80  ) A
                                                     /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
                                          --Select * from tt_SplitValue_28 
                                          DELETE tt_SplitValue_28

                                           WHERE  Businesscolvalues1 IN ( SELECT DISTINCT SplCatShortNameEnum 
                                                                          FROM tt_Flags1_26  )
                                          ;
                                          IF utils.object_id('TEMPDB..tt_NEWTRANCHE_71') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_71 ';
                                          END IF;
                                          DELETE FROM tt_NEWTRANCHE_71;
                                          UTILS.IDENTITY_RESET('tt_NEWTRANCHE_71');

                                          INSERT INTO tt_NEWTRANCHE_71 SELECT * 
                                               FROM ( SELECT ss.AccountEntityID ,
                                                             utils.stuff(( SELECT ',' || US.BUSINESSCOLVALUES1 
                                                                           FROM tt_SplitValue_28 US
                                                                            WHERE  US.AccountentityID = ss.AccountEntityID ), 1, 1, ' ') REPORTIDSLIST  
                                                      FROM tt_Temp_80 SS
                                                        GROUP BY ss.AccountEntityID ) B
                                               ORDER BY 1;
                                          --Select * from tt_NEWTRANCHE_71
                                          --SELECT * 
                                          MERGE INTO A 
                                          USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                                          FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                                                 JOIN tt_NEWTRANCHE_71 B   ON A.AccountentityID = B.AccountentityID 
                                           WHERE A.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                                            AND A.EFFECTIVETOTIMEKEY >= v_TimeKey) src
                                          ON ( A.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET A.SplFlag = src.REPORTIDSLIST;

                                       END;
                                       END IF;
                                       IF v_IsSCD2 = 'Y' THEN

                                       BEGIN
                                          UPDATE ExceptionalDegrationDetail
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND AccountID = v_AccountID
                                            AND FlagAlt_Key = v_FlagAlt_Key
                                            AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    IF v_AUTHMODE = 'N' THEN

                                    BEGIN
                                       v_AuthorisationStatus := 'A' ;
                                       --GOTO AdvFacBillDetail_Insert
                                       GOTO ExceptionalDegrationDetail_Insert;
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
            --/*Adding Flag ----------Farahnaaz 26-03-2021*/
            --		Declare @variable Varchar(100)=''
            --Set @variable=(Select Splcatshortnameenum from dimacsplcategory  where splcatgroup='splflags' and 
            --SplCatName like (select ParameterName from dimparameter
            --where dimparametername ='UploadFLagType' and ParameterAlt_Key=@FlagAlt_key))
            --		  UPDATE A
            --			SET  
            --				A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN @variable--'IBPC'     
            --								ELSE A.SplFlag+','+@variable     END
            --		   FROM DBO.AdvAcOtherDetail A
            DBMS_OUTPUT.PUT_LINE(6);
            v_ErrorHandle := 1 ;
            <<ExceptionalDegrationDetail_Insert>>
            IF v_ErrorHandle = 0 THEN

            BEGIN
               INSERT INTO ExceptionalDegrationDetail_Mod --Entity_Key

                 ( DegrationAlt_Key, SourceAlt_Key, AccountID, CustomerID, FlagAlt_Key, Date_, MarkingAlt_Key, Amount, AuthorisationStatus, Remark, ChangeFields, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )

                 -- ,D2Ktimestamp
                 VALUES ( v_DegrationAlt_Key, v_SourceAlt_Key, v_AccountID, v_CustomerID, v_FlagAlt_Key, v_Date, v_MarkingAlt_Key, v_Amount, v_AuthorisationStatus, v_Remark, v_ChangeFields, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               -- ,@D2Ktimestamp
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO ExceptionalDegrationDetail_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO ExceptionalDegrationDetail_Insert_Edit_Delete;

                  END;
                  END IF;
               END IF;

            END;
            END IF;
            -------------------
            DBMS_OUTPUT.PUT_LINE(7);
            utils.commit_transaction;
            SELECT UTILS.CONVERT_TO_NUMBER(D2Ktimestamp,10,0) 

              INTO v_D2Ktimestamp
              FROM RBL_MISDB_PROD.ExceptionalDegrationDetail 
             WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                      AND EffectiveToTimeKey >= v_TimeKey )
                      AND AccountID = v_AccountID
                      AND FlagAlt_Key = v_FlagAlt_Key;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONDETAILINUP_PROD_24012024" TO "ADF_CDR_RBL_STGDB";
