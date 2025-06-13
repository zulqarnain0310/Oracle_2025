--------------------------------------------------------
--  DDL for Procedure GETTIMEKEYBYMENUID_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" 
(
  v_MenuId IN NUMBER DEFAULT 506 
)
AS
   v_FreqType CHAR := 'D';
   v_DayLimit NUMBER(10,0) := 0;
   v_CarryForwordFlag CHAR := 'Y';
   v_HalfYrDateStartKey NUMBER(10,0) := 0;
   v_HalfYrDateEndKey NUMBER(10,0) := 0;
   v_HalfYrDate VARCHAR2(10);
   v_Date VARCHAR2(200) := ( SELECT SYSDATE 
     FROM DUAL  );
   v_FreqEndDate VARCHAR2(200);
   v_FreqDate VARCHAR2(200);
   --Select @DATE DATE, @FreqEndDate FreqEndDate,@FreqDate FreqDate
   --else 
   --	select @DATE
   --Select LastQtrDate,CurQtrDateKey, * from SysDayMatrix WHERE  TimeKey=25019
   ----CAST(Date AS DATE)=CAST(GETDATE() AS DATE)
   v_EffectiveFromTimeKey NUMBER(10,0);
   v_EffectiveToTimeKey NUMBER(10,0);
   v_EffectiveFromTimeKey_FREEZE NUMBER(10,0);
   v_EffectiveToTimeKey_FREEZE NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--Declare @MenuId int = 516

BEGIN

   SELECT ' ' ,
          NVL(' ', 0) ,
          NVL(' ', 'Y') 

     INTO v_FreqType,
          v_DayLimit,
          v_CarryForwordFlag
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuId;
   IF NULLIF(v_FreqType, ' ') IS NULL THEN

   BEGIN
      v_FreqType := 'D' ;
      v_DayLimit := 0 ;
      v_CarryForwordFlag := 'Y' ;

   END;
   END IF;
   SELECT PrevHalfYrDateKey + 1 ,
          HalfYrDateKey ,
          utils.dateadd('DAY', 1, PrevHalfYrDate) 

     INTO v_HalfYrDateStartKey,
          v_HalfYrDateEndKey,
          v_HalfYrDate
     FROM SysDayMatrix 
    WHERE  DATE_ = v_Date;
   SELECT CASE 
               WHEN v_FreqType = 'D' THEN utils.dateadd('DAY', -v_DayLimit, Date_)
               WHEN v_FreqType = 'W' THEN LastWkDate
               WHEN v_FreqType = 'M' THEN LastMonthDate
               WHEN v_FreqType = 'Q' THEN LastQtrDate
               WHEN v_FreqType = 'Y' THEN LastFinYear
               WHEN v_FreqType = 'H' THEN utils.dateadd('DAY', 1, PrevHalfYrDate)   END 

     INTO v_FreqDate
     FROM SysDayMatrix 
    WHERE  Date_ = v_Date;
   v_FreqEndDate := utils.dateadd('DAY', v_DayLimit, v_FreqDate) ;
   IF v_FreqEndDate >= v_Date THEN
    v_DATE := v_FreqDate ;
   END IF;
   DBMS_OUTPUT.PUT_LINE(v_FreqType);
   DBMS_OUTPUT.PUT_LINE(v_CarryForwordFlag);
   SELECT CASE 
               WHEN v_FreqType = 'D' THEN TimeKey
               WHEN v_FreqType = 'W' THEN LastWkDateKey + 1
               WHEN v_FreqType = 'M' THEN LastMonthDateKey + 1
               WHEN v_FreqType = 'Q' THEN LastQtrDateKey + 1
               WHEN v_FreqType = 'Y' THEN LastFinYearKey + 1
               WHEN v_FreqType = 'H' THEN v_HalfYrDateStartKey   END ,
          CASE 
               WHEN v_CarryForwordFlag = 'N' THEN CASE 
                                                       WHEN v_FreqType = 'D' THEN TimeKey
                                                       WHEN v_FreqType = 'W' THEN WeekDateKey
                                                       WHEN v_FreqType = 'M' THEN ( SELECT TimeKey 
                                                                                    FROM SysDayMatrix 
                                                                                     WHERE  Date_ = EOMONTH(v_DATE) )
                                                       WHEN v_FreqType = 'Q' THEN CurQtrDateKey
                                                       WHEN v_FreqType = 'Y' THEN CurFinYearKey
                                                       WHEN v_FreqType = 'H' THEN v_HalfYrDateEndKey   END
          ELSE 49999
             END 

     INTO v_EffectiveFromTimeKey,

          --END  EffectiveFromTimeKey,
          v_EffectiveToTimeKey

     --EffectiveToTimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(Date_,200) = v_DATE;
   IF ( v_FreqType = 'F'
     AND ( v_MenuId = 506
     OR v_MenuId = 505 ) ) THEN

   BEGIN
      SELECT ( SELECT MAX(TimeKey)  
               FROM SysDataMatrix 
                WHERE  Prev_Qtr_key = ( SELECT MAX(TimeKey)  
                                        FROM SysDataMatrix 
                                         WHERE  NVL(QTR_Initialised, 'N') = 'Y'
                                                  AND NVL(QTR_Frozen, 'N') = 'Y' ) ) 

        INTO v_EffectiveFromTimeKey_FREEZE
        FROM DUAL ;
      --if(@MenuId=505)
      v_EffectiveToTimeKey_FREEZE := v_EffectiveFromTimeKey_FREEZE ;
      --else
      --SELECT @EffectiveToTimeKey_FREEZE=49999
      OPEN  v_cursor FOR
         SELECT v_EffectiveFromTimeKey_FREEZE EffectiveFromTimeKey  ,
                v_EffectiveToTimeKey_FREEZE EffectiveToTimeKey  ,
                v_DATE Date_  ,
                'TimeKey' TableName  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE
      IF ( v_FreqType = 'F' ) THEN

      BEGIN
         SELECT TimeKey 

           INTO v_EffectiveFromTimeKey_FREEZE
           FROM SysDayMatrix 
          WHERE  DATE_ = ( SELECT MIN(MonthFirstDate)  
                           FROM SysDataMatrix 
                            WHERE  NVL(QTR_Initialised, 'N') = 'Y'
                                     AND NVL(QTR_Frozen, 'N') = 'N' );
         v_EffectiveToTimeKey_FREEZE := 49999 ;
         OPEN  v_cursor FOR
            SELECT v_EffectiveFromTimeKey_FREEZE EffectiveFromTimeKey  ,
                   v_EffectiveToTimeKey_FREEZE EffectiveToTimeKey  ,
                   v_DATE Date_  ,
                   'TimeKey' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE
         IF ( v_MenuId = 643 ) THEN
          DECLARE
            v_YrStTimekey NUMBER(10,0);
            v_YrStartdate VARCHAR2(200);
            v_YrEndTimekey NUMBER(10,0);
            v_YrEndDate VARCHAR2(200);

         BEGIN
            SELECT MIN(Timekey)  

              INTO v_YrEndTimekey
              FROM ModluleFreezeStatus 
             WHERE  ModuleName = 'FactTarget'
                      AND NVL(Frozen, 'N') = 'N';
            SELECT ( SELECT DATE_ 
                     FROM SysDayMatrix 
                      WHERE  TimeKey = v_YrEndTimekey ) 

              INTO v_YrEndDate
              FROM DUAL ;
            v_YrStartdate := utils.dateadd('DAY', 1, utils.dateadd('YEAR', -1, v_YrEndDate)) ;
            SELECT ( SELECT TimeKey 
                     FROM SysDayMatrix 
                      WHERE  DATE_ = v_YrStartdate ) 

              INTO v_YrStTimekey
              FROM DUAL ;
            OPEN  v_cursor FOR
               SELECT v_YrStTimekey EffectiveFromTimeKey  ,
                      49999 EffectiveToTimeKey  ,
                      v_DATE Date_  ,
                      'TimeKey' TableName  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE

         BEGIN
            OPEN  v_cursor FOR
               SELECT v_EffectiveFromTimeKey EffectiveFromTimeKey  ,
                      v_EffectiveToTimeKey EffectiveToTimeKey  ,
                      v_DATE Date_  ,
                      'TimeKey' TableName  
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GETTIMEKEYBYMENUID_04122023" TO "ADF_CDR_RBL_STGDB";
