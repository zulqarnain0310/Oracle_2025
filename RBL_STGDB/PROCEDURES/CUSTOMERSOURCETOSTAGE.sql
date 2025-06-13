--------------------------------------------------------
--  DDL for Procedure CUSTOMERSOURCETOSTAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."CUSTOMERSOURCETOSTAGE" 
AS
   v_cursor SYS_REFCURSOR;--rollback tran

BEGIN
   BEGIN
      DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         --------------------------------------Finacle Customer------------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'CustomerSourceToStageDB'
                                   AND TableName = 'CUSTOMER_SOURCESYSTEM01_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'CustomerSourceToStageDB'
                              AND TableName = 'CUSTOMER_SOURCESYSTEM01_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'CustomerSourceToStageDB'
                      AND TableName = 'CUSTOMER_SOURCESYSTEM01_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'CustomerSourceToStageDB' ,
                       'CUSTOMER_SOURCESYSTEM01_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE CUSTOMER_SOURCESYSTEM01_STG ';
            INSERT INTO RBL_STGDB.CUSTOMER_SOURCESYSTEM01_STG
              ( DateOfData, SourceSystem, UCIC_ID, CustomerID, CustomerName, Constitution, Gender, SegmentCode, PANNO, PrevQtrRV, CurrQtrRV, AssetClass, NPADate, DBT_LOS_Date, AlwaysNPA )
              ( SELECT date_of_data ,
                       Source_System ,
                       UCIC_ID ,
                       Customer_ID ,
                       Customer_Name ,
                       Customer_Constitution ,
                       Gender ,
                       Customer_Segment_Code ,
                       PAN_No ,
                       NULL PrevQtrRV  ,
                       NULL CurrQtrRV  ,
                       Asset_Class ,
                       NPA_Date ,
                       DBT_LOS_Date ,
                       Always_NPA 
                FROM DWH_STG.customer_data_finacle  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'CUSTOMER_SOURCESYSTEM01_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.customer_data_finacle  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.CUSTOMER_SOURCESYSTEM01_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'CUSTOMER_SOURCESYSTEM01_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'CUSTOMER_SOURCESYSTEM01_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------ECBF Customer------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'CustomerSourceToStageDB'
                                   AND TableName = 'CUSTOMER_SOURCESYSTEM03_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'CustomerSourceToStageDB'
                              AND TableName = 'CUSTOMER_SOURCESYSTEM03_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'CustomerSourceToStageDB'
                      AND TableName = 'CUSTOMER_SOURCESYSTEM03_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'CustomerSourceToStageDB' ,
                       'CUSTOMER_SOURCESYSTEM03_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE CUSTOMER_SOURCESYSTEM03_STG ';
            INSERT INTO RBL_STGDB.CUSTOMER_SOURCESYSTEM03_STG
              ( DateOfData, SourceSystem, UCIC_ID, CustomerID, CustomerName, Constitution, Gender, SegmentCode, PANNO, PrevQtrRV, CurrQtrRV, AssetClass, NPADate, DBT_LOS_Date, AlwaysNPA )
              ( SELECT date_of_data ,
                       Source_System ,
                       UCIC_ID ,
                       Customer_ID ,
                       Customer_Name ,
                       Customer_Constitution ,
                       Gender ,
                       Customer_Segment_Code ,
                       PAN_No ,
                       NULL PrevQtrRV  ,
                       NULL CurrQtrRV  ,
                       Asset_Class ,
                       NPA_Date ,
                       DBT_LOS_Date ,
                       Always_NPA 
                FROM DWH_STG.customer_data_ecbf  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'CUSTOMER_SOURCESYSTEM03_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.customer_data_ecbf  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.CUSTOMER_SOURCESYSTEM03_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'CUSTOMER_SOURCESYSTEM03_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM03_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM03_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'CUSTOMER_SOURCESYSTEM03_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------VP Customer------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'CustomerSourceToStageDB'
                                   AND TableName = 'CUSTOMER_SOURCESYSTEM06_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'CustomerSourceToStageDB'
                              AND TableName = 'CUSTOMER_SOURCESYSTEM06_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'CustomerSourceToStageDB'
                      AND TableName = 'CUSTOMER_SOURCESYSTEM06_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'CustomerSourceToStageDB' ,
                       'CUSTOMER_SOURCESYSTEM06_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE CUSTOMER_SOURCESYSTEM06_STG ';
            INSERT INTO RBL_STGDB.CUSTOMER_SOURCESYSTEM06_STG
              ( DateOfData, SourceSystem, UCIC_ID, CustomerID, CustomerName, Constitution, Gender, SegmentCode, PANNO, PrevQtrRV, CurrQtrRV, AssetClass, NPADate, DBT_LOS_Date, AlwaysNPA )
              ( SELECT date_of_data ,
                       source_system_name ,
                       UCIC_ID ,
                       Customer_ID ,
                       Customer_Name ,
                       Customer_Constitution ,
                       Gender ,
                       Customer_Segment_Code ,
                       PAN_No ,
                       NULL PrevQtrRV  ,
                       NULL CurrQtrRV  ,
                       Asset_Class ,
                       NPA_Date ,
                       DBT_LOS_Date ,
                       Always_NPA 
                FROM DWH_STG.Customer_data_visionplus  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'CUSTOMER_SOURCESYSTEM06_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.Customer_data_visionplus  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.CUSTOMER_SOURCESYSTEM06_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'CUSTOMER_SOURCESYSTEM06_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM06_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM06_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'CUSTOMER_SOURCESYSTEM06_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------FIS Customer------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'CustomerSourceToStageDB'
                                   AND TableName = 'CUSTOMER_SOURCESYSTEM07_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'CustomerSourceToStageDB'
                              AND TableName = 'CUSTOMER_SOURCESYSTEM07_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'CustomerSourceToStageDB'
                      AND TableName = 'CUSTOMER_SOURCESYSTEM07_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'CustomerSourceToStageDB' ,
                       'CUSTOMER_SOURCESYSTEM07_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE CUSTOMER_SOURCESYSTEM07_STG ';
            INSERT INTO RBL_STGDB.CUSTOMER_SOURCESYSTEM07_STG
              ( DateOfData, SourceSystem, UCIC_ID, CustomerID, CustomerName, Constitution, Gender, SegmentCode, PANNO, PrevQtrRV, CurrQtrRV, AssetClass, NPADate, DBT_LOS_Date, AlwaysNPA )
              ( SELECT Date_of_Data ,
                       Source_System ,
                       UCIC_ID ,
                       Customer_ID ,
                       Customer_Name ,
                       Customer_Constitution ,
                       Gender ,
                       Customer_Segment_Code ,
                       PAN_No ,
                       NULL PrevQtrRV  ,
                       NULL CurrQtrRV  ,
                       Asset_Class ,
                       npa_date ,
                       DBT_LOS_Date ,
                       Always_NPA 
                FROM DWH_STG.customer_data_fis  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'CUSTOMER_SOURCESYSTEM07_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.customer_data_fis  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.CUSTOMER_SOURCESYSTEM07_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'CUSTOMER_SOURCESYSTEM07_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM07_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM07_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'CUSTOMER_SOURCESYSTEM07_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------EIFS Customer------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'CustomerSourceToStageDB'
                                   AND TableName = 'CUSTOMER_SOURCESYSTEM08_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'CustomerSourceToStageDB'
                              AND TableName = 'CUSTOMER_SOURCESYSTEM08_STG' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'CustomerSourceToStageDB'
                      AND TableName = 'CUSTOMER_SOURCESYSTEM08_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'CustomerSourceToStageDB' ,
                       'CUSTOMER_SOURCESYSTEM08_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE CUSTOMER_SOURCESYSTEM08_STG ';
            INSERT INTO RBL_STGDB.CUSTOMER_SOURCESYSTEM08_STG
              ( DateOfData, SourceSystem, UCIC_ID, CustomerID, CustomerName, Constitution, Gender, SegmentCode, PANNO, PrevQtrRV, CurrQtrRV, AssetClass, NPADate, DBT_LOS_Date, AlwaysNPA )
              ( SELECT Date_of_Data ,
                       Source_System ,
                       UCIC_ID ,
                       Customer_id ,
                       Customer_Name ,
                       Customer_Constitution ,
                       gender ,
                       Customer_Segment_Code ,
                       PAN_No ,
                       NULL PrevQtrRV  ,
                       NULL CurrQtrRV  ,
                       Asset_Class ,
                       NPA_Date ,
                       DBT_LOS_Date ,
                       Always_NPA 
                FROM DWH_STG.Customer_data_EIFS  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'CUSTOMER_SOURCESYSTEM08_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.Customer_data_EIFS  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.CUSTOMER_SOURCESYSTEM08_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'CUSTOMER_SOURCESYSTEM08_STG'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM08_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CUSTOMER_SOURCESYSTEM08_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'CUSTOMER_SOURCESYSTEM08_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------Coborrower Customer------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'CustomerSourceToStageDB'
                                   AND TableName = 'CoBorrowerData' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'CustomerSourceToStageDB'
                              AND TableName = 'CoBorrowerData' );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DELETE RBL_STGDB.Package_AUDIT

             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
                      AND DataBaseName = 'RBL_STGDB'
                      AND PackageName = 'CustomerSourceToStageDB'
                      AND TableName = 'CoBorrowerData';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'CustomerSourceToStageDB' ,
                       'CoBorrowerData' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE CoBorrowerData ';
            INSERT INTO RBL_STGDB.CoBorrowerData
              ( CustomerACID, CustomerID, UCIC, CustomerType, Cohort_No, DateOfData )
              ( SELECT CustomerACID ,
                       CustomerID ,
                       UCIC ,
                       CustomerType ,
                       Cohort_no ,
                       DateOfData 
                FROM DWH_STG.CoBorrowerData  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'CoBorrowerData' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.CoBorrowerData  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.CoBorrowerData  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'CoBorrowerData'
              AND A.EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  )) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET Timekey = pos_2,
                                         STG_COUNT = pos_3;
            ----------------------
            UPDATE RBL_STGDB.Package_AUDIT
               SET ExecutionEndTime = SYSDATE,
                   ExecutionStatus = 1
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CoBorrowerData';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'CustomerSourceToStageDB'
              AND TableName = 'CoBorrowerData';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'CoBorrowerData'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;

      END;
  END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
