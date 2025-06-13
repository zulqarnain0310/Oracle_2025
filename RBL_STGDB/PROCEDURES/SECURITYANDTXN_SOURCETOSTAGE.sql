--------------------------------------------------------
--  DDL for Procedure SECURITYANDTXN_SOURCETOSTAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_STGDB"."SECURITYANDTXN_SOURCETOSTAGE" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN
   BEGIN
      DECLARE
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         --------------------------------------FINACLE SECURITY------------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'SecurityandTxnSourceToStage'
                                   AND TableName = 'SECURITY_SOURCESYSTEM01_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'SecurityandTxnSourceToStage'
                              AND TableName = 'SECURITY_SOURCESYSTEM01_STG' );
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
                      AND PackageName = 'SecurityandTxnSourceToStage'
                      AND TableName = 'SECURITY_SOURCESYSTEM01_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'SecurityandTxnSourceToStage' ,
                       'SECURITY_SOURCESYSTEM01_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE SECURITY_SOURCESYSTEM01_STG ';
            INSERT INTO RBL_STGDB.SECURITY_SOURCESYSTEM01_STG
              ( DateofData, SourceSystem, AccountID, CollateralID, SecurityCode, SecurityValue, Valuationdate, SecurityChargeStatus, ValuationExpiryDate, Stock_Audit_Date, Customer_ID, Collateral_Type, Valuation_Source, apportioned_value, Sec_Perf_Flg
              --, Type_Of_Currency 
              )
              ( SELECT Date_of_Data ,
                       Source_System_Name ,
                       Account_ID ,
                       Security_ID CollateralID  ,
                       Security_Code ,
                       Security_Value ,
                       Valuation_date ,
                       Charge_Type_Code SecurityChargeStatus  ,
                       Valuation_expiry_date ,
                       Stock_Audit_Date ,
                       Customer_ID ,
                       Collateral_Type ,
                       Valuation_Source ,
                       apportioned_value ,
                       Sec_Perf_Flg 
                       --,Security_Currency_code Type_Of_Currency  
                FROM DWH_STG.collateral_type_master_finacle  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'SECURITY_SOURCESYSTEM01_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.collateral_type_master_finacle  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.SECURITY_SOURCESYSTEM01_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'SECURITY_SOURCESYSTEM01_STG'
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
              AND PackageName = 'SecurityandTxnSourceToStage'
              AND TableName = 'SECURITY_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'SecurityandTxnSourceToStage'
              AND TableName = 'SECURITY_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'SECURITY_SOURCESYSTEM01_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------MIFIN SECURITY------------------------------------------------------------------------------------
         /*
         if 0=(Select COUNT(1)
                  From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                  And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         		 And TableName='SECURITY_SOURCESYSTEM04_STG')
         		 OR
                  0=(Select ISNULL(ExecutionStatus,0)ExecutionStatus
                  From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                  And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         		 And TableName='SECURITY_SOURCESYSTEM04_STG')

         BEGIN

         			Delete From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' And TableName='SECURITY_SOURCESYSTEM04_STG'

                     Insert into RBL_STGDB..Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
                     Select GETDATE(),'RBL_STGDB','SecurityandTxnSourceToStage','SECURITY_SOURCESYSTEM04_STG',GETDATE(),0

         			Truncate Table SECURITY_SOURCESYSTEM04_STG

         			insert into RBL_STGDB.dbo.SECURITY_SOURCESYSTEM04_STG
         (
         DateofData
         ,SourceSystem
         ,AccountID
         ,CustomerID
         ,CaratValue
         ,GoldWeightNetGms
         ,CollateralID
         )

         select 
         DateofData
         ,SourceSystem
         ,AccountID
         ,CustomerID
         ,CaratValue
         ,GoldWeightNetGms
         ,CollateralID
         from DWH_STG.dwh.SECURITY_SOURCESYSTEM04

         			insert into RBL_STGDB.dbo.table_audit (EXT_DATE,TableName,SRC_COUNT)
         			select   CONVERT(DATE,GETDATE()) as Ext_Date,'SECURITY_SOURCESYSTEM04_STG' as TableName,Count(1) as SRC_Count
                     from     DWH_STG.[DWH].SECURITY_SOURCESYSTEM04

         			UPDATE RBL_STGDB.dbo.TABLE_AUDIT  SET Timekey=(select Timekey from RBL_MISDB_PROD.DBO.SysDataMatrix  where CurrentStatus='C'),
         									STG_COUNT = (SELECT COUNT (1) FROM RBL_STGDB.dbo.SECURITY_SOURCESYSTEM04_STG)
                     FROM   RBL_STGDB.dbo.TABLE_AUDIT WHERE [TABLENAME] ='SECURITY_SOURCESYSTEM04_STG' 
                     AND    EXT_DATE =(SELECT CONVERT(DATE,GETDATE()))

         			Update    RBL_STGDB..Package_AUDIT    
         			Set       ExecutionEndTime=GETDATE(),ExecutionStatus=1
                     WHERE     CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And       DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         			And       TableName='SECURITY_SOURCESYSTEM04_STG'

                     Update    RBL_STGDB..Package_AUDIT 
         			Set       TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
                     WHERE     CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And       DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         			And       TableName='SECURITY_SOURCESYSTEM04_STG'

         			Update    RBL_STGDB..TABLE_AUDIT 
         			set       Audit_Flg= case when SRC_COUNT=STG_COUNT then 0 else 1 end where TableName='SECURITY_SOURCESYSTEM04_STG'
                     AND       EXT_DATE =(SELECT CONVERT(DATE,GETDATE()))


                     update    RBL_MISDB_PROD.dbo.BANDAUDITSTATUS 
         			set       CompletedCount=CompletedCount+1 
         			where     BandName='SourceToStage'


         END
         */
         --------------------------------------FINACLE TRANSACTION------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'SecurityandTxnSourceToStage'
                                   AND TableName = 'TXN_SOURCESYSTEM01_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'SecurityandTxnSourceToStage'
                              AND TableName = 'TXN_SOURCESYSTEM01_STG' );
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
                      AND PackageName = 'SecurityandTxnSourceToStage'
                      AND TableName = 'TXN_SOURCESYSTEM01_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'SecurityandTxnSourceToStage' ,
                       'TXN_SOURCESYSTEM01_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE TXN_SOURCESYSTEM01_STG ';
            INSERT INTO RBL_STGDB.TXN_SOURCESYSTEM01_STG
              ( DateofData, SourceSystem, AccountID, TxnDate, TxnID, TxnType, TxnSubType, TxnCurrency, TxnAmountinCurrency, TxnAmountINR, TxnParticulars )
              ( SELECT date_of_data ,
                       source_System ,
                       Account_ID ,
                       tran_date ,
                       Txn_ID ,
                       Txn_Type ,
                       Txn_Sub_Type ,
                       Txn_Currency ,
                       Txn_Amount_in_Currency ,
                       Txn_Amount_INR ,
                       Txn_Particulars 
                FROM DWH_STG.transaction_data_finacle  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'TXN_SOURCESYSTEM01_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.transaction_data_finacle  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.TXN_SOURCESYSTEM01_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'TXN_SOURCESYSTEM01_STG'
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
              AND PackageName = 'SecurityandTxnSourceToStage'
              AND TableName = 'TXN_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'SecurityandTxnSourceToStage'
              AND TableName = 'TXN_SOURCESYSTEM01_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'TXN_SOURCESYSTEM01_STG'
              AND EXT_DATE = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                 FROM DUAL  );
            UPDATE RBL_MISDB_PROD.BANDAUDITSTATUS
               SET CompletedCount = CompletedCount + 1
             WHERE  BandName = 'SourceToStage';

         END;
         END IF;
         --------------------------------------MIFIN GOLDMASTER------------------------------------------------------------------------------
         /*
         if 0=(Select COUNT(1)
                  From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                  And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         		 And TableName='MIFINGOLDMASTER_STG')
         		 OR
                  0=(Select ISNULL(ExecutionStatus,0)ExecutionStatus
                  From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                  And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         		 And TableName='MIFINGOLDMASTER_STG')

         BEGIN
         			Delete From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' And TableName='MIFINGOLDMASTER_STG'

                     Insert into RBL_STGDB..Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
                     Select GETDATE(),'RBL_STGDB','SecurityandTxnSourceToStage','MIFINGOLDMASTER_STG',GETDATE(),0


         			Truncate Table MIFINGOLDMASTER_STG

         			--CALL SP



         			insert into RBL_STGDB.dbo.table_audit (EXT_DATE,TableName,SRC_COUNT)
         			select   CONVERT(DATE,GETDATE()) as Ext_Date,'MIFINGOLDMASTER_STG' as TableName,Count(1) as SRC_Count
                     from     DWH_STG.DWH.MIFINGOLDMASTER


         			UPDATE RBL_STGDB.dbo.TABLE_AUDIT  SET Timekey=(select Timekey from RBL_MISDB_PROD.DBO.SysDataMatrix  where CurrentStatus='C'),
         									STG_COUNT = (SELECT COUNT (1) FROM RBL_STGDB.dbo.MIFINGOLDMASTER_STG)
                     FROM   RBL_STGDB.dbo.TABLE_AUDIT WHERE [TABLENAME] ='MIFINGOLDMASTER_STG' 
                     AND    EXT_DATE =(SELECT CONVERT(DATE,GETDATE()))

         			----------------------


         			Update    RBL_STGDB..Package_AUDIT    
         			Set       ExecutionEndTime=GETDATE(),ExecutionStatus=1
                     WHERE     CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And       DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         			And       TableName='MIFINGOLDMASTER_STG'

                     Update    RBL_STGDB..Package_AUDIT 
         			Set       TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
                     WHERE     CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And       DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         			And       TableName='MIFINGOLDMASTER_STG'


         			Update    RBL_STGDB..TABLE_AUDIT 
         			set       Audit_Flg= case when SRC_COUNT=STG_COUNT then 0 else 1 end where TableName='MIFINGOLDMASTER_STG'
                     AND       EXT_DATE =(SELECT CONVERT(DATE,GETDATE()))


                     update    RBL_MISDB_PROD.dbo.BANDAUDITSTATUS 
         			set       CompletedCount=CompletedCount+1 
         			where     BandName='SourceToStage'


         END
         */
         --------------------------------------INDUS SECURITY------------------------------------------------------------------------------
         /*
         if 0=(Select COUNT(1)
                  From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                  And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         		 And TableName='SECURITY_SOURCESYSTEM02_STG')
         		 OR
                  0=(Select ISNULL(ExecutionStatus,0)ExecutionStatus
                  From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                  And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         		 And TableName='SECURITY_SOURCESYSTEM02_STG')

         BEGIN
         			Delete From RBL_STGDB..Package_AUDIT WHERE CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' And TableName='SECURITY_SOURCESYSTEM02_STG'

                     Insert into RBL_STGDB..Package_AUDIT(Execution_date,DataBaseName,PackageName,TableName,ExecutionStartTime,ExecutionStatus)
                     Select GETDATE(),'RBL_STGDB','SecurityandTxnSourceToStage','SECURITY_SOURCESYSTEM02_STG',GETDATE(),0


         			Truncate Table SECURITY_SOURCESYSTEM02_STG

         			--CALL SP



         			insert into RBL_STGDB.dbo.table_audit (EXT_DATE,TableName,SRC_COUNT)
         			select   CONVERT(DATE,GETDATE()) as Ext_Date,'SECURITY_SOURCESYSTEM02_STG' as TableName,Count(1) as SRC_Count
                     from     DWH_STG.DWH.SECURITY_SOURCESYSTEM02


         			UPDATE RBL_STGDB.dbo.TABLE_AUDIT  SET Timekey=(select Timekey from RBL_MISDB_PROD.DBO.SysDataMatrix  where CurrentStatus='C'),
         									STG_COUNT = (SELECT COUNT (1) FROM RBL_STGDB.dbo.SECURITY_SOURCESYSTEM02_STG)
                     FROM   RBL_STGDB.dbo.TABLE_AUDIT WHERE [TABLENAME] ='SECURITY_SOURCESYSTEM02_STG' 
                     AND    EXT_DATE =(SELECT CONVERT(DATE,GETDATE()))

         			----------------------


         			Update    RBL_STGDB..Package_AUDIT    
         			Set       ExecutionEndTime=GETDATE(),ExecutionStatus=1
                     WHERE     CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And       DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         			And       TableName='SECURITY_SOURCESYSTEM02_STG'

                     Update    RBL_STGDB..Package_AUDIT 
         			Set       TimeDuration_Sec=DateDiff(ss,ExecutionStartTime,ExecutionEndTime)
                     WHERE     CONVERT(DATE, ExecutionStartTime) =(SELECT CONVERT (DATE,GETDATE()))
                     And       DataBaseName='RBL_STGDB' And PackageName='SecurityandTxnSourceToStage' 
         			And       TableName='SECURITY_SOURCESYSTEM02_STG'


         			Update    RBL_STGDB..TABLE_AUDIT 
         			set       Audit_Flg= case when SRC_COUNT=STG_COUNT then 0 else 1 end where TableName='SECURITY_SOURCESYSTEM02_STG'
                     AND       EXT_DATE =(SELECT CONVERT(DATE,GETDATE()))


                     update    RBL_MISDB_PROD.dbo.BANDAUDITSTATUS 
         			set       CompletedCount=CompletedCount+1 
         			where     BandName='SourceToStage'


         END
         */
         --------------------------------------ECBF SECURITY------------------------------------------------------------------------------
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE 0 = ( SELECT COUNT(1)  
                         FROM RBL_STGDB.Package_AUDIT 
                          WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                                 FROM DUAL  )
                                   AND DataBaseName = 'RBL_STGDB'
                                   AND PackageName = 'SecurityandTxnSourceToStage'
                                   AND TableName = 'SECURITY_SOURCESYSTEM03_STG' )
           OR 0 = ( SELECT NVL(ExecutionStatus, 0) ExecutionStatus  
                    FROM RBL_STGDB.Package_AUDIT 
                     WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                            FROM DUAL  )
                              AND DataBaseName = 'RBL_STGDB'
                              AND PackageName = 'SecurityandTxnSourceToStage'
                              AND TableName = 'SECURITY_SOURCESYSTEM03_STG' );
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
                      AND PackageName = 'SecurityandTxnSourceToStage'
                      AND TableName = 'SECURITY_SOURCESYSTEM03_STG';
            INSERT INTO RBL_STGDB.Package_AUDIT
              ( Execution_date, DataBaseName, PackageName, TableName, ExecutionStartTime, ExecutionStatus )
              ( SELECT SYSDATE ,
                       'RBL_STGDB' ,
                       'SecurityandTxnSourceToStage' ,
                       'SECURITY_SOURCESYSTEM03_STG' ,
                       SYSDATE ,
                       0 
                  FROM DUAL  );
            EXECUTE IMMEDIATE ' TRUNCATE TABLE SECURITY_SOURCESYSTEM03_STG ';
            INSERT INTO RBL_STGDB.SECURITY_SOURCESYSTEM03_STG
              ( DateofData, SourceSystem, AccountID, CollateralID, SecurityCode, SecurityValue, Valuationdate, SecurityChargeStatus, ValuationExpiryDate, Customer_ID, Security_ID, Charge_Type_Code, Valuation_Source, Collateral_Type )
              ( SELECT Date_of_Data ,
                       Source_System_Name ,
                       Account_ID ,
                       NULL CollateralID  ,
                       Security_Code ,
                       Security_Value ,
                       Valuation_date ,
                       NULL SecurityChargeStatus  ,
                       Valuation_expiry_date ,
                       Customer_ID ,
                       Security_ID ,
                       Charge_Type_Code ,
                       Valuation_Source ,
                       Collateral_Type 
                FROM DWH_STG.security_data_ecbf  );
            INSERT INTO RBL_STGDB.table_audit
              ( EXT_DATE, TableName, SRC_COUNT )
              ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) Ext_Date  ,
                       'SECURITY_SOURCESYSTEM03_STG' TableName  ,
                       COUNT(1)  SRC_Count  
                FROM DWH_STG.security_data_ecbf  );
            MERGE INTO RBL_STGDB.TABLE_AUDIT A
            USING (SELECT A.ROWID row_id, ( SELECT SYSDATAMATRIX.Timekey 
              FROM RBL_MISDB_PROD.SysDataMatrix 
             WHERE  SYSDATAMATRIX.CurrentStatus = 'C' ) AS pos_2, ( SELECT COUNT(1)  
              FROM RBL_STGDB.SECURITY_SOURCESYSTEM03_STG  ) AS pos_3
            FROM RBL_STGDB.TABLE_AUDIT A,RBL_STGDB.TABLE_AUDIT  B
             WHERE A.TABLENAME = 'SECURITY_SOURCESYSTEM03_STG'
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
              AND PackageName = 'SecurityandTxnSourceToStage'
              AND TableName = 'SECURITY_SOURCESYSTEM03_STG';
            UPDATE RBL_STGDB.Package_AUDIT
               SET TimeDuration_Sec = utils.datediff('SS', ExecutionStartTime, ExecutionEndTime)
             WHERE  UTILS.CONVERT_TO_DATE(ExecutionStartTime) = ( SELECT UTILS.CONVERT_TO_DATE(SYSDATE) 
                                                                    FROM DUAL  )
              AND DataBaseName = 'RBL_STGDB'
              AND PackageName = 'SecurityandTxnSourceToStage'
              AND TableName = 'SECURITY_SOURCESYSTEM03_STG';
            UPDATE RBL_STGDB.TABLE_AUDIT
               SET Audit_Flg = CASE 
                                    WHEN SRC_COUNT = STG_COUNT THEN 0
                   ELSE 1
                      END
             WHERE  TableName = 'SECURITY_SOURCESYSTEM03_STG'
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
