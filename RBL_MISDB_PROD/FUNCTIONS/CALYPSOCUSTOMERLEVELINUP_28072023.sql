--------------------------------------------------------
--  DDL for Function CALYPSOCUSTOMERLEVELINUP_28072023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" 
(
  --Declare  
  v_UCICID IN VARCHAR2 DEFAULT ' ' ,
  v_CustomerName IN VARCHAR2 DEFAULT ' ' ,
  v_AssetClassAlt_Key IN NUMBER DEFAULT 0 ,
  iv_NPADate IN VARCHAR2 DEFAULT NULL ,
  v_SecurityValue IN VARCHAR2 DEFAULT ' ' ,
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
   v_MocTypeDesc VARCHAR2(20);
   v_Parameter1 VARCHAR2(4000) := ( SELECT 'UCICID|' || NVL(v_UCICID, ' ') || '}' || 'CustomerName|' || NVL(v_CustomerName, ' ') || '}' || 'AssetClassAlt_Key_Pos|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_AssetClassAlt_Key, ' '),30) || '}' || 'NPADate_Pos|' || NVL(v_NPADate, ' ') || '}' || 'SecurityValue_Pos|' || NVL(v_SecurityValue, ' ') || '}' || 'AdditionalProvision_Pos|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_AdditionalProvision, '0'),30) || '} ' || 'MOCTypeAlt_Key|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_MocTypeAlt_Key, ' '),30) || '}' || 'MOCReason|' || NVL(v_MOCReason, ' ') || '}' || 'MOCSourceAltKey|' || UTILS.CONVERT_TO_VARCHAR2(NVL(v_MOCSourceAltkey, ' '),30) 
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
   --,@AccountEntityID int=0  
   ------------Added for Rejection Screen  29/06/2020   ----------  
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_ApprovedByFirstLevel VARCHAR2(20) := NULL;
   v_DateApprovedFirstLevel DATE := NULL;
   v_MOC_Date VARCHAR2(200);
   v_MocStatus VARCHAR2(100) := ' ';
   v_temp NUMBER(1, 0) := 0;
   --	Declare @CustomerEntityID int
   --Select  @CustomerEntityID= IssuerEntityId from InvestmentBasicDetail
   --                          where  InvID=@AccountID
   v_MOCReason_1 VARCHAR2(200);
   v_AppAvail CHAR;
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE(1);
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   ---Priyali----
   IF v_Result = -1 THEN
    RETURN -1;
   END IF;
   --select @MocTypeDesc =MOCTypeName from DimMOCType where MOCTypeAlt_Key=@MocTypeAlt_Key
   -- AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
   SELECT ParameterName 

     INTO v_MocTypeDesc
     FROM DimParameter 
    WHERE  Dimparametername = 'MocType'
             AND ParameterAlt_Key = v_MocTypeAlt_Key
             AND EffectiveFromTimeKey <= v_TimeKey
             AND EffectiveToTimeKey >= v_TimeKey;
   v_NPADate := CASE 
                     WHEN ( v_NPADate = ' '
                       OR v_NPADate = '01/01/1900' ) THEN NULL
   ELSE v_NPADate
      END ;
   v_ScreenName := 'CalypsoCustomerLevel' ;
   -------------------------------------------------------------  
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
   SELECT UTILS.CONVERT_TO_VARCHAR2(ExtDate,200) 

     INTO v_MOC_Date
     FROM SysDataMatrix 
    WHERE  Timekey = v_TimeKey;
   --PRINT '@MOC_DATE'
   -- PRINT @MOC_DATE
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   SELECT MocStatus 

     INTO v_MocStatus
     FROM CalypsoMOCMonitorStatus 
    WHERE  EntityKey IN ( SELECT MAX(EntityKey)  
                          FROM CalypsoMOCMonitorStatus  )
   ;
   IF ( v_MocStatus = 'InProgress' ) THEN

   BEGIN
      v_Result := 5 ;
      RETURN v_Result;

   END;
   END IF;
   --Declare @CustomerId  Varchar(max)
   --Select  @CustomerId= (select RefIssuerID  from InvestmentBasicDetail
   --where RefIssuerId=@UCICID   and   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
   --UNION
   --select CustomerId from curdat.DerivativeDetail
   --where UCIC_ID =@UCICID  and   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM CalypsoInvMOC_ChangeDetails 
                       WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND UCICID = v_UCICID
                                AND MOCType_Flag = 'CUST'
                                AND MOCProcessed = 'N' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      v_Result := 6 ;
      RETURN v_Result;

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM CalypsoDervMOC_ChangeDetails 
                       WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND UCICID = v_UCICID
                                AND MOCType_Flag = 'CUST'
                                AND MOCProcessed = 'N' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      v_Result := 6 ;
      RETURN v_Result;

   END;
   END IF;
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
         IF ( v_OperationFlag = 2
           OR v_OperationFlag = 3 )
           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

          --EDIT AND DELETE  
         BEGIN
            --  Print 4  
            --  SET @CreatedBy= @CrModApBy  
            --  SET @DateCreated = GETDATE()  
            --  Set @Modifiedby=@CrModApBy     
            --  Set @DateModified =GETDATE()   
            --  SET @AuthorisationStatus='MP'  
            --   --UPDATE NP,MP  STATUS   
            --   IF @OperationFlag=2  
            --   BEGIN   
            --    UPDATE CalypsoAccountLevelMOC_Mod  
            --     SET AuthorisationStatus='FM'  
            --     ,ModifyBy=@Modifiedby  
            --     ,DateModified=@DateModified  
            --    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
            --      --AND AccountID=@AccountID  
            --AND  AccountEntityID =@AccountEntityID
            --      AND AuthorisationStatus IN('NP','MP','RM')  
            --						UPDATE CalypsoAccountLevelMOC_Mod
            --					SET EffectiveToTimeKey >= @Timekey-1
            --				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
            --						AND  AccountEntityID =@AccountEntityID
            --						AND AuthorisationStatus IN('A')
            --   END 
            v_CreatedBy := v_CrModApBy ;
            v_DateCreated := SYSDATE ;
            v_Modifiedby := v_CrModApBy ;
            v_DateModified := SYSDATE ;
            v_AuthorisationStatus := 'MP' ;
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
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT COUNT(1)  
                               FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                         AND EffectiveToTimeKey >= v_TimeKey )
                                         AND UCICID = v_UCICID );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND UCICID = v_UCICID;

            END;
            ELSE

            BEGIN
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND UCICID = v_UCICID;

            END;
            END IF;
            ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
            IF NVL(v_CreatedBy, ' ') = ' ' THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('NOT AVAILABLE IN MAIN');
               SELECT CreatedBy ,
                      DateCreated 

                 INTO v_CreatedBy,
                      v_DateCreated
                 FROM RBL_MISDB_PROD.CalypsoCustomerLevelMOC_Mod 
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey )
                         AND UCIFID = v_UCICID
                         AND AuthorisationStatus IN ( 'NP','MP','A','RM' )
               ;

            END;
            ELSE
            DECLARE
               v_temp NUMBER(1, 0) := 0;

             ---IF DATA IS AVAILABLE IN MAIN TABLE
            BEGIN
               DBMS_OUTPUT.PUT_LINE('AVAILABLE IN MAIN');
               ----UPDATE FLAG IN MAIN TABLES AS MP
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT COUNT(1)  
                                  FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND UCICID = v_UCICID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UCICID = v_UCICID;

               END;
               ELSE

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UCICID = v_UCICID;

               END;
               END IF;

            END;
            END IF;
            --UPDATE NP,MP  STATUS 
            IF v_OperationFlag = 2 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT COUNT(1)  
                                  FROM RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails 
                                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                            AND EffectiveToTimeKey >= v_TimeKey )
                                            AND UCICID = v_UCICID );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoInvMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UCICID = v_UCICID;

               END;
               ELSE

               BEGIN
                  UPDATE RBL_MISDB_PROD.CalypsoDervMOC_ChangeDetails
                     SET AuthorisationStatus = v_AuthorisationStatus
                   WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND UCICID = v_UCICID;

               END;
               END IF;
               UPDATE CalypsoCustomerLevelMOC_Mod
                  SET AuthorisationStatus = 'FM',
                      ModifyBy = v_ModifiedBy,
                      DateModified = v_DateModified
                WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                 AND EffectiveToTimeKey >= v_TimeKey )
                 AND UCIFID = v_UCICID
                 AND AuthorisationStatus IN ( 'NP','MP','RM' )
               ;

            END;
            END IF;
            GOTO GLCodeMaster_Insert;
            <<GLCodeMaster_Insert_Edit_Delete>>

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
                                                   AND EffectiveToTimeKey >= 49999
                                                   AND UserLoginID = v_CrModApBy
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
                                           FROM CalypsoCustomerLevelMOC_Mod 
                                            WHERE  CreatedBy = v_CrModApBy
                                                     AND UCIFID = v_UCICID
                                                     AND EffectiveToTimeKey = 49999
                                                     AND AuthorisationStatus = '1A'
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
                      WHERE ( v_CrModApBy = ( SELECT ApprovedByFirstLevel 
                                              FROM CalypsoCustomerLevelMOC_Mod 
                                               WHERE  ApprovedByFirstLevel = v_CrModApBy
                                                        AND UCIFID = v_UCICID
                                                        AND EffectiveToTimeKey = 49999
                                                        AND AuthorisationStatus = '1A'
                                                GROUP BY ApprovedByFirstLevel ) );
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
                     UPDATE CalypsoCustomerLevelMOC_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedBy = v_ApprovedBy,
                            DateApproved = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )

                       --AND AccountID=@AccountID  
                       AND UCIFID = v_UCICID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                     ;
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, 'R', v_ApprovedBy, v_EffectiveFromTimeKey - 1 AS pos_4
                     FROM A ,ExcelUploadHistory A
                            JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                      WHERE UCIFID = v_UCICID
                       AND B.UploadID IS NOT NULL
                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )

                       AND B.EffectiveToTimeKey = 49999) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = 'R',
                                                  A.ApprovedBy = v_ApprovedBy,
                                                  A.EffectiveToTimeKey = pos_4;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoInvMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND UCICID = v_UCICID
                                                  AND MOCType_Flag = 'CUST' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoInvMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UCICID = v_UCICID
                          AND MOCType_Flag = 'CUST'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoDervMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND UCICID = v_UCICID
                                                  AND MOCType_Flag = 'CUST' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoDervMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UCICID = v_UCICID
                          AND MOCType_Flag = 'ACCT'
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
                                              FROM CalypsoCustomerLevelMOC_Mod 
                                               WHERE  CreatedBy = v_CrModApBy
                                                        AND UCIFID = v_UCICID
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

                  --select createdby,* from DimBranch_Mod  
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE CalypsoCustomerLevelMOC_Mod
                        SET AuthorisationStatus = 'R',
                            ApprovedByFirstLevel = v_ApprovedBy,
                            DateApprovedFirstLevel = v_DateApproved,
                            EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )

                       --AND AccountID=@AccountID  
                       AND UCIFID = v_UCICID
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                     ;
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, 'R', v_ApprovedBy, v_EffectiveFromTimeKey - 1 AS pos_4
                     FROM A ,ExcelUploadHistory A
                            JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                      WHERE UCIFID = v_UCICID
                       AND B.UploadID IS NOT NULL
                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                       AND B.EffectiveToTimeKey = 49999) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = 'R',
                                                  A.ApprovedBy = v_ApprovedBy,
                                                  A.EffectiveToTimeKey = pos_4;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoInvMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND UCICID = v_UCICID
                                                  AND MOCType_Flag = 'CUST' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoInvMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UCICID = v_UCICID
                          AND MOCType_Flag = 'CUST'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoDervMOC_ChangeDetails 
                                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_Timekey )
                                                  AND UCICID = v_UCICID
                                                  AND MOCType_Flag = 'CUST' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        UPDATE CalypsoDervMOC_ChangeDetails
                           SET AuthorisationStatus = 'A'
                         WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                          AND EffectiveToTimeKey >= v_TimeKey )
                          AND UCICID = v_UCICID
                          AND MOCType_Flag = 'CUST'
                          AND AuthorisationStatus IN ( 'MP','DP','RM' )
                        ;

                     END;
                     END IF;

                  END;
                  END IF;

               END;

               ---------------Added for Rejection Pop Up Screen  29/06/2020   ----------  
               ELSE
                  IF v_OperationFlag = 18 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(18);
                     v_ApprovedBy := v_CrModApBy ;
                     v_DateApproved := SYSDATE ;
                     UPDATE CalypsoCustomerLevelMOC_Mod
                        SET AuthorisationStatus = 'RM'
                      WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                       AND EffectiveToTimeKey >= v_TimeKey )
                       AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )


                       --AND AccountID=@AccountID
                       AND UCIFID = v_UCICID;
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, 'RM', v_ApprovedBy, v_EffectiveFromTimeKey - 1 AS pos_4
                     FROM A ,ExcelUploadHistory A
                            JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                      WHERE UCIFID = v_UCICID
                       AND B.UploadID IS NOT NULL
                       AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                       AND B.EffectiveToTimeKey = 49999) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = 'RM',
                                                  A.ApprovedBy = v_ApprovedBy,
                                                  A.EffectiveToTimeKey = pos_4;

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
                                                    FROM CalypsoCustomerLevelMOC_Mod 
                                                     WHERE  AuthorisationStatus IN ( 'NP','MP' )

                                                              AND CreatedBy = v_CrModApBy

                                                              --And AccountID=@AccountID 
                                                              AND UCIFID = v_UCICID
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

                        --select * from DimBranch_Mod  
                        ELSE

                        BEGIN
                           v_ApprovedBy := v_CrModApBy ;
                           v_DateApproved := SYSDATE ;
                           DBMS_OUTPUT.PUT_LINE(111111111);
                           UPDATE CalypsoCustomerLevelMOC_Mod
                              SET AuthorisationStatus = '1A',
                                  ApprovedByFirstLevel = v_ApprovedBy,
                                  DateApprovedFirstLevel = v_DateApproved
                            WHERE  UCIFID = v_UCICID
                             AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )
                           ;
                           MERGE INTO A 
                           USING (SELECT A.ROWID row_id, '1A', v_ApprovedBy
                           FROM A ,ExcelUploadHistory A
                                  JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                            WHERE UCIFID = v_UCICID
                             AND B.UploadID IS NOT NULL
                             AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                             AND B.EffectiveToTimeKey = 49999) src
                           ON ( A.ROWID = src.row_id )
                           WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = '1A',
                                                        A.ApprovedBy = v_ApprovedBy;

                        END;
                        END IF;

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
                                                               AND EffectiveToTimeKey = 49999
                                                               AND UserLoginID = v_CrModApBy
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
                                                       FROM CalypsoCustomerLevelMOC_Mod 
                                                        WHERE  AuthorisationStatus IN ( '1A' )

                                                                 AND CreatedBy = v_CrModApBy
                                                                 AND UCIFID = v_UCICID
                                                                 AND EffectiveToTimeKey = 49999

                                                       --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')    
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

                           --select * from DimBranch_Mod  
                           ELSE
                           DECLARE
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE ( v_CrModApBy = ( SELECT ApprovedBy 
                                                          FROM CalypsoCustomerLevelMOC_Mod 
                                                           WHERE  AuthorisationStatus IN ( '1A' )

                                                                    AND ApprovedBy = v_CrModApBy
                                                                    AND UCIFID = v_UCICID
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
                                         FROM CalypsoInvMOC_ChangeDetails 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )

                                                 --AND AccountID=@AccountID
                                                 AND UCICID = v_UCICID;
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
                                    DBMS_OUTPUT.PUT_LINE('Bbbbbb');
                                    SELECT MAX(Entity_Key)  

                                      INTO v_ExEntityKey
                                      FROM CalypsoCustomerLevelMOC_Mod 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey )

                                              --AND AccountID=@AccountID
                                              AND UCIFID = v_UCICID
                                              AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                    ;
                                    SELECT AuthorisationStatus ,
                                           CreatedBy ,
                                           DATECreated ,
                                           ModifyBy ,
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
                                      FROM CalypsoCustomerLevelMOC_Mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    v_ApprovedBy := v_CrModApBy ;
                                    v_DateApproved := SYSDATE ;
                                    SELECT EffectiveFromTimeKey 

                                      INTO v_CurrRecordFromTimeKey
                                      FROM RBL_MISDB_PROD.CalypsoCustomerLevelMOC_Mod 
                                     WHERE  Entity_Key = v_ExEntityKey;
                                    UPDATE RBL_MISDB_PROD.CalypsoCustomerLevelMOC_Mod
                                       SET EffectiveToTimeKey = EffectiveFromTimeKey - 1
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )

                                      --AND AccountID=@AccountID
                                      AND UCIFID = v_UCICID
                                      AND AuthorisationStatus = 'A';
                                    --AND EntityKey=@ExEntityKey
                                    -------DELETE RECORD AUTHORISE
                                    IF v_DelStatus = 'DP' THEN
                                     DECLARE
                                       v_temp NUMBER(1, 0) := 0;

                                    BEGIN
                                       UPDATE RBL_MISDB_PROD.CalypsoCustomerLevelMOC_Mod
                                          SET AuthorisationStatus = 'A',
                                              ApprovedBy = v_ApprovedBy,
                                              DateApproved = v_DateApproved,
                                              EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                        WHERE  UcifID = v_UCICID
                                         AND AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )
                                       ;
                                       MERGE INTO A 
                                       USING (SELECT A.ROWID row_id, 'A', v_ApprovedBy, v_EffectiveFromTimeKey - 1 AS pos_4
                                       FROM A ,ExcelUploadHistory A
                                              JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                                        WHERE UCIFID = v_UCICID
                                         AND B.UploadID IS NOT NULL
                                         AND A.AuthorisationStatus IN ( 'NP','MP','DP','RM','1A' )

                                         AND B.EffectiveToTimeKey = 49999) src
                                       ON ( A.ROWID = src.row_id )
                                       WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = 'A',
                                                                    A.ApprovedBy = v_ApprovedBy,
                                                                    A.EffectiveToTimeKey = pos_4;
                                       BEGIN
                                          SELECT 1 INTO v_temp
                                            FROM DUAL
                                           WHERE EXISTS ( SELECT 1 
                                                          FROM CalypsoInvMOC_ChangeDetails 
                                                           WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey )
                                         AND UCICID = v_UCICID
                                         AND MOCType_Flag = 'CUST' );
                                       EXCEPTION
                                          WHEN OTHERS THEN
                                             NULL;
                                       END;

                                       IF v_temp = 1 THEN

                                       BEGIN
                                          UPDATE CalypsoInvMOC_ChangeDetails
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND UCICID = v_UCICID
                                            AND MOCType_Flag = 'CUST';

                                       END;
                                       ELSE

                                       BEGIN
                                          UPDATE CalypsoDervMOC_ChangeDetails
                                             SET AuthorisationStatus = 'A',
                                                 ModifiedBy = v_ModifiedBy,
                                                 DateModified = v_DateModified,
                                                 ApprovedBy = v_ApprovedBy,
                                                 DateApproved = v_DateApproved,
                                                 EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                                           WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND UCICID = v_UCICID
                                            AND MOCType_Flag = 'CUST';

                                       END;
                                       END IF;

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
                                    UPDATE CalypsoCustomerLevelMOC_Mod
                                       SET AuthorisationStatus = 'A',
                                           ApprovedBy = v_ApprovedBy,
                                           DateApproved = v_DateApproved
                                     WHERE  UcifID = v_UCICID
                                      AND AuthorisationStatus IN ( 'NP','MP','RM','1A' )
                                    ;
                                    MERGE INTO A 
                                    USING (SELECT A.ROWID row_id, 'A', v_ApprovedBy
                                    FROM A ,ExcelUploadHistory A
                                           JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                                     WHERE UCIFID = v_UCICID
                                      AND B.UploadID IS NOT NULL
                                      AND A.AuthorisationStatus IN ( 'NP','MP','RM','1A' )

                                      AND B.EffectiveToTimeKey = 49999) src
                                    ON ( A.ROWID = src.row_id )
                                    WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = 'A',
                                                                 A.ApprovedBy = v_ApprovedBy;

                                 END;
                                 END IF;

                              END;
                              END IF;

                           END;
                           END IF;
                           --Sachin
                           IF v_DelStatus <> 'DP'
                             OR v_AuthMode = 'N' THEN
                            DECLARE
                              v_IsAvailable CHAR(1) := 'N';
                              v_IsSCD2 CHAR(1) := 'N';
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('Check');
                              v_AuthorisationStatus := 'A' ;--changedby siddhant 5/7/2020
                              UPDATE CalypsoCustomerLevelMOC_Mod
                                 SET AuthorisationStatus = 'A'
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND UcifID = v_UCICID
                                AND AuthorisationStatus IN ( '1A' )
                              ;
                              MERGE INTO A 
                              USING (SELECT A.ROWID row_id, 'A', v_ApprovedBy
                              FROM A ,ExcelUploadHistory A
                                     JOIN CalypsoCustomerLevelMOC_Mod B   ON A.UniqueUploadID = B.UploadID 
                               WHERE UCIFID = v_UCICID
                                AND B.UploadID IS NOT NULL
                                AND A.AuthorisationStatus IN ( '1A' )

                                AND B.EffectiveToTimeKey = 49999) src
                              ON ( A.ROWID = src.row_id )
                              WHEN MATCHED THEN UPDATE SET A.AuthorisationStatus = 'A',
                                                           A.ApprovedBy = v_ApprovedBy;
                              UPDATE CalypsoInvMOC_ChangeDetails
                                 SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                     AuthorisationStatus = 'A',
                                     ApprovedBy = v_CrModApBy,
                                     DateApproved = SYSDATE
                               WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey )
                                AND UCICID = v_UCICID
                                AND MOCType_Flag = 'CUST';
                              DBMS_OUTPUT.PUT_LINE('CHECK1');
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM CalypsoInvMOC_ChangeDetails 
                                                  WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                           AND EffectiveToTimeKey >= v_TimeKey )
                                                           AND UCICID = v_UCICID
                                                           AND MOCType_Flag = 'CUST' );
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
                                                    FROM CalypsoInvMOC_ChangeDetails 
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND UCICID = v_UCICID
                                                              AND MOCType_Flag = 'CUST'
                                                              AND EffectiveFromTimeKey <= v_Timekey );
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       NULL;
                                 END;

                                 IF v_temp = 1 THEN

                                 BEGIN
                                    DBMS_OUTPUT.PUT_LINE('BBBB');
                                    --PRINT '@UCIF_ID'
                                    --PRINT @UCIF_ID
                                    UPDATE CalypsoInvMOC_ChangeDetails
                                       SET ucicid = v_UCICID,
                                           AssetClassAlt_Key = v_AssetClassAlt_Key,
                                           NPA_Date = v_NPADate,
                                           CurntQtrRv = v_SecurityValue,
                                           AddlProvPer = v_AdditionalProvision,
                                           MOC_Reason = v_MOCReason_1
                                           --,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
                                            --,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
                                            --,A.=@ScreenFlag        
                                            --,A.=@MOCSource         
                                            --,FlgMoc ='Y'  
                                           ,
                                           MOC_Date = v_MOC_Date,
                                           MOC_Source = v_MOCSourceAltkey
                                           --,MOC_ExpireDate=CASE WHEN @MOC_ExpireDate IS NULL THEN MOC_ExpireDate  ELSE @MOC_ExpireDate END 
                                           ,
                                           ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                           DateApprovedFirstLevel = v_DateApprovedFirstLevel
                                           --,ChangeType                 =CASE WHEN @ChangeTypeAlt_Key=1 THEN 'Auto' else 'Manual' end 
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
                                           --,AddlProvPer                =@AddlProvisionPer

                                              END,
                                           MOCType_Flag = 'CUST'
                                           --,CustomerEntityID            =@CustomerID
                                            --												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
                                           ,
                                           MOCProcessed = 'N'
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                      AND UCICID = v_UCICID
                                      AND MOCType_Flag = 'CUST';

                                 END;

                                 --                                  UPDATE CalypsoInvMOC_ChangeDetails

                                 -- set FraudDate=CASE WHEN FlgFraud='N' THEN NULL ELSE @FraudDate END

                                 --     ,RestructureDate=CASE WHEN RestructureDate ='N'THEN NULL  ELSE @RestructureDate END

                                 --  ,TwoDate=CASE WHEN TwoDate='N' THEN NULL ELSE @TwoDate END  

                                 --  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 

                                 --AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  AccountEntityID=@AccountEntityID

                                 --AND MOCType_Flag='ACCT'
                                 ELSE

                                 BEGIN
                                    v_IsSCD2 := 'Y' ;
                                    UPDATE CalypsoDervMOC_ChangeDetails
                                       SET ucicid = v_UCICID,
                                           AssetClassAlt_Key = v_AssetClassAlt_Key,
                                           NPA_Date = v_NPADate,
                                           CurntQtrRv = v_SecurityValue,
                                           AddlProvPer = v_AdditionalProvision,
                                           MOC_Reason = v_MOCReason_1
                                           --,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
                                            --,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
                                            --,A.=@ScreenFlag        
                                            --,A.=@MOCSource         
                                            --,FlgMoc ='Y'  
                                           ,
                                           MOC_Date = v_MOC_Date,
                                           MOC_Source = v_MOCSourceAltkey
                                           --,MOC_ExpireDate=CASE WHEN @MOC_ExpireDate IS NULL THEN MOC_ExpireDate  ELSE @MOC_ExpireDate END 
                                           ,
                                           ApprovedByFirstLevel = v_ApprovedByFirstLevel,
                                           DateApprovedFirstLevel = v_DateApprovedFirstLevel
                                           --,ChangeType                 =CASE WHEN @ChangeTypeAlt_Key=1 THEN 'Auto' else 'Manual' end 
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
                                           --,AddlProvPer                =@AddlProvisionPer

                                              END,
                                           MOCType_Flag = 'CUST'
                                           --,CustomerEntityID            =@CustomerID
                                            --												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
                                           ,
                                           MOCProcessed = 'N'
                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND EffectiveFromTimeKey = v_EffectiveFromTimeKey
                                      AND UCICID = v_UCICID
                                      AND MOCType_Flag = 'CUST';

                                 END;
                                 END IF;

                              END;
                              END IF;

                           END;
                           END IF;
                           IF v_IsAvailable = 'N'
                             OR v_IsSCD2 = 'Y' THEN
                            DECLARE
                              v_temp NUMBER(1, 0) := 0;

                           BEGIN
                              DBMS_OUTPUT.PUT_LINE('check11111');
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM CalypsoCustomerLevelMOC_Mod a
                                                        JOIN InvestmentIssuerDetail B   ON A.UcifID = B.UcifId
                                                  WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                           AND A.EffectiveToTimeKey >= v_TimeKey )
                                                           AND ( B.EffectiveFromTimeKey <= v_TimeKey
                                                           AND B.EffectiveToTimeKey >= v_TimeKey )
                                                           AND A.UcifID = v_UCICID );
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    NULL;
                              END;

                              IF v_temp = 1 THEN

                              BEGIN
                                 INSERT INTO CalypsoInvMOC_ChangeDetails
                                   ( UCICID, MOCType_Flag, CustomerEntityID, AssetClassAlt_Key, NPA_Date, CurntQtrRv, AddlProvPer, MOC_Reason, MOC_Date, MOC_Source, MOCProcessed, MOCTYPE, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedByFirstLevel, DateApprovedFirstLevel, ApprovedBy, DateApproved )
                                   VALUES ( v_UCICID, 'CUST', NULL, v_AssetClassAlt_Key, v_NPADate, v_SecurityValue, v_AdditionalProvision, v_MOCReason_1, v_MOC_DATE, v_MOCSourceAltkey, 'N', v_MocTypeDesc, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, TO_DATE(v_DateModified,'dd/mm/yyyy'), v_ApprovedByFirstLevel, TO_DATE(v_DateApprovedFirstLevel,'dd/mm/yyyy'), v_ApprovedBy, TO_DATE(v_DateApproved,'dd/mm/yyyy') );
                                 DBMS_OUTPUT.PUT_LINE('check111');
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    UPDATE CalypsoInvMOC_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AUTHMODE = 'Y' THEN 'A'
                                           ELSE NULL
                                              END
                                     WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND UCICID = v_UCICID
                                      AND EffectiveFromTimekey < v_EffectiveFromTimeKey
                                      AND MOCType_Flag = 'CUST';

                                 END;
                                 END IF;

                              END;
                              END IF;
                              BEGIN
                                 SELECT 1 INTO v_temp
                                   FROM DUAL
                                  WHERE EXISTS ( SELECT 1 
                                                 FROM CalypsoCustomerLevelMOC_Mod a
                                                        JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.UcifID = B.UCIC_ID
                                                  WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                                                           AND A.EffectiveToTimeKey >= v_TimeKey )
                                                           AND ( B.EffectiveFromTimeKey <= v_TimeKey
                                                           AND B.EffectiveToTimeKey >= v_TimeKey )
                                                           AND A.UcifID = v_UCICID );
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    NULL;
                              END;

                              IF v_temp = 1 THEN

                              BEGIN
                                 INSERT INTO CalypsoDervMOC_ChangeDetails
                                   ( UCICID, MOCType_Flag, CustomerEntityID, AssetClassAlt_Key, NPA_Date, CurntQtrRv, AddlProvPer, MOC_Reason, MOC_Date, MOC_Source, MOCProcessed, MOCTYPE, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedByFirstLevel, DateApprovedFirstLevel, ApprovedBy, DateApproved )
                                   VALUES ( v_UCICID, 'CUST', NULL, v_AssetClassAlt_Key, v_NPADate, v_SecurityValue, v_AdditionalProvision, v_MOCReason_1, v_MOC_DATE, v_MOCSourceAltkey, 'N', v_MocTypeDesc, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, TO_DATE(v_DateModified,'dd/mm/yyyy'), v_ApprovedByFirstLevel, TO_DATE(v_DateApprovedFirstLevel,'dd/mm/yyyy'), v_ApprovedBy, TO_DATE(v_DateApproved,'dd/mm/yyyy') );
                                 DBMS_OUTPUT.PUT_LINE('check111');
                                 IF v_IsSCD2 = 'Y' THEN

                                 BEGIN
                                    UPDATE CalypsoDervMOC_ChangeDetails
                                       SET EffectiveToTimeKey = v_EffectiveFromTimeKey - 1,
                                           AuthorisationStatus = CASE 
                                                                      WHEN v_AUTHMODE = 'Y' THEN 'A'
                                           ELSE NULL
                                              END
                                     WHERE  ( EffectiveFromTimeKey = EffectiveFromTimeKey
                                      AND EffectiveToTimeKey >= v_TimeKey )
                                      AND UCICID = v_UCICID
                                      AND EffectiveFromTimekey < v_EffectiveFromTimeKey
                                      AND MOCType_Flag = 'CUST';

                                 END;
                                 END IF;

                              END;
                              END IF;

                           END;
                           END IF;
                           IF v_AUTHMODE = 'N' THEN

                           BEGIN
                              v_AuthorisationStatus := 'A' ;
                              GOTO GLCodeMaster_Insert;
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
         <<GLCodeMaster_Insert>>
         IF v_ErrorHandle = 0 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('aaaaa');
            INSERT INTO CalypsoCustomerLevelMOC_Mod
              ( UCIFID, CustomerEntityID, CustomerName, AssetClassAlt_Key, NPADate, SecurityValue, AdditionalProvision, MOCReason, MOCSourceAltkey, MOCDate, MOCType, ScreenFlag, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, ChangeField, MOCType_Flag )
              VALUES ( v_UCICID, NULL, v_CustomerName, v_AssetClassAlt_Key, v_NPADate, v_SecurityValue, v_AdditionalProvision, v_MOCReason_1, v_MOCSourceAltkey, v_MOC_DATE, 
            -- ,@MocTypeAlt_Key
            v_MocTypeDesc, v_ScreenFlag, v_AuthorisationStatus, v_EffectiveFromTimeKey, v_EffectiveToTimeKey, v_CreatedBy, TO_DATE(v_DateCreated,'dd/mm/yyyy'), v_ModifiedBy, TO_DATE(v_DateModified,'dd/mm/yyyy'), v_ApprovedBy, TO_DATE(v_DateApproved,'dd/mm/yyyy'), v_CustomerNPAMOC_ChangeFields, 
            --,@MOC_ExpireDate
            'CUST' );
            --Sachin 
            DBMS_OUTPUT.PUT_LINE('Sachin');
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
                  GOTO GLCodeMaster_Insert_Edit_Delete;

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
                v_ReferenceID => v_UCICID -- ReferenceID ,
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
                v_ReferenceID => v_UCICID -- ReferenceID ,
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
         DBMS_OUTPUT.PUT_LINE(7);
         utils.commit_transaction;
         --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM CustomerLevelMOC WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
         --               AND GLAlt_Key=@GLAlt_Key  
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
      DBMS_OUTPUT.PUT_LINE('ERRR............');
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOCUSTOMERLEVELINUP_28072023" TO "ADF_CDR_RBL_STGDB";
