--------------------------------------------------------
--  DDL for Function BUYOUTMAPPERSTAGEUPLOADDATAINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" 
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
      -------------- IMPLEMENT LOGIC TO RESTRICT DIRECT 2ND LEVEL AUTHORIZATION INSTEAD OF 1ST LEVEL AUTHORIZATION AFTER MAKER ENTRY BY SATWAJI AS ON 27/07/2022
      v_CreatedBy VARCHAR2(50);
      v_ModifiedBy VARCHAR2(50);
      v_ApprovedByFirstLevel1 VARCHAR2(50);
      v_DateApprovedFirstLevel1 DATE;
      ---------------------- IMPLEMENT LOGIC BY SATWAJI AS ON 26/09/2022 TO RESTRICT SAME USER CANNOT BE MADE 1ST LEVEL AUTHORISATION OR 2ND LEVEL AUTHORISATION FROM BACKEND
      v_UserId VARCHAR2(50) := ' ';

   BEGIN
      /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
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
      SELECT CreatedBy ,
             ModifiedBy ,
             ApprovedByFirstLevel ,
             DateApprovedFirstLevel 

        INTO v_CreatedBy,
             v_ModifiedBy,
             v_ApprovedByFirstLevel1,
             v_DateApprovedFirstLevel1
        FROM BuyoutMapperUpload_Mod 
       WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                AND EffectiveToTimeKey >= v_TimeKey )
                AND UploadId = v_UniqueUploadID
                AND AuthorisationStatus IN ( 'NP','MP','DP','RM' )

                AND EntityKey IN ( SELECT MAX(EntityKey)  
                                   FROM BuyoutMapperUpload_Mod 
                                    WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                             AND EffectiveToTimeKey >= v_TimeKey )
                                             AND UploadId = v_UniqueUploadID
                                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
               )

        FETCH FIRST 1 ROWS ONLY;
      IF ( NVL(v_ModifiedBy, v_CreatedBy) <> ' '
        AND NVL(v_ApprovedByFirstLevel1, ' ') = ' '
        AND NVL(v_DateApprovedFirstLevel1, ' ') = ' '
        AND v_OperationFlag IN ( 20,21 )
       ) THEN

      BEGIN
         v_Result := -1 ;
         RETURN v_Result;

      END;
      END IF;
      IF ( v_OperationFlag IN ( 16,17,20,21 )
       ) THEN
       DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         DBMS_OUTPUT.PUT_LINE('16,17,20,21 RESTRICTION');
         IF utils.object_id('TEMPDB..tt_UserIdStatus') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UserIdStatus ';
         END IF;
         DELETE FROM tt_UserIdStatus;
         UTILS.IDENTITY_RESET('tt_UserIdStatus');

         INSERT INTO tt_UserIdStatus ( 
         	SELECT COALESCE(ApprovedByFirstLevel, ModifiedBy, CreatedBy) UserID  
         	  FROM BuyoutMapperUpload_Mod 
         	 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                    AND EffectiveToTimeKey >= v_TimeKey )
                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','R','1A','1D' )

                    AND UploadId = v_UniqueUploadID
                    AND EntityKey IN ( SELECT MAX(EntityKey)  
                                       FROM BuyoutMapperUpload_Mod 
                                        WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey )
                                                 AND UploadId = v_UniqueUploadID
                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','R','1A','1D' )
                   )
          );
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM tt_UserIdStatus 
                             WHERE  UserID = v_UserLoginID );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Result = -1');
            v_Result := -1 ;
            RETURN v_Result;

         END;
         END IF;

      END;
      END IF;
      BEGIN

         BEGIN
            --BEGIN TRAN
            IF ( v_MenuId = 24748 ) THEN

            BEGIN
               IF ( v_OperationFlag = 1 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE NOT ( EXISTS ( SELECT 1 
                                           FROM Buyoutaccountmapper_stg 
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
                                     FROM Buyoutaccountmapper_stg 
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
                                'Buyout Mapper Upload' ,
                                v_EffectiveFromTimeKey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginID ,
                                SYSDATE 
                           FROM DUAL  );
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     SELECT MAX(UniqueUploadID)  

                       INTO v_ExcelUploadId
                       FROM ExcelUploadHistory ;
                     INSERT INTO UploadStatus
                       ( FileNames, UploadedBy, UploadDateTime, UploadType )
                       VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Buyout Mapper Upload' );
                     INSERT INTO BuyoutMapperUpload_Mod
                       ( SrNo, UploadID, SchemeCode, AccountNoinRBLHostSystem, AccountNoofSeller, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated )
                       ( SELECT SlNo ,
                                v_ExcelUploadId ,
                                SchemeCode ,
                                AccountNoinRBLHostSystem ,
                                AccountNoofSeller ,
                                v_Timekey ,
                                49999 ,
                                'NP' ,
                                v_UserLoginID ,
                                SYSDATE 
                         FROM Buyoutaccountmapper_stg 
                          WHERE  FilName = v_FilePathUpload );
                     SELECT NVL(( SELECT MAX(SummaryId)  
                       FROM BuyoutMapperSummary_Mod  ), 0)

                       INTO v_SummaryId
                       FROM DUAL ;
                     INSERT INTO BuyoutaccountmapperSummary_stg
                       ( UploadID, SummaryID, NoOfAccount, SchemeCode )
                       SELECT v_ExcelUploadId ,
                              v_SummaryId + ROW_NUMBER() OVER ( ORDER BY AccountNoinRBLHostSystem  ) ,
                              COUNT(AccountNoinRBLHostSystem)  ,
                              SchemeCode 
                         FROM Buyoutaccountmapper_stg 
                        WHERE  FilName = v_FilePathUpload
                         GROUP BY SchemeCode,AccountNoinRBLHostSystem;
                     --INSERT INTO [BuyoutUploadDetails_Mod]
                     --(
                     --	SlNo
                     --	,UploadID
                     --	,DateofData
                     --	,ReportDate
                     --	,CustomerAcID
                     --	,SchemeCode
                     --	,NPA_ClassSeller
                     --	,NPA_DateSeller
                     --	,DPD_Seller
                     --	,PeakDPD
                     --	,PeakDPD_Date
                     --	,AuthorisationStatus	
                     --	,EffectiveFromTimeKey	
                     --	,EffectiveToTimeKey	
                     --	,CreatedBy	
                     --	,DateCreated
                     --)
                     --SELECT
                     --	SlNo
                     --	,@ExcelUploadId
                     --	,NULL
                     --	,Case When ISNULL(ReportDate,'')<>'' Then Convert(Date,ReportDate) Else NULL END ReportDate
                     --	,CustomerAcID
                     --	,SchemeCode
                     --	,NPA_ClassSeller
                     --	,Case When ISNULL(NPA_DateSeller,'')<>'' Then Convert(Date,NPA_DateSeller) Else NULL END NPA_DateSeller
                     --	,DPD_Seller
                     --	,PeakDPD
                     --	,Case When ISNULL(PeakDPD_Date,'')<>'' Then Convert(Date,PeakDPD_Date) Else NULL END PeakDPD_Date
                     --	,'NP'	
                     --	,@Timekey
                     --	,49999	
                     --	,@UserLoginID	
                     --	,GETDATE()
                     --FROM Buyoutaccountmapper_stg
                     --where FilName=@FilePathUpload 
                     --INSERT INTO IBPCPoolSummary_Mod
                     --(
                     --	UploadID
                     --	,SummaryID
                     --	,PoolID
                     --	,PoolName
                     --	,BalanceOutstanding
                     --	,NoOfAccount
                     --	,AuthorisationStatus	
                     --	,EffectiveFromTimeKey	
                     --	,EffectiveToTimeKey	
                     --	,CreatedBy	
                     --	,DateCreated	
                     --)
                     --SELECT
                     --	@ExcelUploadId
                     --	,@SummaryId+Row_Number() over(Order by PoolID)
                     --	,PoolID
                     --	,PoolName
                     --	,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))
                     --	,Count(PoolID)
                     --	,'NP'	
                     --	,@Timekey
                     --	,49999	
                     --	,@UserLoginID	
                     --	,GETDATE()
                     --FROM IBPCPoolDetail_stg
                     --where FilName=@FilePathUpload
                     --Group by PoolID,PoolName
                     IF utils.object_id('TempDB..tt_Buyout_Upload') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Buyout_Upload ';
                     END IF;
                     DELETE FROM tt_Buyout_Upload;
                     INSERT INTO tt_Buyout_Upload
                       ( AccountNoinRBLHostSystem, FieldName )
                       ( 
                         -- Select SummaryID, 'AUNo' FieldName from BuyoutUploadDetails_stg Where isnull(AUNo,'')<>'' 

                         --UNION ALL
                         SELECT AccountNoinRBLHostSystem ,
                                'SchemeCode' FieldName  
                         FROM Buyoutaccountmapper_stg 
                          WHERE  NVL(SchemeCode, ' ') <> ' '
                         UNION 
                         SELECT AccountNoinRBLHostSystem ,
                                'AccountNoofSeller' FieldName  
                         FROM Buyoutaccountmapper_stg 
                          WHERE  NVL(AccountNoofSeller, ' ') <> ' '
                         UNION ALL 
                         SELECT AccountNoinRBLHostSystem ,
                                'AccountNoinRBLHostSystem' FieldName  
                         FROM Buyoutaccountmapper_stg 
                          WHERE  NVL(AccountNoinRBLHostSystem, ' ') <> ' ' );
                     DBMS_OUTPUT.PUT_LINE('nanda3');
                     --select *
                     MERGE INTO B 
                     USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                     FROM B ,MetaScreenFieldDetail A
                            JOIN tt_Buyout_Upload B   ON A.CtrlName = B.FieldName 
                      WHERE A.MenuId = 24748
                       AND A.IsVisible = 'Y') src
                     ON ( B.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                     DBMS_OUTPUT.PUT_LINE('nanda4');
                     IF utils.object_id('TEMPDB..tt_NEWTRANCHE_31') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_31 ';
                     END IF;
                     DELETE FROM tt_NEWTRANCHE_31;
                     UTILS.IDENTITY_RESET('tt_NEWTRANCHE_31');

                     INSERT INTO tt_NEWTRANCHE_31 SELECT * 
                          FROM ( SELECT ss.AccountNoinRBLHostSystem ,
                                        ss.AccountNoofSeller ,
                                        utils.stuff(( SELECT ',' || US.SrNo 
                                                      FROM tt_Buyout_Upload US
                                                       WHERE  US.AccountNoinRBLHostSystem = ss.AccountNoinRBLHostSystem ), 1, 1, ' ') REPORTIDSLIST  
                                 FROM Buyoutaccountmapper_stg SS
                                   GROUP BY ss.AccountNoinRBLHostSystem,ss.AccountNoofSeller ) B
                          ORDER BY 1;
                     --Select * from BuyoutMapperUpload_Mod
                     --SELECT * 
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                     FROM A ,RBL_MISDB_PROD.BuyoutMapperUpload_Mod A
                            JOIN tt_NEWTRANCHE_31 B   ON A.AccountNoinRBLHostSystem = B.AccountNoinRBLHostSystem
                            AND A.AccountNoofSeller = B.AccountNoofSeller 
                      WHERE A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND A.UploadID = v_ExcelUploadId) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.ChangeFields = src.REPORTIDSLIST;
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     ---DELETE FROM STAGING DATA
                     DELETE Buyoutaccountmapper_stg

                      WHERE  filname = v_FilePathUpload;

                  END;
                  END IF;

               END;
               END IF;
               ----RETURN @ExcelUploadId
               ----DECLARE @UniqueUploadID INT
               --SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
               ----------------------Two level Auth. Changes-------------
               IF ( v_OperationFlag = 16 ) THEN

                ----AUTHORIZE
               BEGIN
                  UPDATE BuyoutMapperUpload_Mod
                     SET AuthorisationStatus = '1A',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE BuyoutMapperSummary_Mod
                     SET AuthorisationStatus = '1A',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Buyout Mapper Upload';

               END;
               END IF;
               --------------------------------------------
               IF ( v_OperationFlag = 20 ) THEN

                ----AUTHORIZE
               BEGIN
                  UPDATE BuyoutMapperUpload_Mod
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE BuyoutMapperSummary_Mod
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  -----maintain history
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                  FROM A ,BuyoutMapperUpload A
                         JOIN BuyoutMapperUpload_Mod B   ON A.AccountNoinRBLHostSystem = B.AccountNoinRBLHostSystem
                         AND B.EffectiveFromTimeKey <= v_Timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE B.UploadID = v_UniqueUploadID
                    AND A.EffectiveToTimeKey >= 49999) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  INSERT INTO BuyoutMapperUpload
                    ( SrNo, UploadID, SchemeCode, AccountNoinRBLHostSystem, AccountNoofSeller, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT SrNo ,
                             UploadID ,
                             SchemeCode ,
                             AccountNoinRBLHostSystem ,
                             AccountNoofSeller ,
                             v_Timekey ,
                             49999 ,
                             AuthorisationStatus ,
                             CreatedBy ,
                             DateCreated ,
                             ModifiedBy ,
                             DateModified ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM BuyoutMapperUpload_Mod A
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey );
                  INSERT INTO BuyoutMapperSummary
                    ( SrNo, UploadID, SchemeCode, SummaryID, NoOfAccount, EffectiveFromTimeKey, EffectiveToTimeKey, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT SrNo ,
                             UploadID ,
                             SchemeCode ,
                             SummaryID ,
                             NoOfAccount ,
                             v_Timekey ,
                             49999 ,
                             AuthorisationStatus ,
                             CreatedBy ,
                             DateCreated ,
                             ModifiedBy ,
                             DateModified ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM BuyoutMapperSummary_Mod A
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey );
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Buyout Mapper Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 17 ) THEN

                ----REJECT
               BEGIN
                  UPDATE BuyoutMapperUpload_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE BuyoutMapperSummary_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Buyout Mapper Upload';

               END;
               END IF;
               --------------------Two level Auth. Changes---------------
               IF ( v_OperationFlag = 21 ) THEN

                ----REJECT
               BEGIN
                  UPDATE BuyoutMapperUpload_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus IN ( 'NP','1A' )
                  ;
                  UPDATE BuyoutMapperSummary_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus IN ( 'NP','1A' )
                  ;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Buyout Mapper Upload';

               END;
               END IF;

            END;
            END IF;
            ---------------------------------------------------------------------
            IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

              AND v_AuthMode = 'Y' THEN
             DECLARE
               v_DateCreated DATE;
               v_ReferenceID1 VARCHAR2(4000);

            BEGIN
               DBMS_OUTPUT.PUT_LINE('log table');
               v_DateCreated := SYSDATE ;
               v_ReferenceID1 := (CASE 
                                       WHEN v_OperationFlag IN ( 16,20,21 )
                                        THEN v_UniqueUploadID
               ELSE v_ExcelUploadId
                  END) ;
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
                   iv_CreatedCheckedDt => v_DateCreated,
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
                   v_ReferenceID => v_ExcelUploadId -- ReferenceID ,
                   ,
                   v_CreatedBy => v_UserLoginID,
                   v_ApprovedBy => NULL,
                   iv_CreatedCheckedDt => v_DateCreated,
                   v_Remark => NULL,
                   v_ScreenEntityAlt_Key => 16 ---ScreenEntityId -- for FXT060 screen
                   ,
                   v_Flag => v_OperationFlag,
                   v_AuthMode => v_AuthMode) ;

               END;
               END IF;

            END;
            END IF;
            --COMMIT TRAN
            ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
            v_Result := CASE 
                             WHEN v_OperationFlag = 1
                               AND v_MenuId = 24748 THEN v_ExcelUploadId
            ELSE 1
               END ;
            UPDATE UploadStatus
               SET InsertionOfData = 'Y',
                   InsertionCompletedOn = SYSDATE
             WHERE  FileNames = v_filepath;
            ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)
            ----BEGIN
            ----	 DELETE FROM IBPCPoolDetail_stg
            ----	 WHERE filEname=@FilePathUpload
            ----	 PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
            ----END
            RETURN v_Result;

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         ------RETURN @UniqueUploadID
         --ROLLBACK TRAN
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERSTAGEUPLOADDATAINUP" TO "ADF_CDR_RBL_STGDB";
