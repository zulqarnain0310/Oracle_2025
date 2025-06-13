--------------------------------------------------------
--  DDL for Procedure HOSTSYSTEMSTATUSNEW_FIS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" 
--EXEC HostSystemStatusNew_FIS 1

(
  v_Assetclass IN NUMBER
)
AS
   v_Date VARCHAR2(200) := ( SELECT utils.dateadd('DAY', -1, Date_) 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_TimeKey NUMBER(10,0) := ( SELECT timekey 
     FROM Automate_Advances 
    WHERE  date_ = v_date );
   v_cursor SYS_REFCURSOR;

BEGIN

   IF v_Assetclass = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT A.UCIF_ID UCIC_Code  ,
                A.RefCustomerID CustomerID  ,
                A.CustomerName ,
                b.CustomerAcid AccountNo  ,
                c.SourceName Host_System_Name  ,
                SignBalance OSBalance  ,
                UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
                B.ActSegmentCode ,
                CASE 
                     WHEN c.SourceName = 'FIS' THEN 'FI'
                     WHEN c.SourceName = 'VisionPlus' THEN 'Credit Card'
                ELSE S.AcBuRevisedSegmentCode
                   END Account_Level_Business_Segment  ,
                --AcBuSegmentDescription [Business Seg Desc]
                'FI' Business_Seg_Desc  ,
                b.ProductCode Base_Account_Scheme_Code  ,
                SMA_Class CrisMac_System_Status  ,
                tbl.Main_Classification Host_System_Status  ,
                tbl.Remarks Remarks  ,
                tbl.Closed_Date Closed_Date  ,
                (CASE 
                      WHEN SignBalance > 0 THEN 'Dr'
                ELSE 'Cr'
                   END) Cr_Dr  
           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                  JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
                  JOIN AdvAcBalanceDetail D   ON B.AccountEntityID = D.AccountEntityId

                  --and D.EffectiveToTimeKey = 49999
                  AND D.EffectiveFromTimeKey <= v_TimeKey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  JOIN ReverseFeedDataInsertSync C   ON B.CustomerAcID = C.CustomerAcID
                  JOIN ENPA_Host_System_Status_tbl_FIS tbl   ON C.CustomerAcID = tbl.Account_No
                  AND UTILS.CONVERT_TO_VARCHAR2(c.ProcessDate,200) = UTILS.CONVERT_TO_VARCHAR2(tbl.Report_Date,200)
                  LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
                  LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
                  AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
                  LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
                  AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
                  LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
                  AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
                  LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
                  AND S.EffectiveToTimeKey = 49999
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_TimeKey
                   AND UTILS.CONVERT_TO_VARCHAR2(Report_Date,200) = v_Date
                   AND C.FinalAssetClassAlt_Key > 1
                   AND B.SourceAlt_Key = 5 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT A.UCIF_ID UCIC_Code  ,
                A.RefCustomerID CustomerID  ,
                A.CustomerName ,
                b.CustomerAcid AccountNo  ,
                c.SourceName Host_System_Name  ,
                SignBalance OSBalance  ,
                UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
                B.ActSegmentCode ,
                CASE 
                     WHEN c.SourceName = 'FIS' THEN 'FI'
                     WHEN c.SourceName = 'VisionPlus' THEN 'Credit Card'
                ELSE S.AcBuRevisedSegmentCode
                   END Account_Level_Business_Segment  ,
                --AcBuSegmentDescription [Business Seg Desc]
                'FI' Business_Seg_Desc  ,
                b.ProductCode Base_Account_Scheme_Code  ,
                SMA_Class CrisMac_System_Status  ,
                tbl.Main_Classification Host_System_Status  ,
                tbl.Remarks Remarks  ,
                tbl.Closed_Date Closed_Date  ,
                (CASE 
                      WHEN SignBalance > 0 THEN 'Dr'
                ELSE 'Cr'
                   END) Cr_Dr  
           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                  JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
                  JOIN AdvAcBalanceDetail D   ON B.AccountEntityID = D.AccountEntityId

                  --and D.EffectiveToTimeKey = 49999
                  AND D.EffectiveFromTimeKey <= v_TimeKey
                  AND D.EffectiveToTimeKey >= v_TimeKey
                  JOIN ReverseFeedDataInsertSync C   ON B.CustomerAcID = C.CustomerAcID
                  JOIN ENPA_Host_System_Status_tbl_FIS tbl   ON C.CustomerAcID = tbl.Account_No
                  AND UTILS.CONVERT_TO_VARCHAR2(c.ProcessDate,200) = UTILS.CONVERT_TO_VARCHAR2(tbl.Report_Date,200)
                  LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
                  LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
                  AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
                  LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
                  AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
                  LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
                  AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
                  LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
                  AND S.EffectiveToTimeKey = 49999
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_TimeKey
                   AND B.EffectiveFromTimeKey <= v_Timekey
                   AND B.EffectiveToTimeKey >= v_TimeKey
                   AND UTILS.CONVERT_TO_VARCHAR2(Report_Date,200) = v_Date
                   AND C.FinalAssetClassAlt_Key = 1
                   AND B.SourceAlt_Key = 5 ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."HOSTSYSTEMSTATUSNEW_FIS" TO "ADF_CDR_RBL_STGDB";
