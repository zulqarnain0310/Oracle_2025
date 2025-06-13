--------------------------------------------------------
--  DDL for Procedure INSERTDATAINTOHIST_TABLE_OPT_MOC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" 
(
  v_TIMEKEY IN NUMBER
)
AS
   /* INSERT DATA FOR MOC TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyCust NUMBER(19,0) := 0;
   --LEFT JOIN PRO.CustomerCal_Hist B
   --	 ON B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
   --	 AND B.CustomerEntityID =T.CustomerEntityID
   -----WHERE t.CustomerEntityID not in (select a.CustomerEntityID from pro.CUSTOMERCAL_hist a where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY )--and t.CustomerEntityID=a.CustomerEntityID )
   /* INSERT RECORD FOR  LIVE AFTE MOC TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyCust1 NUMBER(19,0) := 0;
   /* INSERT DATA FOR MOC TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyAcct NUMBER(19,0) := 0;
   /* INSERT RECORD FOR  LIVE AFTE MOC TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyAcct1 NUMBER(19,0) := 0;
   /* INSERT DATA FOR MOC TIMEKEY - THOSE RECORDS ARE NOT PRESENT ON MIC TIMKEY AFTER EXPIRE */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyRestr NUMBER(19,0) := 0;
   --LEFT JOIN PRO.CustomerCal_Hist B
   --	 ON B.EffectiveFromTimeKey=@TIMEKEY AND B.EffectiveToTimeKey=@TIMEKEY
   --	 AND B.CustomerEntityID =T.CustomerEntityID
   -----WHERE t.CustomerEntityID not in (select a.CustomerEntityID from pro.CUSTOMERCAL_hist a where EffectiveFromTimeKey=@TIMEKEY and EffectiveToTimeKey=@TIMEKEY )--and t.CustomerEntityID=a.CustomerEntityID )
   /* INSERT RECORD FOR  LIVE AFTE MOC TIMEKEY - IN THIS CASE EFFECTIVEFROMTIMEKEY WILL BE @TIMEKEY+1 AND EFFECTIVETOTIMEKEY WIL BE RMAIL SAME */
   /*  New Customers Ac Key ID Update  */
   v_EntityKeyRestr1 NUMBER(19,0) := 0;

BEGIN

   UPDATE GTT_CUSTOMERCAL
      SET IsChanged = NULL;
   UPDATE GTT_AccountCal
      SET IsChanged = NULL;
   DELETE FROM GTT_CustomerCal_Moc;
   UTILS.IDENTITY_RESET('GTT_CustomerCal_Moc');

   INSERT INTO GTT_CustomerCal_Moc ( ENTITYKEY,	BRANCHCODE,	UCIF_ID,	UCIFENTITYID,	CUSTOMERENTITYID,	PARENTCUSTOMERID,	REFCUSTOMERID,	SOURCESYSTEMCUSTOMERID,	CUSTOMERNAME,	CUSTSEGMENTCODE,	CONSTITUTIONALT_KEY,	PANNO,	AADHARCARDNO,	SRCASSETCLASSALT_KEY,	SYSASSETCLASSALT_KEY,	SPLCATG1ALT_KEY,	SPLCATG2ALT_KEY,	SPLCATG3ALT_KEY,	SPLCATG4ALT_KEY,	SMA_CLASS_KEY,	PNPA_CLASS_KEY,	PRVQTRRV,	CURNTQTRRV,	TOTPROVISION,	BANKTOTPROVISION,	RBITOTPROVISION,	SRCNPA_DT,	SYSNPA_DT,	DBTDT,	DBTDT2,	DBTDT3,	LOSSDT,	MOC_DT,	EROSIONDT,	SMA_DT,	PNPA_DT,	ASSET_NORM,	FLGDEG,	FLGUPG,	FLGMOC,	FLGSMA,	FLGPROCESSING,	FLGEROSION,	FLGPNPA,	FLGPERCOLATION,	FLGINMONTH,	FLGDIRTYROW,	DEGDATE,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	COMMONMOCTYPEALT_KEY,	INMONTHMARK,	MOCSTATUSMARK,	SOURCEALT_KEY,	BANKASSETCLASS,	CUST_EXPO,	MOCREASON,	ADDLPROVISIONPER,	FRAUDDT,	FRAUDAMOUNT,	DEGREASON,	CUSTMOVEDESCRIPTION,	TOTOSCUST,	MOCTYPE,	SCREENFLAG,	CHANGEFLD,EntityKeyNew)
   	SELECT A.ENTITYKEY,	A.BRANCHCODE,	A.UCIF_ID,	A.UCIFENTITYID,	A.CUSTOMERENTITYID,	A.PARENTCUSTOMERID,	A.REFCUSTOMERID,	A.SOURCESYSTEMCUSTOMERID,	A.CUSTOMERNAME,	A.CUSTSEGMENTCODE,	A.CONSTITUTIONALT_KEY,	A.PANNO,	A.AADHARCARDNO,	A.SRCASSETCLASSALT_KEY,	A.SYSASSETCLASSALT_KEY,	A.SPLCATG1ALT_KEY,	A.SPLCATG2ALT_KEY,	A.SPLCATG3ALT_KEY,	A.SPLCATG4ALT_KEY,	A.SMA_CLASS_KEY,	A.PNPA_CLASS_KEY,	A.PRVQTRRV,	A.CURNTQTRRV,	A.TOTPROVISION,	A.BANKTOTPROVISION,	A.RBITOTPROVISION,	A.SRCNPA_DT,	A.SYSNPA_DT,	A.DBTDT,	A.DBTDT2,	A.DBTDT3,	A.LOSSDT,	A.MOC_DT,	A.EROSIONDT,	A.SMA_DT,	A.PNPA_DT,	A.ASSET_NORM,	A.FLGDEG,	A.FLGUPG,	A.FLGMOC,	A.FLGSMA,	A.FLGPROCESSING,	A.FLGEROSION,	A.FLGPNPA,	A.FLGPERCOLATION,	A.FLGINMONTH,	A.FLGDIRTYROW,	A.DEGDATE,	A.EFFECTIVEFROMTIMEKEY,	A.EFFECTIVETOTIMEKEY,	A.COMMONMOCTYPEALT_KEY,	A.INMONTHMARK,	A.MOCSTATUSMARK,	A.SOURCEALT_KEY,	A.BANKASSETCLASS,	A.CUST_EXPO,	A.MOCREASON,	A.ADDLPROVISIONPER,	A.FRAUDDT,	A.FRAUDAMOUNT,	A.DEGREASON,	A.CUSTMOVEDESCRIPTION,	A.TOTOSCUST,	A.MOCTYPE,	A.SCREENFLAG,	A.CHANGEFLD,
           UTILS.CONVERT_TO_NUMBER(0,19,0) EntityKeyNew  
   	  FROM MAIN_PRO.CustomerCal_Hist A
             JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY ;
   /* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO MOC OT GRATER THAN MOC TIMKEY*/
   MERGE INTO MAIN_PRO.CustomerCal_Hist A
   USING (SELECT A.ROWID row_id, CASE 
   WHEN a.EffectiveFromTimeKey < v_TIMEKEY THEN v_TIMEKEY - 1
   ELSE v_TIMEKEY
      END AS EffectiveToTimeKey
   FROM MAIN_PRO.CustomerCal_Hist A
          JOIN GTT_CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
          AND A.EffectiveFromTimeKey <= v_TIMEKEY
          AND A.EffectiveToTimeKey >= v_TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
   /* UPADTE DATA AVAILABLE ON SAME TMEKEY */
   MERGE INTO MAIN_PRO.CustomerCal_Hist O
   USING (SELECT O.ROWID row_id, T.BranchCode, T.UCIF_ID, T.UcifEntityID, T.ParentCustomerID, T.RefCustomerID, T.SourceSystemCustomerID, T.CustomerName, T.CustSegmentCode, T.ConstitutionAlt_Key, T.PANNO, T.AadharCardNO, T.SrcAssetClassAlt_Key, T.SysAssetClassAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SMA_Class_Key, T.PNPA_Class_Key, T.PrvQtrRV, T.CurntQtrRv, T.TotProvision, T.BankTotProvision, T.RBITotProvision, T.SrcNPA_Dt, T.SysNPA_Dt, T.DbtDt, T.DbtDt2, T.DbtDt3, T.LossDt, T.MOC_Dt, T.ErosionDt, T.SMA_Dt, T.PNPA_Dt, T.Asset_Norm, T.FlgDeg, T.FlgUpg, T.FlgMoc, T.FlgSMA, T.FlgProcessing, T.FlgErosion, T.FlgPNPA, T.FlgPercolation, T.FlgInMonth, T.FlgDirtyRow, T.DegDate, T.CommonMocTypeAlt_Key, T.InMonthMark, T.MocStatusMark, T.SourceAlt_Key, T.BankAssetClass, T.Cust_Expo, T.MOCReason, T.AddlProvisionPer, T.FraudDt, T.FraudAmount, T.DegReason, T.CustMoveDescription, T.TotOsCust, T.MOCTYPE
   FROM MAIN_PRO.CustomerCal_Hist O
          JOIN GTT_CUSTOMERCAL T   ON O.CustomerEntityId = T.CustomerEntityId 
    WHERE O.EffectiveFromTimeKey = v_TimeKey
     AND O.EffectiveToTimeKey = v_TIMEKEY) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.BranchCode	=	src.BranchCode,
O.UCIF_ID	=	src.UCIF_ID,
O.UcifEntityID	=	src.UcifEntityID,
O.ParentCustomerID	=	src.ParentCustomerID,
O.RefCustomerID	=	src.RefCustomerID,
O.SourceSystemCustomerID	=	src.SourceSystemCustomerID,
O.CustomerName	=	src.CustomerName,
O.CustSegmentCode	=	src.CustSegmentCode,
O.ConstitutionAlt_Key	=	src.ConstitutionAlt_Key,
O.PANNO	=	src.PANNO,
O.AadharCardNO	=	src.AadharCardNO,
O.SrcAssetClassAlt_Key	=	src.SrcAssetClassAlt_Key,
O.SysAssetClassAlt_Key	=	src.SysAssetClassAlt_Key,
O.SplCatg1Alt_Key	=	src.SplCatg1Alt_Key,
O.SplCatg2Alt_Key	=	src.SplCatg2Alt_Key,
O.SplCatg3Alt_Key	=	src.SplCatg3Alt_Key,
O.SplCatg4Alt_Key	=	src.SplCatg4Alt_Key,
O.SMA_Class_Key	=	src.SMA_Class_Key,
O.PNPA_Class_Key	=	src.PNPA_Class_Key,
O.PrvQtrRV	=	src.PrvQtrRV,
O.CurntQtrRv	=	src.CurntQtrRv,
O.TotProvision	=	src.TotProvision,
O.BankTotProvision	=	src.BankTotProvision,
O.RBITotProvision	=	src.RBITotProvision,
O.SrcNPA_Dt	=	src.SrcNPA_Dt,
O.SysNPA_Dt	=	src.SysNPA_Dt,
O.DbtDt	=	src.DbtDt,
O.DbtDt2	=	src.DbtDt2,
O.DbtDt3	=	src.DbtDt3,
O.LossDt	=	src.LossDt,
O.MOC_Dt	=	src.MOC_Dt,
O.ErosionDt	=	src.ErosionDt,
O.SMA_Dt	=	src.SMA_Dt,
O.PNPA_Dt	=	src.PNPA_Dt,
O.Asset_Norm	=	src.Asset_Norm,
O.FlgDeg	=	src.FlgDeg,
O.FlgUpg	=	src.FlgUpg,
O.FlgMoc	=	src.FlgMoc,
O.FlgSMA	=	src.FlgSMA,
O.FlgProcessing	=	src.FlgProcessing,
O.FlgErosion	=	src.FlgErosion,
O.FlgPNPA	=	src.FlgPNPA,
O.FlgPercolation	=	src.FlgPercolation,
O.FlgInMonth	=	src.FlgInMonth,
O.FlgDirtyRow	=	src.FlgDirtyRow,
O.DegDate	=	src.DegDate,
O.CommonMocTypeAlt_Key	=	src.CommonMocTypeAlt_Key,
O.InMonthMark	=	src.InMonthMark,
O.MocStatusMark	=	src.MocStatusMark,
O.SourceAlt_Key	=	src.SourceAlt_Key,
O.BankAssetClass	=	src.BankAssetClass,
O.Cust_Expo	=	src.Cust_Expo,
O.MOCReason	=	src.MOCReason,
O.AddlProvisionPer	=	src.AddlProvisionPer,
O.FraudDt	=	src.FraudDt,
O.FraudAmount	=	src.FraudAmount,
O.DegReason	=	src.DegReason,
O.CustMoveDescription	=	src.CustMoveDescription,
O.TotOsCust	=	src.TotOsCust,
O.MOCTYPE	=	src.MOCTYPE;
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyCust
     FROM MAIN_PRO.CustomerCal_Hist ;
   IF v_EntityKeyCust IS NULL THEN

   BEGIN
      v_EntityKeyCust := 0 ;

   END;
   END IF;
   MERGE INTO GTT_CUSTOMERCAL TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_CUSTOMERCAL TEMP
          JOIN ( SELECT GTT_CUSTOMERCAL.CustomerEntityId ,
                        (v_EntityKeyCust + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                            FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_CUSTOMERCAL ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.CustomerEntityId = ACCT.CustomerEntityId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   MERGE INTO GTT_CUSTOMERCAL T
   USING (SELECT T.ROWID row_id, 'Y'
   FROM GTT_CUSTOMERCAL T
          LEFT JOIN MAIN_PRO.CustomerCal_Hist B   ON B.EffectiveFromTimeKey = v_TIMEKEY
          AND B.EffectiveToTimeKey = v_TIMEKEY
          AND B.CustomerEntityId = T.CustomerEntityId 
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
       FROM GTT_CUSTOMERCAL T
        WHERE  t.IsChanged = 'Y' );
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyCust1
     FROM MAIN_PRO.CustomerCal_Hist ;
   IF v_EntityKeyCust IS NULL THEN

   BEGIN
      v_EntityKeyCust1 := 0 ;

   END;
   END IF;
   MERGE INTO GTT_CustomerCal_Moc TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_CustomerCal_Moc TEMP
          JOIN ( SELECT GTT_CustomerCal_Moc.CustomerEntityId ,
                        (v_EntityKeyCust1 + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                             FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_CustomerCal_Moc ---Where IsChanged in ('C','N')
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
       FROM GTT_CustomerCal_Moc T
        WHERE  EffectiveToTimeKey > v_TIMEKEY );
   /* ACCOUNT - MOC */
   DELETE FROM GTT_AccountCal_Moc;
   UTILS.IDENTITY_RESET('GTT_AccountCal_Moc');

   INSERT INTO GTT_AccountCal_Moc ( ENTITYKEY,	ACCOUNTENTITYID,	UCIFENTITYID,	CUSTOMERENTITYID,	CUSTOMERACID,	REFCUSTOMERID,	SOURCESYSTEMCUSTOMERID,	UCIF_ID,	BRANCHCODE,	FACILITYTYPE,	ACOPENDT,	FIRSTDTOFDISB,	PRODUCTALT_KEY,	SCHEMEALT_KEY,	SUBSECTORALT_KEY,	SPLCATG1ALT_KEY,	SPLCATG2ALT_KEY,	SPLCATG3ALT_KEY,	SPLCATG4ALT_KEY,	SOURCEALT_KEY,	ACTSEGMENTCODE,	INTTRATE,	BALANCE,	BALANCEINCRNCY,	CURRENCYALT_KEY,	DRAWINGPOWER,	CURRENTLIMIT,	CURRENTLIMITDT,	CONTIEXCESSDT,	STOCKSTDT,	DEBITSINCEDT,	LASTCRDATE,	INTTSERVICED,	INTNOTSERVICEDDT,	OVERDUEAMT,	OVERDUESINCEDT,	REVIEWDUEDT,	SECURITYVALUE,	DFVAMT,	GOVTGTYAMT,	COVERGOVGUR,	WRITEOFFAMOUNT,	UNADJSUBSIDY,	CREDITSINCEDT,	DEGREASON,	ASSET_NORM,	REFPERIODMAX,	REFPERIODOVERDUE,	REFPERIODOVERDRAWN,	REFPERIODNOCREDIT,	REFPERIODINTSERVICE,	REFPERIODSTKSTATEMENT,	REFPERIODREVIEW,	NETBALANCE,	APPRRV,	SECUREDAMT,	UNSECUREDAMT,	PROVDFV,	PROVSECURED,	PROVUNSECURED,	PROVCOVERGOVGUR,	ADDLPROVISION,	TOTALPROVISION,	BANKPROVSECURED,	BANKPROVUNSECURED,	BANKTOTALPROVISION,	RBIPROVSECURED,	RBIPROVUNSECURED,	RBITOTALPROVISION,	INITIALNPADT,	FINALNPADT,	SMA_DT,	UPGDATE,	INITIALASSETCLASSALT_KEY,	FINALASSETCLASSALT_KEY,	PROVISIONALT_KEY,	PNPA_REASON,	SMA_CLASS,	SMA_REASON,	FLGMOC,	MOC_DT,	COMMONMOCTYPEALT_KEY,	FLGDEG,	FLGDIRTYROW,	FLGINMONTH,	FLGSMA,	FLGPNPA,	FLGUPG,	FLGFITL,	FLGABINITIO,	NPA_DAYS,	REFPERIODOVERDUEUPG,	REFPERIODOVERDRAWNUPG,	REFPERIODNOCREDITUPG,	REFPERIODINTSERVICEUPG,	REFPERIODSTKSTATEMENTUPG,	REFPERIODREVIEWUPG,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	APPGOVGUR,	USEDRV,	COMPUTEDCLAIM,	UPG_RELAX_MSME,	DEG_RELAX_MSME,	PNPA_DATE,	NPA_REASON,	PNPAASSETCLASSALT_KEY,	DISBAMOUNT,	PRINCOUTSTD,	PRINCOVERDUE,	PRINCOVERDUESINCEDT,	INTOVERDUE,	INTOVERDUESINCEDT,	OTHEROVERDUE,	OTHEROVERDUESINCEDT,	RELATIONSHIPNUMBER,	ACCOUNTFLAG,	COMMERCIALFLAG_ALTKEY,	LIABILITY,	CD,	ACCOUNTSTATUS,	ACCOUNTBLKCODE1,	ACCOUNTBLKCODE2,	EXPOSURETYPE,	MTM_VALUE,	BANKASSETCLASS,	NPATYPE,	SECAPP,	BORROWERTYPEID,	LINECODE,	PROVPERSECURED,	PROVPERUNSECURED,	MOCREASON,	ADDLPROVISIONPER,	FLGINFRA,	REPOSSESSIONDATE,	DERECOGNISEDINTEREST1,	DERECOGNISEDINTEREST2,	PRODUCTCODE,	FLGLCBG,	UNSERVIEDINT,	PREQTRCREDIT,	PRVQTRINT,	CURQTRCREDIT,	CURQTRINT,	ORIGINALBRANCHCODE,	ADVANCERECOVERY,	NOTIONALINTTAMT,	PRVASSETCLASSALT_KEY,	MOCTYPE,	FLGSECURED,	REPOSSESSION,	RCPENDING,	PAYMENTPENDING,	WHEELCASE,	CUSTOMERLEVELMAXPER,	FINALPROVISIONPER,	ISIBPC,	ISSECURITISED,	RFA,	ISNONCOOPERATIVE,	SARFAESI,	WEAKACCOUNT,	PUI,	FLGFRAUD,	FLGRESTRUCTURE,	RESTRUCTUREDATE,	SARFAESIDATE,	FLGUNUSUALBOUNCE,	UNUSUALBOUNCEDATE,	FLGUNCLEAREDEFFECT,	UNCLEAREDEFFECTDATE,	FRAUDDATE,	WEAKACCOUNTDATE,	SCREENFLAG,	CHANGEFIELD,EntityKeyNew)
   	SELECT A.ENTITYKEY,	A.ACCOUNTENTITYID,	A.UCIFENTITYID,	A.CUSTOMERENTITYID,	A.CUSTOMERACID,	A.REFCUSTOMERID,	A.SOURCESYSTEMCUSTOMERID,	A.UCIF_ID,	A.BRANCHCODE,	A.FACILITYTYPE,	A.ACOPENDT,	A.FIRSTDTOFDISB,	A.PRODUCTALT_KEY,	A.SCHEMEALT_KEY,	A.SUBSECTORALT_KEY,	A.SPLCATG1ALT_KEY,	A.SPLCATG2ALT_KEY,	A.SPLCATG3ALT_KEY,	A.SPLCATG4ALT_KEY,	A.SOURCEALT_KEY,	A.ACTSEGMENTCODE,	A.INTTRATE,	A.BALANCE,	A.BALANCEINCRNCY,	A.CURRENCYALT_KEY,	A.DRAWINGPOWER,	A.CURRENTLIMIT,	A.CURRENTLIMITDT,	A.CONTIEXCESSDT,	A.STOCKSTDT,	A.DEBITSINCEDT,	A.LASTCRDATE,	A.INTTSERVICED,	A.INTNOTSERVICEDDT,	A.OVERDUEAMT,	A.OVERDUESINCEDT,	A.REVIEWDUEDT,	A.SECURITYVALUE,	A.DFVAMT,	A.GOVTGTYAMT,	A.COVERGOVGUR,	A.WRITEOFFAMOUNT,	A.UNADJSUBSIDY,	A.CREDITSINCEDT,	A.DEGREASON,	A.ASSET_NORM,	A.REFPERIODMAX,	A.REFPERIODOVERDUE,	A.REFPERIODOVERDRAWN,	A.REFPERIODNOCREDIT,	A.REFPERIODINTSERVICE,	A.REFPERIODSTKSTATEMENT,	A.REFPERIODREVIEW,	A.NETBALANCE,	A.APPRRV,	A.SECUREDAMT,	A.UNSECUREDAMT,	A.PROVDFV,	A.PROVSECURED,	A.PROVUNSECURED,	A.PROVCOVERGOVGUR,	A.ADDLPROVISION,	A.TOTALPROVISION,	A.BANKPROVSECURED,	A.BANKPROVUNSECURED,	A.BANKTOTALPROVISION,	A.RBIPROVSECURED,	A.RBIPROVUNSECURED,	A.RBITOTALPROVISION,	A.INITIALNPADT,	A.FINALNPADT,	A.SMA_DT,	A.UPGDATE,	A.INITIALASSETCLASSALT_KEY,	A.FINALASSETCLASSALT_KEY,	A.PROVISIONALT_KEY,	A.PNPA_REASON,	A.SMA_CLASS,	A.SMA_REASON,	A.FLGMOC,	A.MOC_DT,	A.COMMONMOCTYPEALT_KEY,	A.FLGDEG,	A.FLGDIRTYROW,	A.FLGINMONTH,	A.FLGSMA,	A.FLGPNPA,	A.FLGUPG,	A.FLGFITL,	A.FLGABINITIO,	A.NPA_DAYS,	A.REFPERIODOVERDUEUPG,	A.REFPERIODOVERDRAWNUPG,	A.REFPERIODNOCREDITUPG,	A.REFPERIODINTSERVICEUPG,	A.REFPERIODSTKSTATEMENTUPG,	A.REFPERIODREVIEWUPG,	A.EFFECTIVEFROMTIMEKEY,	A.EFFECTIVETOTIMEKEY,	A.APPGOVGUR,	A.USEDRV,	A.COMPUTEDCLAIM,	A.UPG_RELAX_MSME,	A.DEG_RELAX_MSME,	A.PNPA_DATE,	A.NPA_REASON,	A.PNPAASSETCLASSALT_KEY,	A.DISBAMOUNT,	A.PRINCOUTSTD,	A.PRINCOVERDUE,	A.PRINCOVERDUESINCEDT,	A.INTOVERDUE,	A.INTOVERDUESINCEDT,	A.OTHEROVERDUE,	A.OTHEROVERDUESINCEDT,	A.RELATIONSHIPNUMBER,	A.ACCOUNTFLAG,	A.COMMERCIALFLAG_ALTKEY,	A.LIABILITY,	A.CD,	A.ACCOUNTSTATUS,	A.ACCOUNTBLKCODE1,	A.ACCOUNTBLKCODE2,	A.EXPOSURETYPE,	A.MTM_VALUE,	A.BANKASSETCLASS,	A.NPATYPE,	A.SECAPP,	A.BORROWERTYPEID,	A.LINECODE,	A.PROVPERSECURED,	A.PROVPERUNSECURED,	A.MOCREASON,	A.ADDLPROVISIONPER,	A.FLGINFRA,	A.REPOSSESSIONDATE,	A.DERECOGNISEDINTEREST1,	A.DERECOGNISEDINTEREST2,	A.PRODUCTCODE,	A.FLGLCBG,	A.UNSERVIEDINT,	A.PREQTRCREDIT,	A.PRVQTRINT,	A.CURQTRCREDIT,	A.CURQTRINT,	A.ORIGINALBRANCHCODE,	A.ADVANCERECOVERY,	A.NOTIONALINTTAMT,	A.PRVASSETCLASSALT_KEY,	A.MOCTYPE,	A.FLGSECURED,	A.REPOSSESSION,	A.RCPENDING,	A.PAYMENTPENDING,	A.WHEELCASE,	A.CUSTOMERLEVELMAXPER,	A.FINALPROVISIONPER,	A.ISIBPC,	A.ISSECURITISED,	A.RFA,	A.ISNONCOOPERATIVE,	A.SARFAESI,	A.WEAKACCOUNT,	A.PUI,	A.FLGFRAUD,	A.FLGRESTRUCTURE,	A.RESTRUCTUREDATE,	A.SARFAESIDATE,	A.FLGUNUSUALBOUNCE,	A.UNUSUALBOUNCEDATE,	A.FLGUNCLEAREDEFFECT,	A.UNCLEAREDEFFECTDATE,	A.FRAUDDATE,	A.WEAKACCOUNTDATE,	A.SCREENFLAG,	A.CHANGEFIELD,
           UTILS.CONVERT_TO_NUMBER(0,19,0) EntityKeyNew  
   	  FROM MAIN_PRO.AccountCal_Hist A
             JOIN GTT_AccountCal B   ON A.AccountEntityID = B.AccountEntityID
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY ;
   /* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO MOC OT GRATER THAN MOC TIMKEY*/
   MERGE INTO MAIN_PRO.AccountCal_Hist A
   USING (SELECT A.ROWID row_id, CASE 
   WHEN a.EffectiveFromTimeKey < v_TIMEKEY THEN v_TIMEKEY - 1
   ELSE v_TIMEKEY
      END AS EffectiveToTimeKey
   FROM MAIN_PRO.AccountCal_Hist A
          JOIN GTT_AccountCal B   ON A.AccountEntityID = B.AccountEntityID
          AND A.EffectiveFromTimeKey <= v_TIMEKEY
          AND A.EffectiveToTimeKey >= v_TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
   /* UPADTE DAT AVAILABLE ON SAME TMEKEY */
   MERGE INTO MAIN_PRO.AccountCal_Hist O
   USING (SELECT O.ROWID row_id, T.UcifEntityID, T.CustomerEntityID, T.CustomerAcID, T.RefCustomerID, T.SourceSystemCustomerID, T.UCIF_ID, T.BranchCode, T.FacilityType, T.AcOpenDt, T.FirstDtOfDisb, T.ProductAlt_Key, T.SchemeAlt_key, T.SubSectorAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SourceAlt_Key, T.ActSegmentCode, T.InttRate, T.Balance, T.BalanceInCrncy, T.CurrencyAlt_Key, T.DrawingPower, T.CurrentLimit, T.CurrentLimitDt, T.ContiExcessDt, T.StockStDt, T.DebitSinceDt, T.LastCrDate, T.InttServiced, T.IntNotServicedDt, T.OverdueAmt, T.OverDueSinceDt, T.ReviewDueDt, T.SecurityValue, T.DFVAmt, T.GovtGtyAmt, T.CoverGovGur, T.WriteOffAmount, T.UnAdjSubSidy, T.CreditsinceDt, T.DegReason, T.Asset_Norm, T.REFPeriodMax, T.RefPeriodOverdue, T.RefPeriodOverDrawn, T.RefPeriodNoCredit, T.RefPeriodIntService, T.RefPeriodStkStatement, T.RefPeriodReview, T.NetBalance, T.ApprRV, T.SecuredAmt, T.UnSecuredAmt, T.ProvDFV, T.Provsecured, T.ProvUnsecured, T.ProvCoverGovGur, T.AddlProvision, T.TotalProvision, T.BankProvsecured, T.BankProvUnsecured, T.BankTotalProvision, T.RBIProvsecured, T.RBIProvUnsecured, T.RBITotalProvision, T.InitialNpaDt, T.FinalNpaDt, T.SMA_Dt, T.UpgDate, T.InitialAssetClassAlt_Key, T.FinalAssetClassAlt_Key, T.ProvisionAlt_Key, T.PNPA_Reason, T.SMA_Class, T.SMA_Reason, T.FlgMoc, T.MOC_Dt, T.CommonMocTypeAlt_Key, T.FlgDeg, T.FlgDirtyRow, T.FlgInMonth, T.FlgSMA, T.FlgPNPA, T.FlgUpg, T.FlgFITL, T.FlgAbinitio, T.NPA_Days, T.RefPeriodOverdueUPG, T.RefPeriodOverDrawnUPG, T.RefPeriodNoCreditUPG, T.RefPeriodIntServiceUPG, T.RefPeriodStkStatementUPG, T.RefPeriodReviewUPG, T.AppGovGur, T.UsedRV, T.ComputedClaim, T.UPG_RELAX_MSME, T.DEG_RELAX_MSME, T.PNPA_DATE, T.NPA_Reason, T.PnpaAssetClassAlt_key, T.DisbAmount, T.PrincOutStd, T.PrincOverdue, T.PrincOverdueSinceDt, T.IntOverdue, T.IntOverdueSinceDt, T.OtherOverdue, T.OtherOverdueSinceDt, T.RelationshipNumber, T.AccountFlag, T.CommercialFlag_AltKey, T.Liability, T.CD, T.AccountStatus, T.AccountBlkCode1, T.AccountBlkCode2, T.ExposureType, T.Mtm_Value, T.BankAssetClass, T.NpaType, T.SecApp, T.BorrowerTypeID, T.LineCode, T.ProvPerSecured, T.ProvPerUnSecured, T.MOCReason, T.AddlProvisionPer, T.FlgINFRA, T.RepossessionDate, T.DerecognisedInterest1, T.DerecognisedInterest2, T.ProductCode, T.FlgLCBG, T.unserviedint, T.PreQtrCredit, T.PrvQtrInt, T.CurQtrCredit, T.CurQtrInt, T.OriginalBranchcode, T.AdvanceRecovery, T.NotionalInttAmt, T.PrvAssetClassAlt_Key, T.MOCTYPE, T.FlgSecured, T.RePossession, T.RCPending, T.PaymentPending, T.WheelCase, T.CustomerLevelMaxPer, T.FinalProvisionPer, T.IsIBPC, T.IsSecuritised, T.RFA, T.IsNonCooperative, T.Sarfaesi, T.WeakAccount, T.PUI, T.FlgFraud, T.FlgRestructure, T.RestructureDate, T.SarfaesiDate, T.FlgUnusualBounce, T.UnusualBounceDate, T.FlgUnClearedEffect, T.UnClearedEffectDate, T.FraudDate, T.WeakAccountDate
   FROM MAIN_PRO.AccountCal_Hist O
          JOIN GTT_AccountCal T   ON O.AccountEntityID = T.AccountEntityID 
    WHERE O.EffectiveFromTimeKey = v_TimeKey
     AND O.EffectiveToTimeKey = v_TIMEKEY) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.UcifEntityID	=	src.UcifEntityID,
O.CustomerEntityID	=	src.CustomerEntityID,
O.CustomerAcID	=	src.CustomerAcID,
O.RefCustomerID	=	src.RefCustomerID,
O.SourceSystemCustomerID	=	src.SourceSystemCustomerID,
O.UCIF_ID	=	src.UCIF_ID,
O.BranchCode	=	src.BranchCode,
O.FacilityType	=	src.FacilityType,
O.AcOpenDt	=	src.AcOpenDt,
O.FirstDtOfDisb	=	src.FirstDtOfDisb,
O.ProductAlt_Key	=	src.ProductAlt_Key,
O.SchemeAlt_key	=	src.SchemeAlt_key,
O.SubSectorAlt_Key	=	src.SubSectorAlt_Key,
O.SplCatg1Alt_Key	=	src.SplCatg1Alt_Key,
O.SplCatg2Alt_Key	=	src.SplCatg2Alt_Key,
O.SplCatg3Alt_Key	=	src.SplCatg3Alt_Key,
O.SplCatg4Alt_Key	=	src.SplCatg4Alt_Key,
O.SourceAlt_Key	=	src.SourceAlt_Key,
O.ActSegmentCode	=	src.ActSegmentCode,
O.InttRate	=	src.InttRate,
O.Balance	=	src.Balance,
O.BalanceInCrncy	=	src.BalanceInCrncy,
O.CurrencyAlt_Key	=	src.CurrencyAlt_Key,
O.DrawingPower	=	src.DrawingPower,
O.CurrentLimit	=	src.CurrentLimit,
O.CurrentLimitDt	=	src.CurrentLimitDt,
O.ContiExcessDt	=	src.ContiExcessDt,
O.StockStDt	=	src.StockStDt,
O.DebitSinceDt	=	src.DebitSinceDt,
O.LastCrDate	=	src.LastCrDate,
O.InttServiced	=	src.InttServiced,
O.IntNotServicedDt	=	src.IntNotServicedDt,
O.OverdueAmt	=	src.OverdueAmt,
O.OverDueSinceDt	=	src.OverDueSinceDt,
O.ReviewDueDt	=	src.ReviewDueDt,
O.SecurityValue	=	src.SecurityValue,
O.DFVAmt	=	src.DFVAmt,
O.GovtGtyAmt	=	src.GovtGtyAmt,
O.CoverGovGur	=	src.CoverGovGur,
O.WriteOffAmount	=	src.WriteOffAmount,
O.UnAdjSubSidy	=	src.UnAdjSubSidy,
O.CreditsinceDt	=	src.CreditsinceDt,
O.DegReason	=	src.DegReason,
O.Asset_Norm	=	src.Asset_Norm,
O.REFPeriodMax	=	src.REFPeriodMax,
O.RefPeriodOverdue	=	src.RefPeriodOverdue,
O.RefPeriodOverDrawn	=	src.RefPeriodOverDrawn,
O.RefPeriodNoCredit	=	src.RefPeriodNoCredit,
O.RefPeriodIntService	=	src.RefPeriodIntService,
O.RefPeriodStkStatement	=	src.RefPeriodStkStatement,
O.RefPeriodReview	=	src.RefPeriodReview,
O.NetBalance	=	src.NetBalance,
O.ApprRV	=	src.ApprRV,
O.SecuredAmt	=	src.SecuredAmt,
O.UnSecuredAmt	=	src.UnSecuredAmt,
O.ProvDFV	=	src.ProvDFV,
O.Provsecured	=	src.Provsecured,
O.ProvUnsecured	=	src.ProvUnsecured,
O.ProvCoverGovGur	=	src.ProvCoverGovGur,
O.AddlProvision	=	src.AddlProvision,
O.TotalProvision	=	src.TotalProvision,
O.BankProvsecured	=	src.BankProvsecured,
O.BankProvUnsecured	=	src.BankProvUnsecured,
O.BankTotalProvision	=	src.BankTotalProvision,
O.RBIProvsecured	=	src.RBIProvsecured,
O.RBIProvUnsecured	=	src.RBIProvUnsecured,
O.RBITotalProvision	=	src.RBITotalProvision,
O.InitialNpaDt	=	src.InitialNpaDt,
O.FinalNpaDt	=	src.FinalNpaDt,
O.SMA_Dt	=	src.SMA_Dt,
O.UpgDate	=	src.UpgDate,
O.InitialAssetClassAlt_Key	=	src.InitialAssetClassAlt_Key,
O.FinalAssetClassAlt_Key	=	src.FinalAssetClassAlt_Key,
O.ProvisionAlt_Key	=	src.ProvisionAlt_Key,
O.PNPA_Reason	=	src.PNPA_Reason,
O.SMA_Class	=	src.SMA_Class,
O.SMA_Reason	=	src.SMA_Reason,
O.FlgMoc	=	src.FlgMoc,
O.MOC_Dt	=	src.MOC_Dt,
O.CommonMocTypeAlt_Key	=	src.CommonMocTypeAlt_Key,
O.FlgDeg	=	src.FlgDeg,
O.FlgDirtyRow	=	src.FlgDirtyRow,
O.FlgInMonth	=	src.FlgInMonth,
O.FlgSMA	=	src.FlgSMA,
O.FlgPNPA	=	src.FlgPNPA,
O.FlgUpg	=	src.FlgUpg,
O.FlgFITL	=	src.FlgFITL,
O.FlgAbinitio	=	src.FlgAbinitio,
O.NPA_Days	=	src.NPA_Days,
O.RefPeriodOverdueUPG	=	src.RefPeriodOverdueUPG,
O.RefPeriodOverDrawnUPG	=	src.RefPeriodOverDrawnUPG,
O.RefPeriodNoCreditUPG	=	src.RefPeriodNoCreditUPG,
O.RefPeriodIntServiceUPG	=	src.RefPeriodIntServiceUPG,
O.RefPeriodStkStatementUPG	=	src.RefPeriodStkStatementUPG,
O.RefPeriodReviewUPG	=	src.RefPeriodReviewUPG,
O.AppGovGur	=	src.AppGovGur,
O.UsedRV	=	src.UsedRV,
O.ComputedClaim	=	src.ComputedClaim,
O.UPG_RELAX_MSME	=	src.UPG_RELAX_MSME,
O.DEG_RELAX_MSME	=	src.DEG_RELAX_MSME,
O.PNPA_DATE	=	src.PNPA_DATE,
O.NPA_Reason	=	src.NPA_Reason,
O.PnpaAssetClassAlt_key	=	src.PnpaAssetClassAlt_key,
O.DisbAmount	=	src.DisbAmount,
O.PrincOutStd	=	src.PrincOutStd,
O.PrincOverdue	=	src.PrincOverdue,
O.PrincOverdueSinceDt	=	src.PrincOverdueSinceDt,
O.IntOverdue	=	src.IntOverdue,
O.IntOverdueSinceDt	=	src.IntOverdueSinceDt,
O.OtherOverdue	=	src.OtherOverdue,
O.OtherOverdueSinceDt	=	src.OtherOverdueSinceDt,
O.RelationshipNumber	=	src.RelationshipNumber,
O.AccountFlag	=	src.AccountFlag,
O.CommercialFlag_AltKey	=	src.CommercialFlag_AltKey,
O.Liability	=	src.Liability,
O.CD	=	src.CD,
O.AccountStatus	=	src.AccountStatus,
O.AccountBlkCode1	=	src.AccountBlkCode1,
O.AccountBlkCode2	=	src.AccountBlkCode2,
O.ExposureType	=	src.ExposureType,
O.Mtm_Value	=	src.Mtm_Value,
O.BankAssetClass	=	src.BankAssetClass,
O.NpaType	=	src.NpaType,
O.SecApp	=	src.SecApp,
O.BorrowerTypeID	=	src.BorrowerTypeID,
O.LineCode	=	src.LineCode,
O.ProvPerSecured	=	src.ProvPerSecured,
O.ProvPerUnSecured	=	src.ProvPerUnSecured,
O.MOCReason	=	src.MOCReason,
O.AddlProvisionPer	=	src.AddlProvisionPer,
O.FlgINFRA	=	src.FlgINFRA,
O.RepossessionDate	=	src.RepossessionDate,
O.DerecognisedInterest1	=	src.DerecognisedInterest1,
O.DerecognisedInterest2	=	src.DerecognisedInterest2,
O.ProductCode	=	src.ProductCode,
O.FlgLCBG	=	src.FlgLCBG,
O.unserviedint	=	src.unserviedint,
O.PreQtrCredit	=	src.PreQtrCredit,
O.PrvQtrInt	=	src.PrvQtrInt,
O.CurQtrCredit	=	src.CurQtrCredit,
O.CurQtrInt	=	src.CurQtrInt,
O.OriginalBranchcode	=	src.OriginalBranchcode,
O.AdvanceRecovery	=	src.AdvanceRecovery,
O.NotionalInttAmt	=	src.NotionalInttAmt,
O.PrvAssetClassAlt_Key	=	src.PrvAssetClassAlt_Key,
O.MOCTYPE	=	src.MOCTYPE,
O.FlgSecured	=	src.FlgSecured,
O.RePossession	=	src.RePossession,
O.RCPending	=	src.RCPending,
O.PaymentPending	=	src.PaymentPending,
O.WheelCase	=	src.WheelCase,
O.CustomerLevelMaxPer	=	src.CustomerLevelMaxPer,
O.FinalProvisionPer	=	src.FinalProvisionPer,
O.IsIBPC	=	src.IsIBPC,
O.IsSecuritised	=	src.IsSecuritised,
O.RFA	=	src.RFA,
O.IsNonCooperative	=	src.IsNonCooperative,
O.Sarfaesi	=	src.Sarfaesi,
O.WeakAccount	=	src.WeakAccount,
O.PUI	=	src.PUI,
O.FlgFraud	=	src.FlgFraud,
O.FlgRestructure	=	src.FlgRestructure,
O.RestructureDate	=	src.RestructureDate,
O.SarfaesiDate	=	src.SarfaesiDate,
O.FlgUnusualBounce	=	src.FlgUnusualBounce,
O.UnusualBounceDate	=	src.UnusualBounceDate,
O.FlgUnClearedEffect	=	src.FlgUnClearedEffect,
O.UnClearedEffectDate	=	src.UnClearedEffectDate,
O.FraudDate	=	src.FraudDate,
O.WeakAccountDate	=	src.WeakAccountDate;
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyAcct
     FROM MAIN_PRO.AccountCal_Hist ;
   IF v_EntityKeyAcct IS NULL THEN

   BEGIN
      v_EntityKeyAcct := 0 ;

   END;
   END IF;
   MERGE INTO GTT_AccountCal TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_AccountCal TEMP
          JOIN ( SELECT GTT_AccountCal.AccountEntityID ,
                        (v_EntityKeyAcct + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                            FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_AccountCal ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.AccountEntityID = ACCT.AccountEntityID ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   MERGE INTO GTT_AccountCal T
   USING (SELECT T.ROWID row_id, 'Y'
   FROM GTT_AccountCal T
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

       --select SUM(BALANCE)/10000000,  count(1)
       FROM GTT_AccountCal T
        WHERE  T.ISCHANGED = 'Y' );
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyAcct1
     FROM MAIN_PRO.AccountCal_Hist ;
   IF v_EntityKeyAcct1 IS NULL THEN

   BEGIN
      v_EntityKeyAcct1 := 0 ;

   END;
   END IF;
   MERGE INTO GTT_AccountCal_Moc TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_AccountCal_Moc TEMP
          JOIN ( SELECT GTT_AccountCal_Moc.AccountEntityID ,
                        (v_EntityKeyAcct1 + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                             FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_AccountCal_Moc ---Where IsChanged in ('C','N')
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
       FROM GTT_AccountCal_Moc T
        WHERE  EffectiveToTimeKey > v_TIMEKEY );
   -----------------------------------------------------------
   /* AMAR - 29033023 -- RESTRUCTURE WORK FOR moc PROCESSING */
   DELETE FROM gtt_AdvAcRestructureCal_Moc;
   UTILS.IDENTITY_RESET('GTT_AdvAcRestructureCal_Moc');

   INSERT INTO GTT_AdvAcRestructureCal_Moc ( ENTITYKEY,	ACCOUNTENTITYID,	ASSETCLASSALT_KEYONINVOCATION,	PRERESTRUCTUREASSETCLASSALT_KEY,	PRERESTRUCTURENPA_DATE,	PROVPERONRESTRUCURE,	RESTRUCTURETYPEALT_KEY,	COVID_OTR_CATGALT_KEY,	RESTRUCTUREDT,	SP_EXPIRYDATE,	DPD_ASONRESTRUCTURE,	RESTRUCTUREFAILUREDATE,	DPD_BREACH_DATE,	ZERODPD_DATE,	SP_EXPIRYEXTENDEDDATE,	CURRENTPOS,	CURRENTTOS,	RESTRUCTUREPOS,	RES_POS_TO_CURRENTPOS_PER,	CURRENTDPD,	TOTALDPD,	VDPD,	ADDLPROVPER,	PROVRELEASEPER,	APPLIEDNORMALPROVPER,	FINALPROVPER,	PREDEGPROVPER,	UPGRADEDATE,	SURVPERIODENDDATE,	DEGDURSP_PERIODPROVPER,	NONFINDPD,	INITIALASSETCLASSALT_KEY,	FINALASSETCLASSALT_KEY,	RESTRUCTUREPROVISION,	SECUREDPROVISION,	UNSECUREDPROVISION,	FLGDEG,	FLGUPG,	DEGDATE,	RC_PENDING,	FINALNPADT,	RESTRUCTURESTAGE,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	D2KTIMESTAMP,	DEGREASON,	INVESTMENTGRADE,	POS_10PERPAIDDATE,	DPD_MAXNONFIN,	DPD_MAXFIN,	FLGMORAT,	PRERESTRUCTURENPA_PROV,	RESTRUCTUREFACILITYTYPEALT_KEY,EntityKeyNew )
   	SELECT A.ENTITYKEY,	A.ACCOUNTENTITYID,	A.ASSETCLASSALT_KEYONINVOCATION,	A.PRERESTRUCTUREASSETCLASSALT_KEY,	A.PRERESTRUCTURENPA_DATE,	A.PROVPERONRESTRUCURE,	A.RESTRUCTURETYPEALT_KEY,	A.COVID_OTR_CATGALT_KEY,	A.RESTRUCTUREDT,	A.SP_EXPIRYDATE,	A.DPD_ASONRESTRUCTURE,	A.RESTRUCTUREFAILUREDATE,	A.DPD_BREACH_DATE,	A.ZERODPD_DATE,	A.SP_EXPIRYEXTENDEDDATE,	A.CURRENTPOS,	A.CURRENTTOS,	A.RESTRUCTUREPOS,	A.RES_POS_TO_CURRENTPOS_PER,	A.CURRENTDPD,	A.TOTALDPD,	A.VDPD,	A.ADDLPROVPER,	A.PROVRELEASEPER,	A.APPLIEDNORMALPROVPER,	A.FINALPROVPER,	A.PREDEGPROVPER,	A.UPGRADEDATE,	A.SURVPERIODENDDATE,	A.DEGDURSP_PERIODPROVPER,	A.NONFINDPD,	A.INITIALASSETCLASSALT_KEY,	A.FINALASSETCLASSALT_KEY,	A.RESTRUCTUREPROVISION,	A.SECUREDPROVISION,	A.UNSECUREDPROVISION,	A.FLGDEG,	A.FLGUPG,	A.DEGDATE,	A.RC_PENDING,	A.FINALNPADT,	A.RESTRUCTURESTAGE,	A.EFFECTIVEFROMTIMEKEY,	A.EFFECTIVETOTIMEKEY,	A.D2KTIMESTAMP,	A.DEGREASON,	A.INVESTMENTGRADE,	A.POS_10PERPAIDDATE,	A.DPD_MAXNONFIN,	A.DPD_MAXFIN,	A.FLGMORAT,	A.PRERESTRUCTURENPA_PROV,	A.RESTRUCTUREFACILITYTYPEALT_KEY,
           UTILS.CONVERT_TO_NUMBER(0,19,0) EntityKeyNew  
   	  FROM MAIN_PRO.AdvAcRestructureCal_Hist A
             JOIN MAIN_PRO.AdvAcRestructureCal B   ON A.AccountEntityId = B.AccountEntityId
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY ;
   /* EXPIRE RECORDS ARE LIVE FROM PREV EFFECTIVEFROTIMEKEY TO MOC OT GRATER THAN MOC TIMKEY*/
   MERGE INTO MAIN_PRO.AdvAcRestructureCal_Hist A
   USING (SELECT A.ROWID row_id, CASE 
   WHEN a.EffectiveFromTimeKey < v_TIMEKEY THEN v_TIMEKEY - 1
   ELSE v_TIMEKEY
      END AS EffectiveToTimeKey
   FROM MAIN_PRO.AdvAcRestructureCal_Hist A
          JOIN MAIN_PRO.AdvAcRestructureCal B   ON A.AccountEntityId = B.AccountEntityId
          AND A.EffectiveFromTimeKey <= v_TIMEKEY
          AND A.EffectiveToTimeKey >= v_TIMEKEY ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = src.EffectiveToTimeKey;
   /* UPADTE DATA AVAILABLE ON SAME TMEKEY */
   MERGE INTO MAIN_PRO.AdvAcRestructureCal_Hist O
   USING (SELECT O.ROWID row_id, T.AssetClassAlt_KeyOnInvocation, T.PreRestructureAssetClassAlt_Key, T.PreRestructureNPA_Date, T.ProvPerOnRestrucure, T.RestructureTypeAlt_Key, T.COVID_OTR_CatgAlt_Key, T.RestructureDt, T.SP_ExpiryDate, T.DPD_AsOnRestructure, T.RestructureFailureDate, T.DPD_Breach_Date, T.ZeroDPD_Date, T.SP_ExpiryExtendedDate, T.CurrentPOS, T.CurrentTOS, T.RestructurePOS, T.Res_POS_to_CurrentPOS_Per, T.CurrentDPD, T.TotalDPD, T.VDPD, T.AddlProvPer, T.ProvReleasePer, T.AppliedNormalProvPer, T.FinalProvPer, T.PreDegProvPer, T.UpgradeDate, T.SurvPeriodEndDate, T.DegDurSP_PeriodProvPer, T.NonFinDPD, T.InitialAssetClassAlt_Key, T.FinalAssetClassAlt_Key, T.RestructureProvision, T.SecuredProvision, T.UnSecuredProvision, T.FlgDeg, T.FlgUpg, T.DegDate, T.RC_Pending, T.FinalNpaDt, T.RestructureStage, T.DegReason, T.InvestmentGrade, T.POS_10PerPaidDate, T.DPD_MaxNonFin, T.DPD_MaxFin, T.FlgMorat, T.PreRestructureNPA_Prov, T.RestructureFacilityTypeAlt_Key
   FROM MAIN_PRO.AdvAcRestructureCal_Hist O
          JOIN MAIN_PRO.AdvAcRestructureCal T   ON O.AccountEntityId = T.AccountEntityId 
    WHERE O.EffectiveFromTimeKey = v_TimeKey
     AND O.EffectiveToTimeKey = v_TIMEKEY) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.AssetClassAlt_KeyOnInvocation = src.AssetClassAlt_KeyOnInvocation,
                                O.PreRestructureAssetClassAlt_Key = src.PreRestructureAssetClassAlt_Key,
                                O.PreRestructureNPA_Date = src.PreRestructureNPA_Date,
                                O.ProvPerOnRestrucure = src.ProvPerOnRestrucure,
                                O.RestructureTypeAlt_Key = src.RestructureTypeAlt_Key,
                                O.COVID_OTR_CatgAlt_Key = src.COVID_OTR_CatgAlt_Key,
                                O.RestructureDt = src.RestructureDt,
                                O.SP_ExpiryDate = src.SP_ExpiryDate,
                                O.DPD_AsOnRestructure = src.DPD_AsOnRestructure,
                                O.RestructureFailureDate = src.RestructureFailureDate,
                                O.DPD_Breach_Date = src.DPD_Breach_Date,
                                O.ZeroDPD_Date = src.ZeroDPD_Date,
                                O.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate,
                                O.CurrentPOS = src.CurrentPOS,
                                O.CurrentTOS = src.CurrentTOS,
                                O.RestructurePOS = src.RestructurePOS,
                                O.Res_POS_to_CurrentPOS_Per = src.Res_POS_to_CurrentPOS_Per,
                                O.CurrentDPD = src.CurrentDPD,
                                O.TotalDPD = src.TotalDPD,
                                O.VDPD = src.VDPD,
                                O.AddlProvPer = src.AddlProvPer,
                                O.ProvReleasePer = src.ProvReleasePer,
                                O.AppliedNormalProvPer = src.AppliedNormalProvPer,
                                O.FinalProvPer = src.FinalProvPer,
                                O.PreDegProvPer = src.PreDegProvPer,
                                O.UpgradeDate = src.UpgradeDate,
                                O.SurvPeriodEndDate = src.SurvPeriodEndDate,
                                O.DegDurSP_PeriodProvPer = src.DegDurSP_PeriodProvPer,
                                O.NonFinDPD = src.NonFinDPD,
                                O.InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                O.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                O.RestructureProvision = src.RestructureProvision,
                                O.SecuredProvision = src.SecuredProvision,
                                O.UnSecuredProvision = src.UnSecuredProvision,
                                O.FlgDeg = src.FlgDeg,
                                O.FlgUpg = src.FlgUpg,
                                O.DegDate = src.DegDate,
                                O.RC_Pending = src.RC_Pending,
                                O.FinalNpaDt = src.FinalNpaDt,
                                O.RestructureStage = src.RestructureStage,
                                O.DegReason = src.DegReason,
                                O.InvestmentGrade = src.InvestmentGrade,
                                O.POS_10PerPaidDate = src.POS_10PerPaidDate,
                                O.DPD_MaxNonFin = src.DPD_MaxNonFin,
                                O.DPD_MaxFin = src.DPD_MaxFin,
                                O.FlgMorat = src.FlgMorat,
                                O.PreRestructureNPA_Prov = src.PreRestructureNPA_Prov,
                                O.RestructureFacilityTypeAlt_Key = src.RestructureFacilityTypeAlt_Key;
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyRestr
     FROM MAIN_PRO.AdvAcRestructureCal_Hist ;
   IF v_EntityKeyRestr IS NULL THEN

   BEGIN
      v_EntityKeyRestr := 0 ;

   END;
   END IF;
   MERGE INTO MAIN_PRO.AdvAcRestructureCal TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM MAIN_PRO.AdvAcRestructureCal TEMP
          JOIN ( SELECT AdvAcRestructureCal.AccountEntityId ,
                        (v_EntityKeyRestr + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                             FROM DUAL  )  )) EntityKeyNew  
                 FROM MAIN_PRO.AdvAcRestructureCal ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   MERGE INTO MAIN_PRO.AdvAcRestructureCal T
   USING (SELECT T.ROWID row_id, 'Y'
   FROM MAIN_PRO.AdvAcRestructureCal T
          LEFT JOIN MAIN_PRO.AdvAcRestructureCal_Hist B   ON B.EffectiveFromTimeKey = v_TIMEKEY
          AND B.EffectiveToTimeKey = v_TIMEKEY
          AND B.AccountEntityId = T.AccountEntityId 
    WHERE B.AccountEntityId IS NULL) src
   ON ( T.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET t.IsChanged = 'Y';
   /***************************************************************************************************************/
   INSERT INTO MAIN_PRO.AdvAcRestructureCal_Hist
     ( AccountEntityId, AssetClassAlt_KeyOnInvocation, PreRestructureAssetClassAlt_Key, PreRestructureNPA_Date, ProvPerOnRestrucure, RestructureTypeAlt_Key, COVID_OTR_CatgAlt_Key, RestructureDt, SP_ExpiryDate, DPD_AsOnRestructure, RestructureFailureDate, DPD_Breach_Date, ZeroDPD_Date, SP_ExpiryExtendedDate, CurrentPOS, CurrentTOS, RestructurePOS, Res_POS_to_CurrentPOS_Per, CurrentDPD, TotalDPD, VDPD, AddlProvPer, ProvReleasePer, AppliedNormalProvPer, FinalProvPer, PreDegProvPer, UpgradeDate, SurvPeriodEndDate, DegDurSP_PeriodProvPer, NonFinDPD, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, RestructureProvision, SecuredProvision, UnSecuredProvision, FlgDeg, FlgUpg, DegDate, RC_Pending, FinalNpaDt, RestructureStage, EffectiveFromTimeKey, EffectiveToTimeKey, DegReason, InvestmentGrade, POS_10PerPaidDate, DPD_MaxNonFin, DPD_MaxFin, FlgMorat, PreRestructureNPA_Prov, RestructureFacilityTypeAlt_Key )
     ( SELECT T.AccountEntityId ,
              T.AssetClassAlt_KeyOnInvocation ,
              T.PreRestructureAssetClassAlt_Key ,
              T.PreRestructureNPA_Date ,
              T.ProvPerOnRestrucure ,
              T.RestructureTypeAlt_Key ,
              T.COVID_OTR_CatgAlt_Key ,
              T.RestructureDt ,
              T.SP_ExpiryDate ,
              T.DPD_AsOnRestructure ,
              T.RestructureFailureDate ,
              T.DPD_Breach_Date ,
              T.ZeroDPD_Date ,
              T.SP_ExpiryExtendedDate ,
              T.CurrentPOS ,
              T.CurrentTOS ,
              T.RestructurePOS ,
              T.Res_POS_to_CurrentPOS_Per ,
              T.CurrentDPD ,
              T.TotalDPD ,
              T.VDPD ,
              T.AddlProvPer ,
              T.ProvReleasePer ,
              T.AppliedNormalProvPer ,
              T.FinalProvPer ,
              T.PreDegProvPer ,
              T.UpgradeDate ,
              T.SurvPeriodEndDate ,
              T.DegDurSP_PeriodProvPer ,
              T.NonFinDPD ,
              T.InitialAssetClassAlt_Key ,
              T.FinalAssetClassAlt_Key ,
              T.RestructureProvision ,
              T.SecuredProvision ,
              T.UnSecuredProvision ,
              T.FlgDeg ,
              T.FlgUpg ,
              T.DegDate ,
              T.RC_Pending ,
              T.FinalNpaDt ,
              T.RestructureStage ,
              v_TIMEKEY EffectiveFromTimeKey  ,
              v_TIMEKEY EffectiveToTimeKey  ,
              T.DegReason ,
              T.InvestmentGrade ,
              T.POS_10PerPaidDate ,
              T.DPD_MaxNonFin ,
              T.DPD_MaxFin ,
              T.FlgMorat ,
              T.PreRestructureNPA_Prov ,
              T.RestructureFacilityTypeAlt_Key 
       FROM MAIN_PRO.AdvAcRestructureCal T
        WHERE  t.IsChanged = 'Y' );
   SELECT MAX(EntityKey)  

     INTO v_EntityKeyRestr1
     FROM MAIN_PRO.AdvAcRestructureCal_Hist ;
   IF v_EntityKeyRestr1 IS NULL THEN

   BEGIN
      v_EntityKeyRestr1 := 0 ;

   END;
   END IF;
   MERGE INTO GTT_AdvAcRestructureCal_Moc TEMP
   USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
   FROM GTT_AdvAcRestructureCal_Moc TEMP
          JOIN ( SELECT GTT_AdvAcRestructureCal_Moc.AccountEntityId ,
                        (v_EntityKeyRestr1 + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                              FROM DUAL  )  )) EntityKeyNew  
                 FROM GTT_AdvAcRestructureCal_Moc ---Where IsChanged in ('C','N')
                        ) ACCT   ON TEMP.AccountEntityId = ACCT.AccountEntityId ) src
   ON ( TEMP.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
   --WHERE Temp.IsChanged in ('C','N')
   INSERT INTO MAIN_PRO.AdvAcRestructureCal_Hist
     ( AccountEntityId, AssetClassAlt_KeyOnInvocation, PreRestructureAssetClassAlt_Key, PreRestructureNPA_Date, ProvPerOnRestrucure, RestructureTypeAlt_Key, COVID_OTR_CatgAlt_Key, RestructureDt, SP_ExpiryDate, DPD_AsOnRestructure, RestructureFailureDate, DPD_Breach_Date, ZeroDPD_Date, SP_ExpiryExtendedDate, CurrentPOS, CurrentTOS, RestructurePOS, Res_POS_to_CurrentPOS_Per, CurrentDPD, TotalDPD, VDPD, AddlProvPer, ProvReleasePer, AppliedNormalProvPer, FinalProvPer, PreDegProvPer, UpgradeDate, SurvPeriodEndDate, DegDurSP_PeriodProvPer, NonFinDPD, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, RestructureProvision, SecuredProvision, UnSecuredProvision, FlgDeg, FlgUpg, DegDate, RC_Pending, FinalNpaDt, RestructureStage, EffectiveFromTimeKey, EffectiveToTimeKey, DegReason, InvestmentGrade, POS_10PerPaidDate, DPD_MaxNonFin, DPD_MaxFin, FlgMorat, PreRestructureNPA_Prov, RestructureFacilityTypeAlt_Key )
     ( SELECT T.AccountEntityId ,
              T.AssetClassAlt_KeyOnInvocation ,
              T.PreRestructureAssetClassAlt_Key ,
              T.PreRestructureNPA_Date ,
              T.ProvPerOnRestrucure ,
              T.RestructureTypeAlt_Key ,
              T.COVID_OTR_CatgAlt_Key ,
              T.RestructureDt ,
              T.SP_ExpiryDate ,
              T.DPD_AsOnRestructure ,
              T.RestructureFailureDate ,
              T.DPD_Breach_Date ,
              T.ZeroDPD_Date ,
              T.SP_ExpiryExtendedDate ,
              T.CurrentPOS ,
              T.CurrentTOS ,
              T.RestructurePOS ,
              T.Res_POS_to_CurrentPOS_Per ,
              T.CurrentDPD ,
              T.TotalDPD ,
              T.VDPD ,
              T.AddlProvPer ,
              T.ProvReleasePer ,
              T.AppliedNormalProvPer ,
              T.FinalProvPer ,
              T.PreDegProvPer ,
              T.UpgradeDate ,
              T.SurvPeriodEndDate ,
              T.DegDurSP_PeriodProvPer ,
              T.NonFinDPD ,
              T.InitialAssetClassAlt_Key ,
              T.FinalAssetClassAlt_Key ,
              T.RestructureProvision ,
              T.SecuredProvision ,
              T.UnSecuredProvision ,
              T.FlgDeg ,
              T.FlgUpg ,
              T.DegDate ,
              T.RC_Pending ,
              T.FinalNpaDt ,
              T.RestructureStage ,
              v_TIMEKEY + 1 EffectiveFromTimeKey  ,
              EffectiveToTimeKey ,
              T.DegReason ,
              T.InvestmentGrade ,
              T.POS_10PerPaidDate ,
              T.DPD_MaxNonFin ,
              T.DPD_MaxFin ,
              T.FlgMorat ,
              T.PreRestructureNPA_Prov ,
              T.RestructureFacilityTypeAlt_Key 
       FROM GTT_AdvAcRestructureCal_Moc T
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

  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAINTOHIST_TABLE_OPT_MOC" TO "ADF_CDR_RBL_STGDB";
