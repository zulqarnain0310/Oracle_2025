--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'TWOACUPLOAD.xlsx' ,
  v_UploadTypeParameterAlt_Key IN NUMBER
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--DECLARE  
--@MenuID INT=161,  
--@UserLoginId varchar(20)='FNASUPERADMIN',  
--@Timekey int=49999
--,@filepath varchar(500)='InterestReversalUpload (5).xlsx'  

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
         IF ( v_MenuID = 1470 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*------------------validations on Action Flag -------02-04-2021-----------------*/
            v_ParameterName VARCHAR2(100);

         BEGIN
            -- IF OBJECT_ID('tempdb..TwoAc') IS NOT NULL  
            --BEGIN  
            -- DROP TABLE TwoAc  
            --END
            IF utils.object_id('TwoAc') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE TwoAc';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM AccountFlagging_Stg 
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
               DELETE FROM TwoAc;
               UTILS.IDENTITY_RESET('TwoAc');

               INSERT INTO TwoAc SELECT * ,
                                        UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                        UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                        UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM AccountFlagging_Stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            ----SELECT * FROM TwoAc
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE TwoAc V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'ACID,Amount,Date,Action',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(ACID, ' ') = ' '
              AND NVL(Amount, ' ') = ' '
              AND NVL(Date_, ' ') = ' '
              AND NVL(ACTION, ' ') = ' ';
            --WHERE
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM TwoAc 
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
            /*VALIDATIONS ON ACID */
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account cannot be blank.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM TwoAc A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(ACID, ' ') = ' ';
            -- ----SELECT * FROM TwoAc
            /*------Account ID Validation----Pranay 22-03-2021---*/
            UPDATE TwoAc V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM TwoAc A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
                    --								-- WHERE ISNULL(V.ACID,'')<>''
                    --								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
                    --								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
                    --								--										Timekey=@Timekey
                    --								--		))
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  NVL(V.ACID, ' ') <> ' '
              AND V.ACID NOT IN ( SELECT CustomerACID 
                                  FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                                   WHERE  EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
            ;
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID can not be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID can not be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM TwoAc A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
                    --								-- WHERE ISNULL(V.ACID,'')<>''
                    --								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
                    --								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
                    --								--										Timekey=@Timekey
                    --								--		))
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  NVL(V.ACID, ' ') = ' ';
            ----
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID cantains special character(s). Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID cantains special character(s). Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM TwoAc A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM TwoAc V
                    --								-- WHERE ISNULL(V.ACID,'')<>''
                    --								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
                    --								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
                    --								--										Timekey=@Timekey
                    --								--		))
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(V.ACID, ' '), '%[^a-zA-Z0-9]%');
            IF utils.object_id('TEMPDB..tt_DUB2_7') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_7 ';
            END IF;
            DELETE FROM tt_DUB2_7;
            UTILS.IDENTITY_RESET('tt_DUB2_7');

            INSERT INTO tt_DUB2_7 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY ACID ORDER BY ACID  ) ROW_  
                        FROM TwoAc  ) X
                WHERE  ROW_ > 1;
            UPDATE TwoAc V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate records found.AccountID are repeated.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate records found. AccountID are repeated.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM #UploadNewAccount A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                    --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                    ----AND SRNO IN(SELECT Srno FROM tt_DUB2_7))
                    --AND ACID IN(SELECT ACID FROM tt_DUB2_7 GROUP BY ACID))
                    --							FOR XML PATH ('')
                    --							),1,1,'')   

             WHERE  NVL(ACID, ' ') <> ' '
              AND ACID IN ( SELECT ACID 
                            FROM tt_DUB2_7 
                              GROUP BY ACID )
            ;
            /*validations on Amount*/
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'AMOUNT cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'AMOUNT cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Amount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Amount'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(Amount, ' ') = ' ';--and ISNUMERIC(V.Amount)=0 
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'AMOUNT require numberic Values . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'AMOUNT require numberic Values . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Amount'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Amount'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(Amount, ' ') <> ' '
              AND utils.isnumeric(Amount) = 0;
            ----------------------------------------------
            /*validations on Date*/
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DATE cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DATE cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO   -- DATE cannot be blank . Please check the values and upload again
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(Date_, ' ') = ' ';
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ?dd-mm-yyyy?'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ?dd-mm-yyyy?'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO   -- DATE cannot be blank . Please check the values and upload again
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(Date_, ' ') <> ' '
              AND utils.isdate(Date_) = 0;
            ----------------------------------------------
            /*------------------validations on Action Flag -------Pranay 22-03-2021-----------------*/
            UPDATE TwoAc V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Please enter (Y or N) value in Action column. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Please enter (Y or N) value in Action column. Please check the values and upload again'
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

             WHERE  v.Action NOT IN ( 'Y','N' )
            ;
            SELECT ParameterName 

              INTO v_ParameterName
              FROM DimParameter 
             WHERE  DimParameterName = 'uploadflagtype'
                      AND EffectiveToTimeKey = 49999
                      AND ParameterAlt_Key = v_UploadTypeParameterAlt_Key;
            UPDATE TwoAc V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account is not marked to the selected flag. You can only add the marked flag for this account.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account is not marked to the selected flag. You can only add the marked flag for this account.'
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

             WHERE  v.Action IN ( 'N' )

              AND NOT EXISTS ( SELECT 1 
                               FROM ExceptionFinalStatusType A
                                WHERE  A.ACID = V.ACID
                                         AND A.StatusType = v_ParameterName
                                         AND A.EffectiveToTimeKey = 49999 );
            ------------------------------------------------------------------
            UPDATE TwoAc V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account with selected flag is already pending for authorization. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account with selected flag is already pending for authorization. Please check the values and upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  v.Action IN ( 'N','Y' )

              AND EXISTS ( SELECT 1 
                           FROM AccountFlaggingDetails_Mod A
                            WHERE  A.ACID = V.ACID
                                     AND A.UploadTypeParameterAlt_Key = v_UploadTypeParameterAlt_Key
                                     AND A.EffectiveToTimeKey = 49999
                                     AND AuthorisationStatus IN ( 'NP','MP' )
             );
            -----------------------
            UPDATE TwoAc V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account with selected flag is already pending for authorization. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account with selected flag is already pending for authorization. Please check the values and upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM TwoAc A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM TwoAc V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  v.Action IN ( 'N','Y' )

              AND EXISTS ( SELECT 1 
                           FROM ExceptionalDegrationDetail_Mod A
                            WHERE  A.AccountID = V.ACID
                                     AND A.FlagAlt_Key = v_UploadTypeParameterAlt_Key
                                     AND A.EffectiveToTimeKey = 49999
                                     AND AuthorisationStatus IN ( 'NP','MP' )
             );
            -----------------------
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
                                FROM AccountFlagging_Stg 
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
            INSERT INTO RBL_MISDB_PROD.MasterUploadData
              ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Srnooferroneousrows, Flag )
              ( SELECT SrNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM TwoAc  );
            --	----SELECT * FROM TwoAc 
            --	--ORDER BY ErrorMessage,TwoAc.ErrorinColumn DESC
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
                               FROM AccountFlagging_Stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE AccountFlagging_Stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.AccountFlagging_Stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM TwoAc
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_ACCOUNTFLAGGINGUPLOAD_19112021" TO "ADF_CDR_RBL_STGDB";
