--------------------------------------------------------
--  DDL for Procedure GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" 
AS
   v_TIMEKEY NUMBER(10,0) := ( SELECT TIMEKEY 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_EXT_DATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM Automate_Advances 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN

      BEGIN
         --SQL Server BEGIN TRANSACTION;
         utils.incrementTrancount;
         -----------------------------------------------------------------------------------------------------------------------------------------------    
         --ALL ENPA ACCOUNT AS PER CRISMAC ENPA REPORT    
         --SELECT 'ALL ENPA ACCOUNT AS PER CRISMAC ENPA REPORT'  
         TABLE IF  --SQLDEV: NOT RECOGNIZED
         IF tt_TEMP_17  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_TEMP_17;
         UTILS.IDENTITY_RESET('tt_TEMP_17');

         INSERT INTO tt_TEMP_17 ( 
         	SELECT * 
         	  FROM ( SELECT v_EXT_DATE CRisMac_Report_Date  ,
                          UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) Host_System_Report_Date  ,
                          A.UCIF_ID UCIC_ID  ,
                          A.RefCustomerID CustomerID  ,
                          B.CustomerAcID AccountID  ,
                          A.CustomerName BorroweName  ,
                          C.SourceName Host_System_Name  ,
                          B.DPD_Max Account_DPD  ,
                          B.RefPeriodOverdue NPA_Norm  ,
                          CASE 
                               WHEN SourceName = 'FIS' THEN 'FI'
                          ELSE AcBuRevisedSegmentCode
                             END Business_Segment  ,
                          B.PrincOutStd Principal_OS_CRisMac  ,
                          E.PrincipalBalance Principal_OS_Host  ,
                          E.SourceNpaDate Host_System_NPA_Date  ,
                          Z.SourceNpaDate Host_System_NPA_Date_CIF_Level  ,
                          B.FinalNpaDt CRisMac_NPA_Date  ,
                          E.SourceAssetClass Host_System_ACL_Account_Level  ,
                          Z.SourceAssetClass Host_System_ACL_CIF_LeveL  ,
                          B.FinalAssetClassAlt_Key CRisMac_Asset_Classification  ,
                          1 STATUS  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL B
                          JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL A   ON A.CustomerEntityID = B.CustomerEntityID
                          AND A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND NVL(b.WriteOffAmount, 0) = 0
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                          AND ( C.EffectiveFromTimeKey <= v_TimeKey
                          AND C.EffectiveToTimeKey >= v_TimeKey )
                          AND C.SourceAlt_Key = ( SELECT SourceAlt_Key 
                                                  FROM DIMSOURCEDB 
                                                   WHERE  SourceName = 'FIS'
                                                            AND EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.ACCOUNTENTITYID = B.AccountEntityID
                          AND ( E.EffectiveFromTimeKey <= v_TimeKey
                          AND E.EffectiveToTimeKey >= v_TimeKey )
                          JOIN DimAssetClass F   ON F.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
                          AND ( F.EffectiveFromTimeKey <= v_TimeKey
                          AND F.EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail Z   ON A.RefCustomerID = Z.RefCustomerID
                          AND ( Z.EffectiveFromTimeKey <= v_TimeKey
                          AND Z.EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN DimAcBuSegment DS   ON DS.AcBuSegmentCode = B.ActSegmentCode
                          AND ( DS.EffectiveFromTimeKey <= v_TimeKey
                          AND DS.EffectiveToTimeKey >= v_TimeKey )
                    WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             AND B.FinalAssetClassAlt_Key > 1
                   UNION 

                   ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    

                   --ALL ACCOUNTS WHICH ARE STAMPED NPA IN HOST ACCOUNT BUT NOT NPA/TWO IN CRISMAC ACCOUNT (ACCOUNT WISE)    
                   SELECT v_EXT_DATE CRisMac_Report_Date  ,
                          UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) Host_System_Report_Date  ,
                          A.UCIF_ID UCIC_ID  ,
                          A.RefCustomerID CustomerID  ,
                          B.CustomerAcID AccountID  ,
                          A.CustomerName BorroweName  ,
                          C.SourceName Host_System_Name  ,
                          B.DPD_Max Account_DPD  ,
                          B.RefPeriodOverdue NPA_Norm  ,
                          CASE 
                               WHEN SourceName = 'FIS' THEN 'FI'
                          ELSE AcBuRevisedSegmentCode
                             END Business_Segment  ,
                          B.PrincOutStd Principal_OS_CRisMac  ,
                          E.PrincipalBalance Principal_OS_Host  ,
                          E.SourceNpaDate Host_System_NPA_Date  ,
                          Z.SourceNpaDate Host_System_NPA_Date_CIF_Level  ,
                          B.FinalNpaDt CRisMac_NPA_Date  ,
                          E.SourceAssetClass Host_System_ACL_Account_Level  ,
                          Z.SourceAssetClass Host_System_ACL_CIF_LeveL  ,
                          B.FinalAssetClassAlt_Key CRisMac_Asset_Classification  ,
                          2 STATUS  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL B
                          JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL A   ON A.CustomerEntityID = B.CustomerEntityID
                          AND A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND NVL(b.WriteOffAmount, 0) = 0
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                          AND ( C.EffectiveFromTimeKey <= v_TimeKey
                          AND C.EffectiveToTimeKey >= v_TimeKey )
                          AND C.SourceAlt_Key = ( SELECT SourceAlt_Key 
                                                  FROM DIMSOURCEDB 
                                                   WHERE  SourceName = 'FIS'
                                                            AND EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.ACCOUNTENTITYID = B.AccountEntityID
                          AND ( E.EffectiveFromTimeKey <= v_TimeKey
                          AND E.EffectiveToTimeKey >= v_TimeKey )
                          JOIN DimAssetClass F   ON F.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
                          AND ( F.EffectiveFromTimeKey <= v_TimeKey
                          AND F.EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail Z   ON A.RefCustomerID = Z.RefCustomerID
                          AND ( Z.EffectiveFromTimeKey <= v_TimeKey
                          AND Z.EffectiveToTimeKey >= v_TimeKey )
                          JOIN DimAssetClassMapping G   ON E.SourceAssetClass = G.SrcSysClassCode
                          AND G.SourceAlt_Key = 5
                          AND G.SourceAlt_Key = C.SourceAlt_Key
                          JOIN DimAssetClassMapping_Customer H   ON H.AssetClassShortName = Z.SourceAssetClass
                          AND H.SourceAlt_Key = 5
                          AND H.SourceAlt_Key = C.SourceAlt_Key
                          LEFT JOIN DimAcBuSegment DS   ON DS.AcBuSegmentCode = B.ActSegmentCode
                          AND ( DS.EffectiveFromTimeKey <= v_TimeKey
                          AND DS.EffectiveToTimeKey >= v_TimeKey )
                    WHERE  B.FinalAssetClassAlt_Key = 1
                             AND G.AssetClassAlt_Key > 1
                   UNION 

                   ------------------------------------------------------------------------------------------------------------------------------------------------------------    

                   --'ALL ACCOUNTS WHICH ARE STAMPED NPA IN HOST ACCOUNT BUT NOT NPA/TWO IN CRISMAC ACCOUNT (CUSTOMER WISE)'     
                   SELECT v_EXT_DATE CRisMac_Report_Date  ,
                          UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) Host_System_Report_Date  ,
                          A.UCIF_ID UCIC_ID  ,
                          A.RefCustomerID CustomerID  ,
                          B.CustomerAcID AccountID  ,
                          A.CustomerName BorroweName  ,
                          C.SourceName Host_System_Name  ,
                          B.DPD_Max Account_DPD  ,
                          B.RefPeriodOverdue NPA_Norm  ,
                          CASE 
                               WHEN SourceName = 'FIS' THEN 'FI'
                          ELSE AcBuRevisedSegmentCode
                             END Business_Segment  ,
                          B.PrincOutStd Principal_OS_CRisMac  ,
                          E.PrincipalBalance Principal_OS_Host  ,
                          E.SourceNpaDate Host_System_NPA_Date  ,
                          F.SourceNpaDate Host_System_NPA_Date_CIF_Level  ,
                          B.FinalNpaDt CRisMac_NPA_Date  ,
                          E.SourceAssetClass Host_System_ACL_Account_Level  ,
                          F.SourceAssetClass Host_System_ACL_CIF_LeveL  ,
                          B.FinalAssetClassAlt_Key CRisMac_Asset_Classification  ,
                          3 STATUS  
                   FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL B
                          JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL A   ON A.CustomerEntityID = B.CustomerEntityID
                          AND A.EffectiveFromTimeKey <= v_TimeKey
                          AND A.EffectiveToTimeKey >= v_TimeKey
                          AND NVL(b.WriteOffAmount, 0) = 0
                          AND B.EffectiveFromTimeKey <= v_TimeKey
                          AND B.EffectiveToTimeKey >= v_TimeKey
                          JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SourceAlt_Key
                          AND ( C.EffectiveFromTimeKey <= v_TimeKey
                          AND C.EffectiveToTimeKey >= v_TimeKey )
                          AND C.SourceAlt_Key = ( SELECT SourceAlt_Key 
                                                  FROM DIMSOURCEDB 
                                                   WHERE  SourceName = 'FIS'
                                                            AND EffectiveFromTimeKey <= v_TimeKey
                                                            AND EffectiveToTimeKey >= v_TimeKey )
                          JOIN DimAssetClass D   ON D.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
                          AND ( D.EffectiveFromTimeKey <= v_TimeKey
                          AND D.EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBalanceDetail E   ON E.ACCOUNTENTITYID = B.AccountEntityID
                          AND ( E.EffectiveFromTimeKey <= v_TimeKey
                          AND E.EffectiveToTimeKey >= v_TimeKey )
                          LEFT JOIN CurDat_RBL_MISDB_PROD.AdvCustOtherDetail F   ON A.RefCustomerID = F.RefCustomerId
                          AND ( F.EffectiveFromTimeKey <= v_TimeKey
                          AND F.EffectiveToTimeKey >= v_TimeKey )
                          JOIN DimAssetClassMapping G   ON E.SourceAssetClass = G.SrcSysClassCode
                          AND G.SourceAlt_Key = 5
                          AND G.SourceAlt_Key = C.SourceAlt_Key
                          JOIN DimAssetClassMapping_Customer H   ON H.AssetClassShortName = F.SourceAssetClass
                          AND H.SourceAlt_Key = 5
                          AND H.SourceAlt_Key = C.SourceAlt_Key
                          LEFT JOIN DimAcBuSegment DS   ON DS.AcBuSegmentCode = B.ActSegmentCode
                          AND ( DS.EffectiveFromTimeKey <= v_TimeKey
                          AND DS.EffectiveToTimeKey >= v_TimeKey )
                    WHERE  A.SysAssetClassAlt_Key = 1
                             AND H.AssetClassAlt_Key <> 1 ) A );
         --CRisMac_Report_Date,      
         --Host_System_Report_Date,      
         --UCIC_ID ,      
         --CustomerID,      
         --AccountID,      
         --BorroweName,    
         --Host_System_Name,      
         --Account_DPD,      
         --NPA_Norm,      
         --Business_Segment ,    
         --Principal_OS_CRisMac,      
         -- Principal_OS_Host,      
         -- Host_System_NPA_Date,      
         --CRisMac_NPA_Date,     
         --Host_System_ACL_Account_Level,    
         --Host_System_ACL_CIF_LeveL,    
         --CRisMac_Asset_Classification    
         -- ;with CTE as
         --(
         --select AccountID,status,ROW_NUMBER() over  (partition by AccountID order by status asc )rn from tt_TEMP_17
         --)delete  from #temp a inner join CTE b on a.accountid=b=accountid and a.status=b.status where rn>1
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_TEMP_171  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_TEMP1_12;
         UTILS.IDENTITY_RESET('tt_TEMP1_12');

         INSERT INTO tt_TEMP1_12 SELECT * 
              FROM ( SELECT CRisMac_Report_Date ,
                            Host_System_Report_Date ,
                            UCIC_ID ,
                            CustomerID ,
                            AccountID ,
                            BorroweName ,
                            Host_System_Name ,
                            Account_DPD ,
                            NPA_Norm ,
                            Business_Segment ,
                            Principal_OS_CRisMac ,
                            Principal_OS_Host ,
                            Host_System_NPA_Date ,
                            Host_System_NPA_Date_CIF_Level ,
                            CRisMac_NPA_Date ,
                            Host_System_ACL_Account_Level ,
                            Host_System_ACL_CIF_LeveL ,
                            CRisMac_Asset_Classification ,
                            Status 
                     FROM ( SELECT CRisMac_Report_Date ,
                                   Host_System_Report_Date ,
                                   UCIC_ID ,
                                   CustomerID ,
                                   AccountID ,
                                   BorroweName ,
                                   Host_System_Name ,
                                   Account_DPD ,
                                   NPA_Norm ,
                                   Business_Segment ,
                                   Principal_OS_CRisMac ,
                                   Principal_OS_Host ,
                                   Host_System_NPA_Date ,
                                   Host_System_NPA_Date_CIF_Level ,
                                   CRisMac_NPA_Date ,
                                   Host_System_ACL_Account_Level ,
                                   Host_System_ACL_CIF_LeveL ,
                                   CRisMac_Asset_Classification ,
                                   STATUS ,
                                   ROW_NUMBER() OVER ( PARTITION BY AccountID ORDER BY STATUS ASC  ) rn  
                            FROM tt_TEMP_17  ) cte
                      WHERE  rn = 1 ) B;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GANASEVA_HOST_SYSTEM_NPA_DATA ';
         INSERT INTO GANASEVA_HOST_SYSTEM_NPA_DATA
           ( CRisMac_Report_Date, Host_System_Report_Date, UCIC_ID, CustomerID, AccountID, BorroweName, Host_System_Name, Account_DPD, NPA_Norm, Business_Segment, Principal_OS_CRisMac, Principal_OS_Host, Host_System_NPA_Date, Host_System_NPA_Date_CIF_Level, CRisMac_NPA_Date, Host_System_ACL_Account_Level, Host_System_ACL_CIF_LeveL, CRisMac_Asset_Classification, Status )
           ( SELECT CRisMac_Report_Date ,
                    Host_System_Report_Date ,
                    UCIC_ID ,
                    CustomerID ,
                    AccountID ,
                    BorroweName ,
                    Host_System_Name ,
                    Account_DPD ,
                    NPA_Norm ,
                    Business_Segment ,
                    Principal_OS_CRisMac ,
                    Principal_OS_Host ,
                    Host_System_NPA_Date ,
                    Host_System_NPA_Date_CIF_Level ,
                    CRisMac_NPA_Date ,
                    Host_System_ACL_Account_Level ,
                    Host_System_ACL_CIF_LeveL ,
                    CRisMac_Asset_Classification ,
                    Status 
             FROM tt_TEMP1_12  );
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_17 ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP1_12 ';
         utils.commit_transaction;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      ROLLBACK;
      utils.resetTrancount;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GANASEVA_HOST_SYSTEM_NPA_REPORT_DATA_04122023" TO "ADF_CDR_RBL_STGDB";
