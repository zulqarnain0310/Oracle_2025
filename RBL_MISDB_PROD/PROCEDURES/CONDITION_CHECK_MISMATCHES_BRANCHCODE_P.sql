--------------------------------------------------------
--  DDL for Procedure CONDITION_CHECK_MISMATCHES_BRANCHCODE_P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" 
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
   IF utils.object_id('TEMPDB..tt_TEMPInsert_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert_6 ';
   END IF;
   DELETE FROM tt_TEMPInsert_6;
   --------------------------------------------------- Finacle -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPFinacle_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPFinacle_6 ';
   END IF;
   DELETE FROM tt_TEMPFinacle_6;
   UTILS.IDENTITY_RESET('tt_TEMPFinacle_6');

   INSERT INTO tt_TEMPFinacle_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_finacle --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' ) 
           --where date_of_data=@Date
           A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Finacle' SourceSystem  ,
              1 SourceTableAlt_Key  
       FROM tt_TEMPFinacle_6 c
              LEFT JOIN dwh_DWH_STG.account_data_finacle D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_finacle_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   --------------------------------------------------- Indus -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPIndus_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPIndus_4 ';
   END IF;
   DELETE FROM tt_TEMPIndus_4;
   UTILS.IDENTITY_RESET('tt_TEMPIndus_4');

   INSERT INTO tt_TEMPIndus_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Indus' SourceSystem  ,
              2 SourceTableAlt_Key  
       FROM tt_TEMPIndus_4 c
              LEFT JOIN dwh_DWH_STG.accounts_data D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------ECBF-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_ECBF_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_ECBF_6 ';
   END IF;
   DELETE FROM tt_TEMP_ECBF_6;
   UTILS.IDENTITY_RESET('tt_TEMP_ECBF_6');

   INSERT INTO tt_TEMP_ECBF_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data_ecbf --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'ECBF' SourceSystem  ,
              3 SourceTableAlt_Key  
       FROM tt_TEMP_ECBF_6 c
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------Mifin-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_Mifin_4') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_Mifin_4 ';
   END IF;
   DELETE FROM tt_TEMP_Mifin_4;
   UTILS.IDENTITY_RESET('tt_TEMP_Mifin_4');

   INSERT INTO tt_TEMP_Mifin_4 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data_mifin --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Mifin' SourceSystem  ,
              4 SourceTableAlt_Key  
       FROM tt_TEMP_Mifin_4 c
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------FIS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_FIS_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_FIS_6 ';
   END IF;
   DELETE FROM tt_TEMP_FIS_6;
   UTILS.IDENTITY_RESET('tt_TEMP_FIS_6');

   INSERT INTO tt_TEMP_FIS_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_FIS --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'FIS' SourceSystem  ,
              5 SourceTableAlt_Key  
       FROM tt_TEMP_FIS_6 c
              LEFT JOIN dwh_DWH_STG.account_data_FIS D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_FIS_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------Vision Plus-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_VP_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_VP_6 ';
   END IF;
   DELETE FROM tt_TEMP_VP_6;
   UTILS.IDENTITY_RESET('tt_TEMP_VP_6');

   INSERT INTO tt_TEMP_VP_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT customer_ac_id 
             FROM dwh_DWH_STG.account_data_visionplus --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'VisionPlus' SourceSystem  ,
              6 SourceTableAlt_Key  
       FROM tt_TEMP_VP_6 c
              LEFT JOIN dwh_DWH_STG.account_data_visionplus D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_visionplus_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------METAGRID-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_METAGRID_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_METAGRID_6 ';
   END IF;
   DELETE FROM tt_TEMP_METAGRID_6;
   UTILS.IDENTITY_RESET('tt_TEMP_METAGRID_6');

   INSERT INTO tt_TEMP_METAGRID_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_metagrid --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'METAGRID' SourceSystem  ,
              8 SourceTableAlt_Key  
       FROM tt_TEMP_METAGRID_6 c
              LEFT JOIN dwh_DWH_STG.account_data_metagrid D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_metagrid_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------EIFS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_EIFS_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_EIFS_6 ';
   END IF;
   DELETE FROM tt_TEMP_EIFS_6;
   UTILS.IDENTITY_RESET('tt_TEMP_EIFS_6');

   INSERT INTO tt_TEMP_EIFS_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_AC_ID 
             FROM dwh_DWH_STG.Account_data_EIFS --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsert_6
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem, SourceTableAlt_Key )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'EIFS' SourceSystem  ,
              11 SourceTableAlt_Key  
       FROM tt_TEMP_EIFS_6 c
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
        FROM tt_TEMPInsert_6 a
               JOIN RBL_MISDB_PROD.DIMSOURCEDB b   ON a.SourceTableAlt_Key = b.SourceAlt_Key
               AND b.EffectiveToTimeKey = 49999
       WHERE  b.Active_Inactive = 'Y'
                AND v_Date BETWEEN b.StartDate AND b.EndDate ;
      DBMS_SQL.RETURN_RESULT(v_cursor);------------------------------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES_BRANCHCODE_P" TO "ADF_CDR_RBL_STGDB";
