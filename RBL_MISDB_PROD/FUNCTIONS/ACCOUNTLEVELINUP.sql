--------------------------------------------------------
--  DDL for Function ACCOUNTLEVELINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" 
(
  --Declare  
  v_AccountID IN VARCHAR2 DEFAULT ' ' ,
  v_POS IN NUMBER,
  v_InterestReceivable IN NUMBER,
  v_RestructureFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  iv_RestructureDate IN VARCHAR2 DEFAULT NULL ,
  v_FITLFlagAlt_Key IN VARCHAR2 DEFAULT ' ' ,
  v_DFVAmount IN NUMBER,
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
      v_AccountEntityID NUMBER(10,0);
      v_CustomerEntityID NUMBER(10,0);
      v_MOCReason_1 VARCHAR2(200);
      v_AppAvail CHAR;

   BEGIN
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
      SELECT AccountEntityID 

        INTO v_AccountEntityID
        FROM AdvAcBasicDetail 
       WHERE  CustomerACID = v_AccountID;
      SELECT CustomerEntityID 

        INTO v_CustomerEntityID
        FROM AdvAcBasicDetail 
       WHERE  CustomerACID = v_AccountID
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

             --EDIT AND DELETE  
            BEGIN
               DBMS_OUTPUT.PUT_LINE(4);
               v_CreatedBy := v_CrModApBy ;
               v_DateCreated := SYSDATE ;
               v_Modifiedby := v_CrModApBy ;
               v_DateModified := SYSDATE ;
               v_AuthorisationStatus := 'MP' ;
               --UPDATE NP,MP  STATUS   
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE AccountLevelMOC_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifyBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )

                    --AND AccountID=@AccountID  
                    AND AccountEntityID = v_AccountEntityID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;
                  UPDATE AccountLevelMOC_Mod
                     SET EffectiveToTimeKey = v_TimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID
                    AND AuthorisationStatus IN ( 'A' )
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
                                              FROM AccountLevelMOC_Mod 
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
                                                 FROM AccountLevelMOC_Mod 
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
                        UPDATE AccountLevelMOC_Mod
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
                                           FROM MOC_ChangeDetails 
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
                           UPDATE MOC_ChangeDetails
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
                                                 FROM AccountLevelMOC_Mod 
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
                        UPDATE AccountLevelMOC_Mod
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
                                           FROM MOC_ChangeDetails 
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
                           UPDATE MOC_ChangeDetails
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
                        UPDATE AccountLevelMOC_Mod
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
                                                       FROM AccountLevelMOC_Mod 
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
                              UPDATE AccountLevelMOC_Mod
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
                                                          FROM AccountLevelMOC_Mod 
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
                                                             FROM AccountLevelMOC_Mod 
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
                                            FROM MOC_ChangeDetails 
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
                                       DBMS_OUTPUT.PUT_LINE('B');
                                       DBMS_OUTPUT.PUT_LINE('C');
                                       SELECT MAX(EntityKey)  

                                         INTO v_ExEntityKey
                                         FROM AccountLevelMOC_Mod 
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
                                         FROM AccountLevelMOC_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       --SELECT @ExEntityKey= MIN(EntityKey) FROM DBO.AccountLevelMOC_MOd 
                                       --	WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
                                       --		AND AccountID=@AccountID
                                       --		AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM RBL_MISDB_PROD.AccountLevelMOC_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       DBMS_OUTPUT.PUT_LINE('SacExpire');
                                       DBMS_OUTPUT.PUT_LINE('@EffectiveFromTimeKey');
                                       DBMS_OUTPUT.PUT_LINE(v_EffectiveFromTimeKey);
                                       DBMS_OUTPUT.PUT_LINE('@Timekey');
                                       DBMS_OUTPUT.PUT_LINE(v_Timekey);
                                       --PRINT '@UCIF_ID'
                                       --PRINT @UCIF_ID
                                       UPDATE RBL_MISDB_PROD.AccountLevelMOC_Mod
                                          SET EffectiveToTimeKey = EffectiveFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )

                                         --AND AccountID=@AccountID
                                         AND AccountEntityID = v_AccountEntityID
                                         AND AuthorisationStatus = 'A';
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE RBL_MISDB_PROD.AccountLevelMOC_Mod
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
                                                             FROM MOC_ChangeDetails 
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
                                             UPDATE MOC_ChangeDetails
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
                                          UPDATE AccountLevelMOC_Mod
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
                                 --select * from dbo.AccountLevelMOC_MOd
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
                                    UPDATE MOC_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = 'A'
                                     WHERE  ( EffectiveFromTimeKey < v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND AccountEntityID = v_AccountEntityID
                                      AND MOCType_Flag = 'ACCT';
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM MOC_ChangeDetails 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND AccountEntityID = v_AccountEntityID
                                                                 AND MOCType_Flag = 'ACCT' );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN

                                    BEGIN
                                       v_IsAvailable := 'Y' ;

                                    END;
                                    END IF;
                                    --SET @AuthorisationStatus='A'
                                    IF v_IsAvailable = 'Y' THEN

                                    BEGIN
                                       --PRINT 'BBBB'
                                       --PRINT '@UCIF_ID'
                                       --PRINT @UCIF_ID
                                       UPDATE MOC_ChangeDetails
                                          SET PrincOutStd = CASE 
                                                                 WHEN v_POS IS NULL THEN PrincOutStd
                                              ELSE v_POS
                                                 END,
                                              unserviedint = CASE 
                                                                  WHEN v_InterestReceivable IS NULL THEN unserviedint
                                              ELSE v_InterestReceivable
                                                 END,
                                              FLGFITL = CASE 
                                                             WHEN v_FITLFlagAlt_Key IS NULL THEN FLGFITL
                                              ELSE v_FITLFlagAlt_Key
                                                 END,
                                              DFVAmt = CASE 
                                                            WHEN v_DFVAmount IS NULL THEN DFVAmt
                                              ELSE v_DFVAmount
                                              --,FlgRestructure=CASE WHEN @RestructureFlagAlt_Key IS NULL THEN FlgRestructure  ELSE @RestructureFlagAlt_Key END  
                                               --,RestructureDate=CASE WHEN @RestructureDate IS NULL THEN RestructureDate  ELSE @RestructureDate END    

                                                 END,
                                              TwoAmount = CASE 
                                                               WHEN v_TwoAmount IS NULL THEN TwoAmount
                                              ELSE v_TwoAmount
                                                 END,
                                              TwoDate = CASE 
                                                             WHEN v_TwoDate IS NULL THEN TwoDate
                                              ELSE v_TwoDate
                                                 END,
                                              AddlProvAbs = CASE 
                                                                 WHEN v_AdditionalProvisionAbsolute IS NULL THEN AddlProvAbs
                                              ELSE v_AdditionalProvisionAbsolute
                                                 END,
                                              MOC_Reason = v_MOCReason_1,
                                              FlgFraud = CASE 
                                                              WHEN v_FraudAccountFlagAlt_Key IS NULL THEN FlgFraud
                                              ELSE v_FraudAccountFlagAlt_Key
                                                 END,
                                              FraudDate = CASE 
                                                               WHEN v_FraudDate IS NULL THEN FraudDate
                                              ELSE v_FraudDate
                                              --,A.=@ScreenFlag        
                                               --,A.=@MOCSource         
                                               --,FlgMoc ='Y'  

                                                 END,
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
                                              CustomerEntityID = v_CustomerEntityID,
                                              TwoFlag = CASE 
                                                             WHEN NVL(v_TwoDate, ' ') <> ' ' THEN 'Y'
                                              ELSE 'N'
                                                 END
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                         AND AccountEntityID = v_AccountEntityID
                                         AND MOCType_Flag = 'ACCT';
                                       UPDATE MOC_ChangeDetails
                                          SET FraudDate = CASE 
                                                               WHEN FlgFraud = 'N' THEN NULL
                                              ELSE v_FraudDate
                                                 END,
                                              RestructureDate = CASE 
                                                                     WHEN RestructureDate = 'N' THEN NULL
                                              ELSE v_RestructureDate
                                                 END,
                                              TwoDate = CASE 
                                                             WHEN TwoDate = 'N' THEN NULL
                                              ELSE v_TwoDate
                                                 END
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                         AND AccountEntityID = v_AccountEntityID
                                         AND MOCType_Flag = 'ACCT';

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
                                    DBMS_OUTPUT.PUT_LINE('Insert into Main Table');
                                    DBMS_OUTPUT.PUT_LINE('@ExEntityKey');
                                    DBMS_OUTPUT.PUT_LINE(v_ExEntityKey);
                                    --PRINT '@DateCreated'
                                    --PRINT Convert(datetime,@DateCreated)
                                    --ALTER TABLE MOC_ChangeDetails
                                    --ADD MOC_TYPEFLAG Varchar(4) NULL
                                    INSERT INTO MOC_ChangeDetails
                                      ( AccountEntityID, AddlProvAbs, FlgFraud, FraudDate
                                    --,FlgRestructure       
                                     --,RestructureDate 
                                    , PrincOutStd, unserviedint, FLGFITL, DFVAmt, MOC_Reason
                                    --,ScreenFlag 
                                    , MOC_Source, MOC_Date
                                    --,MOCBy     
                                    , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
                                    --,Changefield  
                                    , MOCType_Flag, TwoAmount, TwoDate, CustomerEntityID, ApprovedByFirstLevel, DateApprovedFirstLevel, TwoFlag )
                                      VALUES ( v_AccountEntityID, v_AdditionalProvisionAbsolute, v_FraudAccountFlagAlt_Key, v_FraudDate, 
                                    --,@RestructureFlagAlt_Key

                                    --,@RestructureDate 
                                    v_POS, v_InterestReceivable, v_FITLFlagAlt_Key, v_DFVAmount, v_MOCReason_1, 
                                    --,'S'         
                                    v_MOCSource, v_MOC_Date, 
                                    -- ,@CreatedBy    
                                    v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, 
                                    --  ,@AccountNPAMOC_ChangeFields  
                                    'ACCT', v_TwoAmount, v_TwoDate, v_CustomerEntityID, v_ApprovedByFirstLevel, v_DateApprovedFirstLevel, CASE 
                                                                                                                                               WHEN NVL(v_TwoDate, ' ') <> ' ' THEN 'Y'
                                    ELSE 'N'
                                       END );

                                 END;
                                 END IF;
                                 --UPDATE A
                                 --SET A.UcifEntityID=B.UcifEntityID,
                                 --A.CustomerEntityId=B.CustomerEntityId
                                 --From MOC_ChangeDetails A
                                 --INNER JOIN PRO.CustomerCal_Hist B
                                 --ON A.UCIF_ID =B.UCIF_ID 
                                 --IF (@CollateralOwnerShipTypeAlt_Key=1)
                                 --	BEGIN 
                                 --		Update CollateralOtherOwner
                                 --		SET EffectiveToTimeKey=EffectiveFromTimeKey-1
                                 --		Where   AccountID=@AccountID  and EffectiveFromTimeKey=@EffectiveFromTimeKey and EffectiveToTimeKey=@EffectiveToTimeKey
                                 --	END
                                 -----------------Added on 13-03-2021
                                 ------------------------------------------------------
                                 ----------------------------------------------------------------------------------------------------
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    UPDATE MOC_ChangeDetails
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
                              ---------------------------------------------  
                              -- DECLARE @Parameter varchar(50)  
                              -- DECLARE @FinalParameter varchar(50)  
                              -- SET @Parameter = (select STUFF(( SELECT Distinct ',' +ChangeField   
                              --           from AccountLevelMOC_Mod where AccountID = @AccountID  
                              --           and ISNULL(AuthorisationStatus,'A') = 'A' for XML PATH('')),1,1,'') )  
                              --           If OBJECT_ID('#A') is not null  
                              --           drop table #A  
                              --select DISTINCT VALUE   
                              --into #A   
                              --from (  
                              --  SELECT  CHARINDEX('|',VALUE) CHRIDX,VALUE  
                              --  FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter,',')  
                              -- ) A  
                              -- )X  
                              -- SET @FinalParameter = (select STUFF(( SELECT Distinct ',' + Value from #A  for XML PATH('')),1,1,''))  
                              --       UPDATE  A  
                              --       set   a.ChangeField = @FinalParameter                                           
                              --       from  [PRO].AccountCal_Hist   A  
                              --       WHERE  (EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY)   
                              --       and   CustomerAcID = @AccountID  
                              ------------------------------------------------------------------------------  
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
               INSERT INTO AccountLevelMOC_Mod
                 ( AccountID, AccountEntityID, AdditionalProvisionAbsolute, FraudAccountFlag, FraudDate, RestructureFlag, RestructureDate, RePossessionFlag, RePossessionDate, InherentWeaknessFlag, InherentWeaknessDate, SARFAESIFlag, SARFAESIDate, POS, InterestReceivable, FITLFlag, DFVAmount, MOCReason, ScreenFlag, MOCSource, MOCDate
               --,MOCBy     
               , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, Changefield, MOC_TYPEFLAG, TwoAmount, TwoDate, FlgTwo )
                 VALUES ( v_AccountID, v_AccountEntityID, v_AdditionalProvisionAbsolute, v_FraudAccountFlagAlt_Key, v_FraudDate, v_RestructureFlagAlt_Key, v_RestructureDate, v_RePossessionFlagAlt_Key, v_RePossessionDate, v_InherentWeaknessFlagAlt_Key, v_InherentWeaknessDate, v_SARFAESIFlagAlt_Key, v_SARFAESIDate, v_POS, v_InterestReceivable, v_FITLFlagAlt_Key, v_DFVAmount, v_MOCReason_1, 'S', v_MOCSource, v_MOC_Date, 
               -- ,@CreatedBy    
               v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, v_DateModified, v_ApprovedBy, v_DateApproved, v_AccountNPAMOC_ChangeFields, 'ACCT', v_TwoAmount, v_TwoDate, CASE 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLEVELINUP" TO "ADF_CDR_RBL_STGDB";
