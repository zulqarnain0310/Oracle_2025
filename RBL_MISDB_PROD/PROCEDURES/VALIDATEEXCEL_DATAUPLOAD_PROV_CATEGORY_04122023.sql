--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'ProvCategory.xlsx' 
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
         ----declare @UserLoginId  VARCHAR(20)='fnachecker' ,@filepath VARCHAR(MAX) ='ProvCategory.xlsx' 
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
         IF ( v_MenuID = 1468 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            v_ProvisionPercent NUMBER(10,0);

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadProCategory') IS NOT NULL  
            IF utils.object_id('UploadProCategory') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadProCategory';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT 1 
                                     FROM CategoryDetails_stg 
                                      WHERE  FilName = v_FilePathUpload ) );
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
                          ' ' ErrorData  ,
                          ' ' ErrorType  ,
                          v_filepath ,
                          'SUCCESS' 
                     FROM DUAL  );
               --SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS' 
               GOTO errordata;

            END;
            ELSE

            BEGIN
               DBMS_OUTPUT.PUT_LINE('DATA PRESENT');
               DELETE FROM UploadProCategory;
               UTILS.IDENTITY_RESET('UploadProCategory');

               INSERT INTO UploadProCategory SELECT * ,
                                                    UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                    UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                    UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM CategoryDetails_stg 
                   WHERE  FilName = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            ----SELECT * FROM UploadProCategory
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE UploadProCategory V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'SlNo,ACID,CustomerID,CategoryID,Action',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') = ' '
              AND NVL(ACID, ' ') = ' '
              AND NVL(CustomerID, ' ') = ' '
              AND NVL(CategoryID, ' ') = ' '
              AND NVL(ACTION, ' ') = ' ';
            -- ISNULL(PoolID,'')=''
            --AND ISNULL(PoolName,'')=''
            --AND ISNULL(PoolType,'')=''
            --AND ISNULL(AccountID,'')=''
            --AND ISNULL(CustomerID,'')=''
            --AND ISNULL(PrincipalOutstandinginRs,'')=''
            --AND ISNULL(InterestReceivableinRs,'')=''
            --AND ISNULL(OSBalanceinRs,'')=''
            --AND ISNULL(IBPCExposureinRs,'')=''
            --AND ISNULL(DateofIBPCreckoning,'')=''
            --AND ISNULL(DateofIBPCmarking,'')=''
            --AND ISNULL(MaturityDate,'')=''
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadProCategory 
                                WHERE  NVL(ErrorMessage, ' ') <> ' ' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('ACID');
               GOTO ERRORDATA;

            END;
            END IF;
            -------------------------------------
            -----validations on Srno
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Sr. No. cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Sr. No. cannot be blank.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = 'SRNO',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(v.SlNo, ' ') = ' ';
            --UPDATE UploadProCategory
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sr. No.  Please check the values and upload again'     
            --							  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Sr. No.  Please check the values and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SRNO' ELSE ErrorinColumn +','+SPACE(1)+  'SRNO' END     
            --	,Srnooferroneousrows=SlNo
            --FROM UploadProCategory V  
            --WHERE ISNULL(v.SlNo,'')=0   OR ISNULL(v.SlNo,'')<0
            DBMS_OUTPUT.PUT_LINE(123);
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sr. No.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sr. No.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SRNO'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SRNO'
                      END,
                   V.Srnooferroneousrows = SlNo
             WHERE  utils.isnumeric(v.SlNo) = 0;
            IF utils.object_id('TEMPDB..tt_R2_2') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_R2_2 ';
            END IF;
            DELETE FROM tt_R2_2;
            UTILS.IDENTITY_RESET('tt_R2_2');

            INSERT INTO tt_R2_2 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY SlNO ORDER BY SlNO  ) ROW_  
                        FROM UploadProCategory  ) A
                WHERE  ROW_ > 1;
            DBMS_OUTPUT.PUT_LINE('DUB');
            UPDATE UploadProCategory V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Following sr. no. are repeated'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Following sr. no. are repeated'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SRNO'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SRNO'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT DISTINCT ','+SRNO 
                    --FROM #UploadNewAccount
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  V.SlNo IN ( SELECT Slno 
                                FROM tt_R2_2  )
            ;
            ----------------------------------
            /*validations on ACID*/
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ACID cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ACID cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(ACID, ' ') = ' ';
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid ACID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid ACID.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ACID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ACID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(ACID, ' ') <> ' '
              AND LENGTH(ACID) > 20;
            UPDATE UploadProCategory V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --select *

             WHERE  NVL(V.ACID, ' ') <> ' '
              AND V.ACID NOT IN ( SELECT CustomerACID 
                                  FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                                   WHERE  EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
            ;
            IF utils.object_id('TEMPDB..tt_DUB2_24') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_24 ';
            END IF;
            DELETE FROM tt_DUB2_24;
            UTILS.IDENTITY_RESET('tt_DUB2_24');

            INSERT INTO tt_DUB2_24 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY ACID ORDER BY ACID  ) rw  
                        FROM UploadProCategory  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate Account ID found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Account ID found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'Account ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
               END AS pos_3, V.SlNo
            FROM V ,UploadProCategory V
                   JOIN tt_DUB2_24 D   ON D.ACID = V.ACID ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            /*validations on CustomerID*/
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CustomerID cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CustomerID cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(CustomerID, ' ') = ' ';
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CustomerID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CustomerID.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CustomerID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CustomerID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(CustomerID, ' ') <> ' '

              --AND LEN(CustomerID)>16

              --AND V.CustomerID NOT IN(SELECT CustomerID FROM [CurDat].[CustomerBasicDetail] 

              --						WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)
              AND V.CustomerID NOT IN ( SELECT RefCustomerId 
                                        FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                                               JOIN UploadProCategory V   ON A.CustomerACID = V.ACID
                                         WHERE  A.EffectiveFromTimeKey <= v_Timekey
                                                  AND A.EffectiveToTimeKey >= v_Timekey )
            ;
            /*validations on CategoryID*/
            IF utils.object_id('TEMPDB..tt_EXISTDATA_2') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_EXISTDATA_2 ';
            END IF;
            DELETE FROM tt_EXISTDATA_2;
            UTILS.IDENTITY_RESET('tt_EXISTDATA_2');

            INSERT INTO tt_EXISTDATA_2 ( 
            	SELECT A.ACID ,
                    MAX(D.ProvisionSecured)  ProvisionPercent  

            	  --,d.provisionname
            	  FROM CategoryDetails_stg A
                    --INNER JOIN AdvAcBasicDetail B
                     --			on B.CustomerAcId=A.acid

                      JOIN DimProvision_SegStd D   ON A.CategoryID = D.BankCategoryID
            	  GROUP BY A.ACID );
            ----select * from AcCatUploadHistory
            IF utils.object_id('TEMPDB..tt_EXISTDATA_21') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_EXISTDATA1_2 ';
            END IF;
            DELETE FROM tt_EXISTDATA1_2;
            UTILS.IDENTITY_RESET('tt_EXISTDATA1_2');

            INSERT INTO tt_EXISTDATA1_2 ( 
            	SELECT B.acid 
            	  FROM ( SELECT A.ACID ,
                             MAX(D.ProvisionSecured)  ProvisionPercent  
                      FROM AcCatUploadHistory A
                             JOIN DimProvision_SegStd D   ON A.CategoryID = D.BankCategoryID
                        GROUP BY A.ACID ) b
                      JOIN tt_EXISTDATA_2 E   ON b.ACID = E.ACID
            	 WHERE  b.ProvisionPercent > E.ProvisionPercent );
            MERGE INTO U 
            USING (SELECT U.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Category ID is Lowest . Please check the values and upload again'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CategoryID is Lowest. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CategoryID'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CategoryID'
               END AS pos_3, U.SlNo
            FROM U ,UploadProCategory U
                   JOIN tt_EXISTDATA1_2 E   ON U.ACID = E.ACID 
             WHERE U.Action = 'A') src
            ON ( U.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET U.ErrorMessage = pos_2,
                                         U.ErrorinColumn = pos_3,
                                         U.Srnooferroneousrows = src.SlNo;
            --select * from DimProvision_SegStd
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CategoryID cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CategoryID cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CategoryID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CategoryID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(CategoryID, ' ') = ' ';
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CategoryID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CategoryID.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CategoryID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CategoryID'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(CategoryID, ' ') <> ' '
              AND LENGTH(CategoryID) > 16;
            UPDATE UploadProCategory V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CategoryID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CategoryID.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CategoryID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CategoryID'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --select *


            --Inner Join DimProvision_SegStd A ON A.BankCategoryID=V.CategoryID
            WHERE  V.CategoryID NOT IN ( SELECT BankCategoryID 
                                         FROM DimProvision_SegStd A
                                          WHERE  A.BankCategoryID = V.CategoryID
                                                   AND A.EffectiveToTimeKey = 49999 )
            ;
            UPDATE UploadProCategory V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account has Already Same CategoryID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account has Already Same CategoryID.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CategoryID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CategoryID'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --select *


            --Inner Join DimProvision_SegStd A ON A.BankCategoryID=V.CategoryID

            --WHERE V.CategoryID  not in (select BankCategoryID  from DimProvision_SegStd A where A.BankCategoryID=V.CategoryID And A.EffectiveToTimeKey=49999)
            WHERE  EXISTS ( SELECT 1 
                            FROM AcCatUploadHistory A
                             WHERE  A.CategoryID = V.CategoryID
                                      AND A.ACID = V.ACID
                                      AND A.EffectiveToTimeKey = 49999
                                      AND NVL(A.AuthorisationStatus, 'A') = 'A'
                            UNION 
                            SELECT 1 
                            FROM AcCatUploadHistory_Mod B
                             WHERE  B.CategoryID = V.CategoryID
                                      AND B.ACID = V.ACID
                                      AND B.EffectiveToTimeKey = 49999
                                      AND NVL(B.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
             )
              AND V.Action = 'A';
            UPDATE UploadProCategory V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account has Not Marked in CategoryID.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account has Not Marked in CategoryID.  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CategoryID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CategoryID'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --select *


            --Inner Join DimProvision_SegStd A ON A.BankCategoryID=V.CategoryID

            --WHERE V.CategoryID  not in (select BankCategoryID  from DimProvision_SegStd A where A.BankCategoryID=V.CategoryID And A.EffectiveToTimeKey=49999)
            WHERE  NOT EXISTS ( SELECT 1 
                                FROM AcCatUploadHistory A
                                 WHERE  A.CategoryID = V.CategoryID
                                          AND A.ACID = V.ACID
                                          AND A.EffectiveToTimeKey = 49999
                                          AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                UNION 
                                SELECT 1 
                                FROM AcCatUploadHistory_Mod B
                                 WHERE  B.CategoryID = V.CategoryID
                                          AND B.ACID = V.ACID
                                          AND B.EffectiveToTimeKey = 49999
                                          AND NVL(B.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
             )
              AND V.Action = 'R';
            /*validations on Action*/
            UPDATE UploadProCategory V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Action.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Action.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Action'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Action'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  V.Action NOT IN ( 'A','R' )

              AND LENGTH(ACTION) = 1;
            --IF OBJECT_ID('TEMPDB..tt_DUB2_24') IS NOT NULL
            --DROP TABLE tt_DUB2_24
            --SELECT * INTO tt_DUB2_24 FROM(
            --SELECT *,ROW_NUMBER() OVER(PARTITION BY ACID ORDER BY ACID ) ROW FROM UploadProCategory
            --)X
            --WHERE ROW>1
            DBMS_OUTPUT.PUT_LINE('123');
            GOTO valid;

         END;
         END IF;
         <<ErrorData>>
         -- print 'no'  
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
                                FROM CategoryDetails_stg 
                                 WHERE  FilName = v_FilePathUpload );
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
            --(SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag) 

              ( ColumnName, ErrorData, ErrorType, FileNames, Srnooferroneousrows, Flag )
              ( SELECT --SlNo,
                 ErrorinColumn ,
                 ErrorMessage ,
                 ErrorinColumn ,
                 v_filepath ,
                 Srnooferroneousrows ,
                 'SUCCESS' 
                FROM UploadProCategory  );
            DBMS_OUTPUT.PUT_LINE('VALIDATION ERRORS1');
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
            DBMS_OUTPUT.PUT_LINE('Delete Upload status');
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
            DBMS_OUTPUT.PUT_LINE('UpdaTE Upload status');
            UPDATE UploadStatus
               SET ValidationOfData = 'Y',
                   ValidationOfDataCompletedOn = SYSDATE
             WHERE  FileNames = v_filepath;

         END;
         END IF;
         <<final>>
         DBMS_OUTPUT.PUT_LINE('vj');
         DBMS_OUTPUT.PUT_LINE(v_filepath);
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
                 ORDER BY SR_No ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CategoryDetails_stg 
                                WHERE  FilName = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE CategoryDetails_stg

                WHERE  FilName = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.AcCatUploadHistory_Stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadProCategory
         DBMS_OUTPUT.PUT_LINE('p');

      END;
   EXCEPTION
      WHEN OTHERS THEN

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

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_PROV_CATEGORY_04122023" TO "ADF_CDR_RBL_STGDB";
