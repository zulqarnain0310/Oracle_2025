--------------------------------------------------------
--  DDL for Procedure FRAUD_DOWNLOADDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" 
(
  iv_Timekey IN NUMBER,
  v_UserLoginId IN VARCHAR2,
  v_ExcelUploadId IN NUMBER,
  v_UploadType IN VARCHAR2
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
--,@Page SMALLINT =1     
--   ,@perPage INT = 30000   
----DECLARE @Timekey INT=49999
----	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
----	,@ExcelUploadId INT=4
----	,@UploadType VARCHAR(50)='Interest reversal'

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   --DECLARE @PageFrom INT, @PageTo INT   
   --SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
   --SET @PageTo = @perPage*@Page  
   IF ( v_UploadType = 'Fraud Upload' ) THEN

   BEGIN
      --SELECT * FROM(
      OPEN  v_cursor FOR
         SELECT A.RefCustomerACID ,
                'Details' TableName  ,
                UploadID ,
                SrNo ,
                AccountEntityId ,
                CustomerEntityId ,
                RefCustomerID ,
                D.ParameterName RFA_Reported_By_Bank  ,
                RFA_DateReportingByBank ,
                E.ParameterName Name_of_Other_Banks_Reporting_RFA  ,
                RFA_OtherBankDate ,
                FraudOccuranceDate ,
                FraudDeclarationDate ,
                FraudNature ,
                FraudArea ,
                CurrentAssetClassAltKey ,
                F.ParameterName Provision_Proference  
           FROM Fraud_Details_Mod A
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     CASE 
                                          WHEN ParameterName = 'NO' THEN 'N'
                                     ELSE 'Y'
                                        END ParameterName  ,
                                     'RFA_Reported_By_Bank' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'DimYesNo'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.RFA_ReportingByBank = D.ParameterAlt_Key
                  LEFT JOIN ( SELECT BankRPAlt_Key ParameterAlt_Key  ,
                                     BankName ParameterName  ,
                                     'Name_of_Other_Banks_Reporting_RFA' Tablename  
                              FROM DimBankRP 
                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.RFA_OtherBankAltKey = E.ParameterAlt_Key
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     ParameterName ,
                                     'Provision_Proference' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'DimProvisionPreference'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) F   ON A.ProvPref = F.ParameterAlt_Key
          WHERE  UploadId = v_ExcelUploadId
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_DOWNLOADDATA" TO "ADF_CDR_RBL_STGDB";
