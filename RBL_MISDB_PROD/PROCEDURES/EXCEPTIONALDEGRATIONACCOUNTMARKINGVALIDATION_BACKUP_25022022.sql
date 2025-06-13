--------------------------------------------------------
--  DDL for Procedure EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" 
(
  v_CustomerACID IN VARCHAR2 DEFAULT NULL ,
  v_FlagAlt_Key IN VARCHAR2 DEFAULT NULL ,
  v_MarkingAlt_Key IN NUMBER
)
AS
   v_Timekey NUMBER(10,0);
   --Select 
   --'' As SourceAlt_Key
   --,''As CustomerID
   --,''As ACID
   --,'' As StatusType
   --,'' As StatusDate
   --,''As Amount
   --,'CustExceptionFinalStatusType'as TableName
   v_cursor SYS_REFCURSOR;

BEGIN

   --Set @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')
   --10  add 20 remove
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   IF v_MarkingAlt_Key = 20 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

    ----addd
   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT AccountID 
                             FROM ExceptionalDegrationDetail_Mod 
                              WHERE  MarkingAlt_Key = v_MarkingAlt_Key
                                       AND EffectiveFromTimeKey <= v_Timekey
                                       AND EffectiveToTimeKey >= v_Timekey
                                       AND FlagAlt_Key = v_FlagAlt_Key
                                       AND AccountID = v_CustomerACID
                                       AND AuthorisationStatus IN ( 'NP','MP','1A' )

                             UNION 
                             SELECT ACID 
                             FROM AccountFlaggingDetails_Mod 
                              WHERE  ACTION = 'Y'
                                       AND EffectiveFromTimeKey <= v_Timekey
                                       AND EffectiveToTimeKey >= v_Timekey
                                       AND UploadTypeParameterAlt_Key = v_FlagAlt_Key
                                       AND Acid = v_CustomerACID
                                       AND AuthorisationStatus IN ( 'NP','MP','1A' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT SourceAlt_Key ,
                   CustomerID ,
                   ACID ,
                   StatusType ,
                   --,D.ParameterName
                   StatusDate ,
                   Amount ,
                   'YCustExceptionFinalStatusType' TableName  
              FROM ExceptionFinalStatusType E
                     JOIN DimParameter D   ON E.StatusType = D.ParameterName
                     AND D.EffectiveToTimeKey = 49999
                     AND D.DimParameterName = 'UploadFLagType'
             WHERE  ACID = v_CustomerACID
                      AND D.ParameterAlt_Key = v_FlagAlt_Key
                      AND E.EffectiveToTimeKey = 49999 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT ' ' SourceAlt_Key  ,
                   ' ' CustomerID  ,
                   ' ' ACID  ,
                   ' ' StatusType  ,
                   ' ' StatusDate  ,
                   ' ' Amount  ,
                   'YCustExceptionFinalStatusType' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   --Select 
   --SourceAlt_Key
   --,CustomerID
   --,ACID
   --,StatusType
   ----,D.ParameterName
   --,StatusDate
   --,Amount
   --,'CustExceptionFinalStatusType'as TableName
   --from ExceptionFinalStatusType E
   --inner join DimParameter D on E.statustype=D.ParameterName And D.EffectiveToTimeKey=49999
   --And D.DimParameterName='UploadFLagType'
   --where ACID=@CustomerACID And D.ParameterAlt_Key=@FlagAlt_Key
   --And E.EffectiveToTimeKey=49999
   IF v_MarkingAlt_Key = 10 THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

    ---Remove 
   BEGIN
      --IF Not Exists(
      --			select AccountID from ExceptionalDegrationDetail_Mod 
      --			where MarkingAlt_Key=@MarkingAlt_Key and EffectiveFromTimeKey<=@Timekey
      --				and	EffectiveToTimeKey>=@Timekey and  FlagAlt_Key=@FlagAlt_Key and AccountID=@CustomerACID
      --				And AuthorisationStatus in ('NP','MP','1A')
      --UNION
      --Select ACID from AccountFlaggingDetails_Mod
      --where Action='N'and EffectiveFromTimeKey<=@Timekey
      --				and	EffectiveToTimeKey>=@Timekey
      --and UploadTypeParameterAlt_Key=@FlagAlt_Key
      --and Acid=@CustomerACID
      --And AuthorisationStatus in ('NP','MP','1A')
      --)
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT ACID 
                             FROM ExceptionFinalStatusType E
                                    JOIN DimParameter D   ON E.statustype = D.ParameterName
                                    AND D.EffectiveToTimeKey = 49999
                                    AND D.DimParameterName = 'UploadFLagType'
                              WHERE  E.EffectiveFromTimeKey <= v_Timekey
                                       AND E.EffectiveToTimeKey >= v_Timekey
                                       AND D.ParameterAlt_Key = v_FlagAlt_Key
                                       AND ACID = v_CustomerACID
                                       AND NVL(E.AuthorisationStatus, 'A') IN ( 'A' )
       );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT ' ' SourceAlt_Key  ,
                   ' ' CustomerID  ,
                   ' ' ACID  ,
                   ' ' StatusType  ,
                   ' ' StatusDate  ,
                   ' ' Amount  ,
                   'YCustExceptionFinalStatusType' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT SourceAlt_Key ,
                   CustomerID ,
                   ACID ,
                   StatusType ,
                   StatusDate ,
                   Amount ,
                   'NCustExceptionFinalStatusType' TableName  
              FROM ExceptionFinalStatusType E
                     JOIN DimParameter D   ON E.StatusType = D.ParameterName
                     AND D.EffectiveToTimeKey = 49999
                     AND D.DimParameterName = 'UploadFLagType'
             WHERE  ACID = v_CustomerACID
                      AND D.ParameterAlt_Key = v_FlagAlt_Key
                      AND E.EffectiveToTimeKey = 49999 ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTMARKINGVALIDATION_BACKUP_25022022" TO "ADF_CDR_RBL_STGDB";
