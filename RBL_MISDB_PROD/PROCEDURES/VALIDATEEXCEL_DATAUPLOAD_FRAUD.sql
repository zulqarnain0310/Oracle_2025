--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_FRAUD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" 
(
  v_MenuID IN NUMBER DEFAULT 24738 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'mcheck1' ,
  iv_Timekey IN NUMBER DEFAULT 25999 ,
  v_filepath IN VARCHAR2 DEFAULT 'NPAFraudAccount.xlsx' 
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--DECLARE  
--@MenuID INT=24715,  
--@UserLoginId varchar(20)='lvl1admin',  
--@Timekey int=26085
--,@filepath varchar(500)='Fraud_AWupload (15).xlsx'  

BEGIN

   BEGIN
      DECLARE
         --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   
         v_DateOfData VARCHAR2(200);
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
         SELECT TimeKey 

           INTO v_Timekey
           FROM SysDataMatrix 
          WHERE  CurrentStatus = 'C';
         SELECT UTILS.CONVERT_TO_VARCHAR2(ExtDate,200) 

           INTO v_DateOfData
           FROM SysDataMatrix 
          WHERE  Timekey = v_Timekey;
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
         IF ( v_MenuID = 24738 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on SrNo*/
            v_DuplicateCnt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadAccMOCPool') IS NOT NULL  
            IF utils.object_id('UploadFraudPool') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadFraudPool';

            END;
            END IF;
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


            --SELECT * FROM AccountLvlMOCDetails_stg
            BEGIN
               DBMS_OUTPUT.PUT_LINE('NO DATA');
               INSERT INTO RBL_MISDB_PROD.MasterUploadData
                 ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Flag )
                 ( SELECT 0 SrNo  ,
                          ' ' ColumnName  ,
                          'No Record found' ErrorData  ,
                          'No Record found' ErrorType  ,
                          v_filepath ,
                          'SUCCESS' 
                     FROM DUAL  );
               --SELECT 0 SrNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
               GOTO errordata;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DATA PRESENT');
               DELETE FROM UploadFraudPool;
               UTILS.IDENTITY_RESET('UploadFraudPool');

               INSERT INTO UploadFraudPool SELECT * ,
                                                  UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                  UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                  UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM NPAFraudAccountUpload_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            --select * from UploadFraudPool
            ------------------------------------------------------------------------------ 
            DBMS_OUTPUT.PUT_LINE('Sudesh');
            ----SELECT * FROM UploadAccMOCPool
            --SrNo	Territory	AccountNumber	InterestReversalAmount	filename
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'SrNo,Account ID,RFA Reported by Bank,Date of RFA Reporting by Bank,Name of Other Bank Reporting RFA
                   ,Date of Reporting RFA by Other Bank,
                   		Date of Fraud Occurrence,Date of Fraud Declaration by RBL
                   ,Nature of Fraud,Areas of Operations,Post Fraud Flagging Asset Class,Provision Preference',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SrNo, ' ') = ' '
              AND NVL(AccountNumber, ' ') = ' '
              AND NVL(RFAreportedbyBank, ' ') = ' '
              AND NVL(DateofRFAreportingbyBank, ' ') = ' '
              AND NVL(NameofotherBankreportingRFA, ' ') = ' '
              AND NVL(DateofreportingRFAbyOtherBank, ' ') = ' '
              AND NVL(DateofFraudoccurrence, ' ') = ' '
              AND NVL(DateofFrauddeclarationbyRBL, ' ') = ' '
              AND NVL(NatureofFraud, ' ') = ' '
              AND NVL(AreasofOperations, ' ') = ' '
              AND NVL(Provisionpreference, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('JAGRUTI');
            --UPDATE UploadAccMOCPool
            --	SET  
            --        ErrorMessage= 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     
            --	,ErrorinColumn='no value for MOC'  
            --		,Srnooferroneousrows=''
            --   FROM UploadAccMOCPool V  
            -- WHERE 
            -- ISNULL(SrNo,'')<>''
            --AND ISNULL(POSinRs,'')=''
            --AND ISNULL(InterestReceivableinRs,'')=''
            ----AND ISNULL(AdditionalProvisionAbsoluteinRs,'')=''
            ----AND ISNULL(RestructureFlagYN,'')=''
            ----AND ISNULL(RestructureDate,'')=''
            --AND ISNULL(FITLFlagYN,'')=''
            --AND ISNULL(DFVAmount,'')=''
            ----AND ISNULL(MOCAdditionalProvisionalExpiryDate,'')=''
            --AND ISNULL(AdditionalProvision,'')=''
            ----AND ISNULL(RePossesssionFlagYN,'')=''
            ----AND ISNULL(RePossessionDate,'')=''
            ----AND ISNULL(InherentWeaknessFlag,'')=''
            ----AND ISNULL(InherentWeaknessDate,'')=''
            ----AND ISNULL(SARFAESIFlag,'')=''
            ----AND ISNULL(SARFAESIDate,'')=''
            ----AND ISNULL(UnusualBounceFlag,'')=''
            ----AND ISNULL(UnusualBounceDate,'')=''
            ----AND ISNULL(UnclearedEffectsFlag,'')=''
            ----AND ISNULL(UnclearedEffectsDate,'')=''
            --AND ISNULL(FraudFlag,'')=''
            --AND ISNULL(FraudDate,'')=''
            ----AND ISNULL(MOCSource,'')=''
            ----AND ISNULL(MOCReason,'')=''
            ----WHERE ISNULL(V.SrNo,'')=''
            ---- ----AND ISNULL(Territory,'')=''
            ---- AND ISNULL(AccountID,'')=''
            ---- AND ISNULL(PoolID,'')=''
            ---- AND ISNULL(filename,'')=''
            DBMS_OUTPUT.PUT_LINE('PRASHANT1');
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadFraudPool 
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
            DBMS_OUTPUT.PUT_LINE('PRASHANT2');
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(v.SrNo, ' ') = ' ';
            --   UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadAccMOCPool V  
            --WHERE (ISNULL(v.SrNo,'')<>'' or ISNULL(v.SrNo,0)=0)  -- OR ISNULL(v.SrNo,'')<0
            DBMS_OUTPUT.PUT_LINE('PRASHANT3');
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(SrNo) > 16;
            DBMS_OUTPUT.PUT_LINE('PRASHANT4');
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE --(ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR 
              REGEXP_LIKE(utils.isnumeric(SrNo), '%^[0-9]%');
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo

            -- WHERE ISNULL(SrNo,'') LIKE '%[,!@#$%^&*()_-+=/]%'
            WHERE  REGEXP_LIKE(NVL(SrNo, ' '), '%[^0-9a-zA-Z]%');
            --LIKE'%[,!@#$%^&*()_-+=/]%- \ / _%'
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM UploadFraudPool 
              GROUP BY SrNo

               HAVING COUNT(SrNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadFraudPool V
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
                                        FROM UploadFraudPool 
                                          GROUP BY SrNo

                                           HAVING COUNT(SrNo)  > 1 )
            ;
            END IF;
            ------------------------------------------------
            /*VALIDATIONS ON AccountID */
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AccountNumber, ' ') = ' ';
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(AccountNumber) > 20;
            -- ----SELECT * FROM UploadAccMOCPool
            UPDATE UploadFraudPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.AccountNumber, ' ') <> ' '
              AND V.AccountNumber NOT IN ( SELECT CustomerACID 
                                           FROM AdvAcBasicDetail 
                                            WHERE  EffectiveFromTimeKey <= v_Timekey
                                                     AND EffectiveToTimeKey >= v_Timekey )
            ;
            IF utils.object_id('TEMPDB..tt_DUB2_21') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_21 ';
            END IF;
            DELETE FROM tt_DUB2_21;
            UTILS.IDENTITY_RESET('tt_DUB2_21');

            INSERT INTO tt_DUB2_21 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountNumber ORDER BY AccountNumber  ) rw  
                        FROM UploadFraudPool  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate Account ID found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Account ID found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'Account ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
               END AS pos_3, V.SrNo
            FROM V ,UploadFraudPool V
                   JOIN tt_DUB2_21 D   ON D.AccountNumber = V.AccountNumber ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SrNo;
            ---------------------Authorization for Screen Same acc ID --------------------------
            UPDATE UploadFraudPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen – Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen – Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.AccountNumber, ' ') <> ' '
              AND V.AccountNumber IN ( SELECT RefCustomerACID 
                                       FROM Fraud_Details_Mod 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey
                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','DP','RM','1A' )

                                                 AND NVL(Screenflag, ' ') <> 'U' )
            ;
            ---------------------------------------------------------------------------Upload for same account ID--------------
            UPDATE UploadFraudPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen Upload– Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform Fraud, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Fraud Screen Upload– Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.AccountNumber, ' ') <> ' '
              AND V.AccountNumber IN ( SELECT RefCustomerACID 
                                       FROM Fraud_Details_Mod 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey
                                                 AND AuthorisationStatus IN ( 'NP','MP','1A','FM' )

                                                 AND NVL(Screenflag, ' ') = 'U' )
            ;
            -------------------------RFA Reported by Bank------------------------------------------------------
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘RFA Reported by Bank(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘RFA Reported by Bank(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'RFA Reported by Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'RFA Reported by Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(RFAreportedbyBank, ' ') NOT IN ( 'Y','N',' ' )
            ;
            ------------------------Name of Other Bank Reporting RFA---------------------------------------------
            UPDATE UploadFraudPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Name of Other Bank Reporting RFA’. Kindly upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Name of Other Bank Reporting RFA’. Kindly upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Name of Other Bank Reporting RFA'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Name of Other Bank Reporting RFA'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( NVL(NameofotherBankreportingRFA, ' ') NOT IN ( SELECT BankName 
                                                                     FROM DimBankRP  )

              AND NVL(NameofotherBankreportingRFA, ' ') NOT IN ( ' ' )
             );
            -----------------------Provision Preference---------------------------------------------
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Provision Preference is Mandatory. Kindly upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Provision Preference is Mandatory. Kindly upload againn'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Provision Preference'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Provision Preference'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(Provisionpreference, ' ') = ' ';
            UPDATE UploadFraudPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Provision Preference’. Kindly upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Provision Preference’. Kindly upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Provision Preference'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Provision Preference'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(Provisionpreference, ' ') NOT IN ( SELECT ParameterName 
                                                           FROM DimParameter 
                                                            WHERE  DimParameterName IN ( 'DimProvisionPreference' )
             )
            ;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            /*VALIDATIONS Date of RFA Reporting by Bank */
            ---------------------------------------
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of RFA Reporting by Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of RFA Reporting by Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofRFAreportingbyBank, ' ') <> ' '
              AND utils.isdate(DateofRFAreportingbyBank) = 0;
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of RFA reporting by bank is mandatory when RFA reported by bank is Y.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of RFA reporting by bank is mandatory when RFA reported by bank is Y.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of RFA Reporting by Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of RFA Reporting by Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(RFAreportedbyBank, ' ') = 'Y'
              AND NVL(DateofRFAreportingbyBank, ' ') = ' ';
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of RFA Reporting by Bank must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of RFA Reporting by Bank must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of RFA Reporting by Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of RFA Reporting by Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofRFAreportingbyBank) = 1 THEN CASE 
                                                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(DateofRFAreportingbyBank,200) > v_DateOfData THEN 1
                          ELSE 0
                             END   END) = 1;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            /*VALIDATIONS Date of Reporting RFA by Other Bank */
            ---------------------------------------
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of Reporting RFA by Other Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of Reporting RFA by Other Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofreportingRFAbyOtherBank, ' ') <> ' '
              AND utils.isdate(DateofreportingRFAbyOtherBank) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of Reporting RFA by Other Bank must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of Reporting RFA by Other Bank must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of Reporting RFA by Other Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of Reporting RFA by Other Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofreportingRFAbyOtherBank) = 1 THEN CASE 
                                                                                         WHEN UTILS.CONVERT_TO_VARCHAR2(DateofreportingRFAbyOtherBank,200) > v_DateOfData THEN 1
                          ELSE 0
                             END   END) = 1;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            /*VALIDATIONS Date of Fraud Occurrence */
            ---------------------------------------
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of Fraud Occurrence'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of Fraud Occurrence'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofFraudoccurrence, ' ') <> ' '
              AND utils.isdate(DateofFraudoccurrence) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of Fraud Occurrence must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of Fraud Occurrence must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of Fraud Occurrence'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of Fraud Occurrence'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofFraudoccurrence) = 1 THEN CASE 
                                                                                 WHEN UTILS.CONVERT_TO_VARCHAR2(DateofFraudoccurrence,200) > v_DateOfData THEN 1
                          ELSE 0
                             END   END) = 1;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            ---------------------------------------
            /*VALIDATIONS Date of Fraud Declaration by RBL
             */
            ---------------------------------------
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of Fraud Declaration by RBL'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of Fraud Declaration by RBL'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofFrauddeclarationbyRBL, ' ') <> ' '
              AND utils.isdate(DateofFrauddeclarationbyRBL) = 0;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of Fraud Declaration by RBL must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of Fraud Declaration by RBL must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of Fraud Declaration by RBL'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of Fraud Declaration by RBL'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofFrauddeclarationbyRBL) = 1 THEN CASE 
                                                                                       WHEN UTILS.CONVERT_TO_VARCHAR2(DateofFrauddeclarationbyRBL,200) > v_DateOfData THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'FraudDeclarationDate is mandatory . Please upload and confirm.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'FraudDeclarationDate is mandatory . Please upload and confirm.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'FraudDeclarationDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'FraudDeclarationDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateofFrauddeclarationbyRBL, ' ') = ' ';
            --/*VALIDATIONS Current NPA Date 
            -- */---------------------------------------
            -- SET DATEFORMAT DMY
            --UPDATE UploadFraudPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN ' Current NPA Date' ELSE   ErrorinColumn +','+SPACE(1)+' Current NPA Date' END     
            --		,Srnooferroneousrows=V.SrNo	
            -- FROM UploadFraudPool V  
            -- WHERE ISNULL(CurrentNPA_Date,'') <>'' AND ISDATE(CurrentNPA_Date)=0
            --  Set DateFormat DMY
            -- UPDATE UploadFraudPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' Current NPA Date by RBL must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ ' Current NPA Date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN ' Current NPA Date' ELSE   ErrorinColumn +','+SPACE(1)+' Current NPA Date' END      
            --		,Srnooferroneousrows=V.SrNo	
            -- FROM UploadFraudPool V  
            -- WHERE (Case When ISDATE(CurrentNPA_Date)=1 Then Case When Cast(CurrentNPA_Date as date)>Cast(@DateOfData as Date)
            --                                                               Then 1 Else 0 END END)=1
            --  UPDATE UploadFraudPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CurrentNPA_Date is mandatory . Please upload and confirm.'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'CurrentNPA_Date is mandatory . Please upload and confirm.'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CurrentNPA_Date' ELSE   ErrorinColumn +','+SPACE(1)+'CurrentNPA_Date' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadFraudPool V  
            -- WHERE  ISNULL(CurrentNPA_Date,'' )=''
            /*VALIDATIONS ON Nature of Fraud */
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Nature of Fraud must be Mandatory.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Nature of Fraud must be Mandatory.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Nature of Fraud'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Nature of Fraud'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(NatureofFraud, ' ') = ' ';
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Nature of Fraud cant be more than 500 characters.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Nature of Fraud cant be more than 500 characters.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Nature of Fraud'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Nature of Fraud'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(NatureofFraud) > 500;
            ---------------------------------------
            /*VALIDATIONS ON Areas of Operations */
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Areas of Operations must be Mandatory.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Areas of Operations must be Mandatory.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Areas of Operations'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Areas of Operations'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AreasofOperations, ' ') = ' ';
            UPDATE UploadFraudPool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Areas of Operations cant be more than 500 characters.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Areas of Operations cant be more than 500 characters.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Areas of Operations'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Areas of Operations'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(AreasofOperations) > 500;
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
                                FROM NPAFraudAccountUpload_stg 
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
              ( SELECT ' ' SrNo  ,
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
              ( SELECT SrNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM UploadFraudPool  );
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
                               FROM NPAFraudAccountUpload_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE NPAFraudAccountUpload_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.NPAFraudAccountUpload_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
   DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      ------to delete file if it has errors
      --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
      --begin
      --print 'ppp'
      -- IF EXISTS(SELECT 1 FROM AccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
      -- BEGIN
      -- print '123'
      --DELETE FROM AccountLvlMOCDetails_stg
      --WHERE filename=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- END
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM NPAFraudAccountUpload_stg 
                          WHERE  filname = v_FilePathUpload );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DELETE NPAFraudAccountUpload_stg

          WHERE  filname = v_FilePathUpload;
         DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.NPAFraudAccountUpload_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

      END;
      END IF;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_FRAUD" TO "ADF_CDR_RBL_STGDB";
