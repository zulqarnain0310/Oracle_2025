--------------------------------------------------------
--  DDL for Procedure BUYOUTMAPPERGETUPLOADSTATUS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" 
(
  v_FileName IN VARCHAR2,
  v_Level IN VARCHAR2
)
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM RBL_MISDB_PROD.UploadStatus 
                       WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName
                                AND v_Level = 'Upload' );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DELETE UploadStatus

       WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName;

   END;
   ELSE
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM RBL_MISDB_PROD.UploadStatus 
                              WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName )
        AND v_Level = 'Upload';
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT 'OK' StatusOfUpload  ,
                   v_FileName FileNames  ,
                   ' ' Error  ,
                   'UploadStatus' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM RBL_MISDB_PROD.UploadStatus 
                             WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName
                                      AND NVL(ValidationOfSheetNames, 'N') = 'Y'
                                      AND NVL(ValidationOfData, 'N') = 'Y'
                                      AND NVL(InsertionOfData, 'N') = 'Y' )
           AND v_Level = 'Upload';
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT 'OK' StatusOfUpload  ,
                      v_FileName FileNames  ,
                      ' ' Error  ,
                      'UploadStatus' TableName  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF v_Level = 'Upload' THEN

            BEGIN
               OPEN  v_cursor FOR
                  SELECT 'NOT OK' StatusOfUpload  ,
                         v_FileName FileNames  ,
                         'File Upload is In Progress By Other User' ErrorMsg  ,
                         'UploadStatus' TableName  
                    FROM DUAL  ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            ELSE

            BEGIN
               IF v_Level = 'VOS' THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

                --- Validation of SheetName
               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM RBL_MISDB_PROD.ErrorMessageVOS 
                                      WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT ErrorMsg ,
                               Flag ,
                               TableName ,
                               FileNames 
                          FROM RBL_MISDB_PROD.ErrorMessageVOS 
                         WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  ELSE
                  DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM RBL_MISDB_PROD.UploadStatus 
                                         WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT 'Validating Header and Sheet Name' ErrorMsg  ,
                                  'In Progress' Flag  ,
                                  'ErrorInUpload' TableName  ,
                                  v_FileName FileNames  ,
                                  ' ' Srnooferroneousrows  
                             FROM DUAL  ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     ELSE

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT NULL ErrorMsg  ,
                                  NULL Flag  ,
                                  'ErrorInUpload' TableName  ,
                                  NULL FileNames  ,
                                  NULL Srnooferroneousrows  
                             FROM DUAL  ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     END IF;

                  END;
                  END IF;

               END;
               END IF;
               IF v_Level = 'VOD' THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

                --- Validation of Data In excels
               BEGIN
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM RBL_MISDB_PROD.MasterUploadData 
                                      WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN
                   DECLARE
                     v_temp NUMBER(1, 0) := 0;

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE(1111111111);
                     --Select SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows
                     --from dbo.MasterUploadData
                     --where FileNames=@FileName
                     --AND ISNULL(ERRORDATA,'')<>''
                     --ORDER BY ErrorData DESC
                     BEGIN
                        SELECT 1 INTO v_temp
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1 
                                        FROM RBL_MISDB_PROD.MasterUploadData 
                                         WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName
                                                  AND CAST(NVL(ErrorData, ' ') AS VARCHAR(1000)) <> ' ' );
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF v_temp = 1 THEN

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT SR_No ,
                                  ColumnName ,
                                  ErrorData ,
                                  ErrorType ,
                                  FileNames ,
                                  Flag ,
                                  Srnooferroneousrows ,
                                  'Validation' TableName  
                             FROM RBL_MISDB_PROD.MasterUploadData 

                           --(SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames ORDER BY ColumnName,ErrorData,ErrorType,FileNames )AS ROW 

                           --FROM  dbo.MasterUploadData    )a 

                           --WHERE A.ROW=1
                           WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName
                                    AND CAST(NVL(ERRORDATA, ' ') AS VARCHAR(1000))<> ' '
                             ORDER BY SR_No ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     ELSE

                     BEGIN
                        OPEN  v_cursor FOR
                           SELECT SR_No ,
                                  ColumnName ,
                                  ErrorData ,
                                  ErrorType ,
                                  FileNames ,
                                  Flag ,
                                  Srnooferroneousrows ,
                                  'Validation' TableName  
                             FROM ( SELECT SR_NO	,
                                        COLUMNNAME	,
                                        ERRORDATA	,
                                        ERRORTYPE	,
                                        FILENAMES	,
                                        FLAG	,
                                        SRNOOFERRONEOUSROWS	,
                                           ROW_NUMBER() OVER ( PARTITION BY ColumnName, ErrorData, ErrorType, FileNames ORDER BY ColumnName, ErrorData, ErrorType, FileNames  ) ROW  
                                    FROM RBL_MISDB_PROD.MasterUploadData  ) a
                            WHERE  A.ROW = 1
                                     AND CAST(FileNames AS VARCHAR(1000))= v_FileName ;
                           DBMS_SQL.RETURN_RESULT(v_cursor);

                     END;
                     END IF;

                  END;

                  --ORDER BY ErrorData DESC
                  ELSE

                  BEGIN
                     OPEN  v_cursor FOR
                        SELECT ' ' SR_No  ,
                               ' ' ColumnName  ,
                               ' ' ErrorData  ,
                               ' ' ErrorType  ,
                               v_FileName FileNames  ,
                               'SUCCESS' Flag  ,
                               ' ' Srnooferroneousrows  ,
                               'Validation' TableName  
                          FROM DUAL  ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;

               END;
               END IF;
               IF v_Level = 'TOT' THEN

                --- Truncate of Table
               BEGIN
                  OPEN  v_cursor FOR
                     SELECT NVL(TruncateTable, 'N') StatusOfUpload  ,
                            v_FileName FileNames  ,
                            CASE 
                                 WHEN NVL(TruncateTable, 'N') = 'N' THEN 'Truncating Table'
                            ELSE 'Truncation Complete'
                               END ErrorMsg  ,
                            CASE 
                                 WHEN NVL(TruncateTable, 'N') = 'N' THEN 'In Progress'
                                 WHEN NVL(TruncateTable, 'N') = 'E' THEN 'Error'
                            ELSE 'SUCCESS'
                               END Flag  ,
                            'ErrorInUpload' TableName  
                       FROM UploadStatus 
                      WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);
                  DELETE UploadStatus

                   WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName;

               END;
               END IF;
               IF v_Level = 'IOD' THEN

                --- Insertion Of Data
               BEGIN
                  OPEN  v_cursor FOR
                     SELECT NVL(InsertionOfData, 'N') StatusOfUpload  ,
                            v_FileName FileNames  ,
                            CASE 
                                 WHEN NVL(InsertionOfData, 'N') = 'N' THEN 'Inserting Data'
                            ELSE 'Data Insertion Complete'
                               END ErrorMsg  ,
                            CASE 
                                 WHEN NVL(InsertionOfData, 'N') = 'N' THEN 'In Progress'
                                 WHEN NVL(InsertionOfData, 'N') = 'E' THEN 'Error'
                            ELSE 'SUCCESS'
                               END Flag  

                       -- ,'ErrorInUpload' as TableName
                       FROM UploadStatus 
                      WHERE  CAST(FileNames AS VARCHAR(1000))= v_FileName ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;

            END;
            END IF;
         END IF;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTMAPPERGETUPLOADSTATUS" TO "ADF_CDR_RBL_STGDB";
