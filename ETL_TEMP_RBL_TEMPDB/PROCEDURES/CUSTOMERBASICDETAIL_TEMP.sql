--------------------------------------------------------
--  DDL for Procedure CUSTOMERBASICDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   v_vEffectivefrom NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_DATE VARCHAR2(200) ;
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_CustomerEntityId NUMBER(10,0) := 0;
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_UcifEntityID NUMBER(10,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT Date_ INTO v_DATE 
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y'  ;


   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempCustomerBasicDetail ';
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   
   --------------------------------------------------------------------------------------------------------------------------------------------------- 
   INSERT INTO RBL_TEMPDB.TempCustomerBasicDetail
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
              NVL(DC.ConstitutionAlt_Key, '999') ConstitutionAlt_Key ,---STBLW9ENTTYPE  (master STBLW9ENTTYPE) if blank then INDIVIDUAL 

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
                     FROM RBL_TEMPDB.TempAdvAcBasicDetail  ) ACBD   ON C.CUSTOMERID = ACBD.REFCUSTOMERID
              LEFT JOIN RBL_MISDB_PROD.DIMSOURCEDB S   ON S.SourceName = C.SourceSystem
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN RBL_MISDB_PROD.DimConstitutionMapping DC   ON RTRIM(LTRIM(DC.SrcSysConstitutionName)) = RTRIM(LTRIM(C.Constitution))
              AND DC.EffectiveToTimeKey = 49999 );
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
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM RBL_TEMPDB.TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

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
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM RBL_TEMPDB.TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

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
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM RBL_TEMPDB.TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

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
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM RBL_TEMPDB.TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

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
   			INNER JOIN  (SELECT DISTINCT REFCUSTOMERID FROM RBL_TEMPDB.TempAdvAcBasicDetail)	ACBD  ON C.CUSTOMERID = ACBD.REFCUSTOMERID

   */
   /*********************************************************************************************************/
   /*  Existing Customers Customer Entity ID Update  */
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.CustomerEntityId
   FROM RBL_TEMPDB.TempCustomerBasicDetail TEMP
          JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail MAIN   ON TEMP.CustomerId = MAIN.CustomerId 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CustomerEntityId = src.CustomerEntityId;
   SELECT MAX(CustomerEntityId)  

     INTO v_CustomerEntityId
     FROM RBL_MISDB_PROD.CustomerBasicDetail ;
   IF v_CustomerEntityId IS NULL THEN

   BEGIN
      v_CustomerEntityId := 0 ;

   END;
   END IF;
   DELETE FROM GTT_CustEntityID;
   UTILS.IDENTITY_RESET('GTT_CustEntityID');

   INSERT INTO GTT_CustEntityID SELECT CustomerId ,
                                      (v_CustomerEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                             FROM DUAL  )  )) CustomerEntityId  
        FROM RBL_TEMPDB.TempCustomerBasicDetail 
       WHERE  CustomerEntityId = 0
                OR CustomerEntityId IS NULL;
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.CustomerEntityId
   FROM RBL_TEMPDB.TempCustomerBasicDetail TEMP
          JOIN GTT_CustEntityID ACCT   ON TEMP.CustomerId = ACCT.CustomerId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.CustomerEntityId = src.CustomerEntityId;
   /*********************************************************************************************************/
   /*  Existing Customers Customer UCIF Entity ID Update  */
   
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.UcifEntityID
   FROM RBL_TEMPDB.TempCustomerBasicDetail TEMP
          JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail MAIN   ON TEMP.UCIF_ID = MAIN.UCIF_ID 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.UcifEntityID = src.UcifEntityID;
   SELECT MAX(UcifEntityID)  

     INTO v_UcifEntityID
     FROM RBL_MISDB_PROD.CustomerBasicDetail ;
   IF v_UcifEntityID IS NULL THEN

   BEGIN
      v_UcifEntityID := 0 ;

   END;
   END IF;
   
   DELETE FROM GTT_UcifEntityID;
   UTILS.IDENTITY_RESET('GTT_UcifEntityID');

   INSERT INTO GTT_UcifEntityID SELECT UCIF_ID ,
                                      (v_UcifEntityID + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                         FROM DUAL  )  )) UcifEntityID  
        FROM ( SELECT UCIF_ID 
               FROM RBL_TEMPDB.TempCustomerBasicDetail 
                WHERE  UcifEntityID = 0
                         OR UcifEntityID IS NULL
                 GROUP BY UCIF_ID ) A;
   MERGE INTO RBL_TEMPDB.TempCustomerBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.UcifEntityID
   FROM RBL_TEMPDB.TempCustomerBasicDetail TEMP
          JOIN GTT_UcifEntityID ACCT   ON TEMP.UCIF_ID = ACCT.UCIF_ID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.UcifEntityID = src.UcifEntityID;
   
   /***********************************************************************************************************/
   /*  Updating CustomerEntityID In AdvAcBasciDetail  */
   
   MERGE INTO RBL_TEMPDB.TempAdvAcBasicDetail ACBD  
   USING (SELECT ACBD.ROWID row_id, CBD.CustomerEntityId
   FROM RBL_TEMPDB.TempCustomerBasicDetail CBD
          JOIN RBL_TEMPDB.TempAdvAcBasicDetail ACBD   ON CBD.CustomerId = (CASE 
                                                                     WHEN ACBD.RefCustomerId IS NULL THEN ACBD.CustomerAcID
        ELSE ACBD.RefCustomerId
           END) ) src
   ON ( ACBD.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET ACBD.CustomerEntityId = src.CustomerEntityId;
   /*********************************************************************************************************/
   --------------------------------------------------------------------------------------------------------------------------
   /* UPDATING DATA VALUE NOT PROVIDED */
   UPDATE RBL_TEMPDB.TempCustomerBasicDetail
      SET CasteAlt_Key = 0
    WHERE  CasteAlt_Key IS NULL;
   UPDATE RBL_TEMPDB.TempCustomerBasicDetail
      SET ReligionAlt_Key = 0
    WHERE  ReligionAlt_Key IS NULL;
   UPDATE RBL_TEMPDB.TempCustomerBasicDetail
      SET FarmerCatAlt_Key = 0
    WHERE  FarmerCatAlt_Key IS NULL;
   UPDATE RBL_TEMPDB.TempCustomerBasicDetail
      SET CustSalutationAlt_Key = 0
    WHERE  CustSalutationAlt_Key IS NULL;
   UPDATE RBL_TEMPDB.TempCustomerBasicDetail
      SET ConstitutionAlt_Key = 0
    WHERE  ConstitutionAlt_Key IS NULL;

       
        DELETE FROM RBL_TEMPDB.TempCustomerBasicDetail
        WHERE rowid not in
        (SELECT MIN(rowid)
        FROM RBL_TEMPDB.TempCustomerBasicDetail
        GROUP BY CustomerEntityid);
      -------------------------------------------------------------------------------------------------------------------------- 

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."CUSTOMERBASICDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
