--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" 
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
         IF ( v_MenuID = 24734 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            v_DuplicateCnt NUMBER(10,0) := 0;
            /*validations on Customer ID*/
            v_Count NUMBER(10,0);
            v_I NUMBER(10,0);
            v_Entity_Key NUMBER(10,0);
            v_TaggingLevel VARCHAR2(100) := ' ';
            v_CustomerID VARCHAR2(100) := ' ';
            v_AccountId VARCHAR2(100) := ' ';
            v_RelatedUCICCustomerIDAccountID VARCHAR2(100) := ' ';
            v_UCIC VARCHAR2(100) := ' ';
            v_LenderNameCnt NUMBER(10,0) := 0;
            v_PoolType NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadRPModuleLender') IS NOT NULL  
            IF utils.object_id('UploadRPModuleLender') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadRPModuleLender';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM RPModuleLender_stg 
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
               DELETE FROM UploadRPModuleLender;
               UTILS.IDENTITY_RESET('UploadRPModuleLender');

               INSERT INTO UploadRPModuleLender SELECT * ,
                                                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                       UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM RPModuleLender_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            --SrNo	Territory	ACID	InterestReversalAmount	sheetname
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'CollateralID,Tagging Level,DistributionLevel,CollateralType,CollateralOwnerType,Interest CollateralOwnershipType,Balances,Dates',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(CustomerID, ' ') = ' '
              AND NVL(LenderName, ' ') = ' '
              AND NVL(InDefaultDate, ' ') = ' '
              AND NVL(OutofDefaultDate, ' ') = ' ';
            --WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(sheetname,'')=''
            --IF EXISTS(SELECT 1 FROM UploadRPModuleLender WHERE ISNULL(ErrorMessage,'')<>'')
            --BEGIN
            --PRINT 'NO DATA'
            --GOTO ERRORDATA;
            --END
            /*validations on Sl. No.*/
            ------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('Satart11');
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(SrNo, ' ') = ' '
              OR NVL(SrNo, '0') = '0';
            UPDATE UploadRPModuleLender V
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
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(SrNo) = 0
              AND NVL(SrNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SrNo), '%^[0-9]%');
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  REGEXP_LIKE(NVL(SrNo, ' '), '%[,!@#$%^&*()_-+=/]%');
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM UploadRPModuleLender 
              GROUP BY SrNo

               HAVING COUNT(SrNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadRPModuleLender V
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
                                        FROM UploadRPModuleLender 
                                          GROUP BY SrNo

                                           HAVING COUNT(SrNo)  > 1 )
            ;
            END IF;
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Customer ID cannot be blank . Please check the values and upload again.n'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer IDl'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomerID, ' ') = ' ';
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You can not Upload Lender where RP Details are not found . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' You can not Upload Lender where RP Details are not found . Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer IDl'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.CustomerID, ' ') NOT IN ( SELECT V.CustomerID 
                                                    FROM UploadRPModuleLender V
                                                           JOIN RP_Portfolio_Details B   ON V.CustomerID = B.CustomerID
                                                     WHERE  NVL(B.IsActive, 'N') = 'Y' )
            ;
            IF utils.object_id('TempDB..tt_tmp_33') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp_33 ';
            END IF;
            DELETE FROM tt_tmp_33;
            UTILS.IDENTITY_RESET('tt_tmp_33');

            INSERT INTO tt_tmp_33 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_NUMBER(SrNo,10,0)  ) RecentRownumber  ,
                                         SrNo ,
                                         CustomerID 
                 FROM UploadRPModuleLender ;
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_tmp_33 ;
            v_I := 1 ;
            v_Entity_Key := 0 ;
            v_CustomerId := ' ' ;
            v_UCIC := ' ' ;
            v_AccountId := ' ' ;
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT CustomerID ,
                         SrNo 

                    INTO v_RelatedUCICCustomerIDAccountID,
                         v_Entity_Key
                    FROM tt_tmp_33 
                   WHERE  RecentRownumber = v_I
                    ORDER BY SrNo;
                  IF v_TaggingLevel = 'Customer ID' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('Sachin');
                     SELECT CustomerId 

                       INTO v_CustomerId
                       FROM CurDat_RBL_MISDB_PROD.CustomerBasicDetail 
                      WHERE  CustomerId = v_RelatedUCICCustomerIDAccountID;
                     IF v_CustomerId = ' ' THEN

                     BEGIN
                        UPDATE UploadRPModuleLender
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is invalid. Kindly check the entered customer id'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID is invalid. Kindly check the entered customer id'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                                  END
                         WHERE  SrNo = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  --							  END
                  v_I := v_I + 1 ;
                  v_CustomerId := ' ' ;
                  v_UCIC := ' ' ;
                  v_AccountId := ' ' ;

               END;
            END LOOP;
            ----------------------------------------------------------------
            /*validations on Lender Name And Customer ID*/
            TABLE IF  --SQLDEV: NOT RECOGNIZED
            IF tt_tmp_3311  --SQLDEV: NOT RECOGNIZED
            DELETE FROM tt_tmp11_4;
            UTILS.IDENTITY_RESET('tt_tmp11_4');

            INSERT INTO tt_tmp11_4 ( 
            	SELECT DISTINCT V.CustomerID ,
                             C.BankName LenderName  ,
                             B.InDefaultDate ,
                             B.OutOfDefaultDate 
            	  FROM UploadRPModuleLender V
                      JOIN RP_Lender_Details B   ON V.CustomerID = B.CustomerID
                      JOIN DIMBANK C   ON B.ReportingLenderAlt_Key = C.BankAlt_Key );
            --Select 'tt_tmp_3311',* from tt_tmp_3311
            MERGE INTO UploadRPModuleLender V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'This CustomerId and LenderName are alreary present in Lender Table . Please check the values and upload again.'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' This CustomerId and LenderName are alreary present in Lender Table . Please check the values and upload again.'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InDefaultDate/OutOfDefaultDate'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InDefaultDate/OutOfDefaultDate'
               END AS pos_3, V.SrNo
            FROM UploadRPModuleLender V
                   JOIN tt_tmp11_4 B   ON V.CustomerID = B.CustomerID
                   AND V.LenderName = B.LenderName 
             WHERE NVL(B.InDefaultDate, ' ') <> ' '
              AND B.OutOfDefaultDate IS NULL) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SrNo;
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You can not provide InDefaultDate and OutOfDefaultDate simaltanously. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You can not provide InDefaultDate and OutOfDefaultDate simaltanously. Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InDefaultDate/OutOfDefaultDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InDefaultDate/OutOfDefaultDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.InDefaultDate, ' ') <> ' '
              AND NVL(V.OutOfDefaultDate, ' ') <> ' ';
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You need to provide Indefault date . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You need to provide Indefault date. Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InDefaultDate/OutOfDefaultDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InDefaultDate/OutOfDefaultDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.InDefaultDate, ' ') = ' '
              AND NVL(V.OutOfDefaultDate, ' ') = ' ';
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You can not Upload Lender where CustomerID and Lender is already present with IndefaultDate. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' You can not Upload Lender where CustomerID and Lender is already present with IndefaultDate.Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InDefaultDate/OutOfDefaultDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InDefaultDate/OutOfDefaultDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.CustomerID, ' ') IN ( SELECT V.CustomerID 
                                                FROM UploadRPModuleLender V
                                                       JOIN RPModuleLender_Mod B   ON V.CustomerID = B.CustomerID
                                                       AND V.LenderName = B.LenderName
                                                 WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                          AND EffectiveToTimeKey >= v_TimeKey )
                                                          AND AuthorisationStatus IN ( 'NP','MP','FM','A','1A' )
             )
            ;
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You can not Upload Lender where CustomerID and Lender is Not with IndefaultDate. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' You can not Upload Lender where CustomerID and Lender Not present with IndefaultDate.Please check the values and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InDefaultDate/OutOfDefaultDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InDefaultDate/OutOfDefaultDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(V.CustomerID, ' ') NOT IN ( SELECT V.CustomerID 
                                                    FROM UploadRPModuleLender V
                                                           JOIN RPModuleLender_Mod B   ON V.CustomerID = B.CustomerID
                                                           AND V.LenderName = B.LenderName
                                                     WHERE  ( EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey )
                                                              AND AuthorisationStatus IN ( 'NP','MP','FM','A','1A' )
             )

              AND NVL(V.InDefaultDate, ' ') = ' ';
            --------------------------------------------------------
            ----------------------------------------------------------------
            /*validations on Lender Name*/
            UPDATE UploadRPModuleLender V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Lender Name cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Lender Name cannot be blank . Please check the values and upload again.n'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Lender Name'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Lender Name'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(LenderName, ' ') = ' ';
            IF utils.object_id('LenderNameData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE LenderNameData';

            END;
            END IF;
            DELETE FROM LenderNameData;
            UTILS.IDENTITY_RESET('LenderNameData');

            INSERT INTO LenderNameData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY LenderName ORDER BY LenderName  ) ROW_  ,
                               LenderName 
                        FROM UploadRPModuleLender  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_LenderNameCnt
              FROM LenderNameData A
                     LEFT JOIN DIMBANK B   ON A.LenderName = B.BankName
             WHERE  B.BankName IS NULL;
            IF v_LenderNameCnt > 0 THEN

            BEGIN
               UPDATE UploadRPModuleLender V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Lender Name’. Kindly enter the values as mentioned in the ‘Lender Name’ master and upload again. Click on ‘Download Master value’ to download the valid values for the











                                           column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Lender Name’. Kindly enter the values as mentioned in the ‘Lender Name’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Lender Name'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Lender Name'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(LenderName, ' ') <> ' '
                 AND V.LenderName IN ( SELECT A.LenderName 
                                       FROM LenderNameData A
                                              LEFT JOIN DIMBANK B   ON A.LenderName = B.BankName
                                        WHERE  B.BankName IS NULL )
               ;

            END;
            END IF;
            ------------------------------------------------------------------------
            /*validations on InDefault Date*/
            --UPDATE UploadRPModuleLender
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InDefaultDate cannot be blank . Please check the values and upload again.'     
            --						ELSE ErrorMessage+','+SPACE(1)+' InDefaultDate cannot be blank . Please check the values and upload again.n'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate' END   
            --		,Srnooferroneousrows=V.SrNo
            -- FROM UploadRPModuleLender V  
            -- WHERE ISNULL(InDefaultDate,'')=''
            --   SET DateFormat DMY
            --  UPDATE UploadRPModuleLender
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InDefaultDate  is not Valid Date . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'InDefaultDate is not Valid Date . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'InDefaultDate' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadRPModuleLender V  
            --  WHERE ISDATE(InDefaultDate)=0 AND ISNULL(InDefaultDate,'')=''
            -------------------------------------------------------------------------------
            /*validations on Out of Default Date*/
            --UPDATE UploadRPModuleLender
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OutDefaultDate cannot be blank . Please check the values and upload again.'     
            --					ELSE ErrorMessage+','+SPACE(1)+' OutDefaultDate cannot be blank . Please check the values and upload again.n'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OutDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'OutDefaultDate' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadRPModuleLender V  
            --WHERE ISNULL(OutofDefaultDate,'')=''
            --   SET DateFormat DMY
            --  UPDATE UploadRPModuleLender
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'OutDefaultDate  is not Valid Date . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'OutDefaultDate is not Valid Date . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'OutDefaultDate' ELSE   ErrorinColumn +','+SPACE(1)+'OutDefaultDate' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadRPModuleLender V  
            --  WHERE ISDATE(OutofDefaultDate)=0 AND ISNULL(OutofDefaultDate,'')=''
            ------------------------------------------------------------------------
            ------------------------------------------------------
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
                                FROM RPModuleLender_stg 
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
              ( SELECT SrNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM UploadRPModuleLender  );
            DBMS_OUTPUT.PUT_LINE('Row Effected');
            DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
            --	----SELECT * FROM UploadRPModuleLender 
            --	--ORDER BY ErrorMessage,UploadRPModuleLender.ErrorinColumn DESC
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
                               FROM RPModuleLender_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('1');
               DELETE RPModuleLender_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE('2');
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.RPModuleLender_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadRPModuleLender
         DBMS_OUTPUT.PUT_LINE('p');

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ------to delete file if it has errors
      --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
      --begin
      --print 'ppp'
      -- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE sheetname=@FilePathUpload)
      -- BEGIN
      -- print '123'
      -- DELETE FROM IBPCPoolDetail_stg
      -- WHERE sheetname=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- END
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE sheetname=@FilePathUpload)
                 --	 BEGIN
                 --	 DELETE FROM IBPCPoolDetail_stg
                 --	 WHERE sheetname=@FilePathUpload
                 --	 PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                 ,--	 END
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RPMODULELENDERUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
