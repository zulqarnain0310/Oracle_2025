--------------------------------------------------------
--  DDL for Function BACKDATEDACLPROCDETAILINUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" 
-- ===================================================================
 -- AUTHOR:				<SATWAJI YANNAWAR>
 -- CREATE DATE:			<07/02/2023>
 -- DESCRIPTION:			<BACKDATED ACL PROCESSING TABLE INSERT/UPDATE>
 -- ===================================================================

(
  v_BackACLProcEntityId IN NUMBER DEFAULT NULL ,
  v_ActionExecutionDate IN VARCHAR2 DEFAULT ' ' ,
  v_BackACLProcStatus IN VARCHAR2 DEFAULT ' ' ,
  v_RequestReason IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorName IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorEmpId IN VARCHAR2 DEFAULT ' ' ,
  v_BackACLProcRejectReason IN VARCHAR2 DEFAULT ' ' ,
  ------------------------ D2K Columns -----------------------    
  v_Timekey IN NUMBER DEFAULT 0 ,
  v_UserLoginID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_TaskName IN VARCHAR2 DEFAULT ' ' ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;
--DECLARE
--	 @BackACLProcEntityId    INT				= 1,    
--	 @JobName				VARCHAR(100)	= 'DWH_Backup',
--	 @ActionExecutionDate   VARCHAR(10)		= '02/02/2023',
--	 @BackACLProcStatus		VARCHAR(100)	= 'DISABLE',
--	 @Remarks				VARCHAR(1000)	= 'DWH_Backup JOB DISABLE',
--	 @OriginatorName		VARCHAR(100)	= 'SATWAJI YANNAWAR',    
--	 @OriginatorEmpId		VARCHAR(50)		= 'C33228',  
--	 @BackACLProcRejectReason	VARCHAR(1000)	= '',
--	 ------------------------ D2K Columns -----------------------    
--	 @Timekey				INT				= 26389,  
--	 @UserLoginID			VARCHAR(100)	= 'C28549',  
--	 @OperationFlag			INT				= 16,  
--	 @Result				INT				= 0 --OUTPUT

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
            v_BackACLProcEntityId1 NUMBER(10,0) := ( SELECT NVL(MAX(BackACLProcEntityId) , 0) + 1 
              FROM BackDatedACLProcDetail  );
            v_temp NUMBER(1, 0) := 0;

         BEGIN
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM BackDatedACLProcDetail 
                                WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND BackACLProcEntityId = v_BackACLProcEntityId );
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_temp = 1 THEN

            BEGIN
               IF ( v_OperationFlag = 16 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Approve');
                  UPDATE BackDatedACLProcDetail
                     SET AuthorisationStatus = 'A',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND BackACLProcEntityId = v_BackACLProcEntityId
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;

               END;
               END IF;
               IF ( v_OperationFlag = 17 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Reject');
                  UPDATE BackDatedACLProcDetail
                     SET AuthorisationStatus = 'R',
                         BackACLProcRejectReason = v_BackACLProcRejectReason,
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND BackACLProcEntityId = v_BackACLProcEntityId
                    AND AuthorisationStatus IN ( 'NP','MP' )
                  ;

               END;
               END IF;
               IF ( v_OperationFlag = 22 ) THEN

               BEGIN
                  DBMS_OUTPUT.PUT_LINE('Execute');
                  UPDATE BackDatedACLProcDetail
                     SET AuthorisationStatus = 'EX',
                         ApprovedBy = v_UserLoginID,
                         DateApproved = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND BackACLProcEntityId = v_BackACLProcEntityId
                    AND UTILS.CONVERT_TO_VARCHAR2(ActionExecutionDate,200,p_style=>103) = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200,p_style=>103)
                    AND AuthorisationStatus = ('A');

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
                                     FROM BackDatedACLProcDetail 
                                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                               AND EffectiveToTimeKey >= v_Timekey )
                                               AND EffectiveFromTimeKey = v_Timekey
                                               AND BackACLProcEntityId = v_BackACLProcEntityId );
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF v_temp = 1 THEN

                  BEGIN
                     /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                     DBMS_OUTPUT.PUT_LINE('SAME TIMEKEY');
                     UPDATE BackDatedACLProcDetail
                        SET ActionExecutionDate = UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103),
                            BackACLProcStatus = v_BackACLProcStatus,
                            Remarks = v_RequestReason,
                            OriginatorName = v_OriginatorName,
                            OriginatorEmpId = v_OriginatorEmpId,
                            BackACLProcRejectReason = v_BackACLProcRejectReason,
                            TaskName = v_TaskName,
                            AuthorisationStatus = 'MP',
                            EffectiveFromTimeKey = v_Timekey,
                            EffectiveToTimeKey = 49999,
                            ModifiedBy = v_UserLoginID,
                            DateModified = SYSDATE
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey )
                       AND BackACLProcEntityId = v_BackACLProcEntityId
                       AND AuthorisationStatus IN ( 'NP','MP' )
                     ;

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
                       FROM BackDatedACLProcDetail 
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                               AND EffectiveToTimeKey >= v_Timekey )
                               AND BackACLProcEntityId = v_BackACLProcEntityId;
                     /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                     DBMS_OUTPUT.PUT_LINE('INSERT LOG');
                     INSERT INTO BackDatedACLProcDetail
                       ( BackACLProcEntityId, ActionExecutionDate, BackACLProcStatus, Remarks, OriginatorName, OriginatorEmpId, BackACLProcRejectReason, TaskName, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified )
                       ( SELECT v_BackACLProcEntityId BackACLProcEntityId  ,
                                UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103) ActionExecutionDate  ,
                                v_BackACLProcStatus BackACLProcStatus  ,
                                v_RequestReason RequestReason  ,
                                v_OriginatorName ,
                                v_OriginatorEmpId ,
                                v_BackACLProcRejectReason BackACLProcRejectReason  ,
                                v_TaskName ,
                                'MP' AuthorisationStatus  ,
                                v_TimeKey EffectiveFomTimeKey  ,
                                49999 EffectiveToTimeKey  ,
                                v_CreatedBy ,
                                v_DateCreated ,
                                v_UserLoginId ModifiedBy  ,
                                SYSDATE DateModified  
                           FROM DUAL  );
                     --FROM BackDatedACLProcDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)   
                     --AND BackACLProcEntityId=@BackACLProcEntityId    
                     DBMS_OUTPUT.PUT_LINE('EXPIRE OLD RECORD');
                     UPDATE BackDatedACLProcDetail
                        SET AuthorisationStatus = 'FM',
                            EffectiveToTimeKey = v_Timekey - 1
                      WHERE  ( EffectiveFromTimeKey <= v_Timekey
                       AND EffectiveToTimeKey >= v_Timekey )
                       AND BackACLProcEntityId = v_BackACLProcEntityId
                       AND EffectiveFromTimeKey < v_Timekey;

                  END;
                  END IF;

               END;
               END IF;

            END;
            ELSE

            BEGIN
               /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
               DBMS_OUTPUT.PUT_LINE('INSERT LOG');
               INSERT INTO BackDatedACLProcDetail
                 ( BackACLProcEntityId, ActionExecutionDate, BackACLProcStatus, Remarks, OriginatorName, OriginatorEmpId, BackACLProcRejectReason, TaskName, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                 ( SELECT v_BackACLProcEntityId1 BackACLProcEntityId  ,
                          UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103) ActionExecutionDate  ,
                          v_BackACLProcStatus BackACLProcStatus  ,
                          v_RequestReason RequestReason  ,
                          v_OriginatorName ,
                          v_OriginatorEmpId ,
                          v_BackACLProcRejectReason BackACLProcRejectReason  ,
                          v_TaskName ,
                          'NP' AuthorisationStatus  ,
                          v_TimeKey EffectiveFromTimeKey  ,
                          49999 EffectiveToTimeKey  ,
                          v_UserLoginId CreatedBy  ,
                          SYSDATE DateCreated  
                     FROM DUAL  );

            END;
            END IF;
            --FROM BackDatedACLProcDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)   
            --AND BackACLProcEntityId=@BackACLProcEntityId    
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."BACKDATEDACLPROCDETAILINUP" TO "ADF_CDR_RBL_STGDB";
