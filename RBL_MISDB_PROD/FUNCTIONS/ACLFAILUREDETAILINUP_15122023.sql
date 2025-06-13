--------------------------------------------------------
--  DDL for Function ACLFAILUREDETAILINUP_15122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" 
(
  v_ACLFailEntityId IN NUMBER DEFAULT NULL ,
  v_RcaId IN NUMBER DEFAULT NULL ,
  v_ACLFailuerdate IN VARCHAR2 DEFAULT ' ' ,
  v_ACLFailuerReason IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorName IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorEmpId IN VARCHAR2 DEFAULT ' ' ,
  v_ModeOfCommunication IN VARCHAR2 DEFAULT ' ' ,
  v_IntimationTime IN VARCHAR2 DEFAULT ' ' ,
  v_D2KUserName IN VARCHAR2 DEFAULT ' ' ,
  v_D2KUserEmpId IN VARCHAR2 DEFAULT ' ' ,
  v_D2KInformedDate IN VARCHAR2 DEFAULT ' ' ,
  v_ACLIssueResolvedDate IN VARCHAR2 DEFAULT ' ' ,
  v_ACLIssueResolvedTime IN VARCHAR2 DEFAULT ' ' ,
  v_ETLStartTime IN VARCHAR2 DEFAULT ' ' ,
  v_ETLEndTime IN VARCHAR2 DEFAULT ' ' ,
  v_ETLStatus IN VARCHAR2 DEFAULT ' ' ,
  v_SourceName IN VARCHAR2 DEFAULT ' ' ,
  v_ETLSolution IN VARCHAR2 DEFAULT ' ' ,
  ------------------------ D2K Columns -----------------------    
  v_Timekey IN NUMBER,
  v_UserLoginID IN VARCHAR2,
  --@OperationFlag   INT,    --@MenuId     INT,    --@AuthMode    CHAR(1),    --@filepath    VARCHAR(MAX),    --@EffectiveFromTimeKey INT,    --@EffectiveToTimeKey  INT,    
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_cursor SYS_REFCURSOR;
--@UniqueUploadID   INT    
--SELECT * FROM ACLFailureDetail    

BEGIN

   BEGIN
      DECLARE
         -- BEGIN TRANSACTION    
         v_ACLFailEntityId1 NUMBER(10,0) := ( SELECT NVL(MAX(ACLFailEntityId) , 0) + 1 
           FROM ACLFailureDetail  );
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM ACLFailureDetail 
                             WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND ACLFailEntityId = v_ACLFailEntityId );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('UPDATE');
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            UPDATE ACLFailureDetail
               SET
               --ACLFailuerdate    = CONVERT(DATE,@ACLFailuerdate,103),    
             ACLFailuerdate = UTILS.CONVERT_TO_VARCHAR2(v_ACLFailuerdate,200),
             RCA_ID = v_RcaId,
             ACLFailuerReason = v_ACLFailuerReason,
             OriginatorName = v_OriginatorName,
             OriginatorEmpId = v_OriginatorEmpId,
             ModeOfCommunication = v_ModeOfCommunication,
             IntimationTime = v_IntimationTime,
             D2KUserName = v_D2KUserName,
             D2KUserEmpId = v_D2KUserEmpId,
             D2KInformedDate = UTILS.CONVERT_TO_VARCHAR2(v_D2KInformedDate,200),
             ACLIssueResolvedDate = UTILS.CONVERT_TO_VARCHAR2(v_ACLIssueResolvedDate
             --D2KInformedDate    = CONVERT(DATE,@D2KInformedDate,103),    
              --ACLIssueResolvedDate  = CONVERT(DATE,@ACLIssueResolvedDate,103),    
             ,200),
             ACLIssueResolvedTime = v_ACLIssueResolvedTime,
             ETLStartTime = v_ETLStartTime,
             ETLEndTime = v_ETLEndTime,
             ETLStatus = v_ETLStatus,
             AuthorisationStatus = 'MP',
             ModifiedBy = v_UserLoginID,
             DateModified = SYSDATE,
             SourceName = v_SourceName,
             ETLSolution = v_ETLSolution
             WHERE  ( EffectiveFromTimeKey <= v_Timekey
              AND EffectiveToTimeKey >= v_Timekey )
              AND ACLFailEntityId = v_ACLFailEntityId;

         END;
         ELSE

         BEGIN
            DBMS_OUTPUT.PUT_LINE('INSERT');
            INSERT INTO ACLFailureDetail
              ( ACLFailEntityId, RCA_ID, ACLFailuerdate, ACLFailuerReason, OriginatorName, OriginatorEmpId, ModeOfCommunication, IntimationTime, D2KUserName, D2KUserEmpId, D2KInformedDate, ACLIssueResolvedDate, ACLIssueResolvedTime, ETLStartTime, ETLEndTime, ETLStatus, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, SourceName, ETLSolution )
              ( SELECT v_ACLFailEntityId1 ACLFailEntityId  ,
                       v_RcaId ,
                       UTILS.CONVERT_TO_VARCHAR2(v_ACLFailuerdate,200,p_style=>103) ACLFailuerdate  ,
                       v_ACLFailuerReason ,
                       v_OriginatorName ,
                       v_OriginatorEmpId ,
                       v_ModeOfCommunication ,
                       v_IntimationTime ,
                       v_D2KUserName ,
                       v_D2KUserEmpId ,
                       UTILS.CONVERT_TO_VARCHAR2(v_D2KInformedDate,200,p_style=>103) D2KInformedDate  ,
                       UTILS.CONVERT_TO_VARCHAR2(v_ACLIssueResolvedDate,200,p_style=>103) ACLIssueResolvedDate  ,
                       v_ACLIssueResolvedTime ,
                       v_ETLStartTime ,
                       v_ETLEndTime ,
                       v_ETLStatus ,
                       'NP' AuthorisationStatus  ,
                       v_TimeKey EffectiveFromTimeKey  ,
                       49999 EffectiveToTimeKey  ,
                       v_UserLoginId CreatedBy  ,
                       SYSDATE DateCreated  ,
                       v_SourceName ,
                       v_ETLSolution 
                  FROM DUAL  );

         END;
         END IF;
         --FROM ACLFailureDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)    
         --AND ACLFailEntityId=@ACLFailEntityId    
         -- COMMIT TRANSACTION    
         v_Result := 1 ;
         RETURN v_Result;

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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLFAILUREDETAILINUP_15122023" TO "ADF_CDR_RBL_STGDB";
