--------------------------------------------------------
--  DDL for Procedure CLOBTOBLOB_SQLDEVELOPER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" 
  ( 
    tableNameL      VARCHAR2 , 
    clobColumnNameL VARCHAR2, 
    blobColumnNameL VARCHAR2 ) 
AS 
  tableName      VARCHAR2 ( 500 ) := '';--to_UPPER(tableNameL); 
  clobColumnName VARCHAR2 ( 500 ) := '';--to_UPPER(clobColumNameL); 
  blobColumnName VARCHAR2 ( 500 ) := '';--to_UPPER(blobColumNameL); 
  tmpString      VARCHAR2 ( 500 ) := ''; 
  errorOut       BOOLEAN          := false; 
  inputLength    NUMBER; -- size of input CLOB 
  offSet         NUMBER := 1; 
  pieceMaxSize   NUMBER := 4000;          -- the max size of each peice large for 12c
  piece          VARCHAR2 ( 4000 CHAR ) ; -- these pieces will make up the entire CLOB 
  currentPlace   NUMBER := 1;            -- this is where were up to in the CLOB 
  blobLoc BLOB;                          -- blob locator in the table 
  clobLoc CLOB;                          -- clob locator pointsthis is the value from the dat file 
  myquery VARCHAR2 ( 2000 ) ; 
  -- THIS HAS TO BE CHANGED FOR SPECIFIC CUSTOMER TABLE 
  -- AND COLUMN NAMES 
  --CURSOR cur; 
TYPE cur_typ 
IS 
  REF 
  CURSOR; 
    cur cur_typ; 
    --cur_rec cur%ROWTYPE; 
  BEGIN 
    tableName      := UPPER ( tableNameL ) ; 
    clobColumnName := UPPER ( clobColumnNameL ) ; 
    blobColumnName := UPPER ( blobColumnNameL ) ; 
    BEGIN 
      EXECUTE immediate 'select table_name from user_tables where table_name = :1 ' INTO tmpString USING tableName; 
      IF ( tmpString != tableName ) THEN 
        errorOut     := true; 
      ELSE 
        BEGIN 
          EXECUTE immediate 'select COLUMN_NAME from user_tab_columns where table_name = :1 and COLUMN_NAME = :2 ' INTO tmpString USING tableName, clobColumnName; 
          IF ( tmpString != clobColumnName ) THEN 
            errorOut     := true; 
          ELSE 
            EXECUTE immediate 'select COLUMN_NAME from user_tab_columns where table_name = :1 and COLUMN_NAME = :2 ' INTO tmpString USING tableName, blobColumnName; 
            IF ( tmpString != blobColumnName ) THEN 
              errorOut     := true; 
            END IF; 
          END IF; 
        END; 
      END IF; 
    EXCEPTION 
    WHEN OTHERS THEN 
      errorOut := true; 
    END; 
    IF ( errorOut = true ) THEN 
      raise_application_error ( -20001, 'Invalid parameters' ) ; 
    END IF; 
    EXECUTE immediate 'update ' || tableName || ' set ' || blobColumnName || '= empty_blob() ' ; 
    myquery := 'SELECT '||clobColumnName||' clob_column , '||blobColumnName||' blob_column FROM ' || tableName || ' FOR UPDATE'; 
    OPEN cur FOR myquery;-- using clobColumName, blobColumnName ; 
    FETCH cur 
       INTO clobLoc, 
      blobLoc ; 

  WHILE cur%FOUND 
  LOOP 
    --RETRIVE THE clobLoc and blobLoc 
    --clobLoc := cur_rec.clob_column; 
    --blobLoc := cur_rec.blob_column; 
    currentPlace := 1; -- reset evertime 
    -- find the lenght of the clob 
    inputLength := DBMS_LOB.getLength ( clobLoc ) ; 
    -- loop through each peice 
    LOOP 
      IF (inputLength > 1) /* if originally zero length, could have a chr(0) character */ 
      THEN 
        -- get the next piece and add it to the clob 
        piece := DBMS_LOB.subStr ( clobLoc,pieceMaxSize,currentPlace ) ; 
        -- append this piece to the BLOB 
        DBMS_LOB.WRITEAPPEND ( blobLoc, LENGTH ( piece ) /2, HEXTORAW ( piece ) ) ; 
      END IF; 
      currentPlace := currentPlace                     + pieceMaxSize ; 
      EXIT 
    WHEN inputLength < currentplace; 
    END LOOP; 
    FETCH cur 
       INTO clobLoc, 
      blobLoc ; 
  END LOOP; 
  EXECUTE immediate 'alter table ' || tableName || ' drop column ' || clobColumnName; 
  --unnecessary after ddl 
  COMMIT; 
END CLOBtoBLOB_sqldeveloper;

/

  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_TEMPDB"."CLOBTOBLOB_SQLDEVELOPER" TO "ADF_CDR_RBL_STGDB";
