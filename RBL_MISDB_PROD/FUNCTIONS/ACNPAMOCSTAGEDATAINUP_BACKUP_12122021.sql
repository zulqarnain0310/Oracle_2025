--------------------------------------------------------
--  DDL for Function ACNPAMOCSTAGEDATAINUP_BACKUP_12122021
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" 
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
   --Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
   --Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
   -- where A.CurrentStatus='C')
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT LastMonthDateKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Timekey = v_Timekey;
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := v_TimeKey ;
   v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
   DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
   DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
   BEGIN

      BEGIN
         --BEGIN TRAN
         IF ( v_MenuId = 24715 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM AccountLvlMOCDetails_stg 
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
                                  FROM AccountLvlMOCDetails_stg 
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
                             'Account MOC Upload' ,
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
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Account MOC Upload' );
                  /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                  --INSERT INTO AccountMOCDetail_MOD
                  --(
                  --	 SrNo
                  --	,UploadID
                  --	,SlNo
                  --	,AccountID
                  --	,POSinRs
                  --	,InterestReceivableinRs
                  --	,AdditionalProvisionAbsoluteinRs
                  --	,RestructureFlag
                  --	,RestructureDat
                  --	,FITLFlag
                  --	,DFVAmount
                  --	,RePossesssionFlag
                  --	,RePossessionDate
                  --	,InherentWeaknessFlag
                  --	,InherentWeaknessDate
                  --	,SARFAESIFlag
                  --	,SARFAESIDate
                  --	,UnusualBounceFlag
                  --	,UnusualBounceDate
                  --	,UnclearedEffectsFlag
                  --	,UnclearedEffectsDate
                  --	,FraudFlag
                  --	,FraudDate
                  --	,MOCSource
                  --	,MOCReason
                  --	,AuthorisationStatus	
                  --	,EffectiveFromTimeKey	
                  --	,EffectiveToTimeKey	
                  --	,CreatedBy	
                  --	,DateCreated
                  --	,ScreenFlag
                  --)
                  --SELECT
                  --	 SlNo
                  --	,@ExcelUploadId
                  --	,SlNo
                  --	,AccountID
                  --	,POSinRs
                  --	,InterestReceivableinRs
                  --	,AdditionalProvisionAbsoluteinRs
                  --	,RestructureFlagYN
                  --	,RestructureDate	
                  --	,FITLFlagYN
                  --	,DFVAmount
                  --	,RePossesssionFlagYN
                  --	,RePossessionDate
                  --	,InherentWeaknessFlag
                  --	,InherentWeaknessDate
                  --	,SARFAESIFlag
                  --	,SARFAESIDate
                  --	,UnusualBounceFlag
                  --	,UnusualBounceDate
                  --	,UnclearedEffectsFlag
                  --	,UnclearedEffectsDate
                  --	,FraudFlag
                  --	,FraudDate
                  --	,MOCSource
                  --	,MOCReason
                  --	,'NP'	
                  --	,@Timekey
                  --	,@TimeKey	
                  --	,@UserLoginID	
                  --	,GETDATE()	
                  --	,'U'
                  --FROM AccountLvlMOCDetails_stg
                  --where filname=@FilePathUpload
                  INSERT INTO AccountLevelMOC_Mod
                    ( SrNo, UploadID, AccountID, POS, InterestReceivable, AdditionalProvisionAbsolute, RestructureFlag, RestructureDate, FITLFlag, DFVAmount, RePossessionFlag, RePossessionDate, InherentWeaknessFlag, InherentWeaknessDate, SARFAESIFlag, SARFAESIDate, UnusualBounceFlag, UnusualBounceDate, UnclearedEffectsFlag, UnclearedEffectsDate, FraudAccountFlag, FraudDate, MOCSource, MOCReason, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ScreenFlag, ChangeField )
                    ( SELECT SlNo ,
                             v_ExcelUploadId ,
                             AccountID ,
                             --,POSinRs
                             NVL(CASE 
                                      WHEN NVL(POSinRs, '0') <> '0' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(POSinRs,10,0), 0),30,2)   END, 0) POSinRs  ,
                             --,InterestReceivableinRs
                             NVL(CASE 
                                      WHEN NVL(InterestReceivableinRs, '0') <> '0' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(InterestReceivableinRs,10,0), 0),30,2)   END, 0) InterestReceivableinRs  ,
                             --,AdditionalProvisionAbsoluteinRs
                             NVL(CASE 
                                      WHEN NVL(AdditionalProvisionAbsoluteinRs, '0') <> '0' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(AdditionalProvisionAbsoluteinRs,10,0), 0),30,2)   END, 0) AdditionalProvisionAbsoluteinRs  ,
                             RestructureFlagYN ,
                             CASE 
                                  WHEN RestructureDate <> ' ' THEN RestructureDate
                             ELSE NULL
                                END RestructureDate  ,
                             FITLFlagYN ,
                             --,DFVAmount
                             NVL(CASE 
                                      WHEN NVL(DFVAmount, '0') <> '0' THEN UTILS.CONVERT_TO_NUMBER(NVL(UTILS.CONVERT_TO_NUMBER(DFVAmount,10,0), 0),30,2)   END, 0) DFVAmount  ,
                             RePossesssionFlagYN ,
                             CASE 
                                  WHEN RePossessionDate <> ' ' THEN RePossessionDate
                             ELSE NULL
                                END RePossessionDate  ,
                             InherentWeaknessFlag ,
                             CASE 
                                  WHEN InherentWeaknessDate <> ' ' THEN InherentWeaknessDate
                             ELSE NULL
                                END InherentWeaknessDate  ,
                             SARFAESIFlag ,
                             CASE 
                                  WHEN SARFAESIDate <> ' ' THEN SARFAESIDate
                             ELSE NULL
                                END SARFAESIDate  ,
                             UnusualBounceFlag ,
                             CASE 
                                  WHEN UnusualBounceDate <> ' ' THEN UnusualBounceDate
                             ELSE NULL
                                END UnusualBounceDate  ,
                             UnclearedEffectsFlag ,
                             CASE 
                                  WHEN UnclearedEffectsDate <> ' ' THEN UnclearedEffectsDate
                             ELSE NULL
                                END UnclearedEffectsDate  ,
                             FraudFlag ,
                             FraudDate ,
                             MOCSource ,
                             MOCReason ,
                             'NP' ,
                             v_Timekey ,
                             v_TimeKey ,
                             v_UserLoginID ,
                             SYSDATE ,
                             'U' ,
                             NULL 
                      FROM AccountLvlMOCDetails_stg A
                       WHERE  filname = v_FilePathUpload );
                  ---------------------------------------------------------ChangeField Logic---------------------
                  ----select * from AccountLvlMOCDetails_stg
                  IF utils.object_id('TempDB..tt_AccountMocUpload_8') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_AccountMocUpload_8 ';
                  END IF;
                  DELETE FROM tt_AccountMocUpload_8;
                  INSERT INTO tt_AccountMocUpload_8
                    ( AccountID, FieldName )
                    ( SELECT AccountID ,
                             'POSinRs' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(POSinRs, ' ') <> ' ' --Is not NULL

                      UNION 
                      SELECT AccountID ,
                             'InterestReceivableinRs' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(InterestReceivableinRs, ' ') <> ' ' --InterestReceivableinRs Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'AdditionalProvisionAbsoluteinRs' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(AdditionalProvisionAbsoluteinRs, ' ') <> ' ' --AdditionalProvisionAbsoluteinRs Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'RestructureFlagYN' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(RestructureFlagYN, ' ') <> ' ' --RestructureFlagYN Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'RestructureDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(RestructureDate, ' ') <> ' ' --RestructureDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'FITLFlagYN' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(FITLFlagYN, ' ') <> ' ' --FITLFlagYN Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'DFVAmount' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(DFVAmount, ' ') <> ' ' --DFVAmount Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'RePossesssionFlagYN' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(RePossesssionFlagYN, ' ') <> ' ' --RePossesssionFlagYN Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'RePossessionDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(RePossessionDate, ' ') <> ' ' --RePossessionDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'InherentWeaknessFlag' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(InherentWeaknessFlag, ' ') <> ' ' --InherentWeaknessFlag Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'InherentWeaknessDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(InherentWeaknessDate, ' ') <> ' ' --InherentWeaknessDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'SARFAESIFlag' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(SARFAESIFlag, ' ') <> ' ' --SARFAESIFlag Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'SARFAESIDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(SARFAESIDate, ' ') <> ' ' --SARFAESIDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'UnusualBounceFlag' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(UnusualBounceFlag, ' ') <> ' ' --UnusualBounceFlag Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'UnusualBounceDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(UnusualBounceDate, ' ') <> ' ' --UnusualBounceDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'UnclearedEffectsFlag' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(UnclearedEffectsFlag, ' ') <> ' ' --UnclearedEffectsFlag Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'UnclearedEffectsDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(UnclearedEffectsDate, ' ') <> ' ' --UnclearedEffectsDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'FraudFlag' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(FraudFlag, ' ') <> ' ' --FraudFlag Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'FraudDate' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(FraudDate, ' ') <> ' ' --FraudDate Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'MOCSource' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(MOCSource, ' ') <> ' ' --MOCSource Is not NULL

                      UNION ALL 
                      SELECT AccountID ,
                             'MOCReason' FieldName  
                      FROM AccountLvlMOCDetails_stg 
                       WHERE  NVL(MOCReason, ' ') <> ' ' );--MOCReason Is not NULL
                  --select *
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                  FROM B ,MetaScreenFieldDetail A
                         JOIN tt_AccountMocUpload_8 B   ON A.CtrlName = B.FieldName 
                   WHERE A.MenuId = 24715
                    AND A.IsVisible = 'Y') src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                  IF utils.object_id('TEMPDB..tt_NEWTRANCHE_8') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_8 ';
                  END IF;
                  DELETE FROM tt_NEWTRANCHE_8;
                  UTILS.IDENTITY_RESET('tt_NEWTRANCHE_8');

                  INSERT INTO tt_NEWTRANCHE_8 SELECT * 
                       FROM ( SELECT ss.AccountID ,
                                     utils.stuff(( SELECT ',' || US.SrNo 
                                                   FROM tt_AccountMocUpload_8 US
                                                    WHERE  US.AccountID = ss.AccountID ), 1, 1, ' ') REPORTIDSLIST  
                              FROM AccountLvlMOCDetails_stg SS
                                GROUP BY ss.AccountID ) B
                       ORDER BY 1;
                  --Select * from tt_NEWTRANCHE_8
                  --SELECT * 
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                  FROM A ,RBL_MISDB_PROD.AccountLevelMOC_Mod A
                         JOIN tt_NEWTRANCHE_8 B   ON A.AccountID = B.AccountID 
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
                  --	 UploadID
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
                  --FROM AccountLvlMOCDetails_stg
                  --where filename=@FilePathUpload
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
                  --where filename=@FilePathUpload
                  --Group by PoolID,PoolName
                  ---DELETE FROM STAGING DATA
                  DELETE AccountLvlMOCDetails_stg

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
               UPDATE AccountLevelMOC_Mod
                  SET AuthorisationStatus = '1A',
                      ApprovedByFirstLevel = v_UserLoginID,
                      DateApprovedFirstLevel = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = '1A',
                      ApprovedBy = v_UserLoginID
                WHERE  UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Account MOC Upload';

            END;
            END IF;
            --------------------------------------------
            IF ( v_OperationFlag = 20 ) THEN

             ----AUTHORIZE
            BEGIN
               UPDATE AccountLevelMOC_Mod
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  UploadId = v_UniqueUploadID;
               -----maintain history
               --Update  A
               --Set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1
               --from AccountMOCDetail A
               --inner join AccountMOCDetail_MOD B
               --ON A.AccountID=B.AccountID
               --AND B.EffectiveFromTimeKey <=@Timekey
               --AND B.EffectiveToTimeKey >=@Timekey
               --Where B.UploadId=@UniqueUploadID
               --AND A.EffectiveToTimeKey >=49999
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_ACCOUNT_CAL_2  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_ACCOUNT_CAL_2;
               UTILS.IDENTITY_RESET('tt_ACCOUNT_CAL_2');

               INSERT INTO tt_ACCOUNT_CAL_2 ( 
               	SELECT A.* 
               	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
                         JOIN AccountLevelMOC_Mod B   ON A.CustomerAcID = B.AccountID
               	 WHERE  ( A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey ) );
               --Select AccountEntityID,* from tt_ACCOUNT_CAL_2
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, v_TimeKey - 1 AS EffectiveToTimeKey
               FROM A ,PRO_RBL_MISDB_PROD.AccountCal_Hist A
                      JOIN AccountLevelMOC_Mod B   ON A.CustomerAcID = B.AccountID 
                WHERE ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey )
                 AND A.EffectiveFromTimeKey < v_TImeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN B.POS IS NULL THEN Balance
               ELSE B.POS
                  END AS pos_2, CASE 
               WHEN B.InterestReceivable IS NULL THEN unserviedint
               ELSE B.InterestReceivable
                  END AS pos_3, CASE 
               WHEN B.RestructureFlag IS NULL THEN FlgRestructure
               ELSE B.RestructureFlag
                  END AS pos_4, CASE 
               WHEN B.RestructureDate IS NULL THEN A.RestructureDate
               ELSE B.RestructureDate
                  END AS pos_5, CASE 
               WHEN B.FITLFlag IS NULL THEN FLGFITL
               ELSE B.FITLFlag
                  END AS pos_6, CASE 
               WHEN B.DFVAmount IS NULL THEN DFVAmt
               ELSE B.DFVAmount
                  END AS pos_7, CASE 
               WHEN B.RePossessionFlag IS NULL THEN RePossession
               ELSE B.RePossessionFlag
                  END AS pos_8, CASE 
               WHEN B.RePossessionDate IS NULL THEN A.RepossessionDate
               ELSE B.RePossessionDate
                  END AS pos_9, CASE 
               WHEN B.InherentWeaknessFlag IS NULL THEN WeakAccount
               ELSE B.InherentWeaknessFlag
                  END AS pos_10, CASE 
               WHEN B.InherentWeaknessDate IS NULL THEN WeakAccountDate
               ELSE B.InherentWeaknessDate
                  END AS pos_11, CASE 
               WHEN B.SARFAESIFlag IS NULL THEN Sarfaesi
               ELSE B.SARFAESIFlag
                  END AS pos_12, CASE 
               WHEN B.SARFAESIDate IS NULL THEN A.SarfaesiDate
               ELSE B.SARFAESIDate
                  END AS pos_13, CASE 
               WHEN B.UnusualBounceFlag IS NULL THEN FlgUnusualBounce
               ELSE B.UnusualBounceFlag
                  END AS pos_14, CASE 
               WHEN B.UnusualBounceDate IS NULL THEN A.UnusualBounceDate
               ELSE B.UnusualBounceDate
                  END AS pos_15, CASE 
               WHEN B.UnclearedEffectsFlag IS NULL THEN FlgUnClearedEffect
               ELSE B.UnclearedEffectsFlag
                  END AS pos_16, CASE 
               WHEN B.UnclearedEffectsDate IS NULL THEN UnClearedEffectDate
               ELSE B.UnclearedEffectsDate
                  END AS pos_17, CASE 
               WHEN B.AdditionalProvisionAbsolute IS NULL THEN AddlProvision
               ELSE B.AdditionalProvisionAbsolute
                  END AS pos_18, B.MOCReason, CASE 
               WHEN B.FraudAccountFlag IS NULL THEN FlgFraud
               ELSE B.FraudAccountFlag
                  END AS pos_20, CASE 
               WHEN B.FraudDate IS NULL THEN A.FraudDate
               ELSE B.FraudDate
                  END AS pos_21, 'Y', 'U', B.ChangeField
               FROM A ,PRO_RBL_MISDB_PROD.AccountCal_Hist a
                      JOIN AccountLevelMOC_Mod B   ON A.CustomerAcID = B.AccountID 
                WHERE A.EffectiveFromTimeKey = v_TimeKey
                 AND A.EffectiveToTimeKey = v_TimeKey) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.Balance = pos_2,
                                            A.unserviedint = pos_3,
                                            A.FlgRestructure = pos_4,
                                            A.RestructureDate = pos_5,
                                            A.FLGFITL = pos_6,
                                            A.DFVAmt = pos_7,
                                            A.RePossession = pos_8,
                                            A.RepossessionDate = pos_9,
                                            A.WeakAccount = pos_10,
                                            A.WeakAccountDate = pos_11,
                                            A.Sarfaesi = pos_12,
                                            A.SarfaesiDate = pos_13,
                                            A.FlgUnusualBounce = pos_14,
                                            A.UnusualBounceDate = pos_15,
                                            A.FlgUnClearedEffect = pos_16,
                                            A.UnClearedEffectDate
                                            --------,A.=@AdditionalProvisionCustomerlevel	
                                             = pos_17,
                                            A.AddlProvision = pos_18,
                                            A.MOCReason = src.MOCReason,
                                            A.FlgFraud = pos_20,
                                            A.FraudDate
                                            --,A.=@ScreenFlag						
                                             --,A.=@MOCSource							
                                             = pos_21,
                                            A.FlgMoc = 'Y',
                                            a.ScreenFlag = 'U',
                                            A.ChangeField = src.ChangeField;
               -- FlgRestructure	Char(1)
               --,RestructureDate	Date
               --,WeakAccountDate	Date
               --,SarfaesiDate	Date
               --,FlgUnusualBounce	Char(1)
               --,UnusualBounceDate	Date
               --,FlgUnClearedEffect	Char(1)
               --,UnClearedEffectDate	Date
               --,FlgFraud			Char(1)
               --,FraudDate			Date
               INSERT INTO PRO_RBL_MISDB_PROD.AccountCal_Hist
                 ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate, ScreenFlag, ChangeField )
                 ( SELECT A.AccountEntityID ,
                          UcifEntityID ,
                          CustomerEntityID ,
                          CustomerAcID ,
                          RefCustomerID ,
                          SourceSystemCustomerID ,
                          UCIF_ID ,
                          BranchCode ,
                          FacilityType ,
                          AcOpenDt ,
                          FirstDtOfDisb ,
                          ProductAlt_Key ,
                          SchemeAlt_key ,
                          SubSectorAlt_Key ,
                          SplCatg1Alt_Key ,
                          SplCatg2Alt_Key ,
                          SplCatg3Alt_Key ,
                          SplCatg4Alt_Key ,
                          SourceAlt_Key ,
                          ActSegmentCode ,
                          InttRate ,
                          CASE 
                               WHEN B.POS IS NULL THEN Balance
                          ELSE B.POS
                             END col  ,
                          BalanceInCrncy ,
                          CurrencyAlt_Key ,
                          DrawingPower ,
                          CurrentLimit ,
                          CurrentLimitDt ,
                          ContiExcessDt ,
                          StockStDt ,
                          DebitSinceDt ,
                          LastCrDate ,
                          InttServiced ,
                          IntNotServicedDt ,
                          OverdueAmt ,
                          OverDueSinceDt ,
                          ReviewDueDt ,
                          SecurityValue ,
                          CASE 
                               WHEN B.DFVAmount IS NULL THEN DFVAmt
                          ELSE B.DFVAmount
                             END DFVAmt  ,
                          GovtGtyAmt ,
                          CoverGovGur ,
                          WriteOffAmount ,
                          UnAdjSubSidy ,
                          CreditsinceDt ,
                          DegReason ,
                          Asset_Norm ,
                          REFPeriodMax ,
                          RefPeriodOverdue ,
                          RefPeriodOverDrawn ,
                          RefPeriodNoCredit ,
                          RefPeriodIntService ,
                          RefPeriodStkStatement ,
                          RefPeriodReview ,
                          NetBalance ,
                          ApprRV ,
                          SecuredAmt ,
                          UnSecuredAmt ,
                          ProvDFV ,
                          Provsecured ,
                          ProvUnsecured ,
                          ProvCoverGovGur ,
                          CASE 
                               WHEN B.AdditionalProvisionAbsolute IS NULL THEN AddlProvision
                          ELSE B.AdditionalProvisionAbsolute
                             END AddlProvision  ,
                          TotalProvision ,
                          BankProvsecured ,
                          BankProvUnsecured ,
                          BankTotalProvision ,
                          RBIProvsecured ,
                          RBIProvUnsecured ,
                          RBITotalProvision ,
                          InitialNpaDt ,
                          FinalNpaDt ,
                          SMA_Dt ,
                          UpgDate ,
                          InitialAssetClassAlt_Key ,
                          FinalAssetClassAlt_Key ,
                          ProvisionAlt_Key ,
                          PNPA_Reason ,
                          SMA_Class ,
                          SMA_Reason ,
                          FlgMoc ,
                          MOC_Dt ,
                          CommonMocTypeAlt_Key ,
                          FlgDeg ,
                          FlgDirtyRow ,
                          FlgInMonth ,
                          FlgSMA ,
                          FlgPNPA ,
                          FlgUpg ,
                          CASE 
                               WHEN B.FITLFlag IS NULL THEN FLGFITL
                          ELSE B.FITLFlag
                             END FlgFITL  ,
                          FlgAbinitio ,
                          NPA_Days ,
                          RefPeriodOverdueUPG ,
                          RefPeriodOverDrawnUPG ,
                          RefPeriodNoCreditUPG ,
                          RefPeriodIntServiceUPG ,
                          RefPeriodStkStatementUPG ,
                          RefPeriodReviewUPG ,
                          v_TimeKey ,
                          v_TimeKey ,
                          AppGovGur ,
                          UsedRV ,
                          ComputedClaim ,
                          UPG_RELAX_MSME ,
                          DEG_RELAX_MSME ,
                          PNPA_DATE ,
                          NPA_Reason ,
                          PnpaAssetClassAlt_key ,
                          DisbAmount ,
                          PrincOutStd ,
                          PrincOverdue ,
                          PrincOverdueSinceDt ,
                          IntOverdue ,
                          IntOverdueSinceDt ,
                          OtherOverdue ,
                          OtherOverdueSinceDt ,
                          RelationshipNumber ,
                          AccountFlag ,
                          CommercialFlag_AltKey ,
                          Liability ,
                          CD ,
                          AccountStatus ,
                          AccountBlkCode1 ,
                          AccountBlkCode2 ,
                          ExposureType ,
                          Mtm_Value ,
                          BankAssetClass ,
                          NpaType ,
                          SecApp ,
                          BorrowerTypeID ,
                          LineCode ,
                          ProvPerSecured ,
                          ProvPerUnSecured ,
                          B.MOCReason ,
                          AddlProvisionPer ,
                          FlgINFRA ,
                          CASE 
                               WHEN B.RePossessionDate IS NULL THEN A.RepossessionDate
                          ELSE B.RePossessionDate
                             END RepossessionDate  ,
                          DerecognisedInterest1 ,
                          DerecognisedInterest2 ,
                          ProductCode ,
                          FlgLCBG ,
                          CASE 
                               WHEN B.InterestReceivable IS NULL THEN unserviedint
                          ELSE B.InterestReceivable
                             END unserviedint  ,
                          PreQtrCredit ,
                          PrvQtrInt ,
                          CurQtrCredit ,
                          CurQtrInt ,
                          OriginalBranchcode ,
                          AdvanceRecovery ,
                          NotionalInttAmt ,
                          PrvAssetClassAlt_Key ,
                          MOCTYPE ,
                          FlgSecured ,
                          CASE 
                               WHEN B.RePossessionFlag IS NULL THEN RePossession
                          ELSE B.RePossessionFlag
                             END RePossession  ,
                          RCPending ,
                          PaymentPending ,
                          WheelCase ,
                          CustomerLevelMaxPer ,
                          FinalProvisionPer ,
                          IsIBPC ,
                          IsSecuritised ,
                          RFA ,
                          IsNonCooperative ,
                          CASE 
                               WHEN B.SARFAESIFlag IS NULL THEN Sarfaesi
                          ELSE B.SARFAESIFlag
                             END Sarfaesi  ,
                          CASE 
                               WHEN B.InherentWeaknessFlag IS NULL THEN WeakAccount
                          ELSE B.InherentWeaknessFlag
                             END WeakAccount  ,
                          PUI ,
                          CASE 
                               WHEN B.RestructureFlag IS NULL THEN FlgRestructure
                          ELSE B.RestructureFlag
                             END FlgRestructure  ,
                          CASE 
                               WHEN B.RePossessionDate IS NULL THEN A.RestructureDate
                          ELSE B.RePossessionDate
                             END RestructureDate  ,
                          CASE 
                               WHEN B.InherentWeaknessDate IS NULL THEN WeakAccountDate
                          ELSE B.InherentWeaknessDate
                             END WeakAccountDate  ,
                          CASE 
                               WHEN B.SARFAESIFlag IS NULL THEN Sarfaesi
                          ELSE B.SARFAESIFlag
                             END SarfaesiDate  ,
                          CASE 
                               WHEN B.UnusualBounceFlag IS NULL THEN FlgUnusualBounce
                          ELSE B.UnusualBounceFlag
                             END FlgUnusualBounce  ,
                          CASE 
                               WHEN B.UnusualBounceDate IS NULL THEN A.UnusualBounceDate
                          ELSE B.UnusualBounceDate
                             END UnusualBounceDate  ,
                          CASE 
                               WHEN B.UnclearedEffectsFlag IS NULL THEN FlgUnClearedEffect
                          ELSE B.UnclearedEffectsFlag
                             END FlgUnClearedEffect  ,
                          CASE 
                               WHEN B.UnclearedEffectsDate IS NULL THEN UnClearedEffectDate
                          ELSE B.UnclearedEffectsDate
                             END UnClearedEffectDate  ,
                          CASE 
                               WHEN B.FraudAccountFlag IS NULL THEN FlgFraud
                          ELSE B.FraudAccountFlag
                             END FlgFraud  ,
                          CASE 
                               WHEN B.FraudDate IS NULL THEN A.FraudDate
                          ELSE B.FraudDate
                             END FraudDate  ,
                          'U' ,
                          B.ChangeField 
                   FROM tt_ACCOUNT_CAL_2 A
                          JOIN AccountLevelMOC_Mod B   ON A.CustomerAcID = B.AccountID
                    WHERE  ( A.EffectiveToTimeKey > v_TimeKey )
                             OR ( A.EffectiveFromTimeKey < v_TimeKey
                             AND A.EffectiveToTimeKey = v_TimeKey ) );
               INSERT INTO PRO_RBL_MISDB_PROD.AccountCal_Hist
                 ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate, ScreenFlag, ChangeField )
                 ( SELECT A.AccountEntityID ,
                          UcifEntityID ,
                          CustomerEntityID ,
                          CustomerAcID ,
                          RefCustomerID ,
                          SourceSystemCustomerID ,
                          UCIF_ID ,
                          BranchCode ,
                          FacilityType ,
                          AcOpenDt ,
                          FirstDtOfDisb ,
                          ProductAlt_Key ,
                          SchemeAlt_key ,
                          SubSectorAlt_Key ,
                          SplCatg1Alt_Key ,
                          SplCatg2Alt_Key ,
                          SplCatg3Alt_Key ,
                          SplCatg4Alt_Key ,
                          SourceAlt_Key ,
                          ActSegmentCode ,
                          InttRate ,
                          Balance ,
                          BalanceInCrncy ,
                          CurrencyAlt_Key ,
                          DrawingPower ,
                          CurrentLimit ,
                          CurrentLimitDt ,
                          ContiExcessDt ,
                          StockStDt ,
                          DebitSinceDt ,
                          LastCrDate ,
                          InttServiced ,
                          IntNotServicedDt ,
                          OverdueAmt ,
                          OverDueSinceDt ,
                          ReviewDueDt ,
                          SecurityValue ,
                          DFVAmt ,
                          GovtGtyAmt ,
                          CoverGovGur ,
                          WriteOffAmount ,
                          UnAdjSubSidy ,
                          CreditsinceDt ,
                          DegReason ,
                          Asset_Norm ,
                          REFPeriodMax ,
                          RefPeriodOverdue ,
                          RefPeriodOverDrawn ,
                          RefPeriodNoCredit ,
                          RefPeriodIntService ,
                          RefPeriodStkStatement ,
                          RefPeriodReview ,
                          NetBalance ,
                          ApprRV ,
                          SecuredAmt ,
                          UnSecuredAmt ,
                          ProvDFV ,
                          Provsecured ,
                          ProvUnsecured ,
                          ProvCoverGovGur ,
                          AddlProvision ,
                          TotalProvision ,
                          BankProvsecured ,
                          BankProvUnsecured ,
                          BankTotalProvision ,
                          RBIProvsecured ,
                          RBIProvUnsecured ,
                          RBITotalProvision ,
                          InitialNpaDt ,
                          FinalNpaDt ,
                          SMA_Dt ,
                          UpgDate ,
                          InitialAssetClassAlt_Key ,
                          FinalAssetClassAlt_Key ,
                          ProvisionAlt_Key ,
                          PNPA_Reason ,
                          SMA_Class ,
                          SMA_Reason ,
                          FlgMoc ,
                          SYSDATE MOC_Dt  ,
                          CommonMocTypeAlt_Key ,
                          FlgDeg ,
                          FlgDirtyRow ,
                          FlgInMonth ,
                          FlgSMA ,
                          FlgPNPA ,
                          FlgUpg ,
                          FlgFITL ,
                          FlgAbinitio ,
                          NPA_Days ,
                          RefPeriodOverdueUPG ,
                          RefPeriodOverDrawnUPG ,
                          RefPeriodNoCreditUPG ,
                          RefPeriodIntServiceUPG ,
                          RefPeriodStkStatementUPG ,
                          RefPeriodReviewUPG ,
                          v_Timekey + 1 ,
                          A.EffectiveToTimeKey ,
                          AppGovGur ,
                          UsedRV ,
                          ComputedClaim ,
                          UPG_RELAX_MSME ,
                          DEG_RELAX_MSME ,
                          PNPA_DATE ,
                          NPA_Reason ,
                          PnpaAssetClassAlt_key ,
                          DisbAmount ,
                          PrincOutStd ,
                          PrincOverdue ,
                          PrincOverdueSinceDt ,
                          IntOverdue ,
                          IntOverdueSinceDt ,
                          OtherOverdue ,
                          OtherOverdueSinceDt ,
                          RelationshipNumber ,
                          AccountFlag ,
                          CommercialFlag_AltKey ,
                          Liability ,
                          CD ,
                          AccountStatus ,
                          AccountBlkCode1 ,
                          AccountBlkCode2 ,
                          ExposureType ,
                          Mtm_Value ,
                          BankAssetClass ,
                          NpaType ,
                          SecApp ,
                          BorrowerTypeID ,
                          LineCode ,
                          ProvPerSecured ,
                          ProvPerUnSecured ,
                          B.MOCReason MOCReason  ,
                          AddlProvisionPer ,
                          FlgINFRA ,
                          A.RepossessionDate ,
                          DerecognisedInterest1 ,
                          DerecognisedInterest2 ,
                          ProductCode ,
                          FlgLCBG ,
                          unserviedint ,
                          PreQtrCredit ,
                          PrvQtrInt ,
                          CurQtrCredit ,
                          CurQtrInt ,
                          OriginalBranchcode ,
                          AdvanceRecovery ,
                          NotionalInttAmt ,
                          PrvAssetClassAlt_Key ,
                          MOCTYPE ,
                          FlgSecured ,
                          RePossession ,
                          RCPending ,
                          PaymentPending ,
                          WheelCase ,
                          CustomerLevelMaxPer ,
                          FinalProvisionPer ,
                          IsIBPC ,
                          IsSecuritised ,
                          RFA ,
                          IsNonCooperative ,
                          Sarfaesi ,
                          WeakAccount ,
                          PUI ,
                          FlgRestructure ,
                          A.RestructureDate ,
                          WeakAccountDate ,
                          A.SarfaesiDate ,
                          FlgUnusualBounce ,
                          A.UnusualBounceDate ,
                          FlgUnClearedEffect ,
                          UnClearedEffectDate ,
                          FlgFraud ,
                          A.FraudDate ,
                          'U' ,
                          B.ChangeField 
                   FROM tt_ACCOUNT_CAL_2 A
                          JOIN AccountLevelMOC_Mod B   ON A.CustomerAcID = B.AccountID
                    WHERE  A.EffectiveToTimeKey > v_TimeKey );
               ---pre moc
               INSERT INTO PreMoc_RBL_MISDB_PROD.ACCOUNTCAL
                 ( AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, UnserviedInt
               --,ENTITYKEY
               , OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgRestructure, RestructureDate, WeakAccountDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FlgFraud, FraudDate, ScreenFlag )
                 ( SELECT A.AccountEntityID ,
                          A.UcifEntityID ,
                          A.CustomerEntityID ,
                          A.CustomerAcID ,
                          A.RefCustomerID ,
                          A.SourceSystemCustomerID ,
                          A.UCIF_ID ,
                          A.BranchCode ,
                          A.FacilityType ,
                          A.AcOpenDt ,
                          A.FirstDtOfDisb ,
                          A.ProductAlt_Key ,
                          A.SchemeAlt_key ,
                          A.SubSectorAlt_Key ,
                          A.SplCatg1Alt_Key ,
                          A.SplCatg2Alt_Key ,
                          A.SplCatg3Alt_Key ,
                          A.SplCatg4Alt_Key ,
                          A.SourceAlt_Key ,
                          A.ActSegmentCode ,
                          A.InttRate ,
                          A.Balance ,
                          A.BalanceInCrncy ,
                          A.CurrencyAlt_Key ,
                          A.DrawingPower ,
                          A.CurrentLimit ,
                          A.CurrentLimitDt ,
                          A.ContiExcessDt ,
                          A.StockStDt ,
                          A.DebitSinceDt ,
                          A.LastCrDate ,
                          A.PreQtrCredit ,
                          A.PrvQtrInt ,
                          A.CurQtrCredit ,
                          A.CurQtrInt ,
                          A.InttServiced ,
                          A.IntNotServicedDt ,
                          A.OverdueAmt ,
                          A.OverDueSinceDt ,
                          A.ReviewDueDt ,
                          A.SecurityValue ,
                          A.DFVAmt ,
                          A.GovtGtyAmt ,
                          A.CoverGovGur ,
                          A.WriteOffAmount ,
                          A.UnAdjSubSidy ,
                          A.CreditsinceDt ,
                          A.DegReason ,
                          A.Asset_Norm ,
                          A.REFPeriodMax ,
                          A.RefPeriodOverdue ,
                          A.RefPeriodOverDrawn ,
                          A.RefPeriodNoCredit ,
                          A.RefPeriodIntService ,
                          A.RefPeriodStkStatement ,
                          A.RefPeriodReview ,
                          A.NetBalance ,
                          A.ApprRV ,
                          A.SecuredAmt ,
                          A.UnSecuredAmt ,
                          A.ProvDFV ,
                          A.Provsecured ,
                          A.ProvUnsecured ,
                          A.ProvCoverGovGur ,
                          A.AddlProvision ,
                          A.TotalProvision ,
                          A.BankProvsecured ,
                          A.BankProvUnsecured ,
                          A.BankTotalProvision ,
                          A.RBIProvsecured ,
                          A.RBIProvUnsecured ,
                          A.RBITotalProvision ,
                          A.InitialNpaDt ,
                          A.FinalNpaDt ,
                          A.SMA_Dt ,
                          A.UpgDate ,
                          A.InitialAssetClassAlt_Key ,
                          A.FinalAssetClassAlt_Key ,
                          A.ProvisionAlt_Key ,
                          A.PNPA_Reason ,
                          A.SMA_Class ,
                          A.SMA_Reason ,
                          'Y' FlgMoc  ,
                          A.MOC_Dt ,
                          A.CommonMocTypeAlt_Key ,
                          A.FlgDeg ,
                          A.FlgDirtyRow ,
                          A.FlgInMonth ,
                          A.FlgSMA ,
                          A.FlgPNPA ,
                          A.FlgUpg ,
                          A.FlgFITL ,
                          A.FlgAbinitio ,
                          A.NPA_Days ,
                          A.RefPeriodOverdueUPG ,
                          A.RefPeriodOverDrawnUPG ,
                          A.RefPeriodNoCreditUPG ,
                          A.RefPeriodIntServiceUPG ,
                          A.RefPeriodStkStatementUPG ,
                          A.RefPeriodReviewUPG ,
                          v_TimeKey ,
                          v_TimeKey ,
                          A.AppGovGur ,
                          A.UsedRV ,
                          A.ComputedClaim ,
                          A.UPG_RELAX_MSME ,
                          A.DEG_RELAX_MSME ,
                          A.PNPA_DATE ,
                          A.NPA_Reason ,
                          A.PnpaAssetClassAlt_key ,
                          A.DisbAmount ,
                          A.PrincOutStd ,
                          A.PrincOverdue ,
                          A.PrincOverdueSinceDt ,
                          A.IntOverdue ,
                          A.IntOverdueSinceDt ,
                          A.OtherOverdue ,
                          A.OtherOverdueSinceDt ,
                          A.RelationshipNumber ,
                          A.AccountFlag ,
                          A.CommercialFlag_AltKey ,
                          A.Liability ,
                          A.CD ,
                          A.AccountStatus ,
                          A.AccountBlkCode1 ,
                          A.AccountBlkCode2 ,
                          A.ExposureType ,
                          A.Mtm_Value ,
                          A.BankAssetClass ,
                          A.NpaType ,
                          A.SecApp ,
                          A.BorrowerTypeID ,
                          A.LineCode ,
                          A.ProvPerSecured ,
                          A.ProvPerUnSecured ,
                          A.MOCReason ,
                          A.AddlProvisionPer ,
                          A.FlgINFRA ,
                          A.RepossessionDate ,
                          A.DerecognisedInterest1 ,
                          A.DerecognisedInterest2 ,
                          A.ProductCode ,
                          A.FlgLCBG ,
                          A.UnserviedInt ,
                          --,ENTITYKEY
                          A.OriginalBranchcode ,
                          A.AdvanceRecovery ,
                          A.NotionalInttAmt ,
                          A.PrvAssetClassAlt_Key ,
                          A.MOCTYPE ,
                          A.FlgSecured ,
                          A.RePossession ,
                          A.RCPending ,
                          A.PaymentPending ,
                          A.WheelCase ,
                          A.CustomerLevelMaxPer ,
                          A.FinalProvisionPer ,
                          A.IsIBPC ,
                          A.IsSecuritised ,
                          A.RFA ,
                          A.IsNonCooperative ,
                          A.Sarfaesi ,
                          A.WeakAccount ,
                          A.PUI ,
                          A.FlgRestructure ,
                          A.RestructureDate ,
                          A.WeakAccountDate ,
                          A.SarfaesiDate ,
                          A.FlgUnusualBounce ,
                          A.UnusualBounceDate ,
                          A.FlgUnClearedEffect ,
                          A.UnClearedEffectDate ,
                          A.FlgFraud ,
                          A.FraudDate ,
                          'U' 
                   FROM tt_ACCOUNT_CAL_2 A
                          JOIN AccountLevelMOC_Mod C   ON A.CustomerAcID = C.AccountID
                          LEFT JOIN PreMoc_RBL_MISDB_PROD.ACCOUNTCAL B   ON ( B.EffectiveFromTimeKey = v_TimeKey
                          AND B.EffectiveToTimeKey = v_TimeKey )
                          AND A.CustomerACID = B.CustomerAcID
                    WHERE  B.CustomerAcID IS NULL );
               UPDATE ExcelUploadHistory
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey
                 AND UniqueUploadID = v_UniqueUploadID
                 AND UploadType = 'Account MOC Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN

             ----REJECT
            BEGIN
               UPDATE AccountLevelMOC_Mod
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
                 AND UploadType = 'Account MOC Upload';

            END;
            END IF;
            IF ( v_OperationFlag = 21 ) THEN

             ----REJECT
            BEGIN
               UPDATE AccountLevelMOC_Mod
                  SET AuthorisationStatus = 'R',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
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
                 AND UploadType = 'Account MOC Upload';

            END;
            END IF;

         END;
         END IF;
         --COMMIT TRAN
         ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END
         v_Result := CASE 
                          WHEN v_OperationFlag = 1
                            AND v_MenuId = 24715 THEN v_ExcelUploadId
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACNPAMOCSTAGEDATAINUP_BACKUP_12122021" TO "ADF_CDR_RBL_STGDB";
