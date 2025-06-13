--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'fnachecker' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_filepath IN VARCHAR2 DEFAULT 'AccountMOCUpload.xlsx' 
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
         -- SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
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
         IF ( v_MenuID = 24749 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;
            --  /*validations on SourceSystem*/
            --  UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘SourceSystem’ is mandatory. Kindly check and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'The column ‘SourceSystem’ is mandatory. Kindly check and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE ErrorinColumn +','+SPACE(1)+  'SourceSystem' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V  
            ----								----				WHERE ISNULL(ACID,'')='' )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(SourceSystem,'')='' 
            --   UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID not existing with Source System; Please check and upload again.'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Account ID not existing with Source System; Please check and upload again.'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem/AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem/AccountID' END   
            --		,Srnooferroneousrows=V.InvestmentIDDerivativeRefNo		
            --  FROM 
            --  CalypsoUploadAccMOCPool V
            --  left join dimsourcedb E
            --  on v.SourceSystem =e.sourcealt_key
            --  AND e.EffectiveFromTimeKey<=@timekey AND e.EffectiveToTimeKey>=@timekey  
            --   left JOIN InvestmentBasicDetail B 
            --   ON 
            --      V.InvestmentIDDerivativeRefNo = B.InvID
            --   AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
            --    left JOIN CurDat.DerivativeDetail c 
            --   ON c.Sourcesystem = e.sourcename 
            --   and V.InvestmentIDDerivativeRefNo = c.DerivativeRefNo
            --   AND c.EffectiveFromTimeKey<=@timekey AND c.EffectiveToTimeKey>=@timekey
            --   left join CurDat.InvestmentIssuerDetail d
            --   on b.RefIssuerID=d.IssuerID
            --   and v.SourceSystem = d.SourceAlt_Key 
            --   and d.EffectiveFromTimeKey<=@timekey AND d.EffectiveToTimeKey>=@timekey
            -- WHERE (ISNULL(c.DerivativeRefNo,'')='' 
            -- and ISNULL(b.InvID,'')='') 
            /*validations on SlNo*/
            v_DuplicateCnt NUMBER(10,0) := 0;
            --------------------------RESTRUCTURE FLAG ---------------------------------------
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘Restructure Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Restructure Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE ErrorinColumn +','+SPACE(1)+  'RestructureFlag' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(RestructureFlagYN,'') NOT IN('Y','N') AND  ISNULL(RestructureFlagYN,'')<>''
            --UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is already marked with the Restructured flag. You can only remove the marked flag for this account'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Account is already marked with the Restructured flag. You can only remove the marked flag for this account'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFlag' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- Inner Join PRO.AccountCal_Hist  A ON V.AccountID=A.CustomerAcID And A.EffectiveToTimeKey=49999
            -- WHERE ISNULL(A.FlgRestructure,'') ='Y'
            --UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not marked to the Restructured flag. You can only add the marked flag for this account'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Account is not marked to the Restructured flag. You can only add the marked flag for this account'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFlag' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            --Inner Join PRO.AccountCal_Hist  A ON V.AccountID=A.CustomerAcID And A.EffectiveToTimeKey=49999
            -- WHERE ISNULL(A.FlgRestructure,'') ='N'
            -----------------------------------------------------------------
            /*validations on Restructure Date */
            --UPDATE CalypsoUploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'RestructureDate Can not be Blank . Please enter the RestructureDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'RestructureDate Can not be Blank. Please enter the RestructureDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            --WHERE ISNULL(RestructureDate,'')='' 
            -- SET DATEFORMAT DMY
            --UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(RestructureDate,'')<>'' AND ISDATE(RestructureDate)=0
            --  Set DateFormat DMY
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Restructure date must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Restructure date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE (Case When ISDATE(RestructureDate)=1 Then Case When Cast(RestructureDate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1
            --  UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Restructure Date is mandatory when value ‘Y’ is entered in column ‘Restructure Flag'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Restructure Date is mandatory when value ‘Y’ is entered in column ‘Restructure Flag'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(RestructureFlagYN,'') IN('Y') AND ISNULL(RestructureDate,'' )=''
            -----------------------------------------------------------------
            /*validations on FraudDate */
            --UPDATE CalypsoUploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'FraudDate Can not be Blank . Please enter the FraudDate and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'FraudDate Can not be Blank. Please enter the FraudDate and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            --WHERE ISNULL(FraudDate,'')='' 
            -- Set DateFormat DMY
            --UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(FraudDate,'')<>'' AND ISDATE(FraudDate)=0
            -- Set DateFormat DMY
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Fraud date must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Fraud date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            --WHERE (Case When ISDATE(FraudDate)=1 Then Case When Cast(FraudDate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1
            -- UPDATE CalypsoUploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Fraud Date is mandatory when value ‘Y’ is entered in column ‘Fraud Flag'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'Fraud Date is mandatory when value ‘Y’ is entered in column ‘Fraud Flag'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            --WHERE ISNULL(FraudDate,'')=''
            ---------------------------------MOC Source---------------------------
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the 
            --column'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSource' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSource' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- left JOIN  DimMOCType a 
            -- on v.MOCSOURCE = A.MOCTypeName
            -- WHERE A.MOCTypeName is NULL
            -------------MOCSource--------------------
            --   Declare @ValidSourceInt int=0
            --	IF OBJECT_ID('MocSourceData') IS NOT NULL  
            --	  BEGIN  
            --	   DROP TABLE MocSourceData  
            --	  END
            --SELECT * into MocSourceData  FROM(
            -- SELECT ROW_NUMBER() OVER(PARTITION BY MOCSOURCE  ORDER BY  MOCSOURCE ) 
            -- ROW ,MOCSOURCE FROM CalypsoUploadAccMOCPool
            --)X
            -- WHERE ROW=1
            --   SELECT  @ValidSourceInt=COUNT(*) FROM MocSourceData A
            -- Left JOIN DimMOCType B
            -- ON  A.MOCSOURCE=B.MOCTypeName
            -- Where B.MOCTypeName IS NULL
            -- AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
            --   IF @ValidSourceInt>0
            --     BEGIN
            --	         UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
            --        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END     
            --		,Srnooferroneousrows=V.SlNo
            --		 FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(MOCSOURCE,'')<>''
            -- AND  V.MOCSOURCE IN(
            --				SELECT  A.MOCSOURCE FROM MocSourceData A
            --					 Left JOIN DimMOCType B
            --					 ON  A.MOCSOURCE=B.MOCTypeName
            --					 Where B.MOCTypeName IS NULL
            --					 AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
            --				 )
            --	 END
            --	 UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC source can not be blank,  Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+'MOC source can not be blank,  Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END       
            --		,Srnooferroneousrows=V.SlNo
            --   FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(MOCSOURCE,'')=''
            v_ValidSourceInt NUMBER(10,0) := 0;

         BEGIN
            -- IF OBJECT_ID('tempdb..CalypsoUploadAccMOCPool') IS NOT NULL  
            IF utils.object_id('CalypsoUploadAccMOCPool') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE CalypsoUploadAccMOCPool';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT * 
                                     FROM CalypsoAccountLvlMOCDetails_stg 
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
               DELETE FROM CalypsoUploadAccMOCPool;
               UTILS.IDENTITY_RESET('CalypsoUploadAccMOCPool');

               INSERT INTO CalypsoUploadAccMOCPool SELECT * ,
                                                          UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                          UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                          UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM CalypsoAccountLvlMOCDetails_stg 
                   WHERE  filname = v_FilePathUpload;
               OPEN  v_cursor FOR
                  SELECT 'a' 
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
            -- update A
            -- set A.SourceSystem = B.SourceAlt_Key
            -- from CalypsoUploadAccMOCPool A
            -- INNER JOIN DIMSOURCEDB B 
            -- ON A.SourceSystem = B.SourceName
            --select 'b'
            ------------------------------------------------------------------------------  
            ----SELECT * FROM CalypsoUploadAccMOCPool
            --SlNo	Territory	ACID	InterestReversalAmount	filename
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   ErrorinColumn = 'SlNo,Account ID,POS,Interest Receivable,Balances,Dates',
                   Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') = ' '
              AND NVL(InvestmentIDDerivativeRefNo, ' ') = ' '
              AND NVL(AdditionalProvisionAbsolute, ' ') = ' '

              --AND ISNULL(SourceSystem,'')=''
              AND NVL(BookValueINRMTMValue, ' ') = ' '
              AND NVL(UnservicedInterest, ' ') = ' '
              AND NVL(MOCSource, ' ') = ' '
              AND NVL(MOCReason, ' ') = ' ';
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Excel Vaildate '
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Excel Vaildate'
                      END,
                   Srnooferroneousrows = ' '
             WHERE  NVL(SlNo, ' ') <> ' '
              AND NVL(InvestmentIDDerivativeRefNo, ' ') = ' '
              AND NVL(AdditionalProvisionAbsolute, ' ') = ' '

              --AND ISNULL(SourceSystem,'')=''
              AND NVL(BookValueINRMTMValue, ' ') = ' '
              AND NVL(UnservicedInterest, ' ') = ' '
              AND NVL(MOCSource, ' ') = ' '
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
                               FROM CalypsoUploadAccMOCPool 
                                WHERE  NVL(ErrorMessage, ' ') <> ' ' );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('NO DATA');
               GOTO valid;

            END;
            END IF;
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo cannot be blank . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(SlNo, ' ') = ' '
              OR NVL(SlNo, '0') = '0';
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'SlNo cannot be greater than 16 character . Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  LENGTH(SlNo) > 16;
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Sl. No., kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Sl. No., kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  ( utils.isnumeric(SlNo) = 0
              AND NVL(SlNo, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(SlNo), '%^[0-9]%');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Special characters not allowed, kindly remove and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Special characters not allowed, kindly remove and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'SlNo'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'SlNo'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  REGEXP_LIKE(NVL(SlNo, ' '), '%[,!@#$%^&*()_-+=/]%- \ / _');
            --
            SELECT COUNT(1)  

              INTO v_DuplicateCnt
              FROM CalypsoUploadAccMOCPool 
              GROUP BY SlNo

               HAVING COUNT(SlNo)  > 1;
            IF ( v_DuplicateCnt > 0 ) THEN
             UPDATE CalypsoUploadAccMOCPool V
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
                                        FROM CalypsoUploadAccMOCPool 
                                          GROUP BY SlNo

                                           HAVING COUNT(SlNo)  > 1 )
            ;
            END IF;
            ------------------------------------------------
            /*VALIDATIONS ON AccountID */
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'The column ‘Account ID’ is mandatory. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM CalypsoUploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(InvestmentIDDerivativeRefNo, ' ') = ' ';
            -- ----SELECT * FROM CalypsoUploadAccMOCPool
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.InvestmentIDDerivativeRefNo, ' ') <> ' '
              AND V.InvestmentIDDerivativeRefNo NOT IN ( SELECT invid 
                                                         FROM InvestmentBasicDetail 
                                                          WHERE  EffectiveFromTimeKey <= v_Timekey
                                                                   AND EffectiveToTimeKey >= v_Timekey
                                                         UNION 
                                                         SELECT DerivativeRefNo 
                                                         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail 
                                                          WHERE  EffectiveFromTimeKey <= v_Timekey
                                                                   AND EffectiveToTimeKey >= v_Timekey )
            ;
            IF utils.object_id('TEMPDB..tt_DUB2_20') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_20 ';
            END IF;
            DELETE FROM tt_DUB2_20;
            UTILS.IDENTITY_RESET('tt_DUB2_20');

            INSERT INTO tt_DUB2_20 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY InvestmentIDDerivativeRefNo ORDER BY InvestmentIDDerivativeRefNo  ) rw  
                        FROM CalypsoUploadAccMOCPool  ) X
                WHERE  rw > 1;
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate Account ID found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Account ID found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'Account ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
               END AS pos_3, V.SlNo
            FROM V ,CalypsoUploadAccMOCPool V
                   JOIN tt_DUB2_20 D   ON D.InvestmentIDDerivativeRefNo = V.InvestmentIDDerivativeRefNo ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SlNo;
            ---------------------Authorization for Screen Same acc ID --------------------------
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC – Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.InvestmentIDDerivativeRefNo, ' ') <> ' '
              AND V.InvestmentIDDerivativeRefNo IN ( SELECT AccountID 
                                                     FROM CalypsoAccountLevelMOC_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_Timekey
                                                               AND EffectiveToTimeKey >= v_Timekey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                               AND NVL(Screenflag, ' ') <> 'U' )
            ;
            ---------------------------------------------------------------------------Upload for same account ID--------------
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC Upload– Authorization’ menu'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'You cannot perform MOC, Record is pending for authorization for this Account ID. Kindly authorize or Reject the record through ‘Account Level NPA MOC Upload– Authorization’ menu'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(V.InvestmentIDDerivativeRefNo, ' ') <> ' '
              AND V.InvestmentIDDerivativeRefNo IN ( SELECT AccountID 
                                                     FROM CalypsoAccountLevelMOC_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_Timekey
                                                               AND EffectiveToTimeKey >= v_Timekey
                                                               AND AuthorisationStatus IN ( 'NP','MP','1A','FM' )
             )
            ;--and ISNULL(Screenflag,'') = 'U'
            ---------------------------------------
            --/*VALIDATIONS ON POS in Rs */
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid POSinRs. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid POSinRs. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSinRs' ELSE ErrorinColumn +','+SPACE(1)+  'POSinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								--STUFF((SELECT ','+SlNo 
            ----								--FROM CalypsoUploadAccMOCPool A
            ----								--WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
            ----								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
            ----								--)
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- --WHERE (ISNUMERIC(POSinRs)=0 AND ISNULL(POSinRs,'')<>'') OR 
            -- --ISNUMERIC(POSinRs) LIKE '%^[0-9]%'
            -- PRINT 'INVALID' 
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid POSinRs. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid POSinRs. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSinRs' ELSE ErrorinColumn +','+SPACE(1)+  'POSinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- --WHERE ISNULL(POSinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            --  UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘POS in Rs.’. Kindly check and upload value'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘POS in Rs.’. Kindly check and upload value'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSinRs' ELSE ErrorinColumn +','+SPACE(1)+  'POSinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT SlNo FROM CalypsoUploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
            ----								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
            ----								---- )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            ----WHERE ISNULL(POSinRs,'')<>''
            ----AND (CHARINDEX('.',ISNULL(POSinRs,''))>0  AND Len(Right(ISNULL(POSinRs,''),Len(ISNULL(POSinRs,''))-CHARINDEX('.',ISNULL(POSinRs,''))))>2)
            -----------------------------------------------------------------
            /*validations on MOC Reason */
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid MOC Reason. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid MOC Reasons. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM CalypsoUploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(MOCReason, ' ') NOT IN ( SELECT ParameterName 
                                                 FROM DimParameter 
                                                  WHERE  EffectiveFromTimeKey <= v_Timekey
                                                           AND EffectiveToTimeKey >= v_Timekey
                                                           AND DimParameterName = 'DimMOCReason' )
            ;
            --('Wrong UCIC Linkage','DPD Freeze','Wrong recovery appropriation in source system','Exceptional issue, requires IAD concurrence',
            --'Advances Adjustment','Security Value Update','CNPA','Restructure','Portfolio Buyout-Requires IAD Concurrence','NPA Date update',
            --'Litigation','NPA Settlement','Standard Settlement','Erosion in Security Value','Sale of Assets','RFA/Fraud','Additional Provision','NPA Divergence')
            ---------------------------------------------------------
            /*validations on InterestReceivableinRs */
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InterestReceivableinRs cannot be blank. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'InterestReceivableinRs cannot be blank. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(InterestReceivableinRs,'')=''
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InterestReceivableinRs. Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid InterestReceivableinRs. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								--STUFF((SELECT ','+SlNo 
            ----								--FROM CalypsoUploadAccMOCPool A
            ----								--WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
            ----								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
            ----								--)
            ----								--FOR XML PATH ('')
            ----								--),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- --WHERE (ISNUMERIC(InterestReceivableinRs)=0 AND ISNULL(InterestReceivableinRs,'')<>'') OR 
            -- --ISNUMERIC(InterestReceivableinRs) LIKE '%^[0-9]%'
            -- PRINT 'INVALID' 
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InterestReceivableinRs. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InterestReceivableinRs. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            ----								----)
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- --WHERE ISNULL(InterestReceivableinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'
            --  UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InterestReceivableinRs. Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT SlNo FROM CalypsoUploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
            ----								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
            ----								---- )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- --WHERE ISNULL(InterestReceivableinRs,'')<>''
            ----AND (CHARINDEX('.',ISNULL(InterestReceivableinRs,''))>0  AND Len(Right(ISNULL(InterestReceivableinRs,''),Len(ISNULL(InterestReceivableinRs,''))-CHARINDEX('.',ISNULL(InterestReceivableinRs,''))))>2)
            -----------------------------------------------------------------
            /*validations on Additional Provision - Absolute in Rs. */
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Additional Provision - Absolute in Rs.’. Kindly check and upload value'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Additional Provision - Absolute in Rs.’. Kindly check and upload value'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(AdditionalProvisionAbsoluteinRs,'')=''
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AdditionalProvisionAbsoluteinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AdditionalProvisionAbsoluteinRs'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM CalypsoUploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(AdditionalProvisionAbsolute) = 0
              AND NVL(AdditionalProvisionAbsolute, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(AdditionalProvisionAbsolute), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AdditionalProvisionAbsoluteinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AdditionalProvisionAbsoluteinRs'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM CalypsoUploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(AdditionalProvisionAbsolute, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AdditionalProvisionAbsoluteinRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AdditionalProvisionAbsoluteinRs'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM CalypsoUploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM CalypsoUploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AdditionalProvisionAbsolute, ' ') <> ' '
              AND ( INSTR(NVL(AdditionalProvisionAbsolute, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(AdditionalProvisionAbsolute, ' '), -LENGTH(NVL(AdditionalProvisionAbsolute, ' ')) - INSTR(NVL(AdditionalProvisionAbsolute, ' '), '.'), LENGTH(NVL(AdditionalProvisionAbsolute, ' ')) - INSTR(NVL(AdditionalProvisionAbsolute, ' '), '.'))) > 2 );
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
                        FROM CalypsoUploadAccMOCPool  ) X
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
               UPDATE CalypsoUploadAccMOCPool V
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
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC source can not be blank,  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC source can not be blank,  Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCSOURCE'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCSOURCE'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(MOCSOURCE, ' ') = ' ';
            ---------------------------------------
            /*VALIDATIONS ON BookValueINRMTMValue */
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid BookValueINRMTMValue. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid BookValueINRMTMValue. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'BookValueINRMTMValue'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'BookValueINRMTMValue'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(BookValueINRMTMValue) = 0
              AND NVL(BookValueINRMTMValue, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(BookValueINRMTMValue), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid BookValueINRMTMValue. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid BookValueINRMTMValue. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'BookValueINRMTMValue'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'BookValueINRMTMValue'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(BookValueINRMTMValue, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘BookValueINRMTMValue’. Kindly check and upload value'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘BookValueINRMTMValue’. Kindly check and upload value'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'BookValueINRMTMValue'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'BookValueINRMTMValue'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(BookValueINRMTMValue, ' ') <> ' '
              AND ( INSTR(NVL(BookValueINRMTMValue, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(BookValueINRMTMValue, ' '), -LENGTH(NVL(BookValueINRMTMValue, ' ')) - INSTR(NVL(BookValueINRMTMValue, ' '), '.'), LENGTH(NVL(BookValueINRMTMValue, ' ')) - INSTR(NVL(BookValueINRMTMValue, ' '), '.'))) > 2 );
            -----------------------------------------------------------------
            ---------------------------------------
            /*VALIDATIONS ON UnservicedInterest */
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid UnservicedInterest. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid UnservicedInterest. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnservicedInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnservicedInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								--STUFF((SELECT ','+SlNo 
                    --								--FROM UploadAccMOCPool A
                    --								--WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								--WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR 
                    --								--ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'
                    --								--)
                    --								--FOR XML PATH ('')
                    --								--),1,1,'')   

             WHERE  ( utils.isnumeric(UnservicedInterest) = 0
              AND NVL(UnservicedInterest, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(UnservicedInterest), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('INVALID');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid UnservicedInterest. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid UnservicedInterest. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnservicedInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnservicedInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(UnservicedInterest, ' '), '%[,!@#$%^&*()_-+=/]%');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid value in column ‘UnservicedInterest’. Kindly check and upload value'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid value in column ‘UnservicedInterest’. Kindly check and upload value'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'UnservicedInterest'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'UnservicedInterest'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM UploadAccMOCPool A
                    --								----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(UnservicedInterest, ' ') <> ' '
              AND ( INSTR(NVL(UnservicedInterest, ' '), '.') > 0
              AND LENGTH(SUBSTR(NVL(UnservicedInterest, ' '), -LENGTH(NVL(UnservicedInterest, ' ')) - INSTR(NVL(UnservicedInterest, ' '), '.'), LENGTH(NVL(UnservicedInterest, ' ')) - INSTR(NVL(UnservicedInterest, ' '), '.'))) > 2 );
            -----------------------------------------------------------------
            -----------------------------------MOC Reason-------------------------
            --UPDATE CalypsoUploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Reason Can not be Blank . Please enter the MOC Reason and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'MOC Reason Can not be Blank. Please enter the MOC Reason and upload again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            --WHERE ISNULL(MOCReason,'')='' 
            --UPDATE CalypsoUploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason cannot be greater than 500 characters'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason cannot be greater than 500 characters'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            --WHERE LEN(MOCReason)>500
            -- UPDATE CalypsoUploadAccMOCPool
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'     
            --					ELSE ErrorMessage+','+SPACE(1)+ 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'      END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
            --	,Srnooferroneousrows=V.SlNo
            --	--STUFF((SELECT ','+SlNo 
            --	--						FROM #UploadNewAccount A
            --	--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --	--										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
            --	--										)
            --	--						FOR XML PATH ('')
            --	--						),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            --WHERE LEN(MOCReason) LIKE '%[!@#$%^&*()_+=]%'
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC Reason column is mandatory. Kindly check and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC Reason column is mandatory. Kindly check and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --FROM CalypsoUploadCustMocUpload A
                    --WHERE A.SlNo IN(SELECT V.SlNo  FROM CalypsoUploadCustMocUpload V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(MOCReason, ' ') = ' ';
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC reason cannot be greater than 500 characters'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC reason cannot be greater than 500 characters'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --STUFF((SELECT ','+SlNo 
                    --						FROM #UploadNewAccount A
                    --						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
                    --										WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
                    --										)
                    --						FOR XML PATH ('')
                    --						),1,1,'')   

             WHERE  LENGTH(MOCReason) > 500;
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOC reason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOC reason'
                      END,
                   Srnooferroneousrows = V.SlNo
                   --								----STUFF((SELECT ','+SlNo 
                    --								----FROM CalypsoUploadCustMocUpload A
                    --								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadCustMocUpload V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(MOCReason, ' '), '%[!@#$%^&*()_+=]%');
            UPDATE CalypsoUploadAccMOCPool V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'MOC reason should be as per master values'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MOC reason should be as per master values'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MOCReason'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MOCReason'
                      END,
                   Srnooferroneousrows = V.SlNo
             WHERE  NVL(MOCReason, ' ') <> ' '
              AND NVL(MOCReason, ' ') NOT IN ( SELECT ParameterName 
                                               FROM DimParameter 
                                                WHERE  EffectiveFromTimeKey <= v_Timekey
                                                         AND EffectiveToTimeKey >= v_Timekey
                                                         AND DimParameterName = 'DimMOCReason' )
            ;
            /*VALIDATIONS ON TWO Date */
            --UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TwoDate' ELSE   ErrorinColumn +','+SPACE(1)+'TwoDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(TWODate,'')<>'' AND ISDATE(TWODate)=0
            --  UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘TWO Date’ is mandatory. Kindly check and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'The column ‘TWO Date’ is mandatory. Kindly check and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TWO Date' ELSE ErrorinColumn +','+SPACE(1)+  'TWO Date' END  
            --		,Srnooferroneousrows=V.SlNo
            ----								----STUFF((SELECT ','+SlNo 
            ----								----FROM CalypsoUploadAccMOCPool A
            ----								----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V  
            ----								----				WHERE ISNULL(ACID,'')='' )
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            --FROM CalypsoUploadAccMOCPool V  
            -- WHERE ISNULL(Twodate,'')=''  --and ISNULL(TWOFlag,'') = 'Y'
            -- UPDATE CalypsoUploadAccMOCPool
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'TWO date must be less than equal to current date. Kindly check and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'TWO date must be less than equal to current date. Kindly check and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TwoDate' ELSE   ErrorinColumn +','+SPACE(1)+'TwoDate' END      
            --		,Srnooferroneousrows=V.SlNo
            --		--STUFF((SELECT ','+SlNo 
            --		--						FROM #UploadNewAccount A
            --		--						WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --		--										  WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))
            --		--										)
            --		--						FOR XML PATH ('')
            --		--						),1,1,'')   
            -- FROM CalypsoUploadAccMOCPool V  
            --WHERE (Case When ISDATE(Twodate)=1 Then Case When Cast(Twodate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1
            -------------------------------Validations on TWO Amount-----------------
            -----------------------------------------------------------
            --select * from DimMOCType
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
                                FROM CalypsoAccountLvlMOCDetails_stg 
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
                FROM CalypsoUploadAccMOCPool  );
            --	----SELECT * FROM CalypsoUploadAccMOCPool 
            --	--ORDER BY ErrorMessage,CalypsoUploadAccMOCPool.ErrorinColumn DESC
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
         DBMS_OUTPUT.PUT_LINE('Jayadev');
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
            DBMS_OUTPUT.PUT_LINE('Jayadev1');
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM CalypsoAccountLvlMOCDetails_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE CalypsoAccountLvlMOCDetails_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE('Jayadev2');
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.CalypsoAccountLvlMOCDetails_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM CalypsoUploadAccMOCPool
         DBMS_OUTPUT.PUT_LINE('p');

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ------to delete file if it has errors
      --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
      --begin
      --print 'ppp'
      -- IF EXISTS(SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
      -- BEGIN
      -- print '123'
      -- DELETE FROM CalypsoAccountLvlMOCDetails_stg
      -- WHERE filename=@FilePathUpload
      -- PRINT 'ROWS DELETED FROM DBO.CalypsoAccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      -- END
      -- END
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  --IF EXISTS(SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)
                 --	 BEGIN
                 --	 DELETE FROM CalypsoAccountLvlMOCDetails_stg
                 --	 WHERE filename=@FilePathUpload
                 --	 PRINT 'ROWS DELETED FROM DBO.CalypsoAccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
                 ,--	 END
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_CALYPSOACCNPAMOCUPLOAD_28042023" TO "ADF_CDR_RBL_STGDB";
