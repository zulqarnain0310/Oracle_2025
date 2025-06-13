--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" 
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
         IF ( v_MenuID = 24703 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on Sl. No.*/
            ------------------------------------------------------------
            v_DuplicateCnt NUMBER(10,0) := 0;
            -----------------------------------------------------------
            /*validations on System CollateralID*/
            ------------------------------------------------------------
            v_SystemCollateralIDCnt NUMBER(10,0) := 0;
            v_SystemCollateralIDMgmtCnt NUMBER(10,0) := 0;
            ------------------------------------------------------
            /*validations on Customer ID */
            ------------------------------------------------------------
            v_CustomerID NUMBER(10,0) := 0;
            ------------------------------------------------------------------------------
            /*validations on Other Owner Relationship */
            ------------------------------------------------------------
            v_CollateralOwnerType NUMBER(10,0) := 0;
            ------------------------------------------------------------------------------
            /*validations on Address Category */
            ------------------------------------------------------------
            v_AddressCategoryCnt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadOtherOwnerDetail') IS NOT NULL  
            IF utils.object_id('UploadOtherOwnerDetail') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadOtherOwnerDetail';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM CollateralOthOwnerDetails_stg 
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
               DELETE FROM UploadOtherOwnerDetail;
               UTILS.IDENTITY_RESET('UploadOtherOwnerDetail');

               INSERT INTO UploadOtherOwnerDetail SELECT * ,
                                                         UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                         UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                         UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM CollateralOthOwnerDetails_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'CollateralID,Customer of theBank,Customer ID,Other Owner Name,Other Owner Relationship,Address Type,Balances,Dates',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SystemCollateralID, ' ') = ' '
              AND NVL(CustomeroftheBank, ' ') = ' '
              AND NVL(CustomerID, ' ') = ' '
              AND NVL(OtherOwnerName, ' ') = ' '
              AND NVL(OtherOwnerRelationship, ' ') = ' '
              AND NVL(Ifrelativeentervalue, ' ') = ' '
              AND NVL(AddressType, ' ') = ' '
              AND NVL(AddressCategory, ' ') = ' '
              AND NVL(AddressLine1, ' ') = ' '
              AND NVL(AddressLine2, ' ') = ' '
              AND NVL(AddressLine3, ' ') = ' '
              AND NVL(City, ' ') = ' '
              AND NVL(PinCode, ' ') = ' '
              AND NVL(Country, ' ') = ' '
              AND NVL(District, ' ') = ' '
              AND NVL(StdCodeO, ' ') = ' '
              AND NVL(PhoneNoO, ' ') = ' '
              AND NVL(StdCodeR, ' ') = ' '
              AND NVL(PhoneNoR, ' ') = ' '
              AND NVL(MobileNo, ' ') = ' '
              AND NVL(StdCodeO, ' ') = ' ';
            --WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filname,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadOtherOwnerDetail 
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
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(SrNo, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
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
            UPDATE UploadOtherOwnerDetail V
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
              FROM UploadOtherOwnerDetail 
              GROUP BY SrNo

               HAVING COUNT(SrNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadOtherOwnerDetail V
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
                                        FROM UploadOtherOwnerDetail 
                                          GROUP BY SrNo

                                           HAVING COUNT(SrNo)  > 1 )
            ;
            END IF;
            IF utils.object_id('SystemCollateralIDData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE SystemCollateralIDData';

            END;
            END IF;
            DELETE FROM SystemCollateralIDData;
            UTILS.IDENTITY_RESET('SystemCollateralIDData');

            INSERT INTO SystemCollateralIDData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY SystemCollateralID ORDER BY SystemCollateralID  ) ROW_  ,
                               SystemCollateralID 
                        FROM UploadOtherOwnerDetail  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_SystemCollateralIDCnt
              FROM UploadOtherOwnerDetail A
                     LEFT JOIN CollateralMgmt B   ON A.SystemCollateralID = B.CollateralID
             WHERE  B.CollateralID IS NULL;
            SELECT COUNT(*)  

              INTO v_SystemCollateralIDMgmtCnt
              FROM UploadOtherOwnerDetail A
                     LEFT JOIN CollateralMgmt_Mod B   ON A.SystemCollateralID = B.CollateralID
             WHERE  B.CollateralID IS NULL;
            IF ( v_SystemCollateralIDCnt > 0
              OR v_SystemCollateralIDMgmtCnt > 0 ) THEN

            BEGIN
               UPDATE UploadOtherOwnerDetail V
                  SET A.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'System Collateral ID cannot be blank . Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'System Collateral ID cannot be blank . Please check the values and upload again'
                         END,
                      A.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'System CollateralID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'System CollateralID'
                         END,
                      A.Srnooferroneousrows = V.SrNo
                WHERE  NVL(SystemCollateralID, ' ') = ' '
                 AND V.SystemCollateralID IN ( SELECT A.SystemCollateralID 
                                               FROM UploadOtherOwnerDetail A
                                                      LEFT JOIN CollateralMgmt B   ON A.SystemCollateralID = B.CollateralID
                                                WHERE  B.CollateralID IS NULL )
               ;
               UPDATE UploadOtherOwnerDetail V
                  SET A.ErrorMessage = CASE 
                                            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'System Collateral ID cannot be blank . Please check the values and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'System Collateral ID cannot be blank . Please check the values and upload again'
                         END,
                      A.ErrorinColumn = CASE 
                                             WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'System CollateralID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'System CollateralID'
                         END,
                      A.Srnooferroneousrows = V.SrNo
                WHERE  NVL(SystemCollateralID, ' ') = ' '
                 AND V.SystemCollateralID IN ( SELECT A.SystemCollateralID 
                                               FROM UploadOtherOwnerDetail A
                                                      LEFT JOIN CollateralMgmt_Mod B   ON A.SystemCollateralID = B.CollateralID
                                                WHERE  B.CollateralID IS NULL )
               ;

            END;
            END IF;
            -------------------------------------------------------------------
            /*validations on Customer of the Bank*/
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer of the Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer of the Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomeroftheBank, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer of the Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer of the Bank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomeroftheBank, ' ') NOT IN ( 'Y','N' )
            ;
            IF utils.object_id('CustomerIDData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE CustomerIDData';

            END;
            END IF;
            DELETE FROM CustomerIDData;
            UTILS.IDENTITY_RESET('CustomerIDData');

            INSERT INTO CustomerIDData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CustomerID ORDER BY CustomerID  ) ROW_  ,
                               CustomerID 
                        FROM UploadOtherOwnerDetail  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_CustomerID
              FROM CustomerIDData a
                     JOIN CustomerBasicDetail b   ON a.CustomerID = b.CustomerID
             WHERE  b.CustomerID IS NULL;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is blank. Kindly update and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID is blank. Kindly update and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomerID, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine1, ' ') LIKE '%- \ / _%';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is mandatory, since other owner is customer of the Bank. Kindly update and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID is mandatory, since other owner is customer of the Bank. Kindly update and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomerID, ' ') = ' '
              AND NVL(CustomeroftheBank, ' ') = 'Y';
            IF v_CustomerID > 0 THEN
             UPDATE UploadOtherOwnerDetail V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is invalid. Kindly check the entered customer id'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID is invalid. Kindly check the entered customer id'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer IDD'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomerID, ' ') <> ' '
              AND V.CustomerID IN ( SELECT A.CustomerID 
                                    FROM CustomerIDData a
                                           JOIN CustomerBasicDetail b   ON A.CustomerID = b.CustomerID
                                     WHERE  b.CustomerID IS NULL )
            ;
            END IF;
            -----------------------------------------------------------------------------
            /*validations on Other Owner name */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Other Owner name cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Other Owner name cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Other Owner name'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Other Owner name'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(OtherOwnerName, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Other Owner name cannot be more than 100 Character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Other Owner name cannot be more than 100 Character . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Other Owner name'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Other Owner name'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(OtherOwnerName) > 100;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer of the Bank’. In case otherwise, display error message “Other Owner Name is mandatory, since other owner is not a customer of the Bank. Kindly update and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer of the Bank’. In case otherwise, display error message “Other Owner Name is mandatory, since other owner is not a customer of the Bank. Kindly update and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Other Owner name'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Other Owner name'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CustomerID, ' ') = ' '
              AND NVL(CustomeroftheBank, ' ') = 'N';
            IF utils.object_id('OtherOwnerRelationshipData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE OtherOwnerRelationshipData';

            END;
            END IF;
            DELETE FROM OtherOwnerRelationshipData;
            UTILS.IDENTITY_RESET('OtherOwnerRelationshipData');

            INSERT INTO OtherOwnerRelationshipData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY OtherOwnerRelationship ORDER BY OtherOwnerRelationship  ) ROW_  ,
                               OtherOwnerRelationship 
                        FROM UploadOtherOwnerDetail  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_CollateralOwnerType
              FROM OtherOwnerRelationshipData A
                     LEFT JOIN DimCollateralOwnerType B   ON A.OtherOwnerRelationship = B.CollOwnerDescription
             WHERE  B.CollOwnerDescription IS NULL;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Other Owner Relationship cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Other Owner Relationship cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Other Owner Relationship'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Other Owner Relationship'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(OtherOwnerRelationship, ' ') = ' ';
            IF v_CollateralOwnerType > 0 THEN

            BEGIN
               UPDATE UploadOtherOwnerDetail V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Other Owner Relationship’. Kindly enter the values as mentioned in the ‘Other Owner Relationship’ master and upload again. Click on ‘Download Master value’ to downloa


                                          d the valid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Other Owner Relationship’. Kindly enter the values as mentioned in the ‘Other Owner Relationship’ master and upload again. Click on ‘Download Master value’ to download the valid values for the




                       column'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Other Owner Relationship'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Other Owner Relationshipe'
                         END,
                      Srnooferroneousrows = V.SrNo
                      --	STUFF((SELECT ','+SRNO 
                       --							FROM #UploadNewAccount A
                       --							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
                       --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
                       ----AND SRNO IN(SELECT Srno FROM #DUB2))
                       --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))
                       --							FOR XML PATH ('')
                       --							),1,1,'')   

                WHERE  NVL(OtherOwnerRelationship, ' ') <> ' '
                 AND V.OtherOwnerRelationship IN ( SELECT A.OtherOwnerRelationship 
                                                   FROM OtherOwnerRelationshipData A
                                                          LEFT JOIN DimCollateralOwnerType B   ON A.OtherOwnerRelationship = B.CollOwnerDescription
                                                    WHERE  B.CollOwnerDescription IS NULL )
               ;

            END;
            END IF;
            -------------------------------------------------------------
            /*validations on If Relative, enter value */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'If Relative, enter value is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'If Relative, enter value is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Relative, enter value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Relative, enter value'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(Ifrelativeentervalue, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'If Relative, enter value is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'If Relative, enter value is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Relative, enter value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Relative, enter value'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(Ifrelativeentervalue) > 100;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN '’If Relative, enter value’ is mandatory, since value ‘Relative’ is entered in column ‘Other Owner Relationship’. Kindly update and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '’If Relative, enter value’ is mandatory, since value ‘Relative’ is entered in column ‘Other Owner Relationship’. Kindly update and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Relative, enter value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Relative, enter value'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(OtherOwnerRelationship, ' ') = 'Relative'
              AND NVL(Ifrelativeentervalue, ' ') = ' ';
            ----------------------------------------------------------------------
            /*validations on Address Type */
            ------------------------------------------------------------
            --UPDATE UploadOtherOwnerDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Address Type is blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Address Type is blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Address Type' ELSE   ErrorinColumn +','+SPACE(1)+'Address Type' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadOtherOwnerDetail V  
            --WHERE ISNULL(AddressType,'')=''
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Type is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Type is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Type'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(AddressType) > 200;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Address Type’. Kindly enter ‘Owned Leased or Rent’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Address Type’. Kindly enter ‘Owned Leased or Rent’ and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Type'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressType, ' ') NOT IN ( 'Owned','Leased','Rent',' ' )
            ;
            IF utils.object_id('AddressCategoryData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE AddressCategoryData';

            END;
            END IF;
            DELETE FROM AddressCategoryData;
            UTILS.IDENTITY_RESET('AddressCategoryData');

            INSERT INTO AddressCategoryData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY AddressCategory ORDER BY AddressCategory  ) ROW_  ,
                               AddressCategory 
                        FROM UploadOtherOwnerDetail  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_AddressCategoryCnt
              FROM AddressCategoryData A
                     LEFT JOIN DimAddressCategory B   ON A.AddressCategory = B.AddressCategoryName
             WHERE  B.AddressCategoryName IS NULL;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Category cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Category cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Category'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Category'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressCategory, ' ') = ' ';
            --Check
            IF v_AddressCategoryCnt > 0 THEN

            BEGIN
               UPDATE UploadOtherOwnerDetail V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Address Category’. Kindly enter the values as mentioned in the ‘Address Category’ master and upload again. Click on ‘Download Master value’ to download the valid valu
                                          es for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Address Category’. Kindly enter the values as mentioned in the ‘Address Category’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Category'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Category'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(AddressType, ' ') <> ' '
                 AND V.AddressType IN ( SELECT A.AddressCategory 
                                        FROM AddressCategoryData A
                                               LEFT JOIN DimAddressCategory B   ON A.AddressCategory = B.AddressCategoryName
                                         WHERE  B.AddressCategoryName IS NULL )
               ;

            END;
            END IF;
            -----------------------------------------------
            /*validations on Address Line 1 */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Line 1 cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Line 1 cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 1'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 1'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine1, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Line 1 is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Line 1 is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 1'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 1'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(AddressLine1) > 500;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try againn'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 1'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 1'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine1, ' ') LIKE '%- \ / _%';
            ----------------------------------------------------------------
            /*validations on Address Line 2 */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Line 2 cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Line 2 cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 2'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 2'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine2, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Line 2 is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Line 2 is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 2'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 2'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(AddressLine2) > 500;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 2'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 2'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine2, ' ') LIKE '%- \ / _%';
            -----------------------------------------------------------------------------
            /*validations on Address Line 3 */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Line 3 cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Line 3 cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 3'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 3'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine3, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Address Line 3 is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Address Line 3 is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 3'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 3'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(AddressLine3) > 500;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Address Line 3'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Address Line 3'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AddressLine3, ' ') LIKE '%- \ / _%';
            -----------------------------------------------------------------------------
            /*validations on City */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'City cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'City cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'City'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'City'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(City, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'City is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'City is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'City'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'City'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(City) > 50;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'City'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'City'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(City, ' ') LIKE '%- \ / _%';
            -----------------------------------------------------------------------------
            /*validations on PinCode */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PinCode cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PinCode cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PinCode'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PinCode'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(PinCode, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PinCode is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PinCode is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PinCode'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PinCode'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(PinCode) = 0
              AND NVL(PinCode, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(PinCode), '%^[0-9]%');
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN '‘Invalid Pincode, please check and upload again’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '‘Invalid Pincode, please check and upload again’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PinCode'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PinCode'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(PinCode) > 6
              AND INSTR(PinCode, '.') > 0;
            -----------------------------------------------------------------------------
            /*validations on Country  */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Country  cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Country  cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Country '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Country '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(Country, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Country  is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Country  is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Country '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Country '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(Country) > 100;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Country'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Country'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(Country, ' ') LIKE '%- \ / _%';
            -----------------------------------------------------------------------------
            /*validations on District  */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'District  cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'District  cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'District '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'District '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(District, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'District  is Invalid . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'District  is Invalid . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'District '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'District '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(District) > 100;
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are allowed, kindly remove and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Country'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Country'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(District, ' ') LIKE '%- \ / _%';
            -----------------------------------------------------------------------------
            /*validations on Std Code (O)  */
            ------------------------------------------------------------
            --UPDATE UploadOtherOwnerDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Std Code (O)  cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Std Code (O)  cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (O) ' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (O) ' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadOtherOwnerDetail V  
            --WHERE ISNULL(StdCodeO,'')=''
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid STD CODE (O), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid STD CODE (O), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Std Code (O) '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Std Code (O) '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(StdCodeO) = 0
              AND NVL(StdCodeO, ' ') <> ' ' );
            --AND ISNUMERIC(StdCodeO) LIKE '%^[0-9]%'
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid STD CODE (O), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid STD CODE (O), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Std Code (O)'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Std Code (O)'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( LENGTH(StdCodeO) < 3
              AND NVL(StdCodeO, ' ') <> ' ' );
            -----------------------------------------------------------------------------
            /*validations on Phone No (O)  */
            ------------------------------------------------------------
            --UPDATE UploadOtherOwnerDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Phone No (O)  cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Phone No (O)  cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (O) ' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (O) ' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadOtherOwnerDetail V  
            --WHERE ISNULL(PhoneNoO,'')=''
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Phone No (O), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Phone No (O), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Phone No (O) '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Phone No (O) '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(PhoneNoO) = 0
              AND NVL(PhoneNoO, ' ') <> ' ' );
            --AND ISNUMERIC(PhoneNoO) LIKE '%^[0-9]%'
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid STD CODE (O), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid STD CODE (O), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Std Code (O)'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Std Code (O)'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( LENGTH(PhoneNoO) < 10
              AND NVL(PhoneNoO, ' ') <> ' ' );
            -----------------------------------------------------------------------------
            /*validations on Std Code (R)  */
            ------------------------------------------------------------
            --UPDATE UploadOtherOwnerDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Std Code (R)  cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Std Code (R)  cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Std Code (R) ' ELSE   ErrorinColumn +','+SPACE(1)+'Std Code (R) ' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadOtherOwnerDetail V  
            --WHERE ISNULL(StdCodeR,'')=''
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Std Code (R), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Std Code (R), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Std Code (R) '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Std Code (R) '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(StdCodeR) = 0
              AND NVL(StdCodeR, ' ') <> ' ' );
            -- AND ISNUMERIC(StdCodeR) LIKE '%^[0-9]%'
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Std Code (R), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Std Code (R), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Std Code (R)'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Std Code (R)'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( LENGTH(StdCodeR) < 3
              AND NVL(StdCodeR, ' ') <> ' ' );
            -----------------------------------------------------------------------------
            /*validations on Phone No (R)  */
            ------------------------------------------------------------
            --UPDATE UploadOtherOwnerDetail
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Phone No (R) cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Phone No (R)  cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Phone No (R) ' ELSE   ErrorinColumn +','+SPACE(1)+'Phone No (R) ' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadOtherOwnerDetail V  
            --WHERE ISNULL(PhoneNoR,'')=''
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Phone No (R), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Phone No (R), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Phone No (R) '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Phone No (R) '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(PhoneNoR) = 0
              AND NVL(PhoneNoR, ' ') <> ' ' );
            --AND ISNUMERIC(PhoneNoR) LIKE '%^[0-9]%'
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Phone No (R), please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Phone No (R), please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Phone No (R)'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Phone No (R)'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( LENGTH(PhoneNoR) < 10
              AND NVL(PhoneNoR, ' ') <> ' ' );
            -----------------------------------------------------------------------------
            /*validations on Mobile No.  */
            ------------------------------------------------------------
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Mobile No. cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Mobile No.  cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Mobile No. '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Mobile No. '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(MobileNo, ' ') = ' ';
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Mobile No., please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Mobile No., please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Mobile No. '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Mobile No. '
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(MobileNo) = 0
              AND NVL(MobileNo, ' ') <> ' ' );
            -- AND ISNUMERIC(MobileNo) LIKE '%^[0-9]%'
            UPDATE UploadOtherOwnerDetail V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Mobile No., please check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Mobile No., please check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Mobile No.'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Mobile No.'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( LENGTH(MobileNo) < 10
              AND NVL(MobileNo, ' ') <> ' ' );
            -----------------------------------------------------------------------------
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
                                FROM CollateralOthOwnerDetails_stg 
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
                FROM UploadOtherOwnerDetail  );
            --	----SELECT * FROM UploadOtherOwnerDetail 
            --	--ORDER BY ErrorMessage,UploadOtherOwnerDetail.ErrorinColumn DESC
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
                                      AND NVL(ERRORDATA, ' ') <> ' '
                                      AND NVL(ERRORDATA, ' ') <> 'No Record found' );
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
                               FROM CollateralOthOwnerDetails_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('1');
               DELETE CollateralOthOwnerDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE('2');
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.CollateralOthOwnerDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadOtherOwnerDetail
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALOTHEROWNERUPLOAD_04122023" TO "ADF_CDR_RBL_STGDB";
