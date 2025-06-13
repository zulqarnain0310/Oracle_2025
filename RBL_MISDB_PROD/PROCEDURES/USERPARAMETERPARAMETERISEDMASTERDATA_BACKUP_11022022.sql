--------------------------------------------------------
--  DDL for Procedure USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- =============================================
 -- Author:		<Author,,Name>
 -- Create date: <Create Date,,>
 -- Description:	<Description,,>
 -- =============================================
 --exec UserParameterParameterisedMasterData 'Y','Y',24957

(
  v_blnFetchMetaData IN CHAR,
  v_blnFetchMasterData IN CHAR,
  iv_TimeKey IN NUMBER
)
AS
   v_TimeKey NUMBER(5,0) := iv_TimeKey;
   v_cursor SYS_REFCURSOR;

 -- NITIN : 21 DEC 2010
BEGIN

   --DECLARE @TimeKey AS SMALLINT -- NITIN : 21 DEC 2010
   SELECT Timekey 

     INTO v_TimeKey
     FROM SysDayMatrix 
    WHERE  UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200) = UTILS.CONVERT_TO_VARCHAR2(date_,200);-- NITIN : 21 DEC 2010
   OPEN  v_cursor FOR
      SELECT CtrlName ,
             FldName ,
             FldCaption ,
             FldDataType ,
             FldLength ,
             ErrorCheck ,
             DataSeq ,
             CriticalErrorType ,
             MsgFlag ,
             MsgDescription ,
             ReportFieldNo ,
             ScreenFieldNo ,
             ViableForSCD2 
        FROM metaUserFieldDetail 
       WHERE  FrmName = 'frmUserPolicy' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   --SELECT 
   --SeqNo,
   --ParameterType,
   --ParameterValue,
   --ShortNameEnum,
   --MinValue,
   --MaxValue,
   --EffectiveFromTimeKey,
   --EffectiveToTimeKey,
   --AuthorisationStatus ,
   --'N' AS IsMainTable
   --from DimUserParameters 
   -- WHERE (DimUserParameters.EffectiveFromTimeKey <=@TimeKey AND DimUserParameters.EffectiveToTimekey>=@TimeKey) 
   -- ORDER BY SeqNo
   --------------------------
   IF utils.object_id('Tempdb..tt_temp_303') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_303 ';
   END IF;
   DELETE FROM tt_temp_303;
   UTILS.IDENTITY_RESET('tt_temp_303');

   INSERT INTO tt_temp_303 ( 
   	SELECT 
           --SeqNo,

           --ParameterType,

           --ParameterValue,

           --ShortNameEnum,

           --MinValue,

           --MaxValue,

           --EffectiveFromTimeKey,

           --EffectiveToTimeKey,

           --AuthorisationStatus ,

           --IsMainTable,

           --CreatedModifiedBy
           * 
   	  FROM ( SELECT SeqNo ,
                    ParameterType ,
                    ParameterValue ,
                    ShortNameEnum ,
                    MinValue ,
                    MaxValue ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    SR.AuthorisationStatus ,
                    'N' IsMainTable  ,
                    CASE 
                         WHEN NVL(SR.ModifyBy, ' ') = ' ' THEN SR.CreatedBy
                    ELSE SR.ModifyBy
                       END CreatedModifiedBy  
             FROM RBL_MISDB_PROD.DimUserParameters_mod SR
                    JOIN ( SELECT AuthorisationStatus 
                           FROM RBL_MISDB_PROD.DimUserParameters_mod SER
                                  JOIN ( SELECT MAX(EntityKey)  EntityKey  
   	  FROM RBL_MISDB_PROD.DimUserParameters_mod SR
   	 WHERE  AuthorisationStatus IN ( 'NP','MP','DP','RM' )

              AND ( SR.EffectiveFromTimeKey <= v_TimeKey
              AND SR.EffectiveToTimeKey >= v_TimeKey )

   	--AND SR.AssetBlockAlt_key=@AssetBlockAlt_key 
   	GROUP BY EntityKey ) A   ON ( SER.EffectiveFromTimeKey <= v_TimeKey
                                  AND SER.EffectiveToTimeKey >= v_TimeKey )
                                  AND A.EntityKey = SER.EntityKey
                                --AND SER.AssetBlockAlt_key=@AssetBlockAlt_key 
                                 --GROUP BY AuthorisationStatus		
                          ) S   ON ( SR.EffectiveFromTimeKey <= v_TimeKey
                    AND SR.EffectiveToTimeKey >= v_TimeKey )
                    AND SR.AuthorisationStatus = S.AuthorisationStatus
             UNION 

             --WHERE AssetBlockAlt_key = @AssetBlockAlt_key 

             --AND (SR.EffectiveFromTimeKey <=@TimeKey AND SR.EffectiveToTimeKey >=@TimeKey )
             SELECT SeqNo ,
                    ParameterType ,
                    ParameterValue ,
                    ShortNameEnum ,
                    MinValue ,
                    MaxValue ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    AuthorisationStatus ,
                    'Y' IsMainTable  ,
                    CASE 
                         WHEN NVL(SR.ModifyBy, ' ') = ' ' THEN SR.CreatedBy
                    ELSE SR.ModifyBy
                       END CreatedModifiedBy  
             FROM RBL_MISDB_PROD.DimUserParameters SR
              WHERE  NVL(AuthorisationStatus, 'A') = 'A'
                       AND ( SR.EffectiveFromTimeKey <= v_TimeKey
                       AND SR.EffectiveToTimeKey >= v_TimeKey ) ) Temp );
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_temp_303  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ------------------------------
   --SELECT MsgDescription  
   --		,ParameterType
   --		,ParameterValue
   --		,MinValue
   --		,MaxValue
   --		,'N' AS IsMainTable
   --		FROM metaUserFieldDetail  meta
   --		INNER JOIN DimUserParameters dimUser
   --		ON meta.FldCaption = dimUser.ShortNameEnum
   --		WHERE FrmName ='frmUserPolicy' 
   --		AND (dimUser.EffectiveFromTimeKey <=@TimeKey AND dimUser.EffectiveToTimekey>=@TimeKey) 
   --		ORDER BY SeqNo
   OPEN  v_cursor FOR
      SELECT MsgDescription ,
             ParameterType ,
             ParameterValue ,
             MinValue ,
             MaxValue ,
             IsMainTable ,
             CreatedModifiedBy ,
             --,SeqNo
             'HO' UserLocation  
        FROM metaUserFieldDetail meta
               JOIN tt_temp_303 dimUser   ON meta.FldCaption = dimUser.ShortNameEnum

      --left join DimUserInfo D

      --ON D.UserLoginID=dimuser.CreatedModifiedBy
      WHERE  FrmName = 'frmUserPolicy'
               AND ( dimUser.EffectiveFromTimeKey <= v_TimeKey
               AND dimUser.EffectiveToTimekey >= v_TimeKey )

      --AND SeqNo IN (1,6)
      GROUP BY MsgDescription,ParameterType,ParameterValue,MinValue,MaxValue,IsMainTable,CreatedModifiedBy,SeqNo
        ORDER BY SeqNo ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERPARAMETERPARAMETERISEDMASTERDATA_BACKUP_11022022" TO "ADF_CDR_RBL_STGDB";
