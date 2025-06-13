--------------------------------------------------------
--  DDL for Procedure ADVCUSTNPADETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" 
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
   EXECUTE IMMEDIATE ' DELETE FROM RBL_TEMPDB.TEMPAdvCustNPADetail ';
   /*INSERT ALL NPA CUSTOMERS DATA IN ADVCUSTNPADETAIL TABLE */
   INSERT INTO RBL_TEMPDB.TEMPAdvCustNPADetail
     ( CustomerEntityId, Cust_AssetClassAlt_Key, NPADt, LastInttChargedDt, DbtDt, LosDt, DefaultReason1Alt_Key, DefaultReason2Alt_Key, StaffAccountability, LastIntBooked, RefCustomerID, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, MocStatus, MocDate, MocTypeAlt_Key
   --,WillfulDefault
    --,WillfulDefaultReasonAlt_Key
    --,WillfulRemark
    --,WillfulDefaultDate
   , NPA_Reason )
     ( 
       -------------------------FINACLE---------------------------
       SELECT B.CustomerEntityId ,
              C.AssetClassAlt_Key Cust_AssetClassAlt_Key  ,
              AC.NPADATE NPADt  ,
              NULL LastInttChargedDt  ,
              (CASE 
                    WHEN C.AssetClassSubGroup = 'DOUBTFUL' THEN A.DBT_LOS_Date
              ELSE NULL
                 END) DbtDt  ,
              (CASE 
                    WHEN C.AssetClassSubGroup = 'LOSS' THEN A.DBT_LOS_Date
              ELSE NULL
                 END) LosDt  ,
              NULL DefaultReason1Alt_Key  ,
              NULL DefaultReason2Alt_Key  ,
              NULL StaffAccountability  ,
              NULL LastIntBooked  ,
              A.CustomerId RefCustomerID  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              NULL MocTypeAlt_Key  ,
              --,NULL WillfulDefault
              --,NULL WillfulDefaultReasonAlt_Key
              --,NULL WillfulRemark
              --,NULL WillfulDefaultDate
              NULL NPA_Reason  

       --select * from rBL_MISDB.dbo.DimAssetClassMapping
       FROM RBL_STGDB.CUSTOMER_ALL_SOURCE_SYSTEM A
              JOIN RBL_TEMPDB.TempCustomerBasicDetail B   ON A.CustomerID = B.CustomerId
              JOIN ( SELECT CustomerID ,
                            AssetClassCode ,
                            MIN(NPADate)  NPADate  
                     FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM01_STG 
                       GROUP BY CustomerID,AssetClassCode ) AC   ON A.CustomerID = AC.CustomerID
              JOIN RBL_MISDB_PROD.DimAssetClassMapping C   ON ( C.EffectiveFromTimeKey <= 49999
              AND C.EffectiveToTimeKey >= 49999 )
              AND AC.AssetClassCode = C.SrcSysClassCode
              AND NVL(C.AssetClassShortNameEnum, 'STD') <> 'STD' );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
