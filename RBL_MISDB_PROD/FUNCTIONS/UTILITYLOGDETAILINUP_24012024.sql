--------------------------------------------------------
--  DDL for Function UTILITYLOGDETAILINUP_24012024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" 
(
  --DECLARE
  v_UtilEntityId IN NUMBER DEFAULT NULL ,
  v_ActionExecutionDate IN VARCHAR2 DEFAULT ' ' ,
  v_UtilityReason IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorName IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorEmpId IN VARCHAR2 DEFAULT ' ' ,
  v_UtilityRejectReason IN VARCHAR2 DEFAULT ' ' ,
  v_SourceName IN VARCHAR2 DEFAULT ' ' ,
  v_DateofData IN VARCHAR2 DEFAULT ' ' ,
  ------------------------ D2K Columns -----------------------  
  v_Timekey IN NUMBER,
  v_UserLoginID IN VARCHAR2,
  v_OperationFlag IN NUMBER,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;
--@MenuId     INT,  
--@AuthMode    CHAR(1),  
--@filepath    VARCHAR(MAX),  
--@UniqueUploadID   INT  

BEGIN

   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE EXISTS ( SELECT 1 
                      FROM ACLProcessInProgressStatus 
                       WHERE  STATUS = 'RUNNING'
                                AND StatusFlag = 'N'
                                AND TimeKey IN ( SELECT MAX(Timekey)  
                                                 FROM ACLProcessInProgressStatus  )
    );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('ACL Process is In Progress');

   END;

   --IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )

   --BEGIN

   --	PRINT 'ACL Process Completed'
   ELSE

   BEGIN
      BEGIN
         DECLARE
            -- BEGIN TRANSACTION  
            v_UtilEntityId1 NUMBER(10,0) := ( SELECT NVL(MAX(UtilEntityId) , 0) + 1 
              FROM UtilityLogDetail  );
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM UtilityLogDetail 
                                WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND UtilEntityId = v_UtilEntityId );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               IF ( v_OperationFlag = 16 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Approve');
                  UPDATE UtilityLogDetail
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND UtilEntityId = v_UtilEntityId
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;

               END;
               END IF;
               IF ( v_OperationFlag = 17 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Reject');
                  UPDATE UtilityLogDetail
                     SET AuthorisationStatus = 'R',
                         UtilityRejectReason = v_UtilityRejectReason,
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND UtilEntityId = v_UtilEntityId
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;

               END;
               END IF;
               IF ( v_OperationFlag = 3 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Delete Request');
                  UPDATE UtilityLogDetail
                     SET AuthorisationStatus = 'DP',
                         ModifiedBy = v_UserLoginID,
                         DateModified = SYSDATE,
                         EffectiveToTimeKey = EffectiveFromTimeKey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND UtilEntityId = v_UtilEntityId
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;

               END;
               END IF;
               IF ( v_OperationFlag = 5 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Execute Request');
                  UPDATE UtilityLogDetail
                     SET AuthorisationStatus = 'EX',
                         ExecutedBy = v_UserLoginID,
                         DateExecuted = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND UtilEntityId = v_UtilEntityId
                    AND AuthorisationStatus = 'A';

               END;
               END IF;
               IF ( v_OperationFlag = 2 ) THEN
                DECLARE
                  v_temp NUMBER(1, 0) := 0;

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('UPDATE LOG');
                  BEGIN
                     SELECT 1 INTO v_temp
                       FROM DUAL
                      WHERE EXISTS ( SELECT 1 
                                     FROM UtilityLogDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND EffectiveFromTimeKey = v_Timekey
                                               AND UtilEntityId = v_UtilEntityId );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     DBMS_OUTPUT.PUT_LINE('SAME TIMEKEY');
                     UPDATE UtilityLogDetail
                        SET ActionExecutionDate = UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103),
                            UtilityReason = v_UtilityReason,
                            OriginatorName = v_OriginatorName,
                            OriginatorEmpId = v_OriginatorEmpId,
                            UtilityRejectReason = v_UtilityRejectReason,
                            SourceName = v_SourceName,
                            DateofData = UTILS.CONVERT_TO_VARCHAR2(v_DateofData,200,p_style=>103),
                            AuthorisationStatus = 'MP',
                            EffectiveFromTimeKey = v_Timekey,
                            EffectiveToTimeKey = 49999,
                            ModifiedBy = v_UserLoginID,
                            DateModified = SYSDATE
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey )
                       AND UtilEntityId = v_UtilEntityId
                       AND AuthorisationStatus = 'NP';

                  END;
                  ELSE
                  DECLARE
                     v_CreatedBy VARCHAR2(50);
                     v_DateCreated DATE;

                  BEGIN
                     SELECT CreatedBy ,
                            DateCreated 

                       INTO v_CreatedBy,
                            v_DateCreated
                       FROM UtilityLogDetail 
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                               AND EffectiveToTimeKey >= v_Timekey )
                               AND UtilEntityId = v_UtilEntityId;
                     DBMS_OUTPUT.PUT_LINE('INSERT LOG');
                     INSERT INTO UtilityLogDetail
                       ( UtilEntityId, ActionExecutionDate, UtilityReason, OriginatorName, OriginatorEmpId, UtilityRejectReason, SourceName, DateofData, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified )
                       ( SELECT v_UtilEntityId UtilityEntityId  ,
                                UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103) ActionExecutionDate  ,
                                v_UtilityReason UtilityReason  ,
                                v_OriginatorName ,
                                v_OriginatorEmpId ,
                                v_UtilityRejectReason UtilityRejectReason  ,
                                v_SourceName ,
                                v_DateofData ,
                                'MP' AuthorisationStatus  ,
                                v_TimeKey EffectiveFomTimeKey  ,
                                49999 EffectiveToTimeKey  ,
                                v_CreatedBy ,
                                v_DateCreated ,
                                v_UserLoginId ModifiedBy  ,
                                SYSDATE DateModified  
                           FROM DUAL  );
                     --FROM UtilityLogDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) 
                     --AND UtilEntityId=@UtilEntityId  
                     DBMS_OUTPUT.PUT_LINE('EXPIRE OLD RECORD');
                     UPDATE UtilityLogDetail
                        SET AuthorisationStatus = 'FM',
                            EffectiveToTimeKey = v_Timekey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey )
                       AND UtilEntityId = v_UtilEntityId
                       AND EffectiveFromTimeKey < v_Timekey;

                  END;
                  END IF;

               END;
               END IF;

            END;
            ELSE
            DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               ---------- IMPLEMENT LOGIC TO CHECK IF RECORD IS ALREDY AVAILABLE IN LOG TABLE OR NOT BY SATWAJI AS ON 17/04/2023 -----------------------------------------
               --SELECT * FROM UtilityLogDetail ORDER BY 1 DESC
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM UtilityLogDetail 
                                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND SourceName = v_SourceName
                                            AND DateofData = v_DateofData
                                            AND ActionExecutionDate = v_ActionExecutionDate
                                            AND UtilityReason = v_UtilityReason );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('ALREADY EXISTS');
                  v_Result := -4 ;
                  RETURN v_Result;

               END;
               ELSE

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('INSERT NEW LOG');
                  INSERT INTO UtilityLogDetail
                    ( UtilEntityId, ActionExecutionDate, UtilityReason, OriginatorName, OriginatorEmpId, UtilityRejectReason, SourceName, DateofData, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                    ( SELECT v_UtilEntityId1 UtilityEntityId  ,
                             UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103) ActionExecutionDate  ,
                             v_UtilityReason UtilityReason  ,
                             v_OriginatorName ,
                             v_OriginatorEmpId ,
                             v_UtilityRejectReason UtilityRejectReason  ,
                             v_SourceName ,
                             v_DateofData ,
                             'NP' AuthorisationStatus  ,
                             v_TimeKey EffectiveFromTimeKey  ,
                             49999 EffectiveToTimeKey  ,
                             v_UserLoginId CreatedBy  ,
                             SYSDATE DateCreated  
                        FROM DUAL  );

               END;
               END IF;

            END;
            END IF;
            --FROM UtilityLogDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey) 
            --AND UtilEntityId=@UtilEntityId  
            -- COMMIT TRANSACTION  
            v_Result := 1 ;
            RETURN v_Result;

         END;
      EXCEPTION
         WHEN OTHERS THEN

      BEGIN
         --ROLLBACK TRANSACTION  
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

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."UTILITYLOGDETAILINUP_24012024" TO "ADF_CDR_RBL_STGDB";
