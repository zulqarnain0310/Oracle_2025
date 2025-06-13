--------------------------------------------------------
--  DDL for Function BORRBALANCEDETAILINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" 
-- =============================================
 -- Author:				<SNEHAL >
 -- Create date:			<28/06/2018>
 -- Description:			<BorrBalanceDetail Table Insert/ Update>
 -- =============================================

(
  --DECLARE
  v_BorrEntityID IN NUMBER DEFAULT 0 ,
  v_BorrBalanceEntityID IN NUMBER DEFAULT 0 ,
  v_Balance IN NUMBER DEFAULT 0 ,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  --	,@IsMOC						CHAR(1)			= 'N'
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 24909 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 49999 ,
  v_TimeKey IN NUMBER DEFAULT 24909 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;
--,@BranchCode				varchar(10)		
--,@ScreenEntityId			INT				=null

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

   --IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )

   --BEGIN

   --	PRINT 'ACL Process Completed'
   ELSE
   DECLARE
      v_AuthorisationStatus CHAR(2) := NULL;
      v_CreatedBy VARCHAR2(20) := NULL;
      v_DateCreated DATE := NULL;
      v_ModifiedBy VARCHAR2(20) := NULL;
      v_DateModified DATE := NULL;
      v_ApprovedBy VARCHAR2(20) := NULL;
      v_DateApproved DATE := NULL;
      v_ExCustomer_Key NUMBER(10,0) := 0;
      v_ErrorHandle NUMBER(10,0) := 0;
      v_ExEntityKey NUMBER(10,0) := 0;
      ---FOR MOC
      v_MocFromTimeKey NUMBER(10,0) := 0;
      v_MocToTimeKey NUMBER(10,0) := 0;
      v_MocDate DATE := NULL;
      v_PrevAssetClassAlt_Key NUMBER(5,0);
      v_PrevNPADt VARCHAR2(200);
      v_PrevConstitutionAlt_Key NUMBER(5,0) := 0;
      v_PrevConstName VARCHAR2(60);
      v_MocStatus CHAR(1);
      v_AppAvail CHAR;

   BEGIN
      DBMS_OUTPUT.PUT_LINE('BorrBalanceDetailInUp');
      DBMS_OUTPUT.PUT_LINE(v_OperationFlag);
      DBMS_OUTPUT.PUT_LINE(1);
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
      --IF @IsMOC='Y'
      --	BEGIN
      --		--- for MOC Effective from TimeKey and Effective to time Key is Prev_Qtr_key e.g for 2922  2830
      --		SET @EffectiveFromTimeKey =@TimeKey 
      --		SET @EffectiveToTimeKey =@TimeKey 
      --		SET @MocDate =GETDATE()
      --	END
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
                            FROM BorrBalanceDetail 
                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                                      AND BorrEntityID = v_BorrEntityID

                                      --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                            UNION 
                            SELECT 1 
                            FROM BorrBalanceDetail_mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND BorrEntityID = v_BorrEntityID

                                      --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
          );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            v_Result := -6 ;
            RETURN v_Result;-- CUSTOMERID ALEADY EXISTS

         END;
         ELSE

         BEGIN
            DBMS_OUTPUT.PUT_LINE(3);

         END;
         END IF;

      END;
      END IF;
      BEGIN

         BEGIN
            --SQL Server BEGIN TRANSACTION;
            utils.incrementTrancount;
            --SELECT @ReportEntityId = MAX(ReportEntityId) FROM 
            --(
            --	SELECT MAX(ReportEntityId) ReportEntityId FROM ExcelUtility_RptMaster_Mod --WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey>= @TimeKey
            --	UNION
            --	SELECT MAX(ReportEntityId) ReportEntityId FROM ExcelUtility_RptMaster --WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey>= @TimeKey
            --)a
            --SET @ReportEntityId = ISNULL(@ReportEntityId,0)+1
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
               GOTO TopManagementProfile_Insert;
               <<TopManagementProfile_Insert_Add>>

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
                    FROM BorrBalanceDetail 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND BorrEntityID = v_BorrEntityID;
                  --AND BorrBalanceEntityID = @BorrBalanceEntityID
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM BorrBalanceDetail_mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND BorrEntityID = v_BorrEntityID

                               --AND BorrBalanceEntityID = @BorrBalanceEntityID		
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE BorrBalanceDetail
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BorrEntityID = v_BorrEntityID;

                  END;
                  END IF;
                  --AND BorrBalanceEntityID = @BorrBalanceEntityID
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE BorrBalanceDetail_mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BorrEntityID = v_BorrEntityID

                       --AND BorrBalanceEntityID = @BorrBalanceEntityID
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  GOTO TopManagementProfile_Insert;
                  <<TopManagementProfile_Insert_Edit_Delete>>

               END;
               ELSE
                  IF v_OperationFlag = 3
                    AND v_AuthMode = 'N' THEN

                  BEGIN
                     -- DELETE WITHOUT MAKER CHECKER
                     DBMS_OUTPUT.PUT_LINE(' 3 Deleteing');
                     DBMS_OUTPUT.PUT_LINE(v_TImekey);
                     DBMS_OUTPUT.PUT_LINE(v_BorrEntityID);
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE BorrBalanceDetail
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BorrEntityID = v_BorrEntityID;
                     --AND BorrBalanceEntityID = @BorrBalanceEntityID
                     DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,2) || 'Row Deleted');

                  END;
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE BorrBalanceDetail_mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND BorrEntityID = v_BorrEntityID

                          --AND BorrBalanceEntityID = @BorrBalanceEntityID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM BorrBalanceDetail 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND BorrEntityID = v_BorrEntityID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN


                        --AND BorrBalanceEntityID = @BorrBalanceEntityID	
                        BEGIN
                           UPDATE BorrBalanceDetail
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND BorrEntityID = v_BorrEntityID

                             --AND BorrBalanceEntityID = @BorrBalanceEntityID
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
                           UPDATE BorrBalanceDetail_mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND BorrEntityID = v_BorrEntityID;

                        END;

                        --AND BorrBalanceEntityID = @BorrBalanceEntityID	
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
                                      FROM BorrBalanceDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey )
                                              AND BorrEntityID = v_BorrEntityID;
                                    --AND BorrBalanceEntityID = @BorrBalanceEntityID
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
                                 DBMS_OUTPUT.PUT_LINE(v_AuthMode);
                                 DBMS_OUTPUT.PUT_LINE('C');
                                 SELECT MAX(EntityKey)  

                                   INTO v_ExEntityKey
                                   FROM BorrBalanceDetail_mod 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey )
                                           AND BorrEntityID = v_BorrEntityID

                                           --AND BorrBalanceEntityID = @BorrBalanceEntityID	
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
                                   FROM BorrBalanceDetail_mod 
                                  WHERE  EntityKey = v_ExEntityKey;
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 SELECT MIN(EntityKey)  

                                   INTO v_ExEntityKey
                                   FROM BorrBalanceDetail_mod 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey )
                                           AND BorrEntityID = v_BorrEntityID

                                           --AND BorrBalanceEntityID = @BorrBalanceEntityID	
                                           AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                 ;
                                 SELECT EffectiveFromTimeKey 

                                   INTO v_CurrRecordFromTimeKey
                                   FROM BorrBalanceDetail_mod 
                                  WHERE  EntityKey = v_ExEntityKey;
                                 UPDATE BorrBalanceDetail_mod
                                    SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                   AND EffectiveToTimeKey >= v_Timekey )
                                   AND BorrEntityID = v_BorrEntityID

                                   --AND BorrBalanceEntityID = @BorrBalanceEntityID	
                                   AND AuthorisationStatus = 'A';
                                 -------DELETE RECORD AUTHORISE
                                 IF v_DelStatus = 'DP' THEN
                                  DECLARE
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    UPDATE BorrBalanceDetail_mod
                                       SET AuthorisationStatus = 'A',
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved,
                                           EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                     WHERE  BorrEntityID = v_BorrEntityID

                                      --AND BorrBalanceEntityID = @BorrBalanceEntityID	
                                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                                    ;
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM BorrBalanceDetail 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND BorrEntityID = v_BorrEntityID );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN


                                    --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                    BEGIN
                                       UPDATE BorrBalanceDetail
                                          SET AuthorisationStatus = 'A',
                                              ModifiedBy = v_ModifiedBy,
                                              DateModified = v_DateModified,
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND BorrEntityID = v_BorrEntityID;

                                    END;
                                    END IF;

                                 END;

                                 --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                  -- END OF DELETE BLOCK
                                 ELSE

                                  -- OTHER THAN DELETE STATUS
                                 BEGIN
                                    UPDATE BorrBalanceDetail_Mod
                                       SET AuthorisationStatus = 'A',
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved
                                     WHERE  BorrEntityID = v_BorrEntityID

                                      --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                      AND AuthorisationStatus IN ( 'NP','MP','RM' )
                                    ;

                                 END;
                                 END IF;

                              END;
                              END IF;
                              DBMS_OUTPUT.PUT_LINE(v_DelStatus || 'authorization status');
                              IF v_DelStatus <> 'DP'
                                OR v_AuthMode = 'N' THEN
                               DECLARE
                                 v_IsAvailable CHAR(1) := 'N';
                                 v_IsSCD2 CHAR(1) := 'N';
                                 v_temp NUMBER(1, 0) := 0;

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE(v_DelStatus || 'Del');
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM BorrBalanceDetail 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND BorrEntityID = v_BorrEntityID );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN
                                  DECLARE
                                    v_temp NUMBER(1, 0) := 0;


                                 --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                 BEGIN
                                    v_IsAvailable := 'Y' ;
                                    v_AuthorisationStatus := 'A' ;
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM BorrBalanceDetail 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                                                 AND BorrEntityID = v_BorrEntityID );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN


                                    --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('BBBB');
                                       UPDATE BorrBalanceDetail
                                          SET BorrEntityID = v_BorrEntityID
                                              --,BorrBalanceEntityID		= @BorrBalanceEntityID
                                              ,
                                              Balance = v_Balance,
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
                                         AND BorrEntityID = v_BorrEntityID;

                                    END;

                                    --AND BorrBalanceEntityID = @BorrBalanceEntityID
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
                                    DBMS_OUTPUT.PUT_LINE(v_IsAvailable || ' IsAvailable');
                                    DBMS_OUTPUT.PUT_LINE('MAIN INSERT 1');
                                    INSERT INTO BorrBalanceDetail
                                      ( BorrEntityID
                                    --,BorrBalanceEntityID		
                                    , Balance, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                      ( SELECT v_BorrEntityID ,
                                               --,@BorrBalanceEntityID		
                                               v_Balance ,
                                               CASE 
                                                    WHEN v_AUTHMODE = 'Y' THEN v_AuthorisationStatus
                                               ELSE NULL
                                                  END col  ,
                                               v_EffectiveFromTimeKey ,
                                               v_EffectiveToTimeKey ,
                                               v_CreatedBy ,
                                               v_DateCreated ,
                                               CASE 
                                                    WHEN v_IsAvailable = 'Y' THEN v_ModifiedBy
                                               ELSE NULL
                                                  END col  ,
                                               CASE 
                                                    WHEN v_IsAvailable = 'Y' THEN v_DateModified
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
                                    UPDATE BorrBalanceDetail
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AUTHMODE = 'Y' THEN 'A'
                                           ELSE NULL
                                              END

                                    --,ServiceLastdate = @ServiceLastdate	 --ADDED BY HAMID ON 16 MAR 2018
                                    WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND BorrEntityID = v_BorrEntityID

                                      --AND BorrBalanceEntityID = @BorrBalanceEntityID
                                      AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                 END;
                                 END IF;

                              END;
                              END IF;
                              IF v_AUTHMODE = 'N' THEN

                              BEGIN
                                 v_AuthorisationStatus := 'A' ;
                                 GOTO TopManagementProfile_Insert;
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
            ----***********maintain log table
            --****************************
            DBMS_OUTPUT.PUT_LINE(6);
            v_ErrorHandle := 1 ;
            <<TopManagementProfile_Insert>>
            IF v_ErrorHandle = 0 THEN

            BEGIN
               --SELECT @ServiceLastdate
               INSERT INTO BorrBalanceDetail_mod
                 ( BorrEntityID
               --,BorrBalanceEntityID		
               , Balance, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                 VALUES ( v_BorrEntityID, 
               --,@BorrBalanceEntityID		
               v_Balance, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved );
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO TopManagementProfile_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO TopManagementProfile_Insert_Edit_Delete;

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
              FROM BorrBalanceDetail 
             WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                      AND EffectiveToTimeKey >= v_TimeKey )
                      AND BorrEntityID = v_BorrEntityID;
            --AND BorrBalanceEntityID = @BorrBalanceEntityID
            IF v_OperationFlag = 3 THEN

            BEGIN
               v_Result := 3 ;
               RETURN v_Result;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE(8);
               v_Result := v_BorrEntityID ;
               RETURN v_Result;

            END;
            END IF;

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         --RETURN @MgmtProfileEntityId
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BORRBALANCEDETAILINUP" TO "ADF_CDR_RBL_STGDB";
