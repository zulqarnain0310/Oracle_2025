--------------------------------------------------------
--  DDL for Table GTT_ACCOUNTCAL_HIST
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_ACCOUNTCAL_HIST" 
   (	"ENTITYKEY" NUMBER(19,0), 
	"ACCOUNTENTITYID" NUMBER(10,0), 
	"UCIFENTITYID" NUMBER(10,0), 
	"CUSTOMERENTITYID" NUMBER(10,0), 
	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"REFCUSTOMERID" VARCHAR2(50 CHAR), 
	"SOURCESYSTEMCUSTOMERID" VARCHAR2(50 CHAR), 
	"UCIF_ID" VARCHAR2(50 CHAR), 
	"BRANCHCODE" VARCHAR2(20 CHAR), 
	"FACILITYTYPE" VARCHAR2(10 CHAR), 
	"ACOPENDT" VARCHAR2(200 CHAR), 
	"FIRSTDTOFDISB" VARCHAR2(200 CHAR), 
	"PRODUCTALT_KEY" NUMBER(10,0), 
	"SCHEMEALT_KEY" NUMBER(10,0), 
	"SUBSECTORALT_KEY" NUMBER(10,0), 
	"SPLCATG1ALT_KEY" NUMBER(10,0), 
	"SPLCATG2ALT_KEY" NUMBER(10,0), 
	"SPLCATG3ALT_KEY" NUMBER(10,0), 
	"SPLCATG4ALT_KEY" NUMBER(10,0), 
	"SOURCEALT_KEY" NUMBER(3,0), 
	"ACTSEGMENTCODE" VARCHAR2(30 CHAR), 
	"INTTRATE" NUMBER(16,8), 
	"BALANCE" NUMBER(16,2), 
	"BALANCEINCRNCY" NUMBER(16,2), 
	"CURRENCYALT_KEY" NUMBER(10,0), 
	"DRAWINGPOWER" NUMBER(16,2), 
	"CURRENTLIMIT" NUMBER(16,2), 
	"CURRENTLIMITDT" VARCHAR2(200 CHAR), 
	"CONTIEXCESSDT" VARCHAR2(200 CHAR), 
	"STOCKSTDT" VARCHAR2(200 CHAR), 
	"DEBITSINCEDT" VARCHAR2(200 CHAR), 
	"LASTCRDATE" VARCHAR2(200 CHAR), 
	"INTTSERVICED" CHAR(1 CHAR), 
	"INTNOTSERVICEDDT" VARCHAR2(200 CHAR), 
	"OVERDUEAMT" NUMBER(18,2), 
	"OVERDUESINCEDT" VARCHAR2(200 CHAR), 
	"REVIEWDUEDT" VARCHAR2(200 CHAR), 
	"SECURITYVALUE" NUMBER(24,0), 
	"DFVAMT" NUMBER(16,2), 
	"GOVTGTYAMT" NUMBER(16,2), 
	"COVERGOVGUR" NUMBER(16,2), 
	"WRITEOFFAMOUNT" NUMBER(16,2), 
	"UNADJSUBSIDY" NUMBER(16,2), 
	"CREDITSINCEDT" VARCHAR2(200 CHAR), 
	"DEGREASON" CLOB, 
	"ASSET_NORM" VARCHAR2(15 CHAR), 
	"REFPERIODMAX" NUMBER(10,0), 
	"REFPERIODOVERDUE" NUMBER(5,0), 
	"REFPERIODOVERDRAWN" NUMBER(5,0), 
	"REFPERIODNOCREDIT" NUMBER(5,0), 
	"REFPERIODINTSERVICE" NUMBER(5,0), 
	"REFPERIODSTKSTATEMENT" NUMBER(5,0), 
	"REFPERIODREVIEW" NUMBER(5,0), 
	"NETBALANCE" NUMBER(16,2), 
	"APPRRV" NUMBER(22,2), 
	"SECUREDAMT" NUMBER(16,2), 
	"UNSECUREDAMT" NUMBER(16,2), 
	"PROVDFV" NUMBER(16,2), 
	"PROVSECURED" NUMBER(16,2), 
	"PROVUNSECURED" NUMBER(16,2), 
	"PROVCOVERGOVGUR" NUMBER(16,2), 
	"ADDLPROVISION" NUMBER(16,2), 
	"TOTALPROVISION" NUMBER(16,2), 
	"BANKPROVSECURED" NUMBER(16,2), 
	"BANKPROVUNSECURED" NUMBER(16,2), 
	"BANKTOTALPROVISION" NUMBER(16,2), 
	"RBIPROVSECURED" NUMBER(18,2), 
	"RBIPROVUNSECURED" NUMBER(18,2), 
	"RBITOTALPROVISION" NUMBER(18,2), 
	"INITIALNPADT" VARCHAR2(200 CHAR), 
	"FINALNPADT" VARCHAR2(200 CHAR), 
	"SMA_DT" VARCHAR2(200 CHAR), 
	"UPGDATE" VARCHAR2(200 CHAR), 
	"INITIALASSETCLASSALT_KEY" NUMBER(10,0), 
	"FINALASSETCLASSALT_KEY" NUMBER(10,0), 
	"PROVISIONALT_KEY" NUMBER(10,0), 
	"PNPA_REASON" CLOB, 
	"SMA_CLASS" VARCHAR2(5 CHAR), 
	"SMA_REASON" CLOB, 
	"FLGMOC" CHAR(1 CHAR), 
	"MOC_DT" VARCHAR2(200 CHAR), 
	"COMMONMOCTYPEALT_KEY" NUMBER(5,0), 
	"FLGDEG" CHAR(1 CHAR), 
	"FLGDIRTYROW" CHAR(1 CHAR), 
	"FLGINMONTH" CHAR(1 CHAR), 
	"FLGSMA" CHAR(1 CHAR), 
	"FLGPNPA" CHAR(1 CHAR), 
	"FLGUPG" CHAR(1 CHAR), 
	"FLGFITL" CHAR(1 CHAR), 
	"FLGABINITIO" CHAR(1 CHAR), 
	"NPA_DAYS" NUMBER(10,0), 
	"REFPERIODOVERDUEUPG" NUMBER(5,0), 
	"REFPERIODOVERDRAWNUPG" NUMBER(5,0), 
	"REFPERIODNOCREDITUPG" NUMBER(5,0), 
	"REFPERIODINTSERVICEUPG" NUMBER(5,0), 
	"REFPERIODSTKSTATEMENTUPG" NUMBER(5,0), 
	"REFPERIODREVIEWUPG" NUMBER(5,0), 
	"EFFECTIVEFROMTIMEKEY" NUMBER(10,0), 
	"EFFECTIVETOTIMEKEY" NUMBER(10,0), 
	"APPGOVGUR" NUMBER(18,2), 
	"USEDRV" NUMBER(18,2), 
	"COMPUTEDCLAIM" NUMBER(22,2), 
	"UPG_RELAX_MSME" CHAR(1 CHAR), 
	"DEG_RELAX_MSME" CHAR(1 CHAR), 
	"PNPA_DATE" VARCHAR2(200 CHAR), 
	"NPA_REASON" CLOB, 
	"PNPAASSETCLASSALT_KEY" NUMBER(10,0), 
	"DISBAMOUNT" NUMBER(18,2), 
	"PRINCOUTSTD" NUMBER(18,2), 
	"PRINCOVERDUE" NUMBER(18,2), 
	"PRINCOVERDUESINCEDT" VARCHAR2(200 CHAR), 
	"INTOVERDUE" NUMBER(18,2), 
	"INTOVERDUESINCEDT" VARCHAR2(200 CHAR), 
	"OTHEROVERDUE" NUMBER(18,2), 
	"OTHEROVERDUESINCEDT" VARCHAR2(200 CHAR), 
	"RELATIONSHIPNUMBER" VARCHAR2(30 CHAR), 
	"ACCOUNTFLAG" VARCHAR2(20 CHAR), 
	"COMMERCIALFLAG_ALTKEY" NUMBER(5,0), 
	"LIABILITY" VARCHAR2(20 CHAR), 
	"CD" VARCHAR2(20 CHAR), 
	"ACCOUNTSTATUS" VARCHAR2(20 CHAR), 
	"ACCOUNTBLKCODE1" VARCHAR2(25 CHAR), 
	"ACCOUNTBLKCODE2" VARCHAR2(25 CHAR), 
	"EXPOSURETYPE" VARCHAR2(50 CHAR), 
	"MTM_VALUE" NUMBER(18,2), 
	"BANKASSETCLASS" VARCHAR2(10 CHAR), 
	"NPATYPE" VARCHAR2(10 CHAR), 
	"SECAPP" CHAR(1 CHAR), 
	"BORROWERTYPEID" NUMBER(10,0), 
	"LINECODE" VARCHAR2(30 CHAR), 
	"PROVPERSECURED" NUMBER(10,4), 
	"PROVPERUNSECURED" NUMBER(10,4), 
	"MOCREASON" VARCHAR2(500 CHAR), 
	"ADDLPROVISIONPER" NUMBER(6,2), 
	"FLGINFRA" CHAR(1 CHAR), 
	"REPOSSESSIONDATE" VARCHAR2(200 CHAR), 
	"DERECOGNISEDINTEREST1" NUMBER(14,0), 
	"DERECOGNISEDINTEREST2" NUMBER(14,0), 
	"PRODUCTCODE" VARCHAR2(20 CHAR), 
	"FLGLCBG" CHAR(1 CHAR), 
	"UNSERVIEDINT" NUMBER(18,2), 
	"PREQTRCREDIT" NUMBER(18,2), 
	"PRVQTRINT" NUMBER(18,2), 
	"CURQTRCREDIT" NUMBER(18,2), 
	"CURQTRINT" NUMBER(18,2), 
	"ORIGINALBRANCHCODE" VARCHAR2(10 CHAR), 
	"ADVANCERECOVERY" NUMBER(16,2), 
	"NOTIONALINTTAMT" NUMBER(16,2), 
	"PRVASSETCLASSALT_KEY" NUMBER(10,0), 
	"MOCTYPE" VARCHAR2(15 CHAR), 
	"FLGSECURED" CHAR(1 CHAR), 
	"REPOSSESSION" CHAR(1 CHAR), 
	"RCPENDING" CHAR(1 CHAR), 
	"PAYMENTPENDING" CHAR(1 CHAR), 
	"WHEELCASE" CHAR(1 CHAR), 
	"CUSTOMERLEVELMAXPER" NUMBER(5,2), 
	"FINALPROVISIONPER" NUMBER(5,2), 
	"ISIBPC" CHAR(1 CHAR), 
	"ISSECURITISED" CHAR(1 CHAR), 
	"RFA" CHAR(1 CHAR), 
	"ISNONCOOPERATIVE" CHAR(1 CHAR), 
	"SARFAESI" CHAR(1 CHAR), 
	"WEAKACCOUNT" CHAR(1 CHAR), 
	"PUI" CHAR(1 CHAR), 
	"FLGFRAUD" CHAR(1 CHAR), 
	"FLGRESTRUCTURE" CHAR(1 CHAR), 
	"RESTRUCTUREDATE" VARCHAR2(200 CHAR), 
	"SARFAESIDATE" VARCHAR2(200 CHAR), 
	"FLGUNUSUALBOUNCE" CHAR(1 CHAR), 
	"UNUSUALBOUNCEDATE" VARCHAR2(200 CHAR), 
	"FLGUNCLEAREDEFFECT" CHAR(1 CHAR), 
	"UNCLEAREDEFFECTDATE" VARCHAR2(200 CHAR), 
	"FRAUDDATE" VARCHAR2(200 CHAR), 
	"WEAKACCOUNTDATE" VARCHAR2(200 CHAR), 
	"SCREENFLAG" CHAR(1 CHAR), 
	"CHANGEFIELD" CLOB
   ) ON COMMIT DELETE ROWS 
 LOB ("DEGREASON") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) 
 LOB ("PNPA_REASON") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) 
 LOB ("SMA_REASON") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) 
 LOB ("NPA_REASON") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) 
 LOB ("CHANGEFIELD") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
