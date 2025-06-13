--------------------------------------------------------
--  DDL for Procedure CCOD_SMA_NEW_TABLE_INSERT_4
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" 
AS
   v_TIMEKEY NUMBER(10,0) := '27250';
   v_date VARCHAR2(200) := '2024-08-09';

BEGIN

   --------------------------------------------------------------------sma ccod data moving into temp table
   INSERT INTO tt_CCOD_SMA
     ( SELECT B.AccountEntityID ,
              A."Account No." customeracid  ,
              NVL(c.MovementToStatus, 'STD') MovementFromStatus  ,
              A.AccountSMA_AssetClass MovementToStatus  ,
              v_date MovementFromDate  ,
              v_Timekey effectivefromtimekey  ,
              49999 effectivetotimekey  
       FROM tt_Temp_SMA_Main_Table_fina A
              JOIN MAIN_PRO.ACCOUNTCAL B   ON A.Account_No_ = B.CustomerAcID
              LEFT JOIN MAIN_PRO.CCOD_SMA c   ON A.Account_No_ = c.CustomerAcID
              AND c.effectivetotimekey = 49999
        WHERE  Source_System <> 'Visionplus'
                 AND Facility IN ( 'CC','OD' )

                 AND a.AccountSMA_AssetClass NOT IN ( 'Agri-Loan','FDOD' )
      );
   --AND           A.AccountSMA_AssetClass IN ('SMA_1','SMA_2')        
   --previous day and current data are same then data is delete from temp table
   DELETE A
    WHERE ROWID IN 
   ( SELECT A.ROWID
     FROM tt_CCOD_SMA A
            JOIN MAIN_PRO.CCOD_SMA B   ON A.Customeracid = B.Customeracid,
          A
    WHERE  b.effectivetotimekey = 49999
             AND A.MovementToStatus = B.MovementToStatus );
   --mismatch data are expired from ccod main table
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, v_timekey - 1 AS effectivetotimekey
   FROM A ,MAIN_PRO.CCOD_SMA A
          JOIN tt_CCOD_SMA B   ON A.Customeracid = B.Customeracid 
    WHERE A.effectivetotimekey = 49999
     AND A.MovementToStatus <> B.MovementToStatus) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.effectivetotimekey = src.effectivetotimekey;
   --insert mismatch data inserted into ccod main table
   INSERT INTO MAIN_PRO.CCOD_SMA
     ( AccountEntityID, CustomerAcID, MovementFromDate, MovementFromStatus, MovementToStatus, MovementToDate, EffectiveFromTimeKey, effectivetotimekey )
     ( SELECT AccountEntityID ,
              Customeracid ,
              MovementFromDate ,
              MovementFromStatus ,
              MovementToStatus ,
              '2086-01-01' ,
              v_Timekey ,
              49999 
       FROM tt_CCOD_SMA  );
   ----------------------------------------------------------------------------------------
   --outofdefault flag and date are updated
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'Y', v_Date
   FROM A ,tt_Temp_SMA_Main_Table_fina A
          JOIN MAIN_PRO.CCOD_SMA B   ON A.Account_No_ = B.Customeracid 
    WHERE A.Source_System <> 'Visionplus'
     AND A.Facility IN ( 'CC','OD' )

     AND B.effectiveFROMtimekey = v_Timekey
     AND MovementToStatus = 'STD') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET out_of_default_Y_N_ = 'Y',
                                out_of_default_date = v_Date;
   --getting indefault date data
   DELETE FROM tt_CCOD_INDEFAULT;
   UTILS.IDENTITY_RESET('tt_CCOD_INDEFAULT');

   INSERT INTO tt_CCOD_INDEFAULT ( 
   	SELECT CustomerAcID ,
           MAX(MovementFromDate)  MovementFromDateCCOD_IN  
   	  FROM MAIN_PRO.CCOD_SMA b
   	 WHERE  B.MovementFromStatus = 'STD'
              AND B.MovementToStatus IN ( 'SMA_1','SMA_2' )

   	  GROUP BY CustomerAcID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDateCCOD_IN, CASE 
   WHEN b.MovementFromDateCCOD_IN = v_date THEN 'Y'
   ELSE 'N'
      END AS pos_3, b.MovementFromDateCCOD_IN
   FROM A ,tt_Temp_SMA_Main_Table_fina A
          JOIN tt_CCOD_INDEFAULT b   ON A.Account_No_ = B.Customeracid ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.in_default_date = src.MovementFromDateCCOD_IN,
                                a.in_default_Y_N_ = pos_3,
                                b.First_Time_SMA_Classification_Date = src.MovementFromDateCCOD_IN;
   -----------------------------------------------------------------
   DELETE FROM tt_CCOD_ACCOUNT_SMA;
   UTILS.IDENTITY_RESET('tt_CCOD_ACCOUNT_SMA');

   INSERT INTO tt_CCOD_ACCOUNT_SMA ( 
   	SELECT CustomerAcID ,
           MAX(MovementFromDate)  MovementFromDate_ACCSMA  
   	  FROM MAIN_PRO.CCOD_SMA b
   	 WHERE  B.MovementToStatus IN ( 'SMA_1','SMA_2' )

              AND MovementFromStatus <> MovementToStatus
   	  GROUP BY CustomerAcID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate_ACCSMA
   FROM A ,tt_Temp_SMA_Main_Table_fina A
          JOIN tt_CCOD_ACCOUNT_SMA b   ON A.Account_No_ = B.Customeracid ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.AccountSMA_Dt = src.MovementFromDate_ACCSMA;
   ---------------------------------------------------------------------
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, b.MovementFromDate, b.MovementFromStatus, b.MovementToStatus
   FROM A ,tt_Temp_SMA_Main_Table_fina a
          JOIN MAIN_PRO.CCOD_SMA b   ON A.Account_No_ = B.Customeracid 
    WHERE b.EffectiveFromTimeKey <= v_TIMEKEY
     AND b.effectivetotimekey >= v_TIMEKEY) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.MovementFromDate = src.MovementFromDate,
                                a.MovementFromStatus = src.MovementFromStatus,
                                a.MovementToStatus = src.MovementToStatus;
   ---------------------------------------------------------------------
   -- select     a.[Account No.],max(b.SMA_date) SMA_date
   -- into       #CCOD_SMA_1
   --FROM        #Temp_SMA_Main_Table_final A
   --INNER JOIN  ##CCOD_SMA B
   --ON          A.[Account No.]=B.Customeracid
   --where       A.[Source System] <>'Visionplus'
   --and         A.Facility in ('CC','OD')
   ----AND         B.effectiveFROMtimekey=@Timekey
   --AND         SMA_Class='STD'
   --group by  a.[Account No.]
   --  select     a.[Account No.],min(b.SMA_date) SMA_date
   -- into       #CCOD_SMA_2
   --FROM        #Temp_SMA_Main_Table_final A
   --INNER JOIN  ##CCOD_SMA B
   --ON          A.[Account No.]=B.Customeracid
   --left join   #CCOD_SMA_1 c
   --on          a.[Account No.]=c.[Account No.]
   --where       A.[Source System] <>'Visionplus'
   --and         A.Facility in ('CC','OD')
   ----AND         B.effectiveFROMtimekey=@Timekey
   ----AND         SMA_Class<>'STD'
   --and         b.SMA_date >isnull(c.SMA_date,'1900-01-01')
   -- group by  a.[Account No.]
   --Update        a
   --set           a.[in_default date]=b.SMA_date,a.[in_default (Y/N)]=case when b.SMA_date=@date then 'Y' else 'N' end
   --              ,[First Time SMA Classification Date]=b.SMA_date
   --from          #Temp_SMA_Main_Table_final a
   --inner join    #CCOD_SMA_2  b
   -- on            a.[Account No.]=b.[Account No.]
   --
   --SELECT * INTO #MovementfromTo FROM (
   --SELECT *,ROW_NUMBER() OVER (PARTITION BY CUSTOMERACID ORDER BY CUSTOMERACID,SMA_DATE DESC) RN
   --FROM ##CCOD_SMA
   --)a WHERE RN<=2
   --Update        a
   --set           a.MovementFromDate=b.sma_date,a.MovementFromStatus=b.SMA_Class,a.MovementToStatus=c.sma_date,a.AccountSMA_Dt=b.sma_date
   --from          #Temp_SMA_Main_Table_final a
   --inner join    #MovementfromTo b
   --on            a.[Account No.]=b.customeracid
   --and           b.rn=2
   --inner join    #MovementfromTo c
   --on            a.[Account No.]=c.customeracid
   --and           c.rn=1
   --Update        a
   --set           a.AccountSMA_Dt=isnull(c.sma_date,d.SMA_Dt)
   --from          #Temp_SMA_Main_Table_final a
   --inner join    #MovementfromTo c
   --on            a.[Account No.]=c.customeracid
   --and           c.rn=1
   --left join     #MovementfromTo b
   --on            a.[Account No.]=b.customeracid
   --and           b.rn=2
   --left join     #TempACCOUNTCAL d
   --on            a.[Account No.]=d.customeracid
   --Update        a
   --set           a.MovementFromDate=b.SMA_date,a.MovementToStatus='STD'
   --from          #Temp_SMA_Main_Table_final a
   --inner join    #CCOD_SMA_1 b
   --on            a.[Account No.]=b.[Account No.]
   --  select     a.[Account No.],max(b.SMA_date) SMA_date,b.sma_class
   -- into       #CCOD_SMA_3
   --FROM        #Temp_SMA_Main_Table_final A
   --INNER JOIN  ##CCOD_SMA B
   --ON          A.[Account No.]=B.Customeracid
   --left join   #CCOD_SMA_1 c
   --on          a.[Account No.]=c.[Account No.]
   --where       A.[Source System] <>'Visionplus'
   --and         A.Facility in ('CC','OD')
   ----AND         B.effectiveFROMtimekey=@Timekey
   ----AND         SMA_Class<>'STD'
   --and         b.SMA_date <isnull(c.SMA_date,'1900-01-01')
   -- group by  a.[Account No.],sma_class
   --Update        a
   --set           a.MovementFromStatus=b.SMA_class
   --from          #Temp_SMA_Main_Table_final a
   --inner join    #CCOD_SMA_3  b
   -- on            a.[Account No.]=b.[Account No.]
   ------------First time insert manually------------------------------------------------
   --AccountEntityID,Customeracid,SMA_Class,SMA_date,@Timekey,49999
   INSERT INTO MAIN_PRO.CCOD_SMA
     ( SELECT a.AccountEntityID ,
              a.CustomerAcID ,
              b.MovementFromDate ,
              b.MovementFromStatus ,
              b.MovementToStatus ,
              b.MovementToDate ,
              b.EffectiveFromTimeKey ,
              49999 effectivetotimekey  
       FROM MAIN_PRO.ACCOUNTCAL A
              JOIN MAIN_PRO.ACCOUNT_MOVEMENT_HISTORY B   ON A.CustomerAcID = B.CustomerAcID
        WHERE  b.EffectiveToTimeKey = 49999
                 AND a.SourceAlt_Key <> 6
                 AND FacilityType IN ( 'CC','OD' )


                 --and           b.MovementToStatus<>'STD'
                 AND a.RefPeriodOverdue <= 91
                 AND b.FinalAssetClassAlt_Key = 1 );
   UPDATE MAIN_PRO.CCOD_SMA
      SET MovementToStatus = 'STD'
    WHERE  MovementToStatus = 'SMA_0';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CCOD_SMA_NEW_TABLE_INSERT_4" TO "ADF_CDR_RBL_STGDB";
