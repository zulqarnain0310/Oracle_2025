--------------------------------------------------------
--  DDL for Procedure INTERFACEAUTHOLEVELINSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_EntityId IN NUMBER,
  v_NewAuthenticationLevelAlt_Key IN NUMBER,
  v_NewAuthenticationLevel IN VARCHAR2,
  v_1stLevelApprovedBy IN VARCHAR2,
  v_2ndLevelApprovedBy IN VARCHAR2,
  v_AuthorisationStatus IN VARCHAR2 DEFAULT NULL ,
  iv_EffectiveFromTimeKey IN NUMBER DEFAULT 0 ,
  iv_EffectiveToTimeKey IN NUMBER DEFAULT 0 ,
  v_CreatedBy IN VARCHAR2 DEFAULT NULL ,
  v_DateCreated IN DATE DEFAULT NULL ,
  v_ModifiedBy IN VARCHAR2 DEFAULT NULL ,
  v_DateModified IN DATE DEFAULT NULL ,
  v_ApprovedBy IN VARCHAR2 DEFAULT NULL ,
  v_DateApproved IN DATE DEFAULT NULL ,
  v_OperationFlag IN NUMBER DEFAULT 0 ,
  v_Result OUT NUMBER/* DEFAULT 0*/
)
AS
   v_EffectiveFromTimeKey NUMBER(10,0) := iv_EffectiveFromTimeKey;
   v_EffectiveToTimeKey NUMBER(10,0) := iv_EffectiveToTimeKey;
   --	SET NOCOUNT ON;
   --		PRINT 1
   --		SET DATEFORMAT DMY
   --@AuthorisationStatus		varchar(5)			= NULL 
   --,@CreatedBy					VARCHAR(20)		= NULL
   --,@DateCreated				SMALLDATETIME	= NULL
   --,@ModifiedBy				VARCHAR(20)		= NULL
   --,@DateModified				SMALLDATETIME	= NULL
   --,@ApprovedBy				VARCHAR(20)		= NULL
   --,@DateApproved				SMALLDATETIME	= NULL
   v_ErrorHandle NUMBER(10,0) := 0;
   v_ExEntityKey NUMBER(10,0) := 0;
   ------------Added for Rejection Screen  29/06/2020   ----------
   --DECLARE			
   v_Uniq_EntryID NUMBER(10,0) := 0;
   v_RejectedBY VARCHAR2(50) := NULL;
   v_RemarkBy VARCHAR2(50) := NULL;
   v_RejectRemark VARCHAR2(200) := NULL;
   v_ScreenName VARCHAR2(200) := NULL;
   v_Entity_Key NUMBER(10,0);
   v_ValuationDateChar VARCHAR2(12);
   v_TimeKey NUMBER(10,0);

BEGIN

   --SET @ScreenName = 'Collateral'
   -------------------------------------------------------------
   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   v_EffectiveFromTimeKey := v_TimeKey ;
   v_EffectiveToTimeKey := 49999 ;
   --AS
   IF ( v_OperationFlag = 1 ) THEN

   BEGIN
      INSERT INTO InterfaceAuthoLevel
        ( EntityId, NewAuthenticationLevelAlt_Key, NewAuthenticationLevel, A1stLevelApprovedBy, A2ndLevelApprovedBy, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
        ( SELECT v_EntityId ,
                 v_NewAuthenticationLevelAlt_Key ,
                 v_NewAuthenticationLevel ,
                 v_1stLevelApprovedBy ,
                 v_2ndLevelApprovedBy ,
                 v_AuthorisationStatus ,
                 v_EffectiveFromTimeKey ,
                 v_EffectiveToTimeKey ,
                 v_CreatedBy ,
                 v_DateCreated ,
                 v_ModifiedBy ,
                 v_DateModified ,
                 v_ApprovedBy ,
                 v_DateApproved 
            FROM DUAL  );

   END;
   END IF;

   BEGIN
      v_Result := 0 ;

   END;

   BEGIN
      v_Result := 1 ;

   END;
   IF ( v_OperationFlag = 2 ) THEN

   BEGIN
      SELECT MAX(Entity_Key)  

        INTO v_Entity_Key
        FROM InterfaceAuthoLevel 
       WHERE  NewAuthenticationLevelAlt_Key = v_NewAuthenticationLevelAlt_Key;
      UPDATE InterfaceAuthoLevel
         SET EffectiveFromTimeKey = v_Timekey - 1,
             EffectiveToTimeKey = v_Timekey - 1
       WHERE  Entity_Key = v_Entity_Key;

      BEGIN
         INSERT INTO InterfaceAuthoLevel
           ( EntityId, NewAuthenticationLevelAlt_Key, NewAuthenticationLevel, A1stLevelApprovedBy, A2ndLevelApprovedBy, AuthorisationStatus, EffectiveFromTimeKey, EffectiveToTimeKey, CreatedBy, DateCreated, ModifiedBy, DateModified, ApprovedBy, DateApproved )
           ( SELECT v_EntityId ,
                    v_NewAuthenticationLevelAlt_Key ,
                    v_NewAuthenticationLevel ,
                    v_1stLevelApprovedBy ,
                    v_2ndLevelApprovedBy ,
                    v_AuthorisationStatus ,
                    v_EffectiveFromTimeKey ,
                    v_EffectiveToTimeKey ,
                    v_CreatedBy ,
                    v_DateCreated ,
                    v_ModifiedBy ,
                    v_DateModified ,
                    v_ApprovedBy ,
                    v_DateApproved 
               FROM DUAL  );

      END;

      BEGIN
         v_Result := 0 ;

      END;

      BEGIN
         v_Result := 1 ;

      END;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INTERFACEAUTHOLEVELINSERT" TO "ADF_CDR_RBL_STGDB";
