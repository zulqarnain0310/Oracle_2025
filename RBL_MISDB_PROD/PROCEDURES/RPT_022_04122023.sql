--------------------------------------------------------
--  DDL for Procedure RPT_022_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_022_04122023" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	26-05-2021
DISCRIPTION		:   SMA Movement- Ac Level listing
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_FromDate IN VARCHAR2,
  v_ToDate IN VARCHAR2,
  v_Cost IN FLOAT,
  v_MovementStatus IN VARCHAR2
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@FromDate   AS VARCHAR(15)='30/09/2020'
   --,@ToDate     AS VARCHAR(15)='21/11/2086'
   --,@Cost   AS FLOAT=1
   --,@MovementStatus   AS VARCHAR(MAX)='1,2,3,4,5,6,7,8,9,10'
   v_Flag CHAR(5);
   v_Department VARCHAR2(10);
   v_AuthenFlag CHAR(5);
   v_Code VARCHAR2(10);
   v_BankCode NUMBER(10,0);
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_FromDate))  );
   v_To1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_ToDate))  );
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
   OPEN  v_cursor FOR
      SELECT DB.BranchCode ,
             AMH.CustomerACID ,
             CustomerID ,
             CustomerName ,
             MovementToStatus ,
             UTILS.CONVERT_TO_VARCHAR2(MovementToDate,20,p_style=>103) MovementToDate  ,
             ProductCode ,
             SUM(NVL(TotOsAcc, 0))  / v_Cost TotOsAcc  ,
             AssetClassShortNameEnum 
        FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY AMH
               LEFT JOIN CustomerBasicDetail CBD   ON CBD.CustomerID = AMH.RefCustomerID
               AND CBD.EffectiveToTimeKey = 49999
               LEFT JOIN AdvAcBasicDetail ACBD   ON ACBD.CustomerACID = AMH.CustomerACID
               AND ACBD.EffectiveToTimeKey = 49999
               JOIN DimAssetClass DAC   ON AMH.FinalAssetClassAlt_Key = DAC.AssetClassAlt_Key
               AND DAC.EffectiveToTimeKey = 49999
               LEFT JOIN DimGLProduct DGLP   ON DGLP.GLProductAlt_Key = ACBD.GLProductAlt_Key
               AND DGLP.EffectiveToTimeKey = 49999
               LEFT JOIN DimBranch DB   ON ACBD.BranchCode = DB.BranchCode
               AND DB.EffectiveToTimeKey = 49999
       WHERE  v_From1 = MovementFromDate
                AND v_To1 = MovementToDate
                AND (CASE 
                          WHEN MovementFromStatus = 'STD'
                            AND MovementToStatus = 'SMA_0' THEN 1
                          WHEN MovementFromStatus = 'SMA_0'
                            AND MovementToStatus = 'STD' THEN 2
                          WHEN MovementFromStatus = 'SMA_0'
                            AND MovementToStatus = 'SMA_1' THEN 3
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'STD' THEN 4
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'SMA_0' THEN 5
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'SMA_2' THEN 6
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'SMA_1' THEN 7
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'SMA_0' THEN 8
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'STD' THEN 9
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus IN ( 'SUB','DB1','DB2','DB3','LOS' )
                           THEN 10   END) IN ( SELECT * 
                                               FROM TABLE(Split(v_MovementStatus, ','))  )

        GROUP BY DB.BranchCode,AMH.CustomerACID,CustomerID,CustomerName,MovementToStatus,MovementToDate,ProductCode,AssetClassShortNameEnum ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_022_04122023" TO "ADF_CDR_RBL_STGDB";
