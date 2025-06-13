--------------------------------------------------------
--  DDL for Procedure IRAC_NEW_REPORT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" 
AS
   v_Timekey NUMBER(10,0) := ( SELECT TIMEKEY 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Timekey = v_Timekey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( v_Timekey )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CIF_ID  ,
             B.LastCrDate Last_Credit_Date  ,
             REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
             B.CustomerAcID Account_No_  ,
             SourceName Source_System  ,
             DPD_Max Account_DPD  ,
             CD Cycle_Past_due  ,
             FinalNpaDt NPA_Date  ,
             B.StockStDt Stock_Statement_valuation_date  ,
             CurntQtrRv Customer_Security_Value  ,
             REPLACE(NVL(A.DegReason, b.NPA_Reason), ',', ' ') Degrade_Reason  ,
             CASE 
                  WHEN B.SecApp = 'S' THEN 'SECURED'
             ELSE 'UNSECURED'
                END Secured_Unsecured  ,
             A2.AssetClassName Asset_Classification  ,
             B.TotalProvision Provision_Total  ,
             RD.RestructureDt ,
             RT.ParameterName Type_of_restructuring  
        FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
               JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
               AND NVL(B.WriteOffAmount, 0) = 0
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999
               LEFT JOIN ADVACRESTRUCTUREDETAIL RD   ON B.AccountEntityID = RD.AccountEntityId
               AND RD.EffectiveFromTimeKey <= v_Timekey
               AND RD.EffectiveToTimeKey >= v_Timekey
               LEFT JOIN ( SELECT ParameterAlt_Key ,
                                  ParameterName 
                           FROM DimParameter 
                            WHERE  DimParameterName LIKE '%TypeofRestructuring%'
                                     AND EffectiveToTimeKey = 49999 ) RT   ON RD.RestructureTypeAlt_Key = RT.ParameterAlt_Key
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
               AND X.EffectiveToTimeKey = 49999
               LEFT JOIN ( SELECT A.CustomerEntityID ,
                                  SUM(NetBalance)  NetBalance  ,
                                  SUM(SecuredAmt)  SecuredAmt  ,
                                  SUM(UnSecuredAmt)  UnSecuredAmt  ,
                                  SUM(TotalProvision)  TotalProvision  ,
                                  SUM(Provsecured)  Provsecured  ,
                                  SUM(ProvUnsecured)  ProvUnsecured  ,
                                  SUM(NetBalance)  - SUM(NVL(totalprovision, 0))  NetNPA  
                           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                                  JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
                            WHERE  B.EffectiveFromTimeKey <= v_LastQtrDateKey
                                     AND b.EffectiveToTimeKey >= v_LastQtrDateKey
                                     AND A.EffectiveFromTimeKey <= v_LastQtrDateKey
                                     AND A.EffectiveToTimeKey >= v_LastQtrDateKey
                                     AND B.FinalAssetClassAlt_Key > 1
                             GROUP BY A.CustomerEntityID ) Y   ON A.CustomerEntityID = Y.CustomerEntityID
               LEFT JOIN DPD DPD   ON B.accountentityid = DPD.AccountEntityid
       WHERE  B.FinalAssetClassAlt_Key > 1
                AND b.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                AND A.EffectiveFromTimeKey <= v_Timekey
                AND A.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."IRAC_NEW_REPORT_04122023" TO "ADF_CDR_RBL_STGDB";
