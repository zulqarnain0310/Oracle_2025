--------------------------------------------------------
--  DDL for Procedure EXCEPTIONDEGRADATION_HISTORY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" 
(
  v_AccountID IN VARCHAR2
)
AS
   --Declare @AccountID varchar(30)='1002035020000138'
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF utils.object_id('Tempdb..tt_FINAL') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_FINAL ';
   END IF;
   DELETE FROM tt_FINAL;
   UTILS.IDENTITY_RESET('tt_FINAL');

   INSERT INTO tt_FINAL ( 
   	SELECT 'S' Flag  ,
           S.SourceName ,
           AccountID AccountID  ,
           E.CustomerID ,
           F.ParameterName FlagDesciption  ,
           Date_ ,
           E.Amount ,
           H.ParameterName MarkingDescription  ,
           A.CreatedBy ,
           A.DateCreated ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel ,
           A.ApprovedBy ,
           A.DateApproved 

   	  --select *
   	  FROM ExceptionFinalStatusType E
             LEFT JOIN RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod A   ON E.ACID = A.AccountID
             LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                ParameterName 
                         FROM DimParameter A
                          WHERE  DimParameterName = 'UploadFLagType'

                                   --and          ParameterAlt_Key in (1,3,9,17,18,19)
                                   AND A.EffectiveFromTimeKey <= v_Timekey
                                   AND A.EffectiveToTimeKey >= v_Timekey ) F   ON F.ParameterAlt_Key = A.FlagAlt_Key
             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                ParameterName ,
                                'DimYesNo' Tablename  
                         FROM DimParameter 
                          WHERE  DimParameterName = 'DimYesNo'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.MarkingAlt_Key
   	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
              AND A.EffectiveToTimeKey >= v_TimeKey
              AND E.EffectiveFromTimeKey <= v_TimeKey
              AND E.EffectiveToTimeKey >= v_TimeKey
              AND A.AccountID = v_AccountID
              AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                    FROM RBL_MISDB_PROD.ExceptionalDegrationDetail_Mod 
                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey
                                              AND NVL(AuthorisationStatus, 'A') IN ( 'A' )

                                      GROUP BY AccountID,FlagAlt_Key )

   	UNION ALL 
   	SELECT 'U' Flag  ,
           S.SourceName ,
           E.ACID AccountID  ,
           B.RefCustomerId CustomerId  ,
           F.ParameterName FlagDesciption  ,
           Date_ ,
           E.Amount ,
           A.ACTION MarkingDescription  ,
           A.CreatedBy ,
           A.DateCreated ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel ,
           A.ApprovedBy ,
           A.DateApproved 

   	  --select *
   	  FROM ExceptionFinalStatusType E
             JOIN AccountFlaggingDetails_Mod A   ON E.ACID = A.ACID
             LEFT JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.ACID = B.SystemACID
             AND B.EffectiveFromTimeKey <= v_TimeKey
             AND B.EffectiveToTimeKey >= v_TimeKey
             AND E.EffectiveFromTimeKey <= v_TimeKey
             AND E.EffectiveToTimeKey >= v_TimeKey
             LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = B.SourceAlt_Key
             AND S.EffectiveToTimeKey = 49999
             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                ParameterName 
                         FROM DimParameter A
                          WHERE  DimParameterName = 'UploadFLagType'

                                   --and          ParameterAlt_Key in (1,3,9,17,18,19)
                                   AND A.EffectiveFromTimeKey <= v_Timekey
                                   AND A.EffectiveToTimeKey >= v_Timekey ) F   ON F.ParameterAlt_Key = A.UploadTypeParameterAlt_Key
   	 WHERE  A.EffectiveFromTimeKey <= v_TimeKey
              AND A.EffectiveToTimeKey >= v_TimeKey
              AND A.ACID = v_AccountID
              AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                    FROM RBL_MISDB_PROD.AccountFlaggingDetails_Mod 
                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey
                                              AND NVL(AuthorisationStatus, 'A') IN ( 'A' )

                                      GROUP BY acid,UploadTypeParameterAlt_Key )
    );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_FINAL 
       WHERE  ApprovedByFirstLevel IS NOT NULL ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select distinct Accountid,* from #Final
   --Select  * from ExceptionalDegrationDetail_Mod where AccountID='1002035020000138'
   --Select   * from AccountFlaggingDetails_Mod where acid='1002035020000138'
   --Select * from ExceptionFinalStatusType where acid='1002035020000138'

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONDEGRADATION_HISTORY" TO "ADF_CDR_RBL_STGDB";
