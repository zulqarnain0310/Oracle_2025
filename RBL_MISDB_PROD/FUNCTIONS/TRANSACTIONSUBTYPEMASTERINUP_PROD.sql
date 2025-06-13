--------------------------------------------------------
--  DDL for Function TRANSACTIONSUBTYPEMASTERINUP_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" 
(
  iv_Transaction_Sub_TypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_Transaction_Sub_Type_Code IN VARCHAR2 DEFAULT ' ' ,
  v_Transaction_Sub_Type_Description IN VARCHAR2 DEFAULT ' ' ,
  v_SourceAlt_Key IN VARCHAR2 DEFAULT ' ' ,
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
   v_Transaction_Sub_TypeAlt_Key NUMBER(10,0) := iv_Transaction_Sub_TypeAlt_Key;
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
      v_AppAvail CHAR;

   BEGIN
      v_ScreenName := 'TransactionSubTypeMaster' ;
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
      IF utils.object_id('Tempdb..tt_Temp_137') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_137 ';
      END IF;
      IF utils.object_id('Tempdb..tt_final_76') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_final_76 ';
      END IF;
      DELETE FROM tt_Temp_137;
      INSERT INTO tt_Temp_137
        VALUES ( v_Transaction_Sub_Type_Code, v_SourceAlt_Key, v_Transaction_Sub_Type_Description );
      DELETE FROM tt_final_76;
      UTILS.IDENTITY_RESET('tt_final_76');

      INSERT INTO tt_final_76 ( 
      	SELECT A.Businesscolvalues1 SourceAlt_Key  ,
              Transaction_Sub_Type_Code ,
              Transaction_Sub_Type_Description 
      	  FROM ( SELECT Transaction_Sub_Type_Code ,
                       Transaction_Sub_Type_Description ,
                       a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
                FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(SourceAlt_Key, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                              Transaction_Sub_Type_Code ,
                              Transaction_Sub_Type_Description 
                       FROM tt_Temp_137  ) A
                        /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A );

      EXECUTE IMMEDIATE ' ALTER TABLE tt_final_76 
         ADD ( Transaction_Sub_TypeAlt_Key NUMBER(10,0)  ) ';
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
                            FROM DimTransactionSubTypeMaster 
                             WHERE  SourceAlt_Key IN ( SELECT * 
                                                       FROM TABLE(SPLIT(v_SourceAlt_Key, ','))  )

                                      AND Transaction_Sub_Type_Code = v_Transaction_Sub_Type_Code
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM DimTransactionSubTypeMaster_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND SourceAlt_Key IN ( SELECT * 
                                                             FROM TABLE(SPLIT(v_SourceAlt_Key, ','))  )

                                      AND Transaction_Sub_Type_Code = v_Transaction_Sub_Type_Code
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
            SELECT NVL(MAX(Transaction_Sub_TypeAlt_Key) , 0) + 1 

              INTO v_Transaction_Sub_TypeAlt_Key
              FROM ( SELECT Transaction_Sub_TypeAlt_Key 
                     FROM DimTransactionSubTypeMaster 
                     UNION 
                     SELECT Transaction_Sub_TypeAlt_Key 
                     FROM DimTransactionSubTypeMaster_Mod  ) A;
            IF v_OperationFlag = 1 THEN

            BEGIN
               MERGE INTO TEMP 
               USING (SELECT TEMP.ROWID row_id, ACCT.Transaction_Sub_TypeAlt_Key
               FROM TEMP ,tt_final_76 TEMP
                      JOIN ( SELECT tt_final_76.SourceAlt_Key ,
                                    (v_Transaction_Sub_TypeAlt_Key + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                                      FROM DUAL  )  )) Transaction_Sub_TypeAlt_Key  
                             FROM tt_final_76 
                              WHERE  tt_final_76.Transaction_Sub_TypeAlt_Key = 0
                                       OR tt_final_76.Transaction_Sub_TypeAlt_Key IS NULL ) ACCT   ON TEMP.SourceAlt_Key = ACCT.SourceAlt_Key ) src
               ON ( TEMP.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET TEMP.Transaction_Sub_TypeAlt_Key = src.Transaction_Sub_TypeAlt_Key;

            END;
            END IF;

         END;
         END IF;

      END;
      END IF;
      IF v_OperationFlag = 2 THEN

      BEGIN
         MERGE INTO TEMP 
         USING (SELECT TEMP.ROWID row_id, v_Transaction_Sub_TypeAlt_Key
         FROM TEMP ,tt_final_76 TEMP ) src
         ON ( TEMP.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET TEMP.Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;

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
               --SET @Transaction_Sub_TypeAlt_Key = (Select ISNULL(Max(Transaction_Sub_TypeAlt_Key),0)+1 from 
               --						        (Select Transaction_Sub_TypeAlt_Key from DimTransactionSubTypeMaster
               --						 UNION 
               --						        Select Transaction_Sub_TypeAlt_Key from DimTransactionSubTypeMaster_Mod
               --						)A)
               GOTO TransactionSubTypeMaster_Insert;
               <<TransactionSubTypeMaster_Insert_Add>>

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
                    FROM DimTransactionSubTypeMaster 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM DimTransactionSubTypeMaster_Mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE DimTransactionSubTypeMaster
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE DimTransactionSubTypeMaster_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  GOTO TransactionSubTypeMaster_Insert;
                  <<TransactionSubTypeMaster_Insert_Edit_Delete>>

               END;
               ELSE
                  IF v_OperationFlag = 3
                    AND v_AuthMode = 'N' THEN

                  BEGIN
                     -- DELETE WITHOUT MAKER CHECKER
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE DimTransactionSubTypeMaster
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;

                  END;

                  -----------------------------------------first lvel auth.---------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimTransactionSubTypeMaster_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM DimTransactionSubTypeMaster 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimTransactionSubTypeMaster
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     ---------------------------------------------------------------------------
                     ELSE
                        IF v_OperationFlag = 17
                          AND v_AuthMode = 'Y' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE DimTransactionSubTypeMaster_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;
                           ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                           DBMS_OUTPUT.PUT_LINE('Sunil');
                           --		DECLARE @EntityKey as Int 
                           --		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                           --							 FROM DimBankRP_Mod 
                           --								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                           --									AND BankRPAlt_Key=@BankRPAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
                           --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                           --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                           --------------------------------
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM DimTransactionSubTypeMaster 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE DimTransactionSubTypeMaster
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
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
                              UPDATE DimTransactionSubTypeMaster_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;

                           END;

                           -----new add
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE DimTransactionSubTypeMaster_Mod
                                    SET AuthorisationStatus = '1A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
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
                                            FROM DimTransactionSubTypeMaster 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;
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
                                         FROM DimTransactionSubTypeMaster_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
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
                                         FROM DimTransactionSubTypeMaster_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(EntityKey)  

                                         INTO v_ExEntityKey
                                         FROM DimTransactionSubTypeMaster_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM DimTransactionSubTypeMaster_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       UPDATE DimTransactionSubTypeMaster_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                                         AND AuthorisationStatus = 'A';
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE DimTransactionSubTypeMaster_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM DimTransactionSubTypeMaster 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE DimTransactionSubTypeMaster
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE DimTransactionSubTypeMaster_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
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
                                                          FROM DimTransactionSubTypeMaster 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key );
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
                                                             FROM DimTransactionSubTypeMaster 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_TimeKey
                                                                       AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             DBMS_OUTPUT.PUT_LINE('BBBB');
                                             UPDATE DimTransactionSubTypeMaster
                                                SET SourceAlt_Key = v_SourceAlt_Key,
                                                    Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key,
                                                    Transaction_Sub_Type_Code = v_Transaction_Sub_Type_Code,
                                                    Transaction_Sub_Type_Description = v_Transaction_Sub_Type_Description,
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
                                               AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key;

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
                                          INSERT INTO DimTransactionSubTypeMaster
                                            ( SourceAlt_Key, Transaction_Sub_TypeAlt_Key, Transaction_Sub_Type_Code, Transaction_Sub_Type_Description, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                            ( SELECT SourceAlt_Key ,
                                                     v_Transaction_Sub_TypeAlt_Key ,
                                                     Transaction_Sub_Type_Code ,
                                                     Transaction_Sub_Type_Description ,
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
                                              FROM tt_final_76 TEMP );

                                       END;
                                       END IF;
                                       IF v_IsSCD2 = 'Y' THEN

                                       BEGIN
                                          UPDATE DimTransactionSubTypeMaster
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND Transaction_Sub_TypeAlt_Key = v_Transaction_Sub_TypeAlt_Key
                                            AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    IF v_AUTHMODE = 'N' THEN

                                    BEGIN
                                       v_AuthorisationStatus := 'A' ;
                                       GOTO TransactionSubTypeMaster_Insert;
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
            <<TransactionSubTypeMaster_Insert>>
            IF v_ErrorHandle = 0 THEN

            BEGIN
               -----------------------------------------------------------
               --	IF Object_id('Tempdb..tt_Temp_137') Is Not Null
               --Drop Table tt_Temp_137
               --	IF Object_id('Tempdb..tt_final_76') Is Not Null
               --Drop Table tt_final_76
               --Create table tt_Temp_137
               --(Transaction_Sub_Type_Code Varchar(5)
               --,SourceAlt_Key Varchar(20)
               --,Transaction_Sub_Type_Description	varchar(50)
               --)
               --Insert into tt_Temp_137 values(@Transaction_Sub_Type_Code,@SourceAlt_Key,@Transaction_Sub_Type_Description)
               --Select A.Businesscolvalues1 as SourceAlt_Key,Transaction_Sub_Type_Code,Transaction_Sub_Type_Description  into tt_final_76 From (
               --SELECT Transaction_Sub_Type_Code,Transaction_Sub_Type_Description,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
               --                            FROM  (SELECT 
               --                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
               --											Transaction_Sub_Type_Code,Transaction_Sub_Type_Description
               --                                            from tt_Temp_137
               --                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
               --)A 
               --ALTER TABLE #FINAL ADD Transaction_Sub_TypeAlt_Key INT
               --IF @OperationFlag=1 
               --BEGIN
               --UPDATE TEMP 
               --SET TEMP.Transaction_Sub_TypeAlt_Key=ACCT.Transaction_Sub_TypeAlt_Key
               -- FROM tt_final_76 TEMP
               --INNER JOIN (SELECT SourceAlt_Key,(@Transaction_Sub_TypeAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Transaction_Sub_TypeAlt_Key
               --			FROM tt_final_76
               --			WHERE Transaction_Sub_TypeAlt_Key=0 OR Transaction_Sub_TypeAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
               --END
               --IF @OperationFlag=2 
               --BEGIN
               --UPDATE TEMP 
               --SET TEMP.Transaction_Sub_TypeAlt_Key=@Transaction_Sub_TypeAlt_Key
               -- FROM tt_final_76 TEMP
               --END
               --------------------------------------------------
               INSERT INTO DimTransactionSubTypeMaster_Mod
                 ( SourceAlt_Key, Transaction_Sub_TypeAlt_Key, Transaction_Sub_Type_Code, Transaction_Sub_Type_Description, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                 ( SELECT
                   --@Transaction_Sub_TypeAlt_Key
                    SourceAlt_Key ,
                    Transaction_Sub_TypeAlt_Key ,
                    Transaction_Sub_Type_Code ,
                    Transaction_Sub_Type_Description ,
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
                         WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                    ELSE NULL
                       END col  ,
                    CASE 
                         WHEN v_AuthMode = 'Y' THEN v_DateApproved
                    ELSE NULL
                       END col  
                   FROM tt_final_76  );
               --VALUES
               --			( 
               --					 @SourceAlt_Key					
               --					,@Transaction_Sub_TypeAlt_Key	
               --					,@Transaction_Sub_Type_Code		
               --					,@Transaction_Sub_Type_Description
               --					,@AuthorisationStatus
               --					,@EffectiveFromTimeKey
               --					,@EffectiveToTimeKey 
               --					,@CreatedBy
               --					,@DateCreated
               --					,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
               --					,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
               --					,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
               --					,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
               --			)
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO TransactionSubTypeMaster_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO TransactionSubTypeMaster_Insert_Edit_Delete;

                  END;
                  END IF;
               END IF;

            END;
            END IF;
            -------------------
            DBMS_OUTPUT.PUT_LINE(7);
            utils.commit_transaction;
            --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimBankRP WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
            --															AND BankRPAlt_Key=@BankRPAlt_Key
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERINUP_PROD" TO "ADF_CDR_RBL_STGDB";
