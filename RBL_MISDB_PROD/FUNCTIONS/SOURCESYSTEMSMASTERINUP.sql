--------------------------------------------------------
--  DDL for Function SOURCESYSTEMSMASTERINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" 
(
  iv_SourceAlt_Key IN NUMBER DEFAULT 0 ,
  v_SourceName IN VARCHAR2 DEFAULT ' ' ,
  --,@SourceSystemsMaster_changeFields Varchar(50) =''         ----Commented by kapil khot because in Production SP this paramer is not available---------D2k System Common Columns		--
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
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_StartDate IN VARCHAR2,--Newly added by Kapil khot on 06/06/2024
  v_EndDate IN VARCHAR2,--Newly added by Kapil khot on 06/06/2024
  v_Active_Inactive IN CHAR,--Newly added by Kapil khot on 06/06/2024
  v_Reason IN VARCHAR2
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_SourceAlt_Key NUMBER(10,0) := iv_SourceAlt_Key;
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

 --Newly added by Kapil khot on 06/06/2024
BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'SourceSystemMaster' ;
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
                         FROM DIMSOURCEDB 
                          WHERE  SourceName = v_SourceName
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM DimSourceDB_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND SourceName = v_SourceName
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
         SELECT NVL(MAX(SourceAlt_Key) , 0) + 1 

           INTO v_SourceAlt_Key
           FROM ( SELECT SourceAlt_Key 
                  FROM DIMSOURCEDB 
                  UNION 
                  SELECT SourceAlt_Key 
                  FROM DimSourceDB_Mod  ) A;

      END;
      END IF;

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         ---------------------Added on 29/05/2020 for user allocation rights
         /*
         		IF @AccessScopeAlt_Key in (1,2)
         		BEGIN
         		PRINT 'Sunil'

         		IF EXISTS(				                
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
            --SET @SourceAlt_Key = (Select ISNULL(Max(SourceAlt_Key),0)+1 from 
            --						(Select SourceAlt_Key from DIMSOURCEDB
            --						 UNION 
            --						 Select SourceAlt_Key from DimSourceDB_Mod
            --						)A)
            GOTO SourceSystemMaster_Insert;
            <<SourceSystemMaster_Insert_Add>>

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
                 FROM DIMSOURCEDB 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND SourceAlt_Key = v_SourceAlt_Key;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimSourceDB_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND SourceAlt_Key = v_SourceAlt_Key
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DIMSOURCEDB
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND SourceAlt_Key = v_SourceAlt_Key;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE DimSourceDB_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND SourceAlt_Key = v_SourceAlt_Key
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO SourceSystemMaster_Insert;
               <<SourceSystemMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE DIMSOURCEDB
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND SourceAlt_Key = v_SourceAlt_Key;

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
                     UPDATE DimSourceDB_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND SourceAlt_Key = v_SourceAlt_Key
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DIMSOURCEDB 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND SourceAlt_Key = v_SourceAlt_Key );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DIMSOURCEDB
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND SourceAlt_Key = v_SourceAlt_Key
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
                        UPDATE DimSourceDB_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND SourceAlt_Key = v_SourceAlt_Key
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM DIMSOURCEDB 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND SourceAlt_Key = v_SourceAlt_Key );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DIMSOURCEDB
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND SourceAlt_Key = v_SourceAlt_Key
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
                           UPDATE DimSourceDB_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND SourceAlt_Key = v_SourceAlt_Key;

                        END;

                        -----new add
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimSourceDB_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedByFirstLevel = v_ApprovedBy --New Colum is added 'ApprovedByFirstLevel' in MOD table,   -->Previously ,ApprovedBy=@ApprovedBy
                                     ,
                                     DateApprovedFirstLevel = v_DateApproved --New Colum is added 'DateApprovedFirstLevel' in MOD table, -->Previously ,DateApproved=@DateApproved

                               WHERE  SourceAlt_Key = v_SourceAlt_Key
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

                           END;

                           ---------------------------
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
                                         FROM DIMSOURCEDB 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND SourceAlt_Key = v_SourceAlt_Key;
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
                                    SELECT MAX(Source_Key)  

                                      INTO v_ExEntityKey
                                      FROM DimSourceDB_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND SourceAlt_Key = v_SourceAlt_Key
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
                                      FROM DimSourceDB_Mod 
                                     WHERE  Source_Key = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(Source_Key)  

                                      INTO v_ExEntityKey
                                      FROM DimSourceDB_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND SourceAlt_Key = v_SourceAlt_Key
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM DimSourceDB_Mod 
                                     WHERE  Source_Key = v_ExEntityKey;
                                    UPDATE DimSourceDB_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND SourceAlt_Key = v_SourceAlt_Key
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE DimSourceDB_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  SourceAlt_Key = v_SourceAlt_Key
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DIMSOURCEDB 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND SourceAlt_Key = v_SourceAlt_Key );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE DIMSOURCEDB
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND SourceAlt_Key = v_SourceAlt_Key;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE DimSourceDB_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  SourceAlt_Key = v_SourceAlt_Key
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
                                                       FROM DIMSOURCEDB 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND SourceAlt_Key = v_SourceAlt_Key );
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
                                                          FROM DIMSOURCEDB 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND SourceAlt_Key = v_SourceAlt_Key );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE DIMSOURCEDB
                                             SET SourceAlt_Key = v_SourceAlt_Key,
                                                 SourceName = v_SourceName,
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
                                                    END,
                                                 StartDate = v_StartDate --Newly added by Kapil khot on 06/06/2024
                                                 ,
                                                 EndDate = v_EndDate --Newly added by Kapil khot on 06/06/2024
                                                 ,
                                                 Active_Inactive = v_Active_Inactive --Newly added by Kapil khot on 06/06/2024
                                                 ,
                                                 Reason = v_Reason --Newly added by Kapil khot on 06/06/2024

                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND SourceAlt_Key = v_SourceAlt_Key;

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
                                       INSERT INTO DIMSOURCEDB
                                         ( Source_Key ---------------Newly Added by kapil on 08/07/2024
                                       , SourceAlt_Key, SourceName, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, RecordStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, StartDate --Newly added by Kapil khot on 06/06/2024
                                       , EndDate --Newly added by Kapil khot on 06/06/2024
                                       , Active_Inactive --Newly added by Kapil khot on 06/06/2024
                                       , Reason --Newly added by Kapil khot on 06/06/2024
                                        )
                                         ( SELECT ( SELECT MAX(Source_Key)  + 1 
                                                    FROM DIMSOURCEDB 
                                                           ) ,---------------Newly Added by kapil on 08/07/2024

                                                  v_SourceAlt_Key ,
                                                  v_SourceName ,
                                                  CASE 
                                                       WHEN v_AUTHMODE = 'Y' THEN v_AuthorisationStatus
                                                  ELSE NULL
                                                     END col  ,
                                                  v_EffectiveFromTimeKey ,
                                                  v_EffectiveToTimeKey ,
                                                  'C' ,
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
                                                     END col  ,
                                                  v_StartDate ,--Newly added by Kapil khot on 06/06/2024

                                                  v_EndDate ,--Newly added by Kapil khot on 06/06/2024

                                                  v_Active_Inactive ,--Newly added by Kapil khot on 06/06/2024

                                                  v_Reason --Newly added by Kapil khot on 06/06/2024
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE DIMSOURCEDB
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND SourceAlt_Key = v_SourceAlt_Key
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO SourceSystemMaster_Insert;
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
         <<SourceSystemMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO DimSourceDB_Mod
              ( SourceAlt_Key, SourceName, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, StartDate --Newly added by Kapil khot on 06/06/2024
            , EndDate --Newly added by Kapil khot on 06/06/2024
            , Active_Inactive --Newly added by Kapil khot on 06/06/2024
            , Reason --Newly added by Kapil khot on 06/06/2024
             )
              VALUES ( v_SourceAlt_Key, v_SourceName, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               END, v_StartDate --Newly added by Kapil khot on 06/06/2024
            , v_EndDate --Newly added by Kapil khot on 06/06/2024
            , v_Active_Inactive --Newly added by Kapil khot on 06/06/2024
            , v_Reason );--Newly added by Kapil khot on 06/06/2024
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO SourceSystemMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO SourceSystemMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------------------------Attendance Log----------------------------	
         IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_DateCreated1 DATE;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('log table');
            v_DateCreated1 := SYSDATE ;
            --declare @ReferenceID1 varchar(max)
            --set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @SourceAlt_Key else @SourceAlt_Key end)
            IF v_OperationFlag IN ( 16,17,18,20,21 )
             THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Authorised');
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ',
                v_MenuID =>  ----BranchCode
                v_MenuID,
                v_ReferenceID => v_SourceName,
                v_CreatedBy =>  -- ReferenceID ,
                NULL,
                v_ApprovedBy => v_CrModApBy,
                iv_CreatedCheckedDt => v_DateCreated1,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 16,
                v_Flag =>  ---ScreenEntityId -- for FXT060 screen
                v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('UNAuthorised');
               -- Declare
               -- set @CreatedBy  =@UserLoginID
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ',
                v_MenuID =>  ----BranchCode
                v_MenuID,
                v_ReferenceID => v_SourceName,
                v_CreatedBy =>  -- ReferenceID ,
                v_CrModApBy,
                v_ApprovedBy => NULL,
                iv_CreatedCheckedDt => v_DateCreated1,
                v_Remark => NULL,
                v_ScreenEntityAlt_Key => 16,
                v_Flag =>  ---ScreenEntityId -- for FXT060 screen
                v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            END IF;

         END;
         END IF;
         ---------------------------------------------------------------------------------------
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERINUP" TO "ADF_CDR_RBL_STGDB";
