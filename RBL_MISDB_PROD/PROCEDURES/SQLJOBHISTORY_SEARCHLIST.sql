--------------------------------------------------------
--  DDL for Procedure SQLJOBHISTORY_SEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" 
(
  v_JobName IN VARCHAR2,
  v_StartDate IN VARCHAR2,
  v_EndDate IN VARCHAR2
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   --set @StartDate= convert(date,@StartDate,103)
   --set @EndDate= convert(date,@EndDate,103)
   --print @StartDate
   --print @EndDate
   IF ( ( NVL(v_JobName, ' ') = ' ' )
     AND ( NVL(v_StartDate, ' ') = ' ' ) ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT UserId ,
                JobName ,
                JobAction ,
                Remarks ,
                DateOfJob DateOfJobExecution  ,
                IP_Address ,
                AttachedFilePath ,
                ActionResult ,
                ErrorMessage 
           FROM JobLogsHistory 
           ORDER BY 2,
                    5 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;

   --where          convert(date,DateOfJob,103) >= convert(date,@StartDate,103)

   --and            convert(date,DateOfJob,103) <= convert(date,@EndDate,103)

   --and            JobName=@JobName
   ELSE
      IF ( ( NVL(v_JobName, ' ') = ' ' )
        AND ( NVL(v_StartDate, ' ') <> ' ' ) ) THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT UserId ,
                   JobName ,
                   JobAction ,
                   Remarks ,
                   DateOfJob DateOfJobExecution  ,
                   IP_Address ,
                   AttachedFilePath ,
                   ActionResult ,
                   ErrorMessage 
              FROM JobLogsHistory 
             WHERE  UTILS.CONVERT_TO_VARCHAR2(DateOfJob,200,p_style=>103) >= UTILS.CONVERT_TO_VARCHAR2(v_StartDate,200,p_style=>103)
                      AND UTILS.CONVERT_TO_VARCHAR2(DateOfJob,200,p_style=>103) <= UTILS.CONVERT_TO_VARCHAR2(v_EndDate,200,p_style=>103)
              ORDER BY 2,
                       5 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;

      --and            JobName=@JobName
      ELSE
         IF ( ( NVL(v_JobName, ' ') <> ' ' )
           AND ( NVL(v_StartDate, ' ') = ' ' ) ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT UserId ,
                      JobName ,
                      JobAction ,
                      Remarks ,
                      DateOfJob DateOfJobExecution  ,
                      IP_Address ,
                      AttachedFilePath ,
                      ActionResult ,
                      ErrorMessage 
                 FROM JobLogsHistory 

               --where          convert(date,DateOfJob,103) >= convert(date,@StartDate,103)

               --and            convert(date,DateOfJob,103) <= convert(date,@EndDate,103)
               WHERE  JobName = v_JobName
                 ORDER BY 2,
                          5 ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF ( ( NVL(v_JobName, ' ') <> ' ' )
              AND ( NVL(v_StartDate, ' ') <> ' ' ) ) THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT UserId ,
                         JobName ,
                         JobAction ,
                         Remarks ,
                         DateOfJob DateOfJobExecution  ,
                         IP_Address ,
                         AttachedFilePath ,
                         ActionResult ,
                         ErrorMessage 
                    FROM JobLogsHistory 
                   WHERE  UTILS.CONVERT_TO_VARCHAR2(DateOfJob,200,p_style=>103) >= UTILS.CONVERT_TO_VARCHAR2(v_StartDate,200,p_style=>103)
                            AND UTILS.CONVERT_TO_VARCHAR2(DateOfJob,200,p_style=>103) <= UTILS.CONVERT_TO_VARCHAR2(v_EndDate,200,p_style=>103)
                            AND JobName = v_JobName
                    ORDER BY 2,
                             5 ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SQLJOBHISTORY_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
