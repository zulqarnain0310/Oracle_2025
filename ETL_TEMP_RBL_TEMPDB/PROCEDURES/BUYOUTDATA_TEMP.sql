--------------------------------------------------------
--  DDL for Procedure BUYOUTDATA_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" 
-- =============================================
 -- Author:		MANDEEP SINGH
 -- Create date: 26-08-2022
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
   ---------------------------------------------------------------------------------------------------------------------------------------------
   -------------Added by Prashant---05-08-2024---------------
   v_DATE1 VARCHAR2(200) ;
-- Add the parameters for the stored procedure here

BEGIN
   SELECT Date_ INTO v_DATE
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y' ;

   -------------Added by Prashant---05-08-2024---------------
   SELECT UTILS.CONVERT_TO_VARCHAR2(Date_ - 1,200) INTO v_DATE1 
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
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_STGDB.BUYOUTDATA_STG ';
   INSERT INTO RBL_STGDB.BUYOUTDATA_STG
     ( Vendor_Account_No, Vendor_Account_NPA_Date, Vendor_Account_DPD, Account_Report_Date )
     ( SELECT Vendor_Account_No ,
              Vendor_Account_NPA_Date ,
              Vendor_Account_DPD ,
              Account_Report_Date 
       FROM RBL_STGDB.BUYOUTDATA_STG_Hist 
        WHERE  UTILS.CONVERT_TO_VARCHAR2(CreatedDate,200) = v_DATE1 );
   --------------------------------------------------------------------------------------------------------------------------------------------------- 
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempBuyoutData ';
   INSERT INTO RBL_TEMPDB.TempBuyoutData
     ( DateofData, ReportDate, AccountEntityId, SchemeCode, NPA_ClassSeller, NPA_DateSeller, DPD_Seller, PeakDPD, PeakDPD_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, NPA_DueToMainAdv, NPA_EffectedToMainAdv, IsChanged, NPA_Flag, RBL_Account_No, Seller_Account_No )
     ( 
       -------------    FINACLE  ---------
       SELECT A.Account_Report_Date DateofData  ,
              A.Account_Report_Date ReportDate  ,
              0 AccountEntityId  ,
              NULL SchemeCode  ,
              NULL NPA_ClassSeller  ,
              Vendor_Account_NPA_Date NPA_DateSeller  ,
              Vendor_Account_DPD DPD_Seller  ,
              NULL PeakDPD  ,
              NULL PeakDPD_Date  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              NULL NPA_DueToMainAdv  ,
              NULL NPA_EffectedToMainAdv  ,
              NULL IsChanged  ,
              NULL NPA_Flag  ,
              NULL RBL_Account_No  ,
              A.Vendor_Account_No Seller_Account_No  

       --   'SSISUSER' CreatedBy

       --,GETDATE() DateCreated

       --,NULL ModifiedBy

       --,NULL DateModified

       --,NULL ApprovedBy

       --,NULL DateApproved

       --,NULL D2Ktimestamp

       --,NULL MocStatus

       --,NULL MocDate

       --,NULL MocTypeAlt_Key
       FROM RBL_STGDB.BUYOUTDATA_STG A );
   /*********************************************************************************************************/
   /*  Existing RBL_Account_No  Update  */
   MERGE INTO RBL_TEMPDB.TempBuyoutData TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.AccountNoinRBLHostSystem, ADVAC.AccountEntityId, MAIN.SchemeCode
   FROM RBL_TEMPDB.TempBuyoutData TEMP
          JOIN RBL_MISDB_PROD.BuyoutMapperUpload MAIN   ON TEMP.Seller_Account_No = MAIN.AccountNoofSeller
          AND MAIN.EffectiveFromTimeKey <= v_TimeKey
          AND MAIN.EffectiveToTimeKey >= v_TimeKey
          JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail ADVAC   ON ADVAC.CustomerACID = MAIN.AccountNoinRBLHostSystem
          AND ADVAC.EffectiveFromTimeKey <= v_TimeKey
          AND ADVAC.EffectiveToTimeKey >= v_TimeKey ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.RBL_Account_No = src.AccountNoinRBLHostSystem,
                                TEMP.AccountEntityId = src.AccountEntityId,
                                TEMP.SchemeCode = src.SchemeCode;--Truncate table RBL_STGDB.[dbo].[BUYOUTDATA_STG] --Added by Prashant---05082024--This query has been commented---
   
EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."BUYOUTDATA_TEMP" TO "ADF_CDR_RBL_STGDB";
