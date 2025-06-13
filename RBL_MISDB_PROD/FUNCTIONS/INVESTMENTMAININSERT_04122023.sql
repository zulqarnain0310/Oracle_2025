--------------------------------------------------------
--  DDL for Function INVESTMENTMAININSERT_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" 
--DECLARE

(
  v_Entitykey IN NUMBER DEFAULT 0 ,
  v_Remark IN VARCHAR2 DEFAULT ' ' ,
  v_MenuID IN NUMBER DEFAULT 0 ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_AuthMode IN CHAR DEFAULT 'N' ,
  v_IsMOC IN CHAR DEFAULT 'N' ,
  v_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  v_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_TimeKey IN NUMBER DEFAULT 0 ,
  v_CrModApBy IN VARCHAR2 DEFAULT 'd2k' ,
  v_D2Ktimestamp OUT NUMBER/* DEFAULT 0*/,
  v_Result OUT NUMBER/* DEFAULT 0*/,
  iv_InvEntityId IN NUMBER DEFAULT 0 ,
  v_InvID IN VARCHAR2 DEFAULT ' ' ,
  v_HoldingNature IN CHAR DEFAULT '0' ,
  v_CurrencyAlt_Key IN NUMBER DEFAULT 0 ,
  v_CurrencyConvRate IN NUMBER DEFAULT 0.0 ,
  v_BookType IN VARCHAR2 DEFAULT ' ' ,
  v_BookValue IN NUMBER DEFAULT 0.0 ,
  v_BookValueINR IN NUMBER DEFAULT 0.0 ,
  v_MTMValue IN NUMBER DEFAULT 0.0 ,
  v_MTMValueINR IN NUMBER DEFAULT 0.0 ,
  v_EncumberedMTM IN NUMBER DEFAULT 0.0 ,
  v_AssetClass_AltKey IN NUMBER DEFAULT 0 ,
  iv_NPIDt IN VARCHAR2 DEFAULT NULL ,
  iv_DBTDate IN VARCHAR2 DEFAULT NULL ,
  iv_LatestBSDate IN VARCHAR2 DEFAULT NULL ,
  iv_Interest_DividendDueDate IN VARCHAR2 DEFAULT NULL ,
  v_Interest_DividendDueAmount IN NUMBER DEFAULT 0.0 ,
  iv_PartialRedumptionDueDate IN VARCHAR2 DEFAULT NULL ,
  v_PartialRedumptionSettledY_N IN CHAR DEFAULT 'N' ,
  iv_IssuerEntityID IN NUMBER DEFAULT 0 ,
  v_SourceAlt_key IN NUMBER DEFAULT ' ' ,
  v_BranchCode IN VARCHAR2 DEFAULT ' ' ,
  v_UcifId IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerID IN VARCHAR2 DEFAULT ' ' ,
  v_IssuerName IN VARCHAR2 DEFAULT ' ' ,
  v_Ref_Txn_Sys_Cust_ID IN VARCHAR2 DEFAULT ' ' ,
  v_PanNo IN VARCHAR2 DEFAULT ' ' ,
  v_Issuer_Category_Code IN CHAR DEFAULT 'N' ,
  v_GrpEntityOfBank IN CHAR DEFAULT 'N' ,
  v_ISIN IN VARCHAR2 DEFAULT ' ' ,
  v_InstrTypeAlt_key IN NUMBER DEFAULT 0 ,
  v_InstrName IN VARCHAR2 DEFAULT ' ' ,
  v_InvestmentNature IN VARCHAR2 DEFAULT ' ' ,
  v_Sector IN VARCHAR2 DEFAULT ' ' ,
  v_Industry_Altkey IN NUMBER DEFAULT 0 ,
  v_ExposureType IN VARCHAR2 DEFAULT ' ' ,
  v_SecurityValue IN NUMBER DEFAULT 0.0 ,
  iv_MaturityDt IN VARCHAR2 DEFAULT NULL ,
  iv_ReStructureDate IN VARCHAR2 DEFAULT NULL ,
  ---------ADD Changefields Column------Commented 26/05/2021
  v_Basic_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_Financial_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  v_Issuer_ChangeFields IN VARCHAR2 DEFAULT ' ' ,
  -----------D2k System Common Columns			
  v_InvestmentBasicDetailsInUp IN CHAR DEFAULT 'N' ,
  v_InvestmentFinancialDetailInUp IN CHAR DEFAULT 'N' ,
  v_InvestmentIssuerDetailINUP IN CHAR DEFAULT 'N' 
)
RETURN NUMBER
AS
   v_NPIDt VARCHAR2(20) := iv_NPIDt;
   v_DBTDate VARCHAR2(20) := iv_DBTDate;
   v_LatestBSDate VARCHAR2(20) := iv_LatestBSDate;
   v_Interest_DividendDueDate VARCHAR2(20) := iv_Interest_DividendDueDate;
   v_PartialRedumptionDueDate VARCHAR2(20) := iv_PartialRedumptionDueDate;
   v_MaturityDt VARCHAR2(20) := iv_MaturityDt;
   v_ReStructureDate VARCHAR2(20) := iv_ReStructureDate;
   v_IssuerEntityID NUMBER(10,0) := iv_IssuerEntityID;
   v_InvEntityId NUMBER(10,0) := iv_InvEntityId;
   v_cursor SYS_REFCURSOR;

BEGIN

   /*TODO:SQLDEV*/ SET XACT_ABORT ON /*END:SQLDEV*/
   BEGIN

      BEGIN
         --********************************************************************************
         /*  update and set date paramter here */
         IF v_NPIDt = ' ' THEN

         BEGIN
            v_NPIDt := NULL ;

         END;
         END IF;
         IF v_DBTDate = ' ' THEN

         BEGIN
            v_DBTDate := NULL ;

         END;
         END IF;
         IF v_LatestBSDate = ' ' THEN

         BEGIN
            v_LatestBSDate := NULL ;

         END;
         END IF;
         IF v_Interest_DividendDueDate = ' ' THEN

         BEGIN
            v_Interest_DividendDueDate := NULL ;

         END;
         END IF;
         IF v_PartialRedumptionDueDate = ' ' THEN

         BEGIN
            v_PartialRedumptionDueDate := NULL ;

         END;
         END IF;
         IF v_MaturityDt = ' ' THEN

         BEGIN
            v_MaturityDt := NULL ;

         END;
         END IF;
         IF v_ReStructureDate = ' ' THEN

         BEGIN
            v_ReStructureDate := NULL ;

         END;
         END IF;
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         -------------------
         IF v_InvestmentIssuerDetailINUP = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(1);
            utils.var_number :=RBL_MISDB_PROD.InvestmentIssuerDetailInUP(v_Entitykey,
                                                                         v_IssuerEntityID,
                                                                         v_SourceAlt_key,
                                                                         v_BranchCode,
                                                                         v_UcifId,
                                                                         v_IssuerID,
                                                                         v_IssuerName,
                                                                         v_Ref_Txn_Sys_Cust_ID,
                                                                         v_PanNo,
                                                                         v_Issuer_Category_Code,
                                                                         v_GrpEntityOfBank,
                                                                         v_Remark,
                                                                         v_MenuID,
                                                                         v_OperationFlag,
                                                                         v_AuthMode,
                                                                         v_IsMOC,
                                                                         v_EffectiveFromTimeKey,
                                                                         v_EffectiveToTimeKey,
                                                                         v_TimeKey,
                                                                         v_CrModApBy,
                                                                         v_D2Ktimestamp,
                                                                         v_Result) ;

         END;
         END IF;
         IF v_OperationFlag = 1 THEN

         BEGIN
            v_IssuerEntityId := v_Result ;
            OPEN  v_cursor FOR
               SELECT '1' 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_OperationFlag <> 1 THEN

         BEGIN
            v_RESULT := v_IssuerEntityId ;

         END;
         END IF;
         IF v_InvestmentBasicDetailsInUp = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(2);
            utils.var_number :=InvestmentBasicDetailInUP(v_Entitykey,
                                                         v_InvEntityId,
                                                         v_IssuerEntityId,
                                                         v_InvID,
                                                         v_ISIN,
                                                         v_InstrTypeAlt_key,
                                                         v_InstrName,
                                                         v_InvestmentNature,
                                                         v_Sector,
                                                         v_Industry_Altkey,
                                                         v_ExposureType,
                                                         v_SecurityValue,
                                                         v_MaturityDt,
                                                         v_ReStructureDate,
                                                         v_Remark,
                                                         v_MenuID,
                                                         v_OperationFlag,
                                                         v_AuthMode,
                                                         v_IsMOC,
                                                         v_EffectiveFromTimeKey,
                                                         v_EffectiveToTimeKey,
                                                         v_TimeKey,
                                                         v_CrModApBy,
                                                         v_D2Ktimestamp,
                                                         v_Result) ;

         END;
         END IF;
         IF v_OperationFlag = 1 THEN

         BEGIN
            v_InvEntityId := v_Result ;
            OPEN  v_cursor FOR
               SELECT '1' 
                 FROM DUAL  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;
         IF v_OperationFlag <> 1 THEN

         BEGIN
            v_RESULT := v_InvEntityId ;

         END;
         END IF;
         IF v_InvestmentFinancialDetailInUp = 'Y' THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE(3);
            utils.var_number :=InvestmentFinancialDetailInUP(v_Entitykey,
                                                             v_InvEntityId,
                                                             v_InvID,
                                                             v_IssuerID,
                                                             v_HoldingNature,
                                                             v_CurrencyAlt_Key,
                                                             v_CurrencyConvRate,
                                                             v_BookType,
                                                             v_BookValue,
                                                             v_BookValueINR,
                                                             v_MTMValue,
                                                             v_MTMValueINR,
                                                             v_EncumberedMTM,
                                                             v_AssetClass_AltKey,
                                                             v_NPIDt,
                                                             v_DBTDate,
                                                             v_LatestBSDate,
                                                             v_Interest_DividendDueDate,
                                                             v_Interest_DividendDueAmount,
                                                             v_PartialRedumptionDueDate,
                                                             v_PartialRedumptionSettledY_N,
                                                             v_Remark,
                                                             v_MenuID,
                                                             v_OperationFlag,
                                                             v_AuthMode,
                                                             v_IsMOC,
                                                             v_EffectiveFromTimeKey,
                                                             v_EffectiveToTimeKey,
                                                             v_TimeKey,
                                                             v_CrModApBy,
                                                             v_D2Ktimestamp,
                                                             v_Result) ;

         END;
         END IF;
         utils.commit_transaction;
         v_D2Ktimestamp := 1 ;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      ROLLBACK;
      utils.resetTrancount;
      v_Result := -1 ;
      RETURN v_Result;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTMAININSERT_04122023" TO "ADF_CDR_RBL_STGDB";
