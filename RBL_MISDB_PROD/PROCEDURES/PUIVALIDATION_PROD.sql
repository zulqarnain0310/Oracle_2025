--------------------------------------------------------
--  DDL for Procedure PUIVALIDATION_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUIVALIDATION_PROD" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_xmlDocument IN CLOB DEFAULT ' ' ,
  v_Timekey IN NUMBER DEFAULT 49999 ,
  v_ScreenFlag IN VARCHAR2 DEFAULT 'PUI' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)
   IF v_ScreenFlag = 'PUI' THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      IF utils.object_id('TEMPDB..tt_PUIData') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PUIData ';
      END IF;
      DELETE FROM tt_PUIData;
      UTILS.IDENTITY_RESET('tt_PUIData');

      INSERT INTO tt_PUIData SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT (1) 
                                                                     FROM DUAL  )  ) RowNum_  ,
                                    /*TODO:SQLDEV*/ C.value('./CustomerEntityID[1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerEntityID  ,
                                    /*TODO:SQLDEV*/ C.value('./CustomerID [1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerID  ,
                                    /*TODO:SQLDEV*/ C.value('./CustomerName [1]','VARCHAR(255)') /*END:SQLDEV*/ CustomerName  ,
                                    /*TODO:SQLDEV*/ C.value('./AccountID [1]','VARCHAR(30)') /*END:SQLDEV*/ AccountID  ,
                                    CASE 
                                         WHEN /*TODO:SQLDEV*/ C.value('./OriginalDCCO	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                    ELSE /*TODO:SQLDEV*/ C.value('./OriginalDCCO[1]','VARCHAR(20)') /*END:SQLDEV*/
                                       END OriginalEnvisagCompletionDt  ,
                                    CASE 
                                         WHEN /*TODO:SQLDEV*/ C.value('./RevisedDCCO	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                    ELSE /*TODO:SQLDEV*/ C.value('./RevisedDCCO[1]','VARCHAR(20)') /*END:SQLDEV*/
                                       END RevisedCompletionDt  ,
                                    CASE 
                                         WHEN /*TODO:SQLDEV*/ C.value('./ActualDCCO	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                    ELSE /*TODO:SQLDEV*/ C.value('./ActualDCCO[1]','VARCHAR(20)') /*END:SQLDEV*/
                                       END ActualCompletionDt  ,
                                    /*TODO:SQLDEV*/ C.value('./ProjectCategory [1]','VARCHAR(100)') /*END:SQLDEV*/ ProjectCat  ,
                                    /*TODO:SQLDEV*/ C.value('./ProjectDelayReason [1]','VARCHAR(100)') /*END:SQLDEV*/ ProjectDelReason  ,
                                    /*TODO:SQLDEV*/ C.value('./StandardRestructured [1]','VARCHAR(20)') /*END:SQLDEV*/ StandardRestruct  ,
                                    UTILS.CONVERT_TO_VARCHAR2('',4000) ERROR  
           FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/DataSet/Gridrow') AS t(c) /*END:SQLDEV*/) ;
      --select 'tt_PUIData',* from tt_PUIData
      /****************************************************************************************************************

      											FOR CHECKING A CUSTOMER  ID 

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.CustomerID, ' ') = ' ' THEN 'Customer Id should not be Empty'
      WHEN NVL(C.RefCustomerID, ' ') = ' ' THEN 'Invalid Customer Id'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON A.CustomerID = C.RefCustomerID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;--C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
      /****************************************************************************************************************

      											FOR CHECKING A CustomerName

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.CustomerName, ' ') = ' ' THEN 'CustomerName should not be Empty'
      WHEN NVL(C.CustomerName, ' ') = ' ' THEN 'Invalid Customer Name'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON A.CustomerName = C.CustomerName ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;--C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
      /****************************************************************************************************************

      											FOR CHECKING A AccountID

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.AccountID, ' ') = ' ' THEN 'Account ID should not be Empty'
      WHEN NVL(C.CustomerAcID, ' ') = ' ' THEN 'Invalid Account ID'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON A.AccountID = C.CustomerAcID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;--C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
      /****************************************************************************************************************

      											FOR CHECKING A OriginalEnvisagCompletionDt

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' '
        AND NVL(A.OriginalEnvisagCompletionDt, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN 'Invalid OriginalEnvisagCompletionDt'
      WHEN NVL(ERROR, ' ') <> ' '
        AND NVL(A.OriginalEnvisagCompletionDt, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'Invalid OriginalEnvisagCompletionDt'
      WHEN NVL(ERROR, ' ') = ' '
        AND NVL(A.OriginalEnvisagCompletionDt, ' ') = ' ' THEN 'OriginalEnvisagCompletionDt cannot be empty'
      WHEN NVL(ERROR, ' ') <> ' '
        AND NVL(A.OriginalEnvisagCompletionDt, ' ') = ' ' THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'OriginalEnvisagCompletionDt cannot be empty'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN ( 
                         --SELECT 1
                         SELECT tt_PUIData.RowNum_ ,
                                1 correct  
                         FROM tt_PUIData 
                          WHERE  utils.isdate(tt_PUIData.OriginalEnvisagCompletionDt) = 1
                                   AND (CASE 
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt)), 3, 1) = '-'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt))) = 9
                                               OR LENGTH(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt))) = 11 )
                                               AND utils.isnumeric(SUBSTR(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt)), 4, 3)) = 0
                                               AND SUBSTR(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt)), 7, 1) = '-' THEN 1
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt)), 3, 1) = '/'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt))) = 8
                                               OR LENGTH(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt))) = 10 )
                                               AND SUBSTR(RTRIM(LTRIM(tt_PUIData.OriginalEnvisagCompletionDt)), 6, 1) = '/' THEN 1   END) = 1 ) B   ON A.RowNum_ = B.RowNum_ 
       WHERE NVL(B.RowNum_, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING RevisedCompletionDt

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' '
        AND NVL(A.RevisedCompletionDt, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN 'Invalid RevisedCompletionDt'
      WHEN NVL(ERROR, ' ') <> ' '
        AND NVL(A.RevisedCompletionDt, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'Invalid RevisedCompletionDt'
      WHEN NVL(ERROR, ' ') = ' '
        AND NVL(A.RevisedCompletionDt, ' ') = ' ' THEN 'RevisedCompletionDt cannot be empty'
      WHEN NVL(ERROR, ' ') <> ' '
        AND NVL(A.RevisedCompletionDt, ' ') = ' ' THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'RevisedCompletionDt cannot be empty'
      WHEN NVL(ERROR, ' ') <> ' '
        AND ( UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,200,p_style=>103) > UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,200,p_style=>103) ) THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'RevisedCompletionDt cannot be empty'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN ( 
                         --SELECT 1
                         SELECT tt_PUIData.RowNum_ ,
                                1 correct  
                         FROM tt_PUIData 
                          WHERE  utils.isdate(tt_PUIData.RevisedCompletionDt) = 1
                                   AND (CASE 
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt)), 3, 1) = '-'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt))) = 9
                                               OR LENGTH(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt))) = 11 )
                                               AND utils.isnumeric(SUBSTR(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt)), 4, 3)) = 0
                                               AND SUBSTR(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt)), 7, 1) = '-' THEN 1
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt)), 3, 1) = '/'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt))) = 8
                                               OR LENGTH(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt))) = 10 )
                                               AND SUBSTR(RTRIM(LTRIM(tt_PUIData.RevisedCompletionDt)), 6, 1) = '/' THEN 1   END) = 1 ) B   ON A.RowNum_ = B.RowNum_ 
       WHERE NVL(B.RowNum_, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      DBMS_OUTPUT.PUT_LINE('A');
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN ( UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,200,p_style=>103) < UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,200,p_style=>103) ) THEN 'RevisedCompletionDt should be greater OriginalEnvisagCompletionDt'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING ProjectCategory

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ProjectCat, ' ') = ' ' THEN 'Project Category should not be Empty'
      WHEN NVL(B.ParameterName, ' ') = ' ' THEN 'Invalid Project Category'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN DimParameter B   ON A.ProjectCat = B.ParameterName
             AND b.DimParameterName = 'ProjectCategory' ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING ProjectDelayReason

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.ProjectDelReason, ' ') = ' ' THEN 'Project Delay Reason should not be Empty'
      WHEN NVL(B.ParameterName, ' ') = ' ' THEN 'Invalid Project Delay Reason'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN DimParameter B   ON A.ProjectDelReason = B.ParameterName
             AND b.DimParameterName = 'ProdectDelReson' ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING StandardRestruct

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.StandardRestruct, ' ') = ' ' THEN 'StandardRestruct should not be Empty'
      WHEN NVL(B.ParameterName, ' ') = ' ' THEN 'Invalid StandardRestruct'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_PUIData A
             LEFT JOIN DimParameter B   ON A.StandardRestruct = B.ParameterName
             AND b.DimParameterName = 'DimYesNo' ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOROUTPUT

      ****************************************************************************************************************/
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM tt_PUIData 
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
                   CustomerID ,
                   CustomerName ,
                   AccountID ,
                   OriginalEnvisagCompletionDt ,
                   RevisedCompletionDt ,
                   ActualCompletionDt ,
                   ProjectCat ,
                   ProjectDelReason ,
                   StandardRestruct ,
                   ERROR ,
                   'ErrorData' TableName  
              FROM tt_PUIData 
             WHERE  NVL(ERROR, ' ') <> ' ' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT RowNum_ ,
                   CustomerID ,
                   CustomerName ,
                   AccountID ,
                   CASE 
                        WHEN utils.isdate(OriginalEnvisagCompletionDt) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OriginalEnvisagCompletionDt,200),10,p_style=>103)
                   ELSE OriginalEnvisagCompletionDt
                      END OriginalEnvisagCompletionDt  ,
                   CASE 
                        WHEN utils.isdate(RevisedCompletionDt) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(RevisedCompletionDt,200),10,p_style=>103)
                   ELSE RevisedCompletionDt
                      END RevisedCompletionDt  ,
                   CASE 
                        WHEN utils.isdate(ActualCompletionDt) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(ActualCompletionDt,200),10,p_style=>103)
                   ELSE ActualCompletionDt
                      END ActualCompletionDt  ,
                   ProjectCat ,
                   ProjectDelReason ,
                   StandardRestruct ,
                   'PUIData' TableName  
              FROM tt_PUIData  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PUIData ';

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUIVALIDATION_PROD" TO "ADF_CDR_RBL_STGDB";
