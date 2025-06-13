--------------------------------------------------------
--  DDL for Procedure DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14565 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   BEGIN

      BEGIN
         --select * from 	SysCRisMacMenu where menucaption like '%Instrument%'
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_114') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_114 ';
            END IF;
            DELETE FROM tt_temp_114;
            UTILS.IDENTITY_RESET('tt_temp_114');

            INSERT INTO tt_temp_114 ( 
            	SELECT A.InstrumentTypeMappingAlt_Key ,
                    A.InstrumentTypeName ,
                    A.InstrumentTypeAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SrcSysInstrumentTypeCode ,
                    A.SrcSysInstrumentTypeName ,
                    --A.InstrumentTypeGroup,
                    --A.InstrumentTypeSubGroup,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModifie ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT A.InstrumentTypeMappingAlt_Key ,--as Code,

                             A.InstrumentTypeName ,--as InstrumentTypeName,

                             A.InstrumentTypeAlt_Key ,
                             S.SourceAlt_Key ,
                             A.SrcSysInstrumentTypeCode ,
                             A.SrcSysInstrumentTypeName ,
                             --,A.InstrumentTypeGroup
                             --,A.InstrumentTypeSubGroup
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModifie ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModifie) ModAppDate  
                      FROM DimInstrumentTypeMapping A
                             LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.InstrumentTypeMappingAlt_Key ,--as Code,

                             A.InstrumentTypeName ,--as InstrumentTypeName,

                             A.InstrumentTypeAlt_Key ,
                             S.SourceAlt_Key ,
                             A.SrcSysInstrumentTypeCode ,
                             A.SrcSysInstrumentTypeName ,
                             --,A.InstrumentTypeGroup
                             --,A.InstrumentTypeSubGroup
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModifie ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModifie) ModAppDate  
                      FROM DimInstrumentTypeMapping_Mod A
                             LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.InstrumentType_Key IN ( SELECT MAX(InstrumentType_Key)  
                                                              FROM DimInstrumentTypeMapping_Mod 
                                                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                        AND EffectiveToTimeKey >= v_TimeKey
                                                                        AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                                GROUP BY InstrumentType_Key )
                     ) A
            	  GROUP BY A.InstrumentTypeMappingAlt_Key,A.InstrumentTypeName,A.InstrumentTypeAlt_Key,A.SourceAlt_Key,A.SrcSysInstrumentTypeCode,A.SrcSysInstrumentTypeName
                        --,A.InstrumentTypeGroup
                         --,A.InstrumentTypeSubGroup
                        ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY InstrumentTypeMappingAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'InstrumentTypeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_114 A ) 
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
               IF utils.object_id('TempDB..tt_temp_11416') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_84 ';
               END IF;
               DELETE FROM tt_temp16_84;
               UTILS.IDENTITY_RESET('tt_temp16_84');

               INSERT INTO tt_temp16_84 ( 
               	SELECT A.InstrumentTypeMappingAlt_Key ,
                       A.InstrumentTypeName ,
                       A.InstrumentTypeAlt_Key ,
                       A.SourceAlt_Key ,
                       A.SrcSysInstrumentTypeCode ,
                       A.SrcSysInstrumentTypeName ,
                       --,A.InstrumentTypeGroup
                       --,A.InstrumentTypeSubGroup
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModifie ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT A.InstrumentTypeMappingAlt_Key ,
                                A.InstrumentTypeName ,
                                A.InstrumentTypeAlt_Key ,
                                S.SourceAlt_Key ,
                                A.SrcSysInstrumentTypeCode ,
                                A.SrcSysInstrumentTypeName ,
                                --,A.InstrumentTypeGroup
                                --,A.InstrumentTypeSubGroup
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModifie ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModifie) ModAppDate  
                         FROM DimInstrumentTypeMapping_Mod A
                                LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.InstrumentType_Key IN ( SELECT MAX(InstrumentType_Key)  
                                                                 FROM DimInstrumentTypeMapping_Mod 
                                                                  WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                           AND EffectiveToTimeKey >= v_TimeKey
                                                                           AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                                   GROUP BY InstrumentType_Key )
                        ) A
               	  GROUP BY A.InstrumentTypeMappingAlt_Key,A.InstrumentTypeName,A.InstrumentTypeAlt_Key,A.SourceAlt_Key,A.SrcSysInstrumentTypeCode,A.SrcSysInstrumentTypeName
                           --,A.InstrumentTypeGroup
                            --,A.InstrumentTypeSubGroup
                           ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY InstrumentTypeMappingAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'InstrumentTypeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_84 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag IN ( 20 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_11420') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_51 ';
                  END IF;
                  DELETE FROM tt_temp20_51;
                  UTILS.IDENTITY_RESET('tt_temp20_51');

                  INSERT INTO tt_temp20_51 ( 
                  	SELECT A.InstrumentTypeMappingAlt_Key ,
                          A.InstrumentTypeName ,
                          A.InstrumentTypeAlt_Key ,
                          A.SourceAlt_Key ,
                          A.SrcSysInstrumentTypeCode ,
                          A.SrcSysInstrumentTypeName ,
                          --,A.InstrumentTypeGroup
                          --,A.InstrumentTypeSubGroup
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.ModifiedBy ,
                          A.DateModifie ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT A.InstrumentTypeMappingAlt_Key ,
                                   A.InstrumentTypeName ,
                                   A.InstrumentTypeAlt_Key ,
                                   S.SourceAlt_Key ,
                                   A.SrcSysInstrumentTypeCode ,
                                   A.SrcSysInstrumentTypeName ,
                                   --,A.InstrumentTypeGroup
                                   --,A.InstrumentTypeSubGroup
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ModifiedBy ,
                                   A.DateModifie ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApproved, A.DateModifie) ModAppDate  
                            FROM DimInstrumentTypeMapping_Mod A
                                   LEFT JOIN DIMSOURCEDB S   ON S.SourceAlt_Key = A.SourceAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.InstrumentType_Key IN ( SELECT MAX(InstrumentType_Key)  
                                                                    FROM DimInstrumentTypeMapping_Mod 
                                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                              AND EffectiveToTimeKey >= v_TimeKey

                                                                              --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                                                                              AND (CASE 
                                                                                        WHEN v_AuthLevel = 2
                                                                                          AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
                  	 THEN 1
                  	WHEN v_AuthLevel = 1
                  	  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
                  	 THEN 1
                                                                            ELSE 0
                                                                               END) = 1
                                                                      GROUP BY InstrumentType_Key )
                           ) A
                  	  GROUP BY A.InstrumentTypeMappingAlt_Key,A.InstrumentTypeName,A.InstrumentTypeAlt_Key,A.SourceAlt_Key,A.SrcSysInstrumentTypeCode,A.SrcSysInstrumentTypeName
                              --,A.InstrumentTypeGroup
                               --,A.InstrumentTypeSubGroup
                              ,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY InstrumentTypeMappingAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'InstrumentTypeMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_51 A ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;
               END IF;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMINSTRUMENTTYPEMASTER_SEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
