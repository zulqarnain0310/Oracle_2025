--------------------------------------------------------
--  DDL for Procedure ACCTCALHISTMERGE_LOOP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" 
----USE [RBL_MISDB]
 ----GO
 ----/****** Object:  StoredProcedure [PRO].[CustAcctCalHistMerge]    Script Date: 10/17/2021 7:16:07 PM ******/
 ----SET ANSI_NULLS ON
 ----GO
 ----SET QUOTED_IDENTIFIER ON
 ----GO
 ------ =============================================
 ------ Author:		<Author,,Name>
 ------ Create date: <Create Date,,>
 ------ Description:	<Description,,>
 ------ =============================================
 ----/*   ADD NEW OLUMN
 ----	ALTER TABLE PRO.PUI_CAL ADD IsChanged CHAR(1)
 ----	ALTER TABLE PRO.ADVACRESTRUCTURECAL ADD IsChanged CHAR(1)
 ----	ALTER TABLE PRO.ACCOUNTCAL ADD IsChanged CHAR(1)
 ----	ALTER TABLE PRO.CUSTOMERCAL ADD IsChanged CHAR(1)
 ----*/
 -----exec [PRO].[AcctCalHistMerge_loop] @date1='2021-07-11', @date2='2021-07-31'

(
  ---- Add the parameters for the stored procedure here
  v_date1 IN VARCHAR2 DEFAULT ' ' ,
  v_date2 IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_VEFFECTIVETO NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
   v_RowCnt NUMBER(5,0) ;
   v_RowNo NUMBER(5,0) := 1;

BEGIN
  SELECT COUNT(1)  INTO v_RowCnt
     FROM GTT_TIMEKEY  ;

   DELETE FROM GTT_TIMEKEY;
   UTILS.IDENTITY_RESET('GTT_TIMEKEY');

   INSERT INTO GTT_TIMEKEY(TIMEKEY,EXTDATE) SELECT Timekey ,
                                 DATE_ 
                                 --,ROW_NUMBER() OVER ( ORDER BY TIMEKEY  ) ROWID_  
        FROM RBL_MISDB_PROD.sysdaymatrix 
       WHERE  date_ BETWEEN v_date1 AND v_date2;
   /*  CUSTOMER DATA MERGE */
   WHILE v_RowNo <= v_RowCnt 
   LOOP 

      BEGIN
         SELECT Timekey ,
                Timekey - 1 

           INTO v_Timekey,
                v_VEFFECTIVETO
           FROM GTT_TIMEKEY 
          WHERE  ROWID = (SELECT MAX(ROWID) FROM GTT_TIMEKEY);
         SELECT Timekey ,
                Timekey - 1 

           INTO v_Timekey,
                v_VEFFECTIVETO
           FROM GTT_TIMEKEY 
          WHERE  ROWID = (SELECT MAX(ROWID) FROM GTT_TIMEKEY);
         /*  ACCOUNT DATA MERGE */
         DELETE FROM GTT_ACDATA;
         UTILS.IDENTITY_RESET('GTT_ACDATA');

         INSERT INTO GTT_ACDATA ( ENTITYKEY,	ACCOUNTENTITYID,	UCIFENTITYID,	CUSTOMERENTITYID,	CUSTOMERACID,	REFCUSTOMERID,	SOURCESYSTEMCUSTOMERID,	UCIF_ID,	BRANCHCODE,	FACILITYTYPE,	ACOPENDT,	FIRSTDTOFDISB,	PRODUCTALT_KEY,	SCHEMEALT_KEY,	SUBSECTORALT_KEY,	SPLCATG1ALT_KEY,	SPLCATG2ALT_KEY,	SPLCATG3ALT_KEY,	SPLCATG4ALT_KEY,	SOURCEALT_KEY,	ACTSEGMENTCODE,	INTTRATE,	BALANCE,	BALANCEINCRNCY,	CURRENCYALT_KEY,	DRAWINGPOWER,	CURRENTLIMIT,	CURRENTLIMITDT,	CONTIEXCESSDT,	STOCKSTDT,	DEBITSINCEDT,	LASTCRDATE,	INTTSERVICED,	INTNOTSERVICEDDT,	OVERDUEAMT,	OVERDUESINCEDT,	REVIEWDUEDT,	SECURITYVALUE,	DFVAMT,	GOVTGTYAMT,	COVERGOVGUR,	WRITEOFFAMOUNT,	UNADJSUBSIDY,	CREDITSINCEDT,	DEGREASON,	ASSET_NORM,	REFPERIODMAX,	REFPERIODOVERDUE,	REFPERIODOVERDRAWN,	REFPERIODNOCREDIT,	REFPERIODINTSERVICE,	REFPERIODSTKSTATEMENT,	REFPERIODREVIEW,	NETBALANCE,	APPRRV,	SECUREDAMT,	UNSECUREDAMT,	PROVDFV,	PROVSECURED,	PROVUNSECURED,	PROVCOVERGOVGUR,	ADDLPROVISION,	TOTALPROVISION,	BANKPROVSECURED,	BANKPROVUNSECURED,	BANKTOTALPROVISION,	RBIPROVSECURED,	RBIPROVUNSECURED,	RBITOTALPROVISION,	INITIALNPADT,	FINALNPADT,	SMA_DT,	UPGDATE,	INITIALASSETCLASSALT_KEY,	FINALASSETCLASSALT_KEY,	PROVISIONALT_KEY,	PNPA_REASON,	SMA_CLASS,	SMA_REASON,	FLGMOC,	MOC_DT,	COMMONMOCTYPEALT_KEY,	FLGDEG,	FLGDIRTYROW,	FLGINMONTH,	FLGSMA,	FLGPNPA,	FLGUPG,	FLGFITL,	FLGABINITIO,	NPA_DAYS,	REFPERIODOVERDUEUPG,	REFPERIODOVERDRAWNUPG,	REFPERIODNOCREDITUPG,	REFPERIODINTSERVICEUPG,	REFPERIODSTKSTATEMENTUPG,	REFPERIODREVIEWUPG,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	APPGOVGUR,	USEDRV,	COMPUTEDCLAIM,	UPG_RELAX_MSME,	DEG_RELAX_MSME,	PNPA_DATE,	NPA_REASON,	PNPAASSETCLASSALT_KEY,	DISBAMOUNT,	PRINCOUTSTD,	PRINCOVERDUE,	PRINCOVERDUESINCEDT,	INTOVERDUE,	INTOVERDUESINCEDT,	OTHEROVERDUE,	OTHEROVERDUESINCEDT,	RELATIONSHIPNUMBER,	ACCOUNTFLAG,	COMMERCIALFLAG_ALTKEY,	LIABILITY,	CD,	ACCOUNTSTATUS,	ACCOUNTBLKCODE1,	ACCOUNTBLKCODE2,	EXPOSURETYPE,	MTM_VALUE,	BANKASSETCLASS,	NPATYPE,	SECAPP,	BORROWERTYPEID,	LINECODE,	PROVPERSECURED,	PROVPERUNSECURED,	MOCREASON,	ADDLPROVISIONPER,	FLGINFRA,	REPOSSESSIONDATE,	DERECOGNISEDINTEREST1,	DERECOGNISEDINTEREST2,	PRODUCTCODE,	FLGLCBG,	UNSERVIEDINT,	PREQTRCREDIT,	PRVQTRINT,	CURQTRCREDIT,	CURQTRINT,	ORIGINALBRANCHCODE,	ADVANCERECOVERY,	NOTIONALINTTAMT,	PRVASSETCLASSALT_KEY,	MOCTYPE,	FLGSECURED,	REPOSSESSION,	RCPENDING,	PAYMENTPENDING,	WHEELCASE,	CUSTOMERLEVELMAXPER,	FINALPROVISIONPER,	ISIBPC,	ISSECURITISED,	RFA,	ISNONCOOPERATIVE,	SARFAESI,	WEAKACCOUNT,	PUI,	FLGFRAUD,	FLGRESTRUCTURE,	RESTRUCTUREDATE,	SARFAESIDATE,	FLGUNUSUALBOUNCE,	UNUSUALBOUNCEDATE,	FLGUNCLEAREDEFFECT,	UNCLEAREDEFFECTDATE,	FRAUDDATE,	WEAKACCOUNTDATE,	SCREENFLAG,	CHANGEFIELD,EntityKeyNew,IsChanged)
         	SELECT ENTITYKEY,	ACCOUNTENTITYID,	UCIFENTITYID,	CUSTOMERENTITYID,	CUSTOMERACID,	REFCUSTOMERID,	SOURCESYSTEMCUSTOMERID,	UCIF_ID,	BRANCHCODE,	FACILITYTYPE,	ACOPENDT,	FIRSTDTOFDISB,	PRODUCTALT_KEY,	SCHEMEALT_KEY,	SUBSECTORALT_KEY,	SPLCATG1ALT_KEY,	SPLCATG2ALT_KEY,	SPLCATG3ALT_KEY,	SPLCATG4ALT_KEY,	SOURCEALT_KEY,	ACTSEGMENTCODE,	INTTRATE,	BALANCE,	BALANCEINCRNCY,	CURRENCYALT_KEY,	DRAWINGPOWER,	CURRENTLIMIT,	CURRENTLIMITDT,	CONTIEXCESSDT,	STOCKSTDT,	DEBITSINCEDT,	LASTCRDATE,	INTTSERVICED,	INTNOTSERVICEDDT,	OVERDUEAMT,	OVERDUESINCEDT,	REVIEWDUEDT,	SECURITYVALUE,	DFVAMT,	GOVTGTYAMT,	COVERGOVGUR,	WRITEOFFAMOUNT,	UNADJSUBSIDY,	CREDITSINCEDT,	DEGREASON,	ASSET_NORM,	REFPERIODMAX,	REFPERIODOVERDUE,	REFPERIODOVERDRAWN,	REFPERIODNOCREDIT,	REFPERIODINTSERVICE,	REFPERIODSTKSTATEMENT,	REFPERIODREVIEW,	NETBALANCE,	APPRRV,	SECUREDAMT,	UNSECUREDAMT,	PROVDFV,	PROVSECURED,	PROVUNSECURED,	PROVCOVERGOVGUR,	ADDLPROVISION,	TOTALPROVISION,	BANKPROVSECURED,	BANKPROVUNSECURED,	BANKTOTALPROVISION,	RBIPROVSECURED,	RBIPROVUNSECURED,	RBITOTALPROVISION,	INITIALNPADT,	FINALNPADT,	SMA_DT,	UPGDATE,	INITIALASSETCLASSALT_KEY,	FINALASSETCLASSALT_KEY,	PROVISIONALT_KEY,	PNPA_REASON,	SMA_CLASS,	SMA_REASON,	FLGMOC,	MOC_DT,	COMMONMOCTYPEALT_KEY,	FLGDEG,	FLGDIRTYROW,	FLGINMONTH,	FLGSMA,	FLGPNPA,	FLGUPG,	FLGFITL,	FLGABINITIO,	NPA_DAYS,	REFPERIODOVERDUEUPG,	REFPERIODOVERDRAWNUPG,	REFPERIODNOCREDITUPG,	REFPERIODINTSERVICEUPG,	REFPERIODSTKSTATEMENTUPG,	REFPERIODREVIEWUPG,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	APPGOVGUR,	USEDRV,	COMPUTEDCLAIM,	UPG_RELAX_MSME,	DEG_RELAX_MSME,	PNPA_DATE,	NPA_REASON,	PNPAASSETCLASSALT_KEY,	DISBAMOUNT,	PRINCOUTSTD,	PRINCOVERDUE,	PRINCOVERDUESINCEDT,	INTOVERDUE,	INTOVERDUESINCEDT,	OTHEROVERDUE,	OTHEROVERDUESINCEDT,	RELATIONSHIPNUMBER,	ACCOUNTFLAG,	COMMERCIALFLAG_ALTKEY,	LIABILITY,	CD,	ACCOUNTSTATUS,	ACCOUNTBLKCODE1,	ACCOUNTBLKCODE2,	EXPOSURETYPE,	MTM_VALUE,	BANKASSETCLASS,	NPATYPE,	SECAPP,	BORROWERTYPEID,	LINECODE,	PROVPERSECURED,	PROVPERUNSECURED,	MOCREASON,	ADDLPROVISIONPER,	FLGINFRA,	REPOSSESSIONDATE,	DERECOGNISEDINTEREST1,	DERECOGNISEDINTEREST2,	PRODUCTCODE,	FLGLCBG,	UNSERVIEDINT,	PREQTRCREDIT,	PRVQTRINT,	CURQTRCREDIT,	CURQTRINT,	ORIGINALBRANCHCODE,	ADVANCERECOVERY,	NOTIONALINTTAMT,	PRVASSETCLASSALT_KEY,	MOCTYPE,	FLGSECURED,	REPOSSESSION,	RCPENDING,	PAYMENTPENDING,	WHEELCASE,	CUSTOMERLEVELMAXPER,	FINALPROVISIONPER,	ISIBPC,	ISSECURITISED,	RFA,	ISNONCOOPERATIVE,	SARFAESI,	WEAKACCOUNT,	PUI,	FLGFRAUD,	FLGRESTRUCTURE,	RESTRUCTUREDATE,	SARFAESIDATE,	FLGUNUSUALBOUNCE,	UNUSUALBOUNCEDATE,	FLGUNCLEAREDEFFECT,	UNCLEAREDEFFECTDATE,	FRAUDDATE,	WEAKACCOUNTDATE,	SCREENFLAG,	CHANGEFIELD
                 ,UTILS.CONVERT_TO_NUMBER(0,19,0) EntityKeyNew  
                 ,'N' IsChanged  
         	  FROM MAIN_PRO.AccountCal_Hist 
         	 WHERE  EffectiveFromTimeKey = v_TimeKey ;
         IF 1 = 1 THEN
          DECLARE
            /*  New Customers Ac Key ID Update  */
            v_EntityKeyAc NUMBER(19,0) := 0;

         BEGIN
            MERGE INTO GTT_ACDATA T
            USING (SELECT T.ROWID row_id, 'E'
            FROM MAIN_PRO.AccountCal_Hist O
                   JOIN GTT_ACDATA T   ON O.AccountEntityID = T.AccountEntityID
                   AND O.EffectiveToTimeKey = 49999 ) src
            ON ( T.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET T.IsChanged = 'E';
            MERGE INTO GTT_ACDATA T 
            USING (SELECT T.ROWID row_id, 'C'
            FROM MAIN_PRO.AccountCal_Hist O
                   JOIN GTT_ACDATA T   ON O.AccountEntityID = T.AccountEntityID
                   AND O.EffectiveToTimeKey = 49999 
             WHERE ( NVL(O.UcifEntityID, 0) <> NVL(T.UcifEntityID, 0)
              OR NVL(O.CustomerEntityID, 0) <> NVL(T.CustomerEntityID, 0)
              OR NVL(O.CustomerAcID, ' ') <> NVL(T.CustomerAcID, ' ')
              OR NVL(O.RefCustomerID, ' ') <> NVL(T.RefCustomerID, ' ')
              OR NVL(O.SourceSystemCustomerID, ' ') <> NVL(T.SourceSystemCustomerID, ' ')
              OR NVL(O.UCIF_ID, ' ') <> NVL(T.UCIF_ID, ' ')
              OR NVL(O.BranchCode, ' ') <> NVL(T.BranchCode, ' ')
              OR NVL(O.FacilityType, ' ') <> NVL(T.FacilityType, ' ')
              OR NVL(O.AcOpenDt, '1900-01-01') <> NVL(T.AcOpenDt, '1900-01-01')
              OR NVL(O.FirstDtOfDisb, '1900-01-01') <> NVL(T.FirstDtOfDisb, '1900-01-01')
              OR NVL(O.ProductAlt_Key, 0) <> NVL(T.ProductAlt_Key, 0)
              OR NVL(O.SchemeAlt_key, 0) <> NVL(T.SchemeAlt_key, 0)
              OR NVL(O.SubSectorAlt_Key, 0) <> NVL(T.SubSectorAlt_Key, 0)
              OR NVL(O.SplCatg1Alt_Key, 0) <> NVL(T.SplCatg1Alt_Key, 0)
              OR NVL(O.SplCatg2Alt_Key, 0) <> NVL(T.SplCatg2Alt_Key, 0)
              OR NVL(O.SplCatg3Alt_Key, 0) <> NVL(T.SplCatg3Alt_Key, 0)
              OR NVL(O.SplCatg4Alt_Key, 0) <> NVL(T.SplCatg4Alt_Key, 0)
              OR NVL(O.SourceAlt_Key, 0) <> NVL(T.SourceAlt_Key, 0)
              OR NVL(O.ActSegmentCode, ' ') <> NVL(T.ActSegmentCode, ' ')
              OR NVL(O.InttRate, 0) <> NVL(T.InttRate, 0)
              OR NVL(O.Balance, 0) <> NVL(T.Balance, 0)
              OR NVL(O.BalanceInCrncy, 0) <> NVL(T.BalanceInCrncy, 0)
              OR NVL(O.CurrencyAlt_Key, 0) <> NVL(T.CurrencyAlt_Key, 0)
              OR NVL(O.DrawingPower, 0) <> NVL(T.DrawingPower, 0)
              OR NVL(O.CurrentLimit, 0) <> NVL(T.CurrentLimit, 0)
              OR NVL(O.CurrentLimitDt, '1900-01-01') <> NVL(T.CurrentLimitDt, '1900-01-01')
              OR NVL(O.ContiExcessDt, '1900-01-01') <> NVL(T.ContiExcessDt, '1900-01-01')
              OR NVL(O.StockStDt, '1900-01-01') <> NVL(T.StockStDt, '1900-01-01')
              OR NVL(O.DebitSinceDt, '1900-01-01') <> NVL(T.DebitSinceDt, '1900-01-01')
              OR NVL(O.LastCrDate, '1900-01-01') <> NVL(T.LastCrDate, '1900-01-01')
              OR NVL(O.InttServiced, ' ') <> NVL(T.InttServiced, ' ')
              OR NVL(O.IntNotServicedDt, '1900-01-01') <> NVL(T.IntNotServicedDt, '1900-01-01')
              OR NVL(O.OverdueAmt, 0) <> NVL(T.OverdueAmt, 0)
              OR NVL(O.OverDueSinceDt, '1900-01-01') <> NVL(T.OverDueSinceDt, '1900-01-01')
              OR NVL(O.ReviewDueDt, '1900-01-01') <> NVL(T.ReviewDueDt, '1900-01-01')
              OR NVL(O.SecurityValue, 0) <> NVL(T.SecurityValue, 0)
              OR NVL(O.DFVAmt, 0) <> NVL(T.DFVAmt, 0)
              OR NVL(O.GovtGtyAmt, 0) <> NVL(T.GovtGtyAmt, 0)
              OR NVL(O.CoverGovGur, 0) <> NVL(T.CoverGovGur, 0)
              OR NVL(O.WriteOffAmount, 0) <> NVL(T.WriteOffAmount, 0)
              OR NVL(O.UnAdjSubSidy, 0) <> NVL(T.UnAdjSubSidy, 0)
              OR NVL(O.CreditsinceDt, '1900-01-01') <> NVL(T.CreditsinceDt, '1900-01-01')
              OR CAST(NVL(O.DegReason, ' ') AS VARCHAR(1000)) <> CAST(NVL(T.DegReason, ' ') AS VARCHAR(1000))
              OR NVL(O.Asset_Norm, ' ') <> NVL(T.Asset_Norm, ' ')
              OR NVL(O.REFPeriodMax, 0) <> NVL(T.REFPeriodMax, 0)
              OR NVL(O.RefPeriodOverdue, 0) <> NVL(T.RefPeriodOverdue, 0)
              OR NVL(O.RefPeriodOverDrawn, 0) <> NVL(T.RefPeriodOverDrawn, 0)
              OR NVL(O.RefPeriodNoCredit, 0) <> NVL(T.RefPeriodNoCredit, 0)
              OR NVL(O.RefPeriodIntService, 0) <> NVL(T.RefPeriodIntService, 0)
              OR NVL(O.RefPeriodStkStatement, 0) <> NVL(T.RefPeriodStkStatement, 0)
              OR NVL(O.RefPeriodReview, 0) <> NVL(T.RefPeriodReview, 0)
              OR NVL(O.NetBalance, 0) <> NVL(T.NetBalance, 0)
              OR NVL(O.ApprRV, 0) <> NVL(T.ApprRV, 0)
              OR NVL(O.SecuredAmt, 0) <> NVL(T.SecuredAmt, 0)
              OR NVL(O.UnSecuredAmt, 0) <> NVL(T.UnSecuredAmt, 0)
              OR NVL(O.ProvDFV, 0) <> NVL(T.ProvDFV, 0)
              OR NVL(O.Provsecured, 0) <> NVL(T.Provsecured, 0)
              OR NVL(O.ProvUnsecured, 0) <> NVL(T.ProvUnsecured, 0)
              OR NVL(O.ProvCoverGovGur, 0) <> NVL(T.ProvCoverGovGur, 0)
              OR NVL(O.AddlProvision, 0) <> NVL(T.AddlProvision, 0)
              OR NVL(O.TotalProvision, 0) <> NVL(T.TotalProvision, 0)
              OR NVL(O.BankProvsecured, 0) <> NVL(T.BankProvsecured, 0)
              OR NVL(O.BankProvUnsecured, 0) <> NVL(T.BankProvUnsecured, 0)
              OR NVL(O.BankTotalProvision, 0) <> NVL(T.BankTotalProvision, 0)
              OR NVL(O.RBIProvsecured, 0) <> NVL(T.RBIProvsecured, 0)
              OR NVL(O.RBIProvUnsecured, 0) <> NVL(T.RBIProvUnsecured, 0)
              OR NVL(O.RBITotalProvision, 0) <> NVL(T.RBITotalProvision, 0)
              OR NVL(O.InitialNpaDt, '1900-01-01') <> NVL(T.InitialNpaDt, '1900-01-01')
              OR NVL(O.FinalNpaDt, '1900-01-01') <> NVL(T.FinalNpaDt, '1900-01-01')
              OR NVL(O.SMA_Dt, '1900-01-01') <> NVL(T.SMA_Dt, '1900-01-01')
              OR NVL(O.UpgDate, '1900-01-01') <> NVL(T.UpgDate, '1900-01-01')
              OR NVL(O.InitialAssetClassAlt_Key, 0) <> NVL(T.InitialAssetClassAlt_Key, 0)
              OR NVL(O.FinalAssetClassAlt_Key, 0) <> NVL(T.FinalAssetClassAlt_Key, 0)
              OR NVL(O.ProvisionAlt_Key, 0) <> NVL(T.ProvisionAlt_Key, 0)
              OR CAST(NVL(O.PNPA_Reason, ' ') AS VARCHAR(1000)) <> CAST(NVL(T.PNPA_Reason, ' ') AS VARCHAR(1000))              
              OR NVL(O.SMA_Class, ' ') <> NVL(T.SMA_Class, ' ')
              OR CAST(NVL(O.SMA_Reason, ' ') AS VARCHAR(1000)) <> CAST(NVL(T.SMA_Reason, ' ') AS VARCHAR(1000))
              OR NVL(O.FlgMoc, ' ') <> NVL(T.FlgMoc, ' ')
              OR NVL(O.MOC_Dt, '1900-01-01') <> NVL(T.MOC_Dt, '1900-01-01')
              OR NVL(O.CommonMocTypeAlt_Key, 0) <> NVL(T.CommonMocTypeAlt_Key, 0)
              OR NVL(O.FlgDeg, ' ') <> NVL(T.FlgDeg, ' ')
              OR NVL(O.FlgDirtyRow, ' ') <> NVL(T.FlgDirtyRow, ' ')
              OR NVL(O.FlgInMonth, ' ') <> NVL(T.FlgInMonth, ' ')
              OR NVL(O.FlgSMA, ' ') <> NVL(T.FlgSMA, ' ')
              OR NVL(O.FlgPNPA, ' ') <> NVL(T.FlgPNPA, ' ')
              OR NVL(O.FlgUpg, ' ') <> NVL(T.FlgUpg, ' ')
              OR NVL(O.FlgFITL, ' ') <> NVL(T.FlgFITL, ' ')
              OR NVL(O.FlgAbinitio, ' ') <> NVL(T.FlgAbinitio, ' ')
              OR NVL(O.NPA_Days, 0) <> NVL(T.NPA_Days, 0)
              OR NVL(O.RefPeriodOverdueUPG, 0) <> NVL(T.RefPeriodOverdueUPG, 0)
              OR NVL(O.RefPeriodOverDrawnUPG, 0) <> NVL(T.RefPeriodOverDrawnUPG, 0)
              OR NVL(O.RefPeriodNoCreditUPG, 0) <> NVL(T.RefPeriodNoCreditUPG, 0)
              OR NVL(O.RefPeriodIntServiceUPG, 0) <> NVL(T.RefPeriodIntServiceUPG, 0)
              OR NVL(O.RefPeriodStkStatementUPG, 0) <> NVL(T.RefPeriodStkStatementUPG, 0)
              OR NVL(O.RefPeriodReviewUPG, 0) <> NVL(T.RefPeriodReviewUPG, 0)
              OR NVL(O.AppGovGur, 0) <> NVL(T.AppGovGur, 0)
              OR NVL(O.UsedRV, 0) <> NVL(T.UsedRV, 0)
              OR NVL(O.ComputedClaim, 0) <> NVL(T.ComputedClaim, 0)
              OR NVL(O.UPG_RELAX_MSME, ' ') <> NVL(T.UPG_RELAX_MSME, ' ')
              OR NVL(O.DEG_RELAX_MSME, ' ') <> NVL(T.DEG_RELAX_MSME, ' ')
              OR NVL(O.PNPA_DATE, '1900-01-01') <> NVL(T.PNPA_DATE, '1900-01-01')
              OR CAST(NVL(O.NPA_Reason, ' ') AS VARCHAR(1000)) <> CAST(NVL(T.NPA_Reason, ' ') AS VARCHAR(1000))
              OR NVL(O.PnpaAssetClassAlt_key, 0) <> NVL(T.PnpaAssetClassAlt_key, 0)
              OR NVL(O.DisbAmount, 0) <> NVL(T.DisbAmount, 0)
              OR NVL(O.PrincOutStd, 0) <> NVL(T.PrincOutStd, 0)
              OR NVL(O.PrincOverdue, 0) <> NVL(T.PrincOverdue, 0)
              OR NVL(O.PrincOverdueSinceDt, '1900-01-01') <> NVL(T.PrincOverdueSinceDt, '1900-01-01')
              OR NVL(O.IntOverdue, 0) <> NVL(T.IntOverdue, 0)
              OR NVL(O.IntOverdueSinceDt, '1900-01-01') <> NVL(T.IntOverdueSinceDt, '1900-01-01')
              OR NVL(O.OtherOverdue, 0) <> NVL(T.OtherOverdue, 0)
              OR NVL(O.OtherOverdueSinceDt, '1900-01-01') <> NVL(T.OtherOverdueSinceDt, '1900-01-01')
              OR NVL(O.RelationshipNumber, ' ') <> NVL(T.RelationshipNumber, ' ')
              OR NVL(O.AccountFlag, ' ') <> NVL(T.AccountFlag, ' ')
              OR NVL(O.CommercialFlag_AltKey, 0) <> NVL(T.CommercialFlag_AltKey, 0)
              OR NVL(O.Liability, ' ') <> NVL(T.Liability, ' ')
              OR NVL(O.CD, ' ') <> NVL(T.CD, ' ')
              OR NVL(O.AccountStatus, ' ') <> NVL(T.AccountStatus, ' ')
              OR NVL(O.AccountBlkCode1, ' ') <> NVL(T.AccountBlkCode1, ' ')
              OR NVL(O.AccountBlkCode2, ' ') <> NVL(T.AccountBlkCode2, ' ')
              OR NVL(O.ExposureType, ' ') <> NVL(T.ExposureType, ' ')
              OR NVL(O.Mtm_Value, 0) <> NVL(T.Mtm_Value, 0)
              OR NVL(O.BankAssetClass, ' ') <> NVL(T.BankAssetClass, ' ')
              OR NVL(O.NpaType, ' ') <> NVL(T.NpaType, ' ')
              OR NVL(O.SecApp, ' ') <> NVL(T.SecApp, ' ')
              OR NVL(O.BorrowerTypeID, 0) <> NVL(T.BorrowerTypeID, 0)
              OR NVL(O.LineCode, ' ') <> NVL(T.LineCode, ' ')
              OR NVL(O.ProvPerSecured, 0) <> NVL(T.ProvPerSecured, 0)
              OR NVL(O.ProvPerUnSecured, 0) <> NVL(T.ProvPerUnSecured, 0)
              OR NVL(O.MOCReason, ' ') <> NVL(T.MOCReason, ' ')
              OR NVL(O.AddlProvisionPer, 0) <> NVL(T.AddlProvisionPer, 0)
              OR NVL(O.FlgINFRA, ' ') <> NVL(T.FlgINFRA, ' ')
              OR NVL(O.RepossessionDate, '1900-01-01') <> NVL(T.RepossessionDate, '1900-01-01')
              OR NVL(O.DerecognisedInterest1, 0) <> NVL(T.DerecognisedInterest1, 0)
              OR NVL(O.DerecognisedInterest2, 0) <> NVL(T.DerecognisedInterest2, 0)
              OR NVL(O.ProductCode, ' ') <> NVL(T.ProductCode, ' ')
              OR NVL(O.FlgLCBG, ' ') <> NVL(T.FlgLCBG, ' ')
              OR NVL(O.unserviedint, 0) <> NVL(T.unserviedint, 0)
              OR NVL(O.PreQtrCredit, 0) <> NVL(T.PreQtrCredit, 0)
              OR NVL(O.PrvQtrInt, 0) <> NVL(T.PrvQtrInt, 0)
              OR NVL(O.CurQtrCredit, 0) <> NVL(T.CurQtrCredit, 0)
              OR NVL(O.CurQtrInt, 0) <> NVL(T.CurQtrInt, 0)
              OR NVL(O.OriginalBranchcode, ' ') <> NVL(T.OriginalBranchcode, ' ')
              OR NVL(O.AdvanceRecovery, 0) <> NVL(T.AdvanceRecovery, 0)
              OR NVL(O.NotionalInttAmt, 0) <> NVL(T.NotionalInttAmt, 0)
              OR NVL(O.PrvAssetClassAlt_Key, 0) <> NVL(T.PrvAssetClassAlt_Key, 0)
              OR NVL(O.MOCTYPE, ' ') <> NVL(T.MOCTYPE, ' ')
              OR NVL(O.FlgSecured, ' ') <> NVL(T.FlgSecured, ' ')
              OR NVL(O.RePossession, ' ') <> NVL(T.RePossession, ' ')
              OR NVL(O.RCPending, ' ') <> NVL(T.RCPending, ' ')
              OR NVL(O.PaymentPending, ' ') <> NVL(T.PaymentPending, ' ')
              OR NVL(O.WheelCase, ' ') <> NVL(T.WheelCase, ' ')
              OR NVL(O.CustomerLevelMaxPer, 0) <> NVL(T.CustomerLevelMaxPer, 0)
              OR NVL(O.FinalProvisionPer, 0) <> NVL(T.FinalProvisionPer, 0)
              OR NVL(O.IsIBPC, ' ') <> NVL(T.IsIBPC, ' ')
              OR NVL(O.IsSecuritised, ' ') <> NVL(T.IsSecuritised, ' ')
              OR NVL(O.RFA, ' ') <> NVL(T.RFA, ' ')
              OR NVL(O.IsNonCooperative, ' ') <> NVL(T.IsNonCooperative, ' ')
              OR NVL(O.Sarfaesi, ' ') <> NVL(T.Sarfaesi, ' ')
              OR NVL(O.WeakAccount, ' ') <> NVL(T.WeakAccount, ' ')
              OR NVL(O.PUI, ' ') <> NVL(T.PUI, ' ')
              OR NVL(O.FlgFraud, ' ') <> NVL(T.FlgFraud, ' ')
              OR NVL(O.FlgRestructure, ' ') <> NVL(T.FlgRestructure, ' ')
              OR NVL(O.RestructureDate, '1900-01-01') <> NVL(T.RestructureDate, '1900-01-01')
              OR NVL(O.SarfaesiDate, '1900-01-01') <> NVL(T.SarfaesiDate, '1900-01-01')
              OR NVL(O.FlgUnusualBounce, ' ') <> NVL(T.FlgUnusualBounce, ' ')
              OR NVL(O.UnusualBounceDate, '1900-01-01') <> NVL(T.UnusualBounceDate, '1900-01-01')
              OR NVL(O.FlgUnClearedEffect, ' ') <> NVL(T.FlgUnClearedEffect, ' ')
              OR NVL(O.UnClearedEffectDate, '1900-01-01') <> NVL(T.UnClearedEffectDate, '1900-01-01')
              OR NVL(O.FraudDate, '1900-01-01') <> NVL(T.FraudDate, '1900-01-01')
              OR NVL(O.WeakAccountDate, '1900-01-01') <> NVL(T.WeakAccountDate, '1900-01-01') )) src
            ON ( T.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET T.IsChanged = 'C';
            MERGE INTO GTT_ACDATA A
            USING (SELECT A.ROWID row_id, 'U'
            FROM GTT_ACDATA A
                   JOIN MAIN_PRO.AccountCal_Hist B   ON B.AccountEntityID = A.AccountEntityID 
             WHERE B.EffectiveFromTimeKey = v_TimeKey
              AND A.IsChanged = 'C') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.IsChanged = 'U';
            ----------For Changes Records
            MERGE INTO MAIN_PRO.AccountCal_Hist B
            USING (SELECT b.ROWID row_id, v_VEFFECTIVETO
            FROM GTT_ACDATA A
                   JOIN MAIN_PRO.AccountCal_Hist B   ON B.AccountEntityID = A.AccountEntityID
                   AND B.EffectiveToTimeKey = 49999 
             WHERE B.EffectiveFromTimeKey < v_TimeKey
              AND A.IsChanged = 'C') src
            ON ( b.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET b.EffectiveToTimeKey = v_VEFFECTIVETO;
            MERGE INTO MAIN_PRO.AccountCal_Hist O 
            USING (SELECT O.ROWID row_id, T.UcifEntityID, T.CustomerEntityID, T.CustomerAcID, T.RefCustomerID, T.SourceSystemCustomerID, T.UCIF_ID, T.BranchCode, T.FacilityType, T.AcOpenDt, T.FirstDtOfDisb, T.ProductAlt_Key, T.SchemeAlt_key, T.SubSectorAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SourceAlt_Key, T.ActSegmentCode, T.InttRate, T.Balance, T.BalanceInCrncy, T.CurrencyAlt_Key, T.DrawingPower, T.CurrentLimit, T.CurrentLimitDt, T.ContiExcessDt, T.StockStDt, T.DebitSinceDt, T.LastCrDate, T.InttServiced, T.IntNotServicedDt, T.OverdueAmt, T.OverDueSinceDt, T.ReviewDueDt, T.SecurityValue, T.DFVAmt, T.GovtGtyAmt, T.CoverGovGur, T.WriteOffAmount, T.UnAdjSubSidy, T.CreditsinceDt, T.DegReason, T.Asset_Norm, T.REFPeriodMax, T.RefPeriodOverdue, T.RefPeriodOverDrawn, T.RefPeriodNoCredit, T.RefPeriodIntService, T.RefPeriodStkStatement, T.RefPeriodReview, T.NetBalance, T.ApprRV, T.SecuredAmt, T.UnSecuredAmt, T.ProvDFV, T.Provsecured, T.ProvUnsecured, T.ProvCoverGovGur, T.AddlProvision, T.TotalProvision, T.BankProvsecured, T.BankProvUnsecured, T.BankTotalProvision, T.RBIProvsecured, T.RBIProvUnsecured, T.RBITotalProvision, T.InitialNpaDt, T.FinalNpaDt, T.SMA_Dt, T.UpgDate, T.InitialAssetClassAlt_Key, T.FinalAssetClassAlt_Key, T.ProvisionAlt_Key, T.PNPA_Reason, T.SMA_Class, T.SMA_Reason, T.FlgMoc, T.MOC_Dt, T.CommonMocTypeAlt_Key, T.FlgDeg, T.FlgDirtyRow, T.FlgInMonth, T.FlgSMA, T.FlgPNPA, T.FlgUpg, T.FlgFITL, T.FlgAbinitio, T.NPA_Days, T.RefPeriodOverdueUPG, T.RefPeriodOverDrawnUPG, T.RefPeriodNoCreditUPG, T.RefPeriodIntServiceUPG, T.RefPeriodStkStatementUPG, T.RefPeriodReviewUPG, T.AppGovGur, T.UsedRV, T.ComputedClaim, T.UPG_RELAX_MSME, T.DEG_RELAX_MSME, T.PNPA_DATE, T.NPA_Reason, T.PnpaAssetClassAlt_key, T.DisbAmount, T.PrincOutStd, T.PrincOverdue, T.PrincOverdueSinceDt, T.IntOverdue, T.IntOverdueSinceDt, T.OtherOverdue, T.OtherOverdueSinceDt, T.RelationshipNumber, T.AccountFlag, T.CommercialFlag_AltKey, T.Liability, T.CD, T.AccountStatus, T.AccountBlkCode1, T.AccountBlkCode2, T.ExposureType, T.Mtm_Value, T.BankAssetClass, T.NpaType, T.SecApp, T.BorrowerTypeID, T.LineCode, T.ProvPerSecured, T.ProvPerUnSecured, T.MOCReason, T.AddlProvisionPer, T.FlgINFRA, T.RepossessionDate, T.DerecognisedInterest1, T.DerecognisedInterest2, T.ProductCode, T.FlgLCBG, T.unserviedint, T.PreQtrCredit, T.PrvQtrInt, T.CurQtrCredit, T.CurQtrInt, T.OriginalBranchcode, T.AdvanceRecovery, T.NotionalInttAmt, T.PrvAssetClassAlt_Key, T.MOCTYPE, T.FlgSecured, T.RePossession, T.RCPending, T.PaymentPending, T.WheelCase, T.CustomerLevelMaxPer, T.FinalProvisionPer, T.IsIBPC, T.IsSecuritised, T.RFA, T.IsNonCooperative, T.Sarfaesi, T.WeakAccount, T.PUI, T.FlgFraud, T.FlgRestructure, T.RestructureDate, T.SarfaesiDate, T.FlgUnusualBounce, T.UnusualBounceDate, T.FlgUnClearedEffect, T.UnClearedEffectDate, T.FraudDate, T.WeakAccountDate
            FROM MAIN_PRO.AccountCal_Hist O
                   JOIN GTT_ACDATA T   ON O.AccountEntityID = T.AccountEntityID 
             WHERE O.EffectiveFromTimeKey = v_TimeKey
              AND T.IsChanged = 'U') src
            ON ( O.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET UcifEntityID = src.UcifEntityID,
                                         CustomerEntityID = src.CustomerEntityID,
                                         CustomerAcID = src.CustomerAcID,
                                         RefCustomerID = src.RefCustomerID,
                                         SourceSystemCustomerID = src.SourceSystemCustomerID,
                                         UCIF_ID = src.UCIF_ID,
                                         BranchCode = src.BranchCode,
                                         FacilityType = src.FacilityType,
                                         AcOpenDt = src.AcOpenDt,
                                         FirstDtOfDisb = src.FirstDtOfDisb,
                                         ProductAlt_Key = src.ProductAlt_Key,
                                         SchemeAlt_key = src.SchemeAlt_key,
                                         SubSectorAlt_Key = src.SubSectorAlt_Key,
                                         SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                         SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                         SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                         SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                         SourceAlt_Key = src.SourceAlt_Key,
                                         ActSegmentCode = src.ActSegmentCode,
                                         InttRate = src.InttRate,
                                         Balance = src.Balance,
                                         BalanceInCrncy = src.BalanceInCrncy,
                                         CurrencyAlt_Key = src.CurrencyAlt_Key,
                                         DrawingPower = src.DrawingPower,
                                         CurrentLimit = src.CurrentLimit,
                                         CurrentLimitDt = src.CurrentLimitDt,
                                         ContiExcessDt = src.ContiExcessDt,
                                         StockStDt = src.StockStDt,
                                         DebitSinceDt = src.DebitSinceDt,
                                         LastCrDate = src.LastCrDate,
                                         InttServiced = src.InttServiced,
                                         IntNotServicedDt = src.IntNotServicedDt,
                                         OverdueAmt = src.OverdueAmt,
                                         OverDueSinceDt = src.OverDueSinceDt,
                                         ReviewDueDt = src.ReviewDueDt,
                                         SecurityValue = src.SecurityValue,
                                         DFVAmt = src.DFVAmt,
                                         GovtGtyAmt = src.GovtGtyAmt,
                                         CoverGovGur = src.CoverGovGur,
                                         WriteOffAmount = src.WriteOffAmount,
                                         UnAdjSubSidy = src.UnAdjSubSidy,
                                         CreditsinceDt = src.CreditsinceDt,
                                         DegReason = src.DegReason,
                                         Asset_Norm = src.Asset_Norm,
                                         REFPeriodMax = src.REFPeriodMax,
                                         RefPeriodOverdue = src.RefPeriodOverdue,
                                         RefPeriodOverDrawn = src.RefPeriodOverDrawn,
                                         RefPeriodNoCredit = src.RefPeriodNoCredit,
                                         RefPeriodIntService = src.RefPeriodIntService,
                                         RefPeriodStkStatement = src.RefPeriodStkStatement,
                                         RefPeriodReview = src.RefPeriodReview,
                                         NetBalance = src.NetBalance,
                                         ApprRV = src.ApprRV,
                                         SecuredAmt = src.SecuredAmt,
                                         UnSecuredAmt = src.UnSecuredAmt,
                                         ProvDFV = src.ProvDFV,
                                         Provsecured = src.Provsecured,
                                         ProvUnsecured = src.ProvUnsecured,
                                         ProvCoverGovGur = src.ProvCoverGovGur,
                                         AddlProvision = src.AddlProvision,
                                         TotalProvision = src.TotalProvision,
                                         BankProvsecured = src.BankProvsecured,
                                         BankProvUnsecured = src.BankProvUnsecured,
                                         BankTotalProvision = src.BankTotalProvision,
                                         RBIProvsecured = src.RBIProvsecured,
                                         RBIProvUnsecured = src.RBIProvUnsecured,
                                         RBITotalProvision = src.RBITotalProvision,
                                         InitialNpaDt = src.InitialNpaDt,
                                         FinalNpaDt = src.FinalNpaDt,
                                         SMA_Dt = src.SMA_Dt,
                                         UpgDate = src.UpgDate,
                                         InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                         FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                         ProvisionAlt_Key = src.ProvisionAlt_Key,
                                         PNPA_Reason = src.PNPA_Reason,
                                         SMA_Class = src.SMA_Class,
                                         SMA_Reason = src.SMA_Reason,
                                         FlgMoc = src.FlgMoc,
                                         MOC_Dt = src.MOC_Dt,
                                         CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                         FlgDeg = src.FlgDeg,
                                         FlgDirtyRow = src.FlgDirtyRow,
                                         FlgInMonth = src.FlgInMonth,
                                         FlgSMA = src.FlgSMA,
                                         FlgPNPA = src.FlgPNPA,
                                         FlgUpg = src.FlgUpg,
                                         FlgFITL = src.FlgFITL,
                                         FlgAbinitio = src.FlgAbinitio,
                                         NPA_Days = src.NPA_Days,
                                         RefPeriodOverdueUPG = src.RefPeriodOverdueUPG,
                                         RefPeriodOverDrawnUPG = src.RefPeriodOverDrawnUPG,
                                         RefPeriodNoCreditUPG = src.RefPeriodNoCreditUPG,
                                         RefPeriodIntServiceUPG = src.RefPeriodIntServiceUPG,
                                         RefPeriodStkStatementUPG = src.RefPeriodStkStatementUPG,
                                         RefPeriodReviewUPG = src.RefPeriodReviewUPG,
                                         AppGovGur = src.AppGovGur,
                                         UsedRV = src.UsedRV,
                                         ComputedClaim = src.ComputedClaim,
                                         UPG_RELAX_MSME = src.UPG_RELAX_MSME,
                                         DEG_RELAX_MSME = src.DEG_RELAX_MSME,
                                         PNPA_DATE = src.PNPA_DATE,
                                         NPA_Reason = src.NPA_Reason,
                                         PnpaAssetClassAlt_key = src.PnpaAssetClassAlt_key,
                                         DisbAmount = src.DisbAmount,
                                         PrincOutStd = src.PrincOutStd,
                                         PrincOverdue = src.PrincOverdue,
                                         PrincOverdueSinceDt = src.PrincOverdueSinceDt,
                                         IntOverdue = src.IntOverdue,
                                         IntOverdueSinceDt = src.IntOverdueSinceDt,
                                         OtherOverdue = src.OtherOverdue,
                                         OtherOverdueSinceDt = src.OtherOverdueSinceDt,
                                         RelationshipNumber = src.RelationshipNumber,
                                         AccountFlag = src.AccountFlag,
                                         CommercialFlag_AltKey = src.CommercialFlag_AltKey,
                                         Liability = src.Liability,
                                         CD = src.CD,
                                         AccountStatus = src.AccountStatus,
                                         AccountBlkCode1 = src.AccountBlkCode1,
                                         AccountBlkCode2 = src.AccountBlkCode2,
                                         ExposureType = src.ExposureType,
                                         Mtm_Value = src.Mtm_Value,
                                         BankAssetClass = src.BankAssetClass,
                                         NpaType = src.NpaType,
                                         SecApp = src.SecApp,
                                         BorrowerTypeID = src.BorrowerTypeID,
                                         LineCode = src.LineCode,
                                         ProvPerSecured = src.ProvPerSecured,
                                         ProvPerUnSecured = src.ProvPerUnSecured,
                                         MOCReason = src.MOCReason,
                                         AddlProvisionPer = src.AddlProvisionPer,
                                         FlgINFRA = src.FlgINFRA,
                                         RepossessionDate = src.RepossessionDate,
                                         DerecognisedInterest1 = src.DerecognisedInterest1,
                                         DerecognisedInterest2 = src.DerecognisedInterest2,
                                         ProductCode = src.ProductCode,
                                         FlgLCBG = src.FlgLCBG,
                                         unserviedint = src.unserviedint,
                                         PreQtrCredit = src.PreQtrCredit,
                                         PrvQtrInt = src.PrvQtrInt,
                                         CurQtrCredit = src.CurQtrCredit,
                                         CurQtrInt = src.CurQtrInt,
                                         OriginalBranchcode = src.OriginalBranchcode,
                                         AdvanceRecovery = src.AdvanceRecovery,
                                         NotionalInttAmt = src.NotionalInttAmt,
                                         PrvAssetClassAlt_Key = src.PrvAssetClassAlt_Key,
                                         MOCTYPE = src.MOCTYPE,
                                         FlgSecured = src.FlgSecured,
                                         RePossession = src.RePossession,
                                         RCPending = src.RCPending,
                                         PaymentPending = src.PaymentPending,
                                         WheelCase = src.WheelCase,
                                         CustomerLevelMaxPer = src.CustomerLevelMaxPer,
                                         FinalProvisionPer = src.FinalProvisionPer,
                                         IsIBPC = src.IsIBPC,
                                         IsSecuritised = src.IsSecuritised,
                                         RFA = src.RFA,
                                         IsNonCooperative = src.IsNonCooperative,
                                         Sarfaesi = src.Sarfaesi,
                                         WeakAccount = src.WeakAccount,
                                         PUI = src.PUI,
                                         FlgFraud = src.FlgFraud,
                                         FlgRestructure = src.FlgRestructure,
                                         RestructureDate = src.RestructureDate,
                                         SarfaesiDate = src.SarfaesiDate,
                                         FlgUnusualBounce = src.FlgUnusualBounce,
                                         UnusualBounceDate = src.UnusualBounceDate,
                                         FlgUnClearedEffect = src.FlgUnClearedEffect,
                                         UnClearedEffectDate = src.UnClearedEffectDate,
                                         FraudDate = src.FraudDate,
                                         WeakAccountDate = src.WeakAccountDate;
            ----------------------------------------------------------------------------------------------------------------------------------------------
            MERGE INTO MAIN_PRO.AccountCal_Hist AA 
            USING (SELECT AA.ROWID row_id, v_VEFFECTIVETO
            FROM MAIN_PRO.AccountCal_Hist AA 
             WHERE AA.EffectiveToTimeKey = 49999
              AND NOT EXISTS ( SELECT 1 
                               FROM GTT_ACDATA BB
                                WHERE  AA.AccountEntityID = BB.AccountEntityID )) src
            ON ( AA.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET EffectiveToTimeKey = v_VEFFECTIVETO;
            SELECT MAX(EntityKey)  

              INTO v_EntityKeyAc
              FROM MAIN_PRO.AccountCal_Hist ;
            IF v_EntityKeyAc IS NULL THEN

            BEGIN
               v_EntityKeyAc := 0 ;

            END;
            END IF;
            MERGE INTO GTT_ACDATA TEMP
            USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
            FROM GTT_ACDATA TEMP
                   JOIN ( SELECT GTT_ACDATA.AccountEntityId ,
                                 (v_EntityKeyAc + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                                   FROM DUAL  )  )) EntityKeyNew  
                          FROM GTT_ACDATA 
                           WHERE  GTT_ACDATA.IsChanged IN ( 'C','N' )
                         ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId 
             WHERE Temp.IsChanged IN ( 'C','N' )
            ) src
            ON ( TEMP.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
            /***************************************************************************************************************/
            INSERT INTO MAIN_PRO.AccountCal_Hist
              ( EntityKey, AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgFraud, FlgRestructure, RestructureDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FraudDate, WeakAccountDate )
              ( SELECT EntityKeyNew ,
                       AccountEntityID ,
                       UcifEntityID ,
                       CustomerEntityID ,
                       CustomerAcID ,
                       RefCustomerID ,
                       SourceSystemCustomerID ,
                       UCIF_ID ,
                       BranchCode ,
                       FacilityType ,
                       AcOpenDt ,
                       FirstDtOfDisb ,
                       ProductAlt_Key ,
                       SchemeAlt_key ,
                       SubSectorAlt_Key ,
                       SplCatg1Alt_Key ,
                       SplCatg2Alt_Key ,
                       SplCatg3Alt_Key ,
                       SplCatg4Alt_Key ,
                       SourceAlt_Key ,
                       ActSegmentCode ,
                       InttRate ,
                       Balance ,
                       BalanceInCrncy ,
                       CurrencyAlt_Key ,
                       DrawingPower ,
                       CurrentLimit ,
                       CurrentLimitDt ,
                       ContiExcessDt ,
                       StockStDt ,
                       DebitSinceDt ,
                       LastCrDate ,
                       InttServiced ,
                       IntNotServicedDt ,
                       OverdueAmt ,
                       OverDueSinceDt ,
                       ReviewDueDt ,
                       SecurityValue ,
                       DFVAmt ,
                       GovtGtyAmt ,
                       CoverGovGur ,
                       WriteOffAmount ,
                       UnAdjSubSidy ,
                       CreditsinceDt ,
                       DegReason ,
                       Asset_Norm ,
                       REFPeriodMax ,
                       RefPeriodOverdue ,
                       RefPeriodOverDrawn ,
                       RefPeriodNoCredit ,
                       RefPeriodIntService ,
                       RefPeriodStkStatement ,
                       RefPeriodReview ,
                       NetBalance ,
                       ApprRV ,
                       SecuredAmt ,
                       UnSecuredAmt ,
                       ProvDFV ,
                       Provsecured ,
                       ProvUnsecured ,
                       ProvCoverGovGur ,
                       AddlProvision ,
                       TotalProvision ,
                       BankProvsecured ,
                       BankProvUnsecured ,
                       BankTotalProvision ,
                       RBIProvsecured ,
                       RBIProvUnsecured ,
                       RBITotalProvision ,
                       InitialNpaDt ,
                       FinalNpaDt ,
                       SMA_Dt ,
                       UpgDate ,
                       InitialAssetClassAlt_Key ,
                       FinalAssetClassAlt_Key ,
                       ProvisionAlt_Key ,
                       PNPA_Reason ,
                       SMA_Class ,
                       SMA_Reason ,
                       FlgMoc ,
                       MOC_Dt ,
                       CommonMocTypeAlt_Key ,
                       FlgDeg ,
                       FlgDirtyRow ,
                       FlgInMonth ,
                       FlgSMA ,
                       FlgPNPA ,
                       FlgUpg ,
                       FlgFITL ,
                       FlgAbinitio ,
                       NPA_Days ,
                       RefPeriodOverdueUPG ,
                       RefPeriodOverDrawnUPG ,
                       RefPeriodNoCreditUPG ,
                       RefPeriodIntServiceUPG ,
                       RefPeriodStkStatementUPG ,
                       RefPeriodReviewUPG ,
                       v_TimeKey EffectiveFromTimeKey  ,
                       49999 EffectiveToTimeKey  ,
                       AppGovGur ,
                       UsedRV ,
                       ComputedClaim ,
                       UPG_RELAX_MSME ,
                       DEG_RELAX_MSME ,
                       PNPA_DATE ,
                       NPA_Reason ,
                       PnpaAssetClassAlt_key ,
                       DisbAmount ,
                       PrincOutStd ,
                       PrincOverdue ,
                       PrincOverdueSinceDt ,
                       IntOverdue ,
                       IntOverdueSinceDt ,
                       OtherOverdue ,
                       OtherOverdueSinceDt ,
                       RelationshipNumber ,
                       AccountFlag ,
                       CommercialFlag_AltKey ,
                       Liability ,
                       CD ,
                       AccountStatus ,
                       AccountBlkCode1 ,
                       AccountBlkCode2 ,
                       ExposureType ,
                       Mtm_Value ,
                       BankAssetClass ,
                       NpaType ,
                       SecApp ,
                       BorrowerTypeID ,
                       LineCode ,
                       ProvPerSecured ,
                       ProvPerUnSecured ,
                       MOCReason ,
                       AddlProvisionPer ,
                       FlgINFRA ,
                       RepossessionDate ,
                       DerecognisedInterest1 ,
                       DerecognisedInterest2 ,
                       ProductCode ,
                       FlgLCBG ,
                       unserviedint ,
                       PreQtrCredit ,
                       PrvQtrInt ,
                       CurQtrCredit ,
                       CurQtrInt ,
                       OriginalBranchcode ,
                       AdvanceRecovery ,
                       NotionalInttAmt ,
                       PrvAssetClassAlt_Key ,
                       MOCTYPE ,
                       FlgSecured ,
                       RePossession ,
                       RCPending ,
                       PaymentPending ,
                       WheelCase ,
                       CustomerLevelMaxPer ,
                       FinalProvisionPer ,
                       IsIBPC ,
                       IsSecuritised ,
                       RFA ,
                       IsNonCooperative ,
                       Sarfaesi ,
                       WeakAccount ,
                       PUI ,
                       FlgFraud ,
                       FlgRestructure ,
                       RestructureDate ,
                       SarfaesiDate ,
                       FlgUnusualBounce ,
                       UnusualBounceDate ,
                       FlgUnClearedEffect ,
                       UnClearedEffectDate ,
                       FraudDate ,
                       WeakAccountDate 

                --select SUM(BALANCE)/10000000,  count(1)
                FROM GTT_ACDATA T
                 WHERE  NVL(T.IsChanged, 'N') IN ( 'C','N' )
               );
             
               MERGE INTO RBL_MISDB_PROD.ACCAHIST_TIMEKEY_REC_COUNT a
               USING (SELECT A.ROWID row_id, b.NoofAcs_Opt, b.Balance_Opt, a.Balance - b.Balance_Opt AS pos_4, a.NoofAcs_Current - b.NoofAcs_Opt AS pos_5
               FROM RBL_MISDB_PROD.ACCAHIST_TIMEKEY_REC_COUNT a
                      JOIN (( SELECT v_timekey timekey  ,
                                          COUNT(1)  NoofAcs_Opt  ,
                                          SUM(BALANCE)  Balance_Opt  
              FROM MAIN_PRO.AccountCal_Hist 
             WHERE  EffectiveFromTimeKey <= v_timekey
                      AND EffectiveToTimeKey >= v_timekey )) b   
                ON a.timekey = b.timekey ) src
               ON ( A.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET a.NoofAcs_Opt = src.NoofAcs_Opt,
                                            a.Balance_Opt = src.Balance_Opt,
                                            a.Balance_Diff = pos_4,
                                            a.NoofAcs_Diff = pos_5
               ;

         END;
         END IF;
         /*  END OF ACCOUNT DATA MERGE */
         v_RowNo := v_RowNo + 1 ;

      END;
   END LOOP;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCTCALHISTMERGE_LOOP" TO "ADF_CDR_RBL_STGDB";
