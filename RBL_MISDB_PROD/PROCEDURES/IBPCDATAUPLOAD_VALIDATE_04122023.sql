--------------------------------------------------------
--  DDL for Procedure IBPCDATAUPLOAD_VALIDATE_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

(
  v_XMLDocument IN CLOB DEFAULT u'' ,
  v_ScreenName IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   DBMS_OUTPUT.PUT_LINE('IBPCDataUpload_Validate');
   IF utils.object_id('Tempdb..tt_IBPCDataUpload_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_IBPCDataUpload_2 ';
   END IF;
   DELETE FROM tt_IBPCDataUpload_2;
   UTILS.IDENTITY_RESET('tt_IBPCDataUpload_2');

   INSERT INTO tt_IBPCDataUpload_2 ( 
   	SELECT /*TODO:SQLDEV*/ C.value('./Soldto				[1]','VARCHAR(50)'	) /*END:SQLDEV*/ ParticipatingBank  ,
           /*TODO:SQLDEV*/ C.value('./CustID				[1]','VARCHAR(20)'	) /*END:SQLDEV*/ CustomerId  ,
           /*TODO:SQLDEV*/ C.value('./AccountNumber					[1]','VARCHAR(30)'	) /*END:SQLDEV*/ CustomerACID  ,
           /*TODO:SQLDEV*/ C.value('./Segment				[1]','VARCHAR(100)'	) /*END:SQLDEV*/ REMARK  ,
           /*TODO:SQLDEV*/ C.value('./Customer				[1]','VARCHAR(100)'	) /*END:SQLDEV*/ CUSTOMERNAME  ,
           /*TODO:SQLDEV*/ C.value('./IBPCSep19					[1]','VARCHAR(30)'	) /*END:SQLDEV*/ IBPC_Amount  

   	  --FROM @XMLDocument.nodes('/DataSet/BondsUploadEntry') AS t(c)
   	  FROM TABLE(/*TODO:SQLDEV*/ @XMLDocument.nodes('/Root/Sheet1') AS t(c) /*END:SQLDEV*/)  );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_IBPCDataUpload_2 
      ADD ( SrNo NUMBER(10,0)  ) ';
   MERGE INTO tt_IBPCDataUpload_2 
   USING (SELECT tt_IBPCDataUpload_2.ROWID row_id, RowNo
   FROM tt_IBPCDataUpload_2 ,( SELECT ROW_NUMBER() OVER ( ORDER BY tt_IBPCDataUpload_2.CustomerId  ) RowNo  ,
                                      tt_IBPCDataUpload_2.CustomerId 
                               FROM tt_IBPCDataUpload_2  ) D 
    WHERE D.CustomerId = tt_IBPCDataUpload_2.CustomerId) src
   ON ( tt_IBPCDataUpload_2.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET tt_IBPCDataUpload_2.SrNo = RowNo;
   DELETE FROM tt_ErrorData_2;
   --,Row_No  SMALLINT  
   --ISNUMERIC(T.Amount)
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              CustomerId ,
              'CustomerId' columnName  ,
              NVL(CustomerId, ' ') errorData  ,
              'CustomerId should be a numeric' errorDescription  
       FROM tt_IBPCDataUpload_2 
        WHERE  utils.isnumeric(CustomerId) = 0
                 AND NVL(CustomerId, ' ') <> ' ' );
   ---------
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              CustomerId ,
              'Customer Id' ,
              CustomerId ,
              'Customer Id  Allows max 8 digits value' 
       FROM tt_IBPCDataUpload_2 
        WHERE  LENGTH(NVL(CustomerId, ' ')) > 5
                 AND NVL(CustomerId, ' ') <> ' ' );
   ---------------
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              ParticipatingBank ,
              'SoldTo' columnName  ,
              NVL(ParticipatingBank, ' ') errorData  ,
              'Sold to should be containing alphanumeric value' errorDescription  
       FROM tt_IBPCDataUpload_2 
        WHERE  REGEXP_LIKE(ParticipatingBank, '%[0-9][a-zA-Z]%')
                 AND ParticipatingBank LIKE '%()><.,?/[]{}*&^%$#@!%' );
   --------
   ---------
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              CustomerACID ,
              'Customer ACID' ,
              CustomerACID ,
              'Customer ACCOUNT ID  Allows max 8 digits value' 
       FROM tt_IBPCDataUpload_2 
        WHERE  LENGTH(NVL(CustomerACID, ' ')) > 12
                 AND NVL(CustomerACID, ' ') <> ' ' );
   ---
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              REMARK ,
              'Segment' ,
              REMARK ,
              'Segment should be containing character value' 
       FROM tt_IBPCDataUpload_2 
        WHERE  NVL(REMARK, ' ') <> ' '
                 AND REGEXP_LIKE(REMARK, '%[a-zA-Z]%') );
   ----
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              CUSTOMERNAME ,
              'Customer Name' ,
              CUSTOMERNAME ,
              'Customer Name should be containing alphanumeric value' 
       FROM tt_IBPCDataUpload_2 
        WHERE  NVL(CUSTOMERNAME, ' ') <> ' '
                 AND REGEXP_LIKE(CUSTOMERNAME, '%[a-zA-Z]%') );
   -----------
   INSERT INTO tt_ErrorData_2
     ( srno, CustomerId, columnName, errorData, errorDescription )
     ( SELECT srno ,
              IBPC_Amount ,
              'IBPC_Amount' ,
              IBPC_Amount ,
              'IBPC_Amount contains numeric values' 
       FROM tt_IBPCDataUpload_2 
        WHERE  utils.isnumeric(IBPC_Amount) = 0
                 AND NVL(IBPC_Amount, ' ') <> ' ' );
   ---------
   OPEN  v_cursor FOR
      SELECT srno ,
             CustomerId ,
             columnName ,
             errorData ,
             errorDescription ,
             'validationerror' TableName  
        FROM tt_ErrorData_2 
        ORDER BY srno ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IBPCDATAUPLOAD_VALIDATE_04122023" TO "ADF_CDR_RBL_STGDB";
