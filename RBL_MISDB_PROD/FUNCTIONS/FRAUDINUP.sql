--------------------------------------------------------
--  DDL for Function FRAUDINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."FRAUDINUP" 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --exec [dbo].[FraudInUP] N'','','809000283277','1','0009','','1406','','','2079428','','10','10','1','11/22/2021','Y','11/22/2021','Indian Overseas Bank','11/22/2021','11/22/2021','11/22/2021','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','','','','','1,2,3,4'--SELECT * FROm Fraud--SELECT * FROm dbo.Fraud_Mod--Declare	
  v_Entitykey IN NUMBER DEFAULT 0 ,
  iv_AccountEntityId IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerEntityID IN VARCHAR2 DEFAULT ' ' ,
  v_RefCustomerACID IN VARCHAR2 DEFAULT ' ' ,
  iv_RefCustomerID IN VARCHAR2 DEFAULT ' ' ,
  v_RFA_ReportingByBank IN VARCHAR2,--------int = 0
  iv_RFA_DateReportingByBank IN VARCHAR2 DEFAULT NULL ,
  v_RFA_OtherBankAltKey IN NUMBER DEFAULT 0 ,
  iv_RFA_OtherBankDate IN VARCHAR2 DEFAULT NULL ,
  iv_FraudOccuranceDate IN VARCHAR2 DEFAULT NULL ,
  iv_FraudDeclarationDate IN VARCHAR2 DEFAULT NULL ,
  v_FraudNature IN VARCHAR2 DEFAULT ' ' ,
  v_FraudArea IN VARCHAR2 DEFAULT ' ' ,
  v_CurrentAssetClassAltKey IN NUMBER DEFAULT 0 ,
  v_ProvPref IN NUMBER DEFAULT 0 ,
  v_FraudAccounts_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_CurrentNPA_Date IN VARCHAR2 DEFAULT NULL ,
  ---------D2k System Common Columns		---------------------------------
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_Authlevel IN VARCHAR2 DEFAULT ' ' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_RFA_DateReportingByBank VARCHAR2(20) := iv_RFA_DateReportingByBank;
   v_RFA_OtherBankDate VARCHAR2(20) := iv_RFA_OtherBankDate;
   v_FraudOccuranceDate VARCHAR2(20) := iv_FraudOccuranceDate;
   v_FraudDeclarationDate VARCHAR2(20) := iv_FraudDeclarationDate;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_AccountEntityId VARCHAR2(20) := iv_AccountEntityId;
   v_CustomerEntityID VARCHAR2(30) := iv_CustomerEntityID;
   v_RefCustomerID VARCHAR2(30) := iv_RefCustomerID;
   v_AuthorisationStatus VARCHAR2(5) := NULL;
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
   -----------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_MOC_Initialized_Date VARCHAR2(20) := NULL;
   v_AssetClassatFraudAltKey NUMBER(10,0);
   v_NPADtatFraud VARCHAR2(200);
   v_temp NUMBER(1, 0) := 0;
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_RFA_DateReportingByBank := CASE 
                                     WHEN ( v_RFA_DateReportingByBank = ' '
                                       OR v_RFA_DateReportingByBank = '01/01/1900'
                                       OR v_RFA_DateReportingByBank = '1900/01/01' ) THEN NULL
   ELSE v_RFA_DateReportingByBank
      END ;
   v_RFA_OtherBankDate := CASE 
                               WHEN ( v_RFA_OtherBankDate = ' '
                                 OR v_RFA_OtherBankDate = '01/01/1900'
                                 OR v_RFA_OtherBankDate = '1900/01/01' ) THEN NULL
   ELSE v_RFA_OtherBankDate
      END ;
   v_FraudOccuranceDate := CASE 
                                WHEN ( v_FraudOccuranceDate = ' '
                                  OR v_FraudOccuranceDate = '01/01/1900'
                                  OR v_FraudOccuranceDate = '1900/01/01' ) THEN NULL
   ELSE v_FraudOccuranceDate
      END ;
   v_FraudDeclarationDate := CASE 
                                  WHEN ( v_FraudDeclarationDate = ' '
                                    OR v_FraudDeclarationDate = '01/01/1900'
                                    OR v_FraudDeclarationDate = '1900/01/01' ) THEN NULL
   ELSE v_FraudDeclarationDate
      END ;
   v_ScreenName := 'Fraud' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   SELECT AccountEntityID 

     INTO v_AccountEntityID
     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
    WHERE  CustomerACID = v_RefCustomerACID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   SELECT CustomerEntityId 

     INTO v_CustomerEntityID
     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
    WHERE  CustomerACID = v_RefCustomerACID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   SELECT RefCustomerId 

     INTO v_RefCustomerid
     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
    WHERE  CustomerACID = v_RefCustomerACID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(DISTINCT AssetClassAtFraudAltKey)  
               FROM Fraud_Details_Mod 
                WHERE  AccountEntityId = v_AccountEntityID
                         AND EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','1A','A' )
    ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      SELECT AssetClassAtFraudAltKey 

        INTO v_AssetClassatFraudAltKey
        FROM Fraud_Details_Mod 
       WHERE  AccountEntityId = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey
                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','1A','A' )
      ;
      SELECT NPA_DateAtFraud 

        INTO v_NPADtatFraud
        FROM Fraud_Details_Mod 
       WHERE  AccountEntityId = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey
                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','1A','A' )
      ;

   END;
   ELSE

   BEGIN
      SELECT Cust_AssetClassAlt_Key 

        INTO v_AssetClassatFraudAltKey
        FROM RBL_MISDB_PROD.AdvCustNPADetail 
       WHERE  CustomerEntityId = v_CustomerEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      SELECT NPADt 

        INTO v_NPADtatFraud
        FROM RBL_MISDB_PROD.AdvCustNPADetail 
       WHERE  CustomerEntityId = v_CustomerEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;

   END;
   END IF;
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
                         FROM RBL_MISDB_PROD.Fraud_Details 
                          WHERE  RefCustomerACID = v_RefCustomerACID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM RBL_MISDB_PROD.Fraud_Details_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND RefCustomerACID = v_RefCustomerACID
                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
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
         --SELECT @AccountEntityID= NEXT VALUE FOR Seq_AccountEntityID
         --PRINT @AccountEntityID
         SELECT NVL(MAX(AccountEntityId) , 0) + 1 

           INTO v_AccountEntityId
           FROM ( SELECT AccountEntityId 
                  FROM RBL_MISDB_PROD.Fraud_Details 
                  UNION 
                  SELECT AccountEntityId 
                  FROM RBL_MISDB_PROD.Fraud_Details_Mod  ) A;

      END;
      END IF;

   END;
   END IF;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
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
            --SET @AccountEntityID = (Select ISNULL(Max(AccountEntityID),0)+1 from 
            --						(Select AccountEntityID from dbo.Fraud_Details
            --						 UNION 
            --						 Select AccountEntityID from dbo.Fraud_Details_Mod
            --						)A)
            GOTO Fraud_Details_Insert;
            <<Fraud_Details_Insert_Add>>

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
                      DateCreated ,
                      AccountEntityID 

                 INTO v_CreatedBy,
                      v_DateCreated,
                      v_AccountEntityID
                 FROM RBL_MISDB_PROD.Fraud_Details 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND AccountEntityID = v_AccountEntityID;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM RBL_MISDB_PROD.Fraud_Details_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND AccountEntityID = v_AccountEntityID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE RBL_MISDB_PROD.Fraud_Details
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO Fraud_Details_Insert;
               <<Fraud_Details_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE RBL_MISDB_PROD.Fraud_Details
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND AccountEntityID = v_AccountEntityID;

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
                     UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND RefCustomerACID = v_RefCustomerACID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM RBL_MISDB_PROD.Fraud_Details 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND AccountEntityID = v_AccountEntityID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE RBL_MISDB_PROD.Fraud_Details
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND RefCustomerACID = v_RefCustomerACID
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
                        UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                           SET AuthorisationStatus = 'R',
                               FirstLevelApprovedBy = v_ApprovedBy,
                               FirstLevelDateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND RefCustomerACID = v_RefCustomerACID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        --------------------------------
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM RBL_MISDB_PROD.Fraud_Details 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND AccountEntityID = v_AccountEntityID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE RBL_MISDB_PROD.Fraud_Details
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND RefCustomerACID = v_RefCustomerACID
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
                           UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND RefCustomerACID = v_RefCustomerACID;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                                 SET AuthorisationStatus = '1A',
                                     FirstLevelApprovedBy = v_ApprovedBy,
                                     FirstLevelDateApproved = v_DateApproved
                               WHERE  RefCustomerACID = v_RefCustomerACID
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
                                         FROM RBL_MISDB_PROD.Fraud_Details 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND RefCustomerACID = v_RefCustomerACID;
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
                                    SELECT MAX(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM RBL_MISDB_PROD.Fraud_Details_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND RefCustomerACID = v_RefCustomerACID
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
                                      FROM RBL_MISDB_PROD.Fraud_Details_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM RBL_MISDB_PROD.Fraud_Details_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND RefCustomerACID = v_RefCustomerACID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM RBL_MISDB_PROD.Fraud_Details_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND RefCustomerACID = v_RefCustomerACID
                                      AND AuthorisationStatus = 'A';
                                    ----alter table dbo.Fraud_Details
                                    ----alter column BranchCode varchar(30)
                                    ----exec sp_refreshview 'InvestmentIssuerDetail'
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  RefCustomerACID = v_RefCustomerACID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM RBL_MISDB_PROD.Fraud_Details 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND AccountEntityID = v_AccountEntityID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE RBL_MISDB_PROD.Fraud_Details
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND RefCustomerACID = v_RefCustomerACID;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.Fraud_Details_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  RefCustomerACID = v_RefCustomerACID
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
                                                       FROM RBL_MISDB_PROD.Fraud_Details 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND RefCustomerACID = v_RefCustomerACID );
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
                                                          FROM RBL_MISDB_PROD.Fraud_Details 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND AccountEntityID = v_AccountEntityID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE RBL_MISDB_PROD.Fraud_Details
                                             SET AccountEntityId = v_AccountEntityId,
                                                 CustomerEntityId = v_CustomerEntityID,
                                                 RefCustomerACID = v_RefCustomerACID,
                                                 RefCustomerID = v_RefCustomerID,
                                                 RFA_ReportingByBank = v_RFA_ReportingByBank,
                                                 RFA_DateReportingByBank = v_RFA_DateReportingByBank,
                                                 RFA_OtherBankAltKey = v_RFA_OtherBankAltKey,
                                                 RFA_OtherBankDate = v_RFA_OtherBankDate,
                                                 FraudOccuranceDate = v_FraudOccuranceDate,
                                                 FraudDeclarationDate = v_FraudDeclarationDate,
                                                 FraudNature = v_FraudNature,
                                                 FraudArea = v_FraudArea
                                                 --,AssetClassAtFraud			=	@AssetClassatFraud
                                                  --,NPA_DateAtFraud			=	@NPADtatFraud
                                                 ,
                                                 CurrentAssetClassAltKey = v_CurrentAssetClassAltKey,
                                                 ProvPref = v_ProvPref,
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
                                                 FirstLevelDateApproved = v_DateApprovedFirstLevel,
                                                 screenFlag = 'S'
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND RefCustomerACID = v_RefCustomerACID;

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
                                       INSERT INTO RBL_MISDB_PROD.Fraud_Details
                                         ( AccountEntityId, CustomerEntityId, RefCustomerACID, RefCustomerID, RFA_ReportingByBank, RFA_DateReportingByBank, RFA_OtherBankAltKey, RFA_OtherBankDate, FraudOccuranceDate, FraudDeclarationDate, FraudNature, FraudArea, AssetClassAtFraudAltKey, NPA_DateAtFraud, CurrentAssetClassAltKey, ProvPref, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, FirstLevelApprovedBy, FirstLevelDateApproved, screenFlag )
                                         ( SELECT v_AccountEntityId ,
                                                  v_CustomerEntityId ,
                                                  v_RefCustomerACID ,
                                                  v_RefCustomerID ,
                                                  v_RFA_ReportingByBank ,
                                                  --,case when @RFA_ReportingByBank='10' then 'N' Else 'Y' End
                                                  v_RFA_DateReportingByBank ,
                                                  --,@RFA_OtherBankAltKey
                                                  v_RFA_OtherBankAltKey ,
                                                  v_RFA_OtherBankDate ,
                                                  v_FraudOccuranceDate ,
                                                  v_FraudDeclarationDate ,
                                                  v_FraudNature ,
                                                  v_FraudArea ,
                                                  v_AssetClassAtFraudAltKey ,
                                                  v_CurrentNPA_Date ,
                                                  v_CurrentAssetClassAltKey ,
                                                  v_ProvPref ,
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
                                                  v_DateApprovedFirstLevel ,
                                                  'S' 
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.Fraud_Details
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND RefCustomerACID = v_RefCustomerACID
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO Fraud_Details_Insert;
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
         <<Fraud_Details_Insert>>
         IF v_ErrorHandle = 0 THEN
          DECLARE
            v_Parameter1 VARCHAR2(50);
            v_FinalParameter1 VARCHAR2(50);

         BEGIN
            INSERT INTO RBL_MISDB_PROD.Fraud_Details_Mod
              ( AccountEntityId, CustomerEntityId, RefCustomerACID, RefCustomerID, RFA_ReportingByBank, RFA_DateReportingByBank, RFA_OtherBankAltKey, RFA_OtherBankDate, FraudOccuranceDate, FraudDeclarationDate, FraudNature, FraudArea, AssetClassAtFraudAltKey, NPA_DateAtFraud, CurrentAssetClassAltKey, ProvPref, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, FirstLevelApprovedBy, FirstLevelDateApproved, FraudAccounts_ChangeFields, screenFlag )
              VALUES ( v_AccountEntityId, v_CustomerEntityId, v_RefCustomerACID, v_RefCustomerID, v_RFA_ReportingByBank, 
            --,case when @RFA_ReportingByBank='10' THEN 'N' ELSE 'Y' END
            v_RFA_DateReportingByBank, 
            --,@RFA_OtherBankAltKey
            v_RFA_OtherBankAltKey, v_RFA_OtherBankDate, v_FraudOccuranceDate, v_FraudDeclarationDate, v_FraudNature, v_FraudArea, v_AssetClassatFraudAltKey, v_CurrentNPA_Date, v_CurrentAssetClassAltKey, v_ProvPref, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               END, v_ApprovedByFirstLevel, v_DateApprovedFirstLevel, v_FraudAccounts_ChangeFields, 'S' );
            SELECT utils.stuff(( SELECT ',' || FraudAccounts_ChangeFields 
                                 FROM Fraud_Details_Mod 
                                  WHERE  RefCustomerAcid = v_RefCustomerACID
                                           AND NVL(AuthorisationStatus, 'A') IN ( 'A','MP' )
                                ), 1, 1, ' ') 

              INTO v_Parameter1
              FROM DUAL ;
            IF utils.object_id('tt_AA_21') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AA_21 ';
            END IF;
            DELETE FROM tt_AA_21;
            UTILS.IDENTITY_RESET('tt_AA_21');

            INSERT INTO tt_AA_21 ( 
            	SELECT DISTINCT VALUE 
            	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                             VALUE 
                      FROM ( SELECT VALUE 
                             FROM TABLE(STRING_SPLIT(v_Parameter1, ','))  ) A ) X );
            SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                 FROM tt_AA_21  ), 1, 1, ' ') 

              INTO v_FinalParameter1
              FROM DUAL ;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, v_FinalParameter1
            FROM A ,Fraud_Details_Mod A 
             WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
              AND EffectiveToTimeKey >= v_tiMEKEY )
              AND RefCustomerAcid = v_RefCustomerACID) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET a.FraudAccounts_ChangeFields = v_FinalParameter1;
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO Fraud_Details_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO Fraud_Details_Insert_Edit_Delete;

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
                v_ReferenceID => v_RefCustomerACID -- ReferenceID ,
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
                v_ReferenceID => v_RefCustomerACID -- ReferenceID ,
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
      --END

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUDINUP" TO "ADF_CDR_RBL_STGDB";
