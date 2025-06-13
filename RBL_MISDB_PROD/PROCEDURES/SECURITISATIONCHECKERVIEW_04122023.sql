--------------------------------------------------------
--  DDL for Procedure SECURITISATIONCHECKERVIEW_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'FnaAdmin' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_UploadID IN NUMBER
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         SELECT MAX(Timekey)  

           INTO v_Timekey
           FROM SysDayMatrix 
          WHERE  UTILS.CONVERT_TO_VARCHAR2(date_,200) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
         DBMS_OUTPUT.PUT_LINE(v_Timekey);
         IF ( v_MenuID = '1461' ) THEN

         BEGIN
            --Select Row_Number()Over(Partition By PoolID,PoolName,SecuritisationType Order By PoolID,PoolName,SecuritisationType)SrNo ,* from (
            OPEN  v_cursor FOR
               SELECT ROW_NUMBER() OVER ( ORDER BY PoolID  ) SrNo  ,
                      PoolID ,
                      PoolName ,
                      SecuritisationType ,
                      NoofAccounts ,
                      POS ,
                      SecuritisationExposureAmt ,
                      UTILS.CONVERT_TO_VARCHAR2(SecuritisationReckoningDate,20,p_style=>103) SecuritisationReckoningDate  ,
                      UTILS.CONVERT_TO_VARCHAR2(SecuritisationMarkingDate,20,p_style=>103) SecuritisationMarkingDate  ,
                      UTILS.CONVERT_TO_VARCHAR2(MaturityDate,20,p_style=>103) MaturityDate  ,
                      SecuritisationPortfolio ,
                      UTILS.CONVERT_TO_VARCHAR2(DateofRemoval,20,p_style=>103) DateofRemoval  ,
                      TotalPosBalance ,
                      TotalInttReceivable 
                 FROM ( SELECT PoolID ,
                               PoolName ,
                               SecuritisationType ,
                               --,Count(1) NoofAccounts
                               --,SUM(POS)POS
                               --,SUM(SecuritisationExposureAmt)SecuritisationExposureAmt
                               --,MAx(SecuritisationReckoningDate)SecuritisationReckoningDate
                               --,MAx(SecuritisationMarkingDate)SecuritisationMarkingDate
                               --,MAx(MaturityDate)MaturityDate  --Added by Maniraj 22032021 5:02 PM		
                               --,SUM(SecuritisationPortfolio)SecuritisationPortfolio
                               --,Max(MaturityDate)DateofRemoval
                               --,SUM(TotalPosBalance)TotalPosBalance
                               --,SUM(TotalInttReceivable)TotalInttReceivable
                               --Changed by jayadev---------------------------------------------------------
                               NoOfAccount NoofAccounts  ,
                               POS ,
                               SecuritisationExposureAmt ,
                               SecuritisationReckoningDate ,
                               SecuritisationMarkingDate ,
                               MaturityDate ,
                               MaturityDate DateofRemoval  ,
                               SecuritisationPortfolio ,
                               TotalPosBalance ,
                               TotalInttReceivable 
                        FROM SecuritizedSummary_Mod 
                         WHERE --Isnull(AuthorisationStatus,'A') in ('NP','MP','1A')
                          EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey
                            AND UploadID = v_UploadID ) 
                      --Group By 

                      --PoolID,PoolName,SecuritisationType
                      A ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITISATIONCHECKERVIEW_04122023" TO "ADF_CDR_RBL_STGDB";
