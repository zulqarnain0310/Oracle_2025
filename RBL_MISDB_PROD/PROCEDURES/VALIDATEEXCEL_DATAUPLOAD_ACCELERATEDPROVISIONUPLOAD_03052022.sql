--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'IBPCUPLOAD.xlsx' 
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
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
         SELECT MAX(Timekey)  

           INTO v_Timekey
           FROM SysDayMatrix 
          WHERE  UTILS.CONVERT_TO_VARCHAR2(date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
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
            -------------------------------------------------------------------------
            ----------------------------------------------
            v_DateCount NUMBER(10,0) := 0;
            --NOT IN(Select  Convert(Varchar(10),DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, EffectiveDate) + 1, 0)),103)
            --                                          from UploadAcceleratedProvision)
            --AND ISNULL(TaggingLevel,'') Not In('UCIC', 'CustomerID', 'AccountID')
            -------------------------------------------------------------------------
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
            /*-------------------Additional Provision%------------------------- */
            -- changes done on 19-03-21 Pranay 
            v_NumValue NUMBER(10,0) := 0;
            v_BusinessSegmentCnt NUMBER(10,0) := 0;
            v_ValidCnt NUMBER(10,0) := 0;
            v_AssetClassificationCnt NUMBER(10,0) := 0;
            ----------------------------------------------------------------------------------------------------------------------
            ---------------------Valid Customer/Account/UCIC-----------------------
            v_ValidCountAccount NUMBER(10,0) := 0;
            v_ValidCountCustomer NUMBER(10,0) := 0;
            v_ValidCountUCIC NUMBER(10,0) := 0;

         BEGIN
            --Update A
            --SET A.BusinessSegment=CASE WHEN C.AcBuSegmentCode IS NOT NULL Then C.AcBuSegmentCode ELSE A.BusinessSegment END
            --From AccountLevelApproachUpload_stg A 
            --Left JOIN (
            --Select  AcBuSegmentCode,AcBuRevisedSegmentCode,'SegmentMaster' as TableName 
            --from DimAcBuSegment A where	 A.EffectiveFromTimeKey<=@TimeKey
            --AND A.EffectiveToTimeKey >=@TimeKey) 
            --C ON A.BusinessSegment=C.AcBuRevisedSegmentCode
            --Where filname=@FilePathUpload
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
                                WHERE  DimAssetClass.EffectiveFromTimeKey <= v_Timekey
                                         AND DimAssetClass.EffectiveToTimeKey >= v_Timekey ) C   ON A.AssetClassification = C.AssetClassName 
             WHERE filname = v_FilePathUpload) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.AssetClassification = src.AssetClassification;
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
            --WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filname,'')=''
            --IF EXISTS(SELECT 1 FROM UploadAcceleratedProvision WHERE ISNULL(ErrorMessage,'')<>'')
            --BEGIN
            --PRINT 'NO DATA'
            --GOTO ERRORDATA;
            --END
            /*validations on Sl. No.*/
            ------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('Satart11');
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
            /*validations on Accelerated Provision Duration*/
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
            /*validations on Effective Date*/
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
            IF utils.object_id('TempDB..tt_tmp_17') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp_17 ';
            END IF;
            DELETE FROM tt_tmp_17;
            UTILS.IDENTITY_RESET('tt_tmp_17');

            INSERT INTO tt_tmp_17 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_NUMBER(Entity_Key,10,0)  ) RecentRownumber  ,
                                         Entity_Key ,
                                         AccountId ,
                                         CustomerId ,
                                         UCIC ,
                                         UTILS.CONVERT_TO_VARCHAR2(' ',1000) ErrorMessage  
                 FROM UploadAcceleratedProvision ;
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_tmp_17 ;
            v_I := 1 ;
            v_Entity_Key := 0 ;
            v_CustomerId := ' ' ;
            v_UCIC := ' ' ;
            v_AccountId := ' ' ;
            v_CustomerId1 := ' ' ;
            v_UCIC1 := ' ' ;
            v_AccountId1 := ' ' ;
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT CustomerId ,
                         UCIC ,
                         AccountId ,
                         Entity_Key 

                    INTO v_CustomerId1,
                         v_UCIC1,
                         v_AccountId1,
                         v_Entity_Key
                    FROM tt_tmp_17 
                   WHERE  RecentRownumber = v_I
                    ORDER BY Entity_Key;
                  IF v_AccountId1 <> ' ' THEN

                  BEGIN
                     SELECT CustomerACID 

                       INTO v_AccountId
                       FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                      WHERE  CustomerACID = v_AccountId1;
                     IF v_AccountId = ' ' THEN

                     BEGIN
                        UPDATE UploadAcceleratedProvision
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID is invalid. Kindly check the entered Account ID'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID is invalid. Kindly check the entered Account ID'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                                  END
                         WHERE  Entity_Key = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  IF v_CustomerId1 <> ' ' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('Sachin');
                     SELECT CustomerId 

                       INTO v_CustomerId
                       FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
                      WHERE  CustomerId = v_CustomerId1;
                     IF v_CustomerId = ' ' THEN

                     BEGIN
                        DBMS_OUTPUT.PUT_LINE('@CustomerIdAf');
                        DBMS_OUTPUT.PUT_LINE(v_CustomerId);
                        UPDATE UploadAcceleratedProvision
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is invalid. Kindly check the entered Customer ID'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID is invalid. Kindly check the entered Customer ID'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerId'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerId'
                                  END
                         WHERE  Entity_Key = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  IF v_UCIC1 <> ' ' THEN

                  BEGIN
                     SELECT UCIF_ID 

                       INTO v_UCIC
                       FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
                      WHERE  UCIF_ID = v_UCIC1;
                     IF v_UCIC = ' ' THEN

                     BEGIN
                        UPDATE UploadAcceleratedProvision
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN '	  UCIC is invalid. Kindly check the entered UCIC'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '	  UCIC is invalid. Kindly check the entered UCIC'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account ID'
                                  END
                         WHERE  Entity_Key = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  v_I := v_I + 1 ;
                  v_CustomerId := ' ' ;
                  v_UCIC := ' ' ;
                  v_AccountId := ' ' ;
                  v_CustomerID1 := ' ' ;
                  v_UCIC1 := ' ' ;
                  v_AccountId1 := ' ' ;

               END;
            END LOOP;
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
                                     WHERE  EffectiveFromTimeKey <= v_Timekey
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
                               WHERE  EffectiveFromTimeKey <= v_Timekey
                                        AND EffectiveToTimeKey >= v_Timekey
                                        AND AuthorisationStatus IN ( 'NP','MP','1A' )
             )
            ;
            -------------------------------------------------------------------------
            ----------------------------------------------
            /*validations on Secured/Unsecured*/
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
            -----------------------------------------------------------------
            /*-------------------Additional Prov for ACCT ID (Rs.)------------------------- */
            -- changes done on 19-03-21 Pranay 
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
            --------------------------------------------------------------------------------------------------------------------
            ---------------------Business Segment-----------------------
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
                                                                WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                                                         AND A.EffectiveToTimeKey >= v_TimeKey ) C   ON A.BusinessSegment = C.AcBuSegmentCode
                                             WHERE  C.AcBuSegmentCode IS NULL )
               ;

            END;
            END IF;
            ----------------------------------------------------------------------------------------------------------------------
            ---------------------Asset Classification-----------------------
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
                                                                    WHERE  EffectiveFromTimeKey <= v_Timekey
                                                                             AND EffectiveToTimeKey >= v_Timekey ) C   ON A.AssetClassification = C.AssetClassAlt_Key
                                                 WHERE  C.AssetClassAlt_Key IS NULL )
               ;

            END;
            END IF;
            IF  --SQLDEV: NOT RECOGNIZED
            IF tt_tmp_173  --SQLDEV: NOT RECOGNIZED
            DELETE FROM tt_tmp3_10;
            UTILS.IDENTITY_RESET('tt_tmp3_10');

            INSERT INTO tt_tmp3_10 ( 
            	SELECT D.AccountID ,
                    COUNT(1)  CountRecord  
            	  FROM UploadAcceleratedProvision D
                      JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A   ON D.AccountID = A.CustomerACID
                      LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail B   ON A.CustomerEntityId = B.CustomerEntityId
            	 WHERE  B.Cust_AssetClassAlt_Key = D.AssetClassification
                       AND A.FlgSecured = CASE 
                                               WHEN SecuredUnsecured = 'Secured' THEN 'S'
                                               WHEN SecuredUnsecured = 'Unsecured' THEN 'U'   END
                       AND D.AccountID <> ' '
                       AND A.segmentcode IN ( SELECT AcBuSegmentCode 
                                              FROM DimAcBuSegment A
                                                     JOIN UploadAcceleratedProvision Z   ON A.AcBuRevisedSegmentCode = Z.BusinessSegment )

            	  GROUP BY D.AccountID );
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
                                                 FROM tt_tmp3_10  )

              AND NVL(AccountID, ' ') <> ' ';
            IF  --SQLDEV: NOT RECOGNIZED
            IF tt_tmp_171  --SQLDEV: NOT RECOGNIZED
            DELETE FROM tt_tmp1_16;
            UTILS.IDENTITY_RESET('tt_tmp1_16');

            INSERT INTO tt_tmp1_16 ( 
            	SELECT D.CustomerID ,
                    COUNT(1)  CountRecord  
            	  FROM UploadAcceleratedProvision D
                      JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON D.CustomerID = B.CustomerId
                      JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A   ON A.CustomerEntityId = B.CustomerEntityId
                      LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail C   ON A.CustomerEntityId = C.CustomerEntityId
            	 WHERE  C.Cust_AssetClassAlt_Key = D.AssetClassification
                       AND A.FlgSecured = CASE 
                                               WHEN SecuredUnsecured = 'Secured' THEN 'S'
                                               WHEN SecuredUnsecured = 'Unsecured' THEN 'U'   END
                       AND D.CustomerID <> ' '
                       AND A.segmentcode IN ( SELECT AcBuSegmentCode 
                                              FROM DimAcBuSegment A
                                                     JOIN UploadAcceleratedProvision Z   ON A.AcBuRevisedSegmentCode = Z.BusinessSegment )

            	  GROUP BY D.CustomerID );
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
                                                  FROM tt_tmp1_16  )

              AND NVL(CustomerID, ' ') <> ' ';
            IF  --SQLDEV: NOT RECOGNIZED
            IF tt_tmp_172  --SQLDEV: NOT RECOGNIZED
            DELETE FROM tt_tmp2_25;
            UTILS.IDENTITY_RESET('tt_tmp2_25');

            INSERT INTO tt_tmp2_25 ( 
            	SELECT D.UCIC ,
                    COUNT(1)  CountRecord  
            	  FROM UploadAcceleratedProvision D
                      JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON D.UCIC = B.UCIF_ID
                      JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A   ON A.CustomerEntityId = B.CustomerEntityId
                      LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustNpaDetail C   ON A.CustomerEntityId = C.CustomerEntityId
            	 WHERE  C.Cust_AssetClassAlt_Key = D.AssetClassification
                       AND A.FlgSecured = CASE 
                                               WHEN SecuredUnsecured = 'Secured' THEN 'S'
                                               WHEN SecuredUnsecured = 'Unsecured' THEN 'U'   END
                       AND D.UCIC <> ' '
                       AND A.segmentcode IN ( SELECT AcBuSegmentCode 
                                              FROM DimAcBuSegment A
                                                     JOIN UploadAcceleratedProvision Z   ON A.AcBuRevisedSegmentCode = Z.BusinessSegment )

            	  GROUP BY D.UCIC );
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
                                            FROM tt_tmp2_25  )

              AND NVL(UCIC, ' ') <> ' ';
            -----------------------------------------------------------------------
            ---------------------------------------------------
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
               --DELETE FROM AccountLevelApproachUpload_stg
               --WHERE filname=@FilePathUpload
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCELERATEDPROVISIONUPLOAD_03052022" TO "ADF_CDR_RBL_STGDB";
