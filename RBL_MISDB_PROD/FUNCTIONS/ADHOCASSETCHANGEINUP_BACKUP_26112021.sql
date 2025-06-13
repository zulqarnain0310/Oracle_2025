--------------------------------------------------------
--  DDL for Function ADHOCASSETCHANGEINUP_BACKUP_26112021
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[ValuationSourceDropDown]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[ValuationSourceDropDown]--D
 --GO
 --/****** Object:  StoredProcedure [dbo].[ValidateExcel_DataUpload_ColletralUpload]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[ValidateExcel_DataUpload_ColletralUpload] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[ColletralUploadDataInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[ColletralUploadDataInUp]  --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[CollateralValueSearchList]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[CollateralValueSearchList] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[CollateralValueInsert]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[CollateralValueInsert] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[CollateralMgmtSearchList]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[CollateralMgmtSearchList] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[CollateralMgmtInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[CollateralMgmtInUp] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[AdhocAssetClassViewDetail]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[AdhocAssetClassViewDetail] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[ADHOCASSETCLASSQuickSearchList]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[ADHOCASSETCLASSQuickSearchList] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[AdhocAssetChangeInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
 --DROP PROCEDURE [dbo].[AdhocAssetChangeInUp] --D
 --GO
 --/****** Object:  StoredProcedure [dbo].[AdhocAssetChangeInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

(
  --Declare
  v_UCIF_ID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_AssetclassAlt_key IN NUMBER,
  iv_NpaDate IN VARCHAR2 DEFAULT ' ' ,
  v_Reasonforchange IN VARCHAR2 DEFAULT ' ' ,
  v_ChangeTypeAlt_Key IN VARCHAR2 DEFAULT ' ' ,
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
  v_OldUCIF_ID IN VARCHAR2 DEFAULT ' ' ,
  --,@TotCollateralsUCICCustAcc VARCHAR(5)	=''
  v_IfPercentagevalue_or_Absolutevalue IN NUMBER DEFAULT 0 ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_NpaDate VARCHAR2(10) := iv_NpaDate;
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_CustomerName VARCHAR2(200) := iv_CustomerName;
   --	DECLARE @Parameter varchar(max) = (select 'AccountID|' + ISNULL(@AccountID,' ') + '}'+ 'UCICID|' + isnull(@UCICID,' ')
   --+ '}'+ 'CustomerID|'+isnull(@CustomerID,'')+ '}'+ 'CustomerName|'+isnull(@CustomerName,'')
   --+ '}'+ 'TaggingAlt_Key|'+convert(VARCHAR,isnull(@TaggingAlt_Key,''))
   --+ '}'+ 'DistributionAlt_Key|'+convert(VARCHAR,isnull(@DistributionAlt_Key,''))
   --+ '}'+ 'UCIF_ID|'+isnull(@UCIF_ID,'')
   --+ '}'+ 'CollateralTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralTypeAlt_Key,''))
   --+ '}'+ 'CollateralSubTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralSubTypeAlt_Key,''))
   --+ '}'+ 'CollateralOwnerTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralOwnerTypeAlt_Key,''))
   --+ '}'+ 'CollateralOwnerShipTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralOwnerShipTypeAlt_Key,''))
   --+ '}'+ 'ChargeTypeAlt_Key|'+convert(VARCHAR,isnull(@ChargeTypeAlt_Key,''))
   --+ '}'+ 'ChargeNatureAlt_Key|'+convert(VARCHAR,isnull(@ChargeNatureAlt_Key,''))
   --+ '}'+ 'ShareAvailabletoBankAlt_Key|'+convert(VARCHAR,isnull(@ShareAvailabletoBankAlt_Key,''))
   --+ '}'+ 'CollateralShareamount|'+convert(VARCHAR,isnull(@CollateralShareamount,'')))
   ----DECLARE		@Result					INT				=0 
   --exec SecurityCheckDataValidation 14610 ,@Parameter,@Result OUTPUT
   --IF @Result = -1
   --return -1
   --FirstLevelDateApproved 
   --	FirstLevelApprovedBy  
   v_AuthorisationStatus VARCHAR2(5) := NULL;
   v_CreatedBy VARCHAR2(20) := NULL;
   v_DateCreated DATE := NULL;
   v_ModifiedBy VARCHAR2(20) := NULL;
   v_ModifyBy VARCHAR2(20) := NULL;
   v_DateModified DATE := NULL;
   v_ApprovedBy VARCHAR2(20) := NULL;
   v_DateApproved DATE := NULL;
   v_ApprovedByFirstLevel VARCHAR2(20) := NULL;
   v_DateApprovedFirstLevel DATE := NULL;
   v_FirstLevelApprovedBy VARCHAR2(20) := NULL;
   v_FirstLevelDateApproved DATE := NULL;
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   v_AccountEntityId NUMBER(10,0) := 0;
   v_CustomerEntityId NUMBER(10,0) := 0;
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_CollIDAutoGenerated NUMBER(10,0);
   v_SecurityEntityID NUMBER(5,0);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_NpaDate := CASE 
                     WHEN v_NpaDate = ' ' THEN NULL
   ELSE UTILS.CONVERT_TO_VARCHAR2(v_NpaDate,200)
      END ;
   v_ScreenName := 'Collateral' ;
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   SELECT CustomerName 

     INTO v_CustomerName
     FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
    WHERE  UCIF_ID = v_UCIF_ID;
   --SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
   DBMS_OUTPUT.PUT_LINE('A');
   v_NpaDate := CASE 
                     WHEN ( v_NpaDate = ' '
                       OR v_NpaDate = '01/01/1900'
                       OR v_NpaDate = '1900/01/01' ) THEN NULL
   ELSE v_NpaDate
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
   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         -----
         DBMS_OUTPUT.PUT_LINE(3);
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
               OPEN  v_cursor FOR
                  SELECT * --@SecurityEntityID=SecurityEntityID

                    FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND UCIF_ID = v_UCIF_ID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

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
              FROM AdhocACL_ChangeDetails 

            --select * from AdhocACL_ChangeDetails 
            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                     AND EffectiveToTimeKey >= v_TimeKey )
                     AND UCIF_ID = v_UCIF_ID;
            ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
            IF NVL(v_CreatedBy, ' ') = ' ' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM AdhocACL_ChangeDetails_Mod 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND UCIF_ID = v_UCIF_ID
                         AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
               ;

            END;
            ELSE

             ---IF DATA IS AVAILABLE IN MAIN TABLE
            BEGIN
               DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
               ----UPDATE FLAG IN MAIN TABLES AS MP
               UPDATE AdhocACL_ChangeDetails
                  SET AuthorisationStatus = v_AuthorisationStatus
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND UCIF_ID = v_UCIF_ID;

            END;
            END IF;
            --UPDATE NP,MP  STATUS 
            IF v_OperationFlag = 2 THEN

            BEGIN
               UPDATE AdhocACL_ChangeDetails_Mod
                  SET AuthorisationStatus = 'FM',
                      ModifyBy = v_ModifyBy,
                      DateModified = v_DateModified
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND UCIF_ID = v_UCIF_ID
                 AND AuthorisationStatus IN ( 'NP','MP','RM' )
               ;

            END;
            END IF;
            GOTO Collateral_Insert;
            <<Collateral_Insert_Edit_Delete>>

         END;
         ELSE
            IF v_OperationFlag = 3
              AND v_AuthMode = 'N' THEN

            BEGIN
               -- DELETE WITHOUT MAKER CHECKER
               v_Modifiedby := v_CrModApBy ;
               v_DateModified := SYSDATE ;
               UPDATE AdhocACL_ChangeDetails
                  SET ModifyBy = v_ModifyBy,
                      DateModified = v_DateModified,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND UCIF_ID = v_UCIF_ID;

            END;

            ----------------------------------------------------------------------------------
            ELSE
               IF v_OperationFlag = 21
                 AND v_AuthMode = 'Y' THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  v_ApprovedBy := v_CrModApBy ;
                  v_DateApproved := SYSDATE ;
                  UPDATE AdhocACL_ChangeDetails_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_ApprovedBy,
                         DateApproved = v_DateApproved,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UCIF_ID = v_UCIF_ID
                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                  ;
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM AdhocACL_ChangeDetails 
                                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND UCIF_ID = v_UCIF_ID );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     UPDATE AdhocACL_ChangeDetails
                        SET AuthorisationStatus = 'A'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND UCIF_ID = v_UCIF_ID
                       AND AuthorisationStatus IN ( 'MP','DP','RM' )
                     ;

                  END;
                  END IF;

               END;

               ---------------------------------------------------------------------------------------------	
               ELSE
                  IF v_OperationFlag = 17
                    AND v_AuthMode = 'Y' THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE AdhocACL_ChangeDetails_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND UCIF_ID = v_UCIF_ID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                     DBMS_OUTPUT.PUT_LINE('Sunil');
                     --		DECLARE @EntityKey as Int 
                     --SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
                     --					 FROM DimGL_Mod 
                     --						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
                     --							AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
                     --	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
                     --,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
                     --------------------------------
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM AdhocACL_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND UCIF_ID = v_UCIF_ID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE AdhocACL_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UCIF_ID = v_UCIF_ID
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
                        UPDATE AdhocACL_ChangeDetails_Mod
                           SET AuthorisationStatus = 'RM'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                          AND UCIF_ID = v_UCIF_ID;

                     END;
                     ELSE
                        IF v_OperationFlag = 16 THEN

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           --SET @ApprovedByFirstLevel	   = @CrModApBy 
                           --SET @DateApprovedFirstLevel  = GETDATE()
                           v_FirstLevelDateApproved := SYSDATE ;
                           v_FirstLevelApprovedBy := v_CrModApBy ;
                           --select * from AdhocACL_ChangeDetails_MOD
                           UPDATE AdhocACL_ChangeDetails_Mod
                              SET AuthorisationStatus = '1A',
                                  FirstLevelApprovedBy = v_ApprovedBy,
                                  FirstLevelDateApproved = v_DateApproved
                            WHERE  UCIF_ID = v_UCIF_ID
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
                                      FROM AdhocACL_ChangeDetails 
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey )
                                              AND UCIF_ID = v_UCIF_ID;
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
                                   FROM AdhocACL_ChangeDetails_Mod 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey )
                                           AND UCIF_ID = v_UCIF_ID
                                           AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                 ;
                                 SELECT AuthorisationStatus ,
                                        CreatedBy ,
                                        DATECreated ,
                                        ModifyBy ,
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
                                   FROM AdhocACL_ChangeDetails_Mod 
                                  WHERE  EntityKey = v_ExEntityKey;
                                 v_ApprovedBy := v_CrModApBy ;
                                 v_DateApproved := SYSDATE ;
                                 SELECT MIN(EntityKey)  

                                   INTO v_ExEntityKey
                                   FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey )
                                           AND UCIF_ID = v_UCIF_ID
                                           AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                 ;
                                 SELECT EffectiveFromTimeKey 

                                   INTO v_CurrRecordFromTimeKey
                                   FROM RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod 
                                  WHERE  EntityKey = v_ExEntityKey;
                                 DBMS_OUTPUT.PUT_LINE('SacExpire');
                                 DBMS_OUTPUT.PUT_LINE('@EffectiveFromTimeKey');
                                 DBMS_OUTPUT.PUT_LINE(v_EffectiveFromTimeKey);
                                 DBMS_OUTPUT.PUT_LINE('@Timekey');
                                 DBMS_OUTPUT.PUT_LINE(v_Timekey);
                                 DBMS_OUTPUT.PUT_LINE('@UCIF_ID');
                                 DBMS_OUTPUT.PUT_LINE(v_UCIF_ID);
                                 UPDATE RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod
                                    SET EffectiveToTimeKey = EffectiveFromTimeKey - 1
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                   AND EffectiveToTimeKey >= v_Timekey )
                                   AND UCIF_ID = v_UCIF_ID
                                   AND AuthorisationStatus = 'A';
                                 -------DELETE RECORD AUTHORISE
                                 IF v_DelStatus = 'DP' THEN
                                  DECLARE
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    UPDATE RBL_MISDB_PROD.AdhocACL_ChangeDetails_Mod
                                       SET AuthorisationStatus = 'A',
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved,
                                           EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                     WHERE  UCIF_ID = v_UCIF_ID
                                      AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE EXISTS ( SELECT 1 
                                                       FROM AdhocACL_ChangeDetails 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND UCIF_ID = v_UCIF_ID );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN

                                    BEGIN
                                       UPDATE AdhocACL_ChangeDetails
                                          SET AuthorisationStatus = 'A',
                                              ModifyBy = v_ModifyBy,
                                              DateModified = v_DateModified,
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND UCIF_ID = v_UCIF_ID;

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
                                    UPDATE AdhocACL_ChangeDetails_Mod
                                       SET AuthorisationStatus = 'A',
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved
                                     WHERE  UCIF_ID = v_UCIF_ID
                                      AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                    ;

                                 END;
                                 END IF;

                              END;
                              END IF;
                              --select * from dbo.AdhocACL_ChangeDetails_Mod
                              IF v_DelStatus <> 'DP'
                                OR v_AuthMode = 'N' THEN
                               DECLARE
                                 v_IsAvailable CHAR(1) := 'N';
                                 v_IsSCD2 CHAR(1) := 'N';
                                 v_temp NUMBER(1, 0) := 0;

                              BEGIN
                                 DBMS_OUTPUT.PUT_LINE('Check');
                                 v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                                 BEGIN
                                    SELECT 1 INTO v_temp
                                      FROM DUAL
                                     WHERE EXISTS ( SELECT 1 
                                                    FROM AdhocACL_ChangeDetails 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND UCIF_ID = v_UCIF_ID );
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
                                                       FROM AdhocACL_ChangeDetails 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND EffectiveFromTimeKey = v_TimeKey
                                                                 AND UCIF_ID = v_UCIF_ID );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN

                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('BBBB');
                                       DBMS_OUTPUT.PUT_LINE('@UCIF_ID');
                                       DBMS_OUTPUT.PUT_LINE(v_UCIF_ID);
                                       UPDATE AdhocACL_ChangeDetails
                                          SET UCIF_ID = v_UCIF_ID,
                                              CustomerId = v_CustomerID,
                                              CustomerName = v_CustomerName,
                                              AssetClassAlt_Key = v_AssetClassAlt_Key,
                                              NPA_Date = CASE 
                                                              WHEN v_NpaDate = ' ' THEN NULL
                                              ELSE v_NpaDate
                                                 END,
                                              Reason = v_Reasonforchange,
                                              FirstLevelApprovedBy = v_ApprovedByFirstLevel,
                                              FirstLevelDateApproved = v_DateApprovedFirstLevel,
                                              ChangeType = v_ChangeTypeAlt_Key,
                                              ModifyBy = v_ModifyBy,
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
                                         AND UCIF_ID = v_UCIF_ID;

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
                                    DBMS_OUTPUT.PUT_LINE('@DateCreated');
                                    DBMS_OUTPUT.PUT_LINE(UTILS.CONVERT_TO_DATETIME(v_DateCreated));
                                    INSERT INTO AdhocACL_ChangeDetails
                                      ( UCIF_ID, CustomerId, CustomerEntityId, CustomerName, AssetClassAlt_Key, NPA_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, DateCreated, CreatedBy, DateModified, ModifyBy, DateApproved, ApprovedBy, Reason, FirstLevelDateApproved, FirstLevelApprovedBy, ChangeType )
                                      ( SELECT v_UCIF_ID ,
                                               v_CustomerId ,
                                               v_CustomerEntityId ,
                                               v_CustomerName ,
                                               v_AssetClassAlt_Key ,
                                               CASE 
                                                    WHEN v_NpaDate = ' ' THEN NULL
                                               ELSE v_NpaDate
                                                  END col  ,
                                               v_AuthorisationStatus ,
                                               v_EffectiveFromTimeKey ,
                                               v_EffectiveToTimeKey ,
                                               v_DateCreated ,
                                               v_CreatedBy ,
                                               v_DateModified ,
                                               ' ' ,
                                               v_DateApproved ,
                                               v_ApprovedBy ,
                                               v_Reasonforchange ,
                                               v_DateApprovedFirstLevel ,
                                               v_ApprovedByFirstLevel ,
                                               v_ChangeTypeAlt_Key 
                                          FROM DUAL  );

                                 END;
                                 END IF;
                                 MERGE INTO A 
                                 USING (SELECT A.ROWID row_id, B.UcifEntityID, B.CustomerEntityId
                                 FROM A ,AdhocACL_ChangeDetails A
                                        JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.UCIF_ID = B.UCIF_ID ) src
                                 ON ( A.ROWID = src.row_id )
                                 WHEN MATCHED THEN UPDATE SET A.UcifEntityID = src.UcifEntityID,
                                                              A.CustomerEntityId = src.CustomerEntityId;
                                 --IF (@CollateralOwnerShipTypeAlt_Key=1)
                                 --	BEGIN 
                                 --		Update CollateralOtherOwner
                                 --		SET EffectiveToTimeKey=EffectiveFromTimeKey-1
                                 --		Where   UCIF_ID=@UCIF_ID  and EffectiveFromTimeKey=@EffectiveFromTimeKey and EffectiveToTimeKey=@EffectiveToTimeKey
                                 --	END
                                 -----------------Added on 13-03-2021
                                 ------------------------------------------------------
                                 ----------------------------------------------------------------------------------------------------
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    UPDATE AdhocACL_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AUTHMODE = 'Y' THEN 'A'
                                           ELSE NULL
                                              END
                                     WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND UCIF_ID = v_UCIF_ID
                                      AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                 END;
                                 END IF;

                              END;
                              END IF;
                              IF v_AUTHMODE = 'N' THEN

                              BEGIN
                                 v_AuthorisationStatus := 'A' ;
                                 GOTO Collateral_Insert;
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
         DBMS_OUTPUT.PUT_LINE(6);
         v_ErrorHandle := 1 ;
         <<Collateral_Insert>>
         IF v_ErrorHandle = 0 THEN
          DECLARE
            v_AccountExist NUMBER(10,0) := 0;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('@SecurityEntityIDSac');
            DBMS_OUTPUT.PUT_LINE(v_SecurityEntityID);
            SELECT 1 

              INTO v_AccountExist
              FROM AdhocACL_ChangeDetails 
             WHERE  UCIF_ID = v_UCIF_ID;
            INSERT INTO AdhocACL_ChangeDetails_Mod
              ( UCIF_ID, CustomerId, CustomerEntityId, CustomerName, AssetClassAlt_Key, NPA_Date, Remark, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, DateCreated, CreatedBy, DateModified, ModifyBy, DateApproved, ApprovedBy, Reason, FirstLevelDateApproved, FirstLevelApprovedBy, ChangeType )
              VALUES ( v_UCIF_ID, v_CustomerId, v_CustomerEntityId, v_CustomerName, v_AssetClassAlt_Key, CASE 
                                                                                                              WHEN v_NpaDate = ' ' THEN NULL
            ELSE v_NpaDate
               END, v_Remark, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, TO_DATE(CASE 
                                                                                                                WHEN v_AccountExist = 1 THEN v_DateModified
            ELSE v_DateCreated
               END,'dd/mm/yyyy'), CASE 
                                       WHEN v_AccountExist = 1 THEN v_ModifiedBy
            ELSE v_CreatedBy
               END, TO_DATE(v_DateModified,'dd/mm/yyyy'), v_ModifiedBy, TO_DATE(v_DateApproved,'dd/mm/yyyy'), v_ApprovedBy, v_Reasonforchange, TO_DATE(v_ApprovedByFirstLevel,'dd/mm/yyyy'), v_DateApprovedFirstLevel, v_ChangeTypeAlt_Key );
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.UcifEntityID, B.CustomerEntityId
            FROM A ,AdhocACL_ChangeDetails_Mod A
                   JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.UCIF_ID = B.UCIF_ID ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.UcifEntityID = src.UcifEntityID,
                                         A.CustomerEntityId = src.CustomerEntityId;
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
                  GOTO Collateral_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -------------------
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
         --															AND GLAlt_Key=@GLAlt_Key
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCHANGEINUP_BACKUP_26112021" TO "ADF_CDR_RBL_STGDB";
