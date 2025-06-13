--------------------------------------------------------
--  DDL for Procedure RPT_042_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_042_04122023" 
AS
   ----------Host RF NPA Report----
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_HostDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) 
     FROM DUAL  );
   --(C.flgdeg='Y' OR c.InitialNpaDt<>c.FinalNpaDt ) AND A.AssetClassAlt_Key<>C.FinalAssetClassAlt_Key 
   v_cursor SYS_REFCURSOR;

BEGIN


   BEGIN
      OPEN  v_cursor FOR
         SELECT v_Date CriSMacReportDate  ,
                v_HostDate HostSystemReportDate  ,
                D.UCIF_ID UCICNO  ,
                D.CustomerID CIFNO  ,
                B.CustomerACID AccountNo  ,
                D.CustomerName BorrowerName  ,
                H.SourceName ,
                I.AcBuSegmentDescription BusinessSegment  ,
                C.DPD_Max AccountDPD  ,
                C.REFPeriodMax NPANorm  ,
                A.PrincipalBalance PrincipleBalanceCrisMac  ,
                A.PrincipalBalance PrincipleBalanceHost  ,
                A.SourceNpaDate HostSystemNPADate  ,
                --,G.SourceNpaDate as CIFLevelHostSystemNPADAte,
                C.FinalNPADt CrisMacNPADt  ,
                A.SourceAssetClass HostAssetClass  ,
                --,G.SourceAssetClass as CIFLevelAssetClass,
                F.SrcSysClassCode CrisMacAssetCLass  
           FROM AdvAcBalanceDetail A
                  JOIN AdvAcBasicDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey )
                  AND ( A.EffectiveFromTimeKey <= v_TimeKey
                  AND A.EffectiveToTimeKey >= v_TimeKey )
                  AND A.accountentityid = B.accountentityid
                  JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
                  AND C.EffectiveToTimeKey >= v_TimeKey )
                  AND A.accountentityid = C.accountentityid
                  JOIN CustomerBasicDetail D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
                  AND D.EffectiveToTimeKey >= v_TimeKey )
                  AND D.customerid = B.RefcustomerID
                  JOIN AdvCustOtherDetail G   ON ( G.EffectiveFromTimeKey <= v_TimeKey
                  AND G.EffectiveToTimeKey >= v_TimeKey )
                  AND G.RefcustomerID = D.CUstomerID
                  JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL E   ON ( E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey )
                  AND E.customerEntityID = C.CustomerEntityID
                  JOIN DimAssetClass F   ON ( F.EffectiveFromTimeKey <= v_TimeKey
                  AND F.EffectiveToTimeKey >= v_TimeKey )
                  AND F.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
                  JOIN DIMSOURCEDB H   ON ( H.EffectiveFromTimeKey <= v_TimeKey
                  AND H.EffectiveToTimeKey >= v_TimeKey )
                  AND H.sourceAlt_Key = B.SourceAlt_Key
                  JOIN DimAcBuSegment I   ON ( I.EffectiveFromTimeKey <= v_TimeKey
                  AND I.EffectiveToTimeKey >= v_TimeKey )
                  AND I.AcBuSegmentCode = B.segmentcode
                --Below join is added by Swati

                  JOIN DimAssetClassMapping J   ON ( J.EffectiveFromTimeKey <= v_TimeKey
                  AND J.EffectiveToTimeKey >= v_TimeKey )
                  AND A.SourceAssetClass = J.SrcSysClassCode
                  AND B.SourceAlt_Key = j.SourceAlt_Key
          WHERE  ( C.InitialAssetClassAlt_Key = 1
                   AND C.FinalAssetClassAlt_Key > 1 )
                   OR ( J.AssetClassAlt_Key = 1
                   AND C.FinalAssetClassAlt_Key > 1 )
                   OR ( C.InitialAssetClassAlt_Key > 1
                   AND C.FinalAssetClassAlt_Key > 1
                   AND NVL(C.InitialNpaDt, ' ') <> NVL(C.FinalNpaDt, ' ') )
         UNION 
         SELECT v_Date CriSMacReportDate  ,
                v_HostDate HostSystemReportDate  ,
                D.UCIF_ID UCICNO  ,
                D.CustomerID CIFNO  ,
                B.CustomerACID AccountNo  ,
                D.CustomerName BorrowerName  ,
                H.SourceName ,
                I.AcBuSegmentDescription BusinessSegment  ,
                C.DPD_Max AccountDPD  ,
                C.REFPeriodMax NPANorm  ,
                A.PrincipalBalance PrincipleBalanceCrisMac  ,
                A.PrincipalBalance PrincipleBalanceHost  ,
                A.SourceNpaDate HostSystemNPADate  ,
                --,G.SourceNpaDate as CIFLevelHostSystemNPADAte,
                C.FinalNPADt CrisMacNPADt  ,
                A.SourceAssetClass HostAssetClass  ,
                --,G.SourceAssetClass as CIFLevelAssetClass,
                F.SrcSysClassCode CrisMacAssetCLass  
           FROM AdvAcBalanceDetail A
                  JOIN AdvAcBasicDetail B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                  AND B.EffectiveToTimeKey >= v_TimeKey )
                  AND ( A.EffectiveFromTimeKey <= v_TimeKey
                  AND A.EffectiveToTimeKey >= v_TimeKey )
                  AND A.accountentityid = B.accountentityid
                  JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON ( C.EffectiveFromTimeKey <= v_TimeKey
                  AND C.EffectiveToTimeKey >= v_TimeKey )
                  AND A.accountentityid = C.accountentityid
                  JOIN CustomerBasicDetail D   ON ( D.EffectiveFromTimeKey <= v_TimeKey
                  AND D.EffectiveToTimeKey >= v_TimeKey )
                  AND D.customerid = B.RefcustomerID
                  JOIN AdvCustOtherDetail G   ON ( G.EffectiveFromTimeKey <= v_TimeKey
                  AND G.EffectiveToTimeKey >= v_TimeKey )
                  AND G.RefcustomerID = D.CUstomerID
                  JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL E   ON ( E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey )
                  AND E.customerEntityID = C.CustomerEntityID
                  JOIN DimAssetClass F   ON ( F.EffectiveFromTimeKey <= v_TimeKey
                  AND F.EffectiveToTimeKey >= v_TimeKey )
                  AND F.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
                  JOIN DIMSOURCEDB H   ON ( H.EffectiveFromTimeKey <= v_TimeKey
                  AND H.EffectiveToTimeKey >= v_TimeKey )
                  AND H.sourceAlt_Key = B.SourceAlt_Key
                  JOIN DimAcBuSegment I   ON ( I.EffectiveFromTimeKey <= v_TimeKey
                  AND I.EffectiveToTimeKey >= v_TimeKey )
                  AND I.AcBuSegmentCode = B.segmentcode
                --Below join is added by Swati

                  JOIN DimAssetClassMapping J   ON ( J.EffectiveFromTimeKey <= v_TimeKey
                  AND J.EffectiveToTimeKey >= v_TimeKey )
                  AND A.SourceAssetClass = J.SrcSysClassCode
                  AND B.SourceAlt_Key = j.SourceAlt_Key
          WHERE  ( C.InitialAssetClassAlt_Key > 1
                   AND C.FinalAssetClassAlt_Key = 1 )
                   OR ( J.AssetClassAlt_Key > 1
                   AND C.FinalAssetClassAlt_Key = 1 ) ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--C.flgUPG='Y' And A.SourceAssetClass='LOSS' and C.FinalAssetClassAlt_Key=1 
      --AND A.AssetClassAlt_Key<>C.FinalAssetClassAlt_Key 

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_042_04122023" TO "ADF_CDR_RBL_STGDB";
