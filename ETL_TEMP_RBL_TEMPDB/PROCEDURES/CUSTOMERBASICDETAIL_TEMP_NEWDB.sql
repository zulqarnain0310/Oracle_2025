--------------------------------------------------------
--  DDL for Procedure CUSTOMERBASICDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) := ( SELECT Date_ 
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_CustomerEntityId NUMBER(10,0) := 0;
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_UcifEntityID NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempCustomerBasicDetail ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   --------------------------------------------------------------------------------------------------------------------------------------------------- 
   INSERT INTO TempCustomerBasicDetail
     ( CustomerEntityId, CustomerId, D2kCustomerid, ParentBranchCode, CustomerName, CustomerInitial, CustomerSinceDt
   --,ConsentObtained
   , ConstitutionAlt_Key, OccupationAlt_Key, ReligionAlt_Key, CasteAlt_Key, FarmerCatAlt_Key, GaurdianSalutationAlt_Key, GaurdianName, GuardianType, CustSalutationAlt_Key, MaritalStatusAlt_Key
   --,DegUpgFlag
    --,ProcessingFlag
    --,MOCLock
    --,MoveNpaDt
   , AssetClass, BIITransactionCode, D2K_REF_NO
   --,CustomerNameBackup
    --,ScrCrErrorBackup
   , ScrCrError, ReferenceAcNo, CustCRM_RatingAlt_Key, CustCRM_RatingDt, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, D2Ktimestamp, FLAG, MocStatus, MocDate
   --,BaselProcessing
   , MocTypeAlt_Key, CommonMocTypeAlt_Key, LandHolding, ScrCrErrorSeq
   --,CustType
    --,ServProviderAlt_Key
    --,NonCustTypeAlt_Key
   , Remark, UCIF_ID, SourceSystemAlt_Key )
     ( 
       ------------------------FINACLE SYSTEM DATA----------------------
       SELECT 0 CustomerEntityId  ,
              C.CustomerId CustomerId  ,
              C.CustomerId D2kCustomerid  ,
              NULL ParentBranchCode  ,
              LTRIM(C.CustomerName) CustomerName  ,
              NULL CustomerInitial  ,
              NULL CustomerSinceDt ,---DAO

              --,'Y' AS ConsentObtained
              0 ConstitutionAlt_Key ,---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 

              0 OccupationAlt_Key ,---OCC  (master  UTBLOC)

              0 ReligionAlt_Key  ,
              0 CasteAlt_Key  ,
              0 FarmerCatAlt_Key  ,
              NULL GaurdianSalutationAlt_Key  ,
              NULL GaurdianName  ,
              NULL GuardianType  ,
              0 CustSalutationAlt_Key  ,
              0 MaritalStatusAlt_Key  ,
              --,NULL AS DegUpgFlag
              --,0 AS ProcessingFlag
              --,NULL AS MOCLock
              --,NULL AS MoveNpaDt
              NULL AssetClass  ,
              NULL BIITransactionCode  ,
              NULL D2K_REF_NO  ,
              --,NULL AS CustomerNameBackup
              --,NULL AS ScrCrErrorBackup
              NULL ScrCrError  ,
              NULL ReferenceAcNo  ,
              NULL CustCRM_RatingAlt_Key  ,
              NULL CustCRM_RatingDt  ,
              NULL AuthorisationStatus  ,
              v_VEFFECTIVEFROM EFFECTIVEFROMTIMEKEY  ,
              49999 EFFECTIVETOTIMEKEY  ,
              'SSISUSER' ASCREATEDBY  ,
              SYSDATE DATECREATED  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL D2Ktimestamp  ,
              NULL FLAG  ,
              NULL MocStatus  ,
              NULL MocDate  ,
              --,NULL AS BaselProcessing
              NULL MocTypeAlt_Key  ,
              NULL CommonMocTypeAlt_Key  ,
              NULL LandHolding  ,
              NULL ScrCrErrorSeq  ,
              --,NULL AS CustType
              --,NULL AS ServProviderAlt_Key
              --,NULL AS NonCustTypeAlt_Key
              NULL Remark  ,
              UCIC_ID ,
              S.SourceAlt_Key 
       FROM RBL_STGDB.CUSTOMER_ALL_SOURCE_SYSTEM C --first used this table

              JOIN ( SELECT DISTINCT REFCUSTOMERID 
                     FROM TempAdvAcBasicDetail  ) ACBD   ON C.CUSTOMERID = ACBD.REFCUSTOMERID
              LEFT JOIN RBL_MISDB_010922_UAT.DIMSOURCEDB S   ON S.SourceName = C.SourceSystem
              AND S.EffectiveToTimeKey = 49999 );
   /*LEFT
   UNION


   ------------------------INDUS SYSTEM DATA----------------------

     SELECT 
   			 0 AS  CustomerEntityId
   			,C.CustomerId AS CustomerId
   			,C.CustomerId AS D2kCustomerid
   			,NULL AS ParentBranchCode
   			,LTRIM(C.CustomerName) AS CustomerName
   			,NULL AS CustomerInitial
   			,NULL AS CustomerSinceDt---DAO
   			--,'Y' AS ConsentObtained
   			,0 AS ConstitutionAlt_Key  ---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 
   			,0 AS OccupationAlt_Key  ---OCC  (master  UTBLOC)
   			,0 AS ReligionAlt_Key
   			,0 AS CasteAlt_Key
   			,0 AS FarmerCatAlt_Key
   			,NULL AS GaurdianSalutationAlt_Key
   			,NULL AS GaurdianName
   			,NULL AS GuardianType
   			,0 AS CustSalutationAlt_Key
   			,0 AS MaritalStatusAlt_Key
   			--,NULL AS DegUpgFlag
   			--,0 AS ProcessingFlag
   			--,NULL AS MOCLock
   			--,NULL AS MoveNpaDt
   			,NULL AS AssetClass
   			,NULL AS BIITransactionCode
   			,NULL AS D2K_REF_NO
   			--,NULL AS CustomerNameBackup
   			--,NULL AS ScrCrErrorBackup
   			,NULL AS ScrCrError
   			,NULL AS ReferenceAcNo
   			,NULL AS CustCRM_RatingAlt_Key
   			,NULL AS CustCRM_RatingDt
   			,NULL AS AuthorisationStatus
   			,@VEFFECTIVEFROM AS EFFECTIVEFROMTIMEKEY
   			,49999 AS EFFECTIVETOTIMEKEY
   			,'SSISUSER' ASCREATEDBY
   			,GETDATE() AS DATECREATED
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS FLAG
   			,NULL AS MocStatus
   			,NULL AS MocDate
   			--,NULL AS BaselProcessing
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CommonMocTypeAlt_Key
   			,NULL AS LandHolding
   			,NULL AS ScrCrErrorSeq
   			--,NULL AS CustType
   			--,NULL AS ServProviderAlt_Key
   			--,NULL AS NonCustTypeAlt_Key
   			,NULL AS Remark

   			FROM  RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM02_STG C  --first used this table
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

   UNION 


   ------------------------ECBF SYSTEM DATA----------------------

     SELECT 
   			 0 AS  CustomerEntityId
   			,C.CustomerId AS CustomerId
   			,C.CustomerId AS D2kCustomerid
   			,NULL AS ParentBranchCode
   			,LTRIM(C.CustomerName) AS CustomerName
   			,NULL AS CustomerInitial
   			,NULL AS CustomerSinceDt---DAO
   			--,'Y' AS ConsentObtained
   			,0 AS ConstitutionAlt_Key  ---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 
   			,0 AS OccupationAlt_Key  ---OCC  (master  UTBLOC)
   			,0 AS ReligionAlt_Key
   			,0 AS CasteAlt_Key
   			,0 AS FarmerCatAlt_Key
   			,NULL AS GaurdianSalutationAlt_Key
   			,NULL AS GaurdianName
   			,NULL AS GuardianType
   			,0 AS CustSalutationAlt_Key
   			,0 AS MaritalStatusAlt_Key
   			--,NULL AS DegUpgFlag
   			--,0 AS ProcessingFlag
   			--,NULL AS MOCLock
   			--,NULL AS MoveNpaDt
   			,NULL AS AssetClass
   			,NULL AS BIITransactionCode
   			,NULL AS D2K_REF_NO
   			--,NULL AS CustomerNameBackup
   			--,NULL AS ScrCrErrorBackup
   			,NULL AS ScrCrError
   			,NULL AS ReferenceAcNo
   			,NULL AS CustCRM_RatingAlt_Key
   			,NULL AS CustCRM_RatingDt
   			,NULL AS AuthorisationStatus
   			,@VEFFECTIVEFROM AS EFFECTIVEFROMTIMEKEY
   			,49999 AS EFFECTIVETOTIMEKEY
   			,'SSISUSER' ASCREATEDBY
   			,GETDATE() AS DATECREATED
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS FLAG
   			,NULL AS MocStatus
   			,NULL AS MocDate
   			--,NULL AS BaselProcessing
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CommonMocTypeAlt_Key
   			,NULL AS LandHolding
   			,NULL AS ScrCrErrorSeq
   			--,NULL AS CustType
   			--,NULL AS ServProviderAlt_Key
   			--,NULL AS NonCustTypeAlt_Key
   			,NULL AS Remark

   			FROM  RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM03_STG C  --first used this table
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

   UNION


   ------------------------MIFIN SYSTEM DATA----------------------

     SELECT 
   			 0 AS  CustomerEntityId
   			,C.CustomerId AS CustomerId
   			,C.CustomerId AS D2kCustomerid
   			,NULL AS ParentBranchCode
   			,LTRIM(C.CustomerName) AS CustomerName
   			,NULL AS CustomerInitial
   			,NULL AS CustomerSinceDt---DAO
   			--,'Y' AS ConsentObtained
   			,0 AS ConstitutionAlt_Key  ---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 
   			,0 AS OccupationAlt_Key  ---OCC  (master  UTBLOC)
   			,0 AS ReligionAlt_Key
   			,0 AS CasteAlt_Key
   			,0 AS FarmerCatAlt_Key
   			,NULL AS GaurdianSalutationAlt_Key
   			,NULL AS GaurdianName
   			,NULL AS GuardianType
   			,0 AS CustSalutationAlt_Key
   			,0 AS MaritalStatusAlt_Key
   			--,NULL AS DegUpgFlag
   			--,0 AS ProcessingFlag
   			--,NULL AS MOCLock
   			--,NULL AS MoveNpaDt
   			,NULL AS AssetClass
   			,NULL AS BIITransactionCode
   			,NULL AS D2K_REF_NO
   			--,NULL AS CustomerNameBackup
   			--,NULL AS ScrCrErrorBackup
   			,NULL AS ScrCrError
   			,NULL AS ReferenceAcNo
   			,NULL AS CustCRM_RatingAlt_Key
   			,NULL AS CustCRM_RatingDt
   			,NULL AS AuthorisationStatus
   			,@VEFFECTIVEFROM AS EFFECTIVEFROMTIMEKEY
   			,49999 AS EFFECTIVETOTIMEKEY
   			,'SSISUSER' ASCREATEDBY
   			,GETDATE() AS DATECREATED
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS FLAG
   			,NULL AS MocStatus
   			,NULL AS MocDate
   			--,NULL AS BaselProcessing
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CommonMocTypeAlt_Key
   			,NULL AS LandHolding
   			,NULL AS ScrCrErrorSeq
   			--,NULL AS CustType
   			--,NULL AS ServProviderAlt_Key
   			--,NULL AS NonCustTypeAlt_Key
   			,NULL AS Remark

   			FROM  RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM04_STG C  --first used this table
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

   UNION 


   ------------------------GANASEVA SYSTEM DATA----------------------

     SELECT 
   			 0 AS  CustomerEntityId
   			,C.CustomerId AS CustomerId
   			,C.CustomerId AS D2kCustomerid
   			,NULL AS ParentBranchCode
   			,LTRIM(C.CustomerName) AS CustomerName
   			,NULL AS CustomerInitial
   			,NULL AS CustomerSinceDt---DAO
   			--,'Y' AS ConsentObtained
   			,0 AS ConstitutionAlt_Key  ---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 
   			,0 AS OccupationAlt_Key  ---OCC  (master  UTBLOC)
   			,0 AS ReligionAlt_Key
   			,0 AS CasteAlt_Key
   			,0 AS FarmerCatAlt_Key
   			,NULL AS GaurdianSalutationAlt_Key
   			,NULL AS GaurdianName
   			,NULL AS GuardianType
   			,0 AS CustSalutationAlt_Key
   			,0 AS MaritalStatusAlt_Key
   			--,NULL AS DegUpgFlag
   			--,0 AS ProcessingFlag
   			--,NULL AS MOCLock
   			--,NULL AS MoveNpaDt
   			,NULL AS AssetClass
   			,NULL AS BIITransactionCode
   			,NULL AS D2K_REF_NO
   			--,NULL AS CustomerNameBackup
   			--,NULL AS ScrCrErrorBackup
   			,NULL AS ScrCrError
   			,NULL AS ReferenceAcNo
   			,NULL AS CustCRM_RatingAlt_Key
   			,NULL AS CustCRM_RatingDt
   			,NULL AS AuthorisationStatus
   			,@VEFFECTIVEFROM AS EFFECTIVEFROMTIMEKEY
   			,49999 AS EFFECTIVETOTIMEKEY
   			,'SSISUSER' ASCREATEDBY
   			,GETDATE() AS DATECREATED
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS FLAG
   			,NULL AS MocStatus
   			,NULL AS MocDate
   			--,NULL AS BaselProcessing
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CommonMocTypeAlt_Key
   			,NULL AS LandHolding
   			,NULL AS ScrCrErrorSeq
   			--,NULL AS CustType
   			--,NULL AS ServProviderAlt_Key
   			--,NULL AS NonCustTypeAlt_Key
   			,NULL AS Remark

   			FROM  RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM05_STG C  --first used this table
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

   UNION


   ------------------------VISION PLUS SYSTEM DATA----------------------

     SELECT 
   			 0 AS  CustomerEntityId
   			,C.CustomerId AS CustomerId
   			,C.CustomerId AS D2kCustomerid
   			,NULL AS ParentBranchCode
   			,LTRIM(C.CustomerName) AS CustomerName
   			,NULL AS CustomerInitial
   			,NULL AS CustomerSinceDt---DAO
   			--,'Y' AS ConsentObtained
   			,0 AS ConstitutionAlt_Key  ---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 
   			,0 AS OccupationAlt_Key  ---OCC  (master  UTBLOC)
   			,0 AS ReligionAlt_Key
   			,0 AS CasteAlt_Key
   			,0 AS FarmerCatAlt_Key
   			,NULL AS GaurdianSalutationAlt_Key
   			,NULL AS GaurdianName
   			,NULL AS GuardianType
   			,0 AS CustSalutationAlt_Key
   			,0 AS MaritalStatusAlt_Key
   			--,NULL AS DegUpgFlag
   			--,0 AS ProcessingFlag
   			--,NULL AS MOCLock
   			--,NULL AS MoveNpaDt
   			,NULL AS AssetClass
   			,NULL AS BIITransactionCode
   			,NULL AS D2K_REF_NO
   			--,NULL AS CustomerNameBackup
   			--,NULL AS ScrCrErrorBackup
   			,NULL AS ScrCrError
   			,NULL AS ReferenceAcNo
   			,NULL AS CustCRM_RatingAlt_Key
   			,NULL AS CustCRM_RatingDt
   			,NULL AS AuthorisationStatus
   			,@VEFFECTIVEFROM AS EFFECTIVEFROMTIMEKEY
   			,49999 AS EFFECTIVETOTIMEKEY
   			,'SSISUSER' ASCREATEDBY
   			,GETDATE() AS DATECREATED
   			,NULL AS ModifiedBy
   			,NULL AS DateModified
   			,NULL AS ApprovedBy
   			,NULL AS DateApproved
   			,NULL AS D2Ktimestamp
   			,NULL AS FLAG
   			,NULL AS MocStatus
   			,NULL AS MocDate
   			--,NULL AS BaselProcessing
   			,NULL AS MocTypeAlt_Key
   			,NULL AS CommonMocTypeAlt_Key
   			,NULL AS LandHolding
   			,NULL AS ScrCrErrorSeq
   			--,NULL AS CustType
   			--,NULL AS ServProviderAlt_Key
   			--,NULL AS NonCustTypeAlt_Key
   			,NULL AS Remark

   			FROM  RBL_STGDB.DBO.CUSTOMER_SOURCESYSTEM06_STG C  --first used this table
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

   */
   /*********************************************************************************************************/
   /*  Existing Customers Customer Entity ID Update  */
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, MAIN.CustomerEntityId
   FROM TEMP ,TempCustomerBasicDetail TEMP
          JOIN CurDat_RBL_MISDB_010922_UAT.CustomerBasicDetail MAIN   ON TEMP.CustomerId = MAIN.CustomerId 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CustomerEntityId = src.CustomerEntityId;
   SELECT MAX(CustomerEntityId)  

     INTO v_CustomerEntityId
     FROM RBL_MISDB_010922_UAT.CustomerBasicDetail ;
   IF v_CustomerEntityId IS NULL THEN

   BEGIN
      v_CustomerEntityId := 0 ;

   END;
   END IF;
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_CustEntityID_4  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_CustEntityID_4;
   UTILS.IDENTITY_RESET('tt_CustEntityID_4');

   INSERT INTO tt_CustEntityID_4 SELECT CustomerId ,
                                        (v_CustomerEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                               FROM DUAL  )  )) CustomerEntityId  
        FROM TempCustomerBasicDetail 
       WHERE  CustomerEntityId = 0
                OR CustomerEntityId IS NULL;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, ACCT.CustomerEntityId
   FROM TEMP ,TempCustomerBasicDetail TEMP
          JOIN tt_CustEntityID_4 ACCT   ON TEMP.CustomerId = ACCT.CustomerId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CustomerEntityId = src.CustomerEntityId;
   IF  --SQLDEV: NOT RECOGNIZED
   /*********************************************************************************************************/
   /*  Existing Customers Customer UCIF Entity ID Update  */
   IF tt_CustEntityID_4  --SQLDEV: NOT RECOGNIZED
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, MAIN.UcifEntityID
   FROM TEMP ,TempCustomerBasicDetail TEMP
          JOIN CurDat_RBL_MISDB_010922_UAT.CustomerBasicDetail MAIN   ON TEMP.UCIF_ID = MAIN.UCIF_ID 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.UcifEntityID = src.UcifEntityID;
   SELECT MAX(UcifEntityID)  

     INTO v_UcifEntityID
     FROM RBL_MISDB_010922_UAT.CustomerBasicDetail ;
   IF v_UcifEntityID IS NULL THEN

   BEGIN
      v_UcifEntityID := 0 ;

   END;
   END IF;
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_UcifEntityID_4  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_UcifEntityID_4;
   UTILS.IDENTITY_RESET('tt_UcifEntityID_4');

   INSERT INTO tt_UcifEntityID_4 SELECT UCIF_ID ,
                                        (v_UcifEntityID + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                           FROM DUAL  )  )) UcifEntityID  
        FROM ( SELECT UCIF_ID 
               FROM TempCustomerBasicDetail 
                WHERE  UcifEntityID = 0
                         OR UcifEntityID IS NULL
                 GROUP BY UCIF_ID ) A;
   MERGE INTO TEMP 
   USING (SELECT TEMP.ROWID row_id, ACCT.UcifEntityID
   FROM TEMP ,TempCustomerBasicDetail TEMP
          JOIN tt_UcifEntityID_4 ACCT   ON TEMP.UCIF_ID = ACCT.UCIF_ID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.UcifEntityID = src.UcifEntityID;
   IF  --SQLDEV: NOT RECOGNIZED
   /***********************************************************************************************************/
   /*  Updating CustomerEntityID In AdvAcBasciDetail  */
   IF tt_UcifEntityID_4  --SQLDEV: NOT RECOGNIZED
   MERGE INTO ACBD 
   USING (SELECT ACBD.ROWID row_id, CBD.CustomerEntityId
   FROM ACBD ,TempCustomerBasicDetail CBD
          JOIN TempAdvAcBasicDetail ACBD   ON CBD.CustomerId = (CASE 
                                                                     WHEN ACBD.RefCustomerId IS NULL THEN ACBD.CustomerAcID
        ELSE ACBD.RefCustomerId
           END) ) src
   ON ( ACBD.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET ACBD.CustomerEntityId = src.CustomerEntityId;
   /*********************************************************************************************************/
   --------------------------------------------------------------------------------------------------------------------------
   /* UPDATING DATA VALUE NOT PROVIDED */
   UPDATE TempCustomerBasicDetail
      SET CasteAlt_Key = 0
    WHERE  CasteAlt_Key IS NULL;
   UPDATE TempCustomerBasicDetail
      SET ReligionAlt_Key = 0
    WHERE  ReligionAlt_Key IS NULL;
   UPDATE TempCustomerBasicDetail
      SET FarmerCatAlt_Key = 0
    WHERE  FarmerCatAlt_Key IS NULL;
   UPDATE TempCustomerBasicDetail
      SET CustSalutationAlt_Key = 0
    WHERE  CustSalutationAlt_Key IS NULL;
   UPDATE TempCustomerBasicDetail
      SET ConstitutionAlt_Key = 0
    WHERE  ConstitutionAlt_Key IS NULL;
   WITH cte AS ( SELECT * ,
                        ROW_NUMBER() OVER ( PARTITION BY CustomerEntityid ORDER BY CustomerEntityid  ) Rnk  
     FROM TempCustomerBasicDetail  ) 
      DELETE cte

       WHERE  Rnk > 1
      ;-------------------------------------------------------------------------------------------------------------------------- 

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
