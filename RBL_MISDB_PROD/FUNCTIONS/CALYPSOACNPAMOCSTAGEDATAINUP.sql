--------------------------------------------------------
--  DDL for Function CALYPSOACNPAMOCSTAGEDATAINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" 
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
   v_temp NUMBER(1, 0) := 0;
   ------RETURN @UniqueUploadID  
   --ROLLBACK TRAN  
   v_cursor SYS_REFCURSOR;
--DECLARE @Timekey INT=24928,  
-- @UserLoginID VARCHAR(100)='FNAOPERATOR',  
-- @OperationFlag INT=1,  
-- @MenuId INT=163,  
-- @AuthMode CHAR(1)='N',  
-- @filepath VARCHAR(MAX)='',  
-- @EffectiveFromTimeKey INT=24928,  
-- @EffectiveToTimeKey INT=49999,  
--    @Result  INT=0 ,  
-- @UniqueUploadID INT=41  

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
      --DECLARE @Timekey INT  
      --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle  
      -- WHERE ProcessType='Quarterly')  
      --Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A  
      --Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey  
      -- where A.CurrentStatus='C')  
      --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')   
      --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   
      --DECLARE @LastMonthDate date = (select  LastMonthDate from SysDayMatrix where Timekey in (select  Timekey from sysdatamatrix where CurrentStatus = 'C'))  
      v_MocDate VARCHAR2(200);
      v_MocStatus VARCHAR2(100) := ' ';
      v_FilePathUpload VARCHAR2(100);

   BEGIN
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDataMatrix 
       WHERE  MOC_Initialised = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';
      SELECT ExtDate 

        INTO v_MocDate
        FROM SysDataMatrix 
       WHERE  MOC_Initialised = 'Y'
                AND NVL(MOC_Frozen, 'N') = 'N';
      DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
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
      v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
      DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
      DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
      BEGIN

         BEGIN
            --BEGIN TRAN  
            IF ( v_MenuId = 27767 ) THEN

            BEGIN
               IF ( v_OperationFlag = 1 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE NOT ( EXISTS ( SELECT 1 
                                           FROM CalypsoAccountLvlMOCDetails_stg 
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
                                     FROM CalypsoAccountLvlMOCDetails_stg 
                                      WHERE  filname = v_FilePathUpload );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN
                   DECLARE
                     v_ExcelUploadId NUMBER(10,0);
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     INSERT INTO ExcelUploadHistory
                       ( UploadedBy, DateofUpload, AuthorisationStatus
                     --,Action   
                     , UploadType, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                       ( SELECT v_UserLoginID ,
                                SYSDATE ,
                                'NP' ,
                                --,'NP'  
                                'Calypso Account MOC Upload' ,
                                v_EffectiveFromTimeKey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginID ,
                                SYSDATE 
                           FROM DUAL  );
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     DBMS_OUTPUT.PUT_LINE('Prashant');
                     SELECT MAX(UniqueUploadID)  

                       INTO v_ExcelUploadId
                       FROM ExcelUploadHistory ;
                     INSERT INTO UploadStatus
                       ( FileNames, UploadedBy, UploadDateTime, UploadType )
                       VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Calypso Account MOC Upload' );
                     /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                     --INSERT INTO AccountMOCDetail_MOD  
                     --(  
                     --  SrNo  
                     -- ,UploadID  
                     -- ,SlNo  
                     -- ,AccountID  
                     -- ,POSinRs  
                     -- ,InterestReceivableinRs  
                     -- ,AdditionalProvisionAbsoluteinRs  
                     -- ,RestructureFlag  
                     -- ,RestructureDat  
                     -- ,FITLFlag  
                     -- ,DFVAmount  
                     -- ,RePossesssionFlag  
                     -- ,RePossessionDate  
                     -- ,InherentWeaknessFlag  
                     -- ,InherentWeaknessDate  
                     -- ,SARFAESIFlag  
                     -- ,SARFAESIDate  
                     -- ,UnusualBounceFlag  
                     -- ,UnusualBounceDate  
                     -- ,UnclearedEffectsFlag  
                     -- ,UnclearedEffectsDate  
                     -- ,FraudFlag  
                     -- ,FraudDate  
                     -- ,MOCSource  
                     -- ,MOCReason  
                     -- ,AuthorisationStatus   
                     -- ,EffectiveFromTimeKey   
                     -- ,EffectiveToTimeKey   
                     -- ,CreatedBy   
                     -- ,DateCreated  
                     -- ,ScreenFlag  
                     --)  
                     --SELECT  
                     --  SlNo  
                     -- ,@ExcelUploadId  
                     -- ,SlNo  
                     -- ,AccountID  
                     -- ,POSinRs  
                     -- ,InterestReceivableinRs  
                     -- ,AdditionalProvisionAbsoluteinRs  
                     -- ,RestructureFlagYN  
                     -- ,RestructureDate   
                     -- ,FITLFlagYN  
                     -- ,DFVAmount  
                     -- ,RePossesssionFlagYN  
                     -- ,RePossessionDate  
                     -- ,InherentWeaknessFlag  
                     -- ,InherentWeaknessDate  
                     -- ,SARFAESIFlag  
                     -- ,SARFAESIDate  
                     -- ,UnusualBounceFlag  
                     -- ,UnusualBounceDate  
                     -- ,UnclearedEffectsFlag  
                     -- ,UnclearedEffectsDate  
                     -- ,FraudFlag  
                     -- ,FraudDate  
                     -- ,MOCSource  
                     -- ,MOCReason  
                     -- ,'NP'   
                     -- ,@Timekey  
                     -- ,@TimeKey   
                     -- ,@UserLoginID   
                     -- ,GETDATE()   
                     -- ,'U'  
                     --FROM AccountLvlMOCDetails_stg  
                     --where filname=@FilePathUpload  
                     INSERT INTO CalypsoAccountLevelMOC_Mod
                       ( SrNo, UploadID, AccountId, BookValue, unserviedint, AdditionalProvisionAbsolute, MOCSource, MOCReason, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ScreenFlag, ChangeField
                     --,FlgTwo  
                      --,TwoDate  
                      -- ,TwoAmount  
                     , MOCDate, MOC_TYPEFLAG )
                       ( SELECT SlNo ,
                                v_ExcelUploadId ,
                                InvestmentIDDerivativeRefNo ,
                                NVL(CASE 
                                         WHEN NVL(BookValueINRMTMValue, ' ') <> ' ' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(BookValueINRMTMValue,16,2), 0),30,2)   END, NULL) BookValueINRMTMValue  ,
                                NVL(CASE 
                                         WHEN NVL(UnservicedInterest, ' ') <> ' ' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(UnservicedInterest,16,2), 0),30,2)   END, NULL) UnservicedInterest  ,
                                NVL(CASE 
                                         WHEN NVL(AdditionalProvisionAbsolute, ' ') <> ' ' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(AdditionalProvisionAbsolute,16,2), 0),30,2)   END, NULL) AdditionalProvisionAbsoluteinRs  ,
                                MOCSource ,
                                MOCReason ,
                                'NP' ,
                                v_Timekey ,
                                v_EffectiveToTimeKey ,
                                v_UserLoginID ,
                                SYSDATE ,
                                'U' ,
                                NULL ,
                                v_MocDate ,
                                'ACCT' 
                         FROM CalypsoAccountLvlMOCDetails_stg A
                          WHERE  filname = v_FilePathUpload );
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoAccountLevelMOC_Mod A
                                               JOIN InvestmentBasicDetail B   ON A.AccountID = B.InvID
                                               AND B.EffectiveFromTimeKey <= v_TimeKey
                                               AND B.EffectiveToTimeKey >= v_TimeKey
                                         WHERE  A.UploadID = v_ExcelUploadId );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        MERGE INTO A 
                        USING (SELECT A.ROWID row_id, B.InvEntityID
                        FROM A ,CalypsoAccountLevelMOC_Mod A
                               JOIN InvestmentBasicDetail B   ON A.AccountID = B.InvID
                               AND B.EffectiveFromTimeKey <= v_TimeKey
                               AND B.EffectiveToTimeKey >= v_TimeKey 
                         WHERE A.UploadId = v_ExcelUploadId) src
                        ON ( A.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET A.AccountEntityID = src.InvEntityID;

                     END;
                     ELSE

                     BEGIN
                        MERGE INTO A 
                        USING (SELECT A.ROWID row_id, B.DerivativeEntityID
                        FROM A ,CalypsoAccountLevelMOC_Mod A
                               JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.AccountID = B.DerivativeRefNo
                               AND B.EffectiveFromTimeKey <= v_TimeKey
                               AND B.EffectiveToTimeKey >= v_TimeKey 
                         WHERE A.UploadId = v_ExcelUploadId) src
                        ON ( A.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET A.AccountEntityID = src.DerivativeEntityID;

                     END;
                     END IF;
                     ---------------------------------------------------------ChangeField Logic---------------------  
                     ----select * from AccountLvlMOCDetails_stg  
                     IF utils.object_id('TempDB..tt_AccountMocUpload_9') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountMocUpload_9 ';
                     END IF;
                     DELETE FROM tt_AccountMocUpload_9;
                     INSERT INTO tt_AccountMocUpload_9
                       ( AccountID, FieldName )
                       ( SELECT InvestmentIDDerivativeRefNo ,
                                'AdditionalProvisionAbsolute' FieldName  
                         FROM CalypsoAccountLvlMOCDetails_stg 
                          WHERE  NVL(AdditionalProvisionAbsolute, ' ') <> ' ' --AdditionalProvisionAbsoluteinRs Is not NULL  

                         UNION 

                         --Select AccountID, 'RestructureFlagYN' FieldName from AccountLvlMOCDetails_stg Where isnull(RestructureFlagYN,'')<>'' --RestructureFlagYN Is not NULL  

                         --UNION ALL  

                         --Select AccountID, 'RestructureDate' FieldName from AccountLvlMOCDetails_stg Where isnull(RestructureDate,'')<>'' --RestructureDate Is not NULL  

                         --UNION ALL  

                         --countID, 'RePossesssionFlagYN' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(RePossesssionFlagYN,'')<>'' --RePossesssionFlagYN Is not NULL  

                         --Select AccountID, 'UnclearedEffectsFlag' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(UnclearedEffectsFlag,'')<>'' --UnclearedEffectsFlag Is not NULL  

                         --UNION ALL  

                         --Select AccountID, 'UnclearedEffectsDate' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(UnclearedEffectsDate,'')<>'' --UnclearedEffectsDate Is not NULL  

                         --UNION ALL  

                         --Select AccountID, 'FraudFlag' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(FraudFlag,'')<>'' --FraudFlag Is not NULL  

                         --UNION ALL  

                         --Select InvestmentIDDerivativeRefNo,'FraudDate' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(FraudDate,'')<>'' --FraudDate Is not NULL  

                         --UNION ALL  
                         SELECT InvestmentIDDerivativeRefNo ,
                                'MOCSource' FieldName  
                         FROM CalypsoAccountLvlMOCDetails_stg 
                          WHERE  NVL(MOCSource, ' ') <> ' ' --MOCSource Is not NULL  

                         UNION ALL 
                         SELECT InvestmentIDDerivativeRefNo ,
                                'MOCReason' FieldName  
                         FROM CalypsoAccountLvlMOCDetails_stg 
                          WHERE  NVL(MOCReason, ' ') <> ' ' );--MOCReason Is not NULL  
                     --UNION ALL  
                     --Select AccountID, 'TwoFlag' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(TwoFlag,'')<>'' --TwoFlag Is not NULL  
                     --UNION ALL  
                     --Select InvestmentIDDerivativeRefNo, 'TwoDate' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(TwoDate,'')<>'' --TwoDate Is not NULL  
                     ----UNION ALL  
                     --Select AccountID, 'TwoAmount' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(TwoAmount,'')<>'' --TwoAmount Is not NULL  
                     --select *  
                     MERGE INTO B 
                     USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                     FROM B ,MetaScreenFieldDetail A
                            JOIN tt_AccountMocUpload_9 B   ON A.CtrlName = B.FieldName 
                      WHERE A.MenuId = 27767
                       AND A.IsVisible = 'Y') src
                     ON ( B.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                     IF utils.object_id('TEMPDB..tt_NEWTRANCHE_41') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_41 ';
                     END IF;
                     DELETE FROM tt_NEWTRANCHE_41;
                     UTILS.IDENTITY_RESET('tt_NEWTRANCHE_41');

                     INSERT INTO tt_NEWTRANCHE_41 SELECT * 
                          FROM ( SELECT ss.InvestmentIDDerivativeRefNo ,
                                        utils.stuff(( SELECT ',' || US.SrNo 
                                                      FROM tt_AccountMocUpload_9 US
                                                       WHERE  US.AccountID = ss.InvestmentIDDerivativeRefNo ), 1, 1, ' ') REPORTIDSLIST  
                                 FROM CalypsoAccountLvlMOCDetails_stg SS
                                   GROUP BY ss.InvestmentIDDerivativeRefNo ) B
                          ORDER BY 1;
                     --Select * from tt_NEWTRANCHE_41  
                     --SELECT *   
                     MERGE INTO A 
                     USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                     FROM A ,RBL_MISDB_PROD.CalypsoAccountLevelMOC_Mod A
                            JOIN tt_NEWTRANCHE_41 B   ON A.AccountID = B.InvestmentIDDerivativeRefNo 
                      WHERE A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey
                       AND A.UploadId = v_ExcelUploadId) src
                     ON ( A.ROWID = src.row_id )
                     WHEN MATCHED THEN UPDATE SET A.ChangeField = src.REPORTIDSLIST;
                     DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                     -------------------------------------------------------------------------------------  
                     --Declare @SummaryId int  
                     --Set @SummaryId=IsNull((Select Max(SummaryId) from AccountMOCDetail_MOD),0)  
                     --INSERT INTO AccountMOCSummary_Mod  
                     --(  
                     --  UploadID  
                     -- ,SummaryID  
                     -- ,PoolID  
                     -- ,PoolName  
                     -- ,PoolType  
                     -- ,BalanceOutstanding  
                     -- ,NoOfAccount  
                     -- ,IBPCExposureAmt  
                     -- ,IBPCReckoningDate  
                     -- ,IBPCMarkingDate  
                     -- ,MaturityDate  
                     -- ,TotalPosBalance  
                     -- ,TotalInttReceivable  
                     --)  
                     --SELECT  
                     -- @ExcelUploadId  
                     -- ,@SummaryId+Row_Number() over(Order by PoolID)  
                     -- ,PoolID  
                     -- ,PoolName  
                     -- ,PoolType  
                     -- ,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))  
                     -- ,Count(PoolID)  
                     -- ,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))  
                     -- ,DateofIBPCreckoning  
                     -- ,DateofIBPCmarking  
                     -- ,MaturityDate  
                     -- ,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))  
                     -- ,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))  
                     --FROM AccountLvlMOCDetails_stg  
                     --where filename=@FilePathUpload  
                     --Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate  
                     --INSERT INTO IBPCPoolSummary_Mod  
                     --(  
                     -- UploadID  
                     -- ,SummaryID  
                     -- ,PoolID  
                     -- ,PoolName  
                     -- ,BalanceOutstanding  
                     -- ,NoOfAccount  
                     -- ,AuthorisationStatus   
                     -- ,EffectiveFromTimeKey   
                     -- ,EffectiveToTimeKey   
                     -- ,CreatedBy   
                     -- ,DateCreated   
                     --)  
                     --SELECT  
                     -- @ExcelUploadId  
                     -- ,@SummaryId+Row_Number() over(Order by PoolID)  
                     -- ,PoolID  
                     -- ,PoolName  
                     -- ,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))  
                     -- ,Count(PoolID)  
                     -- ,'NP'   
                     -- ,@Timekey  
                     -- ,49999   
                     -- ,@UserLoginID   
                     -- ,GETDATE()  
                     --FROM IBPCPoolDetail_stg  
                     --where filename=@FilePathUpload  
                     --Group by PoolID,PoolName  
                     -----DELETE FROM STAGING DATA  
                     DELETE CalypsoAccountLvlMOCDetails_stg

                      WHERE  filname = v_FilePathUpload;

                  END;
                  END IF;

               END;
               END IF;
               ----RETURN @ExcelUploadId  
               ----DECLARE @UniqueUploadID INT  
               --SET  @UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)  
               ----------------------01042021-------------  
               IF ( v_OperationFlag = 16 ) THEN

                ----AUTHORIZE  
               BEGIN
                  UPDATE CalypsoAccountLevelMOC_Mod
                     SET AuthorisationStatus = '1A',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedBy = v_UserLoginID
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Calypso Account MOC Upload';

               END;
               END IF;
               --------------------------------------------  
               IF ( v_OperationFlag = 20 ) THEN

                ----AUTHORIZE  
               BEGIN
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     UPDATE CalypsoAccountLevelMOC_Mod
                        SET AuthorisationStatus = 'A',
                            ApprovedBy = v_UserLoginID,
                            DateApproved = SYSDATE
                      WHERE  UploadId = v_UniqueUploadID;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoInvMOC_ChangeDetails A
                                               JOIN InvestmentBasicDetail B   ON A.AccountEntityID = B.InvEntityId
                                               AND A.EffectiveFromTimeKey <= v_Timekey
                                               AND A.EffectiveToTimeKey >= v_Timekey
                                               AND B.EffectiveFromTimeKey <= v_Timekey
                                               AND B.EffectiveToTimeKey >= v_Timekey
                                               JOIN CalypsoAccountLevelMOC_Mod C   ON B.InvEntityId = C.AccountEntityID
                                               AND C.EffectiveFromTimeKey <= v_Timekey
                                               AND C.EffectiveToTimeKey >= v_Timekey
                                               AND C.AuthorisationStatus = 'A'
                                               AND UploadId = v_UniqueUploadID
                                         WHERE  A.EffectiveToTimeKey >= v_Timekey
                                                  AND A.AuthorisationStatus = 'A'
                                                  AND A.MOCType_Flag = 'ACCT'
                                                  AND UploadId = v_UniqueUploadID );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        MERGE INTO A 
                        USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                        FROM A ,CalypsoInvMOC_ChangeDetails A
                               JOIN InvestmentBasicDetail B   ON A.AccountEntityID = B.InvEntityId
                               AND A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND B.EffectiveFromTimeKey <= v_Timekey
                               AND B.EffectiveToTimeKey >= v_Timekey
                               JOIN CalypsoAccountLevelMOC_Mod C   ON B.InvEntityId = C.AccountEntityID
                               AND C.EffectiveFromTimeKey <= v_Timekey
                               AND C.EffectiveToTimeKey >= v_Timekey
                               AND C.AuthorisationStatus = 'A'
                               AND UploadId = v_UniqueUploadID 
                         WHERE A.EffectiveToTimeKey >= v_Timekey
                          AND A.AuthorisationStatus = 'A'
                          AND A.MOCType_Flag = 'ACCT'
                          AND UploadId = v_UniqueUploadID) src
                        ON ( A.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;

                     END;
                     ELSE

                     BEGIN
                        MERGE INTO A 
                        USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                        FROM A ,CalypsoDervMOC_ChangeDetails A
                               JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.AccountEntityID = B.DerivativeEntityID
                               AND A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND B.EffectiveFromTimeKey <= v_Timekey
                               AND B.EffectiveToTimeKey >= v_Timekey
                               JOIN CalypsoAccountLevelMOC_Mod C   ON B.DerivativeEntityID = C.AccountEntityID
                               AND C.EffectiveFromTimeKey <= v_Timekey
                               AND C.EffectiveToTimeKey >= v_Timekey
                               AND C.AuthorisationStatus = 'A'
                               AND UploadId = v_UniqueUploadID 
                         WHERE A.EffectiveToTimeKey >= v_Timekey
                          AND A.AuthorisationStatus = 'A'
                          AND A.MOCType_Flag = 'ACCT'
                          AND UploadId = v_UniqueUploadID) src
                        ON ( A.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;

                     END;
                     END IF;
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM CalypsoAccountLevelMOC_Mod A
                                               JOIN InvestmentFinancialDetail B   ON A.AccountID = B.RefInvID
                                               AND B.EffectiveFromTimeKey <= v_Timekey
                                               AND B.EffectiveToTimeKey >= v_Timekey
                                         WHERE  A.UploadId = v_UniqueUploadID
                                                  AND A.EffectiveFromTimeKey <= v_Timekey
                                                  AND A.EffectiveToTimeKey >= v_Timekey
                                                  AND A.AuthorisationStatus = 'A' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        INSERT INTO CalypsoInvMOC_ChangeDetails
                          ( AccountEntityID, CustomerEntityId, AddlProvAbs, FlgFraud, FraudDate, PrincOutStd, unserviedint, FLGFITL, DFVAmt, MOC_Source, MOC_Date, MOC_By, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MOCType_Flag, TwoFlag, TwoDate, ApprovedByFirstLevel, DateApprovedFirstLevel, MOC_Reason, MOCProcessed, BookValue )
                          ( SELECT B.InvEntityID ,
                                   B.IssuerEntityID ,
                                   A.AdditionalProvisionAbsolute ,
                                   A.FraudAccountFlag ,
                                   A.FraudDate ,
                                   A.POS ,
                                   A.unserviedint ,--receivable column removed unserviced removed added        

                                   A.FITLFlag ,
                                   A.DFVAmount ,
                                   A.MOCSource ,
                                   A.MOCDate ,
                                   A.CreatedBy ,
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifyBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   'ACCT' MOCType_Flag  ,
                                   A.FlgTwo ,
                                   A.TwoDate ,
                                   a.ApprovedByFirstLevel ,
                                   a.DateApprovedFirstLevel ,
                                   MOCReason ,
                                   'N' ,
                                   A.BookValue 
                            FROM CalypsoAccountLevelMOC_Mod A
                                   JOIN InvestmentBasicDetail B   ON A.AccountID = B.InvID
                                   AND B.EffectiveFromTimeKey <= v_Timekey
                                   AND B.EffectiveToTimeKey >= v_Timekey
                             WHERE  A.UploadId = v_UniqueUploadID
                                      AND A.EffectiveFromTimeKey <= v_Timekey
                                      AND A.EffectiveToTimeKey >= v_Timekey
                                      AND A.AuthorisationStatus = 'A' );

                     END;
                     ELSE

                     BEGIN
                        INSERT INTO CalypsoDervMOC_ChangeDetails
                          ( AccountEntityID, CustomerEntityId, AddlProvAbs, FlgFraud, FraudDate, PrincOutStd, unserviedint, FLGFITL, DFVAmt, MOC_Source, MOC_Date, MOC_By, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MOCType_Flag, TwoFlag, TwoDate, ApprovedByFirstLevel, DateApprovedFirstLevel, MOC_Reason, MOCProcessed )
                          ( SELECT B.DerivativeEntityID ,
                                   C.CustomerEntityId ,
                                   A.AdditionalProvisionAbsolute ,
                                   A.FraudAccountFlag ,
                                   A.FraudDate ,
                                   A.POS ,
                                   A.InterestReceivable ,
                                   A.FITLFlag ,
                                   A.DFVAmount ,
                                   A.MOCSource ,
                                   A.MOCDate ,
                                   A.CreatedBy ,
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifyBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   'ACCT' MOCType_Flag  ,
                                   A.FlgTwo ,
                                   A.TwoDate ,
                                   a.ApprovedByFirstLevel ,
                                   a.DateApprovedFirstLevel ,
                                   MOCReason ,
                                   'N' 
                            FROM CalypsoAccountLevelMOC_Mod A
                                   JOIN CurDat_RBL_MISDB_PROD.DerivativeDetail B   ON A.AccountID = B.DerivativeRefNo
                                   AND B.EffectiveFromTimeKey <= v_Timekey
                                   AND B.EffectiveToTimeKey >= v_Timekey
                                   LEFT JOIN AdvAcBasicDetail C   ON A.AccountID = C.CustomerACID
                                   AND C.EffectiveFromTimeKey <= v_Timekey
                                   AND C.EffectiveToTimeKey >= v_Timekey
                             WHERE  A.UploadId = v_UniqueUploadID
                                      AND A.EffectiveFromTimeKey <= v_Timekey
                                      AND A.EffectiveToTimeKey >= v_Timekey
                                      AND A.AuthorisationStatus = 'A' );

                     END;
                     END IF;
                     UPDATE ExcelUploadHistory
                        SET AuthorisationStatus = 'A',
                            ApprovedBy = v_UserLoginID,
                            DateApproved = SYSDATE
                      WHERE  EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey
                       AND UniqueUploadID = v_UniqueUploadID
                       AND UploadType = 'Calypso Account MOC Upload';

                  END;

               END;
               END IF;
               IF ( v_OperationFlag = 17 ) THEN

                ----REJECT  
               BEGIN
                  UPDATE CalypsoAccountLevelMOC_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE,
                         EffectiveToTimeKey = v_EffectiveFromTimeKey - 1
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Calypso Account MOC Upload';

               END;
               END IF;
               IF ( v_OperationFlag = 21 ) THEN

                ----REJECT  
               BEGIN
                  UPDATE CalypsoAccountLevelMOC_Mod
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
                    AND UploadType = 'Calypso Account MOC Upload';

               END;
               END IF;

            END;
            END IF;
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
                               AND v_MenuId = 27767 THEN v_ExcelUploadId
            ELSE 1
               END ;
            UPDATE UploadStatus
               SET InsertionOfData = 'Y',
                   InsertionCompletedOn = SYSDATE
             WHERE  FileNames = v_filepath;
            ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)  
            ----BEGIN  
            ----  DELETE FROM IBPCPoolDetail_stg  
            ----  WHERE filEname=@FilePathUpload  
            ----  PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))  
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CALYPSOACNPAMOCSTAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
