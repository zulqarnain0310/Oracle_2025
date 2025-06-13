--------------------------------------------------------
--  DDL for Procedure INSERTDATAINTOHIST_TABLE_OPT_BACKDTD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" 
--USE [RBL_MISDB_UAT]
 --GO
 --/****** Object:  StoredProcedure [PRO].[InsertDataINTOHIST_TABLE_OPT_BACKDTD]    Script Date: 16-03-2022 14:54:55 ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

(
  v_TIMEKEY IN NUMBER DEFAULT 26388 
)
AS
   /* INSERT DATA FOR BACKDTD TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyCust NUMBER(19,0) := 0;
   --LEFT JOIN PRO.CustomerCal_Hist B
   --	 ON B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
   --	 AND B.CustomerEntityID =T.CustomerEntityID
   -----WHERE t.CustomerEntityID not in (select a.CustomerEntityID from pro.CUSTOMERCAL_hist a where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY )--and t.CustomerEntityID=a.CustomerEntityID )
   /* INSERT RECORD FOR  LIVE AFTE BACKDTD TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyCust1 NUMBER(19,0) := 0;
   /* INSERT DATA FOR BACKDTD TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyAcct NUMBER(19,0) := 0;
   /* INSERT RECORD FOR  LIVE AFTE BACKDTD TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyAcct1 NUMBER(19,0) := 0;
   V_COUNT INT :=0;

BEGIN

   ------DECLARE @TIMEKEY INT=26298
   UPDATE MAIN_PRO.CUSTOMERCAL
      SET IsChanged = NULL;
   UPDATE MAIN_PRO.ACCOUNTCAL
      SET IsChanged = NULL;
   SELECT COUNT(1) INTO v_COUNT FROM GTT_CustomerCal_BACKDTD ;
   IF v_COUNT>1
   THEN
   DELETE FROM GTT_CustomerCal_BACKDTD;
   END IF;
   UTILS.IDENTITY_RESET('GTT_CustomerCal_BACKDTD');

   INSERT INTO GTT_CustomerCal_BACKDTD (AADHARCARDNO,	ADDLPROVISIONPER,	ASSET_NORM,	BANKASSETCLASS,	BANKTOTPROVISION,	BRANCHCODE,	COMMONMOCTYPEALT_KEY,	CONSTITUTIONALT_KEY,	CURNTQTRRV,	CUST_EXPO,	CUSTMOVEDESCRIPTION,	CUSTOMERENTITYID,	CUSTOMERNAME,	CUSTSEGMENTCODE,	DBTDT,	DBTDT2,	DBTDT3,	DEGDATE,	DEGREASON,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	ENTITYKEY,	EROSIONDT,	FLGDEG,	FLGDIRTYROW,	FLGEROSION,	FLGINMONTH,	FLGMOC,	FLGPERCOLATION,	FLGPNPA,	FLGPROCESSING,	FLGSMA,	FLGUPG,	FRAUDAMOUNT,	FRAUDDT,	INMONTHMARK,	LOSSDT,	MOC_DT,	MOCREASON,	MOCSTATUSMARK,	MOCTYPE,	PANNO,	PARENTCUSTOMERID,	PNPA_CLASS_KEY,	PNPA_DT,	PRVQTRRV,	RBITOTPROVISION,	REFCUSTOMERID,	SMA_CLASS_KEY,	SMA_DT,	SOURCEALT_KEY,	SOURCESYSTEMCUSTOMERID,	SPLCATG1ALT_KEY,	SPLCATG2ALT_KEY,	SPLCATG3ALT_KEY,	SPLCATG4ALT_KEY,	SRCASSETCLASSALT_KEY,	SRCNPA_DT,	SYSASSETCLASSALT_KEY,	SYSNPA_DT,	TOTOSCUST,	TOTPROVISION,	UCIF_ID,	UCIFENTITYID,	ISCHANGED,	ENTITYKEYNEW)
   	SELECT A.AADHARCARDNO,	A.ADDLPROVISIONPER,	A.ASSET_NORM,	A.BANKASSETCLASS,	A.BANKTOTPROVISION,	A.BRANCHCODE,	A.COMMONMOCTYPEALT_KEY,	A.CONSTITUTIONALT_KEY,	A.CURNTQTRRV,	A.CUST_EXPO,	A.CUSTMOVEDESCRIPTION,	A.CUSTOMERENTITYID,	A.CUSTOMERNAME,	A.CUSTSEGMENTCODE,	A.DBTDT,	A.DBTDT2,	A.DBTDT3,	A.DEGDATE,	A.DEGREASON,	A.EFFECTIVEFROMTIMEKEY,	A.EFFECTIVETOTIMEKEY,	A.ENTITYKEY,	A.EROSIONDT,	A.FLGDEG,	A.FLGDIRTYROW,	A.FLGEROSION,	A.FLGINMONTH,	A.FLGMOC,	A.FLGPERCOLATION,	A.FLGPNPA,	A.FLGPROCESSING,	A.FLGSMA,	A.FLGUPG,	A.FRAUDAMOUNT,	A.FRAUDDT,	A.INMONTHMARK,	A.LOSSDT,	A.MOC_DT,	A.MOCREASON,	A.MOCSTATUSMARK,	A.MOCTYPE,	A.PANNO,	A.PARENTCUSTOMERID,	A.PNPA_CLASS_KEY,	A.PNPA_DT,	A.PRVQTRRV,	A.RBITOTPROVISION,	A.REFCUSTOMERID,	A.SMA_CLASS_KEY,	A.SMA_DT,	A.SOURCEALT_KEY,	A.SOURCESYSTEMCUSTOMERID,	A.SPLCATG1ALT_KEY,	A.SPLCATG2ALT_KEY,	A.SPLCATG3ALT_KEY,	A.SPLCATG4ALT_KEY,	A.SRCASSETCLASSALT_KEY,	A.SRCNPA_DT,	A.SYSASSETCLASSALT_KEY,	A.SYSNPA_DT,	A.TOTOSCUST,	A.TOTPROVISION,	A.UCIF_ID,	A.UCIFENTITYID,	A.CHANGEFLD
            ,UTILS.CONVERT_TO_NUMBER(0,19,0) EntityKeyNew  
   	  FROM MAIN_PRO.CustomerCal_Hist A
             JOIN MAIN_PRO.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY ;
   /* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO BACKDTD OR GRATER THAN BACKDTD TIMKEY*/
   MERGE INTO MAIN_PRO.CustomerCal_Hist A
   USING (SELECT A.ROWID row_id, CASE 
   WHEN a.EffectiveFromTimeKey < v_TIMEKEY THEN v_TIMEKEY - 1
   ELSE v_TIMEKEY
      END AS EffectiveToTimeKey
   FROM MAIN_PRO.CustomerCal_Hist A
          JOIN MAIN_PRO.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
          AND A.EffectiveFromTimeKey <= v_TIMEKEY
          AND A.EffectiveToTimeKey >= v_TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
   /* UPADTE DATA AVAILABLE ON SAME TMEKEY */
   MERGE INTO MAIN_PRO.CustomerCal_Hist O
   USING (SELECT O.ROWID row_id, T.BranchCode, T.UCIF_ID, T.UcifEntityID, T.ParentCustomerID, T.RefCustomerID, T.SourceSystemCustomerID, T.CustomerName, T.CustSegmentCode, T.ConstitutionAlt_Key, T.PANNO, T.AadharCardNO, T.SrcAssetClassAlt_Key, T.SysAssetClassAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SMA_Class_Key, T.PNPA_Class_Key, T.PrvQtrRV, T.CurntQtrRv, T.TotProvision, T.BankTotProvision, T.RBITotProvision, T.SrcNPA_Dt, T.SysNPA_Dt, T.DbtDt, T.DbtDt2, T.DbtDt3, T.LossDt, T.MOC_Dt, T.ErosionDt, T.SMA_Dt, T.PNPA_Dt, T.Asset_Norm, T.FlgDeg, T.FlgUpg, T.FlgMoc, T.FlgSMA, T.FlgProcessing, T.FlgErosion, T.FlgPNPA, T.FlgPercolation, T.FlgInMonth, T.FlgDirtyRow, T.DegDate, T.CommonMocTypeAlt_Key, T.InMonthMark, T.MocStatusMark, T.SourceAlt_Key, T.BankAssetClass, T.Cust_Expo, T.MOCReason, T.AddlProvisionPer, T.FraudDt, T.FraudAmount, T.DegReason, T.CustMoveDescription, T.TotOsCust, T.MOCTYPE
   FROM MAIN_PRO.CustomerCal_Hist O
          JOIN MAIN_PRO.CUSTOMERCAL T   ON O.CustomerEntityId = T.CustomerEntityID 
    WHERE O.EffectiveFromTimeKey = v_TimeKey
     AND O.EffectiveToTimeKey = v_TIMEKEY) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET BranchCode = src.BranchCode,
                                UCIF_ID = src.UCIF_ID,
                                UcifEntityID = src.UcifEntityID,
                                ParentCustomerID = src.ParentCustomerID,
                                RefCustomerID = src.RefCustomerID,
                                SourceSystemCustomerID = src.SourceSystemCustomerID,
                                CustomerName = src.CustomerName,
                                CustSegmentCode = src.CustSegmentCode,
                                ConstitutionAlt_Key = src.ConstitutionAlt_Key,
                                PANNO = src.PANNO,
                                AadharCardNO = src.AadharCardNO,
                                SrcAssetClassAlt_Key = src.SrcAssetClassAlt_Key,
                                SysAssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                SMA_Class_Key = src.SMA_Class_Key,
                                PNPA_Class_Key = src.PNPA_Class_Key,
                                PrvQtrRV = src.PrvQtrRV,
                                CurntQtrRv = src.CurntQtrRv,
                                TotProvision = src.TotProvision,
                                BankTotProvision = src.BankTotProvision,
                                RBITotProvision = src.RBITotProvision,
                                SrcNPA_Dt = src.SrcNPA_Dt,
                                SysNPA_Dt = src.SysNPA_Dt,
                                DbtDt = src.DbtDt,
                                DbtDt2 = src.DbtDt2,
                                DbtDt3 = src.DbtDt3,
                                LossDt = src.LossDt,
                                MOC_Dt = src.MOC_Dt,
                                ErosionDt = src.ErosionDt,
                                SMA_Dt = src.SMA_Dt,
                                PNPA_Dt = src.PNPA_Dt,
                                Asset_Norm = src.Asset_Norm,
                                FlgDeg = src.FlgDeg,
                                FlgUpg = src.FlgUpg,
                                FlgMoc = src.FlgMoc,
                                FlgSMA = src.FlgSMA,
                                FlgProcessing = src.FlgProcessing,
                                FlgErosion = src.FlgErosion,
                                FlgPNPA = src.FlgPNPA,
                                FlgPercolation = src.FlgPercolation,
                                FlgInMonth = src.FlgInMonth,
                                FlgDirtyRow = src.FlgDirtyRow,
                                DegDate = src.DegDate,
                                CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                InMonthMark = src.InMonthMark,
                                MocStatusMark = src.MocStatusMark,
                                SourceAlt_Key = src.SourceAlt_Key,
                                BankAssetClass = src.BankAssetClass,
                                Cust_Expo = src.Cust_Expo,
                                MOCReason = src.MOCReason,
                                AddlProvisionPer = src.AddlProvisionPer,
                                FraudDt = src.FraudDt,
                                FraudAmount = src.FraudAmount,
                                DegReason = src.DegReason,
                                CustMoveDescription = src.CustMoveDescription,
                                TotOsCust = src.TotOsCust,
                                MOCTYPE = src.MOCTYPE;
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyCust
     FROM MAIN_PRO.CustomerCal_Hist ;
   IF v_EntityKeyCust IS NULL THEN

   BEGIN
      v_EntityKeyCust := 0 ;

   END;
   END IF;
   MERGE INTO MAIN_PRO.CUSTOMERCAL TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM MAIN_PRO.CUSTOMERCAL TEMP
          JOIN ( SELECT CUSTOMERCAL.CustomerEntityId ,
                        (v_EntityKeyCust + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                            FROM DUAL  )  )) EntityKeyNew  
                 FROM MAIN_PRO.CUSTOMERCAL ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.CustomerEntityID = ACCT.CustomerEntityId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   MERGE INTO MAIN_PRO.CUSTOMERCAL T
   USING (SELECT T.ROWID row_id, 'Y'
   FROM MAIN_PRO.CUSTOMERCAL T
          LEFT JOIN MAIN_PRO.CustomerCal_Hist B   ON B.EffectiveFromTimeKey = v_TIMEKEY
          AND B.EffectiveToTimeKey = v_TIMEKEY
          AND B.CustomerEntityId = T.CustomerEntityID 
    WHERE B.CustomerEntityId IS NULL) src
   ON ( T.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET t.IsChanged = 'Y';
   /***************************************************************************************************************/
   INSERT INTO MAIN_PRO.CustomerCal_Hist
     ( EntityKey, BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, ChangeFld, ScreenFlag )
     ( SELECT T.EntityKeyNew ,
              T.BranchCode ,
              T.UCIF_ID ,
              T.UcifEntityID ,
              T.CustomerEntityID ,
              T.ParentCustomerID ,
              T.RefCustomerID ,
              T.SourceSystemCustomerID ,
              T.CustomerName ,
              T.CustSegmentCode ,
              T.ConstitutionAlt_Key ,
              T.PANNO ,
              T.AadharCardNO ,
              T.SrcAssetClassAlt_Key ,
              T.SysAssetClassAlt_Key ,
              T.SplCatg1Alt_Key ,
              T.SplCatg2Alt_Key ,
              T.SplCatg3Alt_Key ,
              T.SplCatg4Alt_Key ,
              T.SMA_Class_Key ,
              T.PNPA_Class_Key ,
              T.PrvQtrRV ,
              T.CurntQtrRv ,
              T.TotProvision ,
              T.BankTotProvision ,
              T.RBITotProvision ,
              T.SrcNPA_Dt ,
              T.SysNPA_Dt ,
              T.DbtDt ,
              T.DbtDt2 ,
              T.DbtDt3 ,
              T.LossDt ,
              T.MOC_Dt ,
              T.ErosionDt ,
              T.SMA_Dt ,
              T.PNPA_Dt ,
              T.Asset_Norm ,
              T.FlgDeg ,
              T.FlgUpg ,
              T.FlgMoc ,
              T.FlgSMA ,
              T.FlgProcessing ,
              T.FlgErosion ,
              T.FlgPNPA ,
              T.FlgPercolation ,
              T.FlgInMonth ,
              T.FlgDirtyRow ,
              T.DegDate ,
              v_TIMEKEY EffectiveFromTimeKey  ,
              v_TIMEKEY EffectiveToTimeKey  ,
              t.CommonMocTypeAlt_Key ,
              t.InMonthMark ,
              t.MocStatusMark ,
              t.SourceAlt_Key ,
              t.BankAssetClass ,
              t.Cust_Expo ,
              t.MOCReason ,
              t.AddlProvisionPer ,
              t.FraudDt ,
              t.FraudAmount ,
              t.DegReason ,
              t.CustMoveDescription ,
              t.TotOsCust ,
              t.MOCTYPE ,
              NULL ChangeFld  ,
              NULL ScreenFlag  
       FROM MAIN_PRO.CUSTOMERCAL T
        WHERE  t.IsChanged = 'Y' );
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyCust1
     FROM MAIN_PRO.CustomerCal_Hist ;
   IF v_EntityKeyCust IS NULL THEN

   BEGIN
      v_EntityKeyCust1 := 0 ;

   END;
   END IF;
   MERGE INTO GTT_CustomerCal_BACKDTD TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_CustomerCal_BACKDTD TEMP
          JOIN ( SELECT GTT_CustomerCal_BACKDTD.CustomerEntityId ,
                        (v_EntityKeyCust1 + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                             FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_CustomerCal_BACKDTD ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.CustomerEntityId = ACCT.CustomerEntityId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   INSERT INTO MAIN_PRO.CustomerCal_Hist
     ( EntityKey, BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, ChangeFld, ScreenFlag )
     ( SELECT T.EntityKeyNew ,
              T.BranchCode ,
              T.UCIF_ID ,
              T.UcifEntityID ,
              T.CustomerEntityID ,
              T.ParentCustomerID ,
              T.RefCustomerID ,
              T.SourceSystemCustomerID ,
              T.CustomerName ,
              T.CustSegmentCode ,
              T.ConstitutionAlt_Key ,
              T.PANNO ,
              T.AadharCardNO ,
              T.SrcAssetClassAlt_Key ,
              T.SysAssetClassAlt_Key ,
              T.SplCatg1Alt_Key ,
              T.SplCatg2Alt_Key ,
              T.SplCatg3Alt_Key ,
              T.SplCatg4Alt_Key ,
              T.SMA_Class_Key ,
              T.PNPA_Class_Key ,
              T.PrvQtrRV ,
              T.CurntQtrRv ,
              T.TotProvision ,
              T.BankTotProvision ,
              T.RBITotProvision ,
              T.SrcNPA_Dt ,
              T.SysNPA_Dt ,
              T.DbtDt ,
              T.DbtDt2 ,
              T.DbtDt3 ,
              T.LossDt ,
              T.MOC_Dt ,
              T.ErosionDt ,
              T.SMA_Dt ,
              T.PNPA_Dt ,
              T.Asset_Norm ,
              T.FlgDeg ,
              T.FlgUpg ,
              T.FlgMoc ,
              T.FlgSMA ,
              T.FlgProcessing ,
              T.FlgErosion ,
              T.FlgPNPA ,
              T.FlgPercolation ,
              T.FlgInMonth ,
              T.FlgDirtyRow ,
              T.DegDate ,
              v_TIMEKEY + 1 EffectiveFromTimeKey  ,
              T.EffectiveToTimeKey ,
              T.CommonMocTypeAlt_Key ,
              T.InMonthMark ,
              T.MocStatusMark ,
              T.SourceAlt_Key ,
              T.BankAssetClass ,
              T.Cust_Expo ,
              T.MOCReason ,
              T.AddlProvisionPer ,
              T.FraudDt ,
              T.FraudAmount ,
              T.DegReason ,
              T.CustMoveDescription ,
              T.TotOsCust ,
              T.MOCTYPE ,
              NULL ChangeFld  ,
              NULL ScreenFlag  
       FROM GTT_CustomerCal_BACKDTD T
        WHERE  EffectiveToTimeKey > v_TIMEKEY );
   /* ACCOUNT - BACKDTD */
   v_COUNT:=0;
   SELECT COUNT(1) INTO v_COUNT FROM GTT_ACCOUNTCAL_BACKDTD;
   IF v_COUNT>1
   THEN
   DELETE FROM GTT_AccountCal_BACKDTD;
   END IF;
   UTILS.IDENTITY_RESET('GTT_AccountCal_BACKDTD');

   INSERT INTO GTT_AccountCal_BACKDTD ( ACCOUNTBLKCODE1,	ACCOUNTBLKCODE2,	ACCOUNTENTITYID,	ACCOUNTFLAG,	ACCOUNTSTATUS,	ACOPENDT,	ACTSEGMENTCODE,	ADDLPROVISION,	ADDLPROVISIONPER,	ADVANCERECOVERY,	APPGOVGUR,	APPRRV,	ASSET_NORM,	BALANCE,	BALANCEINCRNCY,	BANKASSETCLASS,	BANKPROVSECURED,	BANKPROVUNSECURED,	BANKTOTALPROVISION,	BORROWERTYPEID,	BRANCHCODE,	CD,	COMMERCIALFLAG_ALTKEY,	COMMONMOCTYPEALT_KEY,	COMPUTEDCLAIM,	CONTIEXCESSDT,	COVERGOVGUR,	CREDITSINCEDT,	CURQTRCREDIT,	CURQTRINT,	CURRENCYALT_KEY,	CURRENTLIMIT,	CURRENTLIMITDT,	CUSTOMERACID,	CUSTOMERENTITYID,	CUSTOMERLEVELMAXPER,	DEBITSINCEDT,	DEG_RELAX_MSME,	DEGREASON,	DERECOGNISEDINTEREST1,	DERECOGNISEDINTEREST2,	DFVAMT,	DISBAMOUNT,	DRAWINGPOWER,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	ENTITYKEY,	EXPOSURETYPE,	FACILITYTYPE,	FINALASSETCLASSALT_KEY,	FINALNPADT,	FINALPROVISIONPER,	FIRSTDTOFDISB,	FLGABINITIO,	FLGDEG,	FLGDIRTYROW,	FLGFITL,	FLGFRAUD,	FLGINFRA,	FLGINMONTH,	FLGLCBG,	FLGMOC,	FLGPNPA,	FLGRESTRUCTURE,	FLGSECURED,	FLGSMA,	FLGUNCLEAREDEFFECT,	FLGUNUSUALBOUNCE,	FLGUPG,	FRAUDDATE,	GOVTGTYAMT,	INITIALASSETCLASSALT_KEY,	INITIALNPADT,	INTNOTSERVICEDDT,	INTOVERDUE,	INTOVERDUESINCEDT,	INTTRATE,	INTTSERVICED,	ISCHANGED,	ISIBPC,	ISNONCOOPERATIVE,	ISSECURITISED,	LASTCRDATE,	LIABILITY,	LINECODE,	MOC_DT,	MOCREASON,	MOCTYPE,	MTM_VALUE,	NETBALANCE,	NOTIONALINTTAMT,	NPA_DAYS,	NPA_REASON,	NPATYPE,	ORIGINALBRANCHCODE,	OTHEROVERDUE,	OTHEROVERDUESINCEDT,	OVERDUEAMT,	OVERDUESINCEDT,	PAYMENTPENDING,	PNPA_DATE,	PNPA_REASON,	PNPAASSETCLASSALT_KEY,	PREQTRCREDIT,	PRINCOUTSTD,	PRINCOVERDUE,	PRINCOVERDUESINCEDT,	PRODUCTALT_KEY,	PRODUCTCODE,	PROVCOVERGOVGUR,	PROVDFV,	PROVISIONALT_KEY,	PROVPERSECURED,	PROVPERUNSECURED,	PROVSECURED,	PROVUNSECURED,	PRVASSETCLASSALT_KEY,	PRVQTRINT,	PUI,	RBIPROVSECURED,	RBIPROVUNSECURED,	RBITOTALPROVISION,	RCPENDING,	REFCUSTOMERID,	REFPERIODINTSERVICE,	REFPERIODINTSERVICEUPG,	REFPERIODMAX,	REFPERIODNOCREDIT,	REFPERIODNOCREDITUPG,	REFPERIODOVERDRAWN,	REFPERIODOVERDRAWNUPG,	REFPERIODOVERDUE,	REFPERIODOVERDUEUPG,	REFPERIODREVIEW,	REFPERIODREVIEWUPG,	REFPERIODSTKSTATEMENT,	REFPERIODSTKSTATEMENTUPG,	RELATIONSHIPNUMBER,	REPOSSESSION,	REPOSSESSIONDATE,	RESTRUCTUREDATE,	REVIEWDUEDT,	RFA,	SARFAESI,	SARFAESIDATE,	SCHEMEALT_KEY,	SECAPP,	SECUREDAMT,	SECURITYVALUE,	SMA_CLASS,	SMA_DT,	SMA_REASON,	SOURCEALT_KEY,	SOURCESYSTEMCUSTOMERID,	SPLCATG1ALT_KEY,	SPLCATG2ALT_KEY,	SPLCATG3ALT_KEY,	SPLCATG4ALT_KEY,	STOCKSTDT,	SUBSECTORALT_KEY,	TOTALPROVISION,	UCIF_ID,	UCIFENTITYID,	UNADJSUBSIDY,	UNCLEAREDEFFECTDATE,	UNSECUREDAMT,	UNSERVIEDINT,	UNUSUALBOUNCEDATE,	UPG_RELAX_MSME,	UPGDATE,	USEDRV,	WEAKACCOUNT,	WEAKACCOUNTDATE,	WHEELCASE,	WRITEOFFAMOUNT,	ENTITYKEYNEW)
   	SELECT A.ACCOUNTBLKCODE1,	A.ACCOUNTBLKCODE2,	A.ACCOUNTENTITYID,	A.ACCOUNTFLAG,	A.ACCOUNTSTATUS,	A.ACOPENDT,	A.ACTSEGMENTCODE,	A.ADDLPROVISION,	A.ADDLPROVISIONPER,	A.ADVANCERECOVERY,	A.APPGOVGUR,	A.APPRRV,	A.ASSET_NORM,	A.BALANCE,	A.BALANCEINCRNCY,	A.BANKASSETCLASS,	A.BANKPROVSECURED,	A.BANKPROVUNSECURED,	A.BANKTOTALPROVISION,	A.BORROWERTYPEID,	A.BRANCHCODE,	A.CD,	A.COMMERCIALFLAG_ALTKEY,	A.COMMONMOCTYPEALT_KEY,	A.COMPUTEDCLAIM,	A.CONTIEXCESSDT,	A.COVERGOVGUR,	A.CREDITSINCEDT,	A.CURQTRCREDIT,	A.CURQTRINT,	A.CURRENCYALT_KEY,	A.CURRENTLIMIT,	A.CURRENTLIMITDT,	A.CUSTOMERACID,	A.CUSTOMERENTITYID,	A.CUSTOMERLEVELMAXPER,	A.DEBITSINCEDT,	A.DEG_RELAX_MSME,	A.DEGREASON,	A.DERECOGNISEDINTEREST1,	A.DERECOGNISEDINTEREST2,	A.DFVAMT,	A.DISBAMOUNT,	A.DRAWINGPOWER,	A.EFFECTIVEFROMTIMEKEY,	A.EFFECTIVETOTIMEKEY,	A.ENTITYKEY,	A.EXPOSURETYPE,	A.FACILITYTYPE,	A.FINALASSETCLASSALT_KEY,	A.FINALNPADT,	A.FINALPROVISIONPER,	A.FIRSTDTOFDISB,	A.FLGABINITIO,	A.FLGDEG,	A.FLGDIRTYROW,	A.FLGFITL,	A.FLGFRAUD,	A.FLGINFRA,	A.FLGINMONTH,	A.FLGLCBG,	A.FLGMOC,	A.FLGPNPA,	A.FLGRESTRUCTURE,	A.FLGSECURED,	A.FLGSMA,	A.FLGUNCLEAREDEFFECT,	A.FLGUNUSUALBOUNCE,	A.FLGUPG,	A.FRAUDDATE,	A.GOVTGTYAMT,	A.INITIALASSETCLASSALT_KEY,	A.INITIALNPADT,	A.INTNOTSERVICEDDT,	A.INTOVERDUE,	A.INTOVERDUESINCEDT,	A.INTTRATE,	A.INTTSERVICED,	A.CHANGEFIELD,	A.ISIBPC,	A.ISNONCOOPERATIVE,	A.ISSECURITISED,	A.LASTCRDATE,	A.LIABILITY,	A.LINECODE,	A.MOC_DT,	A.MOCREASON,	A.MOCTYPE,	A.MTM_VALUE,	A.NETBALANCE,	A.NOTIONALINTTAMT,	A.NPA_DAYS,	A.NPA_REASON,	A.NPATYPE,	A.ORIGINALBRANCHCODE,	A.OTHEROVERDUE,	A.OTHEROVERDUESINCEDT,	A.OVERDUEAMT,	A.OVERDUESINCEDT,	A.PAYMENTPENDING,	A.PNPA_DATE,	A.PNPA_REASON,	A.PNPAASSETCLASSALT_KEY,	A.PREQTRCREDIT,	A.PRINCOUTSTD,	A.PRINCOVERDUE,	A.PRINCOVERDUESINCEDT,	A.PRODUCTALT_KEY,	A.PRODUCTCODE,	A.PROVCOVERGOVGUR,	A.PROVDFV,	A.PROVISIONALT_KEY,	A.PROVPERSECURED,	A.PROVPERUNSECURED,	A.PROVSECURED,	A.PROVUNSECURED,	A.PRVASSETCLASSALT_KEY,	A.PRVQTRINT,	A.PUI,	A.RBIPROVSECURED,	A.RBIPROVUNSECURED,	A.RBITOTALPROVISION,	A.RCPENDING,	A.REFCUSTOMERID,	A.REFPERIODINTSERVICE,	A.REFPERIODINTSERVICEUPG,	A.REFPERIODMAX,	A.REFPERIODNOCREDIT,	A.REFPERIODNOCREDITUPG,	A.REFPERIODOVERDRAWN,	A.REFPERIODOVERDRAWNUPG,	A.REFPERIODOVERDUE,	A.REFPERIODOVERDUEUPG,	A.REFPERIODREVIEW,	A.REFPERIODREVIEWUPG,	A.REFPERIODSTKSTATEMENT,	A.REFPERIODSTKSTATEMENTUPG,	A.RELATIONSHIPNUMBER,	A.REPOSSESSION,	A.REPOSSESSIONDATE,	A.RESTRUCTUREDATE,	A.REVIEWDUEDT,	A.RFA,	A.SARFAESI,	A.SARFAESIDATE,	A.SCHEMEALT_KEY,	A.SECAPP,	A.SECUREDAMT,	A.SECURITYVALUE,	A.SMA_CLASS,	A.SMA_DT,	A.SMA_REASON,	A.SOURCEALT_KEY,	A.SOURCESYSTEMCUSTOMERID,	A.SPLCATG1ALT_KEY,	A.SPLCATG2ALT_KEY,	A.SPLCATG3ALT_KEY,	A.SPLCATG4ALT_KEY,	A.STOCKSTDT,	A.SUBSECTORALT_KEY,	A.TOTALPROVISION,	A.UCIF_ID,	A.UCIFENTITYID,	A.UNADJSUBSIDY,	A.UNCLEAREDEFFECTDATE,	A.UNSECUREDAMT,	A.UNSERVIEDINT,	A.UNUSUALBOUNCEDATE,	A.UPG_RELAX_MSME,	A.UPGDATE,	A.USEDRV,	A.WEAKACCOUNT,	A.WEAKACCOUNTDATE,	A.WHEELCASE,	A.WRITEOFFAMOUNT
    ,UTILS.CONVERT_TO_NUMBER(0,19,0) EntityKeyNew  
   	  FROM MAIN_PRO.AccountCal_Hist A
             JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityID = B.AccountEntityID
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY ;
   /* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO BACKDTD OT GRATER THAN BACKDTD TIMKEY*/
   MERGE INTO MAIN_PRO.AccountCal_Hist A
   USING (SELECT A.ROWID row_id, CASE 
   WHEN a.EffectiveFromTimeKey < v_TIMEKEY THEN v_TIMEKEY - 1
   ELSE v_TIMEKEY
      END AS EffectiveToTimeKey
   FROM MAIN_PRO.AccountCal_Hist A
          JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityID = B.AccountEntityID
          AND A.EffectiveFromTimeKey <= v_TIMEKEY
          AND A.EffectiveToTimeKey >= v_TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
   /* UPADTE DAT AVAILABLE ON SAME TMEKEY */
   MERGE INTO MAIN_PRO.AccountCal_Hist T
   USING (SELECT O.ROWID row_id, T.UcifEntityID, T.CustomerEntityID, T.CustomerAcID, T.RefCustomerID, T.SourceSystemCustomerID, T.UCIF_ID, T.BranchCode, T.FacilityType, T.AcOpenDt, T.FirstDtOfDisb, T.ProductAlt_Key, T.SchemeAlt_key, T.SubSectorAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SourceAlt_Key, T.ActSegmentCode, T.InttRate, T.Balance, T.BalanceInCrncy, T.CurrencyAlt_Key, T.DrawingPower, T.CurrentLimit, T.CurrentLimitDt, T.ContiExcessDt, T.StockStDt, T.DebitSinceDt, T.LastCrDate, T.InttServiced, T.IntNotServicedDt, T.OverdueAmt, T.OverDueSinceDt, T.ReviewDueDt, T.SecurityValue, T.DFVAmt, T.GovtGtyAmt, T.CoverGovGur, T.WriteOffAmount, T.UnAdjSubSidy, T.CreditsinceDt, T.DegReason, T.Asset_Norm, T.REFPeriodMax, T.RefPeriodOverdue, T.RefPeriodOverDrawn, T.RefPeriodNoCredit, T.RefPeriodIntService, T.RefPeriodStkStatement, T.RefPeriodReview, T.NetBalance, T.ApprRV, T.SecuredAmt, T.UnSecuredAmt, T.ProvDFV, T.Provsecured, T.ProvUnsecured, T.ProvCoverGovGur, T.AddlProvision, T.TotalProvision, T.BankProvsecured, T.BankProvUnsecured, T.BankTotalProvision, T.RBIProvsecured, T.RBIProvUnsecured, T.RBITotalProvision, T.InitialNpaDt, T.FinalNpaDt, T.SMA_Dt, T.UpgDate, T.InitialAssetClassAlt_Key, T.FinalAssetClassAlt_Key, T.ProvisionAlt_Key, T.PNPA_Reason, T.SMA_Class, T.SMA_Reason, T.FlgMoc, T.MOC_Dt, T.CommonMocTypeAlt_Key, T.FlgDeg, T.FlgDirtyRow, T.FlgInMonth, T.FlgSMA, T.FlgPNPA, T.FlgUpg, T.FlgFITL, T.FlgAbinitio, T.NPA_Days, T.RefPeriodOverdueUPG, T.RefPeriodOverDrawnUPG, T.RefPeriodNoCreditUPG, T.RefPeriodIntServiceUPG, T.RefPeriodStkStatementUPG, T.RefPeriodReviewUPG, T.AppGovGur, T.UsedRV, T.ComputedClaim, T.UPG_RELAX_MSME, T.DEG_RELAX_MSME, T.PNPA_DATE, T.NPA_Reason, T.PnpaAssetClassAlt_key, T.DisbAmount, T.PrincOutStd, T.PrincOverdue, T.PrincOverdueSinceDt, T.IntOverdue, T.IntOverdueSinceDt, T.OtherOverdue, T.OtherOverdueSinceDt, T.RelationshipNumber, T.AccountFlag, T.CommercialFlag_AltKey, T.Liability, T.CD, T.AccountStatus, T.AccountBlkCode1, T.AccountBlkCode2, T.ExposureType, T.Mtm_Value, T.BankAssetClass, T.NpaType, T.SecApp, T.BorrowerTypeID, T.LineCode, T.ProvPerSecured, T.ProvPerUnSecured, T.MOCReason, T.AddlProvisionPer, T.FlgINFRA, T.RepossessionDate, T.DerecognisedInterest1, T.DerecognisedInterest2, T.ProductCode, T.FlgLCBG, T.UnserviedInt, T.PreQtrCredit, T.PrvQtrInt, T.CurQtrCredit, T.CurQtrInt, T.OriginalBranchcode, T.AdvanceRecovery, T.NotionalInttAmt, T.PrvAssetClassAlt_Key, T.MOCTYPE, T.FlgSecured, T.RePossession, T.RCPending, T.PaymentPending, T.WheelCase, T.CustomerLevelMaxPer, T.FinalProvisionPer, T.IsIBPC, T.IsSecuritised, T.RFA, T.IsNonCooperative, T.Sarfaesi, T.WeakAccount, T.PUI, T.FlgFraud, T.FlgRestructure, T.RestructureDate, T.SarfaesiDate, T.FlgUnusualBounce, T.UnusualBounceDate, T.FlgUnClearedEffect, T.UnClearedEffectDate, T.FraudDate, T.WeakAccountDate
   FROM MAIN_PRO.AccountCal_Hist O
          JOIN MAIN_PRO.ACCOUNTCAL T   ON O.AccountEntityID = T.AccountEntityID 
    WHERE O.EffectiveFromTimeKey = v_TimeKey
     AND O.EffectiveToTimeKey = v_TIMEKEY) src
   ON ( T.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET T.UcifEntityID = src.UcifEntityID,
                                T.CustomerEntityID = src.CustomerEntityID,
                                T.CustomerAcID = src.CustomerAcID,
                                T.RefCustomerID = src.RefCustomerID,
                                T.SourceSystemCustomerID = src.SourceSystemCustomerID,
                                T.UCIF_ID = src.UCIF_ID,
                                T.BranchCode = src.BranchCode,
                                T.FacilityType = src.FacilityType,
                                T.AcOpenDt = src.AcOpenDt,
                                T.FirstDtOfDisb = src.FirstDtOfDisb,
                                T.ProductAlt_Key = src.ProductAlt_Key,
                                T.SchemeAlt_key = src.SchemeAlt_key,
                                T.SubSectorAlt_Key = src.SubSectorAlt_Key,
                                T.SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                T.SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                T.SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                T.SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                T.SourceAlt_Key = src.SourceAlt_Key,
                                T.ActSegmentCode = src.ActSegmentCode,
                                T.InttRate = src.InttRate,
                                T.Balance = src.Balance,
                                T.BalanceInCrncy = src.BalanceInCrncy,
                                T.CurrencyAlt_Key = src.CurrencyAlt_Key,
                                T.DrawingPower = src.DrawingPower,
                                T.CurrentLimit = src.CurrentLimit,
                                T.CurrentLimitDt = src.CurrentLimitDt,
                                T.ContiExcessDt = src.ContiExcessDt,
                                T.StockStDt = src.StockStDt,
                                T.DebitSinceDt = src.DebitSinceDt,
                                T.LastCrDate = src.LastCrDate,
                                T.InttServiced = src.InttServiced,
                                T.IntNotServicedDt = src.IntNotServicedDt,
                                T.OverdueAmt = src.OverdueAmt,
                                T.OverDueSinceDt = src.OverDueSinceDt,
                                T.ReviewDueDt = src.ReviewDueDt,
                                T.SecurityValue = src.SecurityValue,
                                T.DFVAmt = src.DFVAmt,
                                T.GovtGtyAmt = src.GovtGtyAmt,
                                T.CoverGovGur = src.CoverGovGur,
                                T.WriteOffAmount = src.WriteOffAmount,
                                T.UnAdjSubSidy = src.UnAdjSubSidy,
                                T.CreditsinceDt = src.CreditsinceDt,
                                T.DegReason = src.DegReason,
                                T.Asset_Norm = src.Asset_Norm,
                                T.REFPeriodMax = src.REFPeriodMax,
                                T.RefPeriodOverdue = src.RefPeriodOverdue,
                                T.RefPeriodOverDrawn = src.RefPeriodOverDrawn,
                                T.RefPeriodNoCredit = src.RefPeriodNoCredit,
                                T.RefPeriodIntService = src.RefPeriodIntService,
                                T.RefPeriodStkStatement = src.RefPeriodStkStatement,
                                T.RefPeriodReview = src.RefPeriodReview,
                                T.NetBalance = src.NetBalance,
                                T.ApprRV = src.ApprRV,
                                T.SecuredAmt = src.SecuredAmt,
                                T.UnSecuredAmt = src.UnSecuredAmt,
                                T.ProvDFV = src.ProvDFV,
                                T.Provsecured = src.Provsecured,
                                T.ProvUnsecured = src.ProvUnsecured,
                                T.ProvCoverGovGur = src.ProvCoverGovGur,
                                T.AddlProvision = src.AddlProvision,
                                T.TotalProvision = src.TotalProvision,
                                T.BankProvsecured = src.BankProvsecured,
                                T.BankProvUnsecured = src.BankProvUnsecured,
                                T.BankTotalProvision = src.BankTotalProvision,
                                T.RBIProvsecured = src.RBIProvsecured,
                                T.RBIProvUnsecured = src.RBIProvUnsecured,
                                T.RBITotalProvision = src.RBITotalProvision,
                                T.InitialNpaDt = src.InitialNpaDt,
                                T.FinalNpaDt = src.FinalNpaDt,
                                T.SMA_Dt = src.SMA_Dt,
                                T.UpgDate = src.UpgDate,
                                T.InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                T.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                T.ProvisionAlt_Key = src.ProvisionAlt_Key,
                                T.PNPA_Reason = src.PNPA_Reason,
                                T.SMA_Class = src.SMA_Class,
                                T.SMA_Reason = src.SMA_Reason,
                                T.FlgMoc = src.FlgMoc,
                                T.MOC_Dt = src.MOC_Dt,
                                T.CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                T.FlgDeg = src.FlgDeg,
                                T.FlgDirtyRow = src.FlgDirtyRow,
                                T.FlgInMonth = src.FlgInMonth,
                                T.FlgSMA = src.FlgSMA,
                                T.FlgPNPA = src.FlgPNPA,
                                T.FlgUpg = src.FlgUpg,
                                T.FlgFITL = src.FlgFITL,
                                T.FlgAbinitio = src.FlgAbinitio,
                                T.NPA_Days = src.NPA_Days,
                                T.RefPeriodOverdueUPG = src.RefPeriodOverdueUPG,
                                T.RefPeriodOverDrawnUPG = src.RefPeriodOverDrawnUPG,
                                T.RefPeriodNoCreditUPG = src.RefPeriodNoCreditUPG,
                                T.RefPeriodIntServiceUPG = src.RefPeriodIntServiceUPG,
                                T.RefPeriodStkStatementUPG = src.RefPeriodStkStatementUPG,
                                T.RefPeriodReviewUPG = src.RefPeriodReviewUPG,
                                T.AppGovGur = src.AppGovGur,
                                T.UsedRV = src.UsedRV,
                                T.ComputedClaim = src.ComputedClaim,
                                T.UPG_RELAX_MSME = src.UPG_RELAX_MSME,
                                T.DEG_RELAX_MSME = src.DEG_RELAX_MSME,
                                T.PNPA_DATE = src.PNPA_DATE,
                                T.NPA_Reason = src.NPA_Reason,
                                T.PnpaAssetClassAlt_key = src.PnpaAssetClassAlt_key,
                                T.DisbAmount = src.DisbAmount,
                                T.PrincOutStd = src.PrincOutStd,
                                T.PrincOverdue = src.PrincOverdue,
                                T.PrincOverdueSinceDt = src.PrincOverdueSinceDt,
                                T.IntOverdue = src.IntOverdue,
                                T.IntOverdueSinceDt = src.IntOverdueSinceDt,
                                T.OtherOverdue = src.OtherOverdue,
                                T.OtherOverdueSinceDt = src.OtherOverdueSinceDt,
                                T.RelationshipNumber = src.RelationshipNumber,
                                T.AccountFlag = src.AccountFlag,
                                T.CommercialFlag_AltKey = src.CommercialFlag_AltKey,
                                T.Liability = src.Liability,
                                T.CD = src.CD,
                                T.AccountStatus = src.AccountStatus,
                                T.AccountBlkCode1 = src.AccountBlkCode1,
                                T.AccountBlkCode2 = src.AccountBlkCode2,
                                T.ExposureType = src.ExposureType,
                                T.Mtm_Value = src.Mtm_Value,
                                T.BankAssetClass = src.BankAssetClass,
                                T.NpaType = src.NpaType,
                                T.SecApp = src.SecApp,
                                T.BorrowerTypeID = src.BorrowerTypeID,
                                T.LineCode = src.LineCode,
                                T.ProvPerSecured = src.ProvPerSecured,
                                T.ProvPerUnSecured = src.ProvPerUnSecured,
                                T.MOCReason = src.MOCReason,
                                T.AddlProvisionPer = src.AddlProvisionPer,
                                T.FlgINFRA = src.FlgINFRA,
                                T.RepossessionDate = src.RepossessionDate,
                                T.DerecognisedInterest1 = src.DerecognisedInterest1,
                                T.DerecognisedInterest2 = src.DerecognisedInterest2,
                                T.ProductCode = src.ProductCode,
                                T.FlgLCBG = src.FlgLCBG,
                                T.unserviedint = src.UnserviedInt,
                                T.PreQtrCredit = src.PreQtrCredit,
                                T.PrvQtrInt = src.PrvQtrInt,
                                T.CurQtrCredit = src.CurQtrCredit,
                                T.CurQtrInt = src.CurQtrInt,
                                T.OriginalBranchcode = src.OriginalBranchcode,
                                T.AdvanceRecovery = src.AdvanceRecovery,
                                T.NotionalInttAmt = src.NotionalInttAmt,
                                T.PrvAssetClassAlt_Key = src.PrvAssetClassAlt_Key,
                                T.MOCTYPE = src.MOCTYPE,
                                T.FlgSecured = src.FlgSecured,
                                T.RePossession = src.RePossession,
                                T.RCPending = src.RCPending,
                                T.PaymentPending = src.PaymentPending,
                                T.WheelCase = src.WheelCase,
                                T.CustomerLevelMaxPer = src.CustomerLevelMaxPer,
                                T.FinalProvisionPer = src.FinalProvisionPer,
                                T.IsIBPC = src.IsIBPC,
                                T.IsSecuritised = src.IsSecuritised,
                                T.RFA = src.RFA,
                                T.IsNonCooperative = src.IsNonCooperative,
                                T.Sarfaesi = src.Sarfaesi,
                                T.WeakAccount = src.WeakAccount,
                                T.PUI = src.PUI,
                                T.FlgFraud = src.FlgFraud,
                                T.FlgRestructure = src.FlgRestructure,
                                T.RestructureDate = src.RestructureDate,
                                T.SarfaesiDate = src.SarfaesiDate,
                                T.FlgUnusualBounce = src.FlgUnusualBounce,
                                T.UnusualBounceDate = src.UnusualBounceDate,
                                T.FlgUnClearedEffect = src.FlgUnClearedEffect,
                                T.UnClearedEffectDate = src.UnClearedEffectDate,
                                T.FraudDate = src.FraudDate,
                                T.WeakAccountDate = src.WeakAccountDate;
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyAcct
     FROM MAIN_PRO.AccountCal_Hist ;
   IF v_EntityKeyAcct IS NULL THEN

   BEGIN
      v_EntityKeyAcct := 0 ;

   END;
   END IF;
   MERGE INTO MAIN_PRO.ACCOUNTCAL TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM MAIN_PRO.ACCOUNTCAL TEMP
          JOIN ( SELECT ACCOUNTCAL.AccountEntityID ,
                        (v_EntityKeyAcct + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                            FROM DUAL  )  )) EntityKeyNew  
                 FROM MAIN_PRO.ACCOUNTCAL ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.AccountEntityID = ACCT.AccountEntityID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   MERGE INTO MAIN_PRO.ACCOUNTCAL T
   USING (SELECT T.ROWID row_id, 'Y'
   FROM MAIN_PRO.ACCOUNTCAL T
          LEFT JOIN MAIN_PRO.AccountCal_Hist B   ON B.EffectiveFromTimeKey = v_TIMEKEY
          AND B.EffectiveToTimeKey = v_TIMEKEY
          AND B.AccountEntityID = T.AccountEntityID 
    WHERE B.AccountEntityID IS NULL) src
   ON ( T.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET t.IsChanged = 'Y';
   /***************************************************************************************************************/
   INSERT INTO MAIN_PRO.AccountCal_Hist
     ( EntityKey, AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgFraud, FlgRestructure, RestructureDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FraudDate, WeakAccountDate, ScreenFlag, ChangeField )
     ( SELECT T.EntityKeyNew ,
              T.AccountEntityID ,
              T.UcifEntityID ,
              T.CustomerEntityID ,
              T.CustomerAcID ,
              T.RefCustomerID ,
              T.SourceSystemCustomerID ,
              T.UCIF_ID ,
              T.BranchCode ,
              T.FacilityType ,
              T.AcOpenDt ,
              T.FirstDtOfDisb ,
              T.ProductAlt_Key ,
              T.SchemeAlt_key ,
              T.SubSectorAlt_Key ,
              T.SplCatg1Alt_Key ,
              T.SplCatg2Alt_Key ,
              T.SplCatg3Alt_Key ,
              T.SplCatg4Alt_Key ,
              T.SourceAlt_Key ,
              T.ActSegmentCode ,
              T.InttRate ,
              T.Balance ,
              T.BalanceInCrncy ,
              T.CurrencyAlt_Key ,
              T.DrawingPower ,
              T.CurrentLimit ,
              T.CurrentLimitDt ,
              T.ContiExcessDt ,
              T.StockStDt ,
              T.DebitSinceDt ,
              T.LastCrDate ,
              T.InttServiced ,
              T.IntNotServicedDt ,
              T.OverdueAmt ,
              T.OverDueSinceDt ,
              T.ReviewDueDt ,
              T.SecurityValue ,
              T.DFVAmt ,
              T.GovtGtyAmt ,
              T.CoverGovGur ,
              T.WriteOffAmount ,
              T.UnAdjSubSidy ,
              T.CreditsinceDt ,
              T.DegReason ,
              T.Asset_Norm ,
              T.REFPeriodMax ,
              T.RefPeriodOverdue ,
              T.RefPeriodOverDrawn ,
              T.RefPeriodNoCredit ,
              T.RefPeriodIntService ,
              T.RefPeriodStkStatement ,
              T.RefPeriodReview ,
              T.NetBalance ,
              T.ApprRV ,
              T.SecuredAmt ,
              T.UnSecuredAmt ,
              T.ProvDFV ,
              T.Provsecured ,
              T.ProvUnsecured ,
              T.ProvCoverGovGur ,
              T.AddlProvision ,
              T.TotalProvision ,
              T.BankProvsecured ,
              T.BankProvUnsecured ,
              T.BankTotalProvision ,
              T.RBIProvsecured ,
              T.RBIProvUnsecured ,
              T.RBITotalProvision ,
              T.InitialNpaDt ,
              T.FinalNpaDt ,
              T.SMA_Dt ,
              T.UpgDate ,
              T.InitialAssetClassAlt_Key ,
              T.FinalAssetClassAlt_Key ,
              T.ProvisionAlt_Key ,
              T.PNPA_Reason ,
              T.SMA_Class ,
              T.SMA_Reason ,
              T.FlgMoc ,
              T.MOC_Dt ,
              T.CommonMocTypeAlt_Key ,
              T.FlgDeg ,
              T.FlgDirtyRow ,
              T.FlgInMonth ,
              T.FlgSMA ,
              T.FlgPNPA ,
              T.FlgUpg ,
              T.FlgFITL ,
              T.FlgAbinitio ,
              T.NPA_Days ,
              T.RefPeriodOverdueUPG ,
              T.RefPeriodOverDrawnUPG ,
              T.RefPeriodNoCreditUPG ,
              T.RefPeriodIntServiceUPG ,
              T.RefPeriodStkStatementUPG ,
              T.RefPeriodReviewUPG ,
              v_TimeKey EffectiveFromTimeKey  ,
              v_TimeKey EffectiveToTimeKey  ,
              T.AppGovGur ,
              T.UsedRV ,
              T.ComputedClaim ,
              T.UPG_RELAX_MSME ,
              T.DEG_RELAX_MSME ,
              T.PNPA_DATE ,
              T.NPA_Reason ,
              T.PnpaAssetClassAlt_key ,
              T.DisbAmount ,
              T.PrincOutStd ,
              T.PrincOverdue ,
              T.PrincOverdueSinceDt ,
              T.IntOverdue ,
              T.IntOverdueSinceDt ,
              T.OtherOverdue ,
              T.OtherOverdueSinceDt ,
              T.RelationshipNumber ,
              T.AccountFlag ,
              T.CommercialFlag_AltKey ,
              T.Liability ,
              T.CD ,
              T.AccountStatus ,
              T.AccountBlkCode1 ,
              T.AccountBlkCode2 ,
              T.ExposureType ,
              T.Mtm_Value ,
              T.BankAssetClass ,
              T.NpaType ,
              T.SecApp ,
              T.BorrowerTypeID ,
              T.LineCode ,
              T.ProvPerSecured ,
              T.ProvPerUnSecured ,
              T.MOCReason ,
              T.AddlProvisionPer ,
              T.FlgINFRA ,
              T.RepossessionDate ,
              T.DerecognisedInterest1 ,
              T.DerecognisedInterest2 ,
              T.ProductCode ,
              T.FlgLCBG ,
              T.UnserviedInt ,
              T.PreQtrCredit ,
              T.PrvQtrInt ,
              T.CurQtrCredit ,
              T.CurQtrInt ,
              T.OriginalBranchcode ,
              T.AdvanceRecovery ,
              T.NotionalInttAmt ,
              T.PrvAssetClassAlt_Key ,
              T.MOCTYPE ,
              T.FlgSecured ,
              T.RePossession ,
              T.RCPending ,
              T.PaymentPending ,
              T.WheelCase ,
              T.CustomerLevelMaxPer ,
              T.FinalProvisionPer ,
              T.IsIBPC ,
              T.IsSecuritised ,
              T.RFA ,
              T.IsNonCooperative ,
              T.Sarfaesi ,
              T.WeakAccount ,
              T.PUI ,
              T.FlgFraud ,
              T.FlgRestructure ,
              T.RestructureDate ,
              T.SarfaesiDate ,
              T.FlgUnusualBounce ,
              T.UnusualBounceDate ,
              T.FlgUnClearedEffect ,
              T.UnClearedEffectDate ,
              T.FraudDate ,
              T.WeakAccountDate ,
              NULL ScreenFlag  ,
              NULL ChangeField  

       --select SUM(BALANCE)/10000000,  count(1)
       FROM MAIN_PRO.ACCOUNTCAL T
        WHERE  T.IsChanged = 'Y' );
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyAcct1
     FROM MAIN_PRO.AccountCal_Hist ;
   IF v_EntityKeyAcct1 IS NULL THEN

   BEGIN
      v_EntityKeyAcct1 := 0 ;

   END;
   END IF;
   MERGE INTO GTT_AccountCal_BACKDTD TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_AccountCal_BACKDTD TEMP
          JOIN ( SELECT GTT_AccountCal_BACKDTD.AccountEntityID ,
                        (v_EntityKeyAcct1 + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                             FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_AccountCal_BACKDTD ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.AccountEntityID = ACCT.AccountEntityID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   INSERT INTO MAIN_PRO.AccountCal_Hist
     ( EntityKey, AccountEntityID, UcifEntityID, CustomerEntityID, CustomerAcID, RefCustomerID, SourceSystemCustomerID, UCIF_ID, BranchCode, FacilityType, AcOpenDt, FirstDtOfDisb, ProductAlt_Key, SchemeAlt_key, SubSectorAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceAlt_Key, ActSegmentCode, InttRate, Balance, BalanceInCrncy, CurrencyAlt_Key, DrawingPower, CurrentLimit, CurrentLimitDt, ContiExcessDt, StockStDt, DebitSinceDt, LastCrDate, InttServiced, IntNotServicedDt, OverdueAmt, OverDueSinceDt, ReviewDueDt, SecurityValue, DFVAmt, GovtGtyAmt, CoverGovGur, WriteOffAmount, UnAdjSubSidy, CreditsinceDt, DegReason, Asset_Norm, REFPeriodMax, RefPeriodOverdue, RefPeriodOverDrawn, RefPeriodNoCredit, RefPeriodIntService, RefPeriodStkStatement, RefPeriodReview, NetBalance, ApprRV, SecuredAmt, UnSecuredAmt, ProvDFV, Provsecured, ProvUnsecured, ProvCoverGovGur, AddlProvision, TotalProvision, BankProvsecured, BankProvUnsecured, BankTotalProvision, RBIProvsecured, RBIProvUnsecured, RBITotalProvision, InitialNpaDt, FinalNpaDt, SMA_Dt, UpgDate, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, ProvisionAlt_Key, PNPA_Reason, SMA_Class, SMA_Reason, FlgMoc, MOC_Dt, CommonMocTypeAlt_Key, FlgDeg, FlgDirtyRow, FlgInMonth, FlgSMA, FlgPNPA, FlgUpg, FlgFITL, FlgAbinitio, NPA_Days, RefPeriodOverdueUPG, RefPeriodOverDrawnUPG, RefPeriodNoCreditUPG, RefPeriodIntServiceUPG, RefPeriodStkStatementUPG, RefPeriodReviewUPG, EffectiveFromTimeKey, EffectiveToTimeKey, AppGovGur, UsedRV, ComputedClaim, UPG_RELAX_MSME, DEG_RELAX_MSME, PNPA_DATE, NPA_Reason, PnpaAssetClassAlt_key, DisbAmount, PrincOutStd, PrincOverdue, PrincOverdueSinceDt, IntOverdue, IntOverdueSinceDt, OtherOverdue, OtherOverdueSinceDt, RelationshipNumber, AccountFlag, CommercialFlag_AltKey, Liability, CD, AccountStatus, AccountBlkCode1, AccountBlkCode2, ExposureType, Mtm_Value, BankAssetClass, NpaType, SecApp, BorrowerTypeID, LineCode, ProvPerSecured, ProvPerUnSecured, MOCReason, AddlProvisionPer, FlgINFRA, RepossessionDate, DerecognisedInterest1, DerecognisedInterest2, ProductCode, FlgLCBG, unserviedint, PreQtrCredit, PrvQtrInt, CurQtrCredit, CurQtrInt, OriginalBranchcode, AdvanceRecovery, NotionalInttAmt, PrvAssetClassAlt_Key, MOCTYPE, FlgSecured, RePossession, RCPending, PaymentPending, WheelCase, CustomerLevelMaxPer, FinalProvisionPer, IsIBPC, IsSecuritised, RFA, IsNonCooperative, Sarfaesi, WeakAccount, PUI, FlgFraud, FlgRestructure, RestructureDate, SarfaesiDate, FlgUnusualBounce, UnusualBounceDate, FlgUnClearedEffect, UnClearedEffectDate, FraudDate, WeakAccountDate, ScreenFlag, ChangeField )
     ( SELECT T.EntityKeyNew ,
              T.AccountEntityID ,
              T.UcifEntityID ,
              T.CustomerEntityID ,
              T.CustomerAcID ,
              T.RefCustomerID ,
              T.SourceSystemCustomerID ,
              T.UCIF_ID ,
              T.BranchCode ,
              T.FacilityType ,
              T.AcOpenDt ,
              T.FirstDtOfDisb ,
              T.ProductAlt_Key ,
              T.SchemeAlt_key ,
              T.SubSectorAlt_Key ,
              T.SplCatg1Alt_Key ,
              T.SplCatg2Alt_Key ,
              T.SplCatg3Alt_Key ,
              T.SplCatg4Alt_Key ,
              T.SourceAlt_Key ,
              T.ActSegmentCode ,
              T.InttRate ,
              T.Balance ,
              T.BalanceInCrncy ,
              T.CurrencyAlt_Key ,
              T.DrawingPower ,
              T.CurrentLimit ,
              T.CurrentLimitDt ,
              T.ContiExcessDt ,
              T.StockStDt ,
              T.DebitSinceDt ,
              T.LastCrDate ,
              T.InttServiced ,
              T.IntNotServicedDt ,
              T.OverdueAmt ,
              T.OverDueSinceDt ,
              T.ReviewDueDt ,
              T.SecurityValue ,
              T.DFVAmt ,
              T.GovtGtyAmt ,
              T.CoverGovGur ,
              T.WriteOffAmount ,
              T.UnAdjSubSidy ,
              T.CreditsinceDt ,
              T.DegReason ,
              T.Asset_Norm ,
              T.REFPeriodMax ,
              T.RefPeriodOverdue ,
              T.RefPeriodOverDrawn ,
              T.RefPeriodNoCredit ,
              T.RefPeriodIntService ,
              T.RefPeriodStkStatement ,
              T.RefPeriodReview ,
              T.NetBalance ,
              T.ApprRV ,
              T.SecuredAmt ,
              T.UnSecuredAmt ,
              T.ProvDFV ,
              T.Provsecured ,
              T.ProvUnsecured ,
              T.ProvCoverGovGur ,
              T.AddlProvision ,
              T.TotalProvision ,
              T.BankProvsecured ,
              T.BankProvUnsecured ,
              T.BankTotalProvision ,
              T.RBIProvsecured ,
              T.RBIProvUnsecured ,
              T.RBITotalProvision ,
              T.InitialNpaDt ,
              T.FinalNpaDt ,
              T.SMA_Dt ,
              T.UpgDate ,
              T.InitialAssetClassAlt_Key ,
              T.FinalAssetClassAlt_Key ,
              T.ProvisionAlt_Key ,
              T.PNPA_Reason ,
              T.SMA_Class ,
              T.SMA_Reason ,
              T.FlgMoc ,
              T.MOC_Dt ,
              T.CommonMocTypeAlt_Key ,
              T.FlgDeg ,
              T.FlgDirtyRow ,
              T.FlgInMonth ,
              T.FlgSMA ,
              T.FlgPNPA ,
              T.FlgUpg ,
              T.FlgFITL ,
              T.FlgAbinitio ,
              T.NPA_Days ,
              T.RefPeriodOverdueUPG ,
              T.RefPeriodOverDrawnUPG ,
              T.RefPeriodNoCreditUPG ,
              T.RefPeriodIntServiceUPG ,
              T.RefPeriodStkStatementUPG ,
              T.RefPeriodReviewUPG ,
              v_TimeKey + 1 EffectiveFromTimeKey  ,
              EffectiveToTimeKey ,
              T.AppGovGur ,
              T.UsedRV ,
              T.ComputedClaim ,
              T.UPG_RELAX_MSME ,
              T.DEG_RELAX_MSME ,
              T.PNPA_DATE ,
              T.NPA_Reason ,
              T.PnpaAssetClassAlt_key ,
              T.DisbAmount ,
              T.PrincOutStd ,
              T.PrincOverdue ,
              T.PrincOverdueSinceDt ,
              T.IntOverdue ,
              T.IntOverdueSinceDt ,
              T.OtherOverdue ,
              T.OtherOverdueSinceDt ,
              T.RelationshipNumber ,
              T.AccountFlag ,
              T.CommercialFlag_AltKey ,
              T.Liability ,
              T.CD ,
              T.AccountStatus ,
              T.AccountBlkCode1 ,
              T.AccountBlkCode2 ,
              T.ExposureType ,
              T.Mtm_Value ,
              T.BankAssetClass ,
              T.NpaType ,
              T.SecApp ,
              T.BorrowerTypeID ,
              T.LineCode ,
              T.ProvPerSecured ,
              T.ProvPerUnSecured ,
              T.MOCReason ,
              T.AddlProvisionPer ,
              T.FlgINFRA ,
              T.RepossessionDate ,
              T.DerecognisedInterest1 ,
              T.DerecognisedInterest2 ,
              T.ProductCode ,
              T.FlgLCBG ,
              T.unserviedint ,
              T.PreQtrCredit ,
              T.PrvQtrInt ,
              T.CurQtrCredit ,
              T.CurQtrInt ,
              T.OriginalBranchcode ,
              T.AdvanceRecovery ,
              T.NotionalInttAmt ,
              T.PrvAssetClassAlt_Key ,
              T.MOCTYPE ,
              T.FlgSecured ,
              T.RePossession ,
              T.RCPending ,
              T.PaymentPending ,
              T.WheelCase ,
              T.CustomerLevelMaxPer ,
              T.FinalProvisionPer ,
              T.IsIBPC ,
              T.IsSecuritised ,
              T.RFA ,
              T.IsNonCooperative ,
              T.Sarfaesi ,
              T.WeakAccount ,
              T.PUI ,
              T.FlgFraud ,
              T.FlgRestructure ,
              T.RestructureDate ,
              T.SarfaesiDate ,
              T.FlgUnusualBounce ,
              T.UnusualBounceDate ,
              T.FlgUnClearedEffect ,
              T.UnClearedEffectDate ,
              T.FraudDate ,
              T.WeakAccountDate ,
              NULL ScreenFlag  ,
              NULL ChangeField  
       FROM GTT_AccountCal_BACKDTD T
        WHERE  EffectiveToTimeKey > v_TIMEKEY );
   UPDATE MAIN_PRO.AclRunningProcessStatus
      SET COMPLETED = 'Y',
          ERRORDATE = NULL,
          ERRORDESCRIPTION = NULL,
          COUNT = NVL(COUNT, 0) + 1
    WHERE  RUNNINGPROCESSNAME = 'InsertDataIntoHistTable';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_BACKDTD" TO "ADF_CDR_RBL_STGDB";
