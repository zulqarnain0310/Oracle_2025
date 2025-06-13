--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" 
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
--@MenuID INT=128,  
--@UserLoginId varchar(20)='test_two',  
--@Timekey int=49999
--,@filepath varchar(500)='CustlevelNPAMOCUpload.xlsx'  

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
         --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
         --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)  
         SELECT Timekey 

           INTO v_Timekey
           FROM SysDataMatrix 
          WHERE  MOC_Initialised = 'Y'
                   AND NVL(MOC_Frozen, 'N') = 'N';
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
         IF ( v_MenuID = 128 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on Sl. No.*/
            ------------------------------------------------------------
            v_DuplicateCnt NUMBER(10,0) := 0;
            ----------------------------------------------
            /*VALIDATIONS ON CustomerID */
            ------------------------------------------------------------
            v_Count NUMBER(10,0);
            v_I NUMBER(10,0);
            v_Entity_Key NUMBER(10,0);
            v_RefCustomerID VARCHAR2(100) := ' ';
            v_CustomerIDFound NUMBER(10,0) := 0;
            v_DuplicateCustomerCnt NUMBER(10,0) := 0;
            v_DuplicateAssetClassInt NUMBER(10,0) := 0;
            -----------------------------------------------------------------
            -------------MOCSource--------------------
            v_ValidSourceInt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadCustMocUpload') IS NOT NULL  
            IF utils.object_id('UploadCustMocUpload') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadCustMocUpload';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM CustlevelNPAMOCDetails_stg 
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
                 ( SELECT 0 SlNo  ,
                          ' ' ColumnName  ,
                          'No Record found' ErrorData  ,
                          'No Record found' ErrorType  ,
                          v_filepath ,
                          'SUCCESS' 
                     FROM DUAL  );
               --SELECT 0 SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
               GOTO errordata;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DATA PRESENT');
               DELETE FROM UploadCustMocUpload;
               UTILS.IDENTITY_RESET('UploadCustMocUpload');

               INSERT INTO UploadCustMocUpload SELECT * ,
                                                      UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                      UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                      UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM CustlevelNPAMOCDetails_stg 
                   WHERE  filname = v_FilePathUpload;
               MERGE INTO A 
               USING (SELECT A.ROWID row_id, B.SourceAlt_Key
               FROM A ,UploadCustMocUpload A
                      JOIN DIMSOURCEDB B   ON A.SourceSystem = B.SourceName ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET A.SourceAlt_Key = src.SourceAlt_Key;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            ----SELECT * FROM UploadCustMocUpload
            --SlNo	Territory	ACID	InterestReversalAmount	filename
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'Sl.No.,Customer ID,AssetClass,NPADate,SecurityValue,AdditionalProvision%,MOCSource,MOCType,MOCReason',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') = ' '
              AND NVL(CustomerID, ' ') = ' '
              AND NVL(AssetClass, ' ') = ' '
              AND NVL(NPADate, ' ') = ' '
              AND NVL(SecurityValue, ' ') = ' '
              AND NVL(AdditionalProvision, ' ') = ' '
              AND NVL(MOCSource, ' ') = ' '
              AND NVL(MOCType, ' ') = ' '
              AND NVL(MOCReason, ' ') = ' ';
            --WHERE ISNULL(V.SlNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filename,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadCustMocUpload 
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
            MERGE INTO UploadCustMocUpload V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID not existing with Source System; Please check and upload again.'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID not existing with Source System; Please check and upload again.'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SourceSystem/CustomerID'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SourceSystem/CustomerID'
               END AS pos_3, V.CustomerID
            FROM UploadCustMocUpload V
                   LEFT JOIN CustomerBasicDetail B   ON V.SourceAlt_Key = B.SourceSystemAlt_Key
                   AND V.CustomerID = B.CustomerID 
             WHERE ( NVL(B.SourceSystemAlt_Key, 0) = 0
              OR NVL(B.CustomerID, ' ') = ' ' )) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.CustomerID;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') = ' '
              OR NVL(SlNo, '0') = '0';
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(SlNo) > 16;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(SlNo) = 0
              AND NVL(SlNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SlNo), '%^[0-9]%');
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(SlNo, ' '), '%[,!@#$%^&*()_-+=/]%- \ / _');
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM UploadCustMocUpload 
              GROUP BY SlNo

               HAVING COUNT(SlNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadCustMocUpload V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Sl. No., kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') IN ( SELECT SlNo 
                                        FROM UploadCustMocUpload 
                                          GROUP BY SlNo

                                           HAVING COUNT(SlNo)  > 1 )
            ;
            END IF;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘Customer ID’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘Customer ID’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadCustMocUpload A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadCustMocUpload V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CustomerID, ' ') = ' ';
            -------
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - \ / _. are allowed , Kindly remove and upload again '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - \ / _. are allowed , Kindly remove and upload again '
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerId'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerId'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(CustomerId, ' '), '%[,!@#$%^&*()+=]%');
            IF utils.object_id('TempDB..tt_tmp_29') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp_29 ';
            END IF;
            DELETE FROM tt_tmp_29;
            UTILS.IDENTITY_RESET('tt_tmp_29');

            INSERT INTO tt_tmp_29 ( 
            	SELECT CustomerID 
            	  FROM UploadCustMocUpload  );
            SELECT COUNT(A.CustomerId)  

              INTO v_CustomerIDFound
              FROM tt_tmp_29 B
                     LEFT JOIN CustomerBasicDetail A   ON A.CustomerId = B.CustomerID
                     AND A.EffectiveFromTimeKey <= v_TimeKey
                     AND A.EffectiveToTimeKey >= v_TimeKey
             WHERE  A.CustomerID IS NULL;
            IF v_CustomerIDFound > 0 THEN

            BEGIN
               UPDATE UploadCustMocUpload
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN ' Customer ID is invalid. Kindly check the entered  Customer ID '
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Customer ID is invalid. Kindly check the entered  Customer ID '
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                         END
                WHERE  Entity_Key = v_Entity_Key;

            END;
            END IF;
            SELECT COUNT(1)  

              INTO v_DuplicateCustomerCnt
              FROM UploadCustMocUpload 
              GROUP BY CustomerID

               HAVING COUNT(CustomerID)  > 1;
            IF ( v_DuplicateCustomerCnt > 0 ) THEN

            BEGIN
               UPDATE UploadCustMocUpload V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Duplicate Customer ID., kindly check and upload again'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Customer ID., kindly check and upload again'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Customer ID'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Customer ID'
                         END,
                      Srnooferroneousrows = V.SlNo
                WHERE  NVL(CustomerID, ' ') IN ( SELECT CustomerID 
                                                 FROM UploadCustMocUpload 
                                                   GROUP BY CustomerID

                                                    HAVING COUNT(CustomerID)  > 1 )
               ;

            END;
            END IF;
            -- ----SELECT * FROM UploadCustMocUpload
            UPDATE UploadCustMocUpload V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerId'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.CustomerID, ' ') <> ' '
              AND V.CustomerID IN ( SELECT CustomerId 
                                    FROM CustomerLevelMOC_Mod A
                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey
                                              AND NVL(ScreenFlag, ' ') <> 'U'
                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
             )
            ;
            UPDATE UploadCustMocUpload V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC Upload – Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Customer ID. Kindly authorize or Reject the record through ‘Customer Level MOC Upload – Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.CustomerID, ' ') <> ' '
              AND V.CustomerID IN ( SELECT CustomerId 
                                    FROM CustomerLevelMOC_Mod A
                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey
                                              AND NVL(ScreenFlag, ' ') = 'U'
                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )
             )
            ;
            --UPDATE UploadCustMocUpload
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for an Account ID' + CONVERT(VARCHAR(30),Y.CustomerAcID)+ ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC Upload – Authorization’ menuu'     
            --						ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for an Account ID' + CONVERT(VARCHAR(30),Y.CustomerAcID)+ ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC Upload– Authorization’ menuu'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
            --		,Srnooferroneousrows=V.SlNo
            --		FROM UploadCustMocUpload V  
            --		INNER Join PRO.CustomerCal_Hist Z On V.CustomerID=Z.RefCustomerID
            --	    INNER Join PRO.AccountCal_Hist Y on Y.CustomerEntityID=Z.CustomerEntityID
            --		WHERE ISNULL(V.CustomerId,'')<>''
            -- AND V.CustomerId  IN (
            -- Select F.RefCustomerID from AccountLevelMOC_mod A
            --  INNER Join PRO.AccountCal_Hist F on A.AccountID=F.CustomerACID
            --INNER join PRO.CustomerCal_Hist B On F.CustomerEntityId=B.CustomerEntityID
            --Where A.EntityKey in   (
            --                         SELECT MAX(EntityKey)
            --                         FROM AccountLevelMOC_mod
            --                         WHERE EffectiveFromTimeKey <= @TimeKey
            --                               AND EffectiveToTimeKey >= @TimeKey
            --                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
            --							    And MOCSource<>'U'
            --                         GROUP BY AccountID
            --                     ))
            ----------------------------------------------
            --IF OBJECT_ID('TEMPDB..#DupCustomerid') IS NOT NULL
            --DROP TABLE #DupCustomerid
            --SELECT * INTO #DupCustomerid FROM(
            --SELECT *,ROW_NUMBER() OVER(PARTITION BY SlNo ORDER BY Customerid ) as rw  FROM UploadCustMocUpload
            --)X
            --WHERE rw>1
            --UPDATE V
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Customerid found. Kindly check and upload again'     
            --					ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Customerid found. Kindly check and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Customerid' ELSE V.ErrorinColumn +','+SPACE(1)+  'Customerid' END  
            --	,Srnooferroneousrows=V.SlNo
            --	FROM UploadCustMocUpload V 
            --	INNer JOIN #DupCustomerid D ON D.DupCustomerid=V.DupCustomerid
            ---- ----SELECT * FROM UploadCustMocUpload
            -- comment due to forchange field 21062021 as discuused with Jaydev/Akshay/Anuj
            /*validations on AssetClass */
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Asset Class or gretaer than 16 character,  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Asset Class or gretaer than 16 character,  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AssetClass'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AssetClass'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(AssetClass, ' ') <> ' '
              AND LENGTH(AssetClass) > 16;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - \ / _. are allowed , Kindly remove and upload again '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - \ / _. are allowed , Kindly remove and upload again '
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AssetClass'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AssetClass'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(AssetClass, ' '), '%[,!@#$%^&*()+=]%');
            IF utils.object_id('AssetClassData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE AssetClassData';

            END;
            END IF;
            IF utils.object_id('AssetClassValidationData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE AssetClassValidationData';

            END;
            END IF;
            DELETE FROM AssetClassValidationData;
            UTILS.IDENTITY_RESET('AssetClassValidationData');

            INSERT INTO AssetClassValidationData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY B.CustomerID ORDER BY B.CustomerID  ) ROW_  ,
                               B.CustomerID ,
                               C.AssetClassName AssetClassOrg  ,
                               B.AssetClass AssetClassUpload  
                        FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                               JOIN UploadCustMocUpload B   ON A.RefCustomerID = B.CustomerID
                               JOIN DimAssetClass C   ON A.SysAssetClassAlt_Key = C.AssetClassAlt_Key
                         WHERE  A.EffectiveFromTimeKey <= v_Timekey
                                  AND A.EffectiveToTimeKey >= v_Timekey ) X
                WHERE  ROW_ = 1;
            DELETE FROM AssetClassData;
            UTILS.IDENTITY_RESET('AssetClassData');

            INSERT INTO AssetClassData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY AssetClass ORDER BY AssetClass  ) ROW_  ,
                               AssetClass 
                        FROM UploadCustMocUpload  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DuplicateAssetClassInt
              FROM AssetClassData A
                     LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassName
             WHERE  B.AssetClassName IS NULL;
            IF v_DuplicateAssetClassInt > 0 THEN

            BEGIN
               UPDATE UploadCustMocUpload V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Asset Class’. Kindly enter the values as mentioned in the ‘Asset Class’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Asset Class’. Kindly enter the values as mentioned in the ‘Asset Class’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Asset Class'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Asset Class'
                         END,
                      Srnooferroneousrows = V.SlNo
                WHERE  NVL(AssetClass, ' ') <> ' '
                 AND V.AssetClass IN ( SELECT A.AssetClass 
                                       FROM AssetClassData A
                                              LEFT JOIN DimAssetClass B   ON A.AssetClass = B.AssetClassName
                                        WHERE  B.AssetClassName IS NULL )
               ;

            END;
            END IF;
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            -- UPDATE UploadCustMocUpload
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You have AssetClass STANDARD and You can change it only SUB-STANDARD. '     
            --					ELSE ErrorMessage+','+SPACE(1)+'You have AssetClass STANDARD and You can change it only SUB-STANDARD '    END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END   
            --	,Srnooferroneousrows=V.SlNo
            --  FROM UploadCustMocUpload V 
            --WHERE V.CustomerID IN(Select B.CustomerID
            --		  FROM AssetClassValidationData B					
            --		    WHERE (Case When ISNULL(B.AssetClassOrg,'') ='STANDARD' AND ISNULL(B.AssetClassUpload,'') NOT IN('SUB-STANDARD','','STANDARD') Then 1
            --              Else 0 END)=1)
            --   UPDATE UploadCustMocUpload
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You have AssetClass SUB-STANDARD and You can change it only STANDARD,DOUBTFUL I,LOS '     
            --					ELSE ErrorMessage+','+SPACE(1)+'You have AssetClass SUB-STANDARD and You can change it only STANDARD,DOUBTFUL I,LOS. '    END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END   
            --	,Srnooferroneousrows=V.SlNo
            --   FROM UploadCustMocUpload V 
            -- WHERE V.CustomerID IN(Select B.CustomerID
            --		  FROM AssetClassValidationData B					
            --		    WHERE (Case When ISNULL(AssetClassOrg,'') ='SUB-STANDARD' AND ISNULL(AssetClassUpload,'') NOT IN('STANDARD','DOUBTFUL I','LOS','SUB-STANDARD') Then 1
            --				 Else 0 END)=1
            --				 )
            --------------NPADATE-----------------------
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADATE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADATE'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  utils.isdate(NPADATE) = 0
              AND NVL(NPADATE, ' ') <> ' ';
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'NPA Date is mandatory since ‘Asset class’ is set as NPA. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'NPA Date is mandatory since ‘Asset class’ is set as NPA. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADATE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADATE'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(AssetClass, ' ') IN ( 'NPA' )

              AND (NPADATE) = ' ';
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'NPA Date must be blank since ‘Asset class’ is STD. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'NPA Date must be blank since ‘Asset class’ is STD. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADATE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADATE'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( NVL(AssetClass, ' ') IN ( 'STANDARD' )

              OR NVL(AssetClass, ' ') IS NULL )
              AND (NPADATE) <> ' ';
            /*TODO:SQLDEV*/ Set DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'NPA date must be less than equal to current date. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'NPA date must be less than equal to current date. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADATE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADATE'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  (CASE 
                          WHEN utils.isdate(NPADATE) = 1 THEN CASE 
                                                                   WHEN UTILS.CONVERT_TO_VARCHAR2(NPADATE,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'NPA Date is mandatory  since ‘Asset class’ is not STANDARD. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'NPA Date is mandatory  since ‘Asset class’ is not STANDARD. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADATE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADATE'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( NVL(AssetClass, ' ') NOT IN ( 'STANDARD',' ' )
             )
              AND (NPADATE) = ' ';
            --------------security value----------------
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Security value Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Security value Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Security value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Security value'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --						

             WHERE  NVL(Securityvalue, ' ') <> ' '
              AND ( INSTR(NVL(Securityvalue, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(Securityvalue, ' '), -LENGTH(NVL(Securityvalue, ' ')) - INSTR(NVL(Securityvalue, ' '), '.'), LENGTH(NVL(Securityvalue, ' ')) - INSTR(NVL(Securityvalue, ' '), '.'))) > 2 );
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in ‘Security Value’ column. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in ‘Security Value’ column. Kindly check and upload again '
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SecurityValue'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SecurityValue'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(Securityvalue) = 0
              AND NVL(Securityvalue, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(Securityvalue), '%^[0-9]%');
            --------------Additional Provision%-----------------
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Security value Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Security value Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Security value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Security value'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --						

             WHERE  NVL(Securityvalue, ' ') <> ' '
              AND ( INSTR(NVL(AdditionalProvision, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(AdditionalProvision, ' '), -LENGTH(NVL(AdditionalProvision, ' ')) - INSTR(NVL(AdditionalProvision, ' '), '.'), LENGTH(NVL(AdditionalProvision, ' ')) - INSTR(NVL(AdditionalProvision, ' '), '.'))) > 2 );
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --							

             WHERE  NVL(AdditionalProvision, ' ') <> ' '
              AND UTILS.CONVERT_TO_NUMBER(NVL(AdditionalProvision, '0'),5,2) > 100;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Additional Provision %’. Kindly check and upload again '
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision%'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision%'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(AdditionalProvision) = 0
              AND NVL(AdditionalProvision, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(AdditionalProvision), '%^[0-9]%');
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Additional Provision ’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Additional Provision ’. Kindly check and upload again '
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Additional Provision'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Additional Provision'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  (INSTR(AdditionalProvision, '.')) > 0;
            IF utils.object_id('MocSourceData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE MocSourceData';

            END;
            END IF;
            DELETE FROM MocSourceData;
            UTILS.IDENTITY_RESET('MocSourceData');

            INSERT INTO MocSourceData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY MOCSOURCE ORDER BY MOCSOURCE  ) ROW_  ,
                               MOCSOURCE 
                        FROM UploadCustMocUpload  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_ValidSourceInt
              FROM MocSourceData A
                     LEFT JOIN DimMOCType B   ON A.MOCSOURCE = B.MOCTypeName
             WHERE  B.MOCTypeName IS NULL
                      AND EffectiveFromTimeKey <= v_Timekey
                      AND EffectiveToTimeKey >= v_Timekey;
            IF v_ValidSourceInt > 0 THEN

            BEGIN
               UPDATE UploadCustMocUpload V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCSOURCE'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCSOURCE'
                         END,
                      Srnooferroneousrows = V.SlNo
                WHERE  NVL(MOCSOURCE, ' ') <> ' '
                 AND V.MOCSource IN ( SELECT A.MOCSOURCE 
                                      FROM MocSourceData A
                                             LEFT JOIN DimMOCType B   ON A.MOCSOURCE = B.MOCTypeName
                                       WHERE  B.MOCTypeName IS NULL
                                                AND EffectiveFromTimeKey <= v_Timekey
                                                AND EffectiveToTimeKey >= v_Timekey )
               ;

            END;
            END IF;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC source can not be blank,  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC source can not be blank,  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCSOURCE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCSOURCE'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(MOCSOURCE, ' ') = ' ';
            ---------------MOCType---------------------
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOCType is mandatory . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOCType is mandatory . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCType'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCType'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(MOCType, ' ') = ' ';
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCType'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCType'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(MOCType, ' ') NOT IN ( 'Auto','Manual' )
            ;
            ----------------MOCReason---------------------
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC Reason column is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC Reason column is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --FROM UploadCustMocUpload A
                    --WHERE A.SlNo IN(SELECT V.SlNo  FROM UploadCustMocUpload V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(MOCReason, ' ') = ' ';
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC reason cannot be greater than 500 characters'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC reason cannot be greater than 500 characters'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPADate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  LENGTH(MOCReason) > 500;
            UPDATE UploadCustMocUpload V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOC reason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOC reason'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadCustMocUpload A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadCustMocUpload V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(MOCReason, ' '), '%[!@#$%^&*()_+=]%');
            ----------------------------------------------
            /*validations on SourceSystem*/
            --    Declare @DuplicateSourceSystemDataInt int=0
            --	IF OBJECT_ID('SourceSystemData') IS NOT NULL  
            --	  BEGIN  
            --	   DROP TABLE SourceSystemData 
            --	  END
            --	   SELECT * into SourceSystemData  FROM(
            -- SELECT ROW_NUMBER() OVER(PARTITION BY SourceSystem  ORDER BY  SourceSystem ) 
            -- ROW ,SourceSystem FROM UploadCustMocUpload
            --)X
            -- WHERE ROW=1
            --  SELECT  @DuplicateSourceSystemDataInt=COUNT(*) FROM UploadCustMocUpload A
            -- Left JOIN DIMSOURCEDB B
            -- ON  A.SourceSystem=B.SourceName
            -- Where B.SourceName IS NULL
            --    IF @DuplicateSourceSystemDataInt>0
            --	BEGIN
            --	       UPDATE UploadCustMocUpload
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for theco
            --lumn'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
            --        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem' END     
            --		,Srnooferroneousrows=V.SlNo
            --		 FROM UploadCustMocUpload V  
            -- WHERE ISNULL(SourceSystem,'')<>''
            -- AND  V.SourceSystem IN(
            --                     SELECT  A.SourceSystem FROM UploadCustMocUpload A
            --					 Left JOIN DIMSOURCEDB B
            --					 ON  A.SourceSystem=B.SourceName
            --					 Where B.SourceName IS NULL
            --                 )
            --	END
            ------------------------------------------------------
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
                                FROM CustlevelNPAMOCDetails_stg 
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
              ( SELECT ' ' SlNo  ,
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
              ( SELECT SlNo ,
                       ErrorinColumn ,
                       ErrorMessage ,
                       ErrorinColumn ,
                       v_filepath ,
                       Srnooferroneousrows ,
                       'SUCCESS' 
                FROM UploadCustMocUpload  );
            --	----SELECT * FROM UploadCustMocUpload 
            --	--ORDER BY ErrorMessage,UploadCustMocUpload.ErrorinColumn DESC
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
                               FROM CustlevelNPAMOCDetails_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE CustlevelNPAMOCDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadCustMocUpload
         DBMS_OUTPUT.PUT_LINE('p');

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ------to delete file if it has errors
      --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
      --begin
      --print 'ppp'
      -- IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filename=@FilePathUpload)
      -- BEGIN
      -- print '123'
      -- DELETE FROM CustlevelNPAMOCDetails_stg
      -- WHERE filename=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- END
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filename=@FilePathUpload)
                 --	 BEGIN
                 --	 DELETE FROM CustlevelNPAMOCDetails_stg
                 --	 WHERE filename=@FilePathUpload
                 --	 PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                 ,--	 END
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CUSTMOCUPLOAD_26092023" TO "ADF_CDR_RBL_STGDB";
