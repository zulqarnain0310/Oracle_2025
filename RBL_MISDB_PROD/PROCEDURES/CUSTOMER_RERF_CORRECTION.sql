--------------------------------------------------------
--  DDL for Procedure CUSTOMER_RERF_CORRECTION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" 
AS

BEGIN

   --select * into   ReverseFeedDataInsertSync_Customer_30062022 
   --from			ReverseFeedDataInsertSync_Customer
   --Delete      A    
   --from        ReverseFeedDataInsertSync_Customer a
   --inner join 
   --(
   --select distinct CustomerID from ReverseFeedDataInsertSync_Customer
   --where ProcessDate='2022-06-30'
   --except 
   --select distinct CustomerID from ReverseFeedData
   --where DateofData='2022-06-30'
   --)b 
   --on    a.CustomerID=b.CustomerID
   --where a.ProcessDate='2022-06-30'
   --Update         a
   --set            a.RecipientEmailIDs=b.RecipientEmailIDs
   --from           AlertRecipient a
   --inner join     AlertRecipient_28062022 b
   --on             a.AlertId=b.AlertId
   --where		   a.AlertId=4
   --update AlertRecipient
   --set RecipientEmailIDs ='MohdFarhan.Ansari@rblbank.com,Sagar.Gaikwad2@rblbank.com,Kiran.Kumar@rblbank.com,Tushar.Patel@rblbank.com,Prachi.Katkar@rblbank.com,Ridhi.Shukla@rblbank.com,Jinal.Malde@rblbank.com,Ravi.Paul@rblbank.com,Abhinay.Asgaonkar@rblbank.com,Nikhil.Iyer2@rblbank.com,Amol.Parab@rblbank.com,Santosh.Kumar4@rblbank.com,Amol.Shinde@rblbank.com,Rajesh.Rao@rblbank.com,Kiran.Shejwal@rblbank.com,Srikanth.Bhaskarabhatta@rblbank.com,Amit.Pandit@rblbank.com,Vikrant.Roday@rblbank.com,Vijay.Avati2@rblbank.com,Robin.Daniel@rblbank.com,Rashmi.Shinde2@rblbank.com,Sreekanth.Narayana@rblbank.com,Neha.Dixit@rblbank.com,rbl.calypsosupport@rblbank.com,Vinit.Kadam@rblbank.com,Ralph.Vanbuerle@rblbank.com,Priyanka.Barai@rblbank.com,Ashish.Raul@rblbank.com,Nimish.Chindarkar@rblbank.com,Amit.Goel@rblbank.com,Vikram.Samant@rblbank.com,Raghuveer.Shanbhag@rblbank.com,Sunandita.Kanjilal@rblbank.com,Prashant1@rblbank.com,vivek4@rblbank.com,Priyanka.Patil@rblbank.com,vinod.patil1@rblbank.com,mallika.iyer@rblbank.com,dilip.dumbhare@rblbank.com,Pulkit.Dekhane@rblbank.com,Vijay.Rathod@rblbank.com,Tejesh.Pujari2@rblbank.com ,CRisMACENPAProjectTeam@rblbank.com'
   --where AlertId=4
   --Update AlertRecipient
   --set RecipientEmailIDs='Prashant1@rblbank.com,vivek4@rblbank.com'
   --where AlertId=4
   INSERT INTO ControlTable_DWHCount_Status
     VALUES ( '2022-07-10', 'Y', SYSDATE );--Drop Table ACL_format
   --Delete from Ucic_require
   --update SysDataMatrix  set MOC_Frozen='Y' Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N' 
   --Update  SysDataMatrix set MOC_Initialised='Y' where TimeKey=26479
   --select * from Automate_Advances where EXT_FLG='Y'
   --Update Automate_Advances SET EXT_FLG='N' where EXT_FLG='Y'
   --Update Automate_Advances SET EXT_FLG='Y' where Date='2022-07-04'
   --select * from Automate_Advances where EXT_FLG='Y'
   --select * into pro.CUSTOMERCAL_30062022 from pro.CUSTOMERCAL
   --select * into pro.ACCOUNTCAL_30062022 from pro.ACCOUNTCAL
   --select 36970-4679
   --Update AlertRecipient
   --set RecipientEmailIDs='Prashant1@rblbank.com,vivek4@rblbank.com'
   --where AlertId=4
   --update AlertRecipient
   --set RecipientEmailIDs='anirudha.mulay@rblbank.com,gajanan.kamalja@rblbank.com,prashant1@rblbank.com,nimish.chindarkar@rblbank.com,kiran.kumar@rblbank.com,ashish.raul@rblbank.com,sachin.joshi@rblbank.com,abdultharadara.azim@rblbank.com,santosh.kumar4@rblbank.com,dinesh.rai@rblbank.com,akhileshwar.tiwari2@rblbank.com,varun.bhondave@rblbank.com,akshay.ukarande@rblbank.com,mohini.jadhav@rblbank.com,manoj.chhabra@rblbank.com,RBL_MIS@rblbank.com,sag-mis@rblbank.com,vivek4@rblbank.com,ankita.magar2@rblbank.com,dilip.dumbhare@rblbank.com,mallika.iyer@rblbank.com,Pulkit.Dekhane@rblbank.com,Vijay.Rathod@rblbank.com,Tejesh.Pujari2@rblbank.com,abhishek.chandak@rblbank.com'
   --,Recipient_CC_EmailIDs='mukesh.pande@rblbank.com'
   --where AlertId=1
   --update AlertRecipient
   --set RecipientEmailIDs='prashant1@rblbank.com'
   --,Recipient_CC_EmailIDs=''
   --where AlertId=1
   --select * from AlertRecipient
   --update ganaseva_file_RERF
   --set k=''
   --where f='std'
   --update PostMOCTimeKey set Timekey=26479
   -- update  ExceptionFinalStatusType
   --set EffectiveToTimeKey=26478
   --where ACID='809003029823' and StatusType='Litigation'
   --update DimUserInfo
   --set UserLogged=0
   --where UserLoginID='20754'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."CUSTOMER_RERF_CORRECTION" TO "ADF_CDR_RBL_STGDB";
