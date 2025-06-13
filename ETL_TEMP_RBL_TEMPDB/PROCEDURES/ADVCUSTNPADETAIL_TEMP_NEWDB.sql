--------------------------------------------------------
--  DDL for Procedure ADVCUSTNPADETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" 
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
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TEMPAdvCustNPADetail ';
   /*INSERT ALL NPA CUSTOMERS DATA IN ADVCUSTNPADETAIL TABLE */
   INSERT INTO TempAdvCustNPAdetail
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
              JOIN TempCustomerBasicDetail B   ON A.CustomerID = B.CustomerId
              JOIN ( SELECT CustomerID ,
                            AssetClassCode ,
                            MIN(NPADate)  NPADate  
                     FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM01_STG 
                       GROUP BY CustomerID,AssetClassCode ) AC   ON A.CustomerID = AC.CustomerID
              JOIN RBL_MISDB_010922_UAT.DimAssetClassMapping C   ON ( C.EffectiveFromTimeKey <= 49999
              AND C.EffectiveToTimeKey >= 49999 )
              AND AC.AssetClassCode = C.SrcSysClassCode
              AND NVL(C.AssetClassShortNameEnum, 'STD') <> 'STD'
              AND C.SourceAlt_Key = 1 );/*
   UNION 

   -----------------INDUS-------------------------------

   			SELECT 
   					B.CustomerEntityId
   					,C.AssetClassAlt_Key Cust_AssetClassAlt_Key
   					,A.NPADATE AS  NPADt
   					,NULL LastInttChargedDt
   					,(Case When C.AssetClassSubGroup='DOUBTFUL' then A.DBT_LOS_Date Else Null End) DbtDt
   					,(Case When C.AssetClassSubGroup='LOSS' then A.DBT_LOS_Date Else Null End) LosDt
   					,NULL DefaultReason1Alt_Key
   					,NULL DefaultReason2Alt_Key
   					,NULL StaffAccountability
   					,NULL LastIntBooked
   					,A.CustomerId RefCustomerID
   					,NULL AuthorisationStatus
   					,@vEffectivefrom EffectiveFromTimeKey
   					,49999 EffectiveToTimeKey
   					,'SSISUSER' CreatedBy
   					,GETDATE() DateCreated
   					,NULL ModifiedBy
   					,NULL DateModified
   					,NULL ApprovedBy
   					,NULL DateApproved
   					,NULL MocStatus
   					,NULL MocDate
   					,NULL MocTypeAlt_Key
   					--,NULL WillfulDefault
   					--,NULL WillfulDefaultReasonAlt_Key
   					--,NULL WillfulRemark
   					--,NULL WillfulDefaultDate
   					,NULL NPA_Reason
   		FROM RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM02_STG A
   		    INNER JOIN TempCustomerBasicDetail B
   			on A.CustomerID=B.CustomerId  
   			INNER JOIN RBL_MISDB_010922_UAT.dbo.DimAssetClass C
   				ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
   				AND A.AssetClass=C.SrcSysClassCode
   				AND ISNULL(C.AssetClassShortNameEnum,'STD')<>'STD'


   UNION 

   -------------------------------ECBF ------------------------------

   			SELECT 
   					B.CustomerEntityId
   					,C.AssetClassAlt_Key Cust_AssetClassAlt_Key
   					,A.NPADATE AS  NPADt
   					,NULL LastInttChargedDt
   					,(Case When C.AssetClassSubGroup='DOUBTFUL' then A.DBT_LOS_Date Else Null End) DbtDt
   					,(Case When C.AssetClassSubGroup='LOSS' then A.DBT_LOS_Date Else Null End) LosDt
   					,NULL DefaultReason1Alt_Key
   					,NULL DefaultReason2Alt_Key
   					,NULL StaffAccountability
   					,NULL LastIntBooked
   					,A.CustomerId RefCustomerID
   					,NULL AuthorisationStatus
   					,@vEffectivefrom EffectiveFromTimeKey
   					,49999 EffectiveToTimeKey
   					,'SSISUSER' CreatedBy
   					,GETDATE() DateCreated
   					,NULL ModifiedBy
   					,NULL DateModified
   					,NULL ApprovedBy
   					,NULL DateApproved
   					,NULL MocStatus
   					,NULL MocDate
   					,NULL MocTypeAlt_Key
   					--,NULL WillfulDefault
   					--,NULL WillfulDefaultReasonAlt_Key
   					--,NULL WillfulRemark
   					--,NULL WillfulDefaultDate
   					,NULL NPA_Reason
   		FROM RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM03_STG A
   		    INNER JOIN TempCustomerBasicDetail B
   			on A.CustomerID=B.CustomerId  
   			INNER JOIN RBL_MISDB_010922_UAT.dbo.DimAssetClass C
   				ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
   				AND A.AssetClass=C.SrcSysClassCode
   				AND ISNULL(C.AssetClassShortNameEnum,'STD')<>'STD'

   UNION

   ------------------------MIFIN

   			SELECT 
   					B.CustomerEntityId
   					,C.AssetClassAlt_Key Cust_AssetClassAlt_Key
   					,A.NPADATE AS  NPADt
   					,NULL LastInttChargedDt
   					,(Case When C.AssetClassSubGroup='DOUBTFUL' then A.DBT_LOS_Date Else Null End) DbtDt
   					,(Case When C.AssetClassSubGroup='LOSS' then A.DBT_LOS_Date Else Null End) LosDt
   					,NULL DefaultReason1Alt_Key
   					,NULL DefaultReason2Alt_Key
   					,NULL StaffAccountability
   					,NULL LastIntBooked
   					,A.CustomerId RefCustomerID
   					,NULL AuthorisationStatus
   					,@vEffectivefrom EffectiveFromTimeKey
   					,49999 EffectiveToTimeKey
   					,'SSISUSER' CreatedBy
   					,GETDATE() DateCreated
   					,NULL ModifiedBy
   					,NULL DateModified
   					,NULL ApprovedBy
   					,NULL DateApproved
   					,NULL MocStatus
   					,NULL MocDate
   					,NULL MocTypeAlt_Key
   					--,NULL WillfulDefault
   					--,NULL WillfulDefaultReasonAlt_Key
   					--,NULL WillfulRemark
   					--,NULL WillfulDefaultDate
   					,NULL NPA_Reason
   		FROM RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM04_STG A
   		    INNER JOIN TempCustomerBasicDetail B
   			on A.CustomerID=B.CustomerId  
   			INNER JOIN RBL_MISDB_010922_UAT.dbo.DimAssetClass C
   				ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
   				AND A.AssetClass=C.SrcSysClassCode
   				AND ISNULL(C.AssetClassShortNameEnum,'STD')<>'STD'

   UNION

   ---------------------------------GANASEVA

   			SELECT 
   					B.CustomerEntityId
   					,C.AssetClassAlt_Key Cust_AssetClassAlt_Key
   					,A.NPADATE AS  NPADt
   					,NULL LastInttChargedDt
   					,(Case When C.AssetClassSubGroup='DOUBTFUL' then A.DBT_LOS_Date Else Null End) DbtDt
   					,(Case When C.AssetClassSubGroup='LOSS' then A.DBT_LOS_Date Else Null End) LosDt
   					,NULL DefaultReason1Alt_Key
   					,NULL DefaultReason2Alt_Key
   					,NULL StaffAccountability
   					,NULL LastIntBooked
   					,A.CustomerId RefCustomerID
   					,NULL AuthorisationStatus
   					,@vEffectivefrom EffectiveFromTimeKey
   					,49999 EffectiveToTimeKey
   					,'SSISUSER' CreatedBy
   					,GETDATE() DateCreated
   					,NULL ModifiedBy
   					,NULL DateModified
   					,NULL ApprovedBy
   					,NULL DateApproved
   					,NULL MocStatus
   					,NULL MocDate
   					,NULL MocTypeAlt_Key
   					--,NULL WillfulDefault
   					--,NULL WillfulDefaultReasonAlt_Key
   					--,NULL WillfulRemark
   					--,NULL WillfulDefaultDate
   					,NULL NPA_Reason
   		FROM RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM05_STG A
   		    INNER JOIN TempCustomerBasicDetail B
   			on A.CustomerID=B.CustomerId  
   			INNER JOIN RBL_MISDB_010922_UAT.dbo.DimAssetClass C
   				ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
   				AND A.AssetClass=C.SrcSysClassCode
   				AND ISNULL(C.AssetClassShortNameEnum,'STD')<>'STD'

   UNION

   --------------------VISION PLUS

   			SELECT 
   					B.CustomerEntityId
   					,C.AssetClassAlt_Key Cust_AssetClassAlt_Key
   					,A.NPADATE AS  NPADt
   					,NULL LastInttChargedDt
   					,(Case When C.AssetClassSubGroup='DOUBTFUL' then A.DBT_LOS_Date Else Null End) DbtDt
   					,(Case When C.AssetClassSubGroup='LOSS' then A.DBT_LOS_Date Else Null End) LosDt
   					,NULL DefaultReason1Alt_Key
   					,NULL DefaultReason2Alt_Key
   					,NULL StaffAccountability
   					,NULL LastIntBooked
   					,A.CustomerId RefCustomerID
   					,NULL AuthorisationStatus
   					,@vEffectivefrom EffectiveFromTimeKey
   					,49999 EffectiveToTimeKey
   					,'SSISUSER' CreatedBy
   					,GETDATE() DateCreated
   					,NULL ModifiedBy
   					,NULL DateModified
   					,NULL ApprovedBy
   					,NULL DateApproved
   					,NULL MocStatus
   					,NULL MocDate
   					,NULL MocTypeAlt_Key
   					--,NULL WillfulDefault
   					--,NULL WillfulDefaultReasonAlt_Key
   					--,NULL WillfulRemark
   					--,NULL WillfulDefaultDate
   					,NULL NPA_Reason
   		FROM RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM06_STG A
   		    INNER JOIN TempCustomerBasicDetail B
   			on A.CustomerID=B.CustomerId  
   			INNER JOIN RBL_MISDB_010922_UAT.dbo.DimAssetClass C
   				ON (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)
   				AND A.AssetClass=C.SrcSysClassCode
   				AND ISNULL(C.AssetClassShortNameEnum,'STD')<>'STD'



   --UPDATE B SET B.Cust_AssetClassAlt_Key=A.Cust_AssetClassAlt_Key
   --            ,B.NPADt=A.NPADt
   --			,B.DbtDt=A.DbtDt   
   --			,B.LosDt=A.LosDt
   --FROM RBL_MISDB_010922_UAT.curdat.AdvCustNPAdetail A INNER JOIN AdvCustNPAdetail B ON A.CustomerEntityId=B.CustomerEntityID
   --AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY
   --AND B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY



   --

   --*****************************************************--
   --	UPDATE ASSET RELATED DATA IN RESPECTIVE TEMP TABLE --
   --*****************************************************--

   	--	UPDATE ASSET CLASS IN  TEMPDB BALANCEDETAIL TABLE --
   	UPDATE A
   		SET A.AssetClassAlt_Key=C.Cust_AssetClassAlt_Key
   	FROM TempAdVAcBalanceDetail A
   		INNER JOIN TempAdvAcBasicDetail B
   			ON A.AccountEntityId=B.AccountEntityId
   		INNER JOIN RBL_MISDB_010922_UAT.dbo.AdvCustNPAdetail C
   			ON C.REFCUSTOMERID=A.REFCUSTOMERID
   			where (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey) and B.ISLAD  is null

   	--	UPDATE ASSET CLASS IN  TEMPDB ADVACFINANCIALDETAIL TABLE --

   	UPDATE A
   		SET A.NpaDt=C.NpaDt
   	FROM TempAdvAcFinancialDetail A
   		INNER JOIN TempAdvAcBasicDetail B
   			ON A.AccountEntityId=B.AccountEntityId
   		INNER JOIN RBL_MISDB_010922_UAT.dbo.AdvCustNPAdetail C
   			ON C.REFCUSTOMERID=A.REFCUSTOMERID
   			where (C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey)

   --
   */

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ADVCUSTNPADETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
