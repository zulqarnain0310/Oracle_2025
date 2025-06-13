--------------------------------------------------------
--  DDL for Procedure UCIC_MISMATCH_CHECK_CONDITIONS_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" 
AS
   v_Date VARCHAR2(200) := ( SELECT DISTINCT date_of_data 
     FROM dwh_DWH_STG.account_data_finacle  );
   v_PrvDate VARCHAR2(200) := ( SELECT DISTINCT utils.dateadd('DAY', -1, v_Date) 
     FROM DUAL  );
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('TEMPDB..tt_TEMPInsert_10') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert_10 ';
   END IF;
   DELETE FROM tt_TEMPInsert_10;
   ----------------------------------------------------------------Finacle--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Finacle' SourceSystem  
       FROM dwh_DWH_STG.customer_data_finacle a
              JOIN dwh_DWH_STG.customer_data_finacle_backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------Indus--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Indus' SourceSystem  
       FROM dwh_DWH_STG.customer_data a
              JOIN dwh_DWH_STG.customer_data_backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------ECBF--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'ECBF' SourceSystem  
       FROM dwh_DWH_STG.customer_data_ecbf a
              JOIN dwh_DWH_STG.customer_data_ecbf_Backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------MiFin--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.CustomerID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.CustomerID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'MiFin' SourceSystem  
       FROM dwh_DWH_STG.customer_data_mifin a
              JOIN dwh_DWH_STG.customer_data_mifin_Backup b   ON a.CustomerID = b.CustomerID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.DateOfData = v_Date
               AND b.DateOfData = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------FIS--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'FIS' SourceSystem  
       FROM dwh_DWH_STG.customer_data_FIS a
              JOIN dwh_DWH_STG.customer_data_FIS_Backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------Vision Plus--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Vision Plus' SourceSystem  
       FROM dwh_DWH_STG.customer_data_visionplus a
              JOIN dwh_DWH_STG.customer_data_visionplus_Backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------Metagrid--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'Metagrid' SourceSystem  
       FROM dwh_DWH_STG.customer_data_metagrid a
              JOIN dwh_DWH_STG.customer_data_metagrid_backup b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------EIFS--------------------------------------------------------------------------
   INSERT INTO tt_TEMPInsert_10
     ( CD_Cust_ID, CD_UCIC, PD_Cust_ID, PD_UCIC_ID, SourceSystem )
     SELECT A.Customer_ID CD_Cust_ID  ,
            A.UCIC_ID CD_UCIC  ,
            b.Customer_ID PD_Cust_ID  ,
            b.UCIC_ID PD_UCIC_ID  ,
            'EIFS' SourceSystem  
       FROM dwh_DWH_STG.Customer_data_EIFS a
              JOIN dwh_DWH_STG.Customer_data_EIFS_BACKUP b   ON a.Customer_ID = b.Customer_ID
      WHERE  NVL(a.UCIC_ID, ' ') <> NVL(b.UCIC_ID, ' ')
               AND a.date_of_data = v_Date
               AND b.date_of_data = v_PrvDate
       ORDER BY 1;
   ----------------------------------------------------------------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT PD_UCIC_ID ,
             PD_Cust_ID ,
             CD_UCIC ,
             CD_Cust_ID ,
             SourceSystem Source_System  
        FROM tt_TEMPInsert_10  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);----------------------------------------------------------------------------------------------------------------------------
   --select distinct date_of_data from Update  DWH_STG.dwh.customer_data_finacle_backup set UCIC_ID='RBL022521431asd' where date_of_data='2023-01-20'
   --and Customer_ID='103100295'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UCIC_MISMATCH_CHECK_CONDITIONS_04122023" TO "ADF_CDR_RBL_STGDB";
