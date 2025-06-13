--------------------------------------------------------
--  DDL for Function INVESTENBASICDETAILINUP_24012024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" 
(
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_InvEntityId IN NUMBER DEFAULT 0 ,
  v_InvID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerEntityId IN NUMBER DEFAULT 0 ,
  v_RefIssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_EntityKey IN NUMBER DEFAULT 0 ,
  v_ISIN IN VARCHAR2 DEFAULT ' ' ,
  v_InstrTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_InstrName IN VARCHAR2 DEFAULT ' ' ,
  v_InvestmentNature IN VARCHAR2 DEFAULT ' ' ,
  v_InternalRating IN NUMBER DEFAULT 0 ,
  iv_InRatingDate IN VARCHAR2 DEFAULT ' ' ,
  iv_InRatingExpiryDate IN VARCHAR2 DEFAULT ' ' ,
  v_ExRating IN NUMBER DEFAULT 0 ,
  v_ExRatingAgency IN NUMBER DEFAULT 0 ,
  iv_ExRatingDate IN VARCHAR2 DEFAULT ' ' ,
  iv_ExRatingExpiryDate IN VARCHAR2 DEFAULT ' ' ,
  v_Sector IN VARCHAR2 DEFAULT ' ' ,
  v_Industry_AltKey IN NUMBER DEFAULT 0 ,
  v_ListedStkExchange IN CHAR,
  v_ExposureType IN VARCHAR2 DEFAULT ' ' ,
  v_SecurityValue IN NUMBER DEFAULT 0.0 ,
  iv_MaturityDt IN VARCHAR2 DEFAULT ' ' ,
  iv_ReStructureDate IN VARCHAR2 DEFAULT ' ' ,
  v_MortgageStatus IN CHAR DEFAULT ' ' ,
  v_NHBStatus IN CHAR DEFAULT ' ' ,
  v_ResiPurpose IN CHAR DEFAULT ' ' ,
  v_ScrCrError IN VARCHAR2 DEFAULT ' ' ,
  iv_ExEntityKey IN NUMBER DEFAULT 0 ,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_IsMOC IN CHAR DEFAULT 'N' ,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_BlnSCD2ForInvestmentBasicDetail IN CHAR DEFAULT 'Y' ,
  v_Basic_ChangeFields IN VARCHAR2 DEFAULT ' ' 
)
RETURN NUMBER
AS
   v_InRatingDate VARCHAR2(10) := iv_InRatingDate;
   v_InRatingExpiryDate VARCHAR2(10) := iv_InRatingExpiryDate;
   v_ExRatingDate VARCHAR2(10) := iv_ExRatingDate;
   v_ExRatingExpiryDate VARCHAR2(10) := iv_ExRatingExpiryDate;
   v_MaturityDt VARCHAR2(10) := iv_MaturityDt;
   v_ReStructureDate VARCHAR2(10) := iv_ReStructureDate;
   v_ExEntityKey NUMBER(10,0) := iv_ExEntityKey;
   v_cursor SYS_REFCURSOR;

BEGIN

   DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
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
         v_AuthorisationStatus CHAR(2) := NULL;
         v_CreatedBy VARCHAR2(20) := NULL;
         v_DATECreated DATE := NULL;
         v_Modifiedby VARCHAR2(20) := NULL;
         v_DateModified DATE := NULL;
         v_ApprovedBy VARCHAR2(20) := NULL;
         v_DateApproved DATE := NULL;
         v_ExAccount_Key NUMBER(10,0) := 0;
         v_ErrorHandle NUMBER(10,0) := 0;
         --FOR MOC
         v_MocFromTimeKey NUMBER(10,0) := 0;
         v_MocToTimeKey NUMBER(10,0) := 0;
         v_MocTypeAlt_Key NUMBER(10,0) := 0;
         v_MocDate DATE := NULL;
         v_AppAvail CHAR;

      BEGIN
         v_InRatingDate := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_InRatingDate, ' '),200,p_style=>103) ;
         v_InRatingExpiryDate := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_InRatingExpiryDate, ' '),200,p_style=>103) ;
         v_ExRatingDate := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_ExRatingDate, ' '),200,p_style=>103) ;
         v_ExRatingExpiryDate := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_ExRatingExpiryDate, ' '),200,p_style=>103) ;
         v_MaturityDt := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_MaturityDt, ' '),200,p_style=>103) ;
         v_ReStructureDate := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_ReStructureDate, ' '),200,p_style=>103) ;
         v_MocDate := UTILS.CONVERT_TO_VARCHAR2(NULLIF(v_MocDate, ' '),200,p_style=>103) ;
         DBMS_OUTPUT.PUT_LINE('InvestmentBasicDetailInUP');
         SELECT ParameterValue 

           INTO v_AppAvail
           FROM SysSolutionParameter 
          WHERE  ParameterAlt_Key = 6;
         IF ( v_AppAvail = 'N' ) THEN

         BEGIN
            v_Result := -11 ;
            RETURN v_Result;

         END;
         END IF;
         IF v_OperationFlag = 1 THEN

          --- add
         BEGIN
            DBMS_OUTPUT.PUT_LINE(5);
            -----CHECK DUPLICATE BILL NO AT BRANCH LEVEL
            -- CUSTOMERID ALEADY EXISTS
            --SELECT * from SysSolutionParameter WHERE ParameterName= 'ClientName'
            --EntityID asked to sunil sir for mod taBle 
            Seq_InvEntityId  --SQLDEV: NOT RECOGNIZED
            DBMS_OUTPUT.PUT_LINE(v_InvEntityId);

         END;
         END IF;

      END;
      END IF;

   END;
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         IF ( v_OperationFlag IN ( 1,2,3 )

           AND v_AuthMode = 'Y' ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(4);
            IF v_OperationFlag = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(5);
               v_CreatedBy := v_CrModApBy ;
               v_DATECreated := SYSDATE ;
               v_AuthorisationStatus := 'NP' ;
               GOTO investmentbasicdetail_Insert;
               <<investmentbasicdetail_Insert_Add>>

            END;
            END IF;
            IF v_OperationFlag IN ( 2,3 )
             THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(6);
               v_Modifiedby := v_CrModApBy ;
               v_DateModified := SYSDATE ;
               IF v_AuthMode = 'Y' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(10);
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(11);
                     v_AuthorisationStatus := 'MP' ;

                  END;
                  ELSE

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(12);
                     v_AuthorisationStatus := 'DP' ;

                  END;
                  END IF;
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DATECreated
                    FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND InvEntityId = v_InvEntityId;
                  -----Find createdby from mod table if not available in main table
                  IF NVL(v_CreatedBy, ' ') = ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(13);
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DATECreated
                       FROM InvestmentBasicDetail_mod 
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND InvEntityId = v_InvEntityId;

                  END;
                  ELSE

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(14);
                     UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                        SET AuthorisationStatus = v_AuthorisationStatus
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND InvEntityId = v_InvEntityId;

                  END;
                  END IF;
                  IF v_OperationFlag = 2 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(15);
                     UPDATE InvestmentBasicDetail_mod
                        SET AuthorisationStatus = 'FM',
                            ModifiedBy = v_Modifiedby,
                            DateModified = v_DateModified
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND InvEntityId = v_InvEntityId
                       AND AuthorisationStatus IN ( 'NP','MP' )
                     ;

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;
            GOTO investmentbasicdetail_Insert;
            <<investmentbasicdetail_Insert_EDIT_DELETE>>

         END;
         END IF;
         IF v_OperationFlag = 3
           AND v_AuthMode = 'N' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(16);
            v_Modifiedby := v_CrModApBy ;
            v_DateModified := SYSDATE ;
            UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
               SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                   ModifiedBy = v_Modifiedby,
                   DateModified = v_DateModified
             WHERE  ( EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey )
              AND InvEntityId = v_InvEntityId;

         END;
         ELSE
            IF v_OperationFlag = 21
              AND v_AuthMode = 'Y' THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               v_ApprovedBy := v_CrModApBy ;
               v_DateApproved := SYSDATE ;
               UPDATE InvestmentBasicDetail_mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_ApprovedBy,
                      DateApproved = v_DateApproved,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND InvEntityID = v_InvEntityId
                 AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
               ;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND EntityKey = v_EntityKey );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                     SET AuthorisationStatus = 'A'
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND v_InvEntityId = v_InvEntityId
                    AND AuthorisationStatus IN ( 'MP','DP','RM' )
                  ;

               END;
               END IF;

            END;
            ELSE
               IF v_Operationflag = 17 THEN
                DECLARE
                  v_MocAuthRec_EntityKey NUMBER(10,0) := 0;

               BEGIN
                  DBMS_OUTPUT.PUT_LINE(17);
                  v_ApprovedBy := v_CrModApBy ;
                  v_DateApproved := SYSDATE ;
                  IF v_IsMOC = 'Y' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(18);
                     ---- FINDS Entity Keys of Authorized record from MOD Table
                     SELECT NVL(MAX(EntityKey) , 0) 

                       INTO v_MocAuthRec_EntityKey
                       FROM InvestmentBasicDetail_mod 
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                               AND EffectiveToTimeKey >= v_TimeKey )
                               AND InvEntityId = v_InvEntityId
                               AND v_IsMoc = 'Y'
                               AND AuthorisationStatus = 'A';

                  END;
                  END IF;
                  DBMS_OUTPUT.PUT_LINE(19);
                  UPDATE InvestmentBasicDetail_mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved,
                         EffectiveTotimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND InvEntityId = v_InvEntityId
                    AND (CASE 
                              WHEN v_IsMoc = 'N'
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                               THEN 1
                              WHEN v_IsMoc = 'Y'
                                AND EntityKey > v_MocAuthRec_EntityKey
                                AND AuthorisationStatus <> 'FM' THEN 1   END) = 1;--FOR MOC Set R for Records which are not authorized & Change effective to time key
                  DBMS_OUTPUT.PUT_LINE(20);
                  UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND InvEntityId = v_InvEntityId
                    AND AuthorisationStatus IN ( 'NP','MP','RM','DP' )
                  ;

               END;
               ELSE
                  IF v_OperationFlag = 16 THEN

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE InvestmentBasicDetail_mod
                        SET AuthorisationStatus = '1A',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved
                      WHERE  EntityKey = v_EntityKey
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;

                  END;
                  ELSE
                     IF v_OperationFlag = 18
                       AND v_AuthMode = 'Y' THEN

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE InvestmentBasicDetail_mod
                           SET ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               AuthorisationStatus = 'RM'
                         WHERE  ( EffectiveFromTimeKey <= EffectiveFromTimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND InvEntityId = v_InvEntityId
                          AND AuthorisationStatus IN ( 'NP','MP','DP' )
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
                                   FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey )
                                           AND InvEntityId = v_InvEntityId;
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;

                              END;
                              END IF;

                           END;
                           END IF;
                           ---set parameters and UPDATE mod table in case maker checker enabled
                           IF v_AuthMode = 'Y' THEN
                            DECLARE
                              --Print 'B'
                              v_DelStatus -------------20042021
                               CHAR(2) := ' ';
                              v_CurrRecordFromTimeKey NUMBER(5,0) := 0;
                              v_CurEntityKey NUMBER(10,0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('C');
                              SELECT MAX(EntityKey)  

                                INTO v_ExEntityKey
                                FROM InvestmentBasicDetail_mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND InvEntityId = v_InvEntityId
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
                                FROM InvestmentBasicDetail_mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              SELECT MIN(EntityKey)  

                                INTO v_ExEntityKey
                                FROM InvestmentBasicDetail_mod 
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey )
                                        AND EntityKey = v_EntityKey
                                        AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                              ;
                              SELECT EffectiveFromTimeKey 

                                INTO v_CurrRecordFromTimeKey
                                FROM InvestmentBasicDetail_mod 
                               WHERE  EntityKey = v_ExEntityKey;
                              UPDATE InvestmentBasicDetail_mod
                                 SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND EntityKey = v_EntityKey
                                AND AuthorisationStatus = 'A';
                              -------DELETE RECORD AUTHORISE
                              IF v_DelStatus = 'DP' THEN
                               DECLARE
                                 v_temp NUMBER(1, 0) := 0;

                              BEGIN
                                 UPDATE InvestmentBasicDetail_mod
                                    SET AuthorisationStatus = 'A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved,
                                        EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                  WHERE  EntityKey = v_EntityKey
                                   AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                 ;
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND EntityKey = v_EntityKey );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                                       SET AuthorisationStatus = 'A',
                                           ModifiedBy = v_ModifiedBy,
                                           DateModified = v_DateModified,
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved,
                                           EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND EntityKey = v_EntityKey;

                                 END;
                                 END IF;

                              END;
                               -- END OF DELETE BLOCK
                              ELSE

                               -- OTHER THAN DELETE STATUS
                              BEGIN
                                 UPDATE InvestmentBasicDetail_mod
                                    SET AuthorisationStatus = 'A',
                                        ApprovedBy = v_ApprovedBy,
                                        DateApproved = v_DateApproved
                                  WHERE  EntityKey = v_EntityKey
                                   AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                 ;

                              END;
                              END IF;

                           END;
                           END IF;
                           ----3:40----------------------------------
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
                                                 FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND EntityKey = v_EntityKey );
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
                                                    FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND EffectiveFromTimeKey = v_TimeKey
                                                              AND EntityKey = v_EntityKey );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('BBBB');
                                    UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                                       SET EntityKey = v_EntityKey,
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
                                      AND EntityKey = v_EntityKey;

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
                                 INSERT INTO CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                                   ( EntityKey, BranchCode, InvEntityId, InvID, IssuerEntityId, RefIssuerID, ISIN, InstrTypeAlt_Key, InstrName, InvestmentNature, InternalRating, InRatingDate, InRatingExpiryDate, ExRating, ExRatingAgency, ExRatingDate, ExRatingExpiryDate, Sector, Industry_AltKey, ListedStkExchange, ExposureType, SecurityValue, MaturityDt, ReStructureDate, MortgageStatus, NHBStatus, ResiPurpose, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                                   ( SELECT v_EntityKey ,
                                            v_BranchCode ,
                                            v_InvEntityId ,
                                            v_InvID ,
                                            v_IssuerEntityId ,
                                            v_RefIssuerID ,
                                            v_ISIN ,
                                            v_InstrTypeAlt_Key ,
                                            v_InstrName ,
                                            v_InvestmentNature ,
                                            v_InternalRating ,
                                            v_InRatingDate ,
                                            v_InRatingExpiryDate ,
                                            v_ExRating ,
                                            v_ExRatingAgency ,
                                            v_ExRatingDate ,
                                            v_ExRatingExpiryDate ,
                                            v_Sector ,
                                            v_Industry_AltKey ,
                                            v_ListedStkExchange ,
                                            v_ExposureType ,
                                            v_SecurityValue ,
                                            v_MaturityDt ,
                                            v_ReStructureDate ,
                                            v_MortgageStatus ,
                                            v_NHBStatus ,
                                            v_ResiPurpose ,
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
                                 UPDATE CurDat_RBL_MISDB_PROD.InvestmentBasicDetail
                                    SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                        AuthorisationStatus = CASE 
                                                                   WHEN v_AUTHMODE = 'Y' THEN 'A'
                                        ELSE NULL
                                           END
                                  WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND EntityKey = v_EntityKey
                                   AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                              END;
                              END IF;

                           END;
                           END IF;
                           IF v_AUTHMODE = 'N' THEN

                           BEGIN
                              v_AuthorisationStatus := 'A' ;
                              GOTO investmentbasicdetail_Insert;
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
         <<investmentbasicdetail_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO InvestmentBasicDetail_mod
              ( EntityKey, BranchCode, InvEntityId, InvID, IssuerEntityId, RefIssuerID, ISIN, InstrTypeAlt_Key, InstrName, InvestmentNature, InternalRating, InRatingDate, InRatingExpiryDate, ExRating, ExRatingAgency, ExRatingDate, ExRatingExpiryDate, Sector, Industry_AltKey, ListedStkExchange, ExposureType, SecurityValue, MaturityDt, ReStructureDate, MortgageStatus, NHBStatus, ResiPurpose, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
              VALUES ( v_EntityKey, v_BranchCode, v_InvEntityId, v_InvID, v_IssuerEntityId, v_RefIssuerID, v_ISIN, v_InstrTypeAlt_Key, v_InstrName, v_InvestmentNature, v_InternalRating, v_InRatingDate, v_InRatingExpiryDate, v_ExRating, v_ExRatingAgency, v_ExRatingDate, v_ExRatingExpiryDate, v_Sector, v_Industry_AltKey, v_ListedStkExchange, v_ExposureType, v_SecurityValue, v_MaturityDt, v_ReStructureDate, v_MortgageStatus, v_NHBStatus, v_ResiPurpose, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               GOTO investmentbasicdetail_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO investmentbasicdetail_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM investmentbasicdetail WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --															AND EntityKey=@EntityKey
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTENBASICDETAILINUP_24012024" TO "ADF_CDR_RBL_STGDB";
