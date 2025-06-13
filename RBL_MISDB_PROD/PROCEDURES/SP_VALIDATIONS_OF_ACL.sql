--------------------------------------------------------
--  DDL for Procedure SP_VALIDATIONS_OF_ACL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" CREATE PROC "dbo" . "SP_Validations_OF_ACL" AS BEGIN DROP TABLE IF  --SQLDEV: NOT RECOGNIZED
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;
   ---------------------------------------------Validations for Customer not availble in Customer template table ----------------------------------------
   v_Date VARCHAR2(200) := ( SELECT DISTINCT date_of_data 
     FROM dwh_DWH_STG.account_data_finacle  );
   v_PrvDate VARCHAR2(200) := ( SELECT DISTINCT utils.dateadd('DAY', -1, v_Date) 
     FROM DUAL  );

BEGIN

   IF tt_temp1_18  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_temp1_18;
   UTILS.IDENTITY_RESET('tt_temp1_18');

   INSERT INTO tt_temp1_18 SELECT * 
        FROM ( SELECT SourceSystem ,
                      CASE 
                           WHEN SourceCount = 0 THEN 'FALSE'
                      ELSE 'True'
                         END SourceStatus  
               FROM dwh_stg.dwhControlTable_1 
                WHERE  SourceSystem NOT LIKE '%EIFS%'
               UNION 

               --order by SourceStatus,SourceSystem  
               SELECT SourceSystem ,
                      CASE 
                           WHEN SourceCount = 0 THEN 'True'
                      ELSE 'FALSE'
                         END SourceStatus  
               FROM dwh_stg.dwhControlTable_1 
                WHERE  SourceSystem LIKE '%EIFS%' ) aa
        ORDER BY SourceStatus,
                 SourceSystem;
   --select * from tt_temp1_18
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM tt_temp1_18 
                WHERE  SourceStatus = 'FALSE' ) >= 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      utils.raiserror( 0, 'Date column mismatched' );

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'Success' ACL  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   --Declare @PrvDate date =(select distinct dateadd(Day,-1,date_of_data) from DWH_STG.dwh.account_data_finacle)
   --select @Date
   --select @PrvDate
   IF utils.object_id('TEMPDB..tt_TEMPInsert_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert_8 ';
   END IF;
   DELETE FROM tt_TEMPInsert_8;
   --------------------------------------------------- Finacle -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPFinacle_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPFinacle_8 ';
   END IF;
   DELETE FROM tt_TEMPFinacle_8;
   UTILS.IDENTITY_RESET('tt_TEMPFinacle_8');

   INSERT INTO tt_TEMPFinacle_8 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_finacle --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_finacle --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		 distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'Finacle' SourceSystem
   --from		  tt_TEMPFinacle_8 c 
   --left join     DWH_STG.dwh.account_data_finacle d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data_finacle E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.account_data_finacle_Backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --and           a.date_of_data=@PrvDate
   --left join     DWH_STG.dwh.customer_data_finacle_backup b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where         a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   --------------------------------------------------- Indus -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPIndus_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPIndus_6 ';
   END IF;
   DELETE FROM tt_TEMPIndus_6;
   UTILS.IDENTITY_RESET('tt_TEMPIndus_6');

   INSERT INTO tt_TEMPIndus_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		 distinct d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'Indus' SourceSystem
   --from		  tt_TEMPIndus_6 c 
   --left join     DWH_STG.dwh.accounts_data d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.accounts_data_Backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.customer_data_Backup b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where           a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   ----------------------------------------ECBF-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_ECBF_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_ECBF_8 ';
   END IF;
   DELETE FROM tt_TEMP_ECBF_8;
   UTILS.IDENTITY_RESET('tt_TEMP_ECBF_8');

   INSERT INTO tt_TEMP_ECBF_8 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data_ecbf --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_ecbf --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'ECBF' SourceSystem
   --from		  tt_TEMP_ECBF_8 c 
   --left join     DWH_STG.dwh.accounts_data_ecbf d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data_ecbf E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.accounts_data_ecbf_Backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.customer_data_ecbf_Backup b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where           a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   ----------------------------------------Mifin-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_Mifin_6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_Mifin_6 ';
   END IF;
   DELETE FROM tt_TEMP_Mifin_6;
   UTILS.IDENTITY_RESET('tt_TEMP_Mifin_6');

   INSERT INTO tt_TEMP_Mifin_6 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data_mifin --where date_of_data=@Date

             MINUS 
             SELECT CustomerID 
             FROM dwh_DWH_STG.customer_data_mifin --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.CustomerID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'Mifin' SourceSystem
   --from		  tt_TEMP_Mifin_6 c 
   --left join     DWH_STG.dwh.accounts_data_mifin d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data_mifin E with(Nolock)
   --on            c.Customer_ID=e.CustomerID
   --and           e.DateOfData=@Date
   --left join     DWH_STG.dwh.accounts_data_mifin_Backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.customer_data_mifin_Backup b with(Nolock)
   --on            a.Customer_ID=b.CustomerID
   --where           a.date_of_data=@PrvDate
   --and           b.DateOfData=@PrvDate
   ----------------------------------------FIS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_FIS_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_FIS_8 ';
   END IF;
   DELETE FROM tt_TEMP_FIS_8;
   UTILS.IDENTITY_RESET('tt_TEMP_FIS_8');

   INSERT INTO tt_TEMP_FIS_8 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_FIS --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_FIS --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'FIS' SourceSystem
   --from		  tt_TEMP_FIS_8 c 
   --left join     DWH_STG.dwh.account_data_FIS d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data_FIS E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.account_data_FIS_Backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.customer_data_FIS_Backup b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where           a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   ----------------------------------------Vision Plus-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_VP_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_VP_8 ';
   END IF;
   DELETE FROM tt_TEMP_VP_8;
   UTILS.IDENTITY_RESET('tt_TEMP_VP_8');

   INSERT INTO tt_TEMP_VP_8 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_visionplus --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_visionplus --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'Vision Plus' SourceSystem
   --from		  tt_TEMP_VP_8 c 
   --left join     DWH_STG.dwh.account_data_visionplus d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data_visionplus E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.account_data_visionplus_Backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.customer_data_visionplus_Backup b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where           a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   ----------------------------------------METAGRID-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_METAGRID_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_METAGRID_8 ';
   END IF;
   DELETE FROM tt_TEMP_METAGRID_8;
   UTILS.IDENTITY_RESET('tt_TEMP_METAGRID_8');

   INSERT INTO tt_TEMP_METAGRID_8 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_metagrid --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_metagrid --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select		distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'METAGRID' SourceSystem
   --from		  tt_TEMP_METAGRID_8 c 
   --left join     DWH_STG.dwh.account_data_metagrid d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.customer_data_metagrid E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.account_data_metagrid_backup a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.customer_data_metagrid_backup b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where           a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   ----------------------------------------EIFS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_EIFS_8') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_EIFS_8 ';
   END IF;
   DELETE FROM tt_TEMP_EIFS_8;
   UTILS.IDENTITY_RESET('tt_TEMP_EIFS_8');

   INSERT INTO tt_TEMP_EIFS_8 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.Account_data_EIFS --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.Customer_data_EIFS --where date_of_data=@Date
                    ) A );
   --insert into   tt_TEMPInsert_8([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   --select	distinct	  d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   --			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   --			  'EIFS' SourceSystem
   --from		  tt_TEMP_METAGRID_8 c 
   --left join     DWH_STG.dwh.Account_data_EIFS d with(Nolock)
   --on            c.Customer_ID=d.Customer_ID
   --and           d.date_of_data=@Date
   --left join     DWH_STG.dwh.Customer_data_EIFS E with(Nolock)
   --on            c.Customer_ID=e.Customer_ID
   --and           e.date_of_data=@Date
   --left join     DWH_STG.dwh.Account_data_EIFS_BACKUP a with(Nolock)
   --on            a.customer_id=c.Customer_ID
   --left join     DWH_STG.dwh.Customer_data_EIFS_BACKUP b with(Nolock)
   --on            a.Customer_ID=b.Customer_ID
   --where           a.date_of_data=@PrvDate
   --and           b.date_of_data=@PrvDate
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_temp1_18122  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_temp1122;
   UTILS.IDENTITY_RESET('tt_temp1122');

   INSERT INTO tt_temp1122 ( 
   	SELECT * 
   	  FROM ( SELECT * 
             FROM tt_TEMPFinacle_8 
             UNION 
             SELECT * 
             FROM tt_TEMPIndus_6 
             UNION 
             SELECT * 
             FROM tt_TEMP_ECBF_8 
             UNION 
             SELECT * 
             FROM tt_TEMP_Mifin_6 
             UNION 
             SELECT * 
             FROM tt_TEMP_FIS_8 
             UNION 
             SELECT * 
             FROM tt_TEMP_VP_8 
             UNION 
             SELECT * 
             FROM tt_TEMP_METAGRID_8 
             UNION 
             SELECT * 
             FROM tt_TEMP_EIFS_8  ) AA );
   -----------------------------------------------------------------------------------
   --select [PD - Cust ID],[PD - ACCOUNT ID],[PD - UCIC],[CD - Cust ID],[CD - ACCOUNT ID],[CD - UCIC],
   --SourceSystem AS [Source System] from tt_TEMPInsert_8
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM tt_temp1122  ) >= 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      utils.raiserror( 0, 'Customer ID is Missing' );

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'Success' ACL  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   ------------------------------------------------------------------------------------
   ---------------------------------------------Validations for Branch Code not available----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPInsert_8Branch') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsertBranch ';
   END IF;
   DELETE FROM tt_TEMPInsertBranch;
   --------------------------------------------------- Finacle -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPFinacle_81') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPFinacle1 ';
   END IF;
   DELETE FROM tt_TEMPFinacle1;
   UTILS.IDENTITY_RESET('tt_TEMPFinacle1');

   INSERT INTO tt_TEMPFinacle1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_finacle --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' ) 
           --where date_of_data=@Date
           A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Finacle' SourceSystem  
       FROM tt_TEMPFinacle1 c
              LEFT JOIN dwh_DWH_STG.account_data_finacle D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_finacle_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   --------------------------------------------------- Indus -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPIndus_61') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPIndus1 ';
   END IF;
   DELETE FROM tt_TEMPIndus1;
   UTILS.IDENTITY_RESET('tt_TEMPIndus1');

   INSERT INTO tt_TEMPIndus1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Indus' SourceSystem  
       FROM tt_TEMPIndus1 c
              LEFT JOIN dwh_DWH_STG.accounts_data D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------ECBF-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_ECBF_81') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_ECBF1 ';
   END IF;
   DELETE FROM tt_TEMP_ECBF1;
   UTILS.IDENTITY_RESET('tt_TEMP_ECBF1');

   INSERT INTO tt_TEMP_ECBF1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data_ecbf --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'ECBF' SourceSystem  
       FROM tt_TEMP_ECBF1 c
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------Mifin-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_Mifin_61') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_Mifin1 ';
   END IF;
   DELETE FROM tt_TEMP_Mifin1;
   UTILS.IDENTITY_RESET('tt_TEMP_Mifin1');

   INSERT INTO tt_TEMP_Mifin1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.accounts_data_mifin --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'Mifin' SourceSystem  
       FROM tt_TEMP_Mifin1 c
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_mifin_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------FIS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_FIS_81') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_FIS1 ';
   END IF;
   DELETE FROM tt_TEMP_FIS1;
   UTILS.IDENTITY_RESET('tt_TEMP_FIS1');

   INSERT INTO tt_TEMP_FIS1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_FIS --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'FIS' SourceSystem  
       FROM tt_TEMP_FIS1 c
              LEFT JOIN dwh_DWH_STG.account_data_FIS D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_FIS_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------Vision Plus-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_VP_81') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_VP1 ';
   END IF;
   DELETE FROM tt_TEMP_VP1;
   UTILS.IDENTITY_RESET('tt_TEMP_VP1');

   INSERT INTO tt_TEMP_VP1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT customer_ac_id 
             FROM dwh_DWH_STG.account_data_visionplus --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'VisionPlus' SourceSystem  
       FROM tt_TEMP_VP1 c
              LEFT JOIN dwh_DWH_STG.account_data_visionplus D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_visionplus_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------METAGRID-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_METAGRID_81') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_METAGRID1 ';
   END IF;
   DELETE FROM tt_TEMP_METAGRID1;
   UTILS.IDENTITY_RESET('tt_TEMP_METAGRID1');

   INSERT INTO tt_TEMP_METAGRID1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_Ac_ID 
             FROM dwh_DWH_STG.account_data_metagrid --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'METAGRID' SourceSystem  
       FROM tt_TEMP_METAGRID1 c
              LEFT JOIN dwh_DWH_STG.account_data_metagrid D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_metagrid_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   ----------------------------------------EIFS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_EIFS_81') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_EIFS1 ';
   END IF;
   DELETE FROM tt_TEMP_EIFS1;
   UTILS.IDENTITY_RESET('tt_TEMP_EIFS1');

   INSERT INTO tt_TEMP_EIFS1 ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_AC_ID 
             FROM dwh_DWH_STG.Account_data_EIFS --where date_of_data=@Date

              WHERE  branch_code IS NULL
                       OR branch_code = ' ' --where date_of_data=@Date
            ) A );
   INSERT INTO tt_TEMPInsertBranch
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_Branch_Code, PD_ACCOUNT_ID, PD_Cust_ID, PD_Branch_Code, SourceSystem )
     ( SELECT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
              D.Customer_ID CD_Cust_ID  ,
              D.branch_code CD_Branch_Code  ,
              A.Customer_Ac_ID PD_ACCOUNT_ID  ,
              A.Customer_ID PD_Cust_ID  ,
              A.branch_code PD_Branch_Code  ,
              'EIFS' SourceSystem  
       FROM tt_TEMP_EIFS1 c
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS D   ON c.Customer_Ac_ID = D.Customer_Ac_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS_Backup a   ON a.Customer_Ac_ID = c.Customer_Ac_ID
              AND a.date_of_data = v_PrvDate );
   -----------------------------------------------------------------------------------
   --select [PD - Cust ID],[PD - ACCOUNT ID],[PD - Branch Code],[CD - Cust ID],[CD - ACCOUNT ID],[CD - Branch Code],SourceSystem AS [Source System] from tt_TEMPInsert_8Branch
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE ( SELECT COUNT(*)  
               FROM tt_TEMPInsertBranch  ) >= 1;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      utils.raiserror( 0, 'Branch Code is Missing' );

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT 'Success' ACL  ------------------------------------------------------------------------------------
                --------------------------------------------------------------------------------------------------------------------------------------------
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_VALIDATIONS_OF_ACL" TO "ADF_CDR_RBL_STGDB";
