--------------------------------------------------------
--  DDL for Procedure ACCELERATEDPROVISIONDATAPREPARE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" /*==============================                      
Author : TRILOKI KHANNA               
CREATE DATE : 27-11-2019                      
MODIFY DATE : 27-11-2019                     
DESCRIPTION : UPDATE TOTAL PROVISION                      
--EXEC [pro].[UpdationTotalProvision] @TimeKey =25410                        
=========================================*/
(
  ----Declare             
  v_TimeKey IN NUMBER DEFAULT 26357 ,
  v_BackDtdProcess IN CHAR DEFAULT 'Y' 
)
AS

BEGIN
DECLARE v_SQLERRM VARCHAR(1000);
   BEGIN
      DECLARE
         /*UPDATE PROISION ALT KEY FOR NPA (SUB) ACCOUNT AS PER SEGMENT UNSCURED - RETAIL, MSME AND MICRO  ON THE BASES OF NPA QTR NO */
         /* prepare NPA Qtr No */
         v_ProcessDate VARCHAR2(200);
         v_CurQtrDate VARCHAR2(200);
         v_LastQtrDate VARCHAR2(200);
         v_LastToLastQtrDate VARCHAR2(200);
         v_LastToLastToLastQtrDate VARCHAR2(200);
         v_COUNT INT;
         

      BEGIN
      SELECT DATE_ INTO v_ProcessDate 
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TimeKey ;

         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.AcceleratedProvCalc ';
         SELECT CurQtrDate ,
                LastQtrDate ,
                LastToLastQtrDate 

           INTO v_CurQtrDate,
                v_LastQtrDate,
                v_LastToLastQtrDate
           FROM RBL_MISDB_PROD.SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TimeKey;
         v_LastToLastToLastQtrDate := LAST_DAY(utils.dateadd('MM', -3, v_LastToLastQtrDate)) ;

        SELECT COUNT(1)INTO v_COUNT FROM GTT_AC_NPA_QTR_NO;

         IF V_COUNT>1 
         THEN
            DELETE FROM GTT_AC_NPA_QTR_NO;
         END IF;
         UTILS.IDENTITY_RESET('GTT_AC_NPA_QTR_NO');

         INSERT INTO GTT_AC_NPA_QTR_NO ( 
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
         	  FROM MAIN_PRO.AccountCal_Hist A
                   LEFT JOIN RBL_MISDB_PROD.DimAcBuSegment SEG   ON SEG.AcBuSegmentCode = A.ActSegmentCode
                   AND ( SEG.EffectiveFromTimeKey <= v_TimeKey
                   AND SEG.EffectiveToTimeKey >= v_TimeKey )
                   JOIN RBL_MISDB_PROD.DImprovision_Seg prov   ON PROV.EffectiveFromTimeKey <= v_TimeKey
                   AND Prov.EffectiveToTimekey >= v_TimeKey
                   AND Prov.ProvisionAlt_Key = A.ProvisionAlt_Key
         	 WHERE  FinalAssetClassAlt_Key > 1
                    AND NVL(WriteOffAmount, 0) = 0
                    AND A.EffectiveFromTimeKey <= v_TimeKey
                    AND A.EffectiveToTimekey >= v_TimeKey );
         --select * from GTT_AC_NPA_QTR_NO            
         /* FILTER ACCOUNT LEVEL PROVISION */
         INSERT INTO MAIN_PRO.AcceleratedProvCalc
           ( SELECT A.DateApproved ,
                    C.UcifEntityID ,
                    B.CustomerEntityID ,
                    B.AccountEntityId ,
                    AcceProDuration ,
                    Secured_Unsecured ,
                    CASE 
                         WHEN NVL(AdditionalProvAcct, 0) > 0 THEN 'ACCT'
                    ELSE 'CUSTUCIF'
                       END ProvTypes  ,
                    AdditionalProvAcct ,
                    AdditionalProvision ,
                    CurrentProvisionPer ,
                    ProvisionSecured ,
                    ProvisionUnSecured ,
                    NPA_QTR_NO ,
                    Segment ,
                    ProvisionRule ,
                    LowerDPD ,
                    UpperDPD ,
                    v_TimeKey TimeKey  ,
                    0 AcclrtdAddlprov  ,
                    NULL BucketCreditCard  ,
                    NULL BucketExceptCC  
             FROM RBL_MISDB_PROD.AcceleratedProvision A
                    JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountId = B.CustomerACID
                    AND b.EffectiveFromTimeKey <= v_TimeKey
                    AND b.EffectiveToTimeKey >= v_TimeKey
                    JOIN RBL_MISDB_PROD.CustomerBasicDetail C   ON C.CustomerEntityId = B.CustomerEntityId
                    AND c.EffectiveFromTimeKey <= v_TimeKey
                    AND c.EffectiveToTimeKey >= v_TimeKey
                    JOIN GTT_AC_NPA_QTR_NO D   ON D.AccountEntityID = b.AccountEntityId
              WHERE  EffectiveDate <= v_ProcessDate
                       AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey -- and @BackDtdProcess='Y' commented by Mandeep (18042023)Backdated accelerated provision impact
                      )
                       OR ( A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey --and @BackDtdProcess='N' commented by Mandeep (18042023)Backdated accelerated provision impact
                      ) )
             UNION 

             SELECT a.DateApproved ,
                    b.UcifEntityId ,
                    B.CustomerEntityID ,
                    b.AccountEntityId ,
                    AcceProDuration ,
                    Secured_Unsecured ,
                    'Bucket' ProvTypes  ,
                    0 AdditionalProvAcct  ,
                    a.AdditionalProvision ,
                    CurrentProvisionPer ,
                    ProvisionSecured ,
                    ProvisionUnSecured ,
                    NPA_QTR_NO ,
                    Segment ,
                    ProvisionRule ,
                    LowerDPD ,
                    UpperDPD ,
                    v_TimeKey TimeKey  ,
                    0 AcclrtdAddlprov  ,
                    A.BucketCreditCard ,
                    BucketExceptCC 
             FROM RBL_MISDB_PROD.BucketWiseAcceleratedProvision A
                    JOIN GTT_AC_NPA_QTR_NO b   ON A.SegmentName = B.AcBuRevisedSegmentCode
                    AND A.Secured_Unsecured = B.SecuredUnsecured
                    AND NVL(A.AssetClassNameAlt_key, B.FinalAssetClassAlt_Key) = b.FinalAssetClassAlt_Key
                    AND NVL(A.BucketExceptCC, B.NPA_QTR_NO) = B.NPA_QTR_NO
              WHERE  A.SegmentName <> 'CREDIT CARD'
                       AND EffectiveDate <= v_ProcessDate
                       AND ( ( A.EffectiveFromTimeKey >= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey -- and @BackDtdProcess='Y' commented by Mandeep (18042023)Backdated accelerated provision impact
                      )
                       OR ( A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_TimeKey -- and @BackDtdProcess='N' commented by Mandeep (18042023)Backdated accelerated provision impact
                      ) )
             UNION 
             SELECT a.DateApproved ,
                    b.UcifEntityId ,
                    B.CustomerEntityID ,
                    b.AccountEntityId ,
                    AcceProDuration ,
                    Secured_Unsecured ,
                    'Bucket' ProvTypes  ,
                    0 AdditionalProvAcct  ,
                    a.AdditionalProvision ,
                    CurrentProvisionPer ,
                    ProvisionSecured ,
                    ProvisionUnSecured ,
                    NPA_QTR_NO ,
                    Segment ,
                    ProvisionRule ,
                    LowerDPD ,
                    UpperDPD ,
                    v_TimeKey TimeKey  ,
                    0 AcclrtdAddlprov  ,
                    A.BucketCreditCard ,
                    BucketExceptCC 
             FROM RBL_MISDB_PROD.BucketWiseAcceleratedProvision A
                    JOIN GTT_AC_NPA_QTR_NO b   ON A.SegmentName = B.AcBuRevisedSegmentCode
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
                      AND A.EffectiveToTimeKey >= v_TimeKey -- and @BackDtdProcess='Y' commented by Mandeep (18042023)Backdated accelerated provision impact
                     )
                      OR ( A.EffectiveFromTimeKey <= v_TimeKey
                      AND A.EffectiveToTimeKey >= v_TimeKey ) ) );-- and @BackDtdProcess='N' commented by Mandeep (18042023)Backdated accelerated provision impact
         /*DELETE DUP DATE - USE LATTEST ROW (MAX ENTITYKEY) */
          DELETE FROM (SELECT DATEAPPROVED	,
                                    UCIFENTITYID	,
                                    CUSTOMERENTITYID	,
                                    ACCOUNTENTITYID	,
                                    ACCEPRODURATION	,
                                    SECURED_UNSECURED	,
                                    PROVTYPES	,
                                    ADDITIONALPROVACCT	,
                                    ADDITIONALPROVISION	,
                                    CURRENTPROVISIONPER	,
                                    PROVISIONSECURED	,
                                    PROVISIONUNSECURED	,
                                    NPA_QTR_NO	,
                                    SEGMENT	,
                                    PROVISIONRULE	,
                                    LOWERDPD	,
                                    UPPERDPD	,
                                    TIMEKEY	,
                                    ACCLRTDADDLPROV	,
                                    BUCKETCREDITCARD	,
                                    BUCKETEXCEPTCC	 ,
                                   ROW_NUMBER() OVER ( PARTITION BY AccountEntityId ORDER BY AccountEntityId, DateApproved DESC  ) RID  
           FROM MAIN_PRO.AcceleratedProvCalc  )D
             WHERE  RID > 1
            ;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   v_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = v_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'UpdationTotalProvision';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."ACCELERATEDPROVISIONDATAPREPARE" TO "ADF_CDR_RBL_STGDB";
