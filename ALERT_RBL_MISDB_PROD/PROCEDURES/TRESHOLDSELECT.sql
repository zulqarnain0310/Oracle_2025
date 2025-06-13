--------------------------------------------------------
--  DDL for Procedure TRESHOLDSELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" 
-- =============================================
 -- Author:		<HAMID>
 -- Create date: <09 MAY 2019>
 -- Description:	<TO GET A  LIST OF Treshold Quick Serach>
 -- =============================================

(
  --DECLARE		
  v_Location IN CHAR DEFAULT 'HO' ,
  v_LocationCode IN VARCHAR2 DEFAULT '2' ,
  v_MasterNameAlt_Key IN NUMBER DEFAULT 2 ,
  v_MasterAlt_Key IN NUMBER DEFAULT 0 ,
  v_EffectiveDt IN VARCHAR2,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_Result OUT NUMBER,
  v_SQLQuery OUT VARCHAR2
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_MasterName VARCHAR2(100);
   v_CodeAlt_key VARCHAR2(100);
   v_CodeName VARCHAR2(100);
   v_Sql VARCHAR2(4000) := 'SELECT ' || v_CodeAlt_key || '  FROM ' || v_MasterName || LPAD(' ', 1, ' ') || ' WHERE EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,10) || ' AND EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,10);
   v_temp TT_CODE%ROWTYPE;
   cv_ins SYS_REFCURSOR;
   --SELECT @MasterName, @CodeAlt_key
   v_SqlModInner VARCHAR2(4000);
   --PRINT  @SQL
   v_SqlMod VARCHAR2(4000) := 'SELECT Threshold_SetId
   		,[Location]
   		,LocationCode
   		,A.MasterNameAlt_Key
   		,A.MasterAlt_Key
   		,EffectiveDt
   		,IncreaseThreshold
   		,DecreaseThreshold
   		,ISNULL(A.AuthorisationStatus,''A'') as AuthorisationStatus
   		,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
   		,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
   		,ChangeFields
   		,''N'' IsMainTable
   FROM ALERT.DimThresholdMaster_Mod A 
    INNER JOIN (' || LPAD(' ', 1, ' ') || v_SqlModInner || LPAD(' ', 1, ' ') || ')B 
    ON A.ThresHold_Key = B.ThresHold_Key';
   v_SqlMain VARCHAR2(4000);
   v_temp_1 INSERT%ROWTYPE;
   cv_ins_1 SYS_REFCURSOR;

BEGIN

   IF NVL(v_EffectiveDt, ' ') <> ' ' THEN

   BEGIN
      SELECT Timekey 

        INTO v_Timekey
        FROM SysDayMatrix 
       WHERE  DATE_ = UTILS.CONVERT_TO_VARCHAR2(v_EffectiveDt,200,p_style=>103);

   END;
   END IF;
   SELECT MasterName ,
          MstTablColAlt_key ,
          MstTablColName 

     INTO v_MasterName,
          v_CodeAlt_key,
          v_CodeName
     FROM ALERT_RBL_MISDB_PROD.DImMasterName 
    WHERE  EffectiveFromTimeKey <= v_Timekey
             AND EffectiveToTimeKey >= v_Timekey
             AND MasterNameAlt_Key = v_MasterNameAlt_Key;
   DELETE FROM tt_Code;
   --SELECT @Sql
   cv_ins := (EXECUTE IMMEDIATE v_Sql);
   LOOP
      FETCH cv_ins INTO v_temp;
      EXIT WHEN cv_ins%NOTFOUND;
      INSERT INTO tt_Code VALUES v_temp;
   END LOOP;
   CLOSE cv_ins;
   v_Sql := NULL ;
   v_SqlModInner := 'SELECT MasterNameAlt_Key, MasterAlt_Key, MAX(ThresHold_Key)ThresHold_Key   FROM ' || v_MasterName || ' M ' || 'INNER JOIN ALERT.DimThresholdMaster_Mod  A ON' || '  M.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,10) || ' AND M.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,10) || ' AND A.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,10) || ' AND A.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,10) || ' AND A.AuthorisationStatus IN (''NP'',''MP'',''DP'',''RM'')' || ' AND Location				= ' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_Location,2) || '''' || ' AND LocationCode			= ' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_LocationCode,10) || '''' || ' AND MasterNameAlt_Key	= ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,100) || ' AND MasterAlt_Key		= CASE WHEN ISNULL(' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || ',0)=0 THEN MasterAlt_Key ELSE ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || LPAD(' ', 1, ' ') || 'END' || ' INNER JOIN tt_Code ' || 'ON CODE = A.MasterAlt_Key' || ' GROUP BY MasterNameAlt_Key, MasterAlt_Key' ;
   DBMS_OUTPUT.PUT_LINE(v_SqlMod);
   IF v_OperationFlag <> 16 THEN

   BEGIN
      v_SqlMain := 'SELECT Threshold_SetId
      		,[Location]
      		,LocationCode
      		,A.MasterNameAlt_Key
      		,M.' || v_CodeAlt_key || '
      		,EffectiveDt
      		,IncreaseThreshold
      		,DecreaseThreshold 
      		,ISNULL(A.AuthorisationStatus,''A'') as AuthorisationStatus
      		,ISNULL(A.ModifiedBy,A.CreatedBy) CrModApBy
      		,CAST(A.D2Ktimestamp AS INT)D2Ktimestamp
      		,NULL ChangeFields
      		,''Y'' IsMainTable 
      		FROM ' || v_MasterName || LPAD(' ', 1, ' ') || 'M' ;
      v_SqlMain := v_SqlMain || ' INNER JOIN ALERT.DimThresholdMaster A 
      							ON  A.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND A.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
      							AND M.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND M.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
      							AND ISNULL(A.AuthorisationStatus,''A'')=''A''' || ' AND Location				= ' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_Location,2) || '''' || ' AND LocationCode			= ' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_LocationCode,10) || '''' || ' AND MasterNameAlt_Key	= ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,100) || +'AND M.' || v_CodeAlt_key || LPAD(' ', 1, ' ') || '=' || LPAD(' ', 1, ' ') || 'CASE WHEN ISNULL(' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || ',0)=0 THEN M.' || v_CodeAlt_key || ' ELSE ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || LPAD(' ', 1, ' ') || 'END' || ' AND  M.' || v_CodeAlt_key || LPAD(' ', 1, ' ') || '=' || LPAD(' ', 1, ' ') || 'A.MasterAlt_Key' || ' INNER JOIN tt_Code ' || 'ON CODE = M.' || v_CodeAlt_key || ' ' ;

   END;
   END IF;
   --SELECT @SqlMain
   IF v_OperationFlag <> 16 THEN

   BEGIN
      v_Sql := v_SqlMod || CHR(13) || 'UNION' || CHR(13) || v_SqlMain ;

   END;

   --SELECT @Sql
   ELSE

   BEGIN
      v_Sql := v_SqlMod ;

   END;
   END IF;
   IF utils.object_id('Tempdb..tt_DimThresholdMaster_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DimThresholdMaster_2 ';
   END IF;
   DELETE FROM tt_DimThresholdMaster_2;
   cv_ins := EXECUTE IMMEDIATE v_Sql;
   LOOP
      FETCH cv_ins INTO v_temp;
      EXIT WHEN cv_ins%NOTFOUND;
      INSERT INTO tt_DimThresholdMaster_2 VALUES v_temp;
   END LOOP;
   CLOSE cv_ins;
   v_Sql := NULL ;
   v_Sql := 'SELECT CASE WHEN ISNULL(Threshold_SetId,0)=0 THEN NULL ELSE Threshold_SetId END Threshold_SetId
   ,' || '''' || v_Location || '''' || ' Location
   ,' || '''' || v_LocationCode || '''' || ' LocationCode
   ,' || '''' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,5) || '''' || ' MasterNameAlt_Key
   ,M.ThresholdName
   ,A.' || v_CodeAlt_key || ' AS MasterAlt_Key
   ,C.' || v_CodeName || ' AS MasterName
   ,CONVERT(VARCHAR(10),CAST(EffectiveDt AS DATE),103)EffectiveDt
   ,ISNULL(IncreaseThreshold,0)	IncreaseThreshold
   ,ISNULL(DecreaseThreshold,0)	DecreaseThreshold
   ,B.AuthorisationStatus
   ,B.CrModApBy
   ,B.D2Ktimestamp
   ,B.ChangeFields
   ,B.IsMainTable
    FROM ' || v_MasterName ;
   --EXEC(@SQL)
   v_Sql := v_Sql || LPAD(' ', 1, ' ') || 'A' || CHR(13) || 'LEFT OUTER JOIN tt_DimThresholdMaster_2 B
   							ON A.' || v_CodeAlt_key || LPAD(' ', 1, ' ') || '=' || LPAD(' ', 1, ' ') || 'B.MasterAlt_Key' || CHR(10) || '
   							AND B.MasterAlt_Key		= CASE WHEN ISNULL(' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || ',0)=0 THEN B.MasterAlt_Key ELSE ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || LPAD(' ', 1, ' ') || 'END' || CHR(10) || 'LEFT OUTER JOIN ALERT.DImMasterName M
   							ON M.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND M.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   							AND M.MasterNameAlt_Key = ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterNameAlt_Key,2) || 'LEFT OUTER JOIN ' || v_MasterName || ' C' || LPAD(' ', 1, ' ') || 'ON C.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND C.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || '
   							AND C.' || v_CodeAlt_key || LPAD(' ', 1, ' ') || '=' || LPAD(' ', 1, ' ') || 'A.' || v_CodeAlt_key || ' WHERE A.EffectiveFromTimeKey <= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || ' AND A.EffectiveToTimeKey >= ' || UTILS.CONVERT_TO_VARCHAR2(v_Timekey,5) || 'AND A.' || v_CodeAlt_key || LPAD(' ', 1, ' ') || '=' || LPAD(' ', 1, ' ') || 'CASE WHEN ISNULL(' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || ',0)=0 THEN A.' || v_CodeAlt_key || ' ELSE ' || UTILS.CONVERT_TO_VARCHAR2(v_MasterAlt_Key,5) || LPAD(' ', 1, ' ') || 'END' ;
   --SELECT @Sql
   v_SQLQuery := v_Sql ;
   v_Result := 1 ;--SELECT @SQLQuery
   --EXEC(@Sql)

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "MAIN_PRO";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "MAIN_PRO";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ALERT_RBL_MISDB_PROD"."TRESHOLDSELECT" TO "ADF_CDR_RBL_STGDB";
