--------------------------------------------------------
--  DDL for Procedure DIMSOURCETABLE_SEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" 
(
  v_PageNo IN NUMBER,
  v_PageSize IN NUMBER,
  v_OperationFlag IN NUMBER
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
         --25999
         IF utils.object_id('TempDB..#Previous') IS NOT NULL THEN
          EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Previous ';
         END IF;
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         DBMS_OUTPUT.PUT_LINE('NANDA');
         --------- ADD LOGIC TO CHECK THE ACL PROCESS IS RUNNING OR NOT BY SATWAJI AS ON 28/08/2023 ------------------
         IF ( v_OperationFlag IN ( 1,2,3,16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('ACL Process Status Check');
            ACLProcessStatusCheck() ;

         END;
         END IF;
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_124') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_124 ';
            END IF;
            DELETE FROM tt_temp_124;
            UTILS.IDENTITY_RESET('tt_temp_124');

            INSERT INTO tt_temp_124 WITH Dimsrc AS ( SELECT SourceTable_Key ,
                                                            SourceTableAlt_Key ,
                                                            SourceAlt_Key ,
                                                            SourceTableName ,
                                                            StageTableName ,
                                                            Active_Inactive ,
                                                            Reason ,
                                                            EffectiveFromTimeKey ,
                                                            EffectiveToTimeKey ,
                                                            DateCreated ,
                                                            CreatedBy ,
                                                            DateModified ,
                                                            ModifiedBy ,
                                                            DateApproved ,
                                                            ApprovedBy ,
                                                            AuthorisationStatus 
                 FROM RBL_MISDB_PROD.DimSourceTable D
                WHERE  D.EffectiveFromTimeKey <= v_TimeKey
                         AND D.EffectiveToTimeKey >= v_TimeKey
                         AND NVL(D.AuthorisationStatus, 'A') = 'A'
               UNION 
               SELECT SourceTable_Key ,
                      SourceTableAlt_Key ,
                      SourceAlt_Key ,
                      SourceTableName ,
                      StageTableName ,
                      Active_Inactive ,
                      Reason ,
                      EffectiveFromTimeKey ,
                      EffectiveToTimeKey ,
                      DateCreated ,
                      CreatedBy ,
                      DateModified ,
                      ModifiedBy ,
                      DateApproved ,
                      ApprovedBy ,
                      AuthorisationStatus 
                 FROM RBL_MISDB_PROD.DimSourceTable_Mod D
                WHERE  D.EffectiveFromTimeKey <= v_TimeKey
                         AND D.EffectiveToTimeKey >= v_TimeKey

                         --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                         AND D.SourceTable_Key IN ( SELECT MAX(SourceTable_Key)  
                                                    FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey
                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                      GROUP BY SourceAlt_Key )
                ) 
                  SELECT SourceTable_Key ,
                         SourceTableAlt_Key ,
                         SourceAlt_Key ,
                         SourceTableName ,
                         StageTableName ,
                         Active_Inactive ,
                         Reason ,
                         EffectiveFromTimeKey ,
                         EffectiveToTimeKey ,
                         DateCreated ,
                         CreatedBy ,
                         DateModified ,
                         ModifiedBy ,
                         DateApproved ,
                         ApprovedBy ,
                         AuthorisationStatus 
                    FROM Dimsrc r
                    GROUP BY SourceTable_Key,SourceTableAlt_Key,SourceAlt_Key,SourceTableName,StageTableName,Active_Inactive,Reason,EffectiveFromTimeKey,EffectiveToTimeKey,DateCreated,CreatedBy,DateModified,ModifiedBy,DateApproved,ApprovedBy,AuthorisationStatus
                  ;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SourceTable_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'DimSourceTable' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_124 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                         AND RowNumber <= (v_PageNo * v_PageSize) ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            DBMS_OUTPUT.PUT_LINE('NANDA1');
         END IF;
         IF ( v_OperationFlag IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_12416') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_94 ';
            END IF;
            DELETE FROM tt_temp16_94;
            UTILS.IDENTITY_RESET('tt_temp16_94');

            INSERT INTO tt_temp16_94 WITH dimsrc_mod AS ( SELECT SourceTable_Key ,
                                                                 SourceTableAlt_Key ,
                                                                 SourceAlt_Key ,
                                                                 SourceTableName ,
                                                                 StageTableName ,
                                                                 Active_Inactive ,
                                                                 Reason ,
                                                                 EffectiveFromTimeKey ,
                                                                 EffectiveToTimeKey ,
                                                                 DateCreated ,
                                                                 CreatedBy ,
                                                                 DateModified ,
                                                                 ModifiedBy ,
                                                                 DateApproved ,
                                                                 ApprovedBy ,
                                                                 AuthorisationStatus 
                 FROM RBL_MISDB_PROD.DimSourceTable_Mod D
                WHERE  D.EffectiveFromTimeKey <= v_TimeKey
                         AND D.EffectiveToTimeKey >= v_TimeKey

                         --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                         AND D.SourceTable_Key IN ( SELECT MAX(SourceTable_Key)  
                                                    FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey
                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                      GROUP BY SourceAlt_Key )
                ) 
                  SELECT SourceTable_Key ,
                         SourceTableAlt_Key ,
                         SourceAlt_Key ,
                         SourceTableName ,
                         StageTableName ,
                         Active_Inactive ,
                         Reason ,
                         EffectiveFromTimeKey ,
                         EffectiveToTimeKey ,
                         DateCreated ,
                         CreatedBy ,
                         DateModified ,
                         ModifiedBy ,
                         DateApproved ,
                         ApprovedBy ,
                         AuthorisationStatus 
                    FROM dimsrc_mod r
                    GROUP BY SourceTable_Key,SourceTableAlt_Key,SourceAlt_Key,SourceTableName,StageTableName,Active_Inactive,Reason,EffectiveFromTimeKey,EffectiveToTimeKey,DateCreated,CreatedBy,DateModified,ModifiedBy,DateApproved,ApprovedBy,AuthorisationStatus
                  ;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SourceTable_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'RestructureMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp16_94 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                         AND RowNumber <= (v_PageNo * v_PageSize) ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            IF ( v_OperationFlag IN ( 20 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_12420') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_59 ';
               END IF;
               DELETE FROM tt_temp20_59;
               UTILS.IDENTITY_RESET('tt_temp20_59');

               INSERT INTO tt_temp20_59 WITH dimsrc_mod AS ( SELECT SourceTable_Key ,
                                                                    SourceTableAlt_Key ,
                                                                    SourceAlt_Key ,
                                                                    SourceTableName ,
                                                                    StageTableName ,
                                                                    Active_Inactive ,
                                                                    Reason ,
                                                                    EffectiveFromTimeKey ,
                                                                    EffectiveToTimeKey ,
                                                                    DateCreated ,
                                                                    CreatedBy ,
                                                                    DateModified ,
                                                                    ModifiedBy ,
                                                                    DateApproved ,
                                                                    ApprovedBy ,
                                                                    AuthorisationStatus 
                    FROM RBL_MISDB_PROD.DimSourceTable_Mod D
                   WHERE  D.EffectiveFromTimeKey <= v_TimeKey
                            AND D.EffectiveToTimeKey >= v_TimeKey
                            AND NVL(D.AuthorisationStatus, 'A') IN ( '1A' )

                            AND D.SourceTable_Key IN ( SELECT MAX(SourceTable_Key)  
                                                       FROM RBL_MISDB_PROD.DimSourceTable_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                         GROUP BY SourceAlt_Key )
                   ) 
                     SELECT SourceTable_Key ,
                            SourceTableAlt_Key ,
                            SourceAlt_Key ,
                            SourceTableName ,
                            StageTableName ,
                            Active_Inactive ,
                            Reason ,
                            EffectiveFromTimeKey ,
                            EffectiveToTimeKey ,
                            DateCreated ,
                            CreatedBy ,
                            DateModified ,
                            ModifiedBy ,
                            DateApproved ,
                            ApprovedBy ,
                            AuthorisationStatus 
                       FROM dimsrc_mod r
                       GROUP BY SourceTable_Key,SourceTableAlt_Key,SourceAlt_Key,SourceTableName,StageTableName,Active_Inactive,Reason,EffectiveFromTimeKey,EffectiveToTimeKey,DateCreated,CreatedBy,DateModified,ModifiedBy,DateApproved,ApprovedBy,AuthorisationStatus
                     ;
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SourceTable_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'RestructureMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp20_59 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                   WHERE  RowNumber >= ((v_PageNo - 1) * v_PageSize) + 1
                            AND RowNumber <= (v_PageNo * v_PageSize) ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
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
      --SELECT *
      --	,'RestucturedAsset' AS 'TableName'
      --FROM MetaScreenFieldDetail
      --WHERE ScreenName = 'RestucturedAsset'

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMSOURCETABLE_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
