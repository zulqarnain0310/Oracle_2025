--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'BuyoutUPLOAD.xlsx' 
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--DECLARE  
--@MenuID INT=1466,  
--@UserLoginId varchar(20)=N'2ndlvlchecker',  
--@Timekey int=N'25999'
--,@filepath varchar(500)=N'BuyoutUpload (3).xlsx'  

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
         SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

           INTO v_Timekey
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
         --Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)
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

         BEGIN
            -- IF OBJECT_ID('tempdb..#UploadBuyout') IS NOT NULL  
            --BEGIN  
            -- DROP TABLE #UploadBuyout  
            --END
            IF utils.object_id('UploadBuyout') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadBuyout';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM BuyoutDetails_stg 
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
               DELETE FROM UploadBuyout;
               UTILS.IDENTITY_RESET('UploadBuyout');

               INSERT INTO UploadBuyout SELECT * ,
                                               UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                               UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                               UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM BuyoutDetails_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            --select * from BuyoutDetails_stg
            ----SELECT * FROM UploadBuyout
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE UploadBuyout V
               SET ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   ErrorinColumn = 'SlNo,AUNo,PoolName,Category,BuyoutPartyLoanNo,CustomerName,PAN,AadharNo,PrincipalOutstanding,
                   		InterestReceivable,Charges,AccuredInterest,DPD,AssetClass',
                   Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') = ' '
              AND NVL(AUNo, ' ') = ' '
              AND NVL(PoolName, ' ') = ' '
              AND NVL(Category, ' ') = ' '
              AND NVL(BuyoutPartyLoanNo, ' ') = ' '
              AND NVL(CustomerName, ' ') = ' '
              AND NVL(PAN, ' ') = ' '
              AND NVL(AadharNo, ' ') = ' '
              AND NVL(PrincipalOutstanding, ' ') = ' '
              AND NVL(InterestReceivable, ' ') = ' '
              AND NVL(Charges, ' ') = ' '
              AND NVL(AccuredInterest, ' ') = ' '
              AND NVL(DPD, ' ') = ' '
              AND NVL(AssetClass, ' ') = ' ';
            --WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filname,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadBuyout 
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
            -----validations on Srno
            DBMS_OUTPUT.PUT_LINE('Validation Error MSG');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo is mandatory. Kindly check and upload again'
                      END,
                   ErrorinColumn = 'SRNO',
                   Srnooferroneousrows = ' '
             WHERE  NVL(v.SlNo, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('1');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SlNo, kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SlNo, kindly check and upload again'
                      END,
                   ErrorinColumn = 'SRNO',
                   Srnooferroneousrows = SlNo
             WHERE  NVL(v.SlNo, ' ') = '0'
              OR utils.isnumeric(v.SlNo) = 0;
            DBMS_OUTPUT.PUT_LINE('2');
            IF utils.object_id('TEMPDB..tt_R_6') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_R_6 ';
            END IF;
            DELETE FROM tt_R_6;
            UTILS.IDENTITY_RESET('tt_R_6');

            INSERT INTO tt_R_6 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY SlNo ORDER BY SlNo  ) ROW_  
                        FROM UploadBuyout  ) A
                WHERE  ROW_ > 1;
            DBMS_OUTPUT.PUT_LINE('DUB');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate SlNo, kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate SlNo, kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = SlNo
                   --STUFF((SELECT DISTINCT ','+SlNo 
                    --						FROM UploadBuyout
                    --						FOR XML PATH ('')
                    --						),1,1,'')

             WHERE  V.SlNo IN ( SELECT SlNo 
                                FROM tt_R_6  )
            ;
            DBMS_OUTPUT.PUT_LINE('3');
            /*validations on AUNo*/
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'AUNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'AUNo cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AUNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AUNo'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --FROM UploadBuyout A
                    --WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadBuyout V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(AUNo, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AUNo.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AUNo.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AUNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AUNo'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --	STUFF((SELECT ','+SlNo 
                    --							FROM UploadBuyout A
                    --							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V  
                    --WHERE ISNULL(SOLID,'')<>''
                    --AND  LEN(SOLID)>10)
                    --							FOR XML PATH ('')
                    --							),1,1,'')

             WHERE  NVL(AUNo, ' ') <> ' '
              AND LENGTH(AUNo) > 20;
            ----------------------------------------------
            /*validations on PoolName*/
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PoolName cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PoolName cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolName'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolName'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --FROM UploadBuyout A
                    --WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadBuyout V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(PoolName, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PoolName.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PoolName.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolName'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolName'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --	STUFF((SELECT ','+SlNo 
                    --							FROM UploadBuyout A
                    --							WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V  
                    --WHERE ISNULL(SOLID,'')<>''
                    --AND  LEN(SOLID)>10)
                    --							FOR XML PATH ('')
                    --							),1,1,'')

             WHERE  NVL(PoolName, ' ') <> ' '
              AND LENGTH(PoolName) > 20;
            -------------------------------------------------
            /*VALIDATIONS ON Category */
            UPDATE UploadBuyout v
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Category is mandatory. Kindly check and upload again'
                   ELSE CASE 
                             WHEN ( v.Category = 'With Risk Sharing'
                               OR v.Category = 'Without With Risk Sharing' ) THEN v.Category
                   ELSE 'Invalid value in Category. Kindly enter value ‘With Risk Sharing’ or ‘Without Risk Sharing’ and upload again'
                      END
                      END,
                   ErrorinColumn = 'Category',
                   Srnooferroneousrows = ' '
             WHERE  NVL(v.Category, ' ') = ' ';
            ----------------------------------------------------------------
            /* Commented on 14-05-2021 sunil on shishir advice  */
            --UPDATE UploadBuyout
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in Category. Kindly enter value ‘With Risk Sharing’ or ‘Without Risk Sharing’ and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in Category. Kindly enter value ‘With Risk Sharing’ or ‘Without Risk Sharing’ and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Category' ELSE   ErrorinColumn +','+SPACE(1)+'Category' END       
            --		,Srnooferroneousrows=V.SlNo
            --	FROM UploadBuyout v  
            --	WHERE ISNULL(v.Category,'')<>''  
            --	And V.Category Not In ('With Risk Sharing','Without With Risk Sharing')
            -------------Added on 18-05-2021 sunil on mohsin advice
            UPDATE UploadBuyout v
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in Category. Kindly enter value ‘Agri’ or ‘Marginal’ or ‘Small’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in Category. Kindly enter value ‘Agri’ or ‘Marginal’ or ‘Small’and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Category'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Category'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(v.Category, ' ') <> ' '
              AND V.Category NOT IN ( 'Agri','Marginal','Small' )
            ;
            /*VALIDATIONS ON BuyoutPartyLoanNo */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'BuyoutPartyLoanNo cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'BuyoutPartyLoanNo cannot be blank.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'BuyoutPartyLoanNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'BuyoutPartyLoanNo'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(BuyoutPartyLoanNo, ' ') = ' ';
            -- ----SELECT * FROM UploadBuyout
            --  UPDATE UploadBuyout
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid BuyoutPartyLoanNo found. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid BuyoutPartyLoanNo found. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BuyoutPartyLoanNo' ELSE ErrorinColumn +','+SPACE(1)+  'BuyoutPartyLoanNo' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								--STUFF((SELECT ','+SlNo 
            ----								--FROM UploadBuyout A
            ----								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyout V
            ----								-- WHERE ISNULL(V.ACID,'')<>''
            ----								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
            ----								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            ----								--										Timekey=@Timekey
            ----								--		))
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            --		FROM UploadBuyout V  
            -- WHERE ISNULL(V.BuyoutPartyLoanNo,'')<>''
            -- AND V.BuyoutPartyLoanNo NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
            --								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            --						 )
            IF utils.object_id('TEMPDB..tt_DUB2_17') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_17 ';
            END IF;
            DELETE FROM tt_DUB2_17;
            UTILS.IDENTITY_RESET('tt_DUB2_17');

            INSERT INTO tt_DUB2_17 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY BuyoutPartyLoanNo ORDER BY BuyoutPartyLoanNo  ) ROW_  
                        FROM UploadBuyout  ) X
                WHERE  ROW_ > 1;
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate records found.BuyoutPartyLoanNo are repeated.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate records found. BuyoutPartyLoanNo are repeated.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'BuyoutPartyLoanNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'BuyoutPartyLoanNo'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM #UploadNewAccount A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                    --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                    ----AND SRNO IN(SELECT Srno FROM tt_DUB2_17))
                    --AND ACID IN(SELECT ACID FROM tt_DUB2_17 GROUP BY ACID))
                    --							FOR XML PATH ('')
                    --							),1,1,'')   

             WHERE  NVL(BuyoutPartyLoanNo, ' ') <> ' '
              AND BuyoutPartyLoanNo IN ( SELECT BuyoutPartyLoanNo 
                                         FROM tt_DUB2_17 
                                           GROUP BY BuyoutPartyLoanNo )
            ;
            ------------------------------------------------------------
            /*VALIDATIONS ON CustomerName */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerName cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CustomerName cannot be blank.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerName'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerName'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CustomerName, ' ') = ' ';
            -- ----SELECT * FROM UploadBuyout
            --  UPDATE UploadBuyout
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'CustomerName Can not be blank. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+'CustomerName Can not be blank. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerName' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerName' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								--STUFF((SELECT ','+SRNO 
            ----								--FROM UploadBuyout A
            ----								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
            ----								-- WHERE ISNULL(V.ACID,'')<>''
            ----								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
            ----								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            ----								--										Timekey=@Timekey
            ----								--		))
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            --		FROM UploadBuyout V  
            -- WHERE ISNULL(V.CustomerName,'')<>''
            -- And V.CustomerName Not In (Select B.CustomerName from curdat.AdvAcBasicDetail A 
            --							Inner Join curdat.CustomerBasicDetail B ON A.RefCustomerId=B.CustomerId
            --							And A.EffectiveToTimeKey=49999 and B.EffectiveToTimeKey=49999
            --							Inner Join UploadBuyout C on A.CustomerACID=C.BuyoutPartyLoanNo)
            --------------------------------------------------------------------------------
            /*
            --validations on PAN --

            UPDATE UploadBuyout
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 

            		'The column ‘PAN’ is mandatory. Kindly check and upload again' 
            		ELSE ErrorMessage+','+SPACE(1)+ 'PAN is mandatory. Kindly check and upload again'
            		END
            		,ErrorinColumn='PAN'    
            		,Srnooferroneousrows=''
            	FROM UploadBuyout V  
            	WHERE V.PAN IN(SELECT PAN FROM curdat.advcustrelationship 
            								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            						 )
            */
            /*--------------------validations on PAN-------------------- PRANAY 22-03-2021 */
            /* Commneted on 14-05-2021 sunil of shishir sir advice  */
            --UPDATE UploadBuyout
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
            --		'PAN can not be blank. Kindly check and upload again' 
            --		ELSE ErrorMessage+','+SPACE(1)+ 'PAN can not be blank. Kindly check and upload again' 
            --		END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PAN' ELSE ErrorinColumn +','+SPACE(1)+  'PAN' END  
            --		--,ErrorinColumn='PAN'    
            --		,Srnooferroneousrows=''
            --	FROM UploadBuyout V  
            --	WHERE ISNULL(V.PAN,'')=''
            --UPDATE UploadBuyout
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
            --		'Invalid PAN. PAN length must be 10 characters, first 5 characters must be an alphabet,next 4 character must be numeric 0-9, & last(10th) character must be an alphabet'
            --		ELSE ErrorMessage+','+SPACE(1)+ 'Invalid PAN. PAN length must be 10 characters, first 5 characters must be an alphabet,next 4 character must be numeric 0-9, & last(10th) character must be an alphabet'
            --		END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PAN' ELSE ErrorinColumn +','+SPACE(1)+  'PAN' END  
            --		--,ErrorinColumn='PAN'    
            --		,Srnooferroneousrows=''
            --	FROM UploadBuyout V  
            --	WHERE ISNULL(V.PAN,'')<>''
            --	AND 	V.PAN  not LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]' OR Len(PAN)<>10
            -----------------------------------------------------------
            /*validations on AadharNo */
            /*  Commneted on 14-05-2021 sunil of shishir sir advice     */
            --UPDATE UploadBuyout
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
            --		'The column ‘AadharNo’ is mandatory. Kindly check and upload again' 
            --		ELSE ErrorMessage+','+SPACE(1)+ 'AadharNo is mandatory. Kindly check and upload again'
            --		END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AadharNo' ELSE ErrorinColumn +','+SPACE(1)+  'AadharNo' END  
            --		--,ErrorinColumn='AadharNo'    
            --		,Srnooferroneousrows=''
            --	FROM UploadBuyout V  
            --	WHERE V.AadharNo IN(SELECT AadhaarId FROM curdat.advcustrelationship 
            --								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            --						 )
            /*validations on PrincipalOutstanding */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PrincipalOutstanding cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstanding cannot be blank. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstanding'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalOutstanding, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstanding. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstanding. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstanding'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM UploadBuyout A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(PrincipalOutstanding) = 0
              AND NVL(PrincipalOutstanding, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PrincipalOutstanding), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstanding. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstanding. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstanding'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(PrincipalOutstanding, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstanding. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstanding. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstanding'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM UploadBuyout WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalOutstanding, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(PrincipalOutstanding, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on InterestReceivable */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'InterestReceivable cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'InterestReceivable cannot be blank. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivable'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestReceivable, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivable. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivable. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivable'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM UploadBuyout A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(InterestReceivable) = 0
              AND NVL(InterestReceivable, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(InterestReceivable), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivable. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivable. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivable'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(InterestReceivable, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivable. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivable. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivable'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM UploadBuyout WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestReceivable, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(InterestReceivable, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on Charges */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Charges cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Charges cannot be blank. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charges'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charges'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(Charges, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Charges. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Charges. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charges'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charges'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM UploadBuyout A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(Charges) = 0
              AND NVL(Charges, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(Charges), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Charges. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Charges. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charges'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charges'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(Charges, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Charges. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Charges. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charges'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charges'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM UploadBuyout WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(Charges, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(Charges, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on AccuredInterest */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'AccuredInterest cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'AccuredInterest cannot be blank. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccuredInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccuredInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccuredInterest, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AccuredInterest. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AccuredInterest. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccuredInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccuredInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM UploadBuyout A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(AccuredInterest) = 0
              AND NVL(AccuredInterest, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(AccuredInterest), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AccuredInterest. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AccuredInterest. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccuredInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccuredInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(AccuredInterest, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AccuredInterest. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AccuredInterest. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccuredInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccuredInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM UploadBuyout WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccuredInterest, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(AccuredInterest, 0)) < 0;
            ---------------------------------------------------------------------
            /*validations on DPD */
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DPD cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DPD cannot be blank. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(DPD, ' ') = ' ';
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DPD. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DPD. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM UploadBuyout A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(DPD) = 0
              AND NVL(DPD, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(DPD), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DPD. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DPD. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadBuyout V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(DPD, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadBuyout V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DPD. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DPD. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DPD'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DPD'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadBuyout A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM UploadBuyout WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(DPD, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(Charges, 0)) < 0;
            ----------------For Flag Checking in main table
            MERGE INTO UploadBuyout V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Already Buyout Flag is present. Please Check the Account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Already Buyout Flag is present. Please Check the Account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'BuyoutPartyLoanNo'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'BuyoutPartyLoanNo'
               END AS pos_3, ' ' AS pos_4
            FROM UploadBuyout V
                   JOIN RBL_MISDB_PROD.AdvAcOtherDetail A   ON V.BuyoutPartyLoanNo = A.RefSystemAcId
                   AND A.EffectiveToTimeKey = 49999 
             WHERE A.SplFlag LIKE '%Buyout%') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows
                                         --STUFF((SELECT ','+SRNO 
                                          --						FROM #UploadNewAccount A
                                          --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                                          --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                                          --										)
                                          --						FOR XML PATH ('')
                                          --						),1,1,'')   
                                          = pos_4;
            /*           Commented on 19-05-2021  by advice of Ravish
             ----------------------------------------------------
            --validations on AssetClass --

             UPDATE UploadBuyout
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 

            		'AssetClass is mandatory. Kindly check and upload again' 
            		ELSE ErrorMessage+','+SPACE(1)+ 'AssetClass is mandatory. Kindly check and upload again'
            		END
            		,ErrorinColumn='AssetClass'    
            		,Srnooferroneousrows=''
            	FROM UploadBuyout V  
            	WHERE ISNULL(v.AssetClass,'')=''  

            	*/
            --------------------------------------------------------------------------
            /*      Commented on 19-05-2021  by advice of Ravish

            ---------------------PoolName-Validation------------------------- -- -- changes done on 21-03-21 Pranay 
             Declare @PoolNameCnt int=0,@Category int=0
             --DROP TABLE IF EXISTS PoolNameData

             IF OBJECT_ID('PoolNameBuyoutData') IS NOT NULL  
            	  BEGIN

            		DROP TABLE  PoolNameBuyoutData

            	  END

             SELECT * into PoolNameBuyoutData  FROM(
             SELECT ROW_NUMBER() OVER(PARTITION BY AUNO  ORDER BY  AUNO ) 
             ROW ,AUNO,PoolName,BuyoutPartyLoanNo FROM UploadBuyout
             )X
             WHERE ROW=1


             SELECT @PoolNameCnt=COUNT(*) FROM PoolNameBuyoutData a
             INNER JOIN UploadBuyout b
             ON a.AUNO=b.AUNO 
             WHERE a.PoolName<>b.PoolName

             IF @PoolNameCnt>0
             BEGIN
              PRINT 'PoolName ERROR'
               UPDATE UploadBuyout
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different AUNO of same combination of PoolName is Available. Please check the values and upload again' END    
            						--ELSE ErrorMessage+','+SPACE(1)+ 'Different AUNO of same combination of PoolName and Category is Available. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END     
            		,Srnooferroneousrows=V.SlNo
            	--	STUFF((SELECT ','+SlNo 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SlNo IN(SELECT V.SlNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SlNo IN(SELECT SlNo FROM tt_DUB2_17))
             --AND ACID IN(SELECT ACID FROM tt_DUB2_17 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM UploadBuyout V  
             WHERE ISNULL(AUNO,'')<>''
             AND  BuyoutPartyLoanNo IN(
            				 SELECT DISTINCT B.BuyoutPartyLoanNo from PoolNameBuyoutData a
            				 INNER JOIN UploadBuyout b
            				 on a.AUNO=b.AUNO 
            				 where a.PoolName<>b.PoolName
            				 )

             END

             -------------Category----------------------------------changes done on 21-03-21 Pranay 

            --DROP TABLE IF EXISTS CategoryData
             IF OBJECT_ID('CategoryData') IS NOT NULL  
            	  BEGIN

            		DROP TABLE  CategoryData

            	  END

              SELECT * into CategoryData  FROM(
             SELECT ROW_NUMBER() OVER(PARTITION BY AUNO  ORDER BY  AUNO ) 
             ROW ,AUNO,Category,BuyoutPartyLoanNo FROM UploadBuyout
             )X
             WHERE ROW=1


             select @Category=COUNT(*) from CategoryData a
             INNER JOIN UploadBuyout b
             on a.AUNO=b.AUNO 
             where a.Category<>b.Category

              IF @Category>0
             BEGIN
              PRINT 'Category ERROR'

              UPDATE UploadBuyout
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different AUNO of same combination of Category is Available. Please check the values and upload again' END    
            						--ELSE ErrorMessage+','+SPACE(1)+ 'Different AUNO of same combination of PoolName and Category is Available. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Category' ELSE   ErrorinColumn +','+SPACE(1)+'Category' END     
            		,Srnooferroneousrows=V.SlNo
            	--	STUFF((SELECT ','+SlNo 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SlNo IN(SELECT V.SlNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SlNo IN(SELECT SlNo FROM tt_DUB2_17))
             --AND ACID IN(SELECT ACID FROM tt_DUB2_17 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM UploadBuyout V  
             WHERE ISNULL(AUNO,'')<>''
             AND BuyoutPartyLoanNo IN(
            				 SELECT DISTINCT B.BuyoutPartyLoanNo from CategoryData a
            				 INNER JOIN UploadBuyout b
            				 on a.AUNO=b.AUNO 
            				 where a.Category<>b.Category
            				 )
             END

             --Same PoolName present in Multiple AUNO-- -- pRANAY 21-03-21

            Declare @PoolNameCnt1 int=0
             --DROP TABLE IF EXISTS PoolNameData1
             IF OBJECT_ID('PoolNameBuyoutData1') IS NOT NULL  
            	  BEGIN

            		DROP TABLE  PoolNameBuyoutData1

            	  END

             SELECT * into PoolNameBuyoutData1  
             FROM(SELECT ROW_NUMBER() OVER(PARTITION BY AUNO  ORDER BY  AUNO ) ROW,
            			AUNO,PoolName,BuyoutPartyLoanNo FROM UploadBuyout
            	 )X
             WHERE ROW=1


             SELECT @PoolNameCnt1=COUNT(*)
              FROM PoolNameBuyoutData1 a
             inner JOIN UploadBuyout b
             ON a.PoolName=b.PoolName 
             WHERE a.AUNO<>b.AUNO

             IF @PoolNameCnt1>0
             BEGIN
              PRINT 'Same PoolName present in Multiple AUNO'
               UPDATE UploadBuyout
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Same PoolName present in Multiple AUNO. Please check the values and upload again' END    
            						--ELSE ErrorMessage+','+SPACE(1)+ 'Different AUNO of same combination of PoolName and Category is Available. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END     
            		,Srnooferroneousrows=V.SlNo
            	--	STUFF((SELECT ','+SlNo 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SlNo IN(SELECT V.SlNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SlNo IN(SELECT SlNo FROM tt_DUB2_17))
             --AND ACID IN(SELECT ACID FROM tt_DUB2_17 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM UploadBuyout V  
             WHERE ISNULL(AUNO,'')<>''
             AND  BuyoutPartyLoanNo IN(
            				 SELECT DISTINCT A.BuyoutPartyLoanNo from PoolNameBuyoutData1 a
            				 INNER JOIN UploadBuyout b
            				 ON a.PoolName=b.PoolName 
            				WHERE a.AUNO<>b.AUNO
            				 )

             END

             */
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
                                FROM BuyoutDetails_stg 
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
            DBMS_OUTPUT.PUT_LINE('VALIDATION ERRORS1');
            INSERT INTO RBL_MISDB_PROD.MasterUploadData
              ( SR_No, ColumnName, ErrorData, ErrorType, FileNames, Srnooferroneousrows, Flag )
              ( SELECT SlNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM UploadBuyout  );
            DBMS_OUTPUT.PUT_LINE('VALIDATION ERRORS');
            --	----SELECT * FROM UploadBuyout 
            --	--ORDER BY ErrorMessage,UploadBuyout.ErrorinColumn DESC
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
            DBMS_OUTPUT.PUT_LINE('Validation=Y');
            UPDATE UploadStatus
               SET ValidationOfData = 'Y',
                   ValidationOfDataCompletedOn = SYSDATE
             WHERE  FileNames = v_filepath;

         END;
         END IF;
         <<final>>
         DBMS_OUTPUT.PUT_LINE('ERR');
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
                               FROM BuyoutDetails_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE BuyoutDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.BuyoutDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadBuyout
         DBMS_OUTPUT.PUT_LINE('p');

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ------to delete file if it has errors
      --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
      --begin
      --print 'ppp'
      -- IF EXISTS(SELECT 1 FROM BuyoutDetails_stg WHERE filname=@FilePathUpload)
      -- BEGIN
      -- print '123'
      -- DELETE FROM BuyoutDetails_stg
      -- WHERE filname=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.BuyoutDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- END
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM BuyoutDetails_stg WHERE filname=@FilePathUpload)
                 --	 BEGIN
                 --	 DELETE FROM BuyoutDetails_stg
                 --	 WHERE filname=@FilePathUpload
                 --	 PRINT 'ROWS DELETED FROM DBO.BuyoutDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                 ,--	 END
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTUPLOAD_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
