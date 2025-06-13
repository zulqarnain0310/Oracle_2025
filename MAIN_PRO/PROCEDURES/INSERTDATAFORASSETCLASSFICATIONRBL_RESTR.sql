--------------------------------------------------------
--  DDL for Procedure INSERTDATAFORASSETCLASSFICATIONRBL_RESTR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" /*=========================================
	 AUTHOR : TRILOKI KHANNA
	 CREATE DATE : 09-04-2021
	 MODIFY DATE : 09-04-2021
	 DESCRIPTION : Test Case Cover in This SP

 RefCustomerID	TestCase
2	Degradation - Non Agri with Always STD = Y
15	Degradation - CC/OD: Non Agri - Interest Servicing with Always STD = Y
16	Degradation - CC/OD: Non Agri - Conti Excess Date with Always STD = Y
17	Degradation - CC/OD: Non Agri - Last Credit Date with Always STD = Y
18	Degradation - CC/OD: Non Agri - Stock Stmt Date with Always STD = Y
19	Degradation - CC/OD: Non Agri - Last Review Due Date with Always STD = Y
20	Degradation - CC/OD: Agri - Interest Servicing with Always STD = Y
21	Degradation - CC/OD: Agri - Conti Excess Date with Always STD = Y
22	Degradation - CC/OD: Agri - Last Credit Date with Always STD = Y
23	Degradation - CC/OD: Agri - Last Review Due Date with Always STD = Y
25	Degradation - Non Agri - Interest Servicing Conti Excess Date with Always STD =Y
27	Degradation - Agri - Interest Servicing Conti Excess Date with Always STD =Y
29	Degradation - Non Agri - Interest Servicing Conti Excess Date Last Credit Date with Always STD =Y
31	Degradation - Agri - Interest Servicing Conti Excess Date Last Credit Date with Always STD =Y
33	Degradation - Non Agri - Interest Servicing Conti Excess Date Last Credit Date Stock Stmt Date with Always STD =Y
35	Degradation - Agri - Interest Servicing Conti Excess Date Last Credit Date Last Review Due Date with Always STD =Y
37	Degradation - Non Agri -OverDue Interest Servicing Conti Excess Date Last Credit Date Stock Stmt Date Last Review Due Date with Always STD =Y
46	NULL
118	Identification of SMA-0 (Always_STD Ac)
65	Security Valuation date validations - Current Asset Expired
66	Security Valuation date validations - Current Asset Active
67	Security Valuation date validations - Fixed Asset Expired
68	Security Valuation date validations - Fixed Asset Active
69	Security Valuation date validations - Permanent Asset Expired
70	Security Valuation date validations - Permanent Asset Active
76	Populaton of Secured Amount - FlgSecured = S
77	Populaton of Secured Amount - FlgSecured = U
78	Populaton of UnSecured Amount - FlgSecured = S
79	Populaton of UnSecured Amount - FlgSecured = U
92	Populaton of Secured Amount - FlgSecured = C
93	Populaton of UnSecured Amount - FlgSecured = C

=============================================*/
/*=========================================
 AUTHER : TRILOKI SHNAKER KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 27-11-2019
 DESCRIPTION : INSERT DATA FOR PRO.CUSTOMER CAL AND PRO.ACCOUNT CAL TABLE AND UPDATE SOME OTHER COLUMN
EXEC [PRO].[InsertDataforAssetClassficationRBL] @TIMEKEY=@26090,@BRANCHCODE=NULL,@ISMOC='N'
=============================================*/
------select * from sysdaymatrix where date='2021-06-06'

(
  v_TIMEKEY IN NUMBER,
  v_BRANCHCODE IN VARCHAR2 DEFAULT NULL ,
  v_ISMOC IN CHAR DEFAULT 'N' 
)
AS

BEGIN

   BEGIN
      DECLARE
         -- DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM PRO.EXTDATE_MISDB WHERE FLG = 'Y')
         --DECLARE @TimeKey  Int =(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')
         v_ProcessingDate VARCHAR2(200) := ( SELECT DATE_ 
           FROM SYSDAYMATRIX 
          WHERE  TIMEKEY = v_TIMEKEY );
         v_SETID NUMBER(10,0) := ( SELECT NVL(MAX(NVL(SETID, 0)) , 0) + 1 
           FROM PRO_RBL_MISDB_PROD.ProcessMonitor 
          WHERE  TIMEKEY = v_TIMEKEY );
         v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
           FROM sysdaymatrix 
          WHERE  timekey = v_TIMEKEY );
         v_LastMonthDateKey NUMBER(10,0) := ( SELECT LastMonthDateKey 
           FROM sysdaymatrix 
          WHERE  timekey = v_TIMEKEY );
         v_PrvDateKey NUMBER(10,0) := ( SELECT timekey - 1 
           FROM sysdaymatrix 
          WHERE  TimeKey = v_TIMEKEY );
         v_PROCESSMONTH VARCHAR2(200) := ( SELECT date_ 
           FROM SysDayMatrix 
          WHERE  TimeKey = v_TIMEKEY );
         v_PROCESSDAY VARCHAR2(10) := utils.datename('WEEKDAY', ( SELECT date_ 
                                     FROM SysDayMatrix 
                                      WHERE  TimeKey = v_TIMEKEY ));
         --DECLARE @PANCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='PANCARDNO' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
         --DECLARE @AADHARCARDFLAG CHAR(1)=(SELECT REFVALUE FROM PRO.REFPERIOD WHERE BUSINESSRULE='AADHARCARD' AND EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND EFFECTIVETOTIMEKEY>=@TIMEKEY)
         v_PANCARDFLAG CHAR(1) := ( SELECT 'Y' 
           FROM solutionglobalparameter 
          WHERE  ParameterName = 'PAN Aadhar Dedup Integration'
                   AND ParameterValueAlt_Key = 1
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_AADHARCARDFLAG CHAR(1) := ( SELECT 'Y' 
           FROM solutionglobalparameter 
          WHERE  ParameterName = 'PAN Aadhar Dedup Integration'
                   AND ParameterValueAlt_Key = 1
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_JOINTACCOUNTFLAG CHAR(1) := ( SELECT REFVALUE 
           FROM PRO_RBL_MISDB_PROD.RefPeriod 
          WHERE  BUSINESSRULE = 'JOINT ACCOUNT'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         v_UCFICFLAG CHAR(1) := ( SELECT REFVALUE 
           FROM PRO_RBL_MISDB_PROD.RefPeriod 
          WHERE  BUSINESSRULE = 'UCFIC'
                   AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         --DECLARE @QtrFlg char=(select (CASE WHEN Day(@ProcessingDate)=DAY(EOMONTH(@ProcessingDate)) AND MONTH(@ProcessingDate) IN(3,6,9,12)    THEN 'Y'	END) QtrFlg)
         v_6MnthBackTimeKey NUMBER(5,0);
         v_6MonthBackDate VARCHAR2(200);
         v_HistTimeKey NUMBER(10,0) := 0;
         v_PRVQTRRV NUMBER(10,0) := ( SELECT LastQtrDateKey 
           FROM SYSDAYMATRIX 
          WHERE  TimeKey = v_TIMEKEY );

      BEGIN
         v_6MonthBackDate := utils.dateadd('M', -6, v_ProcessingDate) ;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.CUSTOMERCAL ';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.ACCOUNTCAL ';
         DELETE PRO_RBL_MISDB_PROD.ProcessMonitor

          WHERE  TIMEKEY = v_TIMEKEY;
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET COMPLETED = 'N',
                COUNT = 0,
                ERRORDESCRIPTION = NULL,
                ERRORDATE = NULL;
         --ALTER INDEX INDEX_CUSTOMERENTITYID ON PRO.CUSTOMERCAL DISABLE
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         INSERT INTO PRO_RBL_MISDB_PROD.CUSTOMERCAL
           ( EffectiveFromTimeKey, EffectiveToTimeKey, BRANCHCODE, CUSTOMERENTITYID, RefCustomerID, CUSTOMERNAME, CONSTITUTIONALT_KEY, FlgDeg, FlgUpg, FlgMoc, FlgSMA, FlgProcessing, FlgErosion, FlgPNPA, FlgPercolation, FlgInMonth, FlgDirtyRow, SrcNPA_Dt, SysNPA_Dt, SplCatg1Alt_Key, SplCatg2Alt_Key, SplCatg3Alt_Key, SplCatg4Alt_Key, SourceSystemCustomerID, Asset_Norm, UCIF_ID, UcifEntityID, SourceAlt_Key )
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
                    CBD.SourceSystemAlt_Key 
             FROM RBL_MISDB_PROD.CustomerBasicDetail CBD
                    JOIN RBL_MISDB_PROD.AdvAcBasicDetail ABD   ON CBD.CustomerEntityId = ABD.CustomerEntityId

                    ------------------------------------------AND UCIF_ID in('RBL008207712','RBL009695189','RBL003952108','RBL021433631','RBL008739785','RBL008752172','RBL007820628','RBL008395100')

                    ---process only pui data
                    AND UCIF_ID IN ( SELECT UCIFID 
                                     FROM AdvAcPUIDetailMain a
                                      WHERE  EffectiveToTimeKey = 49999 )

              WHERE  ( CBD.EffectiveFromTimeKey <= v_TIMEKEY
                       AND CBD.EffectiveToTimeKey >= v_TIMEKEY )
                       AND ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                       AND ABD.EffectiveToTimeKey >= v_TIMEKEY )

             ----AND  (CASE WHEN @BRANCHCODE IS NULL AND @ISMOC='N' THEN '0'

             ----           WHEN @BRANCHCODE IS NULL AND @ISMOC='Y' THEN CBD.MocStatus

             ----		   WHEN @BRANCHCODE IS NOT NULL AND @ISMOC='N' THEN CBD.CustomerId

             ----	 END)

             ----	  IN (

             ----	      CASE WHEN @BRANCHCODE IS NULL AND @ISMOC='N' THEN '0'

             ----	           WHEN @BRANCHCODE IS NULL AND @ISMOC='Y' THEN 'Y'

             ----			   WHEN @BRANCHCODE IS NOT NULL AND @ISMOC='N' THEN 

             ----			( 

             ----				SELECT  ACFD.REFCustomerId  FROM CURDAT.AdvCustFinancialDetail ACFD

             ----				WHERE ACFD.EffectiveFromTimeKey<=@TIMEKEY AND ACFD.EffectiveToTimeKey>=@TIMEKEY

             ----			    AND BranchCode=@BRANCHCODE

             ----				GROUP BY  ACFD.REFCustomerId 

             ----			) END

             ----		 )
             GROUP BY ParentBranchCode,CBD.CUSTOMERENTITYID,CBD.CUSTOMERID,CBD.CUSTOMERNAME,CBD.ConstitutionAlt_Key,CBD.UCIF_ID,CBD.UcifEntityID,CBD.SourceSystemAlt_Key );
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'INSERT DATA FOR PRO.CUSTOMERCAL CAL TABLE';
         /*------------------ACCOUNT DATA INSERT------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'INSERT DATA IN ACCOUNTCAL TABLE' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         INSERT INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL
           ( ACCOUNTENTITYID, CUSTOMERACID, FLGDEG, FLGDIRTYROW, FLGINMONTH, FLGSMA, FLGPNPA, FLGUPG, FLGFITL, FLGABINITIO, REFPERIODOVERDUEUPG, REFPERIODOVERDRAWNUPG, REFPERIODNOCREDITUPG, REFPERIODINTSERVICEUPG, REFPERIODSTKSTATEMENTUPG, REFPERIODREVIEWUPG, EFFECTIVEFROMTIMEKEY, EFFECTIVETOTIMEKEY, ASSET_NORM, SPLCATG1ALT_KEY, SPLCATG2ALT_KEY, SPLCATG3ALT_KEY, SPLCATG4ALT_KEY, BALANCE, BALANCEINCRNCY, NETBALANCE, CURRENCYALT_KEY, SOURCEALT_KEY, SECAPP, PROVCOVERGOVGUR, BANKPROVSECURED, BANKPROVUNSECURED, BANKTOTALPROVISION, RBIPROVSECURED, RBIPROVUNSECURED, RBITOTALPROVISION, APPGOVGUR, USEDRV, COMPUTEDCLAIM, PROVPERSECURED, PROVPERUNSECURED, REFPERIODOVERDUE, REFPERIODOVERDRAWN, REFPERIODNOCREDIT, REFPERIODINTSERVICE, REFPERIODSTKSTATEMENT, REFPERIODREVIEW, INITIALASSETCLASSALT_KEY, FINALASSETCLASSALT_KEY, RefCustomerID, SourceSystemCustomerID, CUSTOMERENTITYID, BranchCode, ProductAlt_Key, CURRENTLIMIT, CURRENTLIMITDT, SchemeAlt_Key, SubSectorAlt_Key, FacilityType, InttRate, AcOpenDt, FirstDtOfDisb, PrvAssetClassAlt_Key, FlgSecured, UCIF_ID, UcifEntityID, ActSegmentCode )
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
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDUEUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDUEUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDRAWNUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDRAWNUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODNOCREDITUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODNOCREDITUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODINTSERVICEUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODINTSERVICEUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODSTKSTATEMENTUPG'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODSTKSTATEMENTUPG  ,
                    ( SELECT UTILS.CONVERT_TO_NUMBER(REFVALUE,10,0) 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
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
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDUE'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDUE  ,
                    ( SELECT REFVALUE 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODOVERDRAWN'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODOVERDRAWN  ,
                    ( SELECT REFVALUE 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODNOCREDIT'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODNOCREDIT  ,
                    ( SELECT REFVALUE 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODINTSERVICE'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODINTSERVICE  ,
                    ( SELECT REFVALUE 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
                       WHERE  BUSINESSRULE = 'REFPERIODSTKSTATEMENT'
                                AND EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                AND EFFECTIVETOTIMEKEY >= v_TIMEKEY 
                        FETCH FIRST 1 ROWS ONLY ) REFPERIODSTKSTATEMENT  ,
                    ( SELECT REFVALUE 
                      FROM PRO_RBL_MISDB_PROD.RefPeriod 
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
                    abd.segmentcode 
             FROM RBL_MISDB_PROD.AdvAcBasicDetail ABD
                    JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL CBD   ON abd.CUSTOMERENTITYID = CBD.CUSTOMERENTITYID
                    LEFT JOIN DimGLProduct C   ON C.GLProductAlt_Key = ABD.GLProductAlt_Key
                    AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
                    AND C.EffectiveToTimeKey >= v_TIMEKEY )
              WHERE  ( ABD.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND ABD.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
               GROUP BY ABD.BRANCHCODE,ABD.CUSTOMERENTITYID,ABD.ACCOUNTENTITYID,ABD.SYSTEMACID,ABD.CUSTOMERACID,ABD.GLALT_KEY,ABD.GLPRODUCTALT_KEY,ABD.PRODUCTALT_KEY,ABD.SEGMENTCODE,ABD.ACCOUNTOPENDATE,ABD.FacilityType,ABD.DTOFFIRSTDISB,ABD.CURRENTLIMIT,ABD.CURRENTLIMITDT,ABD.CURRENCYALT_KEY,ABD.REFCUSTOMERID,ABD.SCHEMEALT_KEY,ABD.ACTIVITYALT_KEY,ABD.InttTypeAlt_Key,ABD.SubSectorAlt_Key,ABD.OriginalLimitDt,CBD.CUSTOMERENTITYID,ABD.Pref_InttRate,ABD.SOURCEALT_KEY,CBD.UCIF_ID,CBD.UcifEntityID,ABD.FlgSecured );
         --alter index all on PRO.CUSTOMERCAL  rebuild
         --alter index all on PRO.accountcal   rebuild	 
         /* update ucifentityid from  customerentityid in case of ucifeentity is not  present */
         ----update pro.ACCOUNTCAL set UcifEntityID=CustomerEntityID	 where isnull(ucifentityid,0)=0
         ----update pro.CUSTOMERCAL set UcifEntityID=CustomerEntityID where isnull(ucifentityid,0)=0
         ----update pro.ACCOUNTCAL set UCIF_ID=RefCustomerID	 where UCIF_ID IS NULL
         ----update pro.CUSTOMERCAL set UCIF_ID=RefCustomerID where UCIF_ID IS NULL
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'INSERT DATA IN ACCOUNTCAL TABLE';
         /*------------------UPDATE PANNO IN CUSTOMER CAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE PANNO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.PAN
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId 
          WHERE ( REGEXP_LIKE(B.PAN, '%[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]%') )
           AND ( B.PAN NOT LIKE '%FORMO%'
           AND PAN NOT LIKE '%FORPM%'
           AND PAN NOT LIKE '%FORMF%' )
           AND ( B.PAN IS NOT NULL )
           AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PANNO = src.PAN;
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORMO6161O';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORPM6060F';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORPM6060P';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'FORMF6060F';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET PANNO = NULL
          WHERE  PANNO = 'AAAAA1111A';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PANNO';
         /*------------------UPDATE AADHAR NUMBER IN CUSTOMER CAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE AADHAR NUMBER IN CUSTOMER CAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.AadhaarId
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId 
          WHERE LENGTH(LTRIM(RTRIM(B.AadhaarId))) = 12
           AND REGEXP_LIKE(B.AadhaarId, '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
           AND ( B.AadhaarId IS NOT NULL )
           AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.AADHARCARDNO = src.AadhaarId;
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '000000000000';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '111111111111';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '222222222222';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '333333333333';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '444444444444';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '555555555555';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '666666666666';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '777777777777';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '888888888888';
         UPDATE PRO_RBL_MISDB_PROD.CUSTOMERCAL
            SET AADHARCARDNO = NULL
          WHERE  AADHARCARDNO = '999999999999';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE AADHAR NUMBER IN CUSTOMER CAL';
         ----/*------------------INSERT INVALID PANCARDNO|AADHARCARDNO------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'INSERT INVALID PANCARDNO|AADHARCARDNO' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         DELETE PRO_RBL_MISDB_PROD.InvalidPanAadhar

          WHERE  EFFECTIVEFROMTIMEKEY = v_TIMEKEY
                   AND EFFECTIVETOTIMEKEY = v_TIMEKEY;
         INSERT INTO PRO_RBL_MISDB_PROD.InvalidPanAadhar
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
             FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                    JOIN RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId
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
             FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                    JOIN RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId
              WHERE  ( B.PAN LIKE '%FORMO%'
                       OR B.PAN LIKE '%FORPM%'
                       OR B.PAN LIKE '%FORMF%' )
                       AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         INSERT INTO PRO_RBL_MISDB_PROD.InvalidPanAadhar
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
             FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                    JOIN RBL_MISDB_PROD.AdvCustRelationship B   ON A.CustomerEntityID = B.CustomerEntityId
              WHERE  REGEXP_LIKE(B.AadhaarId, '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
                       AND ( B.AadhaarId IS NOT NULL )
                       AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY );
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'INSERT INVALID PANCARDNO|AADHARCARDNO';
         /*-------------UPDATE ProductCode IN ACCOUNTCAL-------------------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, C.ProductCode
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID
                JOIN DimProduct C   ON B.ProductAlt_Key = C.ProductAlt_Key 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND ( C.EffectiveFromTimeKey <= v_TIMEKEY
           AND C.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.ProductCode = src.ProductCode;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE ProductCode IN ACCOUNTCAL';
         ---Condition Change Required  Modification Done--- 
         /*------------********UPDATE DRAWINGPOWER|REVIEWDUEDT FOR ALL ACCOUNT******--------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE DRAWINGPOWER|REVIEWDUEDT FOR ALL ACCOUNT' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.DRAWINGPOWER, 0) AS pos_2, B.Ac_NextReviewDueDt
         --,WriteOffAmount=ISNULL(B.WriteOffAmt_HO,0)

         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcFinancialDetail B   ON ( B.EFFECTIVEFROMTIMEKEY <= v_TimeKey
                AND B.EFFECTIVETOTIMEKEY >= v_TimeKey )
                AND A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DRAWINGPOWER
                                      --A.ReviewDueDt= (case when FACILITYTYPE in('DL','TL','PC','BP','BD') then null else  B.Ac_NextReviewDueDt   end )
                                       = pos_2,
                                      A.ReviewDueDt = src.Ac_NextReviewDueDt;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE DRAWINGPOWER|REVIEWDUEDT FOR ALL ACCOUNT';
         /*------------********UPDATE FacilityType FOR TLDL ACCOUNT******--------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND NVL(B.ISLAD, 0) = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Asset_Norm --'CONDI_STD'
                                       = 'ALWYS_STD';
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND assetclass = '1') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Asset_Norm = 'ALWYS_STD';
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND assetclass = '2') src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Asset_Norm = 'ALWYS_NPA';
         ---Condition Change Required  Modification Done---  
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Asset_Norm|FacilityType ISLAD  ACCOUNT';
         /*-------------UPDATE BANK ASSET CLASSIFICATION IN ACCOUNTCALL------------------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE BANK ASSET CLASSIFICATION IN ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.SourceAssetClass
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveFromTimeKey > v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.AccountStatus = src.SourceAssetClass;
         MERGE INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL 
         USING (SELECT PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID row_id, C.AssetClassAlt_Key
         FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN AdvAcBalanceDetail B   ON A.AccountEntityID = B.AccountEntityID
                JOIN DimAssetClassMapping C   ON C.SrcSysClassCode = A.AccountStatus
                AND C.EffectiveFromTimeKey <= v_TIMEKEY
                AND C.EffectiveFromTimeKey > v_TIMEKEY 
          WHERE B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveFromTimeKey > v_TIMEKEY) src
         ON ( PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET PRO_RBL_MISDB_PROD.AccountCal.BankAssetClass = src.AssetClassAlt_Key;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE BANK ASSET CLASSIFICATION IN ACCOUNTCAL';
         /*------------********UPDATE ContiExcessDt FOR CC ACCOUNT******--------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         ----EXEC PRO.ContExcsSinceDt  -- COMMENEDT BY AMAR ON 12-06-2021 BANK IS PROVIDING IN SOURCE DATA
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.ContExcsSinceDt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.ContExcsSinceDtAccountCal B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.ContiExcessDt = src.ContExcsSinceDt;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.ContExcsSinceDebitDt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.ContExcsSinceDtDebitAccountCal B   ON ( B.EffectiveFromTimeKey <= v_TimeKey
                AND B.EffectiveToTimeKey >= v_TimeKey )
                AND A.AccountEntityID = B.AccountEntityId ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DebitSinceDt = src.ContExcsSinceDebitDt;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE ContiExcessDt FOR CC ACCOUNT';
         /*---------------******UPDATE Balance,OverdueAmt,OverDueSinceDt,BalanceInCrncy and LastCrDate  FROM AdvACBalanceDetail*******----------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Balance,LastCrDate,CreditsinceDt FOR ALL ACCOUNT' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.Balance, CASE 
         WHEN NVL(DebitSinceDt, '1900-01-01') > NVL(LastCrDt, '1900-01-01') THEN NULL
         ELSE (CASE 
         WHEN FacilityType IN ( 'DL','TL','BP','BD','PC' )
          THEN NULL
         ELSE B.LastCrDt
            END)
            END AS pos_3, B.LastCrDt, B.MocTypeAlt_Key, B.MocStatus, B.MocDate, B.OverDueSinceDt, B.OverDue, B.OverduePrincipal, B.Overdueinterest, B.PrincipalBalance, B.AdvanceRecovery, B.NotionalInttAmt, B.DFVAmt, B.OverduePrincipalDt, B.OverdueIntDt, B.OverOtherdue, B.OverdueOtherDt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcBalanceDetail B   ON ( B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
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
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Balance,LastCrDate,CreditsinceDt FOR ALL ACCOUNT';
         /* starts of temporary updates*/
         --DELETE A  -- DELETE CHARGE OFF ACCOUNTS IN VISION PLUS
         --FROM PRO.ACCOUNTCAL A
         --	INNER JOIN RBL_STGDB.DBO.ACCOUNT_ALL_SOURCE_SYSTEM B
         --		ON A.CustomerAcID=B.CustomerAcID 
         --		AND ChargeoffY_N ='Y'
         DELETE A
         --select count(1)

          WHERE ROWID IN 
         ( SELECT A.ROWID
           FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                  LEFT JOIN AdvFacCreditCardDetail B   ON A.AccountEntityId = B.AccountEntityId
                  AND b.EffectiveFromTimeKey <= v_TIMEKEY
                  AND b.EffectiveToTimeKey >= v_TIMEKEY,
                A
                --select count(1)

          WHERE  a.SourceAlt_Key = 6
                   AND B.AccountEntityId IS NULL );
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, b.CurQtrCredit, b.CurQtrInt
         FROM a ,PRO_RBL_MISDB_PROD.ACCOUNTCAL a
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
         --FROM PRO.AccountCal A INNER  JOIN RBL_STGDB.DBO.ACCOUNT_ALL_SOURCE_SYSTEM b	on a.customeracid=b.CustomerAcID
         --INNER JOIN DIMSOURCEDB c ON A.SourceAlt_Key=c.SourceAlt_Key
         --where ISNULL(B.CD,0)>0 and SourceName='VISIONPLUS' AND c.EffectiveFromTimeKey<=@Timekey and c.EffectiveToTimeKey>=@Timekey
         ----UPDATE A SET Liability=B.Liability,CD=B.CD,AccountStatus=b.AccountStatus,AccountBlkCode1=b.AccountBlkCode1,AccountBlkCode2=b.AccountBlkCode2
         ----FROM PRO.AccountCal A INNER  JOIN RBL_STGDB.DBO.ACCOUNT_ALL_SOURCE_SYSTEM b	on a.customeracid=b.CustomerAcID
         ----INNER JOIN DIMSOURCEDB c ON A.SourceAlt_Key=c.SourceAlt_Key
         ----where  SourceName='VISIONPLUS' AND c.EffectiveFromTimeKey<=@Timekey and c.EffectiveToTimeKey>=@Timekey
         /* end of temporary updates*/
         /*------------------UPDATE OVERDUE SINCE DATE DUE TO DPD MAX FOR VISION PLUS DATA ONLY------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE OVERDUE SINCE DATE DUE TO DPD MAX FOR VISION PLUS DATA ONLY' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, utils.dateadd('DAY', -DPD, v_PROCESSINGDATE) AS OVERDUESINCEDT
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvFacCreditCardDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND NVL(B.DPD, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.OVERDUESINCEDT = src.OVERDUESINCEDT;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.Liability, B.CD, b.AccountStatus, b.AccountBlkCode1, b.AccountBlkCode2
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN AdvFacCreditCardDetail b   ON a.AccountEntityID = b.AccountEntityID
                AND B.EffectiveFromTimeKey <= v_Timekey
                AND B.EffectiveToTimeKey >= v_Timekey
                JOIN DIMSOURCEDB c   ON A.SourceAlt_Key = c.SourceAlt_Key 
          WHERE SourceName = 'VISIONPLUS'
           AND c.EffectiveFromTimeKey <= v_Timekey
           AND c.EffectiveToTimeKey >= v_Timekey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET Liability = src.Liability,
                                      CD = src.CD,
                                      AccountStatus = src.AccountStatus,
                                      AccountBlkCode1 = src.AccountBlkCode1,
                                      AccountBlkCode2 = src.AccountBlkCode2;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.Liability, B.CD, b.AccountStatus, b.AccountBlkCode1, b.AccountBlkCode2
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvFacCreditCardDetail B   ON A.AccountEntityID = B.AccountEntityID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Liability = src.Liability,
                                      B.CD = src.CD,
                                      B.AccountStatus = src.AccountStatus,
                                      B.AccountBlkCode1 = src.AccountBlkCode1,
                                      B.AccountBlkCode2 = src.AccountBlkCode2;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE OVERDUE SINCE DATE DUE TO DPD MAX FOR VISION PLUS DATA ONLY';
         /*-----update SrcAssetClass_Key key|SysAssetClassAlt_Key in customer Cal table--------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'SrcAssetClass_Key key|SysAssetClassAlt_Key' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         SELECT MAX(EffectiveFromTimeKey)  

           INTO v_HistTimeKey
           FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
          WHERE  EffectiveFromTimeKey < v_TIMEKEY;
         IF NVL(v_HistTimeKey, 0) = 0 THEN

         BEGIN
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, NVL(c.Cust_AssetClassAlt_Key, 1) AS pos_2, NVL(c.Cust_AssetClassAlt_Key, 1) AS pos_3, NVL(C.NPADt, NULL) AS pos_4, NVL(C.NPADt, NULL) AS pos_5, NVL(C.DbtDt, NULL) AS pos_6, NVL(C.LosDt, NULL) AS pos_7
            FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail C   ON C.CustomerEntityId = A.CustomerEntityID
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
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, NVL(c.SrcAssetClassAlt_Key, 1) AS pos_2, NVL(c.SysAssetClassAlt_Key, 1) AS pos_3, NVL(C.SrcNPA_Dt, NULL) AS pos_4, NVL(C.SysNPA_Dt, NULL) AS pos_5, NVL(C.DbtDt, NULL) AS pos_6, NVL(C.LossDt, NULL) AS pos_7
            FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON C.CustomerEntityId = A.CustomerEntityID
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
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'SrcAssetClass_Key key|SysAssetClassAlt_Key';
         ----IF OBJECT_ID('TEMPDB..#TEMPTABLE_VISIONPLUS_ASSETCLASS') IS NOT NULL
         ----  DROP TABLE #TEMPTABLE_VISIONPLUS_ASSETCLASS
         ----  SELECT  SOURCESYSTEMCUSTOMERID,
         ----MAX(CASE WHEN CD IN(5,6,7,8,9) THEN 2 ELSE 1 END ) ASSETCLASS ---OR ISNULL(ACCOUNTSTATUS,'N')='Z'
         ----INTO #TEMPTABLE_VISIONPLUS_ASSETCLASS
         ----FROM PRO.ACCOUNTCAL A
         ----INNER JOIN DIMSOURCEDB B
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
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
            IF utils.object_id('TEMPDB..tt_TEMPTABLEPANCARD') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLEPANCARD ';
            END IF;
            DELETE FROM tt_TEMPTABLEPANCARD;
            UTILS.IDENTITY_RESET('tt_TEMPTABLEPANCARD');

            INSERT INTO tt_TEMPTABLEPANCARD ( 
            	SELECT PANNO ,
                    MAX(NVL(SYSASSETCLASSALT_KEY, 1))  SYSASSETCLASSALT_KEY  ,
                    MIN(SYSNPA_DT)  SYSNPA_DT  
            	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                      JOIN DIMSOURCEDB B   ON B.SOURCEALT_KEY = A.SourceAlt_Key
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
            	 WHERE  PANNO IS NOT NULL
                       AND NVL(SYSASSETCLASSALT_KEY, 1) <> 1
            	  GROUP BY PANNO );

            EXECUTE IMMEDIATE ' ALTER TABLE tt_TEMPTABLEPANCARD 
               ADD ( SOURCEDBNAME VARCHAR2(20)  ) ';
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, C.SOURCEDBNAME
            FROM A ,tt_TEMPTABLEPANCARD A
                   JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.PANNO = B.PANNO
                   JOIN DIMSOURCEDB C   ON B.SourceAlt_Key = C.SOURCEALT_KEY
                   AND C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY 
             WHERE A.SYSNPA_DT = B.SysNPA_Dt) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET B.SOURCEDBNAME = src.SOURCEDBNAME;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.SYSASSETCLASSALT_KEY, B.SYSNPA_DT
            FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.SYSASSETCLASSALT_KEY,
                                         A.SYSNPA_DT = src.SYSNPA_DT;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, 'PERCOLATION BY PAN CARD ' || ' ' || B.SOURCEDBNAME || '  ' || B.PANNO AS DEGREASON
            FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO 
             WHERE A.SrcAssetClassAlt_Key = 1
              AND A.SysAssetClassAlt_Key > 1
              AND A.DegReason IS NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;

         END;
         END IF;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY PAN NO';
         /*------------------UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY AADHAR CARD NO------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
            IF utils.object_id('TEMPDB..tt_TEMPTABLE_ADHARCARD') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_ADHARCARD ';
            END IF;
            DELETE FROM tt_TEMPTABLE_ADHARCARD;
            UTILS.IDENTITY_RESET('tt_TEMPTABLE_ADHARCARD');

            INSERT INTO tt_TEMPTABLE_ADHARCARD ( 
            	SELECT AADHARCARDNO ,
                    MAX(NVL(SYSASSETCLASSALT_KEY, 1))  SYSASSETCLASSALT_KEY  ,
                    MIN(SYSNPA_DT)  SYSNPA_DT  ,
                    B.SOURCEDBNAME 
            	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                      JOIN DIMSOURCEDB B   ON B.SOURCEALT_KEY = A.SourceAlt_Key
                      AND B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                      AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY
            	 WHERE  A.AadharCardNO IS NOT NULL
                       AND NVL(A.SysAssetClassAlt_Key, 1) <> 1
            	  GROUP BY AADHARCARDNO,B.SOURCEDBNAME );
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, B.SYSASSETCLASSALT_KEY, B.SYSNPA_DT
            FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_TEMPTABLE_ADHARCARD B   ON A.AadharCardNO = B.AADHARCARDNO ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.SYSASSETCLASSALT_KEY = src.SYSASSETCLASSALT_KEY,
                                         A.SYSNPA_DT = src.SYSNPA_DT;
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, 'PERCOLATION BY AADHAR CARD ' || ' ' || B.SOURCEDBNAME || '  ' || B.AADHARCARDNO AS DEGREASON
            FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_TEMPTABLE_ADHARCARD B   ON A.AadharCardNO = B.AADHARCARDNO 
             WHERE A.SrcAssetClassAlt_Key = 1
              AND A.SysAssetClassAlt_Key > 1
              AND A.DegReason IS NULL) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.DEGREASON = src.DEGREASON;

         END;
         END IF;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SYSASSETCLASSALT_KEY|SYSNPA_DT BY AADHARCARD NO';
         /*-----UPDATE SplCatg Alt_Key ACCOUNT LEVEL--------------- */
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'SplCatg Alt_Key ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.SplCatg1Alt_Key, 0) AS pos_2, NVL(B.SplCatg2Alt_Key, 0) AS pos_3, NVL(B.SplCatg3Alt_Key, 0) AS pos_4, NVL(B.SplCatg4Alt_Key, 0) AS pos_5
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcOtherDetail B   ON A.AccountEntityID = B.ACCOUNTENTITYID
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SplCatg1Alt_Key = pos_2,
                                      A.SplCatg2Alt_Key = pos_3,
                                      A.SplCatg3Alt_Key = pos_4,
                                      A.SplCatg4Alt_Key = pos_5;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'SplCatg Alt_Key ACCOUNT LEVEL';
         /*-----UPDATE SplCatg Alt_Key CUSTOMER LEVEL--------------- */
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE SplCatg Alt_Key CUSTOMER LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.SplCatg1Alt_Key, 0) AS pos_2, NVL(B.SplCatg2Alt_Key, 0) AS pos_3, NVL(B.SplCatg3Alt_Key, 0) AS pos_4, NVL(B.SplCatg4Alt_Key, 0) AS pos_5
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN RBL_MISDB_PROD.AdvCustOtherDetail B   ON A.CustomerEntityID = B.CUSTOMERENTITYID
                AND B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SplCatg1Alt_Key = pos_2,
                                      A.SplCatg2Alt_Key = pos_3,
                                      A.SplCatg3Alt_Key = pos_4,
                                      A.SplCatg4Alt_Key = pos_5;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SplCatg Alt_Key CUSTOMER LEVEL';
         /*----MARKING OF ALWAYS STD Account LEVEL----------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'MARKING OF ALWAYS STD Account LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_STD'
         FROM ACL ,PRO_RBL_MISDB_PROD.ACCOUNTCAL ACL
                LEFT JOIN DimScheme DSE   ON DSE.EffectiveFromTimeKey <= v_TimeKey
                AND DSE.EffectiveToTimeKey >= v_TimeKey
                AND ACL.SchemeAlt_key = DSE.SchemeAlt_Key
                LEFT JOIN DimAcSplCategory DAS1   ON DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg1Alt_Key, 0) = DAS1.SplCatAlt_Key
                AND NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN DimAcSplCategory DAS2   ON DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg2Alt_Key, 0) = DAS2.SplCatAlt_Key
                AND NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN DimAcSplCategory DAS3   ON DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg3Alt_Key, 0) = DAS3.SplCatAlt_Key
                AND NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN DimAcSplCategory DAS4   ON DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg4Alt_Key, 0) = DAS4.SplCatAlt_Key
                AND NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_STD'
                LEFT JOIN DIMPRODUCT P   ON P.ProductAlt_Key = ACL.ProductAlt_Key
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
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'MARKING OF ALWAYS STD Account LEVEL';
         /*--------marking  always NPA account table level----------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking  always NPA account table level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA'
         FROM ACL ,PRO_RBL_MISDB_PROD.ACCOUNTCAL ACL
                LEFT JOIN DimScheme DSE   ON DSE.EffectiveFromTimeKey <= v_TimeKey
                AND DSE.EffectiveToTimeKey >= v_TimeKey
                AND ACL.SchemeAlt_key = DSE.SchemeAlt_Key
                LEFT JOIN DimAcSplCategory DAS1   ON DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg1Alt_Key, 0) = DAS1.SplCatAlt_Key
                AND NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_NPA'
                LEFT JOIN DimAcSplCategory DAS2   ON DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg2Alt_Key, 0) = DAS2.SplCatAlt_Key
                AND NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_NPA'
                LEFT JOIN DimAcSplCategory DAS3   ON DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey
                AND NVL(ACL.SplCatg3Alt_Key, 0) = DAS3.SplCatAlt_Key
                AND NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_NPA'
                LEFT JOIN DimAcSplCategory DAS4   ON DAS4.EffectiveFromTimeKey <= v_TimeKey
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
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking  always NPA account table level';
         /*-----------------marking  always STD CUSTOMER  level------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking  always STD CUSTOMER  level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                LEFT JOIN DimConstitution DCO   ON DCO.EffectiveFromTimeKey <= v_TimeKey
                AND DCO.EffectiveToTimeKey >= v_TimeKey
                AND A.ConstitutionAlt_Key = DCO.ConstitutionAlt_Key
                LEFT JOIN DimSplCategory DAS1   ON DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg1Alt_Key = DAS1.SplCatAlt_Key
                LEFT JOIN DimSplCategory DAS2   ON DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg2Alt_Key = DAS2.SplCatAlt_Key
                LEFT JOIN DimSplCategory DAS3   ON DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg3Alt_Key = DAS3.SplCatAlt_Key
                LEFT JOIN DimSplCategory DAS4   ON DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey
                AND A.SplCatg4Alt_Key = DAS4.SplCatAlt_Key 
          WHERE ( ( NVL(DCO.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_STD' )
           OR ( NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_STD'
           OR NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_STD' ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_STD';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking  always STD CUSTOMER  level';
         /*---marking  always NPA CUSTOMER table level------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'marking  always NPA CUSTOMER table level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                LEFT JOIN DimConstitution DCO   ON ( DCO.EffectiveFromTimeKey <= v_TimeKey
                AND DCO.EffectiveToTimeKey >= v_TimeKey )
                AND A.ConstitutionAlt_Key = DCO.ConstitutionAlt_Key
                LEFT JOIN DimSplCategory DAS1   ON ( DAS1.EffectiveFromTimeKey <= v_TimeKey
                AND DAS1.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg1Alt_Key = DAS1.SplCatAlt_Key
                LEFT JOIN DimSplCategory DAS2   ON ( DAS2.EffectiveFromTimeKey <= v_TimeKey
                AND DAS2.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg2Alt_Key = DAS2.SplCatAlt_Key
                LEFT JOIN DimSplCategory DAS3   ON ( DAS3.EffectiveFromTimeKey <= v_TimeKey
                AND DAS3.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg3Alt_Key = DAS3.SplCatAlt_Key
                LEFT JOIN DimSplCategory DAS4   ON ( DAS4.EffectiveFromTimeKey <= v_TimeKey
                AND DAS4.EffectiveToTimeKey >= v_TimeKey )
                AND A.SplCatg4Alt_Key = DAS4.SplCatAlt_Key 
          WHERE ( ( NVL(DCO.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS1.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS2.AssetClass, 'NORMAL') = 'ALWYS_NPA' )
           OR ( NVL(DAS3.AssetClass, 'NORMAL') = 'ALWYS_NPA'
           OR NVL(DAS4.AssetClass, 'NORMAL') = 'ALWYS_NPA' ) )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking  always NPA CUSTOMER table level';
         /*----UPDATE ACCOUNTS WHOSE CUSTOMER IS IN ALWAYS STANDAED CATEGORY---------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Accounts whose customer is in always standaed category' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO ABD 
         USING (SELECT ABD.ROWID row_id, 'ALWYS_STD'
         FROM ABD ,PRO_RBL_MISDB_PROD.ACCOUNTCAL ABD
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL CBD   ON ABD.CustomerEntityID = CBD.CustomerEntityID 
          WHERE CBD.Asset_Norm = 'ALWYS_STD') src
         ON ( ABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ABD.Asset_Norm = 'ALWYS_STD';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Accounts whose customer is in always standaed category';
         /*----UPDATE ACCOUNTS WHOSE CUSTOMER IS IN ALWAYS NPA CATEGORY--------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE Accounts whose customer is in always NPA category' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO ABD 
         USING (SELECT ABD.ROWID row_id, 'ALWYS_NPA'
         FROM ABD ,PRO_RBL_MISDB_PROD.ACCOUNTCAL ABD
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL CBD   ON ABD.CustomerEntityID = CBD.CustomerEntityID 
          WHERE CBD.Asset_Norm = 'ALWYS_NPA'
           AND ABD.Asset_Norm <> 'ALWYS_STD') src
         ON ( ABD.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ABD.Asset_Norm = 'ALWYS_NPA';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Accounts whose customer is in always NPA category';
         /*-------CurrAssetClassAlt_Key update in Account Cal from customer Cal systemAssetclassalt_key--------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, NVL(c.Cust_AssetClassAlt_Key, 1) AS pos_2, NVL(C.Cust_AssetClassAlt_Key, 1) AS pos_3
            FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                   JOIN RBL_MISDB_PROD.AdvCustNPADetail C   ON C.CustomerEntityId = A.CustomerEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.INITIALASSETCLASSALT_KEY = pos_2,
                                         A.PrvAssetClassAlt_Key = pos_3;

         END;
         ELSE

         BEGIN
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, NVL(c.FinalAssetClassAlt_Key, 1) AS pos_2, NVL(C.FinalAssetClassAlt_Key, 1) AS pos_3
            FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                   JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON C.AccountEntityID = A.AccountEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_HistTimeKey
                   AND C.EFFECTIVETOTIMEKEY >= v_HistTimeKey ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.INITIALASSETCLASSALT_KEY = pos_2,
                                         A.PrvAssetClassAlt_Key = pos_3;

         END;
         END IF;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS FinalAssetClassAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.SysAssetClassAlt_Key, 1) AS FinalAssetClassAlt_Key
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalAssetClassAlt_Key = src.FinalAssetClassAlt_Key;
         IF v_PANCARDFLAG = 'Y' THEN

         BEGIN
            MERGE INTO C 
            USING (SELECT C.ROWID row_id, A.SysAssetClassAlt_Key
            FROM C ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO
                   JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON C.UcifEntityID = A.UcifEntityID ) src
            ON ( C.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET C.FinalAssetClassAlt_Key
                                         --,C.FinalNpaDt=A.SYSNPA_DT  
                                          = src.SysAssetClassAlt_Key;

         END;
         END IF;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'CurrAssetClassAlt_Key update in Account Cal from customer Cal systemAssetclassalt_key';
         /*---------UPDATE INITIALNPADT AND FINALNPADT AT ACCOUNT  LEVEL FROM CUSTOMER TO ACCOUNT------------- */
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         IF NVL(v_HistTimeKey, 0) = 0 THEN

         BEGIN
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, NVL(C.NPADt, NULL) AS InitialNpaDt
            FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                   LEFT JOIN RBL_MISDB_PROD.AdvCustNPADetail C   ON C.CustomerEntityId = A.CustomerEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                   AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.InitialNpaDt = src.InitialNpaDt;

         END;
         ELSE

         BEGIN
            MERGE INTO A 
            USING (SELECT A.ROWID row_id, NVL(C.FinalNpaDt, NULL) AS InitialNpaDt
            FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                   LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist C   ON C.AccountEntityID = A.AccountEntityID
                   AND ( C.EFFECTIVEFROMTIMEKEY <= v_HistTimeKey
                   AND C.EFFECTIVETOTIMEKEY >= v_HistTimeKey ) ) src
            ON ( A.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET A.InitialNpaDt = src.InitialNpaDt;

         END;
         END IF;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.SysNPA_Dt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.CustomerEntityID = B.CustomerEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalNpaDt = src.SysNPA_Dt;
         --WHERE A.INITIALASSETCLASSALT_KEY<>1
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.SysNPA_Dt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FinalNpaDt = src.SysNPA_Dt;
         --WHERE A.INITIALASSETCLASSALT_KEY<>1
         IF v_PANCARDFLAG = 'Y' THEN

         BEGIN
            MERGE INTO C 
            USING (SELECT C.ROWID row_id, A.SysNPA_Dt
            FROM C ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                   JOIN tt_TEMPTABLEPANCARD B   ON A.PANNO = B.PANNO
                   JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON C.UcifEntityID = A.UcifEntityID ) src
            ON ( C.ROWID = src.row_id )
            WHEN MATCHED THEN UPDATE SET C.FinalNpaDt = src.SysNPA_Dt;

         END;
         END IF;
         UPDATE PRO_RBL_MISDB_PROD.ACCOUNTCAL
            SET ASSET_NORM = 'ALWYS_NPA'
          WHERE  INITIALASSETCLASSALT_KEY = 6;
         UPDATE PRO_RBL_MISDB_PROD.ACCOUNTCAL
            SET INITIALASSETCLASSALT_KEY = 1,
                INITIALNPADT = NULL,
                FINALNPADT = NULL,
                FINALASSETCLASSALT_KEY = 1,
                PrvAssetClassAlt_Key = 1
          WHERE  ASSET_NORM = 'ALWYS_STD'
           AND INITIALASSETCLASSALT_KEY <> 1;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE InitialNpaDt AND FinalNpaDt AT Account  level from customer to account';
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         MERGE INTO ACL 
         USING (SELECT ACL.ROWID row_id, b.Amount
         FROM ACL ,PRO_RBL_MISDB_PROD.ACCOUNTCAL ACL
                JOIN ExceptionFinalStatusType b   ON ACL.CustomerAcID = b.ACID 
          WHERE b.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
           AND b.EffectiveToTimeKey >= v_TIMEKEY
           AND B.StatusType IN ( 'TWO','WO' )
         ) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.WriteOffAmount = src.Amount;
         MERGE INTO ACL 
         USING (SELECT ACL.ROWID row_id, 'ALWYS_NPA'
         FROM ACL ,PRO_RBL_MISDB_PROD.ACCOUNTCAL ACL 
          WHERE WriteOffAmount > 0
           AND FinalAssetClassAlt_Key > 1) src
         ON ( ACL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ACL.Asset_Norm = 'ALWYS_NPA';
         --Update ACL 
         --set Asset_Norm='ALWYS_NPA'
         --from PRO.AccountCal ACL
         --inner join curdat.AdvAcWODetail b
         --on ACL.CustomerAcID=b.CustomerAcID
         --where b.EFFECTIVEFROMTIMEKEY<=@TIMEKEY and b.EffectiveToTimeKey>=@TIMEKEY
         --and  ACL.FinalAssetClassAlt_Key>1
         --and b.WriteOffDt is not null
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'marking always NPA account table level where WriteOffAmount>0';
         /*--------marking always NPA account table level where WriteOffAmount>0----------------*/
         /*---------UPDATE PrvQtrRV  AT Customer level--------------------- */
         /*---TO BE REMOVE GET VALUE FROM FUNCTION*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         IF utils.object_id('TEMPDB..tt_PRVQTRRV') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PRVQTRRV ';
         END IF;
         DELETE FROM tt_PRVQTRRV;
         UTILS.IDENTITY_RESET('tt_PRVQTRRV');

         INSERT INTO tt_PRVQTRRV ( 
         	SELECT * 
         	  FROM TABLE(AdvCustSecurityFunpre(v_PRVQTRRV))  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.Total_PriSec, 0) + NVL(B.Total_CollSec, 0) AS PRVQTRRV
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN tt_PRVQTRRV B   ON A.CustomerEntityID = B.CUSTOMERENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PRVQTRRV = src.PRVQTRRV;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PrvQtrRV  AT Customer level';
         --/*---------UPDATE CurntQtrRv  AT Customer level--------------------- */ 
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         IF utils.object_id('TEMPDB..tt_CurntQtrRv') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CurntQtrRv ';
         END IF;
         DELETE FROM tt_CurntQtrRv;
         UTILS.IDENTITY_RESET('tt_CurntQtrRv');

         INSERT INTO tt_CurntQtrRv ( 
         	SELECT * 
         	  FROM TABLE(AdvCustSecurityFun(v_TIMEKEY))  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.Total_PriSec, 0) + NVL(B.Total_CollSec, 0) AS CurntQtrRv
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN tt_CurntQtrRv B   ON A.CustomerEntityID = B.CUSTOMERENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CurntQtrRv = src.CurntQtrRv;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
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
         ----WHERE  ISNULL(A.FLGABINITIO,'N')<>'Y' 	AND A.FINALASSETCLASSALT_KEY NOT IN (6)
         ----and isnull(A.SecurityValue,0)>0
         ----GROUP BY A.CUSTOMERENTITYID
         ----) B ON A.CUSTOMERENTITYID=B.CUSTOMERENTITYID

         ----UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE FINAL CURNTQTRRV AT  CUSTOMER LEVEL'


         ----   --------UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL--------------
             INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
          SELECT ORIGINAL_LOGIN(),'UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID

          ---Condition Change Required --- 

         ------ UPDATE A SET FlgSecured='S'
         ------FROM PRO.AccountCal A INNER  JOIN dbo.AdvAcBasicDetail B ON A.AccountEntityID=B.AccountEntityID
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
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, 'D'
         FROM B ,PRO_RBL_MISDB_PROD.ACCOUNTCAL B
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL a   ON A.CustomerEntityID = B.CustomerEntityID 
          WHERE NVL(CurntQtrRv, 0) > 0
           AND B.SecApp = 'S'
           AND NVL(B.Balance, 0) > 0) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FlgSecured = 'D';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SECURITY FLAG WHERE SECURITY AT CUSTOMER LEVEL BUT  SecApp UNSECURED AT ACCOUNT LEVEL';
         /*----UPDATE FLGABINITIO MARK AT ACCOUNT LEVEL---------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Ab-Initio'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FlgAbinitio = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'update FlgAbinitio MARK at account level';
         /*----UPDATE FLGFITL MARK AT ACCOUNT LEVEL------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'update FlgFITL MARK at account level' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A 
          WHERE ( NVL(A.SplCatg1Alt_Key, 0) = 755
           OR NVL(A.SplCatg2Alt_Key, 0) = 755
           OR NVL(A.SplCatg3Alt_Key, 0) = 755
           OR NVL(A.SplCatg4Alt_Key, 0) = 755 )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.FLGFITL = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'update FlgFITL MARK at account level';
         /*------------------UPDATE OVERDUESINCEDT FROM BILL DETAIL TABLE------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         IF utils.object_id('TEMPDB..tt_BILL_OVERDUE') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BILL_OVERDUE ';
         END IF;
         DELETE FROM tt_BILL_OVERDUE;
         UTILS.IDENTITY_RESET('tt_BILL_OVERDUE');

         INSERT INTO tt_BILL_OVERDUE ( 
         	SELECT AccountEntityID ,
                 BILLENTITYID ,
                 BALANCE ,
                 CASE 
                      WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
                 ELSE BillExtendedDueDt
                    END BILLDUEDT  

         	  ---MIN(BILLDUEDT) BILLDUEDT,MIN(BillExtendedDueDt) BillExtendedDueDt 
         	  FROM RBL_MISDB_PROD.AdvFacBillDetail 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND NVL(BALANCE, 0) > 0
                    AND (CASE 
                              WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
                  ELSE BillExtendedDueDt
                     END) < v_PROCESSINGDATE );
         IF utils.object_id('TEMPDB..tt_BILL_OVERDUE_FINAL') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_BILL_OVERDUE_FINAL ';
         END IF;
         DELETE FROM tt_BILL_OVERDUE_FINAL;
         UTILS.IDENTITY_RESET('tt_BILL_OVERDUE_FINAL');

         INSERT INTO tt_BILL_OVERDUE_FINAL ( 
         	SELECT AccountEntityId ,
                 SUM(BALANCE)  BILOVERDUE  ,
                 MIN(BILLDUEDT)  BILLOVERDUEDT  
         	  FROM tt_BILL_OVERDUE 
         	  GROUP BY AccountEntityId );
         MERGE INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL 
         USING (SELECT PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID row_id, B.BILLOVERDUEDT, B.BILOVERDUE
         FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_BILL_OVERDUE_FINAL B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET OVERDUESINCEDT = src.BILLOVERDUEDT,
                                      OverdueAmt = src.BILOVERDUE;
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
         IF utils.object_id('TEMPDB..tt_PC_OVERDUE') IS NOT NULL THEN
          /* END OF RESTRUCTURE WORK*/
         /* START OF PUI WORK*/
         EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PC_OVERDUE ';
         END IF;
         DELETE FROM tt_PC_OVERDUE;
         UTILS.IDENTITY_RESET('tt_PC_OVERDUE');

         INSERT INTO tt_PC_OVERDUE ( 
         	SELECT AccountEntityID ,
                 PCRefNo ,
                 BALANCE ,
                 CASE 
                      WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                 ELSE PCExtendedDueDt
                    END PCOVERDUEDUEDT  

         	  ---MIN(BILLDUEDT) BILLDUEDT,MIN(BillExtendedDueDt) BillExtendedDueDt 
         	  FROM RBL_MISDB_PROD.AdvFacPCDetail 
         	 WHERE  EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                    AND EFFECTIVETOTIMEKEY >= v_TIMEKEY
                    AND NVL(BALANCE, 0) > 0
                    AND (CASE 
                              WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                  ELSE PCExtendedDueDt
                     END) < v_PROCESSINGDATE );
         IF utils.object_id('TEMPDB..tt_PC_OVERDUE_FINAL') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PC_OVERDUE_FINAL ';
         END IF;
         DELETE FROM tt_PC_OVERDUE_FINAL;
         UTILS.IDENTITY_RESET('tt_PC_OVERDUE_FINAL');

         INSERT INTO tt_PC_OVERDUE_FINAL ( 
         	SELECT AccountEntityId ,
                 SUM(BALANCE)  PCOVERDUE  ,
                 MIN(PCOVERDUEDUEDT)  PCOVERDUEDUEDT  
         	  FROM tt_PC_OVERDUE 
         	  GROUP BY AccountEntityId );
         MERGE INTO PRO_RBL_MISDB_PROD.ACCOUNTCAL 
         USING (SELECT PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID row_id, B.PCOVERDUEDUEDT, B.PCOVERDUE
         FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_PC_OVERDUE_FINAL B   ON A.AccountEntityID = B.AccountEntityId ) src
         ON ( PRO_RBL_MISDB_PROD.ACCOUNTCAL.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET OVERDUESINCEDT = src.PCOVERDUEDUEDT,
                                      OverdueAmt = src.PCOVERDUE;
         --INNER JOIN #TEMPTABLEMINOVERDUEDTPC B ON A.AccountEntityID=B.AccountEntityID AND B.MINOVERDUE < = @PROCESSINGDATE
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE OVERDUESINCEDT FROM BILL DETAIL TABLE';
         /*-----UPDATE COVERGOVGUR BILL AT ACCOUNT LEVEL-------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur BILL AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, C.COVERGOVGUR
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ( SELECT A.AccountEntityID ,
                              SUM(NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0))  COVERGOVGUR  
                       FROM RBL_MISDB_PROD.AdvFacBillDetail A
                              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.ACCOUNTENTITYID = B.AccountEntityID
                        WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                 AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                         GROUP BY A.ACCOUNTENTITYID ) C   ON A.ACCOUNTENTITYID = C.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.COVERGOVGUR = src.COVERGOVGUR;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur BILL AT ACCOUNT LEVEL';
         /*-----UPDATE COVERGOVGUR PC AT ACCOUNT LEVEL-------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur PC AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, C.COVERGOVGUR
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ( SELECT A.AccountEntityID ,
                              SUM(NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0))  COVERGOVGUR  
                       FROM RBL_MISDB_PROD.AdvFacPCDetail A
                              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.ACCOUNTENTITYID = B.AccountEntityID
                        WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                                 AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                         GROUP BY A.ACCOUNTENTITYID ) C   ON A.ACCOUNTENTITYID = C.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.COVERGOVGUR = src.COVERGOVGUR;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur PC AT ACCOUNT LEVEL';
         /*-----UPDATE COVERGOVGUR DL AT ACCOUNT LEVEL-------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur DL AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) AS CoverGovGur
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ADVFACDLDETAIL B   ON A.AccountEntityID = B.ACCOUNTENTITYID 
          WHERE NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) > 0
           AND ( B.EffectiveFromTimeKey <= v_timekey
           AND B.EffectiveToTimeKey >= v_timekey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CoverGovGur = src.CoverGovGur;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur DL AT ACCOUNT LEVEL';
         /*-----UPDATE COVERGOVGUR CC AT ACCOUNT LEVEL-------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE CoverGovGur CC AT ACCOUNT LEVEL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) AS CoverGovGur
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.ADVFACCCDETAIL B   ON A.AccountEntityID = B.ACCOUNTENTITYID 
          WHERE NVL(NVL(CLAIMCOVERAMT, 0) + NVL(CLAIMRECEIVEDAMT, 0), 0) > 0
           AND ( B.EffectiveFromTimeKey <= v_timekey
           AND B.EffectiveToTimeKey >= v_timekey )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.CoverGovGur = src.CoverGovGur;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CoverGovGur CC AT ACCOUNT LEVEL';
         /*---------UPDATE PRVQTRINT,CURQTRINT,CURQTRCREDIT,PREQTRCREDIT-------------*/
         --INSERT INTO PRO.ProcessMonitor(UserID,Description,MODE,StartTime,EndTime,TimeKey,SetID)
         --SELECT ORIGINAL_LOGIN(),'UPDATE PrvQtrInt,CurQtrInt,CurQtrCredit,PreQtrCredit','RUNNING',GETDATE(),NULL,@TIMEKEY,@SetID
         ---Condition Change Required  Modification Done--- 
         /*------------------Update PRVQTRINT,CURQTRINT,CURQTRCREDIT,PREQTRCREDIT------------------*/
         --IF (@PROCESSMONTH = EOMONTH(@PROCESSMONTH))
         --BEGIN
         --EXEC [PRO].[UpdateCADCADURefBalRecovery] @TimeKey=@TimeKey
         --END
         --IF (@PROCESSMONTH <> EOMONTH(@PROCESSMONTH))
         --BEGIN
         --UPDATE a set CurQtrCredit=b.CurQtrCredit,CurQtrInt=b.CurQtrInt
         --from pro.accountcal a
         --inner join pro.accountcal_hist b
         --on a.CustomerAcID=b.CustomerAcID
         --where a.FinalAssetClassAlt_Key>1
         --AND (B.EffectiveFromTimeKey<=@LastMonthDateKey and B.EffectiveToTimeKey>=@LastMonthDateKey)
         --END
         --UPDATE PRO.PROCESSMONITOR SET ENDTIME=GETDATE() ,MODE='COMPLETE' WHERE IdentityKey = (SELECT IDENT_CURRENT('PRO.PROCESSMONITOR')) AND  TIMEKEY=@TIMEKEY AND DESCRIPTION='UPDATE PrvQtrInt,CurQtrInt,CurQtrCredit,PreQtrCredit'
         /*------------------UPDATE INTSERVICESDT IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE INTNOTSERVICEDDT IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'N', utils.dateadd('DAY', -91, v_PROCESSINGDATE) AS pos_3
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                JOIN AdvAcBasicDetail ABD   ON ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'N', NULL
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                JOIN AdvAcBasicDetail ABD   ON ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                AND ABD.EffectiveToTimeKey >= v_TIMEKEY )
                AND ABD.AccountEntityId = A.AccountEntityID 
          WHERE A.FacilityType IN ( 'CC','OD' )

           AND ( utils.dateadd('DAY', 90, A.DebitSinceDt) > v_PROCESSINGDATE
           AND A.DebitSinceDt IS NOT NULL
           AND Asset_Norm <> 'ALWYS_STD' )
           AND C.EffectiveFromTimeKey <= v_timekey
           AND C.EffectiveToTimeKey >= v_timekey

           --AND C.NPANorms='DPD91'
           AND InttServiced = 'N'
           AND ABD.ReferencePeriod = 91) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.InttServiced = 'N',
                                      ABD.INTNOTSERVICEDDT = NULL;
         --UPDATE A SET A.OVERDUEAMT=B.DEMANDAMT
         --            ,A.INTNOTSERVICEDDT=B.DEMANDDATE
         --FROM PRO.ACCOUNTCAL A  INNER JOIN DimProduct C 
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'N', OverdueIntDt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN DimProduct C   ON A.ProductAlt_Key = C.ProductAlt_Key
                JOIN AdvAcBasicDetail ABD   ON ( ABD.EffectiveFromTimeKey <= v_TIMEKEY
                AND ABD.EffectiveToTimeKey >= v_TIMEKEY )
                AND ABD.AccountEntityId = A.AccountEntityID
                JOIN AdvAcBalanceDetail BAL   ON ( BAL.EffectiveFromTimeKey <= v_TIMEKEY
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
                                      ABD.INTNOTSERVICEDDT = OverdueIntDt;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE INTNOTSERVICEDDT IN PRO.ACCOUNTCAL';
         /*------------OVERDUE SINCE DATE IS AVAILABLE BUT OVERDUE AMOUT IS ZERO-----------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'OVERDUE SINCE DATE IS AVAILABLE BUT OVERDUE AMOUT IS ZERO';
         ----/*-----Stock statement date Data Preperation----------------------------------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'Stock statement date Data Preperation' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         IF utils.object_id('Tempdb..tt_Stock') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Stock ';
         END IF;
         DELETE FROM tt_Stock;
         UTILS.IDENTITY_RESET('tt_Stock');

         INSERT INTO tt_Stock ( 
         	SELECT AccountEntityId ,
                 MIN(ValuationDt)  StkSmtDt  ,
                 'S' TYPE  
         	  FROM ( SELECT Advsec.AccountEntityId ,
                          SecurityShortNameEnum ,
                          NVL(MAX(SecDtl.ValuationDate) , '9999-01-01') ValuationDt  
                   FROM RBL_MISDB_PROD.AdvSecurityValueDetail SecDtl
                          JOIN RBL_MISDB_PROD.AdvSecurityDetail Advsec   ON Advsec.SecurityEntityID = SecDtl.SecurityEntityID
                          JOIN DimSecurity sec   ON SecDtl.EffectiveFromTimeKey <= v_TimeKey
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
         ----CREATE CLUSTERED INDEX tt_Stock_IX ON tt_Stock(AccountEntityId)
         ----CREATE NONCLUSTERED INDEX tt_StockNON ON tt_Stock(AccountEntityId,StkSmtDt)
         ----IF OBJECT_ID('Tempdb..tt_Stock2') IS NOT NULL
         ----DROP TABLE tt_Stock2
         ----SELECT  AccountEntityId,MIN(ValuationDt) StkSmtDt,'W' TYPE
         ----INTO tt_Stock2
         ----FROM(SELECT SecDtl.AccountEntityId ,SecurityShortNameEnum,ISNULL(MAX(SecDtl.ValuationDt),'9999-01-01') ValuationDt 
         ----            FROM dbo.ADvSecurityValueDetail SecDtl
         ----            INNER  JOIN DimSecurity sec ON SecDtl.EffectiveFromTimeKey < = @TimeKey
         ----                                          AND SecDtl.EffectiveToTimeKey   >= @TimeKey
         ----						                  AND Sec.EffectiveFromTimeKey < = @TimeKey
         ----                                          AND Sec.EffectiveToTimeKey > = @TimeKey
         ----										  AND SecDtl.SecurityAlt_Key = Sec.SecurityAlt_Key
         ----			WHERE SecurityShortNameEnum IN('PLD- WAREC-GEN','PLD- WAREC-NBHC','PLD- WAREC-NCMSL','PLD- WAREC-CWC','CARNC','CSRNC','WHRDMAT'
         ----										  ,'WHRMSW','WHRNG','WHRSACML','WHRSSL')
         ----			AND  SecDtl.SecurityType='P' 
         ----			GROUP BY SecDtl.AccountEntityId,SecurityShortNameEnum) ST
         ----			GROUP BY AccountEntityId
         ----CREATE CLUSTERED INDEX tt_Stock2_IX ON tt_Stock2(AccountEntityId)
         ----CREATE NONCLUSTERED INDEX tt_Stock2NON ON tt_Stock2(AccountEntityId,StkSmtDt)
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'STOCK STATEMENT DATE DATA PREPERATION';
         /*-----UPDATE STOCK STATEMENT DATE IN PRO.ACCOUNTCAL----------------------------------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         --INNER  JOIN tt_Stock SD ON A.AccountEntityId=SD.AccountEntityId
         --where A.FacilityType='CC'
         /* Added by amar on 17062021 for  get the stock  */
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, StockStmtDt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ADVFACCCDETAIL SD   ON A.AccountEntityID = SD.AccountEntityId 
          WHERE A.FacilityType = 'CC'
           AND SD.EffectiveFromTimeKey <= v_TimeKey
           AND SD.EffectiveToTimeKey >= v_TimeKey) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.StockStDt = StockStmtDt;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'update stock statement date in pro.accountcal';
         /*------UPDATE DerecognisedInterest1 AMT IN PRO.ACCOUNTCAL---------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE DerecognisedInterest1 AMT IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         IF utils.object_id('TEMPDB..tt_TEMPDerecognisedInterest') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPDerecognisedInterest ';
         END IF;
         DELETE FROM tt_TEMPDerecognisedInterest;
         INSERT INTO tt_TEMPDerecognisedInterest
           ( AccountEntityId, DerecognisedInterest1 )
           ( SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM RBL_MISDB_PROD.AdvFacBillDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION 
             SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM RBL_MISDB_PROD.AdvFacPCDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION ALL 
             SELECT B.ACCOUNTENTITYID ,
                    SUM(NVL(B.DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM RBL_MISDB_PROD.ADVFACCCDETAIL B
              WHERE  ( B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY B.ACCOUNTENTITYID
             UNION ALL 
             SELECT C.ACCOUNTENTITYID ,
                    SUM(NVL(C.DerecognisedInterest1, 0))  DerecognisedInterest1  
             FROM RBL_MISDB_PROD.ADVFACDLDETAIL C
              WHERE  ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest1, 0) > 0
               GROUP BY C.ACCOUNTENTITYID );
         /*-----UPDATE DerecognisedInterest1 IN PRO.ACCOUNTCAL TABLE ----------------------------*/
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.DerecognisedInterest1
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_TEMPDerecognisedInterest B   ON A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DerecognisedInterest1 = src.DerecognisedInterest1;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE DerecognisedInterest1 AMT IN PRO.ACCOUNTCAL';
         /*------UPDATE DerecognisedInterest2 AMT IN PRO.ACCOUNTCAL---------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE DerecognisedInterest2 AMT IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         IF utils.object_id('TEMPDB..tt_TEMPDerecognisedInterest_2') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPDerecognisedInterest_2 ';
         END IF;
         DELETE FROM tt_TEMPDerecognisedInterest_2;
         INSERT INTO tt_TEMPDerecognisedInterest_2
           ( AccountEntityId, DerecognisedInterest2 )
           ( SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM RBL_MISDB_PROD.AdvFacBillDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION 
             SELECT A.ACCOUNTENTITYID ,
                    SUM(NVL(DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM RBL_MISDB_PROD.AdvFacPCDetail A
              WHERE  ( A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY A.ACCOUNTENTITYID
             UNION ALL 
             SELECT B.ACCOUNTENTITYID ,
                    SUM(NVL(B.DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM RBL_MISDB_PROD.ADVFACCCDETAIL B
              WHERE  ( B.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND B.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY B.ACCOUNTENTITYID
             UNION ALL 
             SELECT C.ACCOUNTENTITYID ,
                    SUM(NVL(C.DerecognisedInterest2, 0))  DerecognisedInterest2  
             FROM RBL_MISDB_PROD.ADVFACDLDETAIL C
              WHERE  ( C.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
                       AND C.EFFECTIVETOTIMEKEY >= v_TIMEKEY )
                       AND NVL(DerecognisedInterest2, 0) > 0
               GROUP BY C.ACCOUNTENTITYID );
         /*-----UPDATE DerecognisedInterest2 IN PRO.ACCOUNTCAL TABLE ----------------------------*/
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.DerecognisedInterest2
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_TEMPDerecognisedInterest_2 B   ON A.AccountEntityID = B.ACCOUNTENTITYID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.DerecognisedInterest2 = src.DerecognisedInterest2;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE DerecognisedInterest2 AMT IN PRO.ACCOUNTCAL';
         /*-------------UPDATE GovGurAmt FROM ADVACOTHERDETAIL-------------------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( UserID, DESCRIPTION, MODE_, StartTime, EndTime, TimeKey, SetID )
           ( SELECT USER ,
                    'UPDATE GovGurAmt FROM ADVACOTHERDETAIL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SetID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NVL(B.GovGurAmt, 0) AS GovtGtyAmt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN RBL_MISDB_PROD.AdvAcOtherDetail B   ON A.AccountEntityID = B.AccountEntityId
                AND ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY ) 
          WHERE NVL(B.GovGurAmt, 0) > 0) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.GovtGtyAmt = src.GovtGtyAmt;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE GovGurAmt FROM ADVACOTHERDETAIL';
         /*-------------UPDATE UnserviedInt FROM AdvAcFinancialDetail-------------------------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         --inner join DBO.ADVACBALANCEDETAIL  B on (B.EffectiveFromTimeKey<=@TIMEKEY AND B.EffectiveToTimeKey>=@TIMEKEY )
         --and a.AccountEntityID=B.AccountEntityId  
         --WHERE B.UnAppliedIntAmount>0
         */
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE UnserviedInt FROM AdvAcFinancialDetail';
         /*------------------UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 870, 6, CASE 
         WHEN StatusDate IS NULL THEN v_PROCESSINGDATE
         ELSE StatusDate
            END AS pos_5, 'NPA DUE TO FRAUD MARKING' AS pos_6
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Fraud Committed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.SplCatg4Alt_Key = 870,
                                      A.FinalAssetClassAlt_Key = 6,
                                      A.FinalNpaDt = pos_5,
                                      A.NPA_Reason = pos_6;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE FRAUD ACCOUNT MARKING  IN PRO.ACCOUNTCAL';
         /*------------------UPDATE FRAUD ACCOUNT MARKING  IN PRO.CustomerCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE FRAUD ACCOUNT MARKING  IN PRO.CustomerCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO C 
         USING (SELECT C.ROWID row_id, 'ALWYS_NPA', 870, 6, CASE 
         WHEN StatusDate IS NULL THEN v_PROCESSINGDATE
         ELSE StatusDate
            END AS pos_5, 'NPA DUE TO FRAUD MARKING' AS pos_6
         FROM C ,PRO_RBL_MISDB_PROD.CUSTOMERCAL c
                JOIN ExceptionFinalStatusType b   ON c.RefCustomerID = b.CustomerID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Fraud Committed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( C.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET C.Asset_Norm = 'ALWYS_NPA',
                                      C.SplCatg4Alt_Key = 870,
                                      C.SYSASSETCLASSALT_KEY = 6,
                                      C.SYSNPA_DT = pos_5,
                                      C.DEGREASON = pos_6;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE FRAUD ACCOUNT MARKING  IN PRO.CustomerCal';
         /*------------------UPDATE IBPC MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE IBPC MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN IBPCFinalPoolDetail b   ON a.CustomerAcID = b.ACCOUNTID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsIBPC = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE IBPC MARKING  IN PRO.AccountCal';
         /*------------------UPDATE Securitised MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Securitised MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN SecuritizedFinalACDetail b   ON a.CustomerAcID = b.ACCOUNTID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsSecuritised = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Securitised MARKING  IN PRO.AccountCal';
         /*------------------UPDATE PUI MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE PUI MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN AdvAcPUIDetailMain b   ON a.CustomerAcID = b.ACCOUNTID 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.PUI = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE PUI MARKING  IN PRO.AccountCal';
         /*------------------UPDATE RFA MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE RFA MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'RFA'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RFA = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE RFA MARKING  IN PRO.AccountCal';
         /*------------------UPDATE NonCooperative MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE NonCooperative MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Non-cooperative'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.IsNonCooperative = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE NonCooperative MARKING  IN PRO.AccountCal';
         /*------------------UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Repossesed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RePossession = 'Y';
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN REPOSSESSIONDATE IS NULL THEN v_PROCESSINGDATE
         ELSE REPOSSESSIONDATE
            END AS pos_4, 'NPA DUE TO Repossessed Account' AS pos_5, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO Repossessed Account' AS pos_3, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Repossesed'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.NPA_Reason = pos_3,
                                      A.RePossession = 'Y';
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
         FROM a ,PRO_RBL_MISDB_PROD.CUSTOMERCAL a
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
          WHERE b.RePossession = 'Y') src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      a.SysNPA_Dt = src.FinalNpaDt,
                                      a.DegReason = src.NPA_Reason,
                                      a.Asset_Norm = src.Asset_Norm;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Repossessed ACCOUNT MARKING  IN PRO.ACCOUNTCAL';
         /*------------------UPDATE Inherent Weakness  ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Inherent Weakness ACCOUNT MARKING  IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
         ELSE FinalNpaDt
            END AS pos_4, 'NPA DUE TO Inherent Weakness Account' AS pos_5, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO Inherent Weakness Account' AS pos_3, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'Inherent Weakness'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.NPA_Reason = pos_3,
                                      A.WeakAccount = 'Y';
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
         FROM a ,PRO_RBL_MISDB_PROD.CUSTOMERCAL a
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
          WHERE b.WeakAccount = 'Y') src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      a.SysNPA_Dt = src.FinalNpaDt,
                                      a.DegReason = src.NPA_Reason,
                                      a.Asset_Norm = src.Asset_Norm;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Inherent Weakness ACCOUNT MARKING  IN PRO.ACCOUNTCAL';
         /*------------------UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'SARFAESI'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Sarfaesi = 'Y';
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 2, CASE 
         WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
         ELSE FinalNpaDt
            END AS pos_4, 'NPA DUE TO SARFAESI  Account' AS pos_5
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 'NPA DUE TO Sarfaesi Account' AS pos_3, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'SARFAESI'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )
           AND FinalAssetClassAlt_Key > 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'ALWYS_NPA',
                                      A.NPA_Reason = pos_3,
                                      A.Sarfaesi = 'Y';
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, b.FinalAssetClassAlt_Key, b.FinalNpaDt, b.NPA_Reason, b.Asset_Norm
         FROM a ,PRO_RBL_MISDB_PROD.CUSTOMERCAL a
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL b   ON a.CustomerEntityID = b.CustomerEntityID 
          WHERE b.Sarfaesi = 'Y') src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET a.SysAssetClassAlt_Key = src.FinalAssetClassAlt_Key,
                                      a.SysNPA_Dt = src.FinalNpaDt,
                                      a.DegReason = src.NPA_Reason,
                                      a.Asset_Norm = src.Asset_Norm;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE SARFAESI ACCOUNT MARKING IN PRO.ACCOUNTCAL';
         /*------------------UPDATE RC-Pending MARKING  IN PRO.AccountCal------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE RC-Pending MARKING  IN PRO.AccountCal' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'Y'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ExceptionFinalStatusType b   ON a.CustomerAcID = b.acid 
          WHERE ( B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY )
           AND b.StatusType = ( SELECT ParameterShortNameEnum 
                                FROM dimparameter 
                                 WHERE  DimParameterName = 'UploadFLagType'
                                          AND ParameterShortNameEnum = 'RC Pending'
                                          AND EffectiveFromTimeKey <= v_TIMEKEY
                                          AND EffectiveToTimeKey >= v_TIMEKEY )) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.RCPending = 'Y';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE RC-Pending MARKING  IN PRO.AccountCal';
         /*------------------UPDATE Written-Off Accounts ACCOUNT MARKING  IN PRO.ACCOUNTCAL------------------*/
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
           ( USERID, DESCRIPTION, MODE_, STARTTIME, ENDTIME, TIMEKEY, SETID )
           ( SELECT USER ,
                    'UPDATE Written-Off Accounts MARKING IN PRO.ACCOUNTCAL' ,
                    'RUNNING' ,
                    SYSDATE ,
                    NULL ,
                    v_TIMEKEY ,
                    v_SETID 
               FROM DUAL  );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA', 860, 2, CASE 
         WHEN FinalNpaDt IS NULL THEN v_PROCESSINGDATE
         ELSE FinalNpaDt
            END AS pos_5, 'NPA DUE TO Written-Off Account' AS pos_6
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN AdvAcOtherDetail B   ON A.AccountEntityID = B.AccountEntityID
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
         MERGE INTO B 
         USING (SELECT B.ROWID row_id, 'ALWYS_NPA'
         FROM B ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL B   ON A.UcifEntityID = B.UcifEntityID 
          WHERE A.Asset_Norm = 'ALWYS_NPA'
           AND B.UcifEntityID > 0) src
         ON ( B.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.Asset_Norm = 'ALWYS_NPA';
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Written-Off Accounts MARKING IN PRO.ACCOUNTCAL';
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         ------UPDATE A SET A.Asset_Norm=(CASE WHEN A.Balance-ISNULL(e.CurrentValue,0) <=0 THEN 'ALWYS_STD'ELSE 'CONDI_STD' END)
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'CONDI_STD'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN ( SELECT C.AccountEntityID ,
                              SUM(NVL(CurrentValue, 0))  CurrentValue  
                       FROM RBL_MISDB_PROD.AdvSecurityValueDetail B
                              JOIN RBL_MISDB_PROD.AdvSecurityDetail Advsec   ON Advsec.SecurityEntityID = b.SecurityEntityID
                              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL C   ON Advsec.AccountEntityID = C.AccountEntityID
                              AND Advsec.SecurityAlt_Key = Advsec.SecurityAlt_Key
                              AND Advsec.EffectiveFromTimeKey <= v_TimeKey
                              AND Advsec.EffectiveToTimeKey >= v_TimeKey
                              JOIN DimSecurity D   ON D.EffectiveFromTimeKey <= v_TIMEKEY
                              AND D.EffectiveToTimeKey >= v_TIMEKEY
                              AND D.SecurityAlt_Key = Advsec.SecurityAlt_Key
                        WHERE  Advsec.SecurityType = 'P'

                                 --AND ISNULL(D.SecurityShortNameEnum,'') IN('PLD-NSC','PLD-KVP','PLD-G SEC','ASGN-LIFE POL','LI-FDR','LI-FDRSUBSI','LI-NRE DEP'

                                 --    ,'LI-NRNR DEP','LI-FCNR-DEP','LI-RD-DEP','DEPNFBR')	
                                 AND D.SecurityCRM = 'Y'

                       --		and ISNULL(C.Asset_Norm,'NORMAL')='CONDI_STD'		
                       GROUP BY C.AccountEntityID ) E   ON A.AccountEntityID = E.AccountEntityID
                AND NVL(A.Balance, 0) > 0
                AND NVL(A.Balance, 0) > NVL(A.SecurityValue, 0) ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = 'CONDI_STD';
         ---Condition Change Required  Modification Done---  
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, ContinousExcessSecDt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.ContinousExcessSecDtAccountCal B   ON A.CustomerAcID = B.CustomerAcID 
          WHERE B.EffectiveFromTimeKey <= v_TIMEKEY
           AND B.EffectiveToTimeKey >= v_TIMEKEY) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.ContiExcessDt = ContinousExcessSecDt;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IDENTITYKEY = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE CONDI_STD IN PRO.AccountCal';
         --   /*------------********UPDATE Last Credit Date******--------------------*/ 
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, B.LastCrDate
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.LastCreditDtAccountCal B   ON ( B.EffectiveFromTimeKey <= v_TIMEKEY
                AND B.EffectiveToTimeKey >= v_TIMEKEY )
                AND A.CustomerAcID = B.CustomerAcID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.LastCrDate = src.LastCrDate;
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE Last Credit Date';
         /*---------UPDATE AddlProvisionAmount  AT Account level--------------------- */
         INSERT INTO PRO_RBL_MISDB_PROD.ProcessMonitor
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
         UPDATE PRO_RBL_MISDB_PROD.ProcessMonitor
            SET ENDTIME = SYSDATE,
                MODE_ = 'COMPLETE'
          WHERE  IdentityKey = ( SELECT /*TODO:SQLDEV*/ IDENT_CURRENT('PRO.PROCESSMONITOR') /*END:SQLDEV*/ 
                                   FROM DUAL  )
           AND TIMEKEY = v_TIMEKEY
           AND DESCRIPTION = 'UPDATE AddlProvisionAmount  AT Account level';
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_NPA',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
         --       FROM PRO.CUSTOMERCAL A
         -- INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         --     INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --           DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
         --FROM PRO.CUSTOMERCAL A
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         --    INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=NULL,A.DBTDT =NULL,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_STD',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
         -- FROM PRO.CUSTOMERCAL A
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         --  INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME='STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999
         --UPDATE A SET A.SYSASSETCLASSALT_KEY=DA.ASSETCLASSALT_KEY,A.SYSNPA_DT=NULL,A.DBTDT =NULL,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED,A.MOCTYPE=B.MOCTYPE
         -- FROM PRO.CUSTOMERCAL A
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         -- INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME='STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=B.NPADATE,A.FlgMoc='Y',A.ASSET_NORM='ALWYS_NPA',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED
         --       FROM PRO.ACCOUNTCAL A
         -- INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         --     INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=B.NPADATE,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='NPA DUE TO MOC',A.MOC_DT=B.DATECREATED
         --FROM PRO.ACCOUNTCAL A
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         --    INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME<>'STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=NULL,A.FLGMOC='Y',A.ASSET_NORM='ALWYS_STD',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED
         -- FROM PRO.ACCOUNTCAL A
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         --  INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME='STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='MANUAL' AND B.EFFECTIVETOTIMEKEY=49999
         --UPDATE A SET A.FinalAssetClassAlt_Key=DA.ASSETCLASSALT_KEY,A.FinalNpaDt=NULL,A.FLGMOC='Y',A.ASSET_NORM='NORMAL',A.MOCREASON=B.MOCREASON,DEGREASON='STD DUE TO MOC',A.MOC_DT=B.DATECREATED
         -- FROM PRO.ACCOUNTCAL A
         --INNER JOIN DATAUPLOAD.MocCustomerDailyDataUpload B ON A.REFCUSTOMERID=B.CUSTOMERID
         -- INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSSHORTNAME= B.ASSETCLASSIFICATION AND
         --                           DA.ASSETCLASSSHORTNAME='STD' AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE B.MOCTYPE='AUTO' AND  B.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND  B.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --UPDATE  A SET DBTDT=@PROCESSINGDATE FROM PRO.CUSTOMERCAL A  
         --INNER JOIN DIMASSETCLASS DA       ON  DA.ASSETCLASSALT_KEY= A.SYSASSETCLASSALT_KEY AND
         --                           DA.ASSETCLASSSHORTNAME IN ('DB1','DB2','DB3') AND  
         --                           DA.EFFECTIVEFROMTIMEKEY<=@TIMEKEY AND
         --                   DA.EFFECTIVETOTIMEKEY>=@TIMEKEY
         --WHERE DBTDT IS NULL
         ------update a
         ------set a.InitialNpaDt =b.FinalNpaDt
         ------	,A.InitialAssetClassAlt_Key =B.FinalAssetClassAlt_Key
         ------from PRO.ACCOUNTCAL A 
         ------INNER JOIN PRO.AccountCal_Hist B
         ------	ON A.AccountEntityID =B.AccountEntityID
         ------WHERE B.EffectiveFromTimeKey<=26123 AND B.EffectiveToTimeKey>=26123
         ------AND A.FinalAssetClassAlt_Key>1
         ------AND (A.InitialAssetClassAlt_Key<>B.FinalAssetClassAlt_Key)
         --UPDATE DATAUPLOAD.MocCustomerDailyDataUpload SET EFFECTIVETOTIMEKEY=EFFECTIVEFROMTIMEKEY WHERE MOCTYPE='AUTO'
         /* ADDED ON 04072021 AS PER DISCUSSIONS WITH BANK ON 03072021 FOR UPGRADE some ACCOUNT AS PER LIST PROVIDED BY BANK TEAM*/
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_STD'
         ---INITIALASSETCLASSALT_KEY=1
          --,INITIALNPADT=NULL
         , NULL, 1, 1, 'N', 'N', ' ' AS pos_8, NULL
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN Manual_Upgrade B   ON A.CustomerAcID = B.Account_No 
          WHERE VALID_UPTO >= v_ProcessingDate
           AND Account_No NOT IN ( SELECT Account_No 
                                   FROM Manual_NPA  )
         ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET ASSET_NORM = 'ALWYS_STD',
                                      FINALNPADT = NULL,
                                      FINALASSETCLASSALT_KEY = 1,
                                      PrvAssetClassAlt_Key = 1,
                                      flgdeg = 'N',
                                      FlgUpg = 'N',
                                      NPA_Reason = pos_8,
                                      DegReason = NULL;
         /* ADDED ON 04072021 AS PER DISCUSSIONS WITH BANK ON 03072021 FOR UPGRADE some ACCOUNT AS PER LIST PROVIDED BY BANK TEAM*/
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN Manual_NPA B   ON A.CustomerAcID = B.Account_No 
          WHERE VALID_UPTO >= v_ProcessingDate) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET B.ASSET_NORM = 'ALWYS_NPA';
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
         ----		ASSET_NORM='ALWYS_NPA'
         ----		,A.InitialAssetClassAlt_Key =ISNULL(C.FinalAssetClassAlt_Key,A.InitialAssetClassAlt_Key)
         ----		,A.InitialNpaDt=ISNULL(C.FinalNpaDt,A.InitialNpaDt)
         ---- FROM PRO.ACCOUNTCAL A 
         ----	INNER JOIN Manual_NPA B
         ----	ON A.CustomerAcID=B.[Account No]
         ----	 LEFT join pro.AccountCal_Hist  c
         ----		on c.AccountEntityID=a.AccountEntityID
         ----		AND (C.EFFECTIVEFROMTIMEKEY<=@HistTimeKey	AND C.EFFECTIVETOTIMEKEY>=@HistTimeKey)
         ----WHERE VALID_UPTO>=@ProcessingDate
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NULL
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A 
          WHERE InitialAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET InitialNpaDt = NULL;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NULL
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A 
          WHERE FinalAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET FinalNpaDt = NULL;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NULL
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A 
          WHERE SrcAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SrcNPA_Dt = NULL;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NULL
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A 
          WHERE SysAssetClassAlt_Key = 1) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SysNPA_Dt = NULL;
         --update a
         --set a.InitialNpaDt =b.FinalNpaDt
         --from PRO.ACCOUNTCAL A 
         --INNER JOIN PRO.AccountCal_Hist B
         --	ON A.AccountEntityID =B.AccountEntityID
         --WHERE A.INITIALASSETCLASSALT_KEY>1
         --AND A.InitialNpaDt  is NULL 
         --AND B.EffectiveFromTimeKey<=@HistTimeKey AND B.EffectiveToTimeKey>=@HistTimeKey
         ----/*  UPDATE MOC STATUS  */
         ----	DECLARE @PrevMonthTimeKey INT=(SELECT LastMonthDateKey FROM SysDayMatrix WHERE TimeKey =@TIMEKEY)
         ----	DROP TABLE IF EXISTS tt_MOC_DATA
         ----	SELECT UcifEntityID,MAX(SysAssetClassAlt_Key) SysAssetClassAlt_Key,MIN(SysNPA_Dt) SysNPA_Dt  
         ----		INTO tt_MOC_DATA
         ----	FROM PRO.CustomerCal_Hist 
         ----	WHERE EffectiveFromTimeKey<=@PrevMonthTimeKey AND EffectiveToTimeKey >=@PrevMonthTimeKey
         ----	AND LTRIM(RTRIM(MOCTYPE))='Manual'
         ----	GROUP BY UcifEntityID
         ----	UPDATE A
         ----		SET A.Asset_Norm=CASE WHEN B.SysAssetClassAlt_Key=1 THEN 'ALWYS_STD'
         ----							 ELSE 'ALWYS_NPA' END
         ----			,MOCTYPE='Manual'
         ----			,SysAssetClassAlt_Key=B.SysAssetClassAlt_Key
         ----			,SrcAssetClassAlt_Key=B.SysAssetClassAlt_Key
         ----			,SysNPA_Dt=B.SysNPA_Dt
         ----			,SrcNPA_Dt=b.SysNPA_Dt
         ----	FROM pro.CustomerCal A
         ----		INNER JOIN tt_MOC_DATA  B
         ----			ON A.UcifEntityID=B.UcifEntityID
         ----	UPDATE A
         ----		SET A.Asset_Norm=CASE WHEN B.SysAssetClassAlt_Key=1 THEN 'ALWYS_STD'
         ----							 ELSE 'ALWYS_NPA' END
         ----			,MOCTYPE='Manual'
         ----			,FinalAssetClassAlt_Key=B.SysAssetClassAlt_Key
         ----			,InitialAssetClassAlt_Key=b.SysAssetClassAlt_Key
         ----			,InitialNpaDt=B.SysNPA_Dt
         ----			,FinalNpaDt=b.SysNPA_Dt
         ----	FROM pro.ACCOUNTCAL A
         ----		INNER JOIN tt_MOC_DATA  B
         ----			ON A.UcifEntityID=B.UcifEntityID
         /*RESTRUCTURE UPDATES */
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET Completed = 'Y'
          WHERE  ID IN ( 12,13 )
         ;
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.AdvAcRestructureCal ';
         ------------------------Insert Data for Base Columns 
         INSERT INTO PRO_RBL_MISDB_PROD.AdvAcRestructureCal
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
             FROM AdvAcRestructureDetail A
                    JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
              WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                       AND A.EffectiveToTimeKey >= v_Timekey );
         ----------------Update Total OS, Total POS,CrntQtrAssetClass----------------
         --Select * 
         MERGE INTO A 
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
         FROM A ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A
                JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.AccountEntityId = B.AccountEntityID
                LEFT JOIN DimProvision_SegStd SP   ON SP.EffectiveFromTimeKey <= v_TimeKey
                AND SP.EffectiveFromTimeKey >= v_TimeKey
                AND SP.ProvisionAlt_Key = B.ProvisionAlt_Key
                LEFT JOIN DimProvision_Seg NP   ON NP.EffectiveFromTimeKey <= v_TimeKey
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
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN (NVL(RestructurePOS, 0)) > 0 THEN CASE 
                                                     WHEN ((NVL(RestructurePOS, 0) - NVL(A.CurrentPOS, 0.00)) * 100) / (NVL(RestructurePOS, 0)) > 100
                                                       OR ((NVL(RestructurePOS, 0) - NVL(A.CurrentPOS, 0.00)) * 100) / (NVL(RestructurePOS, 0)) < 0 THEN 0
         ELSE UTILS.CONVERT_TO_NUMBER(utils.round_(((NVL(RestructurePOS, 0) - NVL(A.CurrentPOS, 0.00)) * 100) / (NVL(RestructurePOS, 0)), 2),5,2)
            END
         ELSE 0
            END AS Res_POS_to_CurrentPOS_Per
         FROM A ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Res_POS_to_CurrentPOS_Per -----CAST( (CAST((cast((ISNULL(a.RestructurePOS,0.00)-ISNULL(B.PrincOutStd,0.00)) as decimal(22,2))	 /ISNULL(A.RestructurePOS,1)) AS DECIMAL(20,2)))*100 AS DECIMAL(5,2))
                                       = src.Res_POS_to_CurrentPOS_Per;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, utils.dateadd('YY', 1, RestructureDt) AS SP_ExpiryDate
         FROM A ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A 
          WHERE SP_ExpiryDate IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryDate = src.SP_ExpiryDate;
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, CASE 
         WHEN NVL(Res_POS_to_CurrentPOS_Per, 0) < 0 THEN 0
         ELSE Res_POS_to_CurrentPOS_Per
            END AS Res_POS_to_CurrentPOS_Per
         FROM a ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A ) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Res_POS_to_CurrentPOS_Per = src.Res_POS_to_CurrentPOS_Per;
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, v_ProcessingDate
         FROM a ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A 
          WHERE POS_10PerPaidDate IS NULL
           AND NVL(Res_POS_to_CurrentPOS_Per, 0) >= 10) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.POS_10PerPaidDate = v_ProcessingDate;
         MERGE INTO a 
         USING (SELECT a.ROWID row_id, CASE 
         WHEN A.POS_10PerPaidDate > SP_ExpiryDate THEN A.POS_10PerPaidDate
         ELSE SP_ExpiryDate
            END AS SP_ExpiryDate
         FROM a ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A
                JOIN ADVACRESTRUCTUREDETAIL b   ON a.AccountEntityId = b.AccountEntityId
                AND ( b.EffectiveFromTimeKey <= v_TIMEKEY
                AND b.EffectiveToTimeKey >= v_TIMEKEY )
                JOIN DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = B.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring'
                AND D.ParameterShortNameEnum = 'PRUDENTIAL' 
          WHERE A.POS_10PerPaidDate IS NOT NULL) src
         ON ( a.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryDate = src.SP_ExpiryDate;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, utils.dateadd('YY', 1, ZeroDPD_Date) AS SP_ExpiryExtendedDate
         FROM A ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A 
          WHERE ZeroDPD_Date IS NOT NULL
           AND SP_ExpiryExtendedDate IS NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryExtendedDate = src.SP_ExpiryExtendedDate;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, NULL
         FROM A ,PRO_RBL_MISDB_PROD.AdvAcRestructureCal A 
          WHERE SP_ExpiryDate > SP_ExpiryExtendedDate) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.SP_ExpiryExtendedDate = NULL;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, 'ALWYS_NPA'
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal B   ON A.AccountEntityID = B.AccountEntityId
                JOIN DimParameter D   ON D.EffectiveFromTimeKey <= v_timekey
                AND D.EffectiveToTimeKey >= v_timekey
                AND D.ParameterAlt_Key = B.RestructureTypeAlt_Key
                AND D.DimParameterName = 'TypeofRestructuring' 
          WHERE D.ParameterShortNameEnum = 'PRUDENTIAL'
           AND B.DPD_Breach_Date IS NOT NULL) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET D.ASSET_NORM = 'ALWYS_NPA';
         EXECUTE IMMEDIATE ' TRUNCATE TABLE PRO_RBL_MISDB_PROD.PUI_CAL ';
         INSERT INTO PRO_RBL_MISDB_PROD.PUI_CAL
           ( CustomerEntityID, AccountEntityId, ProjectCategoryAlt_Key, ProjectSubCategoryAlt_key, DelayReasonChangeinOwnership, ProjectAuthorityAlt_key, OriginalDCCO, OriginalProjectCost, OriginalDebt, Debt_EquityRatio, ChangeinProjectScope, FreshOriginalDCCO, RevisedDCCO, CourtCaseArbitration, CIOReferenceDate, CIODCCO, TakeOutFinance, AssetClassSellerBookAlt_key, NPADateSellerBook, Restructuring, InitialExtension, BeyonControlofPromoters, DelayReasonOther, FLG_UPG, FLG_DEG, DEFAULT_REASON, ProjCategory, NPA_DATE, PUI_ProvPer, RestructureDate, ActualDCCO, ActualDCCO_Date, UpgradeDate, FinalAssetClassAlt_Key, DPD_Max, EffectiveFromTimeKey, EffectiveToTimeKey, CostOverRunPer, ProjectOwnerShipAlt_Key )
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
                    UTILS.CONVERT_TO_NUMBER((UTILS.CONVERT_TO_NUMBER((UTILS.CONVERT_TO_NUMBER((NVL(c.RevisedProjectCost, 0.00) - NVL(B.OriginalProjectCost, 0.00)),22,2) / NVL(B.OriginalProjectCost, 1)),20,2)) * 100,5,2) CostOverRunPer  ,
                    ProjectOwnerShipAlt_Key 
             FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                    JOIN RBL_MISDB_PROD.AdvAcPUIDetailMain B   ON A.AccountEntityID = B.AccountEntityId
                    AND ( b.EffectiveFromTimeKey <= v_TimeKey
                    AND b.EffectiveToTimeKey >= v_TimeKey )
                    JOIN RBL_MISDB_PROD.AdvAcPUIDetailSub c   ON A.AccountEntityID = c.AccountEntityID
                    AND ( c.EffectiveFromTimeKey <= v_TimeKey
                    AND c.EffectiveToTimeKey >= v_TimeKey )
                    JOIN DimParameter D   ON ParameterAlt_Key = b.ProjectCategoryAlt_Key
                    AND ( D.EffectiveFromTimeKey <= v_TimeKey
                    AND D.EffectiveToTimeKey >= v_TimeKey )
                    AND DimParameterName = 'ProjectCategory' );
         UPDATE PRO_RBL_MISDB_PROD.PUI_CAL
            SET CostOverRunPer = 0
          WHERE  CostOverRunPer < 0;
         UPDATE PRO_RBL_MISDB_PROD.PUI_CAL
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
         /* AMAR - 20092021 - CHNAGES FOR MOC ACL MANUAL EFFECT IN NORMAL PROCESSING */
         IF  --SQLDEV: NOT RECOGNIZED
         IF tt_MOC_DATA  --SQLDEV: NOT RECOGNIZED
         DELETE FROM tt_MOC_DATA;
         UTILS.IDENTITY_RESET('tt_MOC_DATA');

         INSERT INTO tt_MOC_DATA ( 
         	SELECT UcifEntityID ,
                 MAX(AssetClassAlt_Key)  SysAssetClassAlt_Key  ,
                 MIN(Npa_date)  SysNPA_Dt  
         	  FROM MOC_ChangeDetails A
                   JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = b.CustomerEntityID
         	 WHERE  A.EffectiveFromTimeKey <= v_TIMEKEY
                    AND a.EffectiveToTimeKey >= v_TIMEKEY
                    AND MOC_ExpireDate >= v_ProcessingDate
                    AND MOCType_Flag = 'CUST'
                    AND NVL(AssetClassAlt_Key, 0) > 0
         	  GROUP BY UcifEntityID );
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.SysAssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE 'ALWYS_NPA'
            END AS pos_2, 'Manual', B.SysAssetClassAlt_Key, B.SysNPA_Dt
         FROM A ,PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                JOIN tt_MOC_DATA B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = pos_2,
                                      A.MOCTYPE = 'Manual',
                                      A.SysAssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                      A.SysNPA_Dt = src.SysNPA_Dt;
         MERGE INTO A 
         USING (SELECT A.ROWID row_id, CASE 
         WHEN B.SysAssetClassAlt_Key = 1 THEN 'ALWYS_STD'
         ELSE 'ALWYS_NPA'
            END AS pos_2, 'Manual', B.SysAssetClassAlt_Key, b.SysNPA_Dt
         FROM A ,PRO_RBL_MISDB_PROD.ACCOUNTCAL A
                JOIN tt_MOC_DATA B   ON A.UcifEntityID = B.UcifEntityID ) src
         ON ( A.ROWID = src.row_id )
         WHEN MATCHED THEN UPDATE SET A.Asset_Norm = pos_2,
                                      MOCTYPE = 'Manual',
                                      FinalAssetClassAlt_Key = src.SysAssetClassAlt_Key,
                                      FinalNpaDt = src.SysNPA_Dt;
         UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
            SET COMPLETED = 'Y',
                ERRORDATE = NULL,
                ERRORDESCRIPTION = NULL,
                COUNT = NVL(COUNT, 0) + 1
          WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      UPDATE PRO_RBL_MISDB_PROD.AclRunningProcessStatus
         SET COMPLETED = 'N',
             ERRORDATE = SYSDATE,
             ERRORDESCRIPTION = SQLERRM,
             COUNT = NVL(COUNT, 0) + 1
       WHERE  RUNNINGPROCESSNAME = 'InsertDataforAssetClassficationRBL';

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_MISDB_PROD";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "RBL_TEMPDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "MAIN_PRO"."INSERTDATAFORASSETCLASSFICATIONRBL_RESTR" TO "ADF_CDR_RBL_STGDB";
