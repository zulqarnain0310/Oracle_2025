--------------------------------------------------------
--  DDL for Procedure INVESTMENTFINANCIALDETAIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================

AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   ------------For New Records
   --UPDATE A SET A.IsChanged='N'
   ------Select * 
   --from RBL_TEMPDB.DBO.TempInvestmentFinancialDetail A
   --Where Not Exists(Select 1 from DBO.InvestmentFinancialDetail B Where B.EffectiveToTimeKey=49999
   --And A.InvEntityId=B.InvEntityId) 
   MERGE INTO RBL_MISDB_PROD.InvestmentFinancialDetail O
   USING (SELECT O.ROWID row_id, v_vEffectiveto, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'SSISUSER'
   FROM RBL_MISDB_PROD.InvestmentFinancialDetail O
        --INNER JOIN RBL_TEMPDB.DBO.TempInvestmentFinancialDetail AS T
         --ON O.InvEntityId=T.InvEntityId

    WHERE O.EffectiveToTimeKey = 49999) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = v_vEffectiveto,
                                O.DateModified = pos_3,
                                O.ModifiedBy = 'SSISUSER';
   --AND T.EffectiveToTimeKey=49999
   --WHERE 
   --(
   --  --O.Time_Key <> T.Time_Key 
   -- ISNULL(O.HoldingNature,0) <> ISNULL(T.HoldingNature ,0)
   --OR ISNULL(O.CurrencyAlt_Key,0) <> ISNULL(T.CurrencyAlt_Key ,0)
   --OR ISNULL(O.CurrencyConvRate,0) <> ISNULL(T.CurrencyConvRate,0) 
   --OR ISNULL(O.BookType,0) <> ISNULL(T.BookType,0) 
   --OR ISNULL(O.BookValue,0) <> ISNULL(T.BookValue,0) 
   --OR ISNULL(O.BookValueINR,0) <> ISNULL(T.BookValueINR,0) 
   --OR ISNULL(O.MTMValue,0) <> ISNULL(T.MTMValue,0)
   --OR ISNULL(O.MTMValueINR,0) <> ISNULL(T.MTMValueINR,0) 
   --OR ISNULL(O.EncumberedMTM,0) <> ISNULL(T.EncumberedMTM,0) 
   --OR ISNULL(O.AssetClass_AltKey,0) <> ISNULL(T.AssetClass_AltKey ,0)
   --OR ISNULL(O.NPIDt,'1990-01-01') <> ISNULL(T.NPIDt,'1990-01-01') 
   --OR ISNULL(O.TotalProvison,0) <> ISNULL(T.TotalProvison ,0)
   --)
   ------------For Changes Records
   --UPDATE A SET A.IsChanged='C'
   ------Select * 
   --from RBL_TEMPDB.DBO.TempInvestmentFinancialDetail A
   --INNER JOIN DBO.InvestmentFinancialDetail B 
   --ON  A.InvEntityId=B.InvEntityId
   --Where B.EffectiveToTimeKey= @vEffectiveto
   ---------------------------------------------------------------------------------------------------------------
   -------Expire the records
   --UPDATE AA
   --SET 
   -- EffectiveToTimeKey = @vEffectiveto,
   -- DateModified=CONVERT(DATE,GETDATE(),103),
   -- ModifiedBy='SSISUSER' 
   --FROM DBO.InvestmentFinancialDetail AA
   --WHERE AA.EffectiveToTimeKey = 49999
   --AND NOT EXISTS (SELECT 1 FROM RBL_TEMPDB.DBO.TempInvestmentFinancialDetail BB
   --    WHERE  AA.InvEntityId=BB.InvEntityId
   --    AND BB.EffectiveToTimeKey =49999
   --    )
   --INSERT INTO DBO.InvestmentFinancialDetail
   --     (	
   --       --[Time_Key]
   --      --[Inv_Key]
   --	  InvEntityId
   --      ,[HoldingNature]
   --      ,[CurrencyAlt_Key]
   --      ,[CurrencyConvRate]
   --      ,[BookType]
   --      ,[BookValue]
   --      ,[BookValueINR]
   --      ,[MTMValue]
   --      ,[MTMValueINR]
   --      ,[EncumberedMTM]
   --      ,[AssetClass_AltKey]
   --      ,[NPIDt]
   --      ,[TotalProvison]
   --      ,[AuthorisationStatus]
   --      ,[EffectiveFromTimeKey]
   --      ,[EffectiveToTimeKey]
   --      ,[CreatedBy]
   --      ,[DateCreated]
   --      ,[ModifiedBy]
   --      ,[DateModified]
   --      ,[ApprovedBy]
   --      ,[DateApproved]
   --		   )
   --SELECT
   --       --[Time_Key]
   --      --[Inv_Key]
   --	  InvEntityId
   --      ,[HoldingNature]
   --      ,[CurrencyAlt_Key]
   --      ,[CurrencyConvRate]
   --      ,[BookType]
   --      ,[BookValue]
   --      ,[BookValueINR]
   --      ,[MTMValue]
   --      ,[MTMValueINR]
   --      ,[EncumberedMTM]
   --      ,[AssetClass_AltKey]
   --      ,[NPIDt]
   --      ,[TotalProvison]
   --      ,[AuthorisationStatus]
   --      ,[EffectiveFromTimeKey]
   --      ,[EffectiveToTimeKey]
   --      ,[CreatedBy]
   --      ,[DateCreated]
   --      ,[ModifiedBy]
   --      ,[DateModified]
   --      ,[ApprovedBy]
   --      ,[DateApproved]
   --		   FROM RBL_TEMPDB.dbo.TempInvestmentFinancialDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')
   INSERT INTO RBL_MISDB_PROD.InvestmentFinancialDetail
     ( EntityKey, InvEntityId, RefInvID, HoldingNature, CurrencyAlt_Key, CurrencyConvRate, BookType, BookValue, BookValueINR, MTMValue, MTMValueINR, EncumberedMTM, AssetClass_AltKey, NPIDt, TotalProvison, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, DBTDate, LatestBSDate, Interest_DividendDueDate, Interest_DividendDueAmount, PartialRedumptionDueDate, PartialRedumptionSettledY_N, FLGDEG, DEGREASON, DPD, FLGUPG, UpgDate, PROVISIONALT_KEY, InitialAssetAlt_Key, InitialNPIDt, RefIssuerID, DPD_Maturity, DPD_DivOverdue, FinalAssetClassAlt_Key, PartialRedumptionDPD, Asset_Norm, BalanceSheetDate, ListedShares, DPD_BS_Date, ISIN, AssetClass, GL_Code, GL_Description, OVERDUE_AMOUNT, FlgSMA, SMA_Dt, SMA_Class, SMA_Reason, AddlProvision, AddlProvisionPer, MocBy, MOC_Date, FlgMoc, MOC_Reason )
     ( SELECT EntityKey ,
              InvEntityId ,
              RefInvID ,
              HoldingNature ,
              CurrencyAlt_Key ,
              CurrencyConvRate ,
              BookType ,
              BookValue ,
              BookValueINR ,
              MTMValue ,
              MTMValueINR ,
              EncumberedMTM ,
              AssetClass_AltKey ,
              NPIDt ,
              TotalProvison ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifiedBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              DBTDate ,
              LatestBSDate ,
              Interest_DividendDueDate ,
              Interest_DividendDueAmount ,
              PartialRedumptionDueDate ,
              PartialRedumptionSettledY_N ,
              FLGDEG ,
              DEGREASON ,
              DPD ,
              FLGUPG ,
              UpgDate ,
              PROVISIONALT_KEY ,
              NVL(InitialAssetAlt_Key, 1) InitialAssetAlt_Key  ,
              InitialNPIDt ,
              RefIssuerID ,
              DPD_Maturity ,
              DPD_DivOverdue ,
              NVL(FinalAssetClassAlt_Key, 1) FinalAssetClassAlt_Key  ,
              PartialRedumptionDPD ,
              NULL Asset_Norm  ,
              BalanceSheetDate ,
              ListedShares ,
              NULL DPD_BS_Date  ,
              NULL ISIN  ,
              NULL AssetClass  ,
              NULL GL_Code  ,
              NULL GL_Description  ,
              NULL OVERDUE_AMOUNT  ,
              NULL FlgSMA  ,
              NULL SMA_Dt  ,
              NULL SMA_Class  ,
              NULL SMA_Reason  ,
              NULL AddlProvision  ,
              NULL AddlProvisionPer  ,
              NULL MocBy  ,
              NULL MOC_Date  ,
              NULL FlgMoc  ,
              NULL MOC_Reason  
       FROM RBL_TEMPDB.TempInvestmentFinancialDetail T

       --Where ISNULL(T.IsChanged,'U') IN ('N','C')
       WHERE  InvEntityId IS NOT NULL );-- update O
   -- set  
   -- O.FLGDEG = T.FLGDEG
   --,O.DEGREASON = T.DEGREASON
   --,O.DPD = T.DPD
   --,O.FLGUPG = T.FLGUPG
   --,O.UpgDate = T.UpgDate
   --,O.PROVISIONALT_KEY = T.PROVISIONALT_KEY
   --,O.InitialAssetAlt_Key = T.InitialAssetAlt_Key
   --,O.InitialNPIDt = T.InitialNPIDt
   --,O.RefIssuerID = T.RefIssuerID
   --,O.DPD_Maturity = T.DPD_Maturity
   --,O.DPD_DivOverdue = T.DPD_DivOverdue
   --,O.FinalAssetClassAlt_Key = T.FinalAssetClassAlt_Key
   --FROM		dbo.InvestmentFinancialDetail O
   --INNER JOIN	dbo.InvestmentFinancialDetail T
   --on	O.InvEntityId=T.InvEntityId
   --and O.EffectiveToTimeKey=49999
   --AND T.EffectivefromTimeKey=@VEFFECTIVETO

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."INVESTMENTFINANCIALDETAIL_MAIN" TO "ADF_CDR_RBL_STGDB";
