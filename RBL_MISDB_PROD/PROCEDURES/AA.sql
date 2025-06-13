--------------------------------------------------------
--  DDL for Procedure AA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."AA" 
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT InitialAssetClassAlt_Key ,
             InitialNpaDt ,
             FinalAssetClassAlt_Key ,
             FinalNpaDt ,
             NPA_Reason ,
             FlgUpg ,
             UpgDate ,
             * 
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
       WHERE  UcifEntityID IN ( 19437,127426,2458332,2512897,4148274,5011231 )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   UPDATE PRO_RBL_MISDB_PROD.ACCOUNTCAL
      SET FlgUpg = 'U',
          UpgDate = '2021-11-30'
    WHERE  UcifEntityID IN ( 19437,127426,2458332,2512897,4148274,5011231 )
   ;
   OPEN  v_cursor FOR
      SELECT SrcAssetClassAlt_Key ,
             SrcNPA_Dt ,
             SysAssetClassAlt_Key ,
             SysNPA_Dt ,
             DegReason ,
             FlgUpg ,
             * 
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL 
       WHERE  UcifEntityID IN ( 19437,127426,2458332,2512897,4148274,5011231 )
    ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
      SET FlgUpg = 'U'
    WHERE  UcifEntityID IN ( 19437,127426,2458332,2512897,4148274,5011231 )
   ;--select * from DIMSOURCEDB 
   --select count(1) from pro.accountcal where SourceAlt_Key=5
   --select count(1) from AdvAcBalanceDetail a
   --	inner join pro.accountcal b
   --		on a.AccountEntityId=b.AccountEntityID
   --		and a.EffectiveToTimeKey=49999
   --	inner join Ganaseva_30th_1 c
   --		on a.RefSystemAcId =c.customer_ac_id
   --	where SourceAlt_Key=5 and b.OverDueSinceDt is  null
   --	and a.EffectiveFromTimeKey=26267
   --	select count(1) from Ganaseva_30th_1
   --from AdvAcBalanceDetail a
   --	inner join pro.accountcal b
   --		on a.AccountEntityId=b.AccountEntityID
   --		and a.EffectiveToTimeKey=49999
   --	inner join Ganaseva_30th_1 c
   --		on a.RefSystemAcId =c.customer_ac_id
   --	where SourceAlt_Key=5 and b.OverDueSinceDt is  null
   --	and a.EffectiveFromTimeKey=26267
   --	SELECT * FROM Ganaseva_30th_1
   --	SET DATEFORMAT DMY
   --	UPDATE Ganaseva_30th_1 SET principal_Over_due_Since_dt_NEW =principal_Over_due_Since_dt
   --	UPDATE Ganaseva_30th_1 SET Interest_Over_Due_Since_Dt_NEW =Interest_Over_Due_Since_Dt
   --	SET DATEFORMAT YMD
   --	UPDATE Ganaseva_30th_1 SET Oth_Charges_Over_Due_Since_Dt_NEW =Oth_Charges_Over_Due_Since_Dt
   --	SELECT DISTINCT Oth_Charges_Over_Due_Since_Dt FROM Ganaseva_30th_1 WHERE Oth_Charges_Over_Due_Since_Dt  IS NOt NULL 

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."AA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."AA" TO "ADF_CDR_RBL_STGDB";
