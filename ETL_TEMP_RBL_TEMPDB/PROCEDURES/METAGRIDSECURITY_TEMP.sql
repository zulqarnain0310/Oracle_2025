--------------------------------------------------------
--  DDL for Procedure METAGRIDSECURITY_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" 
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
   v_DATE VARCHAR2(200) ;
   --GO
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_MetagridEntityId NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempmetagridSecurity ';
   INSERT INTO RBL_TEMPDB.TempmetagridSecurity
     ( Date_of_Data, Source_System_Name, Customer_ID, Account_ID, Security_ID, Collateral_Type, Security_Code, Charge_Type_Code, Security_Value, Valuation_Source, Valuation_date, Valuation_expiry_date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
     ( SELECT Date_of_Data ,
              Source_System_Name ,
              Customer_ID ,
              Account_ID ,
              Security_ID ,
              Collateral_Type ,
              Security_Code ,
              Charge_Type_Code ,
              Security_Value ,
              Valuation_Source ,
              Valuation_date ,
              Valuation_expiry_date ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  
       FROM RBL_STGDB.metagrid_Security_STG A );
   /*********************************************************************************************************/
   /*  Existing Customers Customer Entity ID Update  */
   MERGE INTO RBL_TEMPDB.TempmetagridSecurity TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.MetagridEntityId
   FROM RBL_TEMPDB.TempmetagridSecurity TEMP
          JOIN RBL_MISDB_PROD.metagridSecurity MAIN   ON TEMP.Account_ID = MAIN.Account_ID 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.MetagridEntityId = src.MetagridEntityId;
   SELECT MAX(MetagridEntityId)  

     INTO v_MetagridEntityId
     FROM RBL_MISDB_PROD.metagridSecurity ;
   IF v_MetagridEntityId IS NULL THEN

   BEGIN
      v_MetagridEntityId := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempmetagridSecurity TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.MetagridEntityId
   FROM RBL_TEMPDB.TempmetagridSecurity TEMP
          JOIN ( SELECT A.Account_ID ,
                        (v_MetagridEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                               FROM DUAL  )  )) MetagridEntityId  
                 FROM RBL_TEMPDB.TempmetagridSecurity A
                  WHERE  A.MetagridEntityId = 0
                           OR A.MetagridEntityId IS NULL ) ACCT   ON TEMP.Account_ID = ACCT.Account_ID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.MetagridEntityId = src.MetagridEntityId;--------------------------------------------------

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."METAGRIDSECURITY_TEMP" TO "ADF_CDR_RBL_STGDB";
