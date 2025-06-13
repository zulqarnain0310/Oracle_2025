--------------------------------------------------------
--  DDL for Procedure CONDITION_CHECK_MISMATCHES_16102024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" 
AS
   v_Date VARCHAR2(200) := ( SELECT DISTINCT date_of_data 
     FROM dwh_DWH_STG.account_data_finacle  );
   v_PrvDate VARCHAR2(200) := ( SELECT DISTINCT utils.dateadd('DAY', -1, v_Date) 
     FROM DUAL  );
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @PrvDate date =(select distinct dateadd(Day,-1,date_of_data) from DWH_STG.dwh.account_data_finacle)
   --select @Date
   --select @PrvDate
   IF utils.object_id('TEMPDB..tt_TEMPInsert_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert_2 ';
   END IF;
   DELETE FROM tt_TEMPInsert_2;
   --------------------------------------------------- Finacle -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPFinacle_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPFinacle_2 ';
   END IF;
   DELETE FROM tt_TEMPFinacle_2;
   UTILS.IDENTITY_RESET('tt_TEMPFinacle_2');

   INSERT INTO tt_TEMPFinacle_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_finacle --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_finacle --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'Finacle' SourceSystem  
       FROM tt_TEMPFinacle_2 c
              LEFT JOIN dwh_DWH_STG.account_data_finacle D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_finacle E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_finacle_Backup a   ON a.customer_id = c.Customer_ID
              AND a.date_of_data = v_PrvDate
              LEFT JOIN dwh_DWH_STG.customer_data_finacle_backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   --------------------------------------------------- Indus -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPIndus') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPIndus ';
   END IF;
   DELETE FROM tt_TEMPIndus;
   UTILS.IDENTITY_RESET('tt_TEMPIndus');

   INSERT INTO tt_TEMPIndus ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'Indus' SourceSystem  
       FROM tt_TEMPIndus c
              LEFT JOIN dwh_DWH_STG.accounts_data D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------ECBF-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_ECBF_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_ECBF_2 ';
   END IF;
   DELETE FROM tt_TEMP_ECBF_2;
   UTILS.IDENTITY_RESET('tt_TEMP_ECBF_2');

   INSERT INTO tt_TEMP_ECBF_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data_ecbf --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_ecbf --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'ECBF' SourceSystem  
       FROM tt_TEMP_ECBF_2 c
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_ecbf E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_ecbf_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------Mifin-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_Mifin') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_Mifin ';
   END IF;
   DELETE FROM tt_TEMP_Mifin;
   UTILS.IDENTITY_RESET('tt_TEMP_Mifin');

   INSERT INTO tt_TEMP_Mifin ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data_mifin --where date_of_data=@Date

             MINUS 
             SELECT CustomerID 
             FROM dwh_DWH_STG.customer_data_mifin --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.CustomerID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'Mifin' SourceSystem  
       FROM tt_TEMP_Mifin c
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_mifin E   ON c.Customer_ID = e.CustomerID
              AND e.DateOfData = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_mifin_Backup b   ON a.Customer_ID = b.CustomerID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.DateOfData = v_PrvDate );
   ----------------------------------------FIS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_FIS_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_FIS_2 ';
   END IF;
   DELETE FROM tt_TEMP_FIS_2;
   UTILS.IDENTITY_RESET('tt_TEMP_FIS_2');

   INSERT INTO tt_TEMP_FIS_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_FIS --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_FIS --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'FIS' SourceSystem  
       FROM tt_TEMP_FIS_2 c
              LEFT JOIN dwh_DWH_STG.account_data_FIS D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_FIS E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_FIS_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_FIS_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------Vision Plus-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_VP_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_VP_2 ';
   END IF;
   DELETE FROM tt_TEMP_VP_2;
   UTILS.IDENTITY_RESET('tt_TEMP_VP_2');

   INSERT INTO tt_TEMP_VP_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_visionplus --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_visionplus --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'Vision Plus' SourceSystem  
       FROM tt_TEMP_VP_2 c
              LEFT JOIN dwh_DWH_STG.account_data_visionplus D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_visionplus E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_visionplus_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_visionplus_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------METAGRID-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_METAGRID_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_METAGRID_2 ';
   END IF;
   DELETE FROM tt_TEMP_METAGRID_2;
   UTILS.IDENTITY_RESET('tt_TEMP_METAGRID_2');

   INSERT INTO tt_TEMP_METAGRID_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_metagrid --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_metagrid --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'METAGRID' SourceSystem  
       FROM tt_TEMP_METAGRID_2 c
              LEFT JOIN dwh_DWH_STG.account_data_metagrid D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_metagrid E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_metagrid_backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_metagrid_backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------EIFS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_EIFS_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_EIFS_2 ';
   END IF;
   DELETE FROM tt_TEMP_EIFS_2;
   UTILS.IDENTITY_RESET('tt_TEMP_EIFS_2');

   INSERT INTO tt_TEMP_EIFS_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.Account_data_EIFS --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.Customer_data_EIFS --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert_2
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'EIFS' SourceSystem  
       FROM tt_TEMP_METAGRID_2 c
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.Customer_data_EIFS E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS_BACKUP a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.Customer_data_EIFS_BACKUP b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   -----------------------------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT PD_Cust_ID ,
             PD_ACCOUNT_ID ,
             PD_UCIC ,
             CD_Cust_ID ,
             CD_ACCOUNT_ID ,
             CD_UCIC ,
             SourceSystem Source_System  
        FROM tt_TEMPInsert_2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);------------------------------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_16102024" TO "ADF_CDR_RBL_STGDB";
