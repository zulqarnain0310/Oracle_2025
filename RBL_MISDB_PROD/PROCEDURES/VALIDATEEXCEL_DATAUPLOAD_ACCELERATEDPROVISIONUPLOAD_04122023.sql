--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'IBPCUPLOAD.xlsx' 
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;

BEGIN

   --fnasuperadmin_IBPCUPLOAD.xlsx
   --DECLARE  
   --@MenuID INT=1458,  
   --@UserLoginId varchar(20)='FNASUPERADMIN',  
   --@Timekey int=49999
   --,@filepath varchar(500)='fnasuperadmin_IBPCUPLOAD.xlsx'  

   BEGIN
      BEGIN
         DECLARE
            v_FilePathUpload VARCHAR2(100);
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            --BEGIN TRAN  
            --Declare @TimeKey int  
            --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
            --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
            -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
            --Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)
            --SET @Timekey= 26388
            SELECT Timekey 

              INTO v_Timekey
              FROM SysDataMatrix 
             WHERE  MOC_Initialised = 'Y'
                      AND NVL(MOC_Frozen, 'N') = 'N';
            DBMS_OUTPUT.PUT_LINE(v_Timekey);
            v_FilePathUpload := v_UserLoginId || '_' || v_filepath ;
            DBMS_OUTPUT.PUT_LINE('@FilePathUpload');
            DBMS_OUTPUT.PUT_LINE(v_FilePathUpload);
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM RBL_MISDB_PROD.MasterUploadData 
                                WHERE  FileNames = v_filepath );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE RBL_MISDB_PROD.MasterUploadData

                WHERE  FileNames = v_filepath;
               DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);

            END;
            END IF;
            IF ( v_MenuID = 24745 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;
               v_DuplicateCnt NUMBER(10,0) := 0;
               v_AcceleratedProvisionCnt NUMBER(10,0) := 0;
               v_PoolType NUMBER(10,0) := 0;
               ----------------------------------------------
               v_DateCount NUMBER(10,0) := 0;
               ----------------------------------------------
               /*validations on Related UCIC / Customer ID / Account ID*/
               v_Count NUMBER(10,0);
               v_I NUMBER(10,0);
               v_Entity_Key NUMBER(10,0);
               v_TaggingLevel VARCHAR2(100) := ' ';
               v_RelatedUCICCustomerIDAccountID VARCHAR2(100) := ' ';
               v_AccountId VARCHAR2(100) := ' ';
               v_CustomerID VARCHAR2(100) := ' ';
               v_UCIC VARCHAR2(100) := ' ';
               v_AccountId1 VARCHAR2(100) := ' ';
               v_CustomerID1 VARCHAR2(100) := ' ';
               v_UCIC1 VARCHAR2(100) := ' ';
               v_SecuredUnsecuredCnt NUMBER(10,0) := 0;
               v_NumValue NUMBER(10,0) := 0;
               v_BusinessSegmentCnt NUMBER(10,0) := 0;
               v_ValidCnt NUMBER(10,0) := 0;
               v_AssetClassificationCnt NUMBER(10,0) := 0;
               v_ValidCountAccount NUMBER(10,0) := 0;
               v_ValidCountCustomer NUMBER(10,0) := 0;
               v_ValidCountUCIC NUMBER(10,0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SACHIN');
               --Update A
               --SET A.BusinessSegment=CASE WHEN C.AcBuSegmentCode IS NOT NULL Then C.AcBuSegmentCode ELSE A.BusinessSegment END
               --From AccountLevelApproachUpload_stg A 
               --Left JOIN (
               --Select  AcBuSegmentCode,AcBuRevisedSegmentCode,'SegmentMaster' as TableName 
               --from DimAcBuSegment A where	 A.EffectiveFromTimeKey<=@TimeKey
               --AND A.EffectiveToTimeKey >=@TimeKey) 
               --C ON A.BusinessSegment=C.AcBuRevisedSegmentCode
               --Where filname=@FilePathUpload
               DBMS_OUTPUT.PUT_LINE('SACHIN12');
               -- IF OBJECT_ID('tempdb..UploadAcceleratedProvision') IS NOT NULL  
               IF utils.object_id('UploadAcceleratedProvision') IS NOT NULL THEN

               BEGIN
                  EXECUTE IMMEDIATE 'DROP TABLE UploadAcceleratedProvision';

               END;
               END IF;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE NOT ( EXISTS ( SELECT * 
                                        FROM AccountLevelApproachUpload_stg 
                                         WHERE  filname = v_FilePathUpload ) );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('NO DATA');
                  INSERT INTO RBL_MISDB_PROD.MasterUploadData
                    ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Flag )
                    ( SELECT 0 SRNO  ,
                             ' ' ColumnName  ,
                             'No Record found' ErrorData  ,
                             'No Record found' ErrorType  ,
                             v_filepath ,
                             'SUCCESS' 
                        FROM DUAL  );
                  --SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
                  GOTO errordata;

               END;
               ELSE
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE NOT ( EXISTS ( SELECT Timekey 
                                           FROM SysDataMatrix 
                                            WHERE  MOC_Initialised = 'Y'
                                                     AND NVL(MOC_Frozen, 'N') = 'N' ) );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('NO DATA');
                     INSERT INTO RBL_MISDB_PROD.MasterUploadData
                       ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Flag )
                       ( SELECT 0 SRNO  ,
                                ' ' ColumnName  ,
                                'There is no MOC Intiliazation Month' ErrorData  ,
                                'There is no MOC Intiliazation Month' ErrorType  ,
                                v_filepath ,
                                'SUCCESS' 
                           FROM DUAL  );
                     --SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
                     GOTO errordata;

                  END;
                  ELSE

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('DATA PRESENT');
                     DELETE FROM UploadAcceleratedProvision;
                     UTILS.IDENTITY_RESET('UploadAcceleratedProvision');

                     INSERT INTO UploadAcceleratedProvision SELECT * ,
                                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                          FROM AccountLevelApproachUpload_stg 
                         WHERE  filname = v_FilePathUpload;

                  END;
                  END IF;
               END IF;
               ------------------------------------------------------------------------------  
               --SrNo	Territory	ACID	InterestReversalAmount	filname
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                      ErrorinColumn = 'SrNo,Accelerated Provision Duration,Effective Date,AccountID,CustomerID UCIC,SecuredUnsecured,AdditionalProvision,AdditionalProvforACCTIDRs',
                      Srnooferroneousrows = ' '
                WHERE  NVL(SrNo, ' ') = ' '
                 AND NVL(AcceleratedProvisionDuration, ' ') = ' '
                 AND NVL(EffectiveDate, ' ') = ' '
                 AND NVL(AccountID, ' ') = ' '
                 AND NVL(CustomerID, ' ') = ' '
                 AND NVL(UCIC, ' ') = ' '
                 AND NVL(SecuredUnsecured, ' ') = ' '
                 AND NVL(AdditionalProvision, ' ') = ' '
                 AND NVL(AdditionalProvforACCTIDRs, ' ') = ' ';
               DBMS_OUTPUT.PUT_LINE('abc');
               --WHERE ISNULL(V.SrNo,'')=''
               -- ----AND ISNULL(Territory,'')=''
               -- AND ISNULL(AccountID,'')=''
               -- AND ISNULL(PoolID,'')=''
               -- AND ISNULL(filname,'')=''
               --IF EXISTS(SELECT 1 FROM UploadAcceleratedProvision WHERE ISNULL(ErrorMessage,'')<>'')
               --BEGIN
               --PRINT 'NO DATA'
               --GOTO ERRORDATA;
               -----------------------------------------------------------------
               DBMS_OUTPUT.PUT_LINE('aa');
               DBMS_OUTPUT.PUT_LINE(v_timekey);
               DBMS_OUTPUT.PUT_LINE('bb');
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN C.AssetClassAlt_Key IS NOT NULL THEN C.AssetClassAlt_Key
               ELSE A.AssetClassification
                  END AS AssetClassification
               FROM A ,AccountLevelApproachUpload_stg A
                      LEFT JOIN ( SELECT DimAssetClass.AssetClassAlt_Key ,
                                         DimAssetClass.AssetClassName ,
                                         'AssetClass' Tablename  
                                  FROM DimAssetClass 
                                   WHERE  DimAssetClass.EffectiveToTimeKey = 49999 ) C   ON A.AssetClassification = C.AssetClassName 
                WHERE filname = v_FilePathUpload) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassification = src.AssetClassification;
               ---------------------------------------------------------------------------
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN C.AssetClassAlt_Key IS NOT NULL THEN C.AssetClassAlt_Key
               ELSE A.AssetClassification
                  END AS AssetClassification
               FROM A ,UploadAcceleratedProvision A
                      LEFT JOIN ( SELECT DimAssetClass.AssetClassAlt_Key ,
                                         DimAssetClass.AssetClassName ,
                                         'AssetClass' Tablename  
                                  FROM DimAssetClass 
                                   WHERE  DimAssetClass.EffectiveToTimeKey = 49999 ) C   ON A.AssetClassification = C.AssetClassName 
                WHERE filname = v_FilePathUpload) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.AssetClassification = src.AssetClassification;
               --------------------------------------------------------
               DBMS_OUTPUT.PUT_LINE('start');
               --END
               DBMS_OUTPUT.PUT_LINE('TEMP START');
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_AdvAcBasicDetail_3  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_AdvAcBasicDetail_3;
               UTILS.IDENTITY_RESET('tt_AdvAcBasicDetail_3');

               INSERT INTO tt_AdvAcBasicDetail_3 ( 
               	SELECT * 
               	  FROM AdvAcBasicDetail 
               	 WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey );
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_CustomerBasicDetail_3  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_CustomerBasicDetail_3;
               UTILS.IDENTITY_RESET('tt_CustomerBasicDetail_3');

               INSERT INTO tt_CustomerBasicDetail_3 ( 
               	SELECT * 
               	  FROM CustomerBasicDetail 
               	 WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey );
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_AdvCustNPADetail  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_AdvCustNPADetail;
               UTILS.IDENTITY_RESET('tt_AdvCustNPADetail');

               INSERT INTO tt_AdvCustNPADetail ( 
               	SELECT * 
               	  FROM AdvCustNPADetail 
               	 WHERE  EffectiveFromTimeKey <= v_Timekey
                          AND EffectiveToTimeKey >= v_Timekey );
               DBMS_OUTPUT.PUT_LINE('TEMP COMPLETE');
               /*validations on Sl. No.*/
               ------------------------------------------------------------
               DBMS_OUTPUT.PUT_LINE('SrNo Validation start');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(SrNo, ' ') = ' '
                 OR NVL(SrNo, '0') = '0';
               DBMS_OUTPUT.PUT_LINE('SrNo Validation start 1');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  LENGTH(SrNo) > 16;
               DBMS_OUTPUT.PUT_LINE('SrNo Validation start2');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( utils.isnumeric(SrNo) = 0
                 AND NVL(SrNo, ' ') <> ' ' )
                 OR REGEXP_LIKE(utils.isnumeric(SrNo), '%^[0-9]%');
               DBMS_OUTPUT.PUT_LINE('SrNo Validation start3');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  REGEXP_LIKE(NVL(SrNo, ' '), '%[,!@#$%^&*()_-+=/]%');
               DBMS_OUTPUT.PUT_LINE('SrNo Validation start4');
               --
               SELECT COUNT(1)  

                 INTO v_DuplicateCnt
                 FROM UploadAcceleratedProvision 
                 GROUP BY SrNo

                  HAVING COUNT(SrNo)  > 1;
               IF ( v_DuplicateCnt > 0 ) THEN
                UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate Sl. No., kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Sl. No., kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(SrNo, ' ') IN ( SELECT SrNo 
                                           FROM UploadAcceleratedProvision 
                                             GROUP BY SrNo

                                              HAVING COUNT(SrNo)  > 1 )
               ;
               END IF;
               DBMS_OUTPUT.PUT_LINE('SrNo Validation complete');
               -------------------------------------------------------------------------
               ---Added by Sachin on 01082022  for "No Moc Intiliazation Month change"
               ------------------------Intiliazation Date------------------------------
               DBMS_OUTPUT.PUT_LINE('a');
               DBMS_OUTPUT.PUT_LINE(v_Timekey);
               DBMS_OUTPUT.PUT_LINE('b');
               --IF (@Timekey IS NULL or @Timekey='')
               --BEGIN
               --PRINT 'SachinTest11'
               --UPDATE UploadAcceleratedProvision
               --	SET  
               --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'There is no MOC Intiliazation Month.Please check again..'     
               --						ELSE ErrorMessage+','+SPACE(1)+'There is no MOC Intiliazation Month.Please check again.'     END
               --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'IntiliazationDate' ELSE   ErrorinColumn +','+SPACE(1)+'IntiliazationDate' END   
               --		,Srnooferroneousrows=V.SrNo
               --   FROM UploadAcceleratedProvision V  
               -- WHERE SrNo IN(Select MIN(SrNo) from UploadAcceleratedProvision)
               -- END 
               /*validations on Accelerated Provision Duration*/
               DBMS_OUTPUT.PUT_LINE('Accelerated Provision Duration validation start');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Accelerated Provision Duration cannot be blank . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Accelerated Provision Duration cannot be blank . Please check the values and upload againn'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Accelerated Provision Duration'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Accelerated Provision Duration'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(AcceleratedProvisionDuration, ' ') = ' ';
               DBMS_OUTPUT.PUT_LINE('Accelerated Provision Duration validation start1');
               IF utils.object_id('AcceleratedProvisionData') IS NOT NULL THEN

               BEGIN
                  EXECUTE IMMEDIATE 'DROP TABLE AcceleratedProvisionData';

               END;
               END IF;
               DELETE FROM AcceleratedProvisionData;
               UTILS.IDENTITY_RESET('AcceleratedProvisionData');

               INSERT INTO AcceleratedProvisionData SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY AcceleratedProvisionDuration ORDER BY AcceleratedProvisionDuration  ) ROW_  ,
                                  AcceleratedProvisionDuration 
                           FROM UploadAcceleratedProvision  ) X
                   WHERE  ROW_ = 1;
               SELECT COUNT(*)  

                 INTO v_AcceleratedProvisionCnt
                 FROM UploadAcceleratedProvision A
                        LEFT JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'AcceleratedProvisionDuration' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimAccProvDuration'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.AcceleratedProvisionDuration = B.ParameterName
                WHERE  B.ParameterName IS NULL;
               DBMS_OUTPUT.PUT_LINE('Accelerated Provision Duration validation start2');
               IF v_AcceleratedProvisionCnt > 0 THEN

               BEGIN
                  UPDATE UploadAcceleratedProvision V
                     SET ErrorMessage = CASE 
                                             WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Accelerated Provision Duration’. Kindly enter the values as mentioned in the ‘Accelerated Provision Duration’ master and upload again. Click on ‘Download Master value’ to download the valid valuesfor the column'
                         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Accelerated Provision Duration’. Kindly enter the values as mentioned in the ‘Accelerated Provision Duration’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                            END,
                         ErrorinColumn = CASE 
                                              WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Accelerated Provision Duration'
                         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Accelerated Provision Duration'
                            END,
                         Srnooferroneousrows = V.SrNo
                   WHERE  NVL(AcceleratedProvisionDuration, ' ') <> ' '
                    AND V.AcceleratedProvisionDuration IN ( SELECT A.AcceleratedProvisionDuration 
                                                            FROM UploadAcceleratedProvision A
                                                                   LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                                                      ParameterName ,
                                                                                      'AcceleratedProvisionDuration' Tablename  
                    FROM DimParameter 
                   WHERE  DimParameterName = 'DimAccProvDuration'
                            AND EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.AcceleratedProvisionDuration = B.ParameterName
                                                             WHERE  B.ParameterName IS NULL )
                  ;

               END;
               END IF;
               DBMS_OUTPUT.PUT_LINE('Accelerated Provision Duration validation completed');
               /*validations on Effective Date*/
               DBMS_OUTPUT.PUT_LINE('Effective Date VALIDATION STAR');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Effective Date cannot be blank . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Effective Date cannot be blank . Please check the values and upload again.n'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Effective Date'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Effective Date'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(EffectiveDate, ' ') = ' ';
               DBMS_OUTPUT.PUT_LINE('Effective Date VALIDATION STAR 1');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Effective Date must be in DD/MM/YYYY format. Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Effective Date must be in DD/MM/YYYY format. Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Effective Date'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Effective Date'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  LENGTH(EffectiveDate) < 10;
               DBMS_OUTPUT.PUT_LINE('Effective Date VALIDATION STAR 2');
               /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Date . Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Date . Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Effective Date'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Effective Date'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  utils.isdate(EffectiveDate) = 0
                 AND NVL(EffectiveDate, ' ') <> ' ';
               DBMS_OUTPUT.PUT_LINE('Effective Date VALIDATION STAR 3');
               SELECT COUNT(1)  

                 INTO v_DateCount
                 FROM UploadAcceleratedProvision 
                WHERE  utils.isdate(EffectiveDate) = 0
                         AND NVL(EffectiveDate, ' ') <> ' ';
               IF v_DateCount = 0 THEN

               BEGIN
                  UPDATE UploadAcceleratedProvision V
                     SET ErrorMessage = CASE 
                                             WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Effective Date must be Month End Date. Kindly check and upload again '
                         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Effective Date must be Month End Date. Kindly check and upload again '
                            END,
                         ErrorinColumn = CASE 
                                              WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Effective Date'
                         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Effective Date'
                            END,
                         Srnooferroneousrows = V.SrNo
                   WHERE  ( NVL(REPLACE(UTILS.CONVERT_TO_VARCHAR2(EffectiveDate,10,p_style=>103), '-', '/'), ' ') <> UTILS.CONVERT_TO_VARCHAR2(utils.dateadd('D', -1, utils.dateadd('M', utils.datediff('M', 0, UTILS.CONVERT_TO_VARCHAR2(EffectiveDate,200,p_style=>103)) + 1, 0)),10,p_style=>103) );

               END;
               END IF;
               --NOT IN(Select  Convert(Varchar(10),DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, EffectiveDate) + 1, 0)),103)
               --                                          from UploadAcceleratedProvision)
               --AND ISNULL(TaggingLevel,'') Not In('UCIC', 'CustomerID', 'AccountID')
               -------------------------------------------------------------------------
               DBMS_OUTPUT.PUT_LINE('Effective Date VALIDATION COMPLETE');
               DBMS_OUTPUT.PUT_LINE('CUSTOMER ID VALIDATION START');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Please enter one of Value AccountID,CustomerID and UCIC . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Please enter one of Value  AccountID,CustomerID and UCIC . Please check the values and upload again.n'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID/CustomerID/UCIC'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID/CustomerID/UCIC'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AccountID, ' ') = ' '
                 AND NVL(CustomerID, ' ') = ' '
                 AND NVL(UCIC, ' ') = ' ' );
               DBMS_OUTPUT.PUT_LINE('CUSTOMER ID VALIDATION START 1');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Please enter one of Value AccountID,CustomerID  . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Please enter one of Value  AccountID,CustomerID  . Please check the values and upload again.n'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID/CustomerID/UCIC'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID/CustomerID/UCIC'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AccountID, ' ') <> ' '
                 AND NVL(CustomerID, ' ') <> ' '
                 AND NVL(UCIC, ' ') = ' ' );
               DBMS_OUTPUT.PUT_LINE('CUSTOMER ID VALIDATION START 2');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Please enter one of Value UCIC,CustomerID  . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Please enter one of Value  UCIC,CustomerID  . Please check the values and upload again.n'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID/CustomerID/UCIC'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID/CustomerID/UCIC'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AccountID, ' ') = ' '
                 AND NVL(CustomerID, ' ') <> ' '
                 AND NVL(UCIC, ' ') <> ' ' );
               DBMS_OUTPUT.PUT_LINE('CUSTOMER ID VALIDATION START 3');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Please enter one of Value UCIC,AccountID  . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Please enter one of Value  UCIC,AccountID  . Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID/CustomerID/UCIC'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID/CustomerID/UCIC'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AccountID, ' ') <> ' '
                 AND NVL(CustomerID, ' ') = ' '
                 AND NVL(UCIC, ' ') <> ' ' );
               --IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp; 
               -- Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,AccountId,CustomerId,UCIC,
               -- Convert(Varchar(1000),'') as ErrorMessage 
               -- into #tmp from UploadAcceleratedProvision WHERE 
               --Select @Count=Count(*) from #tmp
               v_I := 1 ;
               v_Entity_Key := 0 ;
               v_CustomerId := ' ' ;
               v_UCIC := ' ' ;
               v_AccountId := ' ' ;
               v_CustomerId1 := ' ' ;
               v_UCIC1 := ' ' ;
               v_AccountId1 := ' ' ;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID is invalid. Kindly check the entered Account ID'
               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID is invalid. Kindly check the entered Account ID'
                  END AS pos_2, CASE 
               WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                  END AS pos_3
               FROM A ,UploadAcceleratedProvision A
                      LEFT JOIN tt_AdvAcBasicDetail_3 B   ON A.AccountID = B.CustomerACID 
                WHERE B.CustomerACID IS NULL
                 AND A.AccountID <> ' ') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET B.ErrorMessage = pos_2,
                                            B.ErrorinColumn = pos_3;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is invalid. Kindly check the entered Customer ID'
               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'customer ID is invalid. Kindly check the entered Customer ID'
                  END AS pos_2, CASE 
               WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                  END AS pos_3
               FROM A ,UploadAcceleratedProvision A
                      LEFT JOIN tt_CustomerBasicDetail_3 B   ON A.CustomerID = B.CustomerId 
                WHERE B.CustomerID IS NULL
                 AND A.CustomerID <> ' ') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET B.ErrorMessage = pos_2,
                                            B.ErrorinColumn = pos_3;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, CASE 
               WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ucic ID is invalid. Kindly check the entered ucic ID'
               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ucic ID is invalid. Kindly check the entered ucic ID'
                  END AS pos_2, CASE 
               WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ucic'
               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ucic'
                  END AS pos_3
               FROM A ,UploadAcceleratedProvision A
                      LEFT JOIN tt_CustomerBasicDetail_3 B   ON A.UCIC = B.UCIF_ID 
                WHERE B.UCIF_ID IS NULL
                 AND A.UCIC <> ' ') src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET B.ErrorMessage = pos_2,
                                            B.ErrorinColumn = pos_3;
               --While(@I<=@Count)
               --				BEGIN
               --				    Select @CustomerId1 =CustomerId,@UCIC1=UCIC,@AccountId1=AccountId,@Entity_Key=Entity_Key  from #tmp where RecentRownumber=@I 
               --						order By Entity_Key
               --						If @AccountId1<>''
               --						  BEGIN
               --						       Select @AccountId=CustomerACID from tt_AdvAcBasicDetail_3  where CustomerACID=@AccountId1
               --PRINT 'CUSTOMER ID VALIDATION START 5'
               --							   IF @AccountId =''
               --							     BEGIN
               --									   Update UploadAcceleratedProvision
               --									   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID is invalid. Kindly check the entered Account ID'     
               --										 ELSE ErrorMessage+','+SPACE(1)+'Account ID is invalid. Kindly check the entered Account ID'      END
               --										,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Account ID' END   
               --										Where Entity_Key=@Entity_Key
               --								END
               --						  END
               --						  If @CustomerId1<>''
               --						  BEGIN
               --						    Print 'Sachin'
               --	PRINT 'CUSTOMER ID VALIDATION START 6' 
               --						       Select @CustomerId=CustomerId from tt_CustomerBasicDetail_3 where CustomerId=@CustomerId1
               --							  IF @CustomerId =''
               --							       Begin
               --									   Print '@CustomerIdAf'
               --									   Print @CustomerId
               --									   Update UploadAcceleratedProvision
               --									   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is invalid. Kindly check the entered Customer ID'     
               --										 ELSE ErrorMessage+','+SPACE(1)+'Customer ID is invalid. Kindly check the entered Customer ID'      END
               --										,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerId' ELSE   ErrorinColumn +','+SPACE(1)+'CustomerId' END 
               --									   Where Entity_Key=@Entity_Key
               --								END
               --						  END
               --						   If @UCIC1<>''
               --						  BEGIN
               --						       Select @UCIC=UCIF_ID from tt_CustomerBasicDetail_3 where UCIF_ID=@UCIC1
               --							   IF @UCIC =''
               --							      Begin
               --									   Update UploadAcceleratedProvision
               --									   SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '	  UCIC is invalid. Kindly check the entered UCIC'     
               --										 ELSE ErrorMessage+','+SPACE(1)+'	  UCIC is invalid. Kindly check the entered UCIC'      END
               --										,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account ID' END 
               --									   Where Entity_Key=@Entity_Key
               --								End
               --						  END
               --						    SET @I=@I+1
               --							SET @CustomerId=''
               --							SET @UCIC=''
               --							SET @AccountId=''
               --							SET @CustomerID1=''
               --							SET @UCIC1=''
               --							SET @AccountId1=''
               --				END
               DBMS_OUTPUT.PUT_LINE('CUSTOMER ID VALIDATION COMPLETE ');
               DBMS_OUTPUT.PUT_LINE('PENDING ACCOUNT VALIDATION STARTS');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record is pending for authorization for this Account ID. Kindly authorize or Reject the record '
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Record is pending for authorization for this Account ID. Kindly authorize or Reject the record '
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountId'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountId'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(V.AccountID, ' ') <> ' '
                 AND V.AccountID IN ( SELECT AccountId 
                                      FROM AcceleratedProvision_Mod 
                                       WHERE  EffectiveFromTimeKey <= v_Timekey
                                                AND EffectiveToTimeKey >= v_Timekey
                                                AND AuthorisationStatus IN ( 'NP','MP','1A' )
                )
               ;
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record '
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record '
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(V.CustomerID, ' ') <> ' '
                 AND V.CustomerID IN ( SELECT CustomerID 
                                       FROM AcceleratedProvision_Mod 
                                        WHERE  EffectiveFromTimeKey >= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey
                                                 AND AuthorisationStatus IN ( 'NP','MP','1A' )
                )
               ;
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record is pending for authorization for this UCICID. Kindly authorize or Reject the record '
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Record is pending for authorization for this UCICID. Kindly authorize or Reject the record '
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCICID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCICID'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(V.UCIC, ' ') <> ' '
                 AND V.UCIC IN ( SELECT UCICID 
                                 FROM AcceleratedProvision_Mod 
                                  WHERE  EffectiveFromTimeKey >= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey
                                           AND AuthorisationStatus IN ( 'NP','MP','1A' )
                )
               ;
               -------------------------------------------------------------------------
               ----------------------------------------------
               DBMS_OUTPUT.PUT_LINE('PENDING ACCOUNT VALIDATION COMPLETE');
               /*validations on Secured/Unsecured*/
               DBMS_OUTPUT.PUT_LINE('Secured/Unsecured VALIDATION STARTS');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Secured/Unsecured cannot be blank . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Secured/Unsecured cannot be blank . Please check the values and upload again.'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Secured/Unsecured'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Secured/Unsecured'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(SecuredUnsecured, ' ') = ' ';
               DBMS_OUTPUT.PUT_LINE('Secured/Unsecured VALIDATION STARTS 1');
               IF utils.object_id('SecuredUnsecuredData') IS NOT NULL THEN

               BEGIN
                  EXECUTE IMMEDIATE 'DROP TABLE SecuredUnsecuredData';

               END;
               END IF;
               DELETE FROM SecuredUnsecuredData;
               UTILS.IDENTITY_RESET('SecuredUnsecuredData');

               INSERT INTO SecuredUnsecuredData SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY SecuredUnsecured ORDER BY SecuredUnsecured  ) ROW_  ,
                                  SecuredUnsecured 
                           FROM UploadAcceleratedProvision  ) X
                   WHERE  ROW_ = 1;
               SELECT COUNT(*)  

                 INTO v_SecuredUnsecuredCnt
                 FROM SecuredUnsecuredData A
                        LEFT JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'Secure/Unsecure Master' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimExposureType'
                                              AND ParameterName NOT IN ( 'Derived' )

                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.SecuredUnsecured = B.ParameterName
                WHERE  B.ParameterName IS NULL;
               IF v_SecuredUnsecuredCnt > 0 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Secured/Unsecured VALIDATION STARTS 2');
                  UPDATE UploadAcceleratedProvision V
                     SET ErrorMessage = CASE 
                                             WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column Secured/Unsecured’. Kindly enter the values as mentioned in the ‘Secured/Unsecured’ master and upload again. Click on ‘Download Master value’ to download the valid valuesfor the column'
                         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Secured/Unsecured’. Kindly enter the values as mentioned in the ‘Secured/Unsecured’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                            END,
                         ErrorinColumn = CASE 
                                              WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Secured/Unsecured'
                         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Secured/Unsecured'
                            END,
                         Srnooferroneousrows = V.SrNo
                   WHERE  NVL(SecuredUnsecured, ' ') <> ' '
                    AND V.SecuredUnsecured IN ( SELECT A.SecuredUnsecured 
                                                FROM SecuredUnsecuredData A
                                                       LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                                          ParameterName ,
                                                                          'Secure/Unsecure Master' Tablename  
                                                                   FROM DimParameter 
                                                                    WHERE  DimParameterName = 'DimExposureType'
                                                                             AND ParameterName NOT IN ( 'Derived' )

                                                                             AND EffectiveFromTimeKey <= v_TimeKey
                                                                             AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.SecuredUnsecured = B.ParameterName
                                                 WHERE  B.ParameterName IS NULL )
                  ;

               END;
               END IF;
               DBMS_OUTPUT.PUT_LINE('Secured/Unsecured VALIDATION COMPLETE');
               /*-------------------Additional Provision%------------------------- */
               -- changes done on 19-03-21 Pranay 
               DBMS_OUTPUT.PUT_LINE('Additional Provision% START');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Additional Provision%’. Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Additional Provision%’. Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( utils.isnumeric(AdditionalProvision) = 0
                 AND NVL(AdditionalProvision, ' ') <> ' ' )
                 OR REGEXP_LIKE(utils.isnumeric(AdditionalProvision), '%^[0-9]%');
               DBMS_OUTPUT.PUT_LINE('Additional Provision% START 1');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters are not allowed, kindly remove and try again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters are not allowed,  kindly remove and try again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(AdditionalProvision, ' ') <> ' '
                 AND REGEXP_LIKE(NVL(AdditionalProvision, ' '), '%[,/-_!@#$%^&*()+=]%');
               DBMS_OUTPUT.PUT_LINE('Additional Provision% START 2');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN '‘Additional Provision%’ is mandatory for UCIC or CustomerID. Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '‘Additional Provision%’ is mandatory for UCIC or CustomerID. Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AdditionalProvision, ' ') = ' '
                 AND ( NVL(UCIC, ' ') <> ' '
                 OR NVL(CustomerId, ' ') <> ' ' ) );
               DBMS_OUTPUT.PUT_LINE('Additional Provision% START 3');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN '‘Additional Provision%’ should be blank for AccountID . Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '‘‘Additional Provision%’ should be blank for AccountID . Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AdditionalProvision, ' ') <> ' '
                 AND ( NVL(AccountID, ' ') <> ' ' ) );
               SELECT COUNT(1)  

                 INTO v_NumValue
                 FROM UploadAcceleratedProvision V
                WHERE  ( utils.isnumeric(AdditionalProvision) = 0
                         AND NVL(AdditionalProvision, ' ') <> ' ' )
                         OR REGEXP_LIKE(utils.isnumeric(AdditionalProvision), '%^[0-9]%');
               IF v_NumValue = 0 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Additional Provision% START 4');
                  UPDATE UploadAcceleratedProvision V
                     SET ErrorMessage = CASE 
                                             WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Additional Provision%’. Percentage cannot be greater than 100.00. Kindly check and upload again.'
                         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Additional Provision%’. Percentage cannot be greater than 100.00. Kindly check and upload again.'
                            END,
                         ErrorinColumn = CASE 
                                              WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                            END,
                         Srnooferroneousrows = V.SrNo
                   WHERE  NVL(AdditionalProvision, ' ') <> ' '
                    AND UTILS.CONVERT_TO_NUMBER(NVL(AdditionalProvision, '0'),10,2) > 100;

               END;
               END IF;
               DBMS_OUTPUT.PUT_LINE('Additional Provision% COMPLETE');
               -----------------------------------------------------------------
               /*-------------------Additional Prov for ACCT ID (Rs.)------------------------- */
               -- changes done on 19-03-21 Pranay 
               DBMS_OUTPUT.PUT_LINE('Additional Prov for ACCT ID (Rs.) START');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Additional Prov for ACCT ID (Rs.)’. Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Additional Prov for ACCT ID (Rs.)’. Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Prov for ACCT ID (Rs.)'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Prov for ACCT ID (Rs.)'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( utils.isnumeric(AdditionalProvforACCTIDRs) = 0
                 AND NVL(AdditionalProvforACCTIDRs, ' ') <> ' ' )
                 OR REGEXP_LIKE(utils.isnumeric(AdditionalProvforACCTIDRs), '%^[0-9]%');
               DBMS_OUTPUT.PUT_LINE('Additional Prov for ACCT ID (Rs.) START 1');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN '‘Additional Prov for ACCT ID’ is not required for UCIC or CustomerID. Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '‘Additional Prov for ACCT ID’ is not required for UCIC or CustomerID. Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Prov for ACCT ID (Rs.)'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Prov for ACCT ID (Rs.)'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AdditionalProvforACCTIDRs, ' ') <> ' '
                 AND ( NVL(UCIC, ' ') <> ' '
                 OR NVL(CustomerId, ' ') <> ' ' ) );
               DBMS_OUTPUT.PUT_LINE('Additional Prov for ACCT ID (Rs.) START 2');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN '‘Additional Prov for ACCT ID’ is mandatory for AccountId. Kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '‘Additional Prov for ACCT ID’ is mandatory for AccountId.  Kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Prov for ACCT ID (Rs.)'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Prov for ACCT ID (Rs.)'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  ( NVL(AdditionalProvforACCTIDRs, ' ') = ' '
                 AND ( NVL(AccountId, ' ') <> ' ' ) );
               DBMS_OUTPUT.PUT_LINE('Additional Prov for ACCT ID (Rs.) COMPLETE');
               --------------------------------------------------------------------------------------------------------------------
               ---------------------Business Segment-----------------------
               DBMS_OUTPUT.PUT_LINE('BUSINESS SEGMENT START');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Business Segment cannot be blank . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Business Segment cannot be blank . Please check the values and upload againn'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Business Segment'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Business Segment'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(BusinessSegment, ' ') = ' ';
               DBMS_OUTPUT.PUT_LINE('BUSINESS SEGMENT START 1');
               IF utils.object_id('BusinessSegmentData') IS NOT NULL THEN

               BEGIN
                  EXECUTE IMMEDIATE 'DROP TABLE BusinessSegmentData';

               END;
               END IF;
               DELETE FROM BusinessSegmentData;
               UTILS.IDENTITY_RESET('BusinessSegmentData');

               INSERT INTO BusinessSegmentData SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY BusinessSegment ORDER BY BusinessSegment  ) ROW_  ,
                                  BusinessSegment 
                           FROM UploadAcceleratedProvision  ) X
                   WHERE  ROW_ = 1;
               SELECT COUNT(*)  

                 INTO v_BusinessSegmentCnt
                 FROM BusinessSegmentData A
                        LEFT JOIN ( SELECT AcBuSegmentCode ,
                                           AcBuRevisedSegmentCode ,
                                           'SegmentMaster' TableName  
                                    FROM DimAcBuSegment A
                                     WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                              AND A.EffectiveToTimeKey >= v_TimeKey ) C   ON A.BusinessSegment = C.AcBuRevisedSegmentCode
                WHERE  C.AcBuRevisedSegmentCode IS NULL;
               IF v_BusinessSegmentCnt > 0 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('BUSINESS SEGMENT START 2');
                  UPDATE UploadAcceleratedProvision V
                     SET ErrorMessage = CASE 
                                             WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Business Segment’. Kindly enter the values as mentioned in the ‘Business Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Business Segment’. Kindly enter the values as mentioned in the ‘Business Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                            END,
                         ErrorinColumn = CASE 
                                              WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Business Segment'
                         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Business Segment'
                            END,
                         Srnooferroneousrows = V.SrNo
                   WHERE  NVL(BusinessSegment, ' ') <> ' '
                    AND V.BusinessSegment IN ( SELECT A.BusinessSegment 
                                               FROM UploadAcceleratedProvision A
                                                      LEFT JOIN ( SELECT AcBuSegmentCode ,
                                                                         AcBuRevisedSegmentCode ,
                                                                         'SegmentMaster' TableName  
                                                                  FROM DimAcBuSegment A
                                                                   WHERE  A.EffectiveToTimeKey >= v_TimeKey ) C   ON A.BusinessSegment = C.AcBuSegmentCode
                                                WHERE  C.AcBuSegmentCode IS NULL )
                  ;

               END;
               END IF;
               DBMS_OUTPUT.PUT_LINE('BUSINESS SEGMENT COMPLETE');
               ----------------------------------------------------------------------------------------------------------------------
               ---------------------Asset Classification-----------------------
               DBMS_OUTPUT.PUT_LINE('Asset Classification START');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Asset Classification cannot be blank . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Asset Classification cannot be blank . Please check the values and upload againn'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Asset Classification'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Asset Classification'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(AssetClassification, '0') = '0';
               --Declare @ValidCnt int=0
               IF utils.object_id('AssetClassificationData') IS NOT NULL THEN

               BEGIN
                  EXECUTE IMMEDIATE 'DROP TABLE AssetClassificationData';

               END;
               END IF;
               DELETE FROM AssetClassificationData;
               UTILS.IDENTITY_RESET('AssetClassificationData');

               INSERT INTO AssetClassificationData SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY AssetClassification ORDER BY AssetClassification  ) ROW_  ,
                                  AssetClassification 
                           FROM UploadAcceleratedProvision  ) X
                   WHERE  ROW_ = 1;
               SELECT COUNT(*)  

                 INTO v_AssetClassificationCnt
                 FROM AssetClassificationData A
                        LEFT JOIN ( SELECT AssetClassAlt_Key ,
                                           AssetClassName ,
                                           'AssetClass' Tablename  
                                    FROM DimAssetClass 
                                     WHERE  EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) C   ON A.AssetClassification = C.AssetClassAlt_Key
                WHERE  C.AssetClassAlt_Key IS NULL;
               IF v_AssetClassificationCnt > 0 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Asset Classification START 1');
                  UPDATE UploadAcceleratedProvision V
                     SET ErrorMessage = CASE 
                                             WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Asset Classification’. Kindly enter the values as mentioned in the ‘Asset Classification’ master and upload again. Click on ‘Download Master value’ to download the valid valuesfor the column'
                         ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Asset Classification’. Kindly enter the values as mentioned in the ‘Asset Classification’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                            END,
                         ErrorinColumn = CASE 
                                              WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Business Segment'
                         ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Business Segment'
                            END,
                         Srnooferroneousrows = V.SrNo
                   WHERE  NVL(AssetClassification, ' ') <> ' '
                    AND V.AssetClassification IN ( SELECT A.AssetClassification 
                                                   FROM AssetClassificationData A
                                                          LEFT JOIN ( SELECT AssetClassAlt_Key ,
                                                                             AssetClassName ,
                                                                             'AssetClass' Tablename  
                                                                      FROM DimAssetClass 
                                                                       WHERE  EffectiveToTimeKey >= v_Timekey ) C   ON A.AssetClassification = C.AssetClassAlt_Key
                                                    WHERE  C.AssetClassAlt_Key IS NULL )
                  ;

               END;
               END IF;
               DBMS_OUTPUT.PUT_LINE('Asset Classification COMPLETE');
               ----------------------------------------------------------------------------------------------------------------------
               ---------------------Valid Customer/Account/UCIC-----------------------
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC START');
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_tmp3_11  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_tmp3_11;
               UTILS.IDENTITY_RESET('tt_tmp3_11');

               INSERT INTO tt_tmp3_11 ( 
               	SELECT D.AccountID ,
                       COUNT(1)  CountRecord  
               	  FROM UploadAcceleratedProvision D
                         JOIN tt_AdvAcBasicDetail_3 A   ON D.AccountID = A.CustomerACID
                         LEFT JOIN tt_AdvCustNPADetail B   ON A.CustomerEntityId = B.CustomerEntityId
               	 WHERE  B.Cust_AssetClassAlt_Key = D.AssetClassification
                          AND A.FlgSecured = CASE 
                                                  WHEN SecuredUnsecured = 'Secured' THEN 'S'
                                                  WHEN SecuredUnsecured = 'Unsecured' THEN 'U'   END
                          AND D.AccountID <> ' '
                          AND A.segmentcode IN ( SELECT AcBuSegmentCode 
                                                 FROM DimAcBuSegment A
                                                        JOIN UploadAcceleratedProvision Z   ON A.AcBuRevisedSegmentCode = Z.BusinessSegment )

               	  GROUP BY D.AccountID );
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC START 1');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Combination of Business Segment, Asset Classification and Secured/Unsecured for AccountID . Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Combination of Business Segment, Asset Classification and Secured/Unsecured for AccountID. Please check the values and upload againn'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(AccountID, ' ') NOT IN ( SELECT AccountID 
                                                    FROM tt_tmp3_11  )

                 AND NVL(AccountID, ' ') <> ' ';
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_tmp1_17  --SQLDEV: NOT RECOGNIZED
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC START 2');
               DELETE FROM tt_tmp1_17;
               UTILS.IDENTITY_RESET('tt_tmp1_17');

               INSERT INTO tt_tmp1_17 ( 
               	SELECT D.CustomerID ,
                       COUNT(1)  CountRecord  
               	  FROM UploadAcceleratedProvision D
                         JOIN tt_CustomerBasicDetail_4 B   ON D.CustomerID = B.CustomerId
                         JOIN tt_AdvAcBasicDetail_4 A   ON A.CustomerEntityId = B.CustomerEntityId
                         LEFT JOIN tt_AdvCustNPAdetail_17 C   ON A.CustomerEntityId = C.CustomerEntityId
               	 WHERE  C.Cust_AssetClassAlt_Key = D.AssetClassification
                          AND A.FlgSecured = CASE 
                                                  WHEN SecuredUnsecured = 'Secured' THEN 'S'
                                                  WHEN SecuredUnsecured = 'Unsecured' THEN 'U'   END
                          AND D.CustomerID <> ' '
                          AND A.segmentcode IN ( SELECT AcBuSegmentCode 
                                                 FROM DimAcBuSegment A
                                                        JOIN UploadAcceleratedProvision Z   ON A.AcBuRevisedSegmentCode = Z.BusinessSegment )

               	  GROUP BY D.CustomerID );
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC START 2');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Combination of Business Segment, Asset Classification and Secured/Unsecured for Customer ID. Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Combination of Business Segment, Asset Classification and Secured/Unsecured for Customer ID. Please check the values and upload again.'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(CustomerID, ' ') NOT IN ( SELECT CustomerID 
                                                     FROM tt_tmp1_17  )

                 AND NVL(CustomerID, ' ') <> ' ';
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC START 3');
               IF  --SQLDEV: NOT RECOGNIZED
               IF tt_tmp2_26  --SQLDEV: NOT RECOGNIZED
               DELETE FROM tt_tmp2_26;
               UTILS.IDENTITY_RESET('tt_tmp2_26');

               INSERT INTO tt_tmp2_26 ( 
               	SELECT D.UCIC ,
                       COUNT(1)  CountRecord  
               	  FROM UploadAcceleratedProvision D
                         JOIN tt_CustomerBasicDetail_4 B   ON D.UCIC = B.UCIF_ID
                         JOIN tt_AdvAcBasicDetail_4 A   ON A.CustomerEntityId = B.CustomerEntityId
                         LEFT JOIN tt_AdvCustNPAdetail_17 C   ON A.CustomerEntityId = C.CustomerEntityId
               	 WHERE  C.Cust_AssetClassAlt_Key = D.AssetClassification
                          AND A.FlgSecured = CASE 
                                                  WHEN SecuredUnsecured = 'Secured' THEN 'S'
                                                  WHEN SecuredUnsecured = 'Unsecured' THEN 'U'   END
                          AND D.UCIC <> ' '
                          AND A.segmentcode IN ( SELECT AcBuSegmentCode 
                                                 FROM DimAcBuSegment A
                                                        JOIN UploadAcceleratedProvision Z   ON A.AcBuRevisedSegmentCode = Z.BusinessSegment )

               	  GROUP BY D.UCIC );
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC START 3');
               UPDATE UploadAcceleratedProvision V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Combination of Business Segment, Asset Classification and Secured/Unsecured for UCICID. Please check the values and upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Combination of Business Segment, Asset Classification and Secured/Unsecured for UCICID. Please check the values and upload again.'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCICID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCICID'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(UCIC, ' ') NOT IN ( SELECT UCIC 
                                               FROM tt_tmp2_26  )

                 AND NVL(UCIC, ' ') <> ' ';
               DBMS_OUTPUT.PUT_LINE('Valid Customer/Account/UCIC COMPLETE');
               -----------------------------------------------------------------------
               ---------------------------------------------------
               DBMS_OUTPUT.PUT_LINE('SACHIN11');
               DBMS_OUTPUT.PUT_LINE('123');
               GOTO valid;

            END;
            END IF;
            <<ErrorData>>
            DBMS_OUTPUT.PUT_LINE('no');
            OPEN  v_cursor FOR
               SELECT * ,
                      'Data' TableName  
                 FROM RBL_MISDB_PROD.MasterUploadData 
                WHERE  FileNames = v_filepath ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            RETURN;
            <<valid>>
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT EXISTS ( SELECT 1 
                                   FROM AccountLevelApproachUpload_stg 
                                    WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('NO ERRORS');
               INSERT INTO RBL_MISDB_PROD.MasterUploadData
                 ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Flag )
                 ( SELECT ' ' SRNO  ,
                          ' ' ColumnName  ,
                          ' ' ErrorData  ,
                          ' ' ErrorType  ,
                          v_filepath ,
                          'SUCCESS' 
                     FROM DUAL  );

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('VALIDATION ERRORS');
               DBMS_OUTPUT.PUT_LINE('@filepath');
               DBMS_OUTPUT.PUT_LINE(v_filepath);
               INSERT INTO RBL_MISDB_PROD.MasterUploadData
                 ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Srnooferroneousrows, Flag )
                 ( SELECT SrNo ,
                          ErrorinColumn ,
                          ErrorMessage ,
                          ErrorinColumn ,
                          v_filepath ,
                          Srnooferroneousrows ,
                          'SUCCESS' 
                   FROM UploadAcceleratedProvision  );
               DBMS_OUTPUT.PUT_LINE('Row Effected');
               DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
               --	----SELECT * FROM UploadAcceleratedProvision 
               --	--ORDER BY ErrorMessage,UploadAcceleratedProvision.ErrorinColumn DESC
               GOTO final;

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM RBL_MISDB_PROD.MasterUploadData 
                                WHERE  FileNames = v_filepath
                                         AND NVL(ERRORDATA, ' ') <> ' ' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN


            -- added for delete Upload status while error while uploading data.  
            BEGIN
               --SELECT * FROM #OAOLdbo.MasterUploadData
               DELETE UploadStatus

                WHERE  FileNames = v_filepath;

            END;

            --ELSE IF EXISTS (SELECT 1 FROM  UploadStatus where ISNULL(InsertionOfData,'')='' and FileNames=@filepath and UploadedBy=@UserLoginId)  -- added validated condition successfully, delete filename from Upload status  

            --  BEGIN  

            --  print 'RC'  

            --   delete from UploadStatus where FileNames=@filepath  

            --  END    --commented in [OAProvision].[GetStatusOfUpload] SP for checkin 'InsertionOfData' Flag  
            ELSE

            BEGIN
               UPDATE UploadStatus
                  SET ValidationOfData = 'Y',
                      ValidationOfDataCompletedOn = SYSDATE
                WHERE  FileNames = v_filepath;

            END;
            END IF;
            <<final>>
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM RBL_MISDB_PROD.MasterUploadData 
                                WHERE  FileNames = v_filepath
                                         AND NVL(ERRORDATA, ' ') <> ' ' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('ERROR');
               OPEN  v_cursor FOR
                  SELECT SR_No ,
                         ColumnName ,
                         ErrorData ,
                         ErrorType ,
                         FileNames ,
                         Flag ,
                         Srnooferroneousrows ,
                         'Validation' TableName  
                    FROM RBL_MISDB_PROD.MasterUploadData 
                   WHERE  FileNames = v_filepath
                          --(SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames ORDER BY ColumnName,ErrorData,ErrorType,FileNames )AS ROW 
                           --FROM  dbo.MasterUploadData    )a 
                           --WHERE A.ROW=1
                           --AND FileNames=@filepath
                           --AND ISNULL(ERRORDATA,'')<>''

                    ORDER BY SR_No ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM AccountLevelApproachUpload_stg 
                                   WHERE  filname = v_FilePathUpload );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('1');
                  DELETE AccountLevelApproachUpload_stg

                   WHERE  filname = v_FilePathUpload;
                  DBMS_OUTPUT.PUT_LINE('2');
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.AccountLevelApproachUpload_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE(' DATA NOT PRESENT');
               --SELECT *,'Data'TableName
               --FROM dbo.MasterUploadData WHERE FileNames=@filepath 
               --ORDER BY ErrorData DESC
               OPEN  v_cursor FOR
                  SELECT SR_No ,
                         ColumnName ,
                         ErrorData ,
                         ErrorType ,
                         FileNames ,
                         Flag ,
                         Srnooferroneousrows ,
                         'Data' TableName  
                    FROM ( SELECT * ,
                                  ROW_NUMBER() OVER ( PARTITION BY ColumnName, ErrorData, ErrorType, FileNames, Flag, Srnooferroneousrows ORDER BY ColumnName, ErrorData, ErrorType, FileNames, Flag, Srnooferroneousrows  ) ROW_  
                           FROM RBL_MISDB_PROD.MasterUploadData  ) a
                   WHERE  A.ROW = 1
                            AND FileNames = v_filepath ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
            ----SELECT * FROM UploadAcceleratedProvision
            DBMS_OUTPUT.PUT_LINE('p');

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         ------to delete file if it has errors
         --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
         --begin
         --print 'ppp'
         -- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
         -- BEGIN
         -- print '123'
         -- DELETE FROM IBPCPoolDetail_stg
         -- WHERE filname=@FilePathUpload
         -- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
         -- END
         -- END
         INSERT INTO RBL_MISDB_PROD.Error_Log
           ( SELECT utils.error_line ErrorLine  ,
                    SQLERRM ErrorMessage  ,
                    SQLCODE ErrorNumber  ,
                    utils.error_procedure ErrorProcedure  ,
                    utils.error_severity ErrorSeverity  ,
                    utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
                    --	 BEGIN
                    --	 DELETE FROM IBPCPoolDetail_stg
                    --	 WHERE filname=@FilePathUpload
                    --	 PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                    ,--	 END
                    SYSDATE 
               FROM DUAL  );

      END;END;

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
