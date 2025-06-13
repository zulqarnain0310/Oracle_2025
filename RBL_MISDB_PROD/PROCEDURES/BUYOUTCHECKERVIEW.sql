--------------------------------------------------------
--  DDL for Procedure BUYOUTCHECKERVIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" 
(
  v_MenuID IN NUMBER DEFAULT 10 ,
  v_UserLoginId IN VARCHAR2 DEFAULT 'FnaAdmin' ,
  iv_Timekey IN NUMBER DEFAULT 49999 ,
  v_UploadID IN NUMBER
)
AS
   v_Timekey NUMBER(10,0) := iv_Timekey;
   v_cursor SYS_REFCURSOR;
   v_SQLERRM VARCHAR(1000);
   v_SQLCODE VARCHAR(1000);
BEGIN

   BEGIN

      BEGIN
         
         SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

           INTO v_Timekey
           FROM SysDataMatrix A
                  JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
          WHERE  A.CurrentStatus = 'C';
         DBMS_OUTPUT.PUT_LINE(v_Timekey);
         IF ( v_MenuID = '1466' ) THEN

         BEGIN
            OPEN  v_cursor FOR
               SELECT ROW_NUMBER() OVER ( ORDER BY AUNo  ) SrNo  ,
                      AUNo ,
                               PoolName ,
                               Category ,
                               TotalNoofBuyoutParty  ,
                               TotalPrincipalOutstandinginRs,
                               TotalInterestReceivableinRs,
                               BuyoutOSBalanceinRs,
                               TotalChargesinRs,
                               TotalAccuredInterestinRs,
                               NoofAccounts
                 FROM ( SELECT AUNo ,
                               PoolName ,
                               Category ,
                               SUM(TotalNoofBuyoutParty)  TotalNoofBuyoutParty  ,
                               SUM(TotalPrincipalOutstandinginRs)  TotalPrincipalOutstandinginRs  ,
                               SUM(TotalInterestReceivableinRs)  TotalInterestReceivableinRs  ,
                               SUM(BuyoutOSBalanceinRs)  BuyoutOSBalanceinRs  ,
                               SUM(TotalChargesinRs)  TotalChargesinRs  ,
                               SUM(TotalAccuredInterestinRs)  TotalAccuredInterestinRs  ,
                               COUNT(1)  NoofAccounts  
                        FROM BuyoutSummary_Mod 
                         WHERE --Isnull(AuthorisationStatus,'A') in ('NP','MP') And
                          EffectiveFromTimeKey <= v_TimeKey
                            AND EffectiveToTimeKey >= v_TimeKey
                            AND UploadID = v_UploadID
                          GROUP BY AUNo,PoolName,Category ) A ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
   v_SQLERRM:=SQLERRM;
   v_SQLCODE:=SQLCODE;
      INSERT INTO RBL_MISDB_PROD.Error_Log(ERRORLINE
                                        ,	ERRORMESSAGE
                                        ,	ERRORNUMBER
                                        ,	ERRORPROCEDURE
                                        ,	ERRORSEVERITY
                                        ,	ERRORSTATE
                                        )
        ( SELECT utils.error_line ErrorLine  ,
                 v_SQLERRM ErrorMessage  ,
                 v_SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState 
            FROM DUAL  );

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BUYOUTCHECKERVIEW" TO "ADF_CDR_RBL_STGDB";
