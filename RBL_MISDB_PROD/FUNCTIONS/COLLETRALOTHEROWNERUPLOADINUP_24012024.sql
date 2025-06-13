--------------------------------------------------------
--  DDL for Function COLLETRALOTHEROWNERUPLOADINUP_24012024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" 
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
--@Authlevel varchar(5)
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
            IF ( v_MenuId = 24703 ) THEN

            BEGIN
               IF ( v_OperationFlag = 1 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE NOT ( EXISTS ( SELECT 1 
                                           FROM CollateralOthOwnerDetails_stg 
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
                                     FROM CollateralOthOwnerDetails_stg 
                                      WHERE  filname = v_FilePathUpload );
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
                                'Colletral OthOwner Upload' ,
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
                       VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Colletral OthOwner Upload' );
                     INSERT INTO CollateralOthOwnerDetails_MOD
                       ( SrNo, UploadID, SystemCollateralID, CustomeroftheBank, CustomerID, OtherOwnerName, OtherOwnerRelationship, Ifrelativeentervalue, AddressType, AddressCategory, AddressLine1, AddressLine2, AddressLine3, City, PinCode, Country, District, StdCodeO, PhoneNoO, StdCodeR, PhoneNoR, MobileNo, CreatedBy, DateCreated, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey )
                       ( SELECT SrNo ,
                                v_ExcelUploadId ,
                                SystemCollateralID ,
                                CustomeroftheBank ,
                                CustomerID ,
                                OtherOwnerName ,
                                OtherOwnerRelationship ,
                                Ifrelativeentervalue ,
                                AddressType ,
                                AddressCategory ,
                                AddressLine1 ,
                                AddressLine2 ,
                                AddressLine3 ,
                                City ,
                                PinCode ,
                                Country ,
                                District ,
                                StdCodeO ,
                                PhoneNoO ,
                                StdCodeR ,
                                PhoneNoR ,
                                MobileNo ,
                                v_UserLoginID ,
                                SYSDATE ,
                                'NP' ,
                                v_Timekey ,
                                49999 
                         FROM CollateralOthOwnerDetails_stg 
                          WHERE  filname = v_FilePathUpload );
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     --Declare @SummaryId int
                     --Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)
                     --INSERT INTO IBPCPoolSummary_stg
                     --(
                     --	UploadID
                     --	,SummaryID
                     --	,PoolID
                     --	,PoolName
                     --	,PoolType
                     --	,BalanceOutstanding
                     --	,NoOfAccount
                     --	,IBPCExposureAmt
                     --	,IBPCReckoningDate
                     --	,IBPCMarkingDate
                     --	,MaturityDate
                     --	,TotalPosBalance
                     --	,TotalInttReceivable
                     --)
                     --SELECT
                     --	@ExcelUploadId
                     --	,@SummaryId+Row_Number() over(Order by PoolID)
                     --	,PoolID
                     --	,PoolName
                     --	,PoolType
                     --	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
                     --	,Count(PoolID)
                     --	,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
                     --	,DateofIBPCreckoning
                     --	,DateofIBPCmarking
                     --	,MaturityDate
                     --	,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
                     --	,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
                     --FROM IBPCPoolDetail_stg
                     --where FilName=@FilePathUpload
                     --Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate
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
                     DELETE CollateralOthOwnerDetails_stg

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
                  UPDATE CollateralOthOwnerDetails_MOD
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadID = v_UniqueUploadID;
                  UPDATE CollateralOthOwnerDetails_MOD
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Colletral OthOwner Upload';

               END;
               END IF;
               --------------------------------------------
               IF ( v_OperationFlag = 20 ) THEN

                ----AUTHORIZE
               BEGIN
                  UPDATE CollateralOthOwnerDetails_MOD
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE CollateralOthOwnerDetails_MOD
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  INSERT INTO CollateralOtherOwner
                    ( CollateralID, CustomeroftheBankAlt_Key, CustomerID, OtherOwnerName, OtherOwnerRelationshipAlt_Key, IfRelationselectAlt_Key, AddressType, AddressLine1, AddressLine2, AddressLine3, City, PinCode, Country, District, STDCodeO, PhoneNumberO, STDCodeR, PhoneNumberR, MobileNO, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
                    ( SELECT SystemCollateralID CollateralID  ,
                             CASE 
                                  WHEN CustomeroftheBank = 'Y' THEN 1
                             ELSE 0
                                END CustomeroftheBankAlt_Key  ,
                             A.CustomerID ,
                             A.OtherOwnerName ,
                             B.CollateralOwnerTypeAltKey ,
                             1 IfRelationselectAlt_Key  ,
                             A.AddressType ,
                             AddressLine1 ,
                             AddressLine2 ,
                             AddressLine3 ,
                             City ,
                             PinCode ,
                             Country ,
                             District ,
                             StdCodeO ,
                             PhoneNoO ,
                             StdCodeR ,
                             PhoneNoR ,
                             MobileNo ,
                             A.AuthorisationStatus ,
                             v_Timekey ,
                             49999 ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM CollateralOthOwnerDetails_MOD A
                             LEFT JOIN DimCollateralOwnerType B   ON A.OtherOwnerRelationship = B.CollOwnerDescription
                       WHERE  A.UploadID = v_UniqueUploadID
                                AND A.EffectiveToTimeKey >= v_Timekey );
                  --INSERT INTO CollateralValueDetails(
                  --		 CollateralValueatSanctioninRs,
                  --		 CollateralValueasonNPAdateinRs,
                  --		 CollateralValueatthetimeoflastreviewinRs,
                  --		 ValuationDate,
                  --		 LatestCollateralValueinRs,
                  --		 ExpiryBusinessRule
                  --		 ,AuthorisationStatus
                  --		,EffectiveFromTimeKey
                  --		,EffectiveToTimeKey
                  --		,CreatedBy
                  --		,DateCreated
                  --		,ModifiedBy
                  --		,DateModified
                  --		,ApprovedBy
                  --		,DateApproved
                  --			)
                  --SELECT 
                  --		CollateralValueSanctionRs,
                  --		CollateralValueNPADateRs,
                  --		CollateralValueLastReviewRs,
                  --		ValuationDate	,
                  --              CurrentCollateralValueRs,
                  --		ExpiryBusinessRule
                  --		,AuthorisationStatus
                  --		,@Timekey,49999
                  --		,CreatedBy
                  --		,DateCreated
                  --		,ModifiedBy
                  --		,DateModified
                  --		,@UserLoginID
                  --		,Getdate()
                  --                FROM CollateralOthOwnerDetails_MOD A
                  --WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
                  -----------------Insert into Final Tables ----------
                  -----Summary Final -----------
                  /*--------------------Adding Flag To AdvAcOtherDetail------------Sunil 21-03-2021--------*/
                  -- UPDATE A
                  --SET  
                  --       A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
                  --					ELSE A.SplFlag+','+'IBPC'     END
                  -- FROM DBO.AdvAcOtherDetail A
                  --  --INNER JOIN #Temp V  ON A.AccountEntityId=V.AccountEntityId
                  -- INNER JOIN CollateralOthOwnerDetails_MOD B ON A.OldCollateralID=B.OldCollateralID
                  --		WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey
                  --		AND A.EffectiveToTimeKey=49999
                  --------------------------
                  --1
                  --select *from ExceptionFinalStatusType
                  --select * from AdvAcOtherDetail
                  --select * from IBPCFinalPoolDetail 
                  --alter table IBPCFinalPoolDetail
                  --add IBPCOutDate date,IBPCInDate Date
                  --update 
                  -------------------------------------------
                  --		UPDATE A
                  --		SET 
                  ----A.POS=ROUND(B.POS,2),
                  --		a.ModifiedBy=@UserLoginID
                  --		,a.DateModified=GETDATE()
                  --		FROM CollateralMgmt A
                  --		INNER JOIN CollateralOthOwnerDetails_MOD
                  -- B ON (A.EffectiveFromTimeKey<=@Timekey AND A.EffectiveToTimeKey>=@Timekey)
                  --															AND  (B.EffectiveFromTimeKey<=@Timekey AND B.EffectiveToTimeKey>=@Timekey)	
                  --															AND A.OldCollateralID=B.OldCollateralID
                  --WHERE B.AuthorisationStatus='A'
                  --AND B.UploadId=@UniqueUploadID
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Colletral OthOwner Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 17 ) THEN

                ----REJECT
               BEGIN
                  UPDATE CollateralOthOwnerDetails_MOD
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE CollateralOthOwnerDetails_MOD
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
                    AND UploadType = 'Colletral OthOwner Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 21 ) THEN

                ----REJECT
               BEGIN
                  UPDATE CollateralOthOwnerDetails_MOD
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus IN ( 'NP','1A' )
                  ;
                  UPDATE CollateralOthOwnerDetails_MOD
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
                    AND UploadType = 'Colletral OthOwner Upload';

               END;
               END IF;

            END;
            END IF;
            --COMMIT TRAN
            ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
            v_Result := CASE 
                             WHEN v_OperationFlag = 1
                               AND v_MenuId = 24703 THEN v_ExcelUploadId
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLETRALOTHEROWNERUPLOADINUP_24012024" TO "ADF_CDR_RBL_STGDB";
