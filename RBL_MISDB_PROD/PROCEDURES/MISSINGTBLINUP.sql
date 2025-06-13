--------------------------------------------------------
--  DDL for Procedure MISSINGTBLINUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MISSINGTBLINUP" /* CREATED BY DF627 on 23-05-24 FOR IDENTIFYING TABLES THAT DO NOT EXIST ANYMORE BUT STILL USED IN THE SP  */ CREATE PROC "dbo" . "MissingTblInUp" AS BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
AS
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TblNotExists ;  --SQLDEV: NOT RECOGNIZED
   v_Cnt NUMBER(10,0) := 1;
   v_Total NUMBER(10,0) := ( SELECT COUNT(SrNo)  
     FROM tt_Temp1  );

BEGIN

   -- This query identifies tables that do not exist anymore but are still used in the SP.
   -- It also defines whether the database exists or not.
   -- Temporary table to hold intermediate results
   IF tt_Temp_98 ;  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_Temp_98;
   UTILS.IDENTITY_RESET('tt_Temp_98');

   INSERT INTO tt_Temp_98 SELECT ServerName ,
                                 CASE 
                                      WHEN S.is_linked = 1 THEN 'Linked Server'
                                 ELSE 'Primary Server'
                                    END ServerType  ,
                                 referenced_database_name Database_Name  ,
                                 referencing_entity_name SP_Name  ,
                                 TableName ,
                                 A.create_date SP_Created_Date  ,
                                 A.modify_date SP_Modified_Date  ,
                                 'Physical/Temporary Table does not exist' Table_Detail  ,
                                 CASE 
                                      WHEN SD.NAME IS NULL THEN 'Database does not exist in the ' || SYS_CONTEXT('USERENV','HOST') || ' SERVER'
                                 ELSE 'Database exists in the ' || SYS_CONTEXT('USERENV','HOST') || ' SERVER'
                                    END Database_Detail  ,
                                 SYSDATE ProcessDate  ,
                                 ObjectID ,
                                 SchemaID 
        FROM ( SELECT CASE 
                           WHEN referenced_server_name IS NULL THEN SYS_CONTEXT('USERENV','HOST')
                      ELSE referenced_server_name
                         END ServerName  ,
                      /*TODO:SQLDEV*/ SCHEMA_NAME(o.schema_id) /*END:SQLDEV*/ || '.' || /*TODO:SQLDEV*/ OBJECT_NAME(sed.referencing_id) /*END:SQLDEV*/ referencing_entity_name  ,
                      NVL(sed.referenced_schema_name, 'Dbo') || '.' || sed.referenced_entity_name TableName  ,
                      CASE 
                           WHEN referenced_database_name IS NULL THEN SYS_CONTEXT('USERENV','')
                      ELSE referenced_database_name
                         END referenced_database_name  ,
                      sp.create_date ,
                      sp.modify_date ,
                      O.OBJECT_ID ObjectID  ,
                      O.SCHEMA_ID SchemaID  
               FROM sys.objects o
                      JOIN sys.sql_expression_dependencies sed   ON sed.referencing_id = o.OBJECT_ID
                      JOIN sys.procedures sp   ON sp.OBJECT_ID = sed.referencing_id
                      AND sp.TYPE = 'P'
                      LEFT JOIN INFORMATION_SCHEMA.COLUMNS_ SC   ON SC.TABLE_NAME = referenced_entity_name
                WHERE  o.TYPE = 'P'
                         AND referenced_id IS NULL
                         AND SC.TABLE_NAME IS NULL
                         AND sed.is_caller_dependent = 0
                         AND sed.is_ambiguous != 1 ) A
               LEFT JOIN sys.databases SD   ON SD.NAME = A.referenced_database_name
               JOIN sys.servers S   ON S.NAME = A.ServerName
             --WHERE referenced_database_name NOT LIKE '%split%'

        ORDER BY referencing_entity_name;
   -- Temporary tables for processing
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_98Cust ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_981 ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_982 ;  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_TempCust;
   UTILS.IDENTITY_RESET('tt_TempCust');

   INSERT INTO tt_TempCust ( 
   	SELECT DISTINCT Database_Name || '.' || TableName FullTableName  ,
                    TableName ,
                    NULL TblDetail  
   	  FROM tt_Temp_98 t
             JOIN sys.databases db   ON db.NAME = t.Database_Name
             AND db.NAME <> SYS_CONTEXT('USERENV','') );
   DELETE FROM tt_Temp1;
   UTILS.IDENTITY_RESET('tt_Temp1');

   INSERT INTO tt_Temp1 SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                FROM DUAL  )  ) SrNo  ,
                               * 
        FROM tt_TempCust ;
   DELETE FROM tt_TblExists;
   DELETE FROM tt_TblNotExists;
   WHILE ( v_Cnt <= v_Total ) 
   LOOP 
      DECLARE
         v_Rn NUMBER(10,0) := ( SELECT SrNo 
           FROM tt_Temp1 
          WHERE  SrNo = v_Cnt );
         v_TblName VARCHAR2(500) := ( SELECT FullTableName 
           FROM tt_Temp1 
          WHERE  SrNo = v_Rn );

      BEGIN
         BEGIN
            DECLARE
               v_Query VARCHAR2(500) := 'INSERT INTO tt_TblExists SELECT ' || UTILS.CONVERT_TO_VARCHAR2(v_Rn,100) || ', COUNT(*) FROM ' || LPAD(' ', 1, ' ') || v_TblName;

            BEGIN
               EXECUTE IMMEDIATE v_Query;

            END;
         EXCEPTION
            WHEN OTHERS THEN

         BEGIN
            INSERT INTO tt_TblNotExists
              ( SELECT v_Rn ,
                       0 
                  FROM DUAL  );

         END;END;
         v_Cnt := v_Cnt + 1 ;

      END;
   END LOOP;
   DELETE t
    WHERE ROWID IN 
   ( SELECT t.ROWID
     FROM tt_Temp1 t1
            JOIN tt_TblExists t2   ON t2.SrNo = t1.SrNo
            JOIN tt_Temp_98 t   ON t.TableName = t1.TableName,
          t );
   INSERT INTO RBL_MISDB_PROD.MissingTbl
     ( ServerName, ServerType, DbName, ObjectID, SchemaID, SpName, TableName, SpCreatedDate, SpModifiedDate, TableInfo, DatabaseInfo, ProcessDate )
     ( SELECT ServerName ,
              ServerType ,
              Database_Name ,
              ObjectID ,
              SchemaID ,
              SP_Name ,
              TableName ,
              SP_Created_Date ,
              SP_Modified_Date ,
              Table_Detail ,
              Database_Detail ,
              ProcessDate 
       FROM tt_Temp_98  );-- Cleanup temporary tables
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_98 ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_981 ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_982 ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_Temp_98Cust ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TblExists ;  --SQLDEV: NOT RECOGNIZED
   ; TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TblNotExists ;  --SQLDEV: NOT RECOGNIZED

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MISSINGTBLINUP" TO "ADF_CDR_RBL_STGDB";
