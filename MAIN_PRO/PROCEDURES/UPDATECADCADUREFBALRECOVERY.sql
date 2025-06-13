--------------------------------------------------------
--  DDL for Procedure UPDATECADCADUREFBALRECOVERY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" /*===========================================
AUTHER : TRILOKI KHANN
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : CALCULATE PREV QTR AND CURRENT QTR CREDIT AND PREV AND CURRENT QTR INT
--EXEC [PRO].[UpdateCADCADURefBalRecovery] 25490
===================================================*/
(
  v_TimeKey IN NUMBER
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
   BEGIN
      DECLARE
         v_QtrDefinition VARCHAR2(5);
         v_Refdate VARCHAR2(200);
         -- **************************
         -- Code for Qtr Boundry
         -- **************************
         v_Crt_Qtr_StartDt VARCHAR2(200);
         v_Crt_Qtr_EndDt VARCHAR2(200);
         v_Prev_Qtr_StartDt VARCHAR2(200);
         v_Prev_Qtr_EndDt VARCHAR2(200);

      BEGIN
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET PreQtrCredit = 0,
                PrvQtrInt = 0,
                CurQtrCredit = 0,
                CurQtrInt = 0;
         SELECT Date_ 

           INTO v_Refdate
           FROM RBL_MISDB_PROD.SysDayMAtrix 
          WHERE  TimeKey = v_TimeKey;
         IF ( v_Refdate = LAST_DAY(v_Refdate) ) THEN

         BEGIN
            UPDATE RBL_MISDB_PROD.SysSolutionParameter
               SET ParameterValue = 'Qtr'
             WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND ParameterName = 'QtrDefinition';

         END;
         ELSE

         BEGIN
            UPDATE RBL_MISDB_PROD.SysSolutionParameter
               SET ParameterValue = 'Day'
             WHERE  EffectiveFromTimeKey <= v_TimeKey
              AND EffectiveToTimeKey >= v_TimeKey
              AND ParameterName = 'QtrDefinition';

         END;
         END IF;
         -- Qtr condition
         SELECT ParameterValue 

           INTO v_QtrDefinition
           FROM RBL_MISDB_PROD.SysSolutionParameter 
          WHERE  EffectiveFromTimeKey <= v_TimeKey
                   AND EffectiveToTimeKey >= v_TimeKey
                   AND ParameterName = 'QtrDefinition';
         IF v_QtrDefinition = 'Qtr' THEN

         BEGIN
            --SELECT @Crt_Qtr_StartDt= DATEADD(DD,1,LastQtrDate),
            --       @Crt_Qtr_EndDt=Date,
            --	   @Prev_Qtr_StartDt=DATEADD(DD,1,LastToLastQtrDate),
            --	   @Prev_Qtr_EndDt= LastQtrDate
            --FROM RBL_MISDB_PROD.SysDayMAtrix
            --WHERE TimeKEy=@TimeKey
            SELECT utils.dateadd('DAY', 1, LAST_DAY(utils.dateadd('MONTH', -3, Date_))) ,
                   LAST_DAY(DATE_) ,
                   utils.dateadd('DAY', 1, LAST_DAY(utils.dateadd('MONTH', -6, Date_))) ,
                   LAST_DAY(utils.dateadd('MONTH', -3, Date_)) 

              INTO v_Crt_Qtr_StartDt,
                   v_Crt_Qtr_EndDt,
                   v_Prev_Qtr_StartDt,
                   v_Prev_Qtr_EndDt
              FROM RBL_MISDB_PROD.SysDayMAtrix 
             WHERE  TimeKEy = v_TimeKey;

         END;
         ELSE

         BEGIN
            SELECT utils.dateadd('MONTH', -3, DATE_) ,
                   Date_ ,
                   utils.dateadd('MONTH', -6, DATE_) ,
                   utils.dateadd('MONTH', 3, utils.dateadd('MONTH', -6, DATE_) - 1) 

              INTO v_Crt_Qtr_StartDt,
                   v_Crt_Qtr_EndDt,
                   v_Prev_Qtr_StartDt,
                   v_Prev_Qtr_EndDt
              FROM RBL_MISDB_PROD.SysDayMAtrix 
             WHERE  TimeKEy = v_TimeKey;

         END;
         END IF;
         IF utils.object_id('Tempdb..GTT_AcDailyTxnDetail') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_AcDailyTxnDetail ';
         END IF;
         DELETE FROM GTT_AcDailyTxnDetail;
         UTILS.IDENTITY_RESET('GTT_AcDailyTxnDetail');

         INSERT INTO GTT_AcDailyTxnDetail ( 
         	SELECT A.* 
         	  FROM CURDAT_RBL_MISDB_PROD.AcDailyTxnDetail A
         	 WHERE  TxnType IN ( 'CREDIT','DEBIT' )

                    AND TxnSubType IN ( 'RECOVERY','INTEREST' )

                    AND TxnDate BETWEEN v_Prev_Qtr_StartDt AND v_Crt_Qtr_EndDt );
         EXECUTE IMMEDIATE ' CREATE INDEX tt_AcDailyTxnDetail_3_Ctrl
            ON GTT_AcDailyTxnDetail ( EntityKey)';
         EXECUTE IMMEDIATE ' CREATE INDEX tt_AcDailyTxnDetail_3_001_IX
            ON GTT_AcDailyTxnDetail ( TxnType,
                                       TxnSubType,
                                       TxnDate)';
         --***********************
         -- Previous Qtr Credit
         --***********************
 
            MERGE INTO MAIN_PRO.ACCOUNTCAL FCC
            USING (SELECT FCC.ROWID row_id, utils.round_(PQC.TxnAmount, 0) AS PreQtrCredit
            FROM MAIN_PRO.ACCOUNTCAL FCC
                   JOIN (
                        SELECT SUM(NVL(TxnAmount, 0)) TxnAmount 
                               ,A.AccountEntityID 
                        FROM GTT_AcDailyTxnDetail A
                          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityID = B.AccountEntityID
                        WHERE  TxnType = 'CREDIT'
                                AND TxnSubType = 'RECOVERY'
                                AND TxnDate BETWEEN v_Prev_Qtr_StartDt AND v_Prev_Qtr_EndDt
                        GROUP BY A.AccountEntityID 
                        ) PQC   ON FCC.AccountEntityID = PQC.AccountEntityID ) src
            ON ( FCC.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET PreQtrCredit = src.PreQtrCredit
            ;
         --***********************
         -- Previous Qtr Interest
         --***********************

            MERGE INTO MAIN_PRO.ACCOUNTCAL FCC
            USING (SELECT FCC.ROWID row_id, utils.round_(PQC.TxnAmount, 0) AS PrvQtrInt
            FROM MAIN_PRO.ACCOUNTCAL FCC
                   JOIN (
                        SELECT SUM(NVL(TxnAmount, 0)) TxnAmount
                               ,A.AccountEntityID 
                        FROM GTT_AcDailyTxnDetail A
                            JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityID = B.AccountEntityID
                        WHERE  TxnType = 'DEBIT'
                            AND TxnSubType = 'INTEREST'
                            AND TxnDate BETWEEN v_Prev_Qtr_StartDt AND v_Prev_Qtr_EndDt
                         GROUP BY A.AccountEntityID 
                   ) PQC   ON FCC.AccountEntityID = PQC.AccountEntityID ) src
            ON ( FCC.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET PrvQtrInt = src.PrvQtrInt
            ;
         --***********************
         -- Current Qtr Credit
         --***********************
            MERGE INTO MAIN_PRO.ACCOUNTCAL FCC
            USING (SELECT FCC.ROWID row_id, utils.round_(PQC.TxnAmount, 0) AS CurQtrCredit
            FROM MAIN_PRO.ACCOUNTCAL FCC
                   JOIN (
                         SELECT SUM(NVL(TxnAmount, 0)) TxnAmount 
                                ,A.AccountEntityID 
                            FROM GTT_AcDailyTxnDetail A
                              JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityID = B.AccountEntityID
                          WHERE  TxnType = 'CREDIT'
                                AND TxnSubType = 'RECOVERY'
                                AND TxnDate BETWEEN v_Crt_Qtr_StartDt AND v_Crt_Qtr_EndDt
                        GROUP BY A.AccountEntityID 
                   ) PQC   ON FCC.AccountEntityID = PQC.AccountEntityID ) src
            ON ( FCC.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET CurQtrCredit = src.CurQtrCredit
            ;
         --***********************
         -- Current Qtr Interest
         --*********************** 
            MERGE INTO MAIN_PRO.ACCOUNTCAL FCC
            USING (SELECT FCC.ROWID row_id, utils.round_(PQC.TxnAmount, 0) AS CurQtrInt
                    FROM MAIN_PRO.ACCOUNTCAL FCC
                   JOIN (
                        SELECT SUM(NVL(TxnAmount, 0)) TxnAmount
                                ,A.AccountEntityID 
                        FROM GTT_AcDailyTxnDetail A
                                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityID = B.AccountEntityID
                        WHERE  TxnType = 'DEBIT'
                            AND TxnSubType = 'INTEREST'
                            AND TxnDate BETWEEN v_Crt_Qtr_StartDt AND v_Crt_Qtr_EndDt
                        GROUP BY A.AccountEntityID 
                   ) PQC   ON FCC.AccountEntityID = PQC.AccountEntityID ) src
            ON ( FCC.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET CurQtrInt = src.CurQtrInt
            ;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET PreQtrCredit = 0
          WHERE  PreQtrCredit IS NULL;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET PrvQtrInt = 0
          WHERE  PrvQtrInt IS NULL;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET CurQtrCredit = 0
          WHERE  CurQtrCredit IS NULL;
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET CurQtrInt = 0
          WHERE  CurQtrInt IS NULL;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
    V_SQLERRM:=SQLERRM;
      OPEN  v_cursor FOR
         SELECT 'Proc Name: ' || NVL(utils.error_procedure, ' ') || ' ErrorMsg: ' || NVL(V_SQLERRM, ' ') 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATECADCADUREFBALRECOVERY" TO "ADF_CDR_RBL_STGDB";
