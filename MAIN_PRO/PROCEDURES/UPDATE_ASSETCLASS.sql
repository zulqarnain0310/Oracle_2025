--------------------------------------------------------
--  DDL for Procedure UPDATE_ASSETCLASS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."UPDATE_ASSETCLASS" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : UPDATE AssetClass
 ---EXEC [Pro].[Update_AssetClass] @TIMEKEY=25140 
=============================================*/
(
  v_TIMEKEY IN NUMBER
)
AS

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
    V_Table_exists NUMBER(10);
   BEGIN
      DECLARE
      
         v_SUB_Days NUMBER(10,0) ;
         v_DB1_Days NUMBER(10,0) ;
         v_DB2_Days NUMBER(10,0) ;
         v_MoveToDB1 NUMBER(5,2) ;
         v_MoveToLoss NUMBER(5,2) ;
         v_ProcessDate VARCHAR2(200) ;

      BEGIN

        SELECT RefValue INTO v_SUB_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'SUB_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB1_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'DB1_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_DB2_Days
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'DB2_Days'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToDB1
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'MoveToDB1'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT UTILS.CONVERT_TO_NUMBER(RefValue / 100.00,5,2) INTO v_MoveToLoss
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'MoveToLoss'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         SELECT DATE_ INTO v_ProcessDate
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;

if V_Table_exists = 1 Then
            Execute Immediate 'Drop Table GTT_CustomerWiseBalance';
            Execute Immediate 'CREATE GLOBAL TEMPORARY TABLE GTT_CustomerWiseBalance 
                                ON COMMIT DELETE ROWS 
                                AS  ( 
                                    SELECT A.refcustomerid ,
                                        SUM(NVL(A.BALANCE, 0))  Balance  
                                    FROM GTT_ACCOUNTCAL A
                                        JOIN GTT_CUSTOMERCAL B   ON A.refcustomerid = B.refcustomerid
                                    WHERE  NVL(B.FlgProcessing, ''''N'''') = ''''N''''
                                    GROUP BY A.refcustomerid );';
            DBMS_OUTPUT.PUT_LINE('Table Dropped and Re-Created!');
        Else 
            Execute Immediate 'CREATE GLOBAL TEMPORARY TABLE GTT_CustomerWiseBalance 
                                ON COMMIT DELETE ROWS 
                                AS  ( 
                                    SELECT A.refcustomerid ,
                                        SUM(NVL(A.BALANCE, 0))  Balance  
                                    FROM GTT_ACCOUNTCAL A
                                        JOIN GTT_CUSTOMERCAL B   ON A.refcustomerid = B.refcustomerid
                                    WHERE  NVL(B.FlgProcessing, ''''N'''') = ''''N''''
                                    GROUP BY A.refcustomerid );';
            DBMS_OUTPUT.PUT_LINE('New Table Created!');
    END IF;
    
         EXECUTE IMMEDIATE ' CREATE INDEX I1
            ON GTT_CustomerWiseBalance ( refcustomerid)';
         /*-----INTIAL LEVEL SysAssetClassAlt_Key DbtDt,C DegDate----------- */
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, NULL DBTDT, NULL LOSSDt, NULL DEGDATE
         FROM GTT_CustomerWiseBalance a
                JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE ( NVL(B.FlgDeg, 'N') = 'Y'
           AND NVL(B.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DbtDt = NULL,
                                      B.LossDt = NULL,
                                      B.DegDate = NULL;
         /*---CALCULATE SysAssetClassAlt_Key ,DbtDt,DegDate-----------------------*/
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, (CASE 
         WHEN utils.dateadd('DAY', v_SUB_Days, B.SysNPA_Dt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                   FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                    WHERE  DIMASSETCLASS.AssetClassShortName = 'SUB'
                                                                                             AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                             AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days, B.SysNPA_Dt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, B.SysNPA_Dt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                 FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                  WHERE  DIMASSETCLASS.AssetClassShortName = 'DB1'
                                                                                                           AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                           AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, B.SysNPA_Dt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days + v_DB2_Days, B.SysNPA_Dt) > v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                              FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                               WHERE  DIMASSETCLASS.AssetClassShortName = 'DB2'
                                                                                                                        AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                        AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
         WHEN utils.dateadd('DAY', (v_DB1_Days + v_SUB_Days + v_DB2_Days), B.SysNPA_Dt) <= v_ProcessDate THEN ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
                                                                                                                FROM RBL_MISDB_PROD.DimAssetClass 
                                                                                                                 WHERE  DIMASSETCLASS.AssetClassShortName = 'DB3'
                                                                                                                          AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                          AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )   END) AS pos_2, (CASE 
         WHEN utils.dateadd('DAY', v_SUB_Days, B.SysNPA_Dt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, B.SysNPA_Dt) > v_ProcessDate THEN utils.dateadd('DAY', v_SUB_Days, B.SysNPA_Dt)
         WHEN utils.dateadd('DAY', v_SUB_Days + v_DB1_Days, B.SysNPA_Dt) <= v_ProcessDate
           AND utils.dateadd('DAY', v_SUB_Days + v_DB1_Days + v_DB2_Days, B.SysNPA_Dt) > v_ProcessDate THEN utils.dateadd('DAY', v_SUB_Days, B.SysNPA_Dt)
         WHEN utils.dateadd('DAY', (v_DB1_Days + v_SUB_Days + v_DB2_Days), B.SysNPA_Dt) <= v_ProcessDate THEN utils.dateadd('DAY', (v_SUB_Days), B.SysNPA_Dt)
         ELSE TO_DATE(DBTDT,'YYYY-MM-DD')
            END) AS pos_3, v_ProcessDate
         FROM GTT_CustomerWiseBalance A
                JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE ( NVL(B.FlgDeg, 'N') = 'Y'
           AND B.FlgProcessing = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.SysAssetClassAlt_Key --CASE WHEN    B.CurntQtrRv< (A.BALANCE *@MoveToLoss) THEN   (SELECT AssetClassAlt_Key FROM RBL_MISDB_PROD.DimAssetClass WHERE AssetClassShortName='LOS' AND EffectiveFromTimeKey<=@TIMEKEY AND EffectiveToTimeKey>=@TIMEKEY)
                                       = pos_2,
                                      B.DBTDT
                                      --,B.LossDt= (CASE  WHEN     B.CurntQtrRv< (A.BALANCE *@MoveToLoss)   THEN @PROCESSDATE ELSE LossDt END)
                                       = pos_3,
                                      B.DegDate = v_ProcessDate;
         /*-------------MARKING OF FRAUD-----------------------*/
         MERGE INTO GTT_CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id, ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
           FROM RBL_MISDB_PROD.DimAssetClass 
          WHERE  DIMASSETCLASS.AssetClassShortName = 'LOS'
                   AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                   AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY 
           FETCH FIRST 1 ROWS ONLY ) AS SysAssetClassAlt_Key
         FROM GTT_CUSTOMERCAL A 
          WHERE ( NVL(A.SplCatg1Alt_Key, 0) = 870
           OR NVL(A.SplCatg2Alt_Key, 0) = 870
           OR NVL(A.SplCatg3Alt_Key, 0) = 870
           OR NVL(A.SplCatg4Alt_Key, 0) = 870 )
           AND NVL(A.FlgDeg, 'N') = 'Y') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = src.SysAssetClassAlt_Key;
         /*-------- UPDATE DBT DATE NULL FOR LOS CUSTOMERS------------------- */
         MERGE INTO GTT_CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, NULL
         FROM GTT_CustomerWiseBalance A
                JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE ( NVL(B.FlgDeg, 'N') = 'Y'
           AND NVL(B.FlgProcessing, 'N') = 'N' )
           AND SysAssetClassAlt_Key IN ( SELECT AssetClassAlt_Key 
                                         FROM RBL_MISDB_PROD.DimAssetClass 
                                          WHERE  AssetClassShortName = 'LOS'
                                                   AND EffectiveFromTimeKey <= v_TIMEKEY
                                                   AND EffectiveToTimeKey >= v_TIMEKEY )
         ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET DbtDt = NULL;
         /*----UPDATE FINALASSETALT_KEY IN ACCOUNT LEVEL FROM CUSTOMER--------------------*/
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.SysAssetClassAlt_Key
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CUSTOMERCAL B   ON A.REFCUSTOMERID = B.REFCUSTOMERID 
          WHERE ( NVL(B.FlgDeg, 'N') = 'Y'
           AND NVL(B.FlgProcessing, 'N') = 'N' )
           AND ( NVL(A.Asset_Norm, 'NORMAL') = 'NORMAL'
           AND NVL(A.FlgDeg, 'N') = 'Y' )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.SysAssetClassAlt_Key;
         --UPDATE A
         -- SET  A.FinalAssetClassAlt_Key =CASE WHEN A.FlgDeg='Y' AND Asset_Norm='CONDI_STD' THEN FinalAssetClassAlt_Key ELSE  1 END
         --  FROM PRO.AccountCal  A
         --WHERE ISNULL(A.Asset_Norm,'NORMAL')='CONDI_STD' and isnull(InitialAssetClassAlt_Key,1)=1
         --/*------to handle upgrade of advance agianst  cash security IF CUSTOMER IS NPA BUT ISLAD ACCOUNT IS REGULAR------------------------------------*/
         --UPDATE A
         -- SET  A.FinalAssetClassAlt_Key =  case when b.ContinousExcessSecDt is not null  then FinalAssetClassAlt_Key else 1 end
         --  FROM PRO.AccountCal  A left outer join CurDat.AdvAcOtherDetail  b on a.AccountEntityID=b.AccountEntityId and (b.EffectiveFromTimeKey<=@TIMEKEY
         --  and b.EffectiveToTimeKey>=@TIMEKEY)
         --WHERE ISNULL(A.Asset_Norm,'NORMAL')='CONDI_STD' and isnull(a.InitialAssetClassAlt_Key,1)<>1
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_CustomerWiseBalance ';
         MAIN_PRO.Final_AssetClass_Npadate(v_TIMEKEY => v_TIMEKEY,v_FlgPreErosion => 'Y') ;
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'Update_AssetClass';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      -----------------Added for DashBoard 04-03-2021
      --Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'
      V_SQLERRM := SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'Update_AssetClass';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."UPDATE_ASSETCLASS" TO "ADF_CDR_RBL_STGDB";
