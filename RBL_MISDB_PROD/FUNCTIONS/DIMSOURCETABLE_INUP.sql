--------------------------------------------------------
--  DDL for Function DIMSOURCETABLE_INUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" 
(
  iv_SourceTableAlt_Key IN NUMBER DEFAULT 0 ,
  v_SourceAlt_Key IN NUMBER,
  v_SourceTableName IN VARCHAR2,
  v_StageTableName IN VARCHAR2,
  v_Active_Inactive IN CHAR,
  v_Reason IN VARCHAR2,
  --,@Remark					VARCHAR(500)	= ''--,@MenuID                    Int=0
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   --Declare
   v_SourceTableAlt_Key NUMBER(10,0) := iv_SourceTableAlt_Key;
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

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

   BEGIN
      DBMS_OUTPUT.PUT_LINE(1);
      /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
      -------------------------------------------------------------
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
                            FROM RBL_MISDB_PROD.DimSourceTable 
                             WHERE  SourceTableAlt_Key = NVL(v_SourceTableAlt_Key, 0)
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND SourceTableAlt_Key = NVL(v_SourceTableAlt_Key, 0)
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
            SELECT NVL(MAX(SourceTableAlt_Key) , 0) + 1 

              INTO v_SourceTableAlt_Key
              FROM ( SELECT SourceTableAlt_Key 
                     FROM RBL_MISDB_PROD.DimSourceTable 
                     UNION 
                     SELECT SourceTableAlt_Key 
                     FROM RBL_MISDB_PROD.DimSourceTable_Mod  ) A;

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
                    FROM RBL_MISDB_PROD.DimSourceTable 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND SourceTableAlt_Key = v_SourceTableAlt_Key;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND SourceTableAlt_Key = v_SourceTableAlt_Key
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE RBL_MISDB_PROD.DimSourceTable
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND SourceTableAlt_Key = v_SourceTableAlt_Key;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND SourceTableAlt_Key = v_SourceTableAlt_Key
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
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE RBL_MISDB_PROD.DimSourceTable
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND SourceTableAlt_Key = v_SourceTableAlt_Key;

                  END;

                  ------------------------------------new add for First lvl Auth.
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND SourceTableAlt_Key = v_SourceTableAlt_Key
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM RBL_MISDB_PROD.DimSourceTable 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND SourceTableAlt_Key = v_SourceTableAlt_Key );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE RBL_MISDB_PROD.DimSourceTable
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND SourceTableAlt_Key = v_SourceTableAlt_Key
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     ----------------------------------------------
                     ELSE
                        IF v_OperationFlag = 17
                          AND v_AuthMode = 'Y' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND SourceTableAlt_Key = v_SourceTableAlt_Key
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM RBL_MISDB_PROD.DimSourceTable 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND SourceTableAlt_Key = v_SourceTableAlt_Key );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE RBL_MISDB_PROD.DimSourceTable
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND SourceTableAlt_Key = v_SourceTableAlt_Key
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
                              UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND SourceTableAlt_Key = v_SourceTableAlt_Key;

                           END;

                           -------new addd 
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                                    SET AuthorisationStatus = '1A',
                                        ApprovedByFirstLevel = v_ApprovedBy,
                                        DateApprovedFirstLevel = v_DateApproved
                                  WHERE  SourceTableAlt_Key = v_SourceTableAlt_Key
                                   AND AuthorisationStatus IN ( 'NP','MP','RM','DP' )
                                 ;

                              END;

                              ----------------------------------------------------------
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
                                            FROM RBL_MISDB_PROD.DimSourceTable 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND SourceTableAlt_Key = v_SourceTableAlt_Key;
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
                                       SELECT MAX(SourceTable_Key)  

                                         INTO v_ExEntityKey
                                         FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND SourceTableAlt_Key = v_SourceTableAlt_Key
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
                                         FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                        WHERE  SourceTable_Key = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(SourceTable_Key)  

                                         INTO v_ExEntityKey
                                         FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND SourceTableAlt_Key = v_SourceTableAlt_Key
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                        WHERE  SourceTable_Key = v_ExEntityKey;
                                       UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND SourceTableAlt_Key = v_SourceTableAlt_Key
                                         AND AuthorisationStatus = 'A';
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  SourceTableAlt_Key = v_SourceTableAlt_Key
                                            AND AuthorisationStatus IN ( 'DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM RBL_MISDB_PROD.DimSourceTable 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND SourceTableAlt_Key = v_SourceTableAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE RBL_MISDB_PROD.DimSourceTable
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND SourceTableAlt_Key = v_SourceTableAlt_Key;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE RBL_MISDB_PROD.DimSourceTable_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  SourceTableAlt_Key = v_SourceTableAlt_Key
                                            AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                          ;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    --[dbo].[DimSourceTable_Mod]
                                    IF v_DelStatus <> 'DP'
                                      OR v_AuthMode = 'N' THEN
                                     DECLARE
                                       v_IsAvailable CHAR(1) := 'N';
                                       v_IsSCD2 CHAR(1) := 'N';
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       v_AuthorisationStatus := 'A' ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM RBL_MISDB_PROD.DimSourceTable 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND SourceTableAlt_Key = v_SourceTableAlt_Key );
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
                                                             FROM RBL_MISDB_PROD.DimSourceTable 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_TimeKey
                                                                       AND SourceTableAlt_Key = v_SourceTableAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             DBMS_OUTPUT.PUT_LINE('BBBB');
                                             UPDATE RBL_MISDB_PROD.DimSourceTable
                                                SET SourceTableAlt_Key = v_SourceTableAlt_Key,
                                                    SourceAlt_Key = v_SourceAlt_Key,
                                                    SourceTableName = v_SourceTableName,
                                                    StageTableName = v_StageTableName,
                                                    Active_Inactive = v_Active_Inactive,
                                                    Reason = v_Reason,
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
                                               AND SourceTableAlt_Key = v_SourceTableAlt_Key;

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
                                          INSERT INTO RBL_MISDB_PROD.DimSourceTable
                                            ( SourceTableAlt_Key, SourceAlt_Key, SourceTableName, StageTableName, Active_Inactive, Reason, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                            ( SELECT v_SourceTableAlt_Key ,
                                                     v_SourceAlt_Key ,
                                                     v_SourceTableName ,
                                                     v_StageTableName ,
                                                     v_Active_Inactive ,
                                                     v_Reason ,
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
                                          UPDATE RBL_MISDB_PROD.DimSourceTable
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND SourceTableAlt_Key = v_SourceTableAlt_Key
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
               INSERT INTO RBL_MISDB_PROD.DimSourceTable_Mod
                 ( SourceTableAlt_Key, SourceAlt_Key, SourceTableName, StageTableName, Active_Inactive, Reason, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                 VALUES ( v_SourceTableAlt_Key, v_SourceAlt_Key, v_SourceTableName, v_StageTableName, v_Active_Inactive, v_Reason, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
            ---------------------------------------------------------------------------------------
            -------------------
            DBMS_OUTPUT.PUT_LINE(7);
            utils.commit_transaction;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_INUP" TO "ADF_CDR_RBL_STGDB";
