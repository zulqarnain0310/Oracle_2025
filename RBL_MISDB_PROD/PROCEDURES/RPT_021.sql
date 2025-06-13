--------------------------------------------------------
--  DDL for Procedure RPT_021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_021" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	26-05-2021
DISCRIPTION		:   SMA Movement- Summary Report
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_FromDate IN VARCHAR2,
  v_ToDate IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@FromDate   AS VARCHAR(15)='30/09/2020'
   --,@ToDate     AS VARCHAR(15)='21/11/2086'
   --,@Cost   AS FLOAT=1
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
      SELECT NVL(SUM(
                     ------------------Movement of account from Normal to SMA-0--------------
                     CASE 
                          WHEN MovementFromStatus = 'STD'
                            AND MovementToStatus = 'SMA_0' THEN 1
                     ELSE 0
                        END) , 0) Normal_SMA0_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'STD'
                            AND MovementToStatus = 'SMA_0' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost Normal_SMA0_Amt  ,
             ----------------Movement of account from SMA-0 to Normal--------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_0'
                            AND MovementToStatus = 'STD' THEN 1
                     ELSE 0
                        END) , 0) SMA0_Normal_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_0'
                            AND MovementToStatus = 'STD' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA0_Normal_Amt  ,
             ----------------Movement of account from SMA-0 to SMA-1--------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_0'
                            AND MovementToStatus = 'SMA_1' THEN 1
                     ELSE 0
                        END) , 0) SMA0_SMA1_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_0'
                            AND MovementToStatus = 'SMA_1' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA0_SMA1_Amt  ,
             ----------------Movement of account from SMA-1 to Normal-----------------------------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'STD' THEN 1
                     ELSE 0
                        END) , 0) SMA1_Normal_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'STD' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA1_Normal_Amt  ,
             ----------------Movement of account from SMA-1 to SMA-0-------------------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'SMA_0' THEN 1
                     ELSE 0
                        END) , 0) SMA1_SMA0_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'SMA_0' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA1_SMA0_Amt  ,
             ----------------Movement of account from SMA-1 to SMA-2--------------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'SMA_2' THEN 1
                     ELSE 0
                        END) , 0) SMA1_SMA2_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_1'
                            AND MovementToStatus = 'SMA_2' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA1_SMA2_Amt  ,
             ----------------Movement of account from SMA-2 to SMA-1--------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'SMA_1' THEN 1
                     ELSE 0
                        END) , 0) SMA2_SMA1_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'SMA_1' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA2_SMA1_Amt  ,
             ----------------Movement of account from SMA-2 to SMA-0-----------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'SMA_0' THEN 1
                     ELSE 0
                        END) , 0) SMA2_SMA0_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'SMA_0' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA2_SMA0_Amt  ,
             ---------------Movement of account from SMA-2 to Normal------------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'STD' THEN 1
                     ELSE 0
                        END) , 0) SMA2_Normal_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus = 'STD' THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA2_Normal_Amt  ,
             ---------------Movement of account from SMA-2 to NPA-----------------
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus IN ( 'SUB','DB1','DB2','DB3','LOS' )
                           THEN 1
                     ELSE 0
                        END) , 0) SMA2_NPA_Ac  ,
             NVL(SUM(CASE 
                          WHEN MovementFromStatus = 'SMA_2'
                            AND MovementToStatus IN ( 'SUB','DB1','DB2','DB3','LOS' )
                           THEN NVL(TotOsAcc, 0)
                     ELSE 0
                        END) , 0) / v_Cost SMA2_NPA_Amt  
        FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY 
       WHERE  v_From1 = MovementFromDate
                AND v_To1 = MovementToDate ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_021" TO "ADF_CDR_RBL_STGDB";
