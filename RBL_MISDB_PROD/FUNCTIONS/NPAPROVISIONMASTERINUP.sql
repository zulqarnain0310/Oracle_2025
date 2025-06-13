--------------------------------------------------------
--  DDL for Function NPAPROVISIONMASTERINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" 
(
  iv_ProvisionAlt_Key IN NUMBER DEFAULT 0 ,
  v_ProvisionName IN VARCHAR2 DEFAULT ' ' ,
  v_ProvisionSecured IN NUMBER DEFAULT ' ' ,
  v_ProvisionUnSecured IN NUMBER DEFAULT ' ' ,
  v_NPAProvisionMaster_changeFields IN VARCHAR2,
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
   v_ProvisionAlt_Key NUMBER(10,0) := iv_ProvisionAlt_Key;
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
      ----------------------------Dated 15-07-2022--by Prashant------------as per Gaurav sir and Swapna------------
      v_Segment VARCHAR2(100);
      v_AppAvail CHAR;

   BEGIN
      v_ScreenName := 'NPAProvisionMaster' ;
      -------------------------------------------------------------
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  CurrentStatus = 'C';
      SELECT DISTINCT Segment 

        INTO v_Segment
        FROM DimProvision_Seg 
       WHERE  ProvisionAlt_Key = v_ProvisionAlt_Key
                AND EffectiveToTimeKey = 49999;
      -------------------------------------------------------------------------
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
                            FROM DimProvision_Seg 
                             WHERE  ProvisionAlt_Key = v_ProvisionAlt_Key
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM DimNPAProvision_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND ProvisionAlt_Key = v_ProvisionAlt_Key
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
            --SELECT @BankRPAlt_Key=NEXT VALUE FOR Seq_BankRPAlt_Key
            --PRINT @BankRPAlt_Key
            SELECT NVL(MAX(ProvisionAlt_Key) , 0) + 1 

              INTO v_ProvisionAlt_Key
              FROM ( SELECT ProvisionAlt_Key 
                     FROM DimProvision_Seg 
                     UNION 
                     SELECT ProvisionAlt_Key 
                     FROM DimNPAProvision_Mod  ) A;

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
               --SET @ProvisionAlt_Key = (Select ISNULL(Max(ProvisionAlt_Key),0)+1 from 
               --						(Select ProvisionAlt_Key from DimProvision_Seg
               --						 UNION 
               --						 Select ProvisionAlt_Key from DimNPAProvision_Mod
               --						)A)
               GOTO NPAProvisionMaster_Insert;
               <<NPAProvisionMaster_Insert_Add>>

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
                    FROM DimProvision_Seg 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND ProvisionAlt_Key = v_ProvisionAlt_Key;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM DimNPAProvision_Mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND ProvisionAlt_Key = v_ProvisionAlt_Key
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE DimProvision_Seg
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND ProvisionAlt_Key = v_ProvisionAlt_Key;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE DimNPAProvision_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND ProvisionAlt_Key = v_ProvisionAlt_Key
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  GOTO NPAProvisionMaster_Insert;
                  <<NPAProvisionMaster_Insert_Edit_Delete>>

               END;
               ELSE
                  IF v_OperationFlag = 3
                    AND v_AuthMode = 'N' THEN

                  BEGIN
                     -- DELETE WITHOUT MAKER CHECKER
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE DimProvision_Seg
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND ProvisionAlt_Key = v_ProvisionAlt_Key;

                  END;
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimNPAProvision_Mod
                           SET AuthorisationStatus = 'R'
                               --,ApprovedBy	 =@ApprovedBy
                                --,DateApproved=@DateApproved
                               ,
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND ProvisionAlt_Key = v_ProvisionAlt_Key
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
                                           FROM DimProvision_Seg 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND ProvisionAlt_Key = v_ProvisionAlt_Key );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimProvision_Seg
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND ProvisionAlt_Key = v_ProvisionAlt_Key
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     --------------------------------Two level auth. changes------------------------------
                     ELSE
                        IF v_OperationFlag = 21
                          AND v_AuthMode = 'Y' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE DimNPAProvision_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND ProvisionAlt_Key = v_ProvisionAlt_Key
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                           ;
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM DimProvision_Seg 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND ProvisionAlt_Key = v_ProvisionAlt_Key );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE DimProvision_Seg
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND ProvisionAlt_Key = v_ProvisionAlt_Key
                                AND AuthorisationStatus IN ( 'MP','DP','RM' )
                              ;

                           END;
                           END IF;

                        END;

                        ------------------------------------------------------------------
                        ELSE
                           IF v_OperationFlag = 18 THEN

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE(18);
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimNPAProvision_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND ProvisionAlt_Key = v_ProvisionAlt_Key;

                           END;
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE DimNPAProvision_Mod
                                    SET AuthorisationStatus = '1A'
                                        --,ApprovedBy=@ApprovedBy
                                         --,DateApproved=@DateApproved
                                        ,
                                        ApprovedByFirstLevel = v_ApprovedBy,
                                        DateApprovedFirstLevel = v_DateApproved
                                  WHERE  ProvisionAlt_Key = v_ProvisionAlt_Key
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
                                            FROM DimProvision_Seg 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND ProvisionAlt_Key = v_ProvisionAlt_Key;
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
                                         FROM DimNPAProvision_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND ProvisionAlt_Key = v_ProvisionAlt_Key
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
                                         FROM DimNPAProvision_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(EntityKey)  

                                         INTO v_ExEntityKey
                                         FROM DimNPAProvision_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND ProvisionAlt_Key = v_ProvisionAlt_Key
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM DimNPAProvision_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       UPDATE DimNPAProvision_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND ProvisionAlt_Key = v_ProvisionAlt_Key
                                         AND AuthorisationStatus = 'A';
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE DimNPAProvision_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ProvisionAlt_Key = v_ProvisionAlt_Key
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM DimProvision_Seg 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND ProvisionAlt_Key = v_ProvisionAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE DimProvision_Seg
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND ProvisionAlt_Key = v_ProvisionAlt_Key;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE DimNPAProvision_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  ProvisionAlt_Key = v_ProvisionAlt_Key
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
                                                          FROM DimProvision_Seg 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND ProvisionAlt_Key = v_ProvisionAlt_Key );
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
                                                             FROM DimProvision_Seg 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_TimeKey
                                                                       AND ProvisionAlt_Key = v_ProvisionAlt_Key );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             DBMS_OUTPUT.PUT_LINE('BBBB');
                                             UPDATE DimProvision_Seg
                                                SET ProvisionAlt_Key = v_ProvisionAlt_Key,
                                                    ProvisionName = v_ProvisionName,
                                                    ProvisionSecured = v_ProvisionSecured,
                                                    ProvisionUnSecured = v_ProvisionUnSecured,
                                                    Segment = v_Segment,
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
                                               AND ProvisionAlt_Key = v_ProvisionAlt_Key;

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
                                          INSERT INTO DimProvision_Seg
                                            ( ProvisionAlt_Key, ProvisionName, ProvisionSecured, ProvisionUnSecured, Segment, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                            ( SELECT v_ProvisionAlt_Key ,
                                                     v_ProvisionName ,
                                                     v_ProvisionSecured ,
                                                     v_ProvisionUnSecured ,
                                                     v_Segment ,
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
                                          UPDATE DimProvision_Seg
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND ProvisionAlt_Key = v_ProvisionAlt_Key
                                            AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    IF v_AUTHMODE = 'N' THEN

                                    BEGIN
                                       v_AuthorisationStatus := 'A' ;
                                       GOTO NPAProvisionMaster_Insert;
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
            <<NPAProvisionMaster_Insert>>
            IF v_ErrorHandle = 0 THEN
             DECLARE
               v_Parameter2 VARCHAR2(50);
               v_FinalParameter2 VARCHAR2(50);

            BEGIN
               INSERT INTO DimNPAProvision_Mod
                 ( ProvisionAlt_Key, ProvisionName, ProvisionSecured, ProvisionUnSecured, Segment, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, ChangeFields )
                 VALUES ( v_ProvisionAlt_Key, v_ProvisionName, v_ProvisionSecured, v_ProvisionUnSecured, v_Segment, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
                  END, v_NPAProvisionMaster_changeFields );
               SELECT utils.stuff(( SELECT DISTINCT ',' || ChangeFields 
                                    FROM DimNPAProvision_Mod 
                                     WHERE  ProvisionAlt_Key = v_ProvisionAlt_Key
                                              AND NVL(AuthorisationStatus, 'A') IN ( 'A','MP' )
                                   ), 1, 1, ' ') 

                 INTO v_Parameter2
                 FROM DUAL ;
               IF utils.object_id('tt_A_26') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_26 ';
               END IF;
               DELETE FROM tt_A_26;
               UTILS.IDENTITY_RESET('tt_A_26');

               INSERT INTO tt_A_26 ( 
               	SELECT DISTINCT VALUE 
               	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                                VALUE 
                         FROM ( SELECT VALUE 
                                FROM TABLE(STRING_SPLIT(v_Parameter2, ','))  ) A ) X );
               SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                    FROM tt_A_26  ), 1, 1, ' ') 

                 INTO v_FinalParameter2
                 FROM DUAL ;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_FinalParameter2
               FROM A ,DimNPAProvision_Mod A 
                WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
                 AND EffectiveToTimeKey >= v_tiMEKEY )
                 AND ProvisionAlt_Key = v_ProvisionAlt_Key) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET a.ChangeFields = v_FinalParameter2;
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO NPAProvisionMaster_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO NPAProvisionMaster_Insert_Edit_Delete;

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
                  (v_BranchCode => ' ' ----BranchCode
                   ,
                   v_MenuID => v_MenuID,
                   v_ReferenceID => v_ProvisionAlt_Key -- ReferenceID ,
                   ,
                   v_CreatedBy => NULL,
                   v_ApprovedBy => v_CrModApBy,
                   iv_CreatedCheckedDt => v_DateCreated1,
                   v_Remark => NULL,
                   v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                   ,
                   v_Flag => v_OperationFlag,
                   v_AuthMode => v_AuthMode) ;

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('UNAuthorised');
                  -- Declare
                  -- set @CreatedBy  =@UserLoginID
                  utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
                  (v_BranchCode => ' ' ----BranchCode
                   ,
                   v_MenuID => v_MenuID,
                   v_ReferenceID => v_ProvisionAlt_Key -- ReferenceID ,
                   ,
                   v_CreatedBy => v_CrModApBy,
                   v_ApprovedBy => NULL,
                   iv_CreatedCheckedDt => v_DateCreated1,
                   v_Remark => NULL,
                   v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                   ,
                   v_Flag => v_OperationFlag,
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."NPAPROVISIONMASTERINUP" TO "ADF_CDR_RBL_STGDB";
