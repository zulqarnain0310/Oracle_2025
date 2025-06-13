--------------------------------------------------------
--  DDL for Procedure FREEZE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "BS_RBL_MISDB_PROD"."FREEZE_SELECT" 
(
  v_LastQtrDateKey IN NUMBER DEFAULT 25475 ,
  v_UserLoginID IN VARCHAR2 DEFAULT NULL ,
  v_TimeKey IN NUMBER DEFAULT 26692 
)
AS
   v_PrevLastQtrDateKey NUMBER(10,0);
   v_CurrQtrDate VARCHAR2(200);
   v_PreMoc VARCHAR2(1) ;
   v_cursor SYS_REFCURSOR;
   --------------------  New ---------------------
   v_LastQtrDateKey1 NUMBER(10,0);
   v_PrevLastQtrDateKey1 NUMBER(10,0);
   v_CurrQtrDate1 VARCHAR2(200);
   v_LastDayTimeKeyOfQtr NUMBER(10,0);
   v_PreMoc1 VARCHAR2(1) ;
   v_YrStTimekey NUMBER(10,0);
   v_YrStartdate VARCHAR2(200);
   v_YrEndTimekey NUMBER(10,0);
   v_YrEndDate VARCHAR2(200);

BEGIN

   SELECT NVL(BS_Pre_MOC_Freeze, 'N') INTO v_PreMoc  
     FROM BS_RBL_MISDB_PROD.FactBranch 
    WHERE  Timekey = v_LastQtrDateKey
             AND NVL(BS_Pre_MOC_Freeze, 'N') = 'N'
     GROUP BY BS_Pre_MOC_Freeze ;

   SELECT NVL(BS_Pre_MOC_Freeze, 'N') INTO v_PreMoc1 
     FROM BS_RBL_MISDB_PROD.FactBranch 
    WHERE  Timekey = v_LastDayTimeKeyOfQtr
             AND NVL(BS_Pre_MOC_Freeze, 'N') = 'N'
     GROUP BY BS_Pre_MOC_Freeze;

   SELECT MAX(Prev_Qtr_key)  

     INTO v_PrevLastQtrDateKey
     FROM RBL_MISDB_PROD.SysDataMatrix 
    WHERE  Prev_Qtr_key < v_LastQtrDateKey;
   SELECT Date_ 

     INTO v_CurrQtrDate
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  TImekey = ( SELECT MAX(Qtr_key)  
                       FROM RBL_MISDB_PROD.SysDataMatrix 
                        WHERE  Prev_Qtr_key = v_PrevLastQtrDateKey );
   DBMS_OUTPUT.PUT_LINE(v_PrevLastQtrDateKey);
   DBMS_OUTPUT.PUT_LINE(v_CurrQtrDate);
   DBMS_OUTPUT.PUT_LINE(NVL(v_PreMoc, 'Y') || ' PreMoc');
   --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
   --IF (@OperationFlag IN(1,2,3,16,17,20))
   ----BEGIN
   DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
   EXECUTE IMMEDIATE 'EXECUTE ACLProcessStatusCheck()' ;
   ----END
   OPEN  v_cursor FOR
      SELECT MOC_Initialised ,
             QTR_Initialised ,
             MasterFreeze ,
             PreMocFreeze ,
             QTR_Frozen ,
             PRV_QTR_Frozen ,
             MOC_Frozen ,
             v_CurrQtrDate CurrQtrDate  ,
             PrevQtrTimeKey ,
             TableName ,
             NVL(( SELECT 1 
                   FROM ( SELECT CustomerID 
                          FROM DataUpload_RBL_MISDB_PROD.MocAccountDataUpload_Mod 
                           WHERE  AuthorisationStatus IN ( 'NP','MP','DP' )

                          UNION 
                          SELECT CustomerID 
                          FROM DataUpload_RBL_MISDB_PROD.MocCustomerDataUpload_Mod 
                           WHERE  AuthorisationStatus IN ( 'NP','MP','DP' )
                         ) t 
                     FETCH FIRST 1 ROWS ONLY ), 0) DataExist  
        FROM ( SELECT CASE 
                           WHEN NVL(MOC_Initialised, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END MOC_Initialised  ,
                      CASE 
                           WHEN NVL(QTR_Initialised, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END QTR_Initialised  ,
                      CASE 
                           WHEN NVL(BS_MasterFreeze, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END MasterFreeze  ,
                      CASE 
                           WHEN NVL(v_PreMoc, ' ') <> ' ' THEN 'N'
                      ELSE 'Y'
                         END PreMocFreeze  ,
                      CASE 
                           WHEN NVL(QTR_Frozen, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END QTR_Frozen  ,
                      CASE 
                           WHEN NVL(MOC_Frozen, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END MOC_Frozen  ,
                      ( SELECT CASE 
                                    WHEN NVL(QTR_Frozen, ' ') = ' ' THEN 'N'
                               ELSE 'Y'
                                  END col  
                        FROM RBL_MISDB_PROD.SysDataMatrix 
                         WHERE  TImekey = ( SELECT MAX(TImekey)  
                                            FROM RBL_MISDB_PROD.SysDataMatrix 
                                             WHERE  Prev_Qtr_key = v_PrevLastQtrDateKey ) ) PRV_QTR_Frozen  ,
                      Prev_Qtr_key PrevQtrTimeKey  ,
                      'FreezeData' TableName  
               FROM RBL_MISDB_PROD.SysDataMatrix 
                WHERE  Prev_Qtr_key = v_PrevLastQtrDateKey -- AND QTR_Initialised ='Y'
              ) A
        GROUP BY MOC_Initialised,MOC_Frozen,QTR_Initialised,MasterFreeze,PreMocFreeze,QTR_Frozen,PRV_QTR_Frozen,PrevQtrTimeKey,TableName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   SELECT MIN(Prev_Qtr_key)  

     INTO v_LastQtrDateKey1
     FROM RBL_MISDB_PROD.SysDataMatrix 
    WHERE  Prev_Qtr_key > ( SELECT MAX(Prev_Qtr_key)  
                            FROM RBL_MISDB_PROD.SysDataMatrix 
                             WHERE  Prev_Qtr_key = ( SELECT MAX(Prev_Qtr_key)  
                                                     FROM RBL_MISDB_PROD.SysDataMatrix 
                                                      WHERE  QTR_Initialised = 'Y'
                                                               AND QTR_Frozen = 'Y' ) );
   DBMS_OUTPUT.PUT_LINE(v_LastQtrDateKey1);
   SELECT MAX(Prev_Qtr_key)  

     INTO v_PrevLastQtrDateKey1
     FROM RBL_MISDB_PROD.SysDataMatrix 
    WHERE  Prev_Qtr_key < v_LastQtrDateKey1;
   DBMS_OUTPUT.PUT_LINE(v_PrevLastQtrDateKey1);
   SELECT Date_ 

     INTO v_CurrQtrDate1
     FROM RBL_MISDB_PROD.SysDayMatrix 
    WHERE  TImekey = ( SELECT MAX(Qtr_key)  
                       FROM RBL_MISDB_PROD.SysDataMatrix 
                        WHERE  Prev_Qtr_key = v_LastQtrDateKey1 );
   SELECT MAX(TimeKey)  

     INTO v_LastDayTimeKeyOfQtr
     FROM RBL_MISDB_PROD.SysDataMatrix 
    WHERE  Prev_Qtr_key = ( SELECT MAX(TimeKey)  
                            FROM RBL_MISDB_PROD.SysDataMatrix 
                             WHERE  NVL(QTR_Initialised, 'N') = 'Y'
                                      AND NVL(QTR_Frozen, 'N') = 'Y' );
   OPEN  v_cursor FOR
      SELECT MOC_Initialised ,
             QTR_Initialised ,
             MasterFreeze ,
             PreMocFreeze ,
             QTR_Frozen ,
             PRV_QTR_Frozen ,
             MOC_Frozen ,
             v_CurrQtrDate1 CurrQtrDate  ,
             PrevQtrTimeKey ,
             TableName 
        FROM ( SELECT CASE 
                           WHEN NVL(MOC_Initialised, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END MOC_Initialised  ,
                      CASE 
                           WHEN NVL(QTR_Initialised, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END QTR_Initialised  ,
                      CASE 
                           WHEN NVL(BS_MasterFreeze, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END MasterFreeze  ,
                      CASE 
                           WHEN NVL(v_PreMoc1, ' ') <> ' ' THEN 'N'
                      ELSE 'Y'
                         END PreMocFreeze  ,
                      CASE 
                           WHEN NVL(QTR_Frozen, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END QTR_Frozen  ,
                      CASE 
                           WHEN NVL(MOC_Frozen, 'N') = 'Y' THEN 'Y'
                      ELSE 'N'
                         END MOC_Frozen  ,
                      ( SELECT CASE 
                                    WHEN NVL(QTR_Frozen, 'N') = 'N' THEN 'N'
                               ELSE 'Y'
                                  END col  
                        FROM RBL_MISDB_PROD.SysDataMatrix 
                         WHERE  TImekey = ( SELECT MAX(TImekey)  
                                            FROM RBL_MISDB_PROD.SysDataMatrix 
                                             WHERE  Prev_Qtr_key = v_PrevLastQtrDateKey1 ) ) PRV_QTR_Frozen  ,
                      Prev_Qtr_key PrevQtrTimeKey  ,
                      'FreezeData1' TableName  
               FROM RBL_MISDB_PROD.SysDataMatrix 
                WHERE  Prev_Qtr_key = v_LastQtrDateKey1 -- AND QTR_Initialised ='Y'
              ) A
        GROUP BY MOC_Initialised,MOC_Frozen,QTR_Initialised,MasterFreeze,PreMocFreeze,QTR_Frozen,PRV_QTR_Frozen,PrevQtrTimeKey,TableName ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   SELECT MIN(Timekey)  

     INTO v_YrEndTimekey
     FROM RBL_MISDB_PROD.ModluleFreezeStatus 
    WHERE  ModuleName = 'FactTarget'
             AND NVL(Frozen, 'N') = 'N';
   SELECT ( SELECT DATE_ 
            FROM RBL_MISDB_PROD.SysDayMatrix 
             WHERE  TimeKey = v_YrEndTimekey ) 

     INTO v_YrEndDate
     FROM DUAL ;
   v_YrStartdate := utils.dateadd('DAY', 1, utils.dateadd('YEAR', -1, v_YrEndDate)) ;
   SELECT ( SELECT TimeKey 
            FROM RBL_MISDB_PROD.SysDayMatrix 
             WHERE  DATE_ = v_YrStartdate ) 

     INTO v_YrStTimekey
     FROM DUAL ;
   DBMS_OUTPUT.PUT_LINE(v_YrEndDate);
   DBMS_OUTPUT.PUT_LINE(v_YrEndTimekey);
   DBMS_OUTPUT.PUT_LINE(v_YrStartdate);
   DBMS_OUTPUT.PUT_LINE(v_YrStTimekey);
   OPEN  v_cursor FOR
      SELECT v_YrStTimekey YrStartTimekey  ,
             v_YrStartdate YrStartdate  ,
             v_YrEndTimekey YrEndTimekey  ,
             v_YrEndDate YrEndDate  ,
             NVL(Initialised, 'N') Initialised  ,
             NVL(MasterFrozen, 'N') MasterFrozen  ,
             NVL(Frozen, 'N') Frozen  ,
             'Y' PrvFrozen  ,
             'TargetFreezeData' TableName  
        FROM RBL_MISDB_PROD.ModluleFreezeStatus 
       WHERE  ModuleName = 'FactTarget'
                AND Timekey = v_YrEndTimekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "BS_RBL_MISDB_PROD"."FREEZE_SELECT" TO "ADF_CDR_RBL_STGDB";
