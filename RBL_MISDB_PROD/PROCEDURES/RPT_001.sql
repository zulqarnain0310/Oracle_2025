--------------------------------------------------------
--  DDL for Procedure RPT_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_001" /*
CREATE BY		:	Baijayanti
CREATE DATE	    :	07-04-2021
DISCRIPTION		:   Source to Stage - Source System-wise ETL Summary
*/
(
  v_UserName IN VARCHAR2,
  v_MisLocation IN VARCHAR2,
  v_CustFacility IN VARCHAR2,
  v_TimeKey IN NUMBER
)
AS
   --DECLARE 
   -- @UserName AS VARCHAR(20)='D2K'	
   --,@MisLocation AS VARCHAR(20)=''
   --,@CustFacility AS VARCHAR(10)=3
   --,@TimeKey AS INT=26030
   v_Flag CHAR(5);
   v_Department VARCHAR2(10);
   v_AuthenFlag CHAR(5);
   v_Code VARCHAR2(10);
   v_BankCode NUMBER(10,0);
   v_CurDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey );
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
   IF utils.object_id('tempdb..tt_DATA') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA ';
   END IF;
   DELETE FROM tt_DATA;
   UTILS.IDENTITY_RESET('tt_DATA');

   INSERT INTO tt_DATA ( 
   	SELECT SourceSystemName Source_System_Name  ,
           BandName Activity  ,
           MIN(ExecutionStartTime)  ExecutionStartTime  ,
           MAX(ExecutionEndTime)  ExecutionEndTime  ,
           utils.datediff('SS', MIN(ExecutionStartTime) , MAX(ExecutionEndTime) ) TimeDuration_Sec  ,
           CASE 
                WHEN MAX(ExecutionStatus)  = 1 THEN 'Completed'
           ELSE 'Running'
              END ExecutionStatus  
   	  FROM RBL_STGDB.Package_AUDIT PA
             JOIN RBL_STGDB.ETLSolutionParameterforReport ETLSPR   ON ETLSPR.TargetTableName = PA.TableName
             AND ETLSPR.EffectiveFromTimeKey <= v_TimeKey
             AND ETLSPR.EffectiveToTimeKey >= v_TimeKey
             JOIN DimDashBoardETLAudit DETLA   ON PA.TableName = DETLA.PackageTableName
   	 WHERE  BandName = 'Import Source to Stage'
              AND Execution_date = v_CurDate
   	  GROUP BY SourceSystemName,BandName );
   OPEN  v_cursor FOR
      SELECT Source_System_Name ,
             Activity ,
             UTILS.CONVERT_TO_VARCHAR2(ExecutionStartTime,15,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(ExecutionStartTime,15,p_style=>108) ExecutionStartTime  ,
             UTILS.CONVERT_TO_VARCHAR2(ExecutionEndTime,15,p_style=>103) || ' ' || UTILS.CONVERT_TO_VARCHAR2(ExecutionEndTime,15,p_style=>108) ExecutionEndTime  ,
             TimeDuration_Sec ,
             ExecutionStatus 
        FROM tt_DATA  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_001" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_001" TO "ADF_CDR_RBL_STGDB";
