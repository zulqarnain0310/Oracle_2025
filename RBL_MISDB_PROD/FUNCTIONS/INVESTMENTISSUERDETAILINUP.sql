--------------------------------------------------------
--  DDL for Function INVESTMENTISSUERDETAILINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" /****** Object:  StoredProcedure [dbo].[InvestmentIssuerDetailInUP]    Script Date: 9/24/2021 8:20:04 PM ******/
--DROP PROCEDURE [dbo].[InvestmentIssuerDetailInUP]
 --GO
 --/****** Object:  StoredProcedure [dbo].[InvestmentIssuerDetailInUP]    Script Date: 9/24/2021 8:20:04 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --SELECT * FROm DImSOURCEDB--SELECT * FROm investMentissuerdetail_Mod--Declare	
  iv_Entitykey IN NUMBER DEFAULT 0 ,
  iv_IssuerEntityID IN VARCHAR2 DEFAULT ' ' ,
  v_SourceAlt_key IN NUMBER DEFAULT ' ' ,
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_UcifId IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerName IN VARCHAR2 DEFAULT ' ' ,
  v_Ref_Txn_Sys_Cust_ID IN VARCHAR2 DEFAULT ' ' ,
  v_PanNo IN VARCHAR2 DEFAULT ' ' ,
  v_Issuer_Category_Code IN NUMBER DEFAULT ' ' ,
  v_GrpEntityOfBank IN CHAR DEFAULT 'N' ,
  v_InvestmentIssuerDetail_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  ---------D2k System Common Columns		--
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
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_Entitykey NUMBER(19,0) := iv_Entitykey;
   v_IssuerEntityID VARCHAR2(20) := iv_IssuerEntityID;
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
      v_AppAvail CHAR;

   BEGIN
      -------------------------------------------------------------
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  CurrentStatus = 'C';
      v_EffectiveFromTimeKey := v_TimeKey ;
      v_EffectiveToTimeKey := 49999 ;
      SELECT NVL(MAX(Entitykey) , 0) + 1 

        INTO v_Entitykey
        FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail ;
      --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
      SELECT IssuerEntityId 

        INTO v_IssuerEntityId
        FROM InvestmentIssuerDetail_Mod 
       WHERE  IssuerID = v_IssuerID;
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
                            FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                             WHERE  IssuerID = v_IssuerID
                                      AND NVL(AuthorisationStatus, 'A') = 'A'
                                      AND EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey
                            UNION 
                            SELECT 1 
                            FROM InvestmentIssuerDetail_Mod 
                             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND IssuerID = v_IssuerID
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
            --SELECT @IssuerEntityId= NEXT VALUE FOR Seq_IssuerEntityId
            --PRINT @IssuerEntityId
            SELECT NVL(MAX(IssuerEntityID) , 0) + 1 

              INTO v_IssuerEntityID
              FROM ( SELECT IssuerEntityID 
                     FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                     UNION 
                     SELECT IssuerEntityID 
                     FROM InvestmentIssuerDetail_Mod  ) A;

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
               --SET @IssuerEntityID = (Select ISNULL(Max(IssuerEntityID),0)+1 from 
               --						(Select IssuerEntityID from curdat.investMentissuerdetail
               --						 UNION 
               --						 Select IssuerEntityID from investMentissuerdetail_Mod
               --						)A)
               GOTO IssuerIDMaster_Insert;
               <<IssuerIDMaster_Insert_Add>>

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
                         IssuerEntityID 

                    INTO v_CreatedBy,
                         v_DateCreated,
                         v_IssuerEntityID
                    FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND IssuerEntityId = v_IssuerEntityId;
                  ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM InvestmentIssuerDetail_Mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND IssuerEntityId = v_IssuerEntityId
                               AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                     ;

                  END;
                  ELSE

                   ---IF DATA IS AVAILABLE IN MAIN TABLE
                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                     ----UPDATE FLAG IN MAIN TABLES AS MP
                     UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND IssuerEntityId = v_IssuerEntityId;

                  END;
                  END IF;
                  --UPDATE NP,MP  STATUS 
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     UPDATE InvestmentIssuerDetail_Mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND IssuerEntityId = v_IssuerEntityId
                       AND AuthorisationStatus IN ( 'NP','MP','RM' )
                     ;

                  END;
                  END IF;
                  GOTO IssuerIDMaster_Insert;
                  <<IssuerIDMaster_Insert_Edit_Delete>>

               END;
               ELSE
                  IF v_OperationFlag = 3
                    AND v_AuthMode = 'N' THEN

                  BEGIN
                     -- DELETE WITHOUT MAKER CHECKER
                     v_Modifiedby := v_CrModApBy ;
                     v_DateModified := SYSDATE ;
                     UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                        SET ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND IssuerEntityId = v_IssuerEntityId;

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
                        UPDATE InvestmentIssuerDetail_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND IssuerID = v_IssuerID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND IssuerEntityID = v_IssuerEntityID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND IssuerID = v_IssuerID
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
                           UPDATE InvestmentIssuerDetail_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND IssuerID = v_IssuerID
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;
                           --------------------------------
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND IssuerEntityID = v_IssuerEntityID );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND IssuerID = v_IssuerID
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
                              UPDATE InvestmentIssuerDetail_Mod
                                 SET AuthorisationStatus = 'RM'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                                AND IssuerID = v_IssuerID;

                           END;
                           ELSE
                              IF v_OperationFlag = 16 THEN

                              BEGIN
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 UPDATE InvestmentIssuerDetail_Mod
                                    SET AuthorisationStatus = '1A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  IssuerID = v_IssuerID
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
                                            FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                    AND IssuerID = v_IssuerID;
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
                                         FROM InvestmentIssuerDetail_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND IssuerID = v_IssuerID
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
                                         FROM InvestmentIssuerDetail_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       v_ApprovedBy := v_CrModApBy ;
                                       v_DateApproved := SYSDATE ;
                                       SELECT MIN(EntityKey)  

                                         INTO v_ExEntityKey
                                         FROM InvestmentIssuerDetail_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
                                                 AND IssuerID = v_IssuerID
                                                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       SELECT EffectiveFromTimeKey 

                                         INTO v_CurrRecordFromTimeKey
                                         FROM InvestmentIssuerDetail_Mod 
                                        WHERE  EntityKey = v_ExEntityKey;
                                       UPDATE InvestmentIssuerDetail_Mod
                                          SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND IssuerID = v_IssuerID
                                         AND AuthorisationStatus = 'A';
                                       ----alter table curdat.investMentissuerdetail
                                       ----alter column BranchCode varchar(30)
                                       ----exec sp_refreshview 'InvestmentIssuerDetail'
                                       -------DELETE RECORD AUTHORISE
                                       IF v_DelStatus = 'DP' THEN
                                        DECLARE
                                          v_temp NUMBER(1, 0) := 0;

                                       BEGIN
                                          UPDATE InvestmentIssuerDetail_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  IssuerID = v_IssuerID
                                            AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          BEGIN
                                             SELECT 1 INTO v_temp
                                               FROM DUAL
                                              WHERE EXISTS ( SELECT 1 
                                                             FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND IssuerEntityID = v_IssuerEntityID );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                                                SET AuthorisationStatus = 'A',
                                                    ModifiedBy = v_ModifiedBy,
                                                    DateModified = v_DateModified,
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND IssuerID = v_IssuerID;

                                          END;
                                          END IF;

                                       END;
                                        -- END OF DELETE BLOCK
                                       ELSE

                                        -- OTHER THAN DELETE STATUS
                                       BEGIN
                                          UPDATE InvestmentIssuerDetail_Mod
                                             SET AuthorisationStatus = 'A',
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved
                                           WHERE  IssuerID = v_IssuerID
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
                                                          FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND IssuerID = v_IssuerID );
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
                                                             FROM CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail 
                                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                                       AND EffectiveFromTimeKey = v_TimeKey
                                                                       AND IssuerEntityID = v_IssuerEntityID );
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                NULL;
                                          END;

                                          IF v_temp = 1 THEN

                                          BEGIN
                                             DBMS_OUTPUT.PUT_LINE('BBBB');
                                             UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                                                SET IssuerEntityID = v_IssuerEntityID,
                                                    SourceAlt_key = v_SourceAlt_key,
                                                    BranchCode = v_BranchCode,
                                                    IssuerID = v_IssuerID,
                                                    IssuerName = v_IssuerName,
                                                    UcifId = v_UcifId,
                                                    Ref_Txn_Sys_Cust_ID = v_Ref_Txn_Sys_Cust_ID,
                                                    PanNo = v_PanNo,
                                                    Issuer_Category_Code = v_Issuer_Category_Code,
                                                    GrpEntityOfBank = v_GrpEntityOfBank,
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
                                               AND IssuerID = v_IssuerID;

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
                                          INSERT INTO CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                                          --EntityKey

                                            ( IssuerEntityID, SourceAlt_key, BranchCode, UcifId, IssuerID, IssuerName, Ref_Txn_Sys_Cust_ID, PanNo, Issuer_Category_Code, GrpEntityOfBank, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                            ( SELECT 
                                                     --@Entitykey
                                                     v_IssuerEntityID ,
                                                     v_SourceAlt_key ,
                                                     v_BranchCode ,
                                                     v_UcifId ,
                                                     v_IssuerID ,
                                                     v_IssuerName ,
                                                     v_Ref_Txn_Sys_Cust_ID ,
                                                     v_PanNo ,
                                                     v_Issuer_Category_Code ,
                                                     v_GrpEntityOfBank ,
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
                                          UPDATE CurDat_RBL_MISDB_PROD.InvestmentIssuerDetail
                                             SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AUTHMODE = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END
                                           WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND IssuerID = v_IssuerID
                                            AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    IF v_AUTHMODE = 'N' THEN

                                    BEGIN
                                       v_AuthorisationStatus := 'A' ;
                                       GOTO IssuerIDMaster_Insert;
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
            <<IssuerIDMaster_Insert>>
            IF v_ErrorHandle = 0 THEN

            BEGIN
               INSERT INTO InvestmentIssuerDetail_Mod
                 ( IssuerEntityID, SourceAlt_key, BranchCode, UcifId, IssuerID, IssuerName, Ref_Txn_Sys_Cust_ID, PanNo, Issuer_Category_Code, GrpEntityOfBank, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, InvestmentIssuerDetail_ChangeFields )
                 VALUES ( v_IssuerEntityID, v_SourceAlt_key, v_BranchCode, v_UcifId, v_IssuerID, v_IssuerName, v_Ref_Txn_Sys_Cust_ID, v_PanNo, v_Issuer_Category_Code, v_GrpEntityOfBank, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), CASE 
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
                  END,'dd/mm/yyyy'), v_InvestmentIssuerDetail_ChangeFields );
               IF v_OperationFlag = 1
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(3);
                  GOTO IssuerIDMaster_Insert_Add;

               END;
               ELSE
                  IF ( v_OperationFlag = 2
                    OR v_OperationFlag = 3 )
                    AND v_AUTHMODE = 'Y' THEN

                  BEGIN
                     GOTO IssuerIDMaster_Insert_Edit_Delete;

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
                   v_ReferenceID => v_IssuerID -- ReferenceID ,
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
                   v_ReferenceID => v_IssuerID -- ReferenceID ,
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
            --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM curdat.investMentissuerdetail WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
            --															AND IssuerEntityID=@IssuerEntityID
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTISSUERDETAILINUP" TO "ADF_CDR_RBL_STGDB";
