--------------------------------------------------------
--  DDL for Function FRAUD_STAGEDATAINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" 
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
   --   ROLLBACK TRAN
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

   /*TODO:SQLDEV*/ SET XACT_ABORT ON /*END:SQLDEV*/
   --SET DATEFORMAT DMY;
   --	SET NOCOUNT ON;
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
   --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   --SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
   --DECLARE @MOC_Date Date
   --SET @MOC_Date=(select cast(ExtDate as date) from SysDataMatrix where TimeKey=@Timekey )
   DBMS_OUTPUT.PUT_LINE(v_TIMEKEY);
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
   DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
   DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
   BEGIN

      BEGIN
         --BEGIN TRAN
         IF ( v_MenuId = 27773 ) THEN

         BEGIN
            IF ( v_OperationFlag = 1 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT 1 
                                        FROM NPAFraudAccountUpload_stg 
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
               DBMS_OUTPUT.PUT_LINE('Prashant');
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT * 
                                  FROM NPAFraudAccountUpload_stg 
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
                             'Fraud Upload' ,
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
                    VALUES ( v_filepath, v_UserLoginID, TO_DATE(SYSDATE,'dd/mm/yyyy'), 'Fraud Upload' );
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                  FROM A ,Fraud_Details_Mod A
                         JOIN NPAFraudAccountUpload_stg B   ON A.RefCustomerACID = B.AccountNumber
                         AND A.EffectiveFromTimeKey <= v_Timekey
                         AND A.EffectiveToTimeKey >= v_Timekey 
                   WHERE A.EffectiveToTimeKey >= v_Timekey
                    AND A.AuthorisationStatus = 'A') src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                  /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                  INSERT INTO Fraud_Details_Mod
                    ( SrNo, UploadID, RefCustomerACID, RFA_ReportingByBank, RFA_DateReportingByBank, RFA_OtherBankAltKey, RFA_OtherBankDate, FraudOccuranceDate, FraudDeclarationDate, FraudNature, FraudArea, NPA_DateAtFraud, AssetClassAtFraudAltKey, ProvPref, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, screenFlag, AccountEntityId, CustomerEntityId, RefCustomerID )
                    ( SELECT SrNo ,
                             v_ExcelUploadId ,
                             AccountNumber ,
                             D.ParameterAlt_Key ,
                             DateofRFAreportingbyBank ,
                             E.ParameterAlt_Key ,
                             CASE 
                                  WHEN DateofreportingRFAbyOtherBank IN ( ' ','1900-01-01' )
                                   THEN NULL
                             ELSE DateofreportingRFAbyOtherBank
                                END col  ,
                             CASE 
                                  WHEN DateofFraudoccurrence IN ( ' ','1900-01-01' )
                                   THEN NULL
                             ELSE DateofFraudoccurrence
                                END col  ,
                             DateofFrauddeclarationbyRBL ,
                             NatureofFraud ,
                             AreasofOperations ,
                             NPADt ,
                             Cust_AssetClassAlt_Key ,
                             F.ParameterAlt_Key ,
                             'NP' ,
                             v_Timekey ,
                             49999 ,
                             v_UserLoginID ,
                             SYSDATE ,
                             'U' ,
                             c.AccountEntityId ,
                             c.CustomerEntityId ,
                             c.RefCustomerId 
                      FROM NPAFraudAccountUpload_stg A
                             JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail C   ON A.AccountNumber = C.CustomerACID
                             AND C.EffectiveFromTimeKey <= v_Timekey
                             AND C.EffectiveToTimeKey >= v_Timekey
                             LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail B   ON C.CustomerEntityId = B.CustomerEntityId
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_Timekey
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                CASE 
                                                     WHEN ParameterName = 'NO' THEN 'N'
                                                ELSE 'Y'
                                                   END ParameterName  ,
                                                'RFA_Reported_By_Bank' Tablename  
                      FROM DimParameter 
                     WHERE  DimParameterName = 'DimYesNo'
                              AND EffectiveFromTimeKey <= v_TimeKey
                              AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.RFAreportedbyBank = D.ParameterName
                             LEFT JOIN ( SELECT BankRPAlt_Key ParameterAlt_Key  ,
                                                BankName ParameterName  ,
                                                'Name_of_Other_Banks_Reporting_RFA' Tablename  
                                         FROM DimBankRP 
                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.NameofotherBankreportingRFA = E.ParameterName
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'Provision_Proference' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimProvisionPreference'
                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey ) F   ON A.Provisionpreference = F.ParameterName
                       WHERE  filname = v_FilePathUpload );
                  ---------------------------------------------------------ChangeField Logic---------------------
                  ----select * from AccountLvlMOCDetails_stg
                  IF utils.object_id('TempDB..tt_FraudUpload') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FraudUpload ';
                  END IF;
                  DELETE FROM tt_FraudUpload;
                  INSERT INTO tt_FraudUpload
                    ( AccountNumber, FieldName )
                    ( SELECT AccountNumber ,
                             'RFAreportedbyBank' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(RFAreportedbyBank, ' ') <> ' '
                      UNION 
                      SELECT AccountNumber ,
                             'DateofRFAreportingbyBank' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(DateofRFAreportingbyBank, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'NameofotherBankreportingRFA ' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(NameofotherBankreportingRFA, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'DateofreportingRFAbyOtherBank' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(DateofreportingRFAbyOtherBank, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'DateofFraudoccurrence' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(DateofFraudoccurrence, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'DateofFrauddeclarationbyRBL' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(DateofFrauddeclarationbyRBL, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'NatureofFraud' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(NatureofFraud, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'AreasofOperations' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(AreasofOperations, ' ') <> ' '
                      UNION ALL 
                      SELECT AccountNumber ,
                             'Provisionpreference' FieldName  
                      FROM NPAFraudAccountUpload_stg 
                       WHERE  NVL(Provisionpreference, ' ') <> ' ' );
                  --select *
                  MERGE INTO B 
                  USING (SELECT B.ROWID row_id, A.ScreenFieldNo
                  FROM B ,MetaScreenFieldDetail A
                         JOIN tt_FraudUpload B   ON A.CtrlName = B.FieldName 
                   WHERE A.MenuId = v_Menuid
                    AND A.IsVisible = 'Y') src
                  ON ( B.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET B.SrNo = src.ScreenFieldNo;
                  IF utils.object_id('TEMPDB..tt_NEWTRANCHE_72') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_NEWTRANCHE_72 ';
                  END IF;
                  DELETE FROM tt_NEWTRANCHE_72;
                  UTILS.IDENTITY_RESET('tt_NEWTRANCHE_72');

                  INSERT INTO tt_NEWTRANCHE_72 SELECT * 
                       FROM ( SELECT ss.AccountNumber ,
                                     utils.stuff(( SELECT ',' || US.SrNo 
                                                   FROM tt_FraudUpload US
                                                    WHERE  US.AccountNumber = ss.AccountNumber ), 1, 1, ' ') REPORTIDSLIST  
                              FROM NPAFraudAccountUpload_stg SS
                                GROUP BY ss.AccountNumber ) B
                       ORDER BY 1;
                  --Select * from tt_NEWTRANCHE_72
                  --SELECT * 
                  MERGE INTO A 
                  USING (SELECT A.ROWID row_id, B.REPORTIDSLIST
                  FROM A ,RBL_MISDB_PROD.Fraud_Details_Mod A
                         JOIN tt_NEWTRANCHE_72 B   ON A.RefCustomerACID = B.AccountNumber 
                   WHERE A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimeKey >= v_TimeKey
                    AND A.UploadID = v_ExcelUploadId) src
                  ON ( A.ROWID = src.row_id )
                  WHEN MATCHED THEN UPDATE SET A.FraudAccounts_ChangeFields = src.REPORTIDSLIST;
                  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
                  ---DELETE FROM STAGING DATA
                  DELETE NPAFraudAccountUpload_stg

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
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----AUTHORIZE
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                             FROM Fraud_Details_Mod 
                                              WHERE  CreatedBy = v_UserLoginID
                                                       AND UploadId = v_UniqueUploadID
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
                  RETURN v_Result;
                  ROLLBACK;
                  utils.resetTrancount;

               END;
               ELSE

               BEGIN
                  UPDATE Fraud_Details_Mod
                     SET AuthorisationStatus = '1A',
                         FirstLevelApprovedBy = v_UserLoginID,
                         FirstLevelDateApproved = SYSDATE
                   WHERE  UploadId = v_UniqueUploadID
                    AND EffectiveToTimeKey = 49999
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = '1A',
                         ApprovedByFirstLevel = v_UserLoginID,
                         DateApprovedFirstLevel = SYSDATE
                   WHERE  UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Fraud Upload';

               END;
               END IF;

            END;
            END IF;
            --------------------------------------------
            IF ( v_OperationFlag = 20 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----AUTHORIZE
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE v_UserLoginID = ( SELECT UserLoginID 
                                           FROM DimUserInfo 
                                            WHERE  IsChecker2 = 'N'
                                                     AND UserLoginID = v_UserLoginID
                                                     AND EffectiveToTimeKey = 49999 );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  v_Result := -1 ;
                  RETURN v_Result;
                  ROLLBACK;
                  utils.resetTrancount;

               END;
               ELSE
               DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                                FROM Fraud_Details_Mod 
                                                 WHERE  AuthorisationStatus IN ( '1A' )

                                                          AND UploadId = v_UniqueUploadID
                                                          AND EffectiveToTimeKey = 49999
                                                          AND CreatedBy = v_UserLoginID

                                                --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     RETURN v_Result;
                     ROLLBACK;
                     utils.resetTrancount;

                  END;

                  --select * from AccountFlaggingDetails_Mod
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE ( v_UserLoginID = ( SELECT ApprovedBy 
                                                   FROM Fraud_Details_Mod 
                                                    WHERE  AuthorisationStatus IN ( '1A' )

                                                             AND UploadId = v_UniqueUploadID
                                                             AND EffectiveToTimeKey = 49999
                                                             AND ApprovedBy = v_UserLoginID

                                                   --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                   GROUP BY ApprovedBy ) );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        v_Result := -1 ;
                        RETURN v_Result;
                        ROLLBACK;
                        utils.resetTrancount;

                     END;

                     --select * from AccountFlaggingDetails_Mod
                     ELSE

                     BEGIN
                        UPDATE Fraud_Details_Mod
                           SET AuthorisationStatus = 'A',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE
                         WHERE  UploadId = v_UniqueUploadID;
                        MERGE INTO A 
                        USING (SELECT A.ROWID row_id, v_Timekey - 1 AS EffectiveToTimeKey
                        FROM A ,Fraud_Details A
                               JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityId = B.AccountEntityId
                               AND A.EffectiveFromTimeKey <= v_Timekey
                               AND A.EffectiveToTimeKey >= v_Timekey
                               AND B.EffectiveFromTimeKey <= v_Timekey
                               AND B.EffectiveToTimeKey >= v_Timekey
                               JOIN Fraud_Details_Mod C   ON B.AccountEntityId = C.AccountEntityId
                               AND C.EffectiveFromTimeKey <= v_Timekey
                               AND C.EffectiveToTimeKey >= v_Timekey
                               AND C.AuthorisationStatus = 'A'
                               AND C.UploadID = v_UniqueUploadID 
                         WHERE A.EffectiveToTimeKey >= v_Timekey
                          AND A.AuthorisationStatus = 'A'
                          AND A.UploadID = v_UniqueUploadID) src
                        ON ( A.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
                        INSERT INTO Fraud_Details
                          ( SrNo, UploadID, AccountEntityId, CustomerEntityId, RefCustomerACID, RefCustomerID, RFA_ReportingByBank, RFA_DateReportingByBank, RFA_OtherBankAltKey, RFA_OtherBankDate, FraudOccuranceDate, FraudDeclarationDate, FraudNature, FraudArea, CurrentAssetClassAltKey, ProvPref, NPA_DateAtFraud, AssetClassAtFraudAltKey, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, FirstLevelApprovedBy, FirstLevelDateApproved, screenFlag )
                          ( SELECT SrNo ,
                                   UploadID ,
                                   B.AccountEntityId ,
                                   B.CustomerEntityId ,
                                   RefCustomerACID ,
                                   B.RefCustomerID ,
                                   RFA_ReportingByBank ,
                                   RFA_DateReportingByBank ,
                                   RFA_OtherBankAltKey ,
                                   CASE 
                                        WHEN RFA_OtherBankDate IN ( ' ','1900-01-01' )
                                         THEN NULL
                                   ELSE RFA_OtherBankDate
                                      END col  ,
                                   CASE 
                                        WHEN FraudOccuranceDate IN ( ' ','1900-01-01' )
                                         THEN NULL
                                   ELSE FraudOccuranceDate
                                      END col  ,
                                   FraudDeclarationDate ,
                                   FraudNature ,
                                   FraudArea ,
                                   CurrentAssetClassAltKey ,
                                   ProvPref ,
                                   NPA_DateAtFraud ,
                                   AssetClassAtFraudAltKey ,
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   FirstLevelApprovedBy ,
                                   FirstLevelDateApproved ,
                                   screenFlag 
                            FROM Fraud_Details_Mod A
                                   JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityId = B.AccountEntityId
                                   AND B.EffectiveFromTimeKey <= v_Timekey
                                   AND B.EffectiveToTimeKey >= v_Timekey
                             WHERE  A.UploadID = v_UniqueUploadID
                                      AND A.EffectiveFromTimeKey <= v_Timekey
                                      AND A.EffectiveToTimeKey >= v_Timekey
                                      AND A.AuthorisationStatus = 'A' );
                        DBMS_OUTPUT.PUT_LINE('BBBB');
                        MERGE INTO Fraud_Details a
                        USING (SELECT a.ROWID row_id, (CASE 
                        WHEN B.AccountEntityId IS NULL THEN a.AccountEntityId
                        ELSE B.AccountEntityId
                           END) AS pos_2, (CASE 
                        WHEN B.CustomerEntityId IS NULL THEN a.CustomerEntityId
                        ELSE B.CustomerEntityId
                           END) AS pos_3, (CASE 
                        WHEN B.RefCustomerACID IS NULL THEN a.RefCustomerACID
                        ELSE B.RefCustomerACID
                           END) AS pos_4, (CASE 
                        WHEN B.RefCustomerID IS NULL THEN a.RefCustomerID
                        ELSE B.RefCustomerID
                           END) AS pos_5, (CASE 
                        WHEN B.RFA_ReportingByBank IS NULL THEN a.RFA_ReportingByBank
                        ELSE B.RFA_ReportingByBank
                           END) AS pos_6, (CASE 
                        WHEN B.RFA_DateReportingByBank IS NULL THEN a.RFA_DateReportingByBank
                        ELSE B.RFA_DateReportingByBank
                           END) AS pos_7, (CASE 
                        WHEN B.RFA_OtherBankAltKey IS NULL THEN a.RFA_OtherBankAltKey
                        ELSE B.RFA_OtherBankAltKey
                           END) AS pos_8, (CASE 
                        WHEN B.RFA_OtherBankDate IS NULL THEN a.RFA_OtherBankDate
                        ELSE B.RFA_OtherBankDate
                           END) AS pos_9, (CASE 
                        WHEN B.FraudOccuranceDate IS NULL THEN a.FraudOccuranceDate
                        ELSE B.FraudOccuranceDate
                           END) AS pos_10, (CASE 
                        WHEN B.FraudDeclarationDate IS NULL THEN a.FraudDeclarationDate
                        ELSE B.FraudDeclarationDate
                           END) AS pos_11, (CASE 
                        WHEN B.FraudNature IS NULL THEN a.FraudNature
                        ELSE B.FraudNature
                           END) AS pos_12, (CASE 
                        WHEN B.FraudArea IS NULL THEN a.FraudArea
                        ELSE B.FraudArea
                           END) AS pos_13, (CASE 
                        WHEN B.CurrentAssetClassAltKey IS NULL THEN a.CurrentAssetClassAltKey
                        ELSE B.CurrentAssetClassAltKey
                           END) AS pos_14, (CASE 
                        WHEN B.ProvPref IS NULL THEN a.ProvPref
                        ELSE B.ProvPref
                           END) AS pos_15, (CASE 
                        WHEN B.NPA_DateAtFraud IS NULL THEN a.NPA_DateAtFraud
                        ELSE B.NPA_DateAtFraud
                           END) AS pos_16, (CASE 
                        WHEN B.AssetClassAtFraudAltKey IS NULL THEN a.AssetClassAtFraudAltKey
                        ELSE B.AssetClassAtFraudAltKey
                           END) AS pos_17, (CASE 
                        WHEN B.AuthorisationStatus IS NULL THEN a.AuthorisationStatus
                        ELSE B.AuthorisationStatus
                           END) AS pos_18, (CASE 
                        WHEN B.ModifiedBy IS NULL THEN a.ModifiedBy
                        ELSE B.ModifiedBy
                           END) AS pos_19, (CASE 
                        WHEN B.DateModified IS NULL THEN a.DateModified
                        ELSE B.DateModified
                           END) AS pos_20, (CASE 
                        WHEN B.ApprovedBy IS NULL THEN a.ApprovedBy
                        ELSE B.ApprovedBy
                           END) AS pos_21, (CASE 
                        WHEN B.DateApproved IS NULL THEN a.DateApproved
                        ELSE B.DateApproved
                           END) AS pos_22, 'U'
                        FROM Fraud_Details a
                               JOIN Fraud_Details_Mod b   ON a.RefCustomerACID = b.RefCustomerACID
                               AND a.EffectiveFromTimeKey <= v_TimeKey
                               AND a.EffectiveToTimeKey >= v_TimeKey 
                         WHERE b.EffectiveFromTimeKey <= v_TimeKey
                          AND b.EffectiveToTimeKey >= v_TimeKey
                          AND b.RefCustomerACID = b.RefCustomerACID) src
                        ON ( a.ROWID = src.row_id )
                        WHEN MATCHED THEN UPDATE SET b.AccountEntityId = pos_2,
                                                     b.CustomerEntityId = pos_3,
                                                     b.RefCustomerACID = pos_4,
                                                     b.RefCustomerID = pos_5,
                                                     b.RFA_ReportingByBank = pos_6,
                                                     b.RFA_DateReportingByBank = pos_7,
                                                     b.RFA_OtherBankAltKey = pos_8,
                                                     b.RFA_OtherBankDate = pos_9,
                                                     b.FraudOccuranceDate = pos_10,
                                                     b.FraudDeclarationDate = pos_11,
                                                     b.FraudNature = pos_12,
                                                     b.FraudArea = pos_13,
                                                     b.CurrentAssetClassAltKey = pos_14,
                                                     b.ProvPref = pos_15,
                                                     b.NPA_DateAtFraud = pos_16,
                                                     b.AssetClassAtFraudAltKey = pos_17,
                                                     b.AuthorisationStatus = pos_18,
                                                     b.ModifiedBy = pos_19,
                                                     b.DateModified = pos_20,
                                                     b.ApprovedBy = pos_21,
                                                     b.DateApproved = pos_22,
                                                     b.screenFlag = 'U';
                        UPDATE ExcelUploadHistory
                           SET AuthorisationStatus = 'A',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE
                         WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey
                          AND UniqueUploadID = v_UniqueUploadID
                          AND UploadType = 'Fraud Upload';

                     END;
                     END IF;

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----REJECT
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                             FROM Fraud_Details_Mod 
                                              WHERE  CreatedBy = v_UserLoginID
                                                       AND UploadId = v_UniqueUploadID
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
                  RETURN v_Result;
                  ROLLBACK;
                  utils.resetTrancount;

               END;
               ELSE

               BEGIN
                  UPDATE Fraud_Details_Mod
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE,
                         EffectiveToTimeKey = v_Timekey - 1
                   WHERE  UploadId = v_UniqueUploadID
                    AND AuthorisationStatus = 'NP';
                  UPDATE ExcelUploadHistory
                     SET AuthorisationStatus = 'R',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE,
                         EffectiveToTimeKey = v_Timekey - 1
                   WHERE  EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey
                    AND UniqueUploadID = v_UniqueUploadID
                    AND UploadType = 'Fraud Upload';

               END;
               END IF;

            END;
            END IF;
            IF ( v_OperationFlag = 21 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

             ----REJECT
            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE v_UserLoginID = ( SELECT UserLoginID 
                                           FROM DimUserInfo 
                                            WHERE  IsChecker2 = 'N'
                                                     AND UserLoginID = v_UserLoginID
                                                     AND EffectiveToTimeKey = 49999 );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  v_Result := -1 ;
                  RETURN v_Result;
                  ROLLBACK;
                  utils.resetTrancount;

               END;
               ELSE
               DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE ( v_UserLoginID = ( SELECT CreatedBy 
                                                FROM Fraud_Details_Mod 
                                                 WHERE  AuthorisationStatus IN ( '1A' )

                                                          AND UploadId = v_UniqueUploadID
                                                          AND EffectiveToTimeKey = 49999
                                                          AND CreatedBy = v_UserLoginID

                                                --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                GROUP BY CreatedBy ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     v_Result := -1 ;
                     RETURN v_Result;
                     ROLLBACK;
                     utils.resetTrancount;

                  END;

                  --select * from AccountFlaggingDetails_Mod
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE ( v_UserLoginID = ( SELECT ApprovedBy 
                                                   FROM Fraud_Details_Mod 
                                                    WHERE  AuthorisationStatus IN ( '1A' )

                                                             AND UploadId = v_UniqueUploadID
                                                             AND EffectiveToTimeKey = 49999
                                                             AND ApprovedBy = v_UserLoginID

                                                   --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker2='N')
                                                   GROUP BY ApprovedBy ) );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        v_Result := -1 ;
                        RETURN v_Result;
                        ROLLBACK;
                        utils.resetTrancount;

                     END;

                     --select * from AccountFlaggingDetails_Mod
                     ELSE

                     BEGIN
                        UPDATE Fraud_Details_Mod
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE,
                               EffectiveToTimeKey = v_Timekey - 1
                         WHERE  UploadId = v_UniqueUploadID
                          AND AuthorisationStatus IN ( 'NP','1A' )
                        ;
                        UPDATE ExcelUploadHistory
                           SET AuthorisationStatus = 'R',
                               ApprovedBy = v_UserLoginID,
                               DateApproved = SYSDATE,
                               EffectiveToTimeKey = v_Timekey - 1
                         WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey
                          AND UniqueUploadID = v_UniqueUploadID
                          AND UploadType = 'Fraud Upload';

                     END;
                     END IF;

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;

         END;
         END IF;
         IF v_OperationFlag IN ( 1,2,3,16,17,18,20,21 )

           AND v_AuthMode = 'Y' THEN
          DECLARE
            v_DateCreated DATE;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('log table');
            v_DateCreated := SYSDATE ;
            --declare @ReferenceID1 varchar(max)
            --set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @UniqueUploadID else @ExcelUploadId end)
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
                            AND v_MenuId = 27773 THEN v_ExcelUploadId
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_STAGEDATAINUP" TO "ADF_CDR_RBL_STGDB";
