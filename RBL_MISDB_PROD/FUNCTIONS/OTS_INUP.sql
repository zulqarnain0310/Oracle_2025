--------------------------------------------------------
--  DDL for Function OTS_INUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."OTS_INUP" 
(
  --Declare
  v_Account_ID IN VARCHAR2 DEFAULT ' ' ,
  v_Date_Approval_Settlement IN VARCHAR2 DEFAULT ' ' ,
  v_Approving_Authority IN VARCHAR2 DEFAULT ' ' ,
  v_Principal_OS IN NUMBER DEFAULT NULL ,
  v_Interest_Due_time_Settlement IN NUMBER DEFAULT NULL ,
  v_Fees_Charges_Settlement IN NUMBER DEFAULT NULL ,
  v_Total_Dues_Settlement IN NUMBER DEFAULT NULL ,
  v_Settlement_Amount IN NUMBER DEFAULT NULL ,
  v_Principal_Sacrifice IN NUMBER DEFAULT NULL ,
  v_Interest_Waiver IN NUMBER DEFAULT NULL ,
  v_Fees_Waiver IN NUMBER DEFAULT NULL ,
  v_Total_Amount_Sacrificed_Waived IN NUMBER DEFAULT NULL ,
  v_Settlement_Failure IN VARCHAR2 DEFAULT ' ' ,
  --,@Actual_Write_Off_Amount decimal(18,2)=null--,@Actual_Write_Off_Date varchar(20)=''
  v_Account_Closure_Date IN VARCHAR2 DEFAULT ' ' ,
  v_OTS_AWO_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  ---------D2k System Common Columns		--
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  --,@MenuID					SMALLINT		= 0  change to Int
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_AuthMode IN CHAR DEFAULT 'Y' ,
  v_Authlevel IN VARCHAR2 DEFAULT ' ' ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  iv_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT 'Admin' ,
  v_ScreenEntityId IN NUMBER DEFAULT NULL ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0) := iv_TimeKey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   ------------- Security Check--------
   --DECLARE @Parameter varchar(max) = (select 'MOCInitializeDate|' + ISNULL(@MOCInitializeDate,' ') + '}'+ 'GLDescription|' + isnull(@GLDescription,' '))
   ----DECLARE		@Result					INT				=0 
   --exec SecurityCheckDataValidation 14550 ,@Parameter,@Result OUTPUT
   --IF @Result = -1
   --	return -1
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
   ------------Added for Rejection Screen  29/06/2020   ----------
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_MOC_Initialized_Date VARCHAR2(20) := NULL;
   v_AccountEntityID NUMBER(19,0);
   v_CustomerEntityID NUMBER(19,0);
   v_RefCustomerid VARCHAR2(30);
   --declare @Assetclass int
   --set  @Assetclass = (select Cust_AssetClassAlt_Key from curdat.AdvCustNpaDetail where CustomerEntityId=@CustomerEntityID
   --                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
   --declare @NPA_Date Date
   --set  @NPA_Date = (select NPADt from curdat.AdvCustNpaDetail where CustomerEntityId=@CustomerEntityID
   --                           AND  EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey)
   v_AssetclassAltKey NUMBER(10,0);
   v_NPA_Date VARCHAR2(200);
   v_temp NUMBER(1, 0) := 0;
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   v_ScreenName := 'OTS' ;
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
    WHERE  CustomerACID = v_Account_ID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   SELECT CustomerEntityId 

     INTO v_CustomerEntityID
     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
    WHERE  CustomerACID = v_Account_ID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   SELECT RefCustomerId 

     INTO v_RefCustomerid
     FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
    WHERE  CustomerACID = v_Account_ID
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(DISTINCT ACL_Sttlement)  
               FROM OTS_Details_Mod 
                WHERE  AccountEntityId = v_AccountEntityID
                         AND EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey ) > 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      SELECT ACL_Sttlement 

        INTO v_AssetclassAltKey
        FROM OTS_Details_Mod 
       WHERE  AccountEntityId = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      SELECT NPA_Date 

        INTO v_NPA_Date
        FROM OTS_Details_Mod 
       WHERE  AccountEntityId = v_AccountEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;

   END;
   ELSE

   BEGIN
      SELECT Cust_AssetClassAlt_Key 

        INTO v_AssetclassAltKey
        FROM RBL_MISDB_PROD.AdvCustNPADetail 
       WHERE  CustomerEntityId = v_CustomerEntityID
                AND EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey;
      SELECT NPADt 

        INTO v_NPA_Date
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
                         FROM OTS_Details 
                          WHERE  RefCustomerAcid = v_Account_ID
                                   AND NVL(AuthorisationStatus, 'A') = 'A'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey
                         UNION 
                         SELECT 1 
                         FROM OTS_Details_Mod 
                          WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey )
                                   AND RefCustomerAcid = v_Account_ID
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
         DBMS_OUTPUT.PUT_LINE(3);

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
            GOTO MOCFreezeDateMaster_Insert;
            <<MOCFreezeDateMaster_Insert_Add>>

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
                 FROM OTS_Details 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND RefCustomerAcid = v_Account_ID;
               ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
               IF NVL(v_CreatedBy, ' ') = ' ' THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
                  SELECT CreatedBy ,
                         DateCreated 

                    INTO v_CreatedBy,
                         v_DateCreated
                    FROM OTS_Details_Mod 
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey )
                            AND RefCustomerAcid = v_Account_ID
                            AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
                  ;

               END;
               ELSE

                ---IF DATA IS AVAILABLE IN MAIN TABLE
               BEGIN
                  DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
                  ----UPDATE FLAG IN MAIN TABLES AS MP
                  UPDATE OTS_Details
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND RefCustomerAcid = v_Account_ID;

               END;
               END IF;
               --UPDATE NP,MP  STATUS 
               IF v_OperationFlag = 2 THEN

               BEGIN
                  UPDATE OTS_Details_Mod
                     SET AuthorisationStatus = 'FM',
                         ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND RefCustomerAcid = v_Account_ID
                    AND AuthorisationStatus IN ( 'NP','MP','RM' )
                  ;

               END;
               END IF;
               GOTO MOCFreezeDateMaster_Insert;
               <<MOCFreezeDateMaster_Insert_Edit_Delete>>

            END;
            ELSE
               IF v_OperationFlag = 3
                 AND v_AuthMode = 'N' THEN

               BEGIN
                  -- DELETE WITHOUT MAKER CHECKER
                  v_Modifiedby := v_CrModApBy ;
                  v_DateModified := SYSDATE ;
                  UPDATE OTS_Details_Mod
                     SET ModifiedBy = v_Modifiedby,
                         DateModified = v_DateModified,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND RefCustomerAcid = v_Account_ID;

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
                                                         AND UserLoginID = v_CrModApBy
                                                         AND EffectiveToTimeKey = 49999
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
                                                 FROM OTS_Details_Mod 
                                                  WHERE  CreatedBy = v_CrModApBy
                                                           AND RefCustomerAcid = v_Account_ID
                                                           AND AuthorisationStatus = '1A'
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
                        BEGIN
                           SELECT 1 INTO v_temp
                             FROM DUAL
                            WHERE ( v_CrModApBy = ( SELECT ApprovedBy 
                                                    FROM OTS_Details_Mod 
                                                     WHERE  ApprovedBy = v_CrModApBy
                                                              AND RefCustomerAcid = v_Account_ID
                                                              AND AuthorisationStatus = '1A'
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

                        --select createdby,* from DimBranch_Mod
                        ELSE
                        DECLARE
                           v_temp NUMBER(1, 0) := 0;

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           UPDATE OTS_Details_Mod
                              SET AuthorisationStatus = 'R',
                                  ApprovedBy = v_ApprovedBy,
                                  DateApproved = v_DateApproved,
                                  EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND RefCustomerAcid = v_Account_ID
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                           ;
                           BEGIN
                              SELECT 1 INTO v_temp
                                FROM DUAL
                               WHERE EXISTS ( SELECT 1 
                                              FROM OTS_Details 
                                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                        AND EffectiveToTimeKey >= v_Timekey )
                                                        AND RefCustomerAcid = v_Account_ID );
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           IF v_temp = 1 THEN

                           BEGIN
                              UPDATE OTS_Details
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                AND EffectiveToTimeKey >= v_TimeKey )
                                AND RefCustomerAcid = v_Account_ID
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
                                                    FROM OTS_Details_Mod 
                                                     WHERE  CreatedBy = v_CrModApBy
                                                              AND RefCustomerAcid = v_Account_ID
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
                        END IF;
                        --select createdby,* from DimBranch_Mod
                        v_ApprovedBy := v_CrModApBy ;
                        v_DateApproved := SYSDATE ;
                        UPDATE OTS_Details_Mod
                           SET AuthorisationStatus = 'R',
                               FirstLevelApprovedBy = v_ApprovedBy,
                               FirstLevelDateApproved = v_DateApproved,
                               EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND RefCustomerAcid = v_Account_ID
                          AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                        ;
                        ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------
                        DBMS_OUTPUT.PUT_LINE('PRASHANT');
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
                                           FROM OTS_Details 
                                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                     AND EffectiveToTimeKey >= v_Timekey )
                                                     AND RefCustomerAcid = v_Account_ID );
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_temp = 1 THEN

                        BEGIN
                           UPDATE OTS_Details
                              SET AuthorisationStatus = 'A'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND RefCustomerAcid = v_Account_ID
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
                           UPDATE OTS_Details_Mod
                              SET AuthorisationStatus = 'RM'
                            WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                             AND EffectiveToTimeKey >= v_TimeKey )
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND RefCustomerAcid = v_Account_ID;

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
                                                          FROM OTS_Details_Mod 
                                                           WHERE  AuthorisationStatus IN ( 'NP','MP' )

                                                                    AND CreatedBy = v_CrModApBy
                                                                    AND RefCustomerAcid = v_Account_ID
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
                              END IF;
                              --select * from DimBranch_Mod
                              DBMS_OUTPUT.PUT_LINE('Prashant1');
                              v_ApprovedBy := v_CrModApBy ;
                              v_DateApproved := SYSDATE ;
                              v_ApprovedByFirstLevel := v_CrModApBy ;
                              v_DateApprovedFirstLevel := SYSDATE ;
                              UPDATE OTS_Details_Mod
                                 SET AuthorisationStatus = '1A',
                                     FirstLevelApprovedBy = v_ApprovedBy,
                                     FirstLevelDateApproved = v_DateApproved
                               WHERE  RefCustomerAcid = v_Account_ID
                                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                              ;

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
                                                                     AND UserLoginID = v_CrModApBy
                                                                     AND EffectiveToTimeKey = 49999
                                                             GROUP BY UserLoginID );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('Sac1');
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
                                                             FROM OTS_Details_Mod 
                                                              WHERE  AuthorisationStatus IN ( '1A' )

                                                                       AND CreatedBy = v_CrModApBy
                                                                       AND RefCustomerAcid = v_Account_ID
                                                                       AND EffectiveToTimeKey = 49999
                                                               GROUP BY CreatedBy ) );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('Sac2');
                                    v_Result := -1 ;
                                    ROLLBACK;
                                    utils.resetTrancount;
                                    RETURN v_Result;

                                 END;
                                 ELSE
                                 DECLARE
                                    v_temp NUMBER(1, 0) := 0;

                                 BEGIN
                                    BEGIN
                                       SELECT 1 INTO v_temp
                                         FROM DUAL
                                        WHERE ( v_CrModApBy = ( SELECT ApprovedBy 
                                                                FROM OTS_Details_Mod 
                                                                 WHERE  AuthorisationStatus IN ( '1A' )

                                                                          AND ApprovedBy = v_CrModApBy
                                                                          AND RefCustomerAcid = v_Account_ID
                                                                          AND EffectiveToTimeKey = 49999
                                                                  GROUP BY ApprovedBy ) );
                                    EXCEPTION
                                       WHEN OTHERS THEN
                                          NULL;
                                    END;

                                    IF v_temp = 1 THEN

                                    BEGIN
                                       DBMS_OUTPUT.PUT_LINE('Sac3');
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
                                               FROM OTS_Details 
                                              WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                       AND EffectiveToTimeKey >= v_TimeKey )
                                                       AND RefCustomerAcid = v_Account_ID;
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
                                            FROM OTS_Details_Mod 
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey )
                                                    AND RefCustomerAcid = v_Account_ID
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
                                            FROM OTS_Details_Mod 
                                           WHERE  EntityKey = v_ExEntityKey;
                                          v_ApprovedBy := v_CrModApBy ;
                                          v_DateApproved := SYSDATE ;
                                          SELECT MIN(EntityKey)  

                                            INTO v_ExEntityKey
                                            FROM OTS_Details_Mod 
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                    AND EffectiveToTimeKey >= v_Timekey )
                                                    AND RefCustomerAcid = v_Account_ID
                                                    AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                          ;
                                          SELECT EffectiveFromTimeKey 

                                            INTO v_CurrRecordFromTimeKey
                                            FROM OTS_Details_Mod 
                                           WHERE  EntityKey = v_ExEntityKey;
                                          UPDATE OTS_Details_Mod
                                             SET EffectiveToTimeKey = v_CurrRecordFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND RefCustomerAcid = v_Account_ID
                                            AND AuthorisationStatus = 'A';
                                          -------DELETE RECORD AUTHORISE
                                          IF v_DelStatus = 'DP' THEN
                                           DECLARE
                                             v_temp NUMBER(1, 0) := 0;

                                          BEGIN
                                             UPDATE OTS_Details_Mod
                                                SET AuthorisationStatus = 'A',
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved,
                                                    EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                              WHERE  RefCustomerAcid = v_Account_ID
                                               AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                             ;
                                             BEGIN
                                                SELECT 1 INTO v_temp
                                                  FROM DUAL
                                                 WHERE EXISTS ( SELECT 1 
                                                                FROM OTS_Details 
                                                                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                          AND EffectiveToTimeKey >= v_TimeKey )
                                               AND RefCustomerAcid = v_Account_ID );
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   NULL;
                                             END;

                                             IF v_temp = 1 THEN

                                             BEGIN
                                                UPDATE OTS_Details
                                                   SET AuthorisationStatus = 'A',
                                                       ModifiedBy = v_ModifiedBy,
                                                       DateModified = v_DateModified,
                                                       ApprovedBy = v_ApprovedBy,
                                                       DateApproved = v_DateApproved,
                                                       EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                                 WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND RefCustomerAcid = v_Account_ID;

                                             END;
                                             END IF;

                                          END;
                                           -- END OF DELETE BLOCK
                                          ELSE

                                           -- OTHER THAN DELETE STATUS
                                          BEGIN
                                             UPDATE OTS_Details_Mod
                                                SET AuthorisationStatus = 'A',
                                                    ApprovedBy = v_ApprovedBy,
                                                    DateApproved = v_DateApproved
                                              WHERE  RefCustomerAcid = v_Account_ID
                                               AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                             ;

                                          END;
                                          END IF;

                                       END;
                                       END IF;

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
                                                       FROM OTS_Details 
                                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                                 AND RefCustomerAcid = v_Account_ID );
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
                                                          FROM OTS_Details 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                                                    AND EffectiveFromTimeKey = v_TimeKey
                                                                    AND RefCustomerAcid = v_Account_ID );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          DBMS_OUTPUT.PUT_LINE('BBBB');
                                          UPDATE OTS_Details
                                             SET RefCustomerAcid = v_Account_ID,
                                                 Date_Approval_Settlement = v_Date_Approval_Settlement,
                                                 Approving_Authority = v_Approving_Authority,
                                                 Principal_OS = v_Principal_OS,
                                                 Interest_Due_time_Settlement = v_Interest_Due_time_Settlement,
                                                 Fees_Charges_Settlement = v_Fees_Charges_Settlement,
                                                 Total_Dues_Settlement = v_Total_Dues_Settlement,
                                                 Settlement_Amount = v_Settlement_Amount,
                                                 AmtSacrificePOS = v_Principal_Sacrifice,
                                                 AmtWaiverIOS = v_Interest_Waiver,
                                                 AmtWaiverChgOS = v_Fees_Waiver,
                                                 TotalAmtSacrifice = v_Total_Amount_Sacrificed_Waived,
                                                 SettlementFailed = CASE 
                                                                         WHEN v_Settlement_Failure = 10 THEN 'N'
                                                 ELSE 'Y'
                                                 --,Actual_Write_Off_Amount		= @Actual_Write_Off_Amount
                                                  --,Actual_Write_Off_Date			= @Actual_Write_Off_Date

                                                    END,
                                                 Account_Closure_Date = v_Account_Closure_Date,
                                                 AuthorisationStatus = CASE 
                                                                            WHEN v_AuthMode = 'Y' THEN 'A'
                                                 ELSE NULL
                                                    END,
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = CASE 
                                                                   WHEN v_AuthMode = 'Y' THEN v_ApprovedBy
                                                 ELSE NULL
                                                    END,
                                                 DateApproved = CASE 
                                                                     WHEN v_AuthMode = 'Y' THEN v_DateApproved
                                                 ELSE NULL
                                                 --,FirstLevelApprovedBy			= @ApprovedByFirstLevel
                                                  --,FirstLevelDateApproved			= @DateApprovedFirstLevel
                                                  --,ChangeFields					= @OTS_AWO_ChangeFields

                                                    END,
                                                 screenFlag = 'S',
                                                 AccountEntityId = v_AccountEntityId,
                                                 CustomerEntityId = v_CustomerEntityID,
                                                 RefCustomerId = v_RefCustomerid,
                                                 NPA_Date = v_NPA_Date,
                                                 ACL_Sttlement = v_AssetclassAltKey
                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                            AND RefCustomerAcid = v_Account_ID;

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
                                       INSERT INTO OTS_Details
                                         ( RefCustomerAcid, Date_Approval_Settlement, Approving_Authority, Principal_OS, Interest_Due_time_Settlement, Fees_Charges_Settlement, Total_Dues_Settlement, Settlement_Amount, AmtSacrificePOS, AmtWaiverIOS, AmtWaiverChgOS, TotalAmtSacrifice, SettlementFailed
                                       --,Actual_Write_Off_Amount
                                        --,Actual_Write_Off_Date
                                       , Account_Closure_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved
                                       --,FirstLevelApprovedBy
                                        --,FirstLevelDateApproved
                                        --,ChangeFields
                                       , screenFlag, AccountEntityId, CustomerEntityId, RefCustomerId, NPA_Date, ACL_Sttlement )
                                         ( SELECT v_Account_ID ,
                                                  v_Date_Approval_Settlement ,
                                                  v_Approving_Authority ,
                                                  v_Principal_OS ,
                                                  v_Interest_Due_time_Settlement ,
                                                  v_Fees_Charges_Settlement ,
                                                  v_Total_Dues_Settlement ,
                                                  v_Settlement_Amount ,
                                                  v_Principal_Sacrifice ,
                                                  v_Interest_Waiver ,
                                                  v_Fees_Waiver ,
                                                  v_Total_Amount_Sacrificed_Waived ,
                                                  CASE 
                                                       WHEN v_Settlement_Failure = 10 THEN 'N'
                                                  ELSE 'Y'
                                                     END col  ,
                                                  --,@Actual_Write_Off_Amount
                                                  --,@Actual_Write_Off_Date
                                                  v_Account_Closure_Date ,
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
                                                  --,@ApprovedByFirstLevel
                                                  --,@DateApprovedFirstLevel
                                                  --,@OTS_AWO_ChangeFields
                                                  'S' ,
                                                  v_AccountEntityId ,
                                                  v_CustomerEntityID ,
                                                  v_RefCustomerid ,
                                                  v_NPA_Date ,
                                                  v_AssetclassAltKey 
                                             FROM DUAL  );

                                    END;
                                    END IF;
                                    IF v_IsSCD2 = 'Y' THEN

                                    BEGIN
                                       UPDATE OTS_Details
                                          SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                              AuthorisationStatus = CASE 
                                                                         WHEN v_AUTHMODE = 'Y' THEN 'A'
                                              ELSE NULL
                                                 END
                                        WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND RefCustomerAcid = v_Account_ID
                                         AND EffectiveFromTimekey < v_EffectiveFromTimeKey;

                                    END;
                                    END IF;

                                 END;
                                 END IF;
                                 IF v_AUTHMODE = 'N' THEN

                                 BEGIN
                                    v_AuthorisationStatus := 'A' ;
                                    GOTO MOCfreezeDateMaster_Insert;
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
         <<MOCFreezeDateMaster_Insert>>
         IF v_ErrorHandle = 0 THEN
          DECLARE
            v_Parameter1 VARCHAR2(50);
            v_FinalParameter1 VARCHAR2(50);

         BEGIN
            INSERT INTO OTS_Details_Mod
              ( RefCustomerAcid, Date_Approval_Settlement, Approving_Authority, Principal_OS, Interest_Due_time_Settlement, Fees_Charges_Settlement, Total_Dues_Settlement, Settlement_Amount, AmtSacrificePOS, AmtWaiverIOS, AmtWaiverChgOS, TotalAmtSacrifice, SettlementFailed
            --,Actual_Write_Off_Amount
             --,Actual_Write_Off_Date
            , Account_Closure_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, FirstLevelApprovedBy, FirstLevelDateApproved, ChangeFields, screenFlag, AccountEntityId, CustomerEntityId, RefCustomerId, NPA_Date, ACL_Sttlement )
              VALUES ( v_Account_ID, v_Date_Approval_Settlement, v_Approving_Authority, v_Principal_OS, v_Interest_Due_time_Settlement, v_Fees_Charges_Settlement, v_Total_Dues_Settlement, v_Settlement_Amount, v_Principal_Sacrifice, v_Interest_Waiver, v_Fees_Waiver, v_Total_Amount_Sacrificed_Waived, CASE 
                                                                                                                                                                                                                                                                                                                 WHEN v_Settlement_Failure = 10 THEN 'N'
            ELSE 'Y'
               END, 
            --,@Actual_Write_Off_Amount

            --,@Actual_Write_Off_Date
            v_Account_Closure_Date, CASE 
                                         WHEN v_AUTHMODE = 'Y' THEN v_AuthorisationStatus
            ELSE NULL
               END, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), CASE 
                                                                                                                         WHEN v_AuthMode = 'Y'
                                                                                                                           OR v_IsAvailable = 'Y' THEN v_ModifiedBy
            ELSE NULL
               END, TO_DATE(CASE 
                                 WHEN v_AuthMode = 'Y'
                                   OR v_IsAvailable = 'Y' THEN v_DateModified
            ELSE NULL
               END,'dd/mm/yyyy'), CASE 
                                       WHEN v_AUTHMODE = 'Y' THEN v_ApprovedBy
            ELSE NULL
               END, TO_DATE(CASE 
                                 WHEN v_AUTHMODE = 'Y' THEN v_DateApproved
            ELSE NULL
               END,'dd/mm/yyyy'), v_ApprovedByFirstLevel, TO_DATE(v_DateApprovedFirstLevel,'dd/mm/yyyy'), v_OTS_AWO_ChangeFields, 'S', v_AccountEntityId, v_CustomerEntityID, v_RefCustomerid, v_NPA_Date, v_AssetclassAltKey );
            SELECT utils.stuff(( SELECT DISTINCT ',' || ChangeFields 
                                 FROM OTS_Details_Mod 
                                  WHERE  RefCustomerAcid = v_Account_ID
                                           AND NVL(AuthorisationStatus, 'A') IN ( 'A','MP' )
                                ), 1, 1, ' ') 

              INTO v_Parameter1
              FROM DUAL ;
            IF utils.object_id('tt_AA_24') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AA_24 ';
            END IF;
            DELETE FROM tt_AA_24;
            UTILS.IDENTITY_RESET('tt_AA_24');

            INSERT INTO tt_AA_24 ( 
            	SELECT DISTINCT VALUE 
            	  FROM ( SELECT INSTR(VALUE, '|') CHRIDX  ,
                             VALUE 
                      FROM ( SELECT VALUE 
                             FROM TABLE(STRING_SPLIT(v_Parameter1, ','))  ) A ) X );
            SELECT utils.stuff(( SELECT DISTINCT ',' || VALUE 
                                 FROM tt_AA_24  ), 1, 1, ' ') 

              INTO v_FinalParameter1
              FROM DUAL ;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, v_FinalParameter1
            FROM A ,OTS_Details_Mod A 
             WHERE ( EffectiveFromTimeKey <= v_tiMEKEY
              AND EffectiveToTimeKey >= v_tiMEKEY )
              AND RefCustomerAcid = v_Account_ID) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET a.ChangeFields = v_FinalParameter1;
            IF v_OperationFlag = 1
              AND v_AUTHMODE = 'Y' THEN

            BEGIN
               --PRINT 3
               GOTO MOCFreezeDateMaster_Insert_Add;

            END;
            ELSE
               IF ( v_OperationFlag = 2
                 OR v_OperationFlag = 3 )
                 AND v_AUTHMODE = 'Y' THEN

               BEGIN
                  GOTO MOCFreezeDateMaster_Insert_Edit_Delete;

               END;
               END IF;
            END IF;

         END;
         END IF;
         -----------------Attendance Log----------------
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
                v_ReferenceID => v_Account_ID -- ReferenceID ,
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
                v_ReferenceID => v_Account_ID -- ReferenceID ,
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OTS_INUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OTS_INUP" TO "ADF_CDR_RBL_STGDB";
