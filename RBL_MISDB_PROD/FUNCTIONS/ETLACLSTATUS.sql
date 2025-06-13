--------------------------------------------------------
--  DDL for Function ETLACLSTATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ETLACLSTATUS" 
(
  v_Status IN NUMBER DEFAULT 0 
)
RETURN NUMBER
AS
   v_TimeKey NUMBER(10,0);
   v_Date VARCHAR2(200);
   v_cursor SYS_REFCURSOR;

BEGIN

   v_Date := UTILS.CONVERT_TO_VARCHAR2(SYSDATE - 2,200) ;
   BEGIN

      BEGIN
         IF ( v_Status = 1 ) THEN
          DECLARE
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            SELECT Timekey 

              INTO v_Timekey
              FROM Automate_Advances 
             WHERE  Date_ = v_Date;
            --SET @Date =(Select date from Automate_Advances where Timekey=@Timekey)
            DBMS_OUTPUT.PUT_LINE('@Date');
            DBMS_OUTPUT.PUT_LINE(v_Date);
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM RBLACLStatus 
                                WHERE  ACLDate = v_Date );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               DELETE RBLACLStatus

                WHERE  ACLDate = v_Date;

            END;
            END IF;
            INSERT INTO RBL_MISDB_PROD.RBLACLStatus
              ( ExecutionFlag, ACLFlag, RFFlag, ACLDate, ACLTimeKey )
              VALUES ( 'N', 'N', 'N', v_Date, v_Timekey );

         END;
         END IF;
         IF ( v_Status = 2 ) THEN

         BEGIN
            SELECT Timekey 

              INTO v_Timekey
              FROM Automate_Advances 
             WHERE  Date_ = v_Date;
            --SET @Date =(Select date from Automate_Advances where Timekey=@Timekey)
            UPDATE RBLACLStatus
               SET ACLStarttime = SYSDATE
             WHERE  ACLDate = v_Date;

         END;
         END IF;
         IF ( v_Status = 3 ) THEN

         BEGIN
            SELECT Timekey 

              INTO v_Timekey
              FROM Automate_Advances 
             WHERE  Date_ = v_Date;
            --SET @Date =(Select date from Automate_Advances where Timekey=@Timekey)
            UPDATE RBLACLStatus
               SET ACLEndtime = SYSDATE,
                   ACLFlag = 'Y'
             WHERE  ACLDate = v_Date;

         END;
         END IF;
         IF ( v_Status = 4 ) THEN

         BEGIN
            SELECT Timekey 

              INTO v_Timekey
              FROM Automate_Advances 
             WHERE  Date_ = v_Date;
            --SET @Date =(Select date from Automate_Advances where Timekey=@Timekey)
            UPDATE RBLACLStatus
               SET RFStarttime = SYSDATE
             WHERE  ACLDate = v_Date;

         END;
         END IF;
         IF ( v_Status = 5 ) THEN

         BEGIN
            SELECT Timekey 

              INTO v_Timekey
              FROM Automate_Advances 
             WHERE  Date_ = v_Date;
            --SET @Date =(Select date from Automate_Advances where Timekey=@Timekey)
            UPDATE RBLACLStatus
               SET RFEndtime = SYSDATE,
                   RFFlag = 'Y'
             WHERE  ACLDate = v_Date;

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      ROLLBACK;
      utils.resetTrancount;
      INSERT INTO RBL_MISDB_PROD.Error_Log
        ( SELECT utils.error_line ErrorLine  ,
                 SQLERRM ErrorMessage  ,
                 SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      RETURN -1;

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ETLACLSTATUS" TO "ADF_CDR_RBL_STGDB";
