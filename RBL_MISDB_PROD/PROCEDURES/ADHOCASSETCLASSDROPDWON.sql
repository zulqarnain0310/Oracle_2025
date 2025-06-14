--------------------------------------------------------
--  DDL for Procedure ADHOCASSETCLASSDROPDWON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" 
--(If  SUB-STANDARD then NPA Date Mandatory , date format DD-MM-YYYY
 --(If DOUBTFUL I  then NPA Date Mandatory , date format DD-MM-YYYY
 --(If LOS then NPA Date Mandatory , date format DD-MM-YYYY
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================  
 -- Author:    <FARAHNAAZ>  Exec [CustomerLvlNPAMOCDropDown] @AssetClassAlt_Key=1
 -- Create date:   <05/04/2021>  
 -- Description:   <All DropDown Select Query for [CustomerLvlNPAMOCDropDown]
 -- =============================================  

AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--@AssetClassAlt_Key INT =0

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
   --IF (@OperationFlag IN(1,2,3,16,17,20))
   --BEGIN
   DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
   ACLProcessStatusCheck() ;
   --END
   --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 
   --  SET @EffectiveFromTimeKey  = @TimeKey
   --SET @EffectiveToTimeKey = @Timekey
   OPEN  v_cursor FOR
      SELECT DISTINCT ParameterAlt_Key MOCReasonAlt_Key  ,
                      ParameterName MOCReason  ,
                      'ChangeReason' Tablename  
        FROM DimParameter 
       WHERE  DimParameterName = 'DimMoRreason'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT AssetClassAlt_Key ,
             AssetClassName ,
             'AssetClass' Tablename  
        FROM DimAssetClass 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey
        ORDER BY AssetClassAlt_Key ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'ChangeType' Tablename  
        FROM DimParameter 
       WHERE  DimParameterName = 'MOCType'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ENTITYKEY,	MENUID,	SCREENNAME,	CTRLNAME,	RESOURCEKEY,	FLDDATATYPE,	COL_LG,	COL_MD,	COL_SM,	MINLENGTH,	MAXLENGTH,	ERRORCHECK,	DATASEQ,	FLDGRIDVIEW,	CRITICALERRORTYPE,	SCREENFIELDNO,	ISEDITABLE,	ISVISIBLE,	ISUPPER,	ISMANDATORY,	ALLOWCHAR,	DISALLOWCHAR,	DEFAULTVALUE,	ALLOWTOOLTIP,	REFERENCECOLUMNNAME,	REFERENCETABLENAME,	MOC_FLAG,	USERID,	CREATEDBY,	DATECREATED,	MODIFIEDBY,	DATEMODIFIED,	SCREENFIELDGROUP,	HIGHERLEVELEDIT,	APPLICABLEFORWORKFLOW,	ISEXTRACTEDEDITABLE,	ISMOCVISIBLE,
             'AdhocAssetClassChange' TableName  
        FROM MetaScreenFieldDetail 
       WHERE  ScreenName = 'AdhocAssetClassChange' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ADHOCASSETCLASSDROPDWON" TO "ADF_CDR_RBL_STGDB";
