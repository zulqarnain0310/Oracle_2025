--------------------------------------------------------
--  DDL for Procedure RPLENDERVALIDATION_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" 
(
  v_xmlDocument IN CLOB DEFAULT ' ' ,
  v_Timekey IN NUMBER DEFAULT 49999 ,
  v_ScreenFlag IN VARCHAR2 DEFAULT 'Lender' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --declare @todaydate date = (select StartDate from pro.EXTDATE_MISDB where TimeKey=@Timekey)
   IF v_ScreenFlag = 'Lender' THEN
    DECLARE
      v_Date VARCHAR2(200);
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      IF utils.object_id('TEMPDB..tt_RPLenderData_2') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_RPLenderData_2 ';
      END IF;
      DELETE FROM tt_RPLenderData_2;
      UTILS.IDENTITY_RESET('tt_RPLenderData_2');

      INSERT INTO tt_RPLenderData_2 SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT (1) 
                                                                            FROM DUAL  )  ) RowNum_  ,
                                           /*TODO:SQLDEV*/ C.value('./UCICID[1]','VARCHAR(30)') /*END:SQLDEV*/ UCIC_ID  ,
                                           /*TODO:SQLDEV*/ C.value('./CustomerID [1]','VARCHAR(30)') /*END:SQLDEV*/ CustomerID  ,
                                           /*TODO:SQLDEV*/ C.value('./BorrowerPAN [1]','VARCHAR(20)') /*END:SQLDEV*/ PAN_No  ,
                                           --,C.value('./BorrowerName [1]','VARCHAR(255)') CustomerName
                                           /*TODO:SQLDEV*/ C.value('./LenderName [1]','VARCHAR(100)') /*END:SQLDEV*/ LenderName  ,
                                           CASE 
                                                WHEN /*TODO:SQLDEV*/ C.value('./InDefaultDate	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                           ELSE /*TODO:SQLDEV*/ C.value('./InDefaultDate[1]','VARCHAR(20)') /*END:SQLDEV*/
                                              END InDefaultDate  ,
                                           CASE 
                                                WHEN /*TODO:SQLDEV*/ C.value('./OutofDefaultDate	[1]','VARCHAR(20)') /*END:SQLDEV*/ = ' ' THEN NULL
                                           ELSE /*TODO:SQLDEV*/ C.value('./OutofDefaultDate[1]','VARCHAR(20)') /*END:SQLDEV*/
                                              END OutOfDefaultDate  ,
                                           UTILS.CONVERT_TO_VARCHAR2('',4000) ERROR  
           FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/DataSet/Gridrow') AS t(c) /*END:SQLDEV*/) ;
      SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

        INTO v_Date
        FROM SysDataMatrix A
               JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
       WHERE  A.CurrentStatus = 'C';
      /****************************************************************************************************************

      											FOR CHECKING A UCIC ID 

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.UCIC_ID, ' ') = ' ' THEN 'UCIC Id should not be Empty'
      WHEN NVL(C.UCIF_ID, ' ') = ' ' THEN 'Invalid UCIF Id'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON A.UCIC_ID = C.UCIF_ID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;--C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.UCIC_ID = C.UCIF_ID
      /****************************************************************************************************************

      											FOR CHECKING A CUSTOMER  ID 

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.CustomerID, ' ') = ' ' THEN 'Customer Id should not be Empty'
      WHEN NVL(C.RefCustomerID, ' ') = ' ' THEN 'Invalid Customer Id'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON A.CustomerID = C.RefCustomerID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;--C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID
      /****************************************************************************************************************

      											FOR CHECKING A PAN_No

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.PAN_No, ' ') = ' '
        AND NVL(ERROR, ' ') = ' ' THEN 'Pan No Should Not be Empty'
      WHEN NVL(C.PANNO, ' ') = ' '
        AND NVL(ERROR, ' ') <> ' ' THEN ERROR || ',' || LPAD(' ', 1, ' ') || 'Invalid PAN No'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON C.PANNO = A.PAN_No --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND C.PANNO = A.PAN_No

       WHERE NVL(PAN_No, ' ') <> ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(C.PANNO, ' ') = ' '
        AND NVL(ERROR, ' ') = ' ' THEN 'PAN No Not Belong to that Customer Id'
      WHEN NVL(C.PANNO, ' ') = ' '
        AND NVL(ERROR, ' ') <> ' ' THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'PAN NO Not Belong to that Customer Id'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL C   ON A.CustomerID = C.RefCustomerID
             AND A.UCIC_ID = C.UCIF_ID --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey		AND A.CustomerID = C.RefCustomerID		AND A.UCICID = C.UCIF_ID

       WHERE NVL(A.UCIC_ID, ' ') <> ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING A CustomerName

      ****************************************************************************************************************

      				UPDATE A
      		SET ERROR = CASE	WHEN ISNULL(A.CustomerName,'')=''		THEN 'CustomerName should not be Empty'
      							--WHEN ISNULL(C.CustomerName,'')=''	THEN 'Invalid Customer Name'
      							ELSE ERROR
      					END
      		FROM tt_RPLenderData_2 A
      		--LEFT OUTER JOIN PRO.CustomerCal C

      			--ON A.CustomerName = C.CustomerName --C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey	AND A.CUSTOMERID = C.RefCustomerID */
      /****************************************************************************************************************

      											FOR CHECKING A LenderName

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(A.LenderName, ' ') = ' ' THEN 'LenderName should not be Empty'
      WHEN NVL(B.BankName, ' ') = ' ' THEN 'Invalid BankName'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN DimBankRP B   ON A.LenderName = B.BankName ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET B.ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING A InDefaultDate

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' '
        AND NVL(A.InDefaultDate, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN 'Invalid InDefaultDate'
      WHEN NVL(ERROR, ' ') <> ' '
        AND NVL(A.InDefaultDate, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'Invalid InDefaultDate'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN ( 
                         --SELECT 1
                         SELECT tt_RPLenderData_2.RowNum_ ,
                                1 correct  
                         FROM tt_RPLenderData_2 
                          WHERE  utils.isdate(tt_RPLenderData_2.InDefaultDate) = 1
                                   AND (CASE 
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate)), 3, 1) = '-'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate))) = 9
                                               OR LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate))) = 11 )
                                               AND utils.isnumeric(SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate)), 4, 3)) = 0
                                               AND SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate)), 7, 1) = '-' THEN 1
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate)), 3, 1) = '/'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate))) = 8
                                               OR LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate))) = 10 )
                                               AND SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.InDefaultDate)), 6, 1) = '/' THEN 1   END) = 1 ) B   ON A.RowNum_ = B.RowNum_ 
       WHERE NVL(B.RowNum_, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR
                                   --WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.InDefaultDate,103)>convert(date,@Date,103)) THEN 
                                    --			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'
                                    = src.ERROR;
      ----------------Added on 22-01-2021
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN UTILS.CONVERT_TO_VARCHAR2(A.InDefaultDate,200,p_style=>103) > v_Date THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'InDefaultDate Date Cannot be future Date'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR CHECKING OutOfDefaultDate

      ****************************************************************************************************************/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN NVL(ERROR, ' ') = ' '
        AND NVL(A.OutOfDefaultDate, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN 'Invalid OutOfDefaultDate'
      WHEN NVL(ERROR, ' ') <> ' '
        AND NVL(A.OutOfDefaultDate, ' ') <> ' '
        AND NVL(B.correct, 0) <> 1 THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'Invalid OutOfDefaultDate '
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A
             LEFT JOIN ( 
                         --SELECT 1
                         SELECT tt_RPLenderData_2.RowNum_ ,
                                1 correct  
                         FROM tt_RPLenderData_2 
                          WHERE  utils.isdate(tt_RPLenderData_2.OutOfDefaultDate) = 1
                                   AND (CASE 
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate)), 3, 1) = '-'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate))) = 9
                                               OR LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate))) = 11 )
                                               AND utils.isnumeric(SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate)), 4, 3)) = 0
                                               AND SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate)), 7, 1) = '-' THEN 1
                                             WHEN SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate)), 3, 1) = '/'
                                               AND ( LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate))) = 8
                                               OR LENGTH(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate))) = 10 )
                                               AND SUBSTR(RTRIM(LTRIM(tt_RPLenderData_2.OutOfDefaultDate)), 6, 1) = '/' THEN 1   END) = 1 ) B   ON A.RowNum_ = B.RowNum_ 
       WHERE NVL(B.RowNum_, ' ') = ' ') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR
                                   --WHEN ISNULL(ERROR,'')<>'' AND (Convert(date,A.OutOfDefaultDate,103)>convert(date,@Date,103)) THEN 
                                    --			ISNULL(ERROR,'')+','+SPACE(1)+ 'Date Cannot be future Date'
                                    = src.ERROR;
      ----------------Added on 22-01-2021
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, CASE 
      WHEN UTILS.CONVERT_TO_VARCHAR2(A.OutOfDefaultDate,200,p_style=>103) > v_Date THEN NVL(ERROR, ' ') || ',' || LPAD(' ', 1, ' ') || 'OutOfDefaultDate Date Cannot be future Date'
      ELSE ERROR
         END AS ERROR
      FROM A ,tt_RPLenderData_2 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET ERROR = src.ERROR;
      /****************************************************************************************************************

      											FOR OUTPUT

      ****************************************************************************************************************/
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM tt_RPLenderData_2 
                          WHERE  NVL(ERROR, ' ') <> ' ' );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT RowNum_ ,
                   UCIC_ID ,
                   CustomerID ,
                   PAN_No ,
                   --,CustomerName
                   LenderName ,
                   InDefaultDate ,
                   OutOfDefaultDate ,
                   ERROR ,
                   'ErrorData' TableName  
              FROM tt_RPLenderData_2 
             WHERE  NVL(ERROR, ' ') <> ' ' ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT RowNum_ ,
                   UCIC_ID ,
                   CustomerID ,
                   PAN_No ,
                   --,CustomerName
                   LenderName ,
                   CASE 
                        WHEN utils.isdate(InDefaultDate) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(InDefaultDate,200),10,p_style=>103)
                   ELSE InDefaultDate
                      END InDefaultDate  ,
                   CASE 
                        WHEN utils.isdate(OutOfDefaultDate) = 1 THEN UTILS.CONVERT_TO_VARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OutOfDefaultDate,200),10,p_style=>103)
                   ELSE OutOfDefaultDate
                      END OutOfDefaultDate  ,
                   'RPLenderData' TableName  ,
                   Error 
              FROM tt_RPLenderData_2  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_RPLenderData_2 ';

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPLENDERVALIDATION_04122023" TO "ADF_CDR_RBL_STGDB";
