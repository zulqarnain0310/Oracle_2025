--------------------------------------------------------
--  DDL for Procedure SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" 
AS
   --Declare @TimeKey as Int =(26449)
   v_TimeKey NUMBER(10,0) := ( SELECT timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT DISTINCT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_TimeKey );
   v_cursor SYS_REFCURSOR;

BEGIN

   IF utils.object_id('tempdb..tt_temp1_20') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp1_20 ';
   END IF;
   DELETE FROM tt_temp1_20;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE SettlementLitigation_RF ';
   INSERT INTO SettlementLitigation_RF
     ( SourceName )
     VALUES ( 'SettlementLitigation' );
   INSERT INTO tt_temp1_20
     ( SELECT TableName ,
              COUNT(*)  CNT  
       FROM ( SELECT 'SettlementLitigation' TableName  ,
                     ACID || '|' || UTILS.CONVERT_TO_VARCHAR2(DateOfData,10,p_style=>105) || '|' || AcctFlag DataUtility  
              FROM ( SELECT A.ACID ,
                            UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) DateOfData  ,
                            'L' AcctFlag  
                     FROM ExceptionFinalStatusType a
                            LEFT JOIN RF_Settlement_Litigation b   ON a.ACID = b.AccountId
                            AND b.EffectiveFromTimeKey <= v_timekey
                            AND b.EffectiveToTimeKey >= v_timekey
                            AND b.AcctFlag = 'L'
                            JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON C.CustomerACID = A.ACID
                            AND C.EffectiveFromTimeKey <= v_timekey
                            AND C.EffectiveToTimeKey >= v_timekey
                            JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = c.SourceAlt_Key
                            AND D.EffectiveFromTimeKey <= v_timekey
                            AND D.EffectiveToTimeKey >= v_timekey
                      WHERE  a.StatusType = 'Litigation'
                               AND b.AccountId IS NULL
                               AND a.EffectiveFromTimeKey <= v_timekey
                               AND a.EffectiveToTimeKey >= v_timekey
                               AND D.SourceName = 'Finacle'
                               AND c.FacilityType IN ( 'CC','OD' )
                    ) a ) b
         GROUP BY TableName );
   --================================================================================================================================
   --Declare @TimeKey as Int =(26449)
   --Declare @Date as Date =(Select distinct Date from Automate_Advances where Timekey=@TimeKey)
   IF utils.object_id('tempdb..tt_temp2_17') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp2_17 ';
   END IF;
   DELETE FROM tt_temp2_17;
   INSERT INTO tt_temp2_17
     SELECT TableName ,
            COUNT(*)  CNT  
       FROM ( SELECT 'SettlementLitigation' TableName  ,
                     ACID || '|' || UTILS.CONVERT_TO_VARCHAR2(DateOfData,10,p_style=>105) || '|' || AcctFlag DataUtility  
              FROM ( SELECT A.ACID ,
                            UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) DateOfData  ,
                            'S' AcctFlag  
                     FROM ExceptionFinalStatusType a -----OTS_Details a

                            LEFT JOIN RF_Settlement_Litigation b   ON a.ACID = b.AccountId
                            AND b.EffectiveFromTimeKey <= v_timekey
                            AND b.EffectiveToTimeKey >= v_timekey
                            AND b.AcctFlag = 'S'
                            JOIN RBL_MISDB_PROD.AdvAcBasicDetail C   ON C.CustomerACID = A.ACID
                            AND C.EffectiveFromTimeKey <= v_timekey
                            AND C.EffectiveToTimeKey >= v_timekey
                            JOIN DIMSOURCEDB D   ON D.SourceAlt_Key = c.SourceAlt_Key
                            AND D.EffectiveFromTimeKey <= v_timekey
                            AND D.EffectiveToTimeKey >= v_timekey
                      WHERE  a.StatusType = 'Settlement'
                               AND b.AccountId IS NULL
                               AND a.EffectiveFromTimeKey <= v_timekey
                               AND a.EffectiveToTimeKey >= v_timekey
                               AND D.SourceName = 'Finacle'
                               AND c.FacilityType IN ( 'CC','OD' )
                    ) A ) B
       GROUP BY TableName
       ORDER BY 2 DESC;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, CASE 
   WHEN b.CNT IS NULL
     OR b.CNT = ' ' THEN 0
   ELSE b.CNT
      END AS Litigation_Count
   FROM A ,SettlementLitigation_RF a
          JOIN tt_temp1_20 b   ON a.SourceName = b.TableName ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Litigation_Count = src.Litigation_Count;
   UPDATE SettlementLitigation_RF
      SET Litigation_Count = 0
    WHERE  Litigation_Count IS NULL;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, CASE 
   WHEN b.CNT IS NULL THEN 0
   ELSE b.CNT
      END AS Settlement_Count
   FROM A ,SettlementLitigation_RF a
          JOIN tt_temp2_17 b   ON a.SourceName = b.TableName ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.Settlement_Count = src.Settlement_Count;
   UPDATE SettlementLitigation_RF
      SET Settlement_Count = 0
    WHERE  Settlement_Count IS NULL;
   UPDATE SettlementLitigation_RF
      SET Total_Count = Settlement_Count + Litigation_Count;
   OPEN  v_cursor FOR
      SELECT * 
        FROM SettlementLitigation_RF  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SETTLEMENTLITIGATION_RF_COUNT_TRACKER_04122023" TO "ADF_CDR_RBL_STGDB";
