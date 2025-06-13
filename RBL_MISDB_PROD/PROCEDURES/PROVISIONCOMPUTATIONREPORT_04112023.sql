--------------------------------------------------------
--  DDL for Procedure PROVISIONCOMPUTATIONREPORT_04112023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" 
AS
   v_Date VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(Date_,200) 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM Automate_Advances 
    WHERE  Date_ = v_Date );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Date_ = v_Date )
    );

BEGIN

   --------------------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_ADVACRESTRUCTUREDETAIL_11') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ADVACRESTRUCTUREDETAIL_11 ';
   END IF;
   DELETE FROM tt_ADVACRESTRUCTUREDETAIL_11;
   UTILS.IDENTITY_RESET('tt_ADVACRESTRUCTUREDETAIL_11');

   INSERT INTO tt_ADVACRESTRUCTUREDETAIL_11 SELECT * 
        FROM ( SELECT * ,
                      ROW_NUMBER() OVER ( PARTITION BY RefSystemAcId ORDER BY RefSystemAcId, EffectiveFromTimeKey DESC, EntityKey DESC  ) rn  
               FROM ADVACRESTRUCTUREDETAIL RES
                WHERE  RES.EffectiveFromTimeKey <= v_Timekey
                         AND RES.EffectiveToTimeKey >= v_Timekey ) aa
       WHERE  rn = 1;
   ------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------
   IF ( utils.object_id('TEMPDB..tt_PrevQtrDataAccountWise_9') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrDataAccountWise_9 ';
   END IF;
   DELETE FROM tt_PrevQtrDataAccountWise_9;
   UTILS.IDENTITY_RESET('tt_PrevQtrDataAccountWise_9');

   INSERT INTO tt_PrevQtrDataAccountWise_9 ( 
   	SELECT A.CustomerEntityID ,
           b.AccountEntityID ,
           NetBalance ,
           SecuredAmt ,
           UnSecuredAmt ,
           TotalProvision ,
           Provsecured ,
           CustomerAcID ,
           ProvUnsecured ,
           NVL(NetBalance, 0) - NVL(totalprovision, 0) NetNPA  
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
             JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  B.EffectiveFromTimeKey <= v_LastQtrDateKey
              AND b.EffectiveToTimeKey >= v_LastQtrDateKey
              AND A.EffectiveFromTimeKey <= v_LastQtrDateKey
              AND A.EffectiveToTimeKey >= v_LastQtrDateKey
              AND B.FinalAssetClassAlt_Key > 1 );
   -------------------------------------------------------------------------------------------------
   ----select @LastQtrDateKey
   --select * from sysdaymatrix where timekey=26383
   IF ( utils.object_id('TEMPDB..tt_PrevQtrData_13') IS NOT NULL ) THEN
    ------select @LastQtrDateKey
   --------------------------------------------------------------------------
   --IF OBJECT_ID('TEMPDB..#ProvisonComputation_Report') IS NOT NULL
   --		DROP TABLE #ProvisonComputation_Report
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PrevQtrData_13 ';
   END IF;
   DELETE FROM tt_PrevQtrData_13;
   UTILS.IDENTITY_RESET('tt_PrevQtrData_13');

   INSERT INTO tt_PrevQtrData_13 ( 
   	SELECT ACCOUNTENTITYID ,
           CUSTOMERACID ,
           SecuredAmt ,
           UnSecuredAmt ,
           TotalProvision ,
           Provsecured ,
           ProvUnsecured ,
           Addlprovision ,
           NetBalance ,
           FinalAssetClassAlt_Key ----,*


   	  ----MAX(EffectiveToTimeKey)
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_LastQtrDateKey
              AND EffectiveToTimeKey >= v_LastQtrDateKey );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE ProvisonComputation_Report ';
   INSERT INTO ProvisonComputation_Report
     SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
            A.UCIF_ID UCIC  ,
            A.RefCustomerID CIF_ID  ,
            REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
            B.BranchCode Branch_Code  ,
            REPLACE(BranchName, ',', ' ') Branch_Name  ,
            B.CustomerAcID Account_No_  ,
            SourceName Source_System  ,
            B.FacilityType Facility  ,
            SchemeType Scheme_Type  ,
            B.ProductCode Scheme_Code  ,
            ProductName Scheme_Description  ,
            CASE 
                 WHEN B.SecApp = 'S' THEN 'SECURED'
            ELSE 'UNSECURED'
               END Secured_Unsecured  ,
            ActSegmentCode Seg_Code  ,
            (CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
            ELSE AcBuSegmentDescription
               END) Segment_Description  ,
            CASE 
                 WHEN SourceName = 'FIS' THEN 'FI'
                 WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
            ELSE AcBuRevisedSegmentCode
               END Business_Segment  ,
            DPD_Max Account_DPD  ,
            ----,CD [Cycle Past due]
            FinalNpaDt NPA_Date  ,
            A2.AssetClassName Asset_Classification  ,
            REFPERIODOVERDUE NPA_Norms ,--NPANorms as [NPA Norms] 

            B.NetBalance Balance_Outstanding  ,
            CurntQtrRv Customer_Security_Value  ,
            -----,SecurityValue as [Account Security Value]   -- TO BE REMOVED
            ApprRV Security_Value_Appropriated  ,
            B.SecuredAmt Secured_Outstanding  ,
            B.UnSecuredAmt Unsecured_Outstanding  ,
            B.TotalProvision Provision_Total  ,
            B.Provsecured Provision_Secured  ,
            B.ProvUnsecured Provision_Unsecured  ,
            NVL((B.NetBalance - B.TotalProvision), 0) Net_NPA  ,
            UTILS.CONVERT_TO_NUMBER((NVL((B.Provsecured / NULLIF(B.SecuredAmt, 0)) * 100, 0)),5,2) ProvisionSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((B.ProvUnsecured / NULLIF(B.UnSecuredAmt, 0)) * 100, 0)),5,2) ProvisionUnSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((B.TotalProvision / NULLIF(B.NetBalance, 0)) * 100, 0)),5,2) ProvisionTotal_  ,
            NVL(Y.NetBalance, 0) Prev_Qtr_Balance_Outstanding  ,
            NVL(Y.SecuredAmt, 0) Prev_Qtr_Secured_Outstanding  ,
            NVL(Y.UnSecuredAmt, 0) Prev_Qtr_Unsecured_Outstanding  ,
            NVL(Y.TotalProvision, 0) Prev_Qtr_Provision_Total  ,
            NVL(Y.Provsecured, 0) Prev_Qtr_Provision_Secured  ,
            NVL(Y.ProvUnsecured, 0) Prev_Qtr_Provision_Unsecured  ,
            NVL(Y.NetNPA, 0) Prev_Qtr_Net_NPA  ,
            ----,CASE WHEN ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) < 0 
            ----			then 0 
            ----		ELSE ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) 
            ----	END NPAIncrease
            ----,CASE WHEN ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) >= 0 then 0 
            ----ELSE ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) END NPADecrease
            ----,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) < 0 then 0 
            ----ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionIncrease
            ----,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) >= 0 then 0 
            ----ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionDecrease
            ----,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - y.NetNPA),0) < 0 then 0 
            ----ELSE ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) END NetNPAIncrease
            ----,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) >= 0 then 0 ELSE ISNULL(((B.NetBalance-B.TotalProvision) - ISNULL(y.NetNPA,0)),0) END NetNPAnDecrease
            ------ADDED ON 26/03/2022
            B.AccountBlkCode2 Block_Code_V_  ,
            B.Addlprovision Additional_Provision  ,
            EXPS.StatusType ,
            ---------PREV QTR DATA
            A3.AssetClassName PREV_QTR_Asset_Classification  ,
            PREV.Addlprovision PREV_QTR_Additional_Provision  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.Provsecured / NULLIF(PREV.SecuredAmt, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.ProvUnsecured / NULLIF(PREV.UnSecuredAmt, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionUnSecured_  ,
            UTILS.CONVERT_TO_NUMBER((NVL((PREV.TotalProvision / NULLIF(PREV.NetBalance, 0)) * 100, 0)),5,2) PREV_QTR_ProvisionTotal_  ,
            Dimp.ParameterName TypeofRestructuring  ,
            CASE 
                 WHEN A.FlgErosion <> 'Y' THEN NULL
            ELSE (CASE 
                       WHEN A.SysAssetClassAlt_Key = 6 THEN 'Erosion Loss'
            ELSE 'Erosion D_1'
               END)
               END Erosion_Testing  

       --INTO #ProvisonComputation_Report
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
              AND NVL(B.WriteOffAmount, 0) = 0
              LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
              AND src.EffectiveFromTimeKey <= v_Timekey
              AND src.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
              AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
              LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
              AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
              LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
              AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
              LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
              AND S.EffectiveToTimeKey = 49999
              LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
              AND X.EffectiveToTimeKey = 49999
              LEFT JOIN tt_PrevQtrDataAccountWise_9 Y   ON A.CustomerEntityID = Y.CustomerEntityID
              AND b.CustomerAcID = Y.CustomerAcID
            --LEFT JOIN #dpd2 DPD ON B.accountentityid = DPD.AccountEntityID   

              LEFT JOIN tt_PrevQtrData_13 prev   ON B.AccountEntityID = PREV.ACCOUNTENTITYID
              LEFT JOIN DimAssetClass a3   ON a3.EffectiveToTimeKey = 49999
              AND a3.AssetClassAlt_Key = prev.FinalAssetClassAlt_Key
              LEFT JOIN ( 
                          --LEFT JOIN ExceptionFinalStatusType    EXPS    ON EXPS.ACID=B.CustomerAcID  AND EXPS.EffectiveToTimeKey=49999  
                          SELECT DISTINCT SourceAlt_Key ,
                                          CustomerID ,
                                          ACID ,
                                          EffectiveToTimeKey ,
                                          utils.stuff(( SELECT ', ' || B.StatusType 
                                                        FROM ExceptionFinalStatusType B
                                                         WHERE  B.EffectiveToTimeKey = 49999
                                                                  AND B.ACID = A.ACID
                                                          ORDER BY B.ACID ), 1, 1, ' ') StatusType  
                          FROM ExceptionFinalStatusType A
                           WHERE  A.EffectiveToTimeKey = 49999 ) EXPS   ON EXPS.ACID = B.CustomerAcID
              AND EXPS.EffectiveToTimeKey = 49999
              LEFT JOIN tt_ADVACRESTRUCTUREDETAIL_11 RES   ON RES.AccountEntityId = B.AccountEntityID
              AND RES.EffectiveFromTimeKey <= v_Timekey
              AND RES.EffectiveToTimeKey >= v_Timekey
              LEFT JOIN ( SELECT ParameterAlt_Key ,
                                 ParameterName 
                          FROM DimParameter 
                           WHERE  DimParameterName = 'TypeofRestructuring'
                                    AND EffectiveFromTimeKey <= v_Timekey
                                    AND EffectiveToTimeKey >= v_Timekey ) DIMP   ON DIMP.ParameterAlt_Key = RES.RestructureTypeAlt_Key
              LEFT JOIN ExceptionFinalStatusType EF   ON b.CustomerAcID = ef.ACID
              AND EF.StatusType = 'TWO'
              AND ef.EffectiveToTimeKey = 49999
      WHERE  B.FinalAssetClassAlt_Key > 1
               AND ef.ACID IS NULL
             --WHERE B.FinalAssetClassAlt_Key>1    

       ORDER BY "Account No.";--SELECT * FROM #ProvisonComputation_Report

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_04112023" TO "ADF_CDR_RBL_STGDB";
