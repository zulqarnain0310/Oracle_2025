--------------------------------------------------------
--  DDL for Function ACLJOBEXECDETAILINUP_04122023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" 
(
  v_ACLJobExecEntityId IN NUMBER DEFAULT NULL ,
  v_RcaId IN NUMBER DEFAULT NULL ,
  v_JobName IN VARCHAR2 DEFAULT ' ' ,
  v_ACLJobStepNumber IN VARCHAR2 DEFAULT ' ' ,
  v_DateofData IN VARCHAR2 DEFAULT ' ' ,
  v_ActionExecutionDate IN VARCHAR2 DEFAULT ' ' ,
  v_ACLJobExecStatus IN VARCHAR2 DEFAULT ' ' ,
  v_Remarks IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorName IN VARCHAR2 DEFAULT ' ' ,
  v_OriginatorEmpId IN VARCHAR2 DEFAULT ' ' ,
  v_ACLExecRejectReason IN VARCHAR2 DEFAULT ' ' ,
  v_IP_Address IN VARCHAR2 DEFAULT ' ' ,
  v_AttachedFilePath IN VARCHAR2 DEFAULT ' ' ,
  ------------------------ D2K Columns -----------------------    
  v_Timekey IN NUMBER DEFAULT 0 ,
  v_UserLoginID IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
RETURN NUMBER
AS
   v_cursor SYS_REFCURSOR;
--DECLARE
--	 @ACLJobExecEntityId    INT				= 1,    
--	 @JobName				VARCHAR(100)	= 'DWH_Backup',
--	 @ActionExecutionDate   VARCHAR(10)		= '02/02/2023',
--	 @ACLJobExecStatus		VARCHAR(100)	= 'DISABLE',
--	 @Remarks				VARCHAR(1000)	= 'DWH_Backup JOB DISABLE',
--	 @OriginatorName		VARCHAR(100)	= 'SATWAJI YANNAWAR',    
--	 @OriginatorEmpId		VARCHAR(50)		= 'C33228',  
--	 @ACLExecRejectReason	VARCHAR(1000)	= '',
--	 ------------------------ D2K Columns -----------------------    
--	 @Timekey				INT				= 26389,  
--	 @UserLoginID			VARCHAR(100)	= 'C28549',  
--	 @OperationFlag			INT				= 16,  
--	 @Result				INT				= 0 --OUTPUT

BEGIN

   BEGIN
      DECLARE
         -- BEGIN TRANSACTION    
         v_ACLJobExecEntityId1 NUMBER(10,0) := ( SELECT NVL(MAX(ACLJobExecEntityId) , 0) + 1 
           FROM ACLJobExecDetail  );
         v_temp NUMBER(1, 0) := 0;

      BEGIN
         /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
         BEGIN
            SELECT 1 INTO v_temp
              FROM DUAL
             WHERE EXISTS ( SELECT 1 
                            FROM ACLJobExecDetail 
                             WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                      AND EffectiveToTimeKey >= v_Timekey )
                                      AND ACLJobExecEntityId = v_ACLJobExecEntityId );
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF v_temp = 1 THEN

         BEGIN
            IF ( v_OperationFlag = 16 ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Approve');
               UPDATE ACLJobExecDetail
                  SET AuthorisationStatus = 'A',
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  ( EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey )
                 AND ACLJobExecEntityId = v_ACLJobExecEntityId
                 AND AuthorisationStatus IN ( 'NP','MP' )
               ;

            END;
            END IF;
            IF ( v_OperationFlag = 17 ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Reject');
               UPDATE ACLJobExecDetail
                  SET AuthorisationStatus = 'R',
                      ACLExecRejectReason = v_ACLExecRejectReason,
                      ApprovedBy = v_UserLoginID,
                      DateApproved = SYSDATE
                WHERE  ( EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey )
                 AND ACLJobExecEntityId = v_ACLJobExecEntityId
                 AND AuthorisationStatus IN ( 'NP','MP' )
               ;

            END;
            END IF;
            IF ( v_OperationFlag = 22 ) THEN

            BEGIN
               DBMS_OUTPUT.PUT_LINE('Execute');
               UPDATE ACLJobExecDetail
                  SET AuthorisationStatus = 'EX',
                      ExecutedBy = v_UserLoginID,
                      DateExecuted = SYSDATE
                WHERE  ( EffectiveFromTimeKey <= v_Timekey
                 AND EffectiveToTimeKey >= v_Timekey )
                 AND ACLJobExecEntityId = v_ACLJobExecEntityId

                 --AND CONVERT(DATE,ActionExecutionDate,103)=CONVERT(DATE,GETDATE(),103)
                 AND AuthorisationStatus IN ( 'NP','MP' )
               ;

            END;
            END IF;
            --AND AuthorisationStatus='A'
            IF ( v_OperationFlag = 2 ) THEN
             DECLARE
               v_temp NUMBER(1, 0) := 0;

            BEGIN
               DBMS_OUTPUT.PUT_LINE('UPDATE LOG');
               BEGIN
                  SELECT 1 INTO v_temp
                    FROM DUAL
                   WHERE EXISTS ( SELECT 1 
                                  FROM ACLJobExecDetail 
                                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                            AND EffectiveToTimeKey >= v_Timekey )
                                            AND EffectiveFromTimeKey = v_Timekey
                                            AND ACLJobExecEntityId = v_ACLJobExecEntityId );
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_temp = 1 THEN

               BEGIN
                  /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                  DBMS_OUTPUT.PUT_LINE('SAME TIMEKEY');
                  UPDATE ACLJobExecDetail
                     SET JobName = v_JobName,
                         JobStepName = v_ACLJobStepNumber,
                         RCA_ID = v_RcaId,
                         DateofData = UTILS.CONVERT_TO_VARCHAR2(v_DateofData,200,p_style=>103),
                         ActionExecutionDate = UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103),
                         ACLJobExecStatus = v_ACLJobExecStatus,
                         Remarks = v_Remarks,
                         OriginatorName = v_OriginatorName,
                         OriginatorEmpId = v_OriginatorEmpId,
                         ACLExecRejectReason = v_ACLExecRejectReason,
                         IP_Address = v_IP_Address,
                         AuthorisationStatus = 'MP',
                         EffectiveFromTimeKey = v_Timekey,
                         EffectiveToTimeKey = 49999,
                         ModifiedBy = v_UserLoginID,
                         DateModified = SYSDATE
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND ACLJobExecEntityId = v_ACLJobExecEntityId
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
                    FROM ACLJobExecDetail 
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                            AND EffectiveToTimeKey >= v_Timekey )
                            AND ACLJobExecEntityId = v_ACLJobExecEntityId;
                  /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
                  DBMS_OUTPUT.PUT_LINE('INSERT LOG');
                  INSERT INTO ACLJobExecDetail
                    ( ACLJobExecEntityId, RCA_ID, JobName, JobStepName, DateofData, ActionExecutionDate, ACLJobExecStatus, Remarks, OriginatorName, OriginatorEmpId, ACLExecRejectReason, IP_Address, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified )
                    ( SELECT v_ACLJobExecEntityId ACLJobExecEntityId  ,
                             v_RcaId ,
                             v_JobName ,
                             v_ACLJobStepNumber ,
                             UTILS.CONVERT_TO_VARCHAR2(v_DateofData,200,p_style=>103) DateofData  ,
                             UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103) ActionExecutionDate  ,
                             v_ACLJobExecStatus ACLJobExecStatus  ,
                             v_Remarks Remarks  ,
                             v_OriginatorName ,
                             v_OriginatorEmpId ,
                             v_ACLExecRejectReason ACLExecRejectReason  ,
                             v_IP_Address ,
                             'MP' AuthorisationStatus  ,
                             v_TimeKey EffectiveFomTimeKey  ,
                             49999 EffectiveToTimeKey  ,
                             v_CreatedBy ,
                             v_DateCreated ,
                             v_UserLoginId ModifiedBy  ,
                             SYSDATE DateModified  
                        FROM DUAL  );
                  --FROM ACLJobExecDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)   
                  --AND ACLJobExecEntityId=@ACLJobExecEntityId    
                  DBMS_OUTPUT.PUT_LINE('EXPIRE OLD RECORD');
                  UPDATE ACLJobExecDetail
                     SET AuthorisationStatus = 'FM',
                         EffectiveToTimeKey = v_Timekey - 1
                   WHERE  ( EffectiveFromTimeKey <= v_Timekey
                    AND EffectiveToTimeKey >= v_Timekey )
                    AND ACLJobExecEntityId = v_ACLJobExecEntityId
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
            /*TODO:SQLDEV*/ SET DATEFORMAT DMY /*END:SQLDEV*/
            ---------- IMPLEMENT LOGIC TO CHECK IF RECORD IS ALREDY AVAILABLE IN LOG TABLE OR NOT BY SATWAJI AS ON 31/05/2023 -----------------------------------------
            BEGIN
               SELECT 1 INTO v_temp
                 FROM DUAL
                WHERE EXISTS ( SELECT 1 
                               FROM ACLJobExecDetail 
                                WHERE  ( EffectiveFromTimeKey <= v_Timekey
                                         AND EffectiveToTimeKey >= v_Timekey )
                                         AND JobName = v_JobName
                                         AND DateofData = v_DateofData
                                         AND ActionExecutionDate = v_ActionExecutionDate
                                         AND ACLJobExecStatus = v_ACLJobExecStatus
                                         AND Remarks = v_Remarks );
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
               DBMS_OUTPUT.PUT_LINE('INSERT LOG');
               INSERT INTO ACLJobExecDetail
                 ( ACLJobExecEntityId, RCA_ID, JobName, JobStepName, DateofData, ActionExecutionDate, ACLJobExecStatus, Remarks, OriginatorName, OriginatorEmpId, ACLExecRejectReason, IP_Address, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated )
                 ( SELECT v_ACLJobExecEntityId1 ACLJobExecEntityId  ,
                          v_RcaId ,
                          v_JobName ,
                          v_ACLJobStepNumber ,
                          UTILS.CONVERT_TO_VARCHAR2(v_DateofData,200,p_style=>103) DateofData  ,
                          UTILS.CONVERT_TO_VARCHAR2(v_ActionExecutionDate,200,p_style=>103) ActionExecutionDate  ,
                          v_ACLJobExecStatus ACLJobExecStatus  ,
                          v_Remarks Remarks  ,
                          v_OriginatorName ,
                          v_OriginatorEmpId ,
                          v_ACLExecRejectReason ACLExecRejectReason  ,
                          v_IP_Address ,
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
         --FROM ACLJobExecDetail WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)   
         --AND ACLJobExecEntityId=@ACLJobExecEntityId
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

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLJOBEXECDETAILINUP_04122023" TO "ADF_CDR_RBL_STGDB";
