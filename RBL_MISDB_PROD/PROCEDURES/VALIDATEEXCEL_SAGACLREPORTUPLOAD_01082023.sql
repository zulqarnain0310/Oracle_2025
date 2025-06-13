--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" 
(
  iv_MenuID IN NUMBER DEFAULT 24760 ,
  v_UserLoginId IN VARCHAR2 DEFAULT u'C33228' ,
  v_rptDate IN VARCHAR2 DEFAULT u'31/12/2022' ,
  v_FileName IN VARCHAR2 DEFAULT u'SAGUpload.xlsx' 
)
AS
   v_MenuID NUMBER(10,0) := iv_MenuID;
   v_cursor SYS_REFCURSOR;
--DECLARE
--	 @MenuID		INT				= 24760
--	,@rptDate		VARCHAR(10)		= '10/07/2023'
--	,@UserLoginId	VARCHAR(20)		='C33228'
--	,@FileName		VARCHAR(MAX)	= N'SAGUpload (13).xlsx' 

BEGIN

   BEGIN
      DECLARE
         v_FileNameUpload VARCHAR2(100);
         v_temp NUMBER(1, 0) := 0;
         v_rptDate2 VARCHAR2(200);
         v_Timekey NUMBER(10,0);

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         v_FileNameUpload := v_UserLoginId || '_' || v_FileName ;
         DBMS_OUTPUT.PUT_LINE('@FileNameUpload');
         DBMS_OUTPUT.PUT_LINE(v_FileNameUpload);
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                             WHERE  FileNames = v_FileName );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD

             WHERE  FileNames = v_FileName;
            DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);

         END;
         END IF;
         v_rptDate2 := (UTILS.CONVERT_TO_VARCHAR2(v_rptDate,200,p_style=>103)) ;
         DBMS_OUTPUT.PUT_LINE(v_rptDate2);
         SELECT Timekey 

           INTO v_Timekey
           FROM Automate_Advances 
          WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = v_rptDate2;
         DBMS_OUTPUT.PUT_LINE(v_Timekey);
         IF ( NVL(v_MenuID, ' ') = ' ' ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SET @MenuID');
            SELECT MenuId 

              INTO v_MenuId
              FROM SysCRisMacMenu 
             WHERE  MenuCaption = 'ACL Report';
            DBMS_OUTPUT.PUT_LINE(v_MenuId);

         END;
         END IF;
         IF ( v_MenuID = 24760 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            v_DuplicateCnt NUMBER(10,0) := 0;

         BEGIN
            IF NVL(v_TimeKey, 0) = 0 THEN

            BEGIN
               SELECT Timekey 

                 INTO v_TimeKey
                 FROM Automate_Advances 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = v_rptDate2;

            END;
            END IF;
            IF utils.object_id('TEMPDB..tt_UploadSAGACLReport_2') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UploadSAGACLReport_2 ';

            END;
            END IF;
            --drop table IF exists tt_UploadSAGACLReport_2
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM DPDCSVUpload  ) );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

             --where UserLoginId=@UserLoginId))
            BEGIN
               DBMS_OUTPUT.PUT_LINE('NO Data');
               INSERT INTO RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD
                 ( SR_No, UCIF_ID, CustomerId, CustomerACID, ColumnName, ErrorData, ErrorType, FileNames, Flag )
                 ( SELECT 0 SlNo  ,
                          ' ' UCIF_ID  ,
                          ' ' CustomerId  ,
                          ' ' CustomerACID  ,
                          ' ' ColumnName  ,
                          'No Record found' ErrorData  ,
                          'No Record found' ErrorType  ,
                          v_FileName ,
                          'SUCCESS' 
                     FROM DUAL  );
               --SELECT 0 SlNo , '' ColumnName,'' ErrorData,'' ErrorType,'SUCCESS'   
               GOTO ErrorData;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DATA PRESENT');
               DELETE FROM tt_UploadSAGACLReport_2;
               UTILS.IDENTITY_RESET('tt_UploadSAGACLReport_2');

               INSERT INTO tt_UploadSAGACLReport_2 ( 
               	SELECT * ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  

               	  --,CAST('' AS VARCHAR(MAX)) Srnooferroneousrows
               	  FROM DPDCSVUpload  );--WHERE UserLoginId=@UserLoginId

            END;
            END IF;
            UPDATE tt_UploadSAGACLReport_2 
               SET ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   ErrorinColumn = 'SR_No,UCIC_Id,CIF_Id,ACCOUNT_Id,UserLoginId',
                   Srnooferroneousrows = ' '
             WHERE  NVL(SR_No, ' ') = ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(UserLoginId, ' ') = ' ';
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Excel Vaildate '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Excel Vaildate'
                      END,
                   Srnooferroneousrows = ' '
             WHERE  NVL(SR_No, ' ') <> ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(UserLoginId, ' ') = ' ';
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM tt_UploadSAGACLReport_2 
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
            /*VALIDATIONS ON SR_NO */
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SR_No cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SR_No cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(SR_No, ' ') = ' '
              OR NVL(SR_No, '0') = '0';
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SR_No cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SR_No cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  ( NVL(SR_No, ' ') <> ' '
              AND LENGTH(SR_No) > 16 );
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SR_No, kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SR_No, kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  ( utils.isnumeric(SR_No) = 0
              AND NVL(SR_No, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SR_No), '%^[0-9]%');
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed in SR_No, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed SR_No, kindly remove and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  REGEXP_LIKE(NVL(SR_No, ' '), '%[,!@#$%^&*()_-+=/]%-\/_');
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM tt_UploadSAGACLReport_2 
              GROUP BY SR_No

               HAVING COUNT(SR_No)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN

            BEGIN
               UPDATE tt_UploadSAGACLReport_2 V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate SR_No found, kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate SR_No found, kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No'
                         END,
                      Srnooferroneousrows = V.SR_No
                WHERE  NVL(SR_No, ' ') IN ( SELECT SR_No 
                                            FROM tt_UploadSAGACLReport_2 
                                              GROUP BY SR_No

                                               HAVING COUNT(SR_No)  > 1 )
               ;

            END;
            END IF;
            --IF OBJECT_ID('TEMPDB..#LIVE_UCIF_CIF_ACCID') IS NOT NULL  
            --		DROP TABLE #LIVE_UCIF_CIF_ACCID
            --SELECT CBD.UCIF_ID,CBD.CustomerId,ABD.CustomerACID
            --INTO #LIVE_UCIF_CIF_ACCID
            --FROM CustomerBasicDetail CBD
            --INNER JOIN AdvAcBasicDetail ABD
            --ON CBD.CustomerEntityId=ABD.CustomerEntityId
            --AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)
            --WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)
            /*VALIDATIONS ON USER LOGIN ID */
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'User Login ID is given and remaining excel file is blank. Please check the file, fill the missing details and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'User Login ID is given and remaining excel file is blank. Please check the file, fill the missing details and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User ID '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIC_ID, CIF_ID, ACCOUNT_ID'
                      END,
                   Srnooferroneousrows = Srnooferroneousrows
             WHERE  ( NVL(UserLoginId, ' ') <> ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(SR_No, ' ') = ' ' );
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'User Login ID is blank. Please check the file and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'User Login ID is blank. Please check the file and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User ID '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'User ID'
                      END,
                   Srnooferroneousrows = Srnooferroneousrows
             WHERE  ( NVL(UserLoginId, ' ') = ' '
              AND ( NVL(UCIC_Id, ' ') <> ' '
              OR NVL(CIF_Id, ' ') <> ' '
              OR NVL(ACCOUNT_Id, ' ') <> ' '
              AND NVL(SR_No, ' ') <> ' ' ) );
            --IF OBJECT_ID('TEMPDB..#DistinctUserId') IS NOT NULL
            --		DROP TABLE #DistinctUserId
            --SELECT DISTINCT UserLoginId INTO #DistinctUserId FROM tt_UploadSAGACLReport_2
            --IF NOT EXISTS(SELECT 1 FROM #DistinctUserId WHERE UserLoginId=@UserLoginId)
            --BEGIN
            --	UPDATE tt_UploadSAGACLReport_2 SET
            --		ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid User Login Id found. Please check User Login Id and Upload again.'       
            --		ELSE ErrorMessage+','+SPACE(1)+'Invalid User Login Id found. Please check User Login Id and Upload again.'     END  
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'User Id ' ELSE   ErrorinColumn +','+SPACE(1)+'User Id' END     
            --		,Srnooferroneousrows=Srnooferroneousrows
            --	FROM tt_UploadSAGACLReport_2
            --END
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid User Login Id found. Please check User Login Id and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid User Login Id found. Please check User Login Id and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User ID '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'User ID'
                      END,
                   Srnooferroneousrows = Srnooferroneousrows
             WHERE  ( NVL(UserLoginId, ' ') <> ' '
              AND UserLoginId <> v_UserLoginId );
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'User Login Id does not exist in system. Please check the User Login Id and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'User Login Id does not exist in system. Please check the User Login Id and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User Id'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'User Id'
                      END,
                   Srnooferroneousrows = Srnooferroneousrows
             WHERE  UserLoginId NOT IN ( SELECT UserLoginId 
                                         FROM DimUserInfo 
                                          WHERE  EffectiveToTimeKey = 49999 )
            ;
            /*VALIDATIONS ON UCIF ID */
            --UPDATE tt_UploadSAGACLReport_2 SET
            --	ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid User Id. Please check and Upload again.'       
            --	ELSE ErrorMessage+','+SPACE(1)+'Invalid User Id. Please check and Upload again.'     END  
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'User Id' ELSE   ErrorinColumn +','+SPACE(1)+'User Id' END     
            --	,Srnooferroneousrows=Srnooferroneousrows
            --FROM tt_UploadSAGACLReport_2 V
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIF ID is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIF ID Is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  NVL(V.UCIC_Id, ' ') <> ' '
              AND V.UCIC_Id NOT IN ( SELECT UCIF_ID 
                                     FROM CustomerBasicDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey ) )
            ;
            IF utils.object_id('TEMPDB..tt_DUB_UCIF_9') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB_UCIF_9 ';
            END IF;
            --SELECT * FROM tt_UploadSAGACLReport_2
            DELETE FROM tt_DUB_UCIF_9;
            UTILS.IDENTITY_RESET('tt_DUB_UCIF_9');

            INSERT INTO tt_DUB_UCIF_9 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY UCIC_ID ORDER BY UCIC_ID  ) rw  
                        FROM tt_UploadSAGACLReport_2  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate UCIF ID found in the Uploaded file. Please check & remove the duplicate UCIF ID and upload the file again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate UCIF ID found in the Uploaded file. Please check & remove the duplicate UCIF ID and upload the file again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
               END AS pos_3, V.Srnooferroneousrows
            FROM V ,tt_UploadSAGACLReport_2 V
                   JOIN tt_DUB_UCIF_9 D   ON D.UCIC_Id = V.UCIC_Id ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.Srnooferroneousrows;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid UCIF ID. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid UCIF ID. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  NVL(V.UCIC_Id, ' ') <> ' '
              AND REGEXP_LIKE(NVL(UCIC_Id, ' '), '%[,!@#<>$%^&[*{}(])_-+=/]%');
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIC ID cannot be greater than 20 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIC ID cannot be greater than 20 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  LENGTH(UCIC_Id) > 20;
            /*VALIDATIONS ON CUSTOMER ID */
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CUSTOMER ID is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID Is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  NVL(V.CIF_Id, ' ') <> ' '
              AND V.CIF_Id NOT IN ( SELECT CustomerId 
                                    FROM CustomerBasicDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) )
            ;
            IF utils.object_id('TEMPDB..tt_DUB_CIF_9') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB_CIF_9 ';
            END IF;
            DELETE FROM tt_DUB_CIF_9;
            UTILS.IDENTITY_RESET('tt_DUB_CIF_9');

            INSERT INTO tt_DUB_CIF_9 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY CIF_ID ORDER BY CIF_ID  ) rw  
                        FROM tt_UploadSAGACLReport_2  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate CUSTOMER ID found in the Uploaded file. Please check & remove the duplicate CUSTOMER ID and upload the file again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate CUSTOMER ID found in the Uploaded file. Please check & remove the duplicate CUSTOMER ID and upload the file again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
               END AS pos_3, V.Srnooferroneousrows
            FROM V ,tt_UploadSAGACLReport_2 V
                   JOIN tt_DUB_CIF_9 D   ON D.CIF_ID = V.CIF_ID ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.Srnooferroneousrows;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CUSTOMER ID. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CUSTOMER ID. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  NVL(V.CIF_ID, ' ') <> ' '
              AND REGEXP_LIKE(NVL(CIF_ID, ' '), '%[,!@#<>$%^&[*{}(])_-+=/]%');
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CUSTOMER ID cannot be greater than 30 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID cannot be greater than 30 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  LENGTH(CIF_ID) > 30;
            /*VALIDATIONS ON ACCOUNT ID */
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ACCOUNT ID is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID Is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  NVL(V.ACCOUNT_Id, ' ') <> ' '
              AND V.ACCOUNT_Id NOT IN ( SELECT CustomerACID 
                                        FROM AdvAcBasicDetail 
                                         WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                  AND EffectiveToTimeKey >= v_Timekey ) )
            ;
            IF utils.object_id('TEMPDB..tt_DUB_ACCOUNTID_9') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB_ACCOUNTID_9 ';
            END IF;
            DELETE FROM tt_DUB_ACCOUNTID_9;
            UTILS.IDENTITY_RESET('tt_DUB_ACCOUNTID_9');

            INSERT INTO tt_DUB_ACCOUNTID_9 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY ACCOUNT_Id ORDER BY ACCOUNT_Id  ) rw  
                        FROM tt_UploadSAGACLReport_2  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate ACCOUNT ID found in the Uploaded File. Please check & remove the duplicate ACCOUNT ID and upload the file again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate ACCOUNT ID found in the Uploaded File. Please check & remove the duplicate ACCOUNT ID and upload the file again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
               END AS pos_3, V.Srnooferroneousrows
            FROM V ,tt_UploadSAGACLReport_2 V
                   JOIN tt_DUB_ACCOUNTID_9 D   ON D.ACCOUNT_Id = V.ACCOUNT_Id ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.Srnooferroneousrows;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid ACCOUNT ID. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid ACCOUNT ID. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  NVL(V.ACCOUNT_Id, ' ') <> ' '
              AND REGEXP_LIKE(NVL(ACCOUNT_Id, ' '), '%[,!@#<>$%^&[*{}(])_-+=/]%');
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ACCOUNT ID cannot be greater than 30 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID cannot be greater than 30 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  LENGTH(ACCOUNT_Id) > 30;
            --------------------------------------------------------------------------------------------------------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('UCIF_ID Incorrect but CustomerID & Account_ID is Correct');
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerId & Account_Id is Availble and Valid but UCIF ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CustomerId & Account_Id is Availble and Valid but UCIF ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id NOT IN ( SELECT UCIF_ID 
                                     FROM CustomerBasicDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id IN ( SELECT CustomerId 
                                FROM CustomerBasicDetail 
                                 WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                          AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id IN ( SELECT CustomerACID 
                                    FROM CustomerBasicDetail CBD
                                           JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                           AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                           AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                     WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                              AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIF_ID & CustomerId is Availble and Valid but Account_Id is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIF_ID & CustomerId is Availble and Valid but Account_Id is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id IN ( SELECT UCIF_ID 
                                 FROM CustomerBasicDetail 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id IN ( SELECT CustomerId 
                                FROM CustomerBasicDetail 
                                 WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                          AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id NOT IN ( SELECT CustomerACID 
                                        FROM CustomerBasicDetail CBD
                                               JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                               AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                               AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                         WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                                  AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIF_ID & Account_ID is available & Valid but Customer_ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIF_ID & Account_ID is available & Valid but Customer_ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id IN ( SELECT UCIF_ID 
                                 FROM CustomerBasicDetail 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id NOT IN ( SELECT CustomerId 
                                    FROM CustomerBasicDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id IN ( SELECT CustomerACID 
                                    FROM CustomerBasicDetail CBD
                                           JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                           AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                           AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                     WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                              AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerId is available & Valid but UCIF_ID & Account_ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CustomerId is available & Valid but UCIF_ID & Account_ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id NOT IN ( SELECT UCIF_ID 
                                     FROM CustomerBasicDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id IN ( SELECT CustomerId 
                                FROM CustomerBasicDetail 
                                 WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                          AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id NOT IN ( SELECT CustomerACID 
                                        FROM CustomerBasicDetail CBD
                                               JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                               AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                               AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                         WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                                  AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account_Id, CustomerId & UCIF ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account_Id, CustomerId & UCIF ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id NOT IN ( SELECT UCIF_ID 
                                     FROM CustomerBasicDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id NOT IN ( SELECT CustomerId 
                                    FROM CustomerBasicDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id NOT IN ( SELECT CustomerACID 
                                        FROM CustomerBasicDetail CBD
                                               JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                               AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                               AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                         WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                                  AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account_Id is Availble and Valid but CustomerId & UCIF ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account_Id is Availble and Valid but CustomerId & UCIF ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id NOT IN ( SELECT UCIF_ID 
                                     FROM CustomerBasicDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id NOT IN ( SELECT CustomerId 
                                    FROM CustomerBasicDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id IN ( SELECT CustomerACID 
                                    FROM CustomerBasicDetail CBD
                                           JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                           AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                           AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                     WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                              AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            UPDATE tt_UploadSAGACLReport_2 V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIF_ID is available & Valid but Customer_ID & Account_ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIF_ID is available & Valid but Customer_ID & Account_ID is not available for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.Srnooferroneousrows
             WHERE  ( NVL(V.UCIC_Id, ' ') <> ' '
              AND NVL(V.CIF_Id, ' ') <> ' '
              AND NVL(V.ACCOUNT_Id, ' ') <> ' ' )
              AND V.UCIC_Id IN ( SELECT UCIF_ID 
                                 FROM CustomerBasicDetail 
                                  WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                           AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.CIF_Id NOT IN ( SELECT CustomerId 
                                    FROM CustomerBasicDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) )

              AND V.ACCOUNT_Id NOT IN ( SELECT CustomerACID 
                                        FROM CustomerBasicDetail CBD
                                               JOIN AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId
                                               AND ( ABD.EffectiveFromTimeKey <= v_TimeKey
                                               AND ABD.EffectiveToTimeKey >= v_TimeKey )
                                         WHERE  ( CBD.EffectiveFromTimeKey <= v_TimeKey
                                                  AND CBD.EffectiveToTimeKey >= v_TimeKey ) )
            ;
            --------------------------------------------------------------------------------------------------------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('123');
            GOTO valid;

         END;
         END IF;
         <<ErrorData>>
         DBMS_OUTPUT.PUT_LINE('NO');
         OPEN  v_cursor FOR
            SELECT * ,
                   'Data' TableName  
              FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
             WHERE  FileNames = v_FileName ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN;
         <<VALID>>
         -------------- COMMENTED THE FILTER CONDITION BY SATWAJI AS ON 26/06/2023 -------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM DPDCSVUpload  );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

          --WHERE UserLoginId=@UserLoginId
         BEGIN
            DBMS_OUTPUT.PUT_LINE('NO ERRORS');

         END;

         --Insert into dbo.MasterUploadData_SAGACLProvDPD  

         --(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag)   

         --SELECT '' SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@FileName,'SUCCESS'
         ELSE

         BEGIN
            DBMS_OUTPUT.PUT_LINE('VALIDATION ERRORS');
            DBMS_OUTPUT.PUT_LINE(v_FileName);
            INSERT INTO RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD
              ( SR_No, UCIF_ID, CustomerId, CustomerACID, ColumnName, ErrorData, ErrorType, FileNames, Srnooferroneousrows, Flag )
              ( SELECT Srnooferroneousrows ,
                       UCIC_Id ,
                       CIF_Id ,
                       ACCOUNT_Id ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_FileName ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM tt_UploadSAGACLReport_2  );
            GOTO FINAL;

         END;
         END IF;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                             WHERE  FileNames = v_FileName
                                      AND NVL(ERRORDATA, ' ') <> ' ' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE UploadStatus

             WHERE  FileNames = v_FileName;

         END;
         ELSE

         BEGIN
            UPDATE UploadStatus
               SET ValidationOfData = 'Y',
                   ValidationOfDataCompletedOn = SYSDATE
             WHERE  FileNames = v_FileName;

         END;
         END IF;
         <<FINAL>>
         DBMS_OUTPUT.PUT_LINE('FINAL');
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                             WHERE  FileNames = v_FileName
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
               SELECT 1 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT 1 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT SR_No ,
                      UCIF_ID ,
                      CustomerId ,
                      CustomerACID ,
                      ColumnName ,
                      ErrorData ,
                      ErrorType ,
                      FileNames ,
                      Flag ,
                      Srnooferroneousrows ,
                      'Validation' TableName  
                 FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                WHERE  FileNames = v_FileName
                         AND ( NVL(ColumnName, ' ') <> ' '
                         AND NVL(ErrorData, ' ') <> ' '
                         AND NVL(ErrorType, ' ') <> ' ' )
                 ORDER BY SR_No ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            -------------- COMMENTED THE FILTER CONDITION BY SATWAJI AS ON 26/06/2023 -------------------------------
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM DPDCSVUpload  );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

             --WHERE UserLoginId=@UserLoginId
            BEGIN
               DELETE DPDCSVUpload
               ;
               --WHERE UserLoginId=@UserLoginId
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.DPDCSVUpload' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

            END;
            END IF;

         END;
         ELSE
         DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('DATA NOT PRESENT');
            --SELECT *,'Data'TableName
            --FROM dbo.MasterUploadData_SAGACLProvDPD WHERE FileNames=@FileName 
            --ORDER BY ErrorData DESC
            --SELECT SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows,'Data'TableName 
            --FROM
            --(
            --	SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows
            --	ORDER BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows)AS ROW 
            --	FROM  dbo.MasterUploadData_SAGACLProvDPD    
            --)a 
            --WHERE A.ROW=1
            --AND FileNames=@FileName
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM tt_UploadSAGACLReport_2  );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE tt_UploadSAGACLReport_2
               ;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport_2' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

            END;
            END IF;
            OPEN  v_cursor FOR
               SELECT 1 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            OPEN  v_cursor FOR
               SELECT 1 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            IF utils.object_id('TEMPDB..tt_EMPTY_4') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_EMPTY_4 ';
            END IF;
            DELETE FROM tt_EMPTY_4;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_EMPTY_4  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN
   DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      -------------- COMMENTED THE FILTER CONDITION BY SATWAJI AS ON 26/06/2023 -------------------------------
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM DPDCSVUpload  );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

       -- WHERE UserLoginId=@UserLoginId
      BEGIN
         DELETE DPDCSVUpload
         ;
         --WHERE UserLoginId=@UserLoginId
         DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.DPDCSVUpload' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

      END;
      END IF;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD_01082023" TO "ADF_CDR_RBL_STGDB";
