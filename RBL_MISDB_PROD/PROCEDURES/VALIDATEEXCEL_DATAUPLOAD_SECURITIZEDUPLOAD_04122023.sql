--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'FNASUPERADMIN' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'SecuritizedUpload.xlsx' 
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
         --DECLARE @DepartmentId SMALLINT ,@DepartmentCode varchar(100)  
         --SELECT  @DepartmentId= DepartmentId FROM dbo.DimUserInfo   
         --WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey  
         --AND UserLoginID = @UserLoginId  
         --PRINT @DepartmentId  
         --PRINT @DepartmentCode  
         -- SELECT @DepartmentCode=DepartmentCode FROM AxisIntReversalDB.DimDepartment   
         --     WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey   
         --     --AND DepartmentCode IN ('BBOG','FNA')  
         --     AND DepartmentAlt_Key = @DepartmentId  
         --     print @DepartmentCode  
         --     --Select @DepartmentCode=REPLACE('',@DepartmentCode,'_')  
         v_FilePathUpload VARCHAR2(100);
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         --BEGIN TRAN  
         --Declare @TimeKey int  
         -- Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
         ----Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
         ---- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
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
         DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*          Commented on 21-05-2021 on advice of Shishir Sir
             ----------------For Flag Checking in main table


            UPDATE Securitized
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Already securitized Flag is present. Please Check the Account'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'Already securitized Flag is present. Please Check the Account'      END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END      
            		,Srnooferroneousrows=V.SrNo
            		--STUFF((SELECT ','+SRNO 
            		--						FROM #UploadNewAccount A
            		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))

            		--										)
            		--						FOR XML PATH ('')
            		--						),1,1,'')   

             FROM Securitized V  
             Inner Join Dbo.AdvAcOtherDetail A ON V.AccountID=A.RefSystemAcId And A.EffectiveToTimeKey=49999
             WHERE A.SplFlag like '%Securitised%'
             */
            ------------------------------------------------------
            --UPDATE Securitized
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MaturityDate Can not be Less than Other Two. Please enter the Correct Date'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'MaturityDate Can not be Less than Other Two. Please enter the Correct Date'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SRNO 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM Securitized V  
            -- WHERE ISNULL(MaturityDate,'')<>'' AND (Convert(Date,MaturityDate,103)<Convert(Date,DateofSecuritisationMarking,103) OR Convert(Date,MaturityDate,103)<Convert(Date,DateofSecuritisationMarking,103))
            --------------------------------------
            /*  Validations on MisMatch DateofSecuritisationReckoning  */
            /*
             IF OBJECT_ID('TEMPDB..#Date1') IS NOT NULL
             DROP TABLE #Date1

             SELECT * INTO #Date1 FROM(
             SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofSecuritisationReckoning ORDER BY  PoolID,DateofSecuritisationReckoning ) ROW FROM Securitized
             )X
             WHERE ROW>1

             UPDATE Securitized
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofSecuritisationReckoning. Please check the values and upload again'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofSecuritisationReckoning. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofSecuritisationReckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofSecuritisationReckoning' END     
            		,Srnooferroneousrows=V.SrNo
            	--	STUFF((SELECT ','+SRNO 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
             --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM Securitized V  
             WHERE ISNULL(PoolID,'')<>''
             AND PoolID IN(SELECT PoolID FROM #Date1 GROUP BY PoolID)
             */
            ---------------------------------
            /*  Validations on MisMatch DateofSecuritisationMarking  */
            /* IF OBJECT_ID('TEMPDB..#Date2') IS NOT NULL
             DROP TABLE #Date2

             SELECT * INTO #Date2 FROM(
             SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofSecuritisationMarking ORDER BY  PoolID,DateofSecuritisationMarking ) ROW FROM Securitized
             )X
             WHERE ROW>1

             UPDATE Securitized
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofSecuritisationMarking. Please check the values and upload again'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofSecuritisationMarking. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofSecuritisationMarking' ELSE   ErrorinColumn +','+SPACE(1)+'DateofSecuritisationMarking' END     
            		,Srnooferroneousrows=V.SrNo
            	--	STUFF((SELECT ','+SRNO 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
             --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM Securitized V  
             WHERE ISNULL(PoolID,'')<>''
             AND PoolID IN(SELECT PoolID FROM #Date2 GROUP BY PoolID)
             */
            ---------------------------------
            /*  Validations on MisMatch MaturityDate  */
            /*IF OBJECT_ID('TEMPDB..#Date3') IS NOT NULL
             DROP TABLE #Date3

             SELECT * INTO #Date3 FROM(
             SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofSecuritisationMarking ORDER BY  PoolID,DateofSecuritisationMarking ) ROW FROM Securitized
             )X
             WHERE ROW>1

             UPDATE Securitized
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of MaturityDate. Please check the values and upload again'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of MaturityDate. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MaturityDate' ELSE   ErrorinColumn +','+SPACE(1)+'MaturityDate' END     
            		,Srnooferroneousrows=V.SrNo
            	--	STUFF((SELECT ','+SRNO 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
             --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM Securitized V  
             WHERE ISNULL(PoolID,'')<>''
             AND PoolID IN(SELECT PoolID FROM #Date3 GROUP BY PoolID)
             */
            /*-------------------PoolName-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            v_PoolNameCnt NUMBER(10,0) := 0;
            v_SecuritisationType NUMBER(10,0) := 0;
            /*Same PoolName present in Multiple poolID*/
            -- pRANAY 20-03-21
            v_PoolNameCnt1 NUMBER(10,0) := 0;
            -------------------DateofSecuritisationreckoning-------------------------- Pranay 20-03-21
            v_DateofSecuritisationreckoningCnt NUMBER(10,0) := 0;
            -------------------DateofSecuritisationmarking--------------------------Pranay 20-03-21
            v_DateofSecuritisationmarkingCnt NUMBER(10,0) := 0;
            -------------------@MaturityDate--------------------------Pranay 20-03-2021
            v_MaturityDateCnt NUMBER(10,0) := 0;
         --IF (@MenuID=14573)	

         BEGIN
            -- IF OBJECT_ID('tempdb..#Securitized') IS NOT NULL  
            --BEGIN  
            -- DROP TABLE #Securitized  
            --END
            --DROP TABLE IF EXISTS Securitized
            IF utils.object_id('Securitized') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE Securitized';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM SecuritizedDetail_stg 
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
               DELETE FROM Securitized;
               UTILS.IDENTITY_RESET('Securitized');

               INSERT INTO Securitized SELECT * ,
                                              UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                              UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                              UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM SecuritizedDetail_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            --  ------------------------------------------------------------------------------  
            --    ----SELECT * FROM Securitized
            --	--SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE Securitized V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'PoolName,PoolID,CustomerID,AccountID,SecuritisationType,OSBalanceinRs,InterestReceivableinRs,
                   		PrincipalOutstandinginRs,SecuritisationExposureinRs,Dates',
                   V.Srnooferroneousrows = V.SrNo
             WHERE
            --ISNULL(V.SrNo,'')=''
             -- ----AND ISNULL(Territory,'')=''
              NVL(PoolName, ' ') = ' '
              AND NVL(PoolID, ' ') = ' '
              AND NVL(CustomerID, ' ') = ' '
              AND NVL(AccountID, ' ') = ' '
              AND NVL(SecuritisationType, ' ') = ' '
              AND NVL(OSBalanceinRs, ' ') = ' '
              AND NVL(InterestReceivableinRs, ' ') = ' '
              AND NVL(PrincipalOutstandinginRs, ' ') = ' '
              AND NVL(SecuritisationExposureinRs, ' ') = ' '
              AND NVL(DateofSecuritisationReckoning, ' ') = ' '
              AND NVL(DateofSecuritisationMarking, ' ') = ' '
              AND NVL(MaturityDate, ' ') = ' '
              AND NVL(filname, ' ') = ' ';
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM Securitized 
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
            /*validations on POOLID*/
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PoolID cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PoolID cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM Securitized A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(PoolID, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PoolID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PoolID.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM Securitized A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')<>''
                    --AND  LEN(SOLID)>10)
                    --							FOR XML PATH ('')
                    --							),1,1,'')

             WHERE  NVL(PoolID, ' ') <> ' '
              AND LENGTH(PoolID) > 20;
            ----------------------------------------------
            /*validations on PoolName*/
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PoolName cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PoolName cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolName'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolName'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM Securitized A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(PoolName, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PoolName.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PoolName.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolName'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolName'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM Securitized A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')<>''
                    --AND  LEN(SOLID)>10)
                    --							FOR XML PATH ('')
                    --							),1,1,'')

             WHERE  NVL(PoolName, ' ') <> ' '
              AND LENGTH(PoolName) > 20;
            ------------------------------------------------------
            /*validations on SecuritisationType*/
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SecuritisationType cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SecuritisationType cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationType'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationType'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM Securitized A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(SecuritisationType, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SecuritisationType.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SecuritisationType.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationType'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationType'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM Securitized A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')<>''
                    --AND  LEN(SOLID)>10)
                    --							FOR XML PATH ('')
                    --							),1,1,'')

             WHERE  NVL(SecuritisationType, ' ') <> ' '
              AND LENGTH(SecuritisationType) > 40;--20
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SecuritisationType.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SecuritisationType.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationType'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationType'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM Securitized A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V  
                    --WHERE ISNULL(SOLID,'')<>''
                    --AND  LEN(SOLID)>10)
                    --							FOR XML PATH ('')
                    --							),1,1,'')


            --WHERE ISNULL(SecuritisationType,'')<>'' And SecuritisationType not in ('PTC - Pass Thru Certificate','DA - Direct Assignment')
            WHERE  NVL(SecuritisationType, ' ') <> ' '
              AND SecuritisationType NOT IN ( 'PTC','DA' )
            ;---Changes on 19-05-2021 on advice of Ravish ------
            ------------------------------------------------
            /*VALIDATIONS ON AccountID */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID cannot be blank.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountID, ' ') = ' ';
            -- ----SELECT * FROM Securitized
            UPDATE Securitized V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM Securitized A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								-- WHERE ISNULL(V.ACID,'')<>''
                    --								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
                    --								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
                    --								--										Timekey=@Timekey
                    --								--		))
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  NVL(V.AccountID, ' ') <> ' '
              AND V.AccountID NOT IN ( SELECT CustomerACID 
                                       FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
            ;
            IF utils.object_id('TEMPDB..tt_DUB2_42') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_42 ';
            END IF;
            DELETE FROM tt_DUB2_42;
            UTILS.IDENTITY_RESET('tt_DUB2_42');

            INSERT INTO tt_DUB2_42 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountID ORDER BY AccountID  ) ROW_  
                        FROM Securitized  ) X
                WHERE  ROW_ > 1;
            UPDATE Securitized V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate records found.AccountID are repeated.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate records found. AccountID are repeated.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --	STUFF((SELECT ','+SRNO 
                    --							FROM #UploadNewAccount A
                    --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                    --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                    ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                    --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                    --							FOR XML PATH ('')
                    --							),1,1,'')   

             WHERE  NVL(AccountID, ' ') <> ' '
              AND AccountID IN ( SELECT AccountID 
                                 FROM tt_DUB2_42 
                                   GROUP BY AccountID )
            ;
            ----------------------------------------------
            /*VALIDATIONS ON CustomerID */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerID cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CustomerID cannot be blank.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CustomerID, ' ') = ' ';
            -- ----SELECT * FROM Securitized
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CustomerID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CustomerID found. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM Securitized A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								-- WHERE ISNULL(V.ACID,'')<>''
                    --								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
                    --								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
                    --								--										Timekey=@Timekey
                    --								--		))
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  NVL(V.CustomerID, ' ') <> ' '
              AND V.CustomerID NOT IN ( SELECT RefCustomerId 
                                        FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                                               JOIN Securitized V   ON A.CustomerACID = V.AccountID
                                         WHERE  A.EffectiveFromTimeKey <= v_Timekey
                                                  AND A.EffectiveToTimeKey >= v_Timekey )
            ;
            --AND V.CustomerID NOT IN(SELECT CustomerID FROM [CurDat].[CustomerBasicDetail] 
            --							WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            --					 )
            ----------------------------------------------
            ---- ----SELECT * FROM Securitized
            /*validations on PrincipalOutstandinginRs */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalOutstandinginRs, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM Securitized A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(PrincipalOutstandinginRs) = 0
              AND NVL(PrincipalOutstandinginRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PrincipalOutstandinginRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(PrincipalOutstandinginRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM Securitized WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(PrincipalOutstandinginRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(PrincipalOutstandinginRs, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on InterestReceivableinRsinRs */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'InterestReceivableinRs cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestReceivableinRs, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM Securitized A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(InterestReceivableinRs) = 0
              AND NVL(InterestReceivableinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(InterestReceivableinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRsinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(InterestReceivableinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid InterestReceivableinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InterestReceivableinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InterestReceivableinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM Securitized WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InterestReceivableinRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(InterestReceivableinRs, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on PoolOSBalanceinRs */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'OSBalanceinRs cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'OSBalanceinRs cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'OSBalanceinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'OSBalanceinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(OSBalanceinRs, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid OSBalanceinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid OSBalanceinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'OSBalanceinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'OSBalanceinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM Securitized A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(OSBalanceinRs) = 0
              AND NVL(OSBalanceinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(OSBalanceinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid OSBalanceinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid OSBalanceinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'OSBalanceinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'OSBalanceinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(OSBalanceinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid OSBalanceinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid OSBalanceinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'OSBalanceinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'OSBalanceinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM Securitized WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(OSBalanceinRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(OSBalanceinRs, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on SecuritisationExposureinRs */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SecuritisationExposureinRs cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SecuritisationExposureinRs cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationExposureinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationExposureinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(SecuritisationExposureinRs, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SecuritisationExposureinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SecuritisationExposureinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationExposureinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationExposureinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM Securitized A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(SecuritisationExposureinRs) = 0
              AND NVL(SecuritisationExposureinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SecuritisationExposureinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SecuritisationExposureinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SecuritisationExposureinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationExposureinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationExposureinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM Securitized V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(SecuritisationExposureinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SecuritisationExposureinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SecuritisationExposureinRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationExposureinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationExposureinRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM Securitized A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM Securitized WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(SecuritisationExposureinRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(SecuritisationExposureinRs, 0)) < 0;
            -----------------------------------------------------------------
            /*validations on DateofSecuritisationReckoning */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DateofSecuritisationReckoning Can not be Blank . Please enter the DateofSecuritisationReckoning and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationReckoning Can not be Blank. Please enter the DateofSecuritisationReckoning and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSecuritisationReckoning'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationReckoning'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateofSecuritisationReckoning, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSecuritisationReckoning'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationReckoning'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateofSecuritisationReckoning, ' ') <> ' '
              AND utils.isdate(DateofSecuritisationReckoning) = 0;
            --UPDATE Securitized
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofSecuritisationReckoning Can not be Greater than Other Two. Please enter the Correct Date'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DateofSecuritisationReckoning Can not be Greater than Other Two. Please enter the Correct Date'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofSecuritisationReckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofSecuritisationReckoning' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SRNO 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM Securitized V  
            -- WHERE ISNULL(DateofSecuritisationReckoning,'')<>'' AND (Convert(Date,DateofSecuritisationReckoning,103)>Convert(Date,DateofSecuritisationMarking,103) OR Convert(Date,DateofSecuritisationReckoning,103)>Convert(Date,MaturityDate,103))
            --------------------------------------
            /*validations on DateofSecuritisationMarking */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DateofSecuritisationMarking Can not be Blank . Please enter the DateofSecuritisationMarking and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationMarking Can not be Blank. Please enter the DateofSecuritisationMarking and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSecuritisationMarking'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationMarking'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateofSecuritisationMarking, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSecuritisationMarking'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationMarking'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateofSecuritisationMarking, ' ') <> ' '
              AND utils.isdate(DateofSecuritisationMarking) = 0;
            --UPDATE Securitized
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofSecuritisationMarking Can not be Greater than Other Maturity and not less to DateofSecuritisationMarking. Please enter the Correct Date'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DateofSecuritisationMarking Can not be Greater than Other Maturity and not less to DateofSecuritisationMarking. Please enter the Correct Date'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofSecuritisationMarking' ELSE   ErrorinColumn +','+SPACE(1)+'DateofSecuritisationMarking' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SRNO 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM Securitized V  
            -- WHERE ISNULL(DateofSecuritisationMarking,'')<>'' AND (Convert(Date,DateofSecuritisationMarking,103)<Convert(Date,DateofSecuritisationReckoning,103) OR Convert(Date,DateofSecuritisationMarking,103)>Convert(Date,MaturityDate,103))
            --------------------------------------
            /*validations on MaturityDate */
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MaturityDate Can not be Blank . Please enter the MaturityDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MaturityDate Can not be Blank. Please enter the MaturityDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MaturityDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MaturityDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(MaturityDate, ' ') = ' ';
            UPDATE Securitized V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MaturityDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MaturityDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(MaturityDate, ' ') <> ' '
              AND utils.isdate(MaturityDate) = 0;
            --DROP TABLE IF EXISTS PoolNameData
            IF utils.object_id('PoolNameSecuritizedData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE PoolNameSecuritizedData';

            END;
            END IF;
            DELETE FROM PoolNameSecuritizedData;
            UTILS.IDENTITY_RESET('PoolNameSecuritizedData');

            INSERT INTO PoolNameSecuritizedData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY PoolID ORDER BY PoolID  ) ROW_  ,
                               PoolID ,
                               PoolName ,
                               AccountID 
                        FROM Securitized  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_PoolNameCnt
              FROM PoolNameSecuritizedData a
                     JOIN Securitized b   ON a.PoolID = b.PoolID
             WHERE  a.PoolName <> b.PoolName;
            IF v_PoolNameCnt > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('PoolName ERROR');
               UPDATE Securitized V
                  SET a.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Different PoolID of same combination of PoolName is Available. Please check the values and upload again'
                                            --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and SecuritisationType is Available. Please check the values and upload again'     END
                         END,
                      a.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolName'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolName'
                         END,
                      a.Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                       --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(PoolID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM PoolNameSecuritizedData a
                                           JOIN Securitized b   ON A.PoolID = b.PoolID
                                     WHERE  A.PoolName <> b.PoolName )
               ;

            END;
            END IF;
            -------------SecuritisationType----------------------------------changes done on 20-03-21 Pranay 
            TABLE IF  --SQLDEV: NOT RECOGNIZED
            IF SecuritisationTypeData  --SQLDEV: NOT RECOGNIZED
            DELETE FROM SecuritisationTypeData;
            UTILS.IDENTITY_RESET('SecuritisationTypeData');

            INSERT INTO SecuritisationTypeData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY PoolID ORDER BY PoolID  ) ROW_  ,
                               PoolID ,
                               SecuritisationType ,
                               AccountID 
                        FROM Securitized  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_SecuritisationType
              FROM SecuritisationTypeData a
                     JOIN Securitized b   ON a.PoolID = b.PoolID
             WHERE  a.SecuritisationType <> b.SecuritisationType;
            IF v_SecuritisationType > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('SecuritisationType ERROR');
               UPDATE Securitized V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Different PoolID of same combination of SecuritisationType is Available. Please check the values and upload again'
                                          --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and SecuritisationType is Available. Please check the values and upload again'     END
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecuritisationType'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecuritisationType'
                         END,
                      Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                       --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(PoolID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM SecuritisationTypeData a
                                           JOIN Securitized b   ON A.PoolID = b.PoolID
                                     WHERE  A.SecuritisationType <> b.SecuritisationType )
               ;

            END;
            END IF;
            IF  --SQLDEV: NOT RECOGNIZED
            IF PoolNameSecuritizedData1  --SQLDEV: NOT RECOGNIZED
            DELETE FROM PoolNameSecuritizedData1;
            UTILS.IDENTITY_RESET('PoolNameSecuritizedData1');

            INSERT INTO PoolNameSecuritizedData1 SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY PoolID ORDER BY PoolID  ) ROW_  ,
                               PoolID ,
                               PoolName ,
                               AccountID 
                        FROM Securitized  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_PoolNameCnt1
              FROM PoolNameSecuritizedData1 a
                     JOIN Securitized b   ON a.PoolName = b.PoolName
             WHERE  a.PoolID <> b.PoolID;
            IF v_PoolNameCnt1 > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Same PoolName present in Multiple poolID');
               UPDATE Securitized V
                  SET a.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Same PoolName present in Multiple poolID. Please check the values and upload again'
                                            --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and SecuritisationType is Available. Please check the values and upload again'     END
                         END,
                      a.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PoolName'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolName'
                         END,
                      a.Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                       --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(PoolID, ' ') <> ' '
                 AND AccountID IN ( SELECT A.AccountID 
                                    FROM PoolNameSecuritizedData1 a
                                           JOIN Securitized b   ON A.PoolName = b.PoolName
                                     WHERE  A.PoolID <> b.PoolID )
               ;

            END;
            END IF;
            IF  --SQLDEV: NOT RECOGNIZED
            IF DateofSecuritisationreckoningData  --SQLDEV: NOT RECOGNIZED
            DELETE FROM DateofSecuritisationreckoningData;
            UTILS.IDENTITY_RESET('DateofSecuritisationreckoningData');

            INSERT INTO DateofSecuritisationreckoningData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY PoolID ORDER BY PoolID  ) ROW_  ,
                               PoolID ,
                               DateofSecuritisationreckoning ,
                               AccountID 
                        FROM Securitized  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DateofSecuritisationreckoningCnt
              FROM DateofSecuritisationreckoningData a
                     JOIN Securitized b   ON a.PoolID = b.PoolID
             WHERE  a.DateofSecuritisationreckoning <> b.DateofSecuritisationreckoning;
            IF v_DateofSecuritisationreckoningCnt > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DateofSecuritisationreckoning ERROR');
               UPDATE Securitized V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PoolID found different Dates of DateofSecuritisationreckoning. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PoolID found different Dates of DateofSecuritisationreckoning. Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSecuritisationreckoning'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationreckoning'
                         END,
                      Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                       --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(PoolID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM DateofSecuritisationreckoningData a
                                           JOIN Securitized b   ON A.PoolID = b.PoolID
                                     WHERE  A.DateofSecuritisationreckoning <> b.DateofSecuritisationreckoning )
               ;

            END;
            END IF;
            IF  --SQLDEV: NOT RECOGNIZED
            IF DateofSecuritisationmarkingData  --SQLDEV: NOT RECOGNIZED
            DELETE FROM DateofSecuritisationmarkingData;
            UTILS.IDENTITY_RESET('DateofSecuritisationmarkingData');

            INSERT INTO DateofSecuritisationmarkingData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY PoolID ORDER BY PoolID  ) ROW_  ,
                               PoolID ,
                               DateofSecuritisationmarking 
                        FROM Securitized  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DateofSecuritisationmarkingCnt
              FROM DateofSecuritisationmarkingData a
                     JOIN Securitized b   ON a.PoolID = b.PoolID
             WHERE  a.DateofSecuritisationmarking <> b.DateofSecuritisationmarking;
            IF v_DateofSecuritisationmarkingCnt > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DateofSecuritisationmarking ERROR');
               UPDATE Securitized V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PoolID found different Dates of DateofSecuritisationmarking. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PoolID found different Dates of DateofSecuritisationmarking. Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSecuritisationmarking'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSecuritisationmarking'
                         END,
                      Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                       --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(PoolID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM DateofSecuritisationmarkingData a
                                           JOIN Securitized b   ON A.PoolID = b.PoolID
                                     WHERE  A.DateofSecuritisationmarking <> b.DateofSecuritisationmarking )
               ;

            END;
            END IF;
            IF  --SQLDEV: NOT RECOGNIZED
            IF MaturityDateData  --SQLDEV: NOT RECOGNIZED
            DELETE FROM MaturityDateData;
            UTILS.IDENTITY_RESET('MaturityDateData');

            INSERT INTO MaturityDateData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY PoolID ORDER BY PoolID  ) ROW_  ,
                               PoolID ,
                               MaturityDate 
                        FROM Securitized  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_MaturityDateCnt
              FROM MaturityDateData a
                     JOIN Securitized b   ON a.PoolID = b.PoolID
             WHERE  a.MaturityDate <> b.MaturityDate;
            IF v_MaturityDateCnt > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('MaturityDate ERROR');
               UPDATE Securitized V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PoolID found different Dates of MaturityDate. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PoolID found different Dates of MaturityDate. Please check the values and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MaturityDate'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MaturityDate'
                         END,
                      Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM tt_DUB2_42))
                       --AND ACID IN(SELECT ACID FROM tt_DUB2_42 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(PoolID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM MaturityDateData a
                                           JOIN Securitized b   ON A.PoolID = b.PoolID
                                     WHERE  A.MaturityDate <> b.MaturityDate )
               ;

            END;
            END IF;
            ---------------------------------
            GOTO valid;

         END;
         <<ErrorData>>
         DBMS_OUTPUT.PUT_LINE('no');
         OPEN  v_cursor FOR
            SELECT * ,
                   'Validation' TableName  
              FROM RBL_MISDB_PROD.MasterUploadData 
             WHERE  FileNames = v_filepath ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN;
         <<valid>>
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE NOT EXISTS ( SELECT 1 
                                FROM SecuritizedDetail_stg 
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
                FROM Securitized  );
            --	----SELECT * FROM Securitized 
            --	--ORDER BY ErrorMessage,Securitized.ErrorinColumn DESC
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
                               FROM SecuritizedDetail_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE SecuritizedDetail_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.SecuritizedDetail_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
                      'Validation' TableName  
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY ColumnName, ErrorData, ErrorType, FileNames, Flag, Srnooferroneousrows ORDER BY ColumnName, ErrorData, ErrorType, FileNames, Flag, Srnooferroneousrows  ) ROW_  
                        FROM RBL_MISDB_PROD.MasterUploadData  ) a
                WHERE  A.ROW = 1
                         AND FileNames = v_filepath ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         ----SELECT * FROM Securitized
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
                 utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM SecuritizedDetail_stg WHERE filname=@FilePathUpload)
                 --	 BEGIN
                 --	 DELETE FROM SecuritizedDetail_stg
                 --	 WHERE filname=@FilePathUpload
                 --	 PRINT 'ROWS DELETED FROM DBO.SecuritizedDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                 ,--	 END
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SECURITIZEDUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
