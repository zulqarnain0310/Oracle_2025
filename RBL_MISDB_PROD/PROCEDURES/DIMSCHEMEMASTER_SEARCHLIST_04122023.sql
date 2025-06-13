--------------------------------------------------------
--  DDL for Procedure DIMSCHEMEMASTER_SEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
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
         IF ( v_OperationFlag NOT IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_123') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_123 ';
            END IF;
            DELETE FROM tt_temp_123;
            UTILS.IDENTITY_RESET('tt_temp_123');

            INSERT INTO tt_temp_123 ( 
            	SELECT A.SchemeMappingAlt_Key ,
                    A.SchemeName ,
                    A.SchemeAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SrcSysSchemeCode ,
                    A.SrcSysSchemeName ,
                    A.SchemeGroup ,
                    A.SchemeSubGroup ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModifie 
            	  FROM ( SELECT A.SchemeMappingAlt_Key ,--as Code,

                             A.SchemeName ,--as SchemeName,

                             A.SchemeAlt_Key ,
                             S.SourceAlt_Key ,
                             A.SrcSysSchemeCode ,
                             A.SrcSysSchemeName ,
                             A.SchemeGroup ,
                             A.SchemeSubGroup ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModifie 
                      FROM DimSchemeMapping A
                             LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.SchemeMappingAlt_Key ,--as Code,

                             A.SchemeName ,--as SchemeName,

                             A.SchemeAlt_Key ,
                             S.SourceAlt_Key ,
                             A.SrcSysSchemeCode ,
                             A.SrcSysSchemeName ,
                             A.SchemeGroup ,
                             A.SchemeSubGroup ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModifie 
                      FROM DimSchemeMapping_Mod A
                             LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Scheme_Key IN ( SELECT MAX(Scheme_Key)  
                                                      FROM DimSchemeMapping_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                        GROUP BY Scheme_Key )
                     ) A
            	  GROUP BY A.SchemeMappingAlt_Key,A.SchemeName,A.SchemeAlt_Key,A.SourceAlt_Key,A.SrcSysSchemeCode,A.SrcSysSchemeName,A.SchemeGroup,A.SchemeSubGroup,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SchemeMappingAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SchemeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_123 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_12316') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_93 ';
               END IF;
               DELETE FROM tt_temp16_93;
               UTILS.IDENTITY_RESET('tt_temp16_93');

               INSERT INTO tt_temp16_93 ( 
               	SELECT A.SchemeMappingAlt_Key ,
                       A.SchemeName ,
                       A.SchemeAlt_Key ,
                       A.SourceAlt_Key ,
                       A.SrcSysSchemeCode ,
                       A.SrcSysSchemeName ,
                       A.SchemeGroup ,
                       A.SchemeSubGroup ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModifie 
               	  FROM ( SELECT A.SchemeMappingAlt_Key ,
                                A.SchemeName ,
                                A.SchemeAlt_Key ,
                                S.SourceAlt_Key ,
                                A.SrcSysSchemeCode ,
                                A.SrcSysSchemeName ,
                                A.SchemeGroup ,
                                A.SchemeSubGroup ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModifie 
                         FROM DimSchemeMapping_Mod A
                                LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Scheme_Key IN ( SELECT MAX(Scheme_Key)  
                                                         FROM DimSchemeMapping_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                           GROUP BY Scheme_Key )
                        ) A
               	  GROUP BY A.SchemeMappingAlt_Key,A.SchemeName,A.SchemeAlt_Key,A.SourceAlt_Key,A.SrcSysSchemeCode,A.SrcSysSchemeName,A.SchemeGroup,A.SchemeSubGroup,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SchemeMappingAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'SchemeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_93 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSCHEMEMASTER_SEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
