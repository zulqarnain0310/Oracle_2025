--------------------------------------------------------
--  DDL for Function ACCOUNTFLAGGINGSTAGEDATAINUP_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" 
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
  v_UniqueUploadID IN NUMBER,
  iv_UploadTypeParameterAlt_Key IN NUMBER
)
RETURN NUMBER
AS
   v_UploadTypeParameterAlt_Key NUMBER(10,0) := iv_UploadTypeParameterAlt_Key;
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_temp NUMBER(1, 0) := 0;
   ----------------------------------------------------ADDED BY Prashant------17-08-2022--to remove TWO flag marking on current Date------------------------------------------
   v_TimekeyTWO NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
   --Declare @TwoStatusAlt_Key INT 
   --SET @TwoStatusAlt_Key = (select UploadTypeParameterAlt_Key from AccountFlaggingDetails_Mod
   --												 where EffectiveFromTimeKey <=@Timekey and EffectiveToTimeKey >=@Timekey and UploadTypeParameterAlt_Key=1)
   v_FilePathUpload VARCHAR2(100);
--@UploadType varchar(50)
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
   --DECLARE @Timekey INT
   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle
   --	WHERE ProcessType='Quarterly')
   IF NVL(v_UploadTypeParameterAlt_Key, ' ') = ' ' THEN

   BEGIN
      SELECT DISTINCT UploadTypeParameterAlt_Key 

        INTO v_UploadTypeParameterAlt_Key
        FROM AccountFlaggingDetails_Mod 
       WHERE  UploadID = v_UniqueUploadID;

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE v_UploadTypeParameterAlt_Key = ( SELECT DISTINCT ParameterAlt_Key 
                                              FROM DimParameter 
                                               WHERE  DimParameterName = 'UploadFlagType'
                                                        AND ParameterName = 'TWO' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      SELECT DISTINCT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  MOC_Initialised = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';

   END;
   ELSE

   BEGIN
      SELECT DISTINCT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

        INTO v_Timekey
        FROM SysDataMatrix A
               JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
       WHERE  A.CurrentStatus = 'C';

   END;
   END IF;
   SELECT DISTINCT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

     INTO v_TimekeyTWO
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
   --------------------------------------------------------------------------END-------------------------------------------------------------------------------------------------------
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key 
        FROM DimParameter 
       WHERE  DimParameterName = 'UploadFlagType'
                AND ParameterName = 'TWO' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
   DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
   DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
   BEGIN

      BEGIN
         --BEGIN TRAN
         IF ( v_MenuId = 1470 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM AccountFlagging_Stg 
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
                                  FROM AccountFlagging_Stg 
                                   WHERE  FILNAME = v_FilePathUpload );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN
                DECLARE
                  v_ExcelUploadId NUMBER(10,0);

               BEGIN
                  INSERT INTO ExcelUploadHistory
                    ( UploadedBy, DateofUpload, AuthorisationStatus
                  --,Action	
                  , UploadType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT v_UserLoginID ,
                             SYSDATE ,
                             'NP' ,
                             --,'NP'
                             'Account Flagging Upload' ,
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
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Account Flagging Upload' );
                  INSERT INTO AccountFlaggingDetails_Mod
                    ( UploadID, ACID, Amount, Date_
                  --,UploadType
                  , ACTION, UploadTypeParameterAlt_Key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT v_ExcelUploadId ,
                             ACID ,
                             CASE 
                                  WHEN Amount = ' ' THEN NULL
                             ELSE Amount
                                END Amount  ,
                             Date_ ,
                             ACTION ,
                             --,@UploadType
                             v_UploadTypeParameterAlt_Key ,
                             'NP' ,
                             v_Timekey ,
                             49999 ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM AccountFlagging_Stg 

                      --A

                      --Inner Join (Select ParameterAlt_Key,ParameterName,'UploadType' as Tablename 

                      --				  from DimParameter where DimParameterName='UploadFLagType'

                      --				  And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)B

                      --				  ON A.UploadTypeParameterAlt_Key=B.ParameterAlt_Key
                      WHERE  FilName = v_FilePathUpload );
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                  --AND @UploadTypeParameterAlt_Key=1
                  --and A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                  ----Declare @SummaryId int
                  ----Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)
                  ----INSERT INTO IBPCPoolSummary_stg
                  ----(
                  ----	UploadID
                  ----	,SummaryID
                  ----	,PoolID
                  ----	,PoolName
                  ----	,PoolType
                  ----	,BalanceOutstanding
                  ----	,NoOfAccount
                  ----	,IBPCExposureAmt
                  ----	,IBPCReckoningDate
                  ----	,IBPCMarkingDate
                  ----	,MaturityDate
                  ----	,TotalPosBalance
                  ----	,TotalInttReceivable
                  ----)
                  ----SELECT
                  ----	@ExcelUploadId
                  ----	,@SummaryId+Row_Number() over(Order by PoolID)
                  ----	,PoolID
                  ----	,PoolName
                  ----	,PoolType
                  ----	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
                  ----	,Count(PoolID)
                  ----	,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
                  ----	,DateofIBPCreckoning
                  ----	,DateofIBPCmarking
                  ----	,MaturityDate
                  ----	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
                  ----	,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
                  ----FROM IBPCPoolDetail_stg
                  ----where FilName=@FilePathUpload
                  ----Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate
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
                  ---DELETE FROM STAGING DATA
                  DELETE AccountFlagging_Stg

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
               UPDATE AccountFlaggingDetails_Mod
                  SET
                  --AuthorisationStatus	='1A'
                   --,ApprovedBy	=@UserLoginID
                   --,DateApproved	=GETDATE()
                AuthorisationStatus = '1A',
                ApprovedByFirstLevel = v_UserLoginID,
                DateApprovedFirstLevel = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID

               --,ApprovedByFirstLevel=@UserLoginID

               --,DateApprovedFirstLevel=GETDATE()
               WHERE  UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Account Flagging Upload';

            END;
            END IF;
            --------------------------------------------
            IF ( v_OperationFlag = 20 ) THEN
             DECLARE
               v_StatusTypeName VARCHAR2(100);
               ---------------------
               -----------Remove------------------------
               -------select distinct * from AccountFlaggingDetails_Mod where UploadId=543 and Action='N'
               ---------------------------Added By Prashant-----------------------17-08-2022------To remove TWO flag on current Date--------------------------------------------------------------
               v_ParametereAltKey NUMBER(10,0) := ( SELECT DISTINCT UploadTypeParameterAlt_Key 
                 FROM AccountFlaggingDetails_Mod 
                WHERE  UploadId = v_UniqueUploadID
                         AND ACTION = 'N' );
               v_ParameterName VARCHAR2(100);

             ----AUTHORIZE
            BEGIN
               UPDATE AccountFlaggingDetails_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
               FROM A ,AccountFlaggingDetails A
                      JOIN AccountFlaggingDetails_Mod C   ON A.ACID = C.ACID
                      AND A.UploadTypeParameterAlt_Key = C.UploadTypeParameterAlt_Key
                      AND C.EffectiveFromTimeKey <= v_Timekey
                      AND C.EffectiveToTimeKey >= v_Timekey
                      AND C.AuthorisationStatus = 'A' 
                WHERE A.EffectiveToTimeKey >= v_Timekey
                 AND A.AuthorisationStatus = 'A'
                 AND UploadId = v_UniqueUploadID
                 AND C.Action = 'Y') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               SELECT ParameterName 

                 INTO v_StatusTypeName
                 FROM DimParameter 
                WHERE  DimParameterName = 'uploadflagtype'
                         AND EffectiveToTimeKey = 49999
                         AND ParameterAlt_Key = ( SELECT DISTINCT UploadTypeParameterAlt_Key 
                                                  FROM AccountFlaggingDetails_Mod 
                                                   WHERE  UploadId = v_UniqueUploadID
                                                            AND ACTION = 'N' );
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
               FROM A ,ExceptionFinalStatusType A
                      JOIN AccountFlaggingDetails_Mod C   ON A.ACID = C.ACID
                      AND C.EffectiveFromTimeKey <= v_Timekey
                      AND C.EffectiveToTimeKey >= v_Timekey
                      AND C.AuthorisationStatus = 'A' 
                WHERE A.EffectiveToTimeKey >= v_Timekey
                 AND C.UploadID = v_UniqueUploadID
                 AND C.Action = 'Y'
                 AND A.StatusType = v_StatusTypeName) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               -----maintain history
               INSERT INTO AccountFlaggingDetails
                 ( ACID, Amount, Date_
               --,UploadType
               , ACTION, UploadTypeParameterAlt_Key, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved )
                 ( SELECT ACID ,
                          Amount ,
                          Date_ ,
                          ACTION ,
                          --,@UploadType
                          --,@UploadTypeParameterAlt_Key
                          UploadTypeParameterAlt_Key ,
                          AuthorisationStatus ,
                          v_Timekey ,
                          49999 ,
                          CreatedBy ,
                          DateCreated ,
                          ModifyBy ,
                          DateModified ,
                          v_UserLoginID ,
                          SYSDATE 
                   FROM AccountFlaggingDetails_Mod A
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND ACTION = 'Y'

                             --AND @UploadTypeParameterAlt_Key=1
                             AND EffectiveToTimeKey >= v_Timekey );
               INSERT INTO ExceptionFinalStatusType
                 ( SourceAlt_Key, CustomerID, ACID, StatusType, StatusDate, Amount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved )
                 ( SELECT B.SourceAlt_Key ,
                          B.RefCustomerId ,
                          ACID ,
                          H.ParameterName ,
                          Date_ ,
                          Amount ,
                          A.AuthorisationStatus ,
                          a.EffectiveFromTimeKey ,
                          49999 ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          ModifyBy ,
                          A.DateModified ,
                          v_UserLoginID ,
                          SYSDATE 
                   FROM AccountFlaggingDetails_Mod A
                          JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.ACID = B.CustomerACID
                          JOIN ( SELECT ParameterAlt_Key ,
                                        ParameterName ,
                                        'DimYesNo' Tablename  
                                 FROM DimParameter 
                                  WHERE  DimParameterName = 'UploadFlagType'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UploadTypeParameterAlt_Key
                          AND B.EffectiveFromTimeKey <= v_Timekey
                          AND B.EffectiveToTimeKey >= v_Timekey
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND A.Action = 'Y' );
               /*Adding Flag ---------- 02-04-2021*/
               IF utils.object_id('TempDB..tt_Flags_3') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Flags_3 ';
               END IF;
               DELETE FROM tt_Flags_3;
               UTILS.IDENTITY_RESET('tt_Flags_3');

               INSERT INTO tt_Flags_3 ( 
               	SELECT A.ACID ,
                       B.SplCatShortNameEnum 
               	  FROM AccountFlaggingDetails_Mod A
                         JOIN ( SELECT B.ParameterAlt_Key ,
                                       A.SplCatShortNameEnum 
                                FROM DimAcSplCategory A
                                       JOIN DimParameter B   ON A.SplCatName = B.ParameterName
                                       AND B.EffectiveToTimeKey = 49999
                                 WHERE  A.SplCatGroup = 'SplFlags'
                                          AND A.EffectiveToTimeKey = 49999
                                          AND B.DimParameterName = 'uploadflagtype' ) B   ON A.UploadTypeParameterAlt_Key = B.ParameterAlt_Key
               	 WHERE  A.UploadId = v_UniqueUploadID
                          AND A.ACTION = 'Y' );
               --		Declare @variable Varchar(100)=''
               --Set @variable=(Select Splcatshortnameenum from dimacsplcategory  where splcatgroup='splflags' and 
               --SplCatName like (select ParameterName from dimparameter
               --where dimparametername ='UploadFLagType' and ParameterAlt_Key=@UploadTypeParameterAlt_Key))
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN NVL(A.SplFlag, ' ') = ' ' THEN B.SplCatShortNameEnum
               ELSE A.SplFlag || ',' || B.SplCatShortNameEnum
                  END AS SplFlag
               FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                      JOIN tt_Flags_3 B   ON A.RefSystemAcId = B.ACID 
                WHERE A.EffectiveToTimeKey = 49999) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.SplFlag --'IBPC'     
                                             = src.SplFlag;
               IF v_ParametereAltKey = 1 THEN

               BEGIN
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, v_TimekeyTWO - 1 AS EffectiveToTimeKey
                  FROM B ,AccountFlaggingDetails_Mod A
                         JOIN AccountFlaggingDetails B   ON A.ACID = B.ACID
                         AND B.EffectiveFromTimeKey <= v_timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.UploadID = v_UniqueUploadID
                    AND A.Action = 'N'
                    AND B.UploadTypeParameterAlt_Key = A.UploadTypeParameterAlt_Key) src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  --AND A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, v_TimekeyTWO - 1 AS EffectiveToTimeKey
                  FROM B ,AccountFlaggingDetails_Mod A
                         JOIN ExceptionalDegrationDetail B   ON A.ACID = B.AccountID
                         AND B.EffectiveFromTimeKey <= v_timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.UploadID = v_UniqueUploadID
                    AND A.Action = 'N'
                    AND B.FlagAlt_Key = A.UploadTypeParameterAlt_Key) src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  --And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                  SELECT ParameterName 

                    INTO v_ParameterName
                    FROM DimParameter 
                   WHERE  DimParameterName = 'uploadflagtype'
                            AND EffectiveToTimeKey = 49999
                            AND ParameterAlt_Key = ( SELECT DISTINCT UploadTypeParameterAlt_Key 
                                                     FROM AccountFlaggingDetails_Mod 
                                                      WHERE  UploadId = v_UniqueUploadID
                                                               AND ACTION = 'N' );
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, v_TimekeyTWO - 1 AS EffectiveToTimeKey
                  FROM B ,AccountFlaggingDetails_Mod A
                         JOIN ExceptionFinalStatusType B   ON A.ACID = B.ACID
                         AND B.EffectiveFromTimeKey <= v_timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.UploadID = v_UniqueUploadID
                    AND A.Action = 'N'

                    --And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                    AND B.StatusType = v_ParameterName) src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;

               END;
               ELSE

               BEGIN
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                  FROM B ,AccountFlaggingDetails_Mod A
                         JOIN AccountFlaggingDetails B   ON A.ACID = B.ACID
                         AND B.EffectiveFromTimeKey <= v_timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.UploadID = v_UniqueUploadID
                    AND A.Action = 'N'
                    AND B.UploadTypeParameterAlt_Key = A.UploadTypeParameterAlt_Key) src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  --AND A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                  FROM B ,AccountFlaggingDetails_Mod A
                         JOIN ExceptionalDegrationDetail B   ON A.ACID = B.AccountID
                         AND B.EffectiveFromTimeKey <= v_timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.UploadID = v_UniqueUploadID
                    AND A.Action = 'N'
                    AND B.FlagAlt_Key = A.UploadTypeParameterAlt_Key) src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  --And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                  SELECT ParameterName 

                    INTO v_ParameterName
                    FROM DimParameter 
                   WHERE  DimParameterName = 'uploadflagtype'
                            AND EffectiveToTimeKey = 49999
                            AND ParameterAlt_Key = ( SELECT DISTINCT UploadTypeParameterAlt_Key 
                                                     FROM AccountFlaggingDetails_Mod 
                                                      WHERE  UploadId = v_UniqueUploadID
                                                               AND ACTION = 'N' );
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                  FROM B ,AccountFlaggingDetails_Mod A
                         JOIN ExceptionFinalStatusType B   ON A.ACID = B.ACID
                         AND B.EffectiveFromTimeKey <= v_timekey
                         AND B.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.UploadID = v_UniqueUploadID
                    AND A.Action = 'N'

                    --And A.UploadTypeParameterAlt_Key=@UploadTypeParameterAlt_Key
                    AND B.StatusType = v_ParameterName) src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.EffectiveToTimeKey = src.EffectiveToTimeKey;

               END;
               END IF;
               -----------------------------------------------------------------------END---------------------------------------------------------------------------------
               IF utils.object_id('TempDB..tt_Flags_31') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Flags1_3 ';
               END IF;
               DELETE FROM tt_Flags1_3;
               UTILS.IDENTITY_RESET('tt_Flags1_3');

               INSERT INTO tt_Flags1_3 ( 
               	SELECT A.ACID ,
                       B.SplCatShortNameEnum 
               	  FROM AccountFlaggingDetails_Mod A
                         JOIN ( SELECT B.ParameterAlt_Key ,
                                       A.SplCatShortNameEnum 
                                FROM DimAcSplCategory A
                                       JOIN DimParameter B   ON A.SplCatName = B.ParameterName
                                       AND B.EffectiveToTimeKey = 49999
                                 WHERE  A.SplCatGroup = 'SplFlags'
                                          AND A.EffectiveToTimeKey = 49999
                                          AND B.DimParameterName = 'uploadflagtype' ) B   ON A.UploadTypeParameterAlt_Key = B.ParameterAlt_Key
               	 WHERE  A.UploadId = v_UniqueUploadID
                          AND A.ACTION = 'N' );
               IF utils.object_id('TempDB..tt_Temp_9') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_9 ';
               END IF;
               DELETE FROM tt_Temp_9;
               UTILS.IDENTITY_RESET('tt_Temp_9');

               INSERT INTO tt_Temp_9 ( 
               	SELECT A.AccountentityID ,
                       A.SplFlag 
               	  FROM RBL_MISDB_PROD.AdvAcOtherDetail A
                         JOIN tt_Flags1_3 B   ON A.RefSystemAcId = B.ACID

               	--where A.EffectiveToTimeKey=49999 
               	WHERE  A.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                         AND A.EFFECTIVETOTIMEKEY >= v_TimeKey );
               --Select * from tt_Temp_9
               IF utils.object_id('TEMPDB..tt_SplitValue_3') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_SplitValue_3 ';
               END IF;
               DELETE FROM tt_SplitValue_3;
               UTILS.IDENTITY_RESET('tt_SplitValue_3');

               INSERT INTO tt_SplitValue_3 ( 
               	SELECT AccountentityID ,
                       a_SPLIT.VALUE('.', 'VARCHAR(8000)') Businesscolvalues1  
               	  FROM ( SELECT UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(SplFlag, ',', '</M><M>') || '</M>') Businesscolvalues1  ,
                                AccountentityID 
                         FROM tt_Temp_9  ) A
                          /*TODO:SQLDEV*/ CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a) /*END:SQLDEV*/  );
               --Select * from tt_SplitValue_3 
               DELETE tt_SplitValue_3

                WHERE  Businesscolvalues1 IN ( SELECT DISTINCT SplCatShortNameEnum 
                                               FROM tt_Flags1_3  )
               ;
               IF utils.object_id('TEMPDB..tt_NEWTRANCHE_19') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_19 ';
               END IF;
               DELETE FROM tt_NEWTRANCHE_19;
               UTILS.IDENTITY_RESET('tt_NEWTRANCHE_19');

               INSERT INTO tt_NEWTRANCHE_19 SELECT * 
                    FROM ( SELECT ss.AccountEntityID ,
                                  utils.stuff(( SELECT ',' || US.BUSINESSCOLVALUES1 
                                                FROM tt_SplitValue_3 US
                                                 WHERE  US.AccountentityID = ss.AccountEntityID ), 1, 1, ' ') REPORTIDSLIST  
                           FROM tt_Temp_9 SS
                             GROUP BY ss.AccountEntityID ) B
                    ORDER BY 1;
               --Select * from tt_NEWTRANCHE_19
               --SELECT * 
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
               FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                      JOIN tt_NEWTRANCHE_19 B   ON A.AccountentityID = B.AccountentityID 
                WHERE A.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                 AND A.EFFECTIVETOTIMEKEY >= v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.SplFlag = src.REPORTIDSLIST;
               --------------------------------------------------
               ----			INSERT INTO IBPCPoolSummary(
               ----					SummaryID
               ----					,PoolID
               ----					,PoolName
               ----					,PoolType
               ----					,BalanceOutstanding
               ----					,IBPCExposureAmt
               ----					,IBPCReckoningDate
               ----					,IBPCMarkingDate
               ----					,MaturityDate
               ----					,NoOfAccount
               ----						,EffectiveFromTimeKey
               ----						,EffectiveToTimeKey
               ----						,CreatedBy
               ----						,DateCreated
               ----						,ModifyBy
               ----						,DateModified
               ----						,ApprovedBy
               ----						,DateApproved
               ----						,TotalPosBalance
               ----						,TotalInttReceivable
               ----						)
               ----			SELECT SummaryID
               ----					,PoolID
               ----					,PoolName
               ----					,PoolType
               ----					,BalanceOutstanding
               ----					,IBPCExposureAmt
               ----					,IBPCReckoningDate
               ----					,IBPCMarkingDate
               ----					,MaturityDate
               ----					,NoOfAccount
               ----					,@Timekey,49999
               ----					,CreatedBy
               ----					,DateCreated
               ----					,ModifyBy
               ----					,DateModified
               ----					,@UserLoginID
               ----					,Getdate()
               ----					,TotalPosBalance
               ----					,TotalInttReceivable
               ----			FROM IBPCPoolSummary_Mod A
               ----			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
               ----			-----------------Insert into Final Tables ----------
               ----			Insert into IBPCFinalPoolDetail
               ----			(
               ----			SummaryID
               ----			,PoolID
               ----			,PoolName
               ----			,CustomerID
               ----			,AccountID
               ----			,POS
               ----			,InterestReceivable
               ----			,EffectiveFromTimeKey
               ----			,EffectiveToTimeKey
               ----			,CreatedBy
               ----			,DateCreated
               ----			,ModifyBy
               ----			,DateModified
               ----			,ApprovedBy
               ----			,DateApproved
               ----			,ExposureAmount
               ----			)
               ----			SELECT SummaryID
               ----					,PoolID
               ----					,PoolName
               ----					,CustomerID
               ----					,AccountID
               ----					,POS
               ----					,InterestReceivable
               ----					,@Timekey,49999
               ----					,CreatedBy
               ----					,DateCreated
               ----					,ModifyBy
               ----					,DateModified
               ----					,@UserLoginID
               ----					,Getdate()
               ----					,IBPCExposureAmt
               ----			FROM IBPCPoolDetail_MOD A
               ----			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
               ----			---Summary Final -----------
               ----			Insert into IBPCFinalPoolSummary
               ----			(
               ----			SummaryID
               ----			,PoolID
               ----			,PoolName
               ----			,PoolType
               ----			,BalanceOutstanding
               ----			,IBPCExposureAmt
               ----			,IBPCReckoningDate
               ----			,IBPCMarkingDate
               ----			,MaturityDate
               ----			,NoOfAccount
               ----			,EffectiveFromTimeKey
               ----			,EffectiveToTimeKey
               ----			,CreatedBy
               ----			,DateCreated
               ----			,ModifyBy
               ----			,DateModified
               ----			,ApprovedBy
               ----			,DateApproved
               ----			,TotalPosBalance
               ----			,TotalInttReceivable
               ----			)
               ----			SELECT SummaryID
               ----					,PoolID
               ----					,PoolName
               ----					,PoolType
               ----					,BalanceOutstanding
               ----					,IBPCExposureAmt
               ----					,IBPCReckoningDate
               ----					,IBPCMarkingDate
               ----					,MaturityDate
               ----					,NoOfAccount
               ----					,@Timekey,49999
               ----					,CreatedBy
               ----					,DateCreated
               ----					,ModifyBy
               ----					,DateModified
               ----					,@UserLoginID
               ----					,Getdate()
               ----					,TotalPosBalance
               ----					,TotalInttReceivable
               ----			FROM IBPCPoolSummary_Mod A
               ----			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
               -------------------------------------------------
               ---------------------------Added on 20032021----------------------
               MERGE INTO B 
               USING (SELECT B.ROWID row_id, v_EffectiveFromTimeKey - 1 AS pos_2, CASE 
               WHEN v_AUTHMODE = 'Y' THEN 'A'
               ELSE NULL
                  END AS pos_3
               FROM B ,AccountFlaggingDetails B 
                WHERE B.AuthorisationStatus = 'A'
                 AND B.Action = 'N'
                 AND ( B.EffectiveFromTimeKey <= v_Timekey
                 AND B.EffectiveToTimeKey >= v_Timekey )) src
               ON ( B.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = pos_2,
                                            AuthorisationStatus = pos_3;
               --AND B.UploadId=@UniqueUploadID
               ------------------------------------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_UserLoginID, SYSDATE
               FROM A ,AccountFlaggingDetails A
                      JOIN AccountFlaggingDetails_Mod B   ON ( A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey )
                      AND ( B.EffectiveFromTimeKey <= v_Timekey
                      AND B.EffectiveToTimeKey >= v_Timekey )
                      AND A.ACID = B.ACID 
                WHERE B.AuthorisationStatus = 'A'
                 AND B.UploadID = v_UniqueUploadID) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET
               --A.POS=ROUND(B.POS,2),
                a.ModifyBy = v_UserLoginID,
                a.DateModified = SYSDATE;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Account Flagging Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN

             ----REJECT
            BEGIN
               UPDATE AccountFlaggingDetails_Mod
                  SET
                  --AuthorisationStatus	='R'
                   --,ApprovedBy	=@UserLoginID
                   --,DateApproved	=GETDATE()
                AuthorisationStatus = 'R',
                ApprovedByFirstLevel = v_UserLoginID,
                DateApprovedFirstLevel = SYSDATE,
                EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus = 'NP';
               ----UPDATE 
               ----IBPCPoolSummary_MOD 
               ----SET 
               ----AuthorisationStatus	='R'
               ----,ApprovedBy	=@UserLoginID
               ----,DateApproved	=GETDATE()
               ----WHERE UploadId=@UniqueUploadID
               ----AND AuthorisationStatus='NP'
               ----SELECT * FROM IBPCPoolDetail
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Account Flagging Upload';

            END;
            END IF;
            -------------------------Two level Auth. Changes.-------------
            IF ( v_OperationFlag = 21 ) THEN

             ----REJECT
            BEGIN
               UPDATE AccountFlaggingDetails_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE,
                      EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus IN ( 'NP','1A' )
               ;
               ----UPDATE 
               ----IBPCPoolSummary_MOD 
               ----SET 
               ----AuthorisationStatus	='R'
               ----,ApprovedBy	=@UserLoginID
               ----,DateApproved	=GETDATE()
               ----WHERE UploadId=@UniqueUploadID
               ----AND AuthorisationStatus='NP'
               ----SELECT * FROM IBPCPoolDetail
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Account Flagging Upload';

            END;
            END IF;

         END;
         END IF;
         --------------------------------------------------------------
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
                            AND v_MenuId = 1470 THEN v_ExcelUploadId
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTFLAGGINGSTAGEDATAINUP_04122023" TO "ADF_CDR_RBL_STGDB";
