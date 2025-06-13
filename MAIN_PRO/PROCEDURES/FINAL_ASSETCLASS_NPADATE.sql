--------------------------------------------------------
--  DDL for Procedure FINAL_ASSETCLASS_NPADATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" /*=========================================
 AUTHER : TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION :UPDATE FINAL ASSET CLASS AND MIN NPA DATE UPDATE CUSTOMER LEVEL AT ACCOUNT LEVEL
 EXEC [PRO].[Final_AssetClass_Npadate] 25233
=============================================*/ --26857

(
  v_TIMEKEY IN NUMBER,
  v_FlgPreErosion IN CHAR DEFAULT 'N' 
)
AS
    
BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
    V_Table_exists NUMBER(10);
   BEGIN
      DECLARE
         v_PANCARDFLAG CHAR(1) ;
         v_AADHARCARDFLAG CHAR(1) ;
         v_JointAccountFlag CHAR(1) ;
         v_UCFICFlag CHAR(1) ;
         ---------------------------------------------------------------------
         --START OF MODIFICATION--HANDLING OF ACCOUNTS WITH FUTURE NPA DATE
         ---------------------------------------------------------------------
         v_REF_DATE VARCHAR2(200);
         v_MAX NUMBER(10,0);
         v_MIN NUMBER(10,0);

      BEGIN
      
        SELECT 'Y' INTO v_PANCARDFLAG
           FROM RBL_MISDB_PROD.solutionglobalparameter
          WHERE  ParameterName = 'PAN Aadhar Dedup Integration'
                   AND ParameterValueAlt_Key = 1
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT 'Y' INTO v_AADHARCARDFLAG
           FROM RBL_MISDB_PROD.solutionglobalparameter
          WHERE  ParameterName = 'PAN Aadhar Dedup Integration'
                   AND ParameterValueAlt_Key = 1
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_JointAccountFlag
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'Joint Account'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
                   
         SELECT RefValue INTO v_UCFICFlag
           FROM MAIN_PRO.RefPeriod 
          WHERE  BusinessRule = 'UCFIC'
                   AND EffectiveFromTimeKey <= v_TIMEKEY
                   AND EffectiveToTimeKey >= v_TIMEKEY ;
         ---------------------------------------------------------------------
         --START OF MODIFICATION--HANDLING OF ACCOUNTS WITH FUTURE NPA DATE
         ---------------------------------------------------------------------
          SELECT Date_ INTO v_REF_DATE
           FROM RBL_MISDB_PROD.Automate_Advances 
          WHERE  EXT_FLG = 'Y' ;

      
         ----------------------------------Added by Prashant 03012023 as per ashish sir and amar sir ----------------------------------------------------------
            MERGE INTO GTT_ACCOUNTCAL A
            USING (SELECT A.ROWID row_id, 'CONDI_STD'
            FROM GTT_ACCOUNTCAL A
                   JOIN (
                             SELECT UcifEntityID 
                               FROM GTT_ACCOUNTCAL 
                              WHERE  FinalAssetClassAlt_Key > 1
                               GROUP BY UcifEntityID 
                            ) B   ON A.UcifEntityID = B.UcifEntityID
                   JOIN RBL_MISDB_PROD.DimProduct P   ON P.EffectiveFromTimeKey <= v_TIMEKEY
                   AND P.EffectiveToTimeKey >= v_TIMEKEY
                   AND P.ProductAlt_Key = A.ProductAlt_Key
                   AND P.ProductGroup = 'FDSEC' 
             WHERE ASSET_NORM = 'ALWYS_STD') src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.ASSET_NORM = 'CONDI_STD'
            ;
         ------------------------------------------------------------------------------------------------------------
         ----UPDATE  B SET B.finalAssetClassAlt_Key=1, FinalNpaDt =NULL
         ----FROM PRO.CustomerCal  A INNER JOIN PRO.AccountCal B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID AND (A.FlgProcessing='N')
         ---- WHERE A.Asset_Norm='ALWYS_STD'
         /*---update FINALAssetClassAlt_Key  of those account which are not synk customer asset class key---------------------*/
         MERGE INTO GTT_ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, CASE 
         WHEN A.Asset_Norm <> 'ALWYS_STD' THEN A.SysAssetClassAlt_Key
         ELSE ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
           FROM RBL_MISDB_PROD.DimAssetClass
          WHERE  DIMASSETCLASS.AssetClassShortName = 'STD'
                   AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                   AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
            END AS finalAssetClassAlt_Key
         FROM GTT_CustomerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.RefCustomerID = B.RefCustomerID
                AND ( NVL(A.FlgProcessing, 'N') = 'N' )
                AND A.RefCustomerID IS NOT NULL ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.finalAssetClassAlt_Key = src.finalAssetClassAlt_Key;
         MERGE INTO GTT_ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, CASE 
         WHEN A.Asset_Norm <> 'ALWYS_STD' THEN A.SysAssetClassAlt_Key
         ELSE ( SELECT DIMASSETCLASS.AssetClassAlt_Key 
           FROM RBL_MISDB_PROD.DimAssetClass
          WHERE  DIMASSETCLASS.AssetClassShortName = 'STD'
                   AND DIMASSETCLASS.EffectiveFromTimeKey <= v_TIMEKEY
                   AND DIMASSETCLASS.EffectiveToTimeKey >= v_TIMEKEY )
            END AS finalAssetClassAlt_Key
         FROM GTT_CustomerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
                AND ( NVL(A.FlgProcessing, 'N') = 'N' ) 
          WHERE A.SysAssetClassAlt_Key <> B.FinalAssetClassAlt_Key
           AND B.RefCustomerID IS NULL) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.finalAssetClassAlt_Key = src.finalAssetClassAlt_Key;
         /*---------------NPA DATE UPDATE CUSTOMER TO ACCOUNT LEVEL----------------------------------*/
         MERGE INTO GTT_ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, A.SYSNPA_DT
         FROM GTT_CustomerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE NVL(B.ASSET_NORM, 'NORMAL') <> 'ALWYS_STD'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )
           AND NVL(A.SysNPA_Dt, ' ') <> NVL(b.FinalNpaDt, ' ')
           AND NVL(A.FlgDeg, 'N') = 'Y') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FinalNpaDt = src.SYSNPA_DT;
         
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id
         FROM GTT_ACCOUNTCAL A 
          WHERE ASSET_NORM = 'ALWYS_STD') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FINALASSETCLASSALT_KEY = 1,
                                      A.FINALNPADT = NULL,
                                      A.DEGREASON = NULL;--- AND FINALASSETCLASSALT_KEY>1S_STD'
         /*------UPDATING DEG REASON  FOR ACCOUNT WHERE  NO DEFAULT IS THERE------ */
         MERGE INTO GTT_ACCOUNTCAL B
         USING (SELECT B.ROWID row_id, NULL
         FROM GTT_CustomerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE A.FLGDEG = 'Y'
           AND B.DEGREASON IS NULL
           AND B.ASSET_NORM <> 'ALWYS_STD'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = NULL;
         MERGE INTO GTT_ACCOUNTCAL B
         USING (SELECT B.ROWID row_id, 'PERCOLATION BY OTHER ACCOUNT' AS DEGREASON
         FROM GTT_CustomerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE A.FLGDEG = 'Y'
           AND B.DEGREASON IS NULL
           AND B.ASSET_NORM <> 'ALWYS_STD'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.DEGREASON = src.DEGREASON;
         
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.DEGREASON
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CustomerCal B   ON A.SOURCESYSTEMCUSTOMERID = B.SOURCESYSTEMCUSTOMERID 
          WHERE A.DEGREASON LIKE 'PERCOLATION BY OTHER ACCOUNT'
           AND A.FlgDeg = 'N') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;
         UPDATE GTT_CustomerCal
            SET SysNPA_Dt = v_REF_DATE
          WHERE  NVL(SysNPA_Dt, '1900-01-01') > v_REF_DATE;
         UPDATE GTT_ACCOUNTCAL
            SET FinalNpaDt = v_REF_DATE
          WHERE  NVL(FinalNpaDt, '1900-01-01') > v_REF_DATE;
         UPDATE GTT_CustomerCal
            SET SysNPA_Dt = v_REF_DATE
          WHERE  SysNPA_Dt IS NULL
           AND SysAssetClassAlt_Key > 1;
         UPDATE GTT_ACCOUNTCAL
            SET FinalNpaDt = v_REF_DATE
          WHERE  FinalNpaDt IS NULL
           AND FinalAssetClassAlt_Key > 1;
         --Added By Mandeep to mark customer NPA on the basis of CoBorrower Data(14-08-2023) Logic discussed with amar sir--------
         MERGE INTO MAIN_PRO.CoBorrowerCal A
         USING (SELECT A.ROWID row_id, B.FinalAssetClassAlt_Key, B.InitialAssetClassAlt_Key, B.Asset_Norm, B.FINALNPADT, B.InitialNpaDt, B.AccountEntityID, B.CustomerEntityID, B.UcifEntityID, B.DegReason --- Addded by mandeep 13102023 DegReason Update to Null Issue 30092023 Quater End Issue 

         FROM MAIN_PRO.CoBorrowerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.CustomerACID = B.CUSTOMERACID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClass_AltKey = src.FinalAssetClassAlt_Key,
                                      A.InitialAssetClass_AltKey = src.InitialAssetClassAlt_Key,
                                      A.Asset_Norm = src.Asset_Norm,
                                      A.FINALNPADT = src.FINALNPADT,
                                      A.InitialNpaDt = src.InitialNpaDt,
                                      A.AccountEntityid = src.AccountEntityID,
                                      A.Customerentityid = src.CustomerEntityID,
                                      A.UcifEntityID = src.UcifEntityID,
                                      A.DegradeReason = src.DegReason;
         v_MIN := 1 ;
         SELECT MAX(COUNT)  COUNT  

           INTO v_MAX
           FROM ( SELECT COUNT(UCIC)  COUNT  
                  FROM MAIN_PRO.CoBorrowerCal 
                    GROUP BY Cohort_No ) A;
         WHILE v_MAX >= v_MIN 
         LOOP 

            BEGIN
               MERGE INTO MAIN_PRO.CoBorrowerCal B 
               USING (SELECT B.ROWID row_id, A.FinalAssetClass_AltKey, A.FinalNpaDt, CONCAT(B.DegradeReason, ' Co Borrower NPA ' || A.NPA_UCIC_ID || ' UCIC Of Main') AS pos_4
               FROM MAIN_PRO.CoBorrowerCal A
                      JOIN MAIN_PRO.CoBorrowerCal B   ON B.MainCustID = A.CustomerID
                      AND A.CustomerType IN ( 'Coborrower','CO_OBLIGANT' )

                      AND A.FinalAssetClass_AltKey > 1
                      AND B.FinalAssetClass_AltKey = 1 ) src
               ON ( B.ROWID = src.row_id )
               WHEN MATCHED THEN UPDATE SET B.FinalAssetClass_AltKey = src.FinalAssetClass_AltKey,
                                            B.FINALNPADT = src.FinalNpaDt,
                                            B.DegradeReason = pos_4;
               v_MIN := v_MIN + 1 ;

            END;
         END LOOP;
         DELETE FROM tt_MAXASSETCLASS;
         UTILS.IDENTITY_RESET('tt_MAXASSETCLASS');

         INSERT INTO tt_MAXASSETCLASS ( 
         	SELECT Cohort_No ,
                 MAX(FinalAssetClass_AltKey)  FinalAssetClass_AltKey  ,
                 MIN(FinalNpaDt)  FinalNpaDt  
         	  FROM MAIN_PRO.CoBorrowerCal 
         	 WHERE  FinalAssetClass_AltKey > 1
         	  GROUP BY Cohort_No );
         MERGE INTO MAIN_PRO.CoBorrowerCal A
         USING (SELECT A.ROWID row_id, B.FinalAssetClass_AltKey, B.FinalNpaDt
         FROM MAIN_PRO.CoBorrowerCal A
                JOIN tt_MAXASSETCLASS B   ON A.Cohort_No = B.Cohort_No 
          WHERE A.FinalAssetClass_AltKey > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PERC_FinalAssetClass_AltKey = src.FinalAssetClass_AltKey,
                                      A.PERC_FinalNpaDt = src.FinalNpaDt;
         ----DROP TABLE IF EXISTS #MAXUCIC
         ----SELECT 
         ----UCIC,
         ----DegradeReason,
         ----MAX(PERC_FinalAssetClass_AltKey)FINALASSETCLASS_ALTKEY,
         ----MIN(PERC_FinalNpaDt)FinalNpaDt
         ----INTO #MAXUCIC
         ----FROM 
         ----PRO.CoborrowerCAL 
         ----where 
         ----FinalAssetClass_AltKey>1 group by UCIC,DegradeReason
         MERGE INTO GTT_CustomerCal A
         USING (SELECT A.ROWID row_id, B.PERC_FinalAssetClass_AltKey, B.PERC_FinalNpaDt
         --A.NPA_Reason=CONCAT(A.NPA_Reason,' ',b.DegradeReason),
          --A.DegReason=b.DegradeReason
         , CONCAT(CONCAT(b.DegradeReason ,' Percolated by Cohort No' ), B.Cohort_No) AS pos_4
         FROM GTT_CustomerCal A
                JOIN MAIN_PRO.CoBorrowerCal B   ON A.RefCustomerID = B.CustomerID 
          WHERE A.Asset_Norm NOT IN ( 'AlWYS_STD' )

           AND B.PERC_FinalAssetClass_AltKey > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = src.PERC_FinalAssetClass_AltKey,
                                      A.SysNPA_Dt = src.PERC_FinalNpaDt,
                                      A.DegReason -- Addded by mandeep 13102023 DegReason Update to Null Issue 
                                       = pos_4;
         ----------------------Added by prashant-------16112023---------------------
         MERGE INTO GTT_CustomerCal A
         USING (SELECT A.ROWID row_id, B.PERC_FinalAssetClass_AltKey, B.PERC_FinalNpaDt
         --A.NPA_Reason=CONCAT(A.NPA_Reason,' ',b.DegradeReason),
         , CONCAT(CONCAT(b.DegradeReason, ' Percolated by Cohort No'), B.Cohort_No) AS pos_4
         FROM GTT_CustomerCal A
                JOIN MAIN_PRO.CoBorrowerCal B   ON A.UCIF_ID = B.UCIC 
          WHERE A.Asset_Norm NOT IN ( 'AlWYS_STD' )

           AND B.PERC_FinalAssetClass_AltKey > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = src.PERC_FinalAssetClass_AltKey,
                                      A.SysNPA_Dt = src.PERC_FinalNpaDt,
                                      A.DegReason -- Addded by mandeep 13102023 DegReason Update to Null Issue 30092023 Quater End Issue 
                                       = pos_4;
         ---------------------------------------------------------------------
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.PERC_FinalAssetClass_AltKey, B.PERC_FinalNpaDt, (CASE 
         WHEN B.DegradeReason LIKE '%' || A.NPA_Reason || '%' THEN A.NPA_Reason
         ELSE CONCAT(CONCAT(A.NPA_Reason, ','), b.DegradeReason)
            END) AS pos_4, b.DegradeReason
         FROM GTT_ACCOUNTCAL A
                JOIN ( SELECT DISTINCT CoBorrowerCal.CUSTOMERACID ,
                                       CoBorrowerCal.PERC_FinalAssetClass_AltKey ,
                                       CoBorrowerCal.PERC_FinalNpaDt ,
                                       CoBorrowerCal.DegradeReason 
                       FROM MAIN_PRO.CoBorrowerCal  ) B   ON A.CustomerAcID = B.CustomerACID 
          WHERE A.Asset_Norm NOT IN ( 'AlWYS_STD' )

           AND B.PERC_FinalAssetClass_AltKey > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.PERC_FinalAssetClass_AltKey,
                                      A.FinalNpaDt = src.PERC_FinalNpaDt,
                                      A.NPA_Reason = pos_4,
                                      A.DegReason = src.DegradeReason;
         ------------------------------END of COborrower Degrade work --------------------------------------------------------------
         /*------------------------------UPDATE UNIFORM ASSET CLASSIFICATION--------------------------------*/
         --IF OBJECT_ID('TEMPDB..GTT_TEMPTABLE_UCFIC1') IS NOT NULL
         --   DROP TABLE GTT_TEMPTABLE_UCFIC1
         --/*07072021AMAR COMMENT  ED  JOIN FOR DIMDBSOURCE FOR PERCULATE AT UCIF LEVEL AS DISCUSSED WITH sHARMA SIR AND TRILOKI SIR */
         --SELECT UCIF_ID,MAX(ISNULL(SYSASSETCLASSALT_KEY,1)) SYSASSETCLASSALT_KEY
         --,MIN(SYSNPA_DT) SYSNPA_DT-- ,B.SourceDBName 
         -- INTO GTT_TEMPTABLE_UCFIC1 FROM PRO.CUSTOMERCAL A
         -- ---INNER JOIN DIMSOURCEDB  B ON B.SourceAlt_Key=A.SourceAlt_Key 
         -- --AND B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1)<>1
         --GROUP BY  UCIF_ID--,B.SourceDBName
         /* START PERCOLATION WORK -- AMAR 31082021 */

         IF v_FlgPreErosion = 'Y' THEN

         BEGIN
            MAIN_PRO.InvestmentDataProcessing(v_TimeKey) ;
            MAIN_PRO.DerivativeDataProcessing(v_TimeKey) ;

         END;
         END IF;

         /* MERGING DATA FOR ALL SOURCES FOR FIND LOWEST ASSET CLASS AND MIN NPA DATE */
        IF V_Table_exists = 1 Then
            Execute Immediate 'TRUNCATE Table CTE_PERC';
            DBMS_OUTPUT.PUT_LINE('Table Dropped and Re-Created!');
        Else 
            Execute Immediate 'CREATE GLOBAL TEMPORARY TABLE CTE_PERC
                                ON COMMIT DELETE ROWS 
                                AS  ( 
                                   SELECT UCIF_ID ,
                          MAX(NVL(SYSASSETCLASSALT_KEY, 1))  SYSASSETCLASSALT_KEY  ,
                          MIN(SYSNPA_DT)  SYSNPA_DT  ,
                          PercType  
                   FROM GTT_CustomerCal A WHERE 1=2;';
            DBMS_OUTPUT.PUT_LINE('New Table Created!');
    END IF;
    
         INSERT INTO CTE_PERC
         	SELECT * 
         	  FROM (  /* ADVANCE DATA */
                   SELECT UCIF_ID ,
                          MAX(NVL(SYSASSETCLASSALT_KEY, 1))  SYSASSETCLASSALT_KEY  ,
                          MIN(SYSNPA_DT)  SYSNPA_DT  ,
                          'ADV' PercType  
                   FROM GTT_CustomerCal A
                    WHERE  ( UCIF_ID IS NOT NULL
                             AND UCIF_ID <> '0' )
                             AND NVL(SYSASSETCLASSALT_KEY, 1) <> 1
                     GROUP BY UCIF_ID
                   UNION 
                    /* INVESTMENT DATA */
                   SELECT UcifId UCIF_ID  ,
                          MAX(NVL(FinalAssetClassAlt_Key, 1))  SYSASSETCLASSALT_KEY  ,
                          MIN(NPIDt)  SYSNPA_DT  ,
                          'INV' PercType  
                   FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                          JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId
                          AND A.EffectiveFromTimeKey <= v_TIMEKEY
                          AND A.EffectiveToTimeKey >= v_TIMEKEY
                          AND B.EffectiveFromTimeKey <= v_TIMEKEY
                          AND B.EffectiveToTimeKey >= v_TIMEKEY
                          JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
                          AND C.EffectiveFromTimeKey <= v_TIMEKEY
                          AND C.EffectiveToTimeKey >= v_TIMEKEY
                    WHERE  NVL(FinalAssetClassAlt_Key, 1) <> 1
                     GROUP BY UcifId
                   UNION 
                    /* DERIVATIVE DATA */
                   SELECT UCIC_ID ,
                          MAX(NVL(FinalAssetClassAlt_Key, 1))  SYSASSETCLASSALT_KEY  ,
                          MIN(NPIDt)  SYSNPA_DT  ,
                          'DER' PercType  
                   FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
                    WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                             AND A.EffectiveToTimeKey >= v_TIMEKEY
                             AND NVL(FinalAssetClassAlt_Key, 1) <> 1
                     GROUP BY UCIC_ID ) A ;
         /*  FIND LOWEST ASSET CLASS AND IN NPA DATE IN AALL SOURCES */
         IF utils.object_id('TEMPDB..GTT_TEMPTABLE_UCFIC1') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE_UCFIC1 ';
         END IF;
         DELETE FROM GTT_TEMPTABLE_UCFIC1;
         UTILS.IDENTITY_RESET('GTT_TEMPTABLE_UCFIC1');

             INSERT INTO GTT_TEMPTABLE_UCFIC1 ( 
         	SELECT UCIF_ID ,
                 MAX(SYSASSETCLASSALT_KEY)  SYSASSETCLASSALT_KEY  ,
                 MIN(SYSNPA_DT)  SYSNPA_DT  ,
                 'XXX' PercType  
         	  FROM CTE_PERC 
         	  GROUP BY UCIF_ID );
         MERGE INTO GTT_TEMPTABLE_UCFIC1 A
         USING (SELECT A.ROWID row_id, B.PercType
         FROM GTT_TEMPTABLE_UCFIC1 A
                JOIN CTE_PERC B   ON A.UCIF_ID = B.UCIF_ID
                AND A.SYSASSETCLASSALT_KEY = B.SYSASSETCLASSALT_KEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PercType = src.PercType;
         
         /*  UPDATE LOWEST ASSET CLASS AND MIN NPA DATE IN - ADVANCE DATA */
         
         MERGE INTO GTT_CustomerCal A
         USING (SELECT A.ROWID row_id, B.SYSASSETCLASSALT_KEY, B.SYSNPA_DT, CASE 
         WHEN A.SysAssetClassAlt_Key = 1
           AND B.SYSASSETCLASSALT_KEY > 1 THEN CASE 
                                                    WHEN B.PercType = 'INV' THEN 'PERCOLATION BY INVESTMENT UCIFID ' || B.UCIF_ID
                                                    WHEN B.PercType = 'DER' THEN 'PERCOLATION BY DERIVATIVE UCIFID ' || B.UCIF_ID
         ELSE A.DegReason
            END
         ELSE A.DegReason
            END AS pos_4
         FROM GTT_CustomerCal A
                JOIN GTT_TEMPTABLE_UCFIC1 B   ON A.UCIF_ID = B.UCIF_ID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = src.SYSASSETCLASSALT_KEY,
                                      A.SysNPA_Dt = src.SYSNPA_DT,
                                      A.DegReason = pos_4;
         /* UPDATE INVESTMENT DATA - LOWEST ASSET CLASS AND MIN NPA DATE */
         MERGE INTO CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
         USING (SELECT A.ROWID row_id, D.SYSASSETCLASSALT_KEY, D.SYSNPA_DT, CASE 
         WHEN A.FinalAssetClassAlt_Key = 1
           AND D.SYSASSETCLASSALT_KEY > 1 THEN CASE 
                                                    WHEN D.PercType = 'ADV' THEN 'PERCOLATION BY LOAN AC UCIFID ' || D.UCIF_ID
                                                    WHEN D.PercType = 'DER' THEN 'PERCOLATION BY DERIVATIVE UCIFID ' || D.UCIF_ID
         ELSE A.DegReason
            END
         ELSE A.DegReason
            END AS pos_4
         FROM CURDAT_RBL_MISDB_PROD.InvestmentFinancialDetail A
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentBasicDetail B   ON A.InvEntityId = B.InvEntityId
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY
                JOIN CURDAT_RBL_MISDB_PROD.InvestmentIssuerDetail C   ON C.IssuerEntityId = B.IssuerEntityId
                AND C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveToTimeKey >= v_TIMEKEY
                JOIN GTT_TEMPTABLE_UCFIC1 D   ON D.UCIF_ID = C.UcifId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.SYSASSETCLASSALT_KEY,
                                      A.NPIDt = src.SYSNPA_DT,
                                      A.DegReason = pos_4;
         /*  UPDATE   LOWEST ASSET CLASS AND MIN NPA DATE IN -  DERIVATIVE DATA */
         MERGE INTO CurDat_RBL_MISDB_PROD.DerivativeDetail A 
         USING (SELECT A.ROWID row_id, B.SYSASSETCLASSALT_KEY, SYSNPA_DT, CASE 
         WHEN A.FinalAssetClassAlt_Key = 1
           AND B.SYSASSETCLASSALT_KEY > 1 THEN CASE 
                                                    WHEN B.PercType = 'ADV' THEN 'PERCOLATION BY LOAN AC UCIFID ' || B.UCIF_ID
                                                    WHEN B.PercType = 'INV' THEN 'PERCOLATION BY INVESTMENT UCIFID ' || B.UCIF_ID
         ELSE A.DegReason
            END
         ELSE A.DegReason
            END AS pos_4
         FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
                JOIN GTT_TEMPTABLE_UCFIC1 B   ON A.UCIC_ID = B.UCIF_ID
                AND A.EffectiveFromTimeKey <= v_TIMEKEY
                AND A.EffectiveToTimeKey >= v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.SYSASSETCLASSALT_KEY,
                                      A.NPIDt = SYSNPA_DT,
                                      A.DegReason = pos_4;
         
         /* INVESTMENT AND DERVATIVE PROVISION CALCULATION */
       
         IF v_FlgPreErosion = 'N' THEN

         BEGIN
            MAIN_PRO.InvestmentDerivativeProvisionCal(v_TIMEKEY) ;

         END;
         END IF;
         
         /* END OF PERCOLATION WORK */
         /* BUYOUT - MARKING OF PERCoLATION/LiNCKED ACCOUNT NPA IN ADVANCE DATA FROM BUYOUT */
         

         DELETE FROM GTT_CTE_AA;
         UTILS.IDENTITY_RESET('GTT_CTE_AA');

         INSERT INTO GTT_CTE_AA ( 
         	SELECT UcifEntityID 
         	  FROM GTT_ACCOUNTCAL A
                   JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.AccountEntityID = B.AccountEntityId
         	 WHERE  ( FlgDeg = 'Y'
                    OR NVL(A.DPD_OVERDUE, 0) >= A.REFPERIODOVERDUE
                    OR NPA_ClassSeller = 'Y' )
                    AND Asset_Norm <> 'ALYWS_STD'
         	  GROUP BY UcifEntityID );
         /* REMOVE FLAG NPA_VDPD OR NPA_SELLER IN CASE OF SAME UCIF OTHER ACCOUNT DEGRADE  BY REFERENCE PERIOD */
         DELETE FROM GTT_CTE_BB;
         UTILS.IDENTITY_RESET('GTT_CTE_BB');

         INSERT INTO GTT_CTE_BB ( 
         	SELECT A.UcifEntityID 
         	  FROM GTT_CTE_AA A
                   JOIN GTT_ACCOUNTCAL B   ON A.UcifEntityID = B.UcifEntityID
                   LEFT JOIN MAIN_PRO.BuyoutUploadDetailsCal C   ON B.CustomerAcID = C.CustomerAcID
         	 WHERE  C.CustomerAcID IS NULL
                    AND ( B.FlgDeg = 'Y'
                    OR ( NVL(B.DPD_INTSERVICE, 0) >= B.REFPERIODINTSERVICE )
                    OR ( NVL(B.DPD_OVERDRAWN, 0) >= B.REFPERIODOVERDRAWN )
                    OR ( NVL(B.DPD_NOCREDIT, 0) >= B.REFPERIODNOCREDIT )
                    OR ( NVL(B.DPD_OVERDUE, 0) >= B.REFPERIODOVERDUE )
                    OR ( NVL(B.DPD_STOCKSTMT, 0) >= B.REFPERIODSTKSTATEMENT )
                    OR ( NVL(B.DPD_RENEWAL, 0) >= B.REFPERIODREVIEW ) )
         	  GROUP BY A.UcifEntityID );
         MERGE INTO MAIN_PRO.BuyoutUploadDetailsCal B
         USING (SELECT B.ROWID row_id, 'NPA_OTHERS'
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CTE_BB AA   ON A.UcifEntityID = A.UcifEntityID
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON B.AccountEntityId = A.AccountEntityId ) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.NPA_FLAG = 'NPA_OTHERS';
         /* END OF NPA FLAG UPDATE*/
         ----SELECT A.UcifEntityID INTO #BUYOUT_NPA_EFFCTD_TO_NRML_AC
         ----FROM GTT_CTE_AA A
         ----	INNER JOIN PRO.ACCOUNTCAL B
         ----		ON A.UcifEntityID =B.UcifEntityID
         ----		AND B.FlgDeg='N'
         ----		AND Asset_Norm<>'ALYWS_STD'
         ----EXCEPT				
         ----SELECT A.UcifEntityID 
         ----FROM GTT_CTE_AA A
         ----	INNER JOIN PRO.ACCOUNTCAL B
         ----		ON A.UcifEntityID =B.UcifEntityID
         ----	LEFT JOIN PRO.BuyoutUploadDetailsCal C
         ----		ON C.AccountEntityID=B.AccountEntityID
         ----	WHERE C.AccountEntityID IS NULL
         ----		AND (B.FlgDeg='Y'  
         ----					OR (ISNULL(B.DPD_INTSERVICE,0)>=B.REFPERIODINTSERVICE)
         ----					OR (ISNULL(B.DPD_OVERDRAWN,0)>=B.REFPERIODOVERDRAWN)
         ----					OR (ISNULL(B.DPD_NOCREDIT,0) >=B.REFPERIODNOCREDIT)
         ----					OR (ISNULL(B.DPD_OVERDUE,0)  >=B.REFPERIODOVERDUE)
         ----					OR (ISNULL(B.DPD_STOCKSTMT,0)>=B.REFPERIODSTKSTATEMENT)
         ----					OR (ISNULL(B.DPD_RENEWAL,0)  >=B.REFPERIODREVIEW)
         ----			)
         ----		AND Asset_Norm<>'ALYWS_STD'
         ----UPDATE A
         ----	SET A.NPA_EffectedToMainAdv=CASE WHEN C.UcifEntityID IS NULL THEN 'N' ELSE 'Y' END
         ----FROM PRO.BuyoutUploadDetailsCal A
         ----	INNER JOIN pro.ACCOUNTCAL B
         ----		ON A.AccountEntityID=B.AccountEntityID
         ----	 LEFT JOIN #BUYOUT_NPA_EFFCTD_TO_NRML_AC C
         ----		ON B.UcifEntityID=C.UcifEntityID
         /* END OF LOAN BUYOUT */

         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS pos_2, B.SysNPA_Dt
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CustomerCal B   ON A.RefCustomerID = B.RefCustomerID
                AND A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE NVL(B.SysAssetClassAlt_Key, 1) <> 1
           AND B.RefCustomerID <> '0') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = pos_2,
                                      A.FinalNpaDt = src.SysNPA_Dt;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS pos_2, B.SysNPA_Dt
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CustomerCal B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE NVL(B.SysAssetClassAlt_Key, 1) <> 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = pos_2,
                                      A.FinalNpaDt = src.SysNPA_Dt;
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS pos_2, B.SysNPA_Dt
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CustomerCal B   ON A.UcifEntityID = B.UcifEntityID 
          WHERE NVL(B.SysAssetClassAlt_Key, 1) <> 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = pos_2,
                                      A.FinalNpaDt = src.SysNPA_Dt;
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, B.DEGREASON
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CustomerCal B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'N' )
           AND B.DegReason IS NOT NULL
           AND A.FinalAssetClassAlt_Key > 1
           AND A.DegReason IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;
         MERGE INTO GTT_ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.DEGREASON
         FROM GTT_ACCOUNTCAL A
                JOIN GTT_CustomerCal B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE ( B.FlgProcessing = 'N' )
           AND ( A.FLGDEG = 'N' )
           AND B.DegReason IS NOT NULL
           AND A.FinalAssetClassAlt_Key > 1
           AND A.DegReason IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;
         ----UPDATE A SET DegReason='PERCOLATION BY UCIFID ' + ' ' + B.SourceDBName + '  ' + B.UCIF_ID 
         ----FROM PRO.CustomerCal A INNER JOIN GTT_TEMPTABLE_UCFIC1 B ON A.UCIF_ID=B.UCIF_ID
         ----WHERE A.SrcAssetClassAlt_Key=1 AND A.SysAssetClassAlt_Key>1
         ----AND A.DegReason IS NULL
         ---- IF OBJECT_ID('TEMPDB..#TEMPTABLE_UCFICDbtDt') IS NOT NULL
         ----   DROP TABLE #TEMPTABLE_UCFICDbtDt
         ----SELECT UcifEntityID,DbtDt
         ---- INTO #TEMPTABLE_UCFICDbtDt FROM PRO.CUSTOMERCAL
         ----WHERE ( UCIF_ID IS NOT NULL and UCIF_ID<>'0' ) AND  ISNULL(SYSASSETCLASSALT_KEY,1) IN(3,4,5)
         ---- AND DbtDt IS NOT NULL 
         ----GROUP BY  UcifEntityID,DbtDt
         ---- UPDATE B SET DbtDt =A.DbtDt FROM #TEMPTABLE_UCFICDbtDt A
         ----INNER JOIN PRO.CUSTOMERCAL B ON A.UcifEntityID=B.UcifEntityID	 AND B.DbtDt IS NULL
         MERGE INTO GTT_ACCOUNTCAL B 
         USING (SELECT B.ROWID row_id, A.SYSNPA_DT
         FROM GTT_CustomerCal A
                JOIN GTT_ACCOUNTCAL B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID 
          WHERE NVL(B.ASSET_NORM, 'NORMAL') <> 'ALWYS_STD'
           AND ( NVL(A.FlgProcessing, 'N') = 'N' )
           AND NVL(A.SysNPA_Dt, ' ') <> NVL(b.FinalNpaDt, ' ')
           AND NVL(A.FlgDeg, 'N') = 'N'
           AND A.RefCustomerID <> '0') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.FinalNpaDt = src.SYSNPA_DT;
         /*---------------UPDATE ASSET CLASS STD WHERE ASSET NORM ALWAYS STD---------------*/
         MERGE INTO GTT_ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id
         FROM GTT_ACCOUNTCAL A 
          WHERE A.ASSET_NORM = 'ALWYS_STD') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = 1,
                                      A.FinalNpaDt = NULL,
                                      A.DEGREASON = NULL;
         ---UPDATE  MULTIPLE   DegReason IN PRO.CUSTOMERCAL TABLE-------
         IF utils.object_id('TEMPDB..GTT_Data') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_Data ';
         END IF;
         DELETE FROM GTT_Data;
         UTILS.IDENTITY_RESET('GTT_Data');

         INSERT INTO GTT_Data ( 
         	SELECT DISTINCT DegReason ,
                          UcifEntityID 
         	  FROM GTT_ACCOUNTCAL 
         	 WHERE  DegReason IS NOT NULL
                    AND FLGDEG = 'Y' );
         IF utils.object_id('TEMPDB..GTT_NPADegReason') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_NPADegReason ';
         END IF;
         DELETE FROM GTT_NPADegReason;
         UTILS.IDENTITY_RESET('GTT_NPADegReason');

         INSERT INTO GTT_NPADegReason ( 
         	SELECT UcifEntityID ,
                 STRING_AGG(DegReason, ' ') DegReason  
         	  FROM GTT_Data 
         	  GROUP BY UcifEntityID );
         --IF object_id('TEMPDB..#DD') is NOT NULL
         --DROP TABLE #DD
         --Select SourceSystemCustomerID ,DegReason ,ROW_NUMBER()OVER(PARTITION by SourceSystemCustomerID order by SourceSystemCustomerID) AS RN  INTO #DD  FROM GTT_Data
         --IF object_id('TEMPDB..GTT_NPADegReason') is NOT NULL
         --DROP TABLE GTT_NPADegReason
         --SELECT SourceSystemCustomerID ,DegReason INTO GTT_NPADegReason FROM
         --(
         --Select SourceSystemCustomerID,([1] +ISNULL(' ,'+[2],'') +ISNULL(' ,' + [3],'')   +ISNULL(' ,' + [4],'')  +ISNULL(' ,' + [5],'')  +ISNULL(' ,' + [6],'')
         --+ISNULL(' ,' + [7],'')  +ISNULL(' ,' + [8],'')  +ISNULL(' ,' + [9],'')  +ISNULL(' ,' + [10],'')  +ISNULL(' ,' + [11],'')  +ISNULL(' ,' + [12],'')
         --+ISNULL(' ,' + [13],'')  +ISNULL(' ,' + [14],'')  +ISNULL(' ,' + [15],'')  +ISNULL(' ,' + [16],'')  +ISNULL(' ,' + [17],'')) AS DegReason
         --FROM(
         --Select SourceSystemCustomerID, DegReason,  RN FROM #DD  )a 
         --PIVOT 
         --(
         --MAX(DegReason)  FOR RN IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17])
         --) S
         --) A
         MERGE INTO GTT_CustomerCal A
         USING (SELECT A.ROWID row_id, B.DegReason
         FROM GTT_CustomerCal A
                JOIN GTT_NPADegReason B   ON A.UcifEntityID = B.UcifEntityID
                AND A.FlgDeg = 'Y' ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DegReason = src.DegReason;
         UPDATE GTT_CustomerCal
            SET FlgUpg = 'N'
          WHERE  SrcAssetClassAlt_Key = 1
           AND SysAssetClassAlt_Key > 1;
         UPDATE GTT_CustomerCal
            SET FlgDeg = 'N'
          WHERE  SrcAssetClassAlt_Key > 1
           AND SysAssetClassAlt_Key = 1;
         UPDATE GTT_ACCOUNTCAL
            SET FlgUpg = 'N',
                UpgDate = NULL
          WHERE  InitialAssetClassAlt_Key = 1
           AND FinalAssetClassAlt_Key > 1;
         UPDATE GTT_ACCOUNTCAL
            SET FlgDeg = 'N'
          WHERE  InitialAssetClassAlt_Key > 1
           AND FinalAssetClassAlt_Key = 1;
         IF v_FlgPreErosion = 'N' THEN

         BEGIN
            UPDATE MAIN_PRO.AclRunningProcessStatus
               SET COMPLETED = 'Y',
                   ERRORDATE = NULL,
                   ERRORDESCRIPTION = NULL,
                   COUNT = NVL(COUNT, 0) + 1
             WHERE  RUNNINGPROCESSNAME = 'Final_AssetClass_Npadate';

         END;
         END IF;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_Data ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_NPADegReason ';

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
       WHERE  RUNNINGPROCESSNAME = 'Final_AssetClass_Npadate';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."FINAL_ASSETCLASS_NPADATE" TO "ADF_CDR_RBL_STGDB";
