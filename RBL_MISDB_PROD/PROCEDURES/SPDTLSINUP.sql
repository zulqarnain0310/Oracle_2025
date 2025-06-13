--------------------------------------------------------
--  DDL for Procedure SPDTLSINUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SPDTLSINUP" /* CREATED BY DF627 on 05-07-24 FOR STORING THE STORED PROC CODE ALONG WITH LINE NO, CREATED BY, MODIFIED BY, CREATION DATE AND MODIFICATION DATE */ CREATE PROC "dbo" . "SpDtlsInUp" AS BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
AS
   -- Initialize loop variables
   v_Cnt NUMBER(10,0) := 1;
   v_MaxCnt NUMBER(10,0) := ( SELECT COUNT(*)  
     FROM tt_storeproc  );

BEGIN

   -- Drop temporary table if it exists
   -- Create temporary table with stored procedure details
   IF tt_storeproc ;  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_storeproc;
   UTILS.IDENTITY_RESET('tt_storeproc');

   INSERT INTO tt_storeproc SELECT ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                    FROM DUAL  )  ) SrNo  ,
                                   OBJECT_ID ,
                                   SCHEMA_ID ,
                                   /*TODO:SQLDEV*/ SCHEMA_NAME(schema_id) /*END:SQLDEV*/ || '.' || NAME Spname  ,
                                   create_date ,
                                   modify_date 
        FROM sys.objects S
               LEFT JOIN RBL_MISDB_PROD.SpDtls Sp   ON Sp.ObjectID = S.OBJECT_ID
               AND Sp.SchemaID = S.SCHEMA_ID
               AND Sp.SpModifiedDate = S.modify_date
       WHERE  TYPE = 'P'
                AND Sp.SpModifiedDate IS NULL;
   -- Loop through each row in the temporary table
   WHILE ( v_Cnt <= v_MaxCnt ) 
   LOOP 
      DECLARE
         v_Spname VARCHAR2(4000) := ( SELECT Spname 
           FROM tt_storeproc 
          WHERE  SrNo = v_Cnt );
         v_SpCreatedDate DATE := ( SELECT create_date 
           FROM tt_storeproc 
          WHERE  SrNo = v_Cnt );
         v_SpModifiedDate DATE := ( SELECT modify_date 
           FROM tt_storeproc 
          WHERE  SrNo = v_Cnt );
         v_ObjectID NUMBER(10,0) := ( SELECT OBJECT_ID 
           FROM tt_storeproc 
          WHERE  SrNo = v_Cnt );
         v_SchemaID NUMBER(10,0) := ( SELECT SCHEMA_ID 
           FROM tt_storeproc 
          WHERE  SrNo = v_Cnt );

      BEGIN
         -- Insert stored procedure details into [dbo].[SpDtls]
         INSERT INTO RBL_MISDB_PROD.SpDtls
           ( ObjectID, SchemaID, Spcode, Spname, LineNumber, SpCreatedDate, SpModifiedDate, ProcessDate )
           SELECT v_ObjectID ,
                  v_SchemaID ,
                  VALUE LineText  ,
                  v_Spname ,
                  ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                   FROM DUAL  )  ) LineNumber  ,
                  v_SpCreatedDate ,
                  v_SpModifiedDate ,
                  SYSDATE 
             FROM sys.sql_modules M
                     /*TODO:SQLDEV*/ CROSS APPLY STRING_SPLIT(m.definition, CHAR(10)) AS s /*END:SQLDEV*/ 
            WHERE  M.OBJECT_ID = utils.object_id(v_Spname);
         -- Increment counter
         v_Cnt := v_Cnt + 1 ;

      END;
   END LOOP;
   -- Update CreatedBy based on change log
   MERGE INTO S 
   USING (SELECT S.ROWID row_id, CASE 
   WHEN EventType = 'CREATE_PROCEDURE' THEN LoginName   END AS CreatedBy
   FROM S ,RBL_MISDB_PROD.SpDtls S
          JOIN RBL_MISDB_PROD.DbObjChangeLog D   ON D.ObjectID = S.ObjectID
          AND D.SchemaID = S.SchemaID
          AND UTILS.CONVERT_TO_DATETIME(UTILS.CONVERT_TO_VARCHAR2(PostTime,20,p_style=>120)) = UTILS.CONVERT_TO_DATETIME(UTILS.CONVERT_TO_VARCHAR2(SpCreatedDate,20,p_style=>120)) ) src
   ON ( S.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET S.CreatedBy = src.CreatedBy;
   -- Update ModifiedBy based on change log
   MERGE INTO S 
   USING (SELECT S.ROWID row_id, CASE 
   WHEN EventType = 'ALTER_PROCEDURE' THEN LoginName   END AS ModifiedBy
   FROM S ,RBL_MISDB_PROD.SpDtls S
          JOIN RBL_MISDB_PROD.DbObjChangeLog D   ON D.ObjectID = S.ObjectID
          AND D.SchemaID = S.SchemaID
          AND UTILS.CONVERT_TO_DATETIME(UTILS.CONVERT_TO_VARCHAR2(PostTime,20,p_style=>120)) = UTILS.CONVERT_TO_DATETIME(UTILS.CONVERT_TO_VARCHAR2(SpModifiedDate,20,p_style=>120)) ) src
   ON ( S.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET S.ModifiedBy = src.ModifiedBy;-- Drop temporary table
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_storeproc ;  --SQLDEV: NOT RECOGNIZED

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SPDTLSINUP" TO "ADF_CDR_RBL_STGDB";
