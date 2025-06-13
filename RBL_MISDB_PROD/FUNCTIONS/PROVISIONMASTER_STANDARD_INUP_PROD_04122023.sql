--------------------------------------------------------
--  DDL for Function PROVISIONMASTER_STANDARD_INUP_PROD_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" 
(
  iv_Code IN NUMBER DEFAULT 0 ,
  v_BankCategoryID IN NUMBER DEFAULT 0 ,
  v_AssetCategory IN VARCHAR2 DEFAULT ' ' ,
  v_CategoryTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_Provision_RBI_Norms IN NUMBER DEFAULT ' ' ,--Sachin Previous Decimal(5,2)
  v_AdditionalBanksProvision IN NUMBER DEFAULT ' ' ,
  v_Additional_Provision_Bank_Norms_if_any IN NUMBER DEFAULT ' ' ,
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
   v_Code NUMBER(10,0) := iv_Code;
   v_AuthorisationStatus VARCHAR2(2) := NULL;
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

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'ConstitutionMaster' ;
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
                         FROM DimProvision_SegStd 
                          WHERE  BankCategoryID = v_BankCategoryID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM DimProvision_SegStd_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND BankCategoryID = v_BankCategoryID
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

           INTO v_Code
           FROM ( SELECT ProvisionAlt_Key 
                  FROM DimProvision_SegStd 
                  UNION 
                  SELECT ProvisionAlt_Key 
                  FROM DimProvision_SegStd_Mod  ) A;

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
            --SET @Code = (Select ISNULL(Max(ProvisionAlt_Key),0)+1 from 
            --						(Select ProvisionAlt_Key from DimProvision_SegStd
            --						 UNION 
            --						 Select ProvisionAlt_Key from DimProvision_SegStd_Mod
            --						)A)
            GOTO ConstitutionMaster_Insert;
            <<ConstitutionMaster_Insert_Add>>

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
                 FROM DimProvision_SegStd 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )

                         --AND ProvisionAlt_Key =@Code
                         AND BankCategoryID = v_BankCategoryID;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM DimProvision_SegStd_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )

                            --AND ProvisionAlt_Key =@Code
                            AND BankCategoryID = v_BankCategoryID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE DimProvision_SegStd
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )

                    --AND ProvisionAlt_Key =@Code
                    AND BankCategoryID = v_BankCategoryID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE DimProvision_SegStd_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )

                    --AND ProvisionAlt_Key =@Code
                    AND BankCategoryID = v_BankCategoryID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO ConstitutionMaster_Insert;
               <<ConstitutionMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE DimProvision_SegStd
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND BankCategoryID = v_BankCategoryID;-----ProvisionAlt_Key=@Code

               END;
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE DimProvision_SegStd_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )

                       --AND ProvisionAlt_Key =@Code
                       AND BankCategoryID = v_BankCategoryID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM DimProvision_SegStd 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND ProvisionAlt_Key = v_Code );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE DimProvision_SegStd
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )

                          --AND ProvisionAlt_Key =@Code
                          AND BankCategoryID = v_BankCategoryID
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -----------------------------Two Level Auth. Chanegs--------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE DimProvision_SegStd_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )

                          --AND ProvisionAlt_Key =@Code
                          AND BankCategoryID = v_BankCategoryID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM DimProvision_SegStd 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND ProvisionAlt_Key = v_Code );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE DimProvision_SegStd
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )

                             --AND ProvisionAlt_Key =@Code
                             AND BankCategoryID = v_BankCategoryID
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     ------------------------------------------
                     ELSE
                        IF v_OperationFlag = 18 THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE(18);
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE DimProvision_SegStd_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )


                             --AND ProvisionAlt_Key=@Code
                             AND BankCategoryID = v_BankCategoryID;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE DimProvision_SegStd_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  BankCategoryID = v_BankCategoryID
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
                                         FROM DimProvision_SegStd 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )

                                                 --AND ProvisionAlt_Key=@Code
                                                 AND BankCategoryID = v_BankCategoryID;
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
                                      FROM DimProvision_SegStd_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )

                                              --AND ProvisionAlt_Key=@Code
                                              AND BankCategoryID = v_BankCategoryID
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
                                      FROM DimProvision_SegStd_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM DimProvision_SegStd_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )

                                              --AND ProvisionAlt_Key=@Code
                                              AND BankCategoryID = v_BankCategoryID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM DimProvision_SegStd_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE DimProvision_SegStd_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )

                                      --AND ProvisionAlt_Key=@Code
                                      AND BankCategoryID = v_BankCategoryID
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE DimProvision_SegStd_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ProvisionAlt_Key = v_Code
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM DimProvision_SegStd 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )

                                                                    --AND ProvisionAlt_Key=@Code
                                                                    AND BankCategoryID = v_BankCategoryID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE DimProvision_SegStd
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )

                                            --AND ProvisionAlt_Key=@Code
                                            AND BankCategoryID = v_BankCategoryID;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE DimProvision_SegStd_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  ProvisionAlt_Key = v_Code
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
                                                       FROM DimProvision_SegStd 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )

                                                                 --AND ProvisionAlt_Key=@Code
                                                                 AND BankCategoryID = v_BankCategoryID );
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
                                                          FROM DimProvision_SegStd 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey --AND ProvisionAlt_Key=@Code

                                                                    AND BankCategoryID = v_BankCategoryID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE DimProvision_SegStd
                                             SET ProvisionAlt_Key = v_Code,
                                                 BankCategoryID = v_BankCategoryID,
                                                 ProvisionName = v_AssetCategory,
                                                 CategoryTypeAlt_Key = v_CategoryTypeAlt_Key,
                                                 ProvisionSecured = v_Provision_RBI_Norms,
                                                 ProvisionunSecured = v_Provision_RBI_Norms,
                                                 RBIProvisionSecured = v_Provision_RBI_Norms,
                                                 RBIProvisionUnSecured = v_Provision_RBI_Norms,
                                                 AdditionalBanksProvision = v_AdditionalBanksProvision,
                                                 AdditionalprovisionRBINORMS = v_Additional_Provision_Bank_Norms_if_any,
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
                                            AND BankCategoryID = v_BankCategoryID;---ProvisionAlt_Key=@Code

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
                                       --PRINT 123
                                       --PRINT @IsSCD2
                                       --PRINT @IsAvailable
                                       INSERT INTO DimProvision_SegStd
                                         ( ProvisionAlt_Key, BankCategoryID, ProvisionName, CategoryTypeAlt_Key, ProvisionSecured, ProvisionunSecured, RBIProvisionSecured, RBIProvisionUnSecured, AdditionalBanksProvision, AdditionalprovisionRBINORMS, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                         ( SELECT v_Code ,
                                                  v_BankCategoryID ,
                                                  v_AssetCategory ,
                                                  v_CategoryTypeAlt_Key ,
                                                  v_Provision_RBI_Norms ,
                                                  v_Provision_RBI_Norms ,
                                                  v_Provision_RBI_Norms ,
                                                  v_Provision_RBI_Norms ,
                                                  v_AdditionalBanksProvision ,
                                                  v_Additional_Provision_Bank_Norms_if_any ,
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
                                    ---------------------------Added On 19032021     ------------
                                    --Declare @BusinessRule_Alt_key		INT
                                    --,@CatAlt_key				INT
                                    --,@UniqueID					INT
                                    --,@Businesscolalt_key		INT	
                                    --,@Scope						INT
                                    --,@Businesscolvalues1		VARCHAR(MAX)	
                                    --,@Businesscolvalues			VARCHAR(MAX)
                                    --,@UserId					VARCHAR(50)
                                    ----,@OperationFlag				INT
                                    --,@D2kTimestamp				INT	=0
                                    ----,@Result					INT OUTPUT
                                    ----,@AuthMode					CHAR(1)			= 'Y'
                                    ----,@CrModApBy					VARCHAR(20)		=''
                                    --Exec [dbo].[BusinessRuleSetupInUp] @BusinessRule_Alt_key=@BusinessRule_Alt_key, @CatAlt_key=@CatAlt_key,@UniqueID=@UniqueID,@Businesscolalt_key=@Businesscolalt_key,@Scope=@Scope,@Businesscolvalues1=@Businesscolvalues1,
                                    --@Businesscolvalues=@Businesscolvalues,@UserId=@UserId,@OperationFlag=@OperationFlag,@D2kTimestamp=@D2kTimestamp,@Result=@Result,@AuthMode=@AuthMode,@CrModApBy=@CrModApBy
                                    --Declare @Expression varchar(max)=''
                                    --,@FinalExpression VARCHAR(MAX)=''
                                    ----,@D2kTimestamp				INT	OUTPUT
                                    ----,@Result					INT OUTPUT
                                    ----,@UserId					VARCHAR(50)
                                    ----,@OperationFlag				INT
                                    --Exec [dbo].[Provision_Update]  @ProvisionAlt_Key=@CatAlt_key,@Expression=@Expression,@FinalExpression=@FinalExpression,
                                    --@UserId=@UserId,@OperationFlag=@OperationFlag,@D2kTimestamp=@D2kTimestamp,@Result=@Result
                                    ----------------------------------------------------------------------------------------------									
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE DimProvision_SegStd
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND BankCategoryID = v_BankCategoryID ---ProvisionAlt_Key=@Code

                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO ConstitutionMaster_Insert;
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
         <<ConstitutionMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO DimProvision_SegStd_Mod
              ( ProvisionAlt_Key, BankCategoryID, ProvisionName, CategoryTypeAlt_Key, ProvisionSecured, ProvisionunSecured, RBIProvisionSecured, RBIProvisionUnSecured, AdditionalBanksProvision, AdditionalprovisionRBINORMS, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
              VALUES ( v_Code, v_BankCategoryID, v_AssetCategory, v_CategoryTypeAlt_Key, v_Provision_RBI_Norms, v_Provision_RBI_Norms, v_Provision_RBI_Norms, v_Provision_RBI_Norms, v_AdditionalBanksProvision, v_Additional_Provision_Bank_Norms_if_any, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO ConstitutionMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO ConstitutionMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_STANDARD_INUP_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
