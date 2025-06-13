--------------------------------------------------------
--  DDL for Procedure INVESTMENTBASICDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" 
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
   v_DATE VARCHAR2(200);
   --GO
   /*********************************************************************************************************/
   /*  New Customers Customer Entity ID Update  */
   v_InvEntityId NUMBER(10,0) := 0;
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
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempInvestmentBasicDetail ';
   INSERT INTO RBL_TEMPDB.TempInvestmentBasicDetail
     ( BranchCode, Inv_Key, InvID, IssuerID, ISIN, InstrTypeAlt_Key, InstrName, InvestmentNature, InternalRating, InRatingDate, InRatingExpiryDate, ExRating, ExRatingAgency, ExRatingDate, ExRatingExpiryDate, Sector, Industry_AltKey, ListedStkExchange, ExposureType, SecurityValue, MaturityDt, ReStructureDate, MortgageStatus, NHBStatus, ResiPurpose, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
     ( SELECT A.BranchCode ,
              NULL Inv_Key  ,
              (CASE 
                    WHEN HoldingNature IS NULL THEN A.InvID
              ELSE (A.InvID || '_' || UTILS.CONVERT_TO_VARCHAR2(NVL(HoldingNature, ' '),10))
                 END) InvID  ,
              A.IssuerID ,
              ISIN ,
              B.InstrumentTypeAlt_Key ,
              A.InstrName ,
              A.InvestmentNature ,
              NULL InternalRating  ,
              NULL InRatingDate  ,
              NULL InRatingExpiryDate  ,
              NULL ExRating  ,
              NULL ExRatingAgency  ,
              NULL ExRatingDate  ,
              NULL ExRatingExpiryDate  ,
              A.Sector ,
              C.IndustryAlt_Key ,
              NULL ListedStkExchange  ,
              A.ExposureType ,
              A.SecurityValue ,
              A.MaturityDt ,
              A.ReStructureDate ,
              NULL MortgageStatus  ,
              NULL NHBStatus  ,
              NULL ResiPurpose  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  
       FROM RBL_STGDB.INVBASIC_SOURCESYSTEM_STG A
              LEFT JOIN RBL_MISDB_PROD.DimInstrumentType B   ON A.InstrTypeCode = B.InstrumentTypeSubGroup
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_MISDB_PROD.DimIndustry C   ON A.IndustryCode = C.SrcSysIndustryCode
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_STGDB.INVFINANCIAL_SOURCESYSTEM_STG J   ON A.InvID = J.InvID
              JOIN RBL_TEMPDB.TempInvestmentIssuerDetail I   ON I.IssuerID = A.IssuerID );
   /*********************************************************************************************************/
   /*  Existing Customers Customer Entity ID Update  */
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.InvEntityId
   FROM RBL_TEMPDB.TempInvestmentBasicDetail TEMP
          JOIN RBL_MISDB_PROD.InvestmentFinancialDetail MAIN
        --ON TEMP.InvID=(CASE WHEN HoldingNature is NULL THEN MAIN.RefInvID ELSE (MAIN.RefInvID + '_' + cast(ISNULL(HoldingNature,'') as varchar(10))) END)
           ON TEMP.InvID = (CASE 
                                 WHEN ( HoldingNature IS NULL
                                   OR MAIN.RefInvID LIKE '%/_%'ESCAPE '/' ) THEN MAIN.RefInvID
        ELSE (MAIN.RefInvID || '_' || UTILS.CONVERT_TO_VARCHAR2(NVL(HoldingNature, ' '),10))
           END) 
    WHERE MAIN.EffectiveToTimeKey = 49999) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.InvEntityId = src.InvEntityId;
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, a.InvEntityId
   FROM RBL_TEMPDB.TempInvestmentBasicDetail TEMP
          JOIN RBL_STGDB.INVFINANCIAL_SOURCESYSTEM_STG MAIN
        --ON TEMP.InvID=(CASE WHEN HoldingNature is NULL THEN MAIN.RefInvID ELSE (MAIN.RefInvID + '_' + cast(ISNULL(HoldingNature,'') as varchar(10))) END)
           ON TEMP.InvID = (CASE 
                                 WHEN ( HoldingNature IS NULL
                                   OR MAIN.InvID LIKE '%/_%'ESCAPE '/' ) THEN MAIN.InvID
        ELSE (MAIN.InvID || '_' || UTILS.CONVERT_TO_VARCHAR2(NVL(HoldingNature, ' '),10))
           END)
          JOIN RBL_MISDB_PROD.InvestmentBasicDetail a   ON main.invid = a.invid 
    WHERE a.EffectiveToTimeKey = 49999
     AND temp.InvEntityId IS NULL) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.InvEntityId = src.InvEntityId;
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, MAIN.InvEntityId
   FROM RBL_TEMPDB.TempInvestmentBasicDetail TEMP
          JOIN RBL_MISDB_PROD.InvestmentBasicDetail MAIN   ON TEMP.InvID = MAIN.InvID 
    WHERE MAIN.EffectiveToTimeKey = 49999
     AND temp.InvEntityId IS NULL) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.InvEntityId = src.InvEntityId;
   SELECT MAX(InvEntityId)  

     INTO v_InvEntityId
     FROM RBL_MISDB_PROD.InvestmentBasicDetail ;
   IF v_InvEntityId IS NULL THEN

   BEGIN
      v_InvEntityId := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.InvEntityId
   FROM RBL_TEMPDB.TempInvestmentBasicDetail TEMP
          JOIN ( SELECT A.InvID ,
                        (v_InvEntityId + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                          FROM DUAL  )  )) InvEntityId  
                 FROM RBL_TEMPDB.TempInvestmentBasicDetail A
                  WHERE  A.InvEntityId = 0
                           OR A.InvEntityId IS NULL ) ACCT   ON TEMP.InvID = ACCT.InvID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.InvEntityId = src.InvEntityId;
   --------------------------------------------------
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail A
   USING (SELECT A.ROWID row_id, B.IssuerEntityId
   FROM RBL_TEMPDB.TempInvestmentBasicDetail A
          JOIN RBL_TEMPDB.TempInvestmentIssuerDetail B   ON A.IssuerId = B.IssuerId ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IssuerEntityId = src.IssuerEntityId;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTBASICDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
