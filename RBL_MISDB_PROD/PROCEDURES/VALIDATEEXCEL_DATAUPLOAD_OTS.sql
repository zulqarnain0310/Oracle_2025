--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_OTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" 
(
  v_MenuID IN NUMBER DEFAULT 24741 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'AccountMOCUpload.xlsx' 
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--DECLARE  
--@MenuID INT=24741,  
--@UserLoginId varchar(20)='lvl1admin',  
--@Timekey int=26085
--,@filepath varchar(500)='OTS_AWupload (15).xlsx'  

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
         IF ( v_MenuID = 24741 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on SrNo*/
            v_DuplicateCnt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadAccMOCPool') IS NOT NULL  
            IF utils.object_id('UploadOTS_Pool') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadOTS_Pool';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT 1 
                                     FROM OTSUpload_stg 
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
               DELETE FROM UploadOTS_Pool;
               UTILS.IDENTITY_RESET('UploadOTS_Pool');

               INSERT INTO UploadOTS_Pool SELECT * ,
                                                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                 UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM OTSUpload_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            --select * from UploadAccMOCPool
            ------------------------------------------------------------------------------ 
            DBMS_OUTPUT.PUT_LINE('Prashant');
            ----SELECT * FROM UploadAccMOCPool
            --SrNo	Territory	ACID	InterestReversalAmount	filename
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'SrNo,Account Number,Date Approval Settlement,Approving Authority,
                   		Principal Outstandingat the time of settlement,
                   		Interest Due at the time of settlement,
                   		Fees Charges Due at the time of settlement, Settlement Amount,Principal Sacrifice,
                   		Interest Waiver,Fee Waiver,
                   		Action,Settlement Failure',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SrNo, ' ') = ' '
              AND NVL(AccountNumber, ' ') = ' '
              AND NVL(Dateofapprovalofsettlement, ' ') = ' '
              AND NVL(Approvingauthority, ' ') = ' '
              AND NVL(PrincipalOutstandingatthetimeofsettlement, ' ') = ' '
              AND NVL(InterestDueatthetimeofsettlement, ' ') = ' '
              AND NVL(FeesChargesDueatthetimeofsettlement, ' ') = ' '
              AND NVL(Settlementamount, ' ') = ' '
              AND NVL(PrincipalSacrifice, ' ') = ' '
              AND NVL(InterestWaiver, ' ') = ' '
              AND NVL(FeeWaiver, ' ') = ' '
              AND NVL(ACTION, ' ') = ' '
              AND NVL(SettlementFailure, ' ') = ' '

              --AND ISNULL(Actual_Write_Off_Amount,'')=''

              --AND ISNULL(Actual_Write_Off_Date,'')=''
              AND NVL(Accountclosuredateinsystem, ' ') = ' ';
            --OTSUpload_stg
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
                               FROM UploadOTS_Pool 
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
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(v.SrNo, ' ') = ' ';--or ISNULL(v.SrNo,0)< 0)
            --or ISNULL(v.SrNo,0)=0  -- OR ISNULL(v.SrNo,'')<0
            --   UPDATE UploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadAccMOCPool V  
            --WHERE (ISNULL(v.SrNo,'')<>'' or ISNULL(v.SrNo,0)=0)  -- OR ISNULL(v.SrNo,'')<0
            DBMS_OUTPUT.PUT_LINE('PRASHANT3');
            UPDATE UploadOTS_Pool V
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
            UPDATE UploadOTS_Pool V
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
            UPDATE UploadOTS_Pool V
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
              FROM UploadOTS_Pool 
              GROUP BY SrNo

               HAVING COUNT(SrNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadOTS_Pool V
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
                                        FROM UploadOTS_Pool 
                                          GROUP BY SrNo

                                           HAVING COUNT(SrNo)  > 1 )
            ;
            END IF;
            ------------------------------------------------
            /*VALIDATIONS ON AccountID */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountNumber, ' ') = ' ';
            -- ----SELECT * FROM UploadAccMOCPool
            UPDATE UploadOTS_Pool V
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
            IF utils.object_id('TEMPDB..tt_DUB2_22') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_22 ';
            END IF;
            DELETE FROM tt_DUB2_22;
            UTILS.IDENTITY_RESET('tt_DUB2_22');

            INSERT INTO tt_DUB2_22 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountNumber ORDER BY AccountNumber  ) rw  
                        FROM UploadOTS_Pool  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate Account ID found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Account ID found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'Account ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
               END AS pos_3, V.SrNo
            FROM V ,UploadOTS_Pool V
                   JOIN tt_DUB2_22 D   ON D.AccountNumber = V.AccountNumber ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SrNo;
            ---------------------Authorization for Screen Same acc ID --------------------------
            UPDATE UploadOTS_Pool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform OTS, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘OTS Screen – Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform OTS, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘OTS Screen – Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.AccountNumber, ' ') <> ' '
              AND V.AccountNumber IN ( SELECT RefCustomerAcid 
                                       FROM OTS_Details_Mod 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey
                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','RM','1A' )

                                                 AND NVL(Screenflag, ' ') <> 'U' )
            ;
            ---------------------------------------------------------------------------Upload for same account ID--------------
            UPDATE UploadOTS_Pool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform OTS, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘OTS Screen Upload– Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform OTS, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘OTS Screen Upload– Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.AccountNumber, ' ') <> ' '
              AND V.AccountNumber IN ( SELECT RefCustomerAcid 
                                       FROM OTS_Details_Mod 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey
                                                 AND AuthorisationStatus IN ( 'NP','MP','1A','FM' )

                                                 AND NVL(Screenflag, ' ') = 'U' )
            ;
            -------------------------------------------------------
            ------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('NANDA');
            /*VALIDATIONS ON Approvingauthority */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘Approvingauthority’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘Approvingauthority’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Approvingauthority'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Approvingauthority'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(Approvingauthority, ' ') = ' '
              AND ACTION <> 'U';
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            ------------------------------------------------------------------------------------------
            /*VALIDATIONS Date_Approval_Settlement */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date Approval Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date Approval Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(Dateofapprovalofsettlement, ' ') <> ' '
              AND utils.isdate(Dateofapprovalofsettlement) = 0;
            DBMS_OUTPUT.PUT_LINE('NANDA1');
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Approval settlement Date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Approval settlement Date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date Approval Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date Approval Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  (CASE 
                          WHEN utils.isdate(Dateofapprovalofsettlement) = 1 THEN CASE 
                                                                                      WHEN UTILS.CONVERT_TO_VARCHAR2(Dateofapprovalofsettlement,200,p_style=>105) > v_DateOfData THEN 1
                          ELSE 0
                             END   END) = 1;
            DBMS_OUTPUT.PUT_LINE(v_DateOfData);
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Approval Settlement Date is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Approval Settlement Date is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date Approval Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date Approval Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(Dateofapprovalofsettlement, ' ') = ' '
              AND ACTION <> 'U';
            ---------------------------------------
            /*VALIDATIONS ON Principal_OS */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Principal_OS. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Principal_OS. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_OS'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_OS'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(PrincipalOutstandingatthetimeofsettlement) = 0
              AND NVL(PrincipalOutstandingatthetimeofsettlement, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PrincipalOutstandingatthetimeofsettlement), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Principal_OS is Mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Principal_OS is Mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_OS'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_OS'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalOutstandingatthetimeofsettlement, ' ') = ' '
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Principal_OS. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Principal_OS. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_OS'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_OS'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(PrincipalOutstandingatthetimeofsettlement, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column Principal_OS. Kindly check and upload value'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column Principal_OS. Kindly check and upload value'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_OS'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_OS'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalOutstandingatthetimeofsettlement, ' ') <> ' '
              AND ( INSTR(NVL(PrincipalOutstandingatthetimeofsettlement, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(PrincipalOutstandingatthetimeofsettlement, ' '), -LENGTH(NVL(PrincipalOutstandingatthetimeofsettlement, ' ')) - INSTR(NVL(PrincipalOutstandingatthetimeofsettlement, ' '), '.'), LENGTH(NVL(PrincipalOutstandingatthetimeofsettlement, ' ')) - INSTR(NVL(PrincipalOutstandingatthetimeofsettlement, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            /*validations on Interest_Due_time_Settlement */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest_Due_time_Settlement. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest_Due_time_Settlement. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Due_time_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Due_time_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(InterestDueatthetimeofsettlement) = 0
              AND NVL(InterestDueatthetimeofsettlement, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(InterestDueatthetimeofsettlement), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest_Due_time_Settlement. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest_Due_time_Settlement. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Due_time_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Due_time_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(InterestDueatthetimeofsettlement, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest_Due_time_Settlement. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest_Due_time_Settlement. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Due_time_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Due_time_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestDueatthetimeofsettlement, ' ') <> ' '
              AND ( INSTR(NVL(InterestDueatthetimeofsettlement, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(InterestDueatthetimeofsettlement, ' '), -LENGTH(NVL(InterestDueatthetimeofsettlement, ' ')) - INSTR(NVL(InterestDueatthetimeofsettlement, ' '), '.'), LENGTH(NVL(InterestDueatthetimeofsettlement, ' ')) - INSTR(NVL(InterestDueatthetimeofsettlement, ' '), '.'))) <> 2 )
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Interest Due at the time of settlement is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Interest Due at the time of settlement is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Due_time_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Due_time_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestDueatthetimeofsettlement, ' ') = ' '
              AND ACTION <> 'U';
            -----------------------------------------------------------------
            /*validations on Fees_Charges_Settlement */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Fees_Charges_Settlement. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Fees_Charges_Settlement. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Charges_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Charges_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(FeesChargesDueatthetimeofsettlement) = 0
              AND NVL(FeesChargesDueatthetimeofsettlement, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(FeesChargesDueatthetimeofsettlement), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Fees_Charges_Settlement. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Fees_Charges_Settlement. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Charges_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Charges_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(FeesChargesDueatthetimeofsettlement, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Fees_Charges_Settlement. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Fees_Charges_Settlement. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Charges_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Charges_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(FeesChargesDueatthetimeofsettlement, ' ') <> ' '
              AND ( INSTR(NVL(FeesChargesDueatthetimeofsettlement, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(FeesChargesDueatthetimeofsettlement, ' '), -LENGTH(NVL(FeesChargesDueatthetimeofsettlement, ' ')) - INSTR(NVL(FeesChargesDueatthetimeofsettlement, ' '), '.'), LENGTH(NVL(FeesChargesDueatthetimeofsettlement, ' ')) - INSTR(NVL(FeesChargesDueatthetimeofsettlement, ' '), '.'))) <> 2 )
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Fees Charges at the time of settlement is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Fees Charges at the time of settlement is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Charges_Settlement'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Charges_Settlement'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(FeesChargesDueatthetimeofsettlement, ' ') = ' '
              AND ACTION <> 'U';
            -----------------------------------------------------------------
            --/*validations on Total_Dues_Settlement */
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Total_Dues_Settlement. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Total_Dues_Settlement. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Total_Dues_Settlement' ELSE ErrorinColumn +','+SPACE(1)+  'Total_Dues_Settlement' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								--STUFF((SELECT ','+SrNo 
            ----								--FROM UploadAccMOCPool A
            ----								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
            ----								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
            ----								--)
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE (ISNUMERIC(Total_Dues_Settlement)=0 AND ISNULL(Total_Dues_Settlement,'')<>'') OR 
            -- ISNUMERIC(Total_Dues_Settlement) LIKE '%^[0-9]%'
            -- PRINT 'INVALID' 
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Total_Dues_Settlement. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Total_Dues_Settlement. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Total_Dues_Settlement' ELSE ErrorinColumn +','+SPACE(1)+  'Total_Dues_Settlement' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Total_Dues_Settlement,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            --  UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Total_Dues_Settlement. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Total_Dues_Settlement. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Total_Dues_Settlement' ELSE ErrorinColumn +','+SPACE(1)+  'Total_Dues_Settlement' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
            ----								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
            ----								---- )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            --WHERE ISNULL(Total_Dues_Settlement,'')<>''
            --AND (CHARINDEX('.',ISNULL(Total_Dues_Settlement,''))>0  AND Len(Right(ISNULL(Total_Dues_Settlement,''),Len(ISNULL(Total_Dues_Settlement,''))-CHARINDEX('.',ISNULL(Total_Dues_Settlement,''))))<>2)
            -----------------------------------------------------------------
            /*validations on Settlement_Amount */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Settlement_Amount. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Settlement_Amount. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Settlement_Amount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Settlement_Amount'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(Settlementamount) = 0
              AND NVL(Settlementamount, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(Settlementamount), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Settlement_Amount. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Settlement_Amount. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Settlement_Amount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Settlement_Amount'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(Settlementamount, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Settlement amount is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Settlement amount is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Settlement_Amount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Settlement_Amount'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(Settlementamount, ' ') = ' '
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Settlement_Amount. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Settlement_Amount. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Settlement_Amount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Settlement_Amount'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(Settlementamount, ' ') <> ' '
              AND ( INSTR(NVL(Settlementamount, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(Settlementamount, ' '), -LENGTH(NVL(Settlementamount, ' ')) - INSTR(NVL(Settlementamount, ' '), '.'), LENGTH(NVL(Settlementamount, ' ')) - INSTR(NVL(Settlementamount, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            /*validations on Principal_Sacrifice */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Principal_Sacrifice. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Principal_Sacrifice. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_Sacrifice'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_Sacrifice'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(PrincipalSacrifice) = 0
              AND NVL(PrincipalSacrifice, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PrincipalSacrifice), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Principal_Sacrifice. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Principal_Sacrifice. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_Sacrifice'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_Sacrifice'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(PrincipalSacrifice, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Principal Sacrifice is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Principal Sacrifice is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_Sacrifice'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_Sacrifice'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalSacrifice, ' ') = ' '
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Principal_Sacrifice. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Principal_Sacrifice. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Principal_Sacrifice'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Principal_Sacrifice'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalSacrifice, ' ') <> ' '
              AND ( INSTR(NVL(PrincipalSacrifice, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(PrincipalSacrifice, ' '), -LENGTH(NVL(PrincipalSacrifice, ' ')) - INSTR(NVL(PrincipalSacrifice, ' '), '.'), LENGTH(NVL(PrincipalSacrifice, ' ')) - INSTR(NVL(PrincipalSacrifice, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            /*validations on Interest_Waiver */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest_Waiver. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest_Waiver. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(InterestWaiver) = 0
              AND NVL(InterestWaiver, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(InterestWaiver), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest_Waiver. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest_Waiver. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(InterestWaiver, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Interest Waiver is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Interest Waiver is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestWaiver, ' ') = ' '
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest_Waiver. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest_Waiver. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestWaiver, ' ') <> ' '
              AND ( INSTR(NVL(InterestWaiver, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(InterestWaiver, ' '), -LENGTH(NVL(InterestWaiver, ' ')) - INSTR(NVL(InterestWaiver, ' '), '.'), LENGTH(NVL(InterestWaiver, ' ')) - INSTR(NVL(InterestWaiver, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            /*validations on Fees_Waiver */
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Fees_Waiver. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Fees_Waiver. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SrNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(FeeWaiver) = 0
              AND NVL(FeeWaiver, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(FeeWaiver), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(FeeWaiver, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Fees Waiver is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Fees Waiver is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(FeeWaiver, ' ') = ' '
              AND ACTION <> 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Fees_Waiver. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Fees_Waiver. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Fees_Waiver'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Fees_Waiver'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(FeeWaiver, ' ') <> ' '
              AND ( INSTR(NVL(FeeWaiver, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(FeeWaiver, ' '), -LENGTH(NVL(FeeWaiver, ' ')) - INSTR(NVL(FeeWaiver, ' '), '.'), LENGTH(NVL(FeeWaiver, ' ')) - INSTR(NVL(FeeWaiver, ' '), '.'))) <> 2 );
            -----------------------------------------------------------------
            --/*validations on Total_Amount_Sacrificed_Waived */
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Total_Amount_Sacrificed_Waived. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Total_Amount_Sacrificed_Waived. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Total_Amount_Sacrificed_Waived' ELSE ErrorinColumn +','+SPACE(1)+  'Total_Amount_Sacrificed_Waived' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								--STUFF((SELECT ','+SrNo 
            ----								--FROM UploadAccMOCPool A
            ----								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
            ----								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
            ----								--)
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE (ISNUMERIC(Total_Amount_Sacrificed_Waived)=0 AND ISNULL(Total_Amount_Sacrificed_Waived,'')<>'') OR 
            -- ISNUMERIC(Total_Amount_Sacrificed_Waived) LIKE '%^[0-9]%'
            -- PRINT 'INVALID' 
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Total_Amount_Sacrificed_Waived. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Total_Amount_Sacrificed_Waived. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Total_Amount_Sacrificed_Waived' ELSE ErrorinColumn +','+SPACE(1)+  'Total_Amount_Sacrificed_Waived' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Total_Amount_Sacrificed_Waived,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            --  UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Total_Amount_Sacrificed_Waived. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Total_Amount_Sacrificed_Waived. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Total_Amount_Sacrificed_Waived' ELSE ErrorinColumn +','+SPACE(1)+  'Total_Amount_Sacrificed_Waived' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
            ----								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
            ----								---- )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            --WHERE ISNULL(Total_Amount_Sacrificed_Waived,'')<>''
            --AND (CHARINDEX('.',ISNULL(Total_Amount_Sacrificed_Waived,''))>0  AND Len(Right(ISNULL(Total_Amount_Sacrificed_Waived,''),Len(ISNULL(Total_Amount_Sacrificed_Waived,''))-CHARINDEX('.',ISNULL(Total_Amount_Sacrificed_Waived,''))))<>2)
            -----------------------------------------------------------------
            --/*validations on Actual_Write_Off_Amount */
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Actual_Write_Off_Amount. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Actual_Write_Off_Amount. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual_Write_Off_Amount' ELSE ErrorinColumn +','+SPACE(1)+  'Actual_Write_Off_Amount' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								--STUFF((SELECT ','+SrNo 
            ----								--FROM UploadAccMOCPool A
            ----								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
            ----								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
            ----								--)
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE (ISNUMERIC(Actual_Write_Off_Amount)=0 AND ISNULL(Actual_Write_Off_Amount,'')<>'') OR 
            -- ISNUMERIC(Actual_Write_Off_Amount) LIKE '%^[0-9]%'
            -- PRINT 'INVALID' 
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Actual_Write_Off_Amount. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Actual_Write_Off_Amount. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual_Write_Off_Amount' ELSE ErrorinColumn +','+SPACE(1)+  'Actual_Write_Off_Amount' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Actual_Write_Off_Amount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            --  UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Actual_Write_Off_Amount. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Actual_Write_Off_Amount. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual_Write_Off_Amount' ELSE ErrorinColumn +','+SPACE(1)+  'Actual_Write_Off_Amount' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT SrNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
            ----								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
            ----								---- )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            --WHERE ISNULL(Actual_Write_Off_Amount,'')<>''
            --AND (CHARINDEX('.',ISNULL(Actual_Write_Off_Amount,''))>0  AND Len(Right(ISNULL(Actual_Write_Off_Amount,''),Len(ISNULL(Actual_Write_Off_Amount,''))-CHARINDEX('.',ISNULL(Actual_Write_Off_Amount,''))))<>2)
            -----------------------------------------------------------------
            ------------------------------------------------------------------------------------------
            /*VALIDATIONS Actual_Write_Off_Date */
            -- SET DATEFORMAT DMY
            --UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual_Write_Off_Date' ELSE   ErrorinColumn +','+SPACE(1)+'Actual_Write_Off_Date' END     
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Actual_Write_Off_Date,'')<>'' AND ISDATE(Actual_Write_Off_Date)=0
            --  Set DateFormat DMY
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Actual_Write_Off_Date must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Actual_Write_Off_Date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual_Write_Off_Date' ELSE   ErrorinColumn +','+SPACE(1)+'Actual_Write_Off_Date' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE (Case When ISDATE(Actual_Write_Off_Date)=1 Then Case When Cast(Actual_Write_Off_Date as date)>Cast(@DateOfData as Date)
            --                                                               Then 1 Else 0 END END)=1
            --  UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Actual_Write_Off_Date is mandatory'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Actual_Write_Off_Date is mandatory'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Actual_Write_Off_Date' ELSE   ErrorinColumn +','+SPACE(1)+'Actual_Write_Off_Date' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Actual_Write_Off_Date,'') IN('Y') AND ISNULL(Actual_Write_Off_Date,'' )=''
            ---------------------------------------
            ------------------------------------------------------------------------------------------
            --/*VALIDATIONS Account_Closure_Date */
            -- SET DATEFORMAT DMY
            --UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account_Closure_Date' ELSE   ErrorinColumn +','+SPACE(1)+'Account_Closure_Date' END     
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Account_Closure_Date,'')<>'' AND ISDATE(Account_Closure_Date)=0
            --  Set DateFormat DMY
            -- UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account_Closure_Date must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Account_Closure_Date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account_Closure_Date' ELSE   ErrorinColumn +','+SPACE(1)+'Account_Closure_Date' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE (Case When ISDATE(Account_Closure_Date)=1 Then Case When Cast(Account_Closure_Date as date)>Cast(@DateOfData as Date)
            --                                                               Then 1 Else 0 END END)=1
            --  UPDATE UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account_Closure_Date is mandatory'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Account_Closure_Date is mandatory'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account_Closure_Date' ELSE   ErrorinColumn +','+SPACE(1)+'Account_Closure_Date' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SrNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadOTS_Pool V  
            -- WHERE ISNULL(Account_Closure_Date,'') IN('Y') AND ISNULL(Account_Closure_Date,'' )=''
            ---------------------------------------
            --------------------------Settlement_Failure ---------------------------------------
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Settlement_Failure(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Settlement_Failure(Y/N)’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Settlement_Failure'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Settlement_Failure'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SrNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(SettlementFailure, ' ') NOT IN ( 'Y','N' )

              AND NVL(SettlementFailure, ' ') <> ' '
              AND ACTION <> 'U';
            -- UPDATE	UploadOTS_Pool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘Settlement_Failure(Y/N)’. Kindly enter ‘Y or N’ and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Settlement_Failure(Y/N)’. Kindly enter ‘Y or N’ and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Settlement_Failure' ELSE ErrorinColumn +','+SPACE(1)+  'Settlement_Failure' END  
            --		,Srnooferroneousrows=V.SrNo
            ----								----STUFF((SELECT ','+SrNo 
            ----								----FROM UploadAccMOCPool A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadOTS_Pool V  
            --  WHERE ISNULL(SettlementFailure,'')=''
            ----------------------------------------------
            /*------------------validations on Action Flag -------23-11-2021-----------------*/
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Please enter (A or U) value in Action column. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Please enter (A or U) value in Action column. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Action'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Action'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  v.Action NOT IN ( 'A','U' )
            ;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            --------------------------------------------------------------------------------------------------------------------------
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Accountclosuredateinsystem'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Accountclosuredateinsystem'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(Accountclosuredateinsystem, ' ') <> ' '
              AND utils.isdate(Accountclosuredateinsystem) = 0;
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account closure date  is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account closure date is mandatory'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account closure date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account closure date'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(Accountclosuredateinsystem, ' ') = ' '
              AND ACTION = 'U';
            UPDATE UploadOTS_Pool V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account closure date  should be greater than date of approval of settlement. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account closure date  should be greater than date of approval of settlement.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account closure date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account closure date'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SrNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(Accountclosuredateinsystem, ' ') <> ' '
              AND NVL(Accountclosuredateinsystem, ' ') <= NVL(Dateofapprovalofsettlement, ' ');
            /*------------------validations on Action Flag -------23-11-2021-----------------*/
            UPDATE UploadOTS_Pool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not Added in OTS. You can only add account in OTS.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not Added in OTS. You can only add account in OTS.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Action'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Action'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  v.Action IN ( 'U' )

              AND NOT EXISTS ( SELECT 1 
                               FROM OTS_Details A
                                WHERE  A.RefCustomerAcid = V.AccountNumber
                                         AND A.EffectiveToTimeKey = 49999 );
            UPDATE UploadOTS_Pool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is already exist in OTS. You can only Modify account in OTS.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is already exist in OTS. You can only Modify account in OTS'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Action'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Action'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  v.Action IN ( 'A' )

              AND EXISTS ( SELECT 1 
                           FROM OTS_Details A
                            WHERE  A.RefCustomerAcid = V.AccountNumber
                                     AND A.EffectiveToTimeKey = 49999 );
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
                                FROM OTSUpload_stg 
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
                FROM UploadOTS_Pool  );
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
                               FROM OTSUpload_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE OTSUpload_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.OTSUpload_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM OTSUpload_stg 
                          WHERE  filname = v_FilePathUpload );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DELETE OTSUpload_stg

          WHERE  filname = v_FilePathUpload;
         DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.AccountLvlMOCDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

      END;
      END IF;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_OTS" TO "ADF_CDR_RBL_STGDB";
