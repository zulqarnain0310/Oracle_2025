--------------------------------------------------------
--  DDL for Procedure PROJ_CATEGORY_PUI
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" 
AS
   --@ProjectId INT
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --Declare @ProjectId int=1
   OPEN  v_cursor FOR
      SELECT ProjectCategoryDescription ,
             ProjectCategoryAltKey ,
             'ProjectCategory' TableName  
        FROM ProjectCategory PC
       WHERE  PC.EffectiveFromTimeKey <= v_Timekey
                AND PC.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --And ProjectCategoryAltKey=@ProjectId
   --Project Authority Dropdown
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'ProjectAuthority' TableName  
        FROM DimParameter D
       WHERE  dimparametername = 'ProjectAuthority'
                AND D.EffectiveFromTimeKey <= v_Timekey
                AND D.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   -- Project Ownership
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'ProjectOwnership' TableName  
        FROM DimParameter D
       WHERE  dimparametername = 'ProjectOwnership'
                AND D.EffectiveFromTimeKey <= v_Timekey
                AND D.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --Yes NO
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'ChangeinProjectScope' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DIMYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'CourtCaseArbitration' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DIMYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'CIO' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DIMYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'CostOverrun' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DIMYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'TakeOutFinance' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DIMYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'Restructuring' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DIMYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'AssetclassinSellersbook' TableName  
        FROM DimParameter 
       WHERE  dimparametername LIKE '%Assetclass%'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'InitialExtenstion' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DimYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT ParameterAlt_Key ,
             ParameterName ,
             'ExtnReason_BCP' TableName  
        FROM DimParameter 
       WHERE  dimparametername = 'DimYN'
                AND EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   OPEN  v_cursor FOR
      SELECT AssetClassAlt_Key ,
             AssetClassName ,
             'AssetClass' TableName  
        FROM DimAssetClass 
       WHERE  EffectiveFromTimeKey <= v_Timekey
                AND EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROJ_CATEGORY_PUI" TO "ADF_CDR_RBL_STGDB";
