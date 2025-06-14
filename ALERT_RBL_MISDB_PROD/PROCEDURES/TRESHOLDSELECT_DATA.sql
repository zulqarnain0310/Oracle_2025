--------------------------------------------------------
--  DDL for Procedure TRESHOLDSELECT_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" 
(
  v_Location IN CHAR DEFAULT 'HO' ,
  v_LocationCode IN VARCHAR2 DEFAULT ' ' ,
  v_MasterNameAlt_Key IN NUMBER DEFAULT 2 ,
  --,@MasterAlt_Key			INT			=0
  v_EffectiveDt IN VARCHAR2 DEFAULT ' ' ,
  v_Timekey IN NUMBER DEFAULT 49999 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_IncreasedVal IN NUMBER DEFAULT 10 ,
  v_DecreaseVal IN NUMBER DEFAULT 30 
)
AS
   v_SQLQuery_Main VARCHAR2(4000);
   v_Result_1 NUMBER(10,0);
   v_temp TT_DIMTHRESHOLDMASTER_3%ROWTYPE;
   cv_ins SYS_REFCURSOR;
   v_cursor SYS_REFCURSOR;
   v_Flag CHAR(1) := 'N';
    V_COUNT INT;
BEGIN

   ALERT_RBL_MISDB_PROD.TresholdSelect(v_Location => v_Location,
                                       v_LocationCode => v_LocationCode,
                                       v_MasterNameAlt_Key => v_MasterNameAlt_Key,
                                       v_MasterAlt_Key => 
                                       --,@MasterAlt_Key		= @MasterAlt_Key
                                       v_EffectiveDt,
                                       v_EffectiveDt => v_Timekey,
                                       iv_Timekey => v_OperationFlag,
                                       v_OperationFlag => v_Result_1,
                                       v_Result => v_SQLQuery_Main) ;
   DELETE FROM tt_DimThresholdMaster_3;
   --SELECT @SQLQuery_Main;
   
   SELECT COUNT(1) INTO  V_COUNT FROM tt_DimThresholdMaster_3 ;
   IF V_COUNT>1
    THEN
        EXECUTE IMMEDIATE 'DROP TABLE tt_DimThresholdMaster_3';
    END IF;

   cv_ins := EXECUTE IMMEDIATE v_SQLQuery_Main;
   LOOP
      FETCH cv_ins INTO v_temp;
      EXIT WHEN cv_ins%NOTFOUND;
      INSERT INTO tt_DimThresholdMaster_3 VALUES v_temp;
   END LOOP;
   CLOSE cv_ins;
   IF v_OperationFlag = 1 THEN

   BEGIN
      UPDATE tt_DimThresholdMaster_3
         SET IncreaseThreshold = CASE 
                                      WHEN NVL(v_IncreasedVal, 0) <> 0 THEN v_IncreasedVal
             ELSE IncreaseThreshold
                END,
             DecreaseThreshold = CASE 
                                      WHEN NVL(v_DecreaseVal, 0) <> 0 THEN v_DecreaseVal
             ELSE DecreaseThreshold
                END;

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT ROWNUM() SRNO  ,
             LOCATION	,
                LOCATIONCODE	,
                MASTERNAMEALT_KEY	,
                THRESHOLDNAME	,
                MASTERALT_KEY	,
                MASTERNAME	,
                EFFECTIVEDT	,
                INCREASETHRESHOLD	,
                DECREASETHRESHOLD	,
                AUTHORISATIONSTATUS	,
                CRMODAPBY	,
                D2KTIMESTAMP	,
                CHANGEFIELDS	,
                ISMAINTABLE	
        FROM tt_DimThresholdMaster_3  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   DBMS_OUTPUT.PUT_LINE('reem');
   IF ( v_OperationFlag = 1 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE EXISTS ( SELECT 1 
                         FROM ALERT_RBL_MISDB_PROD.DimThresholdmaster 
                          WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                   AND EffectiveToTimeKey >= v_Timekey )
                                   AND MasterNameAlt_Key = v_MasterNameAlt_Key
                                   AND EffectiveDt = UTILS.CONVERT_TO_VARCHAR2(v_EffectiveDt,200,p_style=>103) );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         v_Flag := 'Y' ;

      END;
      END IF;

   END;
   END IF;
   OPEN  v_cursor FOR
      SELECT v_Flag ExistsData  ,
             'FlagData' TableName  
        FROM DUAL  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "MAIN_PRO";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT_DATA" TO "ADF_CDR_RBL_STGDB";
