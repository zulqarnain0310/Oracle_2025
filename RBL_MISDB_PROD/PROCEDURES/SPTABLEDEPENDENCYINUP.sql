--------------------------------------------------------
--  DDL for Procedure SPTABLEDEPENDENCYINUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" /*
AUTHOR - MAMTA (DF627)
DATE - 25-06-24
PURPOSE - THIS CODE INSERT AND UPDATE THE RECORDS OF SP'S LIST AND STORES REFERENCE SERVER, SCHEMA, DB, TABLES, AND COLUMNS INFO ETC 
*/ CREATE PROC "dbo" . "SPTableDependencyInUp" AS BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
AS
   -- Create table tt_SPDependency
   v_CntMax NUMBER(10,0) := ( SELECT COUNT(SrNo)  
     FROM tt_ProcList  );
   v_StrtCnt NUMBER(10,0) := 1;
   v_cursor SYS_REFCURSOR;
   v_cnt NUMBER(10,0) := 1;
   v_totalcnt NUMBER(10,0) := ( SELECT COUNT(*)  
     FROM tt_FinalTemp  );

BEGIN

   -- Drop temporary tables if they exist
   IF tt_ProcList ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_SPDependency ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF #ErrorSp ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_113 ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_FinalTemp ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_MainTbl ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   -- Create temporary table tt_ProcList
   IF tt_ErrorTbl ;  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_ProcList;
   UTILS.IDENTITY_RESET('tt_ProcList');

   INSERT INTO tt_ProcList SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                   FROM DUAL  )  ) SrNo  ,
                                  sp.OBJECT_ID ObjectID  ,
                                  sp.SCHEMA_ID SchemaID  ,
                                  sc.NAME || '.' || sp.NAME SpName  ,
                                  sp.type_desc ,
                                  sp.create_date ,
                                  sp.modify_date 
        FROM sys.procedures sp
               JOIN sys.schemas sc   ON sc.SCHEMA_ID = sp.SCHEMA_ID
       WHERE  sp.TYPE = 'P';
   DELETE FROM tt_SPDependency;
   WHILE ( v_StrtCnt <= v_CntMax ) 
   LOOP 
      DECLARE
         v_ObjectID NUMBER(10,0) := ( SELECT ObjectID 
           FROM tt_ProcList 
          WHERE  SrNo = v_StrtCnt );
         v_SchemaID NUMBER(10,0) := ( SELECT SchemaID 
           FROM tt_ProcList 
          WHERE  SrNo = v_StrtCnt );
         v_procname VARCHAR2(500) := ( SELECT SpName 
           FROM tt_ProcList 
          WHERE  SrNo = v_StrtCnt );
         v_create_date DATE := ( SELECT create_date 
           FROM tt_ProcList 
          WHERE  SrNo = v_StrtCnt );
         v_modify_date DATE := ( SELECT modify_date 
           FROM tt_ProcList 
          WHERE  SrNo = v_StrtCnt );

      BEGIN
         BEGIN

            BEGIN
               INSERT INTO tt_SPDependency
                 ( SELECT referencing_minor_id ,
                          referenced_server_name ,
                          referenced_database_name ,
                          referenced_schema_name ,
                          referenced_entity_name ,
                          referenced_minor_name ,
                          referenced_id ,
                          referenced_minor_id ,
                          referenced_class ,
                          is_caller_dependent ,
                          is_updated ,
                          is_selected ,
                          is_all_columns_found ,
                          v_procname ,
                          v_create_date ,
                          v_modify_date ,
                          v_ObjectID ,
                          v_SchemaID 
                   FROM TABLE(dm_sql_referenced_entities(v_procname, 'OBJECT')) 
                    WHERE  is_ambiguous != 1 );

            END;
         EXCEPTION
            WHEN OTHERS THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT SQLERRM 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;END;
         v_StrtCnt := v_StrtCnt + 1 ;

      END;
   END LOOP;
   -- Delete old entries from SpTableDependencyDtls
   DELETE RBL_MISDB_PROD.SpTableDependencyDtls

    WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDateTime,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   -- Insert new entries into SpTableDependencyDtls
   INSERT INTO RBL_MISDB_PROD.SpTableDependencyDtls
     ( MainDBName, ServerName, ServerType, ReferencedDBName, ReferencedTableName, ReferencedSchemaName, ReferencedColumnName, IsUpdate, IsSelect, IsAllColumnsFound, IsCallerDependent, SpName, SpCreatedDate, SpModifiedDate, TableCreatedDate, TableModifiedDate, ObjectID, SchemaID, ProcessDateTime )
     ( SELECT DISTINCT SYS_CONTEXT('USERENV','') MainDBName  ,
                       COALESCE(SPD.referenced_server_name, SYS_CONTEXT('USERENV','HOST')) ServerName  ,
                       CASE 
                            WHEN S.is_linked = 1 THEN 'Linked Server'
                       ELSE 'Current Server'
                          END ServerType  ,
                       COALESCE(SPD.referenced_database_name, SYS_CONTEXT('USERENV','')) ReferencedDBName  ,
                       SPD.referenced_entity_name ReferencedTableName  ,
                       COALESCE(SPD.referenced_schema_name, /*TODO:SQLDEV*/ SCHEMA_NAME(T.schema_id) /*END:SQLDEV*/) ReferencedSchemaName  ,
                       SPD.referenced_minor_name ReferencedColumnName  ,
                       is_updated ,
                       is_selected ,
                       is_all_columns_found ,
                       is_caller_dependent ,
                       SPName ,
                       CreateSPDate ,
                       ModifiedSPDate ,
                       T.create_date TableViewCreatedDate  ,
                       T.modify_date TableViewModifiedDate  ,
                       SPD.ObjectID ,
                       SPD.SchemaID ,
                       SYSDATE 
       FROM tt_SPDependency SPD
              JOIN SYS.servers S   ON S.NAME = COALESCE(SPD.referenced_server_name, SYS_CONTEXT('USERENV','HOST'))
              LEFT JOIN sys.objects T   ON SPD.referenced_id = T.OBJECT_ID );
   -- Prepare temp table with missing table details
   DELETE FROM tt_Temp_113;
   UTILS.IDENTITY_RESET('tt_Temp_113');

   INSERT INTO tt_Temp_113 ( 
   	SELECT DISTINCT ServerName ,
                    ReferencedDBName ,
                    CASE 
                         WHEN ReferencedSchemaName = ' ' THEN 'DBO'
                    ELSE NVL(ReferencedSchemaName, 'DBO')
                       END ReferencedSchemaName  ,
                    ReferencedTableName 
   	  FROM RBL_MISDB_PROD.SpTableDependencyDtls 
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(ProcessDateTime,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200)
              AND TableCreatedDate IS NULL
              AND IsCallerDependent <> 1 );
   DELETE FROM tt_FinalTemp;
   UTILS.IDENTITY_RESET('tt_FinalTemp');

   INSERT INTO tt_FinalTemp SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                    FROM DUAL  )  ) rn  ,
                                   * 
        FROM tt_Temp_113 ;
   DELETE FROM tt_MainTbl;
   DELETE FROM tt_ErrorTbl;
   WHILE ( v_cnt <= v_totalcnt ) 
   LOOP 
      DECLARE
         v_dbname VARCHAR2(4000) := ( SELECT ReferencedDBName 
           FROM tt_FinalTemp 
          WHERE  rn = v_cnt );
         v_tablename VARCHAR2(4000) := ( SELECT ReferencedTableName 
           FROM tt_FinalTemp 
          WHERE  rn = v_cnt );
         v_schemaname VARCHAR2(4000) := ( SELECT ReferencedSchemaName 
           FROM tt_FinalTemp 
          WHERE  rn = v_cnt );

      BEGIN
         BEGIN
            DECLARE
               v_query VARCHAR2(4000) := 'SELECT ''' || v_dbname || ''', s.name, o.name, o.create_date, o.modify_date, ' || UTILS.CONVERT_TO_VARCHAR2(v_cnt,4000) || ' FROM ' || v_dbname || '.sys.objects o JOIN sys.schemas s ON s.schema_id = o.schema_id WHERE o.name = ''' || v_tablename || ''' AND s.name = ''' || v_schemaname || '''';
               v_temp TT_MAINTBL%ROWTYPE;
               cv_ins SYS_REFCURSOR;

            BEGIN
               cv_ins := EXECUTE IMMEDIATE v_query;
               LOOP
                  FETCH cv_ins INTO v_temp;
                  EXIT WHEN cv_ins%NOTFOUND;
                  INSERT INTO tt_MainTbl VALUES v_temp;
               END LOOP;
               CLOSE cv_ins;

            END;
         EXCEPTION
            WHEN OTHERS THEN

         BEGIN
            INSERT INTO tt_ErrorTbl
              ( SELECT 'TABLE DOES NOT EXISTS' 
                  FROM DUAL  );

         END;END;
         v_cnt := v_cnt + 1 ;

      END;
   END LOOP;
   -- Update SpTableDependencyDtls with table creation and modification dates
   MERGE INTO sp 
   USING (SELECT sp.ROWID row_id, M.create_date, M.modify_date
   FROM sp ,RBL_MISDB_PROD.SpTableDependencyDtls sp
          JOIN tt_MainTbl M   ON M.dbname = sp.ReferencedDBName
          AND M.tablename = sp.ReferencedTableName ) src
   ON ( sp.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET sp.TableCreatedDate = src.create_date,
                                sp.TableModifiedDate = src.modify_date;-- Drop temporary tables
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ProcList ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_SPDependency ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF #ErrorSp ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_113 ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_FinalTemp ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_MainTbl ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ErrorTbl ;  --SQLDEV: NOT RECOGNIZED

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPTABLEDEPENDENCYINUP" TO "ADF_CDR_RBL_STGDB";
