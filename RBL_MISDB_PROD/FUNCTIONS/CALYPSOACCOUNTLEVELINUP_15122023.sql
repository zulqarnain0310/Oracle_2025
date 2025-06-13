--------------------------------------------------------
--  DDL for Function CALYPSOACCOUNTLEVELINUP_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" 
(
  --Declare  
  v_AccountID IN VARCHAR2 DEFAULT ' ' ,
  v_POS IN NUMBER DEFAULT 0 ,
  v_InterestReceivable IN NUMBER DEFAULT 0 ,
  v_RestructureFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_RestructureDate IN VARCHAR2 DEFAULT NULL ,
  v_FITLFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_DFVAmount IN NUMBER DEFAULT 0 ,
  v_RePossessionFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_RePossessionDate IN VARCHAR2 DEFAULT NULL ,
  v_InherentWeaknessFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_InherentWeaknessDate IN VARCHAR2 DEFAULT NULL ,
  v_SARFAESIFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_SARFAESIDate IN VARCHAR2 DEFAULT NULL ,
  v_UnusualBounceFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_UnusualBounceDate IN VARCHAR2 DEFAULT NULL ,
  v_UnclearedEffectsFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_UnclearedEffectsDate IN VARCHAR2 DEFAULT NULL ,
  v_AdditionalProvisionCustomerlevel IN NUMBER,
  v_AdditionalProvisionAbsolute IN NUMBER,
  v_MOCReason IN VARCHAR2 DEFAULT ' ' ,
  v_FraudAccountFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_FraudDate IN VARCHAR2 DEFAULT NULL ,
  v_ScreenFlag IN VARCHAR2 DEFAULT ' ' ,
  v_MOCSource IN NUMBER DEFAULT 0 ,
  v_AccountNPAMOC_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_TwoDate IN VARCHAR2 DEFAULT NULL ,
  --,@TwoFlagAlt_Key						varchar(1)=''
  v_TwoAmount IN NUMBER,
  v_BookValue IN NUMBER,
  v_SMADate IN VARCHAR2,
  v_SMASubAssetClassValue IN VARCHAR2,
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
   v_RestructureDate VARCHAR2(20) := iv_RestructureDate;
   v_FraudDate VARCHAR2(20) := iv_FraudDate;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   --set @UnclearedEffectsDate =case when ( @UnclearedEffectsDate='' or @UnclearedEffectsDate='01/01/1900' or @UnclearedEffectsDate='1900/01/01') then NULL   
   --ELSE @UnclearedEffectsDate END  
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   --,@AccountEntityID int=0  
   ------------Added for Rejection Screen  29/06/2020   ----------  
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_ApprovedByFirstLevel VARCHAR2(20) := NULL;
   v_DateApprovedFirstLevel DATE := NULL;
   v_MOC_Date VARCHAR2(200);
   v_MocStatus VARCHAR2(100) := ' ';
   v_AccountEntityID NUMBER(10,0);
   v_temp NUMBER(1, 0) := 0;
   v_CustomerEntityID NUMBER(10,0);
   v_MOCReason_1 VARCHAR2(200);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_RestructureDate := CASE 
                             WHEN ( v_RestructureDate = ' '
                               OR v_RestructureDate = '01/01/1900'
                               OR v_RestructureDate = '1900/01/01' ) THEN NULL
   ELSE v_RestructureDate
      END ;
   v_FraudDate := CASE 
                       WHEN ( v_FraudDate = ' '
                         OR v_FraudDate = '01/01/1900'
                         OR v_FraudDate = '1900/01/01' ) THEN NULL
   ELSE v_FraudDate
      END ;
   v_ScreenName := 'AccountLevel' ;
   -------------------------------------------------------------  
   --Declare @MOC_DATE                  date=NULL
   --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   -- SET @MOC_DATE =(Select CAST(LastMonthDate AS DATE) from SysDayMatrix where Timekey=@Timekey) 
   -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   SELECT UTILS.CONVERT_TO_VARCHAR2(ExtDate,200) 

     INTO v_MOC_Date
     FROM SysDataMatrix 
    WHERE  Timekey = v_TimeKey;
   --PRINT '@MOC_DATE'
   -- PRINT @MOC_DATE
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   SELECT MocStatus 

     INTO v_MocStatus
     FROM CalypsoMOCMonitorStatus 
    WHERE  EntityKey IN ( SELECT MAX(EntityKey)  
                          FROM CalypsoMOCMonitorStatus  )
   ;
   IF ( v_MocStatus = 'InProgress' ) THEN

   BEGIN
      v_Result := 5 ;
      RETURN v_Result;

   END;
   END IF;
   SELECT ( SELECT InvEntityId 
            FROM InvestmentBasicDetail 
             WHERE  InvID = v_AccountID
            UNION 
            SELECT DerivativeEntityID 
            FROM CurDat_RBL_MISDB_PROD.DerivativeDetail 
             WHERE  DerivativeRefNo = v_AccountID ) 

     INTO v_AccountEntityID
     FROM DUAL ;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM CalypsoInvMOC_ChangeDetails 
                       WHERE  ( EffectiveFromTimeKey = v_TimeKey
                                AND EffectiveToTimeKey = v_TimeKey )
                                AND AccountEntityID = v_AccountEntityID
                                AND MOCType_Flag = 'ACCT'
                                AND MOCProcessed = 'N' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM CalypsoDervMOC_ChangeDetails 
                          WHERE  ( EffectiveFromTimeKey = v_TimeKey
                                   AND EffectiveToTimeKey = v_TimeKey )
                                   AND AccountEntityID = v_AccountEntityID
                                   AND MOCType_Flag = 'ACCT'
                                   AND MOCProcessed = 'N' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Result := 6 ;
         RETURN v_Result;

      END;
      END IF;

   END;
   END IF;
   SELECT IssuerEntityId 

     INTO v_CustomerEntityID
     FROM InvestmentBasicDetail 
    WHERE  InvID = v_AccountID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   SELECT ParameterName 

     INTO v_MOCReason_1
     FROM DimParameter 
    WHERE  DimParameterName LIKE '%MOCReason%'
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey
             AND ParameterAlt_Key = v_MOCReason;
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
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         -----  
         DBMS_OUTPUT.PUT_LINE(3);
         --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
         IF ( v_OperationFlag = 2
           OR v_OperationFlag = 3 )
           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

          --EDIT AND DELETE  
         BEGIN
            --  Print 4  
            --  SET @CreatedBy= @CrModApBy  
            --  SET @DateCreated = GETDATE()  
            --  Set @Modifiedby=@CrModApBy     
            --  Set @DateModified =GETDATE()   
            --  SET @AuthorisationStatus='MP'  
            --   --UPDATE NP,MP  STATUS   
            --   IF @OperationFlag=2  
            --   BEGIN   
            --    UPDATE CalypsoAccountLevelMOC_Mod  
            --     SET AuthorisationStatus='FM'  
            --     ,ModifyBy=@Modifiedby  
            --     ,DateModified=@DateModified  
            --    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
            --      --AND AccountID=@AccountID  
            --AND  AccountEntityID =@AccountEntityID
            --      AND AuthorisationStatus IN('NP','MP','RM')  
            --						UPDATE CalypsoAccountLevelMOC_Mod
            --					SET EffectiveToTimeKey=@TimeKey-1
            --				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
            --						AND  AccountEntityID =@AccountEntityID
            --						AND AuthorisationStatus IN('A')
            --   END 
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_Modifiedby := v_CrModApBy ;
            v_DateModified := SYSDATE ;
            v_AuthorisationStatus := 'MP' ;
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
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT COUNT(1)  
                               FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND AccountEntityID = v_AccountEntityID );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AccountEntityID = v_AccountEntityID;

            END;
            ELSE

            BEGIN
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AccountEntityID = v_AccountEntityID;

            END;
            END IF;
            ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
            IF NVL(v_CreatedBy, ' ') = ' ' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.CalypsoAccountLevelMOC_Mod 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AccountID = v_AccountID
                         AND AccountEntityID = v_AccountEntityID
                         AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
               ;

            END;
            ELSE
            DECLARE
               v_temp NUMBER(1, 0) := 0;

             ---IF DATA IS AVAILABLE IN MAIN TABLE
            BEGIN
               DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
               ----UPDATE FLAG IN MAIN TABLES AS MP
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT COUNT(1)  
                                  FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND AccountEntityID = v_AccountEntityID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID;

               END;
               ELSE

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID;

               END;
               END IF;

            END;
            END IF;
            --UPDATE NP,MP  STATUS 
            IF v_OperationFlag = 2 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT COUNT(1)  
                                  FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND AccountEntityID = v_AccountEntityID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID;

               END;
               ELSE

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID;

               END;
               END IF;
               UPDATE CalypsoAccountLevelMOC_Mod
                  SET AuthorisationStatus = 'FM',
                      ModifyBy = v_ModifiedBy,
                      DateModified = v_DateModified
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND AccountID = v_AccountID
                 AND AccountEntityID = v_AccountEntityID
                 AND AuthorisationStatus IN ( 'NP','MP','RM' )
               ;

            END;
            END IF;
            GOTO GLCodeMaster_Insert;
            <<GLCodeMaster_Insert_Edit_Delete>>

         END;

         -------------------------------------------------------  

         --start 20042021  
         ELSE
            IF v_OperationFlag = 21
              AND v_AuthMode = 'Y' THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE v_CrModApBy = ( SELECT UserLoginID 
                                         FROM DimUserInfo 
                                          WHERE  IsChecker2 = 'N'
                                                   AND EffectiveToTimeKey >= 49999
                                                   AND UserLoginID = v_CrModApBy
                                           GROUP BY UserLoginID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  v_Result := -1 ;
                  ROLLBACK;
                  utils.resetTrancount;
                  RETURN v_Result;

               END;
               END IF;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( v_CrModApBy = ( SELECT CreatedBy 
                                           FROM CalypsoAccountLevelMOC_Mod 
                                            WHERE  CreatedBy = v_CrModApBy
                                                     AND AccountEntityID = v_AccountEntityID
                                                     AND EffectiveToTimeKey = 49999
                                                     AND AuthorisationStatus = '1A'
                                             GROUP BY CreatedBy ) );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  v_Result := -1 ;
                  ROLLBACK;
                  utils.resetTrancount;
                  RETURN v_Result;

               END;

               --select createdby,* from DimBranch_Mod  
               ELSE
               DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_CrModApBy = ( SELECT ApprovedByFirstLevel 
                                              FROM CalypsoAccountLevelMOC_Mod 
                                               WHERE  ApprovedByFirstLevel = v_CrModApBy
                                                        AND AccountEntityID = v_AccountEntityID
                                                        AND EffectiveToTimeKey = 49999
                                                        AND AuthorisationStatus = '1A'
                                                GROUP BY ApprovedByFirstLevel ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     ROLLBACK;
                     utils.resetTrancount;
                     RETURN v_Result;

                  END;

                  --select createdby,* from DimBranch_Mod  
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE CalypsoAccountLevelMOC_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )

                       --AND AccountID=@AccountID  
                       AND AccountEntityID = v_AccountEntityID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoInvMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountEntityID = v_AccountEntityID
                                                  AND MOCType_Flag = 'ACCT' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoInvMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountEntityID = v_AccountEntityID
                          AND MOCType_Flag = 'ACCT'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoDervMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountEntityID = v_AccountEntityID
                                                  AND MOCType_Flag = 'ACCT' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoDervMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountEntityID = v_AccountEntityID
                          AND MOCType_Flag = 'ACCT'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;
                  END IF;

               END;
               END IF;

            END;

            --till here  

            -------------------------------------------------------  
            ELSE
               IF v_OperationFlag = 17
                 AND v_AuthMode = 'Y' THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_CrModApBy = ( SELECT CreatedBy 
                                              FROM CalypsoAccountLevelMOC_Mod 
                                               WHERE  CreatedBy = v_CrModApBy
                                                        AND AccountEntityID = v_AccountEntityID
                                                        AND AuthorisationStatus IN ( 'NP','MP' )

                                                        AND EffectiveToTimeKey = 49999
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     ROLLBACK;
                     utils.resetTrancount;
                     RETURN v_Result;

                  END;

                  --select createdby,* from DimBranch_Mod  
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE CalypsoAccountLevelMOC_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedByFirstLevel = v_ApprovedBy,
                            DateApprovedFirstLevel = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )

                       --AND AccountID=@AccountID  
                       AND AccountEntityID = v_AccountEntityID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoInvMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountEntityID = v_AccountEntityID
                                                  AND MOCType_Flag = 'ACCT' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoInvMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountEntityID = v_AccountEntityID
                          AND MOCType_Flag = 'ACCT'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoDervMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountEntityID = v_AccountEntityID
                                                  AND MOCType_Flag = 'ACCT' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoDervMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountEntityID = v_AccountEntityID
                          AND MOCType_Flag = 'ACCT'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;
                  END IF;

               END;

               ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------  
               ELSE
                  IF v_OperationFlag = 18 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(18);
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE CalypsoAccountLevelMOC_Mod
                        SET AuthorisationStatus = 'RM'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )


                       --AND AccountID=@AccountID
                       AND AccountEntityID = v_AccountEntityID;

                  END;
                  ELSE
                     IF v_OperationFlag = 16 THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE ( v_CrModApBy = ( SELECT CreatedBy 
                                                    FROM CalypsoAccountLevelMOC_Mod 
                                                     WHERE  AuthorisationStatus IN ( 'NP','MP' )

                                                              AND CreatedBy = v_CrModApBy

                                                              --And AccountID=@AccountID 
                                                              AND AccountEntityID = v_AccountEntityID
                                                              AND EffectiveToTimeKey = 49999
                                                      GROUP BY CreatedBy ) );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           v_Result := -1 ;
                           ROLLBACK;
                           utils.resetTrancount;
                           RETURN v_Result;

                        END;

                        --select * from DimBranch_Mod  
                        ELSE

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           DBMS_OUTPUT.PUT_LINE(111111111);
                           UPDATE CalypsoAccountLevelMOC_Mod
                              SET AuthorisationStatus = '1A',
                                  ApprovedByFirstLevel = v_ApprovedBy,
                                  DateApprovedFirstLevel = v_DateApproved
                            WHERE  AccountEntityID = v_AccountEntityID
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;
                     ELSE
                        IF v_OperationFlag = 20
                          OR v_AuthMode = 'N' THEN
                         DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE v_CrModApBy = ( SELECT UserLoginID 
                                                     FROM DimUserInfo 
                                                      WHERE  IsChecker2 = 'N'
                                                               AND EffectiveToTimeKey = 49999
                                                               AND UserLoginID = v_CrModApBy
                                                       GROUP BY UserLoginID );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              v_Result := -1 ;
                              ROLLBACK;
                              utils.resetTrancount;
                              RETURN v_Result;

                           END;
                           END IF;
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE ( v_CrModApBy = ( SELECT CreatedBy 
                                                       FROM CalypsoAccountLevelMOC_Mod 
                                                        WHERE  AuthorisationStatus IN ( '1A' )

                                                                 AND CreatedBy = v_CrModApBy
                                                                 AND AccountEntityID = v_AccountEntityID
                                                                 AND EffectiveToTimeKey = 49999

                                                       --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')    
                                                       GROUP BY CreatedBy ) );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              v_Result := -1 ;
                              ROLLBACK;
                              utils.resetTrancount;
                              RETURN v_Result;

                           END;

                           --select * from DimBranch_Mod  
                           ELSE
                           DECLARE
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE ( v_CrModApBy = ( SELECT ApprovedBy 
                                                          FROM CalypsoAccountLevelMOC_Mod 
                                                           WHERE  AuthorisationStatus IN ( '1A' )

                                                                    AND ApprovedBy = v_CrModApBy
                                                                    AND AccountEntityID = v_AccountEntityID
                                                                    AND EffectiveToTimeKey = 49999
                                                            GROUP BY ApprovedBy ) );
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    NULL;
                              END;

                              IF v_temp = 1 THEN

                              BEGIN
                                 v_Result := -1 ;
                                 ROLLBACK;
                                 utils.resetTrancount;
                                 RETURN v_Result;

                              END;
                              ELSE

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
                                         FROM CalypsoInvMOC_ChangeDetails 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )

                                                 --AND AccountID=@AccountID
                                                 AND AccountEntityID = v_AccountEntityID;
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
                                    DBMS_OUTPUT.PUT_LINE('Bbbbbb');
                                    SELECT MAX(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM CalypsoAccountLevelMOC_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )

                                              --AND AccountID=@AccountID
                                              AND AccountEntityID = v_AccountEntityID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifyBy ,
                                           DateModified ,
                                           ApprovedByFirstLevel ,
                                           DateApprovedFirstLevel 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifiedBy,
                                           v_DateModified,
                                           v_ApprovedByFirstLevel,
                                           v_DateApprovedFirstLevel
                                      FROM CalypsoAccountLevelMOC_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM RBL_MISDB_PROD.CalypsoAccountLevelMOC_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE RBL_MISDB_PROD.CalypsoAccountLevelMOC_Mod
                                       SET EffectiveToTimeKey = EffectiveFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )

                                      --AND AccountID=@AccountID
                                      AND AccountEntityID = v_AccountEntityID
                                      AND AuthorisationStatus = 'A';
                                    --AND EntityKey=@ExEntityKey
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.CalypsoAccountLevelMOC_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  AccountEntityID = v_AccountEntityID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM CalypsoInvMOC_ChangeDetails 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                         AND AccountEntityID = v_AccountID
                                         AND MOCType_Flag = 'ACCT' );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE CalypsoInvMOC_ChangeDetails
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND AccountEntityID = v_AccountEntityID
                                            AND MOCType_Flag = 'ACCT';

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('@DelStatus');
                                       DBMS_OUTPUT.PUT_LINE(v_DelStatus);
                                       DBMS_OUTPUT.PUT_LINE('@AuthMode');
                                       DBMS_OUTPUT.PUT_LINE(v_AuthMode);
                                       UPDATE CalypsoAccountLevelMOC_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  AccountEntityID = v_AccountEntityID
                                         AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                       ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;

                              END;
                              END IF;

                           END;
                           END IF;
                           --Sachin
                           IF v_DelStatus <> 'DP'
                             OR v_AuthMode = 'N' THEN
                            DECLARE
                              v_IsAvailable CHAR(1) := 'N';
                              v_IsSCD2 CHAR(1) := 'N';
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('Check');
                              v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                              UPDATE CalypsoAccountLevelMOC_Mod
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND AccountEntityID = v_AccountEntityID
                                AND AuthorisationStatus IN ( '1A' )
                              ;
                              UPDATE CalypsoInvMOC_ChangeDetails
                                 SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                     AuthorisationStatus = 'A',
                                     ApprovedBy = v_CrModApBy,
                                     DateApproved = SYSDATE
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND AccountEntityID = v_AccountEntityID
                                AND MOCType_Flag = 'ACCT';
                              DBMS_OUTPUT.PUT_LINE('CHECK1');
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM CalypsoInvMOC_ChangeDetails 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND AccountEntityID = v_AccountEntityID
                                                           AND MOCType_Flag = 'ACCT' );
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
                                                    FROM CalypsoInvMOC_ChangeDetails 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND AccountEntityID = v_AccountEntityID
                                                              AND MOCType_Flag = 'ACCT'
                                                              AND EffectiveFromTimeKey = v_TimeKey );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('BBBB');
                                    --PRINT '@UCIF_ID'
                                    --PRINT @UCIF_ID
                                    UPDATE CalypsoInvMOC_ChangeDetails
                                       SET PrincOutStd = CASE 
                                                              WHEN v_POS IS NULL THEN PrincOutStd
                                           ELSE v_POS
                                           ---,unserviedint=CASE WHEN @InterestReceivable IS NULL THEN unserviedint ELSE @InterestReceivable END      
                                            --,FLGFITL  =CASE WHEN @FITLFlagAlt_Key IS NULL THEN FLGFITL ELSE @FITLFlagAlt_Key END     
                                            --,DFVAmt=CASE WHEN @DFVAmount  IS NULL THEN DFVAmt ELSE @DFVAmount END     
                                            --,FlgRestructure=CASE WHEN @RestructureFlagAlt_Key IS NULL THEN FlgRestructure  ELSE @RestructureFlagAlt_Key END  
                                            --,RestructureDate=CASE WHEN @RestructureDate IS NULL THEN RestructureDate  ELSE @RestructureDate END    
                                            --,TwoAmount=CASE WHEN @TwoAmount IS NULL THEN TwoAmount ELSE @TwoAmount  END     
                                            --,TwoDate=CASE WHEN @TwoDate  IS NULL THEN TwoDate ELSE @TwoDate END      

                                              END,
                                           BookValue = CASE 
                                                            WHEN v_BookValue IS NULL THEN BookValue
                                           ELSE v_BookValue
                                              END,
                                           SMADate = CASE 
                                                          WHEN v_SMADate IS NULL THEN SMADate
                                           ELSE v_SMADate
                                              END,
                                           SMASubAssetClassValue = CASE 
                                                                        WHEN v_SMASubAssetClassValue IS NULL THEN SMASubAssetClassValue
                                           ELSE v_SMASubAssetClassValue
                                              END,
                                           AddlProvAbs = CASE 
                                                              WHEN v_AdditionalProvisionAbsolute IS NULL THEN AddlProvAbs
                                           ELSE v_AdditionalProvisionAbsolute
                                              END,
                                           MOC_Reason = v_MOCReason_1
                                           --,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
                                            --,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
                                            --,A.=@ScreenFlag        
                                            --,A.=@MOCSource         
                                            --,FlgMoc ='Y'  
                                           ,
                                           MOC_Date = v_MOC_Date
                                           --,MOC_ExpireDate=CASE WHEN @MOC_ExpireDate IS NULL THEN MOC_ExpireDate  ELSE @MOC_ExpireDate END 
                                           ,
                                           ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                           DateApprovedFirstLevel = v_DateApprovedFirstLevel
                                           --,ChangeType                 =CASE WHEN @ChangeTypeAlt_Key=1 THEN 'Auto' else 'Manual' end 
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
                                           --,AddlProvPer                =@AddlProvisionPer

                                              END,
                                           MOCType_Flag = 'ACCT',
                                           CustomerEntityID = v_CustomerEntityID
                                           --												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
                                           ,
                                           MOCProcessed = 'N'
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                      AND AccountEntityID = v_AccountEntityID
                                      AND MOCType_Flag = 'ACCT';

                                 END;

                                 --                                  UPDATE CalypsoInvMOC_ChangeDetails

                                 -- set FraudDate=CASE WHEN FlgFraud='N' THEN NULL ELSE @FraudDate END

                                 --     ,RestructureDate=CASE WHEN RestructureDate ='N'THEN NULL  ELSE @RestructureDate END

                                 --  ,TwoDate=CASE WHEN TwoDate='N' THEN NULL ELSE @TwoDate END  

                                 --  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 

                                 --AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  AccountEntityID=@AccountEntityID

                                 --AND MOCType_Flag='ACCT'
                                 ELSE

                                 BEGIN
                                    v_IsSCD2 := 'Y' ;
                                    UPDATE CalypsoDervMOC_ChangeDetails
                                       SET PrincOutStd = CASE 
                                                              WHEN v_POS IS NULL THEN PrincOutStd
                                           ELSE v_POS
                                           ---,unserviedint=CASE WHEN @InterestReceivable IS NULL THEN unserviedint ELSE @InterestReceivable END      
                                            --,FLGFITL  =CASE WHEN @FITLFlagAlt_Key IS NULL THEN FLGFITL ELSE @FITLFlagAlt_Key END     
                                            --,DFVAmt=CASE WHEN @DFVAmount  IS NULL THEN DFVAmt ELSE @DFVAmount END     
                                            --,FlgRestructure=CASE WHEN @RestructureFlagAlt_Key IS NULL THEN FlgRestructure  ELSE @RestructureFlagAlt_Key END  
                                            --,RestructureDate=CASE WHEN @RestructureDate IS NULL THEN RestructureDate  ELSE @RestructureDate END    
                                            --,TwoAmount=CASE WHEN @TwoAmount IS NULL THEN TwoAmount ELSE @TwoAmount  END     
                                            --,TwoDate=CASE WHEN @TwoDate  IS NULL THEN TwoDate ELSE @TwoDate END      

                                              END,
                                           BookValue = CASE 
                                                            WHEN v_BookValue IS NULL THEN BookValue
                                           ELSE v_BookValue
                                              END,
                                           SMADate = CASE 
                                                          WHEN v_SMADate IS NULL THEN SMADate
                                           ELSE v_SMADate
                                              END,
                                           SMASubAssetClassValue = CASE 
                                                                        WHEN v_SMASubAssetClassValue IS NULL THEN SMASubAssetClassValue
                                           ELSE v_SMASubAssetClassValue
                                              END,
                                           AddlProvAbs = CASE 
                                                              WHEN v_AdditionalProvisionAbsolute IS NULL THEN AddlProvAbs
                                           ELSE v_AdditionalProvisionAbsolute
                                              END,
                                           MOC_Reason = v_MOCReason_1
                                           --,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
                                            --,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
                                            --,A.=@ScreenFlag        
                                            --,A.=@MOCSource         
                                            --,FlgMoc ='Y'  
                                           ,
                                           MOC_Date = v_MOC_Date
                                           --,MOC_ExpireDate=CASE WHEN @MOC_ExpireDate IS NULL THEN MOC_ExpireDate  ELSE @MOC_ExpireDate END 
                                           ,
                                           ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                           DateApprovedFirstLevel = v_DateApprovedFirstLevel
                                           --,ChangeType                 =CASE WHEN @ChangeTypeAlt_Key=1 THEN 'Auto' else 'Manual' end 
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
                                           --,AddlProvPer                =@AddlProvisionPer

                                              END,
                                           MOCType_Flag = 'ACCT',
                                           CustomerEntityID = v_CustomerEntityID
                                           --												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
                                           ,
                                           MOCProcessed = 'N'
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                      AND AccountEntityID = v_AccountEntityID
                                      AND MOCType_Flag = 'ACCT';

                                 END;
                                 END IF;

                              END;
                              END IF;

                           END;
                           END IF;
                           IF v_IsAvailable = 'N'
                             OR v_IsSCD2 = 'Y' THEN
                            DECLARE
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('check11111');
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM CalypsoAccountLevelMOC_Mod a
                                                        JOIN InvestmentBasicDetail B   ON A.aCCOUNTID = B.iNVid
                                                        AND A.AccountEntityID = B.InvEntityId
                                                  WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                           AND A.EffectiveToTimeKey >= v_TimeKey )
                                                           AND ( B.EffectiveFromTimeKey <= v_TimeKey
                                                           AND B.EffectiveToTimeKey >= v_TimeKey )
                                                           AND AccountEntityID = v_AccountEntityID
                                                           AND aCCOUNTID = v_aCCOUNTID );
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    NULL;
                              END;

                              IF v_temp = 1 THEN

                              BEGIN
                                 INSERT INTO CalypsoInvMOC_ChangeDetails
                                   ( AccountEntityID, AddlProvAbs, FlgFraud, FraudDate, PrincOutStd, unserviedint, FLGFITL, DFVAmt, MOC_Reason, MOC_Source, MOC_Date, MOC_By, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MOCType_Flag, TwoAmount, TwoDate, BookValue, SMADate, SMASubAssetClassValue, CustomerEntityID, ApprovedByFirstLevel, DateApprovedFirstLevel, TwoFlag, MOCProcessed )
                                   VALUES ( v_AccountEntityID, v_AdditionalProvisionAbsolute, v_FraudAccountFlagAlt_Key, v_FraudDate, v_POS, v_InterestReceivable, v_FITLFlagAlt_Key, v_DFVAmount, v_MOCReason_1, v_MOCSource, v_MOC_Date, v_CrModApBy, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, 'ACCT', v_TwoAmount, v_TwoDate, v_BookValue, v_SMADate, v_SMASubAssetClassValue, v_CustomerEntityID, v_ApprovedByFirstLevel, v_DateApprovedFirstLevel, CASE 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 WHEN NVL(v_TwoDate, ' ') <> ' ' THEN 'Y'
                                 ELSE 'N'
                                    END, 'N' );
                                 DBMS_OUTPUT.PUT_LINE('check111');
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    UPDATE CalypsoInvMOC_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AUTHMODE = 'Y' THEN 'A'
                                           ELSE NULL
                                              END
                                     WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND AccountEntityID = v_AccountEntityID
                                      AND EffectiveFromTimekey < v_EffectiveFromTimeKey
                                      AND MOCType_Flag = 'ACCT';

                                 END;
                                 END IF;

                              END;
                              ELSE

                              BEGIN
                                 INSERT INTO CalypsoDervMOC_ChangeDetails
                                   ( AccountEntityID, AddlProvAbs, FlgFraud, FraudDate, PrincOutStd, unserviedint, FLGFITL, DFVAmt, MOC_Reason, MOC_Source, MOC_Date, MOC_By, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MOCType_Flag, TwoAmount, TwoDate, BookValue, SMADate, SMASubAssetClassValue, CustomerEntityID, ApprovedByFirstLevel, DateApprovedFirstLevel, TwoFlag, MOCProcessed )
                                   VALUES ( v_AccountEntityID, v_AdditionalProvisionAbsolute, v_FraudAccountFlagAlt_Key, v_FraudDate, v_POS, v_InterestReceivable, v_FITLFlagAlt_Key, v_DFVAmount, v_MOCReason_1, v_MOCSource, v_MOC_Date, v_CrModApBy, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, 'ACCT', v_TwoAmount, v_TwoDate, v_BookValue, v_SMADate, v_SMASubAssetClassValue, v_CustomerEntityID, v_ApprovedByFirstLevel, v_DateApprovedFirstLevel, CASE 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 WHEN NVL(v_TwoDate, ' ') <> ' ' THEN 'Y'
                                 ELSE 'N'
                                    END, 'N' );
                                 DBMS_OUTPUT.PUT_LINE('check111');
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    UPDATE CalypsoDervMOC_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AUTHMODE = 'Y' THEN 'A'
                                           ELSE NULL
                                              END
                                     WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND AccountEntityID = v_AccountEntityID
                                      AND EffectiveFromTimekey < v_EffectiveFromTimeKey
                                      AND MOCType_Flag = 'ACCT';

                                 END;
                                 END IF;

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
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<GLCodeMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('aaaaa');
            INSERT INTO CalypsoAccountLevelMOC_Mod
              ( AccountID, AccountEntityID, AdditionalProvisionAbsolute, FraudAccountFlag, FraudDate, RestructureFlag, RestructureDate, RePossessionFlag, RePossessionDate, InherentWeaknessFlag, InherentWeaknessDate, SARFAESIFlag, SARFAESIDate, POS, InterestReceivable, FITLFlag, DFVAmount, MOCReason, ScreenFlag, MOCSource, MOCDate
            --,MOCBy     
            , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, Changefield, MOC_TYPEFLAG, TwoAmount, TwoDate, BookValue, SMADate, SMASubAssetClassValue, FlgTwo )
              VALUES ( v_AccountID, v_AccountEntityID, v_AdditionalProvisionAbsolute, v_FraudAccountFlagAlt_Key, v_FraudDate, v_RestructureFlagAlt_Key, v_RestructureDate, v_RePossessionFlagAlt_Key, v_RePossessionDate, v_InherentWeaknessFlagAlt_Key, v_InherentWeaknessDate, v_SARFAESIFlagAlt_Key, v_SARFAESIDate, v_POS, v_InterestReceivable, v_FITLFlagAlt_Key, v_DFVAmount, v_MOCReason_1, 'S', v_MOCSource, v_MOC_Date, 
            -- ,@CreatedBy    
            v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, v_AccountNPAMOC_ChangeFields, 'ACCT', v_TwoAmount, v_TwoDate, v_BookValue, TO_DATE(v_SMADate,'dd/mm/yyyy'), v_SMASubAssetClassValue, CASE 
                                                                                                                                                                                                                                                                                                                                         WHEN NVL(v_TwoDate, ' ') <> ' ' THEN 'Y'
            ELSE 'N'
               END );
            --Sachin     
            DBMS_OUTPUT.PUT_LINE('Sachin');
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);

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
         IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

           AND v_AuthMode = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('log table');
            v_DateCreated := SYSDATE ;
            IF v_OperationFlag IN ( 16,17,18,20,21 )
             THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Authorised');
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ' ----BranchCode
                ,
                v_MenuID => v_MenuID,
                v_ReferenceID => v_AccountID -- ReferenceID ,
                ,
                v_CreatedBy => NULL,
                v_ApprovedBy => v_CrModApBy,
                iv_CreatedCheckedDt => v_DateCreated,
                v_Remark => v_Remark,
                v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('UNAuthorised');
               -- Declare
               v_CreatedBy := v_CrModApBy ;
               utils.var_number :=LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
               (v_BranchCode => ' ' ----BranchCode
                ,
                v_MenuID => v_MenuID,
                v_ReferenceID => v_AccountID -- ReferenceID ,
                ,
                v_CreatedBy => v_CrModApBy,
                v_ApprovedBy => NULL,
                iv_CreatedCheckedDt => v_DateCreated,
                v_Remark => v_Remark,
                v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                ,
                v_Flag => v_OperationFlag,
                v_AuthMode => v_AuthMode) ;

            END;
            END IF;

         END;
         END IF;
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM CustomerLevelMOC WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
         --               AND GLAlt_Key=@GLAlt_Key  
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
      DBMS_OUTPUT.PUT_LINE('ERRR............');
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACCOUNTLEVELINUP_15122023" TO "ADF_CDR_RBL_STGDB";
