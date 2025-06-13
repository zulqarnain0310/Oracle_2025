--------------------------------------------------------
--  DDL for Function CREATEPROJSTATUSPUI_INUP_08072023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" 
(
  v_CustomerId IN VARCHAR2 DEFAULT 0 ,
  v_UCIFID IN VARCHAR2 DEFAULT 0 ,
  v_AccountID IN VARCHAR2 DEFAULT 0 ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_ProjectCategoryAltKey IN NUMBER DEFAULT 0 ,
  v_ProjectSubCategoryAltKey IN NUMBER DEFAULT 0 ,
  v_ProjectAuthorityAltkey IN NUMBER DEFAULT 0 ,
  v_ProjectOwnershipAltKey IN NUMBER DEFAULT 0 ,
  v_OriginalDCCO IN VARCHAR2 DEFAULT ' ' ,
  v_OriginalProjectCost IN NUMBER DEFAULT 0 ,
  v_OriginalDebt IN NUMBER DEFAULT 0 ,
  v_Debt_EquityRatio IN NUMBER DEFAULT 0 ,
  iv_AccountEntityID IN NUMBER DEFAULT 0 ,
  v_CreateProjStatusPUI_changeFields IN VARCHAR2 DEFAULT NULL ,
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
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_ProjectSubCatDescription IN VARCHAR2
)
RETURN NUMBER
AS
   v_AccountEntityID NUMBER(10,0) := iv_AccountEntityID;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_AuthorisationStatus VARCHAR2(2) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   v_ApprovedByFirstLevel VARCHAR2(20) := NULL;
   v_DateApprovedFirstLevel DATE := NULL;
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   SELECT AccountEntityID 

     INTO v_AccountEntityID
     FROM AdvAcBasicDetail 
    WHERE  effectivefromTimekey <= v_Timekey
             AND Effectivetotimekey >= v_Timekey
             AND Customeracid = v_AccountID;
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'PUI' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   --SET @CollateralTypeAltKey = (Select ISNULL(Max(CollateralTypeAltKey),0)+1 from DimCollateralType)
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
                         FROM AdvAcPUIDetailMain 
                          WHERE  AccountID = v_AccountID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM AdvAcPUIDetailMain_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND AccountID = v_AccountID
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
            --SET @ProjectCategoryAltKey = (Select ISNULL(Max(ProjectCategoryAlt_Key),0)+1 from ( 
            --							Select ProjectCategoryAlt_Key from AdvAcPUIDetailMain
            --							UNION 
            --							Select ProjectCategoryAlt_Key from AdvAcPUIDetailMain_Mod)A)
            GOTO CollateralType_Insert;
            <<CollateralType_Insert_Add>>

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
                 FROM AdvAcPUIDetailMain 
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
                    FROM AdvAcPUIDetailMain_Mod 
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
                  UPDATE AdvAcPUIDetailMain
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE AdvAcPUIDetailMain_Mod
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
               GOTO CollateralType_Insert;
               <<CollateralType_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE AdvAcPUIDetailMain
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID;

               END;

               -------------------------
               ELSE
                  IF v_OperationFlag = 21
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE AdvAcPUIDetailMain_Mod
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
                                        FROM AdvAcPUIDetailMain 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountID = v_AccountID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE AdvAcPUIDetailMain
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AccountID = v_AccountID
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -----------------------------
                  ELSE
                     IF v_OperationFlag = 17
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE AdvAcPUIDetailMain_Mod
                           SET AuthorisationStatus = 'R'
                               --,ApprovedBy	 =@ApprovedBy
                                --,DateApproved=@DateApproved
                               ,
                               FirstLevelApprovedBy = v_ApprovedBy,
                               FirstLevelDateApproved = v_DateApproved,
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
                                           FROM AdvAcPUIDetailMain 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AccountID = v_AccountID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE AdvAcPUIDetailMain
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
                           UPDATE AdvAcPUIDetailMain_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND AccountID = v_AccountID;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              v_ApprovedByFirstLevel := v_CrModApBy ;
                              v_DateApprovedFirstLevel := SYSDATE ;
                              UPDATE AdvAcPUIDetailMain_Mod
                                 SET AuthorisationStatus = '1A'
                                     --,ApprovedBy=@ApprovedBy
                                      --,DateApproved=@DateApproved
                                     ,
                                     FirstLevelApprovedBy = v_ApprovedBy,
                                     FirstLevelDateApproved = v_DateApproved
                               WHERE  AccountID = v_AccountID
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
                                         FROM AdvAcPUIDetailMain 
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
                                    SELECT MAX(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM AdvAcPUIDetailMain_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AccountID = v_AccountID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifiedBy ,
                                           DateModified ,
                                           FirstLevelApprovedBy ,
                                           FirstLevelDateApproved 

                                      INTO v_DelStatus,
                                           v_CreatedBy,
                                           v_DateCreated,
                                           v_ModifiedBy,
                                           v_DateModified,
                                           v_ApprovedByFirstLevel,
                                           v_DateApprovedFirstLevel
                                      FROM AdvAcPUIDetailMain_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM AdvAcPUIDetailMain_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AccountID = v_AccountID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM AdvAcPUIDetailMain_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE AdvAcPUIDetailMain_Mod
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
                                       UPDATE AdvAcPUIDetailMain_Mod
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
                                                          FROM AdvAcPUIDetailMain 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AccountID = v_AccountID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE AdvAcPUIDetailMain
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
                                       UPDATE AdvAcPUIDetailMain_Mod
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
                                    v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM AdvAcPUIDetailMain 
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
                                       --SET @AuthorisationStatus='A'
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM AdvAcPUIDetailMain 
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
                                          UPDATE AdvAcPUIDetailMain
                                             SET CustomerID = v_CustomerID,
                                                 UCIFID = v_UCIFID,
                                                 AccountID = v_AccountID,
                                                 CustomerName = v_CustomerName,
                                                 ProjectCategoryAlt_Key = v_ProjectCategoryAltKey,
                                                 ProjectSubCategoryAlt_key = v_ProjectSubCategoryAltkey,
                                                 ProjectOwnerShipAlt_Key = v_ProjectOwnerShipAltKey,
                                                 ProjectAuthorityAlt_key = v_ProjectAuthorityAltkey,
                                                 OriginalDCCO = v_OriginalDCCO,
                                                 OriginalProjectCost = v_OriginalProjectCost,
                                                 OriginalDebt = v_OriginalDebt,
                                                 ProjectSubCatDescription = v_ProjectSubCatDescription
                                                 -- ,Debt_EquityRatio              =@Debt_EquityRatio
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
                                                    END,
                                                 FirstLevelApprovedBy = v_ApprovedByFirstLevel,
                                                 FirstLevelDateApproved = v_DateApprovedFirstLevel
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
                                       INSERT INTO AdvAcPUIDetailMain
                                         ( CustomerID, UCIFID, AccountID, AccountEntityID, CustomerName, ProjectCategoryAlt_Key, ProjectSubCategoryAlt_key, ProjectOwnerShipAlt_Key, ProjectAuthorityAlt_key, OriginalDCCO, OriginalProjectCost, OriginalDebt, ProjectSubCatDescription
                                       --  ,Debt_EquityRatio    --- handled in screen 
                                       , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, FirstLevelApprovedBy, FirstLevelDateApproved )
                                         ( SELECT v_CustomerID ,
                                                  v_UCIFID ,
                                                  v_AccountID ,
                                                  v_AccountEntityID ,
                                                  v_CustomerName ,
                                                  v_ProjectCategoryAltKey ,
                                                  v_ProjectSubCategoryAltkey ,
                                                  v_ProjectOwnerShipAltKey ,
                                                  v_ProjectAuthorityAltkey ,
                                                  v_OriginalDCCO ,
                                                  v_OriginalProjectCost ,
                                                  v_OriginalDebt ,
                                                  v_ProjectSubCatDescription ,
                                                  --,@Debt_EquityRatio
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
                                                     END col  ,
                                                  v_ApprovedByFirstLevel ,
                                                  v_DateApprovedFirstLevel 
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE AdvAcPUIDetailMain
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
                                    GOTO CollateralType_Insert;
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
         <<CollateralType_Insert>>
         IF v_ErrorHandle = 0 THEN
          DECLARE
            v_Parameter2 VARCHAR2(50);
            v_FinalParameter2 VARCHAR2(50);

         BEGIN
            INSERT INTO AdvAcPUIDetailMain_Mod
              ( CustomerID, UCIFID, AccountID, AccountEntityID, CustomerName, ProjectCategoryAlt_Key, ProjectSubCategoryAlt_key, ProjectOwnerShipAlt_Key, ProjectAuthorityAlt_key, OriginalDCCO, OriginalProjectCost, OriginalDebt, ProjectSubCatDescription
            -- ,Debt_EquityRatio
            , AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, ChangeFields )
              VALUES ( v_CustomerID, v_UCIFID, v_AccountID, v_AccountEntityID, v_CustomerName, v_ProjectCategoryAltKey, v_ProjectSubCategoryAltkey, v_ProjectOwnerShipAltKey, v_ProjectAuthorityAltkey, v_OriginalDCCO, v_OriginalProjectCost, v_OriginalDebt, v_ProjectSubCatDescription, 
            --,@Debt_EquityRatio
            v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               END, v_CreateProjStatusPUI_changeFields );
            SELECT utils.stuff(( SELECT DISTINCT ',' || ChangeFields 
                                 FROM AdvAcPUIDetailMain_Mod 
                                  WHERE  AccountID = v_AccountID
                                           AND NVL(AuthorisationStatus, 'A') IN ( 'A','MP' )
                                ), 1, 1, ' ') 

              INTO v_Parameter2
              FROM DUAL ;
            IF utils.object_id('tt_A_9') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_9 ';
            END IF;
            DELETE FROM tt_A_9;
            UTILS.IDENTITY_RESET('tt_A_9');

            INSERT INTO tt_A_9 ( 
            	SELECT DISTINCT VALUE 
            	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                             VALUE 
                      FROM ( SELECT VALUE 
                             FROM TABLE(STRING_SPLIT(v_Parameter2, ','))  ) A ) X );
            SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                 FROM tt_A_9  ), 1, 1, ' ') 

              INTO v_FinalParameter2
              FROM DUAL ;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, v_FinalParameter2
            FROM A ,AdvAcPUIDetailMain_Mod A 
             WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
              AND EffectiveToTimeKey >= v_tiMEKEY )
              AND AccountID = v_AccountID
              AND NVL(AuthorisationStatus, 'A') IN ( 'MP' )
            ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET a.ChangeFields = v_FinalParameter2;
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO CollateralType_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO CollateralType_Insert_Edit_Delete;

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
                v_ReferenceID => v_AccountID -- ReferenceID ,
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
                v_ReferenceID => v_AccountID -- ReferenceID ,
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
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimCollateralType WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --														AND CollateralTypeAltKey=@CollateralTypeAltKey
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
      RETURN -1;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CREATEPROJSTATUSPUI_INUP_08072023" TO "ADF_CDR_RBL_STGDB";
