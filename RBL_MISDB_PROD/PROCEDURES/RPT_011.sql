--------------------------------------------------------
--  DDL for Procedure RPT_011
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_011" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	05-04-2021
DISCRIPTION		:   Slippage Reports - Assignment of NPA Date
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_From IN VARCHAR2,
  v_To IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@From AS VARCHAR(20)='01/01/2021'
   --,@To   AS VARCHAR(20)='31/03/2021'
   --,@Cost FLOAT=1
   v_Flag CHAR(5);
   v_Department VARCHAR2(10);
   v_AuthenFlag CHAR(5);
   v_Code VARCHAR2(10);
   v_BankCode NUMBER(10,0);
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_From))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_to))  );
   v_TimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM SysDayMatrix 
    WHERE  DATE_ = v_to1 );
   -------NEW DATE LOGIC ADDED AS PER MAIL	-	17-12-2018
   v_FromTimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM SysDayMatrix 
    WHERE  DATE_ = v_From1 );
   v_ToTimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM SysDayMatrix 
    WHERE  DATE_ = v_to1 );
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT AuthenticationFlag() 

     INTO v_AuthenFlag
     FROM DUAL ;
   SELECT ADflag() 

     INTO v_Flag
     FROM DUAL ;
   IF v_Flag = 'Y' THEN

   BEGIN
      v_Department := (SUBSTR(v_MisLocation, 0, 2)) ;
      v_Code := (SUBSTR(v_MisLocation, -3, 3)) ;

   END;
   ELSE
      IF v_Flag = 'SQL' THEN

      BEGIN
         IF v_AuthenFlag = 'Y' THEN

         BEGIN
            SELECT UserLocation 

              INTO v_Department
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserName
                      AND EffectiveToTimeKey = 49999 
              FETCH FIRST 1 ROWS ONLY;
            SELECT UserLocationCode 

              INTO v_Code
              FROM DimUserInfo 
             WHERE  UserLoginID = v_UserName
                      AND EffectiveToTimeKey = 49999 
              FETCH FIRST 1 ROWS ONLY;

         END;
         ELSE
            IF v_AuthenFlag = 'N' THEN

            BEGIN
               v_Department := 'RO' ;
               v_Code := '07' ;

            END;
            END IF;
         END IF;

      END;
      END IF;
   END IF;
   SELECT BankAlt_Key 

     INTO v_BankCode
     FROM SysReportformat ;
   ----------------------------------------------ToTimeKey DATA------------------------------------------
   IF ( utils.object_id('tempdb..tt_CURRENTDATA') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CURRENTDATA ';
   END IF;
   DELETE FROM tt_CURRENTDATA;
   UTILS.IDENTITY_RESET('tt_CURRENTDATA');

   INSERT INTO tt_CURRENTDATA ( 
   	SELECT SourceName ,
           CBD.UCIF_ID ,
           CustomerId ,
           CustomerName ,
           ACBD.CustomerACID ,
           DAC.AssetClassShortNameEnum ,
           DAC.AssetClassAlt_Key ,
           UTILS.CONVERT_TO_VARCHAR2(ACFD.NPADt,20,p_style=>103) NPADt  ,
           UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
           ACNPAD.NPA_Reason ,
           NVL(ACBAL.Balance, 0) Balance  
   	  FROM AdvAcBasicDetail ACBD
             JOIN CustomerBasicDetail CBD   ON CBD.CustomerEntityId = ACBD.CustomerEntityId
             AND CBD.EffectiveFromTimeKey <= v_ToTimeKey
             AND CBD.EffectiveToTimeKey >= v_ToTimeKey
             AND ACBD.EffectiveFromTimeKey <= v_ToTimeKey
             AND ACBD.EffectiveToTimeKey >= v_ToTimeKey
             JOIN AdvAcBalanceDetail ACBAL   ON ACBAL.AccountEntityId = ACBD.AccountEntityId
             AND ACBAL.EffectiveFromTimeKey <= v_ToTimeKey
             AND ACBAL.EffectiveToTimeKey >= v_ToTimeKey
             JOIN AdvAcFinancialDetail ACFD   ON ACBAL.AccountEntityId = ACFD.AccountEntityId
             AND ACFD.EffectiveFromTimeKey <= v_ToTimeKey
             AND ACFD.EffectiveToTimeKey >= v_ToTimeKey
             LEFT JOIN AdvCustNPADetail ACNPAD   ON ACBD.CustomerEntityId = ACNPAD.CustomerEntityId
             AND ACNPAD.EffectiveFromTimeKey <= v_ToTimeKey
             AND ACNPAD.EffectiveToTimeKey >= v_ToTimeKey
             JOIN DimAssetClass DAC   ON DAC.AssetClassAlt_Key = ACBAL.AssetClassAlt_Key
             AND DAC.EffectiveFromTimeKey <= v_ToTimeKey
             AND DAC.EffectiveToTimeKey >= v_ToTimeKey
             JOIN DIMSOURCEDB DSDB   ON DSDB.SourceAlt_Key = ACBD.SourceAlt_Key
             AND DSDB.EffectiveFromTimeKey <= v_ToTimeKey
             AND DSDB.EffectiveToTimeKey >= v_ToTimeKey
   	 WHERE  NVL(DAC.AssetClassShortNameEnum, ' ') NOT IN ( 'STD','NA' )
    );
   -----------------------------------------FROM TIMEKEY-----------------------------------------------------
   IF ( utils.object_id('tempdb..tt_PREVIOUSDATA') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PREVIOUSDATA ';
   END IF;
   DELETE FROM tt_PREVIOUSDATA;
   UTILS.IDENTITY_RESET('tt_PREVIOUSDATA');

   INSERT INTO tt_PREVIOUSDATA ( 
   	SELECT SourceName ,
           CBD.UCIF_ID ,
           CustomerId ,
           CustomerName ,
           ACBD.CustomerACID ,
           DAC.AssetClassShortNameEnum ,
           DAC.AssetClassAlt_Key ,
           UTILS.CONVERT_TO_VARCHAR2(ACFD.NPADt,20,p_style=>103) NPADt  ,
           UTILS.CONVERT_TO_VARCHAR2(OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
           ACNPAD.NPA_Reason ,
           NVL(ACBAL.Balance, 0) Balance  
   	  FROM AdvAcBasicDetail ACBD
             JOIN CustomerBasicDetail CBD   ON CBD.CustomerEntityId = ACBD.CustomerEntityId
             AND CBD.EffectiveFromTimeKey <= v_FromTimeKey
             AND CBD.EffectiveToTimeKey >= v_FromTimeKey
             AND ACBD.EffectiveFromTimeKey <= v_FromTimeKey
             AND ACBD.EffectiveToTimeKey >= v_FromTimeKey
             JOIN AdvAcBalanceDetail ACBAL   ON ACBAL.AccountEntityId = ACBD.AccountEntityId
             AND ACBAL.EffectiveFromTimeKey <= v_FromTimeKey
             AND ACBAL.EffectiveToTimeKey >= v_FromTimeKey
             JOIN AdvAcFinancialDetail ACFD   ON ACBAL.AccountEntityId = ACFD.AccountEntityId
             AND ACFD.EffectiveFromTimeKey <= v_FromTimeKey
             AND ACFD.EffectiveToTimeKey >= v_FromTimeKey
             LEFT JOIN AdvCustNPADetail ACNPAD   ON ACBD.CustomerEntityId = ACNPAD.CustomerEntityId
             AND ACNPAD.EffectiveFromTimeKey <= v_FromTimeKey
             AND ACNPAD.EffectiveToTimeKey >= v_FromTimeKey
             JOIN DimAssetClass DAC   ON DAC.AssetClassAlt_Key = ACBAL.AssetClassAlt_Key
             AND DAC.EffectiveFromTimeKey <= v_FromTimeKey
             AND DAC.EffectiveToTimeKey >= v_FromTimeKey
             JOIN DIMSOURCEDB DSDB   ON DSDB.SourceAlt_Key = ACBD.SourceAlt_Key
             AND DSDB.EffectiveFromTimeKey <= v_FromTimeKey
             AND DSDB.EffectiveToTimeKey >= v_FromTimeKey
   	 WHERE  NVL(DAC.AssetClassShortNameEnum, ' ') IN ( 'STD','NA' )
    );
   IF ( utils.object_id('tempdb..tt_DATA_7') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA_7 ';
   END IF;
   DELETE FROM tt_DATA_7;
   UTILS.IDENTITY_RESET('tt_DATA_7');

   INSERT INTO tt_DATA_7 ( 
   	SELECT DATA.* ,
           0 SRNO  
   	  FROM ( SELECT SourceName ,
                    UCIF_ID ,
                    CustomerId ,
                    CustomerName ,
                    CustomerACID ,
                    AssetClassShortNameEnum ,
                    AssetClassAlt_Key ,
                    NPADt ,
                    OverDueSinceDt ,
                    NPA_Reason ,
                    Balance ,
                    'C' FLAG  
             FROM tt_CURRENTDATA 
             UNION ALL 
             SELECT SourceName ,
                    UCIF_ID ,
                    CustomerId ,
                    CustomerName ,
                    CustomerACID ,
                    AssetClassShortNameEnum ,
                    AssetClassAlt_Key ,
                    NPADt ,
                    OverDueSinceDt ,
                    NPA_Reason ,
                    Balance ,
                    'P' FLAG  
             FROM tt_PREVIOUSDATA  ) DATA );
   MERGE INTO DATA 
   USING (SELECT DATA.ROWID row_id, D.SRNO
   FROM DATA ,tt_DATA_7 DATA
          JOIN ( SELECT ROW_NUMBER() OVER ( PARTITION BY CustomerACID ORDER BY SUBSTR(FLAG, -1, 1) DESC  ) SRNO  ,
                        CustomerACID ,
                        FLAG 
                 FROM tt_DATA_7  ) D   ON D.CustomerACID = DATA.CustomerACID
          AND D.FLAG = DATA.FLAG ) src
   ON ( DATA.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET DATA.SRNO = src.SRNO;
   EXECUTE IMMEDIATE ' CREATE INDEX INX_BranchCode1
      ON tt_DATA_7 ( CustomerACID)';
   IF ( utils.object_id('tempdb..tt_TOPROCESS') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TOPROCESS ';
   END IF;
   IF ( utils.object_id('tempdb..tt_MainData') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MainData ';
   END IF;
   DELETE FROM tt_TOPROCESS;
   UTILS.IDENTITY_RESET('tt_TOPROCESS');

   INSERT INTO tt_TOPROCESS ( 
   	SELECT PivotTable.SourceName,
           MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
   	  FROM ( 
   	     SELECT SourceName ,
                , 
                 aggregate
   	       FROM tt_DATA_7 ( SELECT PivotTable.CustomerACID,
   	         MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
   	  FROM ( 
   	     SELECT CustomerACID ,
   	            , 
   	             aggregate
   	       FROM 
   	      GROUP BY CustomerACID,
   	 ) PivotTable 
   	 GROUP BY PivotTable.CustomerACID ) Pvt
   	 WHERE  D.SRNO = 1
              AND CASE 
                       WHEN Asset_CURR IN ( 'STD','NA' )

                         AND Asset_PREV IN ( 'STD','NA' )
                        THEN 0
            ELSE 1
               END = 1
   	      GROUP BY SourceName,
   	 ) PivotTable 
   	 GROUP BY PivotTable.SourceName );

   BEGIN
      DELETE FROM tt_MainData;
      UTILS.IDENTITY_RESET('tt_MainData');

      INSERT INTO tt_MainData ( 
      	SELECT * 
      	  FROM ( SELECT SourceName ,
                       UCIF_ID ,
                       CustomerId ,
                       CustomerName ,
                       CustomerACID ,
                       Balance ,
                       Asset_CURR AssetClassShortNameEnum  ,
                       Asset_PREV ,
                       NPADt ,
                       NPA_Reason ,
                       OverDueSinceDt 
                FROM tt_TOPROCESS P ) DA );

   END;
   ---------------------------------------------------------------
   OPEN  v_cursor FOR
      SELECT DISTINCT SourceName ,
                      UCIF_ID ,
                      CustomerId ,
                      CustomerName ,
                      Data.CustomerACID ,
                      NPADt ,
                      NPA_Reason ,
                      Data.OverDueSinceDt ,
                      NVL(Data.Balance, 0) / v_Cost Balance  ,
                      Data.AssetClassShortNameEnum 
        FROM tt_MainData Data ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA_7 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PREVIOUSDATA ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_CURRENTDATA ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TOPROCESS ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_MainData ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_011" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_011" TO "ADF_CDR_RBL_STGDB";
