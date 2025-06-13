--------------------------------------------------------
--  DDL for Procedure INVESTMENTBASICDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   /*  New Customers EntityKey ID Update  */
   v_EntityKey NUMBER(19,0) := 0;
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail A
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempInvestmentBasicDetail A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.InvestmentBasicDetail B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND A.InvEntityId = B.InvEntityId )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';-- And A.SourceAlt_Key=B.SourceAlt_Key)
   MERGE INTO RBL_MISDB_PROD.InvestmentBasicDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.InvestmentBasicDetail O
          JOIN RBL_TEMPDB.TempInvestmentBasicDetail T   ON O.InvEntityId = T.InvEntityId
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 
    WHERE ( NVL(O.BranchCode, 0) <> NVL(T.BranchCode, 0)
     OR NVL(O.InvID, 0) <> NVL(T.InvID, 0)
     OR NVL(O.IssuerEntityId, 0) <> NVL(T.InvEntityId, 0)
     OR NVL(O.ISIN, 0) <> NVL(T.ISIN, 0)
     OR NVL(O.InstrTypeAlt_Key, 0) <> NVL(T.InstrTypeAlt_Key, 0)
     OR NVL(O.InstrName, 0) <> NVL(T.InstrName, 0)
     OR NVL(O.InvestmentNature, 0) <> NVL(T.InvestmentNature, 0)
     OR NVL(O.InternalRating, 0) <> NVL(T.InternalRating, 0)
     OR NVL(O.InRatingDate, '1990-01-01') <> NVL(T.InRatingDate, '1990-01-01')
     OR NVL(O.InRatingExpiryDate, '1990-01-01') <> NVL(T.InRatingExpiryDate, '1990-01-01')
     OR NVL(O.ExRating, 0) <> NVL(T.ExRating, 0)
     OR NVL(O.ExRatingAgency, 0) <> NVL(T.ExRatingAgency, 0)
     OR NVL(O.ExRatingDate, '1990-01-01') <> NVL(T.ExRatingDate, '1990-01-01')
     OR NVL(O.ExRatingExpiryDate, '1990-01-01') <> NVL(T.ExRatingExpiryDate, '1990-01-01')
     OR NVL(O.Sector, 0) <> NVL(T.Sector, 0)
     OR NVL(O.Industry_AltKey, 0) <> NVL(T.Industry_AltKey, 0)
     OR NVL(O.ListedStkExchange, 0) <> NVL(T.ListedStkExchange, 0)
     OR NVL(O.ExposureType, 0) <> NVL(T.ExposureType, 0)
     OR NVL(O.SecurityValue, 0) <> NVL(T.SecurityValue, 0)
     OR NVL(O.MaturityDt, '1990-01-01') <> NVL(T.MaturityDt, '1990-01-01')
     OR NVL(O.ReStructureDate, '1990-01-01') <> NVL(T.ReStructureDate, '1990-01-01')
     OR NVL(O.MortgageStatus, 0) <> NVL(T.MortgageStatus, 0)
     OR NVL(O.NHBStatus, 0) <> NVL(T.NHBStatus, 0)
     OR NVL(O.ResiPurpose, 0) <> NVL(T.ResiPurpose, 0) )) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempInvestmentBasicDetail A
          JOIN RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   MERGE INTO RBL_MISDB_PROD.InvestmentBasicDetail AA 
   USING (SELECT AA.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.InvestmentBasicDetail AA 
    WHERE AA.EffectiveToTimeKey = 49999
     AND NOT EXISTS ( SELECT 1 
                      FROM RBL_TEMPDB.TempInvestmentBasicDetail BB
                       WHERE  AA.InvEntityId = BB.InvEntityId
                                AND BB.EffectiveToTimeKey = 49999 )) src
   ON ( AA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_vEffectiveto,
                                DateModified = pos_3,
                                ModifiedBy = 'SSISUSER';
   SELECT MAX(EntityKey)  

     INTO v_EntityKey
     FROM RBL_MISDB_PROD.InvestmentBasicDetail ;
   IF v_EntityKey IS NULL THEN

   BEGIN
      v_EntityKey := 0 ;

   END;
   END IF;
   MERGE INTO RBL_TEMPDB.TempInvestmentBasicDetail TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKey
   FROM RBL_TEMPDB.TempInvestmentBasicDetail TEMP
          JOIN ( SELECT "TEMPINVESTMENTBASICDETAIL".InvEntityId ,
                        (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                        FROM DUAL  )  )) EntityKey  
                 FROM RBL_TEMPDB.TempInvestmentBasicDetail 
                  WHERE  "TEMPINVESTMENTBASICDETAIL".EntityKey = 0
                           OR "TEMPINVESTMENTBASICDETAIL".EntityKey IS NULL ) ACCT   ON Temp.InvEntityId = ACCT.InvEntityId 
    WHERE Temp.IsChanged IN ( 'N','C' )
   ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKey = src.EntityKey;
   --IF (SELECT COUNT(1) FROM   RBL_TEMPDB.dbo.TempInvestmentBasicDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')) > 0
   --BEGIN
   INSERT INTO RBL_MISDB_PROD.InvestmentBasicDetail
     ( BranchCode, EntityKey, InvEntityId, IssuerEntityId, InvID, RefIssuerID, ISIN, InstrTypeAlt_Key, InstrName, InvestmentNature, InternalRating, InRatingDate, InRatingExpiryDate, ExRating, ExRatingAgency, ExRatingDate, ExRatingExpiryDate, Sector, Industry_AltKey, ListedStkExchange, ExposureType, SecurityValue, MaturityDt, ReStructureDate, MortgageStatus, NHBStatus, ResiPurpose, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
     ( SELECT BranchCode ,
              EntityKey ,
              InvEntityId ,
              IssuerEntityId ,
              InvID ,
              IssuerID ,
              SUBSTR(ISIN, 1, 12) ,
              InstrTypeAlt_Key ,
              InstrName ,
              InvestmentNature ,
              InternalRating ,
              InRatingDate ,
              InRatingExpiryDate ,
              ExRating ,
              ExRatingAgency ,
              ExRatingDate ,
              ExRatingExpiryDate ,
              Sector ,
              Industry_AltKey ,
              ListedStkExchange ,
              ExposureType ,
              SecurityValue ,
              MaturityDt ,
              ReStructureDate ,
              MortgageStatus ,
              NHBStatus ,
              ResiPurpose ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved 
       FROM RBL_TEMPDB.TempInvestmentBasicDetail T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );--end

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTBASICDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
