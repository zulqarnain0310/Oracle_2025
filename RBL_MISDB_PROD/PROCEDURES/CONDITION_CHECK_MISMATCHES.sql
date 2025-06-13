--------------------------------------------------------
--  DDL for Procedure CONDITION_CHECK_MISMATCHES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" 
AS
   v_Date VARCHAR2(200) := ( SELECT DISTINCT date_of_data 
     FROM dwh_DWH_STG.account_data_finacle  );
   v_PrvDate VARCHAR2(200) := ( SELECT DISTINCT utils.dateadd('DAY', -1, v_Date) 
     FROM DUAL  );
   -----------------------------------------------------------------------------------
   v_cursor SYS_REFCURSOR;

BEGIN

   --Declare @PrvDate date =(select distinct dateadd(Day,-1,date_of_data) from DWH_STG.dwh.account_data_finacle)
   --select @Date
   --select @PrvDate
   IF utils.object_id('TEMPDB..tt_TEMPInsert') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPInsert ';
   END IF;
   DELETE FROM tt_TEMPInsert;
   --------------------------------------------------- Finacle -----------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMPFinacle') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPFinacle ';
   END IF;
   DELETE FROM tt_TEMPFinacle;
   UTILS.IDENTITY_RESET('tt_TEMPFinacle');

   INSERT INTO tt_TEMPFinacle ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_finacle --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_finacle --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'Finacle' SourceSystem  
       FROM tt_TEMPFinacle c
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
   /*
   IF OBJECT_ID('TEMPDB..#TEMPIndus') IS NOT NULL 
   DROP TABLE #TEMPIndus

   select distinct * into #TEMPIndus from (
   select Customer_ID from DWH_STG.dwh.accounts_data with(Nolock)--where date_of_data=@Date
   except
   select Customer_ID from DWH_STG.dwh.customer_data with(Nolock) --where date_of_data=@Date
   )A

   insert into   tt_TEMPInsert([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   select		 distinct d.Customer_Ac_ID [CD - ACCOUNT ID],E.Customer_ID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   			  'Indus' SourceSystem
   from		  #TEMPIndus c 
   left join     DWH_STG.dwh.accounts_data d with(Nolock)
   on            c.Customer_ID=d.Customer_ID
   and           d.date_of_data=@Date
   left join     DWH_STG.dwh.customer_data E with(Nolock)
   on            c.Customer_ID=e.Customer_ID
   and           e.date_of_data=@Date
   left join     DWH_STG.dwh.accounts_data_Backup a with(Nolock)
   on            a.customer_id=c.Customer_ID

   left join     DWH_STG.dwh.customer_data_Backup b with(Nolock)
   on            a.Customer_ID=b.Customer_ID
   where           a.date_of_data=@PrvDate
   and           b.date_of_data=@PrvDate

   */
   ----------------------------------------ECBF-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_ECBF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_ECBF ';
   END IF;
   DELETE FROM tt_TEMP_ECBF;
   UTILS.IDENTITY_RESET('tt_TEMP_ECBF');

   INSERT INTO tt_TEMP_ECBF ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.accounts_data_ecbf --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_ecbf --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'ECBF' SourceSystem  
       FROM tt_TEMP_ECBF c
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_ecbf E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.accounts_data_ecbf_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_ecbf_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------Mifin-------------------------------------------------------------------
   /*
   IF OBJECT_ID('TEMPDB..#TEMP_Mifin') IS NOT NULL 
   DROP TABLE #TEMP_Mifin

   select distinct * into #TEMP_Mifin from (
   select Customer_ID from DWH_STG.dwh.accounts_data_mifin with(Nolock) --where date_of_data=@Date
   except
   select CustomerID from DWH_STG.dwh.customer_data_mifin with(Nolock) --where date_of_data=@Date
   )A

   insert into   tt_TEMPInsert([CD - ACCOUNT ID],[CD - Cust ID],[CD - UCIC],[PD - ACCOUNT ID],[PD - Cust ID],[PD - UCIC],SourceSystem)
   select		distinct  d.Customer_Ac_ID [CD - ACCOUNT ID],E.CustomerID [CD - Cust ID],e.UCIC_ID [CD - UCIC],
   			  a.Customer_Ac_ID [PD - ACCOUNT ID],A.Customer_ID [PD - Cust ID],b.UCIC_ID [PD - UCIC],
   			  'Mifin' SourceSystem
   from		  #TEMP_Mifin c 
   left join     DWH_STG.dwh.accounts_data_mifin d with(Nolock)
   on            c.Customer_ID=d.Customer_ID
   and           d.date_of_data=@Date
   left join     DWH_STG.dwh.customer_data_mifin E with(Nolock)
   on            c.Customer_ID=e.CustomerID
   and           e.DateOfData=@Date
   left join     DWH_STG.dwh.accounts_data_mifin_Backup a with(Nolock)
   on            a.customer_id=c.Customer_ID
   left join     DWH_STG.dwh.customer_data_mifin_Backup b with(Nolock)
   on            a.Customer_ID=b.CustomerID
   where           a.date_of_data=@PrvDate
   and           b.DateOfData=@PrvDate
   */
   ----------------------------------------FIS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_FIS') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_FIS ';
   END IF;
   DELETE FROM tt_TEMP_FIS;
   UTILS.IDENTITY_RESET('tt_TEMP_FIS');

   INSERT INTO tt_TEMP_FIS ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_FIS --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_FIS --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'FIS' SourceSystem  
       FROM tt_TEMP_FIS c
              LEFT JOIN dwh_DWH_STG.account_data_FIS D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_FIS E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_FIS_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_FIS_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------Vision Plus-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_VP') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_VP ';
   END IF;
   DELETE FROM tt_TEMP_VP;
   UTILS.IDENTITY_RESET('tt_TEMP_VP');

   INSERT INTO tt_TEMP_VP ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_visionplus --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_visionplus --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'Vision Plus' SourceSystem  
       FROM tt_TEMP_VP c
              LEFT JOIN dwh_DWH_STG.account_data_visionplus D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_visionplus E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_visionplus_Backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_visionplus_Backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------METAGRID-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_METAGRID') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_METAGRID ';
   END IF;
   DELETE FROM tt_TEMP_METAGRID;
   UTILS.IDENTITY_RESET('tt_TEMP_METAGRID');

   INSERT INTO tt_TEMP_METAGRID ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.account_data_metagrid --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.customer_data_metagrid --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'METAGRID' SourceSystem  
       FROM tt_TEMP_METAGRID c
              LEFT JOIN dwh_DWH_STG.account_data_metagrid D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.customer_data_metagrid E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.account_data_metagrid_backup a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.customer_data_metagrid_backup b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   ----------------------------------------EIFS-------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_EIFS') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_EIFS ';
   END IF;
   DELETE FROM tt_TEMP_EIFS;
   UTILS.IDENTITY_RESET('tt_TEMP_EIFS');

   INSERT INTO tt_TEMP_EIFS ( 
   	SELECT DISTINCT * 
   	  FROM ( SELECT Customer_ID 
             FROM dwh_DWH_STG.Account_data_EIFS --where date_of_data=@Date

             MINUS 
             SELECT Customer_ID 
             FROM dwh_DWH_STG.Customer_data_EIFS --where date_of_data=@Date
                    ) A );
   INSERT INTO tt_TEMPInsert
     ( CD_ACCOUNT_ID, CD_Cust_ID, CD_UCIC, PD_ACCOUNT_ID, PD_Cust_ID, PD_UCIC, SourceSystem )
     ( SELECT DISTINCT D.Customer_Ac_ID CD_ACCOUNT_ID  ,
                       E.Customer_ID CD_Cust_ID  ,
                       e.UCIC_ID CD_UCIC  ,
                       A.Customer_Ac_ID PD_ACCOUNT_ID  ,
                       A.Customer_ID PD_Cust_ID  ,
                       b.UCIC_ID PD_UCIC  ,
                       'EIFS' SourceSystem  
       FROM tt_TEMP_METAGRID c
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS D   ON c.Customer_ID = D.Customer_ID
              AND D.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.Customer_data_EIFS E   ON c.Customer_ID = e.Customer_ID
              AND e.date_of_data = v_Date
              LEFT JOIN dwh_DWH_STG.Account_data_EIFS_BACKUP a   ON a.customer_id = c.Customer_ID
              LEFT JOIN dwh_DWH_STG.Customer_data_EIFS_BACKUP b   ON a.Customer_ID = b.Customer_ID
        WHERE  a.date_of_data = v_PrvDate
                 AND b.date_of_data = v_PrvDate );
   OPEN  v_cursor FOR
      SELECT PD_Cust_ID ,
             PD_ACCOUNT_ID ,
             PD_UCIC ,
             CD_Cust_ID ,
             CD_ACCOUNT_ID ,
             CD_UCIC ,
             SourceSystem Source_System  
        FROM tt_TEMPInsert  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);------------------------------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CONDITION_CHECK_MISMATCHES" TO "ADF_CDR_RBL_STGDB";
