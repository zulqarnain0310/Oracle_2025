--------------------------------------------------------
--  DDL for Procedure ACCOUNTLVLCUSTOMERHISTORY_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" 
(
  v_AccountID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   OPEN  v_cursor FOR
      SELECT B.CustomerID ,
             B.CustomerName ,
             --,UCIC
             B.AssetClassAlt_Key ,
             D.AssetClassName ,
             B.NPADate ,
             B.SecurityValue ,
             B.AdditionalProvision ,
             --,B.FraudAccountFlagAlt_Key
             --,C.ParameterName as FraudAccountFlag
             --,B.FraudDate
             B.MOCTypeAlt_Key ,
             E.ParameterName MOCType  ,
             B.MOCSourceAltkey ,
             Y.MOCTypeName MOCSource  ,
             B.MOCReason ,
             B.MOCBy ,
             B.Level1ApprovedBy ,
             B.Level2ApprovedBy ,
             'CustomerPostMOCHistory' TableName  
        FROM AccountLevelMOC A
               JOIN AdvAcBasicDetail F   ON A.AccountID = F.CustomerACID
               JOIN CustomerLevelMOC B   ON B.CustomerEntityID = F.CustomerEntityID
               JOIN DimAssetClass D   ON B.AssetClassAlt_Key = D.AssetClassAlt_Key
               AND D.EffectiveFromTimeKey <= v_TimeKey
               AND D.EffectiveToTimeKey >= v_TimeKey
               JOIN ( 
                      --inner join(select ParameterAlt_Key,ParameterName,'Fraud' as Tablename

                      -- from DimParameter where DimParameterName='DimYesNo'

                      -- AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)C

                      -- ON B.FraudAccountFlagAlt_Key=C.ParameterAlt_Key
                      SELECT ParameterAlt_Key ,
                             ParameterName ,
                             'MOCType' Tablename  
                      FROM DimParameter 
                       WHERE  DimParameterName = 'MOCType'
                                AND EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey ) E   ON B.MOCTypeAlt_Key = E.ParameterAlt_Key
               JOIN ( SELECT MOCTypeAlt_Key ,
                             MOCTypeName ,
                             'MOCSource' Tablename  
                      FROM DimMOCType 
                       WHERE  EffectiveFromTimeKey <= v_Timekey
                                AND EffectiveToTimeKey >= v_Timekey ) Y   ON Y.MOCTypeAlt_Key = B.MOCSourceAltkey
       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND A.AccountID = v_AccountID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);-- select A.CustomerID
   --	   ,A.CustomerName
   --	   ,UCIC
   --	   ,B.AssetClassAlt_Key
   --	   ,D.AssetClassName
   --	   ,B.NPADate
   --	   ,B.SecurityValue
   --	   ,B.AdditionalProvision
   --	   ,B.FraudAccountFlagAlt_Key
   --	   ,C.ParameterName as FraudAccountFlag
   --	   ,B.FraudDate
   --	   ,B.MOCTypeAlt_Key
   --	   ,E.ParameterName as MOCType
   --	   ,B.MOCReason
   --	   ,B.MOCBy
   --	   ,B.Level1ApprovedBy
   --	   ,B.Level2ApprovedBy
   --	   ,'CustomerPreMOCHistory' TableName
   --	    from AccountLevelPreMOC A
   --inner join CustomerLevelPreMOC B
   --on A.CustomerID=B.CustomerID
   --inner join DimAssetClass D
   --on B.AssetClassAlt_Key=D.AssetClassAlt_Key
   --AND D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey
   --inner join(select ParameterAlt_Key,ParameterName,'Fraud' as Tablename
   -- from DimParameter where DimParameterName='DimYesNo'
   -- AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)C
   -- ON B.FraudAccountFlagAlt_Key=C.ParameterAlt_Key
   --inner join(select ParameterAlt_Key,ParameterName,'MOCType' as Tablename
   -- from DimParameter where DimParameterName='MOCType'
   -- AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)E
   -- ON B.MOCTypeAlt_Key=E.ParameterAlt_Key
   -- Where A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
   -- AND A.AccountID=@AccountID

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY_PROD" TO "ADF_CDR_RBL_STGDB";
