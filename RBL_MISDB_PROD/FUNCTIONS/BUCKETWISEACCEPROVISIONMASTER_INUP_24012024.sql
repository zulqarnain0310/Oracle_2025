--------------------------------------------------------
--  DDL for Function BUCKETWISEACCEPROVISIONMASTER_INUP_24012024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" 
--sp_rename 'BucketWiseAcceProvisionMaster_InUp','BucketWiseAcceProvisionMaster_InUp_20042022'
 -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  iv_BucketWiseAcceleratedProvisionAltKey IN NUMBER DEFAULT 0 ,
  v_AcceProDuration IN NUMBER DEFAULT 0 ,
  v_EffectiveDate IN VARCHAR2 DEFAULT ' ' ,
  v_Secured_Unsecured IN VARCHAR2 DEFAULT ' ' ,
  v_BucketExceptCC IN VARCHAR2 DEFAULT ' ' ,
  v_BucketCreditCard IN VARCHAR2 DEFAULT ' ' ,
  v_AdditionalProvision IN NUMBER DEFAULT 0 ,
  v_SegmentNameAlt_key IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassNameAlt_key IN NUMBER DEFAULT 0 ,
  v_CurrentProvisionPer IN NUMBER DEFAULT 0 ,
  v_BucketWiseAcceleratedProvisionMaster_changeFields IN VARCHAR2 DEFAULT NULL ,
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
   --Declare
   v_BucketWiseAcceleratedProvisionAltKey NUMBER(10,0) := iv_BucketWiseAcceleratedProvisionAltKey;
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
      v_ExBucketWiseAcceleratedProvisionAltKey NUMBER(10,0) := 0;
      --,@BucketWiseAcceleratedProvisionAltKey                Int       =0
      ------------Added for Rejection Screen  29/06/2020   ----------
      v_Uniq_EntryID NUMBER(10,0) := 0;
      v_RejectedBY VARCHAR2(50) := NULL;
      v_RemarkBy VARCHAR2(50) := NULL;
      v_RejectRemark VARCHAR2(200) := NULL;
      v_ScreenName VARCHAR2(200) := NULL;
      v_AppAvail CHAR;

   BEGIN
      v_ScreenName := 'BucketWiseAcceleratedProvisionMaster' ;
      -------------------------------------------------------------
      --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  MOC_Initialised = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';
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
      IF ( NVL(v_EffectiveDate, ' ') <> UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('D', -1, utils.dateadd('M', utils.datediff('M', 0, UTILS.CONVERT_TO_VARCHAR2(v_EffectiveDate,200,p_style=>103)) + 1, 0)),10,p_style=>103) ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('SAC1');
         v_Result := 12 ;
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
                            FROM BucketWiseAcceleratedProvision 
                             WHERE  BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM BucketWiseAcceleratedProvision_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
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
            SELECT NVL(MAX(BucketWiseAcceleratedProvisionEntityID) , 0) + 1 

              INTO v_BucketWiseAcceleratedProvisionAltKey
              FROM ( SELECT BucketWiseAcceleratedProvisionEntityID 
                     FROM BucketWiseAcceleratedProvision 
                     UNION 
                     SELECT BucketWiseAcceleratedProvisionEntityID 
                     FROM BucketWiseAcceleratedProvision_Mod  ) A;

         END;
         END IF;

      END;
      END IF;
      IF v_OperationFlag = 2 THEN

      BEGIN
         --SET @BucketWiseAcceleratedProvisionAltKey=0
         SELECT BucketWiseAcceleratedProvisionEntityID 

           INTO v_BucketWiseAcceleratedProvisionAltKey
           FROM BucketWiseAcceleratedProvision_Mod A
          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey )
                   AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                   AND AuthorisationStatus IN ( 'NP','MP','RM' )

                   AND A.BucketWiseAcceleratedProvisionEntityID IN ( SELECT MAX(BucketWiseAcceleratedProvisionEntityID)  
                                                                     FROM BucketWiseAcceleratedProvision_Mod 
                                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                                               AND AuthorisationStatus IN ( 'NP','MP','RM' )

                                                                       GROUP BY BucketWiseAcceleratedProvisionEntityID )
         ;

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
               ----SET @BucketWiseAcceleratedProvisionAltKey = (Select ISNULL(Max(BucketWiseAcceleratedProvisionAltKey),0)+1 from 
               ----						(Select BucketWiseAcceleratedProvisionAltKey from BucketWiseAcceleratedProvision
               ----						 UNION 
               ----						 Select BucketWiseAcceleratedProvisionAltKey from BucketWiseAcceleratedProvision_Mod
               ----						)A)
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

                  --	UPDATE BucketWiseAcceleratedProvision_Mod

                  --	SET AuthorisationStatus='FM'

                  --	,ModifiedBy=@Modifiedby

                  --	,DateModified=@DateModified

                  --WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

                  --		AND BucketWiseAcceleratedProvisionEntityID =@BucketWiseAcceleratedProvisionAltKey

                  --		AND AuthorisationStatus IN('NP','MP','RM')
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
                    FROM BucketWiseAcceleratedProvision 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM BucketWiseAcceleratedProvision_Mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE BucketWiseAcceleratedProvision
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE BucketWiseAcceleratedProvision_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  --IF @OperationFlag=3
                  --BEGIN	
                  --	UPDATE BucketWiseAcceleratedProvision_Mod
                  --		SET AuthorisationStatus='FM'
                  --		,ModifiedBy=@Modifiedby
                  --		,DateModified=@DateModified
                  --	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
                  --			AND BucketWiseAcceleratedProvisionAltKey =@BucketWiseAcceleratedProvisionAltKey
                  --			AND AuthorisationStatus IN('DP')
                  --END
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
                     UPDATE BucketWiseAcceleratedProvision
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;

                  END;

                  ----------------------------------NEW ADD FIRST LVL AUTH------------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE BucketWiseAcceleratedProvision_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM BucketWiseAcceleratedProvision 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE BucketWiseAcceleratedProvision
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     -------------------------------------------------------------------------
                     ELSE
                        IF v_OperationFlag = 17
                          AND v_AuthMode = 'Y' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE BucketWiseAcceleratedProvision_Mod
                              SET AuthorisationStatus = 'R',
                                  FirstLevelApprovedBy = v_ApprovedBy,
                                  FirstLevelDateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;
                           ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                           DBMS_OUTPUT.PUT_LINE('Sunil');
                           --		DECLARE @BucketWiseAcceleratedProvisionAltKey as Int 
                           --SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@BucketWiseAcceleratedProvisionAltKey=BucketWiseAcceleratedProvisionAltKey
                           --					 FROM DimGL_Mod 
                           --						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                           --							AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
                           --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @BucketWiseAcceleratedProvisionAltKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                           --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                           --------------------------------
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM BucketWiseAcceleratedProvision 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE BucketWiseAcceleratedProvision
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
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
                              UPDATE BucketWiseAcceleratedProvision_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;

                           END;

                           --------NEW ADD------------------

                           --ELSE IF @OperationFlag=16

                           --	BEGIN

                           --	SET @ApprovedBy	   = @CrModApBy 

                           --	SET @DateApproved  = GETDATE()

                           --	UPDATE BucketWiseAcceleratedProvision_Mod

                           --					SET AuthorisationStatus ='1A'

                           --						,ApprovedBy=@ApprovedBy

                           --						,DateApproved=@DateApproved

                           --						WHERE BucketWiseAcceleratedProvisionAltKey=@BucketWiseAcceleratedProvisionAltKey

                           --						AND AuthorisationStatus in('NP','MP','DP','RM')

                           --	END

                           ------------------------------
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE BucketWiseAcceleratedProvision_Mod
                                    SET AuthorisationStatus = '1A',
                                        FirstLevelApprovedBy = v_ApprovedBy,
                                        FirstLevelDateApproved = v_DateApproved
                                  WHERE  BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                                   AND AuthorisationStatus IN ( 'NP','MP','RM' )
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
                                            FROM BucketWiseAcceleratedProvision 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;
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
                                       v_CurBucketWiseAcceleratedProvisionAltKey NUMBER(10,0) := 0;

                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('B');
                                       DBMS_OUTPUT.PUT_LINE('C');
                                       SELECT MAX(BucketWiseAcceleratedProvisionEntityID)  

                                         INTO v_ExBucketWiseAcceleratedProvisionAltKey
                                         FROM BucketWiseAcceleratedProvision_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
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
                                         FROM BucketWiseAcceleratedProvision_Mod 
                                        WHERE  BucketWiseAcceleratedProvisionEntityID = v_ExBucketWiseAcceleratedProvisionAltKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(BucketWiseAcceleratedProvisionEntityID)  

                                         INTO v_ExBucketWiseAcceleratedProvisionAltKey
                                         FROM BucketWiseAcceleratedProvision_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM BucketWiseAcceleratedProvision_Mod 
                                        WHERE  BucketWiseAcceleratedProvisionEntityID = v_ExBucketWiseAcceleratedProvisionAltKey;
                                       UPDATE BucketWiseAcceleratedProvision_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                                         AND AuthorisationStatus = 'A';
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE BucketWiseAcceleratedProvision_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM BucketWiseAcceleratedProvision 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE BucketWiseAcceleratedProvision
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE BucketWiseAcceleratedProvision_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
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
                                                          FROM BucketWiseAcceleratedProvision 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey );
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
                                                             FROM BucketWiseAcceleratedProvision 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                                                       AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             DBMS_OUTPUT.PUT_LINE('BBBB');
                                             UPDATE BucketWiseAcceleratedProvision
                                                SET AcceProDuration = v_AcceProDuration,
                                                    EffectiveDate = v_EffectiveDate,
                                                    Secured_Unsecured = v_Secured_Unsecured,
                                                    AdditionalProvision = v_AdditionalProvision,
                                                    BucketExceptCC = v_BucketExceptCC,
                                                    BucketCreditCard = v_BucketCreditCard,
                                                    SegmentName = v_SegmentNameAlt_key,
                                                    AssetClassNameAlt_key = v_AssetClassNameAlt_key,
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
                                               AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey;

                                          END;
                                          ELSE

                                          BEGIN
                                             v_IsSCD2 := 'Y' ;

                                          END;
                                          END IF;

                                       END;
                                       END IF;
                                       --select @IsAvailable,@IsSCD2
                                       IF v_IsAvailable = 'N'
                                         OR v_IsSCD2 = 'Y' THEN

                                       BEGIN
                                          INSERT INTO BucketWiseAcceleratedProvision
                                            ( BucketWiseAcceleratedProvisionEntityID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, BucketExceptCC, BucketCreditCard, SegmentName, AssetClassNameAlt_key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, CurrentProvisionPer )
                                            ( SELECT BucketWiseAcceleratedProvisionEntityID ,
                                                     AcceProDuration ,
                                                     EffectiveDate ,
                                                     Secured_Unsecured ,
                                                     AdditionalProvision ,
                                                     BucketExceptCC ,
                                                     BucketCreditCard ,
                                                     SegmentName ,
                                                     AssetClassNameAlt_key ,
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
                                                        END col  ,
                                                     CurrentProvisionPer 
                                              FROM BucketWiseAcceleratedProvision_Mod A
                                               WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                        AND A.EffectiveToTimeKey >= v_TimeKey )
                                                        AND A.BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey );

                                       END;
                                       END IF;
                                       IF v_IsSCD2 = 'Y' THEN

                                       BEGIN
                                          UPDATE BucketWiseAcceleratedProvision
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND BucketWiseAcceleratedProvisionEntityID = v_BucketWiseAcceleratedProvisionAltKey
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
               -----------------------------------------------------------
               --	IF Object_id('Tempdb..#Temp') Is Not Null
               --Drop Table #Temp
               --	IF Object_id('Tempdb..#final') Is Not Null
               --Drop Table #final
               --Create table #Temp
               --(ProductCode Varchar(20)
               --,SourceAlt_Key Varchar(20)
               --,ProductDescription Varchar(500)
               --)
               --Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)
               --Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
               --SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
               --                            FROM  (SELECT 
               --                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
               --											ProductCode,ProductDescription
               --                                            from #Temp
               --                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
               --)A 
               --ALTER TABLE #FINAL ADD BucketWiseAcceleratedProvisionAltKey INT
               --IF @OperationFlag=1 
               --BEGIN
               --UPDATE TEMP 
               --SET TEMP.BucketWiseAcceleratedProvisionAltKey=ACCT.BucketWiseAcceleratedProvisionAltKey
               -- FROM #final TEMP
               --INNER JOIN (SELECT SourceAlt_Key,(@BucketWiseAcceleratedProvisionAltKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) BucketWiseAcceleratedProvisionAltKey
               --			FROM #final
               --			WHERE BucketWiseAcceleratedProvisionAltKey=0 OR BucketWiseAcceleratedProvisionAltKey IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
               --END
               --IF @OperationFlag=2 
               --BEGIN
               --UPDATE TEMP 
               --SET TEMP.BucketWiseAcceleratedProvisionAltKey=@BucketWiseAcceleratedProvisionAltKey
               -- FROM #final TEMP
               --END
               --------------------------------------------------
               DBMS_OUTPUT.PUT_LINE('Sacbefore');
               INSERT INTO BucketWiseAcceleratedProvision_Mod
                 ( BucketWiseAcceleratedProvisionEntityID, AcceProDuration, EffectiveDate, Secured_Unsecured, AdditionalProvision, BucketExceptCC, BucketCreditCard, SegmentName, AssetClassNameAlt_key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, changeField, ScreenFlag, CurrentProvisionPer )
                 ( SELECT v_BucketWiseAcceleratedProvisionAltKey ,
                          v_AcceProDuration ,
                          v_EffectiveDate ,
                          v_Secured_Unsecured ,
                          v_AdditionalProvision ,
                          v_BucketExceptCC ,
                          v_BucketCreditCard ,
                          v_SegmentNameAlt_key ,
                          v_AssetClassNameAlt_key ,
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
                             END col  ,
                          v_BucketWiseAcceleratedProvisionMaster_changeFields ,
                          'S' ,
                          v_CurrentProvisionPer 
                     FROM DUAL  );
               DBMS_OUTPUT.PUT_LINE('SacAfter');
               ---------------------------------------------------------------------------------------
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
                   v_ReferenceID => v_BucketWiseAcceleratedProvisionAltKey -- ReferenceID ,
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
                   v_ReferenceID => v_BucketWiseAcceleratedProvisionAltKey -- ReferenceID ,
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUCKETWISEACCEPROVISIONMASTER_INUP_24012024" TO "ADF_CDR_RBL_STGDB";
