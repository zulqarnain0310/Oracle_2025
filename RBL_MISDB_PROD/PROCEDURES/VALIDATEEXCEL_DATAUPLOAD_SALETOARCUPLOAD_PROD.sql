--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'FNASUPERADMIN' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'SaletoARC.xlsx' 
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
         DECLARE
            v_temp NUMBER(1, 0) := 0;
            ---------------------------------
            -------------------@DateOfApproval--------------------------Pranay 21-03-2021
            v_DateOfApprovalCnt NUMBER(10,0) := 0;
            ----------------------------
            -------------------@DateOfSaletoARC--------------------------Pranay 21-03-2021
            v_DateOfSaletoARCCnt NUMBER(10,0) := 0;
         --IF (@MenuID=14573)	

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadSaletoARC') IS NOT NULL  
            --BEGIN  
            -- DROP TABLE UploadSaletoARC  
            --END
            --drop table if exists  UploadSaletoARC 
            IF utils.object_id('UploadSaletoARC') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadSaletoARC';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM SaletoARC_Stg 
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
               DELETE FROM UploadSaletoARC;
               UTILS.IDENTITY_RESET('UploadSaletoARC');

               INSERT INTO UploadSaletoARC SELECT * ,
                                                  UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                  UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                  UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM SaletoARC_Stg 
                   WHERE  filname = v_FilePathUpload;
               UPDATE DateOfSaletoARC 
                  SET UploadID = 1
                WHERE  UploadID IS NULL;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            ----SELECT * FROM UploadSaletoARC
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'SRNO,SourceSystem,CustomerID,CustomerName,AccountID,BalanceOSinRs,POS,InterestReceivableinRs,DateOfSaletoARC,DateofApproval,ExposuretoARCinRs',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(AccountID, ' ') = ' '
              AND NVL(CustomerID, ' ') = ' '
              AND NVL(PrincipalOutstandinginRs, ' ') = ' '
              AND NVL(InterestReceivableinRs, ' ') = ' '
              AND NVL(BalanceOSinRs, ' ') = ' '
              AND NVL(ExposuretoARCinRs, ' ') = ' '
              AND NVL(DateOfSaletoARC, ' ') = ' '
              AND NVL(DateOfApproval, ' ') = ' ';
            -- WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(SourceSystem,'')=''
            -- AND ISNULL(CustomerID,'')=''
            -- AND ISNULL(CustomerName,'')=''
            --AND ISNULL(AccountID,'')=''
            -- AND ISNULL(BalanceOSinRs,'')=''
            -- AND ISNULL(POS,'')=''
            -- AND ISNULL(InterestReceivableinRs,'')=''
            -- AND ISNULL(DateOfSaletoARC,'')=''
            -- AND ISNULL(DateOfApproval,'')=''
            -- AND ISNULL(ExposuretoARCinRs,'')=''
            --  AND ISNULL(filname,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadSaletoARC 
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
            --	 UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 
            --	'Sr. No. cannot be blank.  Please check the values and upload again' 
            --		ELSE ErrorMessage+','+SPACE(1)+ 'Sr. No. cannot be blank.  Please check the values and upload again'
            --		END
            --	,ErrorinColumn='SRNO'    
            --	,Srnooferroneousrows=''
            --	FROM UploadSaletoARC V  
            --	WHERE ISNULL(v.SrNo,'')=''  
            -- UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sr. No.  Please check the values and upload again'     
            --								  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Sr. No.  Please check the values and upload again'      END
            --		,ErrorinColumn='SRNO'    
            --		,Srnooferroneousrows=SRNOSrNo,'')=0   OR ISNULL(v.SrNo,'')<0
            --  IF OBJECT_ID('TEMPDB..#R') IS NOT NULL
            --  DROP TABLE #R
            --  SELECT * INTO #R FROM(
            --  SELECT *,ROW_NUMBER() OVER(PARTITION BY SRNO ORDER BY SRNO)ROW
            --   FROM UploadSaletoARC
            --   )A
            --   WHERE ROW>1
            -- PRINT 'DUB'  
            --  UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Following sr. no. are repeated' 
            --					ELSE ErrorMessage+','+SPACE(1)+     'Following sr. no. are repeated' END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SRNO' ELSE ErrorinColumn +','+SPACE(1)+  'SRNO' END
            --		,Srnooferroneousrows=SRNO
            ----		--STUFF((SELECT DISTINCT ','+SRNO 
            ----		--						FROM UploadSaletoARC
            ----		--						FOR XML PATH ('')
            ----		--						),1,1,'')
            -- FROM UploadSaletoARC V  
            --	WHERE  V.Srno IN(SELECT SRNO FROM #R )
            --  ---------VALIDATIONS ON ACID
            UPDATE UploadSaletoARC V
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
                    --								----FROM UploadSaletoARC A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountID, ' ') = ' ';
            -- ----SELECT * FROM UploadSaletoARC
            UPDATE UploadSaletoARC V
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
                    --								--FROM UploadSaletoARC A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
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
            -- ----SELECT * FROM UploadSaletoARC
            DBMS_OUTPUT.PUT_LINE('acid');
            --  -------combination
            --------	PRINT 'TerritoryAlt_Key'
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadSaletoARC A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --								----WHERE ISNULL(ACID,'') <>'' and LEN(ACID)>25 )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountID, ' ') <> ' '
              AND LENGTH(AccountID) > 25;
            -- -------------------------FOR DUPLICATE ACIDS
            IF utils.object_id('TEMPDB..tt_ACID_DUP_3') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACID_DUP_3 ';
            END IF;
            DELETE FROM tt_ACID_DUP_3;
            UTILS.IDENTITY_RESET('tt_ACID_DUP_3');

            INSERT INTO tt_ACID_DUP_3 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountID ORDER BY AccountID  ) ROW_  
                        FROM UploadSaletoARC  ) A
                WHERE  ROW_ > 1;
            UPDATE UploadSaletoARC V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate records found. Account ID are repeated.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate records found. Account ID are repeated.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadSaletoARC A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --								----WHERE ISNULL(ACID,'') <>'' and ACID IN(SELECT ACID FROM tt_ACID_DUP_3))
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountID, ' ') <> ' '
              AND AccountID IN ( SELECT AccountID 
                                 FROM tt_ACID_DUP_3  )
            ;
            -- --  ---------VALIDATIONS ON ACID
            --  UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID cannot be blank.  Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Account ID cannot be blank.  Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
            --		,Srnooferroneousrows=V.SRNO
            ----								----STUFF((SELECT ','+SRNO 
            ----								----FROM UploadSaletoARC A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V  
            ----								----				WHERE ISNULL(ACID,'')='' )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadSaletoARC V  
            -- WHERE ISNULL(AccountID,'')='' 
            ---- ----SELECT * FROM UploadSaletoARC
            --  UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid Account ID found. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid Account ID found. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
            --		,Srnooferroneousrows=V.SRNO
            ----								--STUFF((SELECT ','+SRNO 
            ----								--FROM UploadSaletoARC A
            ----								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
            ----								-- WHERE ISNULL(V.ACID,'')<>''
            ----								--		AND V.ACID NOT IN(SELECT SystemAcid FROM AxisIntReversalDB.IntReversalDataDetails 
            ----								--										WHERE -----EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            ----								--										Timekey=@Timekey
            ----								--		))
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            --		FROM UploadSaletoARC V  
            -- WHERE ISNULL(V.AccountID,'')<>''
            -- AND V.AccountID NOT IN(SELECT CustomerACID FROM [CurDat].[AdvAcBasicDetail] 
            --								WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            -- )
            ---- ----SELECT * FROM UploadSaletoARC
            --  print 'acid'
            ----  -------combination
            ----------	PRINT 'TerritoryAlt_Key'
            --  UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Account ID found. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+  'Invalid Account ID found. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Account ID' ELSE ErrorinColumn +','+SPACE(1)+  'Account ID' END  
            --		,Srnooferroneousrows=V.SRNO
            ----								----STUFF((SELECT ','+SRNO 
            ----								----FROM UploadSaletoARC A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
            ----								----WHERE ISNULL(ACID,'') <>'' and LEN(ACID)>25 )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadSaletoARC V  
            -- WHERE ISNULL(AccountID,'') <>'' and LEN(AccountID)>25 
            ---- -------------------------FOR DUPLICATE CUSTOMERIDS
            -- IF OBJECT_ID('TEMPDB..#CUSTOMER_DUP') IS NOT NULL
            -- DROP TABLE tt_ACID_DUP_3
            -- SELECT * INTO #CUSTOMER_DUP FROM(
            -- SELECT *,ROW_NUMBER() OVER(PARTITION BY CUSTOMERID ORDER BY  CUSTOMERID)AS ROW FROM UploadSaletoARC
            -- )A
            -- WHERE ROW>1
            -- UPDATE UploadSaletoARC
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found. Customer ID are repeated.  Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+  'Duplicate records found. Customer ID are repeated.  Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Customer ID' ELSE ErrorinColumn +','+SPACE(1)+  'Customer ID' END  
            --		,Srnooferroneousrows=V.SRNO
            ----								----STUFF((SELECT ','+SRNO 
            ----								----FROM UploadSaletoARC A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
            ----								----WHERE ISNULL(ACID,'') <>'' and ACID IN(SELECT ACID FROM tt_ACID_DUP_3))
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM UploadSaletoARC V  
            -- WHERE ISNULL(CustomerID,'') <>'' and CustomerID IN(SELECT CustomerID FROM #CUSTOMER_DUP)
            --  ---------VALIDATIONS ON CustomerID
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID cannot be blank.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadSaletoARC A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CustomerID, ' ') = ' ';
            -- ----SELECT * FROM UploadSaletoARC
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Customer ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Customer ID found. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								--STUFF((SELECT ','+SRNO 
                    --								--FROM UploadSaletoARC A
                    --								--WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
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
                                               JOIN UploadSaletoARC V   ON A.CustomerACID = V.AccountID
                                         WHERE  A.EffectiveFromTimeKey <= v_Timekey
                                                  AND A.EffectiveToTimeKey >= v_Timekey )
            ;
            --AND V.CustomerID NOT IN(SELECT CustomerID FROM [CurDat].[CustomerBasicDetail]
            --							WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            --)
            DBMS_OUTPUT.PUT_LINE('Customerid');
            --  -------combination
            --------	PRINT 'TerritoryAlt_Key'
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Customer ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Customer ID found. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM UploadSaletoARC A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --								----WHERE ISNULL(ACID,'') <>'' and LEN(ACID)>25 )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CustomerID, ' ') <> ' '
              AND LENGTH(CustomerID) > 15;
            ------ -------validations on Balance Outstanding
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Balance Outstanding cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Balance Outstanding cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Balance Outstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Balance Outstanding'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ----WHERE ISNULL(InterestReversalAmount,'')='')
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(BalanceOSinRs, ' ') = ' ';
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Balance Outstanding. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Int Balance Outstanding. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Balance Outstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Balance Outstanding'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM UploadSaletoARC A
                    --WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --)
                    --FOR XML PATH ('')
                    --),1,1,'')   

             WHERE  ( utils.isnumeric(BalanceOSinRs) = 0
              AND NVL(BalanceOSinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(BalanceOSinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Balance Outstanding. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Balance Outstanding. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Balance Outstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Balance Outstanding'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    ----)
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(BalanceOSinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Balance Outstanding. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Balance Outstanding. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Balance Outstanding'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Exposure to Arc Outstanding'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
                    ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    ---- )
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(BalanceOSinRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 6), NVL(BalanceOSinRs, 0)) < 0;
            ------ -------validations on Interest Receivable
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Interest Receivable cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Interest Receivable cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest Receivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest Receivable'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ----WHERE ISNULL(InterestReversalAmount,'')='')
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(InterestReceivableinRs, ' ') = ' ';
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest Receivable. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest Receivable. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest Receivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest Receivable'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM UploadSaletoARC A
                    --WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --)
                    --FOR XML PATH ('')
                    --),1,1,'')   

             WHERE  ( utils.isnumeric(InterestReceivableinRs) = 0
              AND NVL(InterestReceivableinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(InterestReceivableinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest Receivable. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest Receivable. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest Receivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest Receivable'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    ----)
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(InterestReceivableinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Interest Receivable. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Interest Receivable. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Interest Receivable'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Interest Receivable'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
                    ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    ---- )
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(InterestReceivableinRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 6), NVL(InterestReceivableinRs, 0)) < 0;
            ------ -------validations on PrincipalOutstandinginRs
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ----WHERE ISNULL(InterestReversalAmount,'')='')
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(PrincipalOutstandinginRs, ' ') = ' ';
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM UploadSaletoARC A
                    --WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --)
                    --FOR XML PATH ('')
                    --),1,1,'')   

             WHERE  ( utils.isnumeric(PrincipalOutstandinginRs) = 0
              AND NVL(PrincipalOutstandinginRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PrincipalOutstandinginRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    ----)
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(PrincipalOutstandinginRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid PrincipalOutstandinginRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrincipalOutstandinginRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrincipalOutstandinginRs'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
                    ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    ---- )
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(PrincipalOutstandinginRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 6), NVL(PrincipalOutstandinginRs, 0)) < 0;
            ------ -------validations on Exposure to Arc
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Exposure to Arc cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Exposure to Arc cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Exposure to Arc'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Exposure to Arc'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ----WHERE ISNULL(InterestReversalAmount,'')='')
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(ExposuretoARCinRs, ' ') = ' ';
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Exposure to Arc. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Exposure to Arc. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Exposure to Arc'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Exposure to Arc'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM UploadSaletoARC A
                    --WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --)
                    --FOR XML PATH ('')
                    --),1,1,'')   

             WHERE  ( utils.isnumeric(ExposuretoARCinRs) = 0
              AND NVL(ExposuretoARCinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(ExposuretoARCinRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Exposure to Arc. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Exposure to Arc. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Exposure to Arc'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Exposure to Arc'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT V.SrNo FROM UploadSaletoARC V
                    ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    ----)
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(ExposuretoARCinRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Exposure to Arc. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Exposure to Arc. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Exposure to Arc'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Exposure to Arc'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   ----STUFF((SELECT ','+SRNO 
                    ----FROM UploadSaletoARC A
                    ----WHERE A.SrNo IN(SELECT SRNO FROM UploadSaletoARC WHERE ISNULL(InterestReversalAmount,'')<>''
                    ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    ---- )
                    ----FOR XML PATH ('')
                    ----),1,1,'')   

             WHERE  NVL(ExposuretoARCinRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 6), NVL(ExposuretoARCinRs, 0)) < 0;
            ----------------------For Flag checking in Main table 
            MERGE INTO UploadSaletoARC V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Already SaletoArc Flag is present. Please Check the Account'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Already SaletoArc Flag is present. Please Check the Account'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountID'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountID'
               END AS pos_3, V.SrNo
            --STUFF((SELECT ','+SRNO 
             --						FROM #UploadNewAccount A
             --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
             --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
             --										)
             --						FOR XML PATH ('')
             --						),1,1,'')   

            FROM UploadSaletoARC V
                   JOIN RBL_MISDB_PROD.AdvAcOtherDetail A   ON V.AccountID = A.RefSystemAcId
                   AND A.EffectiveToTimeKey = 49999 
             WHERE A.SplFlag LIKE '%SaleArc%') src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SrNo;
            ----------- /*validations on DateOfSaletoARC */
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DateOfSaletoARC Can not be Blank . Please enter the DateOfSaletoARC and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DateOfSaletoARC Can not be Blank. Please enter the DateOfSaletoARC and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateOfSaletoARC'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateOfSaletoARC'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateOfSaletoARC, ' ') = ' ';
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ?dd-mm-yyyy?'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ?dd-mm-yyyy?'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateOfSaletoARC'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateOfSaletoARC'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateOfSaletoARC, ' ') <> ' '
              AND utils.isdate(DateOfSaletoARC) = 0;
            ----------- /*validations on DateOfApproval 
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DateOfApproval Can not be Blank . Please enter the DateOfApproval and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DateOfApproval Can not be Blank. Please enter the DateOfApproval and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateOfApproval'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateOfApproval'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateOfApproval, ' ') = ' ';
            UPDATE UploadSaletoARC V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ?dd-mm-yyyy?'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ?dd-mm-yyyy?'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateOfApproval'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateOfApproval'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
                    --										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  NVL(DateOfApproval, ' ') <> ' '
              AND utils.isdate(DateOfApproval) = 0;
            --DROP TABLE IF EXISTS DateOfApprovalData
            IF utils.object_id('DateOfApprovalData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE DateOfApprovalData';

            END;
            END IF;
            DELETE FROM DateOfApprovalData;
            UTILS.IDENTITY_RESET('DateOfApprovalData');

            INSERT INTO DateOfApprovalData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY UploadID ORDER BY UploadID  ) ROW_  ,
                               UploadID ,
                               DateOfApproval 
                        FROM UploadSaletoARC  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DateOfApprovalCnt
              FROM DateOfApprovalData a
                     JOIN UploadSaletoARC b   ON a.UploadID = b.UploadID
             WHERE  a.DateOfApproval <> b.DateOfApproval;
            IF v_DateOfApprovalCnt > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DateOfApproval ERROR');
               /*DateOfApproval Validation*/
               --Pranay 20-03-2021
               UPDATE UploadSaletoARC V
                  SET b.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UploadID found different Dates of DateOfApproval. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UploadID found different Dates of DateOfApproval. Please check the values and upload again'
                         END,
                      b.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateOfApproval'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateOfApproval'
                         END,
                      b.Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM #DUB2))
                       --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(UploadID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM DateOfApprovalData a
                                           JOIN UploadSaletoARC b   ON A.UploadID = b.UploadID
                                     WHERE  A.DateOfApproval <> b.DateOfApproval )
               ;

            END;
            END IF;
            --DROP TABLE IF EXISTS DateOfSaletoARCData
            IF utils.object_id('DateOfSaletoARCData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE DateOfSaletoARCData';

            END;
            END IF;
            DELETE FROM DateOfSaletoARCData;
            UTILS.IDENTITY_RESET('DateOfSaletoARCData');

            INSERT INTO DateOfSaletoARCData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY UploadID ORDER BY UploadID  ) ROW_  ,
                               UploadID ,
                               DateOfSaletoARC 
                        FROM UploadSaletoARC  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DateOfSaletoARCCnt
              FROM DateOfSaletoARCData a
                     JOIN UploadSaletoARC b   ON a.UploadID = b.UploadID
             WHERE  a.DateOfSaletoARC <> b.DateOfSaletoARC;
            IF v_DateOfSaletoARCCnt > 0 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DateOfSaletoARC ERROR');
               /*DateOfSaletoARC Validation*/
               --Pranay 20-03-2021
               UPDATE UploadSaletoARC V
                  SET b.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'UploadID found different Dates of DateOfSaletoARC. Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'UploadID found different Dates of DateOfSaletoARC. Please check the values and upload again'
                         END,
                      b.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateOfSaletoARC'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateOfSaletoARC'
                         END,
                      b.Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM #DUB2))
                       --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(UploadID, ' ') <> ' '
                 AND AccountID IN ( SELECT B.AccountID 
                                    FROM DateOfSaletoARCData a
                                           JOIN UploadSaletoARC b   ON A.UploadID = b.UploadID
                                     WHERE  A.DateOfSaletoARC <> b.DateOfSaletoARC )
               ;

            END;
            END IF;
            GOTO valid;

         END;
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
                                FROM SaletoARC_Stg 
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
                FROM UploadSaletoARC  );
            --	----SELECT * FROM UploadSaletoARC 
            --	--ORDER BY ErrorMessage,UploadSaletoARC.ErrorinColumn DESC
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
                               FROM SaletoARC_Stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE SaletoARC_Stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.SaletoARC_Stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadSaletoARC
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
      -- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)
      -- BEGIN
      -- print '123'
      -- DELETE FROM IBPCPoolDetail_stg
      -- WHERE filname=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- ELSE IF EXISTS(SELECT 1 FROM [AxisIntReversalDB].IntAccruedData_stg WHERE filname=@FilePathUpload)
      -- BEGIN
      -- DELETE FROM [AxisIntReversalDB].IntAccruedData_stg
      -- WHERE filname=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.[AxisIntReversalDB].IntAccruedData_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- ELSE IF EXISTS(SELECT 1 FROM [AxisIntReversalDB].AddNewAccountData_stg WHERE filname=@FilePathUpload)
      -- BEGIN
      -- DELETE FROM [AxisIntReversalDB].AddNewAccountData_stg
      -- WHERE filname=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.[AxisIntReversalDB].AddNewAccountData_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- end
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
                         FROM SaletoARC_Stg 
                          WHERE  filname = v_FilePathUpload );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DELETE SaletoARC_Stg

          WHERE  filname = v_FilePathUpload;
         DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.SaletoARC_Stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

      END;
      END IF;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_SALETOARCUPLOAD_PROD" TO "ADF_CDR_RBL_STGDB";
