--------------------------------------------------------
--  DDL for Procedure COLLATERALCODESEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" 
(
  v_CollateralCode IN VARCHAR2 DEFAULT ' ' ,
  v_CollateralDescription IN VARCHAR2 DEFAULT ' ' ,
  --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
    v_SQLERRM VARCHAR(1000);
    v_SQLCODE VARCHAR(1000);

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag <> 16 ) THEN

         BEGIN
            IF utils.object_id('TempDB..GTT_TEMP_COL_CODE') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP_COL_CODE ';
            END IF;
            DELETE FROM GTT_TEMP_COL_CODE;
            UTILS.IDENTITY_RESET('GTT_TEMP_COL_CODE');

            INSERT INTO GTT_TEMP_COL_CODE ( 
            	SELECT A.CollateralCodeAltKey ,
                    A.CollateralCode ,
                    A.CollateralDescription ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified 
            	  FROM ( SELECT A.CollateralCodeAltKey ,
                             A.CollateralCode ,
                             A.CollateralDescription ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM DimCollateralCode A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.CollateralCodeAltKey ,
                             A.CollateralCode ,
                             A.CollateralDescription ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM DimCollateralCode_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimCollateralCode_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY CollateralCodeAltKey )
                     ) A
            	  GROUP BY A.CollateralCodeAltKey,A.CollateralCode,A.CollateralDescription,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralCodeAltKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralCodeMaster' TableName  ,
                               COLLATERALCODEALTKEY,	COLLATERALCODE,	COLLATERALDESCRIPTION,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	APPROVEDBY,	DATEAPPROVED,	MODIFIEDBY,	DATEMODIFIED
                        FROM ( SELECT * 
                               FROM GTT_TEMP_COL_CODE A
                                WHERE  NVL(CollateralCode, ' ') LIKE '%' || v_CollateralCode || '%'
                                         AND NVL(CollateralDescription, ' ') LIKE '%' || v_CollateralDescription || '%' ) DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize)
         ELSE

          /*  IT IS Used For GRID Search which are Pending for Authorization    */
         BEGIN
            IF utils.object_id('TempDB..GTT_TEMP_COL_CODE16') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE GTT_TEMP_COL_CODE ';
            END IF;
            DELETE FROM GTT_TEMP_COL_CODE;
            UTILS.IDENTITY_RESET('GTT_TEMP_COL_CODE');

            INSERT INTO GTT_TEMP_COL_CODE ( 
            	SELECT A.CollateralCodeAltKey ,
                    A.CollateralCode ,
                    A.CollateralDescription ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified 
            	  FROM ( SELECT A.CollateralCodeAltKey ,
                             A.CollateralCode ,
                             A.CollateralDescription ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM DimCollateralCode_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimCollateralCode_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY CollateralCodeAltKey )
                     ) A
            	  GROUP BY A.CollateralCodeAltKey,A.CollateralCode,A.CollateralDescription,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralCodeAltKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralCodeMaster' TableName  ,
                               COLLATERALCODEALTKEY,	COLLATERALCODE,	COLLATERALDESCRIPTION,	AUTHORISATIONSTATUS,	EFFECTIVEFROMTIMEKEY,	EFFECTIVETOTIMEKEY,	CREATEDBY,	DATECREATED,	APPROVEDBY,	DATEAPPROVED,	MODIFIEDBY,	DATEMODIFIED
                        FROM ( SELECT * 
                               FROM GTT_TEMP_COL_CODE A
                                WHERE  NVL(CollateralCode, ' ') LIKE '%' || v_CollateralCode || '%'
                                         AND NVL(CollateralDescription, ' ') LIKE '%' || v_CollateralDescription || '%' ) DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
        v_SQLERRM :=SQLERRM;
        v_SQLCODE :=SQLCODE;

      INSERT INTO RBL_MISDB_PROD.Error_Log(ERRORLINE
                                            ,	ERRORMESSAGE
                                            ,	ERRORNUMBER
                                            ,	ERRORPROCEDURE
                                            ,	ERRORSEVERITY
                                            ,	ERRORSTATE
                                            ,	ERRORDATETIME
                                            )
        ( SELECT utils.error_line ErrorLine  ,
                 v_SQLERRM ErrorMessage  ,
                 v_SQLCODE ErrorNumber  ,
                 utils.error_procedure ErrorProcedure  ,
                 utils.error_severity ErrorSeverity  ,
                 utils.error_state ErrorState  ,
                 SYSDATE 
            FROM DUAL  );
      OPEN  v_cursor FOR
         SELECT v_SQLERRM 
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCODESEARCHLIST" TO "ADF_CDR_RBL_STGDB";
