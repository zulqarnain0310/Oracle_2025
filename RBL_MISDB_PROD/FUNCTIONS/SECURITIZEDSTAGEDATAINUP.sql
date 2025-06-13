--------------------------------------------------------
--  DDL for Function SECURITIZEDSTAGEDATAINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" 
(
  iv_Timekey IN NUMBER,
  v_UserLoginID IN VARCHAR2,
  v_OperationFlag IN NUMBER,
  v_MenuId IN NUMBER,
  v_AuthMode IN CHAR,
  v_filepath IN VARCHAR2,
  iv_EffectiveFromTimeKey IN NUMBER,
  iv_EffectiveToTimeKey IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  v_UniqueUploadID IN NUMBER
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_temp NUMBER(1, 0) := 0;
   ------RETURN @UniqueUploadID
   --ROLLBACK TRAN
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=24928,
--	@UserLoginID VARCHAR(100)='FNAOPERATOR',
--	@OperationFlag INT=1,
--	@MenuId INT=163,
--	@AuthMode	CHAR(1)='N',
--	@filepath VARCHAR(MAX)='',
--	@EffectiveFromTimeKey INT=24928,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=41

BEGIN

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
      v_FilePathUpload VARCHAR2(100);

   BEGIN
      --DECLARE @Timekey INT
      --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle
      --	WHERE ProcessType='Quarterly')
      SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

        INTO v_Timekey
        FROM SysDataMatrix A
               JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
       WHERE  A.CurrentStatus = 'C';
      DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
      v_EffectiveFromTimeKey := v_TimeKey ;
      v_EffectiveToTimeKey := 49999 ;
      v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
      DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
      DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
      BEGIN

         BEGIN
            --BEGIN TRAN
            IF ( v_MenuId = 1461 ) THEN

            BEGIN
               IF ( v_OperationFlag = 1 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE NOT ( EXISTS ( SELECT 1 
                                           FROM SecuritizedDetail_stg 
                                            WHERE  filname = v_FilePathUpload ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     --Rollback tran
                     v_Result := -8 ;
                     RETURN v_Result;

                  END;
                  END IF;
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM SecuritizedDetail_stg 
                                      WHERE  FILNAME = v_FilePathUpload );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN
                   DECLARE
                     v_ExcelUploadId NUMBER(10,0);
                     v_SummaryId NUMBER(10,0);

                  BEGIN
                     INSERT INTO ExcelUploadHistory
                       ( UploadedBy, DateofUpload, AuthorisationStatus
                     --,Action	
                     , UploadType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                       ( SELECT v_UserLoginID ,
                                SYSDATE ,
                                'NP' ,
                                --,'NP'
                                'Securitized Upload' ,
                                v_EffectiveFromTimeKey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginId ,
                                SYSDATE 
                           FROM DUAL  );
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     SELECT MAX(UniqueUploadID)  

                       INTO v_ExcelUploadId
                       FROM ExcelUploadHistory ;
                     INSERT INTO UploadStatus
                       ( FileNames, UploadedBy, UploadDateTime, UploadType )
                       VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Securitized Upload' );
                     INSERT INTO SecuritizedDetail_MOD
                       ( SrNo, UploadID, SummaryID, PoolID, PoolName, SecuritisationType, CustomerID, AccountID, POS, InterestReceivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, SecuritizedExposureAmt, OSBalance, SecuritisationExposureinRs, DateofSecuritisationreckoning, DateofSecuritisationmarking, MaturityDate )
                       ( SELECT SrNo ,
                                v_ExcelUploadId ,
                                SummaryID ,
                                PoolID ,
                                PoolName ,
                                SecuritisationType ,
                                CustomerID ,
                                AccountID ,
                                PrincipalOutstandinginRs ,
                                InterestReceivableinRs ,
                                'NP' ,
                                v_Timekey ,
                                49999 ,
                                v_UserLoginID ,
                                SYSDATE ,
                                SecuritisationExposureinRs ,
                                OSBalanceinRs ,
                                SecuritisationExposureinRs ,
                                DateofSecuritisationreckoning ,
                                DateofSecuritisationmarking ,
                                MaturityDate 
                         FROM SecuritizedDetail_stg 
                          WHERE  FilName = v_FilePathUpload );
                     SELECT NVL(( SELECT MAX(SummaryId)  
                       FROM SecuritizedSummary_Mod  ), 0)

                       INTO v_SummaryId
                       FROM DUAL ;
                     INSERT INTO SecuritizedSummary_stg
                       ( UploadID, SummaryID, PoolID, PoolName, SecuritisationType, POS, NoOfAccount, SecuritisationExposureAmt, SecuritisationReckoningDate, SecuritisationMarkingDate, MaturityDate, TotalPosBalance, TotalInttReceivable )
                       SELECT v_ExcelUploadId ,
                              v_SummaryId + ROW_NUMBER() OVER ( ORDER BY PoolID  ) ,
                              PoolID ,
                              PoolName ,
                              SecuritisationType ,
                              SUM(NVL(UTILS.CONVERT_TO_NUMBER(PrincipalOutstandinginRs,16,2), 0) + NVL(UTILS.CONVERT_TO_NUMBER(InterestReceivableinRs,16,2), 0))  ,
                              COUNT(PoolID)  ,
                              SUM(NVL(UTILS.CONVERT_TO_NUMBER(SecuritisationExposureinRs,16,2), 0))  ,
                              DateofSecuritisationReckoning ,
                              DateofSecuritisationMarking ,
                              MaturityDate ,
                              SUM(NVL(UTILS.CONVERT_TO_NUMBER(PrincipalOutstandinginRs,16,2), 0))  ,
                              SUM(NVL(UTILS.CONVERT_TO_NUMBER(InterestReceivableinRs,16,2), 0))  
                         FROM SecuritizedDetail_stg 
                        WHERE  FilName = v_FilePathUpload
                         GROUP BY PoolID,PoolName,SecuritisationType,DateofSecuritisationReckoning,DateofSecuritisationMarking,MaturityDate;
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     --		--INSERT INTO SecuritizedSummary_Mod
                     --		--(
                     --		--	UploadID
                     --		--	,SummaryID
                     --		--	,PoolID
                     --		--	,PoolName
                     --		--	,BalanceOutstanding
                     --		--	,NoOfAccount
                     --		--	,AuthorisationStatus	
                     --		--	,EffectiveFromTimeKey	
                     --		--	,EffectiveToTimeKey	
                     --		--	,CreatedBy	
                     --		--	,DateCreated	
                     --		--)
                     --		--SELECT
                     --		--	@ExcelUploadId
                     --		--	,@SummaryId+Row_Number() over(Order by PoolID)
                     --		--	,PoolID
                     --		--	,PoolName
                     --		--	,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))
                     --		--	,Count(PoolID)
                     --		--	,'NP'	
                     --		--	,@Timekey
                     --		--	,49999	
                     --		--	,@UserLoginID	
                     --		--	,GETDATE()
                     --		--FROM SecuritizedDetail_stg
                     --		--where FilName=@FilePathUpload
                     --		--Group by PoolID,PoolName
                     --		---DELETE FROM STAGING DATA
                     DELETE SecuritizedDetail_stg

                      WHERE  filname = v_FilePathUpload;

                  END;
                  END IF;

               END;
               END IF;
               --		 ----RETURN @ExcelUploadId
               --		   ----DECLARE @UniqueUploadID INT
               --	--SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
               ----------------Two level Auth. changes----------------------
               IF ( v_OperationFlag = 16 ) THEN

                ----AUTHORIZE
               BEGIN
                  UPDATE SecuritizedDetail_MOD
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE SecuritizedSummary_Mod
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Securitized Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 20 ) THEN

                ----AUTHORIZE
               BEGIN
                  UPDATE SecuritizedDetail_MOD
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE SecuritizedSummary_Mod
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, A.EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
                  FROM A ,SecuritizedDetail A
                         JOIN SecuritizedDetail_MOD B   ON A.AccountID = B.AccountID
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE B.UploadID = v_UniqueUploadID
                    AND A.EffectiveToTimeKey >= 49999) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  -----maintain history
                  INSERT INTO SecuritizedDetail
                    ( SummaryID, PoolID, PoolName, SecuritisationType, CustomerID, AccountID, POS, InterestReceivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, SecuritizedExposureAmt, OSBalance, SecuritisationExposureinRs, DateofSecuritisationreckoning, DateofSecuritisationmarking, MaturityDate )
                    ( SELECT SummaryID ,
                             PoolID ,
                             PoolName ,
                             SecuritisationType ,
                             CustomerID ,
                             AccountID ,
                             POS ,
                             InterestReceivable ,
                             AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             v_UserLoginID ,
                             SYSDATE ,
                             SecuritizedExposureAmt ,
                             OSBalance ,
                             SecuritisationExposureinRs ,
                             DateofSecuritisationreckoning ,
                             DateofSecuritisationmarking ,
                             MaturityDate 
                      FROM SecuritizedDetail_MOD A
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND EffectiveToTimeKey >= v_Timekey );
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, A.EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
                  FROM A ,SecuritizedFinalACDetail A
                         JOIN SecuritizedDetail_MOD B   ON A.AccountID = B.AccountID
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE B.UploadID = v_UniqueUploadID
                    AND A.EffectiveToTimeKey >= 49999) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  /*
                  ---new add
                  alter table SecuritizedFinalACDetail
                  add ScrOutDate date,ScrInDate Date


                  */
                  INSERT INTO SecuritizedFinalACDetail
                    ( SummaryID, PoolID, PoolName, SecuritisationType, CustomerID, AccountID, POS, InterestReceivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, ExposureAmount, ScrInDate, AccountBalance )
                    ( SELECT SummaryID ,
                             PoolID ,
                             PoolName ,
                             SecuritisationType ,
                             CustomerID ,
                             AccountID ,
                             POS ,
                             InterestReceivable ,
                             AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             v_UserLoginID ,
                             SYSDATE ,
                             SecuritizedExposureAmt ,
                             SYSDATE ,
                             OSBalance 
                      FROM SecuritizedDetail_MOD A
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND EffectiveToTimeKey >= v_Timekey );
                  INSERT INTO SecuritizedFinalACSummary
                    ( SummaryID, PoolID, PoolName, SecuritisationType, POS, SecuritisationExposureAmt, SecuritisationReckoningDate, SecuritisationMarkingDate, MaturityDate, NoOfAccount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, TotalPosBalance, TotalInttReceivable )
                    ( 
                      --,ScrInDate 
                      SELECT SummaryID ,
                             PoolID ,
                             PoolName ,
                             SecuritisationType ,
                             POS ,
                             SecuritisationExposureAmt ,
                             SecuritisationReckoningDate ,
                             SecuritisationMarkingDate ,
                             MaturityDate ,
                             NoOfAccount ,
                             AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             v_UserLoginID ,
                             SYSDATE ,
                             TotalPosBalance ,
                             TotalInttReceivable 

                      --,GETDATE()
                      FROM SecuritizedSummary_Mod A
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND EffectiveToTimeKey >= v_Timekey );
                  INSERT INTO SecuritizedSummary
                    ( SummaryID, PoolID, PoolName, SecuritisationType, POS, SecuritisationExposureAmt, SecuritisationReckoningDate, SecuritisationMarkingDate, DateofRemoval, NoOfAccount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT SummaryID ,
                             PoolID ,
                             PoolName ,
                             SecuritisationType ,
                             POS ,--,BalanceOutstanding

                             SecuritisationExposureAmt ,
                             SecuritisationReckoningDate ,
                             SecuritisationMarkingDate ,
                             MaturityDate ,
                             NoOfAccount ,
                             AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM SecuritizedSummary_Mod A
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND EffectiveToTimeKey >= v_Timekey );
                  /*--------------------Adding Flag To AdvAcOtherDetail------------Pranay 21-03-2021--------*/
                  IF utils.object_id('TempDB..tt_SecuritizeNew') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SecuritizeNew ';
                  END IF;
                  DELETE FROM tt_SecuritizeNew;
                  UTILS.IDENTITY_RESET('tt_SecuritizeNew');

                  INSERT INTO tt_SecuritizeNew ( 
                  	SELECT A.RefSystemAcId ,
                          A.SplFlag 
                  	  FROM RBL_MISDB_PROD.AdvAcOtherDetail A
                            JOIN SecuritizedDetail_MOD B   ON A.RefSystemAcId = B.AccountID
                  	 WHERE  B.UploadID = v_UniqueUploadID
                             AND B.EffectiveToTimeKey >= v_Timekey
                             AND A.EffectiveToTimeKey = 49999
                             AND A.SplFlag LIKE '%Securitised%' );
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, CASE 
                  WHEN NVL(A.SplFlag, ' ') = ' ' THEN 'Securitised'
                  ELSE A.SplFlag || ',' || 'Securitised'
                     END AS SplFlag
                  FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                       --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId

                         JOIN SecuritizedDetail_MOD B   ON A.RefSystemAcId = B.AccountID 
                   WHERE B.UploadID = v_UniqueUploadID
                    AND B.EffectiveToTimeKey >= v_Timekey
                    AND A.EffectiveToTimeKey = 49999
                    AND NOT EXISTS ( SELECT 1 
                                     FROM tt_SecuritizeNew N
                                      WHERE  N.RefSystemAcId = A.RefSystemAcId )) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.SplFlag = src.SplFlag;
                  -------------------------------------------
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, utils.round_(B.POS, 2) AS pos_2, v_UserLoginID, SYSDATE
                  FROM A ,SecuritizedDetail A
                         JOIN SecuritizedDetail_MOD B   ON ( A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey )
                         AND ( B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey )
                         AND A.AccountID = B.AccountID 
                   WHERE B.AuthorisationStatus = 'A'
                    AND B.UploadID = v_UniqueUploadID) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.POS = pos_2,
                                               a.ModifyBy = v_UserLoginID,
                                               a.DateModified = SYSDATE;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Securitized Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 17 ) THEN

                ----REJECT
               BEGIN
                  UPDATE SecuritizedDetail_MOD
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE SecuritizedSummary_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Securitized Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 21 ) THEN

                ----REJECT
               BEGIN
                  UPDATE SecuritizedDetail_MOD
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus IN ( 'NP','1A' )
                  ;
                  UPDATE SecuritizedSummary_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus IN ( 'NP','1A' )
                  ;
                  --			----SELECT * FROM IBPCPoolDetail
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Securitized Upload';

               END;
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
                   v_ReferenceID => v_UniqueUploadID -- ReferenceID ,
                   ,
                   v_CreatedBy => NULL,
                   v_ApprovedBy => v_UserLoginID,
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
                   v_ReferenceID => v_UniqueUploadID -- ReferenceID ,
                   ,
                   v_CreatedBy => v_UserLoginID,
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
            --COMMIT TRAN
            ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
            v_Result := CASE 
                             WHEN v_OperationFlag = 1
                               AND v_MenuId = 1461 THEN v_ExcelUploadId
            ELSE 1
               END ;
            UPDATE UploadStatus
               SET InsertionOfData = 'Y',
                   InsertionCompletedOn = SYSDATE
             WHERE  FileNames = v_filepath;
            --		 ---- IF EXISTS(SELECT 1 FROM SecuritizedDetail_stg WHERE filEname=@FilePathUpload)
            --		 ----BEGIN
            --			----	 DELETE FROM SecuritizedDetail_stg
            --			----	 WHERE filEname=@FilePathUpload
            --			----	 PRINT 'ROWS DELETED FROM SecuritizedDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
            --		 ----END
            RETURN v_Result;

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT SQLERRM ,
                   utils.error_line 
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         v_Result := -1 ;
         UPDATE UploadStatus
            SET InsertionOfData = 'Y',
                InsertionCompletedOn = SYSDATE
          WHERE  FileNames = v_filepath;
         RETURN -1;

      END;END;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDSTAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
