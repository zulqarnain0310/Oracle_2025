--------------------------------------------------------
--  DDL for Function RESTUCTUREMASTER_INUP_28072023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

(
  v_AccountEntityId IN NUMBER DEFAULT 0 ,
  v_RestructureTypeAlt_Key IN NUMBER DEFAULT 0 ,
  v_RestructureCatgAlt_Key IN NUMBER DEFAULT 0 ,
  iv_RestructureProposalDt IN VARCHAR2 DEFAULT ' ' ,
  v_RestructureDt IN VARCHAR2 DEFAULT ' ' ,
  v_RestructureAmt IN NUMBER DEFAULT NULL ,
  v_ApprovingAuthAlt_Key IN VARCHAR2 DEFAULT NULL ,
  iv_RestructureApprovalDt IN VARCHAR2 DEFAULT ' ' ,
  v_RestructureSequenceRefNo IN NUMBER DEFAULT 0 ,
  v_DiminutionAmount IN NUMBER DEFAULT NULL ,
  v_RestructureByAlt_Key IN NUMBER DEFAULT 0 ,
  v_RefCustomerId IN VARCHAR2 DEFAULT NULL ,
  v_RefSystemAcId IN VARCHAR2 DEFAULT NULL ,
  --,@OverDueSinceDt				Varchar(20)	=' '	-- ,@BankApprovalDt				Varchar(20)	=' '	-- ,@ForwardDt					Varchar(20)	=' '
  v_DisbursementDate IN VARCHAR2 DEFAULT ' ' ,
  v_RestructureAssetClassAlt_key IN NUMBER DEFAULT 0 ,
  v_RestructureNPADate IN VARCHAR2 DEFAULT ' ' ,
  v_Npa_Qtr IN VARCHAR2 DEFAULT NULL ,
  v_RestructurePOS IN NUMBER DEFAULT 0 ,
  v_RevisedBusinessSegment IN VARCHAR2 DEFAULT ' ' ,
  v_BankingType IN NUMBER DEFAULT 0 ,
  --,@Remark					VARCHAR(250)=NULL	
  v_ChangeFields IN VARCHAR2 DEFAULT NULL ,
  --,@PreRestrucDefaultDate		DATETIME=' '--,@PreRestrucAssetClass		INT	=0	--,@PreRestrucNPA_Date		DATETIME=' '--,@PostRestrucAssetClass		INT=0	
  v_IntRepayStartDate IN VARCHAR2 DEFAULT ' ' ,
  iv_PrinRepayStartDate IN VARCHAR2 DEFAULT ' ' ,
  v_RefDate IN VARCHAR2 DEFAULT ' ' ,
  v_InvocationDate IN VARCHAR2 DEFAULT ' ' ,
  v_IsEquityCoversion IN CHAR DEFAULT NULL ,
  v_ConversionDate IN VARCHAR2 DEFAULT ' ' ,
  v_Is_COVID_Morat IN CHAR DEFAULT NULL ,
  v_COVID_OTR_Catg IN VARCHAR2 DEFAULT NULL ,
  v_CRILIC_Fst_DefaultDate IN VARCHAR2 DEFAULT ' ' ,
  v_FstDefaultReportingBank IN VARCHAR2 DEFAULT NULL ,
  iv_ICA_SignDate IN VARCHAR2 DEFAULT ' ' ,
  v_Is_InvestmentGrade IN VARCHAR2 DEFAULT NULL ,
  v_CreditProvision IN NUMBER DEFAULT NULL ,
  v_DFVProvision IN NUMBER DEFAULT NULL ,
  v_MTMProvision IN NUMBER DEFAULT NULL ,
  v_NPA_Provision_per IN NUMBER DEFAULT NULL ,
  v_EquityConversionYN IN VARCHAR2 DEFAULT ' ' ,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN VARCHAR2 DEFAULT 'N' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT ' ' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_RestuctureMaster_ChangeFields IN VARCHAR2,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_RestructureProposalDt VARCHAR2(200) := iv_RestructureProposalDt;
   v_RestructureApprovalDt VARCHAR2(20) := iv_RestructureApprovalDt;
   v_ICA_SignDate VARCHAR2(20) := iv_ICA_SignDate;
   v_PrinRepayStartDate VARCHAR2(20) := iv_PrinRepayStartDate;
   v_AuthorisationStatus CHAR(2) := NULL;
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

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'RestructureMaster' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   v_RestructureProposalDt := CASE 
                                   WHEN ( v_RestructureProposalDt = ' '
                                     OR v_RestructureProposalDt = '01/01/1900' ) THEN NULL
   ELSE v_RestructureProposalDt
      END ;
   v_RestructureApprovalDt := CASE 
                                   WHEN ( v_RestructureApprovalDt = ' '
                                     OR v_RestructureApprovalDt = '01/01/1900' ) THEN NULL
   ELSE v_RestructureApprovalDt
      END ;
   v_ICA_SignDate := CASE 
                          WHEN ( v_ICA_SignDate = ' '
                            OR v_ICA_SignDate = '01/01/1900' ) THEN NULL
   ELSE v_ICA_SignDate
      END ;
   v_PrinRepayStartDate := CASE 
                                WHEN ( v_PrinRepayStartDate = ' '
                                  OR v_PrinRepayStartDate = '01/01/1900' ) THEN NULL
   ELSE v_PrinRepayStartDate
      END ;
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
                         FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                          WHERE  RefSystemAcId = v_RefSystemAcId
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND RefSystemAcId = v_RefSystemAcId
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
         --ELSE
         --	BEGIN
         --	   PRINT 3
         --		--SELECT @BankRPAlt_Key=NEXT VALUE FOR Seq_BankRPAlt_Key
         --		--PRINT @BankRPAlt_Key
         --			 --SET @AccountEntityId = (Select ISNULL(Max(AccountEntityId),0)+1 from 
         --				--						(Select AccountEntityId from Curdat.AdvAcRestructureDetail
         --				--						 UNION 
         --				--						 Select AccountEntityId from dbo.AdvAcRestructureDetail_Mod
         --				--						)A)
         --	END
         ---------------------Added on 29/05/2020 for user allocation rights
         /*
         		IF @AccessScopeAlt_Key in (1,2)
         		BEGIN
         		PRINT 'Sunil'

         		IF EXISTS(				                
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
         					And IsChecker='N'
         				)	
         				BEGIN
         				   PRINT 2
         					SET @Result=-6
         					RETURN @Result -- USER SHOULD HAVE CHECKER RIGHTS 
         				END
         		END


         		IF @AccessScopeAlt_Key in (3)
         		BEGIN
         		PRINT 'Sunil1'

         		IF EXISTS(				                
         					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
         					And IsChecker='Y'
         				)	
         				BEGIN
         				   PRINT 2
         					SET @Result=-8
         					RETURN @Result -- USER SHOULD NOT HAVE CHECKER RIGHTS 
         				END
         		END
         		*/
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
            --SET @AccountEntityId = (Select ISNULL(Max(AccountEntityId),0)+1 from 
            --						(Select AccountEntityId from Curdat.AdvAcRestructureDetail
            --						 UNION 
            --						 Select AccountEntityId from dbo.AdvAcRestructureDetail_Mod
            --						)A)
            GOTO RestructureMaster_Insert;
            <<RestructureMaster_Insert_Add>>

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
                 FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND RefSystemAcId = v_RefSystemAcId;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND RefSystemAcId = v_RefSystemAcId
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND RefSystemAcId = v_RefSystemAcId;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND RefSystemAcId = v_RefSystemAcId
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               -- ConstitutionMaster_Insert
               --ConstitutionMaster_Insert_Edit_Delete:
               GOTO RestructureMaster_Insert;
               <<RestructureMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND RefSystemAcId = v_RefSystemAcId;

               END;
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND RefSystemAcId = v_RefSystemAcId
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                     DBMS_OUTPUT.PUT_LINE('Sunil');
                     --		DECLARE @EntityKey as Int 
                     --		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                     --							 FROM DimBankRP_Mod 
                     --								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                     --									AND BankRPAlt_Key=@BankRPAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
                     --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                     --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                     --------------------------------
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND RefSystemAcId = v_RefSystemAcId );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND RefSystemAcId = v_RefSystemAcId
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;

                  -------------------Two level Auth. Changes------------------
                  ELSE
                     IF v_OperationFlag = 21
                       AND v_AuthMode = 'Y' THEN
                      DECLARE
                        v_temp NUMBER(1, 0) := 0;

                     BEGIN
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_ApprovedBy,
                               DateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND RefSystemAcId = v_RefSystemAcId
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                        ;
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE EXISTS ( SELECT 1 
                                           FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND RefSystemAcId = v_RefSystemAcId );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND RefSystemAcId = v_RefSystemAcId
                             AND AuthorisationStatus IN ( 'MP','DP','RM' )
                           ;

                        END;
                        END IF;

                     END;

                     ----------------------------------------------------------------------
                     ELSE
                        IF v_OperationFlag = 18 THEN

                        BEGIN
                           DBMS_OUTPUT.PUT_LINE(18);
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND RefSystemAcId = v_RefSystemAcId;

                        END;
                        ELSE
                           IF v_OperationFlag = 16 THEN

                           BEGIN
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                                 SET AuthorisationStatus = '1A',
                                     ApprovedBy = v_ApprovedBy,
                                     DateApproved = v_DateApproved
                               WHERE  RefSystemAcId = v_RefSystemAcId
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
                                         FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND RefSystemAcId = v_RefSystemAcId;
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
                                      FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND RefSystemAcId = v_RefSystemAcId
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
                                      FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT MIN(EntityKey)  

                                      INTO v_ExEntityKey
                                      FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )
                                              AND RefSystemAcId = v_RefSystemAcId
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM RBL_MISDB_PROD.AdvAcRestructureDetail_Mod 
                                     WHERE  EntityKey = v_ExEntityKey;
                                    UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                                       SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND RefSystemAcId = v_RefSystemAcId
                                      AND AuthorisationStatus = 'A';
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  RefSystemAcId = v_RefSystemAcId
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND RefSystemAcId = v_RefSystemAcId );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND RefSystemAcId = v_RefSystemAcId;

                                       END;
                                       END IF;

                                    END;
                                     -- END OF DELETE BLOCK
                                    ELSE

                                     -- OTHER THAN DELETE STATUS
                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved
                                        WHERE  RefSystemAcId = v_RefSystemAcId
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
                                                       FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND RefSystemAcId = v_RefSystemAcId );
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
                                                          FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND RefSystemAcId = v_RefSystemAcId );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE(v_AccountEntityId);
                                          UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                                             SET AccountEntityId = v_AccountEntityId,
                                                 RestructureTypeAlt_Key = v_RestructureTypeAlt_Key,
                                                 RestructureCatgAlt_Key = v_RestructureCatgAlt_Key,
                                                 RestructureProposalDt = v_RestructureProposalDt,
                                                 RestructureDt = UTILS.CONVERT_TO_VARCHAR2(v_RestructureDt,200,p_style=>103),
                                                 RestructureAmt = v_RestructureAmt,
                                                 ApprovingAuthAlt_Key = v_ApprovingAuthAlt_Key,
                                                 RestructureApprovalDt = v_RestructureApprovalDt,
                                                 RestructureSequenceRefNo = v_RestructureSequenceRefNo,
                                                 DiminutionAmount = v_DiminutionAmount,
                                                 RestructureByAlt_Key = v_RestructureByAlt_Key,
                                                 RefCustomerId = v_RefCustomerId,
                                                 RefSystemAcId = v_RefSystemAcId
                                                 --,Restructure_NPA_Dt     =@RestructureNPADate
                                                  --,AuthorisationStatus		=	@AuthorisationStatus
                                                  --,OverDueSinceDt			=	@OverDueSinceDt
                                                  --,BankApprovalDt			=	@BankApprovalDt
                                                  --,ForwardDt				=	@ForwardDt
                                                  -- ,Remark					=	@Remark
                                                  -- ,ChangeFields				=	@ChangeFields
                                                  --,PreRestrucDefaultDate	=	@PreRestrucDefaultDate
                                                  --,PreRestrucAssetClass		=	@PreRestrucAssetClass
                                                  --,PreRestrucNPA_Date		=	@PreRestrucNPA_Date
                                                  --,PostRestrucAssetClass	=	@PostRestrucAssetClass
                                                 ,
                                                 IntRepayStartDate = v_IntRepayStartDate,
                                                 RepaymentStartDate = v_PrinRepayStartDate,
                                                 RefDate = v_RefDate --(date,@RefDate ,103)
                                                 ,
                                                 InvocationDate = v_InvocationDate,
                                                 IsEquityCoversion = v_IsEquityCoversion,
                                                 ConversionDate = v_ConversionDate,
                                                 Is_COVID_Morat = v_Is_COVID_Morat,
                                                 COVID_OTR_Catg = v_COVID_OTR_Catg,
                                                 CRILIC_Fst_DefaultDate = v_CRILIC_Fst_DefaultDate,
                                                 FstDefaultReportingBank = v_FstDefaultReportingBank,
                                                 ICA_SignDate = v_ICA_SignDate,
                                                 Is_InvestmentGrade = v_Is_InvestmentGrade,
                                                 CreditProvision = v_CreditProvision,
                                                 DFVProvision = v_DFVProvision,
                                                 MTMProvision = v_MTMProvision,
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
                                                 NPA_Provision_per = v_NPA_Provision_per,
                                                 EquityConversionYN = v_EquityConversionYN
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND RefSystemAcId = v_RefSystemAcId;

                                       END;
                                       ELSE

                                       BEGIN
                                          v_IsSCD2 := 'Y' ;

                                       END;
                                       END IF;

                                    END;
                                    END IF;
                                    --alter table DimProvision_Seg_Mod
                                    --add AdditionalprovisionRBINORMS decimal(16,2)
                                    IF v_IsAvailable = 'N'
                                      OR v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       INSERT INTO CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                                         ( AccountEntityId, RestructureTypeAlt_Key, RestructureCatgAlt_Key, RestructureProposalDt, RestructureDt, RestructureAmt, ApprovingAuthAlt_Key, RestructureApprovalDt, RestructureSequenceRefNo, DiminutionAmount, RestructureByAlt_Key, RefCustomerId, RefSystemAcId
                                       --,Restructure_NPA_Dt     
                                       , AuthorisationStatus
                                       --,OverDueSinceDt
                                        --,BankApprovalDt
                                        --,ForwardDt
                                        -- ,Remark
                                        -- ,ChangeFields
                                        --,PreRestrucDefaultDate
                                        --,PreRestrucAssetClass
                                        --,PreRestrucNPA_Date
                                        --,PostRestrucAssetClass
                                       , IntRepayStartDate, RepaymentStartDate ---=  @PrinRepayStartDate    
                                       , RefDate, InvocationDate, IsEquityCoversion, ConversionDate, Is_COVID_Morat, COVID_OTR_Catg, CRILIC_Fst_DefaultDate, FstDefaultReportingBank, ICA_SignDate, Is_InvestmentGrade, CreditProvision, DFVProvision, MTMProvision, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, EffectiveFromTimeKey, EffectiveToTimeKey, RevisedBusinessSegment, BankingType, DisbursementDate, RestructureAssetClassAlt_key
                                       --,RestructureDate
                                       , Npa_Qtr, RestructurePOS, NPA_Provision_per, EquityConversionYN )
                                         ( SELECT v_AccountEntityId ,
                                                  v_RestructureTypeAlt_Key ,
                                                  v_RestructureCatgAlt_Key ,
                                                  v_RestructureProposalDt ,
                                                  --,@RestructureDt	
                                                  UTILS.CONVERT_TO_VARCHAR2(v_RestructureDt,200,p_style=>103) ,
                                                  v_RestructureAmt ,
                                                  v_ApprovingAuthAlt_Key ,
                                                  v_RestructureApprovalDt ,
                                                  v_RestructureSequenceRefNo ,
                                                  v_DiminutionAmount ,
                                                  v_RestructureByAlt_Key ,
                                                  v_RefCustomerId ,
                                                  v_RefSystemAcId ,
                                                  --,@RestructureNPADate
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN 'A'
                                                  ELSE NULL
                                                     END col  ,
                                                  -- ,@EffectiveFromTimeKey	
                                                  -- ,@EffectiveToTimeKey	
                                                  --,@CreatedBy	
                                                  -- ,@DateCreated	
                                                  -- ,@ModifiedBy	
                                                  --,@DateModified	
                                                  --,@ApprovedBy	
                                                  --,@DateApproved	
                                                  --,@D2Ktimestamp	
                                                  --,@OverDueSinceDt	
                                                  --,@BankApprovalDt	
                                                  --,@ForwardDt	
                                                  -- ,@Remark	
                                                  --,@ChangeFields	
                                                  --,@PreRestrucDefaultDate	
                                                  --,@PreRestrucAssetClass	
                                                  --,@PreRestrucNPA_Date	
                                                  --,@PostRestrucAssetClass	
                                                  v_IntRepayStartDate ,
                                                  v_PrinRepayStartDate ,
                                                  v_RefDate ,
                                                  --,convert(date,@RefDate ,103)	
                                                  v_InvocationDate ,
                                                  v_IsEquityCoversion ,
                                                  v_ConversionDate ,
                                                  v_Is_COVID_Morat ,
                                                  v_COVID_OTR_Catg ,
                                                  v_CRILIC_Fst_DefaultDate ,
                                                  v_FstDefaultReportingBank ,
                                                  v_ICA_SignDate ,
                                                  v_Is_InvestmentGrade ,
                                                  v_CreditProvision ,
                                                  v_DFVProvision ,
                                                  v_MTMProvision ,
                                                  v_CreatedBy ,
                                                  v_DateCreated ,
                                                  v_ModifiedBy ,
                                                  v_DateModified ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                                  ELSE NULL
                                                     END col  ,
                                                  CASE 
                                                       WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                  ELSE NULL
                                                     END col  ,
                                                  v_EffectiveFromTimeKey ,
                                                  v_EffectiveToTimeKey ,
                                                  v_RevisedBusinessSegment ,
                                                  v_BankingType ,
                                                  v_DisbursementDate ,
                                                  v_RestructureAssetClassAlt_key ,
                                                  --,@RestructureDate
                                                  v_Npa_Qtr ,
                                                  v_RestructurePOS ,
                                                  v_NPA_Provision_per ,
                                                  v_EquityConversionYN 
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND RefSystemAcId = v_RefSystemAcId
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO RestructureMaster_Insert;
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
         <<RestructureMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            INSERT INTO RBL_MISDB_PROD.AdvAcRestructureDetail_Mod
              ( AccountEntityId, RestructureTypeAlt_Key, RestructureCatgAlt_Key, RestructureProposalDt, RestructureDt, RestructureAmt, ApprovingAuthAlt_Key, RestructureApprovalDt, RestructureSequenceRefNo, DiminutionAmount, RestructureByAlt_Key, RefCustomerId, RefSystemAcId, Restructure_NPA_Dt, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
            --,D2Ktimestamp
             --,OverDueSinceDt
             --,BankApprovalDt
             --,ForwardDt
            , Remark, ChangeFields
            --,PreRestrucDefaultDate
             --,PreRestrucAssetClass
             --,PreRestrucNPA_Date
             --,PostRestrucAssetClass
            , IntRepayStartDate, RepaymentStartDate, RefDate, InvocationDate, IsEquityCoversion, ConversionDate, Is_COVID_Morat, COVID_OTR_Catg, CRILIC_Fst_DefaultDate, FstDefaultReportingBank, ICA_SignDate, Is_InvestmentGrade, CreditProvision, DFVProvision, MTMProvision, RevisedBusinessSegment, BankingType, DisbursementDate, RestructureAssetClassAlt_key
            --,RestructureDate
            , Npa_Qtr, RestructurePOS, NPA_Provision_per, EquityConversionYN )
              VALUES ( v_AccountEntityId, v_RestructureTypeAlt_Key, v_RestructureCatgAlt_Key, v_RestructureProposalDt, UTILS.CONVERT_TO_VARCHAR2(
            --,@RestructureDt	
            v_RestructureDt,200,p_style=>103), v_RestructureAmt, v_ApprovingAuthAlt_Key, v_RestructureApprovalDt, v_RestructureSequenceRefNo, v_DiminutionAmount, v_RestructureByAlt_Key, v_RefCustomerId, v_RefSystemAcId, v_RestructureNPADate, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, v_DateCreated, CASE 
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
               END, 
            --,@D2Ktimestamp	

            --,@OverDueSinceDt	

            --,@BankApprovalDt	

            --,@ForwardDt	
            v_Remark, v_ChangeFields, 
            --,@PreRestrucDefaultDate	

            --,@PreRestrucAssetClass	

            --,@PreRestrucNPA_Date	

            --,@PostRestrucAssetClass	
            v_IntRepayStartDate, v_PrinRepayStartDate, v_RefDate, 
            --,convert(date,@RefDate ,103)	
            v_InvocationDate, v_IsEquityCoversion, v_ConversionDate, v_Is_COVID_Morat, v_COVID_OTR_Catg, v_CRILIC_Fst_DefaultDate, v_FstDefaultReportingBank, v_ICA_SignDate, v_Is_InvestmentGrade, v_CreditProvision, v_DFVProvision, v_MTMProvision, v_RevisedBusinessSegment, v_BankingType, v_DisbursementDate, v_RestructureAssetClassAlt_key, 
            --,@RestructureDate
            v_Npa_Qtr, v_RestructurePOS, v_NPA_Provision_per, v_EquityConversionYN );
            --,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
            --,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
            --,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
            --,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE(3);
               GOTO RestructureMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO RestructureMaster_Insert_Edit_Delete;

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
                v_ReferenceID => v_RefSystemAcId -- ReferenceID ,
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
                v_ReferenceID => v_RefSystemAcId -- ReferenceID ,
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RESTUCTUREMASTER_INUP_28072023" TO "ADF_CDR_RBL_STGDB";
