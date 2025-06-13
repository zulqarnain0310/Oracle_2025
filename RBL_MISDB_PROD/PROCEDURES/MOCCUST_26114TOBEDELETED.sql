--------------------------------------------------------
--  DDL for Procedure MOCCUST_26114TOBEDELETED
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" 
AS

BEGIN

   DELETE FROM tt_A_24;
   UTILS.IDENTITY_RESET('tt_A_24');

   INSERT INTO tt_A_24 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
   	 WHERE  EffectivefromTimeKey = 26115
              AND EffectiveToTimeKey = 26115
              AND RefCustomerID = '0211101762500000330' );
   UPDATE tt_A_24
      SET EffectiveFromTimeKey = 26114,
          EffectiveToTimeKey = 26114;
   INSERT INTO PRO_RBL_MISDB_PROD.CustomerCal_Hist
     ( BranchCode, UCIF_ID, UcifEntityID, CustomerEntityID, ParentCustomerID, RefCustomerID, SourceSystemCustomerID, CustomerName, CustSegmentCode, ConstitutionAlt_Key, PANNO, AadharCardNO, SrcAssetClassAlt_Key, SysAssetClassAlt_Key, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SMA_Class_Key, PNPA_Class_Key, PrvQtrRV, CurntQtrRv, TotProvision, BankTotProvision, RBITotProvision, SrcNPA_Dt, SysNPA_Dt, DbtDt, DbtDt2, DbtDt3, LossDt, MOC_Dt, ErosionDt, SMA_Dt, PNPA_Dt, Asset_Norm, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, DegDate, EffectiveFromTimeKey, EffectiveToTimeKey, CommonMocTypeAlt_Key, InMonthMark, MocStatusMark, SourceAlt_Key, BankAssetClass, Cust_Expo, MOCReason, AddlProvisionPer, FraudDt, FraudAmount, DegReason, CustMoveDescription, TotOsCust, MOCTYPE, ScreenFlag, ChangeFld )
     ( SELECT BranchCode ,
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
              EffectiveToTimeKey ,
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
              MOCTYPE ,
              ScreenFlag ,
              ChangeFld 
       FROM tt_A_24  );
   -----------------Revert Query
   DELETE PRO_RBL_MISDB_PROD.CustomerCal_Hist

    WHERE  EffectiveFromTimeKey = 26114
             AND EffectiveToTimeKey = 26114;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCCUST_26114TOBEDELETED" TO "ADF_CDR_RBL_STGDB";
