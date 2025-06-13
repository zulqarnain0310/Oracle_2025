--------------------------------------------------------
--  DDL for Procedure ADVSECURITYVALUEDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   --------------------------------------------------------------------------------------------------------------------------------------------------- 
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAdvSecurityValueDetail ';
   INSERT INTO TempAdvSecurityValueDetail
     ( SecurityEntityID, ValuationSourceAlt_Key, ValuationDate, CurrentValue, ValuationExpiryDate, CollateralID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, SecurityValueMain, SecurityValueErosion )
     ( 
       -------------    mifin  ---------
       SELECT C.SecurityEntityID ,
              NULL ValuationSourceAlt_Key  ,
              A.ValuationDate ,
              A.SecurityValue CurrentValue  ,
              A.ValuationExpiryDate ,
              a.CollateralID ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              a.SecurityValue SecurityValueMain  ,
              a.SecurityValue SecurityValueErosion  
       FROM RBL_STGDB.Security_All_Source_System A
              JOIN TempAdvAcBasicDetail B   ON A.AccountID = B.CustomerAcid
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              JOIN TempAdvSecurityDetail C   ON C.AccountEntityID = B.AccountEntityID
              AND A.CollateralID = C.CollateralID
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
              AND C.SecurityType = 'P'
       UNION 

       ----finacle
       SELECT C.SecurityEntityID ,
              NULL ValuationSourceAlt_Key  ,
              A.ValuationDate ,
              A.SecValue_Final CurrentValue  ,
              A.ValuationExpiryDate_New ,
              a.COLLATERALID ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              MainSecurityValue SecurityValueMain  ,
              MainSecurityValue SecurityValueErosion  
       FROM RBL_STGDB.FINACLE_COLLATERAL_DATA A
              JOIN TempCustomerBasicDetail B   ON A.CUSTOMER_ID = B.CUSTOMERID
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              JOIN TempAdvSecurityDetail C   ON C.CustomerEntityID = B.CustomerEntityID
              AND A.CollateralID = C.CollateralID
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
              AND C.SecurityType = 'C'
       UNION ALL 
       SELECT C.SecurityEntityID ,
              NULL ValuationSourceAlt_Key  ,
              A.ValuationDate ,
              A.apportioned_value CurrentValue  ,
              A.ValuationExpiryDate ,
              a.COLLATERALID ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              SecurityValue SecurityValueMain  ,
              SecurityValue SecurityValueErosion  
       FROM RBL_STGDB.Finacle_ODFD_DATA A
              JOIN TempAdvAcBasicDetail B   ON A.CustomerAcID = B.CustomerAcID
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              JOIN TempAdvSecurityDetail C   ON C.CustomerEntityID = B.CustomerEntityID
              AND A.CollateralID = C.CollateralID
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
              AND b.ACCOUNTENTITYID = c.AccountEntityId
              AND C.SecurityType = 'P' );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVSECURITYVALUEDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
