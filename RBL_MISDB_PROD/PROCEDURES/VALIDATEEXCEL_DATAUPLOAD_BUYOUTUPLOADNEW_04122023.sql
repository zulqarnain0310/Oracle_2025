--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" 
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
         SELECT ( SELECT UTILS.CONVERT_TO_NUMBER(B.TimeKey,10,0) 
                  FROM SysDataMatrix A
                         JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
                   WHERE  A.CurrentStatus = 'C' ) 

           INTO v_Timekey
           FROM DUAL ;
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
         IF ( v_MenuID = 1466 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on Sl. No.*/
            ------------------------------------------------------------
            v_DuplicateCnt NUMBER(10,0) := 0;
            ----------------------------------------------
            ----------------------------------------------
            /*validations on Account No*/
            v_Count NUMBER(10,0);
            v_I NUMBER(10,0);
            v_Entity_Key NUMBER(10,0);
            v_CustomerAcID VARCHAR2(100) := ' ';
            v_CustomerAcIDFound NUMBER(10,0) := 0;
            v_CustomerName VARCHAR2(250) := ' ';
            v_CustName VARCHAR2(250) := ' ';
            v_CustomerNameFound NUMBER(10,0) := 0;
            -------------------------------------------------------------------------
            ----------------------------------------------
            ----------------------------------------------
            /*validations on Scheme*/
            v_DuplicateSchemeInt NUMBER(10,0) := 0;
            v_ErrorCount NUMBER(10,0) := 0;
            v_ErrorCount3 NUMBER(10,0) := 0;
            v_ErrorCount2 NUMBER(10,0) := 0;
            v_ErrorCount4 NUMBER(10,0) := 0;
            v_ErrorCount1 NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..BuyoutUploadDetail') IS NOT NULL  
            IF utils.object_id('BuyoutUploadDetail') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE BuyoutUploadDetail';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM BuyoutUploadDetails_stg 
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
               DELETE FROM BuyoutUploadDetail;
               UTILS.IDENTITY_RESET('BuyoutUploadDetail');

               INSERT INTO BuyoutUploadDetail SELECT * ,
                                                     UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                     UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                     UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM BuyoutUploadDetails_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'UCIC,CustomerName,AssetID,LiabID,Segment,CRE,Balances,CollateralSubType,Nmae Of Security Provider,Seniority Charge,Security Status',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(ReportDate, ' ') = ' '
              AND NVL(AccountNo, ' ') = ' '
              AND NVL(SchemeCode, ' ') = ' '
              AND NVL(NPAClassificationwithSeller, ' ') = ' '
              AND NVL(DateofNPAwithSeller, ' ') = ' '
              AND NVL(DPDwithSeller, ' ') = ' '
              AND NVL(PeakDPDwithSeller, ' ') = ' '
              AND NVL(PeakDPDDate, ' ') = ' ';
            --WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filname,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM BuyoutUploadDetail 
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
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') = ' '
              OR NVL(SlNo, '0') = '0';
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(SlNo) > 16;
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(SlNo) = 0
              AND NVL(SlNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SlNo), '%^[0-9]%');
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(SlNo, ' '), '%[,!@#$%^&*()_-+=/]%');
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM BuyoutUploadDetail 
              GROUP BY SlNo

               HAVING COUNT(SlNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE BuyoutUploadDetail V
               SET a.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Sl. No., kindly check and upload again'
                      END,
                   a.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   a.Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') IN ( SELECT SlNo 
                                        FROM BuyoutUploadDetail a
                                          GROUP BY SlNo

                                           HAVING COUNT(SlNo)  > 1 )
            ;
            END IF;
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerAcID cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' CustomerAcID cannot be blank . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerAcID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerAcID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(AccountNo, ' ') = ' ';
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerAcID cannot greater than 25 Character. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' CustomerAcID cannot greater than 25 Character. Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerAcID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerAcID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(NVL(AccountNo, ' ')) > 25;
            IF utils.object_id('TempDB..tt_tmp_19') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp_19 ';
            END IF;
            DELETE FROM tt_tmp_19;
            UTILS.IDENTITY_RESET('tt_tmp_19');

            INSERT INTO tt_tmp_19 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_NUMBER(EntityKey,10,0)  ) RecentRownumber  ,
                                         EntityKey ,
                                         AccountNo 
                 FROM BuyoutUploadDetail ;
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_tmp_19 ;
            v_I := 1 ;
            v_Entity_Key := 0 ;
            v_CustomerAcID := 0 ;
            v_CustomerNameFound := 0 ;
            v_CustomerAcID := ' ' ;
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT AccountNo ,
                         EntityKey 

                    INTO v_CustomerAcID,
                         v_Entity_Key
                    FROM tt_tmp_19 
                   WHERE  RecentRownumber = v_I
                    ORDER BY EntityKey;
                  SELECT COUNT(1)  

                    INTO v_CustomerAcIDFound
                    FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                   WHERE  CustomerAcID = v_CustomerAcID;
                  IF v_CustomerAcIDFound = 0 THEN

                  BEGIN
                     UPDATE BuyoutUploadDetail
                        SET ErrorMessage = CASE 
                                                WHEN NVL(ErrorMessage, ' ') = ' ' THEN ' CustomerAcID is invalid. Kindly check the entered CustomerAcID'
                            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' CustomerAcID is invalid. Kindly check the entered CustomerAcID'
                               END,
                            ErrorinColumn = CASE 
                                                 WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerAcID'
                            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerAcID'
                               END
                      WHERE  EntityKey = v_Entity_Key;

                  END;
                  END IF;
                  v_I := v_I + 1 ;
                  v_CustomerAcID := ' ' ;

               END;
            END LOOP;
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Only special characters  _  are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Only special characters  _  are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerAcID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerAcID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(AccountNo, ' '), '%[-/,!@#$%^&*()+=]%');
            UPDATE BuyoutUploadDetail V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record is pending for authorization for this Account ID. Kindly authorize or Reject the record '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Record is pending for authorization for this Account ID. Kindly authorize or Reject the record '
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerAcID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerAcID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.AccountNo, ' ') <> ' '
              AND V.AccountNo IN ( SELECT CustomerAcID 
                                   FROM BuyoutUploadDetails_Mod 
                                    WHERE  EffectiveFromTimeKey <= v_Timekey
                                             AND EffectiveToTimeKey >= v_Timekey
                                             AND AuthorisationStatus IN ( 'NP','MP','1A' )
             )
            ;
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SchemeCode cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SchemeCode cannot be blank . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SchemeCode'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SchemeCode'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(SchemeCode, ' ') = ' ';
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SchemeCode cannot greater than 25 Character. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SchemeCode cannot greater than 25 Character. Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SchemeCode'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SchemeCode'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(NVL(SchemeCode, ' ')) > 25;
            IF utils.object_id('SchemeTypeData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE SchemeTypeData';

            END;
            END IF;
            DELETE FROM SchemeTypeData;
            UTILS.IDENTITY_RESET('SchemeTypeData');

            INSERT INTO SchemeTypeData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY SchemeCode ORDER BY SchemeCode  ) ROW_  ,
                               SchemeCode 
                        FROM BuyoutUploadDetail  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DuplicateSchemeInt
              FROM BuyoutUploadDetail A
                     LEFT JOIN DimBuyoutSchemeCode B   ON A.SchemeCode = B.SchemeCode
             WHERE  B.SchemeCode IS NULL;
            IF v_DuplicateSchemeInt > 0 THEN

            BEGIN
               UPDATE BuyoutUploadDetail V
                  SET A.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘SchemeCode’. Kindly enter the values as mentioned in the ‘SchemeCode’ master and upload again. Click on ‘Download Master value’ to download the valid values for thecolumn
                                            '
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘SchemeCode’. Kindly enter the values as mentioned in the ‘SchemeCode’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                         END,
                      A.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SchemeCode'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SchemeCode'
                         END,
                      A.Srnooferroneousrows = V.SlNo
                WHERE  NVL(SchemeCode, ' ') <> ' '
                 AND V.SchemeCode IN ( SELECT A.SchemeCode 
                                       FROM BuyoutUploadDetail A
                                              LEFT JOIN DimBuyoutSchemeCode B   ON A.SchemeCode = B.SchemeCode
                                        WHERE  B.SchemeCode IS NULL )
               ;

            END;
            END IF;
            ---------------------------------------------------
            ----------------------------------------------
            /*validations on NPA Classification with Seller */
            --Declare @DuplicateAssetCnt int=0
            -- UPDATE BuyoutUploadDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Classification with Seller cannot be blank or grtater than 3 Character. Please check the values and upload again.'     
            --					ELSE ErrorMessage+','+SPACE(1)+'NPA Classification with Seller cannot be blank or grtater than 3 Character. Please check the values and upload again.'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPA Classification with Seller' ELSE   ErrorinColumn +','+SPACE(1)+'NPA Classification with Seller' END   
            --	,Srnooferroneousrows=V.SlNo
            --  FROM BuyoutUploadDetail V  
            --WHERE ISNULL(NPAClassificationwithSeller,'')='' Or LEn(ISNULL(NPAClassificationwithSeller,'0') )>3
            -- UPDATE BuyoutUploadDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Classification with Seller cannot be blank or grtater than 3 Character. Please check the values and upload again.'     
            --					ELSE ErrorMessage+','+SPACE(1)+'NPA Classification with Seller cannot be blank or grtater than 3 Character. Please check the values and upload again.'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPA Classification with Seller' ELSE   ErrorinColumn +','+SPACE(1)+'NPA Classification with Seller' END   
            --	,Srnooferroneousrows=V.SlNo
            --  FROM BuyoutUploadDetail V  
            --WHERE ISNULL(NPAClassificationwithSeller,'')='' 
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘NPA Classification with Seller’. Kindly enter ‘Y or N’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘NPA Classification with Seller’. Kindly enter ‘Y or N’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPA Classification with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPA Classification with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(NPAClassificationwithSeller, ' ') NOT IN ( 'Y','N',' ','NULL' )
            ;
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            ---------------------------------------------------
            /*validations on Date of NPA with Seller */
            --Declare @DuplicateAssetCnt int=0
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of NPA with Seller cannot be blank When NPA Classification with Seller is Y . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of NPA with Seller cannot be blank When NPA Classification with Seller is Y . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Date of NPA with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Date of NPA with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(NPAClassificationwithSeller, ' ') = 'Y'
              AND NVL(DateofNPAwithSeller, ' ') = ' ';
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN '’Date of NPA with Seller’ must be in ddmmyyyy format. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '’Date of NPA with Seller’ must be in ddmmyyyy format. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPA Date with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPA Date with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  utils.isdate(DateofNPAwithSeller) = 0
              AND NVL(DateofNPAwithSeller, ' ') <> ' ';
            --------------------------------------------------------------------
            ---------------------------------------------------	 
            /*validations on DPD with Seller */
            --Declare @DuplicateAssetCnt int=0
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DPD with Seller cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller cannot be blank . . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(DPDwithSeller, ' ') = ' ';
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DPD with Seller cannot be greater than 4 digits . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller cannot be greater than 4 digits. Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(NVL(DPDwithSeller, ' ')) > 4;
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DPD with Seller., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DPD with Seller, kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(DPDwithSeller) = 0
              AND NVL(DPDwithSeller, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(DPDwithSeller), '%^[0-9]%');
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters are not allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters are not allowed,  kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(DPDwithSeller, ' ') <> ' '
              AND REGEXP_LIKE(NVL(DPDwithSeller, ' '), '%[,/-_!@#$%^&*()+=]%');
            SELECT COUNT(1)  

              INTO v_ErrorCount
              FROM BuyoutUploadDetail V
             WHERE  ( utils.isnumeric(DPDwithSeller) = 0
                      AND NVL(DPDwithSeller, ' ') <> ' ' )
                      OR REGEXP_LIKE(utils.isnumeric(DPDwithSeller), '%^[0-9]%');
            SELECT COUNT(1)  

              INTO v_ErrorCount3
              FROM BuyoutUploadDetail V
             WHERE  NVL(DPDwithSeller, ' ') <> ' '
                      AND REGEXP_LIKE(NVL(DPDwithSeller, ' '), '%[,/-_!@#$%^&*()+=]%');
            SELECT COUNT(1)  

              INTO v_ErrorCount2
              FROM BuyoutUploadDetail V
             WHERE  NVL(PeakDPDwithSeller, ' ') <> ' '
                      AND REGEXP_LIKE(NVL(PeakDPDwithSeller, ' '), '%[,/-_!@#$%^&*()+=]%');
            SELECT COUNT(1)  

              INTO v_ErrorCount4
              FROM BuyoutUploadDetail V
             WHERE  ( utils.isnumeric(PeakDPDwithSeller) = 0
                      AND NVL(PeakDPDwithSeller, ' ') <> ' ' )
                      OR REGEXP_LIKE(utils.isnumeric(PeakDPDwithSeller), '%^[0-9]%');
            IF ( v_ErrorCount = 0
              AND v_ErrorCount3 = 0
              AND v_ErrorCount2 = 0
              AND v_ErrorCount4 = 0 ) THEN

            BEGIN
               UPDATE BuyoutUploadDetail V
                  SET V.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Peak DPD should be greater or equal to  Seller DPD , kindly remove and try again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Peak DPD should be greater or equal to  Seller DPD, kindly remove and try again'
                         END,
                      V.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD with Seller'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD with Seller'
                         END,
                      V.Srnooferroneousrows = V.SlNo
                WHERE  NVL(DPDwithSeller, ' ') <> ' '
                 AND UTILS.CONVERT_TO_NUMBER(NVL(PeakDPDwithSeller, '0'),10,0) < UTILS.CONVERT_TO_NUMBER(NVL(DPDwithSeller, '0'),10,0)
                 AND NVL(PeakDPDwithSeller, ' ') <> ' ';

            END;
            END IF;
            --DPDwithSeller
            --PeakDPDwithSeller
            ---------------------------------------------------	
            ---------------------------------------------------	 
            /*validations on Peak DPD with Seller */
            --Declare @DuplicateAssetCnt int=0
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Peak DPD with Seller cannot be greater than 4 digits . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Peak DPD with Seller cannot be greater than 4 digits . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Peak DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Peak DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(PeakDPDwithSeller, ' ') <> ' '
              AND LENGTH(NVL(PeakDPDwithSeller, ' ')) > 4;
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Peak DPD with Seller., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Peak DPD with Seller, kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Peak DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Peak DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(PeakDPDwithSeller) = 0
              AND NVL(PeakDPDwithSeller, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PeakDPDwithSeller), '%^[0-9]%');
            SELECT COUNT(1)  

              INTO v_ErrorCount1
              FROM BuyoutUploadDetail V
             WHERE  ( utils.isnumeric(PeakDPDwithSeller) = 0
                      AND NVL(PeakDPDwithSeller, ' ') <> ' ' )
                      OR REGEXP_LIKE(utils.isnumeric(PeakDPDwithSeller), '%^[0-9]%');
            --IF @ErrorCount1=0
            --BEGIN
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters are not allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters are not allowed,  kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Peak DPD with Seller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Peak DPD with Seller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(PeakDPDwithSeller, ' ') <> ' '
              AND REGEXP_LIKE(NVL(PeakDPDwithSeller, ' '), '%[,/-_!@#$%^&*()+=]%');
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            --END
            ---------------------------------------------------	
            ---------------------------------------------------
            /*validations on Peak DPD Date*/
            --Declare @DuplicateAssetCnt int=0
            -- UPDATE BuyoutUploadDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Peak DPD Date cannot be blank when Peak DPD with Seller is present . Please check the values and upload again.'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Peak DPD Date cannot be blank when Peak DPD with Seller is present . Please check the values and upload again.'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Peak DPD Date' ELSE   ErrorinColumn +','+SPACE(1)+'Peak DPD Date' END   
            --	,Srnooferroneousrows=V.SlNo
            --  FROM BuyoutUploadDetail V  
            --WHERE  ISNULL(PeakDPDwithSeller,'')<>''  AND ISNULL(PeakDPDDate,'')=''
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Peak DPD Date must be in ddmmyyyy format. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Peak DPD Date must be in ddmmyyyy format. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Peak DPD Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Peak DPD Date'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  utils.isdate(PeakDPDDate) = 0
              AND NVL(PeakDPDDate, ' ') <> ' ';
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            --------------------------------------------------------------------
            ---------------------------------------------------
            /*validations on Report Date*/
            --Declare @DuplicateAssetCnt int=0
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Report Date cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Report Date cannot be blank  . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Report Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Report Date'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(ReportDate, ' ') = ' ';
            UPDATE BuyoutUploadDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Report Date must be in ddmmyyyy format. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Report Date must be in ddmmyyyy format. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Report Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Report Date'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  utils.isdate(ReportDate) = 0
              AND NVL(ReportDate, ' ') <> ' ';
            DBMS_OUTPUT.PUT_LINE('FinalEND');
            --------------------------------------------------------------------
            ---------------------------------------------------
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
                                FROM BuyoutUploadDetails_stg 
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
              ( SELECT SlNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM BuyoutUploadDetail  );
            DBMS_OUTPUT.PUT_LINE('Row Effected');
            DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
            --	----SELECT * FROM BuyoutUploadDetail 
            --	--ORDER BY ErrorMessage,BuyoutUploadDetail.ErrorinColumn DESC
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

                 ORDER BY UTILS.CONVERT_TO_NUMBER(SR_No,10,0) ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM BuyoutUploadDetails_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('1');
               DELETE BuyoutUploadDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE('2');
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.BuyoutUploadDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM BuyoutUploadDetail
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOADNEW_04122023" TO "ADF_CDR_RBL_STGDB";
