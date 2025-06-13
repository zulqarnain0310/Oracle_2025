--------------------------------------------------------
--  DDL for Procedure CUSTACCTCALHISTMERGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."CUSTACCTCALHISTMERGE" 
-- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================
 /*   ADD NEW OLUMN
	ALTER TABLE PRO.PUI_CAL ADD IsChanged CHAR(1)
	ALTER TABLE PRO.ADVACRESTRUCTURECAL ADD IsChanged CHAR(1)
	ALTER TABLE PRO.ACCOUNTCAL ADD IsChanged CHAR(1)
	ALTER TABLE PRO.CUSTOMERCAL ADD IsChanged CHAR(1)
*/
AS
   -- SET NOCOUNT ON added to prevent extra result sets from
   -- interfering with SELECT statements.
   v_VEFFECTIVETO NUMBER(10,0);
   v_TimeKey NUMBER(10,0);
-- Add the parameters for the stored procedure here

BEGIN

   SELECT TIMEKEY - 1 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   SELECT TIMEKEY 

     INTO v_VEFFECTIVETO
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   /*  CUSTOMER DATA MERGE */
   IF 1 = 1 THEN
    DECLARE
      ---------------------------------------------------------------------------------------------------------------
      -------------------------------
      /*  New Customers Ac Key ID Update  */
      v_EntityKey NUMBER(19,0) := 0;

   BEGIN
      MERGE INTO MAIN_PRO.CUSTOMERCAL A
      USING (SELECT A.ROWID row_id, 'N'
      FROM MAIN_PRO.CUSTOMERCAL A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
      MERGE INTO MAIN_PRO.CUSTOMERCAL T
      USING (SELECT T.ROWID row_id, 'C'
      FROM MAIN_PRO.CustomerCal_Hist O
             JOIN MAIN_PRO.CUSTOMERCAL T   ON O.CustomerEntityId = T.CustomerEntityID
             AND O.EffectiveToTimeKey = 49999 
       WHERE ( NVL(O.BranchCode, ' ') <> NVL(T.BranchCode, ' ')
        OR NVL(O.UCIF_ID, ' ') <> NVL(T.UCIF_ID, ' ')
        OR NVL(O.UcifEntityID, 0) <> NVL(T.UcifEntityID, 0)
        OR NVL(O.CustomerEntityID, 0) <> NVL(T.CustomerEntityID, 0)
        OR NVL(O.ParentCustomerID, ' ') <> NVL(T.ParentCustomerID, ' ')
        OR NVL(O.RefCustomerID, ' ') <> NVL(T.RefCustomerID, ' ')
        OR NVL(O.SourceSystemCustomerID, ' ') <> NVL(T.SourceSystemCustomerID, ' ')
        OR NVL(O.CustomerName, ' ') <> NVL(T.CustomerName, ' ')
        OR NVL(O.CustSegmentCode, ' ') <> NVL(T.CustSegmentCode, ' ')
        OR NVL(O.ConstitutionAlt_Key, 0) <> NVL(T.ConstitutionAlt_Key, 0)
        OR NVL(O.PANNO, ' ') <> NVL(T.PANNO, ' ')
        OR NVL(O.AadharCardNO, ' ') <> NVL(T.AadharCardNO, ' ')
        OR NVL(O.SrcAssetClassAlt_Key, 0) <> NVL(T.SrcAssetClassAlt_Key, 0)
        OR NVL(O.SysAssetClassAlt_Key, 0) <> NVL(T.SysAssetClassAlt_Key, 0)
        OR NVL(O.SplCatg1Alt_Key, 0) <> NVL(T.SplCatg1Alt_Key, 0)
        OR NVL(O.SplCatg2Alt_Key, 0) <> NVL(T.SplCatg2Alt_Key, 0)
        OR NVL(O.SplCatg3Alt_Key, 0) <> NVL(T.SplCatg3Alt_Key, 0)
        OR NVL(O.SplCatg4Alt_Key, 0) <> NVL(T.SplCatg4Alt_Key, 0)
        OR NVL(O.SMA_Class_Key, 0) <> NVL(T.SMA_Class_Key, 0)
        OR NVL(O.PNPA_Class_Key, 0) <> NVL(T.PNPA_Class_Key, 0)
        OR NVL(O.PrvQtrRV, 0) <> NVL(T.PrvQtrRV, 0)
        OR NVL(O.CurntQtrRv, 0) <> NVL(T.CurntQtrRv, 0)
        OR NVL(O.TotProvision, 0) <> NVL(T.TotProvision, 0)
        OR NVL(O.BankTotProvision, 0) <> NVL(T.BankTotProvision, 0)
        OR NVL(O.RBITotProvision, 0) <> NVL(T.RBITotProvision, 0)
        OR NVL(O.SrcNPA_Dt, '1900-01-01') <> NVL(T.SrcNPA_Dt, '1900-01-01')
        OR NVL(O.SysNPA_Dt, '1900-01-01') <> NVL(T.SysNPA_Dt, '1900-01-01')
        OR NVL(O.DbtDt, '1900-01-01') <> NVL(T.DbtDt, '1900-01-01')
        OR NVL(O.DbtDt2, '1900-01-01') <> NVL(T.DbtDt2, '1900-01-01')
        OR NVL(O.DbtDt3, '1900-01-01') <> NVL(T.DbtDt3, '1900-01-01')
        OR NVL(O.LossDt, '1900-01-01') <> NVL(T.LossDt, '1900-01-01')
        OR NVL(O.MOC_Dt, '1900-01-01') <> NVL(T.MOC_Dt, '1900-01-01')
        OR NVL(O.ErosionDt, '1900-01-01') <> NVL(T.ErosionDt, '1900-01-01')
        OR NVL(O.SMA_Dt, '1900-01-01') <> NVL(T.SMA_Dt, '1900-01-01')
        OR NVL(O.PNPA_Dt, '1900-01-01') <> NVL(T.PNPA_Dt, '1900-01-01')
        OR NVL(O.Asset_Norm, ' ') <> NVL(T.Asset_Norm, ' ')
        OR NVL(O.FlgDeg, ' ') <> NVL(T.FlgDeg, ' ')
        OR NVL(O.FlgUpg, ' ') <> NVL(T.FlgUpg, ' ')
        OR NVL(O.FlgMoc, ' ') <> NVL(T.FlgMoc, ' ')
        OR NVL(O.FlgSMA, ' ') <> NVL(T.FlgSMA, ' ')
        OR NVL(O.FlgProcessing, ' ') <> NVL(T.FlgProcessing, ' ')
        OR NVL(O.FlgErosion, ' ') <> NVL(T.FlgErosion, ' ')
        OR NVL(O.FlgPNPA, ' ') <> NVL(T.FlgPNPA, ' ')
        OR NVL(O.FlgPercolation, ' ') <> NVL(T.FlgPercolation, ' ')
        OR NVL(O.FlgInMonth, ' ') <> NVL(T.FlgInMonth, ' ')
        OR NVL(O.FlgDirtyRow, ' ') <> NVL(T.FlgDirtyRow, ' ')
        OR NVL(O.DegDate, '1900-01-01') <> NVL(T.DegDate, '1900-01-01')
        OR NVL(O.CommonMocTypeAlt_Key, 0) <> NVL(T.CommonMocTypeAlt_Key, 0)
        OR NVL(O.InMonthMark, ' ') <> NVL(T.InMonthMark, ' ')
        OR NVL(O.MocStatusMark, ' ') <> NVL(T.MocStatusMark, ' ')
        OR NVL(O.SourceAlt_Key, 0) <> NVL(T.SourceAlt_Key, 0)
        OR NVL(O.BankAssetClass, ' ') <> NVL(T.BankAssetClass, ' ')
        OR NVL(O.Cust_Expo, 0) <> NVL(T.Cust_Expo, 0)
        OR NVL(O.MOCReason, ' ') <> NVL(T.MOCReason, ' ')
        OR NVL(O.AddlProvisionPer, 0) <> NVL(T.AddlProvisionPer, 0)
        OR NVL(O.FraudDt, '1900-01-01') <> NVL(T.FraudDt, '1900-01-01')
        OR NVL(O.FraudAmount, 0) <> NVL(T.FraudAmount, 0)
        OR NVL(O.DegReason, ' ') <> NVL(T.DegReason, ' ')
        OR NVL(O.CustMoveDescription, ' ') <> NVL(T.CustMoveDescription, ' ')
        OR NVL(O.TotOsCust, 0) <> NVL(T.TotOsCust, 0)
        OR NVL(O.MOCTYPE, ' ') <> NVL(T.MOCTYPE, ' ') )) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IsChanged = 'C';
      MERGE INTO MAIN_PRO.CUSTOMERCAL A
      USING (SELECT A.ROWID row_id, 'U'
      FROM MAIN_PRO.CUSTOMERCAL A
             JOIN MAIN_PRO.CustomerCal_Hist B   ON B.CustomerEntityID = A.CustomerEntityID 
       WHERE B.EffectiveFromTimeKey = v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'U';
      ----------For Changes Records
      MERGE INTO MAIN_PRO.CUSTOMERCAL A
      USING (SELECT A.ROWID row_id, v_VEFFECTIVETO
      FROM MAIN_PRO.CUSTOMERCAL A
             JOIN MAIN_PRO.CustomerCal_Hist B   ON B.CustomerEntityID = A.CustomerEntityID 
       WHERE B.EffectiveFromTimeKey < v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = v_VEFFECTIVETO;
      MERGE INTO MAIN_PRO.CustomerCal_Hist O
      USING (SELECT O.ROWID row_id, T.BranchCode, T.UCIF_ID, T.UcifEntityID, T.ParentCustomerID, T.RefCustomerID, T.SourceSystemCustomerID, T.CustomerName, T.CustSegmentCode, T.ConstitutionAlt_Key, T.PANNO, T.AadharCardNO, T.SrcAssetClassAlt_Key, T.SysAssetClassAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SMA_Class_Key, T.PNPA_Class_Key, T.PrvQtrRV, T.CurntQtrRv, T.TotProvision, T.BankTotProvision, T.RBITotProvision, T.SrcNPA_Dt, T.SysNPA_Dt, T.DbtDt, T.DbtDt2, T.DbtDt3, T.LossDt, T.MOC_Dt, T.ErosionDt, T.SMA_Dt, T.PNPA_Dt, T.Asset_Norm, T.FlgDeg, T.FlgUpg, T.FlgMoc, T.FlgSMA, T.FlgProcessing, T.FlgErosion, T.FlgPNPA, T.FlgPercolation, T.FlgInMonth, T.FlgDirtyRow, T.DegDate, T.CommonMocTypeAlt_Key, T.InMonthMark, T.MocStatusMark, T.SourceAlt_Key, T.BankAssetClass, T.Cust_Expo, T.MOCReason, T.AddlProvisionPer, T.FraudDt, T.FraudAmount, T.DegReason, T.CustMoveDescription, T.TotOsCust, T.MOCTYPE
      FROM MAIN_PRO.CustomerCal_Hist O
             JOIN MAIN_PRO.CUSTOMERCAL T   ON O.CustomerEntityID = T.CustomerEntityID 
       WHERE O.EffectiveFromTimeKey = v_TimeKey
        AND T.IsChanged = 'U') src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET O.BranchCode = src.BranchCode,
                                   O.UCIF_ID = src.UCIF_ID,
                                   O.UcifEntityID = src.UcifEntityID,
                                   O.ParentCustomerID = src.ParentCustomerID,
                                   O.RefCustomerID = src.RefCustomerID,
                                   O.SourceSystemCustomerID = src.SourceSystemCustomerID,
                                   O.CustomerName = src.CustomerName,
                                   O.CustSegmentCode = src.CustSegmentCode,
                                   O.ConstitutionAlt_Key = src.ConstitutionAlt_Key,
                                   O.PANNO = src.PANNO,
                                   O.AadharCardNO = src.AadharCardNO,
                                   O.SrcAssetClassAlt_Key = src.SrcAssetClassAlt_Key,
                                   O.SysAssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                   O.SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                   O.SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                   O.SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                   O.SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                   O.SMA_Class_Key = src.SMA_Class_Key,
                                   O.PNPA_Class_Key = src.PNPA_Class_Key,
                                   O.PrvQtrRV = src.PrvQtrRV,
                                   O.CurntQtrRv = src.CurntQtrRv,
                                   O.TotProvision = src.TotProvision,
                                   O.BankTotProvision = src.BankTotProvision,
                                   O.RBITotProvision = src.RBITotProvision,
                                   O.SrcNPA_Dt = src.SrcNPA_Dt,
                                   O.SysNPA_Dt = src.SysNPA_Dt,
                                   O.DbtDt = src.DbtDt,
                                   O.DbtDt2 = src.DbtDt2,
                                   O.DbtDt3 = src.DbtDt3,
                                   O.LossDt = src.LossDt,
                                   O.MOC_Dt = src.MOC_Dt,
                                   O.ErosionDt = src.ErosionDt,
                                   O.SMA_Dt = src.SMA_Dt,
                                   O.PNPA_Dt = src.PNPA_Dt,
                                   O.Asset_Norm = src.Asset_Norm,
                                   O.FlgDeg = src.FlgDeg,
                                   O.FlgUpg = src.FlgUpg,
                                   O.FlgMoc = src.FlgMoc,
                                   O.FlgSMA = src.FlgSMA,
                                   O.FlgProcessing = src.FlgProcessing,
                                   O.FlgErosion = src.FlgErosion,
                                   O.FlgPNPA = src.FlgPNPA,
                                   O.FlgPercolation = src.FlgPercolation,
                                   O.FlgInMonth = src.FlgInMonth,
                                   O.FlgDirtyRow = src.FlgDirtyRow,
                                   O.DegDate = src.DegDate,
                                   O.CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                   O.InMonthMark = src.InMonthMark,
                                   O.MocStatusMark = src.MocStatusMark,
                                   O.SourceAlt_Key = src.SourceAlt_Key,
                                   O.BankAssetClass = src.BankAssetClass,
                                   O.Cust_Expo = src.Cust_Expo,
                                   O.MOCReason = src.MOCReason,
                                   O.AddlProvisionPer = src.AddlProvisionPer,
                                   O.FraudDt = src.FraudDt,
                                   O.FraudAmount = src.FraudAmount,
                                   O.DegReason = src.DegReason,
                                   O.CustMoveDescription = src.CustMoveDescription,
                                   O.TotOsCust = src.TotOsCust,
                                   O.MOCTYPE = src.MOCTYPE;
      SELECT MAX(EntityKey)  

        INTO v_EntityKey
        FROM MAIN_PRO.CustomerCal_Hist ;
      IF v_EntityKey IS NULL THEN

      BEGIN
         v_EntityKey := 0 ;

      END;
      END IF;
      MERGE INTO MAIN_PRO.CUSTOMERCAL TEMP
      USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
      FROM MAIN_PRO.CUSTOMERCAL TEMP
             JOIN ( SELECT CUSTOMERCAL.CustomerEntityID ,
                           (v_EntityKey + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                           FROM DUAL  )  )) EntityKeyNew  
                    FROM MAIN_PRO.CUSTOMERCAL  ) ACCT   ON TEMP.CustomerEntityID = ACCT.CustomerEntityID 
       WHERE TEMP.IsChanged IN ( 'C','N' )
      ) src
      ON ( TEMP.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET TEMP.EntityKeyNew = src.EntityKeyNew;
      /***************************************************************************************************************/
      INSERT INTO MAIN_PRO.CustomerCal_Hist
        ( EntityKey, BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE )
        ( SELECT EntityKeyNew ,
                 BranchCode ,
                 UCIF_ID ,
                 UcifEntityID ,
                 CustomerEntityID ,
                 ParentCustomerID ,
                 RefCustomerID ,
                 SourceSystemCustomerID ,
                 CustomerName ,
                 CustSegmentCode ,
                 ConstitutionAlt_Key ,
                 PANNO ,
                 AadharCardNO ,
                 SrcAssetClassAlt_Key ,
                 SysAssetClassAlt_Key ,
                 SplCatg1Alt_Key ,
                 SplCatg2Alt_Key ,
                 SplCatg3Alt_Key ,
                 SplCatg4Alt_Key ,
                 SMA_Class_Key ,
                 PNPA_Class_Key ,
                 PrvQtrRV ,
                 CurntQtrRv ,
                 TotProvision ,
                 BankTotProvision ,
                 RBITotProvision ,
                 SrcNPA_Dt ,
                 SysNPA_Dt ,
                 DbtDt ,
                 DbtDt2 ,
                 DbtDt3 ,
                 LossDt ,
                 MOC_Dt ,
                 ErosionDt ,
                 SMA_Dt ,
                 PNPA_Dt ,
                 Asset_Norm ,
                 FlgDeg ,
                 FlgUpg ,
                 FlgMoc ,
                 FlgSMA ,
                 FlgProcessing ,
                 FlgErosion ,
                 FlgPNPA ,
                 FlgPercolation ,
                 FlgInMonth ,
                 FlgDirtyRow ,
                 DegDate ,
                 EffectiveFromTimeKey ,
                 49999 EffectiveToTimeKey  ,
                 CommonMocTypeAlt_Key ,
                 InMonthMark ,
                 MocStatusMark ,
                 SourceAlt_Key ,
                 BankAssetClass ,
                 Cust_Expo ,
                 MOCReason ,
                 AddlProvisionPer ,
                 FraudDt ,
                 FraudAmount ,
                 DegReason ,
                 CustMoveDescription ,
                 TotOsCust ,
                 MOCTYPE 
          FROM MAIN_PRO.CUSTOMERCAL T
           WHERE  NVL(T.IsChanged, 'N') IN ( 'C','N' )
         );

   END;
   END IF;
   /*  END OF CUSTOMER DATA MERGE */
   /***************************************************************************************************************/
   /*  ACCOUNT DATA MERGE */
   IF 1 = 1 THEN
    DECLARE
      ---------------------------------------------------------------------------------------------------------------
      -------------------------------
      /*  New Customers Ac Key ID Update  */
      v_EntityKeyAc NUMBER(19,0) := 0;

   BEGIN
      MERGE INTO MAIN_PRO.ACCOUNTCAL A
      USING (SELECT A.ROWID row_id, 'N'
      FROM MAIN_PRO.ACCOUNTCAL A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
      MERGE INTO MAIN_PRO.ACCOUNTCAL T 
      USING (SELECT T.ROWID row_id, 'C'
      FROM MAIN_PRO.AccountCal_Hist O
             JOIN MAIN_PRO.ACCOUNTCAL T   ON O.AccountEntityID = T.AccountEntityID
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
        OR CAST(NVL(O.DegReason, ' ') AS VARCHAR(1000))<> CAST(NVL(T.DegReason, ' ') AS VARCHAR(1000))
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
        OR CAST(NVL(O.PNPA_Reason, ' ') AS VARCHAR(1000))<> CAST(NVL(T.PNPA_Reason, ' ') AS VARCHAR(1000))
        OR NVL(O.SMA_Class, ' ') <> NVL(T.SMA_Class, ' ')
        OR CAST(NVL(O.SMA_Reason, ' ') AS VARCHAR(1000))<> CAST(NVL(T.SMA_Reason, ' ') AS VARCHAR(1000))
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
        OR CAST(NVL(O.NPA_Reason, ' ')AS VARCHAR(1000)) <> CAST(NVL(T.NPA_Reason, ' ') AS VARCHAR(1000))
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
        OR NVL(O.unserviedint, 0) <> NVL(T.UnserviedInt, 0)
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
      MERGE INTO MAIN_PRO.ACCOUNTCAL A
      USING (SELECT A.ROWID row_id, 'U'
      FROM MAIN_PRO.ACCOUNTCAL A
             JOIN MAIN_PRO.AccountCal_Hist B   ON B.AccountEntityID = A.AccountEntityID 
       WHERE B.EffectiveFromTimeKey = v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'U';
      ----------For Changes Records
      MERGE INTO MAIN_PRO.ACCOUNTCAL A
      USING (SELECT A.ROWID row_id, v_VEFFECTIVETO
      FROM MAIN_PRO.ACCOUNTCAL A
             JOIN MAIN_PRO.AccountCal_Hist B   ON B.AccountEntityID = A.AccountEntityID 
       WHERE B.EffectiveFromTimeKey < v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = v_VEFFECTIVETO;
      MERGE INTO MAIN_PRO.AccountCal_Hist O
      USING (SELECT O.ROWID row_id, T.UcifEntityID, T.CustomerEntityID, T.CustomerAcID, T.RefCustomerID, T.SourceSystemCustomerID, T.UCIF_ID, T.BranchCode, T.FacilityType, T.AcOpenDt, T.FirstDtOfDisb, T.ProductAlt_Key, T.SchemeAlt_key, T.SubSectorAlt_Key, T.SplCatg1Alt_Key, T.SplCatg2Alt_Key, T.SplCatg3Alt_Key, T.SplCatg4Alt_Key, T.SourceAlt_Key, T.ActSegmentCode, T.InttRate, T.Balance, T.BalanceInCrncy, T.CurrencyAlt_Key, T.DrawingPower, T.CurrentLimit, T.CurrentLimitDt, T.ContiExcessDt, T.StockStDt, T.DebitSinceDt, T.LastCrDate, T.InttServiced, T.IntNotServicedDt, T.OverdueAmt, T.OverDueSinceDt, T.ReviewDueDt, T.SecurityValue, T.DFVAmt, T.GovtGtyAmt, T.CoverGovGur, T.WriteOffAmount, T.UnAdjSubSidy, T.CreditsinceDt, T.DegReason, T.Asset_Norm, T.REFPeriodMax, T.RefPeriodOverdue, T.RefPeriodOverDrawn, T.RefPeriodNoCredit, T.RefPeriodIntService, T.RefPeriodStkStatement, T.RefPeriodReview, T.NetBalance, T.ApprRV, T.SecuredAmt, T.UnSecuredAmt, T.ProvDFV, T.Provsecured, T.ProvUnsecured, T.ProvCoverGovGur, T.AddlProvision, T.TotalProvision, T.BankProvsecured, T.BankProvUnsecured, T.BankTotalProvision, T.RBIProvsecured, T.RBIProvUnsecured, T.RBITotalProvision, T.InitialNpaDt, T.FinalNpaDt, T.SMA_Dt, T.UpgDate, T.InitialAssetClassAlt_Key, T.FinalAssetClassAlt_Key, T.ProvisionAlt_Key, T.PNPA_Reason, T.SMA_Class, T.SMA_Reason, T.FlgMoc, T.MOC_Dt, T.CommonMocTypeAlt_Key, T.FlgDeg, T.FlgDirtyRow, T.FlgInMonth, T.FlgSMA, T.FlgPNPA, T.FlgUpg, T.FlgFITL, T.FlgAbinitio, T.NPA_Days, T.RefPeriodOverdueUPG, T.RefPeriodOverDrawnUPG, T.RefPeriodNoCreditUPG, T.RefPeriodIntServiceUPG, T.RefPeriodStkStatementUPG, T.RefPeriodReviewUPG, T.AppGovGur, T.UsedRV, T.ComputedClaim, T.UPG_RELAX_MSME, T.DEG_RELAX_MSME, T.PNPA_DATE, T.NPA_Reason, T.PnpaAssetClassAlt_key, T.DisbAmount, T.PrincOutStd, T.PrincOverdue, T.PrincOverdueSinceDt, T.IntOverdue, T.IntOverdueSinceDt, T.OtherOverdue, T.OtherOverdueSinceDt, T.RelationshipNumber, T.AccountFlag, T.CommercialFlag_AltKey, T.Liability, T.CD, T.AccountStatus, T.AccountBlkCode1, T.AccountBlkCode2, T.ExposureType, T.Mtm_Value, T.BankAssetClass, T.NpaType, T.SecApp, T.BorrowerTypeID, T.LineCode, T.ProvPerSecured, T.ProvPerUnSecured, T.MOCReason, T.AddlProvisionPer, T.FlgINFRA, T.RepossessionDate, T.DerecognisedInterest1, T.DerecognisedInterest2, T.ProductCode, T.FlgLCBG, T.UnserviedInt, T.PreQtrCredit, T.PrvQtrInt, T.CurQtrCredit, T.CurQtrInt, T.OriginalBranchcode, T.AdvanceRecovery, T.NotionalInttAmt, T.PrvAssetClassAlt_Key, T.MOCTYPE, T.FlgSecured, T.RePossession, T.RCPending, T.PaymentPending, T.WheelCase, T.CustomerLevelMaxPer, T.FinalProvisionPer, T.IsIBPC, T.IsSecuritised, T.RFA, T.IsNonCooperative, T.Sarfaesi, T.WeakAccount, T.PUI, T.FlgFraud, T.FlgRestructure, T.RestructureDate, T.SarfaesiDate, T.FlgUnusualBounce, T.UnusualBounceDate, T.FlgUnClearedEffect, T.UnClearedEffectDate, T.FraudDate, T.WeakAccountDate
      FROM MAIN_PRO.AccountCal_Hist O
             JOIN MAIN_PRO.ACCOUNTCAL T   ON O.AccountEntityID = T.AccountEntityID 
       WHERE O.EffectiveFromTimeKey = v_TimeKey
        AND T.IsChanged = 'U') src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET O.UcifEntityID = src.UcifEntityID,
                                   O.CustomerEntityID = src.CustomerEntityID,
                                   O.CustomerAcID = src.CustomerAcID,
                                   O.RefCustomerID = src.RefCustomerID,
                                   O.SourceSystemCustomerID = src.SourceSystemCustomerID,
                                   O.UCIF_ID = src.UCIF_ID,
                                   O.BranchCode = src.BranchCode,
                                   O.FacilityType = src.FacilityType,
                                   O.AcOpenDt = src.AcOpenDt,
                                   O.FirstDtOfDisb = src.FirstDtOfDisb,
                                   O.ProductAlt_Key = src.ProductAlt_Key,
                                   O.SchemeAlt_key = src.SchemeAlt_key,
                                   O.SubSectorAlt_Key = src.SubSectorAlt_Key,
                                   O.SplCatg1Alt_Key = src.SplCatg1Alt_Key,
                                   O.SplCatg2Alt_Key = src.SplCatg2Alt_Key,
                                   O.SplCatg3Alt_Key = src.SplCatg3Alt_Key,
                                   O.SplCatg4Alt_Key = src.SplCatg4Alt_Key,
                                   O.SourceAlt_Key = src.SourceAlt_Key,
                                   O.ActSegmentCode = src.ActSegmentCode,
                                   O.InttRate = src.InttRate,
                                   O.Balance = src.Balance,
                                   O.BalanceInCrncy = src.BalanceInCrncy,
                                   O.CurrencyAlt_Key = src.CurrencyAlt_Key,
                                   O.DrawingPower = src.DrawingPower,
                                   O.CurrentLimit = src.CurrentLimit,
                                   O.CurrentLimitDt = src.CurrentLimitDt,
                                   O.ContiExcessDt = src.ContiExcessDt,
                                   O.StockStDt = src.StockStDt,
                                   O.DebitSinceDt = src.DebitSinceDt,
                                   O.LastCrDate = src.LastCrDate,
                                   O.InttServiced = src.InttServiced,
                                   O.IntNotServicedDt = src.IntNotServicedDt,
                                   O.OverdueAmt = src.OverdueAmt,
                                   O.OverDueSinceDt = src.OverDueSinceDt,
                                   O.ReviewDueDt = src.ReviewDueDt,
                                   O.SecurityValue = src.SecurityValue,
                                   O.DFVAmt = src.DFVAmt,
                                   O.GovtGtyAmt = src.GovtGtyAmt,
                                   O.CoverGovGur = src.CoverGovGur,
                                   O.WriteOffAmount = src.WriteOffAmount,
                                   O.UnAdjSubSidy = src.UnAdjSubSidy,
                                   O.CreditsinceDt = src.CreditsinceDt,
                                   O.DegReason = src.DegReason,
                                   O.Asset_Norm = src.Asset_Norm,
                                   O.REFPeriodMax = src.REFPeriodMax,
                                   O.RefPeriodOverdue = src.RefPeriodOverdue,
                                   O.RefPeriodOverDrawn = src.RefPeriodOverDrawn,
                                   O.RefPeriodNoCredit = src.RefPeriodNoCredit,
                                   O.RefPeriodIntService = src.RefPeriodIntService,
                                   O.RefPeriodStkStatement = src.RefPeriodStkStatement,
                                   O.RefPeriodReview = src.RefPeriodReview,
                                   O.NetBalance = src.NetBalance,
                                   O.ApprRV = src.ApprRV,
                                   O.SecuredAmt = src.SecuredAmt,
                                   O.UnSecuredAmt = src.UnSecuredAmt,
                                   O.ProvDFV = src.ProvDFV,
                                   O.Provsecured = src.Provsecured,
                                   O.ProvUnsecured = src.ProvUnsecured,
                                   O.ProvCoverGovGur = src.ProvCoverGovGur,
                                   O.AddlProvision = src.AddlProvision,
                                   O.TotalProvision = src.TotalProvision,
                                   O.BankProvsecured = src.BankProvsecured,
                                   O.BankProvUnsecured = src.BankProvUnsecured,
                                   O.BankTotalProvision = src.BankTotalProvision,
                                   O.RBIProvsecured = src.RBIProvsecured,
                                   O.RBIProvUnsecured = src.RBIProvUnsecured,
                                   O.RBITotalProvision = src.RBITotalProvision,
                                   O.InitialNpaDt = src.InitialNpaDt,
                                   O.FinalNpaDt = src.FinalNpaDt,
                                   O.SMA_Dt = src.SMA_Dt,
                                   O.UpgDate = src.UpgDate,
                                   O.InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                   O.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                   O.ProvisionAlt_Key = src.ProvisionAlt_Key,
                                   O.PNPA_Reason = src.PNPA_Reason,
                                   O.SMA_Class = src.SMA_Class,
                                   O.SMA_Reason = src.SMA_Reason,
                                   O.FlgMoc = src.FlgMoc,
                                   O.MOC_Dt = src.MOC_Dt,
                                   O.CommonMocTypeAlt_Key = src.CommonMocTypeAlt_Key,
                                   O.FlgDeg = src.FlgDeg,
                                   O.FlgDirtyRow = src.FlgDirtyRow,
                                   O.FlgInMonth = src.FlgInMonth,
                                   O.FlgSMA = src.FlgSMA,
                                   O.FlgPNPA = src.FlgPNPA,
                                   O.FlgUpg = src.FlgUpg,
                                   O.FlgFITL = src.FlgFITL,
                                   O.FlgAbinitio = src.FlgAbinitio,
                                   O.NPA_Days = src.NPA_Days,
                                   O.RefPeriodOverdueUPG = src.RefPeriodOverdueUPG,
                                   O.RefPeriodOverDrawnUPG = src.RefPeriodOverDrawnUPG,
                                   O.RefPeriodNoCreditUPG = src.RefPeriodNoCreditUPG,
                                   O.RefPeriodIntServiceUPG = src.RefPeriodIntServiceUPG,
                                   O.RefPeriodStkStatementUPG = src.RefPeriodStkStatementUPG,
                                   O.RefPeriodReviewUPG = src.RefPeriodReviewUPG,
                                   O.AppGovGur = src.AppGovGur,
                                   O.UsedRV = src.UsedRV,
                                   O.ComputedClaim = src.ComputedClaim,
                                   O.UPG_RELAX_MSME = src.UPG_RELAX_MSME,
                                   O.DEG_RELAX_MSME = src.DEG_RELAX_MSME,
                                   O.PNPA_DATE = src.PNPA_DATE,
                                   O.NPA_Reason = src.NPA_Reason,
                                   O.PnpaAssetClassAlt_key = src.PnpaAssetClassAlt_key,
                                   O.DisbAmount = src.DisbAmount,
                                   O.PrincOutStd = src.PrincOutStd,
                                   O.PrincOverdue = src.PrincOverdue,
                                   O.PrincOverdueSinceDt = src.PrincOverdueSinceDt,
                                   O.IntOverdue = src.IntOverdue,
                                   O.IntOverdueSinceDt = src.IntOverdueSinceDt,
                                   O.OtherOverdue = src.OtherOverdue,
                                   O.OtherOverdueSinceDt = src.OtherOverdueSinceDt,
                                   O.RelationshipNumber = src.RelationshipNumber,
                                   O.AccountFlag = src.AccountFlag,
                                   O.CommercialFlag_AltKey = src.CommercialFlag_AltKey,
                                   O.Liability = src.Liability,
                                   O.CD = src.CD,
                                   O.AccountStatus = src.AccountStatus,
                                   O.AccountBlkCode1 = src.AccountBlkCode1,
                                   O.AccountBlkCode2 = src.AccountBlkCode2,
                                   O.ExposureType = src.ExposureType,
                                   O.Mtm_Value = src.Mtm_Value,
                                   O.BankAssetClass = src.BankAssetClass,
                                   O.NpaType = src.NpaType,
                                   O.SecApp = src.SecApp,
                                   O.BorrowerTypeID = src.BorrowerTypeID,
                                   O.LineCode = src.LineCode,
                                   O.ProvPerSecured = src.ProvPerSecured,
                                   O.ProvPerUnSecured = src.ProvPerUnSecured,
                                   O.MOCReason = src.MOCReason,
                                   O.AddlProvisionPer = src.AddlProvisionPer,
                                   O.FlgINFRA = src.FlgINFRA,
                                   O.RepossessionDate = src.RepossessionDate,
                                   O.DerecognisedInterest1 = src.DerecognisedInterest1,
                                   O.DerecognisedInterest2 = src.DerecognisedInterest2,
                                   O.ProductCode = src.ProductCode,
                                   O.FlgLCBG = src.FlgLCBG,
                                   O.unserviedint = src.UnserviedInt,
                                   O.PreQtrCredit = src.PreQtrCredit,
                                   O.PrvQtrInt = src.PrvQtrInt,
                                   O.CurQtrCredit = src.CurQtrCredit,
                                   O.CurQtrInt = src.CurQtrInt,
                                   O.OriginalBranchcode = src.OriginalBranchcode,
                                   O.AdvanceRecovery = src.AdvanceRecovery,
                                   O.NotionalInttAmt = src.NotionalInttAmt,
                                   O.PrvAssetClassAlt_Key = src.PrvAssetClassAlt_Key,
                                   O.MOCTYPE = src.MOCTYPE,
                                   O.FlgSecured = src.FlgSecured,
                                   O.RePossession = src.RePossession,
                                   O.RCPending = src.RCPending,
                                   O.PaymentPending = src.PaymentPending,
                                   O.WheelCase = src.WheelCase,
                                   O.CustomerLevelMaxPer = src.CustomerLevelMaxPer,
                                   O.FinalProvisionPer = src.FinalProvisionPer,
                                   O.IsIBPC = src.IsIBPC,
                                   O.IsSecuritised = src.IsSecuritised,
                                   O.RFA = src.RFA,
                                   O.IsNonCooperative = src.IsNonCooperative,
                                   O.Sarfaesi = src.Sarfaesi,
                                   O.WeakAccount = src.WeakAccount,
                                   O.PUI = src.PUI,
                                   O.FlgFraud = src.FlgFraud,
                                   O.FlgRestructure = src.FlgRestructure,
                                   O.RestructureDate = src.RestructureDate,
                                   O.SarfaesiDate = src.SarfaesiDate,
                                   O.FlgUnusualBounce = src.FlgUnusualBounce,
                                   O.UnusualBounceDate = src.UnusualBounceDate,
                                   O.FlgUnClearedEffect = src.FlgUnClearedEffect,
                                   O.UnClearedEffectDate = src.UnClearedEffectDate,
                                   O.FraudDate = src.FraudDate,
                                   O.WeakAccountDate = src.WeakAccountDate;
      SELECT MAX(EntityKey)  

        INTO v_EntityKeyAc
        FROM MAIN_PRO.AccountCal_Hist ;
      IF v_EntityKeyAc IS NULL THEN

      BEGIN
         v_EntityKeyAc := 0 ;

      END;
      END IF;
      MERGE INTO MAIN_PRO.ACCOUNTCAL TEMP
      USING (SELECT TEMP.ROWID row_id, ACCT.EntityKeyNew
      FROM MAIN_PRO.ACCOUNTCAL TEMP
             JOIN ( SELECT ACCOUNTCAL.AccountEntityId ,
                           (v_EntityKeyAc + ROW_NUMBER() OVER ( ORDER BY ( SELECT 1 
                                                                             FROM DUAL  )  )) EntityKeyNew  
                    FROM MAIN_PRO.ACCOUNTCAL  ) ACCT   ON TEMP.AccountEntityID = ACCT.AccountEntityId 
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
                 EffectiveFromTimeKey ,
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
          FROM MAIN_PRO.ACCOUNTCAL T
           WHERE  NVL(T.IsChanged, 'N') IN ( 'C','N' )
         );

   END;
   END IF;
   /*  END OF ACCOUNT DATA MERGE */
   /*  RESTRUCTURE CAL HIST DATA MERGE */
   IF 1 = 1 THEN

   BEGIN
      MERGE INTO MAIN_PRO.AdvAcRestructureCal A
      USING (SELECT A.ROWID row_id, 'N'
      FROM MAIN_PRO.AdvAcRestructureCal A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
      MERGE INTO MAIN_PRO.AdvAcRestructureCal T
      USING (SELECT T.ROWID row_id, 'C'
      FROM MAIN_PRO.AdvAcRestructureCal_Hist O
             JOIN MAIN_PRO.AdvAcRestructureCal T   ON O.AccountEntityId = T.AccountEntityId
             AND O.EffectiveToTimeKey = 49999 
       WHERE ( NVL(O.AssetClassAlt_KeyOnInvocation, 0) <> NVL(T.AssetClassAlt_KeyOnInvocation, 0)
        OR NVL(O.PreRestructureAssetClassAlt_Key, 0) <> NVL(T.PreRestructureAssetClassAlt_Key, 0)
        OR NVL(O.PreRestructureNPA_Date, '1900-01-01') <> NVL(T.PreRestructureNPA_Date, '1900-01-01')
        OR NVL(O.ProvPerOnRestrucure, 0) <> NVL(T.ProvPerOnRestrucure, 0)
        OR NVL(O.RestructureTypeAlt_Key, 0) <> NVL(T.RestructureTypeAlt_Key, 0)
        OR NVL(O.COVID_OTR_CatgAlt_Key, 0) <> NVL(T.COVID_OTR_CatgAlt_Key, 0)
        OR NVL(O.RestructureDt, '1900-01-01') <> NVL(T.RestructureDt, '1900-01-01')
        OR NVL(O.SP_ExpiryDate, '1900-01-01') <> NVL(T.SP_ExpiryDate, '1900-01-01')
        OR NVL(O.DPD_AsOnRestructure, 0) <> NVL(T.DPD_AsOnRestructure, 0)
        OR NVL(O.RestructureFailureDate, '1900-01-01') <> NVL(T.RestructureFailureDate, '1900-01-01')
        OR NVL(O.DPD_Breach_Date, '1900-01-01') <> NVL(T.DPD_Breach_Date, '1900-01-01')
        OR NVL(O.ZeroDPD_Date, '1900-01-01') <> NVL(T.ZeroDPD_Date, '1900-01-01')
        OR NVL(O.SP_ExpiryExtendedDate, '1900-01-01') <> NVL(T.SP_ExpiryExtendedDate, '1900-01-01')
        OR NVL(O.CurrentPOS, 0) <> NVL(T.CurrentPOS, 0)
        OR NVL(O.CurrentTOS, 0) <> NVL(T.CurrentTOS, 0)
        OR NVL(O.RestructurePOS, 0) <> NVL(T.RestructurePOS, 0)
        OR NVL(O.Res_POS_to_CurrentPOS_Per, 0) <> NVL(T.Res_POS_to_CurrentPOS_Per, 0)
        OR NVL(O.CurrentDPD, 0) <> NVL(T.CurrentDPD, 0)
        OR NVL(O.TotalDPD, 0) <> NVL(T.TotalDPD, 0)
        OR NVL(O.VDPD, 0) <> NVL(T.VDPD, 0)
        OR NVL(O.AddlProvPer, 0) <> NVL(T.AddlProvPer, 0)
        OR NVL(O.ProvReleasePer, 0) <> NVL(T.ProvReleasePer, 0)
        OR NVL(O.AppliedNormalProvPer, 0) <> NVL(T.AppliedNormalProvPer, 0)
        OR NVL(O.FinalProvPer, 0) <> NVL(T.FinalProvPer, 0)
        OR NVL(O.PreDegProvPer, 0) <> NVL(T.PreDegProvPer, 0)
        OR NVL(O.UpgradeDate, '1900-01-01') <> NVL(T.UpgradeDate, '1900-01-01')
        OR NVL(O.SurvPeriodEndDate, '1900-01-01') <> NVL(T.SurvPeriodEndDate, '1900-01-01')
        OR NVL(O.DegDurSP_PeriodProvPer, 0) <> NVL(T.DegDurSP_PeriodProvPer, 0)
        OR NVL(O.NonFinDPD, 0) <> NVL(T.NonFinDPD, 0)
        OR NVL(O.InitialAssetClassAlt_Key, 0) <> NVL(T.InitialAssetClassAlt_Key, 0)
        OR NVL(O.FinalAssetClassAlt_Key, 0) <> NVL(T.FinalAssetClassAlt_Key, 0)
        OR NVL(O.RestructureProvision, 0) <> NVL(T.RestructureProvision, 0)
        OR NVL(O.SecuredProvision, 0) <> NVL(T.SecuredProvision, 0)
        OR NVL(O.UnSecuredProvision, 0) <> NVL(T.UnSecuredProvision, 0)
        OR NVL(O.FlgDeg, ' ') <> NVL(T.FlgDeg, ' ')
        OR NVL(O.FlgUpg, ' ') <> NVL(T.FlgUpg, ' ')
        OR NVL(O.DegDate, '1900-01-01') <> NVL(T.DegDate, '1900-01-01')
        OR NVL(O.RC_Pending, ' ') <> NVL(T.RC_Pending, ' ')
        OR NVL(O.FinalNpaDt, '1900-01-01') <> NVL(T.FinalNpaDt, '1900-01-01')
        OR NVL(O.RestructureStage, ' ') <> NVL(T.RestructureStage, ' ')
        OR NVL(O.DegReason, ' ') <> NVL(T.DegReason, ' ')
        OR NVL(O.InvestmentGrade, ' ') <> NVL(T.InvestmentGrade, ' ')
        OR NVL(O.PreRestructureNPA_Prov, 0) <> NVL(T.PreRestructureNPA_Prov, 0)
        OR NVL(O.FlgMorat, ' ') <> NVL(T.FlgMorat, ' ')
        OR NVL(O.POS_10PerPaidDate, '1900-01-01') <> NVL(T.POS_10PerPaidDate, '1900-01-01') )) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IsChanged = 'C';
      MERGE INTO MAIN_PRO.AdvAcRestructureCal A
      USING (SELECT A.ROWID row_id, 'U'
      FROM MAIN_PRO.AdvAcRestructureCal A
             JOIN MAIN_PRO.AdvAcRestructureCal_Hist B   ON B.AccountEntityId = A.AccountEntityId 
       WHERE B.EffectiveFromTimeKey = v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'U';
      ----------For Changes Records
      MERGE INTO MAIN_PRO.AdvAcRestructureCal A
      USING (SELECT A.ROWID row_id, v_VEFFECTIVETO
      FROM MAIN_PRO.AdvAcRestructureCal A
             JOIN MAIN_PRO.AdvAcRestructureCal_Hist B   ON B.AccountEntityId = A.AccountEntityId 
       WHERE B.EffectiveFromTimeKey < v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = v_VEFFECTIVETO;
      MERGE INTO MAIN_PRO.AdvAcRestructureCal_Hist O
      USING (SELECT O.ROWID row_id, T.AssetClassAlt_KeyOnInvocation, T.PreRestructureAssetClassAlt_Key, T.PreRestructureNPA_Date, T.ProvPerOnRestrucure, T.RestructureTypeAlt_Key, T.COVID_OTR_CatgAlt_Key, T.RestructureDt, T.SP_ExpiryDate, T.DPD_AsOnRestructure, T.RestructureFailureDate, T.DPD_Breach_Date, T.ZeroDPD_Date, T.SP_ExpiryExtendedDate, T.CurrentPOS, T.CurrentTOS, T.RestructurePOS, T.Res_POS_to_CurrentPOS_Per, T.CurrentDPD, T.TotalDPD, T.VDPD, T.AddlProvPer, T.ProvReleasePer, T.AppliedNormalProvPer, T.FinalProvPer, T.PreDegProvPer, T.UpgradeDate, T.SurvPeriodEndDate, T.DegDurSP_PeriodProvPer, T.NonFinDPD, T.InitialAssetClassAlt_Key, T.FinalAssetClassAlt_Key, T.RestructureProvision, T.SecuredProvision, T.UnSecuredProvision, T.FlgDeg, T.FlgUpg, T.DegDate, T.RC_Pending, T.FinalNpaDt, T.RestructureStage, T.DegReason, T.InvestmentGrade, T.PreRestructureNPA_Prov, T.FlgMorat, T.POS_10PerPaidDate
      FROM MAIN_PRO.AdvAcRestructureCal_Hist O
             JOIN MAIN_PRO.AdvAcRestructureCal T   ON O.AccountEntityId = T.AccountEntityId 
       WHERE O.EffectiveFromTimeKey = v_TimeKey
        AND T.IsChanged = 'U') src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET AssetClassAlt_KeyOnInvocation = src.AssetClassAlt_KeyOnInvocation,
                                   PreRestructureAssetClassAlt_Key = src.PreRestructureAssetClassAlt_Key,
                                   PreRestructureNPA_Date = src.PreRestructureNPA_Date,
                                   ProvPerOnRestrucure = src.ProvPerOnRestrucure,
                                   RestructureTypeAlt_Key = src.RestructureTypeAlt_Key,
                                   COVID_OTR_CatgAlt_Key = src.COVID_OTR_CatgAlt_Key,
                                   RestructureDt = src.RestructureDt,
                                   SP_ExpiryDate = src.SP_ExpiryDate,
                                   DPD_AsOnRestructure = src.DPD_AsOnRestructure,
                                   RestructureFailureDate = src.RestructureFailureDate,
                                   DPD_Breach_Date = src.DPD_Breach_Date,
                                   ZeroDPD_Date = src.ZeroDPD_Date,
                                   SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate,
                                   CurrentPOS = src.CurrentPOS,
                                   CurrentTOS = src.CurrentTOS,
                                   RestructurePOS = src.RestructurePOS,
                                   Res_POS_to_CurrentPOS_Per = src.Res_POS_to_CurrentPOS_Per,
                                   CurrentDPD = src.CurrentDPD,
                                   TotalDPD = src.TotalDPD,
                                   VDPD = src.VDPD,
                                   AddlProvPer = src.AddlProvPer,
                                   ProvReleasePer = src.ProvReleasePer,
                                   AppliedNormalProvPer = src.AppliedNormalProvPer,
                                   FinalProvPer = src.FinalProvPer,
                                   PreDegProvPer = src.PreDegProvPer,
                                   UpgradeDate = src.UpgradeDate,
                                   SurvPeriodEndDate = src.SurvPeriodEndDate,
                                   DegDurSP_PeriodProvPer = src.DegDurSP_PeriodProvPer,
                                   NonFinDPD = src.NonFinDPD,
                                   InitialAssetClassAlt_Key = src.InitialAssetClassAlt_Key,
                                   FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                   RestructureProvision = src.RestructureProvision,
                                   SecuredProvision = src.SecuredProvision,
                                   UnSecuredProvision = src.UnSecuredProvision,
                                   FlgDeg = src.FlgDeg,
                                   FlgUpg = src.FlgUpg,
                                   DegDate = src.DegDate,
                                   RC_Pending = src.RC_Pending,
                                   FinalNpaDt = src.FinalNpaDt,
                                   RestructureStage = src.RestructureStage,
                                   DegReason = src.DegReason,
                                   InvestmentGrade = src.InvestmentGrade,
                                   PreRestructureNPA_Prov = src.PreRestructureNPA_Prov,
                                   FlgMorat = src.FlgMorat,
                                   POS_10PerPaidDate = src.POS_10PerPaidDate;
      ---------------------------------------------------------------------------------------------------------------
      -------------------------------
      --/*  New Customers Ac Key ID Update  */
      --DECLARE @EntityKeyAc BIGINT=0 
      --SELECT @EntityKeyAc=MAX(EntityKey) FROM  pro.AdvAcRestructureCal_hist
      --IF @EntityKeyAc IS NULL  
      --BEGIN
      --SET @EntityKeyAc=0
      --END
      --UPDATE TEMP 
      --SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
      -- FROM PRO.AdvAcRestructureCal TEMP
      --INNER JOIN (SELECT AccountEntityId,(@EntityKeyAc + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
      --			FROM PRO.AdvAcRestructureCal
      --			)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
      --Where Temp.IsChanged in ('C','N')
      /***************************************************************************************************************/
      INSERT INTO MAIN_PRO.AdvAcRestructureCal_Hist
        ( AccountEntityId, AssetClassAlt_KeyOnInvocation, PreRestructureAssetClassAlt_Key, PreRestructureNPA_Date, ProvPerOnRestrucure, RestructureTypeAlt_Key, COVID_OTR_CatgAlt_Key, RestructureDt, SP_ExpiryDate, DPD_AsOnRestructure, RestructureFailureDate, DPD_Breach_Date, ZeroDPD_Date, SP_ExpiryExtendedDate, CurrentPOS, CurrentTOS, RestructurePOS, Res_POS_to_CurrentPOS_Per, CurrentDPD, TotalDPD, VDPD, AddlProvPer, ProvReleasePer, AppliedNormalProvPer, FinalProvPer, PreDegProvPer, UpgradeDate, SurvPeriodEndDate, DegDurSP_PeriodProvPer, NonFinDPD, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, RestructureProvision, SecuredProvision, UnSecuredProvision, FlgDeg, FlgUpg, DegDate, RC_Pending, FinalNpaDt, RestructureStage, EffectiveFromTimeKey, EffectiveToTimeKey, DegReason, InvestmentGrade, PreRestructureNPA_Prov, FlgMorat, POS_10PerPaidDate )
        ( SELECT AccountEntityId ,
                 AssetClassAlt_KeyOnInvocation ,
                 PreRestructureAssetClassAlt_Key ,
                 PreRestructureNPA_Date ,
                 ProvPerOnRestrucure ,
                 RestructureTypeAlt_Key ,
                 COVID_OTR_CatgAlt_Key ,
                 RestructureDt ,
                 SP_ExpiryDate ,
                 DPD_AsOnRestructure ,
                 RestructureFailureDate ,
                 DPD_Breach_Date ,
                 ZeroDPD_Date ,
                 SP_ExpiryExtendedDate ,
                 CurrentPOS ,
                 CurrentTOS ,
                 RestructurePOS ,
                 Res_POS_to_CurrentPOS_Per ,
                 CurrentDPD ,
                 TotalDPD ,
                 VDPD ,
                 AddlProvPer ,
                 ProvReleasePer ,
                 AppliedNormalProvPer ,
                 FinalProvPer ,
                 PreDegProvPer ,
                 UpgradeDate ,
                 SurvPeriodEndDate ,
                 DegDurSP_PeriodProvPer ,
                 NonFinDPD ,
                 InitialAssetClassAlt_Key ,
                 FinalAssetClassAlt_Key ,
                 RestructureProvision ,
                 SecuredProvision ,
                 UnSecuredProvision ,
                 FlgDeg ,
                 FlgUpg ,
                 DegDate ,
                 RC_Pending ,
                 FinalNpaDt ,
                 RestructureStage ,
                 EffectiveFromTimeKey ,
                 49999 EffectiveToTimeKey  ,
                 DegReason ,
                 InvestmentGrade ,
                 PreRestructureNPA_Prov ,
                 FlgMorat ,
                 POS_10PerPaidDate 
          FROM MAIN_PRO.AdvAcRestructureCal T
           WHERE  NVL(T.IsChanged, 'N') IN ( 'C','N' )
         );

   END;
   END IF;
   /*  END OF RESTRUCTURECAL  DATA MERGE */
   /* RESTRUCTUREDETAIL DATA MERGE */
   IF 1 = 1 THEN
    DECLARE
      /* RESTRUCTURE DETAIL	*/
      v_Procdate VARCHAR2(200) ;
      v_PrevTimeKey NUMBER(10,0) ;

   BEGIN
   
   SELECT DATE_ into v_Procdate
        FROM RBL_MISDB_PROD.SysDayMatrix 
       WHERE  TIMEKEY = v_TIMEKEY ;
       
       SELECT MAX(EffectiveFromTimeKey) into v_PrevTimeKey 
        FROM MAIN_PRO.AdvAcRestructureCal_Hist 
       WHERE  EffectiveFromTimeKey < v_TIMEKEY ;
       
      DELETE FROM GTT_AdvAcRestructureDetail;
      UTILS.IDENTITY_RESET('GTT_AdvAcRestructureDetail');

      INSERT INTO GTT_AdvAcRestructureDetail (ENTITYKEY,ACCOUNTENTITYID,	RESTRUCTURETYPEALT_KEY,	RESTRUCTUREPROPOSALDT,	RESTRUCTUREDT,	RESTRUCTUREAMT,	RESTRUCTUREAPPROVALDT,	RESTRUCTURESEQUENCEREFNO,	DIMINUTIONAMOUNT,	RESTRUCTUREBYALT_KEY,	REFCUSTOMERID,	REFSYSTEMACID,	SDR_INVOKED,	SDR_REFER_DATE,	REMARK,	RESTRUCTUREFACILITYTYPEALT_KEY,	BANKINGRELATIONTYPEALT_KEY,	INVOCATIONDATE,	ASSETCLASSALT_KEYONINVOCATION,	EQUITYCONVERSIONYN,	CONVERSIONDATE,	PRINCREPAYSTARTDATE,	INTTREPAYSTARTDATE,	PRERESTRUCTUREASSETCLASSALT_KEY,	PRERESTRUCTURENPA_DATE,	PROVPERONRESTRUCURE,	COVID_OTR_CATGALT_KEY,	RESTRUCTUREAPPROVINGAUTHORITY,	RESTRUCTRETOS,	UNSERVICEINTTASONRESTRUCTURE,	RESTRUCTUREPOS,	RESTRUCTURESTAGE,	RESTRUCTURESTATUS,	DPD_ASONRESTRUCTURE,	DPD_BREACH_DATE,	ZERODPD_DATE,	SURVPERIODENDDATE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFIEDBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	D2KTIMESTAMP,	RESTRUCTUREFAILUREDATE,	UPGRADEDATE,	PREDEGPROVPER,	SP_EXPIRYEXTENDEDDATE,	CHANGEFIELD,	RESTRUCTUREDESCRIPTION,	INVESTMENTGRADE,	POS_10PERPAIDDATE,	FLGMORAT,	PRERESTRUCTURENPA_PROV,	RESTRUCTUREASSETCLASSALT_KEY,	POSTRESTRUCASSETCLASS,	RESTRUCTURECATGALT_KEY,	BANKINGTYPE,	COVID_OTR_CATG,	IS_COVID_MORAT,	IS_INVESTMENTGRADE,	REVISEDBUSINESSSEGMENT,	PRERESTRUCNPA_DATE,	DISBURSEMENTDATE,	PRERESTRUCDEFAULTDATE,	NPA_QTR,	RESTRUCTUREDATE,	APPROVINGAUTHALT_KEY,	REPAYMENTSTARTDATE,	INTREPAYSTARTDATE,	REFDATE,	ISEQUITYCOVERSION,	FSTDEFAULTREPORTINGBANK,	ICA_SIGNDATE,	CREDITPROVISION,	DFVPROVISION,	MTMPROVISION,	CRILIC_FST_DEFAULTDATE,	REVISEDBUSSEGALT_KEY,	NPA_PROVISION_PER)
      	SELECT ENTITYKEY,	ACCOUNTENTITYID,	RESTRUCTURETYPEALT_KEY,	RESTRUCTUREPROPOSALDT,	RESTRUCTUREDT,	RESTRUCTUREAMT,	RESTRUCTUREAPPROVALDT,	RESTRUCTURESEQUENCEREFNO,	DIMINUTIONAMOUNT,	RESTRUCTUREBYALT_KEY,	REFCUSTOMERID,	REFSYSTEMACID,	SDR_INVOKED,	SDR_REFER_DATE,	REMARK,	RESTRUCTUREFACILITYTYPEALT_KEY,	BANKINGRELATIONTYPEALT_KEY,	INVOCATIONDATE,	ASSETCLASSALT_KEYONINVOCATION,	EQUITYCONVERSIONYN,	CONVERSIONDATE,	PRINCREPAYSTARTDATE,	INTTREPAYSTARTDATE,	PRERESTRUCTUREASSETCLASSALT_KEY,	PRERESTRUCTURENPA_DATE,	PROVPERONRESTRUCURE,	COVID_OTR_CATGALT_KEY,	RESTRUCTUREAPPROVINGAUTHORITY,	RESTRUCTRETOS,	UNSERVICEINTTASONRESTRUCTURE,	RESTRUCTUREPOS,	RESTRUCTURESTAGE,	RESTRUCTURESTATUS,	DPD_ASONRESTRUCTURE,	DPD_BREACH_DATE,	ZERODPD_DATE,	SURVPERIODENDDATE,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	MODIFIEDBY,	DATEMODIFIED,	APPROVEDBY,	DATEAPPROVED,	D2KTIMESTAMP,	RESTRUCTUREFAILUREDATE,	UPGRADEDATE,	PREDEGPROVPER,	SP_EXPIRYEXTENDEDDATE,	CHANGEFIELD,	RESTRUCTUREDESCRIPTION,	INVESTMENTGRADE,	POS_10PERPAIDDATE,	FLGMORAT,	PRERESTRUCTURENPA_PROV,	RESTRUCTUREASSETCLASSALT_KEY,	POSTRESTRUCASSETCLASS,	RESTRUCTURECATGALT_KEY,	BANKINGTYPE,	COVID_OTR_CATG,	IS_COVID_MORAT,	IS_INVESTMENTGRADE,	REVISEDBUSINESSSEGMENT,	PRERESTRUCNPA_DATE,	DISBURSEMENTDATE,	PRERESTRUCDEFAULTDATE,	NPA_QTR,	RESTRUCTUREDATE,	APPROVINGAUTHALT_KEY,	REPAYMENTSTARTDATE,	INTREPAYSTARTDATE,	REFDATE,	ISEQUITYCOVERSION,	FSTDEFAULTREPORTINGBANK,	ICA_SIGNDATE,	CREDITPROVISION,	DFVPROVISION,	MTMPROVISION,	CRILIC_FST_DEFAULTDATE,	REVISEDBUSSEGALT_KEY,	NPA_PROVISION_PER
      	  FROM RBL_MISDB_PROD.AdvAcRestructureDetail 
      	 WHERE  EffectiveFromTimeKey <= v_TIMEKEY
                 AND EffectiveToTimeKey >= v_TIMEKEY ;
      MERGE INTO GTT_AdvAcRestructureDetail A
      USING (SELECT A.ROWID row_id, NVL(B.AppliedNormalProvPer, 0) + NVL(B.FinalProvPer, 0) AS PreDegProvPer
      FROM GTT_AdvAcRestructureDetail A
             JOIN MAIN_PRO.AdvAcRestructureCal_Hist B   ON A.AccountEntityId = B.AccountEntityId
             AND ( B.EffectiveFromTimeKey <= v_PrevTimeKey
             AND B.EffectiveToTimeKey >= v_PrevTimeKey )
             JOIN MAIN_PRO.AdvAcRestructureCal C   ON A.AccountEntityId = C.AccountEntityId
             AND C.InitialAssetClassAlt_Key = 1
             AND C.FinalAssetClassAlt_Key > 1 ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.PreDegProvPer = src.PreDegProvPer;
      /* 1- UPDATE DPD_30_90_Breach_Date IN RESTRCTURE CAL - IF ACCOUNT IS NPA AND DPD >90,   UPDATE ZERO_DPD_DATE =NULL, SP_ExpiryExtendedDate = NULL */
      MERGE INTO GTT_AdvAcRestructureDetail a
      USING (SELECT a.ROWID row_id, b.DPD_Breach_Date, b.ZeroDPD_Date, b.SP_ExpiryExtendedDate, B.RestructureStage
      FROM GTT_AdvAcRestructureDetail a
             JOIN MAIN_PRO.AdvAcRestructureCal b   ON a.AccountEntityId = b.AccountEntityId ) src
      ON ( a.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET a.DPD_Breach_Date = src.DPD_Breach_Date,
                                   a.ZeroDPD_Date = src.ZeroDPD_Date,
                                   a.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate,
                                   A.RestructureStage = src.RestructureStage;
      /* MERGE DATA IN ADVACRESTRUCTURE DETAIL-IN CASE OF EFFECTIVEFROMTIKE IS LESS THAN @TIMEKEY*/
      MERGE INTO CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail O
      USING (SELECT O.ROWID row_id, v_TIMEKEY - 1 AS pos_2, UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103) AS pos_3, 'ACL-PROCESS' AS pos_4
      FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail O
             JOIN GTT_AdvAcRestructureDetail T   ON O.AccountEntityID = T.AccountEntityID
             AND O.EffectiveToTimeKey = 49999
             AND T.EffectiveToTimeKey = 49999
             AND O.EffectiveFromTimeKey < v_TIMEKEY 
       WHERE ( NVL(O.RestructureStage, '1990-01-01') <> NVL(T.RestructureStage, '1990-01-01')
        OR NVL(O.ZeroDPD_Date, '1990-01-01') <> NVL(T.ZeroDPD_Date, '1990-01-01')
        OR NVL(O.SP_ExpiryExtendedDate, '1990-01-01') <> NVL(T.SP_ExpiryExtendedDate, '1990-01-01')
        OR NVL(O.DPD_Breach_Date, '1990-01-01') <> NVL(T.DPD_Breach_Date, '1990-01-01')
        OR NVL(O.UpgradeDate, '1990-01-01') <> NVL(T.UpgradeDate, '1990-01-01')
        OR NVL(O.SurvPeriodEndDate, '1990-01-01') <> NVL(T.SurvPeriodEndDate, '1990-01-01')
        OR NVL(O.RestructureStage, ' ') <> NVL(T.RestructureStage, ' ')
        OR NVL(O.PreDegProvPer, 0) <> NVL(T.PreDegProvPer, 0) )) src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey = pos_2,
                                   O.DateModified = pos_3,
                                   O.ModifiedBy = pos_4;
      /* UPODATE DATA FOR SAME TIMEKEY */
      MERGE INTO CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail A
      USING (SELECT A.ROWID row_id, B.RestructureStage, B.ZeroDPD_Date, B.SP_ExpiryExtendedDate, B.DPD_Breach_Date, B.UpgradeDate, B.SurvPeriodEndDate
      FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail A
             JOIN GTT_AdvAcRestructureDetail B   ON A.AccountEntityId = B.AccountEntityId
             AND A.EffectiveFromTimeKey <= v_TIMEKEY
             AND A.EffectiveToTimeKey >= v_TIMEKEY
             AND A.EffectiveFromTimeKey = v_TIMEKEY ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.RestructureStage = src.RestructureStage,
                                   A.ZeroDPD_Date = src.ZeroDPD_Date,
                                   A.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate,
                                   A.DPD_Breach_Date = src.DPD_Breach_Date,
                                   A.UpgradeDate = src.UpgradeDate,
                                   A.SurvPeriodEndDate = src.SurvPeriodEndDate;
      ----------For Changes Records
      MERGE INTO GTT_AdvAcRestructureDetail A
      USING (SELECT A.ROWID row_id, ISCHANGED
      FROM GTT_AdvAcRestructureDetail A
             JOIN CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail B   ON B.AccountEntityId = A.AccountEntityId 
       WHERE B.EffectiveToTimeKey = v_TIMEKEY - 1
        AND B.ModifiedBy = 'ACL-PROCESS') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged
                                   ----Select * 
                                    = 'C';
      /***************************************************************************************************************/
      INSERT INTO CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail
        ( AccountEntityId, RestructureTypeAlt_Key, RestructureProposalDt, RestructureDt, RestructureAmt, RestructureApprovalDt, RestructureSequenceRefNo, DiminutionAmount, RestructureByAlt_Key, RefCustomerId, RefSystemAcId, SDR_INVOKED, SDR_REFER_DATE, Remark, RestructureFacilityTypeAlt_Key, BankingRelationTypeAlt_Key, InvocationDate, AssetClassAlt_KeyOnInvocation, EquityConversionYN, ConversionDate, PrincRepayStartDate, InttRepayStartDate, PreRestructureAssetClassAlt_Key, PreRestructureNPA_Date, ProvPerOnRestrucure, COVID_OTR_CatgAlt_Key, RestructureApprovingAuthority, RestructreTOS, UnserviceInttAsOnRestructure, RestructurePOS, RestructureStage, RestructureStatus, DPD_AsOnRestructure, DPD_Breach_Date, ZeroDPD_Date, SurvPeriodEndDate, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved, RestructureFailureDate, UpgradeDate, PreDegProvPer, SP_ExpiryExtendedDate, FlgMorat, InvestmentGrade, POS_10PerPaidDate )
        ( SELECT AccountEntityId ,
                 RestructureTypeAlt_Key ,
                 RestructureProposalDt ,
                 RestructureDt ,
                 RestructureAmt ,
                 RestructureApprovalDt ,
                 RestructureSequenceRefNo ,
                 DiminutionAmount ,
                 RestructureByAlt_Key ,
                 RefCustomerId ,
                 RefSystemAcId ,
                 SDR_INVOKED ,
                 SDR_REFER_DATE ,
                 Remark ,
                 RestructureFacilityTypeAlt_Key ,
                 BankingRelationTypeAlt_Key ,
                 InvocationDate ,
                 AssetClassAlt_KeyOnInvocation ,
                 EquityConversionYN ,
                 ConversionDate ,
                 PrincRepayStartDate ,
                 InttRepayStartDate ,
                 PreRestructureAssetClassAlt_Key ,
                 PreRestructureNPA_Date ,
                 ProvPerOnRestrucure ,
                 COVID_OTR_CatgAlt_Key ,
                 RestructureApprovingAuthority ,
                 RestructreTOS ,
                 UnserviceInttAsOnRestructure ,
                 RestructurePOS ,
                 RestructureStage ,
                 RestructureStatus ,
                 DPD_AsOnRestructure ,
                 DPD_Breach_Date ,
                 ZeroDPD_Date ,
                 SurvPeriodEndDate ,
                 AuthorisationStatus ,
                 v_TIMEKEY EffectiveFromTimeKey  ,
                 49999 EffectiveToTimeKey  ,
                 CreatedBy ,
                 DateCreated ,
                 'ACL-PROCESS' ModifiedBy  ,
                 SYSDATE DateModified  ,
                 ApprovedBy ,
                 DateApproved ,
                 RestructureFailureDate ,
                 UpgradeDate ,
                 PreDegProvPer ,
                 SP_ExpiryExtendedDate ,
                 FlgMorat ,
                 InvestmentGrade ,
                 POS_10PerPaidDate 
          FROM GTT_AdvAcRestructureDetail T
           WHERE  NVL(T.IsChanged, 'U') = 'C' );

   END;
   END IF;
   /* END OF RESTRUCTURE DATA */
   /*  PUI CAL HIST DATA MERGE */
   IF 1 = 1 THEN

   BEGIN
      MERGE INTO MAIN_PRO.PUI_CAL A
      USING (SELECT A.ROWID row_id, 'N'
      FROM MAIN_PRO.PUI_CAL A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'N';
      MERGE INTO MAIN_PRO.PUI_CAL T 
      USING (SELECT T.ROWID row_id, 'C'
      FROM MAIN_PRO.PUI_CAL_hist O
             JOIN MAIN_PRO.PUI_CAL T   ON O.AccountEntityId = T.AccountEntityId
             AND O.EffectiveToTimeKey = 49999 
       WHERE ( NVL(O.CustomerEntityID, 0) <> NVL(T.CustomerEntityID, 0)
        OR NVL(O.ProjectCategoryAlt_Key, 0) <> NVL(T.ProjectCategoryAlt_Key, 0)
        OR NVL(O.ProjectSubCategoryAlt_key, 0) <> NVL(T.ProjectSubCategoryAlt_key, 0)
        OR NVL(O.DelayReasonChangeinOwnership, ' ') <> NVL(T.DelayReasonChangeinOwnership, ' ')
        OR NVL(O.ProjectAuthorityAlt_key, 0) <> NVL(T.ProjectAuthorityAlt_key, 0)
        OR NVL(O.OriginalDCCO, '1900-01-01') <> NVL(T.OriginalDCCO, '1900-01-01')
        OR NVL(O.OriginalProjectCost, 0) <> NVL(T.OriginalProjectCost, 0)
        OR NVL(O.OriginalDebt, 0) <> NVL(T.OriginalDebt, 0)
        OR NVL(O.Debt_EquityRatio, 0) <> NVL(T.Debt_EquityRatio, 0)
        OR NVL(O.ChangeinProjectScope, ' ') <> NVL(T.ChangeinProjectScope, ' ')
        OR NVL(O.FreshOriginalDCCO, '1900-01-01') <> NVL(T.FreshOriginalDCCO, '1900-01-01')
        OR NVL(O.RevisedDCCO, '1900-01-01') <> NVL(T.RevisedDCCO, '1900-01-01')
        OR NVL(O.CourtCaseArbitration, ' ') <> NVL(T.CourtCaseArbitration, ' ')
        OR NVL(O.CIOReferenceDate, '1900-01-01') <> NVL(T.CIOReferenceDate, '1900-01-01')
        OR NVL(O.CIODCCO, '1900-01-01') <> NVL(T.CIODCCO, '1900-01-01')
        OR NVL(O.TakeOutFinance, ' ') <> NVL(T.TakeOutFinance, ' ')
        OR NVL(O.AssetClassSellerBookAlt_key, 0) <> NVL(T.AssetClassSellerBookAlt_key, 0)
        OR NVL(O.NPADateSellerBook, '1900-01-01') <> NVL(T.NPADateSellerBook, '1900-01-01')
        OR NVL(O.Restructuring, ' ') <> NVL(T.Restructuring, ' ')
        OR NVL(O.InitialExtension, ' ') <> NVL(T.InitialExtension, ' ')
        OR NVL(O.BeyonControlofPromoters, ' ') <> NVL(T.BeyonControlofPromoters, ' ')
        OR NVL(O.DelayReasonOther, ' ') <> NVL(T.DelayReasonOther, ' ')
        OR NVL(O.FLG_UPG, ' ') <> NVL(T.FLG_UPG, ' ')
        OR NVL(O.FLG_DEG, ' ') <> NVL(T.FLG_DEG, ' ')
        OR NVL(O.DEFAULT_REASON, ' ') <> NVL(T.DEFAULT_REASON, ' ')
        OR NVL(O.ProjCategory, ' ') <> NVL(T.ProjCategory, ' ')
        OR NVL(O.NPA_DATE, '1900-01-01') <> NVL(T.NPA_DATE, '1900-01-01')
        OR NVL(O.PUI_ProvPer, 0) <> NVL(T.PUI_ProvPer, 0)
        OR NVL(O.RestructureDate, '1900-01-01') <> NVL(T.RestructureDate, '1900-01-01')
        OR NVL(O.ActualDCCO, ' ') <> NVL(T.ActualDCCO, ' ')
        OR NVL(O.ActualDCCO_Date, '1900-01-01') <> NVL(T.ActualDCCO_Date, '1900-01-01')
        OR NVL(O.UpgradeDate, '1900-01-01') <> NVL(T.UpgradeDate, '1900-01-01')
        OR NVL(O.FinalAssetClassAlt_Key, 0) <> NVL(T.FinalAssetClassAlt_Key, 0)
        OR NVL(O.DPD_Max, 0) <> NVL(T.DPD_Max, 0) )) src
      ON ( T.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET T.IsChanged = 'C';
      MERGE INTO MAIN_PRO.PUI_CAL A
      USING (SELECT A.ROWID row_id, 'U'
      FROM MAIN_PRO.PUI_CAL A
             JOIN MAIN_PRO.PUI_CAL_hist B   ON B.AccountEntityId = A.AccountEntityId 
       WHERE B.EffectiveFromTimeKey = v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.IsChanged = 'U';
      ----------For Changes Records
      MERGE INTO MAIN_PRO.PUI_CAL A
      USING (SELECT A.ROWID row_id, v_VEFFECTIVETO
      FROM MAIN_PRO.PUI_CAL A
             JOIN MAIN_PRO.PUI_CAL_hist B   ON B.AccountEntityId = A.AccountEntityId 
       WHERE B.EffectiveFromTimeKey < v_TimeKey
        AND A.IsChanged = 'C') src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = v_VEFFECTIVETO;
      MERGE INTO MAIN_PRO.PUI_CAL_hist O
      USING (SELECT O.ROWID row_id, T.CustomerEntityID, T.ProjectCategoryAlt_Key, T.ProjectSubCategoryAlt_key, T.DelayReasonChangeinOwnership, T.ProjectAuthorityAlt_key, T.OriginalDCCO, T.OriginalProjectCost, T.OriginalDebt, T.Debt_EquityRatio, T.ChangeinProjectScope, T.FreshOriginalDCCO, T.RevisedDCCO, T.CourtCaseArbitration, T.CIOReferenceDate, T.CIODCCO, T.TakeOutFinance, T.AssetClassSellerBookAlt_key, T.NPADateSellerBook, T.Restructuring, T.InitialExtension, T.BeyonControlofPromoters, T.DelayReasonOther, T.FLG_UPG, T.FLG_DEG, T.DEFAULT_REASON, T.ProjCategory, T.NPA_DATE, T.PUI_ProvPer, T.RestructureDate, T.ActualDCCO, T.ActualDCCO_Date, T.UpgradeDate, T.FinalAssetClassAlt_Key, T.DPD_Max
      FROM MAIN_PRO.PUI_CAL_hist O
             JOIN MAIN_PRO.PUI_CAL T   ON O.AccountEntityId = T.AccountEntityId 
       WHERE O.EffectiveFromTimeKey = v_TimeKey
        AND T.IsChanged = 'U') src
      ON ( O.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET O.CustomerEntityID = src.CustomerEntityID,
                                   O.ProjectCategoryAlt_Key = src.ProjectCategoryAlt_Key,
                                   O.ProjectSubCategoryAlt_key = src.ProjectSubCategoryAlt_key,
                                   O.DelayReasonChangeinOwnership = src.DelayReasonChangeinOwnership,
                                   O.ProjectAuthorityAlt_key = src.ProjectAuthorityAlt_key,
                                   O.OriginalDCCO = src.OriginalDCCO,
                                   O.OriginalProjectCost = src.OriginalProjectCost,
                                   O.OriginalDebt = src.OriginalDebt,
                                   O.Debt_EquityRatio = src.Debt_EquityRatio,
                                   O.ChangeinProjectScope = src.ChangeinProjectScope,
                                   O.FreshOriginalDCCO = src.FreshOriginalDCCO,
                                   O.RevisedDCCO = src.RevisedDCCO,
                                   O.CourtCaseArbitration = src.CourtCaseArbitration,
                                   O.CIOReferenceDate = src.CIOReferenceDate,
                                   O.CIODCCO = src.CIODCCO,
                                   O.TakeOutFinance = src.TakeOutFinance,
                                   O.AssetClassSellerBookAlt_key = src.AssetClassSellerBookAlt_key,
                                   O.NPADateSellerBook = src.NPADateSellerBook,
                                   O.Restructuring = src.Restructuring,
                                   O.InitialExtension = src.InitialExtension,
                                   O.BeyonControlofPromoters = src.BeyonControlofPromoters,
                                   O.DelayReasonOther = src.DelayReasonOther,
                                   O.FLG_UPG = src.FLG_UPG,
                                   O.FLG_DEG = src.FLG_DEG,
                                   O.DEFAULT_REASON = src.DEFAULT_REASON,
                                   O.ProjCategory = src.ProjCategory,
                                   O.NPA_DATE = src.NPA_DATE,
                                   O.PUI_ProvPer = src.PUI_ProvPer,
                                   O.RestructureDate = src.RestructureDate,
                                   O.ActualDCCO = src.ActualDCCO,
                                   O.ActualDCCO_Date = src.ActualDCCO_Date,
                                   O.UpgradeDate = src.UpgradeDate,
                                   O.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                   O.DPD_Max = src.DPD_Max;
      ---------------------------------------------------------------------------------------------------------------
      -------------------------------
      --/*  New Customers Ac Key ID Update  */
      --DECLARE @EntityKeyAc BIGINT=0 
      --SELECT @EntityKeyAc=MAX(EntityKey) FROM  pro.AdvAcRestructureCal_hist
      --IF @EntityKeyAc IS NULL  
      --BEGIN
      --SET @EntityKeyAc=0
      --END
      --UPDATE TEMP 
      --SET TEMP.EntityKeyNew=ACCT.EntityKeyNew
      -- FROM PRO.AdvAcRestructureCal TEMP
      --INNER JOIN (SELECT AccountEntityId,(@EntityKeyAc + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKeyNew
      --			FROM PRO.AdvAcRestructureCal
      --			)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
      --Where Temp.IsChanged in ('C','N')
      /***************************************************************************************************************/
      INSERT INTO MAIN_PRO.PUI_CAL_hist
        ( CustomerEntityID, AccountEntityId, ProjectCategoryAlt_Key, ProjectSubCategoryAlt_key, DelayReasonChangeinOwnership, ProjectAuthorityAlt_key, OriginalDCCO, OriginalProjectCost, OriginalDebt, Debt_EquityRatio, ChangeinProjectScope, FreshOriginalDCCO, RevisedDCCO, CourtCaseArbitration, CIOReferenceDate, CIODCCO, TakeOutFinance, AssetClassSellerBookAlt_key, NPADateSellerBook, Restructuring, InitialExtension, BeyonControlofPromoters, DelayReasonOther, FLG_UPG, FLG_DEG, DEFAULT_REASON, ProjCategory, NPA_DATE, PUI_ProvPer, RestructureDate, ActualDCCO, ActualDCCO_Date, UpgradeDate, FinalAssetClassAlt_Key, DPD_Max, EffectiveFromTimeKey, EffectiveToTimeKey )
        ( SELECT CustomerEntityID ,
                 AccountEntityId ,
                 ProjectCategoryAlt_Key ,
                 ProjectSubCategoryAlt_key ,
                 DelayReasonChangeinOwnership ,
                 ProjectAuthorityAlt_key ,
                 OriginalDCCO ,
                 OriginalProjectCost ,
                 OriginalDebt ,
                 Debt_EquityRatio ,
                 ChangeinProjectScope ,
                 FreshOriginalDCCO ,
                 RevisedDCCO ,
                 CourtCaseArbitration ,
                 CIOReferenceDate ,
                 CIODCCO ,
                 TakeOutFinance ,
                 AssetClassSellerBookAlt_key ,
                 NPADateSellerBook ,
                 Restructuring ,
                 InitialExtension ,
                 BeyonControlofPromoters ,
                 DelayReasonOther ,
                 FLG_UPG ,
                 FLG_DEG ,
                 DEFAULT_REASON ,
                 ProjCategory ,
                 NPA_DATE ,
                 PUI_ProvPer ,
                 RestructureDate ,
                 ActualDCCO ,
                 ActualDCCO_Date ,
                 UpgradeDate ,
                 FinalAssetClassAlt_Key ,
                 DPD_Max ,
                 EffectiveFromTimeKey ,
                 49999 EffectiveToTimeKey  
          FROM MAIN_PRO.PUI_CAL T
           WHERE  NVL(T.IsChanged, 'N') IN ( 'C','N' )
         );/*  END OF PUI  DATA MERGE */

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."CUSTACCTCALHISTMERGE" TO "ADF_CDR_RBL_STGDB";
