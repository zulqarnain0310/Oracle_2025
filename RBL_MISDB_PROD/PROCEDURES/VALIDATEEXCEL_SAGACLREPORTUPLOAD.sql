--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_SAGACLREPORTUPLOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" 
(
  iv_MenuID IN NUMBER DEFAULT 24754 ,
  v_UserLoginId IN VARCHAR2 DEFAULT u'C33228' ,
  v_rptDate IN VARCHAR2 DEFAULT u'31/12/2022' ,
  v_FileName IN VARCHAR2 DEFAULT u'SAGUpload.xlsx' 
)
AS
   v_MenuID NUMBER(10,0) := iv_MenuID;
   v_cursor SYS_REFCURSOR;
--DECLARE  
--	 @MenuID		INT				= 24754  
--	,@rptDate		VARCHAR(10)		= '30/06/2023'  
--	,@UserLoginId	VARCHAR(20)		= 'C33228'  
--	,@FileName		VARCHAR(MAX)	= N'SAGUpload (3).xlsx'

BEGIN

   BEGIN
      DECLARE
         v_FileNameUpload VARCHAR2(100);
         v_temp NUMBER(1, 0) := 0;
         v_rptDate2 VARCHAR2(200);
         v_Timekey NUMBER(10,0);
         v_FailureCount NUMBER(10,0) := ( SELECT COUNT(*)  
           FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
          WHERE  FileNames = v_FileName
                   AND ( NVL(ColumnName, ' ') <> ' '
                   AND NVL(ErrorData, ' ') <> ' '
                   AND NVL(ErrorType, ' ') <> ' ' ) );
         v_SuccessCount NUMBER(10,0) := ( SELECT COUNT(*)  
           FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
          WHERE  FileNames = v_FileName
                   AND ( NVL(ColumnName, ' ') = ' '
                   AND NVL(ErrorData, ' ') = ' '
                   AND NVL(ErrorType, ' ') = ' ' ) );

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
         IF ( v_MenuID = 24754 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            ----------------------------------------------------------------------`Added by Prashant-----10082023---------------------------------------------------------------	
            v_TimeKey1 NUMBER(10,0) := ( SELECT Timekey 
              FROM Automate_Advances 
             WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = v_rptDate2 );
            v_TimeKey2 NUMBER(10,0) := ( SELECT Timekey 
              FROM Automate_Advances 
             WHERE  EXT_FLG = 'Y' );
            v_DuplicateCnt NUMBER(10,0) := 0;
            /*  --------------------------------------------------------------------------------------------------------------------------------------------------------------  
            			PRINT 'UCIF_ID Incorrect but CustomerID & Account_ID is Correct'  
            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'CustomerId & Account_Id is Availble and Valid but UCIF ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'CustomerId & Account_Id is Availble and Valid but UCIF ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIF ID' ELSE ErrorinColumn +','+SPACE(1)+  'UCIF ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id NOT IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id IN(   
            			      SELECT CustomerACID   
            			      FROM CustomerBasicDetail CBD  
            			      INNER JOIN AdvAcBasicDetail ABD  
            			      ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			      AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			      WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			     )  

            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'UCIF_ID & CustomerId is Availble and Valid but Account_Id is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'UCIF_ID & CustomerId is Availble and Valid but Account_Id is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'ACCOUNT ID' ELSE ErrorinColumn +','+SPACE(1)+  'ACCOUNT ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id NOT IN (   
            			       SELECT CustomerACID   
            			       FROM CustomerBasicDetail CBD  
            			       INNER JOIN AdvAcBasicDetail ABD  
            			       ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			       AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			       WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			      )  

            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'UCIF_ID & Account_ID is available & Valid but Customer_ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'UCIF_ID & Account_ID is available & Valid but Customer_ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIF ID' ELSE ErrorinColumn +','+SPACE(1)+  'UCIF ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id NOT IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id IN(  
            			      SELECT CustomerACID   
            			      FROM CustomerBasicDetail CBD  
            			      INNER JOIN AdvAcBasicDetail ABD  
            			      ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			      AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			      WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			     )  

            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'CustomerId is available & Valid but UCIF_ID & Account_ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'CustomerId is available & Valid but UCIF_ID & Account_ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF ID' ELSE ErrorinColumn +','+SPACE(1)+  'CIF ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id NOT IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id NOT IN(  
            			       SELECT CustomerACID   
            			       FROM CustomerBasicDetail CBD  
            			       INNER JOIN AdvAcBasicDetail ABD  
            			       ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			       AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			       WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			      )  

            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account_Id, CustomerId & UCIF ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'Account_Id, CustomerId & UCIF ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF ID' ELSE ErrorinColumn +','+SPACE(1)+  'CIF ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id NOT IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id NOT IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id NOT IN(  
            			       SELECT CustomerACID   
            			       FROM CustomerBasicDetail CBD  
            			       INNER JOIN AdvAcBasicDetail ABD  
            			       ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			       AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			       WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			      )  

            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Account_Id is Availble and Valid but CustomerId & UCIF ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'Account_Id is Availble and Valid but CustomerId & UCIF ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CIF ID' ELSE ErrorinColumn +','+SPACE(1)+  'CIF ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id NOT IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id NOT IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id IN(   
            			      SELECT CustomerACID   
            			      FROM CustomerBasicDetail CBD  
            			      INNER JOIN AdvAcBasicDetail ABD  
            			      ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			      AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			      WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			     )  

            			UPDATE tt_UploadSAGACLReport SET      
            			  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'UCIF_ID is available & Valid but Customer_ID & Account_ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'         
            			  ELSE ErrorMessage+','+SPACE(1)+'UCIF_ID is available & Valid but Customer_ID & Account_ID is not available for the Uploaded date'+' '+CONVERT(VARCHAR(10),@rptDate,103)+'. Please check the values and upload again'     END    
            			  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIF ID' ELSE ErrorinColumn +','+SPACE(1)+  'UCIF ID' END  
            			  ,Srnooferroneousrows=V.Srnooferroneousrows    
            			FROM tt_UploadSAGACLReport V      
            			WHERE (ISNULL(V.UCIC_Id,'')<>'' AND ISNULL(V.CIF_Id,'')<>''  AND ISNULL(V.ACCOUNT_Id,'')<>'')   
            			AND V.UCIC_Id IN(SELECT UCIF_ID FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.CIF_Id NOT IN(SELECT CustomerId FROM CustomerBasicDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey))   
            			AND V.ACCOUNT_Id NOT IN(  
            			       SELECT CustomerACID   
            			       FROM CustomerBasicDetail CBD  
            			       INNER JOIN AdvAcBasicDetail ABD  
            			       ON CBD.CustomerEntityId=ABD.CustomerEntityId  
            			       AND (ABD.EffectiveFromTimeKey<=@TimeKey AND ABD.EffectiveToTimeKey>=@TimeKey)  
            			       WHERE (CBD.EffectiveFromTimeKey<=@TimeKey AND CBD.EffectiveToTimeKey>=@TimeKey)  
            			      )  

            			*/
            -------------------------------------------Combination start-------------------------------------------------------------------------------------------------------------------  
            v_UCICID_CNT NUMBER(10,0) := ( SELECT COUNT(UCIC_Id)  
              FROM tt_UploadSAGACLReport  );
            v_CIF_Id_CNT NUMBER(10,0) := ( SELECT COUNT(CIF_Id)  
              FROM tt_UploadSAGACLReport  );
            v_ACCOUNT_Id_CNT NUMBER(10,0) := ( SELECT COUNT(ACCOUNT_Id)  
              FROM tt_UploadSAGACLReport  );

         BEGIN
            IF NVL(v_TimeKey, 0) = 0 THEN

            BEGIN
               SELECT Timekey 

                 INTO v_TimeKey
                 FROM Automate_Advances 
                WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = v_rptDate2;

            END;
            END IF;
            IF utils.object_id('TEMPDB..tt_UploadSAGACLReport') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_UploadSAGACLReport ';

            END;
            END IF;
            -------------- COMMENTED THE FILTER CONDITION BY SATWAJI AS ON 20/06/2023 -------------------------------
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
               DELETE FROM tt_UploadSAGACLReport;
               UTILS.IDENTITY_RESET('tt_UploadSAGACLReport');

               INSERT INTO tt_UploadSAGACLReport ( 
               	SELECT * ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  

               	  --,CAST('' AS VARCHAR(MAX)) Srnooferroneousrows  
               	  FROM DPDCSVUpload  );--WHERE UserLoginId=@UserLoginId  

            END;
            END IF;
            IF NVL(v_TimeKey1, 49999) > NVL(v_TimeKey2, 1) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               UPDATE tt_UploadSAGACLReport V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Report date is not equal to or greater than process date. Please check and Upload again.'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Report date is not equal to or greater than process date. Please check and Upload again.'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Report Date'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Report Date'
                         END,
                      Srnooferroneousrows = ' '
                WHERE  NVL(v_TimeKey1, 49999) > NVL(v_TimeKey2, 1);
               OPEN  v_cursor FOR
                  SELECT -8 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
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

               BEGIN
                  DELETE DPDCSVUpload
                  ;
                  DBMS_OUTPUT.PUT_LINE(1);
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.DPDCSVUpload' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM tt_UploadSAGACLReport  );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE tt_UploadSAGACLReport
                  ;
                  DBMS_OUTPUT.PUT_LINE(1);
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;

            END;
            END IF;
            --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            UPDATE tt_UploadSAGACLReport 
               SET ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   ErrorinColumn = 'SR_No,UCIC_Id,CIF_Id,ACCOUNT_Id,UserLoginId',
                   Srnooferroneousrows = ' '
             WHERE  NVL(SR_No, ' ') = ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(UserLoginId, ' ') = ' ';
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No'
                      END,
                   Srnooferroneousrows = ' '
             WHERE  NVL(SR_No, ' ') <> ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(UserLoginId, ' ') = ' ';
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Sr No and User Login Id is present and remaining  excel file is blank. Please check and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Sr No and User Login Id is present and remaining  excel file is blank. Please check and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SR_No,User Login ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SR_No,User Login ID'
                      END,
                   Srnooferroneousrows = SR_No
             WHERE  NVL(SR_No, ' ') <> ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(UserLoginId, ' ') <> ' ';
            --IF EXISTS(SELECT 1 FROM tt_UploadSAGACLReport WHERE ISNULL(ErrorMessage,'')<>'')    
            --BEGIN    
            --	PRINT 'NO DATA'    
            --	GOTO ERRORDATA;    
            --END
            /*VALIDATIONS ON SR_NO */
            UPDATE tt_UploadSAGACLReport V
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
            UPDATE tt_UploadSAGACLReport V
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
            UPDATE tt_UploadSAGACLReport V
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
            UPDATE tt_UploadSAGACLReport V
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
              FROM tt_UploadSAGACLReport 
              GROUP BY SR_No

               HAVING COUNT(SR_No)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN

            BEGIN
               UPDATE tt_UploadSAGACLReport V
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
                                            FROM tt_UploadSAGACLReport 
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
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'User Login ID is given and remaining excel file is blank. Please check the file, fill the missing details and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'User Login ID is given and remaining excel file is blank. Please check the file, fill the missing details and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User ID '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIC_ID, CIF_ID, ACCOUNT_ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  ( NVL(UserLoginId, ' ') <> ' '
              AND NVL(UCIC_Id, ' ') = ' '
              AND NVL(CIF_Id, ' ') = ' '
              AND NVL(ACCOUNT_Id, ' ') = ' '
              AND NVL(SR_No, ' ') = ' ' );
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'User Login ID is blank. Please check the file and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'User Login ID is blank. Please check the file and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User ID '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'User ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  ( NVL(UserLoginId, ' ') = ' '
              AND ( NVL(UCIC_Id, ' ') <> ' '
              OR NVL(CIF_Id, ' ') <> ' '
              OR NVL(ACCOUNT_Id, ' ') <> ' '
              AND NVL(SR_No, ' ') <> ' ' ) );
            --IF OBJECT_ID('TEMPDB..#DistinctUserId') IS NOT NULL  
            --  DROP TABLE #DistinctUserId  
            --SELECT DISTINCT UserLoginId INTO #DistinctUserId FROM tt_UploadSAGACLReport  
            --IF NOT EXISTS(SELECT 1 FROM #DistinctUserId WHERE UserLoginId=@UserLoginId)  
            --BEGIN  
            -- UPDATE tt_UploadSAGACLReport SET  
            --  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid User Login Id found. Please check User Login Id and Upload again.'         
            --  ELSE ErrorMessage+','+SPACE(1)+'Invalid User Login Id found. Please check User Login Id and Upload again.'     END    
            --  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'User Id ' ELSE   ErrorinColumn +','+SPACE(1)+'User Id' END       
            --  ,Srnooferroneousrows=Srnooferroneousrows  
            -- FROM tt_UploadSAGACLReport  
            --END  
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid User Login Id found. Please check User Login Id and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid User Login Id found. Please check User Login Id and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User ID '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'User ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  ( NVL(UserLoginId, ' ') <> ' '
              AND UserLoginId <> v_UserLoginId );
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'User Login Id does not exist in system. Please check the User Login Id and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'User Login Id does not exist in system. Please check the User Login Id and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'User Id'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'User Id'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  UserLoginId NOT IN ( SELECT UserLoginId 
                                         FROM DimUserInfo 
                                          WHERE  EffectiveToTimeKey = 49999 )
            ;
            /*VALIDATIONS ON UCIF ID */
            --UPDATE tt_UploadSAGACLReport SET  
            -- ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid User Id. Please check and Upload again.'         
            -- ELSE ErrorMessage+','+SPACE(1)+'Invalid User Id. Please check and Upload again.'     END    
            -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'User Id' ELSE   ErrorinColumn +','+SPACE(1)+'User Id' END       
            -- ,Srnooferroneousrows=SR_No  
            --FROM tt_UploadSAGACLReport V  
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIF ID is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIF ID Is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(V.UCIC_Id, ' ') <> ' '
              AND V.UCIC_Id NOT IN ( SELECT UCIF_ID 
                                     FROM CustomerBasicDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey ) )
            ;
            IF utils.object_id('TEMPDB..tt_DUB_UCIF_8') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB_UCIF_8 ';
            END IF;
            --SELECT * FROM tt_UploadSAGACLReport  
            DELETE FROM tt_DUB_UCIF_8;
            UTILS.IDENTITY_RESET('tt_DUB_UCIF_8');

            INSERT INTO tt_DUB_UCIF_8 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY UCIC_ID ORDER BY UCIC_ID  ) rw  
                        FROM tt_UploadSAGACLReport  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate UCIF ID found in the Uploaded file. Please check & remove the duplicate UCIF ID and upload the file again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate UCIF ID found in the Uploaded file. Please check & remove the duplicate UCIF ID and upload the file again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
               END AS pos_3, V.SR_No
            FROM V ,tt_UploadSAGACLReport V
                   JOIN tt_DUB_UCIF_8 D   ON D.UCIC_Id = V.UCIC_Id ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SR_No;
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid UCIF ID. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid UCIF ID. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(V.UCIC_Id, ' ') <> ' '
              AND REGEXP_LIKE(NVL(UCIC_Id, ' '), '%[,!@#<>$%^&[*{}(])_-+=/]%');
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UCIC ID cannot be greater than 20 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UCIC ID cannot be greater than 20 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIF ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIF ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  LENGTH(UCIC_Id) > 20;
            /*VALIDATIONS ON CUSTOMER ID */
            DBMS_OUTPUT.PUT_LINE('CUSTOMER ID NOT AVAILABLE');
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CUSTOMER ID is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID Is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(V.CIF_Id, ' ') <> ' '
              AND V.CIF_Id NOT IN ( SELECT CustomerId 
                                    FROM CustomerBasicDetail 
                                     WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                              AND EffectiveToTimeKey >= v_Timekey ) )
            ;
            IF utils.object_id('TEMPDB..tt_DUB_CIF_8') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB_CIF_8 ';
            END IF;
            DELETE FROM tt_DUB_CIF_8;
            UTILS.IDENTITY_RESET('tt_DUB_CIF_8');

            INSERT INTO tt_DUB_CIF_8 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY CIF_ID ORDER BY CIF_ID  ) rw  
                        FROM tt_UploadSAGACLReport  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate CUSTOMER ID found in the Uploaded file. Please check & remove the duplicate CUSTOMER ID and upload the file again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate CUSTOMER ID found in the Uploaded file. Please check & remove the duplicate CUSTOMER ID and upload the file again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
               END AS pos_3, V.SR_No
            FROM V ,tt_UploadSAGACLReport V
                   JOIN tt_DUB_CIF_8 D   ON D.CIF_ID = V.CIF_ID ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SR_No;
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CUSTOMER ID. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CUSTOMER ID. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(V.CIF_ID, ' ') <> ' '
              AND REGEXP_LIKE(NVL(CIF_ID, ' '), '%[,!@#<>$%^&[*{}(])_-+=/]%');
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CUSTOMER ID cannot be greater than 30 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID cannot be greater than 30 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CUSTOMER ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CUSTOMER ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  LENGTH(CIF_ID) > 30;
            /*VALIDATIONS ON ACCOUNT ID */
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ACCOUNT ID is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID Is not Availble for the Uploaded date' || ' ' || UTILS.CONVERT_TO_VARCHAR2(v_rptDate,10,p_style=>103) || '. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(V.ACCOUNT_Id, ' ') <> ' '
              AND V.ACCOUNT_Id NOT IN ( SELECT CustomerACID 
                                        FROM AdvAcBasicDetail 
                                         WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                                  AND EffectiveToTimeKey >= v_Timekey ) )
            ;
            IF utils.object_id('TEMPDB..tt_DUB_ACCOUNTID_8') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB_ACCOUNTID_8 ';
            END IF;
            DELETE FROM tt_DUB_ACCOUNTID_8;
            UTILS.IDENTITY_RESET('tt_DUB_ACCOUNTID_8');

            INSERT INTO tt_DUB_ACCOUNTID_8 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY ACCOUNT_Id ORDER BY ACCOUNT_Id  ) rw  
                        FROM tt_UploadSAGACLReport  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate ACCOUNT ID found in the Uploaded File. Please check & remove the duplicate ACCOUNT ID and upload the file again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate ACCOUNT ID found in the Uploaded File. Please check & remove the duplicate ACCOUNT ID and upload the file again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
               END AS pos_3, V.SR_No
            FROM V ,tt_UploadSAGACLReport V
                   JOIN tt_DUB_ACCOUNTID_8 D   ON D.ACCOUNT_Id = V.ACCOUNT_Id ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SR_No;
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid ACCOUNT ID. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid ACCOUNT ID. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  NVL(V.ACCOUNT_Id, ' ') <> ' '
              AND REGEXP_LIKE(NVL(ACCOUNT_Id, ' '), '%[,!@#<>$%^&[*{}(])_-+=/]%');
            UPDATE tt_UploadSAGACLReport V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ACCOUNT ID cannot be greater than 30 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID cannot be greater than 30 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACCOUNT ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACCOUNT ID'
                      END,
                   Srnooferroneousrows = V.SR_No
             WHERE  LENGTH(ACCOUNT_Id) > 30;
            IF NVL(v_UCICID_CNT, 0) > 0
              AND ( NVL(v_CIF_Id_CNT, 0) > 0
              OR NVL(v_ACCOUNT_Id_CNT, 0) > 0 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               UPDATE tt_UploadSAGACLReport V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Upload data in only one column from either UCIC ID / CIF ID / AC ID. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Upload data in only one column from UCIC ID / CIF ID / AC ID. Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UCIC ID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UCIC ID'
                         END,
                      Srnooferroneousrows = V.SR_No;
               --WHERE CASE WHEN ISNULL(@UCICID_CNT,0)> 0 AND ISNULL(@UCICID_CNT,0)= AND   
               OPEN  v_cursor FOR
                  SELECT -4 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
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
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM tt_UploadSAGACLReport  );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE tt_UploadSAGACLReport
                  ;
                  DBMS_OUTPUT.PUT_LINE(1);
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;

            END;
            END IF;
            IF NVL(v_CIF_Id_CNT, 0) > 0
              AND ( NVL(v_UCICID_CNT, 0) > 0
              OR NVL(v_ACCOUNT_Id_CNT, 0) > 0 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               UPDATE tt_UploadSAGACLReport V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Upload data in only one column from either UCIC ID / CIF ID / AC ID. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Upload data in only one column from UCIC ID / CIF ID / AC ID. Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CIF ID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CIF ID'
                         END,
                      Srnooferroneousrows = V.SR_No;
               --WHERE CASE WHEN ISNULL(@UCICID_CNT,0)> 0 AND ISNULL(@UCICID_CNT,0)= AND   
               OPEN  v_cursor FOR
                  SELECT -4 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
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
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM tt_UploadSAGACLReport  );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE tt_UploadSAGACLReport
                  ;
                  DBMS_OUTPUT.PUT_LINE(1);
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;

            END;
            END IF;
            IF NVL(v_ACCOUNT_Id_CNT, 0) > 0
              AND ( NVL(v_UCICID_CNT, 0) > 0
              OR NVL(v_CIF_Id_CNT, 0) > 0 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               UPDATE tt_UploadSAGACLReport V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Upload data in only one column from either UCIC ID / CIF ID / AC ID. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Upload data in only one column from UCIC ID / CIF ID / AC ID. Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AC ID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AC ID'
                         END,
                      Srnooferroneousrows = V.SR_No;
               --WHERE CASE WHEN ISNULL(@UCICID_CNT,0)> 0 AND ISNULL(@UCICID_CNT,0)= AND   
               OPEN  v_cursor FOR
                  SELECT -4 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
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
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM tt_UploadSAGACLReport  );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE tt_UploadSAGACLReport
                  ;
                  DBMS_OUTPUT.PUT_LINE(1);
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;

            END;
            END IF;
            --------------------------------------------------------------------------------------------------------------------  
            DBMS_OUTPUT.PUT_LINE('123');
            GOTO valid;

         END;
         END IF;
         <<ERRORDATA>>
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
              ( SELECT SR_No ,
                       UCIC_Id ,
                       CIF_Id ,
                       ACCOUNT_Id ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_FileName ,
                       SR_No ,
                       'SUCCESS' 
                FROM tt_UploadSAGACLReport  );
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
         IF ( NVL(v_FailureCount, 0) > 0
           AND NVL(v_SuccessCount, 0) = 0 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            DBMS_OUTPUT.PUT_LINE('All Failure Data');
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
                         AND NVL(ErrorType, ' ') <> ' ' ) ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            --ORDER BY CASE WHEN SR_No IS NULL THEN '' ELSE SR_No END  
            -------------- COMMENTED THE FILTER CONDITION BY SATWAJI AS ON 26/06/2023 -------------------------------  
            --IF EXISTS(SELECT 1 FROM DPDCSVUpload)      --WHERE UserLoginId=@UserLoginId  
            --BEGIN  
            --	DELETE FROM DPDCSVUpload  
            --	--WHERE UserLoginId=@UserLoginId  
            --	PRINT 1  
            --	PRINT 'ROWS DELETED FROM DBO.DPDCSVUpload'+CAST(@@ROWCOUNT AS VARCHAR(100))
            --END  
            OPEN  v_cursor FOR
               SELECT -10 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM tt_UploadSAGACLReport  );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE tt_UploadSAGACLReport
               ;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

            END;
            END IF;

         END;
         ELSE
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT EXISTS ( SELECT * 
                                   FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                                    WHERE  FileNames = v_FileName
                                             AND ( NVL(ColumnName, ' ') <> ' '
                                             AND NVL(ErrorData, ' ') <> ' '
                                             AND NVL(ErrorType, ' ') <> ' ' ) );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('All Success Data');
               OPEN  v_cursor FOR
                  SELECT 10 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM tt_UploadSAGACLReport  );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DELETE tt_UploadSAGACLReport
                  ;
                  DBMS_OUTPUT.PUT_LINE(1);
                  DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM tt_UploadSAGACLReport' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

               END;
               END IF;

            END;

            --ELSE IF (EXISTS(SELECT * FROM dbo.MasterUploadData_SAGACLProvDPD WHERE FileNames=@FileName AND ISNULL(ERRORDATA,'')<>''))  

            --BEGIN  

            -- PRINT 'All Failure Data'  

            -- SELECT SR_No  

            --  ,UCIF_ID  

            --  ,CustomerId  

            --  ,CustomerACID  

            --  ,ColumnName  

            --  ,ErrorData  

            --  ,ErrorType  

            --  ,FileNames  

            --  ,Flag  

            --  ,Srnooferroneousrows,'Validation'TableName  

            -- FROM dbo.MasterUploadData_SAGACLProvDPD  

            -- WHERE FileNames=@FileName  

            -- AND (ISNULL(ColumnName,'')<>'' AND ISNULL(ErrorData,'')<>'' AND ISNULL(ErrorType,'')<>'')  

            -- ORDER BY SR_No  

            -- SELECT -5  

            --END  
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Partial Failure Data');
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
                            AND NVL(ErrorType, ' ') <> ' ' ) ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);
               --ORDER BY SR_No  
               OPEN  v_cursor FOR
                  SELECT 5 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         --TRUNCATE TABLE IRAC_Total_ACL_UploadCount
         --INSERT INTO IRAC_Total_ACL_UploadCount(Count,FileName,UserLoginID)  
         --SELECT COUNT(*) Count,FileNames,@UserLoginId FROM dbo.MasterUploadData_SAGACLProvDPD WHERE FileNames=@FileName AND Flag='SUCCESS' GROUP BY FileNames
         --IF OBJECT_ID('TEMPDB..#InvalidRecords') IS NOT NULL  
         --		DROP TABLE #InvalidRecords  
         --CREATE TABLE #InvalidRecords  
         --   (
         --	 SR_NO VARCHAR(10)
         --	,Ucic_Id VARCHAR(100)
         --	,Customer_Id VARCHAR(100)
         --	,Account_Id VARCHAR(100)
         --   )
         --INSERT INTO #InvalidRecords(SR_NO,Ucic_Id,Customer_Id,Account_Id)
         --SELECT SR_NO,Ucif_Id,CustomerId,CustomerACID FROM dbo.MasterUploadData_SAGACLProvDPD  
         --   WHERE FileNames=@FileName  
         --   AND (ISNULL(ColumnName,'')<>'' AND ISNULL(ErrorData,'')<>'' AND ISNULL(ErrorType,'')<>'')
         ----AND (ISNULL(SR_NO,'')<>'' OR ISNULL(Ucic_Id,'')<>'' OR ISNULL(Customer_Id,'')<>'' OR ISNULL(Account_Id,'')<>'')
         --DELETE A 
         --FROM DPDCSVUpload A
         --LEFT JOIN #InvalidRecords B
         --ON ISNULL(A.SR_No,'')=ISNULL(B.SR_NO,'')
         --OR ISNULL(A.UCIC_Id,'')=ISNULL(B.Ucic_Id,'')
         --OR ISNULL(A.CIF_Id,'')=ISNULL(B.Customer_Id,'')
         --OR ISNULL(A.ACCOUNT_Id,'')=ISNULL(B.Account_Id,'')
         --IF EXISTS(SELECT 1 FROM dbo.MasterUploadData_SAGACLProvDPD WHERE FileNames=@FileName AND ISNULL(ERRORDATA,'')<>'')  
         --BEGIN  
         -- PRINT 'ERROR'  
         -- SELECT 1  
         -- SELECT 1  
         -- SELECT SR_No  
         --  ,UCIF_ID  
         --  ,CustomerId  
         --  ,CustomerACID  
         --  ,ColumnName  
         --  ,ErrorData  
         --  ,ErrorType  
         --  ,FileNames  
         --  ,Flag  
         --  ,Srnooferroneousrows,'Validation'TableName  
         -- FROM dbo.MasterUploadData_SAGACLProvDPD  
         -- WHERE FileNames=@FileName  
         -- AND (ISNULL(ColumnName,'')<>'' AND ISNULL(ErrorData,'')<>'' AND ISNULL(ErrorType,'')<>'')  
         -- ORDER BY SR_No  
         -- -------------- COMMENTED THE FILTER CONDITION BY SATWAJI AS ON 26/06/2023 -------------------------------  
         -- IF EXISTS(SELECT 1 FROM DPDCSVUpload)      --WHERE UserLoginId=@UserLoginId  
         -- BEGIN  
         --  DELETE FROM DPDCSVUpload  
         --  --WHERE UserLoginId=@UserLoginId  
         --  PRINT 1  
         --  PRINT 'ROWS DELETED FROM DBO.DPDCSVUpload'+CAST(@@ROWCOUNT AS VARCHAR(100))  
         -- END  
         --END  
         --ELSE  
         --BEGIN  
         -- PRINT 'DATA NOT PRESENT'  
         -- --SELECT *,'Data'TableName  
         -- --FROM dbo.MasterUploadData_SAGACLProvDPD WHERE FileNames=@FileName   
         -- --ORDER BY ErrorData DESC  
         -- --SELECT SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows,'Data'TableName   
         -- --FROM  
         -- --(  
         -- -- SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows  
         -- -- ORDER BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows)AS ROW   
         -- -- FROM  dbo.MasterUploadData_SAGACLProvDPD      
         -- --)a   
         -- --WHERE A.ROW=1  
         -- --AND FileNames=@FileName  
         -- IF EXISTS(SELECT 1 FROM tt_UploadSAGACLReport)  
         -- BEGIN  
         --  DELETE FROM tt_UploadSAGACLReport  
         --  PRINT 1  
         --  PRINT 'ROWS DELETED FROM tt_UploadSAGACLReport'+CAST(@@ROWCOUNT AS VARCHAR(100))  
         -- END  
         -- SELECT 1  
         -- SELECT 1  
         -- IF OBJECT_ID('TEMPDB..#EMPTY') IS NOT NULL  
         --   DROP TABLE #EMPTY  
         -- CREATE TABLE #EMPTY  
         -- (  
         --  ID INT  
         --  ,Result INT  
         -- )  
         -- SELECT * FROM #EMPTY  
         --END  
         ------------------------------------------------------------------------------------------------------------------
         IF utils.object_id('TEMPDB..tt_Temp_Success_4') IS NOT NULL THEN
          --GROUP BY FileNames  
         --SELECT COUNT(*) Count,FileNames,@UserLoginId from dbo.MasterUploadData_SAGACLProvDPD   
         --WHERE (ISNULL(ColumnName,'')='' AND ISNULL(ErrorData,'')='' AND ISNULL(ErrorType,'')='') AND FileNames=@FileName and Flag='SUCCESS'  
         --GROUP BY FileNames  
         --      INSERT INTO IRAC_Success_ACL_UploadCount(Count)  
         --SELECT count(*) from dbo.MasterUploadData_SAGACLProvDPD   
         --WHERE (ISNULL(ColumnName,'')='' AND ISNULL(ErrorData,'')='' AND ISNULL(ErrorType,'')='' AND FileNames=@FileName --and Flag='SUCCESS'  
         -------------------------------------------------Added by Prashant as on 05.08.2023------------------------------------------------------------------------  
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Temp_Success_4 ';
         END IF;
         DELETE FROM tt_Temp_Success_4;
         UTILS.IDENTITY_RESET('tt_Temp_Success_4');

         INSERT INTO tt_Temp_Success_4 ( 
         	SELECT COUNT(*)  COUNT  ,
                 v_FileName FileName_HC  ,
                 v_UserLoginId UserLoginId  
         	  FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
         	 WHERE  ( NVL(ColumnName, ' ') = ' '
                    AND NVL(ErrorData, ' ') = ' '
                    AND NVL(ErrorType, ' ') = ' ' )
                    AND FileNames = v_FileName
                    AND Flag = 'SUCCESS' );
         EXECUTE IMMEDIATE ' TRUNCATE TABLE IRAC_Success_ACL_UploadCount ';
         INSERT INTO IRAC_Success_ACL_UploadCount
           ( COUNT, FILENAME, UserLoginID )
           ( SELECT COUNT ,
                    FileName_HC ,
                    UserLoginId 
             FROM tt_Temp_Success_4  );
         EXECUTE IMMEDIATE ' TRUNCATE TABLE SAG_ACL_SuccessDetails ';
         --IF ((SELECT COUNT(SR_No) FROM DPDCSVUpload WHERE UserLoginId=@UserLoginId)>0)
         --BEGIN
         --PRINT 'Success SR_NO'
         --INSERT INTO SAG_ACL_SuccessDetails(SR_No,UserLoginID)
         --SELECT SR_No,@UserLoginId FROM dbo.MasterUploadData_SAGACLProvDPD
         --WHERE (ISNULL(ColumnName,'')='' AND ISNULL(ErrorData,'')='' AND ISNULL(ErrorType,'')='') 
         --AND FileNames=@FileName AND Flag='SUCCESS'  
         --END
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE ( ( SELECT COUNT(UCIC_Id)  
                       FROM DPDCSVUpload 
                        WHERE  UserLoginId = v_UserLoginId ) > 0 );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Success UCIC_Id');
            INSERT INTO SAG_ACL_SuccessDetails
              ( UCIC, UserLoginID )
              ( SELECT UCIF_ID ,
                       v_UserLoginId 
                FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                 WHERE  ( NVL(ColumnName, ' ') = ' '
                          AND NVL(ErrorData, ' ') = ' '
                          AND NVL(ErrorType, ' ') = ' ' )
                          AND FileNames = v_FileName
                          AND Flag = 'SUCCESS' );

         END;
         END IF;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE ( ( SELECT COUNT(CIF_Id)  
                       FROM DPDCSVUpload 
                        WHERE  UserLoginId = v_UserLoginId ) > 0 );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Success CIF_ID');
            INSERT INTO SAG_ACL_SuccessDetails
              ( CustID, UserLoginID )
              ( SELECT CustomerId ,
                       v_UserLoginId 
                FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                 WHERE  ( NVL(ColumnName, ' ') = ' '
                          AND NVL(ErrorData, ' ') = ' '
                          AND NVL(ErrorType, ' ') = ' ' )
                          AND FileNames = v_FileName
                          AND Flag = 'SUCCESS' );

         END;
         END IF;
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE ( ( SELECT COUNT(ACCOUNT_Id)  
                       FROM DPDCSVUpload 
                        WHERE  UserLoginId = v_UserLoginId ) > 0 );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Success ACCOUNT_Id');
            INSERT INTO SAG_ACL_SuccessDetails
              ( AC_ID, UserLoginID )
              ( SELECT CustomerACID ,
                       v_UserLoginId 
                FROM RBL_MISDB_PROD.MasterUploadData_SAGACLProvDPD 
                 WHERE  ( NVL(ColumnName, ' ') = ' '
                          AND NVL(ErrorData, ' ') = ' '
                          AND NVL(ErrorType, ' ') = ' ' )
                          AND FileNames = v_FileName
                          AND Flag = 'SUCCESS' );

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN
   DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      ----------------------------------------------------------------------------------------------------------------------
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_SAGACLREPORTUPLOAD" TO "ADF_CDR_RBL_STGDB";
