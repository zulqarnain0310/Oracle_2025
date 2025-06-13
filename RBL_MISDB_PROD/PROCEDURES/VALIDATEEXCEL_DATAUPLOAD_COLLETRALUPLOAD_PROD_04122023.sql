--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
         IF ( v_MenuID = 24702 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            v_DuplicateCnt NUMBER(10,0) := 0;
            -------------------------------------------------------------------------
            ----------------------------------------------
            /*validations on Related UCIC / Customer ID / Account ID*/
            v_Count NUMBER(10,0);
            v_I NUMBER(10,0);
            v_Entity_Key NUMBER(10,0);
            v_TaggingLevel VARCHAR2(100) := ' ';
            v_RelatedUCICCustomerIDAccountID VARCHAR2(100) := ' ';
            v_AccountId VARCHAR2(100) := ' ';
            v_CustomerID VARCHAR2(100) := ' ';
            v_UCIC VARCHAR2(100) := ' ';
            -------------Collateral Type---------------------------------
            v_CollateralTypeCnt NUMBER(10,0) := 0;
            v_PoolType NUMBER(10,0) := 0;
            /*
             UPDATE UploadCollateral
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END     
            		,Srnooferroneousrows=V.SrNo
            	--	STUFF((SELECT ','+SRNO 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SRNO IN(SELECT Srno FROM #DUB2))
             --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM UploadCollateral V  
             WHERE ISNULL(PoolID,'')<>''
             AND PoolID IN(SELECT PoolID FROM #PoolID GROUP BY PoolID)
             */
            -------------Collateral Sub Type---------------------------------
            v_CollateralSubTypeCnt NUMBER(10,0) := 0;
            ----------------------------------------
            ------------Collateral Owner Typee---------------------------------
            v_CollateralOwnerType NUMBER(10,0) := 0;
            ------------------------------------------------
            ------------Charge Typee---------------------------------
            v_ChargeTypeCnt NUMBER(10,0) := 0;
            ---------------------25042021 Added by Poonam/Anuj--------------------------
            ------------Charge Nature---------------------------
            v_ChargeNatureCnt NUMBER(10,0) := 0;
            -----------------------------------------------------------------------------------
            -------------------------------------------------------------
            /*-------------------Validation Date------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on -Validation Datel*/
            v_Validation VARCHAR2(200);
            -- UPDATE UploadCollateral
            --SET  
            --select
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation date must be less than equal to Process Date viz. ########. Kindly check and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Valuation date must be less than equal to Process Date viz. ########. Kindly check and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation date.' ELSE   ErrorinColumn +','+SPACE(1)+'Valuation date' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --WHERE ISDATE(ValuationDate)=1  --AND Convert(date,ValuationDate)>Convert(date,@Validation)
            -----------------------------------------
            ------------Expiry Business Rule---------------------------
            v_ExpiryBusinessRuleCnt NUMBER(10,0) := 0;
            v_ColletralTypeCnt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..UploadCollateral') IS NOT NULL  
            IF utils.object_id('UploadCollateral') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE UploadCollateral';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM CollateralDetails_stg 
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
               DELETE FROM UploadCollateral;
               UTILS.IDENTITY_RESET('UploadCollateral');

               INSERT INTO UploadCollateral SELECT * ,
                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                   UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM CollateralDetails_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            ------------------------------------------------------------------------------  
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE UploadCollateral V
               SET ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   ErrorinColumn = 'CollateralID,Tagging Level,DistributionLevel,CollateralType,CollateralOwnerType,Interest CollateralOwnershipType,Balances,Dates',
                   Srnooferroneousrows = ' '
             WHERE  NVL(OldCollateralID, ' ') = ' '
              AND NVL(TaggingLevel, ' ') = ' '
              AND NVL(DistributionLevel, ' ') = ' '
              AND NVL(DistributionValue, ' ') = ' '
              AND NVL(CollateralType, ' ') = ' '
              AND NVL(CollateralSubType, ' ') = ' '
              AND NVL(CollateralOwnerType, ' ') = ' '
              AND NVL(CollateralOwnershipType, ' ') = ' '
              AND NVL(ChargeType, ' ') = ' '
              AND NVL(ChargeNature, ' ') = ' '
              AND NVL(ShareAvailableToBank, ' ') = ' '
              AND NVL(ShareValue, ' ') = ' '
              AND NVL(CollateralValueatSanctioninRs, ' ') = ' '
              AND NVL(CollateralValueasonNPADateinRs, ' ') = ' '
              AND NVL(CollateralValueatLastReviewinRs, ' ') = ' '
              AND NVL(ValuationDate, ' ') = ' '
              AND NVL(CurrentCollateralValueinRs, ' ') = ' '
              AND NVL(ExpiryBusinessRule, ' ') = ' ';
            --WHERE ISNULL(V.SrNo,'')=''
            -- ----AND ISNULL(Territory,'')=''
            -- AND ISNULL(AccountID,'')=''
            -- AND ISNULL(PoolID,'')=''
            -- AND ISNULL(filname,'')=''
            --IF EXISTS(SELECT 1 FROM UploadCollateral WHERE ISNULL(ErrorMessage,'')<>'')
            --BEGIN
            --PRINT 'NO DATA'
            --GOTO ERRORDATA;
            --END
            /*validations on Sl. No.*/
            ------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('Satart11');
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(SrNo, ' ') = ' '
              OR NVL(SrNo, '0') = '0';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SrNo cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(SrNo) > 16;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(SrNo) = 0
              AND NVL(SrNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SrNo), '%^[0-9]%');
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SrNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SrNo'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  REGEXP_LIKE(NVL(SrNo, ' '), '%[,!@#$%^&*()_-+=/]%');
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM UploadCollateral 
              GROUP BY SrNo

               HAVING COUNT(SrNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE UploadCollateral V
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
                                        FROM UploadCollateral 
                                          GROUP BY SrNo

                                           HAVING COUNT(SrNo)  > 1 )
            ;
            END IF;
            --------------------------------LEN changes 16082021 sudesh-------
            /*validations on Old Collateral IDl*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Old Collateral ID cannot be blank or Less than 20 Character. Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Old Collateral ID cannot be blank or Less than 20 Character . Please check the values and upload again.n'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Old Collateral ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Old Collateral ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE --ISNULL(OldCollateralID,'')='' Or
              LENGTH((OldCollateralID)) > 20;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Old Collateral ID.’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Old Collateral ID’. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Old Collateral ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Old Collateral ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(OldCollateralID) = 0
              AND NVL(OldCollateralID, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(OldCollateralID), '%^[0-9]%');
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Old Collateral ID can not contain decimal. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Old Collateral ID can not contain decimal. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Old Collateral ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Old Collateral ID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  (INSTR(OldCollateralID, '.')) > 0;
            --  UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Old Collateral ID, kindly check and upload again '     
            --					ELSE ErrorMessage+','+SPACE(1)+'Duplicate Old Collateral ID, kindly check and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Old Collateral ID' ELSE   ErrorinColumn +','+SPACE(1)+'Old Collateral ID' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --WHERE 
            -- ISNULL(OldCollateralID,'')  In( 
            --							  SELECT OldCollateralID
            --							FROM UploadCollateral
            --							GROUP BY  OldCollateralID
            --							HAVING COUNT(OldCollateralID) >1
            --						)
            MERGE INTO UploadCollateral V
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Record for Old Collateral ID is pending for authorization in ‘Upload ID’ ' || UTILS.CONVERT_TO_VARCHAR2(C.UploadID,100) || ' kindly remove the record and upload again '
            ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Record for Old Collateral ID is pending for authorization in ‘Upload ID’ ' || UTILS.CONVERT_TO_VARCHAR2(C.UploadID,100) || ' kindly remove the record and upload again '
               END AS pos_2, CASE 
            WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Old Collateral ID'
            ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Old Collateral ID'
               END AS pos_3, V.SrNo
            FROM UploadCollateral V
                   JOIN AdvSecurityDetail_Mod B   ON V.OldCollateralID = B.Security_RefNo
                   JOIN CollateralMgmtUpload_Mod C   ON V.OldCollateralID = C.OldCollateralID 
             WHERE B.AuthorisationStatus IN ( 'NP','MP','FM' )
            ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SrNo;
            -------------------------------------------------------------------------
            ----------------------------------------------
            /*validations on Tagging Level*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Tagging Level cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Tagging Level cannot be blank . Please check the values and upload again.n'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Tagging Level'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Tagging Level'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(TaggingLevel, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Tagging Level’. Kindly enter ‘UCIC or Customerid or AccountID’ and upload again. '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Tagging Level’. Kindly enter ‘UCIC or Customerid or AccountID’ and upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Tagging Level'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Tagging Level'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(DistributionLevel, ' ') <> ' '
              AND NVL(TaggingLevel, ' ') NOT IN ( 'UCIC','CustomerID','AccountID' )
            ;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Related UCIC / Customer ID / Account ID cannot be blank . Please check the values and upload again.n'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account IDl'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(RelatedUCICCustomerIDAccountID, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID should be less than or equal to 16 character . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || ' Related UCIC / Customer ID / Account ID should be less than or equal to 16 character . Please check the values and upload again.n'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account IDl'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(RelatedUCICCustomerIDAccountID) > 20;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters - _ \ / are not allowed, kindly remove and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters - _ \ / are not allowed, kindly remove and try again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account IDl'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  LENGTH(RelatedUCICCustomerIDAccountID) LIKE '%- \ / _%';
            IF utils.object_id('TempDB..tt_tmp_23') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_tmp_23 ';
            END IF;
            DELETE FROM tt_tmp_23;
            UTILS.IDENTITY_RESET('tt_tmp_23');

            INSERT INTO tt_tmp_23 SELECT ROW_NUMBER() OVER ( ORDER BY UTILS.CONVERT_TO_NUMBER(Entity_Key,10,0)  ) RecentRownumber  ,
                                         Entity_Key ,
                                         TaggingLevel ,
                                         RelatedUCICCustomerIDAccountID ,
                                         UTILS.CONVERT_TO_VARCHAR2(' ',1000) ErrorMessage  
                 FROM UploadCollateral ;
            SELECT COUNT(*)  

              INTO v_Count
              FROM tt_tmp_23 ;
            v_I := 1 ;
            v_Entity_Key := 0 ;
            v_CustomerId := ' ' ;
            v_UCIC := ' ' ;
            v_AccountId := ' ' ;
            WHILE ( v_I <= v_Count ) 
            LOOP 

               BEGIN
                  SELECT TaggingLevel ,
                         RelatedUCICCustomerIDAccountID ,
                         Entity_Key 

                    INTO v_TaggingLevel,
                         v_RelatedUCICCustomerIDAccountID,
                         v_Entity_Key
                    FROM tt_tmp_23 
                   WHERE  RecentRownumber = v_I
                    ORDER BY Entity_Key;
                  IF v_TaggingLevel = 'Account ID' THEN

                  BEGIN
                     SELECT CustomerACID 

                       INTO v_AccountId
                       FROM AdvAcBasicDetail 
                      WHERE  CustomerACID = v_RelatedUCICCustomerIDAccountID;
                     IF v_AccountId = ' ' THEN

                     BEGIN
                        UPDATE UploadCollateral
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID is invalid. Kindly check the entered Account id'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID is invalid. Kindly check the entered Account id'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account ID'
                                  END
                         WHERE  Entity_Key = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  IF v_TaggingLevel = 'Customer ID' THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('Sachin');
                     SELECT CustomerId 

                       INTO v_CustomerId
                       FROM CustomerBasicDetail 
                      WHERE  CustomerId = v_RelatedUCICCustomerIDAccountID;
                     IF v_CustomerId = ' ' THEN

                     BEGIN
                        DBMS_OUTPUT.PUT_LINE('@CustomerIdAf');
                        DBMS_OUTPUT.PUT_LINE(v_CustomerId);
                        UPDATE UploadCollateral
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Customer ID is invalid. Kindly check the entered customer id'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Customer ID is invalid. Kindly check the entered customer id'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account ID'
                                  END
                         WHERE  Entity_Key = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  IF v_TaggingLevel = 'UCIC' THEN

                  BEGIN
                     SELECT UCIF_ID 

                       INTO v_UCIC
                       FROM CustomerBasicDetail 
                      WHERE  UCIF_ID = v_RelatedUCICCustomerIDAccountID;
                     IF v_UCIC = ' ' THEN

                     BEGIN
                        UPDATE UploadCollateral
                           SET ErrorMessage = CASE 
                                                   WHEN NVL(ErrorMessage, ' ') = ' ' THEN '	  UCIC is invalid. Kindly check the entered UCIC'
                               ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '	  UCIC is invalid. Kindly check the entered UCIC'
                                  END,
                               ErrorinColumn = CASE 
                                                    WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Related UCIC / Customer ID / Account ID'
                               ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Related UCIC / Customer ID / Account ID'
                                  END
                         WHERE  Entity_Key = v_Entity_Key;

                     END;
                     END IF;

                  END;
                  END IF;
                  v_I := v_I + 1 ;
                  v_CustomerId := ' ' ;
                  v_UCIC := ' ' ;
                  v_AccountId := ' ' ;

               END;
            END LOOP;
            -------------------------------------------------------------------------
            ----------------------------------------------
            /*validations on Distribution Level*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Distribution Level cannot be blank . Please check the values and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Distribution Level cannot be blank . Please check the values and upload again.n'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Distribution Level'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Distribution Level'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(DistributionLevel, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Distribution Level’. Kindly enter ‘Proportionate or Percentage or Absolute’ and upload again’. '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Distribution Level’. Kindly enter ‘Proportionate or Percentage or Absolute’ and upload againn'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Distribution Level'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Distribution Level'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(DistributionLevel, ' ') <> ' '
              AND NVL(DistributionLevel, ' ') NOT IN ( 'Proportionate','Percentage','Absolute' )
            ;
            ---------------------------22042021-----------------
            /*
             IF OBJECT_ID('TEMPDB..#DupPool') IS NOT NULL
             DROP TABLE #DupPool

             SELECT * INTO #DupPool FROM(
             SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID ORDER BY PoolID ) as rw  FROM UploadCollateral
             )X
             WHERE rw>1


             UPDATE V
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Pool ID found. Please check the values and upload again'     
            						ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Pool ID found. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'PoolID' ELSE V.ErrorinColumn +','+SPACE(1)+  'PoolID' END  
            		,Srnooferroneousrows=V.SRNO

            		FROM UploadCollateral V 
            		INNer JOIN #DupPool D ON D.PoolID=V.PoolID
            */
            --------------------------------------------------------------
            /*-------------------Distribution Value-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Distribution Value*/
            -- UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Distribution Value cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Distribution Value cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Value' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Value' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --WHERE ISNULL(DistributionValue,'')=''
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Distribution Value’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Distribution Value’. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Distribution Value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Distribution Value'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(DistributionValue) = 0
              AND NVL(DistributionValue, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(DistributionValue), '%^[0-9]%');
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Distribution Value is mandatory and can not be blank. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Distribution Value is mandatory and can not be blank. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Distribution Value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Distribution Value'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(DistributionLevel, ' ') IN ( 'Percentage','Absolute' )

              AND NVL(DistributionValue, ' ') = ' ';
            --------------------------------precentage,absolute condition changes 16082021 sudesh-------
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Distribution Level.Percentage cannot be greater than 100.00, Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Distribution Level.Percentage cannot be greater than 100.00, Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Distribution Level'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Distribution Value'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( NVL(DistributionValue, ' ') <> ' '
              AND NVL(DistributionLevel, ' ') NOT IN ( 'Percentage','Absolute' )
             )
              AND ( LENGTH(NVL(DistributionValue, ' ')) NOT IN ( 6,5 )

              OR INSTR(NVL(DistributionValue, ' '), '.') = 0
              OR UTILS.CONVERT_TO_NUMBER(NVL('20.12', '0'),5,2) > 100
              OR ( INSTR(NVL(DistributionValue, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(DistributionValue, ' '), -LENGTH(NVL(DistributionValue, ' ')) - INSTR(NVL(DistributionValue, ' '), '.'), LENGTH(NVL(DistributionValue, ' ')) - INSTR(NVL(DistributionValue, ' '), '.'))) <> 2 )
              OR ( INSTR(NVL(DistributionValue, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(DistributionValue, ' '), 0, (INSTR(NVL(DistributionValue, ' '), '.') - 1))) NOT IN ( 3 )
             ) );
            IF utils.object_id('CollateralTypeData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE CollateralTypeData';

            END;
            END IF;
            DELETE FROM CollateralTypeData;
            UTILS.IDENTITY_RESET('CollateralTypeData');

            INSERT INTO CollateralTypeData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CollateralType ORDER BY CollateralType  ) ROW_  ,
                               CollateralType 
                        FROM UploadCollateral  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_CollateralTypeCnt
              FROM CollateralTypeData A
                     LEFT JOIN DimCollateralType B   ON A.CollateralType = B.CollateralTypeDescription
             WHERE  B.CollateralTypeDescription IS NULL;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Type cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Type cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Type'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralType, ' ') = ' ';
            IF v_CollateralTypeCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Collateral Type’. Kindly enter the values as mentioned in the ‘Collateral Type’ master and upload again. Click on ‘Download Master value’ to download the valid value





                                          s








                                           for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Collateral Type’. Kindly enter the values as mentioned in the ‘Collateral Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Type'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Type'
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

                WHERE  NVL(CollateralType, ' ') <> ' '
                 AND V.CollateralType IN ( SELECT A.CollateralType 
                                           FROM CollateralTypeData A
                                                  LEFT JOIN DimCollateralType B   ON A.CollateralType = B.CollateralTypeDescription
                                            WHERE  B.CollateralTypeDescription IS NULL )
               ;

            END;
            END IF;
            IF utils.object_id('CollateralSubTypeData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE CollateralSubTypeData';

            END;
            END IF;
            DELETE FROM CollateralSubTypeData;
            UTILS.IDENTITY_RESET('CollateralSubTypeData');

            INSERT INTO CollateralSubTypeData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY A.CollateralSubType ORDER BY A.CollateralSubType  ) ROW_  ,
                               A.CollateralSubType ,
                               B.CollateralTypeAltKey 
                        FROM UploadCollateral A
                               LEFT JOIN DimCollateralSubType B   ON A.CollateralSubType = B.CollateralSubTypeDescription ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_CollateralSubTypeCnt
              FROM CollateralSubTypeData A
                     LEFT JOIN DimCollateralSubType B   ON A.CollateralSubType = B.CollateralSubTypeDescription
             WHERE  B.CollateralSubTypeDescription IS NULL;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Sub Type cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Sub Type cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Sub Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Sub Type'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralSubType, ' ') = ' ';
            IF v_CollateralSubTypeCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the vali





                                          d values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Sub Typ'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Sub Typ'
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

                WHERE  NVL(CollateralSubType, ' ') <> ' '
                 AND V.CollateralSubType IN ( SELECT A.CollateralSubType 
                                              FROM CollateralSubTypeData A
                                                     LEFT JOIN DimCollateralSubType B   ON A.CollateralSubType = B.CollateralSubTypeDescription
                                               WHERE  B.CollateralSubTypeDescription IS NULL )
               ;

            END;
            END IF;

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Do





                                          wnload Master value’ to download the valid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to do





                      wnload the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Sub Typ'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Sub Typ'
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

                WHERE  NVL(CollateralSubType, ' ') <> ' '
                 AND V.CollateralSubType IN ( SELECT A.CollateralSubType 
                                              FROM CollateralSubTypeData A
                                                     LEFT JOIN DimCollateralType B   ON A.CollateralTypeAltKey = B.CollateralTypeAltKey
                                               WHERE  B.CollateralTypeAltKey IS NULL )
               ;

            END;
            IF utils.object_id('CollateralOwnerTypeData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE CollateralOwnerTypeData';

            END;
            END IF;
            DELETE FROM CollateralOwnerTypeData;
            UTILS.IDENTITY_RESET('CollateralOwnerTypeData');

            INSERT INTO CollateralOwnerTypeData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY CollateralOwnerType ORDER BY CollateralOwnerType  ) ROW_  ,
                               CollateralOwnerType 
                        FROM UploadCollateral  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_CollateralOwnerType
              FROM CollateralOwnerTypeData A
                     LEFT JOIN DimCollateralOwnerType B   ON A.CollateralOwnerType = B.CollOwnerDescription
             WHERE  B.CollOwnerDescription IS NULL;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Owner Type cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Owner Type cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Owner Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Owner Type'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralOwnerType, ' ') = ' ';
            IF v_CollateralSubTypeCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN '“Invalid value in column ‘Collateral Owner Type’. Kindly enter the values as mentioned in the ‘Collateral Owner Type’ master and upload again. Click on ‘Download Master value’ to download the





                                          valid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || '“Invalid value in column ‘Collateral Owner Type’. Kindly enter the values as mentioned in the ‘Collateral Owner Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the colu





                      mn'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Owner Type'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Owner Type'
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

                WHERE  NVL(CollateralType, ' ') <> ' '
                 AND V.CollateralOwnerType IN ( SELECT A.CollateralOwnerType 
                                                FROM CollateralOwnerTypeData A
                                                       LEFT JOIN DimCollateralOwnerType B   ON A.CollateralOwnerType = B.CollOwnerDescription
                                                 WHERE  B.CollOwnerDescription IS NULL )
               ;

            END;
            END IF;
            ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            --------------------Share available to Bank----------------------------------
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Share available to Bank cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Share available to Bank cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Share available to Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Share available to Bank'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ShareAvailableToBank, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN '“Invalid value in column ‘Share available to Bank’. Kindly enter ‘Percentage or Absolute’ and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Share available to Bank’. Kindly enter ‘Percentage or Absolute’ and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Share available to Bank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Share available to Bank'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ShareAvailableToBank, ' ') <> ' '
              AND NVL(ShareAvailableToBank, ' ') NOT IN ( 'Percentage','Absolute' )
            ;
            ----------------------------------------------------------------------------------------
            --/*  New Changes in Pool Name  */
            --IF OBJECT_ID('TEMPDB..#PoolName') IS NOT NULL
            --DROP TABLE #PoolName
            --SELECT * INTO #PoolName FROM(
            --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,PoolType ORDER BY  PoolID,PoolType ) ROW FROM UploadCollateral
            --)X
            --WHERE ROW>1
            --UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END     
            --	,Srnooferroneousrows=V.SrNo
            ----	STUFF((SELECT ','+SRNO 
            ----							FROM #UploadNewAccount A
            ----							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
            ----WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
            ------AND SRNO IN(SELECT Srno FROM #DUB2))
            ----AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))
            ----							FOR XML PATH ('')
            ----							),1,1,'')   
            --FROM UploadCollateral V  
            --WHERE ISNULL(PoolID,'')<>''
            --AND PoolID IN(SELECT PoolID FROM #PoolName GROUP BY PoolID)
            --Check
            ------------Collateral Ownership Type---------------------------------
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Ownership Type cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Ownership Type cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Ownership Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Ownership Type'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralOwnershipType, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Collateral Ownership Type’. Kindly enter ‘Joint or Sole and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Collateral Ownership Type’. Kindly enter ‘Joint or Sole’ and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Ownership Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Ownership Type'
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

             WHERE  (CollateralOwnershipType) NOT IN ( 'Joint','Sole' )
            ;
            IF utils.object_id('ChargeTypeData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE ChargeTypeData';

            END;
            END IF;
            DELETE FROM ChargeTypeData;
            UTILS.IDENTITY_RESET('ChargeTypeData');

            INSERT INTO ChargeTypeData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY ChargeType ORDER BY CollateralOwnerType  ) ROW_  ,
                               ChargeType 
                        FROM UploadCollateral  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_ChargeTypeCnt
              FROM ChargeTypeData A
                     LEFT JOIN DimCollateralChargeType B   ON A.ChargeType = B.CollChargeDescription
             WHERE  B.CollChargeDescription IS NULL;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Charge Type cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Charge Type cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charge Type'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charge Type'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ChargeType, ' ') = ' ';
            IF v_ChargeTypeCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Charge Type’. Kindly enter the values as mentioned in the ‘Charge Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for th















                                          e
                                           column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Charge Type’. Kindly enter the values as mentioned in the ‘Charge Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charge Type'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charge Type'
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

                WHERE  NVL(ChargeType, ' ') <> ' '
                 AND V.ChargeType IN ( SELECT A.ChargeType 
                                       FROM ChargeTypeData A
                                              LEFT JOIN DimCollateralChargeType B   ON A.ChargeType = B.CollChargeDescription
                                        WHERE  B.CollChargeDescription IS NULL )
               ;

            END;
            END IF;
            IF utils.object_id('ChargeNatureData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE ChargeNatureData';

            END;
            END IF;
            DELETE FROM ChargeNatureData;
            UTILS.IDENTITY_RESET('ChargeNatureData');

            INSERT INTO ChargeNatureData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY ChargeNature ORDER BY ChargeNature  ) ROW_  ,
                               ChargeNature 
                        FROM UploadCollateral  ) X
                WHERE  ROW_ = 1;
            SELECT COUNT(*)  

              INTO v_ChargeTypeCnt
              FROM ChargeNatureData A
                     LEFT JOIN DimSecurityChargeType B   ON A.ChargeNature = B.SecurityChargeTypeName
             WHERE  B.SecurityChargeTypeName IS NULL;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Charge Nature cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Charge Nature cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charge Nature'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charge Nature'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ChargeNature, ' ') = ' ';
            IF v_ChargeNatureCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Charge Nature’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for





                                           the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Charge Nature’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Charge Nature'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Charge Nature'
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

                WHERE  NVL(ChargeNature, ' ') <> ' '
                 AND V.ChargeNature IN ( SELECT A.ChargeNature 
                                         FROM ChargeNatureData A
                                                LEFT JOIN DimSecurityChargeType B   ON A.ChargeNature = B.SecurityChargeTypeName
                                          WHERE  B.SecurityChargeTypeName IS NULL )
               ;

            END;
            END IF;
            ---------------------------------------------------------------------------
            /*  
               UPDATE 

            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found.AccountID are repeated.  Please check the values and upload again'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'Duplicate records found. AccountID are repeated.  Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END     
            		,Srnooferroneousrows=V.SrNo
            	--	STUFF((SELECT ','+SRNO 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SRNO IN(SELECT Srno FROM #DUB2))
             --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM UploadCollateral V  
             WHERE ISNULL(AccountID,'')<>''
             AND AccountID IN(SELECT AccountID FROM #DUB2 GROUP BY AccountID)
             */
            ----------------------------------------------
            /*VALIDATIONS ON CustomerID */
            -- ----SELECT * FROM UploadCollateral
            ----------------------------------------------
            ---- ----SELECT * FROM UploadCollateral
            /*validations on PrincipalOutstandinginRs */
            -----------------------------------------------------------------
            -----------------------------------------------------------------
            --UPDATE UploadCollateral
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofIBPCreckoning Can not be Greater than Other Maturity and not less to DateofIBPCreckoning. Please enter the Correct Date'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DateofIBPCreckoning Can not be Greater than Other Maturity and not less to DateofIBPCreckoning. Please enter the Correct Date'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END      
            --		,Srnooferroneousrows=V.SrNo
            --		--STUFF((SELECT ','+SRNO 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM UploadCollateral V  
            -- WHERE ISNULL(DateofIBPCmarking,'')<>'' AND (Cast(DateofIBPCmarking as date)<Cast(DateofIBPCreckoning as Date) OR Cast(DateofIBPCmarking as Date)>Cast(MaturityDate as Date))
            --------------------------------------
            /*
             UPDATE UploadCollateral
            	SET  
                    ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     
            						ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     END
            		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END     
            		,Srnooferroneousrows=V.SrNo
            	--	STUFF((SELECT ','+SRNO 
            	--							FROM #UploadNewAccount A
            	--							WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V  
             --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''
             ----AND SRNO IN(SELECT Srno FROM #DUB2))
             --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))

            	--							FOR XML PATH ('')
            	--							),1,1,'')   

             FROM UploadCollateral V  
             WHERE ISNULL(PoolID,'')<>''
             AND PoolID IN(SELECT PoolID FROM #Date1 GROUP BY PoolID)
             */
            ---------------------------------
            /*  Validations on MisMatch DateofIBPCmarking  */
            ---- Pranay 20-03-21
            --IF OBJECT_ID('TEMPDB..#Date2') IS NOT NULL
            --DROP TABLE #Date2
            --SELECT * INTO #Date2 FROM(
            --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofIBPCmarking ORDER BY  PoolID,DateofIBPCmarking ) ROW FROM UploadCollateral
            --)X
            --WHERE ROW>1
            -------------------DateofIBPCmarking--------------------------Pranay 20-03-21
            ---------------------------------
            /*-------------------Share Value-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Share Valuel*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Share Value cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Share Valu cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Share Value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Share Value'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(Sharevalue, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Share Value’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Share Value’. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Share Value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Share Value'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(Sharevalue) = 0
              AND NVL(Sharevalue, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(Sharevalue), '%^[0-9]%');
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Share Value’. Percentage cannot be greater than 100.00. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Share Value’. Percentage cannot be greater than 100.00. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Share Value'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Share Value'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ShareValue, ' ') <> ' '
              AND NVL(ShareAvailableToBank, ' ') IN ( 'Percentage' )

              AND UTILS.CONVERT_TO_NUMBER(NVL(ShareValue, '0'),5,2) > 100;
            --AND (Len(ISNULL(ShareValue,'')) Not in(6,5) OR CHARINDEX('.',ISNULL(ShareValue,''))=0  OR Convert(Decimal(5,2),ISNULL(ShareValue,'0'))>100  
            -- OR (CHARINDEX('.',ISNULL(ShareValue,''))>0  AND Len(Right(ISNULL(ShareValue,''),Len(ISNULL(ShareValue,''))-CHARINDEX('.',ISNULL(ShareValue,''))))<>2)
            --  OR (CHARINDEX('.',ISNULL(ShareValue,''))>0  AND  Len(Left(ISNULL(DistributionValue,''),(CHARINDEX('.',ISNULL(DistributionValue,''))-1))) NOT IN(3)) )
            -------------------------------------------------------------------------------------------------------------
            /*-------------------Collateral Value at Sanction in Rs.-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Collateral Value at Sanction in Rsl*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Value at Sanction in Rs. cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Value at Sanction in Rs.e cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Value at Sanction in Rs.'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Value at Sanction in Rs.'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralValueatSanctioninRs, ' ') = ' ';
            --(case
            --when CollateralValueatSanctioninRs like '%[^0-9]%' then 'Y'
            --else 'N' END)='Y
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Collateral Value as on NPA Date in Rs.’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Collateral Value as on NPA Date in Rs.’. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Value as on NPA Date in Rs.l'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Value as on NPA Date in Rs.'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(CollateralValueatSanctioninRs) = 0
              AND NVL(CollateralValueatSanctioninRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(CollateralValueatSanctioninRs), '%^[0-9]%');
            -----------------------------------------------------------------------------------
            -------------------------------------------------------------------------------------------------------------
            /*-------------------CCollateral Value as on NPA Date in Rs..-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Collateral Value as on NPA Date in Rs.l*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Value as on NPA Date in Rs. cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Value as on NPA Date in Rs. cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Value as on NPA Date in Rs.'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Value as on NPA Date in Rs.'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralValueasonNPADateinRs, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Collateral Value as on NPA Date in Rs.’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Collateral Value as on NPA Date in Rs..  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Value as on NPA Date in Rs.'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Value as on NPA Date in Rs.'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(CollateralValueasonNPADateinRs) = 0
              AND NVL(CollateralValueasonNPADateinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(CollateralValueasonNPADateinRs), '%^[0-9]%');
            --------------------------------------------------------------------------------------------------------------------
            /*-------------------Collateral Value at Last Review in Rsa...-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Collateral Value at Last Review in Rs.l*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Collateral Value at Last Review in Rs.. cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Collateral Value at Last Review in Rs. cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Value at Last Review in Rs..'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Value at Last Review in Rs..'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CollateralValueatLastReviewinRs, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Collateral Value at Last Review in Rs.’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Collateral Value at Last Review in Rs.’. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Value at Last Review in Rs.'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Value at Last Review in Rs.'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(CollateralValueatLastReviewinRs) = 0
              AND NVL(CollateralValueatLastReviewinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(CollateralValueatLastReviewinRs), '%^[0-9]%');
            ------------------------------------------------------------------------------------------------------
            ---Check
            /*-------------------Valuation Date...-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Valuation Date.l*/
            -- UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Date. cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Valuation Date cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --  WHERE ISNULL(ValuationDate,'')=''
            -- UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Valuation Date’. Kindly check and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Valuation Date Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --WHERE ISNUMERIC(ValuationDate)<>1
            -------------------------------------------------------------------
            /*-------------------Valuation Date...-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Valuation Date.l*/
            -- UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Date. cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Valuation Date cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --  WHERE ISNULL(ValuationDate,'')=''
            -- UPDATE UploadCollateral
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation date must be less than equal to Process Date viz. ########. Kindly check and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Valuation Date  Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM UploadCollateral V  
            --WHERE ISDATE(ValuationDate)<>1
            -------------------------------------------------------------
            /*-------------------Current Collateral Value in Rs...-Validation------------------------- */
            -- changes done on 19-03-21 Pranay 
            /*validations on Current Collateral Value in Rs.l*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Current Collateral Value in Rs. cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Current Collateral Value in Rs. cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Current Collateral Value in Rs..'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PoolID'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(CurrentCollateralValueinRs, ' ') = ' ';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid values in ‘Current Collateral Value in Rs.’. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid values in ‘Current Collateral Value in Rs.’. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Current Collateral Value in Rs..'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Current Collateral Value in Rs.'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(CurrentCollateralValueinRs) = 0
              AND NVL(CurrentCollateralValueinRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(CurrentCollateralValueinRs), '%^[0-9]%');
            --SET @Validation='2100-12-31'
            SELECT B.Date_ 

              INTO v_Validation
              FROM SysDataMatrix A
                     JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
             WHERE  CurrentStatus = 'C';
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Valuation Date cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Valuation Date cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Valuation Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Valuation Date'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ValuationDate, ' ') = ' ';
            /*TODO:SQLDEV*/ SET DateFormat DMY /*END:SQLDEV*/
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Valuation Date is not Valid Date . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Valuation Date is not Valid Date . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Valuation Date'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Valuation Date'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  utils.isdate(ValuationDate) = 0
              AND NVL(ValuationDate, ' ') = ' ';
            IF utils.object_id('ExpiryBusinessRuleData') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE ExpiryBusinessRuleData';

            END;
            END IF;
            IF utils.object_id('ExpiryBusinessRuleData1') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE ExpiryBusinessRuleData1';

            END;
            END IF;
            DELETE FROM ExpiryBusinessRuleData;
            UTILS.IDENTITY_RESET('ExpiryBusinessRuleData');

            INSERT INTO ExpiryBusinessRuleData SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( PARTITION BY ExpiryBusinessRule ORDER BY ExpiryBusinessRule  ) ROW_  ,
                               A.ExpiryBusinessRule ,
                               A.CollateralType ,
                               C.SecurityTypeAlt_Key 
                        FROM UploadCollateral A
                               LEFT JOIN DimValueExpiration C   ON A.ExpiryBusinessRule = C.Documents ) X
                WHERE  ROW_ = 1;
            DELETE FROM ExpiryBusinessRuleData1;
            UTILS.IDENTITY_RESET('ExpiryBusinessRuleData1');

            INSERT INTO ExpiryBusinessRuleData1 SELECT * 
                 FROM ( SELECT A.* 
                        FROM ExpiryBusinessRuleData A
                               LEFT JOIN DimCollateralType B   ON B.CollateralTypeAltKey = A.SecurityTypeAlt_Key
                         WHERE  B.CollateralTypeAltKey IS NULL ) X;
            SELECT COUNT(*)  

              INTO v_ExpiryBusinessRuleCnt
              FROM ExpiryBusinessRuleData A
                     LEFT JOIN DimValueExpiration B   ON A.ExpiryBusinessRule = B.Documents --Check

             WHERE  B.Documents IS NULL;
            UPDATE UploadCollateral V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Expiry Business Rule cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Expiry Business Rule cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Expiry Business Rule'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Expiry Business Rulee'
                      END,
                   Srnooferroneousrows = V.SrNo
             WHERE  NVL(ExpiryBusinessRule, ' ') = ' ';
            IF v_ExpiryBusinessRuleCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘Expiry Business Rule’. Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master and upload again. Click on ‘Download Master value’ to download the v









                                          alid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘Expiry Business Rule’. Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
                      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END

                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Expiry Business Rule'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Owner Type'
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

                WHERE  NVL(ExpiryBusinessRule, ' ') <> ' '
                 AND V.ExpiryBusinessRule IN ( SELECT A.ExpiryBusinessRule 
                                               FROM ExpiryBusinessRuleData A
                                                      LEFT JOIN DimValueExpiration B   ON A.ExpiryBusinessRule = B.Documents --Check

                                                WHERE  B.Documents IS NULL )
               ;

            END;
            END IF;
            SELECT COUNT(*)  

              INTO v_ColletralTypeCnt
              FROM ExpiryBusinessRuleData A
                     LEFT JOIN DimCollateralType B   ON A.CollateralType = B.CollateralTypeDescription
             WHERE  B.CollateralTypeDescription IS NULL;
            IF v_CollateralTypeCnt > 0 THEN

            BEGIN
               UPDATE UploadCollateral V
                  SET ErrorMessage = CASE 
                                          WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid ‘Expiry Business Rule & ‘Collateral Type’ combination. 
                                          		Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master & it’s ‘Collateral Type’ and upload again. Click on ‘D





                                          ownload Master value’ to download the valid values for the column'
                      ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid ‘Expiry Business Rule & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to d





                      ownload the valid values for the column'
                         END,
                      ErrorinColumn = CASE 
                                           WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Collateral Type'
                      ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Collateral Type'
                         END,
                      Srnooferroneousrows = V.SrNo
                WHERE  NVL(ExpiryBusinessRule, ' ') <> ' '
                 AND V.CollateralType IN ( SELECT A.CollateralType 
                                           FROM ExpiryBusinessRuleData1 A )
               ;

            END;
            END IF;
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
                                FROM CollateralDetails_stg 
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
                FROM UploadCollateral  );
            DBMS_OUTPUT.PUT_LINE('Row Effected');
            DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
            --	----SELECT * FROM UploadCollateral 
            --	--ORDER BY ErrorMessage,UploadCollateral.ErrorinColumn DESC
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
                               FROM CollateralDetails_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('1');
               DELETE CollateralDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE('2');
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.CollateralDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM UploadCollateral
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_COLLETRALUPLOAD_PROD_04122023" TO "ADF_CDR_RBL_STGDB";
