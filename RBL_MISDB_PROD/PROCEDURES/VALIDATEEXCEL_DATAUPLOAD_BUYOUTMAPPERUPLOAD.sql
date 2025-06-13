--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" 
(
  v_MenuID IN NUMBER DEFAULT 24748 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'lvl1sa' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'UploadBuyoutMapper (7).xlsx' ,
  v_yesno IN VARCHAR2 DEFAULT 'YES' ,
  iv_MissingAcc IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_MissingAcc VARCHAR2(4000) := iv_MissingAcc;
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
         IF ( v_MenuID = 24748 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            /*validations on Scheme*/
            v_DuplicateSchemeInt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..#UploadBuyoutMapper') IS NOT NULL  
            --BEGIN  
            -- DROP TABLE #UploadBuyoutMapper  
            --END
            IF utils.object_id('UploadBuyoutMapper') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadBuyoutMapper';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM Buyoutaccountmapper_stg 
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
               DELETE FROM UploadBuyoutMapper;
               UTILS.IDENTITY_RESET('UploadBuyoutMapper');

               INSERT INTO UploadBuyoutMapper SELECT * ,
                                                     UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                     UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                     UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM Buyoutaccountmapper_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            --select * from BuyoutDetails_stg
            ----SELECT * FROM UploadBuyoutMapper
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'SlNo,AccountNoinRBLHostSystem,AccountNoofSeller,SchemeCode',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') = ' '
              AND NVL(AccountNoinRBLHostSystem, ' ') = ' '
              AND NVL(AccountNoofSeller, ' ') = ' '
              AND NVL(SchemeCode, ' ') = ' ';
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UploadBuyoutMapper 
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
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = 'SRNO',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(v.SlNo, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('1');
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SlNo, kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SlNo, kindly check and upload again'
                      END,
                   V.ErrorinColumn = 'SRNO',
                   V.Srnooferroneousrows = SlNo
             WHERE  ( utils.isnumeric(SlNo) = 0
              AND NVL(SlNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SlNo), '%^[0-9]%')
              OR NVL(v.SlNo, ' ') <= 0;
            IF utils.object_id('TEMPDB..tt_R') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_R ';
            END IF;
            DELETE FROM tt_R;
            UTILS.IDENTITY_RESET('tt_R');

            INSERT INTO tt_R SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY SlNo ORDER BY SlNo  ) ROW_  
                        FROM UploadBuyoutMapper  ) A
                WHERE  ROW_ > 1;
            DBMS_OUTPUT.PUT_LINE('DUB');
            UPDATE UploadBuyoutMapper V
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
                    --						FROM UploadBuyoutMapper
                    --						FOR XML PATH ('')
                    --						),1,1,'')

             WHERE  V.SlNo IN ( SELECT SlNo 
                                FROM tt_R  )
            ;
            DBMS_OUTPUT.PUT_LINE('3');
            UPDATE UploadBuyoutMapper V
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
            UPDATE UploadBuyoutMapper V
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
                        FROM UploadBuyoutMapper  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_DuplicateSchemeInt
              FROM UploadBuyoutMapper A
                     LEFT JOIN DimBuyoutSchemeCode B   ON A.SchemeCode = B.SchemeCode
             WHERE  B.SchemeCode IS NULL;
            IF v_DuplicateSchemeInt > 0 THEN

            BEGIN
               UPDATE UploadBuyoutMapper V
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
                                       FROM UploadBuyoutMapper A
                                              LEFT JOIN DimBuyoutSchemeCode B   ON A.SchemeCode = B.SchemeCode
                                        WHERE  B.SchemeCode IS NULL )
               ;

            END;
            END IF;
            /*VALIDATIONS ON AccountNoinRBLHostSystem */
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘AccountNoinRBLHostSystem’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘AccountNoinRBLHostSystem’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(AccountNoinRBLHostSystem, ' ') = ' ';
            -- ----SELECT * FROM UploadBuyoutMapper
            UPDATE UploadBuyoutMapper V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AccountNoinRBLHostSystem found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AccountNoinRBLHostSystem found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.AccountNoinRBLHostSystem, ' ') <> ' '
              AND V.AccountNoinRBLHostSystem NOT IN ( SELECT CustomerACID 
                                                      FROM AdvAcBasicDetail 
                                                       WHERE  EffectiveFromTimeKey <= v_Timekey
                                                                AND EffectiveToTimeKey >= v_Timekey )
            ;
            MERGE INTO UploadBuyoutMapper V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid SchemeCode mapped with AccountNoinRBLHostSystem. Please check the values and upload again'
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid SchemeCode mapped with AccountNoinRBLHostSystem. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
               END AS pos_3, V.SlNo
            FROM UploadBuyoutMapper V
                   RIGHT JOIN AdvAcBasicDetail B   ON V.AccountNoinRBLHostSystem = B.CustomerACID
                   LEFT JOIN DimProduct C   ON V.SchemeCode = C.ProductCode
                   AND B.ProductAlt_Key = C.ProductAlt_Key 
             WHERE B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey
              AND V.SchemeCode IS NOT NULL
              AND C.ProductCode IS NULL) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET V.ErrorMessage = pos_2,
                                         V.ErrorinColumn = pos_3,
                                         V.Srnooferroneousrows = src.SlNo;
            IF utils.object_id('TEMPDB..tt_DUB2_12') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_12 ';
            END IF;
            DELETE FROM tt_DUB2_12;
            UTILS.IDENTITY_RESET('tt_DUB2_12');

            INSERT INTO tt_DUB2_12 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountNoinRBLHostSystem ORDER BY AccountNoinRBLHostSystem  ) rw  
                        FROM UploadBuyoutMapper  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate AccountNoinRBLHostSystem found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate AccountNoinRBLHostSystem found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
               END AS pos_3, V.SlNo
            FROM V ,UploadBuyoutMapper V
                   JOIN tt_DUB2_12 D   ON D.AccountNoinRBLHostSystem = V.AccountNoinRBLHostSystem ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SlNo;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record for AccountNoinRBLHostSystem  is pending for authorization in ‘Upload ID’ ' || UTILS.CONVERT_TO_VARCHAR2(B.UploadID,10) || ' kindly remove the record and upload again '
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Record for AccountNoinRBLHostSystem  is pending for authorization in ‘Upload ID’ ' || UTILS.CONVERT_TO_VARCHAR2(B.UploadID,10) || ' kindly remove the record and upload again '
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
               END AS pos_3, V.SlNo
            FROM V ,UploadBuyoutMapper V
                   LEFT JOIN BuyoutMapperUpload_Mod B   ON V.AccountNoinRBLHostSystem = B.AccountNoinRBLHostSystem
                 --LEFT Join CollateralDetailUpload_Mod C ON V.AssetID=C.AssetID						

             WHERE B.AuthorisationStatus IN ( 'NP','MP','FM','RM','1A' )

              AND ( B.AccountNoinRBLHostSystem IS NOT NULL )) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SlNo;
            IF utils.object_id('TEMPDB..tt_MissingAcc') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MissingAcc ';
            END IF;
            DELETE FROM tt_MissingAcc;
            UTILS.IDENTITY_RESET('tt_MissingAcc');

            INSERT INTO tt_MissingAcc ( 
            	SELECT * 
            	  FROM ( SELECT 1 SrNo  ,
                             C.ProductCode ,
                             B.CustomerACID AccountID  
                      FROM AdvAcBasicDetail B
                             LEFT JOIN UploadBuyoutMapper A   ON A.AccountNoinRBLHostSystem = B.CustomerACID
                             LEFT JOIN DimProduct C   ON B.ProductAlt_Key = C.ProductAlt_Key

                             --AND A.SchemeCode= C.ProductCode 
                             AND C.EffectiveFromTimeKey <= v_Timekey
                             AND C.EffectiveToTimeKey >= v_Timekey
                       WHERE  B.EffectiveFromTimeKey <= v_Timekey
                                AND B.EffectiveToTimeKey >= v_Timekey
                                AND A.AccountNoinRBLHostSystem IS NULL
                                AND C.ProductCode IN ( SELECT SchemeCode 
                                                       FROM UploadBuyoutMapper  )
                     ) x );
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT EXISTS ( SELECT 1 
                                   FROM UploadBuyoutMapper 
                                    WHERE  ErrorMessage LIKE '%Invalid SchemeCode%' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM tt_MissingAcc  );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  IF v_yesno = 'YES' THEN
                   DECLARE
                     v_Count VARCHAR2(4000) := ( SELECT COUNT(1)  
                       FROM tt_MissingAcc  );

                  BEGIN
                     SELECT utils.stuff(( SELECT ', ' || B.AccountID 
                       FROM tt_MissingAcc B
                      WHERE  B.SrNo = A.SrNo
                       ORDER BY AccountID ), 1, 1, ' ') 

                       INTO v_MissingAcc
                       FROM tt_MissingAcc A
                       GROUP BY A.SrNo;
                     UPDATE UploadBuyoutMapper
                        SET ErrorMessage = CASE 
                                                WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Count of Buyout Accounts Mapped : ' || v_Count || 'is not tallied with AccountNoinRBLHostSystem. Missing Accounts found are : ' || v_MissingAcc || '.'
                            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Count of Buyout Accounts Mapped : ' || v_Count || 'is not tallied with AccountNoinRBLHostSystem. Missing Accounts found are : ' || v_MissingAcc || '.'
                               END,
                            ErrorinColumn = CASE 
                                                 WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
                            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
                               END,
                            Srnooferroneousrows = NULL;

                  END;
                  ELSE

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('No Missing Accounts from Main table');

                  END;
                  END IF;

               END;
               END IF;

            END;
            END IF;
            /*VALIDATIONS ON AccountNoofSeller */
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘AccountNoofSeller’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘AccountNoofSeller’ is mandatory. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoofSeller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoofSeller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadBuyoutMapper A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyoutMapper V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountNoofSeller, ' ') = ' ';
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in column AccountNoofSeller. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in  column AccountNoofSeller. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoofSeller'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoofSeller'
                      END,
                   V.Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadBuyoutMapper A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadBuyoutMapper V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  INSTR(AccountNoofSeller, ' ', 1) != 0;
            -- ----SELECT * FROM UploadBuyoutMapper
            -- UPDATE UploadBuyoutMapper
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid AccountNoofSeller found. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid AccountNoofSeller found. Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountNoofSeller' ELSE ErrorinColumn +','+SPACE(1)+  'AccountNoofSeller' END  
            --	,Srnooferroneousrows=V.SlNo
            --	FROM UploadBuyoutMapper V  
            --WHERE ISNULL(V.AccountNoofSeller,'')<>''
            --AND V.AccountNoofSeller NOT IN(SELECT CustomerACID FROM AdvAcBasicDetail
            --							WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
            --					 )
            IF utils.object_id('TEMPDB..tt_DUB3') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB3 ';
            END IF;
            DELETE FROM tt_DUB3;
            UTILS.IDENTITY_RESET('tt_DUB3');

            INSERT INTO tt_DUB3 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountNoofSeller ORDER BY AccountNoofSeller  ) rw  
                        FROM UploadBuyoutMapper  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate AccountNoofSeller found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate AccountNoofSeller found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'AccountNoofSeller'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoofSeller'
               END AS pos_3, V.SlNo
            FROM V ,UploadBuyoutMapper V
                   JOIN tt_DUB2_12 D   ON D.AccountNoofSeller = V.AccountNoofSeller ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SlNo;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record for AccountNoofSeller  is pending for authorization in ‘Upload ID’ ' || UTILS.CONVERT_TO_VARCHAR2(B.UploadID,10) || ' kindly remove the record and upload again '
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Record for AccountNoofSeller  is pending for authorization in ‘Upload ID’ ' || UTILS.CONVERT_TO_VARCHAR2(B.UploadID,10) || ' kindly remove the record and upload again '
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoofSeller'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoofSeller'
               END AS pos_3, V.SlNo
            FROM V ,UploadBuyoutMapper V
                   LEFT JOIN BuyoutMapperUpload_Mod B   ON V.AccountNoofSeller = B.AccountNoofSeller
                 --LEFT Join CollateralDetailUpload_Mod C ON V.AssetID=C.AssetID						

             WHERE B.AuthorisationStatus IN ( 'NP','MP','FM','RM','1A' )

              AND ( B.AccountNoofSeller IS NOT NULL )) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SlNo;
            UPDATE UploadBuyoutMapper V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column AccountNoinRBLHostSystem cannot be as same as AccountNoofSeller. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column AccountNoinRBLHostSystem cannot be as same as AccountNoofSeller. Kindly check and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AccountNoinRBLHostSystem'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AccountNoinRBLHostSystem'
                      END,
                   V.Srnooferroneousrows = V.SlNo
             WHERE  NVL(AccountNoofSeller, ' ') = NVL(AccountNoinRBLHostSystem, ' ');
            ---------------------------------------
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
                                FROM Buyoutaccountmapper_stg 
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
                FROM UploadBuyoutMapper  );
            DBMS_OUTPUT.PUT_LINE('VALIDATION ERRORS');
            --	----SELECT * FROM UploadBuyoutMapper 
            --	--ORDER BY ErrorMessage,UploadBuyoutMapper.ErrorinColumn DESC
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
                 ORDER BY SR_No ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM Buyoutaccountmapper_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE Buyoutaccountmapper_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.Buyoutaccountmapper_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadBuyoutMapper
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_BUYOUTMAPPERUPLOAD" TO "ADF_CDR_RBL_STGDB";
