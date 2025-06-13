--------------------------------------------------------
--  DDL for Procedure STATUSREPORT_COUNTWISE_ACLCOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" 
AS
   v_TimeKey NUMBER(10,0) := ( SELECT DISTINCT TimeKey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );

BEGIN

   IF utils.object_id('tempdb..tt_temp6') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp6 ';
   END IF;
   DELETE FROM tt_temp6;
   UTILS.IDENTITY_RESET('tt_temp6');

   INSERT INTO tt_temp6 ( 
   	SELECT b.SourceAlt_Key ,
           a.SourceName ,
           CustomerID ,
           'Upgrade' ACLStatus  

   	  --select		b.SourceAlt_Key,a.SourceName,count(*)
   	  FROM ACL_UPG_DATA a
             JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )
    );
   --select * from tt_temp6 where SourceAlt_Key=1
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'Degrade' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'std'
                 AND FialAssetClass <> 'std' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'SUB-DB1' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'SUB'
                 AND FialAssetClass = 'DB1' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'DB1-DB2' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'DB1'
                 AND FialAssetClass = 'DB2' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'DB2-DB3' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'DB2'
                 AND FialAssetClass = 'DB3' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'DB3-LOS' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'DB3'
                 AND FialAssetClass = 'LOS' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'DB3-LOS' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'SUB'
                 AND FialAssetClass = 'LOS' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'DB3-LOS' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'DB1'
                 AND FialAssetClass = 'LOS' );
   INSERT INTO tt_temp6
     ( SourceAlt_Key, SourceName, CustomerID, ACLStatus )
     ( SELECT b.SourceAlt_Key ,
              a.SourceName ,
              CustomerID ,
              'DB3-LOS' ACLStatus  
       FROM ACL_NPA_DATA a
              JOIN DIMSOURCEDB b   ON a.SourceName = b.SourceName
        WHERE  UTILS.CONVERT_TO_VARCHAR2(Process_Date,200,p_style=>105) IN ( v_Date )

                 AND InitialAssetClass = 'DB2'
                 AND FialAssetClass = 'LOS' );
   IF utils.object_id('tempdb..tt_temp7') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp7 ';
   END IF;
   --select distinct  InitialAssetClass,FialAssetClass from ACL_NPA_DATA 
   DELETE FROM tt_temp7;
   UTILS.IDENTITY_RESET('tt_temp7');

   INSERT INTO tt_temp7 ( 
   	SELECT SourceAlt_Key ,
           SourceName ,
           COUNT(DISTINCT CustomerID)  CNT  
   	  FROM tt_temp6 
   	  GROUP BY SourceAlt_Key,SourceName );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.CNT
   FROM A ,StatusReport a
          JOIN tt_temp7 b   ON a.SourceAlt_Key = b.SourceAlt_Key ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.Total_ACL_Count = src.CNT;
   UPDATE StatusReport
      SET Total_ACL_Count = 0
    WHERE  Total_ACL_Count IS NULL;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."STATUSREPORT_COUNTWISE_ACLCOUNT" TO "ADF_CDR_RBL_STGDB";
