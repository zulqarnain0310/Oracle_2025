--------------------------------------------------------
--  DDL for Procedure RPPORTFOLIOVALIDATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" 
(
  v_xmlDocument IN CLOB DEFAULT ' ' ,
  v_Timekey IN NUMBER DEFAULT 49999 ,
  v_ScreenFlag IN VARCHAR2 DEFAULT 'Automation' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)
   IF v_ScreenFlag = 'Automation' THEN
    DECLARE
      v_Date VARCHAR2(200);
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      IF utils.object_id('TEMPDB..tt_RPPortfoilioData') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_RPPortfoilioData ';
      END IF;
      DELETE FROM tt_RPPortfoilioData;
      UTILS.IDENTITY_RESET('tt_RPPortfoilioData');

      INSERT INTO tt_RPPortfoilioData SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT (1) 
                                                                              FROM DUAL  )  ) RowNum_  ,
                                             /*TODO:SQLDEV*/ C.value('./CustomerEntityID[1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerEntityID  ,
                                             /*TODO:SQLDEV*/ C.value('./UCICID[1]','VARCHAR(30)') /*END:SQLDEV*/ UCIC_ID  ,
                                             /*TODO:SQLDEV*/ C.value('./CustomerID [1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerID  ,
                                             /*TODO:SQLDEV*/ C.value('./BorrowerPAN [1]','VARCHAR(20)') /*END:SQLDEV*/ PAN_No  ,
                                             --,C.value('./BorrowerName [1]','VARCHAR(255)') CustomerName
                                             /*TODO:SQLDEV*/ C.value('./BankIDBankCode [1]','VARCHAR(20)') /*END:SQLDEV*/ BankCode  ,
                                             --,CASE WHEN C.value('./BorrowerDefaultDate	[1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./BorrowerDefaultDate[1]','VARCHAR(20)') END AS BorrowerDefaultDate
                                             /*TODO:SQLDEV*/ C.value('./Exposurebucketing [1]','VARCHAR(100)') /*END:SQLDEV*/ ExposureBucketName  ,
                                             /*TODO:SQLDEV*/ C.value('./Bankingarrangement [1]','VARCHAR(100)') /*END:SQLDEV*/ BankingArrangementName  ,
                                             /*TODO:SQLDEV*/ C.value('./Nameofleadbank [1]','VARCHAR(100)') /*END:SQLDEV*/ LeadBankName  ,
                                             /*TODO:SQLDEV*/ C.value('./BorrowerDefaultStatus [1]','VARCHAR(100)') /*END:SQLDEV*/ DefaultStatus  ,
                                             CASE 
                                                  WHEN /*TODO:SQLDEV*/ C.value('./ApproveddateofnatureofResolutionPlan	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                             ELSE /*TODO:SQLDEV*/ C.value('./ApproveddateofnatureofResolutionPlan[1]','VARCHAR(20)') /*END:SQLDEV*/
                                                END RP_ApprovalDate  ,
                                             /*TODO:SQLDEV*/ C.value('./NatureofresolutionPlan [1]','VARCHAR(100)') /*END:SQLDEV*/ RPNatureName  ,
                                             /*TODO:SQLDEV*/ C.value('./IncaseofOtherpleaseadvisenatureofresolutionplan [1]','VARCHAR(500)') /*END:SQLDEV*/ If_Other  ,
                                             /*TODO:SQLDEV*/ C.value('./ImplementationStatus [1]','VARCHAR(100)') /*END:SQLDEV*/ ImplementationStatus  ,
                                             CASE 
                                                  WHEN /*TODO:SQLDEV*/ C.value('./ActualResolutionPlanImplementationDate	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                             ELSE /*TODO:SQLDEV*/ C.value('./ActualResolutionPlanImplementationDate[1]','VARCHAR(20)') /*END:SQLDEV*/
                                                END Actual_Impl_Date  ,
                                             CASE 
                                                  WHEN /*TODO:SQLDEV*/ C.value('./OutofdefaultdatebyallbankspostinitialRPdeadline	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                             ELSE /*TODO:SQLDEV*/ C.value('./OutofdefaultdatebyallbankspostinitialRPdeadline[1]','VARCHAR(20)') /*END:SQLDEV*/
                                                END RP_OutOfDateAllBanksDeadline  ,
                                             UTILS.CONVERT_TO_VARCHAR2('',4000) ERROR  
           FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/DataSet/Gridrow') AS t(c) /*END:SQLDEV*/) ;
      SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

        INTO v_Date
        FROM SysDataMatrix A
               JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
       WHERE  A.CurrentStatus = 'C';
      --select * from tt_RPPortfoilioData
      /****************************************************************************************************************

      											FOR CHECKING A UCIC ID 

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'UCIC Id should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'UCIC Id should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.UCIC_ID, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      --LEFT OUTER JOIN PRO.CustomerCal C
      --	ON A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.UCIC_ID = C.UCIF_ID
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid UCIC ID,  Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid UCIC ID,  Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.UCIC_ID, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL C
                          WHERE  C.UCIF_ID = A.UCIC_ID )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING A CUSTOMER  ID 

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Customer ID should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Customer ID should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.CustomerID, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      --LEFT OUTER JOIN PRO.CustomerCal C
      --	ON A.CustomerID = C.RefCustomerID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid Customer ID,  Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid Customer ID,  Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.CustomerID, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL C
                          WHERE  C.RefCustomerID = A.CustomerID )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING A PAN_No

      		****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'PAN NO should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'PAN NO should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER  JOIN PRO.CUSTOMERCAL  C
            --	ON C.PANNO = A.PAN_No --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.PANNO = A.PAN_No

       WHERE NVL(A.PAN_No, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid PAN NO,  Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid PAN NO,  Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER  JOIN PRO.CUSTOMERCAL  C
            --	ON C.PANNO = A.PAN_No --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.PANNO = A.PAN_No

       WHERE NVL(PAN_No, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL C
                          WHERE  C.RefCustomerID = A.CustomerID
                                   AND C.PANNO = A.PAN_No )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      --UPDATE A
      --SET ERROR = CASE	WHEN  ISNULL(C.PANNO,'')='' AND ISNULL(ERROR,'')=''	THEN 'PAN No Not Belong to that Customer Id'
      --					WHEN ISNULL(C.PANNO,'')='' AND ISNULL(ERROR,'')<>''	THEN  ISNULL(ERROR,'')+','+SPACE(1)+'PAN NO Not Belong to that Customer Id'
      --					ELSE ERROR
      --			END
      --FROM tt_RPPortfoilioData A
      --LEFT OUTER JOIN PRO.CustomerCal C
      --	ON A.CustomerID = C.RefCustomerID	AND A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CustomerID = C.RefCustomerID		AND A.UCICID = C.UCIF_ID
      --WHERE  ISNULL(A.UCIC_ID,'')<>''
      /****************************************************************************************************************

      											FOR CHECKING A CustomerName

      ****************************************************************************************************************

      				UPDATE A
      		SET ERROR = CASE	WHEN ISNULL(A.CustomerName,'')=''		THEN 'CustomerName should not be Empty'
      							--WHEN ISNULL(C.CustomerName,'')=''	THEN 'Invalid Customer Name'
      							ELSE ERROR
      					END
      		FROM tt_RPPortfoilioData A
      		--LEFT OUTER JOIN PRO.CustomerCal C
      			--ON A.CustomerName = C.CustomerName --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID */
      /****************************************************************************************************************

      											FOR CHECKING BankCode

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Bank Code should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Bank Code should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --Left Outer Join DimBankRP B
            --ON A.BankCode=B.BankCode

       WHERE NVL(A.BankCode, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid Bank Code. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid Bank Code. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --Left Outer Join DimBankRP B
            --ON A.BankCode=B.BankCode

       WHERE NVL(A.BankCode, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM DimBankRP B
                          WHERE  A.BankCode = B.BankCode
                                   AND B.EffectiveToTimeKey = 49999 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING A BorrowerDefaultDate

      ****************************************************************************************************************/
      --	UPDATE A
      --	SET ERROR = 
      --					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.BorrowerDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
      --								THEN 'Invalid BorrowerDefaultDate'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.BorrowerDefaultDate,'')<>'' AND ISNULL(B.correct,0)<>1 
      --										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid BorrowerDefaultDate'
      --							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.BorrowerDefaultDate,'')='' 
      --										THEN 'BorrowerDefaultDate cannot be empty'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.BorrowerDefaultDate,'')='' THEN 
      --										ISNULL(ERROR,'')+','+SPACE(1)+ 'BorrowerDefaultDate cannot be empty'
      --						ELSE ERROR
      --					END
      --	 FROM tt_RPPortfoilioData A
      --	LEFT OUTER JOIN 
      --(
      ----SELECT 1
      --	SELECT RowNum ,1 correct FROM tt_RPPortfoilioData
      --	WHERE ISDATE(BorrowerDefaultDate)=1
      --	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),3,1)='-' 
      --					AND (LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=9 OR LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=11 )
      --					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),4,3))=0 
      --					AND  SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),7,1)='-' 
      --				THEN 1
      --				WHEN SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),3,1)='/'
      --				AND (LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=8 OR LEN(RTRIM(LTRIM(BorrowerDefaultDate)))=10 )
      --				 AND  SUBSTRING(RTRIM(LTRIM(BorrowerDefaultDate)),6,1)='/' THEN 1
      --		END)=1
      --)B 
      --ON A.RowNum = B.RowNum
      --WHERE ISNULL(B.RowNum,'')='' 
      /****************************************************************************************************************

      											FOR CHECKING ExposureBucketName

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'ExposureBucketName should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'ExposureBucketName should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimExposureBucket B
            --ON A. ExposureBucketName=B.BucketName

       WHERE NVL(A.ExposureBucketName, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN ' Invalid ExposureBucketName. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid ExposureBucketName. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimExposureBucket B
            --ON A. ExposureBucketName=B.BucketName

       WHERE NVL(A.ExposureBucketName, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM DimExposureBucket B
                          WHERE  A.ExposureBucketName = B.BucketName
                                   AND B.EffectiveToTimeKey = 49999 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING BankingArrangementName

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'BankingArrangementName should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'BankingArrangementName should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimBankingArrangement B
            --ON A.BankingArrangementName=B.ArrangementDescription

       WHERE NVL(A.BankingArrangementName, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid BankingArrangementName. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid BankingArrangementName. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimBankingArrangement B
            --ON A.BankingArrangementName=B.ArrangementDescription

       WHERE NVL(A.BankingArrangementName, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM DimBankingArrangement B
                          WHERE  A.BankingArrangementName = B.ArrangementDescription
                                   AND B.EffectiveToTimeKey = 49999 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING LeadBankName

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'LeadBankName should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'LeadBankName should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimBankRP B
            --ON A.LeadBankName=B.BankName

       WHERE NVL(A.LeadBankName, ' ') = ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM DimBankingArrangement B
                          WHERE  A.BankingArrangementName = B.ArrangementDescription
                                   AND B.EffectiveToTimeKey = 49999
                                   AND B.ArrangementDescription = 'Sole' )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid LeadBankName. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid LeadBankName. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimBankRP B
            --ON A.LeadBankName=B.BankName

       WHERE NVL(A.LeadBankName, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM DimBankRP B
                          WHERE  A.LeadBankName = B.BankName
                                   AND B.EffectiveToTimeKey = 49999 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING DefaultStatus

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'DefaultStatus should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'DefaultStatus should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.DefaultStatus, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING RP_ApprovalDate

      ****************************************************************************************************************/
      --			UPDATE A
      --	SET ERROR = 
      --					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_ApprovalDate,'')<>'' AND ISNULL(B.correct,0)<>1 
      --								THEN 'Invalid RP_ApprovalDate'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_ApprovalDate,'')<>'' AND ISNULL(B.correct,0)<>1 
      --										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid RP_ApprovalDate'
      --							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_ApprovalDate,'')='' 
      --										THEN 'RP_ApprovalDate cannot be empty'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_ApprovalDate,'')='' THEN 
      --										ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_ApprovalDate cannot be empty'
      --							--WHEN    CONVERT(date,A.RP_ApprovalDate,101)> CONVERT(date,@Date,101) THEN 
      --							--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'
      --						ELSE ERROR
      --					END
      --	 FROM tt_RPPortfoilioData A
      --	LEFT OUTER JOIN 
      --(
      ----SELECT 1
      --	SELECT RowNum ,1 correct FROM tt_RPPortfoilioData
      --	WHERE ISDATE(RP_ApprovalDate)=1
      --	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),3,1)='-' 
      --					AND (LEN(RTRIM(LTRIM(RP_ApprovalDate)))=9 OR LEN(RTRIM(LTRIM(RP_ApprovalDate)))=11 )
      --					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),4,3))=0 
      --					AND  SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),7,1)='-' 
      --				THEN 1
      --				WHEN SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),3,1)='/'
      --				AND (LEN(RTRIM(LTRIM(RP_ApprovalDate)))=8 OR LEN(RTRIM(LTRIM(RP_ApprovalDate)))=10 )
      --				 AND  SUBSTRING(RTRIM(LTRIM(RP_ApprovalDate)),6,1)='/' THEN 1
      --		END)=1
      --)B 
      --ON A.RowNum = B.RowNum
      --WHERE ISNULL(B.RowNum,'')='' 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'RP_ApprovalDate should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'RP_ApprovalDate should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.RP_ApprovalDate, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid RP_ApprovalDate. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid RP_ApprovalDate. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.RP_ApprovalDate, ' ') <> ' '
        AND utils.isdate(A.RP_ApprovalDate) = 0) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      ----------------Added on 22-01-2021
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' ' THEN 'RP_ApprovalDate Date Cannot be future Date'
      ELSE NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'RP_ApprovalDate Date Cannot be future Date'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE utils.isdate(A.RP_ApprovalDate) = 1
        AND UTILS.CONVERT_TO_VARCHAR2(A.RP_ApprovalDate,200,p_style=>103) > v_Date) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING RPNatureName

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'RPNatureName should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'RPNatureName should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimResolutionPlanNature B
            --ON A.RPNatureName=B.RPDescription

       WHERE NVL(A.RPNatureName, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid RPNatureName. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid RPNatureName. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --LEFT OUTER JOIN DimResolutionPlanNature B
            --ON A.RPNatureName=B.RPDescription

       WHERE NVL(A.RPNatureName, ' ') <> ' '
        AND NOT EXISTS ( SELECT 1 
                         FROM DimResolutionPlanNature B
                          WHERE  A.RPNatureName = B.RPDescription
                                   AND B.EffectiveToTimeKey = 49999 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING If_Other

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'If_Other should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'If_Other should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A
           --Inner JOIN DimResolutionPlanNature B
            --ON A.RPNatureName=B.RPDescription
            --where B.RPDescription='Other'

       WHERE NVL(A.If_Other, ' ') = ' '
        AND EXISTS ( SELECT 1 
                     FROM DimResolutionPlanNature B
                      WHERE  A.RPNatureName = B.RPDescription
                               AND B.EffectiveToTimeKey = 49999
                               AND B.RPDescription = 'Other' )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING ImplementationStatus

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'ImplementationStatus should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'ImplementationStatus should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.ImplementationStatus, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING Actual_Impl_Date

      ****************************************************************************************************************/
      --					UPDATE A
      --	SET ERROR = 
      --					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.Actual_Impl_Date,'')<>'' AND ISNULL(B.correct,0)<>1 
      --								THEN 'Invalid Actual_Impl_Date'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.Actual_Impl_Date,'')<>'' AND ISNULL(B.correct,0)<>1 
      --										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'Invalid Actual_Impl_Date'
      --							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.Actual_Impl_Date,'')='' 
      --										THEN 'Actual_Impl_Date cannot be empty'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.Actual_Impl_Date,'')='' THEN 
      --										ISNULL(ERROR,'')+','+SPACE(1)+ 'Actual_Impl_Date cannot be empty'
      --							--WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.Actual_Impl_Date,103)>convert(date,@Date,103)) THEN 
      --							--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'
      --						ELSE ERROR
      --					END
      --	 FROM tt_RPPortfoilioData A
      --	LEFT OUTER JOIN 
      --(
      ----SELECT 1
      --	SELECT RowNum ,1 correct FROM tt_RPPortfoilioData
      --	WHERE ISDATE(Actual_Impl_Date)=1
      --	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),3,1)='-' 
      --					AND (LEN(RTRIM(LTRIM(Actual_Impl_Date)))=9 OR LEN(RTRIM(LTRIM(Actual_Impl_Date)))=11 )
      --					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),4,3))=0 
      --					AND  SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),7,1)='-' 
      --				THEN 1
      --				WHEN SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),3,1)='/'
      --				AND (LEN(RTRIM(LTRIM(Actual_Impl_Date)))=8 OR LEN(RTRIM(LTRIM(Actual_Impl_Date)))=10 )
      --				 AND  SUBSTRING(RTRIM(LTRIM(Actual_Impl_Date)),6,1)='/' THEN 1
      --		END)=1
      --)B 
      --ON A.RowNum = B.RowNum
      --WHERE ISNULL(B.RowNum,'')='' 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Actual_Impl_Date should not be Empty. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Actual_Impl_Date should not be Empty. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.Actual_Impl_Date, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid Actual_Impl_Date. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid Actual_Impl_Date. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.Actual_Impl_Date, ' ') <> ' '
        AND utils.isdate(A.Actual_Impl_Date) = 0) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      ----------------Added on 22-01-2021
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' ' THEN 'Actual_Impl_Date Date Cannot be future Date'
      ELSE NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'Actual_Impl_Date Date Cannot be future Date'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE utils.isdate(A.Actual_Impl_Date) = 1
        AND UTILS.CONVERT_TO_VARCHAR2(A.Actual_Impl_Date,200,p_style=>103) > v_Date) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING RP_OutOfDateAllBanksDeadline

      ****************************************************************************************************************/
      --							UPDATE A
      --	SET ERROR = 
      --					CASE	WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')<>'' AND ISNULL(B.correct,0)<>1 
      --								THEN 'Invalid RP_OutOfDateAllBanksDeadline'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')<>'' AND ISNULL(B.correct,0)<>1 
      --										THEN ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_OutOfDateAllBanksDeadline Actual_Impl_Date'
      --							WHEN ISNULL(ERROR,'')=''  AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')='' 
      --										THEN 'RP_OutOfDateAllBanksDeadline cannot be empty'
      --							WHEN ISNULL(ERROR,'')<>'' AND ISNULL(A.RP_OutOfDateAllBanksDeadline,'')='' THEN 
      --										ISNULL(ERROR,'')+','+SPACE(1)+ 'RP_OutOfDateAllBanksDeadline cannot be empty'
      --							--WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.RP_OutOfDateAllBanksDeadline,103)>convert(date,@Date,103)) THEN 
      --							--			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'
      --						ELSE ERROR
      --					END
      --	 FROM tt_RPPortfoilioData A
      --	LEFT OUTER JOIN 
      --(
      ----SELECT 1
      --	SELECT RowNum ,1 correct FROM tt_RPPortfoilioData
      --	WHERE ISDATE(RP_OutOfDateAllBanksDeadline)=1
      --	AND (CASE	WHEN SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),3,1)='-' 
      --					AND (LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=9 OR LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=11 )
      --					AND ISNUMERIC(SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),4,3))=0 
      --					AND  SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),7,1)='-' 
      --				THEN 1
      --				WHEN SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),3,1)='/'
      --				AND (LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=8 OR LEN(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)))=10 )
      --				 AND  SUBSTRING(RTRIM(LTRIM(RP_OutOfDateAllBanksDeadline)),6,1)='/' THEN 1
      --		END)=1
      --)B 
      --ON A.RowNum = B.RowNum
      --WHERE ISNULL(B.RowNum,'')='' 
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ERROR, ' ') = ' ' THEN 'Invalid RP_OutOfDateAllBanksDeadline. Please check the values and upload again'
      ELSE A.ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid RP_OutOfDateAllBanksDeadline. Please check the values and upload again'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE NVL(A.RP_OutOfDateAllBanksDeadline, ' ') <> ' '
        AND utils.isdate(A.RP_OutOfDateAllBanksDeadline) = 0) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      ----------------Added on 22-01-2021
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' ' THEN 'RP_OutOfDateAllBanksDeadline Date Cannot be future Date'
      ELSE NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'RP_OutOfDateAllBanksDeadline Date Cannot be future Date'
         END AS ERROR
      FROM A ,tt_RPPortfoilioData A 
       WHERE utils.isdate(A.RP_OutOfDateAllBanksDeadline) = 1
        AND UTILS.CONVERT_TO_VARCHAR2(A.RP_OutOfDateAllBanksDeadline,200,p_style=>103) > v_Date) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOROUTPUT

      ****************************************************************************************************************/
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM tt_RPPortfoilioData 
                          WHERE  NVL(ERROR, ' ') <> ' ' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT RowNum_ ,
                   CustomerEntityID ,
                   UCIC_ID ,
                   CustomerID ,
                   PAN_No ,
                   --,CustomerName
                   BankCode ,
                   --,BorrowerDefaultDate
                   ExposureBucketName ,
                   BankingArrangementName ,
                   LeadBankName ,
                   DefaultStatus ,
                   RP_ApprovalDate ,
                   RPNatureName ,
                   If_Other ,
                   ImplementationStatus ,
                   Actual_Impl_Date ,
                   RP_OutOfDateAllBanksDeadline ,
                   ERROR ,
                   'ErrorData' TableName  
              FROM tt_RPPortfoilioData 
             WHERE  NVL(ERROR, ' ') <> ' ' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT RowNum_ ,
                   CustomerEntityID ,
                   UCIC_ID ,
                   CustomerID ,
                   PAN_No ,
                   --,CustomerName
                   BankCode ,
                   --,CASE WHEN  ISDATE(BorrowerDefaultDate)=1 THEN CONVERT(VARCHAR(10),CAST(BorrowerDefaultDate AS DATE),103) ELSE BorrowerDefaultDate END BorrowerDefaultDate
                   ExposureBucketName ,
                   BankingArrangementName ,
                   LeadBankName ,
                   DefaultStatus ,
                   CASE 
                        WHEN utils.isdate(RP_ApprovalDate) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(RP_ApprovalDate,200),10,p_style=>103)
                   ELSE RP_ApprovalDate
                      END RP_ApprovalDate  ,
                   RPNatureName ,
                   If_Other ,
                   ImplementationStatus ,
                   CASE 
                        WHEN utils.isdate(Actual_Impl_Date) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Actual_Impl_Date,200),10,p_style=>103)
                   ELSE Actual_Impl_Date
                      END Actual_Impl_Date  ,
                   CASE 
                        WHEN utils.isdate(RP_OutOfDateAllBanksDeadline) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(RP_OutOfDateAllBanksDeadline,200),10,p_style=>103)
                   ELSE RP_OutOfDateAllBanksDeadline
                      END RP_OutOfDateAllBanksDeadline  ,
                   'RPPortfolioData' TableName  ,
                   ERROR error  
              FROM tt_RPPortfoilioData  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_RPPortfoilioData ';

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPPORTFOLIOVALIDATION" TO "ADF_CDR_RBL_STGDB";
