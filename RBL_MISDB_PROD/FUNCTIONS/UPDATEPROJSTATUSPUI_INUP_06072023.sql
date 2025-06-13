--------------------------------------------------------
--  DDL for Function UPDATEPROJSTATUSPUI_INUP_06072023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" 
(
  v_CustomerID IN VARCHAR2 DEFAULT 0 ,
  v_AccountID IN VARCHAR2 DEFAULT 0 ,
  v_ChangeinProjectScope IN VARCHAR2 DEFAULT ' ' ,
  v_FreshOriginalDCCO IN VARCHAR2 DEFAULT ' ' ,
  iv_RevisedDCCO IN VARCHAR2 DEFAULT ' ' ,
  v_CourtCaseArbitration IN VARCHAR2 DEFAULT ' ' ,
  v_ChangeinOwnerShip IN VARCHAR2 DEFAULT ' ' ,
  iv_CIOReferenceDate IN VARCHAR2 DEFAULT ' ' ,
  iv_CIODCCO IN VARCHAR2 DEFAULT ' ' ,
  v_CostOverRun IN VARCHAR2 DEFAULT ' ' ,
  v_RevisedProjectCost IN NUMBER DEFAULT 0 ,
  v_RevisedDebt IN NUMBER DEFAULT 0 ,
  v_RevisedDebtEquityRatio IN NUMBER DEFAULT 0 ,
  v_TakeOutFinance IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassSellerBookAltkey IN NUMBER DEFAULT 0 ,
  v_NPADateSellerBook IN VARCHAR2 DEFAULT ' ' ,
  v_Restructuring IN CHAR DEFAULT ' ' ,
  iv_AccountEntityID IN NUMBER DEFAULT 0 ,
  v_InitialExtenstion IN VARCHAR2 DEFAULT ' ' ,
  v_ExtnReason_BCP IN VARCHAR2 DEFAULT ' ' ,
  v_Npa_date IN VARCHAR2 DEFAULT ' ' ,
  v_Npa_Reason IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassAlt_Key IN NUMBER DEFAULT 0 ,
  v_ActualDCCO_Achieved IN CHAR DEFAULT ' ' ,
  iv_ActualDCCO_Date IN VARCHAR2 DEFAULT ' ' ,
  v_PUIUpdateProjectStatus_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  ---------D2k System Common Columns  --   
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
   v_AccountEntityID NUMBER(10,0) := iv_AccountEntityID;
   v_CIOReferenceDate VARCHAR2(10) := iv_CIOReferenceDate;
   v_CIODCCO VARCHAR2(10) := iv_CIODCCO;
   v_ActualDCCO_Date VARCHAR2(10) := iv_ActualDCCO_Date;
   v_RevisedDCCO VARCHAR2(10) := iv_RevisedDCCO;
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
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'PUI' ;
   -------------------------------------------------------------  
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   SELECT MAX(AccountEntityID)  

     INTO v_AccountEntityID
     FROM AdvAcBasicDetail 
    WHERE  effectivefromTimekey <= v_TimeKey
             AND Effectivetotimekey >= v_TimeKey
             AND Customeracid = v_AccountID;
   --SET @CollateralTypeAltKey = (Select ISNULL(Max(CollateralTypeAltKey),0)+1 from DimCollateralType)  
   DBMS_OUTPUT.PUT_LINE('A');
   v_CIOReferenceDate := CASE 
                              WHEN v_CIOReferenceDate IN ( ' ','01/01/1900' )
                               THEN NULL
   ELSE v_CIOReferenceDate
      END ;
   v_CIODCCO := CASE 
                     WHEN v_CIODCCO IN ( ' ','01/01/1900' )
                      THEN NULL
   ELSE v_CIODCCO
      END ;
   v_ActualDCCO_Date := CASE 
                             WHEN v_ActualDCCO_Date IN ( ' ','01/01/1900' )
                              THEN NULL
   ELSE v_ActualDCCO_Date
      END ;
   v_RevisedDCCO := CASE 
                         WHEN v_RevisedDCCO IN ( ' ','01/01/1900' )
                          THEN NULL
   ELSE v_RevisedDCCO
      END ;
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
                         FROM AdvAcPUIDetailSub 
                          WHERE  AccountID = v_AccountID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM AdvAcPUIDetailSub_mod 
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
            --SET @AccountEntityID = (Select ISNULL(Max(AccountEntityID),0)+1 from (   
            --       Select AccountEntityID from AdvAcPUIDetailSub  
            --       UNION   
            --       Select AccountEntityID from AdvAcPUIDetailSub_Mod)A)  
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
                 FROM AdvAcPUIDetailSub 
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
                    FROM AdvAcPUIDetailSub_mod 
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
                  UPDATE AdvAcPUIDetailSub
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountID = v_AccountID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS   
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE AdvAcPUIDetailSub_mod
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
                  UPDATE AdvAcPUIDetailSub
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

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE AdvAcPUIDetailSub_mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AccountID = v_AccountID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;

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
                        UPDATE AdvAcPUIDetailSub_mod
                           SET AuthorisationStatus = 'R'
                               --,ApprovedBy  =@ApprovedBy  
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
                                           FROM AdvAcPUIDetailSub 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AccountID = v_AccountID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE AdvAcPUIDetailSub
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
                           UPDATE AdvAcPUIDetailSub_mod
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
                              UPDATE AdvAcPUIDetailSub_mod
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
                                         FROM AdvAcPUIDetailSub 
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
                                      FROM AdvAcPUIDetailSub_mod 
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
                                      FROM AdvAcPUIDetailSub_mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM AdvAcPUIDetailSub_mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND AccountID = v_AccountID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM AdvAcPUIDetailSub_mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE AdvAcPUIDetailSub_mod
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
                                       UPDATE AdvAcPUIDetailSub_mod
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
                                                          FROM AdvAcPUIDetailSub 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AccountID = v_AccountID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE AdvAcPUIDetailSub
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
                                       UPDATE AdvAcPUIDetailSub_mod
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
                                                       FROM AdvAcPUIDetailSub 
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
                                                          FROM AdvAcPUIDetailSub 
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
                                          UPDATE AdvAcPUIDetailSub
                                             SET CustomerID = v_CustomerID,
                                                 AccountID = v_AccountID,
                                                 AccountEntityId = v_AccountEntityId,
                                                 ChangeinProjectScope = CASE 
                                                                             WHEN v_ChangeinProjectScope = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 FreshOriginalDCCO = v_FreshOriginalDCCO,
                                                 RevisedDCCO = v_RevisedDCCO,
                                                 CourtCaseArbitration = CASE 
                                                                             WHEN v_CourtCaseArbitration = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 ChangeinOwnerShip = CASE 
                                                                          WHEN v_ChangeinOwnerShip = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 CIOReferenceDate = v_CIOReferenceDate,
                                                 CIODCCO = v_CIODCCO,
                                                 CostOverRun = CASE 
                                                                    WHEN v_CostOverRun = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 RevisedProjectCost = v_RevisedProjectCost,
                                                 RevisedDebt = v_RevisedDebt
                                                 --,RevisedDebt_EquityRatio   =@RevisedDebtEquityRatio  
                                                 ,
                                                 TakeOutFinance = CASE 
                                                                       WHEN v_TakeOutFinance = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 AssetClassSellerBookAlt_key = v_AssetClassSellerBookAltkey,
                                                 NPADateSellerBook = CASE 
                                                                          WHEN v_NPADateSellerBook IN ( '1900-01-01',' ' )
                                                                           THEN NULL
                                                 ELSE v_NPADateSellerBook
                                                    END,
                                                 Restructuring = v_Restructuring,
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
                                                 InitialExtenstion = CASE 
                                                                          WHEN v_InitialExtenstion = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 ExtnReason_BCP = CASE 
                                                                       WHEN v_ExtnReason_BCP = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 Npa_date = v_Npa_date,
                                                 Npa_Reason = v_Npa_Reason,
                                                 AssetClassAlt_Key = v_AssetClassAlt_Key,
                                                 FirstLevelApprovedBy = v_ApprovedByFirstLevel,
                                                 FirstLevelDateApproved = v_DateApprovedFirstLevel,
                                                 ActualDCCO_Achieved = CASE 
                                                                            WHEN v_ActualDCCO_Achieved = 'Yes' THEN 'Y'
                                                 ELSE 'N'
                                                    END,
                                                 ActualDCCO_Date = v_ActualDCCO_Date
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
                                       INSERT INTO AdvAcPUIDetailSub
                                         ( CustomerID, AccountID, AccountEntityId, ChangeinProjectScope, FreshOriginalDCCO, RevisedDCCO, CourtCaseArbitration, ChangeinOwnerShip, CIOReferenceDate, CIODCCO, CostOverRun, RevisedProjectCost, RevisedDebt
                                       --,RevisedDebt_EquityRatio  
                                       , TakeOutFinance, AssetClassSellerBookAlt_key, NPADateSellerBook, Restructuring, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, InitialExtenstion, ExtnReason_BCP, Npa_date, Npa_Reason, AssetClassAlt_Key, FirstLevelApprovedBy, FirstLevelDateApproved, ActualDCCO_Achieved, ActualDCCO_Date )
                                         ( SELECT v_CustomerID ,
                                                  v_AccountID ,
                                                  v_AccountEntityId ,
                                                  --,@ChangeinProjectScope        
                                                  CASE 
                                                       WHEN v_ChangeinProjectScope = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  v_FreshOriginalDCCO ,
                                                  v_RevisedDCCO ,
                                                  --,@CourtCaseArbitration   
                                                  CASE 
                                                       WHEN v_CourtCaseArbitration = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  -- ,@ChangeinOwnerShip    
                                                  CASE 
                                                       WHEN v_ChangeinOwnerShip = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  v_CIOReferenceDate ,
                                                  v_CIODCCO ,
                                                  -- ,@CostOverRun    
                                                  CASE 
                                                       WHEN v_CostOverRun = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  v_RevisedProjectCost ,
                                                  v_RevisedDebt ,
                                                  --,@RevisedDebtEquityRatio   
                                                  -- ,@TakeOutFinance  
                                                  CASE 
                                                       WHEN v_TakeOutFinance = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  v_AssetClassSellerBookAltkey ,
                                                  CASE 
                                                       WHEN v_NPADateSellerBook IN ( '1900-01-01',' ' )
                                                        THEN NULL
                                                  ELSE v_NPADateSellerBook
                                                     END col  ,
                                                  v_Restructuring ,
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
                                                  --,@InitialExtenstion  
                                                  CASE 
                                                       WHEN v_InitialExtenstion = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  --,@ExtnReason_BCP  
                                                  CASE 
                                                       WHEN v_ExtnReason_BCP = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  v_Npa_date ,
                                                  v_Npa_Reason ,
                                                  v_AssetClassAlt_Key ,
                                                  v_ApprovedByFirstLevel ,
                                                  v_DateApprovedFirstLevel ,
                                                  CASE 
                                                       WHEN v_ActualDCCO_Achieved = 'Yes' THEN 'Y'
                                                  ELSE 'N'
                                                     END col  ,
                                                  v_ActualDCCO_Date 
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE AdvAcPUIDetailSub
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
            INSERT INTO AdvAcPUIDetailSub_mod
              ( CustomerID, AccountID, AccountEntityId, ChangeinProjectScope, FreshOriginalDCCO, RevisedDCCO, CourtCaseArbitration, ChangeinOwnerShip, CIOReferenceDate, CIODCCO, CostOverRun, RevisedProjectCost, RevisedDebt
            --,RevisedDebt_EquityRatio  
            , TakeOutFinance, AssetClassSellerBookAlt_key, NPADateSellerBook, Restructuring, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, InitialExtenstion, ExtnReason_BCP, Npa_date, Npa_Reason, AssetClassAlt_Key, ActualDCCO_Achieved, ActualDCCO_Date, ChangeFields )
              VALUES ( v_CustomerID, v_AccountID, v_AccountEntityId, 
            --,@ChangeinProjectScope   
            CASE 
                 WHEN v_ChangeinProjectScope = 'Yes' THEN 'Y'
            ELSE 'N'
               END, v_FreshOriginalDCCO, v_RevisedDCCO, 
            --,@CourtCaseArbitration   
            CASE 
                 WHEN v_CourtCaseArbitration = 'Yes' THEN 'Y'
            ELSE 'N'
               END, 
            --,@ChangeinOwnerShip    
            CASE 
                 WHEN v_ChangeinOwnerShip = 'Yes' THEN 'Y'
            ELSE 'N'
               END, v_CIOReferenceDate, v_CIODCCO, 
            -- ,@CostOverRun   
            CASE 
                 WHEN v_CostOverRun = 'Yes' THEN 'Y'
            ELSE 'N'
               END, v_RevisedProjectCost, v_RevisedDebt, 
            --,@RevisedDebtEquityRatio   

            --,@TakeOutFinance  
            CASE 
                 WHEN v_TakeOutFinance = 'Yes' THEN 'Y'
            ELSE 'N'
               END, v_AssetClassSellerBookAltkey, CASE 
                                                       WHEN v_NPADateSellerBook IN ( '1900-01-01',' ' )
                                                        THEN NULL
            ELSE v_NPADateSellerBook
               END, v_Restructuring, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), CASE 
                                                                                                                                                                 WHEN v_AuthMode = 'Y'
                                                                                                                                                                   OR v_IsAvailable = 'Y' THEN v_ModifiedBy
            ELSE NULL
               END, TO_DATE(CASE 
                                 WHEN v_AuthMode = 'Y'
                                   OR v_IsAvailable = 'Y' THEN v_DateModified
            ELSE NULL
               END,'dd/mm/yyyy'), CASE 
                                       WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
            ELSE NULL
               END, TO_DATE(CASE 
                                 WHEN v_AuthMode = 'Y' THEN v_DateApproved
            ELSE NULL
               END,'dd/mm/yyyy'), 
            --,@InitialExtenstion  
            CASE 
                 WHEN v_InitialExtenstion = 'Yes' THEN 'Y'
            ELSE 'N'
               END, 
            -- ,@ExtnReason_BCP  
            CASE 
                 WHEN v_ExtnReason_BCP = 'Yes' THEN 'Y'
            ELSE 'N'
               END, v_Npa_date, v_Npa_Reason, v_AssetClassAlt_Key, CASE 
                                                                        WHEN v_ActualDCCO_Achieved = 'Yes' THEN 'Y'
            ELSE 'N'
               END, v_ActualDCCO_Date, v_PUIUpdateProjectStatus_ChangeFields );
            SELECT utils.stuff(( SELECT DISTINCT ',' || ChangeFields 
                                 FROM AdvAcPUIDetailSub_mod 
                                  WHERE  AccountID = v_AccountID
                                           AND NVL(AuthorisationStatus, 'A') IN ( 'A','MP' )
                                ), 1, 1, ' ') 

              INTO v_Parameter2
              FROM DUAL ;
            IF utils.object_id('tt_A_62') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_62 ';
            END IF;
            DELETE FROM tt_A_62;
            UTILS.IDENTITY_RESET('tt_A_62');

            INSERT INTO tt_A_62 ( 
            	SELECT DISTINCT VALUE 
            	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                             VALUE 
                      FROM ( SELECT VALUE 
                             FROM TABLE(STRING_SPLIT(v_Parameter2, ','))  ) A ) X );
            SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                 FROM tt_A_62  ), 1, 1, ' ') 

              INTO v_FinalParameter2
              FROM DUAL ;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, v_FinalParameter2
            FROM A ,AdvAcPUIDetailSub_mod A 
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
         -------------------  
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimCollateralType WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
         --              AND CollateralTypeAltKey=@CollateralTypeAltKey  
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UPDATEPROJSTATUSPUI_INUP_06072023" TO "ADF_CDR_RBL_STGDB";
