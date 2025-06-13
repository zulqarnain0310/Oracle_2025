--------------------------------------------------------
--  DDL for Procedure CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" 
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
   IF utils.object_id('TEMPDB..tt_TEMPInsert_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert_4 ';
   END IF;
   DELETE FROM tt_TEMPInsert_4;
   --------------------------------------------------- Finacle -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPFinacle_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPFinacle_4 ';
   END IF;
   DELETE FROM tt_TEMPFinacle_4;
   UTILS.IDENTITY_RESET('tt_TEMPFinacle_4');

   INSERT INTO tt_TEMPFinacle_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_finacle --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' ) 
           --where date_of_data=@Date
           A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Finacle' SourceSystem  
       FROM tt_TEMPFinacle_4 c
              LEFT JOIN dwh_DWH_STG.account_data_finacle D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_finacle_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   --------------------------------------------------- Indus -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPIndus_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPIndus_2 ';
   END IF;
   DELETE FROM tt_TEMPIndus_2;
   UTILS.IDENTITY_RESET('tt_TEMPIndus_2');

   INSERT INTO tt_TEMPIndus_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Indus' SourceSystem  
       FROM tt_TEMPIndus_2 c
              LEFT JOIN dwh_DWH_STG.accounts_data D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------ECBF-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_ECBF_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_ECBF_4 ';
   END IF;
   DELETE FROM tt_TEMP_ECBF_4;
   UTILS.IDENTITY_RESET('tt_TEMP_ECBF_4');

   INSERT INTO tt_TEMP_ECBF_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data_ecbf --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'ECBF' SourceSystem  
       FROM tt_TEMP_ECBF_4 c
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------Mifin-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_Mifin_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_Mifin_2 ';
   END IF;
   DELETE FROM tt_TEMP_Mifin_2;
   UTILS.IDENTITY_RESET('tt_TEMP_Mifin_2');

   INSERT INTO tt_TEMP_Mifin_2 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data_mifin --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Mifin' SourceSystem  
       FROM tt_TEMP_Mifin_2 c
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------FIS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_FIS_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_FIS_4 ';
   END IF;
   DELETE FROM tt_TEMP_FIS_4;
   UTILS.IDENTITY_RESET('tt_TEMP_FIS_4');

   INSERT INTO tt_TEMP_FIS_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_FIS --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'FIS' SourceSystem  
       FROM tt_TEMP_FIS_4 c
              LEFT JOIN dwh_DWH_STG.account_data_FIS D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_FIS_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------Vision Plus-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_VP_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_VP_4 ';
   END IF;
   DELETE FROM tt_TEMP_VP_4;
   UTILS.IDENTITY_RESET('tt_TEMP_VP_4');

   INSERT INTO tt_TEMP_VP_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT customer_ac_id 
             FROM dwh_DWH_STG.account_data_visionplus --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'VisionPlus' SourceSystem  
       FROM tt_TEMP_VP_4 c
              LEFT JOIN dwh_DWH_STG.account_data_visionplus D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_visionplus_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------METAGRID-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_METAGRID_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_METAGRID_4 ';
   END IF;
   DELETE FROM tt_TEMP_METAGRID_4;
   UTILS.IDENTITY_RESET('tt_TEMP_METAGRID_4');

   INSERT INTO tt_TEMP_METAGRID_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_metagrid --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'METAGRID' SourceSystem  
       FROM tt_TEMP_METAGRID_4 c
              LEFT JOIN dwh_DWH_STG.account_data_metagrid D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_metagrid_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------EIFS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_EIFS_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_EIFS_4 ';
   END IF;
   DELETE FROM tt_TEMP_EIFS_4;
   UTILS.IDENTITY_RESET('tt_TEMP_EIFS_4');

   INSERT INTO tt_TEMP_EIFS_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_AC_ID 
             FROM dwh_DWH_STG.Account_data_EIFS --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_4
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'EIFS' SourceSystem  
       FROM tt_TEMP_EIFS_4 c
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   -----------------------------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT PD_Cust_ID ,
             PD_ACCOUNT_ID ,
             PD_Branch_Code ,
             CD_Cust_ID ,
             CD_ACCOUNT_ID ,
             CD_Branch_Code ,
             SourceSystem Source_System  
        FROM tt_TEMPInsert_4  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);------------------------------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_04122023" TO "ADF_CDR_RBL_STGDB";
