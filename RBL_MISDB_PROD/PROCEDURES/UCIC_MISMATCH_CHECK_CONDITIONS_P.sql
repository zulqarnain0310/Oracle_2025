--------------------------------------------------------
--  DDL for Procedure UCIC_MISMATCH_CHECK_CONDITIONS_P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" 
AS
   v_Date VARCHAR2(200) := ( SELECT DISTINCT date_of_data 
     FROM dwh_DWH_STG.account_data_finacle  );
   v_PrvDate VARCHAR2(200) := ( SELECT DISTINCT utils.dateadd('DAY', -1, v_Date) 
     FROM DUAL  );
   ----------------------------------------------------------------------------------------------------------------------
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('TEMPDB..tt_TEMPInsert_12') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert_12 ';
   END IF;
   DELETE FROM tt_TEMPInsert_12;
   ----------------------------------------------------------------Finacle--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Finacle' SourceSystem  ,
            1 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_finacle a
              JOIN dwh_DWH_STG.customer_data_finacle_backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------Indus--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Indus' SourceSystem  ,
            2 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data a
              JOIN dwh_DWH_STG.customer_data_backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------ECBF--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'ECBF' SourceSystem  ,
            3 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_ecbf a
              JOIN dwh_DWH_STG.customer_data_ecbf_Backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------MiFin--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.CustomerID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.CustomerID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'MiFin' SourceSystem  ,
            4 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_mifin a
              JOIN dwh_DWH_STG.customer_data_mifin_Backup b   ON a.CustomerID = b.CustomerID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.DateOfData = v_Date
               AND b.DateOfData = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------FIS--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'FIS' SourceSystem  ,
            5 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_FIS a
              JOIN dwh_DWH_STG.customer_data_FIS_Backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------Vision Plus--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Vision Plus' SourceSystem  ,
            6 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_visionplus a
              JOIN dwh_DWH_STG.customer_data_visionplus_Backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------Metagrid--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Metagrid' SourceSystem  ,
            8 SourceTableAlt_Key  
       FROM dwh_DWH_STG.customer_data_metagrid a
              JOIN dwh_DWH_STG.customer_data_metagrid_backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------EIFS--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_12
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem, SourceTableAlt_Key )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'EIFS' SourceSystem  ,
            11 SourceTableAlt_Key  
       FROM dwh_DWH_STG.Customer_data_EIFS a
              JOIN dwh_DWH_STG.Customer_data_EIFS_BACKUP b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   OPEN  v_cursor FOR
      SELECT PD_UCIC_ID ,
             PD_Cust_ID ,
             CD_UCIC ,
             CD_Cust_ID ,
             SourceSystem Source_System  
        FROM tt_TEMPInsert_12 a
               JOIN RBL_MISDB_PROD.DIMSOURCEDB b   ON a.SourceTableAlt_Key = b.SourceAlt_Key
               AND b.EffectiveToTimeKey = 49999
       WHERE  b.Active_Inactive = 'Y'
                AND v_Date BETWEEN b.StartDate AND b.EndDate ;
      DBMS_SQL.RETURN_RESULT(v_cursor);----------------------------------------------------------------------------------------------------------------------------
   --select distinct date_of_data from Update  DWH_STG.dwh.customer_data_finacle_backup set UCIC_ID='RBL022521431asd' where date_of_data='2023-01-20'
   --and Customer_ID='103100295'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_P" TO "ADF_CDR_RBL_STGDB";
