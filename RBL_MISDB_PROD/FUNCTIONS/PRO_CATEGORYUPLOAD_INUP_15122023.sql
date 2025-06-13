--------------------------------------------------------
--  DDL for Function PRO_CATEGORYUPLOAD_INUP_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" 
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
  v_UniqueUploadID IN NUMBER
)
RETURN NUMBER
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   ----declare @UserLoginID VARCHAR(100)=N'fnachecker',@filepath VARCHAR(MAX)=N'ProvisionCategoryUpload (1).xlsx'
   v_FilePathUpload VARCHAR2(100);
   ------RETURN @UniqueUploadID
   --ROLLBACK TRAN
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=25999,
--	@UserLoginID VARCHAR(100)=N'fnachecker',
--	@OperationFlag INT=N'1',
--	@MenuId INT=N'1468',
--	@AuthMode	CHAR(1)=N'N',
--	@filepath VARCHAR(MAX)=N'ProvisionCategoryUpload (1).xlsx',
--	@EffectiveFromTimeKey INT=25999,
--	@EffectiveToTimeKey	INT=49999,
--    @Result		INT=0 ,
--	@UniqueUploadID INT=NULL

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
         --fnachecker_ProvisionCategoryUpload (1).xlsx
         --BEGIN TRAN
         IF ( v_MenuId = 1468 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               --select * from categorydetails_stg filname
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM CategoryDetails_stg 
                                         WHERE  filname = v_FilePathUpload ) );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  --Rollback tran
                  v_Result := -8 ;
                  DBMS_OUTPUT.PUT_LINE('an');
                  DBMS_OUTPUT.PUT_LINE('123');
                  RETURN v_Result;

               END;
               END IF;
               --select * from ExcelUploadHistory
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM CategoryDetails_stg 
                                   WHERE  filname = v_FilePathUpload );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN
                DECLARE
                  v_ExcelUploadId NUMBER(10,0);

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('321');
                  INSERT INTO ExcelUploadHistory
                    ( UploadedBy, DateofUpload, AuthorisationStatus
                  --,Action	
                  , UploadType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT v_UserLoginID ,
                             SYSDATE ,
                             'NP' ,
                             --,'NP'
                             'Provision Category Upload' ,
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
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Provision Category Upload' );
                  DBMS_OUTPUT.PUT_LINE('A');
                  INSERT INTO AcCatUploadHistory_Mod
                    ( SlNo, UPLOADID, ACID, CustomerID, CategoryID, ACTION, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT SlNo ,
                             v_ExcelUploadId ,
                             ACID ,
                             CustomerID ,
                             CategoryID ,
                             ACTION ,
                             'NP' ,
                             v_Timekey ,
                             49999 ,
                             v_UserLoginID ,
                             SYSDATE 
                      FROM CategoryDetails_stg 
                       WHERE  FilName = v_FilePathUpload );
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                  /*
                  --------------------------------------------------Max percent
                  IF OBJECT_ID('TEMPDB..#EXISTDATA')IS NOT NULL
                  				DROP TABLE #EXISTDATA
                  				Declare @ProvisionPercent decimal(10,0)
                  								SELECT A.ACID
                  								, @ProvisionPercent=MAX(D.Provisionsecured)ProvisionPercent						
                  								--,d.provisionname
                  								 INTO #EXISTDATA	 
                  								 FROM categorydetails_stg A
                  								--INNER JOIN AdvAcBasicDetail B
                  								--			on B.CustomerAcId=A.acid
                  									INNER JOIN DimProvision_SegStd D
                  											ON A.CategoryID=D.BankCategoryID   
                  											group by A.ACID 

                  											--update STD_ProvDetail


                  	--				Select A.ACID,@ProvisionPercent=(case when A.ProvisionPercent>E.ProvisionPercent  then 1 else 0 end )from(																	
                  	--SELECT A.ACID, MAX(D.Provisionsecured)ProvisionPercent	 FROM AcCatUploadHistory A --
                  	--inner join  DimProvision_SegStd D on A.CategoryID=D.BankCategoryID  group by A.ACID
                  	--)A inner join  #EXISTDATA E on A.ACID=E.ACID

                  	--IF (@ProvisionPercent =1)
                  	--Begin
                  	*/
                  --End
                  --------------------------------------------------------------------------------------
                  --select * from categorydetails_stg
                  --select * from AcCatUploadHistory
                  --select * from DimProvision_SegStd
                  --select ProvisionAlt_Key,* from STD_ProvDetail
                  /*
                  		Declare @SummaryId int
                  		Set @SummaryId=IsNull((Select Max(SummaryId) from IBPCPoolSummary_Mod),0)

                  		INSERT INTO IBPCPoolSummary_stg
                  		(
                  			UploadID
                  			,SummaryID
                  			,PoolID
                  			,PoolName
                  			,PoolType
                  			,BalanceOutstanding
                  			,NoOfAccount
                  			,IBPCExposureAmt
                  			,IBPCReckoningDate
                  			,IBPCMarkingDate
                  			,MaturityDate
                  			,TotalPosBalance
                  			,TotalInttReceivable
                  		)

                  		SELECT
                  			@ExcelUploadId
                  			,@SummaryId+Row_Number() over(Order by PoolID)
                  			,PoolID
                  			,PoolName
                  			,PoolType
                  			,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
                  			,Count(PoolID)
                  			,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))
                  			,DateofIBPCreckoning
                  			,DateofIBPCmarking
                  			,MaturityDate
                  			,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))
                  			,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))
                  		FROM IBPCPoolDetail_stg
                  		where FilName=@FilePathUpload
                  		Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate

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
                  */
                  ---DELETE FROM STAGING DATA
                  DELETE CategoryDetails_stg

                   WHERE  FilName = v_FilePathUpload;

               END;
               END IF;

            END;
            END IF;
            ----RETURN @ExcelUploadId
            ----DECLARE @UniqueUploadID INT
            --SET 	@UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)
            IF ( v_OperationFlag = 16 ) THEN

             ----AUTHORIZE
            BEGIN
               UPDATE AcCatUploadHistory_Mod
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = '1A'
                WHERE  UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Provision Category Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 20 ) THEN

             ----AUTHORIZE
            BEGIN
               UPDATE AcCatUploadHistory_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               --UPDATE 
               --IBPCPoolSummary_MOD 
               --SET 
               --AuthorisationStatus	='A'
               --,ApprovedBy	=@UserLoginID
               --,DateApproved	=GETDATE()
               --WHERE UploadId=@UniqueUploadID
               --select * from AcCatUploadHistory
               -----maintain history
               --Select * 
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, 'N'
               FROM A ,AcCatUploadHistory A
                      JOIN AcCatUploadHistory_Mod B   ON A.ACID = B.ACID
                      AND B.EffectiveToTimeKey = 49999 
                WHERE A.EffectiveToTimeKey = 49999
                 AND B.UPLOADID = v_UniqueUploadID) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.FinalProv = 'N';
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
               FROM A ,AcCatUploadHistory A
                      JOIN AcCatUploadHistory_Mod B   ON A.ACID = B.ACID
                      AND A.CategoryID = B.CategoryID
                      AND B.EffectiveToTimeKey = 49999 
                WHERE A.EffectiveToTimeKey = 49999
                 AND B.Action = 'R'
                 AND B.UPLOADID = v_UniqueUploadID) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               INSERT INTO AcCatUploadHistory
                 ( SlNo, UPLOADID, ACID, CustomerID, CategoryID, ACTION, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifyBy, DateModified, ApprovedBy, DateApproved, FinalProv )
                 ( SELECT SlNo ,
                          v_UniqueUploadID ,
                          ACID ,
                          CustomerID ,
                          CategoryID ,
                          ACTION ,
                          AuthorisationStatus ,
                          v_Timekey ,
                          49999 ,
                          CreatedBy ,
                          DateCreated ,
                          ModifyBy ,
                          DateModified ,
                          v_UserLoginID ,
                          SYSDATE ,
                          'Y' 
                   FROM AcCatUploadHistory_Mod A
                    WHERE  A.UPLOADID = v_UniqueUploadID
                             AND EffectiveToTimeKey >= v_Timekey );
               -------------------In Main Table -----------------------
               IF utils.object_id('TempDB..tt_STD_3') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_STD_3 ';
               END IF;
               DELETE FROM tt_STD_3;
               UTILS.IDENTITY_RESET('tt_STD_3');

               INSERT INTO tt_STD_3 ( 
               	SELECT S.CustomerAcId Acid  ,
                       CASE 
                            WHEN A.ACID IS NULL THEN 113
                       ELSE B.BankCategoryID
                          END BankCategoryID  ,
                       CASE 
                            WHEN A.ACID IS NULL THEN 13
                       ELSE B.ProvisionAlt_Key
                          END ProvisionAlt_Key  ,
                       CASE 
                            WHEN A.ACID IS NULL THEN .40
                       ELSE B.ProvisionSecured
                          END ProvisionSecured  
               	  FROM STD_ProvDetail S
                         LEFT JOIN AcCatUploadHistory A   ON S.CustomerAcId = A.ACID
                         AND A.EffectiveToTimeKey = 49999
                         AND A.Action = 'A'
                         LEFT JOIN DimProvision_SegStd B   ON A.CategoryID = B.BankCategoryID
                         AND b.EffectiveToTimeKey = 49999
               	 WHERE  S.EffectiveToTimeKey = 49999 );
               IF utils.object_id('TempDB..tt_STD_31') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_STD1_3 ';
               END IF;
               DELETE FROM tt_STD1_3;
               UTILS.IDENTITY_RESET('tt_STD1_3');

               INSERT INTO tt_STD1_3 ( 
               	SELECT A.* 
               	  FROM tt_STD_3 A
                         JOIN ( SELECT ACID ,
                                       MAX(ProvisionSecured)  ProvisionSecured  
                                FROM tt_STD_3 
                                  GROUP BY ACID ) B   ON A.ACID = B.ACID
                         AND A.ProvisionSecured = B.ProvisionSecured );
               --Select * 
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
               FROM A ,STD_ProvDetail A
                      JOIN tt_STD1_3 B   ON A.CustomerAcId = B.ACID 
                WHERE A.EffectiveToTimeKey = 49999) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               INSERT INTO STD_ProvDetail
                 ( DataDate, TerritoryAlt_Key, SourceAlt_Key, GL_Code, GLProductAlt_Key, CustomerID, CustomerEntityID, CustomerName, CustomerAcId, SystemAcId, AccountEntityID, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, SanctionDate, FacilityType, AdvType, IndustryCode, Balance, OrgProvisionAlt_Key, ProvisionAlt_Key, FinalProvCatSetId, TotalAdjAmt, NetAmt, TotalExclAmt, NetAmtForProv, FinalProvPer, GovtGtyAmt, DFVAmt, SecurityValue, ApprRV, SecuredAmt, UnSecuredAmt, CoverGovGur, ProvSecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, UploadCatFlag, ExpireStatus, AcsegDesc, Acseg, OriginalBal, ProcessingStatus, Sch9_ProcessingStatus, MOCSTATUS, SCH9_Freeze_Flag, APPROP_GOV_GTY, SCH9_ADJAMT, SCH9_NETAMT, SECTORSHORTNAME, FITL_Provision, FITL_PROV_SECU, FITL_PROV_UNSECU, FITL_PROV_GOVGUR, DFV_Provision, DFV_PROV_SECU, DFV_PROV_UNSECU, DFV_PROV_GOVGUR, AdjCategoryAlt_Key, SubSectorAlt_Key, OriginalAdjBal )
                 ( SELECT DataDate ,
                          TerritoryAlt_Key ,
                          SourceAlt_Key ,
                          GL_Code ,
                          GLProductAlt_Key ,
                          CustomerID ,
                          CustomerEntityID ,
                          CustomerName ,
                          A.CustomerAcId ,
                          SystemAcId ,
                          AccountEntityID ,
                          InitialAssetClassAlt_Key ,
                          FinalAssetClassAlt_Key ,
                          SanctionDate ,
                          FacilityType ,
                          AdvType ,
                          IndustryCode ,
                          Balance ,
                          OrgProvisionAlt_Key ,
                          B.ProvisionAlt_Key ProvisionAlt_Key  ,
                          FinalProvCatSetId ,
                          TotalAdjAmt ,
                          NetAmt ,
                          TotalExclAmt ,
                          NetAmtForProv ,
                          FinalProvPer ,
                          GovtGtyAmt ,
                          DFVAmt ,
                          SecurityValue ,
                          ApprRV ,
                          SecuredAmt ,
                          UnSecuredAmt ,
                          CoverGovGur ,
                          B.ProvisionSecured ProvSecured  ,
                          ProvUnsecured ,
                          ProvCoverGovGur ,
                          AddlProvision ,
                          TotalProvision ,
                          AuthorisationStatus ,
                          v_Timekey EffectiveFromTimeKey  ,
                          49999 EffectiveToTimeKey  ,
                          CreatedBy ,
                          DateCreated ,
                          ModifiedBy ,
                          DateModified ,
                          ApprovedBy ,
                          DateApproved ,
                          UploadCatFlag ,
                          ExpireStatus ,
                          AcsegDesc ,
                          Acseg ,
                          OriginalBal ,
                          ProcessingStatus ,
                          Sch9_ProcessingStatus ,
                          MOCSTATUS ,
                          SCH9_Freeze_Flag ,
                          APPROP_GOV_GTY ,
                          SCH9_ADJAMT ,
                          SCH9_NETAMT ,
                          SECTORSHORTNAME ,
                          FITL_Provision ,
                          FITL_PROV_SECU ,
                          FITL_PROV_UNSECU ,
                          FITL_PROV_GOVGUR ,
                          DFV_Provision ,
                          DFV_PROV_SECU ,
                          DFV_PROV_UNSECU ,
                          DFV_PROV_GOVGUR ,
                          AdjCategoryAlt_Key ,
                          SubSectorAlt_Key ,
                          OriginalAdjBal 
                   FROM STD_ProvDetail A
                          JOIN tt_STD1_3 B   ON A.CustomerAcId = B.ACID
                          JOIN ( SELECT MAX(Entitykey)  Entitykey  ,
                 CustomerAcid 
                                 FROM std_provdetail 
                                  WHERE  EffectiveToTimeKey = v_Timekey - 1
                                   GROUP BY CustomerAcid ) C   ON A.CustomerAcid = C.CustomerAcid
                          AND A.Entitykey = C.Entitykey );
               --Where A.EffectiveToTimeKey=@Timekey-1
               ----------------------------------------------------------------------------------------------------------
               --select * from DimProvision_SegStd
               --alter table AcCatUploadHistory_MOD
               --add Provision
               /*
               			INSERT INTO IBPCPoolSummary(
               					SummaryID
               					,PoolID
               					,PoolName
               					,PoolType
               					,BalanceOutstanding
               					,IBPCExposureAmt
               					,IBPCReckoningDate
               					,IBPCMarkingDate
               					,MaturityDate
               					,NoOfAccount
               						,EffectiveFromTimeKey
               						,EffectiveToTimeKey
               						,CreatedBy
               						,DateCreated
               						,ModifyBy
               						,DateModified
               						,ApprovedBy
               						,DateApproved
               						,TotalPosBalance
               						,TotalInttReceivable
               						)
               			SELECT SummaryID
               					,PoolID
               					,PoolName
               					,PoolType
               					,BalanceOutstanding
               					,IBPCExposureAmt
               					,IBPCReckoningDate
               					,IBPCMarkingDate
               					,MaturityDate
               					,NoOfAccount
               					,@Timekey,49999
               					,CreatedBy
               					,DateCreated
               					,ModifyBy
               					,DateModified
               					,@UserLoginID
               					,Getdate()
               					,TotalPosBalance
               					,TotalInttReceivable
               			FROM IBPCPoolSummary_Mod A
               			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

               			*/
               -----------------Insert into Final Tables ----------
               /*
               			Insert into IBPCFinalPoolDetail
               			(
               			SummaryID
               			,PoolID
               			,PoolName
               			,CustomerID
               			,AccountID
               			,POS
               			,InterestReceivable
               			,EffectiveFromTimeKey
               			,EffectiveToTimeKey
               			,CreatedBy
               			,DateCreated
               			,ModifyBy
               			,DateModified
               			,ApprovedBy
               			,DateApproved
               			,ExposureAmount
               			)
               			SELECT SummaryID
               					,PoolID
               					,PoolName
               					,CustomerID
               					,AccountID
               					,POS
               					,InterestReceivable
               					,@Timekey,49999
               					,CreatedBy
               					,DateCreated
               					,ModifyBy
               					,DateModified
               					,@UserLoginID
               					,Getdate()
               					,IBPCExposureAmt
               			FROM IBPCPoolDetail_MOD A
               			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey

               			---Summary Final -----------

               			Insert into IBPCFinalPoolSummary
               			(
               			SummaryID
               			,PoolID
               			,PoolName
               			,PoolType
               			,BalanceOutstanding
               			,IBPCExposureAmt
               			,IBPCReckoningDate
               			,IBPCMarkingDate
               			,MaturityDate
               			,NoOfAccount
               			,EffectiveFromTimeKey
               			,EffectiveToTimeKey
               			,CreatedBy
               			,DateCreated
               			,ModifyBy
               			,DateModified
               			,ApprovedBy
               			,DateApproved
               			,TotalPosBalance
               			,TotalInttReceivable
               			)
               			SELECT SummaryID
               					,PoolID
               					,PoolName
               					,PoolType
               					,BalanceOutstanding
               					,IBPCExposureAmt
               					,IBPCReckoningDate
               					,IBPCMarkingDate
               					,MaturityDate
               					,NoOfAccount
               					,@Timekey,49999
               					,CreatedBy
               					,DateCreated
               					,ModifyBy
               					,DateModified
               					,@UserLoginID
               					,Getdate()
               					,TotalPosBalance
               					,TotalInttReceivable
               			FROM IBPCPoolSummary_Mod A
               			WHERE  A.UploadId=@UniqueUploadID and EffectiveToTimeKey>=@Timekey
               select * from STD_ProvDetail
               ---------------------------------------------
               */
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_UserLoginID, SYSDATE
               FROM A ,AcCatUploadHistory A
                      JOIN AcCatUploadHistory_Mod B   ON ( A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey )
                      AND ( B.EffectiveFromTimeKey <= v_Timekey
                      AND B.EffectiveToTimeKey >= v_Timekey )
                      AND A.ACID = B.ACID 
                WHERE B.AuthorisationStatus = 'A'
                 AND B.UPLOADID = v_UniqueUploadID) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET
               --A.POS=ROUND(B.POS,2)
                a.ModifyBy = v_UserLoginID,
                a.DateModified = SYSDATE;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Provision Category Upload';

            END;
            END IF;
            -------------------------------------------------------------------
            IF ( v_OperationFlag = 21 ) THEN

             ----REJECT
            BEGIN
               UPDATE AcCatUploadHistory_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus IN ( 'NP','1A' )
               ;
               --UPDATE 
               --IBPCPoolSummary_MOD 
               --SET 
               --AuthorisationStatus	='R'
               --,ApprovedBy	=@UserLoginID
               --,DateApproved	=GETDATE()
               --WHERE UploadId=@UniqueUploadID
               --AND AuthorisationStatus='NP'
               ------SELECT * FROM IBPCPoolDetail
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Provision Category Upload';

            END;
            END IF;
            --------------------------------------------------------------------
            IF ( v_OperationFlag = 17 ) THEN

             ----REJECT
            BEGIN
               UPDATE AcCatUploadHistory_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID
                 AND AuthorisationStatus = 'NP';
               --UPDATE 
               --IBPCPoolSummary_MOD 
               --SET 
               --AuthorisationStatus	='R'
               --,ApprovedBy	=@UserLoginID
               --,DateApproved	=GETDATE()
               --WHERE UploadId=@UniqueUploadID
               --AND AuthorisationStatus='NP'
               ------SELECT * FROM IBPCPoolDetail
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Provision Category Upload';

            END;
            END IF;

         END;
         END IF;
         --COMMIT TRAN
         ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
         v_Result := CASE 
                          WHEN v_OperationFlag = 1
                            AND v_MenuId = 1468 THEN v_ExcelUploadId
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRO_CATEGORYUPLOAD_INUP_15122023" TO "ADF_CDR_RBL_STGDB";
