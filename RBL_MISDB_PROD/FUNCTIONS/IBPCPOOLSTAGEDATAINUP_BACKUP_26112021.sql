--------------------------------------------------------
--  DDL for Function IBPCPOOLSTAGEDATAINUP_BACKUP_26112021
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
  v_Authlevel IN VARCHAR2
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   v_FilePathUpload VARCHAR2(100);
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
         IF ( v_MenuId = 1458 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM IBPCPoolDetail_stg 
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
               DBMS_OUTPUT.PUT_LINE('Sachin');
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM IBPCPoolDetail_stg 
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
                             'IBPC Pool Upload' ,
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
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'IBPC Pool Upload' );
                  INSERT INTO IBPCPoolDetail_MOD
                    ( SrNo, UploadID, SummaryID, PoolID, PoolName, CustomerID, AccountID, POS, InterestReceivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, IBPCExposureAmt, OSBalance, IBPCExposureinRs, DateofIBPCreckoning, DateofIBPCmarking, MaturityDate )
                    ( SELECT SrNo ,
                             v_ExcelUploadId ,
                             SummaryID ,
                             PoolID ,
                             PoolName ,
                             CustomerID ,
                             AccountID ,
                             PrincipalOutstandinginRs ,
                             InterestReceivableinRs ,
                             'NP' ,
                             v_Timekey ,
                             49999 ,
                             v_UserLoginID ,
                             SYSDATE ,
                             IBPCExposureinRs ,
                             OSBalanceinRs ,
                             IBPCExposureinRs ,
                             DateofIBPCreckoning ,
                             DateofIBPCmarking ,
                             MaturityDate 
                      FROM IBPCPoolDetail_stg 
                       WHERE  FilName = v_FilePathUpload );
                  SELECT NVL(( SELECT MAX(SummaryId)  
                               FROM IBPCPoolSummary_Mod  ), 0)

                    INTO v_SummaryId
                    FROM DUAL ;
                  INSERT INTO IBPCPoolSummary_stg
                    ( UploadID, SummaryID, PoolID, PoolName, PoolType, BalanceOutstanding, NoOfAccount, IBPCExposureAmt, IBPCReckoningDate, IBPCMarkingDate, MaturityDate, TotalPosBalance, TotalInttReceivable )
                    SELECT v_ExcelUploadId ,
                           v_SummaryId + ROW_NUMBER() OVER ( ORDER BY PoolID  ) ,
                           PoolID ,
                           PoolName ,
                           PoolType ,
                           SUM(NVL(UTILS.CONVERT_TO_NUMBER(PrincipalOutstandinginRs,16,2), 0) + NVL(UTILS.CONVERT_TO_NUMBER(InterestReceivableinRs,16,2), 0))  ,
                           COUNT(PoolID)  ,
                           SUM(NVL(UTILS.CONVERT_TO_NUMBER(IBPCExposureinRs,16,2), 0))  ,
                           DateofIBPCreckoning ,
                           DateofIBPCmarking ,
                           MaturityDate ,
                           SUM(NVL(UTILS.CONVERT_TO_NUMBER(PrincipalOutstandinginRs,16,2), 0))  ,
                           SUM(NVL(UTILS.CONVERT_TO_NUMBER(InterestReceivableinRs,16,2), 0))  
                      FROM IBPCPoolDetail_stg 
                     WHERE  FilName = v_FilePathUpload
                      GROUP BY PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate;
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
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
                  DELETE IBPCPoolDetail_stg

                   WHERE  filname = v_FilePathUpload;

               END;
               END IF;

            END;
            END IF;
            ----RETURN @ExcelUploadId
            ----DECLARE @UniqueUploadID INT
            --SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
            ----------------------01042021-------------
            IF ( v_OperationFlag = 16 ) THEN

             ----AUTHORIZE
            BEGIN
               UPDATE IBPCPoolDetail_MOD
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE IBPCPoolSummary_Mod
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID
                WHERE  UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'IBPC Pool Upload';

            END;
            END IF;
            --------------------------------------------
            IF ( v_OperationFlag = 20 ) THEN

             ----AUTHORIZE
            BEGIN
               UPDATE IBPCPoolDetail_MOD
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE IBPCPoolSummary_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               -----maintain history
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, A.EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
               FROM A ,IBPCPoolDetail A
                      JOIN IBPCPoolDetail_MOD B   ON A.AccountID = B.AccountID
                      AND B.EffectiveFromTimeKey <= v_Timekey
                      AND B.EffectiveToTimeKey >= v_Timekey 
                WHERE B.UploadID = v_UniqueUploadID
                 AND A.EffectiveToTimeKey >= 49999) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               INSERT INTO IBPCPoolDetail
                 ( SummaryID, PoolID, PoolName, CustomerID, AccountID, POS, InterestReceivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, IBPCExposureAmt, OSBalance )
                 ( 
                   --,IBPCExposureinRs

                   --,DateofIBPCreckoning

                   --,DateofIBPCmarking

                   --,MaturityDate
                   SELECT SummaryID ,
                          PoolID ,
                          PoolName ,
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
                          IBPCExposureAmt ,
                          OSBalance 

                   --,IBPCExposureinRs

                   --,DateofIBPCreckoning

                   --,DateofIBPCmarking

                   --,MaturityDate
                   FROM IBPCPoolDetail_MOD A
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND EffectiveToTimeKey >= v_Timekey );
               INSERT INTO IBPCPoolSummary
                 ( SummaryID, PoolID, PoolName, PoolType, BalanceOutstanding, IBPCExposureAmt, IBPCReckoningDate, IBPCMarkingDate, MaturityDate, NoOfAccount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, TotalPosBalance, TotalInttReceivable )
                 ( SELECT SummaryID ,
                          PoolID ,
                          PoolName ,
                          PoolType ,
                          BalanceOutstanding ,
                          IBPCExposureAmt ,
                          IBPCReckoningDate ,
                          IBPCMarkingDate ,
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
                   FROM IBPCPoolSummary_Mod A
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND EffectiveToTimeKey >= v_Timekey );
               -----------------Insert into Final Tables ----------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, A.EffectiveFromTimeKey - 1 AS EffectiveToTimeKey
               FROM A ,IBPCFinalPoolDetail A
                      JOIN IBPCPoolDetail_MOD B   ON A.AccountID = B.AccountID
                      AND B.EffectiveFromTimeKey <= v_Timekey
                      AND B.EffectiveToTimeKey >= v_Timekey 
                WHERE B.UploadID = v_UniqueUploadID
                 AND A.EffectiveToTimeKey >= 49999) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               INSERT INTO IBPCFinalPoolDetail
                 ( SummaryID, PoolID, PoolName, CustomerID, AccountID, POS, InterestReceivable, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, ExposureAmount, IBPCInDate, AccountBalance --- new add
                )
                 ( SELECT SummaryID ,
                          PoolID ,
                          PoolName ,
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
                          IBPCExposureAmt ,
                          SYSDATE ,
                          -- new add 
                          OSBalance 
                   FROM IBPCPoolDetail_MOD A
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND EffectiveToTimeKey >= v_Timekey );
               ---Summary Final -----------
               INSERT INTO IBPCFinalPoolSummary
                 ( SummaryID, PoolID, PoolName, PoolType, BalanceOutstanding, IBPCExposureAmt, IBPCReckoningDate, IBPCMarkingDate, MaturityDate, NoOfAccount, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, TotalPosBalance, TotalInttReceivable )
                 ( SELECT SummaryID ,
                          PoolID ,
                          PoolName ,
                          PoolType ,
                          BalanceOutstanding ,
                          IBPCExposureAmt ,
                          IBPCReckoningDate ,
                          IBPCMarkingDate ,
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
                   FROM IBPCPoolSummary_Mod A
                    WHERE  A.UploadID = v_UniqueUploadID
                             AND EffectiveToTimeKey >= v_Timekey );
               /*--------------------Adding Flag To AdvAcOtherDetail------------Sunil 21-03-2021--------*/
               IF utils.object_id('TempDB..tt_IBPCNew_5') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_IBPCNew_5 ';
               END IF;
               DELETE FROM tt_IBPCNew_5;
               UTILS.IDENTITY_RESET('tt_IBPCNew_5');

               INSERT INTO tt_IBPCNew_5 ( 
               	SELECT A.RefSystemAcId ,
                       A.SplFlag 
               	  FROM RBL_MISDB_PROD.AdvAcOtherDetail A
                         JOIN IBPCPoolDetail_MOD B   ON A.RefSystemAcId = B.AccountID
               	 WHERE  B.UploadID = v_UniqueUploadID
                          AND B.EffectiveToTimeKey >= v_Timekey
                          AND A.EffectiveToTimeKey = 49999
                          AND A.SplFlag LIKE '%IBPC%' );
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN NVL(A.SplFlag, ' ') = ' ' THEN 'IBPC'
               ELSE A.SplFlag || ',' || 'IBPC'
                  END AS SplFlag
               FROM A ,RBL_MISDB_PROD.AdvAcOtherDetail A
                    --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId

                      JOIN IBPCPoolDetail_MOD B   ON A.RefSystemAcId = B.AccountID 
                WHERE B.UploadID = v_UniqueUploadID
                 AND B.EffectiveToTimeKey >= v_Timekey
                 AND A.EffectiveToTimeKey = 49999
                 AND NOT EXISTS ( SELECT 1 
                                  FROM tt_IBPCNew_5 N
                                   WHERE  N.RefSystemAcId = A.RefSystemAcId )) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.SplFlag = src.SplFlag;
               --------------------------
               --1
               --select *from ExceptionFinalStatusType
               --select * from AdvAcOtherDetail
               --select * from IBPCFinalPoolDetail 
               --alter table IBPCFinalPoolDetail
               --add IBPCOutDate date,IBPCInDate Date
               --update 
               -------------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, utils.round_(B.POS, 2) AS pos_2, v_UserLoginID, SYSDATE
               FROM A ,IBPCPoolDetail A
                      JOIN IBPCPoolDetail_MOD B   ON ( A.EffectiveFromTimeKey <= v_Timekey
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
                 AND UploadType = 'IBPC Pool Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN

             ----REJECT
            BEGIN
               UPDATE IBPCPoolDetail_MOD
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus = 'NP';
               UPDATE IBPCPoolSummary_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus = 'NP';
               ----SELECT * FROM IBPCPoolDetail
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'IBPC Pool Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 21 ) THEN

             ----REJECT
            BEGIN
               UPDATE IBPCPoolDetail_MOD
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus IN ( 'NP','1A' )
               ;
               UPDATE IBPCPoolSummary_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus IN ( 'NP','1A' )
               ;
               ----SELECT * FROM IBPCPoolDetail
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'IBPC Pool Upload';

            END;
            END IF;

         END;
         END IF;
         --COMMIT TRAN
         ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
         v_Result := CASE 
                          WHEN v_OperationFlag = 1
                            AND v_MenuId = 1458 THEN v_ExcelUploadId
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCPOOLSTAGEDATAINUP_BACKUP_26112021" TO "ADF_CDR_RBL_STGDB";
