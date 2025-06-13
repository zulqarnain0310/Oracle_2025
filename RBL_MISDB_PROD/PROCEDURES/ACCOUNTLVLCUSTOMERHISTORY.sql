--------------------------------------------------------
--  DDL for Procedure ACCOUNTLVLCUSTOMERHISTORY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_AccountID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  MOC_Initialised = 'Y'
             AND NVL(MOC_Frozen, 'N') = 'N';
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
        FROM AccountLevelMOC_Mod A
               JOIN AdvAcBasicDetail F   ON A.AccountID = F.CustomerACID
               JOIN CustomerLevelMOC_Mod B   ON B.CustomerEntityID = F.CustomerEntityID
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCOUNTLVLCUSTOMERHISTORY" TO "ADF_CDR_RBL_STGDB";
