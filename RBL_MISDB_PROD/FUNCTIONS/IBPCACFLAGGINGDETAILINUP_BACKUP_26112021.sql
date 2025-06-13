--------------------------------------------------------
--  DDL for Function IBPCACFLAGGINGDETAILINUP_BACKUP_26112021
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" 
-- =============================================  
 -- Author:    <Vasundhara>  
 -- Create date:   <09/03/2021>  
 -- Description:   <Account Flagging For IBPC Table Insert/ Update>  
 -- =============================================  

(
  v_AccountFlagAlt_Key IN NUMBER DEFAULT 0 ,
  v_SourceAlt_Key IN NUMBER DEFAULT 0 ,
  v_SourceName IN VARCHAR2 DEFAULT NULL ,
  v_AccountID IN VARCHAR2 DEFAULT NULL ,
  v_CustomerID IN VARCHAR2 DEFAULT NULL ,
  v_CustomerName IN VARCHAR2 DEFAULT NULL ,
  v_FlagAlt_Key IN VARCHAR2 DEFAULT NULL ,
  --,@PoolID   int     =NULL  
  v_PoolID IN VARCHAR2 DEFAULT NULL ,
  v_PoolName IN VARCHAR2 DEFAULT NULL ,
  v_AccountBalance IN NUMBER DEFAULT NULL ,
  v_POS IN NUMBER DEFAULT NULL ,
  v_InterestReceivable IN NUMBER DEFAULT NULL ,
  v_ExposureAmount IN NUMBER DEFAULT NULL ,
  v_ChangeFields IN VARCHAR2 DEFAULT NULL ,
  iv_ErrorHandle IN NUMBER DEFAULT 0 ,
  iv_ExEntityKey IN NUMBER DEFAULT 0 ,
  ---------D2k System Common Columns  --  
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_IsMOC IN CHAR DEFAULT 'N' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_ExEntityKey NUMBER(10,0) := iv_ExEntityKey;
   v_ErrorHandle NUMBER(10,0) := iv_ErrorHandle;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   ----Added on 26-03-2021
   SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

     INTO v_Timekey
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
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
                         FROM RBL_MISDB_PROD.IBPCACFlaggingDetail 
                          WHERE  AccountId = v_AccountID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                         UNION 
                         SELECT 1 
                         FROM RBL_MISDB_PROD.IBPCACFlaggingDetail_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND AccountId = v_AccountID
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
         --BEGIN TRANSACTION   
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
            GOTO IBPCACFlaggingDetail_Insert;
            <<IBPCACFlaggingDetail_Insert_Add>>

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
                 FROM RBL_MISDB_PROD.IBPCACFlaggingDetail 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AccountID = v_AccountID;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM RBL_MISDB_PROD.IBPCACFlaggingDetail_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND AccountID = v_AccountID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE  
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP  
                  UPDATE RBL_MISDB_PROD.IBPCACFlaggingDetail
                     SET AuthorisationStatus = TRIM(v_AuthorisationStatus)
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS   
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE IBPCACFlaggingDetail_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               --GOTO AdvFacBillDetail_Insert  
               --AdvFacBillDetail_Insert_Edit_Delete:  
               GOTO IBPCACFlaggingDetail_Insert;
               <<IBPCACFlaggingDetail_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER  
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE IBPCACFlaggingDetail
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID;

               END;

               ------------------------------------------------------------------
               ELSE
                  IF v_OperationFlag = 21
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE IBPCACFlaggingDetail_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AccountID = v_AccountID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM IBPCACFlaggingDetail 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountID = v_AccountID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE IBPCACFlaggingDetail
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountID = v_AccountID
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  --------------------------------------------------------------
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE IBPCACFlaggingDetail_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountID = v_AccountID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM IBPCACFlaggingDetail 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AccountID = v_AccountID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE IBPCACFlaggingDetail
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AccountID = v_AccountID
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
                           UPDATE IBPCACFlaggingDetail_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND AccountId = v_AccountID;

                        END;

                        -------------------------------------------------
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE IBPCACFlaggingDetail_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  AccountId = v_AccountID
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

                           END;

                           -------------------------------------------  
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
                                         FROM RBL_MISDB_PROD.IBPCACFlaggingDetail 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND AccountID = v_AccountID;
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
                                      FROM RBL_MISDB_PROD.IBPCACFlaggingDetail_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AccountID = v_AccountID
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
                                      FROM IBPCACFlaggingDetail_Mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(Entity_Key)  

                                      INTO v_ExEntityKey
                                      FROM IBPCACFlaggingDetail_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AccountID = v_AccountID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM IBPCACFlaggingDetail_Mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    UPDATE IBPCACFlaggingDetail_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND AccountID = v_AccountID
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE  
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE IBPCACFlaggingDetail_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  AccountID = v_AccountID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM IBPCACFlaggingDetail 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AccountID = v_AccountID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE IBPCACFlaggingDetail
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND AccountID = v_AccountID;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK  
                                    ELSE

                                     -- OTHER THAN DELETE STATUS  
                                    BEGIN
                                       UPDATE IBPCACFlaggingDetail_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  AccountID = v_AccountID
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
                                                       FROM IBPCACFlaggingDetail 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND AccountID = v_AccountID );
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
                                                          FROM IBPCACFlaggingDetail 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND AccountID = v_AccountID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE IBPCACFlaggingDetail
                                             SET AccountFlagAlt_Key = v_AccountFlagAlt_Key,
                                                 SourceAlt_Key = v_SourceAlt_Key,
                                                 SourceName = v_SourceName,
                                                 AccountID = v_AccountID,
                                                 CustomerID = v_CustomerID,
                                                 CustomerName = v_CustomerName,
                                                 FlagAlt_Key = v_FlagAlt_Key,
                                                 PoolID = v_PoolID,
                                                 PoolName = v_PoolName,
                                                 AccountBalance = v_AccountBalance,
                                                 POS = v_POS,
                                                 InterestReceivable = v_InterestReceivable,
                                                 ExposureAmount = v_ExposureAmount,
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
                                                 Remark = v_Remark
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND AccountID = v_AccountID;

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
                                       INSERT INTO IBPCACFlaggingDetail --Entity_Key  

                                         ( AccountFlagAlt_Key, SourceAlt_Key, SourceName, AccountID, CustomerID, CustomerName, FlagAlt_Key, PoolID, PoolName, AccountBalance, POS, InterestReceivable, ExposureAmount, AuthorisationStatus, Remark, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )

                                         -- ,D2Ktimestamp  
                                         VALUES ( v_AccountFlagAlt_Key, v_SourceAlt_Key, v_SourceName, v_AccountID, v_CustomerID, v_CustomerName, v_FlagAlt_Key, v_PoolID, v_PoolName, v_AccountBalance, v_POS, v_InterestReceivable, v_ExposureAmount, 
                                       --,trim(@AuthorisationStatus)
                                       v_AuthorisationStatus, v_Remark, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
                                       -- ,@D2Ktimestamp  
                                       -----------
                                       DBMS_OUTPUT.PUT_LINE('Sunil111');
                                       IF v_FlagAlt_Key = 'Y' THEN

                                       BEGIN
                                          INSERT INTO IBPCFinalPoolDetail --Entity_Key  
                                           --AccountFlagAlt_Key  

                                            ( SourceAlt_Key, SourceName, AccountID, CustomerID, CustomerName, FlagAlt_Key, PoolID, PoolName, AccountBalance, POS, InterestReceivable, ExposureAmount, AuthorisationStatus, Remark, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, IBPCinDate ----new add
                                           )

                                            -- ,D2Ktimestamp  
                                            VALUES (  -- @AccountFlagAlt_Key  
                                          v_SourceAlt_Key, v_SourceName, v_AccountID, v_CustomerID, v_CustomerName, v_FlagAlt_Key, v_PoolID, v_PoolName, v_AccountBalance, v_POS, v_InterestReceivable, v_ExposureAmount, 
                                          --,trim(@AuthorisationStatus)
                                          v_AuthorisationStatus, v_Remark, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
                                             END, SYSDATE );
                                          --new add
                                          -- ,@D2Ktimestamp  
                                          /*Adding Flag ----------Pranay 21-03-2021*/
                                          MERGE INTO A 
                                          USING (SELECT A.ROWID row_id, CASE 
                                          WHEN NVL(A.SplFlag, ' ') = ' ' THEN 'IBPC'
                                          ELSE A.SplFlag || ',' || 'IBPC'
                                             END AS SplFlag
                                          FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A 
                                           WHERE A.EffectiveToTimeKey = 49999
                                            AND A.RefSystemAcId = v_AccountID) src
                                          ON ( A.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET A.SplFlag = src.SplFlag;

                                       END;
                                       END IF;
                                       --ELSE
                                       IF v_FlagAlt_Key = 'N' THEN

                                       BEGIN
                                          UPDATE IBPCFinalPoolDetail
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 IBPCOutDate -- new add
                                                  = SYSDATE,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND AccountID = v_AccountID;
                                          --WHERE (EffectiveFromTimeKey>=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
                                          --AND EffectiveFromTimekey<@EffectiveFromTimeKey 
                                          ------------------REMOVE FLAG--------1) @FlagAlt_Key='Y' (in IBPCACFlaggingDetailInUp SP)
                                          IF utils.object_id('TempDB..tt_Temp_97') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_97 ';
                                          END IF;
                                          DELETE FROM tt_Temp_97;
                                          UTILS.IDENTITY_RESET('tt_Temp_97');

                                          INSERT INTO tt_Temp_97 ( 
                                          	SELECT AccountentityID ,
                                                  SplFlag 
                                          	  FROM CurDat_RBL_MISDB_PROD.AdvAcOtherDetail 
                                          	 WHERE  EffectiveToTimeKey = 49999
                                                     AND RefSystemAcId = v_AccountID
                                                     AND splflag LIKE '%IBPC%' );
                                          --Select * from tt_Temp_97
                                          IF utils.object_id('TEMPDB..tt_SplitValue_33') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue_33 ';
                                          END IF;
                                          DELETE FROM tt_SplitValue_33;
                                          UTILS.IDENTITY_RESET('tt_SplitValue_33');

                                          INSERT INTO tt_SplitValue_33 ( 
                                          	SELECT AccountentityID ,
                                                  a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
                                          	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(SplFlag, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                                          	AccountentityID 
                                                    FROM tt_Temp_97  ) A
                                                     /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
                                          --Select * from tt_SplitValue_33 
                                          DELETE tt_SplitValue_33

                                           WHERE  Businesscolvalues1 = 'IBPC';
                                          IF utils.object_id('TEMPDB..tt_NEWTRANCHE_77') IS NOT NULL THEN
                                           EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_77 ';
                                          END IF;
                                          DELETE FROM tt_NEWTRANCHE_77;
                                          UTILS.IDENTITY_RESET('tt_NEWTRANCHE_77');

                                          INSERT INTO tt_NEWTRANCHE_77 SELECT * 
                                               FROM ( SELECT ss.AccountEntityID ,
                                                             utils.stuff(( SELECT ',' || US.BUSINESSCOLVALUES1 
                                                                           FROM tt_SplitValue_33 US
                                                                            WHERE  US.AccountentityID = ss.AccountEntityID ), 1, 1, ' ') REPORTIDSLIST  
                                                      FROM tt_Temp_97 SS
                                                        GROUP BY ss.AccountEntityID ) B
                                               ORDER BY 1;
                                          --Select * from tt_NEWTRANCHE_77
                                          --SELECT * 
                                          MERGE INTO A 
                                          USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                                          FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                                                 JOIN tt_NEWTRANCHE_77 B   ON A.AccountentityID = B.AccountentityID 
                                           WHERE A.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                                            AND A.EFFECTIVETOTIMEKEY >= v_TimeKey) src
                                          ON ( A.ROWID = src.row_id )
                                          WHEN MATCHED THEN UPDATE SET A.SplFlag = src.REPORTIDSLIST;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    --------------
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE IBPCACFlaggingDetail
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND AccountID = v_AccountID
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    --GOTO AdvFacBillDetail_Insert  
                                    GOTO IBPCACFlaggingDetail_Insert;
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
         -- IF @FlagAlt_Key='Y'
         --     BEGIN  
         --       INSERT INTO IBPCFinalPoolDetail  
         --       (    --Entity_Key  
         --           --AccountFlagAlt_Key  
         --          SourceAlt_Key  
         --          ,SourceName  
         --          ,AccountID  
         --          ,CustomerID  
         --          ,CustomerName  
         --          ,FlagAlt_Key  
         --          ,PoolID  
         --          ,PoolName  
         --          ,AccountBalance  
         --          ,POS  
         --          ,InterestReceivable
         -- ,ExposureAmount
         --           ,AuthorisationStatus  
         --  ,Remark
         --           ,EffectiveFromTimeKey  
         --           ,EffectiveToTimeKey  
         --           ,CreatedBy  
         --           ,DateCreated  
         --           ,ModifyBy  
         --           ,DateModified  
         --           ,ApprovedBy  
         --           ,DateApproved  
         --  ,IBPCinDate  ----new add
         --          -- ,D2Ktimestamp  
         --         )  
         --      VALUES     
         --        (  -- @AccountFlagAlt_Key  
         --          @SourceAlt_Key  
         --          ,@SourceName  
         --          ,@AccountID  
         --          ,@CustomerID  
         --          ,@CustomerName  
         --          ,@FlagAlt_Key  
         --          ,@PoolID  
         --          ,@PoolName  
         --          ,@AccountBalance  
         --          ,@POS  
         --          ,@InterestReceivable
         -- ,@ExposureAmount
         --           --,trim(@AuthorisationStatus)
         --  ,@AuthorisationStatus
         --  ,@Remark
         --           ,@EffectiveFromTimeKey  
         --           ,@EffectiveToTimeKey  
         --           ,@CreatedBy  
         --           ,@DateCreated  
         --           ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
         --           ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
         --           ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
         --           ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
         --  ,GETDATE()   --new add
         --          -- ,@D2Ktimestamp  
         --           )  
         -- /*Adding Flag ----------Pranay 21-03-2021*/
         -- UPDATE A
         --SET  
         --	A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
         --					ELSE A.SplFlag+','+'IBPC'     END
         --  FROM DBO.AdvAcOtherDetail A
         --  Where A.EffectiveToTimeKey=49999 and A.RefSystemAcId=@AccountID
         --       END  
         -- --ELSE
         -- IF @FlagAlt_Key='N'
         -- BEGIN
         --  UPDATE IBPCFinalPoolDetail SET  
         --       EffectiveToTimeKey=@EffectiveFromTimeKey-1 
         -- ,IBPCOutDate=GETDATE()  -- new add
         --       ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
         --      WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
         --        AND EffectiveFromTimekey<@EffectiveFromTimeKey 
         --  ------------------REMOVE FLAG--------1) @FlagAlt_Key='Y' (in IBPCACFlaggingDetailInUp SP)
         --	IF OBJECT_ID('TempDB..tt_Temp_97') IS NOT NULL
         --	DROP TABLE tt_Temp_97
         --	Select AccountentityID,SplFlag into tt_Temp_97 from Curdat.AdvAcOtherDetail 
         --	where EffectiveToTimeKey=49999 AND RefSystemAcId=@AccountID AND splflag like '%IBPC%'
         --	--Select * from tt_Temp_97
         --	IF OBJECT_ID('TEMPDB..tt_SplitValue_33')  IS NOT NULL
         --	DROP TABLE tt_SplitValue_33        
         --	SELECT AccountentityID,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into tt_SplitValue_33
         --								FROM  (SELECT 
         --												CAST ('<M>' + REPLACE(SplFlag, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
         --												AccountentityID
         --												from tt_Temp_97 
         --										) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
         --	 --Select * from tt_SplitValue_33 
         --	 DELETE FROM tt_SplitValue_33 WHERE Businesscolvalues1='IBPC'
         --	 IF OBJECT_ID('TEMPDB..tt_NEWTRANCHE_77')  IS NOT NULL
         --		DROP TABLE tt_NEWTRANCHE_77
         --		SELECT * INTO tt_NEWTRANCHE_77 FROM(
         --		SELECT 
         --			 SS.AccountentityID,
         --			STUFF((SELECT ',' + US.BUSINESSCOLVALUES1 
         --				FROM #SPLITVALUE US
         --				WHERE US.AccountentityID = SS.AccountentityID
         --				FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
         --			FROM #TEMP SS 
         --			GROUP BY SS.AccountentityID
         --			)B
         --			ORDER BY 1
         --			--Select * from tt_NEWTRANCHE_77
         --		--SELECT * 
         --		UPDATE A SET A.SplFlag=B.REPORTIDSLIST
         --		FROM DBO.AdvAcOtherDetail A
         --		INNER JOIN tt_NEWTRANCHE_77 B ON A.AccountentityID=B.AccountentityID
         --		WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey
         -- END
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<IBPCACFlaggingDetail_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO IBPCACFlaggingDetail_Mod --Entity_Key  

              ( AccountFlagAlt_Key, SourceAlt_Key, SourceName, AccountID, CustomerID, CustomerName, FlagAlt_Key, PoolID, PoolName, AccountBalance, POS, InterestReceivable, ExposureAmount, AuthorisationStatus, Remark
            --,ChangeFields  
            , EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )

              -- ,D2Ktimestamp  
              VALUES ( v_AccountFlagAlt_Key, v_SourceAlt_Key, v_SourceName, v_AccountID, v_CustomerID, v_CustomerName, v_FlagAlt_Key, v_PoolID, v_PoolName, v_AccountBalance, v_POS, v_InterestReceivable, v_ExposureAmount, trim(v_AuthorisationStatus), v_Remark, 
            --,@ChangeFields  
            v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               GOTO IBPCACFlaggingDetail_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO IBPCACFlaggingDetail_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------  
         DBMS_OUTPUT.PUT_LINE(7);
         -- COMMIT TRANSACTION  
         SELECT UTILS.CONVERT_TO_NUMBER(D2Ktimestamp,10,0) 

           INTO v_D2Ktimestamp
           FROM RBL_MISDB_PROD.IBPCACFlaggingDetail 
          WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
                   AND AccountID = v_AccountID;
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
      --ROLLBACK TRAN  
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN -1;---------  

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCACFLAGGINGDETAILINUP_BACKUP_26112021" TO "ADF_CDR_RBL_STGDB";
