--------------------------------------------------------
--  DDL for Procedure ACCELERATEDPROVISIONREPORT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" 
AS
   v_TIMEKEY NUMBER(10,0) := 26357;
   v_ProcessDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TimeKey );
   v_CurrentDate VARCHAR2(200) := ( SELECT UTILS.CONVERT_TO_VARCHAR2(DATE_,200) 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_BackDtdProcess CHAR(1);
   v_CurQtrDate VARCHAR2(200);
   v_LastQtrDate VARCHAR2(200);
   v_LastToLastQtrDate VARCHAR2(200);
   v_LastToLastToLastQtrDate VARCHAR2(200);
   v_cursor SYS_REFCURSOR;
--@TimeKey  INT

BEGIN

   v_BackDtdProcess := CASE 
                            WHEN v_ProcessDate < v_CurrentDate THEN 'Y'
   ELSE 'N'
      END ;
   SELECT CurQtrDate ,
          LastQtrDate ,
          LastToLastQtrDate 

     INTO v_CurQtrDate,
          v_LastQtrDate,
          v_LastToLastQtrDate
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TimeKey;
   v_LastToLastToLastQtrDate := EOMONTH(utils.dateadd('MM', -3, v_LastToLastQtrDate)) ;
   IF  --SQLDEV: NOT RECOGNIZED
   --select * from tt_ACCT_NPA_QTR_NO_REPORT_2
   IF tt_ACCT_NPA_QTR_NO_REPORT_2  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_ACCT_NPA_QTR_NO_REPORT_2;
   UTILS.IDENTITY_RESET('tt_ACCT_NPA_QTR_NO_REPORT_2');

   INSERT INTO tt_ACCT_NPA_QTR_NO_REPORT_2 ( 
   	SELECT A.UcifEntityID ,
           A.CustomerEntityID ,
           A.AccountEntityID ,
           FinalAssetClassAlt_Key ,
           PROV.ProvisionAlt_Key ,
           ProvisionSecured ,
           ProvisionUnSecured ,
           Prov.Segment ,
           ProvisionRule ,
           LowerDPD ,
           UpperDPD ,
           CASE 
                WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastQtrDate) AND v_CurQtrDate THEN 'Q1'
                WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastQtrDate) AND v_LastQtrDate THEN 'Q2'
                WHEN FinalNpaDt BETWEEN utils.dateadd('DD', 1, v_LastToLastToLastQtrDate) AND v_LastToLastQtrDate THEN 'Q3'
           ELSE 'Q4'
              END NPA_QTR_NO  ,
           Seg.AcBuRevisedSegmentCode ,
           CASE 
                WHEN SecApp = 'S' THEN 'Secured'
           ELSE 'UnSecured'
              END SecuredUnsecured  
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist A
             LEFT JOIN DimAcBuSegment SEG   ON SEG.AcBuSegmentCode = A.ActSegmentCode
             AND ( SEG.EffectiveFromTimeKey <= v_TimeKey
             AND SEG.EffectiveToTimeKey >= v_TimeKey )
             JOIN DimProvision_Seg prov   ON PROV.EffectiveFromTimeKey <= v_TimeKey
             AND Prov.EffectiveToTimeKey >= v_TimeKey
             AND Prov.ProvisionAlt_Key = A.ProvisionAlt_Key
   	 WHERE  FinalAssetClassAlt_Key > 1
              AND A.EffectiveFromTimeKey <= v_TimeKey
              AND A.EffectiveToTimekey >= v_TimeKey );
   DELETE FROM tt_ACCT_NPA_QTR_NO_Account_2;
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_ACCT_NPA_QTR_NO_Account_2  --SQLDEV: NOT RECOGNIZED
   INSERT INTO tt_ACCT_NPA_QTR_NO_Account_2
     ( SELECT B.AccountEntityId ,
              CASE 
                   WHEN NVL(AdditionalProvAcct, 0) > 0 THEN 'ACCT'
              ELSE 'CUSTUCIF'
                 END ProvTypes  
       FROM AcceleratedProvision A
              JOIN AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID
              AND b.EffectiveFromTimeKey <= v_TimeKey
              AND b.EffectiveToTimeKey >= v_TimeKey
              JOIN CustomerBasicDetail C   ON C.CustomerEntityId = B.CustomerEntityId
              AND c.EffectiveFromTimeKey <= v_TimeKey
              AND c.EffectiveToTimeKey >= v_TimeKey
              JOIN tt_ACCT_NPA_QTR_NO_REPORT_2 D   ON D.AccountEntityID = b.AccountEntityId
        WHERE  EffectiveDate <= v_ProcessDate
                 AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND v_BackDtdProcess = 'Y' )
                 OR ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND v_BackDtdProcess = 'N' ) )
       UNION 
       SELECT b.AccountEntityId ,
              'Bucket' ProvTypes  
       FROM BucketWiseAcceleratedProvision_TEST A
              JOIN tt_ACCT_NPA_QTR_NO_REPORT_2 b   ON A.SegmentName = B.AcBuRevisedSegmentCode
              AND A.Secured_Unsecured = B.SecuredUnsecured
              AND NVL(A.AssetClassNameAlt_key, B.FinalAssetClassAlt_Key) = b.FinalAssetClassAlt_Key
              AND NVL(A.BucketExceptCC, B.NPA_QTR_NO) = B.NPA_QTR_NO
        WHERE  A.SegmentName <> 'CREDIT CARD'
                 AND EffectiveDate <= v_ProcessDate
                 AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND v_BackDtdProcess = 'Y' )
                 OR ( A.EffectiveFromTimeKey <= v_TimeKey
                 AND A.EffectiveToTimeKey >= v_TimeKey
                 AND v_BackDtdProcess = 'N' ) )
       UNION 
       SELECT b.AccountEntityId ,
              'Bucket' ProvTypes  
       FROM BucketWiseAcceleratedProvision_TEST A
              JOIN tt_ACCT_NPA_QTR_NO_REPORT_2 b   ON A.SegmentName = B.AcBuRevisedSegmentCode
              AND A.Secured_Unsecured = B.SecuredUnsecured
              AND A.AssetClassNameAlt_key = b.FinalAssetClassAlt_Key
              AND A.BucketCreditCard = CASE 
                                            WHEN B.ProvisionRule = 'K/W/E/U'
                                              AND B.LowerDPD = 0
                                              AND UpperDPD = 89 THEN 'DPD 0-89 - bc2'
                                            WHEN B.ProvisionRule = 'OTHERS/BLANK'
                                              AND B.LowerDPD = 0
                                              AND UpperDPD = 89 THEN 'DPD 0-89 - Other'
                                            WHEN B.ProvisionRule IN ( 'K/W/E/U' )

                                              AND B.LowerDPD = 90
                                              AND UpperDPD = 179 THEN 'DPD 90'
                                            WHEN B.ProvisionRule IN ( 'OTHERS/BLANK' )

                                              AND B.LowerDPD = 90
                                              AND UpperDPD = 179 THEN 'DPD 90 - Other'   END

       --WHEN B.ProvisionRule in('OTHERS/BLANK','K/W/E/U') AND B.LowerDPD=180 AND UpperDPD=9999 THEN 'DPD 180+'            
       WHERE  A.SegmentName = 'CREDIT CARD'
                AND B.Segment = 'CREDIT CARD'
                AND EffectiveDate <= v_ProcessDate
                AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND v_BackDtdProcess = 'Y' )
                OR ( A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND v_BackDtdProcess = 'N' ) ) );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_ACCT_NPA_QTR_NO_Account_2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--SELECT * FROM DImprovision_Seg

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACCELERATEDPROVISIONREPORT_04122023" TO "ADF_CDR_RBL_STGDB";
