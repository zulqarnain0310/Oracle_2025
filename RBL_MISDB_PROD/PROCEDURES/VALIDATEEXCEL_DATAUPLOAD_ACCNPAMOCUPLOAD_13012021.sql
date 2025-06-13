--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'AccountMOCUpload.xlsx' 
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
         --  DECLARE @DepartmentId SMALLINT ,@DepartmentCode varchar(100)  
         --SELECT  @DepartmentId= DepartmentId FROM dbo.DimUserInfo   
         --WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey  
         --AND UserLoginID = @UserLoginId  
         --PRINT @DepartmentId  
         --PRINT @DepartmentCode  
         --SELECT @DepartmentCode=DepartmentCode FROM AxisIntReversalDB.DimDepartment   
         --    WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey   
         --    --AND DepartmentCode IN ('BBOG','FNA')  
         --    AND DepartmentAlt_Key = @DepartmentId  
         --    print @DepartmentCode  
         --Select @DepartmentCode=REPLACE('',@DepartmentCode,'_')  
         v_FilePathUpload VARCHAR2(100);
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         --BEGIN TRAN  
         --Declare @TimeKey int  
         --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
         --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
         -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
         -- SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
         --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   
         SELECT Timekey 

           INTO v_Timekey
           FROM SysDataMatrix 
          WHERE  MOC_Initialised = 'Y'
                   AND NVL(MOC_Frozen, 'N') = 'N';
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
         IF ( v_MenuID = 24715 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on SlNo*/
            v_DuplicateCnt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadAccMOCPool') IS NOT NULL  
            IF utils.object_id('UploadAccMOCPool') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadAccMOCPool';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM AccountLvlMOCDetails_stg 
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
                 ( SELECT 0 SlNo  ,
                          ' ' ColumnName  ,
                          'No Record found' ErrorData  ,
                          'No Record found' ErrorType  ,
                          v_filepath ,
                          'SUCCESS' 
                     FROM DUAL  );
               --SELECT 0 SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
               GOTO errordata;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DATA PRESENT');
               DELETE FROM UploadAccMOCPool;
               UTILS.IDENTITY_RESET('UploadAccMOCPool');

               INSERT INTO UploadAccMOCPool SELECT * ,
                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM AccountLvlMOCDetails_stg 
                   WHERE  filname = v_FilePathUpload;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.SourceAlt_Key
               FROM A ,UploadAccMOCPool A
                      JOIN DIMSOURCEDB B   ON A.SourceSystem = B.SourceName ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.SourceAlt_Key = src.SourceAlt_Key;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            ----SELECT * FROM UploadAccMOCPool
            --SlNo	Territory	ACID	InterestReversalAmount	filename
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'SlNo,Account ID,POS,Interest Receivable,Balances,Dates',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') = ' '
              AND NVL(AccountID, ' ') = ' '
              AND NVL(POSinRs, ' ') = ' '
              AND NVL(InterestReceivableinRs, ' ') = ' '
              AND NVL(AdditionalProvisionAbsoluteinRs, ' ') = ' '

              --AND ISNULL(RestructureFlagYN,'')=''

              --AND ISNULL(RestructureDate,'')=''
              AND NVL(FITLFlagYN, ' ') = ' '
              AND NVL(DFVAmount, ' ') = ' '
              AND NVL(RePossesssionFlagYN, ' ') = ' '
              AND NVL(RePossessionDate, ' ') = ' '
              AND NVL(InherentWeaknessFlag, ' ') = ' '
              AND NVL(InherentWeaknessDate, ' ') = ' '
              AND NVL(SARFAESIFlag, ' ') = ' '
              AND NVL(SARFAESIDate, ' ') = ' '
              AND NVL(UnusualBounceFlag, ' ') = ' '
              AND NVL(UnusualBounceDate, ' ') = ' '
              AND NVL(UnclearedEffectsFlag, ' ') = ' '
              AND NVL(UnclearedEffectsDate, ' ') = ' '
              AND NVL(FraudFlag, ' ') = ' '
              AND NVL(FraudDate, ' ') = ' '
              AND NVL(MOCSource, ' ') = ' '
              AND NVL(MOCReason, ' ') = ' ';
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Excel Vaildate '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Excel Vaildate'
                      END,
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') <> ' '
              AND NVL(POSinRs, ' ') = ' '
              AND NVL(InterestReceivableinRs, ' ') = ' '
              AND NVL(AdditionalProvisionAbsoluteinRs, ' ') = ' '

              --AND ISNULL(RestructureFlagYN,'')=''

              --AND ISNULL(RestructureDate,'')=''
              AND NVL(FITLFlagYN, ' ') = ' '
              AND NVL(DFVAmount, ' ') = ' '
              AND NVL(RePossesssionFlagYN, ' ') = ' '
              AND NVL(RePossessionDate, ' ') = ' '
              AND NVL(InherentWeaknessFlag, ' ') = ' '
              AND NVL(InherentWeaknessDate, ' ') = ' '
              AND NVL(SARFAESIFlag, ' ') = ' '
              AND NVL(SARFAESIDate, ' ') = ' '
              AND NVL(UnusualBounceFlag, ' ') = ' '
              AND NVL(UnusualBounceDate, ' ') = ' '
              AND NVL(UnclearedEffectsFlag, ' ') = ' '
              AND NVL(UnclearedEffectsDate, ' ') = ' '
              AND NVL(FraudFlag, ' ') = ' '
              AND NVL(FraudDate, ' ') = ' '
              AND NVL(MOCSource, ' ') = ' '
              AND NVL(MOCReason, ' ') = ' ';
            --WHERE ISNULL(V.SlNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filename,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadAccMOCPool 
                                WHERE  NVL(ErrorMessage, ' ') <> ' ' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('NO DATA');
               GOTO ERRORDATA;

            END;
            END IF;
            /*validations on SourceSystem*/
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID not existing with Source System; Please check and upload again.'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID not existing with Source System; Please check and upload again.'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SourceSystem/AccountID'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SourceSystem/AccountID'
               END AS pos_3, V.AccountID
            FROM UploadAccMOCPool V
                   LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON V.SourceAlt_Key = B.SourceAlt_Key
                   AND V.AccountID = B.CustomerAcID
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_Timekey 
             WHERE ( NVL(B.SourceAlt_Key, ' ') = ' '
              OR NVL(B.CustomerAcID, ' ') = ' ' )) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.AccountID;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') = ' '
              OR NVL(SlNo, '0') = '0';
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(SlNo) > 16;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(SlNo) = 0
              AND NVL(SlNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SlNo), '%^[0-9]%');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(SlNo, ' '), '%[,!@#$%^&*()_-+=/]%- \ / _');
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM UploadAccMOCPool 
              GROUP BY SlNo

               HAVING COUNT(SlNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Sl. No., kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') IN ( SELECT SlNo 
                                        FROM UploadAccMOCPool 
                                          GROUP BY SlNo

                                           HAVING COUNT(SlNo)  > 1 )
            ;
            END IF;
            ------------------------------------------------
            /*VALIDATIONS ON AccountID */
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountID, ' ') = ' ';
            -- ----SELECT * FROM UploadAccMOCPool
            UPDATE UploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.AccountID, ' ') <> ' '
              AND V.AccountID NOT IN ( SELECT CustomerACID 
                                       FROM AdvAcBasicDetail 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
            ;
            IF utils.object_id('TEMPDB..tt_DUB2_3') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_3 ';
            END IF;
            DELETE FROM tt_DUB2_3;
            UTILS.IDENTITY_RESET('tt_DUB2_3');

            INSERT INTO tt_DUB2_3 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountID ORDER BY AccountID  ) rw  
                        FROM UploadAccMOCPool  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate Account ID found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Account ID found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'Account ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
               END AS pos_3, V.SlNo
            FROM V ,UploadAccMOCPool V
                   JOIN tt_DUB2_3 D   ON D.AccountID = V.AccountID ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            ---------------------Authorization for Screen Same acc ID --------------------------
            UPDATE UploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.AccountID, ' ') <> ' '
              AND V.AccountID IN ( SELECT AccountID 
                                   FROM AccountLevelMOC_Mod 
                                    WHERE  EffectiveFromTimeKey <= v_Timekey
                                             AND EffectiveToTimeKey >= v_Timekey
                                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                             AND NVL(Screenflag, ' ') <> 'U' )
            ;
            ---------------------------------------------------------------------------Upload for same account ID--------------
            UPDATE UploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC Upload– Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC Upload– Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.AccountID, ' ') <> ' '
              AND V.AccountID IN ( SELECT AccountID 
                                   FROM AccountLevelMOC_Mod 
                                    WHERE  EffectiveFromTimeKey <= v_Timekey
                                             AND EffectiveToTimeKey >= v_Timekey
                                             AND AuthorisationStatus IN ( 'NP','MP','1A','FM' )

                                             AND NVL(Screenflag, ' ') = 'U' )
            ;
            ---------------------------------------
            /*VALIDATIONS ON POS in Rs */
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid POSinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid POSinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'POSinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'POSinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(POSinRs) = 0
              AND NVL(POSinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(POSinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid POSinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid POSinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'POSinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'POSinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(POSinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘POS in Rs.’. Kindly check and upload value'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘POS in Rs.’. Kindly check and upload value'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'POSinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'POSinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(POSinRs, ' ') <> ' '
              AND ( INSTR(NVL(POSinRs, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(POSinRs, ' '), -LENGTH(NVL(POSinRs, ' ')) - INSTR(NVL(POSinRs, ' '), '.'), LENGTH(NVL(POSinRs, ' ')) - INSTR(NVL(POSinRs, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            /*validations on MOC Reason */
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid MOC Reason. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid MOC Reasons. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(MOCReason, ' ') NOT IN ( 'Wrong UCIC Linkage','DPD Freeze','Wrong recovery appropriation in source system','Exceptional issue, requires IAD concurrence','Advances Adjustment','Security Value Update','CNPA','Restructure','Portfolio Buyout-Requires IAD Concurrence','NPA Date update','Litigation','NPA Settlement','Standard Settlement','Erosion in Security Value','Sale of Assets','RFA/Fraud','Additional Provision','NPA Divergence' )
            ;
            ---------------------------------------------------------
            /*validations on InterestReceivableinRs */
            -- UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InterestReceivableinRs cannot be blank. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'InterestReceivableinRs cannot be blank. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE ISNULL(InterestReceivableinRs,'')=''
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(InterestReceivableinRs) = 0
              AND NVL(InterestReceivableinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(InterestReceivableinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(InterestReceivableinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestReceivableinRs, ' ') <> ' '
              AND ( INSTR(NVL(InterestReceivableinRs, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(InterestReceivableinRs, ' '), -LENGTH(NVL(InterestReceivableinRs, ' ')) - INSTR(NVL(InterestReceivableinRs, ' '), '.'), LENGTH(NVL(InterestReceivableinRs, ' ')) - INSTR(NVL(InterestReceivableinRs, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            /*validations on Additional Provision - Absolute in Rs. */
            -- UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Additional Provision - Absolute in Rs.’. Kindly check and upload value'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Additional Provision - Absolute in Rs.’. Kindly check and upload value'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE ISNULL(AdditionalProvisionAbsoluteinRs,'')=''
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AdditionalProvisionAbsoluteinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AdditionalProvisionAbsoluteinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(AdditionalProvisionAbsoluteinRs) = 0
              AND NVL(AdditionalProvisionAbsoluteinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(AdditionalProvisionAbsoluteinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AdditionalProvisionAbsoluteinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AdditionalProvisionAbsoluteinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(AdditionalProvisionAbsoluteinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AdditionalProvisionAbsoluteinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AdditionalProvisionAbsoluteinRs'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AdditionalProvisionAbsoluteinRs, ' ') <> ' '
              AND ( INSTR(NVL(AdditionalProvisionAbsoluteinRs, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(AdditionalProvisionAbsoluteinRs, ' '), -LENGTH(NVL(AdditionalProvisionAbsoluteinRs, ' ')) - INSTR(NVL(AdditionalProvisionAbsoluteinRs, ' '), '.'), LENGTH(NVL(AdditionalProvisionAbsoluteinRs, ' ')) - INSTR(NVL(AdditionalProvisionAbsoluteinRs, ' '), '.'))) <> 2 );
            --------------------------RESTRUCTURE FLAG ---------------------------------------
            -- UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘Restructure Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Restructure Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE ErrorinColumn +','+SPACE(1)+  'RestructureFlag' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE ISNULL(RestructureFlagYN,'') NOT IN('Y','N') AND  ISNULL(RestructureFlagYN,'')<>''
            --UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is already marked with the Restructured flag. You can only remove the marked flag for this account'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Account is already marked with the Restructured flag. You can only remove the marked flag for this account'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFlag' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- Inner Join PRO.AccountCal_Hist  A ON V.AccountID=A.CustomerAcID And A.EffectiveToTimeKey=49999
            -- WHERE ISNULL(A.FlgRestructure,'') ='Y'
            --UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not marked to the Restructured flag. You can only add the marked flag for this account'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Account is not marked to the Restructured flag. You can only add the marked flag for this account'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFlag' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadAccMOCPool V  
            --Inner Join PRO.AccountCal_Hist  A ON V.AccountID=A.CustomerAcID And A.EffectiveToTimeKey=49999
            -- WHERE ISNULL(A.FlgRestructure,'') ='N'
            -----------------------------------------------------------------
            /*validations on Restructure Date */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'RestructureDate Can not be Blank . Please enter the RestructureDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'RestructureDate Can not be Blank. Please enter the RestructureDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(RestructureDate,'')='' 
            -- SET DATEFORMAT DMY
            --UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE ISNULL(RestructureDate,'')<>'' AND ISDATE(RestructureDate)=0
            --  Set DateFormat DMY
            -- UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Restructure date must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Restructure date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE (Case When ISDATE(RestructureDate)=1 Then Case When Cast(RestructureDate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1
            --  UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Restructure Date is mandatory when value ‘Y’ is entered in column ‘Restructure Flag'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Restructure Date is mandatory when value ‘Y’ is entered in column ‘Restructure Flag'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE ISNULL(RestructureFlagYN,'') IN('Y') AND ISNULL(RestructureDate,'' )=''
            --------------------------FITLFLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘FITL Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘FITL Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FITLFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FITLFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(FITLFlagYN, ' ') NOT IN ( 'Y','N' )

              AND NVL(FITLFlagYN, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the FITL flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the FITL flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FITLFLAG'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FITLFLAG'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'') 

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FLGFITL, ' ') = 'Y'
              AND NVL(V.FITLFlagYN, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the FITL flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the FITL flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FITL'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FITL'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FLGFITL, ' ') = 'N'
              AND NVL(V.FITLFlagYN, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*validations on DFVAmount */
            -- UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘DFVAmount’. Kindly check and upload value'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘DFVAmount’. Kindly check and upload value'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DFVAmount' ELSE ErrorinColumn +','+SPACE(1)+  'DFVAmount' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadAccMOCPool V  
            -- WHERE ISNULL(DFVAmount,'')=''
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DFVAmount Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DFVAmount Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVAmount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVAmount'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(DFVAmount) = 0
              AND NVL(DFVAmount, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(DFVAmount), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DFVAmount Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DFVAmount Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVAmount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVAmount'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(DFVAmount, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DFVAmount Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DFVAmount Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVAmount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVAmount'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(DFVAmount, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND ( INSTR(NVL(DFVAmount, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(DFVAmount, ' '), -LENGTH(NVL(DFVAmount, ' ')) - INSTR(NVL(DFVAmount, ' '), '.'), LENGTH(NVL(DFVAmount, ' ')) - INSTR(NVL(DFVAmount, ' '), '.'))) <> 2 );
            --------------------------Repossesion  FLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Repossesion Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Repossesion Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossesssionFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossesssionFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(RePossesssionFlagYN, ' ') NOT IN ( 'Y','N' )

              AND NVL(RePossesssionFlagYN, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the Repossesion flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the Repossesion flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossesssionFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossesssionFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.RePossession, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the Re-Possession flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the Re-Possession flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossesssionFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossesssionFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.RePossession, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            -----------------------------------------------------------------
            /*validations on RePossessionDate */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'RePossessionDate Can not be Blank . Please enter the RePossessionDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'RePossessionDate Can not be Blank. Please enter the RePossessionDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RePossessionDate' ELSE   ErrorinColumn +','+SPACE(1)+'RePossessionDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(RePossessionDate,'')='' 
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossessionDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossessionDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(RePossessionDate, ' ') <> ' '
              AND utils.isdate(RePossessionDate) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'RePossession date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'RePossession date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossessionDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossessionDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(RePossessionDate) = 1 THEN CASE 
                                                                            WHEN UTILS.CONVERT_TO_VARCHAR2(RePossessionDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Re-Possession Date is mandatory when value ‘Y’ is entered in column ‘Re-Possession Flag'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Re-Possession Date is mandatory when value ‘Y’ is entered in column ‘Re-Possession Flag'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossessionDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossessionDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(RePossesssionFlagYN, ' ') = 'Y'
              AND NVL(RePossessionDate, ' ') = ' ';
            --------------------------Inherent Weakness FLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Inherent Weakness Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Inherent Weakness Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InherentWeaknessFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InherentWeaknessFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InherentWeaknessFLAG, ' ') NOT IN ( 'Y','N' )

              AND NVL(InherentWeaknessFLAG, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the Inherent Weakness flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the Inherent Weakness flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InherentWeaknessFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InherentWeaknessFLAG'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.WeakAccount, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the Inherent Weakness flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the Inherent Weakness flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InherentWeaknessFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InherentWeaknessFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.WeakAccount, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            -----------------------------------------------------------------
            /*validations on InherentWeaknessDate */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InherentWeaknessDate Can not be Blank . Please enter the InherentWeaknessDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'InherentWeaknessDate Can not be Blank. Please enter the InherentWeaknessDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InherentWeaknessDate' ELSE   ErrorinColumn +','+SPACE(1)+'InherentWeaknessDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(InherentWeaknessDate,'')='' 
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InherentWeaknessDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InherentWeaknessDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(InherentWeaknessDate, ' ') <> ' '
              AND utils.isdate(InherentWeaknessDate) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'InherentWeakness date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'InherentWeakness date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InherentWeaknessDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InherentWeaknessDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(InherentWeaknessDate) = 1 THEN CASE 
                                                                                WHEN UTILS.CONVERT_TO_VARCHAR2(InherentWeaknessDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Inherent Weakness Date is mandatory when value ‘Y’ is entered in column ‘Inherent Weakness Flag'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Inherent Weakness Date is mandatory when value ‘Y’ is entered in column ‘Inherent Weakness Flag'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InherentWeaknessDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InherentWeaknessDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(InherentWeaknessFlag, ' ') = 'Y'
              AND NVL(InherentWeaknessDate, ' ') = ' ';
            --------------------------SARFAESI FLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘SARFAESI Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘SARFAESI Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SARFAESIFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SARFAESIFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(SARFAESIFLAG, ' ') NOT IN ( 'Y','N' )

              AND NVL(SARFAESIFLAG, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the SARFAESI flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the SARFAESI flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SARFAESIFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SARFAESIFLAG'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.Sarfaesi, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the SARFAESI flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the SARFAESI flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SARFAESIFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SARFAESIFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.Sarfaesi, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            -----------------------------------------------------------------
            /*validations on SARFAESIDate */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SARFAESIDate Can not be Blank . Please enter the SARFAESIDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'SARFAESIDate Can not be Blank. Please enter the SARFAESIDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SARFAESIDate' ELSE   ErrorinColumn +','+SPACE(1)+'SARFAESIDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(SARFAESIDate,'')='' 
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SARFAESIDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SARFAESIDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(SARFAESIDate, ' ') <> ' '
              AND utils.isdate(SARFAESIDate) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SARFAESI date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SARFAESI date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SARFAESIDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SARFAESIDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(SARFAESIDate) = 1 THEN CASE 
                                                                        WHEN UTILS.CONVERT_TO_VARCHAR2(SARFAESIDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SARFAESI Date is mandatory when value ‘Y’ is entered in column ‘SARFAESI Flag'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SARFAESI Date is mandatory when value ‘Y’ is entered in column ‘SARFAESI Flag'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RePossessionDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RePossessionDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(SARFAESIFlag, ' ') = 'Y'
              AND NVL(SARFAESIDate, ' ') = ' ';
            --------------------------UnusualBounce FLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘UnusualBounce Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘UnusualBounce Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnusualBounceFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnusualBounceFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(UnusualBounceFLAG, ' ') NOT IN ( 'Y','N' )

              AND NVL(UnusualBounceFLAG, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the UnusualBounce flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the UnusualBounce flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnusualBounceFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnusualBounceFLAG'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FlgUnusualBounce, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the UnusualBounce flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the UnusualBounce flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnusualBounceFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnusualBounceFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FlgUnusualBounce, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            -----------------------------------------------------------------
            /*validations on UnusualBounceDate */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UnusualBounceDate Can not be Blank . Please enter the UnusualBounceDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'UnusualBounceDate Can not be Blank. Please enter the UnusualBounceDate and upload again'    END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UnusualBounceDate' ELSE   ErrorinColumn +','+SPACE(1)+'UnusualBounceDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(UnusualBounceDate,'')='' 
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnusualBounceDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnusualBounceDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(UnusualBounceDate, ' ') <> ' '
              AND utils.isdate(UnusualBounceDate) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UnusualBounce date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UnusualBounce date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnusualBounceDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnusualBounceDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(UnusualBounceDate) = 1 THEN CASE 
                                                                             WHEN UTILS.CONVERT_TO_VARCHAR2(UnusualBounceDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Unusual Bounce Date is mandatory when value ‘Y’ is entered in column ‘Unusual Bounce Flag'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Unusual Bounce Date is mandatory when value ‘Y’ is entered in column ‘Unusual Bounce Flag'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnusualBounceDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnusualBounceDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(UnusualBounceFlag, ' ') = 'Y'
              AND NVL(UnusualBounceDate, ' ') = ' ';
            --------------------------UnclearedEffects FLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘UnclearedEffects Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘UnclearedEffects Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnclearedEffectsFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffectsFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(UnclearedEffectsFLAG, ' ') NOT IN ( 'Y','N' )

              AND NVL(UnclearedEffectsFLAG, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the UnclearedEffects flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the UnclearedEffects flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnclearedEffectsFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffectsFLAG'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FlgUnClearedEffect, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the UnclearedEffects flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the UnclearedEffects flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnclearedEffectsFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffectsFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FlgUnClearedEffect, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            -----------------------------------------------------------------
            /*validations on UnclearedEffectsDate */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UnclearedEffectsDate Can not be Blank . Please enter the UnclearedEffectsDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'UnclearedEffectsDate Can not be Blank. Please enter the UnclearedEffectsDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UnclearedEffectsDate' ELSE   ErrorinColumn +','+SPACE(1)+'UnclearedEffectsDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(UnclearedEffectsDate,'')='' 
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnclearedEffectsDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffectsDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(UnclearedEffectsDate, ' ') <> ' '
              AND utils.isdate(UnclearedEffectsDate) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UnclearedEffects date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffects date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnclearedEffectsDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffectsDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(UnclearedEffectsDate) = 1 THEN CASE 
                                                                                WHEN UTILS.CONVERT_TO_VARCHAR2(UnclearedEffectsDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Uncleared Effects Date is mandatory when value ‘Y’ is entered in column ‘Uncleared Effects Flag’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Uncleared Effects Date is mandatory when value ‘Y’ is entered in column ‘Uncleared Effects Flag’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnclearedEffectsDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnclearedEffectsDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(UnclearedEffectsFLAG, ' ') = 'Y'
              AND NVL(UnclearedEffectsDate, ' ') = ' ';
            --------------------------Fraud FLAG ---------------------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Fraud Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Fraud Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(FraudFLAG, ' ') NOT IN ( 'Y','N' )

              AND NVL(FraudFLAG, ' ') <> ' ';
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already marked with the Fraud flag. You can only remove the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already marked with the Fraud flag. You can only remove the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudFLAG'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FlgFraud, ' ') = 'Y') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the Fraud flag. You can only add the marked flag for this account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the Fraud flag. You can only add the marked flag for this account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudFlag'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudFlag'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist A   ON V.AccountID = A.CustomerAcID
                   AND A.EffectiveToTimeKey = 49999 
             WHERE NVL(A.FlgFraud, ' ') = 'N') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            -----------------------------------------------------------------
            /*validations on FraudDate */
            --UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'FraudDate Can not be Blank . Please enter the FraudDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'FraudDate Can not be Blank. Please enter the FraudDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM UploadAccMOCPool V  
            --WHERE ISNULL(FraudDate,'')='' 
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(FraudDate, ' ') <> ' '
              AND utils.isdate(FraudDate) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Fraud date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Fraud date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(FraudDate) = 1 THEN CASE 
                                                                     WHEN UTILS.CONVERT_TO_VARCHAR2(FraudDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Fraud Date is mandatory when value ‘Y’ is entered in column ‘Fraud Flag'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Fraud Date is mandatory when value ‘Y’ is entered in column ‘Fraud Flag'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(FraudFlag, ' ') = 'Y'
              AND NVL(FraudDate, ' ') = ' ';
            ---------------------------------MOC Source---------------------------
            MERGE INTO UploadAccMOCPool V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the 










            column'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCSource'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCSource'
               END AS pos_3, V.SlNo
            --STUFF((SELECT ','+SlNo 
             --						FROM #UploadNewAccount A
             --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadAccMOCPool V
                   LEFT JOIN DimMOCType a   ON v.MOCSource = A.MOCTypeName 
             WHERE A.MOCTypeName IS NULL) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            -----------------------------------MOC Reason-------------------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC Reason Can not be Blank . Please enter the MOC Reason and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC Reason Can not be Blank. Please enter the MOC Reason and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(MOCReason, ' ') = ' ';
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC reason cannot be greater than 500 characters'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC reason cannot be greater than 500 characters'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  LENGTH(MOCReason) > 500;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  REGEXP_LIKE(LENGTH(MOCReason), '%[!@#$%^&*()_+=]%');
            ---------------------------Validations on TWO Flag
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘TWO Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘TWO Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TwoFlag'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TwoFlag'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(TWOFlag, ' ') NOT IN ( 'Y','N' )

              AND NVL(TWOFlag, ' ') <> ' ';
            /*VALIDATIONS ON TWO Date */
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TwoDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TwoDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(TWODate, ' ') <> ' '
              AND utils.isdate(TWODate) = 0;
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘TWO Date’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘TWO Date’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TWO Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TWO Date'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(Twodate, ' ') = ' '
              AND NVL(TWOFlag, ' ') = 'Y';
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'TWO date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'TWO date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TwoDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TwoDate'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(Twodate) = 1 THEN CASE 
                                                                   WHEN UTILS.CONVERT_TO_VARCHAR2(Twodate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            -------------------------------Validations on TWO Amount-----------------
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid TWOAmount Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid TWOAmount Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TWOAmount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TWOAmount'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(TWOAmount) = 0
              AND NVL(TWOAmount, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(TWOAmount), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid TWOAmount. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid TWOAmount. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TWOAmount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TWOAmount'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(TWOAmount, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadAccMOCPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid TWOAmount. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid TWOAmount. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TWOAmount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TWOAmount'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(TWOAmount, ' ') <> ' '
              AND ( INSTR(NVL(TWOAmount, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(TWOAmount, ' '), -LENGTH(NVL(TWOAmount, ' ')) - INSTR(NVL(TWOAmount, ' '), '.'), LENGTH(NVL(TWOAmount, ' ')) - INSTR(NVL(TWOAmount, ' '), '.'))) <> 2 );
            ----------------------------------------------
            /*validations on SourceSystem*/
            --    Declare @DuplicateSourceSystemDataInt int=0
            --	IF OBJECT_ID('SourceSystemData') IS NOT NULL  
            --	  BEGIN  
            --	   DROP TABLE SourceSystemData 
            --	  END
            --	   SELECT * into SourceSystemData  FROM(
            -- SELECT ROW_NUMBER() OVER(PARTITION BY SourceSystem  ORDER BY  SourceSystem ) 
            -- ROW ,SourceSystem FROM UploadAccMOCPool
            --)X
            -- WHERE ROW=1
            --  SELECT  @DuplicateSourceSystemDataInt=COUNT(*) FROM UploadAccMOCPool A
            -- Left JOIN DIMSOURCEDB B
            -- ON  A.SourceSystem=B.SourceName
            -- Where B.SourceName IS NULL
            --    IF @DuplicateSourceSystemDataInt>0
            --	BEGIN
            --	       UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the co
            --lumn'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
            --        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem' END     
            --		,Srnooferroneousrows=V.SlNo
            --		 FROM UploadAccMOCPool V  
            -- WHERE ISNULL(SourceSystem,'')<>''
            -- AND  V.SourceSystem IN(
            --                     SELECT  A.SourceSystem FROM UploadAccMOCPool A
            --					 Left JOIN DIMSOURCEDB B
            --					 ON  A.SourceSystem=B.SourceName
            --					 Where B.SourceName IS NULL
            --                 )
            --	END
            -----------------------------------------------------------
            --select * from DimMOCType
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
                                FROM AccountLvlMOCDetails_stg 
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
              ( SELECT ' ' SlNo  ,
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
            INSERT INTO RBL_MISDB_PROD.MasterUploadData
              ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Srnooferroneousrows, Flag )
              ( SELECT SlNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM UploadAccMOCPool  );
            --	----SELECT * FROM UploadAccMOCPool 
            --	--ORDER BY ErrorMessage,UploadAccMOCPool.ErrorinColumn DESC
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
         DBMS_OUTPUT.PUT_LINE('Jayadev');
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
            DBMS_OUTPUT.PUT_LINE('Jayadev1');
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

            BEGIN
               DELETE AccountLvlMOCDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE('Jayadev2');
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadAccMOCPool
         DBMS_OUTPUT.PUT_LINE('p');

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ------to delete file if it has errors
      --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
      --begin
      --print 'ppp'
      -- IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
      -- BEGIN
      -- print '123'
      -- DELETE FROM AccountLvlMOCDetails_stg
      -- WHERE filename=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- END
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
                 --	 BEGIN
                 --	 DELETE FROM AccountLvlMOCDetails_stg
                 --	 WHERE filename=@FilePathUpload
                 --	 PRINT 'ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                 ,--	 END
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCNPAMOCUPLOAD_13012021" TO "ADF_CDR_RBL_STGDB";
