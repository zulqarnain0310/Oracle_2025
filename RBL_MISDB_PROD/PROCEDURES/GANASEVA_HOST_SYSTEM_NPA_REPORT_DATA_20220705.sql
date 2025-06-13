--------------------------------------------------------
--  DDL for Procedure GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" 
AS
   -- SET NOCOUNT ON added to prevent extra result sets from    
   -- interfering with SELECT statements.    
   v_TIMEKEY NUMBER(10,0) := ( SELECT TIMEKEY 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_EXT_DATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM Automate_Advances 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_cursor SYS_REFCURSOR;

BEGIN

   -------------------------------------------------------------------------------------------------------------------------------------------------  
   ----ALL ENPA ACCOUNT AS PER CRISMAC ENPA REPORT  
   OPEN  v_cursor FOR
      SELECT v_EXT_DATE CRisMac_Report_Date  ,
             SYSDATE Host_System_Report_Date  ,
             A.UCIF_ID UCIC_ID  ,
             A.RefCustomerID CustomerID  ,
             B.CustomerAcID AccountID  ,
             C.SourceName Host_System_Name  ,
             B.DPD_Max Account_DPD  ,
             B.REFPeriodMax NPA_Norm  ,
             B.ActSegmentCode Business_Segment  ,
             B.PrincOutStd Principal_OS_CRisMac  ,
             E.PrincipalBalance Principal_OS_Host  ,
             B.InitialNpaDt Host_System_NPA_Date  ,
             A.SrcNPA_Dt Host_System_NPA_Date_CIF_Level  ,
             B.FinalNpaDt CRisMac_NPA_Date  ,
             B.FinalAssetClassAlt_Key Host_System_Asset_Classification  
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL B
               JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL A   ON A.CustomerEntityID = B.CustomerEntityID
               AND A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey
               AND NVL(b.WriteOffAmount, 0) = 0
               JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
               AND ( C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey )
               AND C.SourceAlt_Key = 5
               JOIN AdvAcBalanceDetail E   ON E.ACCOUNTENTITYID = B.AccountEntityID
               AND ( E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey )
               JOIN DimAssetClass F   ON F.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
               AND ( F.EffectiveFromTimeKey <= v_TimeKey
               AND F.EffectiveToTimeKey >= v_TimeKey )
       WHERE
      --EXISTS (SELECT 1 FROM REVERSEFEEDDATA G WHERE B.RefCustomerID=G.CustomerID AND G.DateofData=@EXT_DATE AND G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )   
       --AND     
        B.EffectiveFromTimeKey <= v_TimeKey
          AND B.EffectiveToTimeKey >= v_TimeKey
          AND B.FinalAssetClassAlt_Key <> 1
      UNION 
      SELECT v_EXT_DATE CRisMac_Report_Date  ,
             SYSDATE Host_System_Report_Date  ,
             A.UCIF_ID UCIC_ID  ,
             A.RefCustomerID CustomerID  ,
             B.CustomerAcID AccountID  ,
             C.SourceName Host_System_Name  ,
             B.DPD_Max Account_DPD  ,
             B.REFPeriodMax NPA_Norm  ,
             B.ActSegmentCode Business_Segment  ,
             B.PrincOutStd Principal_OS_CRisMac  ,
             E.PrincipalBalance Principal_OS_Host  ,
             B.InitialNpaDt Host_System_NPA_Date  ,
             A.SrcNPA_Dt Host_System_NPA_Date_CIF_Level  ,
             B.FinalNpaDt CRisMac_NPA_Date  ,
             B.FinalAssetClassAlt_Key Host_System_Asset_Classification  
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL B
               JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL A   ON A.CustomerEntityID = B.CustomerEntityID
               AND A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey
               AND NVL(b.WriteOffAmount, 0) = 0
               JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
               AND ( C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey )
               AND C.SourceAlt_Key = 5
               JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.ACCOUNTENTITYID = B.AccountEntityID
               AND ( E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey )
               JOIN DimAssetClass F   ON F.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
               AND ( F.EffectiveFromTimeKey <= v_TimeKey
               AND F.EffectiveToTimeKey >= v_TimeKey )
               JOIN DimAssetClassMapping G   ON E.SourceAssetClass = G.SrcSysClassCode
       WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                AND B.FinalAssetClassAlt_Key = 1 --AND E.SourceAssetClass not in ('STD','Standard')  

                AND NVL(b.WriteOffAmount, 0) = 0
                AND G.AssetClassAlt_Key > 1
      UNION 
      SELECT v_EXT_DATE CRisMac_Report_Date  ,
             SYSDATE Host_System_Report_Date  ,
             A.UCIF_ID UCIC_ID  ,
             A.RefCustomerID CustomerID  ,
             B.CustomerAcID AccountID  ,
             C.SourceName Host_System_Name  ,
             B.DPD_Max Account_DPD  ,
             B.REFPeriodMax NPA_Norm  ,
             B.ActSegmentCode Business_Segment  ,
             B.PrincOutStd Principal_OS_CRisMac  ,
             G.PrincipalBalance Principal_OS_Host  ,
             B.InitialNpaDt Host_System_NPA_Date  ,
             A.SrcNPA_Dt Host_System_NPA_Date_CIF_Level  ,
             B.FinalNpaDt CRisMac_NPA_Date  ,
             B.FinalAssetClassAlt_Key Host_System_Asset_Classification  
        FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL B
               JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL A   ON A.CustomerEntityID = B.CustomerEntityID
               AND A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey
               AND NVL(b.WriteOffAmount, 0) = 0
               JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
               AND ( C.EffectiveFromTimeKey <= v_TimeKey
               AND C.EffectiveToTimeKey >= v_TimeKey )
               AND C.SourceAlt_Key = 5
               JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail E   ON E.CustomerEntityId = A.CustomerEntityID
               AND ( E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey )
               JOIN DimAssetClass F   ON F.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
               AND ( F.EffectiveFromTimeKey <= v_TimeKey
               AND F.EffectiveToTimeKey >= v_TimeKey )
               LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail G   ON A.RefCustomerID = G.RefCustomerId
               AND ( G.EffectiveFromTimeKey <= v_TimeKey
               AND G.EffectiveToTimeKey >= v_TimeKey )
               JOIN DimAssetClassMapping_Customer H   ON H.AssetClassShortName = E.SourceAssetClass
               AND H.SourceAlt_Key = 5
       WHERE  NVL(B.WriteOffAmount, 0) = 0
                AND B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey
                AND A.SysAssetClassAlt_Key = 1
                AND H.AssetClassAlt_Key <> 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_20220705" TO "ADF_CDR_RBL_STGDB";
