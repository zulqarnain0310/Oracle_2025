--------------------------------------------------------
--  DDL for Procedure INSERTDATAFORASSETCLASSFICATIONRBL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" /*=========================================  
  AUTHOR : TRILOKI KHANNA  
  CREATE DATE : 09-04-2021  
  MODIFY DATE : 09-04-2021  
  DESCRIPTION : Test Case Cover in This SP  

 RefCustomerID TestCase  
2 Degradation - Non Agri with Always STD = Y  
15 Degradation - CC/OD: Non Agri - Interest Servicing with Always STD = Y  
16 Degradation - CC/OD: Non Agri - Conti Excess Date with Always STD = Y  
17 Degradation - CC/OD: Non Agri - Last Credit Date with Always STD = Y  
18 Degradation - CC/OD: Non Agri - Stock Stmt Date with Always STD = Y  
19 Degradation - CC/OD: Non Agri - Last Review Due Date with Always STD = Y  
20 Degradation - CC/OD: Agri - Interest Servicing with Always STD = Y  
21 Degradation - CC/OD: Agri - Conti Excess Date with Always STD = Y  
22 Degradation - CC/OD: Agri - Last Credit Date with Always STD = Y  
23 Degradation - CC/OD: Agri - Last Review Due Date with Always STD = Y  
25 Degradation - Non Agri - Interest Servicing Conti Excess Date with Always STD =Y  
27 Degradation - Agri - Interest Servicing Conti Excess Date with Always STD =Y  
29 Degradation - Non Agri - Interest Servicing Conti Excess Date Last Credit Date with Always STD =Y  
31 Degradation - Agri - Interest Servicing Conti Excess Date Last Credit Date with Always STD =Y  
33 Degradation - Non Agri - Interest Servicing Conti Excess Date Last Credit Date Stock Stmt Date with Always STD =Y  
35 Degradation - Agri - Interest Servicing Conti Excess Date Last Credit Date Last Review Due Date with Always STD =Y  
37 Degradation - Non Agri -OverDue Interest Servicing Conti Excess Date Last Credit Date Stock Stmt Date Last Review Due Date with Always STD =Y  
46 NULL  
118 Identification of SMA-0 (Always_STD Ac)  
65 Security Valuation date validations - Current Asset Expired  
66 Security Valuation date validations - Current Asset Active  
67 Security Valuation date validations - Fixed Asset Expired  
68 Security Valuation date validations - Fixed Asset Active  
69 Security Valuation date validations - Permanent Asset Expired  
70 Security Valuation date validations - Permanent Asset Active  
76 Populaton of Secured Amount - FlgSecured = S  
77 Populaton of Secured Amount - FlgSecured = U  
78 Populaton of UnSecured Amount - FlgSecured = S  
79 Populaton of UnSecured Amount - FlgSecured = U  
92 Populaton of Secured Amount - FlgSecured = C  
93 Populaton of UnSecured Amount - FlgSecured = C  

=============================================*/
/*=========================================  
 AUTHER : TRILOKI SHNAKER KHANNA  
 CREATE DATE : 27-11-2019  
 MODIFY DATE : 27-11-2019  
 DESCRIPTION : INSERT DATA FOR PRO.CUSTOMER CAL AND PRO.ACCOUNT CAL TABLE AND UPDATE SOME OTHER COLUMN  
EXEC [PRO].[InsertDataforAssetClassficationRBL] @TIMEKEY=@26090,@BRANCHCODE=NULL,@ISMOC='N'  
=============================================*/
------select * from RBL_MISDB_PROD.SysDayMatrix where date='2021-06-06'  

(
  v_TIMEKEY IN NUMBER,
  v_BRANCHCODE IN VARCHAR2 DEFAULT NULL ,
  v_ISMOC IN CHAR DEFAULT 'N' 
)
AS

BEGIN
    DECLARE V_SQLERRM VARCHAR(150);
   BEGIN
      DECLARE
         v_temp NUMBER(1, 0) := 0;
         -- DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')  
         --DECLARE @TimeKey  Int =(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')  
         v_ProcessingDate VARCHAR2(200) ;
         v_SETID NUMBER(10,0) ;
         v_LastQtrDateKey NUMBER(10,0);
         v_LastMonthDateKey NUMBER(10,0);
         v_PrvDateKey NUMBER(10,0);
         v_PROCESSMONTH VARCHAR2(200);
         v_PROCESSDAY VARCHAR2(10) ;
         --DECLARE @PANCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='PANCARDNO' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)  
         --DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='AADHARCARD' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)  
         v_PANCARDFLAG CHAR(1) ;
         v_AADHARCARDFLAG CHAR(1) ;
         v_JOINTACCOUNTFLAG CHAR(1) ;
         v_UCFICFLAG CHAR(1) ;
         --DECLARE @QtrFlg char=(select (CASE WHEN Day(@ProcessingDate)=DAY(EOMONTH(@ProcessingDate)) AND MONTH(@ProcessingDate) IN(3,6,9,12)    THEN 'Y' END) QtrFlg)  
         v_6MnthBackTimeKey NUMBER(5,0);
         v_6MonthBackDate VARCHAR2(200);
         v_HistTimeKey NUMBER(10,0) := 0;
         /* END OF ADHOC CHAMGE */
         /* AMAR - 20092021 - CHNAGES FOR MOC ACL MANUAL EFFECT IN NORMAL PROCESSING */
         /* MOC TYPE AUTO EFFECT REQUIRED ONLY ONCE FOR DAILY NORMAL PROCESS  */
         v_PrevQtrTimeKey INT;

      BEGIN
      
       SELECT DATE_ INTO v_ProcessingDate 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TIMEKEY = v_TIMEKEY ;
         SELECT NVL(MAX(NVL(SETID, 0)) , 0) + 1 INTO v_SETID 
           FROM MAIN_PRO.ProcessMonitor 
          WHERE  TIMEKEY = v_TIMEKEY ;
         SELECT LastQtrDateKey INTO v_LastQtrDateKey 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  timekey = v_TIMEKEY ;
         SELECT LastMonthDateKey INTO v_LastMonthDateKey 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  timekey = v_TIMEKEY ;
         SELECT timekey - 1 INTO v_PrvDateKey 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;
         SELECT date_ INTO v_PROCESSMONTH 
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY ;
         SELECT  utils.datename('WEEKDAY', ( SELECT date_ 
                                     FROM RBL_MISDB_PROD.SysDayMatrix 
                                      WHERE  TimeKey = v_TIMEKEY )) INTO v_PROCESSDAY  FROM DUAL;
         
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
                   
         SELECT REFVALUE INTO v_JOINTACCOUNTFLAG
           FROM MAIN_PRO.RefPeriod 
          WHERE  BUSINESSRULE = 'JOINT ACCOUNT'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
                   
         SELECT REFVALUE INTO v_UCFICFLAG
           FROM MAIN_PRO.RefPeriod 
          WHERE  BUSINESSRULE = 'UCFIC'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY ;
         
         SELECT LastQtrDateKey INTO v_PrevQtrTimeKey
           FROM RBL_MISDB_PROD.SysDayMatrix 
          WHERE  Timekey = v_TIMEKEY ;
          
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM MAIN_PRO.AccountCal_Hist 
                             WHERE  EffectiveFromTimeKey > v_TIMEKEY );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            utils.raiserror( 0, 'You are going to process for wrong date, Please check....' );

         END;
         END IF;
         v_6MonthBackDate := utils.dateadd('M', -6, v_ProcessingDate) ;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.CUSTOMERCAL ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.ACCOUNTCAL ';
         DELETE MAIN_PRO.ProcessMonitor

          WHERE  TIMEKEY = v_TIMEKEY;
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'N',
                COUNT = 0,
                ERRORDESCRIPTION = NULL,
                ERRORDATE = NULL;
         --ALTER INDEX INDEX_CUSTOMERENTITYID ON PRO.CUSTOMERCAL DISABLE  
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'INSERT DATA FOR PRO.CUSTOMERCAL CAL TABLE' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         /*--------------INSERT DATA FOR PRO.CUSTOMERCAL CAL TABLE--------------------------*/
         INSERT INTO MAIN_PRO.CUSTOMERCAL
           ( EffectiveFromTimeKey, EffectiveToTimeKey, BRANCHCODE, CUSTOMERENTITYID, RefCustomerID, CUSTOMERNAME, CONSTITUTIONALT_KEY, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, SrcNPA_Dt, SysNPA_Dt, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceSystemCustomerID, Asset_Norm, UCIF_ID, UcifEntityID, SourceAlt_Key, IsChanged )
           ( SELECT v_TIMEKEY EffectiveFromTimeKey  ,
                    v_TIMEKEY EffectiveToTimeKey  ,
                    ParentBranchCode BRANCHCODE  ,
                    CBD.CUSTOMERENTITYID ,
                    CBD.CUSTOMERID ,
                    CBD.CUSTOMERNAME ,
                    CBD.ConstitutionAlt_Key ,
                    'N' FlgDeg  ,
                    'N' FlgUpg  ,
                    'N' FlgMoc  ,
                    'N' FlgSMA  ,
                    'N' FlgProcessing  ,
                    'N' FlgErosion  ,
                    'N' FlgPNPA  ,
                    'N' FlgPercolation  ,
                    'N' FlgInMonth  ,
                    'N' FlgDirtyRow  ,
                    NULL SrcNPA_Dt  ,
                    NULL SysNPA_Dt  ,
                    0 SplCatg1Alt_Key  ,
                    0 SplCatg2Alt_Key  ,
                    0 SplCatg3Alt_Key  ,
                    0 SplCatg4Alt_Key  ,
                    CBD.CustomerId SourceSystemCustomerID  ,
                    'NORMAL' Asset_Norm  ,
                    UCIF_ID ,
                    UcifEntityID ,
                    CBD.SourceSystemAlt_Key ,
                    'N' IsChanged  
             FROM CURDAT_RBL_MISDB_PROD.CustomerBasicDetail CBD
                    JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId

                    --AND UCIF_ID in ('RBL021860250','RBL021860949') --('RBL008207712','RBL009695189','RBL003952108','RBL021433631','RBL008739785','RBL008752172','RBL007820628','RBL008395100')  
                    AND UcifEntityID IN ( 260712,43236654,11405002 )

              WHERE  ( CBD.EffectiveFromTimeKey <= v_TIMEKEY
                       AND CBD.EffectiveToTimeKey >= v_TIMEKEY )
                       AND ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                       AND ABD.EffectiveToTimeKey >= v_TIMEKEY )
                       AND (CASE 
                                 WHEN v_BRANCHCODE IS NULL
                                   AND v_ISMOC = 'N' THEN '0'
                                 WHEN v_BRANCHCODE IS NULL
                                   AND v_ISMOC = 'Y' THEN CBD.MocStatus
                                 WHEN v_BRANCHCODE IS NOT NULL
                                   AND v_ISMOC = 'N' THEN CBD.CustomerId   END) IN ( CASE 
                                                                                          WHEN v_BRANCHCODE IS NULL
                                                                                            AND v_ISMOC = 'N' THEN '0'
                                                                                          WHEN v_BRANCHCODE IS NULL
                                                                                            AND v_ISMOC = 'Y' THEN 'Y'
                                                                                          WHEN v_BRANCHCODE IS NOT NULL
                                                                                            AND v_ISMOC = 'N' THEN ( SELECT ACFD.REFCustomerId 
                                                                                                                     FROM CurDat_RBL_MISDB_PROD.ADVCUSTFINANCIALDETAIL ACFD
                                                                                                                      WHERE  ACFD.EffectiveFromTimeKey <= v_TIMEKEY
                                                                                                                               AND ACFD.EffectiveToTimeKey >= v_TIMEKEY
                                                                                                                               AND BranchCode = v_BRANCHCODE
                                                                                                                       GROUP BY ACFD.REFCustomerId )   END )

               GROUP BY ParentBranchCode,CBD.CUSTOMERENTITYID,CBD.CUSTOMERID,CBD.CUSTOMERNAME,CBD.ConstitutionAlt_Key,CBD.UCIF_ID,CBD.UcifEntityID,CBD.SourceSystemAlt_Key );
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  
          --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'INSERT DATA FOR PRO.CUSTOMERCAL CAL TABLE';
         /*------------------ACCOUNT DATA INSERT------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'INSERT DATA IN ACCOUNTCAL TABLE' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         INSERT INTO MAIN_PRO.ACCOUNTCAL
           ( ACCOUNTENTITYID, CUSTOMERACID, FLGDEG, FLGDIRTYROW, FLGINMONTH, FLGSMA, FLGPNPA, FLGUPG, FLGFITL, FLGABINITIO, REFPERIODOVERDUEUPG, REFPERIODOVERDRAWNUPG, REFPERIODNOCREDITUPG, REFPERIODINTSERVICEUPG, REFPERIODSTKSTATEMENTUPG, REFPERIODREVIEWUPG, EFFECTIVEFROMTIMEKEY, EFFECTIVETOTIMEKEY, ASSET_NORM, SPLCATG1ALT_KEY, SPLCATG2ALT_KEY, SPLCATG3ALT_KEY, SPLCATG4ALT_KEY, BALANCE, BALANCEINCRNCY, NETBALANCE, CURRENCYALT_KEY, SOURCEALT_KEY, SECAPP, PROVCOVERGOVGUR, BANKPROVSECURED, BANKPROVUNSECURED, BANKTOTALPROVISION, RBIPROVSECURED, RBIPROVUNSECURED, RBITOTALPROVISION, APPGOVGUR, USEDRV, COMPUTEDCLAIM, PROVPERSECURED, PROVPERUNSECURED, REFPERIODOVERDUE, REFPERIODOVERDRAWN, REFPERIODNOCREDIT, REFPERIODINTSERVICE, REFPERIODSTKSTATEMENT, REFPERIODREVIEW, INITIALASSETCLASSALT_KEY, FINALASSETCLASSALT_KEY, RefCustomerID, SourceSystemCustomerID, CUSTOMERENTITYID, BranchCode, ProductAlt_Key, CURRENTLIMIT, CURRENTLIMITDT, SchemeAlt_Key, SubSectorAlt_Key, FacilityType, InttRate, AcOpenDt, FirstDtOfDisb, PrvAssetClassAlt_Key, FlgSecured, UCIF_ID, UcifEntityID, ActSegmentCode, IsChanged )
           ( SELECT ACCOUNTENTITYID ACCOUNTENTITYID  ,
                    CUSTOMERACID CUSTOMERACID  ,
                    'N' FLGDEG  ,
                    'N' FLGDIRTYROW  ,
                    'N' FLGINMONTH  ,
                    'N' FLGSMA  ,
                    'N' FLGPNPA  ,
                    'N' FLGUPG  ,
                    'N' FLGFITL  ,
                    'N' FLGABINITIO  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDUEUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDUEUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDRAWNUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDRAWNUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODNOCREDITUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODNOCREDITUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODINTSERVICEUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODINTSERVICEUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODSTKSTATEMENTUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODSTKSTATEMENTUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODREVIEWUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODREVIEWUPG  ,
                    v_TIMEKEY EFFECTIVEFROMTIMEKEY  ,
                    v_TIMEKEY EFFECTIVETOTIMEKEY  ,
                    'NORMAL' ASSET_NORM  ,
                    0 SPLCATG1ALT_KEY  ,
                    0 SPLCATG2ALT_KEY  ,
                    0 SPLCATG3ALT_KEY  ,
                    0 SPLCATG4ALT_KEY  ,
                    0.00 BALANCE  ,
                    0.00 BALANCEINCRNCY  ,
                    0.00 NETBALANCE  ,
                    62 CURRENCYALT_KEY  ,
                    ABD.SOURCEALT_KEY SOURCEALT_KEY  ,
                    abd.FlgSecured SecApp  ,
                    0.00 PROVCOVERGOVGUR  ,
                    0.00 BANKPROVSECURED  ,
                    0.00 BANKPROVUNSECURED  ,
                    0.00 BANKTOTALPROVISION  ,
                    0.00 RBIPROVSECURED  ,
                    0.00 RBIPROVUNSECURED  ,
                    0.00 RBITOTALPROVISION  ,
                    0.00 APPGOVGUR  ,
                    0.00 USEDRV  ,
                    0.00 COMPUTEDCLAIM  ,
                    0.00 PROVPERSECURED  ,
                    0.00 PROVPERUNSECURED  ,
                    ( SELECT REFVALUE 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDUE'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDUE  ,
                    ( SELECT REFVALUE 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDRAWN'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDRAWN  ,
                    ( SELECT REFVALUE 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODNOCREDIT'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODNOCREDIT  ,
                    ( SELECT REFVALUE 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODINTSERVICE'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODINTSERVICE  ,
                    ( SELECT REFVALUE 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODSTKSTATEMENT'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODSTKSTATEMENT  ,
                    ( SELECT REFVALUE 
                      FROM MAIN_PRO.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODREVIEW'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODREVIEW  ,
                    1 INITIALASSETCLASSALT_KEY  ,
                    1 FINALASSETCLASSALT_KEY  ,
                    ABD.RefCustomerID RefCustomerID  ,
                    ABD.RefCustomerID SourceSystemCustomerID  ,
                    CBD.CUSTOMERENTITYID ,
                    ABD.BRANCHCODE ,
                    ABD.ProductAlt_Key ,
                    ABD.CURRENTLIMIT ,
                    ABD.CURRENTLIMITDT ,
                    ABD.SchemeAlt_Key ,
                    ABD.SubSectorAlt_Key ,
                    ABD.FacilityType ,
                    ABD.Pref_InttRate InttRate  ,
                    ABD.AccountOpenDate AcOpenDt  ,
                    ABD.DtofFirstDisb FirstDtOfDisb  ,
                    1 PrvAssetClassAlt_Key  ,
                    'U' FlgSecured ,--ABD.FlgSecured AS FlgSecured  

                    CBD.UCIF_ID ,
                    CBD.UcifEntityID ,
                    abd.segmentcode ,
                    'N' IsChanged  
             FROM CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail ABD
                    JOIN MAIN_PRO.CUSTOMERCAL CBD   ON abd.CUSTOMERENTITYID = CBD.CUSTOMERENTITYID
                    LEFT JOIN RBL_MISDB_PROD.DimGLProduct C   ON C.GLProductAlt_Key = ABD.GLProductAlt_Key
                    AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                    AND C.EffectiveToTimeKey >= v_TIMEKEY )
              WHERE  ( ABD.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND ABD.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
               GROUP BY ABD.BRANCHCODE,ABD.CUSTOMERENTITYID,ABD.ACCOUNTENTITYID,ABD.SYSTEMACID,ABD.CUSTOMERACID,ABD.GLALT_KEY,ABD.GLPRODUCTALT_KEY,ABD.PRODUCTALT_KEY,ABD.SEGMENTCODE,ABD.ACCOUNTOPENDATE,ABD.FacilityType,ABD.DTOFFIRSTDISB,ABD.CURRENTLIMIT,ABD.CURRENTLIMITDT,ABD.CURRENCYALT_KEY,ABD.REFCUSTOMERID,ABD.SCHEMEALT_KEY,ABD.ACTIVITYALT_KEY,ABD.InttTypeAlt_Key,ABD.SubSectorAlt_Key,ABD.OriginalLimitDt,CBD.CUSTOMERENTITYID,ABD.Pref_InttRate,ABD.SOURCEALT_KEY,CBD.UCIF_ID,CBD.UcifEntityID,ABD.FlgSecured );
         /* starts of temporary updates*/
         --DELETE A  -- DELETE CHARGE OFF ACCOUNTS IN VISION PLUS  
         --FROM PRO.ACCOUNTCAL A  
         -- INNER JOIN RBL_STGDB.DBO.ACCOUNT_ALL_SOURCE_SYSTEM B  
         --  ON A.CustomerAcID=B.CustomerAcID   
         --  AND ChargeoffY_N ='Y'  
         /* delete chargeoff data */
            DELETE MAIN_PRO.ACCOUNTCAL A
            WHERE ROWID IN 
         ( SELECT A.ROWID
           FROM MAIN_PRO.ACCOUNTCAL A
                  LEFT JOIN CURDAT_RBL_MISDB_PROD.AdvFacCreditCardDetail B   ON A.AccountEntityId = B.AccountEntityId
                  AND b.EffectiveFromTimeKey <= v_TIMEKEY
                  AND b.EffectiveToTimeKey >= v_TIMEKEY
                     WHERE  a.SourceAlt_Key = 6
                   AND B.AccountEntityId IS NULL );

         DELETE FROM MAIN_PRO.CUSTOMERCAL A
          WHERE ROWID IN 
         ( SELECT A.ROWID
           FROM MAIN_PRO.CUSTOMERCAL A
                  LEFT JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
          WHERE  B.CustomerEntityID IS NULL );

         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  
          --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'INSERT DATA IN ACCOUNTCAL TABLE';
         /*------------------UPDATE PANNO IN CUSTOMER CAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE PANNO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, B.PAN
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId 
          WHERE ( REGEXP_LIKE(B.PAN, '%[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]%') )
           AND ( B.PAN NOT LIKE '%FORMO%'
           AND PAN NOT LIKE '%FORPM%'
           AND PAN NOT LIKE '%FORMF%' )
           AND ( B.PAN IS NOT NULL )
           AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PANNO = src.PAN;
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORMO6161O';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORPM6060F';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORPM6060P';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORMF6060F';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'AAAAA1111A';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PANNO';
         /*------------------UPDATE AADHAR NUMBER IN CUSTOMER CAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE AADHAR NUMBER IN CUSTOMER CAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, B.AadhaarId
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId 
          WHERE LENGTH(LTRIM(RTRIM(B.AadhaarId))) = 12
           AND REGEXP_LIKE(B.AadhaarId, '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
           AND ( B.AadhaarId IS NOT NULL )
           AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AADHARCARDNO = src.AadhaarId;
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '000000000000';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '111111111111';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '222222222222';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '333333333333';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '444444444444';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '555555555555';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '666666666666';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '777777777777';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '888888888888';
         UPDATE MAIN_PRO.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '999999999999';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE AADHAR NUMBER IN CUSTOMER CAL';
         ----/*------------------INSERT INVALID PANCARDNO|AADHARCARDNO------------------*/  
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'INSERT INVALID PANCARDNO|AADHARCARDNO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         DELETE MAIN_PRO.InvalidPanAadhar

          WHERE  EFFECTIVEFROMTIMEKEY = v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY = v_TIMEKEY;
         INSERT INTO MAIN_PRO.InvalidPanAadhar
           ( DATEOFDATA, CUSTOMERID, SOURCESYSTEMCUSTOMERID, CUSTOMERNAME, SOURCESYSTEMNAME, PANNO, AADHARCARD, EFFECTIVEFROMTIMEKEY, EFFECTIVETOTIMEKEY )
           ( SELECT v_PROCESSINGDATE ,
                    A.RefCustomerID ,
                    A.SourceSystemCustomerID ,
                    A.CustomerName ,
                    NULL SOURCESYSTEMNAME  ,
                    B.PAN ,
                    NULL ,
                    v_TIMEKEY ,
                    v_TIMEKEY 
             FROM MAIN_PRO.CUSTOMERCAL A
                    JOIN CURDAT_RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId
              WHERE  ( REGEXP_LIKE(B.PAN, '%[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]%') )
                       AND ( B.PAN IS NOT NULL )
                       AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
             UNION 
             SELECT v_PROCESSINGDATE ,
                    A.RefCustomerID ,
                    A.SourceSystemCustomerID ,
                    A.CustomerName ,
                    NULL SOURCESYSTEMNAME  ,
                    B.PAN ,
                    NULL ,
                    v_TIMEKEY ,
                    v_TIMEKEY 
             FROM MAIN_PRO.CUSTOMERCAL A
                    JOIN CURDAT_RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId
              WHERE  ( B.PAN LIKE '%FORMO%'
                       OR B.PAN LIKE '%FORPM%'
                       OR B.PAN LIKE '%FORMF%' )
                       AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         INSERT INTO MAIN_PRO.InvalidPanAadhar
           ( DATEOFDATA, CUSTOMERID, SOURCESYSTEMCUSTOMERID, CUSTOMERNAME, SOURCESYSTEMNAME, PANNO, AADHARCARD, EFFECTIVEFROMTIMEKEY, EFFECTIVETOTIMEKEY )
           ( SELECT v_PROCESSINGDATE ,
                    A.RefCustomerID ,
                    A.SourceSystemCustomerID ,
                    A.CustomerName ,
                    NULL SOURCESYSTEMNAME  ,
                    NULL ,
                    B.AadhaarId ,
                    v_TIMEKEY ,
                    v_TIMEKEY 
             FROM MAIN_PRO.CUSTOMERCAL A
                    JOIN CURDAT_RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId
              WHERE  REGEXP_LIKE(B.AadhaarId, '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
                       AND ( B.AadhaarId IS NOT NULL )
                       AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'INSERT INVALID PANCARDNO|AADHARCARDNO';
         /*-------------UPDATE ProductCode IN ACCOUNTCAL-------------------------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE ProductCode IN ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required  Modification Done---   
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, C.ProductCode
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID
                JOIN RBL_MISDB_PROD.DimProduct C   ON B.ProductAlt_Key = C.ProductAlt_Key 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
           AND C.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ProductCode = src.ProductCode;
         
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
            TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE ProductCode IN ACCOUNTCAL';
         ---Condition Change Required  Modification Done---   
         /*------------********UPDATE DRAWINGPOWER|REVIEWDUEDT FOR ALL ACCOUNT******--------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE DRAWINGPOWER|REVIEWDUEDT FOR ALL ACCOUNT' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.DRAWINGPOWER, 0) AS pos_2, B.Ac_NextReviewDueDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcFinancialDetail B   ON ( B.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                AND B.EFFECTIVETOTIMEKEY >= v_TimeKey )
                AND A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DRAWINGPOWER
                                      --A.ReviewDueDt= (case when FACILITYTYPE in('DL','TL','PC','BP','BD') then null else  B.Ac_NextReviewDueDt   end )  
                                       = pos_2,
                                      A.ReviewDueDt = src.Ac_NextReviewDueDt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  
          --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE DRAWINGPOWER|REVIEWDUEDT FOR ALL ACCOUNT';
         /*------------********UPDATE FacilityType FOR TLDL ACCOUNT******--------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Asset_Norm|FacilityType ISLAD  ACCOUNT' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required  Modification Done---   
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND NVL(B.ISLAD, 0) = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm --'CONDI_STD'  
                                       = 'ALWYS_STD';
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND assetclass = '1') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_STD';
         
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND assetclass = '2') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA';
         ---Condition Change Required  Modification Done---    
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  
          --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Asset_Norm|FacilityType ISLAD  ACCOUNT';
         /*-------------UPDATE BANK ASSET CLASSIFICATION IN ACCOUNTCALL------------------------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE BANK ASSET CLASSIFICATION IN ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.SourceAssetClass, C.AssetClassMappingAlt_Key
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveFromTimeKey > v_TIMEKEY
                LEFT JOIN RBL_MISDB_PROD.DimAssetClassMapping C   ON C.SrcSysClassCode = A.AccountStatus
                AND A.SourceAlt_Key = C.SourceAlt_Key
                AND C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveFromTimeKey > v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AccountStatus = src.SourceAssetClass,
                                      A.BankAssetClass = src.AssetClassMappingAlt_Key;
         ----------UPDATE  pro.AccountCal  
         ----------SET pro.AccountCal.BankAssetClass =C.AssetClassAlt_Key  
         ----------   FROM pro.AccountCal A  
         ----------  INNER JOIN CURDAT_RBL_MISDB_PROD.AdvAcBalanceDetail B  
         ----------   ON A.AccountEntityID=B.AccountEntityID  
         ----------  Inner Join RBL_MISDB_PROD.DimAssetClassMapping C ON C.SrcSysClassCode=A.AccountStatus  
         ----------   And C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveFromTimeKey>@TIMEKEY  
         ----------   WHERE B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveFromTimeKey>@TIMEKEY  
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE BANK ASSET CLASSIFICATION IN ACCOUNTCAL';
         /*------------********UPDATE ContiExcessDt FOR CC ACCOUNT******--------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE ContiExcessDt FOR CC ACCOUNT' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required Modification Done ----   
         --Need to uncomment for Full ACL 
         --IF @TIMEKEY >26267  
         --BEGIN  
         -- EXEC PRO.ContExcsSinceDt  -- COMMENEDT BY AMAR ON 12-06-2021 BANK IS PROVIDING IN SOURCE DATA  
         --END  
         IF v_TIMEKEY = 26418 THEN

         BEGIN
            INSERT INTO MAIN_PRO.ContExcsSinceDtAccountCal
              ( CustomerAcID, AccountEntityId, SanctionAmt, SanctionDt, Balance, DrawingPower, ContExcsSinceDt, EffectiveFromTimeKey, EffectiveToTimeKey )
              ( SELECT A.CustomerAcID ,
                       A.AccountEntityId ,
                       currentLimit SanctionAmt  ,
                       CurrentLimitDt SanctionDt  ,
                       c.Balance ,
                       DrawingPower ,
                       ContExcsSinceDt ,
                       26418 EffectiveFromTimeKey  ,
                       49999 
                FROM RBL_TEMPDB.TempAdvAcBasicDetail A
                       JOIN RBL_TEMPDB.TempAdvFacCCDetail B   ON A.AccountEntityId = B.AccountEntityId
                       JOIN RBL_TEMPDB.TempAdvAcBalanceDetail C   ON C.AccountEntityId = A.AccountEntityId
                       JOIN RBL_TEMPDB.TempAdvAcBalanceDetail D   ON D.AccountEntityId = A.AccountEntityId
                       JOIN RBL_TEMPDB.TempAdvAcFinancialDetail E   ON E.AccountEntityId = A.AccountEntityId
                 WHERE  ContExcsSinceDt IS NOT NULL
                          AND a.ProductAlt_Key = 358 );

         END;
         END IF;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.ContExcsSinceDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.ContExcsSinceDtAccountCal B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ContiExcessDt = src.ContExcsSinceDt;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.ContExcsSinceDebitDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.ContExcsSinceDtDebitAccountCal B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DebitSinceDt = src.ContExcsSinceDebitDt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE ContiExcessDt FOR CC ACCOUNT';
         /*---------------******UPDATE Balance,OverdueAmt,OverDueSinceDt,BalanceInCrncy and LastCrDate  FROM CURDAT_RBL_MISDB_PROD.AdvAcBalanceDetail*******----------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Balance,LastCrDate,CreditsinceDt FOR ALL ACCOUNT' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.Balance, CASE 
         WHEN NVL(DebitSinceDt, '1900-01-01') > NVL(LastCrDt, '1900-01-01') THEN NULL
         ELSE (CASE 
         WHEN FacilityType IN ( 'DL','TL','BP','BD','PC' )
          THEN NULL
         ELSE B.LastCrDt
            END)
            END AS pos_3, B.LastCrDt, B.MocTypeAlt_Key, B.MocStatus, B.MocDate, B.OverDueSinceDt, B.OverDue, B.OverduePrincipal, B.Overdueinterest, B.PrincipalBalance, B.AdvanceRecovery, B.NotionalInttAmt, B.DFVAmt, B.OverduePrincipalDt, B.OverdueIntDt, B.OverOtherdue, B.OverdueOtherDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBalanceDetail B   ON ( B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                AND A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Balance = src.Balance,
                                      A.LastCrDate = pos_3,
                                      A.CreditsinceDt = src.LastCrDt,
                                      A.CommonMocTypeAlt_Key = src.MocTypeAlt_Key,
                                      A.FlgMoc = src.MocStatus,
                                      A.MOC_Dt = src.MocDate,
                                      A.OverDueSinceDt = src.OverDueSinceDt,
                                      A.OverdueAmt = src.OverDue,
                                      A.PrincOverdue = src.OverduePrincipal,
                                      A.IntOverdue = src.Overdueinterest,
                                      A.PrincOutStd = src.PrincipalBalance,
                                      A.AdvanceRecovery = src.AdvanceRecovery,
                                      A.NotionalInttAmt = src.NotionalInttAmt,
                                      A.DFVAmt = src.DFVAmt,
                                      A.PrincOverdueSinceDt = src.OverduePrincipalDt,
                                      A.IntOverdueSinceDt = src.OverdueIntDt,
                                      A.OtherOverdue = src.OverOtherdue,
                                      A.OtherOverdueSinceDt = src.OverdueOtherDt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Balance,LastCrDate,CreditsinceDt FOR ALL ACCOUNT';
         MERGE INTO MAIN_PRO.ACCOUNTCAL a
         USING (SELECT a.ROWID row_id, b.CurQtrCredit, b.CurQtrInt
         FROM MAIN_PRO.ACCOUNTCAL a
                JOIN RBL_STGDB.ACCOUNT_ALL_SOURCE_SYSTEM b   ON a.CustomerAcID = b.customeracid 
          WHERE ( NVL(b.CurQtrCredit, 0) > 0
           OR NVL(b.CurQtrInt, 0) > 0 )
           AND a.FacilityType IN ( 'CC','OD' )
         ) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.CurQtrCredit = src.CurQtrCredit,
                                      A.CurQtrInt = src.CurQtrInt;--28062021 added by amar for filter only for ccod  
         --update a  
         --        set  FacilityType='CC'  
         --from pro.accountcal a WHERE FacilityType='CCOD'  
         ------  
         --UPDATE A SET A.OVERDUESINCEDT=DATEADD(DAY,-b.CD,@PROCESSINGDATE)  
         --FROM PRO.AccountCal A INNER  JOIN RBL_STGDB.DBO.ACCOUNT_ALL_SOURCE_SYSTEM b on a.customeracid=b.CustomerAcID  
         --INNER JOIN RBL_MISDB_PROD.DIMSOURCEDB c ON A.SourceAlt_Key=c.SourceAlt_Key  
         --where ISNULL(B.CD,0)>0 and SourceName='VISIONPLUS' AND c.EffectiveFromTimeKey<=@Timekey and c.EffectiveToTimeKey>=@Timekey  
         ----UPDATE A SET Liability=B.Liability,CD=B.CD,AccountStatus=b.AccountStatus,AccountBlkCode1=b.AccountBlkCode1,AccountBlkCode2=b.AccountBlkCode2  
         ----FROM PRO.AccountCal A INNER  JOIN RBL_STGDB.DBO.ACCOUNT_ALL_SOURCE_SYSTEM b on a.customeracid=b.CustomerAcID  
         ----INNER JOIN RBL_MISDB_PROD.DIMSOURCEDB c ON A.SourceAlt_Key=c.SourceAlt_Key  
         ----where  SourceName='VISIONPLUS' AND c.EffectiveFromTimeKey<=@Timekey and c.EffectiveToTimeKey>=@Timekey  
         /* end of temporary updates*/
         /*------------------UPDATE OVERDUE SINCE DATE DUE TO DPD MAX FOR VISION PLUS DATA ONLY------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE OVERDUE SINCE DATE DUE TO DPD MAX FOR VISION PLUS DATA ONLY' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         --UPDATE A SET A.OVERDUESINCEDT=DATEADD(DAY,-DPD,@PROCESSINGDATE)  
         --FROM PRO.AccountCal A INNER  JOIN DBO.AdvFacCreditCardDetail B ON A.AccountEntityID=B.AccountEntityID  
         --WHERE  (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY) AND ISNULL(B.DPD,0)>0  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.Liability, B.CD, b.AccountStatus, b.AccountBlkCode1, b.AccountBlkCode2
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvFacCreditCardDetail b   ON a.AccountEntityID = b.AccountEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN RBL_MISDB_PROD.DIMSOURCEDB c   ON A.SourceAlt_Key = c.SourceAlt_Key 
          WHERE SourceName = 'VISIONPLUS'
           AND c.EffectiveFromTimeKey <= v_Timekey
           AND c.EffectiveToTimeKey >= v_Timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET Liability = src.Liability,
                                      CD = src.CD,
                                      AccountStatus = src.AccountStatus,
                                      AccountBlkCode1 = src.AccountBlkCode1,
                                      AccountBlkCode2 = src.AccountBlkCode2;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.Liability, B.CD, b.AccountStatus, b.AccountBlkCode1, b.AccountBlkCode2
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvFacCreditCardDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Liability = src.Liability,
                                      A.CD = src.CD,
                                      A.AccountStatus = src.AccountStatus,
                                      A.AccountBlkCode1 = src.AccountBlkCode1,
                                      A.AccountBlkCode2 = src.AccountBlkCode2;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE OVERDUE SINCE DATE DUE TO DPD MAX FOR VISION PLUS DATA ONLY';
         /*-----update SrcAssetClass_Key key|SysAssetClassAlt_Key in customer Cal table--------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'SrcAssetClass_Key key|SysAssetClassAlt_Key' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         v_HistTimeKey := v_TIMEKEY - 1 ;--max(EffectiveFromTimeKey) from pro.AccountCal_Hist where  EffectiveFromTimeKey <@TIMEKEY  
         IF NVL(v_HistTimeKey, 0) = 0 THEN

         BEGIN
            MERGE INTO MAIN_PRO.CUSTOMERCAL A
            USING (SELECT A.ROWID row_id, NVL(c.Cust_AssetClassAlt_Key, 1) AS pos_2, NVL(c.Cust_AssetClassAlt_Key, 1) AS pos_3, NVL(C.NPADt, NULL) AS pos_4, NVL(C.NPADt, NULL) AS pos_5, NVL(C.DbtDt, NULL) AS pos_6, NVL(C.LosDt, NULL) AS pos_7
            FROM MAIN_PRO.CUSTOMERCAL A
                   LEFT JOIN CURDAT_RBL_MISDB_PROD.AdvCustNPADetail C   ON C.CustomerEntityId = A.CustomerEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SrcAssetClassAlt_Key = pos_2,
                                         A.SysAssetClassAlt_Key = pos_3,
                                         A.SrcNPA_Dt = pos_4,
                                         A.SysNPA_Dt = pos_5,
                                         A.DbtDt = pos_6,
                                         A.LossDt = pos_7;

         END;
         ELSE

         BEGIN
            MERGE INTO MAIN_PRO.CUSTOMERCAL A
            USING (SELECT A.ROWID row_id, NVL(c.SysAssetClassAlt_Key, 1) AS pos_2, NVL(c.SysAssetClassAlt_Key, 1) AS pos_3, NVL(C.SysNPA_Dt, NULL) AS pos_4, NVL(C.SysNPA_Dt, NULL) AS pos_5, NVL(C.DbtDt, NULL) AS pos_6, NVL(C.LossDt, NULL) AS pos_7
            FROM MAIN_PRO.CUSTOMERCAL A
                   LEFT JOIN MAIN_PRO.CustomerCal_Hist C   ON C.CustomerEntityId = A.CustomerEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_HistTimeKey
                   AND C.EFFECTIVETOTIMEKEY >= v_HistTimeKey ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SrcAssetClassAlt_Key = pos_2,
                                         A.SysAssetClassAlt_Key = pos_3,
                                         A.SrcNPA_Dt = pos_4,
                                         A.SysNPA_Dt = pos_5,
                                         A.DbtDt = pos_6,
                                         A.LossDt = pos_7;

         END;
         END IF;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'SrcAssetClass_Key key|SysAssetClassAlt_Key';
         ----IF OBJECT_ID('TEMPDB..#TEMPTABLE_VISIONPLUS_ASSETCLASS') IS NOT NULL  
         ----  DROP TABLE #TEMPTABLE_VISIONPLUS_ASSETCLASS  
         ----  SELECT  SOURCESYSTEMCUSTOMERID,  
         ----MAX(CASE WHEN CD IN(5,6,7,8,9) THEN 2 ELSE 1 END ) ASSETCLASS ---OR ISNULL(ACCOUNTSTATUS,'N')='Z'  
         ----INTO #TEMPTABLE_VISIONPLUS_ASSETCLASS  
         ----FROM PRO.ACCOUNTCAL A  
         ----INNER JOIN RBL_MISDB_PROD.DIMSOURCEDB B  
         ----ON A.SourceAlt_Key=B.SourceAlt_Key  
         ----WHERE SourceName='VISIONPLUS' AND B.EffectiveFromTimeKey<=@Timekey and B.EffectiveToTimeKey>=@Timekey  
         ----and ( CD IN(5,6,7,8,9) )  
         ----GROUP BY SOURCESYSTEMCUSTOMERID  
         ----UPDATE A SET  A.SYSASSETCLASSALT_KEY=ISNULL(B.ASSETCLASS,1)  
         ----            ,A.SysNPA_Dt=@ProcessingDate  
         ----FROM PRO.CUSTOMERCAL A INNER JOIN #TEMPTABLE_VISIONPLUS_ASSETCLASS B  
         ----ON A.SOURCESYSTEMCUSTOMERID=B.SOURCESYSTEMCUSTOMERID  
         ----WHERE ASSETCLASS=2 AND SYSASSETCLASSALT_KEY=1  
         /*-----update SrcAssetClass_Key key|SysAssetClassAlt_Key in customer Cal table--------------*/
         /*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY PAN NO------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY PAN NO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         IF NVL(v_PANCARDFLAG, 'N') = 'Y' THEN

         BEGIN
            IF utils.object_id('TEMPDB..GTT_TEMPTABLEPANCARD') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLEPANCARD ';
            END IF;
            DELETE FROM GTT_TEMPTABLEPANCARD;
            UTILS.IDENTITY_RESET('GTT_TEMPTABLEPANCARD');

            INSERT INTO GTT_TEMPTABLEPANCARD(PANNO,SYSASSETCLASSALT_KEY,SYSNPA_DT) ( 
            	SELECT PANNO ,
                    MAX(NVL(SYSASSETCLASSALT_KEY, 1))  SYSASSETCLASSALT_KEY  ,
                    MIN(SYSNPA_DT)  SYSNPA_DT  
            	  FROM MAIN_PRO.CUSTOMERCAL A
                      JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON B.SOURCEALT_KEY = A.SourceAlt_Key
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
            	 WHERE  PANNO IS NOT NULL
                       AND NVL(SYSASSETCLASSALT_KEY, 1) <> 1
            	  GROUP BY PANNO );

            MERGE INTO GTT_TEMPTABLEPANCARD A
            USING (SELECT A.ROWID row_id, C.SOURCEDBNAME
            FROM GTT_TEMPTABLEPANCARD A
                   JOIN MAIN_PRO.CUSTOMERCAL B   ON A.PANNO = B.PANNO
                   JOIN RBL_MISDB_PROD.DIMSOURCEDB C   ON B.SourceAlt_Key = C.SOURCEALT_KEY
                   AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
             WHERE A.SYSNPA_DT = B.SysNPA_Dt) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SOURCEDBNAME = src.SOURCEDBNAME;
            MERGE INTO MAIN_PRO.CUSTOMERCAL A
            USING (SELECT A.ROWID row_id, B.SYSASSETCLASSALT_KEY, B.SYSNPA_DT
            FROM MAIN_PRO.CUSTOMERCAL A
                   JOIN GTT_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.SYSASSETCLASSALT_KEY,
                                         A.SYSNPA_DT = src.SYSNPA_DT;
            MERGE INTO MAIN_PRO.CUSTOMERCAL A
            USING (SELECT A.ROWID row_id, 'PERCOLATION BY PAN CARD ' || ' ' || B.SOURCEDBNAME || '  ' || B.PANNO AS DEGREASON
            FROM MAIN_PRO.CUSTOMERCAL A
                   JOIN GTT_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO 
             WHERE A.SrcAssetClassAlt_Key = 1
              AND A.SysAssetClassAlt_Key > 1
              AND A.DegReason IS NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;

         END;
         END IF;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY PAN NO';
         /*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY AADHAR CARD NO------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY AADHARCARD NO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         IF NVL(v_AADHARCARDFLAG, 'N') = 'Y' THEN

         BEGIN
            IF utils.object_id('TEMPDB..GTT_TEMPTABLE_ADHARCARD') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPTABLE_ADHARCARD ';
            END IF;
            DELETE FROM GTT_TEMPTABLE_ADHARCARD;
            UTILS.IDENTITY_RESET('GTT_TEMPTABLE_ADHARCARD');

            INSERT INTO GTT_TEMPTABLE_ADHARCARD ( 
            	SELECT AADHARCARDNO ,
                    MAX(NVL(SYSASSETCLASSALT_KEY, 1))  SYSASSETCLASSALT_KEY  ,
                    MIN(SYSNPA_DT)  SYSNPA_DT  ,
                    B.SOURCEDBNAME 
            	  FROM MAIN_PRO.CUSTOMERCAL A
                      JOIN RBL_MISDB_PROD.DIMSOURCEDB B   ON B.SOURCEALT_KEY = A.SourceAlt_Key
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
            	 WHERE  A.AadharCardNO IS NOT NULL
                       AND NVL(A.SysAssetClassAlt_Key, 1) <> 1
            	  GROUP BY AADHARCARDNO,B.SOURCEDBNAME );
            MERGE INTO MAIN_PRO.CUSTOMERCAL A
            USING (SELECT A.ROWID row_id, B.SYSASSETCLASSALT_KEY, B.SYSNPA_DT
            FROM MAIN_PRO.CUSTOMERCAL A
                   JOIN GTT_TEMPTABLE_ADHARCARD B   ON A.AadharCardNO = B.AADHARCARDNO ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.SYSASSETCLASSALT_KEY,
                                         A.SYSNPA_DT = src.SYSNPA_DT;
            MERGE INTO MAIN_PRO.CUSTOMERCAL A
            USING (SELECT A.ROWID row_id, 'PERCOLATION BY AADHAR CARD ' || ' ' || B.SOURCEDBNAME || '  ' || B.AADHARCARDNO AS DEGREASON
            FROM MAIN_PRO.CUSTOMERCAL A
                   JOIN GTT_TEMPTABLE_ADHARCARD B   ON A.AadharCardNO = B.AADHARCARDNO 
             WHERE A.SrcAssetClassAlt_Key = 1
              AND A.SysAssetClassAlt_Key > 1
              AND A.DegReason IS NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;

         END;
         END IF;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY AADHARCARD NO';
         /*-----UPDATE SplCatg Alt_Key ACCOUNT LEVEL--------------- */
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'SplCatg Alt_Key ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.SplCatg1Alt_Key, 0) AS pos_2, NVL(B.SplCatg2Alt_Key, 0) AS pos_3, NVL(B.SplCatg3Alt_Key, 0) AS pos_4, NVL(B.SplCatg4Alt_Key, 0) AS pos_5
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcOtherDetail B   ON A.AccountEntityID = B.ACCOUNTENTITYID
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SplCatg1Alt_Key = pos_2,
                                      A.SplCatg2Alt_Key = pos_3,
                                      A.SplCatg3Alt_Key = pos_4,
                                      A.SplCatg4Alt_Key = pos_5;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'SplCatg Alt_Key ACCOUNT LEVEL';
         /*-----UPDATE SplCatg Alt_Key CUSTOMER LEVEL--------------- */
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE SplCatg Alt_Key CUSTOMER LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.SplCatg1Alt_Key, 0) AS pos_2, NVL(B.SplCatg2Alt_Key, 0) AS pos_3, NVL(B.SplCatg3Alt_Key, 0) AS pos_4, NVL(B.SplCatg4Alt_Key, 0) AS pos_5
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CUSTOMERENTITYID
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SplCatg1Alt_Key = pos_2,
                                      A.SplCatg2Alt_Key = pos_3,
                                      A.SplCatg3Alt_Key = pos_4,
                                      A.SplCatg4Alt_Key = pos_5;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SplCatg Alt_Key CUSTOMER LEVEL';
         /*----MARKING OF ALWAYS STD Account LEVEL----------------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'MARKING OF ALWAYS STD Account LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL
         USING (SELECT ACL.ROWID row_id, 'ALWYS_STD'
         FROM MAIN_PRO.ACCOUNTCAL ACL
                LEFT JOIN RBL_MISDB_PROD.DimScheme DSE   ON DSE.EffectiveFromTimeKey <= v_TimeKey
                AND DSE.EffectiveToTimeKey >= v_TimeKey
                AND ACL.SchemeAlt_key = DSE.SchemeAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS1   ON DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg1Alt_Key, 0) = DAS1.SplCatAlt_Key
                AND NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS2   ON DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg2Alt_Key, 0) = DAS2.SplCatAlt_Key
                AND NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS3   ON DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg3Alt_Key, 0) = DAS3.SplCatAlt_Key
                AND NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS4   ON DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg4Alt_Key, 0) = DAS4.SplCatAlt_Key
                AND NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN RBL_MISDB_PROD.DimProduct P   ON P.ProductAlt_Key = ACL.ProductAlt_Key
                AND P.EffectiveFromTimeKey <= v_TIMEKEY
                AND P.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE ( ( NVL(DSE.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_STD' ) )
           OR ( NVL(P.AssetClass, 'NORMAL') = 'ALWYS_STD' )) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_STD';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'MARKING OF ALWAYS STD Account LEVEL';
         /*--------marking  always NPA account table level----------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking  always NPA account table level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.ACCOUNTCAL ACL
                LEFT JOIN RBL_MISDB_PROD.DimScheme DSE   ON DSE.EffectiveFromTimeKey <= v_TimeKey
                AND DSE.EffectiveToTimeKey >= v_TimeKey
                AND ACL.SchemeAlt_key = DSE.SchemeAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS1   ON DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg1Alt_Key, 0) = DAS1.SplCatAlt_Key
                AND NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_NPA'
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS2   ON DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg2Alt_Key, 0) = DAS2.SplCatAlt_Key
                AND NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_NPA'
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS3   ON DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg3Alt_Key, 0) = DAS3.SplCatAlt_Key
                AND NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_NPA'
                LEFT JOIN RBL_MISDB_PROD.DimAcSplCategory DAS4   ON DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg4Alt_Key, 0) = DAS4.SplCatAlt_Key
                AND NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_NPA' 
          WHERE ( ( NVL(DSE.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_NPA' ) )) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking  always NPA account table level';
         /*-----------------marking  always STD CUSTOMER  level------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking  always STD CUSTOMER  level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         FROM MAIN_PRO.CUSTOMERCAL A
                LEFT JOIN RBL_MISDB_PROD.DimConstitution DCO   ON DCO.EffectiveFromTimeKey <= v_TimeKey
                AND DCO.EffectiveToTimeKey >= v_TimeKey
                AND A.ConstitutionAlt_Key = DCO.ConstitutionAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS1   ON DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg1Alt_Key = DAS1.SplCatAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS2   ON DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg2Alt_Key = DAS2.SplCatAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS3   ON DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg3Alt_Key = DAS3.SplCatAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS4   ON DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg4Alt_Key = DAS4.SplCatAlt_Key 
          WHERE ( ( NVL(DCO.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_STD'
           OR NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_STD' ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_STD';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking  always STD CUSTOMER  level';
         /*---marking  always NPA CUSTOMER table level------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking  always NPA CUSTOMER table level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.CUSTOMERCAL A
                LEFT JOIN RBL_MISDB_PROD.DimConstitution DCO   ON ( DCO.EffectiveFromTimeKey <= v_TimeKey
                AND DCO.EffectiveToTimeKey >= v_TimeKey )
                AND A.ConstitutionAlt_Key = DCO.ConstitutionAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS1   ON ( DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg1Alt_Key = DAS1.SplCatAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS2   ON ( DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg2Alt_Key = DAS2.SplCatAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS3   ON ( DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg3Alt_Key = DAS3.SplCatAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimSplCategory DAS4   ON ( DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg4Alt_Key = DAS4.SplCatAlt_Key 
          WHERE ( ( NVL(DCO.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_NPA'
           OR NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_NPA' ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking  always NPA CUSTOMER table level';
         /*----UPDATE ACCOUNTS WHOSE CUSTOMER IS IN ALWAYS STANDAED CATEGORY---------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Accounts whose customer is in always standaed category' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL ABD
         USING (SELECT ABD.ROWID row_id, 'ALWYS_STD'
         FROM MAIN_PRO.ACCOUNTCAL ABD
                JOIN MAIN_PRO.CUSTOMERCAL CBD   ON ABD.CustomerEntityID = CBD.CustomerEntityID 
          WHERE CBD.Asset_Norm = 'ALWYS_STD') src
         ON ( ABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ABD.Asset_Norm = 'ALWYS_STD';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Accounts whose customer is in always standaed category';
         /*----UPDATE ACCOUNTS WHOSE CUSTOMER IS IN ALWAYS NPA CATEGORY--------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Accounts whose customer is in always NPA category' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL ABD
         USING (SELECT ABD.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.ACCOUNTCAL ABD
                JOIN MAIN_PRO.CUSTOMERCAL CBD   ON ABD.CustomerEntityID = CBD.CustomerEntityID 
          WHERE CBD.Asset_Norm = 'ALWYS_NPA'
           AND ABD.Asset_Norm <> 'ALWYS_STD') src
         ON ( ABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ABD.Asset_Norm = 'ALWYS_NPA';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Accounts whose customer is in always NPA category';
         /*-------CurrAssetClassAlt_Key update in Account Cal from customer Cal systemAssetclassalt_key--------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'CurrAssetClassAlt_Key update in Account Cal from customer Cal systemAssetclassalt_key' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ------UPDATE A  
         ------SET A.INITIALASSETCLASSALT_KEY=ISNULL(B.SysAssetClassAlt_Key,1)  
         ------   ,A.FinalAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)  
         ------   ,A.PrvAssetClassAlt_Key=ISNULL(B.SysAssetClassAlt_Key,1)  
         ------FROM PRO.ACCOUNTCAL A LEFT  OUTER JOIN   PRO.CUSTOMERCAL  B   
         ------ON   (B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND B.EFFECTIVETOTIMEKEY>=@TIMEKEY)   
         ------AND A.CustomerEntityID=B.CustomerEntityID  
         IF NVL(v_HistTimeKey, 0) = 0 THEN

         BEGIN
            MERGE INTO MAIN_PRO.ACCOUNTCAL A
            USING (SELECT A.ROWID row_id, NVL(c.Cust_AssetClassAlt_Key, 1) AS pos_2, NVL(C.Cust_AssetClassAlt_Key, 1) AS pos_3, NVL(C.NPADt, NULL) AS pos_4
            FROM MAIN_PRO.ACCOUNTCAL A
                   JOIN CURDAT_RBL_MISDB_PROD.AdvCustNPADetail C   ON C.CustomerEntityId = A.CustomerEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.INITIALASSETCLASSALT_KEY = pos_2,
                                         A.PrvAssetClassAlt_Key = pos_3,
                                         A.InitialNpaDt = pos_4;

         END;
         ELSE

         BEGIN
            MERGE INTO MAIN_PRO.ACCOUNTCAL A
            USING (SELECT A.ROWID row_id, NVL(c.FinalAssetClassAlt_Key, 1) AS pos_2, NVL(C.FinalAssetClassAlt_Key, 1) AS pos_3, C.FinalNpaDt
            FROM MAIN_PRO.ACCOUNTCAL A
                   JOIN MAIN_PRO.AccountCal_Hist C   ON C.AccountEntityID = A.AccountEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_HistTimeKey
                   AND C.EFFECTIVETOTIMEKEY >= v_HistTimeKey ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.INITIALASSETCLASSALT_KEY = pos_2,
                                         A.PrvAssetClassAlt_Key = pos_3,
                                         A.InitialNpaDt = src.FinalNpaDt;

         END;
         END IF;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS FinalAssetClassAlt_Key
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS FinalAssetClassAlt_Key
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         IF v_PANCARDFLAG = 'Y' THEN

         BEGIN
            MERGE INTO MAIN_PRO.ACCOUNTCAL C
            USING (SELECT C.ROWID row_id, A.SysAssetClassAlt_Key
            FROM MAIN_PRO.CUSTOMERCAL A
                   JOIN GTT_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO
                   JOIN MAIN_PRO.ACCOUNTCAL C   ON C.UcifEntityID = A.UcifEntityID ) src
            ON ( C.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET C.FinalAssetClassAlt_Key
                                         --,C.FinalNpaDt=A.SYSNPA_DT    
                                          = src.SysAssetClassAlt_Key;

         END;
         END IF;
         --Added by Mandeep (24-03-2023) to stop update in finalassetclass of FDOD always standard account(if initial assetclass <> 1)  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'CONDI_STD'
         FROM MAIN_PRO.ACCOUNTCAL A
                LEFT JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key 
          WHERE A.InitialAssetClassAlt_Key <> 1
           AND C.ProductGroup = 'FDSEC'
           AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'CONDI_STD';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'CurrAssetClassAlt_Key update in Account Cal from customer Cal systemAssetclassalt_key';
         /*---------UPDATE INITIALNPADT AND FINALNPADT AT ACCOUNT  LEVEL FROM CUSTOMER TO ACCOUNT------------- */
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE InitialNpaDt AND FinalNpaDt AT Account  level from customer to account' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ------UPDATE A SET  A.InitialNpaDt=B.SrcNPA_Dt  
         ------             ,A.FinalNpaDt=B.SrcNPA_Dt  
         ------FROM PRO.ACCOUNTCAL  A INNER  JOIN PRO.CUSTOMERCAL B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID  
         ------WHERE A.INITIALASSETCLASSALT_KEY<>1  
         /* COMMENTED BELOQ CODE AND INITIAL NPA DATED INCLUDED IN AB OVE UPDATE WITH INITAIL ASSET CASS*/
         /*  
           IF ISNULL(@HistTimeKey ,0)=0  
           BEGIN  
            UPDATE A SET  A.InitialNpaDt=isnull(C.NPADt,null)  
                 FROM PRO.ACCOUNTCAL A  LEFT hash JOIN dbo.AdvCustNPAdetail C  
             ON C.CustomerEntityId=A.CustomerEntityId  
            AND (C.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND C.EFFECTIVETOTIMEKEY>=@TIMEKEY)  
           END  
           ELSE  
           BEGIN  
            UPDATE A SET  A.InitialNpaDt=isnull(C.FinalNpaDt,null)  
                 FROM PRO.ACCOUNTCAL A  LEFT hash JOIN PRO.AccountCal_Hist C  
             ON C.AccountEntityID=A.AccountEntityID  
            AND (C.EFFECTIVEFROMTIMEKEY<=@HistTimeKey AND C.EFFECTIVETOTIMEKEY>=@HistTimeKey)  
           END  
         */
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.SysNPA_Dt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalNpaDt = src.SysNPA_Dt;
         --WHERE A.INITIALASSETCLASSALT_KEY<>1  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.SysNPA_Dt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalNpaDt = src.SysNPA_Dt;
         --WHERE A.INITIALASSETCLASSALT_KEY<>1  
         IF v_PANCARDFLAG = 'Y' THEN

         BEGIN
            MERGE INTO MAIN_PRO.ACCOUNTCAL C
            USING (SELECT C.ROWID row_id, A.SysNPA_Dt
            FROM MAIN_PRO.CUSTOMERCAL A
                   JOIN GTT_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO
                   JOIN MAIN_PRO.ACCOUNTCAL C   ON C.UcifEntityID = A.UcifEntityID ) src
            ON ( C.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET C.FinalNpaDt = src.SysNPA_Dt;

         END;
         END IF;
         /* AMAR - 23032022 - COMMENTED AS PER DISCUSSIONS AND EMAIL BY ASHISH SIR DATED 23032022*/
         /*  
         UPDATE PRO.ACCOUNTCAL SET ASSET_NORM='ALWYS_NPA'  
         WHERE INITIALASSETCLASSALT_KEY=6  
         */
         /* AMAR - 06042022 0  SHIFTED THIS CODE TO BELOW (AFTER TWO AND SETTLEMENT WORK) - FOR MARKING THE 1ST PRIORITY OF TWO (ALWAYS NPA) */
         /*  
         --UPDATE PRO.ACCOUNTCAL SET INITIALASSETCLASSALT_KEY=1,INITIALNPADT=NULL,FINALNPADT=NULL,FINALASSETCLASSALT_KEY=1,PrvAssetClassAlt_Key=1  
         --WHERE ASSET_NORM='ALWYS_STD' AND INITIALASSETCLASSALT_KEY<>1   
         */
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE InitialNpaDt AND FinalNpaDt AT Account  level from customer to account';
         /*--------MARKING ALWAYS NPA ACCOUNT TABLE LEVEL FOR VISION PLUS ACCOUNT WHERE ACCOUNTBLOCK CODE 2 IS K----------------*/
         /* AMAR 17022022- CHANGES ACCOUNTBLOCKCODE2=K MARKED AS NPA*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking always NPA account table level where vision plus  AccountBlockcode2=K' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 2, v_ProcessingDate, 'NPA DUE TO CREDIT CARD SETTLEMENT - Always NPA' AS pos_5
         FROM MAIN_PRO.ACCOUNTCAL ACL 
          WHERE AccountBlkCode2 = 'K'
           AND FinalAssetClassAlt_Key = 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.FinalAssetClassAlt_Key = 2,
                                      ACL.FinalNpaDt = v_ProcessingDate,
                                      ACL.NPA_Reason = pos_5;
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO CREDIT CARD SETTLEMENT - Always NPA' AS pos_3
         FROM MAIN_PRO.ACCOUNTCAL ACL 
          WHERE AccountBlkCode2 = 'K'
           AND FinalAssetClassAlt_Key > 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.NPA_Reason = pos_3;
         /* CUSTOMER WRITEOFF UPDATE */
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO CREDIT CARD SETTLEMENT - Always NPA' AS pos_3, 2, v_ProcessingDate
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL AC   ON AC.CustomerEntityID = A.CustomerEntityID 
          WHERE AccountBlkCode2 = 'K'
           AND SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DegReason = pos_3,
                                      A.SysAssetClassAlt_Key = 2,
                                      A.SysNPA_Dt = v_ProcessingDate;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO CREDIT CARD SETTLEMENT - Always NPA' AS pos_3
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL AC   ON AC.CustomerEntityID = A.CustomerEntityID 
          WHERE AccountBlkCode2 = 'K'
           AND SysAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DegReason = pos_3;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking always NPA account table level where vision plus  AccountBlockcode2=K';
         /* END OF AMAR 17022022- CHANGES ACCOUNTBLOCKCODE2=K MARKED AS NPA*/
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking always NPA account table level where WriteOffAmount>0' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         --update  ACL set WriteOffAmount=b.WriteOffAmt  
         --from PRO.AccountCal ACL  
         --inner join curdat.AdvAcWODetail b  
         --on ACL.CustomerAcID=b.CustomerAcID  
         --where b.EFFECTIVEFROMTIMEKEY<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY  
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_ProcessingDate
            END AS pos_4, 'NPA DUE TO WRITEOFF MARKING' AS pos_5, b.Amount
         FROM MAIN_PRO.ACCOUNTCAL ACL
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON ACL.CustomerAcID = b.ACID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND FinalAssetClassAlt_Key = 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.FinalAssetClassAlt_Key = 2,
                                      ACL.FinalNpaDt = pos_4,
                                      ACL.NPA_Reason = pos_5,
                                      ACL.WriteOffAmount = src.Amount;
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO WRITEOFF MARKING' AS pos_3, b.Amount
         FROM MAIN_PRO.ACCOUNTCAL ACL
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON ACL.CustomerAcID = b.ACID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND FinalAssetClassAlt_Key > 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.NPA_Reason = pos_3,
                                      ACL.WriteOffAmount = src.Amount;
         /* CUSTOMER WRITEOFF UPDATE */
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO WRITEOFF MARKING' AS pos_3, 2, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_ProcessingDate
            END AS pos_5
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL AC   ON AC.CustomerEntityID = A.CustomerEntityID
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON AC.CustomerAcID = B.ACID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DegReason = pos_3,
                                      A.SysAssetClassAlt_Key = 2,
                                      A.SysNPA_Dt = pos_5;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO WRITEOFF MARKING' AS pos_3
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL AC   ON AC.CustomerEntityID = A.CustomerEntityID
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON AC.CustomerAcID = B.ACID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'TWO','WO' )

           AND SysAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DegReason = pos_3;
         /* SATTLEMENT AND LITIGATION - AMAR ADDED ON 04022022 */
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_ProcessingDate
            END AS pos_4, 'NPA DUE TO ' || StatusType AS pos_5
         FROM MAIN_PRO.ACCOUNTCAL ACL
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON ACL.CustomerAcID = b.ACID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'Settlement','Litigation' )

           AND FinalAssetClassAlt_Key = 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.FinalAssetClassAlt_Key = 2,
                                      ACL.FinalNpaDt = pos_4,
                                      ACL.NPA_Reason = pos_5;
         MERGE INTO MAIN_PRO.ACCOUNTCAL ACL
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO ' || StatusType AS pos_3, CASE 
         WHEN StatusDate < FinalNpaDt THEN StatusDate
         ELSE FinalNpaDt
            END AS pos_4
         FROM MAIN_PRO.ACCOUNTCAL ACL
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON ACL.CustomerAcID = b.ACID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'Settlement','Litigation' )

           AND FinalAssetClassAlt_Key > 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA',
                                      ACL.NPA_Reason = pos_3,
                                      ACL.FinalNpaDt = pos_4;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO ' || StatusType AS pos_3, 2, CASE 
         WHEN StatusDate IS NOT NULL THEN StatusDate
         ELSE v_ProcessingDate
            END AS pos_5
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON A.RefCustomerID = B.CustomerID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'Settlement','Litigation' )

           AND SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DegReason = pos_3,
                                      A.SysAssetClassAlt_Key = 2,
                                      A.SysNPA_Dt = pos_5;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO ' || StatusType AS pos_3, CASE 
         WHEN StatusDate < SysNPA_Dt THEN StatusDate
         ELSE SysNPA_Dt
            END AS pos_4
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON A.RefCustomerID = B.CustomerID
                AND b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY 
          WHERE B.StatusType IN ( 'Settlement','Litigation' )

           AND SysAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.DegReason = pos_3,
                                      A.SysNPA_Dt = pos_4;
         /*END OF -- SATTLEMENT AND LITIGATION - AMAR ADDED ON 04022022 */
         /* AMAR - 06042022 0  SHIFTED THIS CODE FROM ABOVE (BEFORE TWO WORK) - FOR MARKING THE 1ST PRIORITY OF TWO (ALWAYS NPA) */
         UPDATE MAIN_PRO.ACCOUNTCAL
            SET FINALNPADT = NULL,
                FINALASSETCLASSALT_KEY = 1
          WHERE  ASSET_NORM = 'ALWYS_STD'
           AND INITIALASSETCLASSALT_KEY <> 1;
         --Update ACL   
         --set Asset_Norm='ALWYS_NPA'  
         --from PRO.AccountCal ACL  
         --inner join curdat.AdvAcWODetail b  
         --on ACL.CustomerAcID=b.CustomerAcID  
         --where b.EFFECTIVEFROMTIMEKEY<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY  
         --and  ACL.FinalAssetClassAlt_Key>1  
         --and b.WriteOffDt is not null  
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking always NPA account table level where WriteOffAmount>0';
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         /*---------UPDATE PrvQtrRV  AT Customer level--------------------- */
         /*---TO BE REMOVE GET VALUE FROM FUNCTION*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE PrvQtrRV  AT Customer level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required  Modification Done---   
         /*  added below code - as discused with Ashish Sir on 29th MAr'2022 - added new column SecurityValueMain in security value detail table and will be used for Prev QTR RV  */
         --IF OBJECT_ID('TEMPDB..GTT_PRVQTRRV') IS NOT NULL  
         --DROP TABLE GTT_PRVQTRRV  
         -- SELECT CustomerEntityId,SUM(b.SecurityValueMain)  SecurityValueMain   
         --  into GTT_PRVQTRRV  
         -- FROM AdvSecurityDetail A  
         -- INNER JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail B  
         --  ON A.SecurityEntityID =B.SecurityEntityID  
         --  AND A.EffectiveFromTimeKey<=@TIMEKEY AND A.EffectiveToTimeKey>=@TIMEKEY  
         --  AND B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY  
         -- group by CustomerEntityId  
         --UPDATE A SET A.PRVQTRRV= SecurityValueMain  
         --FROM PRO.CUSTOMERCAL A INNER  JOIN GTT_PRVQTRRV B  
         --ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID   
         --    IF OBJECT_ID('TEMPDB..#CustPrevAtrAcl') IS NOT NULL  
         --DROP TABLE #CustPrevAtrAcl
         --SELECT CustomerEntityID,SysAssetClassAlt_Key
         --    INTO #CustPrevAtrAcl
         --FROM Pro.CustomerCal_Hist
         --WHERE EffectiveFromTimeKey<=@TIMEKEY-1 AND EffectiveToTimeKey>=@TIMEKEY-1                
         IF utils.object_id('TEMPDB..GTT_PRVQTRRV') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PRVQTRRV ';
         END IF;
         DELETE FROM GTT_PRVQTRRV;
         UTILS.IDENTITY_RESET('GTT_PRVQTRRV');

         INSERT INTO GTT_PRVQTRRV ( 
         	SELECT A.CustomerEntityId ,
                 --SUM(CASE when c.SysAssetClassAlt_Key>1 THEN b.CurrentValue ELSE SecurityValueMain END) 
                 SUM(SecurityValueMain)  SecurityValueMain --  CHANGED BY MANDEEP (13-07-2023 MAIL DATE sudarshan) SUB Change Request #BRD Daily Security Erosion

         	  FROM CURDAT_RBL_MISDB_PROD.AdvSecurityDetail A
                   JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.SecurityEntityID = B.SecurityEntityID
                   AND A.EffectiveFromTimeKey <= (v_TIMEKEY - 1)
                   AND A.EffectiveToTimeKey >= (v_TIMEKEY - 1)
                   AND B.EffectiveFromTimeKey <= (v_TIMEKEY - 1)
                   AND B.EffectiveToTimeKey >= (v_TIMEKEY - 1)

         	--INNER JOIN #CustPrevAtrAcl C                

         	--    ON C.CustomerEntityID=A.CustomerEntityId                
         	GROUP BY A.CustomerEntityId );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, SecurityValueMain
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN GTT_PRVQTRRV B   ON A.CustomerEntityID = B.CUSTOMERENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PRVQTRRV = SecurityValueMain;
         /*  commented below code - as discused with Ashish Sir on 29th MAr'2022 - added new column SecurityValueMain in security value detail table and will be used for Prev QTR RV  */
         /*--DROP TABLE GTT_PRVQTRRV                  

         --DECLARE @PRVQTRRV INT =(SELECT LastQtrDateKey FROM RBL_MISDB_PROD.SysDayMatrix WHERE TimeKey=@TIMEKEY)                  

         --SELECT *                    
         --INTO GTT_PRVQTRRV                   
         --FROM dbo.AdvCustSecurityFunpre(@PRVQTRRV)                  

         --UPDATE A SET A.PRVQTRRV= ISNULL(B.Total_PriSec,0)+ISNULL(B.Total_CollSec,0)  FROM PRO.CUSTOMERCAL A INNER  JOIN GTT_PRVQTRRV B                  
         --ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                  
         */
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PrvQtrRV  AT Customer level';
         --/*---------UPDATE CurntQtrRv  AT Customer level--------------------- */                   
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CurntQtrRv  AT Customer level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ----Condition Change Required -----                   
         IF utils.object_id('TEMPDB..GTT_CurntQtrRv') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_CurntQtrRv ';
         END IF;
         DELETE FROM GTT_CurntQtrRv;
         UTILS.IDENTITY_RESET('GTT_CurntQtrRv');

         INSERT INTO GTT_CurntQtrRv ( 
         	SELECT CustomerEntityId ,
                 SUM(b.CurrentValue)  CurrentValue  
         	  FROM CURDAT_RBL_MISDB_PROD.AdvSecurityDetail A
                   JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.SecurityEntityID = B.SecurityEntityID
                   AND A.EffectiveFromTimeKey <= v_TIMEKEY
                   AND A.EffectiveToTimeKey >= v_TIMEKEY
                   AND B.EffectiveFromTimeKey <= v_TIMEKEY
                   AND B.EffectiveToTimeKey >= v_TIMEKEY
         	  GROUP BY CustomerEntityId );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, CurrentValue
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN GTT_CurntQtrRv B   ON A.CustomerEntityID = B.CUSTOMERENTITYID 
          WHERE A.SourceAlt_Key <> 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurntQtrRv = CurrentValue;
         ------- ----Added By Mandeep (Security Perfection)
         DELETE FROM GTT_CurntQtrRv_Finacle;
         UTILS.IDENTITY_RESET('GTT_CurntQtrRv_Finacle');

         INSERT INTO GTT_CurntQtrRv_Finacle ( 
         	SELECT CustomerEntityId ,
                 SUM(b.CurrentValue)  CurrentValue  
         	  FROM CURDAT_RBL_MISDB_PROD.AdvSecurityDetail A
                   JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.SecurityEntityID = B.SecurityEntityID
                   AND A.EffectiveFromTimeKey <= v_TIMEKEY
                   AND A.EffectiveToTimeKey >= v_TIMEKEY
                   AND B.EffectiveFromTimeKey <= v_TIMEKEY
                   AND B.EffectiveToTimeKey >= v_TIMEKEY
         	 WHERE  A.Sec_Perf_Flg = 'P'
         	  GROUP BY CustomerEntityId );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, B.CurrentValue
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN GTT_CurntQtrRv_Finacle B   ON A.CustomerEntityID = B.CUSTOMERENTITYID 
          WHERE A.SourceAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurntQtrRv = src.CurrentValue;
         /*                  
         --IF OBJECT_ID('TEMPDB..GTT_CurntQtrRv') IS NOT NULL                  
         --DROP TABLE GTT_CurntQtrRv                  

         --SELECT *                    
         --INTO GTT_CurntQtrRv                   
         --FROM dbo.AdvCustSecurityFun(@TIMEKEY)                  

         ------UPDATE A SET A.CurntQtrRv= ISNULL(B.Total_PriSec,0)+ISNULL(B.Total_CollSec,0)                   
         ------FROM PRO.CUSTOMERCAL A INNER  JOIN GTT_CurntQtrRv B                  
         ------ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                  
         */
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CurntQtrRv  AT Customer level';
         --/*----UPDATE SECURITY VALUE AT ACCOUNT LEVEL------------*/                  
         --INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)                  
         --SELECT ORIGINAL_LOGIN(),'UPDATE SECURITY VALUE AT ACCOUNT LEVEL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID                  
         ---Condition Change Required  Modification Done---                   
         /*  commented below code - security will be sum at customer level and appropriate at account                  
         IF OBJECT_ID('TEMPDB..#TEMPSECURITY') IS NOT NULL                  
         DROP TABLE #TEMPSECURITY                  


         ----SELECT *                    
         ----INTO #TEMPSECURITY                  
         ----FROM dbo.AdvAcSecurityFun(@TIMEKEY,'0')                  

         ----UPDATE A SET A.SecurityValue= ISNULL(B.Total_PriSec,0)+ISNULL(B.Total_CollSec,0)  FROM PRO.AccountCal A INNER  JOIN #TEMPSECURITY B                  
         ----ON A.AccountEntityID=B.AccountEntityID                  




         UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND TIMEKEY=@TIMEKEY AND DESCRIPTION='update security value at account level'                  

            --------------------UPDATE FINAL CURNTQTRRV AT  CUSTOMER LEVEL--------------------                   

          INSERT INTO PRO.PROCESSMONITOR(USERID,DESCRIPTION,MODE,STARTTIME,ENDTIME,TIMEKEY,SETID)                   
         SELECT ORIGINAL_LOGIN(),'UPDATE FINAL CURNTQTRRV AT  CUSTOMER LEVEL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SETID                  

         ----UPDATE A SET A.CURNTQTRRV=ISNULL(A.CURNTQTRRV,0) FROM PRO.CUSTOMERCAL A  INNER JOIN                   
         ----(                  
         ----SELECT A.CUSTOMERENTITYID,SUM(ISNULL(A.SecurityValue,0)) as CURNTQTRRV FROM PRO.ACCOUNTCAL A                   
         ----INNER JOIN PRO.CUSTOMERCAL B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                  
         ----WHERE  ISNULL(A.FLGABINITIO,'N')<>'Y'  AND A.FINALASSETCLASSALT_KEY NOT IN (6)                  
         ----and isnull(A.SecurityValue,0)>0                  
         ----GROUP BY A.CUSTOMERENTITYID                  
         ----) B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID                  

         ----UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE FINAL CURNTQTRRV AT  CUSTOMER LEVEL'                  


         ----   --------UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL--------------                  
             INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)                  
          SELECT ORIGINAL_LOGIN(),'UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID                  

          ---Condition Change Required ---                   

         ------ UPDATE A SET FlgSecured='S'                  
         ------FROM PRO.AccountCal A INNER  JOIN dbo.CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B ON A.AccountEntityID=B.AccountEntityID                  
         ------WHERE  (B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY)               
         ------AND B.FlgSecured='S'                  
         ------AND A.FlgSecured='U'                  

         --UPDATE B SET SecApp='S'                  
         --FROM  PRO.AccountCal B                  
         --WHERE ISNULL(SecurityValue,0)>0                  
         --AND B.SecApp='U'                  
         --AND ISNULL(B.BALANCE,0)>0                   
         --AND (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY)                  

         --UPDATE B SET FlgSecured='D'                  
         --FROM  PRO.AccountCal B                  
         --WHERE ISNULL(SecurityValue,0)>0                  
         --AND B.FlgSecured='U'                  
         --AND ISNULL(B.BALANCE,0)>0                   
         --AND (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY)                  
         */
         ---   --/*----UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL------------*/                  
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL B
         USING (SELECT B.ROWID row_id, 'D'
         FROM MAIN_PRO.ACCOUNTCAL B
                JOIN MAIN_PRO.CUSTOMERCAL a   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE NVL(CurntQtrRv, 0) > 0
           AND B.SecApp = 'S'
           AND NVL(B.Balance, 0) > 0) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FlgSecured = 'D';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT
          LEVEL';
         /*----UPDATE FLGABINITIO MARK AT ACCOUNT LEVEL---------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'update FlgAbinitio MARK at account level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required ---   
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Ab-Initio'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgAbinitio = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'update FlgAbinitio MARK at account level';
         /*----UPDATE FLGFITL MARK AT ACCOUNT LEVEL------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'update FlgFITL MARK at account level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A  
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE ( NVL(A.SplCatg1Alt_Key, 0) = 755
           OR NVL(A.SplCatg2Alt_Key, 0) = 755
           OR NVL(A.SplCatg3Alt_Key, 0) = 755
           OR NVL(A.SplCatg4Alt_Key, 0) = 755 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGFITL = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'update FlgFITL MARK at account level';
         /*------------------UPDATE OVERDUESINCEDT FROM BILL DETAIL TABLE------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE OVERDUESINCEDT FROM BILL DETAIL TABLE ' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         ------------------/*------------------CALCULATE MINIMUMN BILL DUE DATE AND BillExtendedDueDt  DATE------------------*/  
         --IF OBJECT_ID('TEMPDB..#TEMPTABLEMINDATEEBill') IS NOT NULL  
         --    DROP TABLE #TEMPTABLEMINDATEEBill  
         --SELECT AccountEntityID,MIN(BILLDUEDT) BILLDUEDT,MIN(BillExtendedDueDt) BillExtendedDueDt   
         --INTO #TEMPTABLEMINDATEEBill  
         --FROM DBO.ADVFACBILLDETAIL   
         --WHERE EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY   
         --AND ISNULL(BALANCE,0)>0  
         --GROUP BY AccountEntityID  
         --/*------------------UPDATE MINIMUMN DATE IN ACCOUNT CAL TABLE------------------*/  
         --IF OBJECT_ID('TEMPDB..#TEMPTABLEMINOVERDUEDT') IS NOT NULL  
         --    DROP TABLE #TEMPTABLEMINOVERDUEDT  
         --SELECT AccountEntityID,PRO.GETMINIMUMDATE(BILLDUEDT,BillExtendedDueDt,NULL) AS MINOVERDUE   
         --INTO #TEMPTABLEMINOVERDUEDT  
         --FROM #TEMPTABLEMINDATEEBill   
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A .ROWID row_id
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE FacilityType IN ( 'BILL','BP','BD' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET PrincOverdueSinceDt = NULL,
                                      IntOverdueSinceDt = NULL,
                                      ReviewDueDt = NULL,
                                      OverDueSinceDt = NULL,
                                      LastCrDate = NULL,
                                      OtherOverdueSinceDt = NULL,
                                      ContiExcessDt = NULL,
                                      StockStDt = NULL,
                                      DebitSinceDt = NULL,
                                      PrincOverdue = 0,
                                      IntOverdue = 0,
                                      OverdueAmt = 0,
                                      OtherOverdue = 0;
         IF utils.object_id('TEMPDB..GTT_BILL_OVERDUE') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_BILL_OVERDUE ';
         END IF;
         DELETE FROM GTT_BILL_OVERDUE;
         UTILS.IDENTITY_RESET('GTT_BILL_OVERDUE');

         INSERT INTO GTT_BILL_OVERDUE ( 
         	SELECT AccountEntityID ,
                 BILLENTITYID ,
                 BALANCE ,
                 CASE 
                      WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
                 ELSE BillExtendedDueDt
                    END BILLDUEDT  

         	  ---MIN(BILLDUEDT) BILLDUEDT,MIN(BillExtendedDueDt) BillExtendedDueDt     
         	  FROM CURDAT_RBL_MISDB_PROD.AdvFacBillDetail 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND BillNatureAlt_Key <> 9
                    AND NVL(BALANCE, 0) > 0
                    AND (CASE 
                              WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
                  ELSE BillExtendedDueDt
                     END) <= 
                  ----)<@PROCESSINGDATE  --  as discussed with Triloki Sir for SMA KIssue - Consider 1 dpd on due date    
                  v_PROCESSINGDATE );
         IF utils.object_id('TEMPDB..tt_BILL_OVERDUE_18_FINAL') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_BILL_OVERDUE_FINAL ';
         END IF;
         DELETE FROM GTT_BILL_OVERDUE_FINAL;
         UTILS.IDENTITY_RESET('GTT_BILL_OVERDUE_FINAL');

         INSERT INTO GTT_BILL_OVERDUE_FINAL ( 
         	SELECT AccountEntityId ,
                 SUM(BALANCE)  BILOVERDUE  ,
                 MIN(BILLDUEDT)  BILLOVERDUEDT  
         	  FROM GTT_BILL_OVERDUE 
         	  GROUP BY AccountEntityId );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.BILLOVERDUEDT, B.BILOVERDUE
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_BILL_OVERDUE_FINAL B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.OVERDUESINCEDT = src.BILLOVERDUEDT,
                                      A.OverdueAmt = src.BILOVERDUE;
         --=====SCF SOURCE SYSTEM CHANGES==================================================================================================
         IF utils.object_id('TEMPDB..tt_BILL_OVERDUE_18_SCF') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_BILL_OVERDUE_SCF ';
         END IF;
         DELETE FROM GTT_BILL_OVERDUE_SCF;
         UTILS.IDENTITY_RESET('GTT_BILL_OVERDUE_SCF');

         INSERT INTO GTT_BILL_OVERDUE_SCF ( 
         	SELECT AccountEntityID ,
                 MIN(BillDueDt)  BillDueDt  ,
                 MIN(InterestOverdueDate)  InterestOverdueDate  ,
                 SUM(Balance)  Balance  ,
                 SUM(OverdueInterest)  OverdueInterest  
         	  FROM CURDAT_RBL_MISDB_PROD.AdvFacBillDetail 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND BillNatureAlt_Key = 9
                    AND NVL(Balance, 0) > 0
                    AND ( BillDueDt <= v_ProcessingDate
                    OR InterestOverdueDate <= v_ProcessingDate )
         	  GROUP BY AccountEntityId );
         IF utils.object_id('TEMPDB..GTT_BILL_OVERDUE_SCF_FINAL') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_BILL_OVERDUE_SCF_FINAL ';
         END IF;
         DELETE FROM GTT_BILL_OVERDUE_SCF_FINAL;
         UTILS.IDENTITY_RESET('GTT_BILL_OVERDUE_SCF_FINAL');

         INSERT INTO GTT_BILL_OVERDUE_SCF_FINAL ( 
         	SELECT AccountEntityId ,
                 Balance ,
                 overdueinterest ,
                 GETMINIMUMDATE(BillDueDt, InterestOverdueDate, NULL) OverDueSinceDt  ,
                 InterestOverdueDate ,
                 BillDueDt 
         	  FROM GTT_BILL_OVERDUE_SCF  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.BillDueDt, B.InterestOverdueDate, B.OverDueSinceDt, NVL(B.Balance, 0) AS pos_5, NVL(B.Balance, 0) - NVL(B.OverdueInterest, 0) AS pos_6, NVL(B.OverdueInterest, 0) AS pos_7
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_BILL_OVERDUE_SCF_FINAL B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PrincOverdueSinceDt = src.BillDueDt,
                                      A.IntOverdueSinceDt = src.InterestOverdueDate,
                                      A.OverDueSinceDt = src.OverDueSinceDt,
                                      A.OverdueAmt --OverdueInterest may be add as per comfirmation by sitaram sir
                                       = pos_5,
                                      A.PrincOverdue = pos_6,
                                      A.IntOverdue = pos_7;
         IF utils.object_id('TEMPDB..GTT_BILL_Min_ReviewDt') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_BILL_Min_ReviewDt ';
         END IF;
         DELETE FROM GTT_BILL_Min_ReviewDt;
         UTILS.IDENTITY_RESET('GTT_BILL_Min_ReviewDt');

         INSERT INTO GTT_BILL_Min_ReviewDt ( 
         	SELECT AccountEntityId ,
                 MIN(ReviewDuedate)  ReviewDuedate  
         	  FROM CURDAT_RBL_MISDB_PROD.AdvFacBillDetail 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND BillNatureAlt_Key = 9
         	  GROUP BY AccountEntityId );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, ReviewDuedate
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_BILL_Min_ReviewDt B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ReviewDueDt = ReviewDuedate;
         --=====================================================SCF BILL END===========================================================================
         --IF OBJECT_ID('TEMPDB..tt_BILL_OVERDUE_18_FINAL') IS NOT NULL  
         --    DROP TABLE tt_BILL_OVERDUE_18_FINAL  
         --SELECT AccountEntityId,SUM(BALANCE) BILOVERDUE,MIN(BILLDUEDT) BILLOVERDUEDT  
         -- INTO tt_BILL_OVERDUE_18_FINAL  
         --FROM GTT_BILL_OVERDUE GROUP BY AccountEntityId  
         --UPDATE PRO.ACCOUNTCAL SET OVERDUESINCEDT=B.BILLOVERDUEDT ,OverdueAmt  =B.BILOVERDUE  
         --FROM  PRO.ACCOUNTCAL A   
         --INNER JOIN tt_BILL_OVERDUE_18_FINAL B  
         -- ON A.AccountEntityID =B.AccountEntityId  
         --INNER JOIN #TEMPTABLEMINOVERDUEDT B ON A.AccountEntityID=B.AccountEntityID AND B.MINOVERDUE < = @PROCESSINGDATE  
         --IF OBJECT_ID('TEMPDB..#TEMPTABLEMINDATEPC') IS NOT NULL  
         --    DROP TABLE #TEMPTABLEMINDATEPC  
         --SELECT AccountEntityID,MIN(PCDueDt) PCDueDt,MIN(PCExtendedDueDt) PCExtendedDueDt   
         --INTO #TEMPTABLEMINDATEPC  
         --FROM DBO.ADVFACPCDETAIL   
         --WHERE EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY   
         --AND ISNULL(BALANCE,0)>0  
         --GROUP BY AccountEntityID  
         --/*------------------UPDATE MINIMUMN DATE IN ACCOUNT CAL TABLE------------------*/  
         --IF OBJECT_ID('TEMPDB..#TEMPTABLEMINOVERDUEDTPC') IS NOT NULL  
         --    DROP TABLE #TEMPTABLEMINOVERDUEDTPC  
         --SELECT AccountEntityID,PRO.GETMINIMUMDATE(PCDueDt,PCExtendedDueDt,NULL) AS MINOVERDUE   
         --INTO #TEMPTABLEMINOVERDUEDTPC  
         --FROM #TEMPTABLEMINDATEPC   
         IF utils.object_id('TEMPDB..GTT_PC_OVERDUE') IS NOT NULL THEN
          --update a  
         --set a.InitialNpaDt =b.FinalNpaDt  
         --from PRO.ACCOUNTCAL A   
         --INNER JOIN PRO.AccountCal_Hist B  
         -- ON A.AccountEntityID =B.AccountEntityID  
         --WHERE A.INITIALASSETCLASSALT_KEY>1  
         --AND A.InitialNpaDt  is NULL   
         --AND B.EffectiveFromTimeKey<=@HistTimeKey AND B.EffectiveToTimeKey>=@HistTimeKey  
         ----/*  UPDATE MOC STATUS  */  
         ---- DECLARE @PrevMonthTimeKey INT=(SELECT LastMonthDateKey FROM RBL_MISDB_PROD.SysDayMatrix WHERE TimeKey =@TIMEKEY)  
         /* LOAN BUYOUT WORK */
         /* RESET BELOW FIELDS FOR LOANBUYOUT ACCOUNTS */
         /* END OF BUYOUT WORK */
         /*RESTRUCTURE UPDATES */
         --AND B.DPD_Breach_Date IS NOT NULL  
         /* END OF RESTRUCTURE WORK*/
         /* START OF PUI WORK*/
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PC_OVERDUE ';
         END IF;
         DELETE FROM GTT_PC_OVERDUE;
         UTILS.IDENTITY_RESET('GTT_PC_OVERDUE');

         INSERT INTO GTT_PC_OVERDUE ( 
         	SELECT AccountEntityID ,
                 PCRefNo ,
                 BALANCE ,
                 CASE 
                      WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                 ELSE PCExtendedDueDt
                    END PCOVERDUEDUEDT  

         	  ---MIN(BILLDUEDT) BILLDUEDT,MIN(BillExtendedDueDt) BillExtendedDueDt   
         	  FROM CURDAT_RBL_MISDB_PROD.AdvFacPCDetail 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND NVL(BALANCE, 0) > 0
                    AND (CASE 
                              WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                  ELSE PCExtendedDueDt
                     END) <= 
                  ----- )<=@PROCESSINGDATE  --  as discussed with Triloki Sir for SMA KIssue - Consider 1 dpd on due date  
                  v_PROCESSINGDATE );
         IF utils.object_id('TEMPDB..tt_PC_OVERDUE_18_FINAL') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_PC_OVERDUE_FINAL ';
         END IF;
         DELETE FROM GTT_PC_OVERDUE_FINAL;
         UTILS.IDENTITY_RESET('GTT_PC_OVERDUE_FINAL');

         INSERT INTO GTT_PC_OVERDUE_FINAL ( 
         	SELECT AccountEntityId ,
                 SUM(BALANCE)  PCOVERDUE  ,
                 MIN(PCOVERDUEDUEDT)  PCOVERDUEDUEDT  
         	  FROM GTT_PC_OVERDUE 
         	  GROUP BY AccountEntityId );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.PCOVERDUEDUEDT, B.PCOVERDUE
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_PC_OVERDUE_FINAL B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.OVERDUESINCEDT = src.PCOVERDUEDUEDT,
                                      A.OverdueAmt = src.PCOVERDUE;
         --INNER JOIN #TEMPTABLEMINOVERDUEDTPC B ON A.AccountEntityID=B.AccountEntityID AND B.MINOVERDUE < = @PROCESSINGDATE  
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE OVERDUESINCEDT FROM BILL DETAIL TABLE';
         /*-----UPDATE COVERGOVGUR BILL AT ACCOUNT LEVEL-------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur BILL AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, C.COVERGOVGUR
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN ( SELECT A.AccountEntityID ,
                              SUM(NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0))  COVERGOVGUR  
                       FROM CURDAT_RBL_MISDB_PROD.AdvFacBillDetail A
                              JOIN MAIN_PRO.ACCOUNTCAL B   ON A.ACCOUNTENTITYID = B.AccountEntityID
                        WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                 AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                         GROUP BY A.ACCOUNTENTITYID ) C   ON A.ACCOUNTENTITYID = C.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.COVERGOVGUR = src.COVERGOVGUR;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur BILL AT ACCOUNT LEVEL';
         /*-----UPDATE COVERGOVGUR PC AT ACCOUNT LEVEL-------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur PC AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, C.COVERGOVGUR
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN ( SELECT A.AccountEntityID ,
                              SUM(NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0))  COVERGOVGUR  
                       FROM CURDAT_RBL_MISDB_PROD.AdvFacPCDetail A
                              JOIN MAIN_PRO.ACCOUNTCAL B   ON A.ACCOUNTENTITYID = B.AccountEntityID
                        WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                 AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                         GROUP BY A.ACCOUNTENTITYID ) C   ON A.ACCOUNTENTITYID = C.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.COVERGOVGUR = src.COVERGOVGUR;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur PC AT ACCOUNT LEVEL';
         /*-----UPDATE COVERGOVGUR DL AT ACCOUNT LEVEL-------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur DL AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) AS CoverGovGur
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.ADVFACDLDETAIL B   ON A.AccountEntityID = B.ACCOUNTENTITYID 
          WHERE NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) > 0
           AND ( B.EffectiveFromTimeKey <= v_timekey
           AND B.EffectiveToTimeKey >= v_timekey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CoverGovGur = src.CoverGovGur;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur DL AT ACCOUNT LEVEL';
         /*-----UPDATE COVERGOVGUR CC AT ACCOUNT LEVEL-------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur CC AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) AS CoverGovGur
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.ADVFACCCDETAIL B   ON A.AccountEntityID = B.ACCOUNTENTITYID 
          WHERE NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) > 0
           AND ( B.EffectiveFromTimeKey <= v_timekey
           AND B.EffectiveToTimeKey >= v_timekey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CoverGovGur = src.CoverGovGur;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur CC AT ACCOUNT LEVEL';
         /*---------UPDATE PRVQTRINT,CURQTRINT,CURQTRCREDIT,PREQTRCREDIT-------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE PrvQtrInt,CurQtrInt,CurQtrCredit,PreQtrCredit' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required  Modification Done---   
         /*------------------Update PRVQTRINT,CURQTRINT,CURQTRCREDIT,PREQTRCREDIT------------------*/
         ------------IF (@PROCESSMONTH = EOMONTH(@PROCESSMONTH))  
         ------------BEGIN  
         ------------EXEC [PRO].[UpdateCADCADURefBalRecovery] @TimeKey=@TimeKey  
         ------------END  
         ------------IF (@PROCESSMONTH <> EOMONTH(@PROCESSMONTH))  
         ------------BEGIN  
         ------------UPDATE a set CurQtrCredit=b.CurQtrCredit,CurQtrInt=b.CurQtrInt  
         ------------from pro.accountcal a  
         ------------inner join pro.accountcal_hist b  
         ------------on a.CustomerAcID=b.CustomerAcID  
         ------------where a.FinalAssetClassAlt_Key>1  
         ------------AND (B.EffectiveFromTimeKey<=@LastMonthDateKey and B.EffectiveToTimeKey>=@LastMonthDateKey)  
         ------------END  
         -----------------------------------------------------------------------------------------------------------------  
         --DROP TABLE IF EXISTS GTT_CCOD_90DAYS_INTT_CR_AMT  
         --SELECT A.CustomerAcID,  
         --   SUM(CASE WHEN TXNTYPE='DEBIT' AND TXNSUBTYPE='INTEREST' THEN TXNAMOUNT ELSE 0 END)  InterestAmt  
         --  ,SUM(CASE WHEN TXNTYPE='CREDIT'  THEN TXNAMOUNT ELSE 0 END)  CreditAmt  
         -- INTO GTT_CCOD_90DAYS_INTT_CR_AMT  
         -- --SELECT A.CustomerID,a.CustomerACID,TxnDate,TxnType,TxnSubType,TxnAmount,TxnAmountInCurrency,TxnRefNo,Particular  
         --FROM CURDAT_RBL_MISDB_PROD.AcDailyTxnDetail a  
         -- INNER JOIN RBL_MISDB.DBO.CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B  
         --  ON A.AccountEntityId =B.AccountEntityId  
         --  AND B.EffectiveFromTimeKey<=26372 AND B.EffectiveToTimeKey>=26372  
         --  AND B.FacilityType IN('CC','OD')  
         --  --AND A.CUSTOMERACID='609000855742'  
         --where txndate between DATEADD(DD,-89,@ProcessingDate) and @ProcessingDate  
         --GROUP BY A.CustomerAcID  
         ----ORDER BY TxnDate,B.CustomerACID,RefCustomerId  
         --------------------------------------------Added By prashant 08-04-2022 as per Ashish sir--------------------------------------------------------  
         
         DELETE FROM GTT_CCOD_90DAYS_INTT_CR_AMT;
         UTILS.IDENTITY_RESET('GTT_CCOD_90DAYS_INTT_CR_AMT');

         INSERT INTO GTT_CCOD_90DAYS_INTT_CR_AMT ( 
         	SELECT A.CustomerAcID ,
                 SUM(CASE 
                          WHEN TXNTYPE = 'DEBIT' THEN TXNAMOUNT
                     ELSE 0
                        END)  InterestAmt  ,
                 SUM(CASE 
                          WHEN TXNTYPE = 'CREDIT' THEN TXNAMOUNT
                     ELSE 0
                        END)  CreditAmt  

         	  --SELECT A.CustomerID,a.CustomerACID,TxnDate,TxnType,TxnSubType,TxnAmount,TxnAmountInCurrency,TxnRefNo,Particular  
         	  FROM CURDAT_RBL_MISDB_PROD.AcDailyTxnDetail a
                   JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityId = B.AccountEntityId
                   AND B.EffectiveFromTimeKey <= v_TIMEKEY
                   AND B.EffectiveToTimeKey >= v_TIMEKEY
                   AND B.FacilityType IN ( 'CC','OD' )


         	--AND A.CUSTOMERACID='609000855742'  
         	WHERE  txndate BETWEEN utils.dateadd('DD', -89, v_ProcessingDate) AND v_ProcessingDate
         	  GROUP BY A.CustomerAcID );
         --ORDER BY TxnDate,B.CustomerACID,RefCustomerId  
         -------------------------------------------------------------------------------------------------------------------------------  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.ACCOUNTCAL A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurQtrCredit = 0,
                                      A.CurQtrInt = 0,
                                      A.INTNOTSERVICEDDT = NULL,
                                      A.InttServiced = NULL;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, CreditAmt, InterestAmt
         FROM MAIN_PRO.ACCOUNTCAL a
                LEFT JOIN GTT_CCOD_90DAYS_INTT_CR_AMT b   ON A.CustomerAcID = b.CustomerAcID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurQtrCredit = CreditAmt,
                                      A.CurQtrInt = InterestAmt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PrvQtrInt,CurQtrInt,CurQtrCredit,PreQtrCredit';
         /*------------------UPDATE INTSERVICESDT IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE INTNOTSERVICEDDT IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         /*amar 30102021 AS PER DISCUSSIONS with sharma sir and ahishi sir intereset services WILL BE EXECUTING PN QTR END DATE */
         --IF (  (MONTH(@ProcessingDate) IN(3,12) AND DAY(@ProcessingDate)=31)  
         --   OR (MONTH(@ProcessingDate) IN(6,9)  AND DAY(@ProcessingDate)=30)  
         -- )  
         -- BEGIN  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'N', utils.dateadd('DAY', -89, v_PROCESSINGDATE) AS pos_3
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail ABD   ON ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                AND ABD.EffectiveToTimeKey >= v_TIMEKEY )
                AND ABD.AccountEntityId = A.AccountEntityID 
          WHERE NVL(A.Balance, 0) > 0
           AND NVL(A.CurQtrCredit, 0) < NVL(A.CurQtrInt, 0)
           AND A.FacilityType IN ( 'CC','OD' )

            /* REMOVED CONDITION FOR FirstDtOfDisb AS DISCUSSED WITH SHARMA SIR ON 04102021*/
           AND ( Asset_Norm <> 'ALWYS_STD' )

           ----AND (DATEADD(DAY,90,A.FirstDtOfDisb)<@PROCESSINGDATE AND A.FirstDtOfDisb IS NOT NULL AND Asset_Norm<>'ALWYS_STD' )  
           AND C.EffectiveFromTimeKey <= v_timekey
           AND C.EffectiveToTimeKey >= v_timekey

           ----AND C.NPANorms='DPD91'  
           AND ABD.ReferencePeriod = 91) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                      A.INTNOTSERVICEDDT = pos_3;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'N', NULL
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail ABD   ON ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                AND ABD.EffectiveToTimeKey >= v_TIMEKEY )
                AND ABD.AccountEntityId = A.AccountEntityID 
          WHERE A.FacilityType IN ( 'CC','OD' )

           AND ( utils.dateadd('DAY', 89, A.DebitSinceDt) > v_PROCESSINGDATE
           AND A.DebitSinceDt IS NOT NULL
           AND Asset_Norm <> 'ALWYS_STD' )
           AND C.EffectiveFromTimeKey <= v_timekey
           AND C.EffectiveToTimeKey >= v_timekey

           --AND C.NPANorms='DPD91'  
           AND InttServiced = 'N'
           AND ABD.ReferencePeriod = 91) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                      A.INTNOTSERVICEDDT = NULL;
         --END  
         --UPDATE A SET A.OVERDUEAMT=B.DEMANDAMT  
         --            ,A.INTNOTSERVICEDDT=B.DEMANDDATE  
         --FROM PRO.ACCOUNTCAL A  INNER JOIN RBL_MISDB_PROD.DimProduct C   
         -- ON A.ProductAlt_Key=C.ProductAlt_Key   
         --INNER JOIN   
         --(  
         --SELECT  AccountEntityID ,SUM(BalanceDemand) DEMANDAMT,MIN(DemandOverDueDate) DEMANDDATE   
         --FROM CurDat.AdvAcDemandDetail  
         --where EffectiveFromTimeKey<=@timekey AND EffectiveToTimeKey>=@timekey  
         --and ISNULL(BalanceDemand,0) > 0  
         --GROUP BY AccountEntityID  
         --) B  ON A.AccountEntityID=B.AccountEntityID   
         --AND C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey  
         --AND C.NPANorms='DPD366'  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'N', OverdueIntDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBasicDetail ABD   ON ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                AND ABD.EffectiveToTimeKey >= v_TIMEKEY )
                AND ABD.AccountEntityId = A.AccountEntityID
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcBalanceDetail BAL   ON ( BAL.EffectiveFromTimeKey <= v_TIMEKEY
                AND BAL.EffectiveToTimeKey >= v_TIMEKEY )
                AND BAL.AccountEntityId = A.AccountEntityID 
          WHERE A.FacilityType IN ( 'CC','OD' )

           AND ( utils.dateadd('DAY', 90, A.DebitSinceDt) > v_PROCESSINGDATE
           AND A.DebitSinceDt IS NOT NULL
           AND Asset_Norm <> 'ALWYS_STD' )
           AND C.EffectiveFromTimeKey <= v_timekey
           AND C.EffectiveToTimeKey >= v_timekey

           --AND C.NPANorms='DPD91'  

           --AND InttServiced='N'  
           AND ABD.ReferencePeriod IN ( 366,181 )

           AND c.Agrischeme = 'Y') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                      A.INTNOTSERVICEDDT = OverdueIntDt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE INTNOTSERVICEDDT IN PRO.ACCOUNTCAL';
         /*------------OVERDUE SINCE DATE IS AVAILABLE BUT OVERDUE AMOUT IS ZERO-----------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'OVERDUE SINCE DATE IS AVAILABLE BUT OVERDUE AMOUT IS ZERO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ------UPDATE A  SET A.OverDueSinceDt=(CASE WHEN isnull(A.OverdueAmt,0)<=0 THEN NULL ELSE A.OverDueSinceDt END)  
         ------FROM PRO.AccountCal A  
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'OVERDUE SINCE DATE IS AVAILABLE BUT OVERDUE AMOUT IS ZERO';
         ----/*-----Stock statement date Data Preperation----------------------------------------------------*/  
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Stock statement date Data Preperation' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         IF utils.object_id('Tempdb..GTT_STOCK') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_STOCK ';
         END IF;
         DELETE FROM GTT_STOCK;
         UTILS.IDENTITY_RESET('GTT_STOCK');

         INSERT INTO GTT_STOCK ( 
         	SELECT AccountEntityId ,
                 MIN(ValuationDt)  StkSmtDt  ,
                 'S' TYPE  
         	  FROM ( SELECT Advsec.AccountEntityId ,
                          SecurityShortNameEnum ,
                          NVL(MAX(SecDtl.ValuationDate) , '9999-01-01') ValuationDt  
                   FROM CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail SecDtl
                          JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityDetail Advsec   ON Advsec.SecurityEntityID = SecDtl.SecurityEntityID
                          JOIN RBL_MISDB_PROD.DimSecurity sec   ON SecDtl.EffectiveFromTimeKey <= v_TimeKey
                          AND SecDtl.EffectiveToTimeKey >= v_TimeKey
                          AND Sec.EffectiveFromTimeKey <= v_TimeKey
                          AND Sec.EffectiveToTimeKey >= v_TimeKey
                          AND Advsec.SecurityAlt_Key = Sec.SecurityAlt_Key
                          AND Advsec.EffectiveFromTimeKey <= v_TimeKey
                          AND Advsec.EffectiveToTimeKey >= v_TimeKey
                    WHERE  SecurityShortNameEnum IN ( 'HYP-STOCK','HYP-BDEBT' )

                             AND Advsec.SecurityType = 'P'
                             AND ValuationDate IS NOT NULL
                     GROUP BY Advsec.AccountEntityId,SecurityShortNameEnum ) ST
         	  GROUP BY AccountEntityId );
         ----CREATE CLUSTERED INDEX GTT_STOCK_IX ON GTT_STOCK(AccountEntityId)  
         ----CREATE NONCLUSTERED INDEX GTT_STOCKNON ON GTT_STOCK(AccountEntityId,StkSmtDt)  
         ----IF OBJECT_ID('Tempdb..GTT_STOCK2') IS NOT NULL  
         ----DROP TABLE GTT_STOCK2  
         ----SELECT  AccountEntityId,MIN(ValuationDt) StkSmtDt,'W' TYPE  
         ----INTO GTT_STOCK2  
         ----FROM(SELECT SecDtl.AccountEntityId ,SecurityShortNameEnum,ISNULL(MAX(SecDtl.ValuationDt),'9999-01-01') ValuationDt   
         ----            FROM dbo.CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail SecDtl  
         ----            INNER  JOIN RBL_MISDB_PROD.DimSecurity sec ON SecDtl.EffectiveFromTimeKey < = @TimeKey  
         ----                                          AND SecDtl.EffectiveToTimeKey   >= @TimeKey  
         ----                        AND Sec.EffectiveFromTimeKey < = @TimeKey  
         ----                                          AND Sec.EffectiveToTimeKey > = @TimeKey  
         ----            AND SecDtl.SecurityAlt_Key = Sec.SecurityAlt_Key  
         ----   WHERE SecurityShortNameEnum IN('PLD- WAREC-GEN','PLD- WAREC-NBHC','PLD- WAREC-NCMSL','PLD- WAREC-CWC','CARNC','CSRNC','WHRDMAT'  
         ----            ,'WHRMSW','WHRNG','WHRSACML','WHRSSL')  
         ----   AND  SecDtl.SecurityType='P'   
         ----   GROUP BY SecDtl.AccountEntityId,SecurityShortNameEnum) ST  
         ----   GROUP BY AccountEntityId  
         ----CREATE CLUSTERED INDEX GTT_STOCK2_IX ON GTT_STOCK2(AccountEntityId)  
         ----CREATE NONCLUSTERED INDEX GTT_STOCK2NON ON GTT_STOCK2(AccountEntityId,StkSmtDt)  
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'STOCK STATEMENT DATE DATA PREPERATION';
         /*-----UPDATE STOCK STATEMENT DATE IN PRO.ACCOUNTCAL----------------------------------------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'update stock statement date in pro.accountcal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         /*  amar  - 12062021 commented temporary for use stock date as provided in excel data  as discussed with Sharma Sir*/
         --UPDATE A SET A.StockStDt=StkSmtDt  
         --FROM PRO.AccountCal A   
         --INNER  JOIN GTT_STOCK SD ON A.AccountEntityId=SD.AccountEntityId  
         --where A.FacilityType='CC'  
         /* Added by amar on 17062021 for  get the stock  */
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, StockStmtDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.ADVFACCCDETAIL SD   ON A.AccountEntityID = SD.AccountEntityId 
          WHERE A.FacilityType = 'CC'
           AND SD.EffectiveFromTimeKey <= v_TimeKey
           AND SD.EffectiveToTimeKey >= v_TimeKey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.StockStDt = StockStmtDt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'update stock statement date in pro.accountcal';
         /*------UPDATE DerecognisedInterest1 AMT IN PRO.ACCOUNTCAL---------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE DerecognisedInterest1 AMT IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         IF utils.object_id('TEMPDB..GTT_TEMPDerecognisedInterest') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMPDerecognisedInterest ';
         END IF;
         DELETE FROM GTT_TEMPDerecognisedInterest;
         INSERT INTO GTT_TEMPDerecognisedInterest
           ( AccountEntityId, DerecognisedInterest1 )
           ( SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM CURDAT_RBL_MISDB_PROD.AdvFacBillDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION 
             SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM CURDAT_RBL_MISDB_PROD.AdvFacPCDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION ALL 
             SELECT B.ACCOUNTENTITYID ,
                    SUM(NVL(B.DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM CURDAT_RBL_MISDB_PROD.ADVFACCCDETAIL B
              WHERE  ( B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY B.ACCOUNTENTITYID
             UNION ALL 
             SELECT C.ACCOUNTENTITYID ,
                    SUM(NVL(C.DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM CURDAT_RBL_MISDB_PROD.ADVFACDLDETAIL C
              WHERE  ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY C.ACCOUNTENTITYID );
         /*-----UPDATE DerecognisedInterest1 IN PRO.ACCOUNTCAL TABLE ----------------------------*/
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.DerecognisedInterest1
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_TEMPDerecognisedInterest B   ON A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DerecognisedInterest1 = src.DerecognisedInterest1;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE DerecognisedInterest1 AMT IN PRO.ACCOUNTCAL';
         /*------UPDATE DerecognisedInterest2 AMT IN PRO.ACCOUNTCAL---------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE DerecognisedInterest2 AMT IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         IF utils.object_id('TEMPDB..tt_TEMPDerecognisedInterest_36') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPDerecognisedInterest_36 ';
         END IF;
         DELETE FROM tt_TEMPDerecognisedInterest_36;
         INSERT INTO tt_TEMPDerecognisedInterest_36
           ( AccountEntityId, DerecognisedInterest2 )
           ( SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM CURDAT_RBL_MISDB_PROD.AdvFacBillDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION 
             SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM CURDAT_RBL_MISDB_PROD.AdvFacPCDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION ALL 
             SELECT B.ACCOUNTENTITYID ,
                    SUM(NVL(B.DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM CURDAT_RBL_MISDB_PROD.ADVFACCCDETAIL B
              WHERE  ( B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY B.ACCOUNTENTITYID
             UNION ALL 
             SELECT C.ACCOUNTENTITYID ,
                    SUM(NVL(C.DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM CURDAT_RBL_MISDB_PROD.ADVFACDLDETAIL C
              WHERE  ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY C.ACCOUNTENTITYID );
         /*-----UPDATE DerecognisedInterest2 IN PRO.ACCOUNTCAL TABLE ----------------------------*/
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.DerecognisedInterest2
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN tt_TEMPDerecognisedInterest_36 B   ON A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DerecognisedInterest2 = src.DerecognisedInterest2;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE DerecognisedInterest2 AMT IN PRO.ACCOUNTCAL';
         /*-------------UPDATE GovGurAmt FROM ADVACOTHERDETAIL-------------------------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE GovGurAmt FROM ADVACOTHERDETAIL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, NVL(B.GovGurAmt, 0) AS GovtGtyAmt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcOtherDetail B   ON A.AccountEntityID = B.AccountEntityId
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE NVL(B.GovGurAmt, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.GovtGtyAmt = src.GovtGtyAmt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE GovGurAmt FROM ADVACOTHERDETAIL';
         /*-------------UPDATE UnserviedInt FROM AdvAcFinancialDetail-------------------------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE UnserviedInt FROM AdvAcFinancialDetail' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         /*  as discussionsed with Mr.Ashish -RBL and Sharma Sir also Email from Mr. Assish on 27-07-2021 for remove Unapplied intte checking when upgrading account  */
         /*  
         --update A SET UnserviedInt=B.UnAppliedIntAmount  
         --FROM PRO.AccountCal  A  
         --inner join DBO.CURDAT_RBL_MISDB_PROD.AdvAcBalanceDetail  B on (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY )  
         --and a.AccountEntityID=B.AccountEntityId    
         --WHERE B.UnAppliedIntAmount>0  
         */
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE UnserviedInt FROM AdvAcFinancialDetail';
         /*------------------UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 870, 6
         --,A.FinalNpaDt=CASE WHEN StatusDate is NULL then @PROCESSINGDATE else  StatusDate end  
         , CASE 
         WHEN a.FinalNpaDt IS NOT NULL
           AND a.FinalNpaDt < NVL(b.StatusDate, v_ProcessingDate) THEN a.FinalNpaDt
         ELSE NVL(b.StatusDate, v_ProcessingDate)
            END AS pos_5, 'NPA DUE TO FRAUD MARKING' AS pos_6
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Fraud Committed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.SplCatg4Alt_Key = 870,
                                      A.FinalAssetClassAlt_Key = 6,
                                      A.FinalNpaDt --Email date 16-06-2022---For Fraud cases date of NPA should be earlier of fraud date or NPA date before marking account as fraud.
                                       = pos_5,
                                      A.NPA_Reason = pos_6;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL';
         /*------------------UPDATE FRAUD ACCOUNT MARKING  IN PRO.CustomerCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE FRAUD ACCOUNT MARKING  IN PRO.CustomerCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.CUSTOMERCAL C
         USING (SELECT C.ROWID row_id, 'ALWYS_NPA', 870, 6
         --,C.SYSNPA_DT=CASE WHEN StatusDate is NULL then @PROCESSINGDATE else  StatusDate end  
         , CASE 
         WHEN C.SysNPA_Dt IS NOT NULL
           AND C.SysNPA_Dt < NVL(b.StatusDate, v_ProcessingDate) THEN C.SysNPA_Dt
         ELSE NVL(b.StatusDate, v_ProcessingDate)
            END AS pos_5, 'NPA DUE TO FRAUD MARKING' AS pos_6
         FROM MAIN_PRO.CUSTOMERCAL C
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON c.RefCustomerID = b.CustomerID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Fraud Committed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET C.Asset_Norm = 'ALWYS_NPA',
                                      C.SplCatg4Alt_Key = 870,
                                      C.SYSASSETCLASSALT_KEY = 6,
                                      C.SYSNPA_DT --Email date 16-06-2022---For Fraud cases date of NPA should be earlier of fraud date or NPA date before marking account as fraud.
                                       = pos_5,
                                      C.DEGREASON = pos_6;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  ) AND 
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE FRAUD ACCOUNT MARKING  IN PRO.CustomerCal';
         /*------------------UPDATE IBPC MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE IBPC MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.IBPCFinalPoolDetail B   ON a.CustomerAcID = b.ACCOUNTID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsIBPC = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE IBPC MARKING  IN PRO.AccountCal';
         /*------------------UPDATE Securitised MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Securitised MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.SecuritizedFinalACDetail b   ON a.CustomerAcID = b.ACCOUNTID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsSecuritised = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Securitised MARKING  IN PRO.AccountCal';
         /*------------------UPDATE PUI MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE PUI MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcPUIDetailMain b   ON a.CustomerAcID = b.ACCOUNTID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PUI = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PUI MARKING  IN PRO.AccountCal';
         /*------------------UPDATE RFA MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE RFA MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'RFA'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RFA = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
          TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE RFA MARKING  IN PRO.AccountCal';
         /*------------------UPDATE NonCooperative MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE NonCooperative MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Non-cooperative'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsNonCooperative = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE NonCooperative MARKING  IN PRO.AccountCal';
         /*------------------UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Repossesed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RePossession = 'Y';
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN REPOSSESSIONDATE IS NULL THEN v_PROCESSINGDATE
         ELSE REPOSSESSIONDATE
            END AS pos_4, 'NPA DUE TO Repossessed Account' AS pos_5, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Repossesed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.FinalAssetClassAlt_Key = 2,
                                      A.FinalNpaDt --FinalNpaDt  
                                       = pos_4,
                                      A.NPA_Reason = pos_5,
                                      A.RePossession = 'Y';
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO Repossessed Account' AS pos_3, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Repossesed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.NPA_Reason = pos_3,
                                      A.RePossession = 'Y';
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
          WHERE b.RePossession = 'Y') src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      a.SysNPA_Dt = src.FinalNpaDt,
                                      a.DegReason = src.NPA_Reason,
                                      a.Asset_Norm = src.Asset_Norm;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL';
         /*------------------UPDATE Inherent Weakness  ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Inherent Weakness ACCOUNT MARKING  IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
         ELSE FinalNpaDt
            END AS pos_4, 'NPA DUE TO Inherent Weakness Account' AS pos_5, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Inherent Weakness'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.FinalAssetClassAlt_Key = 2,
                                      A.FinalNpaDt = pos_4,
                                      A.NPA_Reason = pos_5,
                                      A.WeakAccount = 'Y';
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO Inherent Weakness Account' AS pos_3, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Inherent Weakness'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.NPA_Reason = pos_3,
                                      A.WeakAccount = 'Y';
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
          WHERE b.WeakAccount = 'Y') src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      a.SysNPA_Dt = src.FinalNpaDt,
                                      a.DegReason = src.NPA_Reason,
                                      a.Asset_Norm = src.Asset_Norm;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )AND 
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Inherent Weakness ACCOUNT MARKING  IN PRO.ACCOUNTCAL';
         /*------------------UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'SARFAESI'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Sarfaesi = 'Y';
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
         ELSE FinalNpaDt
            END AS pos_4, 'NPA DUE TO SARFAESI  Account' AS pos_5
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'SARFAESI'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.FinalAssetClassAlt_Key = 2,
                                      A.FinalNpaDt = pos_4,
                                      A.NPA_Reason = pos_5;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO Sarfaesi Account' AS pos_3, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'SARFAESI'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.NPA_Reason = pos_3,
                                      A.Sarfaesi = 'Y';
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
          WHERE b.Sarfaesi = 'Y') src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      a.SysNPA_Dt = src.FinalNpaDt,
                                      a.DegReason = src.NPA_Reason,
                                      a.Asset_Norm = src.Asset_Norm;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL';
         /*------------------UPDATE RC-Pending MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE RC-Pending MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'Y'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM RBL_MISDB_PROD.dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'RC Pending'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RCPending = 'Y';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE RC-Pending MARKING  IN PRO.AccountCal';
         /*------------------UPDATE Written-Off Accounts ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Written-Off Accounts MARKING IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 860, 2, CASE 
         WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
         ELSE FinalNpaDt
            END AS pos_5, 'NPA DUE TO Written-Off Account' AS pos_6
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN CURDAT_RBL_MISDB_PROD.AdvAcOtherDetail B   ON A.AccountEntityID = B.AccountEntityID
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE 860 IN ( NVL(B.SplCatg1Alt_Key, 0),NVL(B.SplCatg2Alt_Key, 0),NVL(B.SplCatg3Alt_Key, 0),NVL(B.SplCatg4Alt_Key, 0) )

           AND FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.SplCatg4Alt_Key = 860,
                                      A.FinalAssetClassAlt_Key = 2,
                                      A.FinalNpaDt = pos_5,
                                      A.NPA_Reason = pos_6;
         ---------  Changed on 22-05-2021   
         MERGE INTO MAIN_PRO.CUSTOMERCAL B
         USING (SELECT B.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID 
          WHERE A.Asset_Norm = 'ALWYS_NPA'
           AND B.UcifEntityID > 0) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Asset_Norm = 'ALWYS_NPA';
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Written-Off Accounts MARKING IN PRO.ACCOUNTCAL';
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE CONDI_STD IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         ---Condition Change Required  Modification Done---   
         /*  amar - changes on 12012023 - if security not availavle then consider as 0 current value */
          
            MERGE INTO MAIN_PRO.ACCOUNTCAL A
            USING (SELECT A.ROWID row_id, 'CONDI_STD'
            FROM MAIN_PRO.ACCOUNTCAL A
                   JOIN RBL_MISDB_PROD.DimProduct DP   ON A.ProductAlt_Key = dp.ProductAlt_Key
                   AND DP.ProductGroup = 'FDSEC'
                   AND DP.EffectiveFromTimeKey <= v_TimeKey
                   AND DP.EffectiveToTimeKey >= v_TimeKey
                   LEFT JOIN (
                                SELECT C.AccountEntityID ,
                                       SUM(NVL(CurrentValue, 0))  CurrentValue  
                                   FROM MAIN_PRO.ACCOUNTCAL C
                                          LEFT JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityDetail Advsec   ON Advsec.AccountEntityID = C.AccountEntityID
                                          AND Advsec.EffectiveFromTimeKey <= v_TimeKey
                                          AND Advsec.EffectiveToTimeKey >= v_TimeKey
                                          LEFT JOIN CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON Advsec.SecurityEntityID = b.SecurityEntityID
                                          AND B.SecurityEntityID = Advsec.SecurityEntityID
                                          AND B.EffectiveFromTimeKey <= v_TimeKey
                                          AND B.EffectiveToTimeKey >= v_TimeKey
                                          JOIN RBL_MISDB_PROD.DimProduct DP   ON c.ProductAlt_Key = dp.ProductAlt_Key
                                          AND DP.ProductGroup = 'FDSEC'
                                          AND DP.EffectiveFromTimeKey <= v_TimeKey
                                          AND DP.EffectiveToTimeKey >= v_TimeKey
                                          AND C.EffectiveFromTimeKey <= v_TimeKey
                                          AND C.EffectiveToTimeKey >= v_TimeKey
                                   GROUP BY C.AccountEntityID                    
                                ) E   ON A.AccountEntityID = E.AccountEntityID 
             WHERE NVL(A.Balance, 0) > 0
              AND NVL(A.Balance, 0) > NVL(E.CurrentValue, 0)) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'CONDI_STD'
            ;
         -----------------------------------------------Added by Prashant 08-03-2023 for 2nd FDOD Issue----------------------------------------------
         MERGE INTO MAIN_PRO.ACCOUNTCAL C
         USING (SELECT C.ROWID row_id, 'CONDI_STD'
         FROM MAIN_PRO.ACCOUNTCAL C
                JOIN RBL_MISDB_PROD.DimProduct DP   ON c.ProductAlt_Key = dp.ProductAlt_Key
                AND DP.ProductGroup = 'FDSEC'
                AND DP.EffectiveFromTimeKey <= v_TimeKey
                AND DP.EffectiveToTimeKey >= v_TimeKey
                AND c.InitialAssetClassAlt_Key > 1 ) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET c.Asset_Norm = 'CONDI_STD';
         --------------------------------------------------------------------------------------------------
         /*  
         ------UPDATE A SET A.Asset_Norm=(CASE WHEN A.Balance-ISNULL(e.CurrentValue,0) <=0 THEN 'ALWYS_STD'ELSE 'CONDI_STD' END)  
         UPDATE A SET A.Asset_Norm='CONDI_STD'   
            FROM PRO.AccountCal A  
            INNER JOIN (  
               SELECT C.AccountEntityID,SUM(isnull(CurrentValue,0)) CurrentValue  
                     FROM dbo.CURDAT_RBL_MISDB_PROD.AdvSecurityValueDetail B  
            INNER  JOIN dbo.AdvSecurityDetail Advsec on Advsec.SecurityEntityID=b.SecurityEntityID  
             INNER JOIN PRO.AccountCal C ON Advsec.AccountEntityID=C.AccountEntityID    
              AND Advsec.SecurityAlt_Key = Advsec.SecurityAlt_Key  
                                         AND  Advsec.EffectiveFromTimeKey < = @TimeKey  
                                                 AND Advsec.EffectiveToTimeKey   >= @TimeKey  
            --INNER JOIN RBL_MISDB_PROD.DimSecurity D ON D.EffectiveFromTimeKey<=@TIMEKEY  
            --          AND D.EffectiveToTimeKey>=@TIMEKEY  
            --          AND D.SecurityAlt_Key=Advsec.SecurityAlt_Key  
            inner join RBL_MISDB_PROD.DimProduct DP
         	on         c.ProductAlt_Key=dp.ProductAlt_Key
         	and        DP.ProductGroup='FDSEC'
         	AND  DP.EffectiveFromTimeKey < = @TimeKey  
               AND DP.EffectiveToTimeKey   >= @TimeKey  
            --WHERE  Advsec.SecurityType='P'   
            ----AND ISNULL(D.SecurityShortNameEnum,'') IN('PLD-NSC','PLD-KVP','PLD-G SEC','ASGN-LIFE POL','LI-FDR','LI-FDRSUBSI','LI-NRE DEP'  
            --                                               --    ,'LI-NRNR DEP','LI-FCNR-DEP','LI-RD-DEP','DEPNFBR')   
            --AND D.SecurityCRM='Y'  
           --  and ISNULL(C.Asset_Norm,'NORMAL')='CONDI_STD'    

            GROUP BY C.AccountEntityID  
             ) E  ON A.AccountEntityID=E.AccountEntityID  
             and  ISNULL(A.Balance,0)>0   AND ISNULL(A.Balance,0)>ISNULL(E.CurrentValue,0)  
           */
         ---Condition Change Required  Modification Done---    
         --Need to uncomment for Full ACL 
         --EXEC  PRO.ContinousExcessSecDtAccountCalLogic  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, ContinousExcessSecDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.ContinousExcessSecDtAccountCal B   ON A.CustomerAcID = B.CustomerAcID 
          WHERE B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ContiExcessDt = SRC.ContinousExcessSecDt;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CONDI_STD IN PRO.AccountCal';
         --   /*------------********UPDATE Last Credit Date******--------------------*/   
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Last Credit Date' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required Modification Done  ---   
         --Need to uncomment for Full ACL 
         --EXEC PRO.LastCreditDtAccountCalUpdate  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, B.LastCrDate
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.LastCreditDtAccountCal B   ON ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY )
                AND A.CustomerAcID = B.CustomerAcID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.LastCrDate = src.LastCrDate;
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Last Credit Date';
         /*---------UPDATE AddlProvisionAmount  AT Account level--------------------- */
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE AddlProvisionAmount  AT Account level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         ---Condition Change Required ---   
         --IF OBJECT_ID('TEMPDB..#AddlProvisionAmount') IS NOT NULL  
         --DROP TABLE #AddlProvisionAmount  
         --select AccountEntityID,CustomerAcID,AddlProvisionPer, AddlProvision,MOCTYPE  
         --into #AddlProvisionAmount  
         --from pro.accountcal_hist   A  
         --where A.EffectiveFromTimeKey<=@LastQtrDateKey and A.EffectiveToTimeKey>=@LastQtrDateKey   
         --and AddlProvision>0   
         ----and MOCTYPE='Manual'  
         --UPDATE B SET ADDLPROVISIONPER=A.ADDLPROVISIONPER,ADDLPROVISION=A.ADDLPROVISION,MOCTYPE=A.MOCTYPE  
         --FROM #ADDLPROVISIONAMOUNT A  
         --INNER JOIN PRO.ACCOUNTCAL B  
         --ON A.CUSTOMERACID=B.CUSTOMERACID  
         UPDATE MAIN_PRO.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  --IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ FROM DUAL  )
           TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE AddlProvisionAmount  AT Account level';
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_NPA',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE  
         --       FROM PRO.CUSTOMERCAL A  
         -- INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         --     INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --           DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999  
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE  
         --FROM PRO.CUSTOMERCAL A  
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         --    INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=NULL,A.DBTDT =NULL,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_STD',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE  
         -- FROM PRO.CUSTOMERCAL A  
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         --  INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME='STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999  
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=NULL,A.DBTDT =NULL,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE  
         -- FROM PRO.CUSTOMERCAL A  
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         -- INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME='STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=B.NPADATE,A.FlgMoc='Y',A.ASSET_NORM='ALWYS_NPA',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED  
         --       FROM PRO.ACCOUNTCAL A  
         -- INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         --     INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999  
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED  
         --FROM PRO.ACCOUNTCAL A  
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         --    INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=NULL,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_STD',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED  
         -- FROM PRO.ACCOUNTCAL A  
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         --  INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME='STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999  
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=NULL,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED  
         -- FROM PRO.ACCOUNTCAL A  
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID  
         -- INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND  
         --                           DA.ASSETCLASSSHORTNAME='STD' AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --UPDATE  A SET DBTDT=@PROCESSINGDATE FROM PRO.CUSTOMERCAL A    
         --INNER JOIN RBL_MISDB_PROD.DIMASSETCLASS DA       ON  DA.ASSETCLASSALT_KEY= A.SYSASSETCLASSALT_KEY AND  
         --                           DA.ASSETCLASSSHORTNAME IN ('DB1','DB2','DB3') AND    
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY  
         --WHERE DBTDT IS NULL  
         ------update a  
         ------set a.InitialNpaDt =b.FinalNpaDt  
         ------ ,A.InitialAssetClassAlt_Key =B.FinalAssetClassAlt_Key  
         ------from PRO.ACCOUNTCAL A   
         ------INNER JOIN PRO.AccountCal_Hist B  
         ------ ON A.AccountEntityID =B.AccountEntityID  
         ------WHERE B.EffectiveFromTimeKey<=26123 AND B.EffectiveToTimeKey>=26123  
         ------AND A.FinalAssetClassAlt_Key>1  
         ------AND (A.InitialAssetClassAlt_Key<>B.FinalAssetClassAlt_Key)  
         --UPDATE DATAUPLOAD.MocCustomerDailyDataUpload SET EFFECTIVETOTIMEKEY=EFFECTIVEFROMTIMEKEY WHERE MOCTYPE='AUTO'  
         /* ADDED ON 04072021 AS PER DISCUSSIONS WITH BANK ON 03072021 FOR UPGRADE some ACCOUNT AS PER LIST PROVIDED BY BANK TEAM*/
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.Manual_Upgrade B   ON A.CustomerAcID = B.Account_No 
          WHERE VALID_UPTO >= '2021-10-25'
           AND Account_No NOT IN ( SELECT Account_No 
                                   FROM RBL_MISDB_PROD.Manual_NPA  )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ASSET_NORM = 'ALWYS_STD',
                                      FINALNPADT = NULL,
                                      FINALASSETCLASSALT_KEY = 1,
                                      PrvAssetClassAlt_Key = 1,
                                      flgdeg = 'N',
                                      FlgUpg = 'N',
                                      NPA_Reason = '',
                                      DegReason = NULL;
         /* ADDED ON 04072021 AS PER DISCUSSIONS WITH BANK ON 03072021 FOR UPGRADE some ACCOUNT AS PER LIST PROVIDED BY BANK TEAM*/
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.Manual_NPA B   ON A.CustomerAcID = B.Account_No 
          WHERE VALID_UPTO >= v_ProcessingDate) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ASSET_NORM = 'ALWYS_NPA';
         /* THIS CODE IS ONLY FOR FORCEFULLY MARKED NPA FOE SEPECIFIC ACCOUNT (10 AC) AS PER BANK EAMIL DTD 28072021 */
         /*  
          UPDATE A  
          SET  A.FinalAssetClassAlt_Key=2  
           ,A.FinalNpaDt=B.NPA_dATE  
           ,A.Asset_Norm ='ALWYS_NPA'  
          --select CustomerAcID,Asset_Norm ,FinalAssetClassAlt_Key,FinalNpaDt  
          FROM [pro].accountcal A   
          INNER JOIN Manual_NPA_28072021 b   
           ON a.CustomerAcID = b.[Account No]  
           */
         ----UPDATE A SET    
         ----  ASSET_NORM='ALWYS_NPA'  
         ----  ,A.InitialAssetClassAlt_Key =ISNULL(C.FinalAssetClassAlt_Key,A.InitialAssetClassAlt_Key)  
         ----  ,A.InitialNpaDt=ISNULL(C.FinalNpaDt,A.InitialNpaDt)  
         ---- FROM PRO.ACCOUNTCAL A   
         ---- INNER JOIN Manual_NPA B  
         ---- ON A.CustomerAcID=B.[Account No]  
         ----  LEFT join pro.AccountCal_Hist  c  
         ----  on c.AccountEntityID=a.AccountEntityID  
         ----  AND (C.EFFECTIVEFROMTIMEKEY<=@HistTimeKey AND C.EFFECTIVETOTIMEKEY>=@HistTimeKey)  
         ----WHERE VALID_UPTO>=@ProcessingDate  
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, NULL
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE InitialAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET InitialNpaDt = NULL;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, NULL
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FinalNpaDt = NULL;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id, NULL
         FROM MAIN_PRO.CUSTOMERCAL A 
          WHERE SrcAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SrcNPA_Dt = NULL;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id, NULL
         FROM MAIN_PRO.CUSTOMERCAL A 
          WHERE SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysNPA_Dt = NULL;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.BuyoutUploadDetailsCal ';
         INSERT INTO MAIN_PRO.BuyoutUploadDetailsCal
           ( DateofData, ReportDate, CustomerAcID, AccountEntityID, SchemeCode, NPA_ClassSeller, NPA_DateSeller, DPD_Seller, PeakDPD, PeakDPD_Date, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey )
           ( SELECT A.DateofData ,
                    A.ReportDate ,
                    A.CustomerAcID ,
                    B.AccountEntityID ,
                    A.SchemeCode ,
                    A.NPA_ClassSeller ,
                    A.NPA_DateSeller ,
                    A.DPD_Seller ,
                    A.PeakDPD ,
                    A.PeakDPD_Date ,
                    A.AuthorisationStatus ,
                    v_TIMEKEY EffectiveFromTimeKey  ,
                    49999 EffectiveToTimeKey  
             FROM RBL_MISDB_PROD.BuyoutUploadDetails A
                    JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerAcID = B.CustomerAcID
              WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                       AND A.EffectiveToTimeKey >= v_TIMEkEY );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET OverDueSinceDt = NULL,
                                      PrincOverdueSinceDt = NULL,
                                      IntOverdueSinceDt = NULL,
                                      OtherOverdueSinceDt = NULL;
         /*
           -- UPDATE NPA COLUMNS IN CASE OF NPA MARKED 'Y' IN SELLER BOOK --  
           UPDATE  A   
            SET  FinalAssetClassAlt_Key=CASE WHEN NPA_ClassSeller='Y' AND A.FinalAssetClassAlt_Key=1 THEN 2 ELSE  A.FinalAssetClassAlt_Key END  
             ,FinalNpaDt=CASE WHEN NPA_ClassSeller='Y' AND A.FinalAssetClassAlt_Key=1 THEN ISNULL(NPA_DateSeller,B.ReportDate) ELSE  A.FinalNpaDt END  
             ,Asset_Norm=CASE WHEN NPA_ClassSeller='Y' THEN 'ALWYS_NPA' ELSE A.Asset_Norm END  
             ,NPA_Reason=CASE WHEN NPA_ClassSeller='Y' THEN 'NPA with Seller' ELSE A.NPA_Reason END  
           FROM PRO.ACCOUNTCAL A  
            INNER JOIN PRO.BuyoutUploadDetailsCal B  
            ON A.CustomerAcID=B.CustomerAcID  

           UPDATE  C   
            SET  SysAssetClassAlt_Key=CASE WHEN NPA_ClassSeller='Y' AND C.SysAssetClassAlt_Key=1 THEN 2 ELSE  C.SysAssetClassAlt_Key END  
             ,C.SysNPA_Dt=CASE WHEN NPA_ClassSeller='Y' AND C.SysAssetClassAlt_Key=1 THEN ISNULL(NPA_DateSeller,B.ReportDate) ELSE  C.SysNPA_Dt END  
             ,Asset_Norm=CASE WHEN NPA_ClassSeller='Y' THEN 'ALWYS_NPA' ELSE A.Asset_Norm END  
             ,C.DegReason=CASE WHEN NPA_ClassSeller='Y' THEN 'NPA with Seller' ELSE C.DegReason END  
           FROM PRO.ACCOUNTCAL A  
            INNER JOIN PRO.BuyoutUploadDetailsCal B  
            ON A.CustomerAcID=B.CustomerAcID  
            inner join pro.CUSTOMERCAL C  
            ON A.CustomerEntityID=C.CustomerEntityID  
           */
         /* UPDATE FLAG NPA_EffectedToMainAdv FROMHIST TABLE PREV. DAYE */
         -- UPDATE  A  
         -- SET A.NPA_EffectedToMainAdv=C.NPA_EffectedToMainAdv  
         --  ,A.NPA_Flag=c.NPA_Flag  
         --FROM  PRO.BuyoutUploadDetailsCal A  
         --  INNER JOIN PRO.BuyoutUploadDetailsCal_Hist C  
         --  ON A.AccountEntityID=C.AccountEntityID  
         --  AND C.EffectiveFromTimeKey<=@TIMEKEY-1 AND C.EffectiveToTimeKey>=@TIMEkEY-1  
         /* UPDATE OVERDUE SINCE DATE FROM DPD WITH SELLER AND DATE DOFF OF REPORT AND PROCESSDATE */
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, utils.dateadd('DD', -(NVL(B.DPD_Seller, 0) - 1), ReportDate) AS OverDueSinceDt
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID 
          WHERE NVL(B.DPD_Seller, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.OverDueSinceDt
                                      ---------,A.DPD_PrincOverdue  =DATEADD(DD,- (ISNULL(B.DPD_Seller,0)+DATEDIFF(DD,ReportDate,@ProcessingDate)),@ProcessingDate)  
                                       = src.OverDueSinceDt;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.AdvAcRestructureCal ';
         ------------------------Insert Data for Base Columns   
         INSERT INTO MAIN_PRO.AdvAcRestructureCal
           ( AccountEntityId, AssetClassAlt_KeyOnInvocation, PreRestructureAssetClassAlt_Key, PreRestructureNPA_Date, ProvPerOnRestrucure, RestructureTypeAlt_Key, COVID_OTR_CatgAlt_Key, RestructureDt, SP_ExpiryDate, RestructurePOS, DPD_AsOnRestructure, RestructureFailureDate, DPD_Breach_Date, ZeroDPD_Date, SP_ExpiryExtendedDate, Res_POS_to_CurrentPOS_Per, CurrentDPD, TotalDPD, VDPD, AddlProvPer, ProvReleasePer, UpgradeDate, SurvPeriodEndDate, PreDegProvPer, NonFinDPD, InitialAssetClassAlt_Key, FinalAssetClassAlt_Key, RestructureProvision, SecuredProvision, UnSecuredProvision, FlgDeg, FlgUpg, DegDate, RestructureStage, EffectiveFromTimeKey, EffectiveToTimeKey, InvestmentGrade, POS_10PerPaidDate, FlgMorat, PreRestructureNPA_Prov, RestructureFacilityTypeAlt_Key )
           ( SELECT A.AccountEntityId ,
                    AssetClassAlt_KeyOnInvocation ,
                    PreRestructureAssetClassAlt_Key ,
                    PreRestructureNPA_Date ,
                    ProvPerOnRestrucure ,
                    RestructureTypeAlt_Key ,
                    COVID_OTR_CatgAlt_Key ,
                    RestructureDt ,
                    utils.dateadd('YY', 1, (CASE 
                                                 WHEN NVL(PrincRepayStartDate, '1900-01-01') >= NVL(InttRepayStartDate, '1900-01-01') THEN PrincRepayStartDate
                                  ELSE InttRepayStartDate
                                     END)) SP_ExpiryDate  ,
                    CASE 
                         WHEN NVL(RestructurePOS, 0) <= 0 THEN 0
                    ELSE NVL(RestructurePOS, 0)
                       END RestructurePOS  ,
                    DPD_AsOnRestructure ,
                    NULL RestructureFailureDate  ,
                    DPD_Breach_Date ,
                    ZeroDPD_Date ,
                    NULL SP_ExpiryExtendedDate  ,
                    0 Res_POS_to_CurrentPOS_Per  ,
                    0 CurrentDPD  ,
                    0 TotalDPD  ,
                    0 VDPD  ,
                    0 AddlProvPer  ,
                    0 ProvReleasePer  ,
                    UpgradeDate ,
                    SurvPeriodEndDate ,
                    PreDegProvPer ,
                    0 NonFinDPD  ,
                    1 InitialAssetClassAlt_Key  ,
                    1 FinalAssetClassAlt_Key  ,
                    0 RestructureProvision  ,
                    0 SecuredProvision  ,
                    0 UnSecuredProvision  ,
                    'N' FlgDeg  ,
                    'N' FlgUpg  ,
                    NULL DegDate  ,
                    RestructureStage ,
                    v_Timekey EffectiveFromTimeKey  ,
                    v_Timekey EffectiveToTimeKey  ,
                    InvestmentGrade ,
                    POS_10PerPaidDate ,
                    FlgMorat ,
                    PreRestructureNPA_Prov ,
                    RestructureFacilityTypeAlt_Key 
             FROM RBL_MISDB_PROD.AdvAcRestructureDetail A
                    JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
              WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_Timekey );
         ----------------Update Total OS, Total POS,CrntQtrAssetClass----------------  
         --Select *   
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN NVL(PrincOutStd, 0) <= 0 THEN 0
         ELSE NVL(PrincOutStd, 0)
            END AS pos_2, Balance
         --,A.FinalAssetClassAlt_Key=b.FinalAssetClassAlt_Key  
          --,A.InitialAssetClassAlt_Key=B.InitialAssetClassAlt_Key  
         , CASE 
         WHEN B.FinalAssetClassAlt_Key = 1 THEN SP.ProvisionSecured
         ELSE B.FinalProvisionPer
            END AS pos_4, CASE 
         WHEN A.UpgradeDate IS NOT NULL THEN utils.dateadd('YY', 1, A.UpgradeDate)
         ELSE NULL
            END AS pos_5, B.DPD_Max
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                LEFT JOIN RBL_MISDB_PROD.DimProvision_SegStd SP   ON SP.EffectiveFromTimeKey <= v_TimeKey
                AND SP.EffectiveFromTimeKey >= v_TimeKey
                AND SP.ProvisionAlt_Key = B.ProvisionAlt_Key
                LEFT JOIN RBL_MISDB_PROD.DimProvision_Seg NP   ON NP.EffectiveFromTimeKey <= v_TimeKey
                AND NP.EffectiveFromTimeKey >= v_TimeKey
                AND NP.ProvisionAlt_Key = B.ProvisionAlt_Key 
          WHERE A.EffectiveFromTimeKey <= v_TimeKey
           AND A.EffectiveToTimeKey >= v_TimeKey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurrentPOS = pos_2,
                                      A.CurrentTOS = Balance,
                                      A.AppliedNormalProvPer
                                      --,A.FinalNpaDt=b.FinalNpaDt  
                                       --,A.UpgradeDate=b.UpgDate  
                                       = pos_4,
                                      A.SurvPeriodEndDate = pos_5,
                                      A.CurrentDPD = src.DPD_Max;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN (NVL(RestructurePOS, 0)) > 0 THEN CASE 
                                                     WHEN ((NVL(RestructurePOS, 0) - NVL(A.CurrentPOS, 0.00)) * 100) / (NVL(RestructurePOS, 0)) > 100
                                                       OR ((NVL(RestructurePOS, 0) - NVL(A.CurrentPOS, 0.00)) * 100) / (NVL(RestructurePOS, 0)) < 0 THEN 0
         ELSE UTILS.CONVERT_TO_NUMBER(utils.round_(((NVL(RestructurePOS, 0) - NVL(A.CurrentPOS, 0.00)) * 100) / (NVL(RestructurePOS, 0)), 2),5,2)
            END
         ELSE 0
            END AS Res_POS_to_CurrentPOS_Per
         FROM MAIN_PRO.AdvAcRestructureCal A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Res_POS_to_CurrentPOS_Per -----CAST( (CAST((cast((ISNULL(a.RestructurePOS,0.00)-ISNULL(B.PrincOutStd,0.00)) as decimal(22,2))  /ISNULL(A.RestructurePOS,1)) AS DECIMAL(20,2)))*100 AS DECIMAL(5,2))  
                                       = src.Res_POS_to_CurrentPOS_Per;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A 
         USING (SELECT A.ROWID row_id, utils.dateadd('YY', 1, RestructureDt) AS SP_ExpiryDate
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE SP_ExpiryDate IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryDate = src.SP_ExpiryDate;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT a.ROWID row_id, CASE 
         WHEN NVL(Res_POS_to_CurrentPOS_Per, 0) < 0 THEN 0
         ELSE Res_POS_to_CurrentPOS_Per
            END AS Res_POS_to_CurrentPOS_Per
         FROM MAIN_PRO.AdvAcRestructureCal A ) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Res_POS_to_CurrentPOS_Per = src.Res_POS_to_CurrentPOS_Per;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A  
         USING (SELECT a.ROWID row_id, v_ProcessingDate
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE POS_10PerPaidDate IS NULL
           AND NVL(Res_POS_to_CurrentPOS_Per, 0) >= 10) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.POS_10PerPaidDate = v_ProcessingDate;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT a.ROWID row_id, CASE 
         WHEN A.POS_10PerPaidDate > SP_ExpiryDate THEN A.POS_10PerPaidDate
         ELSE SP_ExpiryDate
            END AS SP_ExpiryDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN CURDAT_RBL_MISDB_PROD.ADVACRESTRUCTUREDETAIL b   ON a.AccountEntityId = b.AccountEntityId
                AND ( b.EffectiveFromTimeKey <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY )
                JOIN RBL_MISDB_PROD.dimparameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = B.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum = 'PRUDENTIAL' 
          WHERE A.POS_10PerPaidDate IS NOT NULL) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryDate = src.SP_ExpiryDate;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A 
         USING (SELECT A.ROWID row_id, utils.dateadd('YY', 1, ZeroDPD_Date) AS SP_ExpiryExtendedDate
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE ZeroDPD_Date IS NOT NULL
           AND SP_ExpiryExtendedDate IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate;
         ----Email Date 16-06-2022 ---For restructure we need some change to be done in pre-existing logic. This will be discuss separately by Ashish/Anirudha.
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A
         USING (SELECT A.ROWID row_id, utils.dateadd('YY', 1, DPD_Breach_Date) AS SP_ExpiryExtendedDate
         FROM MAIN_PRO.AdvAcRestructureCal A
                JOIN RBL_MISDB_PROD.dimparameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = A.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE DPD_Breach_Date IS NOT NULL
           AND ZeroDPD_Date IS NULL
           AND SP_ExpiryExtendedDate IS NULL
           AND D.ParameterShortNameEnum IN ( 'MSME_OLD','MSME_COVID','MSME_COVID_RF2' )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate;
         MERGE INTO MAIN_PRO.AdvAcRestructureCal A 
         USING (SELECT A.ROWID row_id, NULL
         FROM MAIN_PRO.AdvAcRestructureCal A 
          WHERE SP_ExpiryDate > SP_ExpiryExtendedDate) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryExtendedDate = NULL;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.AdvAcRestructureCal B   ON A.AccountEntityID = B.AccountEntityId
                JOIN RBL_MISDB_PROD.dimparameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = B.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE D.ParameterShortNameEnum = 'PRUDENTIAL') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ASSET_NORM = 'ALWYS_NPA';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.PUI_CAL ';
         INSERT INTO MAIN_PRO.PUI_CAL
           ( CustomerEntityID, AccountEntityId, ProjectCategoryAlt_Key, ProjectSubCategoryAlt_key, DelayReasonChangeinOwnership, ProjectAuthorityAlt_key, OriginalDCCO, OriginalProjectCost, OriginalDebt, Debt_EquityRatio, ChangeinProjectScope, FreshOriginalDCCO, RevisedDCCO, CourtCaseArbitration, CIOReferenceDate, CIODCCO, TakeOutFinance, AssetClassSellerBookAlt_key, NPADateSellerBook, Restructuring, InitialExtension, BeyonControlofPromoters, DelayReasonOther, FLG_UPG, FLG_DEG, DEFAULT_REASON, ProjCategory, NPA_DATE, PUI_ProvPer, RestructureDate, ActualDCCO, ActualDCCO_Date, UpgradeDate, FinalAssetClassAlt_Key, DPD_Max, EffectiveFromTimeKey, EffectiveToTimeKey, RevisedDebt, CostOverrun, CostOverRunPer, RevisedProjectCost, ProjectOwnerShipAlt_Key )
           ( SELECT A.CustomerEntityID ,
                    B.AccountEntityId ,
                    B.ProjectCategoryAlt_Key ,
                    B.ProjectSubCategoryAlt_key ,
                    c.ChangeinOwnerShip ,
                    B.ProjectAuthorityAlt_key ,
                    B.OriginalDCCO ,
                    B.OriginalProjectCost ,
                    B.OriginalDebt ,
                    B.Debt_EquityRatio ,
                    C.ChangeinProjectScope ,
                    C.FreshOriginalDCCO ,
                    C.RevisedDCCO ,
                    C.CourtCaseArbitration ,
                    C.CIOReferenceDate ,
                    C.CIODCCO ,
                    --,C.CostOverRun,C.RevisedProjectCost,C.RevisedDebt,C.RevisedDebt_EquityRatio,C.AuthorisationStatus  
                    C.TakeOutFinance ,
                    C.AssetClassSellerBookAlt_key ,
                    C.NPADateSellerBook ,
                    C.Restructuring ,
                    --,((C.RevisedProjectCost-B.OriginalProjectCost)*100)/B.OriginalProjectCost OverRunPer   
                    InitialExtenstion ,-- InitialExtension  

                    ExtnReason_BCP ,-- BeyonControlofPromoters  

                    ---,'Y' ChangeInManagement  
                    NULL DelayReasonOther  ,
                    'N' FLG_UPG  ,
                    'N' FLG_DEG  ,
                    UTILS.CONVERT_TO_VARCHAR2(' ',50) DEFAULT_REASON  ,
                    D.ParameterShortNameEnum ProjCategory  ,
                    UTILS.CONVERT_TO_VARCHAR2('',200) NPA_DATE  ,
                    0.00 PUI_ProvPer  ,
                    UTILS.CONVERT_TO_VARCHAR2('',200) RestructureDate  ,
                    ActualDCCO_Achieved ,-- ActualDCCO  

                    ActualDCCO_Date ,
                    UTILS.CONVERT_TO_VARCHAR2('',200) UpgradeDate  ,
                    A.FinalAssetClassAlt_Key ,
                    A.DPD_Max ,
                    v_TimeKey EffectiveFromTimeKey  ,
                    v_TimeKey EffectiveToTimeKey  ,
                    RevisedDebt ,
                    CostOverrun ,
                    UTILS.CONVERT_TO_NUMBER((UTILS.CONVERT_TO_NUMBER((UTILS.CONVERT_TO_NUMBER((NVL(c.RevisedProjectCost, 0.00) - NVL(B.OriginalProjectCost, 0.00)),22,2) / NVL(B.OriginalProjectCost, 1)),20,2)) * 100,5,2) CostOverRunPer  ,
                    RevisedProjectCost ,
                    ProjectOwnerShipAlt_Key 
             FROM MAIN_PRO.ACCOUNTCAL A
                    JOIN RBL_MISDB_PROD.AdvAcPUIDetailMain B   ON A.AccountEntityID = B.AccountEntityId
                    AND ( b.EffectiveFromTimeKey <= v_TimeKey
                    AND b.EffectiveToTimeKey >= v_TimeKey )
                    JOIN RBL_MISDB_PROD.AdvAcPUIDetailSub c   ON A.AccountEntityID = c.AccountEntityID
                    AND ( c.EffectiveFromTimeKey <= v_TimeKey
                    AND c.EffectiveToTimeKey >= v_TimeKey )
                    JOIN RBL_MISDB_PROD.dimparameter D   ON ParameterAlt_Key = b.ProjectCategoryAlt_Key
                    AND ( D.EffectiveFromTimeKey <= v_TimeKey
                    AND D.EffectiveToTimeKey >= v_TimeKey )
                    AND DimParameterName = 'ProjectCategory' );
         UPDATE MAIN_PRO.PUI_CAL
            SET CostOverRunPer = 0
          WHERE  CostOverRunPer < 0;
         UPDATE MAIN_PRO.PUI_CAL
            SET FinnalDCCO_Date = CASE 
                                       WHEN NVL(OriginalDCCO, '1900-01-01') > NVL(CIODCCO, '1900-01-01')
                                         AND NVL(OriginalDCCO, '1900-01-01') > NVL(FreshOriginalDCCO, '1900-01-01') THEN OriginalDCCO
                                       WHEN NVL(CIODCCO, '1900-01-01') > NVL(OriginalDCCO, '1900-01-01')
                                         AND NVL(CIODCCO, '1900-01-01') > NVL(FreshOriginalDCCO, '1900-01-01') THEN CIODCCO
                                       WHEN NVL(FreshOriginalDCCO, '1900-01-01') > NVL(CIODCCO, '1900-01-01')
                                         AND NVL(FreshOriginalDCCO, '1900-01-01') > NVL(OriginalDCCO, '1900-01-01') THEN FreshOriginalDCCO
                ELSE '1900-01-01'
                   END;
         /* END OF PUI WORK*/
         ---case when NPA_DateSeller>=FinalNpaDt then FinalNpaDt else NPA_DateSeller end
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN NPA_DateSeller IS NOT NULL
           AND A.FinalAssetClassAlt_Key = 1 THEN 2
         ELSE A.FinalAssetClassAlt_Key
            END AS pos_2, CASE 
         WHEN NPA_DateSeller IS NOT NULL
           AND A.FinalAssetClassAlt_Key = 1 THEN NVL(NPA_DateSeller, b.DateofData)
         ELSE (CASE 
         WHEN NPA_DateSeller IS NOT NULL
           AND NVL(NPA_DateSeller, B.DateofData) < FinalNpaDt THEN NPA_DateSeller
         ELSE FinalNpaDt
            END)
            END AS pos_3, CASE 
         WHEN NPA_DateSeller IS NOT NULL THEN 'ALWYS_NPA'
         ELSE A.Asset_Norm
            END AS pos_4, CASE 
         WHEN NPA_DateSeller IS NOT NULL THEN 'NPA with Seller'
         ELSE TO_CHAR(A.NPA_Reason)
            END AS pos_5
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FinalAssetClassAlt_Key = pos_2,
                                      FinalNpaDt = pos_3,
                                      Asset_Norm = pos_4,
                                      NPA_Reason = pos_5;
         MERGE INTO MAIN_PRO.CUSTOMERCAL C
         USING (SELECT C.ROWID row_id, CASE 
         WHEN NPA_DateSeller IS NOT NULL
           AND C.SysAssetClassAlt_Key = 1 THEN 2
         ELSE C.SysAssetClassAlt_Key
            END AS pos_2, CASE 
         WHEN NPA_DateSeller IS NOT NULL
           AND C.SysAssetClassAlt_Key = 1 THEN NVL(NPA_DateSeller, b.DateofData)
         ELSE (CASE 
         WHEN NPA_DateSeller IS NOT NULL
           AND NVL(NPA_DateSeller, B.DateofData) < SysNPA_Dt THEN NPA_DateSeller
         ELSE SysNPA_Dt
            END)
            END AS pos_3, CASE 
         WHEN NPA_DateSeller IS NOT NULL THEN 'ALWYS_NPA'
         ELSE A.Asset_Norm
            END AS pos_4, CASE 
         WHEN NPA_DateSeller IS NOT NULL THEN 'NPA with Seller'
         ELSE C.DegReason
            END AS pos_5
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN MAIN_PRO.BuyoutUploadDetailsCal B   ON A.CustomerAcID = B.CustomerAcID
                JOIN MAIN_PRO.CUSTOMERCAL C   ON A.CustomerEntityID = C.CustomerEntityID ) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET SysAssetClassAlt_Key = pos_2,
                                      C.SysNPA_Dt = pos_3,
                                      Asset_Norm = pos_4,
                                      C.DegReason = pos_5;
         /*  UPDATE MOC AND ADHOC CHANGES */
         INSERT INTO MAIN_PRO.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'MOC UPDATES AUTO AND MANUAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         /* ADHOC CHANGE WORK */
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, B.NPA_Date, 'ALWYS_NPA', B.Reason, 'NPA DUE TO Adhoc' AS pos_6, B.DATECREATED
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.CustomerEntityID = B.CustomerEntityId
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME <> 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.ASSETCLASSALT_KEY,
                                      A.SYSNPA_DT = src.NPA_Date,
                                      A.ASSET_NORM = 'ALWYS_NPA',
                                      A.MOCREASON = src.Reason,
                                      A.DEGREASON = pos_6,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, B.NPA_Date, 'ALWYS_NPA', B.Reason, 'NPA DUE TO Adhoc' AS pos_6, B.DATECREATED
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.UcifEntityID = B.UcifEntityID
                AND NVL(A.UcifEntityID, 0) <> 0
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME <> 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.ASSETCLASSALT_KEY,
                                      A.SYSNPA_DT = src.NPA_Date,
                                      A.ASSET_NORM = 'ALWYS_NPA',
                                      A.MOCREASON = src.Reason,
                                      A.DEGREASON = pos_6,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, NULL SYSNPA_DT, NULL DBTDT, 'ALWYS_STD' ASSET_NORM
                    , B.REASON, 'STD DUE TO Adhoc' AS pos_7, B.DATECREATED
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.CustomerEntityID = B.CustomerEntityId
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME = 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.ASSETCLASSALT_KEY,
                                      A.SYSNPA_DT = NULL,
                                      A.DBTDT = NULL,
                                      A.ASSET_NORM = 'ALWYS_STD',
                                      A.MOCREASON = src.REASON,
                                      A.DEGREASON = pos_7,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY,B.REASON, 'STD DUE TO Adhoc' AS pos_7, B.DATECREATED
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.UcifEntityID = B.UcifEntityID
                AND NVL(A.UcifEntityID, 0) <> 0
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME = 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.ASSETCLASSALT_KEY,
                                      A.SYSNPA_DT = NULL,
                                      A.DBTDT = NULL,
                                      A.ASSET_NORM = 'ALWYS_STD',
                                      A.MOCREASON = src.REASON,
                                      A.DEGREASON = pos_7,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, B.NPA_Date, 'ALWYS_NPA', B.REASON, 'NPA DUE TO Adhoc' AS pos_6, B.DATECREATED
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.CustomerEntityID = B.CustomerEntityId
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME <> 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.ASSETCLASSALT_KEY,
                                      A.FinalNpaDt = src.NPA_Date,
                                      A.ASSET_NORM = 'ALWYS_NPA',
                                      A.MOCREASON = src.REASON,
                                      A.DEGREASON = pos_6,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, B.NPA_Date, 'ALWYS_NPA', B.REASON, 'NPA DUE TO Adhoc' AS pos_6, B.DATECREATED
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.UcifEntityID = B.UcifEntityID
                AND NVL(A.UcifEntityID, 0) <> 0
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME <> 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.ASSETCLASSALT_KEY,
                                      A.FinalNpaDt = src.NPA_Date,
                                      A.ASSET_NORM = 'ALWYS_NPA',
                                      A.MOCREASON = src.REASON,
                                      A.DEGREASON = pos_6,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, NULL, 'ALWYS_STD', B.REASON, 'STD DUE TO Adhoc' AS pos_6, B.DATECREATED
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.CustomerEntityID = B.CustomerEntityId
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME = 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.ASSETCLASSALT_KEY,
                                      A.FinalNpaDt = NULL,
                                      A.ASSET_NORM = 'ALWYS_STD',
                                      A.MOCREASON = src.REASON,
                                      A.DEGREASON = pos_6,
                                      A.MOC_DT = src.DATECREATED;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, DA.ASSETCLASSALT_KEY, NULL, 'ALWYS_STD', B.REASON, 'STD DUE TO Adhoc' AS pos_6, B.DATECREATED
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdhocACL_ChangeDetails B   ON A.UcifEntityID = B.UcifEntityID
                AND NVL(A.UcifEntityID, 0) <> 0
                JOIN RBL_MISDB_PROD.DIMASSETCLASS DA   ON DA.AssetClassAlt_Key = B.AssetClassAlt_Key
                AND DA.ASSETCLASSSHORTNAME = 'STD'
                AND DA.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                AND DA.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
          WHERE B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.ASSETCLASSALT_KEY,
                                      A.FinalNpaDt = NULL,
                                      A.ASSET_NORM = 'ALWYS_STD',
                                      A.MOCREASON = src.REASON,
                                      A.DEGREASON = pos_6,
                                      A.MOC_DT = src.DATECREATED;
         UPDATE RBL_MISDB_PROD.AdhocACL_ChangeDetails
            SET EFFECTIVETOTIMEKEY = v_TIMEKEY
          WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND EFFECTIVETOTIMEKEY >= v_TIMEKEY;
         MERGE INTO RBL_MISDB_PROD.MOC_ChangeDetails A 
         USING (SELECT A.ROWID row_id, v_TIMEKEY
         FROM RBL_MISDB_PROD.MOC_ChangeDetails A 
          WHERE A.EffectiveFromTimeKey <= v_TIMEKEY
           AND a.EffectiveToTimeKey >= v_TIMEKEY
           AND A.MOCTYPE = 'AUTO') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.EffectiveToTimeKey = v_TIMEKEY;
         
         
         DELETE FROM GTT_MOC_DATA;
         UTILS.IDENTITY_RESET('GTT_MOC_DATA');

         INSERT INTO GTT_MOC_DATA ( 
         	SELECT UcifEntityID ,
                 MAX(AssetClassAlt_Key)  SysAssetClassAlt_Key  ,
                 MIN(Npa_date)  SysNPA_Dt  ,
                 'Manual' MOCTYPE  ,
                 A.EffectiveFromTimeKey 
         	  FROM RBL_MISDB_PROD.MOC_ChangeDetails A
                   JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = b.CustomerEntityID
         	 WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                    AND a.EffectiveToTimeKey >= v_TIMEKEY
                    AND ( MOC_ExpireDate >= v_ProcessingDate )

                    -- AND A.EffectiveFromTimeKey >= @PrevQtrTimeKey  -------------- Commented by Sudesh 17032023 ------ MOC Manual Carry forward issue fix--------
                    AND MOCType_Flag = 'CUST'

                    ----AND ISNULL(AssetClassAlt_Key,0)>0  
                    AND a.MOCTYPE = 'Manual'
         	  GROUP BY UcifEntityID,A.EffectiveFromTimeKey );
         INSERT INTO GTT_MOC_DATA
           ( SELECT UcifEntityID ,
                    MAX(AssetClassAlt_Key)  SysAssetClassAlt_Key  ,
                    MIN(Npa_date)  SysNPA_Dt  ,
                    'Auto' MOCTYPE  ,
                    A.EffectiveFromTimeKey 
             FROM RBL_MISDB_PROD.MOC_ChangeDetails A
                    JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = b.CustomerEntityID
              WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                       AND a.EffectiveToTimeKey >= v_TIMEKEY
                       AND MOCType_Flag = 'CUST'

                       ----AND ISNULL(AssetClassAlt_Key,0)>0  
                       AND a.MOCTYPE = 'Auto'
                       AND b.UcifEntityID NOT IN ( SELECT UcifEntityID 
                                                   FROM GTT_MOC_DATA  )

               GROUP BY UcifEntityID,A.EffectiveFromTimeKey );
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.SysAssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE 'ALWYS_NPA'
            END AS pos_2, b.MOCTYPE
         -- ,SysAssetClassAlt_Key=isnull(B.SysAssetClassAlt_Key,a.SysAssetClassAlt_Key)  
          -- ,SysNPA_Dt=case when  b.SysNPA_Dt <a.SysNPA_Dt then b.SysNPA_Dt else  isnull(A.SysNPA_Dt,B.SysNPA_Dt)  end ---email Dated 16-06-2022--For some cases there is change in NPA date from 31 March 2022 QTR v/s 31 May 2022 output
          -- Change date 01/03/2023 - referance mail from sunita maity mail date -  06/02/2023 05.55PM
         , NVL(B.SysNPA_Dt, A.SysNPA_Dt) AS pos_4
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN GTT_MOC_DATA B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = pos_2,
                                      A.MOCTYPE = src.MOCTYPE,
                                      A.SysNPA_Dt = pos_4;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.SysAssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE 'ALWYS_NPA'
            END AS pos_2, b.MOCTYPE
         -- ,FinalAssetClassAlt_Key=isnull(B.SysAssetClassAlt_Key,a.FinalAssetClassAlt_Key)  
          --,FinalNpaDt=case when  b.SysNPA_Dt <a.FinalNpaDt then b.SysNPA_Dt else isnull(a.FinalNpaDt,b.SysNPA_Dt) end ---email Dated 16-06-2022--For some cases there is change in NPA date from 31 March 2022 QTR v/s 31 May 2022 output
         , b.SysNPA_Dt --AddedBy mandeep/Sudesh (Mail Date-(18-02-2023) Subject-#Prod Issue: Moc Issue)

         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_MOC_DATA B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = pos_2,
                                      MOCTYPE = src.MOCTYPE,
                                      FinalNpaDt = src.SysNPA_Dt;
         ----------------------------ADDED BY PRASHANT AS PER SUNITA---- DATED MAIL 22-09-2022 ------------------------------------------------------------------------
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.SysAssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE 'ALWYS_NPA'
            END AS pos_2, CASE 
         WHEN b.effectivefromtimekey >= v_PrevQtrTimeKey THEN NVL(B.SysAssetClassAlt_Key, a.SysAssetClassAlt_Key)
         ELSE NVL(a.SysAssetClassAlt_Key, b.SysAssetClassAlt_Key)
            END AS pos_3
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN GTT_MOC_DATA B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm
                                      -- ,MOCTYPE=b.MOCTYPE  
                                       = pos_2,
                                      A.SysAssetClassAlt_Key
                                      -- ,SysNPA_Dt=case when  b.SysNPA_Dt <a.SysNPA_Dt then b.SysNPA_Dt else  isnull(A.SysNPA_Dt,B.SysNPA_Dt)  end ---email Dated 16-06-2022--For some cases there is change in NPA date from 31 March 2022 QTR v/s 31 May 2022 output
                                       = pos_3;
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.SysAssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE 'ALWYS_NPA'
            END AS pos_2, CASE 
         WHEN b.effectivefromtimekey >= v_PrevQtrTimeKey THEN NVL(B.SysAssetClassAlt_Key, a.FinalAssetClassAlt_Key)
         ELSE NVL(a.FinalAssetClassAlt_Key, b.SysAssetClassAlt_Key)
            END AS pos_3
         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_MOC_DATA B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm
                                      --,MOCTYPE=b.MOCTYPE  
                                       = pos_2,
                                      FinalAssetClassAlt_Key
                                      --isnull(B.SysAssetClassAlt_Key,a.FinalAssetClassAlt_Key)  
                                       = pos_3;
         -------------------------------------------------------------------------------------------------------
         /*ADDED BY AMAR ON 21-06-2022 REMOVE FLAG ALWYS_STD AND ALWYS_NPA FOR BUYOUT ACCOUNT AS PER EMAIL DATED 20-06-2022 AT 3:39PM BY ASHISH SIR  AND ALSO CONFIRMATION BY SITARAM SIR EMAIL DATED 20-06-2022 AT 4:30*/
         --commented by mandeep with approval of jaydev sir (logic removed for buyout moc carry forward--20/03/2023)
         /*	  UPDATE A
         		SET  A.Asset_Norm='NORMAL'
         			,A.FinalAssetClassAlt_Key =A.InitialAssetClassAlt_Key
         			,A.FinalNpaDt =A.InitialNpaDt
         	  FROM PRO.ACCOUNTCAL A  
         	  INNER JOIN PRO.BuyoutUploadDetailsCal B  
         			ON A.AccountEntityID=B.AccountEntityID
         		WHERE isnull(A.Asset_Norm,'')<>'NORMAL'


         				  UPDATE C
         		SET  c.Asset_Norm='NORMAL'
         			,c.SysAssetClassAlt_Key =c.SrcAssetClassAlt_Key
         			,c.SysNPA_Dt =c.SrcNPA_Dt
         	  FROM pro.customercal c
         	  inner join PRO.ACCOUNTCAL A  
         	  on         a.CustomerEntityID=c.CustomerEntityID
         	  INNER JOIN PRO.BuyoutUploadDetailsCal B  
         			ON A.AccountEntityID=B.AccountEntityID
         		WHERE isnull(C.Asset_Norm,'')<>'NORMAL' */
         /*END OF BUYOUT CHANGES */
         /* UPDATE NPA COLUMNS IN CASE OF NPA MARKED 'Y' IN SELLER BOOK */
         /*END OF BUYOUT CHANGES */
         --------------------------Added by Prashant under guidence of Amar sir and Ashish Sir--------29-10-2022-------------------------------
         --IF OBJECT_ID('TEMPDB..GTT_UPDATETEMPASSETCLASSASSETNORM') IS NOT NULL  
         -- DROP TABLE  GTT_UPDATETEMPASSETCLASSASSETNORM  
         --select a.CustomerEntityID, count(a.CustomerAcID) CNT
         --into          GTT_UPDATETEMPASSETCLASSASSETNORM
         --from		  pro.accountcal a
         --inner join    pro.CUSTOMERCAL b
         --on            a.CustomerEntityID=b.CustomerEntityID
         --group by      a.CustomerEntityID
         --having    count(a.CustomerAcID)=1
         --UPDATE         A
         --SET			   A.SysAssetClassAlt_Key=B.FinalAssetClassAlt_Key,A.SysNPA_Dt=B.FinalNpaDt ,a.Asset_Norm=b.Asset_Norm
         --from           pro.CUSTOMERCAL A
         --INNER JOIN	   pro.ACCOUNTCAL  B
         --ON             A.CustomerEntityID=B.CustomerEntityID
         --INNER JOIN     GTT_UPDATETEMPASSETCLASSASSETNORM C
         --ON             A.CustomerEntityID=C.CustomerEntityID
         --where          a.SysAssetClassAlt_Key<>b.FinalAssetClassAlt_Key
         ---------------------------------------------------END-------------------------------------------------------------------------------
         ------------------------Added by Prashant under guidence of Amar sir and Ashish Sir--------29102022-------------------------------
         IF utils.object_id('TEMPDB..GTT_UPDATETEMPASSETCLASSASSETNORM') IS NOT NULL THEN
          -------------------------------------------------END-------------------------------------------------------------------------------
         --------------------------COBORROWER WORK ADDED BY MANDEEP -------------------------------------------------------------------------
         EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_UPDATETEMPASSETCLASSASSETNORM ';
         END IF;
         DELETE FROM GTT_UPDATETEMPASSETCLASSASSETNORM;
         UTILS.IDENTITY_RESET('GTT_UPDATETEMPASSETCLASSASSETNORM');

         INSERT INTO GTT_UPDATETEMPASSETCLASSASSETNORM ( 
         	SELECT a.CustomerEntityID ,
                 COUNT(a.CustomerAcID)  CNT  
         	  FROM MAIN_PRO.ACCOUNTCAL a
                   JOIN MAIN_PRO.CUSTOMERCAL b   ON a.CustomerEntityID = b.CustomerEntityID
         	  GROUP BY a.CustomerEntityID

         	   HAVING COUNT(a.CustomerAcID)  = 1 );
         MERGE INTO MAIN_PRO.ACCOUNTCAL A
         USING (SELECT A.ROWID row_id, 1, NULL
         --SELECT *

         FROM MAIN_PRO.ACCOUNTCAL A
                JOIN GTT_UPDATETEMPASSETCLASSASSETNORM C   ON A.CustomerEntityID = C.CustomerEntityID 
          WHERE A.Asset_Norm = 'ALWYS_STD'
           AND a.ProductCode IN ( SELECT ProductCode 
                                  FROM RBL_MISDB_PROD.DimProduct 
                                   WHERE  ProductGroup = 'FDSEC'
                                            AND EffectiveToTimeKey = 49999 )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = 1,
                                      A.FinalNpaDt = NULL;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A
         USING (SELECT A.ROWID row_id, B.FinalAssetClassAlt_Key, B.FinalNpaDt, b.Asset_Norm
         FROM MAIN_PRO.CUSTOMERCAL A
                JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
                JOIN GTT_UPDATETEMPASSETCLASSASSETNORM C   ON A.CustomerEntityID = C.CustomerEntityID 
          WHERE a.SysAssetClassAlt_Key <> b.FinalAssetClassAlt_Key) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      A.SysNPA_Dt = src.FinalNpaDt,
                                      a.Asset_Norm = src.Asset_Norm;
         -------------------------------------------------END-------------------------------------------------------------------------------
         ----Added By Mandeep 10-07-2023 to remove NPA reason of STD account---------------------
         MERGE INTO MAIN_PRO.ACCOUNTCAL A 
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.ACCOUNTCAL A 
          WHERE A.FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalNpaDt = NULL,
                                      A.NPA_Reason = NULL;
         MERGE INTO MAIN_PRO.CUSTOMERCAL A 
         USING (SELECT A.ROWID row_id
         FROM MAIN_PRO.CUSTOMERCAL A 
          WHERE A.SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysNPA_Dt = NULL,
                                      A.DegReason = NULL;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE MAIN_PRO.CoBorrowerCal ';
         INSERT INTO MAIN_PRO.CoBorrowerCal
           ( CustomerACID, CustomerID, UCIC, CustomerType, Cohort_No, TIMEKEY )
           ( SELECT CustomerACID ,
                    CustomerID ,
                    UCIC ,
                    CustomerType ,
                    Cohort_No ,
                    TimeKey 
             FROM RBL_MISDB_PROD.CoBorrowerData 
              WHERE  TIMEKEY = v_TIMEKEY );
         --Update main cust id for main customertype-------------
         MERGE INTO MAIN_PRO.CoBorrowerCal A 
         USING (SELECT A.ROWID row_id, A.CustomerID
         FROM MAIN_PRO.CoBorrowerCal A 
          WHERE A.CustomerType = 'Main') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.MainCUSTID = src.CustomerID;
         --IF CustomerAcid is same for two records and one is coborrower and other is main then update coborrower maincustid=custid of main
         MERGE INTO MAIN_PRO.CoBorrowerCal B 
         USING (SELECT B.ROWID row_id, A.CustomerID
         FROM MAIN_PRO.CoBorrowerCal A
                JOIN MAIN_PRO.CoBorrowerCal B   ON A.CustomerACID = B.CustomerACID
                AND B.CustomerType = 'Co-borrower' 
          WHERE A.CustomerType = 'Main') src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.MainCUSTID = src.CustomerID;
         -------------------------------------------------END-------------------------------------------------------------------------------
         UPDATE MAIN_PRO.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   V_SQLERRM:=SQLERRM;
      UPDATE MAIN_PRO.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = V_SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

   END;END;

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NI DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL" TO "ADF_CDR_RBL_STGDB";
