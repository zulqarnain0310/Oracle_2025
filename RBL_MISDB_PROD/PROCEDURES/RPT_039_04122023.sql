--------------------------------------------------------
--  DDL for Procedure RPT_039_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_039_04122023" 
--USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[Rpt-039]    Script Date: 4/5/2022 4:20:45 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

(
  v_TimeKey IN NUMBER,
  v_Cost IN FLOAT
)
AS
   ---Exceeptional_Degradation Report
   --DECLARE 
   --      @TimeKey AS INT=26391,
   --	  @Cost    AS FLOAT=1
   v_Date VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey );
   -------------------------------------Asset Classification
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT v_Date Process_date  ,
             E.StatusDate Date_of_exceptional_Degrade  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             BranchName ,
             CustomerAcID ,
             SourceName ,
             B.FacilityType ,
             SchemeType ,
             B.ProductCode ,
             ProductName ,
             ActSegmentCode ,
             AcBuSegmentDescription ,
             AcBuRevisedSegmentCode ,
             DPD_Max ,
             UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             A1.AssetClassName InitialAssetName  ,
             --,A2.AssetClassName                                    AS FinalAssetName
             (CASE 
                   WHEN A2.AssetClassName IN ( 'DOUBTFUL I','DOUBTFUL III','SUB-STANDARD','DOUBTFUL II','LOS' )
                    THEN 'NPA'
             ELSE 'STD'
                END) FinalAssetName  ,
             NPANorms ,
             NVL(DrawingPower, 0) / v_Cost DrawingPower  ,
             NVL(CurrentLimit, 0) / v_Cost Sanction_Limit  ,
             NVL(Balance, 0) / v_Cost Balance  ,
             E.StatusType Exception_Degradation_Flag  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               AND A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey
               AND B.EffectiveFromTimeKey <= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey
               JOIN ExceptionFinalStatusType E   ON E.ACID = B.CustomerAcID
               AND E.EffectiveFromTimeKey <= v_TimeKey
               AND E.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DIMSOURCEDB src   ON B.SourceAlt_Key = src.SourceAlt_Key
               AND src.EffectiveFromTimeKey <= v_TimeKey
               AND src.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = B.ProductAlt_Key
               AND PD.EffectiveFromTimeKey <= v_TimeKey
               AND PD.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimAssetClass A1   ON A1.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
               AND A1.EffectiveFromTimeKey <= v_TimeKey
               AND A1.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
               AND A2.EffectiveFromTimeKey <= v_TimeKey
               AND A2.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuRevisedSegmentCode
               AND S.EffectiveFromTimeKey <= v_TimeKey
               AND S.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
               AND X.EffectiveFromTimeKey <= v_TimeKey
               AND X.EffectiveToTimeKey >= v_TimeKey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--WHERE RefPeriodOverdue NOT IN (181,366)

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_039_04122023" TO "ADF_CDR_RBL_STGDB";
