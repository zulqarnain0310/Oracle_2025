--------------------------------------------------------
--  DDL for Procedure ACDAILYTXNDETAIL_TEMP_NEWDB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" 
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
-- Add the parameters for the stored procedure here

BEGIN

   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   -- Insert statements for procedure here
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TempAcDailyTxnDetail ';
   /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
   SELECT TimeKey 

     INTO v_vEffectiveFrom
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   SELECT TimeKey 

     INTO v_TimeKey
     FROM RBL_MISDB_010922_UAT.Automate_Advances 
    WHERE  EXT_FLG = 'Y';
   INSERT INTO TempAcDailyTxnDetail
     ( Branchcode, CustomerID, CustomerAcID, AccountEntityId, TxnDate, TxnType, TxnSubType, TxnTime, CurrencyAlt_Key, CurrencyConvRate, TxnAmount, TxnAmountInCurrency, ExtDate, TxnRefNo, TxnValueDate, MnemonicCode, Particular, AuthorisationStatus, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, Remark, TrueCredit, IsProcessed, Balance )
     ( 
       ----FINACLE DATA------
       SELECT NULL Branchcode ,--ETC  --PROFILE 

              ACBD.REFCUSTOMERID CustomerID ,--PROFILE 

              TXN.CustomerAcID CustomerAcID ,--PROFILE 

              ACBD.AccountEntityId AccountEntityId ,--PROFILE 

              '2021-06-01' ,-- TXN.TxnDate AS [TxnDate]  --PROFILE        t_AccountTrx  TrxDate

              'CREDIT' ,--TXN.TxnType AS  [TxnType]  --PROFILE      t_AccountTrx  TrxTypeID

              'RECOVERY' ,--TXN.TxnSubType AS [TxnSubType]  --PROFILE 

              NULL TxnTime ,--PROFILE     t_AccountTrx  TrxDate

              NULL ,--DC.CurrencyAlt_Key AS [CurrencyAlt_Key]  --PROFILE    t_AccountTrx  TrxCurrencyID

              NULL ,--DCC.ConvRate AS [CurrencyConvRate]  --PROFILE 

              TXN.CurQtrCredit TxnAmountINR ,--AS [TxnAmount]  --PROFILE   t_AccountTrx  TrxAmount

              NULL ,--TXN.TxnAmountinCurrency AS [TxnAmountInCurrency]   --t_AccountTrx  TrxAmount

              v_DATE ExtDate  ,
              NULL TxnRefNo ,--PROFILE    --t_AccountTrx AccountTrxID

              NULL TxnValueDate ,--PROFILE   --t_AccountTrx   ValueDate

              NULL MnemonicCode ,--ETC  --PROFILE 	  t_AccountTrx  TrxTypeID

              'PREPARE CUR QTR CREDIT AS RECOVERY' ,--TXN.TxnParticulars AS [Particular]  --PROFILE    t_AccountTrx  TrxDescription

              NULL AuthorisationStatus  ,
              'SSISUSER' CreatedBy ,--PROFILE   t_AccountTrx  CreatedBy

              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL Remark ,--PROFILE    t_AccountTrx   Remarks

              NULL TrueCredit  ,
              NULL IsProcessed  ,
              NULL Balance --PROFILE 

       FROM RBL_STGDB.ACCOUNT_SOURCESYSTEM01_STG txn --PROFILE 	

              LEFT JOIN TempAdvAcBasicDetail ACBD   ON ACBD.CustomerAcID = TXN.CustomerAcID

       --LEFT JOIN RBL_MISDB.dbo.DimCurrency DC	ON LTRIM(RTRIM(ISNULL(DC.CurrencyCode,'')))=TXN.TxnCurrency

       --and DC.EffectiveFromTimeKey<=@TimeKey AND DC.EffectiveToTimeKey>=@TimeKey

       --LEFT join RBL_MISDB.dbo.DimCurCovRate DCC on DCC.CurrencyCode= DC.CurrencyCode AND DCC.ConvDate=@DATE

       --and DCC.EffectiveFromTimeKey<=@TimeKey AND DCC.EffectiveToTimeKey>=@TimeKey
       WHERE  TXN.CurQtrCredit > 0
       UNION 

       ----FINACLE DATA------
       SELECT NULL Branchcode ,--ETC  --PROFILE 

              ACBD.REFCUSTOMERID CustomerID ,--PROFILE 

              TXN.AccountID CustomerAcID ,--PROFILE 

              ACBD.AccountEntityId AccountEntityId ,--PROFILE 

              TXN.TxnDate TxnDate ,--PROFILE        t_AccountTrx  TrxDate

              TXN.TxnType TxnType ,--PROFILE      t_AccountTrx  TrxTypeID

              TXN.TxnSubType TxnSubType ,--PROFILE 

              NULL TxnTime ,--PROFILE     t_AccountTrx  TrxDate

              DC.CurrencyAlt_Key CurrencyAlt_Key ,--PROFILE    t_AccountTrx  TrxCurrencyID

              DCC.ConvRate CurrencyConvRate ,--PROFILE 

              TXN.TxnAmountINR TxnAmount ,--PROFILE   t_AccountTrx  TrxAmount

              TXN.TxnAmountinCurrency TxnAmountInCurrency ,--t_AccountTrx  TrxAmount

              v_DATE ExtDate  ,
              NULL TxnRefNo ,--PROFILE    --t_AccountTrx AccountTrxID

              NULL TxnValueDate ,--PROFILE   --t_AccountTrx   ValueDate

              NULL MnemonicCode ,--ETC  --PROFILE 	  t_AccountTrx  TrxTypeID

              TXN.TxnParticulars Particular ,--PROFILE    t_AccountTrx  TrxDescription

              NULL AuthorisationStatus  ,
              'SSISUSER' CreatedBy ,--PROFILE   t_AccountTrx  CreatedBy

              SYSDATE DateCreated  ,
              NULL ModifiedBy  ,
              NULL DateModified  ,
              NULL ApprovedBy  ,
              NULL DateApproved  ,
              NULL Remark ,--PROFILE    t_AccountTrx   Remarks

              NULL TrueCredit  ,
              NULL IsProcessed  ,
              NULL Balance --PROFILE 

       FROM RBL_STGDB.TXN_SOURCESYSTEM04_STG txn --PROFILE 	

              LEFT JOIN TempAdvAcBasicDetail ACBD   ON ACBD.CustomerAcID = TXN.AccountID
              LEFT JOIN RBL_MISDB_010922_UAT.DimCurrency DC   ON LTRIM(RTRIM(NVL(DC.CurrencyCode, ' '))) = TXN.TxnCurrency
              AND DC.EffectiveFromTimeKey <= v_TimeKey
              AND DC.EffectiveToTimeKey >= v_TimeKey
              LEFT JOIN RBL_MISDB_010922_UAT.DimCurCovRate DCC   ON DCC.CurrencyCode = DC.CurrencyCode
              AND DCC.ConvDate = v_DATE
              AND DCC.EffectiveFromTimeKey <= v_TimeKey
              AND DCC.EffectiveToTimeKey >= v_TimeKey );

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_TEMP_RBL_TEMPDB"."ACDAILYTXNDETAIL_TEMP_NEWDB" TO "ADF_CDR_RBL_STGDB";
