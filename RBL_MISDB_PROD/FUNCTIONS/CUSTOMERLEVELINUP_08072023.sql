--------------------------------------------------------
--  DDL for Function CUSTOMERLEVELINUP_08072023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" 
--USE [USFB_ENPADB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CustomerLevelInUp]    Script Date: 18-11-2021 13:33:01 ******/
 --DROP PROCEDURE [dbo].[CustomerLevelInUp]
 --GO
 --/****** Object:  StoredProcedure [dbo].[CustomerLevelInUp]    Script Date: 18-11-2021 13:33:01 ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

(
  --Declare
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassAlt_Key IN NUMBER DEFAULT 0 ,
  iv_NPADate IN VARCHAR2 DEFAULT NULL ,
  iv_SecurityValue IN VARCHAR2 DEFAULT ' ' ,
  v_AdditionalProvision IN NUMBER DEFAULT ' ' ,
  --,@FraudAccountFlagAlt_Key	Int=0--,@FraudDate					Date
  v_MocTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_MOCReason IN VARCHAR2 DEFAULT ' ' ,
  v_MOCSourceAltkey IN NUMBER DEFAULT 0 ,
  v_ScreenFlag IN VARCHAR2 DEFAULT 'S' ,
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
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_CustomerNPAMOC_ChangeFields IN VARCHAR2 DEFAULT ' ' 
)
RETURN NUMBER
AS
   v_NPADate VARCHAR2(20) := iv_NPADate;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_SecurityValue VARCHAR2(50) := iv_SecurityValue;
   v_Parameter1 VARCHAR2(4000) := ( SELECT 'CustomerID|' || NVL(v_CustomerID, ' ') || '}' || 'CustomerName|' || NVL(v_CustomerName, ' ') || '}' || 'AssetClassAlt_Key_Pos|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_AssetClassAlt_Key, ' '),30) || '}' || 'NPADate_Pos|' || NVL(v_NPADate, ' ') || '}' || 'SecurityValue_Pos|' || NVL(v_SecurityValue, ' ') || '}' || 'AdditionalProvision_Pos|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_AdditionalProvision, '0'),30) || '} ' || 'MOCTypeAlt_Key|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_MocTypeAlt_Key, ' '),30) || '}' || 'MOCReason|' || NVL(v_MOCReason, ' ') || '}' || 'MOCSourceAltKey|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_MOCSourceAltkey, ' '),30) 
     FROM DUAL  );
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
   v_ApprovedByFirstLevel VARCHAR2(20) := NULL;
   v_DateApprovedFirstLevel DATE := NULL;
   v_MOCType_Flag VARCHAR2(4) := NULL;
   v_MOC_DATE VARCHAR2(20) := NULL;
   v_CustomerEntityID NUMBER(10,0);
   v_MocTypeDesc VARCHAR2(20);
   v_MOCReason_1 VARCHAR2(200);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --DECLARE		@Result					INT				=0 
   utils.var_number :=SecurityCheckDataValidation(126,
                                                  v_Parameter1,
                                                  v_Result) ;
   IF v_Result = -1 THEN
    RETURN -1;
   END IF;
   v_NPADate := CASE 
                     WHEN ( v_NPADate = ' '
                       OR v_NPADate = '01/01/1900' ) THEN NULL
   ELSE v_NPADate
      END ;
   v_ScreenName := 'CustomerLevel' ;
   -------------------------------------------------------------
   --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
   -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   --SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
   SELECT UTILS.CONVERT_TO_VARCHAR2(ExtDate,200) 

     INTO v_MOC_Date
     FROM SysDataMatrix 
    WHERE  Timekey = v_TimeKey;
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   SELECT CustomerEntityID 

     INTO v_CustomerEntityID
     FROM CustomerBasicDetail 
    WHERE  CustomerId = v_CustomerId
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   v_SecurityValue := CASE 
                           WHEN v_SecurityValue = ' ' THEN NULL
   ELSE v_SecurityValue
      END ;
   --select @MocTypeDesc =MOCTypeName from DimMOCType where MOCTypeAlt_Key=@MocTypeAlt_Key
   -- AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
   SELECT ParameterName 

     INTO v_MocTypeDesc
     FROM DimParameter 
    WHERE  Dimparametername = 'MocType'
             AND ParameterAlt_Key = v_MocTypeAlt_Key
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
         IF v_OperationFlag = 1
           AND v_AuthMode = 'Y' THEN

          -- ADD
         BEGIN
            DBMS_OUTPUT.PUT_LINE('Add');
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_AuthorisationStatus := 'NP' ;
            GOTO MOCcustomerDateMaster_Insert;
            <<MOCcustomerDateMaster_Insert_Add>>

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
                 FROM MOC_ChangeDetails 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND CustomerEntityID = v_CustomerEntityID
                         AND MOCType_Flag = 'CUST';
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM CustomerLevelMOC_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND CustomerEntityID = v_CustomerEntityID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE MOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerEntityID = v_CustomerEntityID
                    AND MOCType_Flag = 'CUST';

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE CustomerLevelMOC_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_TimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerEntityID = v_CustomerEntityID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;
                  UPDATE CustomerLevelMOC_Mod
                     SET EffectiveToTimeKey = v_TimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerEntityID = v_CustomerEntityID
                    AND AuthorisationStatus IN ( 'A' )
                  ;

               END;
               END IF;
               GOTO MOCcustomerDateMaster_Insert;
               <<MOCcustomerDateMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE CustomerLevelMOC_Mod
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND CustomerEntityID = v_CustomerEntityID;

               END;

               -------------------------------------------------------

               --start 20042021
               ELSE
                  IF v_OperationFlag = 21
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE CustomerLevelMOC_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND CustomerEntityID = v_CustomerEntityID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM MOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND CustomerEntityID = v_CustomerEntityID
                                                  AND MOCType_Flag = 'CUST' );
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
                          AND CustomerEntityID = v_CustomerEntityID
                          AND MOCType_Flag = 'CUST'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

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
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE CustomerLevelMOC_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedByFirstLevel = v_ApprovedBy,
                               DateApprovedFirstLevel = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND CustomerEntityID = v_CustomerEntityID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                        DBMS_OUTPUT.PUT_LINE('Sunil');
                        --		DECLARE @EntityKey as Int 
                        --SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                        --					 FROM MOCInitializeDetails_Mod 
                        --						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                        --							AND MOCInitializeDate=@MOCInitializeDate And ISNULL(AuthorisationStatus,'A')='R'
                        --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                        --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                        --------------------------------
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM MOC_ChangeDetails 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND CustomerEntityID = v_CustomerEntityID
                                                     AND MOCType_Flag = 'CUST' );
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
                             AND CustomerEntityID = v_CustomerEntityID
                             AND MOCType_Flag = 'CUST'
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
                           UPDATE CustomerLevelMOC_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND CustomerEntityID = v_CustomerEntityID;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE CustomerLevelMOC_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedByFirstLevel = v_ApprovedBy,
                                     DateApprovedFirstLevel = v_DateApproved
                               WHERE  CustomerEntityID = v_CustomerEntityID
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
                                         FROM MOC_ChangeDetails 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND CustomerEntityID = v_CustomerEntityID;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 ---set parameters and UPDATE mod table in case maker checker enabled
                                 IF v_AuthMode = 'Y' THEN
                                  DECLARE
                                    v_DelStatus -------------20042021
                                     CHAR(2) := ' ';
                                    v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                                    v_CurEntityKey NUMBER(10,0) := 0;

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('B');
                                    DBMS_OUTPUT.PUT_LINE('C');
                                    SELECT MAX(Entity_Key)  

                                      INTO v_ExEntityKey
                                      FROM CustomerLevelMOC_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND CustomerEntityID = v_CustomerEntityID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifiedBy ,
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
                                      FROM CustomerLevelMOC_Mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    --SELECT @ExEntityKey= MIN(Entity_Key) FROM CustomerLevelMOC_Mod 
                                    --	WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
                                    --		AND  CustomerEntityID =@CustomerEntityID
                                    --		AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM CustomerLevelMOC_Mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    UPDATE CustomerLevelMOC_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND CustomerEntityID = v_CustomerEntityID
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE CustomerLevelMOC_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  CustomerEntityID = v_CustomerEntityID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM MOC_ChangeDetails 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND CustomerEntityID = v_CustomerEntityID
                                                                    AND MOCType_Flag = 'CUST' );
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
                                            AND CustomerEntityID = v_CustomerEntityID
                                            AND MOCType_Flag = 'CUST';

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE CustomerLevelMOC_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  CustomerEntityID = v_CustomerEntityID
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
                                    v_AuthorisationStatus := 'A' ;
                                    UPDATE MOC_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = 'A'
                                     WHERE  ( EffectiveFromTimeKey < v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND CustomerEntityID = v_CustomerEntityID
                                      AND MOCType_Flag = 'CUST';
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM MOC_ChangeDetails 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND CustomerEntityID = v_CustomerEntityID
                                                                 AND MOCType_Flag = 'CUST' );
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
                                       UPDATE MOC_ChangeDetails
                                          SET MOCType_Flag = 'CUST',
                                              CustomerEntityID = v_CustomerEntityID,
                                              AssetClassAlt_Key = v_AssetClassAlt_Key,
                                              NPA_Date = v_NPADate,
                                              CurntQtrRv = v_SecurityValue
                                              --, MOC_ExpireDate		 =@MOC_ExpireDate
                                              ,
                                              MOC_Reason = v_MOCReason_1,
                                              MOCTYPE = v_MocTypeDesc,
                                              MOC_Date = v_MOC_DATE
                                              --, AdditionalProvision    =@AdditionalProvision
                                              ,
                                              AddlProvPer = v_AdditionalProvision
                                              -- MOC_By					 =
                                              ,
                                              MOC_Source = v_MOCSourceAltkey,
                                              AuthorisationStatus = v_AuthorisationStatus,
                                              EffectiveFromTimeKey = v_Timekey,
                                              EffectiveToTimeKey = 49999,
                                              CreatedBy = v_CrModApBy,
                                              DateCreated = v_DateCreated,
                                              ModifiedBy = v_ModifiedBy,
                                              DateModified = v_DateModified,
                                              ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                              DateApprovedFirstLevel = v_DateApprovedFirstLevel,
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                         AND CustomerEntityID = v_CustomerEntityID
                                         AND MOCType_Flag = 'CUST';

                                    END;
                                    ELSE

                                    BEGIN
                                       v_IsSCD2 := 'Y' ;

                                    END;
                                    END IF;
                                    IF v_IsAvailable = 'N'
                                      OR v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       INSERT INTO MOC_ChangeDetails
                                         ( MOCType_Flag, CustomerEntityID, AssetClassAlt_Key, NPA_Date, CurntQtrRv
                                       --,AdditionalProvision
                                       , AddlProvPer
                                       --,MOC_ExpireDate
                                       , MOC_Reason, MOC_Date, MOC_Source, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedByFirstLevel, DateApprovedFirstLevel, ApprovedBy, DateApproved
                                       --,ScreenFlag
                                       , MOCTYPE )
                                         ( SELECT 'CUST' ,
                                                  v_CustomerEntityID ,
                                                  v_AssetClassAlt_Key ,
                                                  v_NPADate ,
                                                  v_SecurityValue ,
                                                  v_AdditionalProvision ,
                                                  --,@MOC_ExpireDate
                                                  v_MOCReason_1 ,
                                                  v_MOC_DATE ,
                                                  v_MOCSourceAltkey ,
                                                  'A' ,
                                                  v_TimeKey ,
                                                  49999 ,
                                                  v_CreatedBy ,
                                                  v_DateCreated ,
                                                  v_ModifiedBy ,
                                                  v_DateModified ,
                                                  v_ApprovedByFirstLevel ,
                                                  v_DateApprovedFirstLevel ,
                                                  v_CrModApBy ,
                                                  SYSDATE ,
                                                  --,'S'
                                                  --,@MocTypeAlt_Key
                                                  v_MocTypeDesc 
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE MOC_ChangeDetails
                                          SET
                                          --EffectiveToTimeKey=@EffectiveFromTimeKey-1,
                                        AuthorisationStatus = CASE 
                                                                   WHEN v_AUTHMODE = 'Y' THEN 'A'
                                        ELSE NULL
                                           END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND CustomerEntityID = v_CustomerEntityID
                                         AND MOCType_Flag = 'CUST'
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO MOCcustomerDateMaster_Insert;
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
         <<MOCcustomerDateMaster_Insert>>
         IF v_ErrorHandle = 0 THEN
          DECLARE
            v_Parameter3 VARCHAR2(50);
            v_FinalParameter3 VARCHAR2(50);

         BEGIN
            INSERT INTO CustomerLevelMOC_Mod
              ( CustomerID, CustomerEntityID, CustomerName, AssetClassAlt_Key, NPADate, SecurityValue, AdditionalProvision, MOCReason, MOCSourceAltkey, MOCDate, MOCType, ScreenFlag, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, ChangeField
            --,MOC_ExpireDate
            , MOCType_Flag )
              VALUES ( v_CustomerID, v_CustomerEntityID, v_CustomerName, v_AssetClassAlt_Key, v_NPADate, v_SecurityValue, v_AdditionalProvision, v_MOCReason_1, v_MOCSourceAltkey, v_MOC_DATE, 
            -- ,@MocTypeAlt_Key
            v_MocTypeDesc, v_ScreenFlag, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, TO_DATE(v_DateModified,'dd/mm/yyyy'), v_ApprovedBy, TO_DATE(v_DateApproved,'dd/mm/yyyy'), v_CustomerNPAMOC_ChangeFields, 
            --,@MOC_ExpireDate
            'CUST' );
            SELECT utils.stuff(( SELECT ',' || ChangeField 
                                 FROM CustomerLevelMOC_Mod 
                                  WHERE  CustomerEntityID = v_CustomerEntityID
                                           AND NVL(AuthorisationStatus, 'A') IN ( 'A','MP' )
                                ), 1, 1, ' ') 

              INTO v_Parameter3
              FROM DUAL ;
            IF utils.object_id('tt_AA_11') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AA_11 ';
            END IF;
            DELETE FROM tt_AA_11;
            UTILS.IDENTITY_RESET('tt_AA_11');

            INSERT INTO tt_AA_11 ( 
            	SELECT DISTINCT VALUE 
            	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                             VALUE 
                      FROM ( SELECT VALUE 
                             FROM TABLE(STRING_SPLIT(v_Parameter3, ','))  ) A ) X );
            SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                 FROM tt_AA_11  ), 1, 1, ' ') 

              INTO v_FinalParameter3
              FROM DUAL ;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, v_FinalParameter3
            FROM A ,CustomerLevelMOC_Mod A 
             WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
              AND EffectiveToTimeKey >= v_tiMEKEY )
              AND CustomerEntityID = v_CustomerEntityID) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET a.ChangeField = v_FinalParameter3;
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO MOCcustomerDateMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO MOCcustomerDateMaster_Insert_Edit_Delete;

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
                v_ReferenceID => v_CustomerID -- ReferenceID ,
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
                v_ReferenceID => v_CustomerID -- ReferenceID ,
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMERLEVELINUP_08072023" TO "ADF_CDR_RBL_STGDB";
