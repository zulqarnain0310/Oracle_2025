--------------------------------------------------------
--  DDL for Procedure RPT_014
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_014" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	09-04-2021
DISCRIPTION		:   NPA Erosion Report
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_TimeKey IN NUMBER,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@TimeKey AS INT=26114
   --,@Cost    AS FLOAT=1
   v_Flag CHAR(5);
   v_Department VARCHAR2(10);
   v_AuthenFlag CHAR(5);
   v_Code VARCHAR2(10);
   v_BankCode NUMBER(10,0);
   v_PerQtrKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey );
   ------------------------------------------------
   ---------------------------------------------Final Selection---------------------------
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
   ----------------------------------Security Data-------------------------
   -------------------------Per------------------------
   IF ( utils.object_id('tempdb..tt_Per_Security') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Per_Security ';
   END IF;
   DELETE FROM tt_Per_Security;
   UTILS.IDENTITY_RESET('tt_Per_Security');

   INSERT INTO tt_Per_Security ( 
   	SELECT AccountEntityId ,
           SUM(NVL(CurrentValue, 0))  Per_SecurityValue  
   	  FROM AdvSecurityDetail ASD
             JOIN AdvSecurityValueDetail ASVD   ON ASD.SecurityEntityID = ASVD.SecurityEntityID
   	 WHERE  ASD.EffectiveFromTimeKey <= v_PerQtrKey
              AND ASD.EffectiveToTimeKey >= v_PerQtrKey
              AND ASVD.EffectiveFromTimeKey <= v_PerQtrKey
              AND ASVD.EffectiveToTimeKey >= v_PerQtrKey
   	  GROUP BY AccountEntityId );
   --------------------Cur-----------------------------------
   IF ( utils.object_id('tempdb..tt_Cur_Security') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Cur_Security ';
   END IF;
   DELETE FROM tt_Cur_Security;
   UTILS.IDENTITY_RESET('tt_Cur_Security');

   INSERT INTO tt_Cur_Security ( 
   	SELECT AccountEntityId ,
           SUM(NVL(CurrentValue, 0))  Cur_SecurityValue  
   	  FROM AdvSecurityDetail ASD
             JOIN AdvSecurityValueDetail ASVD   ON ASD.SecurityEntityID = ASVD.SecurityEntityID
   	 WHERE  ASD.EffectiveFromTimeKey <= v_TimeKey
              AND ASD.EffectiveToTimeKey >= v_TimeKey
              AND ASVD.EffectiveFromTimeKey <= v_TimeKey
              AND ASVD.EffectiveToTimeKey >= v_TimeKey
   	  GROUP BY AccountEntityId );
   ------------------------------------------------------------------
   ----------------------------------Per AssetClass------------------------
   IF ( utils.object_id('tempdb..tt_Per_AssetClass') IS NOT NULL ) THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Per_AssetClass ';
   END IF;
   DELETE FROM tt_Per_AssetClass;
   UTILS.IDENTITY_RESET('tt_Per_AssetClass');

   INSERT INTO tt_Per_AssetClass ( 
   	SELECT ACBD.AccountEntityId ,
           AssetClassShortNameEnum 
   	  FROM AdvAcBasicDetail ACBD
             JOIN AdvAcBalanceDetail ACBAL   ON ACBD.AccountEntityId = ACBAL.AccountEntityId
             JOIN DimAssetClass DAC   ON ACBAL.AssetClassAlt_Key = DAC.AssetClassAlt_Key
             AND DAC.EffectiveFromTimeKey <= v_PerQtrKey
             AND DAC.EffectiveToTimeKey >= v_PerQtrKey
   	 WHERE  ACBD.EffectiveFromTimeKey <= v_PerQtrKey
              AND ACBD.EffectiveToTimeKey >= v_PerQtrKey
              AND ACBAL.EffectiveFromTimeKey <= v_PerQtrKey
              AND ACBAL.EffectiveToTimeKey >= v_PerQtrKey );
   OPEN  v_cursor FOR
      SELECT CBD.CustomerId ,
             CBD.CustomerName ,
             SUM(NVL(PS.Per_SecurityValue, 0))  / v_Cost Per_SecurityValue  ,
             SUM(NVL(CS.Cur_SecurityValue, 0))  / v_Cost Cur_SecurityValue  ,
             ((SUM(NVL(CS.Cur_SecurityValue, 0))  / v_Cost) / (NULLIF(SUM(NVL(ACBAL.Balance, 0)) , 0) / v_Cost)) * 100 Security_Erosion  ,
             PAC.AssetClassShortNameEnum Prv_AssetClass  ,
             DAC.AssetClassShortNameEnum Current_AssetClass  ,
             SUM(NVL(ACBAL.Balance, 0))  / v_Cost Balance_Outstanding  
        FROM AdvAcBasicDetail ACBD
               JOIN CustomerBasicDetail CBD   ON ACBD.CustomerEntityId = CBD.CustomerEntityId
               AND CBD.EffectiveFromTimeKey <= v_TimeKey
               AND CBD.EffectiveToTimeKey >= v_TimeKey
               AND ACBD.EffectiveFromTimeKey <= v_TimeKey
               AND ACBD.EffectiveToTimeKey >= v_TimeKey
               JOIN AdvAcBalanceDetail ACBAL   ON ACBD.AccountEntityId = ACBAL.AccountEntityId
               AND ACBAL.EffectiveFromTimeKey <= v_TimeKey
               AND ACBAL.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN tt_Per_Security PS   ON ACBD.AccountEntityId = PS.AccountEntityId
               LEFT JOIN tt_Cur_Security CS   ON ACBD.AccountEntityId = CS.AccountEntityId
               LEFT JOIN tt_Per_AssetClass PAC   ON ACBD.AccountEntityId = PAC.AccountEntityId
               JOIN DimAssetClass DAC   ON ACBAL.AssetClassAlt_Key = DAC.AssetClassAlt_Key
               AND DAC.EffectiveFromTimeKey <= v_TimeKey
               AND DAC.EffectiveToTimeKey >= v_TimeKey
       WHERE  (NVL(CS.Cur_SecurityValue, 0) / NULLIF(NVL(ACBAL.Balance, 0), 0)) * 100 < 50
        GROUP BY CBD.CustomerId,CBD.CustomerName,PAC.AssetClassShortNameEnum,DAC.AssetClassShortNameEnum ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_014" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_014" TO "ADF_CDR_RBL_STGDB";
