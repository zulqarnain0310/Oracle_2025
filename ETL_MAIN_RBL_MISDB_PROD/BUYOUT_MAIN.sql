--------------------------------------------------------
--  DDL for Procedure BUYOUT_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" 
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
     FROM RBL_MISDB_PROD.AUTOMATE_ADVANCES 
    WHERE  EXT_FLG = 'Y';
   ----------For New Records
   MERGE INTO RBL_TEMPDB.TempBuyoutData A 
   USING (SELECT A.ROWID row_id, 'N'
   FROM RBL_TEMPDB.TempBuyoutData A 
    WHERE NOT EXISTS ( SELECT 1 
                       FROM RBL_MISDB_PROD.BuyoutUploadDetails B
                        WHERE  B.EffectiveToTimeKey = 49999
                                 AND B.CustomerAcID = A.RBL_Account_No
                                 AND A.SchemeCode = B.SchemeCode )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'N';
   MERGE INTO RBL_MISDB_PROD.BuyoutUploadDetails O
   USING (SELECT O.ROWID row_id, v_vEffectiveto
   FROM RBL_MISDB_PROD.BuyoutUploadDetails O
          JOIN RBL_TEMPDB.TempBuyoutData T   ON O.CustomerAcID = T.RBL_Account_No
          AND O.SchemeCode = T.SchemeCode
          AND O.EffectiveToTimeKey = 49999
          AND T.EffectiveToTimeKey = 49999 ) src
   ON ( O.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET O.EffectiveToTimeKey --,
                                 --O.DateModified=CONVERT(DATE,GETDATE(),103),
                                 --O.ModifiedBy='SSISUSER'
                                 = v_vEffectiveto;
   --WHERE 
   --(  
   --   ISNULL(O.BranchCode,0) <> ISNULL(T.BranchCode,0)
   --OR ISNULL(O.GLAlt_Key,0)<> ISNULL(T.GLAlt_Key,0)
   --OR ISNULL(O.ProductAlt_Key,0)<> ISNULL(T.ProductAlt_Key,0)
   --OR ISNULL(O.GLProductAlt_Key,0)<> ISNULL(T.GLProductAlt_Key,0)
   --OR ISNULL(O.FacilityType,0) <> ISNULL(T.FacilityType,0)
   --OR ISNULL(O.SubSectorAlt_Key,0)<> ISNULL(T.SubSectorAlt_Key,0)
   --OR ISNULL(O.ActivityAlt_Key,0)<> ISNULL(T.ActivityAlt_Key,0)
   --OR ISNULL(O.IndustryAlt_Key,0)<> ISNULL(T.IndustryAlt_Key,0)
   --OR ISNULL(O.SchemeAlt_Key,0)<> ISNULL(T.SchemeAlt_Key,0)
   --OR ISNULL(O.DistrictAlt_Key,0)<> ISNULL(T.DistrictAlt_Key,0)
   --OR ISNULL(O.AreaAlt_Key,0)<> ISNULL(T.AreaAlt_Key,0)
   --OR ISNULL(O.VillageAlt_Key,0)<> ISNULL(T.VillageAlt_Key,0)
   --OR ISNULL(O.StateAlt_Key,0)<> ISNULL(T.StateAlt_Key,0)
   --OR ISNULL(O.CurrencyAlt_Key,0)<> ISNULL(T.CurrencyAlt_Key,0)
   --OR ISNULL(O.OriginalSanctionAuthAlt_Key,0)<> ISNULL(T.OriginalSanctionAuthAlt_Key,0)
   --OR ISNULL(O.OriginalLimitRefNo,0) <> ISNULL(T.OriginalLimitRefNo,0)
   --OR ISNULL(O.OriginalLimit,0) <> ISNULL(T.OriginalLimit,0)
   --OR ISNULL(O.OriginalLimitDt,'1990-01-01') <> ISNULL(T.OriginalLimitDt,'1990-01-01')
   --OR ISNULL(O.DtofFirstDisb,'1990-01-01') <>  ISNULL(T.DtofFirstDisb,'1990-01-01')
   --OR ISNULL(O.AdjDt,'1990-01-01') <> ISNULL(T.AdjDt,'1990-01-01')
   --OR ISNULL(O.MarginType,0) <> ISNULL(T.MarginType,0)
   --OR ISNULL(O.CurrentLimitRefNo,0) <> ISNULL(T.CurrentLimitRefNo,0)
   --OR ISNULL(O.AccountName,0) <> ISNULL(T.AccountName,0)
   --OR ISNULL(O.LastDisbDt,'1990-01-01') <> ISNULL(T.LastDisbDt,'1990-01-01')
   --OR ISNULL(O.Ac_LADDt,'1990-01-01') <> ISNULL(T.Ac_LADDt,'1990-01-01')
   --OR ISNULL(O.Ac_DocumentDt,'1990-01-01') <> ISNULL(T.Ac_DocumentDt,'1990-01-01')
   --OR ISNULL(O.CurrentLimit,0) <> ISNULL(T.CurrentLimit,0)
   --OR ISNULL(O.InttTypeAlt_Key,0)<> ISNULL(T.InttTypeAlt_Key,0)
   --OR ISNULL(O.CurrentLimitDt,'1990-01-01') <> ISNULL(T.CurrentLimitDt,'1990-01-01')
   --OR ISNULL(O.Ac_DueDt,'1990-01-01') <> ISNULL(T.Ac_DueDt,'1990-01-01')
   --OR ISNULL(O.DrawingPowerAlt_Key,0) <> ISNULL(T.DrawingPowerAlt_Key,0)
   --OR ISNULL(O.RefCustomerId,'AA') <> ISNULL(T.RefCustomerId,'AA')
   --OR ISNULL(O.FincaleBasedIndustryAlt_key,0) <> ISNULL(T.FincaleBasedIndustryAlt_Key,0)
   --OR ISNULL(O.ISLAD,0) <> ISNULL(T.ISLAD,0)
   --OR ISNULL(O.ISLAD,0) <> ISNULL(T.ISLAD,0)
   --OR ISNULL(O.segmentcode,0) <> ISNULL(T.segmentcode,0)
   --OR ISNULL(O.ReferencePeriod,0) <> ISNULL(T.ReferencePeriod,0)
   --OR ISNULL(O.FlgSecured,0) <> ISNULL(T.FlgSecured,0)
   --)
   ----------For Changes Records
   MERGE INTO RBL_TEMPDB.TempBuyoutData A
   USING (SELECT A.ROWID row_id, 'C'
   FROM RBL_TEMPDB.TempBuyoutData A
          JOIN RBL_MISDB_PROD.BuyoutUploadDetails B   ON B.CustomerAcID = A.RBL_Account_No
          AND A.SchemeCode = B.SchemeCode 
    WHERE B.EffectiveToTimeKey = v_vEffectiveto) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.IsChanged
                                ----Select * 
                                 = 'C';
   ---------------------------------------------------------------------------------------------------------------
   ---------Expire the records
   --UPDATE AA
   --SET 
   -- EffectiveToTimeKey = @vEffectiveto--,
   -- --DateModified=CONVERT(DATE,GETDATE(),103),
   -- --ModifiedBy='SSISUSER' 
   --FROM [DBO].[BuyoutUploadDetails] AA
   --WHERE AA.EffectiveToTimeKey = 49999
   --AND NOT EXISTS (SELECT 1 FROM RBL_TEMPDB.[dbo].[TempBuyoutData] BB
   --    WHERE AA.CustomerAcID=BB.RBL_Account_No And AA.[SchemeCode]=BB.[SchemeCode]
   --    AND BB.EffectiveToTimeKey =49999
   --    )
   -------------------------------
   /*  New Customers Ac Key ID Update  */
   --DECLARE @Ac_Key BIGINT=0 
   --SELECT @Ac_Key=MAX(Ac_Key) FROM  RBL_MISDB.[PRO].[BuyoutUploadDetailsCal]
   --IF @Ac_Key IS NULL  
   --BEGIN
   --SET @Ac_Key=0
   --END
   --UPDATE TEMP 
   --SET TEMP.Ac_Key=ACCT.Ac_Key
   -- FROM RBL_TEMPDB.DBO.[TempAdvAcBasicDetail] TEMP
   --INNER JOIN (SELECT CustomerAcId,(@Ac_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Ac_Key
   --			FROM RBL_TEMPDB.DBO.[TempAdvAcBasicDetail]
   --			WHERE Ac_Key=0 OR Ac_Key IS NULL)ACCT ON TEMP.CustomerAcId=ACCT.CustomerAcId
   --Where Temp.IsChanged in ('N','C')
   /***************************************************************************************************************/
   /***************************************************************************************************************/
   INSERT INTO RBL_MISDB_PROD.BuyoutUploadDetails
     ( DateofData, ReportDate, CustomerAcID, SchemeCode, NPA_ClassSeller, NPA_DateSeller, DPD_Seller, PeakDPD, PeakDPD_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
     ( SELECT DateofData ,
              ReportDate ,
              RBL_Account_No ,
              SchemeCode ,
              NPA_ClassSeller ,
              NPA_DateSeller ,
              DPD_Seller ,
              PeakDPD ,
              PeakDPD_Date ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              'SSISUSER' CreatedBy  ,
              SYSDATE DateCreated  
       FROM RBL_TEMPDB.TempBuyoutData T
        WHERE  NVL(T.IsChanged, 'U') IN ( 'N','C' )
      );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "MAIN_PRO";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "MAIN_PRO";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "RBL_TEMPDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "ETL_MAIN_RBL_MISDB_PROD"."BUYOUT_MAIN" TO "ADF_CDR_RBL_STGDB";
