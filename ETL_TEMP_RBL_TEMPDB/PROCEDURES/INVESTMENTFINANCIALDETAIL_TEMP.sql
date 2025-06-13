--------------------------------------------------------
--  DDL for Procedure INVESTMENTFINANCIALDETAIL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" 
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
   v_VEFFECTIVETO NUMBER(10,0);
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
   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE RBL_TEMPDB.TempInvestmentFinancialDetail ';
   INSERT INTO RBL_TEMPDB.TempInvestmentFinancialDetail
     ( Time_Key, InvEntityId, RefIssuerID, RefInvID, HoldingNature, CurrencyAlt_Key, CurrencyConvRate, BookType, BookValue, BookValueINR, MTMValue, MTMValueINR, EncumberedMTM, AssetClass_AltKey, NPIDt, TotalProvison, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, Interest_DividendDueDate, Interest_DividendDueAmount, LatestBSDate, PartialRedumptionDueDate, PartialRedumptionSettledY_N, BalanceSheetDate, ListedShares )
     ( SELECT v_TimeKey Time_Key  ,
              InvEntityId ,
              A.IssuerID ,
              A.InvID ,
              --,(A.InvID + '_' + cast(HoldingNature as varchar(10))) InvID
              HoldingNature ,
              C.CurrencyAlt_Key ,
              CurrencyConvRate ,
              BookType ,
              BookValue ,
              BookValueINR ,
              MTMValue ,
              MTMValueINR ,
              EncumberedMTM ,
              B.AssetClassAlt_Key ,
              A.NPADt NPIDt  ,
              NULL TotalProvison  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              Interest_DividendoVERDueDate ,
              Interest_DividendOVERDueAmount ,
              LatestBSDate ,
              RedumptionDueDate ,
              RedumptionProceedSettledY_N ,
              BalanceSheetDate ,
              ListedShares 

       ----SELECT *		
       FROM RBL_STGDB.INVFINANCIAL_SOURCESYSTEM_STG A
              LEFT JOIN RBL_MISDB_PROD.DimAssetClass B   ON A.AssetClass = B.SrcSysClassCode
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_MISDB_PROD.DimCurrency C   ON A.CurrencyCode = C.SrcSysCurrencyCode
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
              JOIN RBL_TEMPDB.TempInvestmentBasicDetail I   ON I.InvID = A.InvID
        WHERE  NVL(HoldingNature, ' ') = ' '
       UNION 
       SELECT v_TimeKey Time_Key  ,
              InvEntityId ,
              A.IssuerID ,
              (A.InvID || '_' || UTILS.CONVERT_TO_VARCHAR2(NVL(HoldingNature, ' '),10)) InvID  ,
              --,(A.InvID + '_' + cast(HoldingNature as varchar(10))) InvID
              HoldingNature ,
              C.CurrencyAlt_Key ,
              CurrencyConvRate ,
              BookType ,
              BookValue ,
              BookValueINR ,
              MTMValue ,
              MTMValueINR ,
              EncumberedMTM ,
              B.AssetClassAlt_Key ,
              A.NPADt NPIDt  ,
              NULL TotalProvison  ,
              NULL AuthorisationStatus  ,
              v_vEffectivefrom EffectiveFromTimeKey  ,
              49999 EffectiveToTimeKey  ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              Interest_DividendoVERDueDate ,
              Interest_DividendOVERDueAmount ,
              LatestBSDate ,
              RedumptionDueDate ,
              RedumptionProceedSettledY_N ,
              BalanceSheetDate ,
              ListedShares 

       ----SELECT *		
       FROM RBL_STGDB.INVFINANCIAL_SOURCESYSTEM_STG A
              LEFT JOIN RBL_MISDB_PROD.DimAssetClass B   ON A.AssetClass = B.SrcSysClassCode
              AND B.EffectiveFromTimeKey <= v_TimeKey
              AND B.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_MISDB_PROD.DimCurrency C   ON A.CurrencyCode = C.SrcSysCurrencyCode
              AND C.EffectiveFromTimeKey <= v_TimeKey
              AND C.EffectiveToTimeKey >= v_TimeKey
              JOIN RBL_TEMPDB.TempInvestmentBasicDetail I   ON I.InvID = (A.InvID || '_' || UTILS.CONVERT_TO_VARCHAR2(NVL(HoldingNature, ' '),10))
        WHERE  NVL(HoldingNature, ' ') <> ' ' );
   /*********************************************************************************************************/
   /*  Existing Customers Customer Entity ID Update  */
   ------------------Added by Sudesh for One Time Code Run during LIVE 23102023 Investment Holding Nature Carry Forward--------
   IF v_TimeKey = 27012 THEN

    ------------27012 (15th is the next expected timekey so for one time run 27002 will be used; For any other date processing change kindly mention the same timekey here)
   BEGIN
      MERGE INTO RBL_TEMPDB.TempInvestmentFinancialDetail O
      USING (SELECT O.ROWID row_id, O.FLGDEG FLGDEG, T.DEGREASON DEGREASON, T.DPD DPD, O.FLGUPG FLGUPG, T.UpgDate UpgDate, T.PROVISIONALT_KEY PROVISIONALT_KEY, T.FinalAssetClassAlt_Key FinalAssetClassAlt_Key, T.NPIDt , T.RefIssuerID RefIssuerID, T.DPD_Maturity DPD_Maturity, T.DPD_DivOverdue DPD_DivOverdue
      FROM RBL_TEMPDB.TempInvestmentFinancialDetail O
             JOIN RBL_MISDB_PROD.InvestmentFinancialDetail T
           --on	SUBSTRING(O.RefInvID,1,charindex('_',O.RefInvID)-1)  =T.RefInvID
              ON O.RefInvID = T.RefInvID
             AND O.EffectiveToTimeKey = 49999
             AND T.EffectivefromTimeKey <= v_VEFFECTIVETO
             AND T.EffectiveToTimeKey >= v_VEFFECTIVETO ) src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET O.FLGDEG = src.FLGDEG,
                                   O.DEGREASON = src.DEGREASON,
                                   O.DPD = src.DPD,
                                   O.FLGUPG = src.FLGUPG,
                                   O.UpgDate = src.UpgDate,
                                   O.PROVISIONALT_KEY = src.PROVISIONALT_KEY,
                                   O.InitialAssetAlt_Key = src.FinalAssetClassAlt_Key,
                                   O.InitialNPIDt = src.NPIDt,
                                   O.RefIssuerID = src.RefIssuerID,
                                   O.DPD_Maturity = src.DPD_Maturity,
                                   O.DPD_DivOverdue = src.DPD_DivOverdue,
                                   O.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                   O.NPIDt = src.NPIDt;

   END;
   ELSE

   BEGIN
      MERGE INTO RBL_TEMPDB.TempInvestmentFinancialDetail O
      USING (SELECT O.ROWID row_id, O.FLGDEG, T.DEGREASON, T.DPD, O.FLGUPG, T.UpgDate, T.PROVISIONALT_KEY, T.FinalAssetClassAlt_Key, T.NPIDt, T.RefIssuerID, T.DPD_Maturity, T.DPD_DivOverdue
      FROM RBL_TEMPDB.TempInvestmentFinancialDetail O
             JOIN RBL_MISDB_PROD.InvestmentFinancialDetail T   ON O.InvEntityId = T.InvEntityId
             AND O.EffectiveToTimeKey = 49999
             AND T.EffectivefromTimeKey <= v_VEFFECTIVETO
             AND T.EffectiveToTimeKey >= v_VEFFECTIVETO ) src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET O.FLGDEG = src.FLGDEG,
                                   O.DEGREASON = src.DEGREASON,
                                   O.DPD = src.DPD,
                                   O.FLGUPG = src.FLGUPG,
                                   O.UpgDate = src.UpgDate,
                                   O.PROVISIONALT_KEY = src.PROVISIONALT_KEY,
                                   O.InitialAssetAlt_Key = src.FinalAssetClassAlt_Key,
                                   O.InitialNPIDt = src.NPIDt,
                                   O.RefIssuerID = src.RefIssuerID,
                                   O.DPD_Maturity = src.DPD_Maturity,
                                   O.DPD_DivOverdue = src.DPD_DivOverdue,
                                   O.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                   O.NPIDt = src.NPIDt;

   END;
   END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."INVESTMENTFINANCIALDETAIL_TEMP" TO "ADF_CDR_RBL_STGDB";
