--------------------------------------------------------
--  DDL for Procedure VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" 
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
--fnachecker_RestructuredAssetsUpload.xlsx
--DECLARE  
--@MenuID INT=24714,  
--@UserLoginId varchar(20)='fnachecker',  
--@Timekey int=49999
--,@filepath varchar(500)='RestructuredAssetsUpload.xlsx'  

BEGIN

   BEGIN
      DECLARE
         v_FilePathUpload VARCHAR2(100);
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         --BEGIN TRAN  
         --Declare @TimeKey int  
         --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
         --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
         -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
         --Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)
         SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

           INTO v_Timekey
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
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
         IF ( v_MenuID = 24714 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            -----------------SELECT * FROM RetsructuredAssetsUpload_stg
            -- IF OBJECT_ID('tempdb..RestructureAssets') IS NOT NULL  
            IF utils.object_id('RestructureAssets') IS NOT NULL THEN

            BEGIN
               EXECUTE IMMEDIATE 'DROP TABLE RestructureAssets';

            END;
            END IF;
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE NOT ( EXISTS ( SELECT 1 
                                     FROM RetsructuredAssetsUpload_stg 
                                      WHERE  filname = v_FilePathUpload ) );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN


            ----update RetsructuredAssetsUpload_stg set filname='2ndlvlchecker_RestructuredAssetsUpload.xlsx'
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
               DELETE FROM RestructureAssets;
               UTILS.IDENTITY_RESET('RestructureAssets');

               INSERT INTO RestructureAssets SELECT * ,
                                                    UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorMessage  ,
                                                    UTILS.CONVERT_TO_VARCHAR2(' ',4000) ErrorinColumn  ,
                                                    UTILS.CONVERT_TO_VARCHAR2(' ',4000) Srnooferroneousrows  
                    FROM RetsructuredAssetsUpload_stg 
                   WHERE  filname = v_FilePathUpload;

            END;
            END IF;
            --drop table RestructureAssets
            --alter table select * from RetsructuredAssetsUpload_stg
            --alter column POSasonDateofRstrctr varchar(max)
            ------------------------------------------------------------------------------  
            ----SELECT * FROM RestructureAssets
            --SrNo	Territory	ACID	InterestReversalAmount	filname
            UPDATE RestructureAssets V
               SET V.ErrorMessage = 'There is no data in excel. Kindly check and upload again',
                   V.ErrorinColumn = 'Pool ID,Pool Name,Customer ID,Account ID,POS,Interest Receivable,Balances,Dates',
                   V.Srnooferroneousrows = ' '
             WHERE  NVL(SrNo, ' ') = ' '
              AND NVL(RestructureFacility, ' ') = ' '
              AND NVL(RevisedBusinessSeg, ' ') = ' '
              AND NVL(AccountID, ' ') = ' '
              AND NVL(DisbursementDate, ' ') = ' '
              AND NVL(ReferenceDate, ' ') = ' '
              AND NVL(InvocationDate, ' ') = ' '
              AND NVL(DateofConversionintoEquity, ' ') = ' '
              AND NVL(PrinRpymntStartDate, ' ') = ' '
              AND NVL(InttRpymntStartDate, ' ') = ' '
              AND NVL(AssetClassatRstrctr, ' ') = ' '
              AND NVL(NPADate, ' ') = ' '
              AND NVL(NPAQuarter, ' ') = ' '
              AND NVL(TypeofRestructuring, ' ') = ' '
              AND NVL(CovidMoratoriamMSME, ' ') = ' '
              AND NVL(CovidOTRCategory, ' ') = ' '
              AND NVL(BankingRelationship, ' ') = ' '
              AND NVL(DateofRestructuring, ' ') = ' '
              AND NVL(RestructuringApprovingAuth, ' ') = ' '
              AND NVL(DateofIstDefaultonCRILIC, ' ') = ' '
              AND NVL(ReportingBank, ' ') = ' '
              AND NVL(DateofSigningICA, ' ') = ' '
              AND NVL(OSasonDateofRstrctr, ' ') = ' '
              AND NVL(POSasonDateofRstrctr, ' ') = ' '
              AND NVL(InvestmentGrade, ' ') = ' '
              AND NVL(CreditProvisionRs, ' ') = ' '
              AND NVL(DFVProvisionRs, ' ') = ' '
              AND NVL(MTMProvisionRs, ' ') = ' ';
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM RestructureAssets 
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
            -- /*validations on POOLID*/
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'POOLID cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'POOLID cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POOLID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(PoolID,'')=''
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid PoolID.  Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid PoolID.  Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(PoolID,'')<>''
            --AND LEN(PoolID)>20
            /*validations on Restructure Facility*/
            DBMS_OUTPUT.PUT_LINE('A');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Restructure Facility cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Restructure Facility cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Restructure Facility'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Restructure Facility'
                      END,
                   V.Srnooferroneousrows = V.SrNo
                   --STUFF((SELECT ','+SRNO 
                    --FROM RestructureAssets A
                    --WHERE A.SrNo IN(SELECT V.SrNo  FROM RestructureAssets V  
                    --WHERE ISNULL(SOLID,'')='')
                    --FOR XML PATH ('')
                    --),1,1,'')

             WHERE  NVL(RestructureFacility, ' ') = ' ';
            --select * from RestructureAssets where PoolType  in  ('With Risk' , 'With out Risk')
            DBMS_OUTPUT.PUT_LINE('A1');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Restructure Facility.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Restructure Facility.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Restructure Facility'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Restructure Facility'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(RestructureFacility, ' ') <> ' '
              AND LENGTH(RestructureFacility) > 20;
            DBMS_OUTPUT.PUT_LINE('A2');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Restructure Facility.  Please check the values With Restructured OR Additional Finance OR FITL OR Other and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Restructure Facility.  Please check the values With Restructured OR Additional Finance OR FITL OR Other and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Restructure Facility'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Restructure Facility'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  RestructureFacility NOT IN ( 'Restructured','Additional Finance','FITL','Other' )
            ;
            /*validations on Revised Business Seg*/
            DBMS_OUTPUT.PUT_LINE('A');
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Revised Business Seg cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Revised Business Seg cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Revised Business Seg' ELSE   ErrorinColumn +','+SPACE(1)+'Revised Business Seg' END   
            --	,Srnooferroneousrows=V.SrNo
            --							--STUFF((SELECT ','+SRNO 
            --							--FROM RestructureAssets A
            --							--WHERE A.SrNo IN(SELECT V.SrNo  FROM RestructureAssets V  
            --							--WHERE ISNULL(SOLID,'')='')
            --							--FOR XML PATH ('')
            --							--),1,1,'')
            --  FROM RestructureAssets V  
            --WHERE ISNULL(RevisedBusinessSeg,'')=''
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Revised Business Seg,special characters - , /\ are allowed . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Revised Business Seg,special characters - , /\ are allowed . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Revised Business Seg'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Revised Business Seg'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  REGEXP_LIKE(NVL(RevisedBusinessSeg, ' '), '%[!@#$%^&*(),_+=]%');
            -------------------------------------------------------
            /*validations on Banking Relationship*/
            DBMS_OUTPUT.PUT_LINE('A3');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Banking Relationship cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Banking Relationship cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Banking Relationship'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Banking Relationship'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(BankingRelationship, ' ') = ' ';
            --select * from RestructureAssets where PoolType  in  ('With Risk' , 'With out Risk')
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Banking Relationship.  Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Banking Relationship.  Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Banking Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Banking Relationship' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(BankingRelationship,'')<>''
            -- AND LEN(BankingRelationship)>20
            DBMS_OUTPUT.PUT_LINE('A4');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Banking Relationship.  Please check the values 
                                         		With Sole Banking OR Multiple Banking OR Consortium OR Consortium-WC OR Consortium-TL OR WC-MBA OR TL-MBA and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Banking Relationship.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Banking Relationship'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Banking Relationship'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  BankingRelationship NOT IN ( 'Sole Banking','Multiple Banking','Consortium','Consortium-WC','Consortium-TL','WC-MBA','TL-MBA',' ' )
            ;
            DBMS_OUTPUT.PUT_LINE('A5');
            ---------------------------------------------------------------------------------------------------------------------
            /*validations on Type of Restructuring*/
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Type of Restructuring cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Type of Restructuring cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Type of Restructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Type of Restructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') = ' ';
            --select * from RestructureAssets where PoolType  in  ('With Risk' , 'With out Risk')
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Banking Relationship.  Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Banking Relationship.  Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Banking Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Banking Relationship' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(BankingRelationship,'')<>''
            -- AND LEN(BankingRelationship)>20
            DBMS_OUTPUT.PUT_LINE('A6');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Type of Restructuring.  Please check the values 
                                         		With IRAC OR Prudential Framework_June 07 Circular OR Resolution Framework_Covid OTR OR MSME_Old Circular OR MSME_Covid Circular
                                         		    OR DCCO OR Natural Calamity OR BIFR OR Other  and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Type of Restructuring.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TypeofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TypeofRestructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') NOT IN ( 'IRAC','Prudential Framework_June 07 Circular','Resolution Framework_Covid OTR','MSME_Old Circular','MSME_Covid Circular','DCCO','Natural Calamity','BIFR','Other' )
            ;
            ---------------------------------------------------------------------------------------------------------------------
            /*validations on Covid Moratoriam MSME*/
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CovidMoratoriamMSME cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'CovidMoratoriamMSME cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CovidMoratoriamMSME' ELSE   ErrorinColumn +','+SPACE(1)+'CovidMoratoriamMSME' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(CovidMoratoriamMSME,'')=''
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CovidMoratoriamMSME cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CovidMoratoriamMSME cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CovidMoratoriamMSME'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CovidMoratoriamMSME'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') IN ( 'MSME_Old Circular','MSME_Covid Circular' )

              AND NVL(CovidMoratoriamMSME, ' ') NOT IN ( 'Y','N','NA' )
            ;
            --------------------------------------------------------------------------------------------
            /*validations on Covid - OTR Category*/
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'CovidOTRCategory cannot be blank . Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'CovidOTRCategory cannot be blank . Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CovidOTRCategory' ELSE   ErrorinColumn +','+SPACE(1)+'CovidOTRCategory' END   
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(CovidOTRCategory,'')=''
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'In case otherwise display "Invalid Value entered in column Covid - OTR Category. Kindly enter either of the mentioned values and try again - Personal, other'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'In case otherwise display "Invalid Value entered in column Covid - OTR Category. Kindly enter either of the mentioned values and try again - Personal, other'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CovidOTRCategory'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CovidOTRCategory'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') IN ( 'Resolution Framework_Covid OTR' )

              AND NVL(CovidOTRCategory, ' ') NOT IN ( 'Personal','Other' )
            ;
            -----------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('A7');
            /*VALIDATIONS ON AccountID */
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID cannot be blank.  Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID cannot be blank.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   V.Srnooferroneousrows = V.SRNO
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM RestructureAssets A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM RestructureAssets V  
                    --								----				WHERE ISNULL(ACID,'')='' )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(AccountID, ' ') = ' ';
            -- ----SELECT * FROM RestructureAssets
            DBMS_OUTPUT.PUT_LINE('A8');
            UPDATE RestructureAssets V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Account ID found. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Account ID found. Please check the values and upload again'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SRNO
             WHERE  NVL(V.AccountID, ' ') <> ' '
              AND V.AccountID NOT IN ( SELECT CustomerACID 
                                       FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail 
                                        WHERE  EffectiveFromTimeKey <= v_Timekey
                                                 AND EffectiveToTimeKey >= v_Timekey )
            ;
            IF utils.object_id('TEMPDB..tt_DUB2_28') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DUB2_28 ';
            END IF;
            DELETE FROM tt_DUB2_28;
            UTILS.IDENTITY_RESET('tt_DUB2_28');

            INSERT INTO tt_DUB2_28 SELECT * 
                 FROM ( SELECT * ,
                               ROW_NUMBER() OVER ( PARTITION BY AccountID ORDER BY AccountID  ) rw  
                        FROM RestructureAssets  ) X
                WHERE  rw > 1;
            DBMS_OUTPUT.PUT_LINE('A9');
            MERGE INTO V 
            USING (SELECT V.ROWID row_id, CASE 
            WHEN NVL(V.ErrorMessage, ' ') = ' ' THEN 'Duplicate Account ID found. Please check the values and upload again'
            ELSE V.ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Duplicate Account ID found. Please check the values and upload again'
               END AS pos_2, CASE 
            WHEN NVL(V.ErrorinColumn, ' ') = ' ' THEN 'Account ID'
            ELSE V.ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
               END AS pos_3, V.SRNO
            FROM V ,RestructureAssets V
                   JOIN tt_DUB2_28 D   ON D.AccountID = V.AccountID ) src
            ON ( V.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET ErrorMessage = pos_2,
                                         ErrorinColumn = pos_3,
                                         Srnooferroneousrows = src.SRNO;
            DBMS_OUTPUT.PUT_LINE('A10');
            UPDATE RestructureAssets V
               SET ErrorMessage = CASE 
                                       WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Account ID are pending for authorization'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Account ID are pending for authorization'
                      END,
                   ErrorinColumn = CASE 
                                        WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Account ID'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Account ID'
                      END,
                   Srnooferroneousrows = V.SRNO
             WHERE  NVL(V.AccountID, ' ') <> ' '
              AND V.AccountID IN ( SELECT AccountID 
                                   FROM RestructureAsset_Upload_Mod 
                                    WHERE  EffectiveFromTimeKey <= v_Timekey
                                             AND EffectiveToTimeKey >= v_Timekey
                                             AND AuthorisationStatus IN ( 'NP','MP','1A','FM' )
             )
            ;
            --------------------DisbursementDate
            DBMS_OUTPUT.PUT_LINE('An1');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'DisbursementDate Can not be Blank . Please enter the DisbursementDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DisbursementDate Can not be Blank. Please enter the DisbursementDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DisbursementDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DisbursementDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DisbursementDate, ' ') = ' ';
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DisbursementDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DisbursementDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DisbursementDate, ' ') <> ' '
              AND utils.isdate(DisbursementDate) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DisbursementDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DisbursementDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DisbursementDate) = 1 THEN CASE 
                                                                            WHEN UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                          ELSE 0
                             END   END) = 1;
            --WHERE (Case When ISDATE(DisbursementDate)=1 Then Case When Cast(DisbursementDate as date)>Cast(GETDATE() as Date) Then 1
            --            WHEN ISDATE(DisbursementDate)=1 Then Case When Cast(DisbursementDate as date)>Cast(GETDATE() as Date) Then 1 Else 0  END END )=1
            --select isdate(getdate())
            ------------------------------------------------ReferenceDate --------------------
            DBMS_OUTPUT.PUT_LINE('An2');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ReferenceDate Can not be Blank . Please enter the ReferenceDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ReferenceDate Can not be Blank. Please enter the ReferenceDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ReferenceDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ReferenceDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(ReferenceDate, ' ') = ' ';
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ReferenceDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ReferenceDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(ReferenceDate, ' ') <> ' '
              AND utils.isdate(ReferenceDate) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ReferenceDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ReferenceDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(ReferenceDate) = 1 THEN CASE 
                                                                         WHEN UTILS.CONVERT_TO_VARCHAR2(ReferenceDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                         WHEN UTILS.CONVERT_TO_VARCHAR2(ReferenceDate,200) < UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            ------------------------------------------------InvocationDate --------------------
            DBMS_OUTPUT.PUT_LINE('An3');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'InvocationDate Can not be Blank . Please enter the InvocationDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'InvocationDate Can not be Blank. Please enter the InvocationDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InvocationDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InvocationDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(InvocationDate, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('An33');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InvocationDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InvocationDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(InvocationDate, ' ') <> ' '
              AND utils.isdate(InvocationDate) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Disbursement Date '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InvocationDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InvocationDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(InvocationDate) = 1 THEN CASE 
                                                                          WHEN UTILS.CONVERT_TO_VARCHAR2(InvocationDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                          WHEN UTILS.CONVERT_TO_VARCHAR2(InvocationDate,200) < UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            ---------------------------------------------------------------------------
            ------------------------------------------------DateofConversionintoEquity --------------------
            DBMS_OUTPUT.PUT_LINE('An4');
            --UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofConversionintoEquity Can not be Blank . Please enter the DateofConversionintoEquity and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DateofConversionintoEquity Can not be Blank. Please enter the DateofConversionintoEquity and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofConversionintoEquity' ELSE   ErrorinColumn +','+SPACE(1)+'DateofConversionintoEquity' END   
            --		,Srnooferroneousrows=V.SrNo
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(DateofConversionintoEquity,'')='' 
            DBMS_OUTPUT.PUT_LINE('An44');
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofConversionintoEquity'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofConversionintoEquity'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofConversionintoEquity, ' ') <> ' '
              AND utils.isdate(DateofConversionintoEquity) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Disbursement Date '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofConversionintoEquity'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofConversionintoEquity'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofConversionintoEquity) = 1 THEN CASE 
                                                                                      WHEN UTILS.CONVERT_TO_VARCHAR2(DateofConversionintoEquity,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                                      WHEN UTILS.CONVERT_TO_VARCHAR2(DateofConversionintoEquity,200) < UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            ---------------------------------------------------------------------------
            ------------------------------------------------PrinRpymntStartDate --------------------
            DBMS_OUTPUT.PUT_LINE('An5');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'PrinRpymntStartDate Can not be Blank . Please enter the PrinRpymntStartDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'PrinRpymntStartDate Can not be Blank. Please enter the PrinRpymntStartDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrinRpymntStartDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrinRpymntStartDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(PrinRpymntStartDate, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('An55');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrinRpymntStartDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrinRpymntStartDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(PrinRpymntStartDate, ' ') <> ' '
              AND utils.isdate(PrinRpymntStartDate) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Disbursement Date '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'PrinRpymntStartDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'PrinRpymntStartDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(PrinRpymntStartDate) = 1 THEN CASE 
                                                                               WHEN UTILS.CONVERT_TO_VARCHAR2(PrinRpymntStartDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                               WHEN UTILS.CONVERT_TO_VARCHAR2(PrinRpymntStartDate,200) < UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            ------------------------------------------------InttRpymntStartDate --------------------
            DBMS_OUTPUT.PUT_LINE('An6');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'InttRpymntStartDate Can not be Blank . Please enter the InttRpymntStartDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'InttRpymntStartDate Can not be Blank. Please enter the InttRpymntStartDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InttRpymntStartDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InttRpymntStartDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(InttRpymntStartDate, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('An66');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InttRpymntStartDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InttRpymntStartDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(InttRpymntStartDate, ' ') <> ' '
              AND utils.isdate(InttRpymntStartDate) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Disbursement Date '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'InttRpymntStartDate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'InttRpymntStartDate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(InttRpymntStartDate) = 1 THEN CASE 
                                                                               WHEN UTILS.CONVERT_TO_VARCHAR2(InttRpymntStartDate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                               WHEN UTILS.CONVERT_TO_VARCHAR2(InttRpymntStartDate,200) < UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            ------------------------------------------------InttRpymntStartDate --------------------
            DBMS_OUTPUT.PUT_LINE('An6');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'AssetClassatRstrctr Can not be Blank . Please enter the InttRpymntStartDate and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'AssetClassatRstrctr Can not be Blank. Please enter the InttRpymntStartDate and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AssetClassatRstrctr'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AssetClassatRstrctr'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AssetClassatRstrctr, ' ') = ' ';
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Value entered in column Asset Class at Rstrctr. Kindly enter either of the mentioned values and try again - STD,SUB,DB1,DB2,DB3,LOS '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Value entered in column Asset Class at Rstrctr. Kindly enter either of the mentioned values and try again - STD,SUB,DB1,DB2,DB3,LOS'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'AssetClassatRstrctr'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'AssetClassatRstrctr'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AssetClassatRstrctr, ' ') NOT IN ( 'STD','SUB','DB1','DB2','DB3','LOS' )
            ;
            ------------------------------------------------NPADate --------------------
            DBMS_OUTPUT.PUT_LINE('An7');
            --UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPADate Can not be Blank . Please enter the NPADate and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'NPADate Can not be Blank. Please enter the NPADate and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPADate' ELSE   ErrorinColumn +','+SPACE(1)+'NPADate' END      
            --		,Srnooferroneousrows=V.SrNo
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(NPADate,'')='' 
            DBMS_OUTPUT.PUT_LINE('An77');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(NPADate, ' ') <> ' '
              AND utils.isdate(NPADate) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Disbursement Date '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Disbursement Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(NPADate) = 1 THEN CASE 
                                                                   WHEN UTILS.CONVERT_TO_VARCHAR2(NPADate,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                   WHEN UTILS.CONVERT_TO_VARCHAR2(NPADate,200) < UTILS.CONVERT_TO_VARCHAR2(DisbursementDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ASSET Class is NPA. Please enter NPA DATE'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ASSET Class is NPA. Please enter NPA DATE'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPADate'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPADate'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AssetClassatRstrctr, ' ') IN ( 'SUB','DB1','DB2','DB3','LOS' )

              AND NVL(NPADate, ' ') = ' ';
            ---------------------------------------------------------------------------
            ------------------------------------------------NPA Quarter --------------------
            DBMS_OUTPUT.PUT_LINE('An7');
            --UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Quarter Can not be Blank . Please enter the NPA Quarter and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'NPA Quarter Can not be Blank. Please enter the NPA Quarter and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPA Quarter' ELSE   ErrorinColumn +','+SPACE(1)+'NPA Quarter' END      
            --		,Srnooferroneousrows=V.SrNo
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(NPAQuarter,'')='' 
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ASSET Class is NPA. Please enter NPA Quarter'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ASSET Class is NPA. Please enter NPA Quarter'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'NPA Quarter'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'NPA Quarter'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(AssetClassatRstrctr, ' ') IN ( 'SUB','DB1','DB2','DB3','LOS' )

              AND NVL(NPAQuarter, ' ') = ' ';
            ---------------------------------------------------------------------------------------------------------------------
            /*validations on Type of Restructuring*/
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Type of Restructuring cannot be blank . Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Type of Restructuring cannot be blank . Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Type of Restructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Type of Restructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') = ' ';
            --select * from RestructureAssets where PoolType  in  ('With Risk' , 'With out Risk')
            -- UPDATE RestructureAssets
            --SET  
            --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Banking Relationship.  Please check the values and upload again'     
            --					ELSE ErrorMessage+','+SPACE(1)+'Invalid Banking Relationship.  Please check the values and upload again'     END
            --	,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Banking Relationship' ELSE   ErrorinColumn +','+SPACE(1)+'Banking Relationship' END       
            --	,Srnooferroneousrows=V.SrNo
            --  FROM RestructureAssets V  
            --WHERE ISNULL(BankingRelationship,'')<>''
            -- AND LEN(BankingRelationship)>20
            --Print 'A6'
            --  UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Type of Restructuring.  Please check the values 
            --		With IRAC OR Prudential Framework_June 07 Circular OR Resolution Framework_Covid OTR OR MSME_Old Circular OR MSME_Covid Circular
            --		    OR DCCO OR Natural Calamity OR BIFR OR Other  and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+'Invalid Type of Restructuring.  Please check the values and upload again'     END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TypeofRestructuring' ELSE   ErrorinColumn +','+SPACE(1)+'TypeofRestructuring' END     
            --		,Srnooferroneousrows=V.SrNo
            --   FROM RestructureAssets V  
            -- WHERE ISNULL(TypeofRestructuring,'')  NOT in  ('IRAC' , 'Prudential Framework_June 07 Circular','Resolution Framework_Covid OTR'
            --                                          ,'MSME_Old Circular','MSME_Covid Circular','DCCO','Natural Calamity','BIFR','Other')
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid Type of Restructuring.  Please check the values 
                                         		With IRAC OR Prudential Framework_June 07 Circular OR Resolution Framework_Covid OTR OR MSME_Old Circular OR MSME_Covid Circular
                                         		    OR DCCO OR Natural Calamity OR BIFR OR Other  and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid Type of Restructuring.  Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'TypeofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'TypeofRestructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') NOT IN ( 'IRAC','Prudential Framework_June 07 Circular','Resolution Framework_Covid OTR','MSME_Old Circular','MSME_Covid Circular','DCCO','Natural Calamity','BIFR','Other' )
            ;
            ------------------------------------------------DateofRestructuring --------------------
            DBMS_OUTPUT.PUT_LINE('An8');
            --UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofRestructuring Can not be Blank . Please enter the DateofRestructuring and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DateofRestructuring Can not be Blank. Please enter the DateofRestructuring and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofRestructuring' ELSE   ErrorinColumn +','+SPACE(1)+'DateofRestructuring' END      
            --		,Srnooferroneousrows=V.SrNo
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(DateofRestructuring,'')='' 
            DBMS_OUTPUT.PUT_LINE('An88');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofRestructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofRestructuring, ' ') <> ' '
              AND utils.isdate(DateofRestructuring) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Invocation Date  '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Invocation Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofRestructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofRestructuring) = 1 THEN CASE 
                                                                               WHEN UTILS.CONVERT_TO_VARCHAR2(DateofRestructuring,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                               WHEN UTILS.CONVERT_TO_VARCHAR2(DateofRestructuring,200) < UTILS.CONVERT_TO_VARCHAR2(InvocationDate,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of Restructuring can not be blank. Please check and Upload again  '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of Restructuring can not be blank. Please check and Upload again '
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofRestructuringf'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') <> ' '
              AND NVL(DateofRestructuring, ' ') = ' ';
            ---------------------------------------------------------------------------
            ------------------------------------------------Restructuring Approving Auth --------------------
            DBMS_OUTPUT.PUT_LINE('An8');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Restructuring Approving Auth Can not be Blank . Please enter the Restructuring Approving Auth and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DateofRestructuring Can not be Blank. Please enter the DateofRestructuring and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Restructuring Approving Auth'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Restructuring Approving Auth'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(TypeofRestructuring, ' ') <> ' '
              AND NVL(RestructuringApprovingAuth, ' ') = ' ';
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'For Restructuring Approving Auth column, special characters -  /\ are allowed. Kindly check and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'For Restructuring Approving Auth, special characters -  /\ are allowed. Kindly check and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Restructuring Approving Auth'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Restructuring Approving Auth'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  REGEXP_LIKE(NVL(RestructuringApprovingAuth, ' '), '%[!@#$%^&*(),_+=]%');
            ------------------------------------------------Date of Ist Default on CRILIC --------------------
            DBMS_OUTPUT.PUT_LINE('An8');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofIstDefaultonCRILIC'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofIstDefaultonCRILIC'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofIstDefaultonCRILIC, ' ') <> ' '
              AND utils.isdate(DateofIstDefaultonCRILIC) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Invocation Date  '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Invocation Date'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofRestructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofIstDefaultonCRILIC) = 1 THEN CASE 
                                                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(DateofIstDefaultonCRILIC,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                                    WHEN UTILS.CONVERT_TO_VARCHAR2(DateofIstDefaultonCRILIC,200) < UTILS.CONVERT_TO_VARCHAR2(DateofRestructuring,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            ------------------------------------------------Reporting Bank --------------------
            DBMS_OUTPUT.PUT_LINE('An8');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'ReportingBank can not be blank. Please check and Upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'ReportingBank can not be blank. Please check and Upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ReportingBank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ReportingBank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofIstDefaultonCRILIC, ' ') <> ' '
              AND NVL(ReportingBank, ' ') = ' ';
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Reporting Bank column, special characters -  /\ are allowed. Kindly check and try again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Reporting Bank column, special characters -  /\ are allowed. Kindly check and try again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'ReportingBank'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'ReportingBank'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  REGEXP_LIKE(NVL(RestructuringApprovingAuth, ' '), '%[!@#$%^&*(),_+=]%');
            ------------------------------------------------DateofSigningICA --------------------
            --UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofSigningICA Can not be Blank . Please enter the DateofSigningICA and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DateofSigningICA Can not be Blank. Please enter the DateofSigningICA and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofSigningICA' ELSE   ErrorinColumn +','+SPACE(1)+'DateofSigningICA' END      
            --		,Srnooferroneousrows=V.SrNo
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(DateofSigningICA,'')='' 
            DBMS_OUTPUT.PUT_LINE('An99');
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSigningICA'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSigningICA'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(DateofSigningICA, ' ') <> ' '
              AND utils.isdate(DateofSigningICA) = 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid date format.Date should be less than equal to current date and greater than Date of Restructuring  '
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid date format. Date should be less than equal to current date and greater than Date of Restructuring'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofRestructuring'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofRestructuring'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  (CASE 
                          WHEN utils.isdate(DateofSigningICA) = 1
                            AND utils.isdate(DateofRestructuring) = 1 THEN CASE 
                                                                                WHEN UTILS.CONVERT_TO_VARCHAR2(DateofSigningICA,200) > UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) THEN 1
                                                                                WHEN UTILS.CONVERT_TO_VARCHAR2(DateofSigningICA,200) < UTILS.CONVERT_TO_VARCHAR2(DateofRestructuring,200) THEN 2
                          ELSE 0
                             END   END) IN ( 1,2 )
            ;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Date of Signing ICA can not be blank. Please check and upload again.'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Date of Signing ICA can not be blank. Please check and upload again.'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DateofSigningICA'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DateofSigningICA'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(CovidOTRCategory, ' ') IN ( 'Others' )

              AND NVL(BankingRelationship, ' ') IN ( 'Consortium','Consortium-WC','Consortium-TL','WC-MBA','TL-MBA' )

              AND NVL(DateofSigningICA, ' ') = ' ';
            ---------------------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('An10');
            ------------------------------------------------O/S as on date of Rstrctr --------------------
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'O/S as on date of Rstrctr Can only be Numeric . Please enter the O/S as on date of Rstrctr and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'O/S as on date of Rstrctr Can only be Numeric . Please enter the O/S as on date of Rstrctr and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'O/S as on date of Rstrctr'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'O/S as on date of Rstrctr'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(OSasonDateofRstrctr) = 0
              AND NVL(OSasonDateofRstrctr, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(OSasonDateofRstrctr), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('An99');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'O/S as on date of Rstrctr Can not be Blank . Please enter the O/S as on date of Rstrctr and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'O/S as on date of Rstrctr Can not be Blank . Please enter the O/S as on date of Rstrctr and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'O/S as on date of Rstrctr'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'O/S as on date of Rstrctr'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(OSasonDateofRstrctr, ' ') = ' '
              AND NVL(TypeofRestructuring, ' ') <> ' ';
            ------------------------------------------------POS as on date of Rstrctr--------------------
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'POS as on date of Rstrctr Can only be Numeric . Please enter the POS as on date of Rstrctr and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'POS as on date of Rstrctr Can only be Numeric . Please enter the POS as on date of Rstrctr and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'POS as on date of Rstrctr'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'POS as on date of Rstrctr'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( utils.isnumeric(POSasonDateofRstrctr) = 0
              AND NVL(POSasonDateofRstrctr, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(POSasonDateofRstrctr), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('An99');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'POS as on date of Rstrctr Can not be Blank . Please enter the POS as on date of Rstrctr and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'POS as on date of Rstrctr Can not be Blank . Please enter the POS as on date of Rstrctr and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'POS as on date of Rstrctr'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'POS as on date of Rstrctr'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  NVL(OSasonDateofRstrctr, ' ') = ' '
              AND NVL(TypeofRestructuring, ' ') <> ' ';
            ------------------------------------------------Investment Grade--------------------
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'No value expected when Banking Relation is other than Consortium, Consortium-WC, Consortium-TL, WC-MBC, TL-MBA'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'No value expected when Banking Relation is other than Consortium, Consortium-WC, Consortium-TL, WC-MBC, TL-MBA'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Investment Grade'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Investment Grade'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( NVL(BankingRelationship, ' ') NOT IN ( 'Consortium','Consortium-WC','Consortium-TL','WC-MBA','TL-MBA' )

              AND NVL(InvestmentGrade, ' ') <> 'NA' );
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'This column is mandatory when Banking Relation is either Consortium, Consortium-WC, Consortium-TL, WC-MBC, TL-MBA. Kindly enter Y or N and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'This column is mandatory when Banking Relation is either Consortium, Consortium-WC, Consortium-TL, WC-MBC, TL-MBA. Kindly enter Y or N and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'Investment Grade'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'Investment Grade'
                      END,
                   V.Srnooferroneousrows = V.SrNo
             WHERE  ( NVL(BankingRelationship, ' ') IN ( 'Consortium','Consortium-WC','Consortium-TL','WC-MBA','TL-MBA' )

              AND NVL(InvestmentGrade, ' ') NOT IN ( 'Yes','No' )
             );
            -----------------------------------------------CreditProvisionRs
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'CreditProvisionRs cannot be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs cannot be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CreditProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM RestructureAssets A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM RestructureAssets V
                    --								----WHERE ISNULL(InterestReversalAmount,'')='')
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CreditProvisionRs, ' ') = ' ';
            DBMS_OUTPUT.PUT_LINE('An101');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CreditProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CreditProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CreditProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  ( utils.isnumeric(CreditProvisionRs) = 0
              AND NVL(CreditProvisionRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(CreditProvisionRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('An11');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CreditProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CreditProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CreditProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM RestructureAssets A
                    --								----WHERE A.SrNo IN(SELECT V.SrNo FROM RestructureAssets V
                    --								---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
                    --								----)
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  REGEXP_LIKE(NVL(CreditProvisionRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            DBMS_OUTPUT.PUT_LINE('An111');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid CreditProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid CreditProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CreditProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
                   --								----STUFF((SELECT ','+SRNO 
                    --								----FROM RestructureAssets A
                    --								----WHERE A.SrNo IN(SELECT SRNO FROM RestructureAssets WHERE ISNULL(InterestReversalAmount,'')<>''
                    --								---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
                    --								---- )
                    --								----FOR XML PATH ('')
                    --								----),1,1,'')   

             WHERE  NVL(CreditProvisionRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(CreditProvisionRs, 0)) < 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN ' CreditProvisionRs can not be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs can not be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'CreditProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'CreditProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  NVL(TypeofRestructuring, ' ') <> ' '
              AND NVL(CreditProvisionRs, ' ') = ' ';
            -----------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('An12');
            -----------------------------------------------DFVProvisionRs
            -- UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DFVProvisionRs cannot be blank. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'DFVProvisionRs cannot be blank. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DFVProvisionRs' ELSE ErrorinColumn +','+SPACE(1)+  'DFVProvisionRs' END  
            --		,Srnooferroneousrows=V.SRNO
            ----								----STUFF((SELECT ','+SRNO 
            ----								----FROM RestructureAssets A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM RestructureAssets V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(DFVProvisionRs,'')=''
            DBMS_OUTPUT.PUT_LINE('An121');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DFVProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DFVProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  ( utils.isnumeric(DFVProvisionRs) = 0
              AND NVL(DFVProvisionRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(DFVProvisionRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('An122');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DFVProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DFVProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  REGEXP_LIKE(NVL(DFVProvisionRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            DBMS_OUTPUT.PUT_LINE('An123');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid DFVProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid DFVProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  NVL(DFVProvisionRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(DFVProvisionRs, 0)) < 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN ' DFVProvisionRs can not be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'DFVProvisionRs can not be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'DFVProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'DFVProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  NVL(TypeofRestructuring, ' ') <> ' '
              AND NVL(DFVProvisionRs, ' ') = ' ';
            -----------------------------------------------------------------
            DBMS_OUTPUT.PUT_LINE('An13');
            -----------------------------------------------MTMProvisionRs
            -- UPDATE RestructureAssets
            --	SET  
            --        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MTMProvisionRs cannot be blank. Please check the values and upload again'     
            --						ELSE ErrorMessage+','+SPACE(1)+ 'MTMProvisionRs cannot be blank. Please check the values and upload again'      END
            --		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MTMProvisionRs' ELSE ErrorinColumn +','+SPACE(1)+  'MTMProvisionRs' END  
            --		,Srnooferroneousrows=V.SRNO
            ----								----STUFF((SELECT ','+SRNO 
            ----								----FROM RestructureAssets A
            ----								----WHERE A.SrNo IN(SELECT V.SrNo FROM RestructureAssets V
            ----								----WHERE ISNULL(InterestReversalAmount,'')='')
            ----								----FOR XML PATH ('')
            ----								----),1,1,'')   
            -- FROM RestructureAssets V  
            -- WHERE ISNULL(MTMProvisionRs,'')=''
            DBMS_OUTPUT.PUT_LINE('An131');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid MTMProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid MTMProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MTMProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MTMProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  ( utils.isnumeric(MTMProvisionRs) = 0
              AND NVL(MTMProvisionRs, ' ') <> ' ' )
              OR REGEXP_LIKE(utils.isnumeric(MTMProvisionRs), '%^[0-9]%');
            DBMS_OUTPUT.PUT_LINE('An14');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid MTMProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid MTMProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MTMProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MTMProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  REGEXP_LIKE(NVL(MTMProvisionRs, ' '), '%[,!@#$%^&*()_-+=/]%');
            DBMS_OUTPUT.PUT_LINE('An141');
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN 'Invalid MTMProvisionRs. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'Invalid MTMProvisionRs. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MTMProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MTMProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  NVL(MTMProvisionRs, ' ') <> ' '

              --AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0
              AND TRY_CONVERT(DECIMAL_(25, 2), NVL(MTMProvisionRs, 0)) < 0;
            UPDATE RestructureAssets V
               SET V.ErrorMessage = CASE 
                                         WHEN NVL(ErrorMessage, ' ') = ' ' THEN ' MTMProvisionRs can not be blank. Please check the values and upload again'
                   ELSE ErrorMessage || ',' || LPAD(' ', 1, ' ') || 'MTMProvisionRs can not be blank. Please check the values and upload again'
                      END,
                   V.ErrorinColumn = CASE 
                                          WHEN NVL(ErrorinColumn, ' ') = ' ' THEN 'MTMProvisionRs'
                   ELSE ErrorinColumn || ',' || LPAD(' ', 1, ' ') || 'MTMProvisionRs'
                      END,
                   V.Srnooferroneousrows = V.SRNO
             WHERE  NVL(TypeofRestructuring, ' ') <> ' '
              AND NVL(MTMProvisionRs, ' ') = ' ';
            ---------------------------------
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
                                FROM RetsructuredAssetsUpload_stg 
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
                FROM RestructureAssets  );
            --	----SELECT * FROM RestructureAssets 
            --	--ORDER BY ErrorMessage,RestructureAssets.ErrorinColumn DESC
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
                               FROM RetsructuredAssetsUpload_stg 
                                WHERE  filname = v_FilePathUpload );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE RetsructuredAssetsUpload_stg

                WHERE  filname = v_FilePathUpload;
               DBMS_OUTPUT.PUT_LINE(1);
               DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.RetsructuredAssetsUpload_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

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
         ----SELECT * FROM RestructureAssets
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
      -- END
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
                         FROM RetsructuredAssetsUpload_stg 
                          WHERE  filname = v_FilePathUpload );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         DELETE RetsructuredAssetsUpload_stg

          WHERE  filname = v_FilePathUpload;
         DBMS_OUTPUT.PUT_LINE('ROWS DELETED FROM DBO.RetsructuredAssetsUpload_stg' || UTILS.CONVERT_TO_VARCHAR2(SQL%ROWCOUNT,100));

      END;
      END IF;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."VALIDATEEXCEL_DATAUPLOAD_RESTRUCTUREASSETSUPLOAD_01012021" TO "ADF_CDR_RBL_STGDB";
