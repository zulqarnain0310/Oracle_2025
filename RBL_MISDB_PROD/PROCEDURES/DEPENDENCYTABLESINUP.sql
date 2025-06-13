--------------------------------------------------------
--  DDL for Procedure DEPENDENCYTABLESINUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" /*  CREATED BY DF627 ON 24-05-24 FOR THE PURPOSE OF IDENTIFYING DEPENDENCY OF THE TABLES */
AS

BEGIN

   -- Finding the dependency of any table irrespective of the database on the same server
   -- and this can be used for identifying one more thing that
   -- if one table we are using of another db then that should be common
   -- in all the sps of the current database as well
   INSERT INTO RBL_MISDB_PROD.TableDependencyDtls
     ( SELECT ServerName ,
              CASE 
                   WHEN is_linked = 1 THEN 'Linked DB Server'
              ELSE 'Main DB Server'
                 END ServerType  ,
              DbName Db_Name  ,
              ObjectID ,
              SchemaID ,
              referencing_object Sp_Name  ,
              NVL(referenced_schema_name, 'dbo') || '.' || referenced_entity_name Table_Name  ,
              Sp_Created_Date ,
              Sp_Modified_Date ,
              CASE 
                   WHEN is_linked = 1 THEN 'Information not available'
                   WHEN DbName <> SYS_CONTEXT('USERENV','') THEN 'Information not available'
              ELSE Table_Info
                 END Table_Info  ,
              CASE 
                   WHEN is_linked = 1 THEN 'Information not available'
              ELSE Database_Info
                 END Database_Info  ,
              SYSDATE ProcessDate  
       FROM ( SELECT CASE 
                          WHEN referenced_server_name IS NULL THEN SYS_CONTEXT('USERENV','HOST')
                     ELSE referenced_server_name
                        END ServerName  ,
                     /*TODO:SQLDEV*/ SCHEMA_NAME(op.schema_id) /*END:SQLDEV*/ || '.' || /*TODO:SQLDEV*/ OBJECT_NAME(referencing_id) /*END:SQLDEV*/ referencing_object  ,
                     COALESCE(referenced_database_name, SYS_CONTEXT('USERENV','')) DbName  ,
                     referenced_schema_name ,
                     referenced_entity_name ,
                     op.create_date Sp_Created_Date  ,
                     op.modify_date Sp_Modified_Date  ,
                     CASE 
                          WHEN sd.NAME IS NULL THEN 'Database does not exist'
                     ELSE 'Database exists'
                        END Database_Info  ,
                     CASE 
                          WHEN t.NAME IS NULL THEN 'Table does not exist'
                     ELSE 'Table exists'
                        END Table_Info  ,
                     op.OBJECT_ID ObjectID  ,
                     op.SCHEMA_ID SchemaID  
              FROM sys.sql_expression_dependencies S
                     JOIN sys.objects op   ON op.OBJECT_ID = S.referencing_id
                     LEFT JOIN sys.databases sd   ON sd.NAME = COALESCE(referenced_database_name, SYS_CONTEXT('USERENV',''))
                     LEFT JOIN sys.objects t   ON t.OBJECT_ID = S.referenced_id
               WHERE  S.is_ambiguous != 1 --ADDED ON 02/07/24
             ) 
            -- Uncomment and modify the below lines for specific filtering

            -- WHERE OBJECT_NAME(referencing_id) LIKE '%dummy%'

            -- WHERE referenced_entity_name LIKE '%customerbasicdetail%'
            A
              JOIN sys.servers S   ON S.NAME = A.ServerName );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DEPENDENCYTABLESINUP" TO "ADF_CDR_RBL_STGDB";
