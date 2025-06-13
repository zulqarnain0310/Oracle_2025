--------------------------------------------------------
--  DDL for Procedure COLLATERALCHARGETYPESEARCHLIST_18082021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" 
(
  v_ChargeTypeID IN VARCHAR2 DEFAULT ' ' ,
  v_ChargeType IN VARCHAR2 DEFAULT ' ' ,
  v_CollChargeDescription IN VARCHAR2 DEFAULT ' ' ,
  --@PageNo					INT         = 1, --@PageSize					INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

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
            IF utils.object_id('TempDB..tt_temp_26') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_26 ';
            END IF;
            DELETE FROM tt_temp_26;
            UTILS.IDENTITY_RESET('tt_temp_26');

            INSERT INTO tt_temp_26 ( 
            	SELECT A.CollateralChargeTypeAltKey ,
                    A.ChargeTypeID ,
                    A.ChargeType ,
                    A.CollChargeDescription ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified 
            	  FROM ( SELECT A.CollateralChargeTypeAltKey ,
                             A.ChargeTypeID ,
                             A.ChargeType ,
                             A.CollChargeDescription ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM DimCollateralChargeType A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.CollateralChargeTypeAltKey ,
                             A.ChargeTypeID ,
                             A.ChargeType ,
                             A.CollChargeDescription ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM DimCollateralChargeType_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimCollateralChargeType_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY CollateralChargeTypeAltKey )
                     ) A
            	  GROUP BY A.CollateralChargeTypeAltKey,A.ChargeTypeID,A.ChargeType,A.CollChargeDescription,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralChargeTypeAltKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralChargeTypeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_26 A
                                WHERE  NVL(ChargeTypeID, ' ') LIKE '%' || v_ChargeTypeID || '%'
                                         AND NVL(ChargeType, ' ') LIKE '%' || v_ChargeType || '%'
                                         AND NVL(CollChargeDescription, ' ') LIKE '%' || v_CollChargeDescription || '%' ) DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize)
         ELSE

          /*  IT IS Used For GRID Search which are Pending for Authorization    */
         BEGIN
            IF utils.object_id('TempDB..tt_temp_2616') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_19 ';
            END IF;
            DELETE FROM tt_temp16_19;
            UTILS.IDENTITY_RESET('tt_temp16_19');

            INSERT INTO tt_temp16_19 ( 
            	SELECT A.CollateralChargeTypeAltKey ,
                    A.ChargeTypeID ,
                    A.ChargeType ,
                    A.CollChargeDescription ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified 
            	  FROM ( SELECT A.CollateralChargeTypeAltKey ,
                             A.ChargeTypeID ,
                             A.ChargeType ,
                             A.CollChargeDescription ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM DimCollateralChargeType_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimCollateralChargeType_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY CollateralChargeTypeAltKey )
                     ) A
            	  GROUP BY A.CollateralChargeTypeAltKey,A.ChargeTypeID,A.ChargeType,A.CollChargeDescription,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralChargeTypeAltKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralChargeTypeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp16_19 A
                                WHERE  NVL(ChargeTypeID, ' ') LIKE '%' || v_ChargeTypeID || '%'
                                         AND NVL(ChargeType, ' ') LIKE '%' || v_ChargeType || '%'
                                         AND NVL(CollChargeDescription, ' ') LIKE '%' || v_CollChargeDescription || '%' ) DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize)
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
         DBMS_SQL.RETURN_RESULT(v_cursor);--RETURN -1

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALCHARGETYPESEARCHLIST_18082021" TO "ADF_CDR_RBL_STGDB";
