--------------------------------------------------------
--  DDL for Procedure MOC_CHANGEDETAILS_CORRECTIONS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" 
AS

BEGIN

   --SELECT DISTINCT [CIF ID] CIFID INTO #TEMP546 FROM security_4
   --select  CIFID, UcifEntityID,RefCustomerID,CustomerEntityID into #temp12354 from pro.CUSTOMERCAL_hist a
   --inner join     #TEMP546 b
   --on             a.RefCustomerID=b.CIFID
   --where  EffectiveFromTimeKey <=26388 and EffectiveToTimeKey >=26388
   --select b.*,a.*  from MOC_ChangeDetails a
   --inner join     #temp12354 b
   --on            a.CustomerEntityID=b.CustomerEntityID
   --where        MOC_Date='2022-03-31'
   --and			AssetClassAlt_Key is not null
   --AND RefCustomerID<>'10937698' 
   --AND MOCTYPE='AUTO'
   --select b.*,a.*  from MOC_ChangeDetails a
   --inner join     #temp12354 b
   --on            a.CustomerEntityID=b.CustomerEntityID
   --where        MOC_Date='2022-03-31'
   --and			AssetClassAlt_Key=3
   --AND RefCustomerID='10937698' 
   --AND MOCTYPE='AUTO' 
   /*
   --select b.*,a.*
   Update         a
   set            EffectiveToTimeKey=49999
   from           MOC_ChangeDetails a
   inner join     #temp12354 b
   on            a.CustomerEntityID=b.CustomerEntityID
   where        MOC_Date='2022-03-31'
   and			AssetClassAlt_Key is not null
   AND RefCustomerID<>'10937698' 
   AND MOCTYPE='AUTO'


   --select b.*,a.* 
   Update         a
   set            EffectiveToTimeKey=49999
   from		 MOC_ChangeDetails a
   inner join   #temp12354 b
   on           a.CustomerEntityID=b.CustomerEntityID
   where        MOC_Date='2022-03-31'
   and			AssetClassAlt_Key=3
   AND			RefCustomerID='10937698' 
   AND			MOCTYPE='AUTO' 
   */
   --update  MOC_ChangeDetails 
   --set EffectiveToTimeKey=26407
   --where CustomerEntityID in (1332432,1409031)
   --and EffectiveToTimeKey=49999
   --Update        a
   --set           a.FinalNpaDt=convert(date,[Exisitng NPA Date],105)
   --from		  pro.ACCOUNTCAL a
   --inner join    npa_date_correction b
   --on            a.UCIF_ID=b.UCIC
   --Update        a
   --set           a.SysNPA_Dt=convert(date,[Exisitng NPA Date],105)
   --from		  pro.CUSTOMERCAL a
   --inner join    npa_date_correction b
   --on            a.UCIF_ID=b.UCIC
   --update pro.CUSTOMERCAL
   --set SysAssetClassAlt_Key=6
   --where UCIF_ID in ('RBL008490873','RBL010261155')
   --update pro.ACCOUNTCAL
   --set FinalAssetClassAlt_Key=6
   --where UCIF_ID in ('RBL008490873','RBL010261155')
   --Update        a
   --set           a.FinalNpaDt=convert(date,[NPA Date],105)
   --from		  pro.ACCOUNTCAL a
   --inner join    [NPA Date updatetion 1] b
   --on            a.UCIF_ID=b.UCIC
   --Update        a
   --set           a.SysNPA_Dt=convert(date,[NPA Date],105)
   --from		  pro.CUSTOMERCAL a
   --inner join    [NPA Date updatetion 1] b
   --on            a.UCIF_ID=b.UCIC
   -- update AdvAcPUIDetailSub
   --set AccountEntityId=2242384
   --where CustomerID in ('20102016')
   -- update AdvAcPUIDetailSub
   --set  AccountEntityId=2182753
   --where CustomerID in ('203005194')
   --Update       a
   --set          a.SourceNpaDate=b.NPA_Date
   --from		 curdat.AdvCustOtherDetail a
   --inner join    DWH_STG.dwh.customer_data b
   --on            a.RefCustomerId=b.Customer_ID
   --where         a.SourceNpaDate is  null
   --Update       a
   --set          a.SourceNpaDate=b.NPA_Date
   --from		 curdat.AdvCustOtherDetail a
   --inner join    DWH_STG.dwh.customer_data_finacle b
   --on            a.RefCustomerId=b.Customer_ID
   --where         a.SourceNpaDate is  null
   --select * into ReverseFeedDataInsertSync_Customer_01072022 from ReverseFeedDataInsertSync_Customer
   --Truncate table ReverseFeedDataInsertSync_Customer
   --SELECT * FROM Automate_Advances WHERE EXT_FLG='Y'
   DELETE FROM AdvSecurityDetail_02072022;
   UTILS.IDENTITY_RESET('AdvSecurityDetail_02072022');

   INSERT INTO AdvSecurityDetail_02072022 SELECT * 
        FROM AdvSecurityDetail 
       WHERE  EffectiveFromTimeKey = 26479;
   DELETE FROM AdvSecurityValueDetail_02072022;
   UTILS.IDENTITY_RESET('AdvSecurityValueDetail_02072022');

   INSERT INTO AdvSecurityValueDetail_02072022 SELECT * 
        FROM AdvSecurityValueDetail 
       WHERE  EffectiveFromTimeKey = 26479;
   DELETE AdvSecurityDetail

    WHERE  EffectiveFromTimeKey = 26479;
   UPDATE AdvSecurityDetail
      SET EffectiveToTimekey = 49999
    WHERE  EffectiveToTimeKey = 26478;
   DELETE AdvSecurityValueDetail

    WHERE  EffectiveFromTimeKey = 26479;
   UPDATE AdvSecurityValueDetail
      SET EffectiveToTimekey = 49999
    WHERE  EffectiveToTimeKey = 26478;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOC_CHANGEDETAILS_CORRECTIONS" TO "ADF_CDR_RBL_STGDB";
