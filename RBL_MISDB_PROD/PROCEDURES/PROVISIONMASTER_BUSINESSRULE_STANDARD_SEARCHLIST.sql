--------------------------------------------------------
--  DDL for Procedure PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 
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
            IF utils.object_id('TempDB..tt_temp_215') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_215 ';
            END IF;
            DELETE FROM tt_temp_215;
            UTILS.IDENTITY_RESET('tt_temp_215');

            INSERT INTO tt_temp_215 ( 
            	SELECT A.Code ,
                    A.BankCategoryID ,
                    A.AssetCategory ,
                    A.CategoryType ,
                    A.CategoryTypeAlt_Key ,
                    A.ProvisionPrcntRBINorms ,
                    A.AdditionalBanksProvision ,
                    A.AdditionalProvisionPrcntBankNorms ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.BusinessRuleAuthPending ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT A.ProvisionAlt_Key Code  ,
                             A.BankCategoryID ,
                             A.ProvisionName AssetCategory  ,
                             B.ParameterName CategoryType  ,
                             A.CategoryTypeAlt_Key ,
                             A.ProvisionSecured ProvisionPrcntRBINorms  ,
                             A.AdditionalBanksProvision ,
                             A.AdditionalprovisionRBINORMS AdditionalProvisionPrcntBankNorms  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             (CASE 
                                   WHEN D.AuthorisationStatus IN ( 'NP','MP' )
                                    THEN 1
                             ELSE 0
                                END) BusinessRuleAuthPending  ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  

                      --select * from  DimProvision_SegStd  
                      FROM DimProvision_SegStd A
                             LEFT JOIN ( SELECT MAX(AuthorisationStatus)  AuthorisationStatus  ,
            	CatAlt_key 
                                         FROM DimBusinessRuleSetup_mod 
                                          WHERE  AuthorisationStatus IN ( 'NP','MP' )

                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                           GROUP BY CatAlt_key ) D   ON D.CatAlt_key = A.BankCategoryID
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CategoryType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Category Type'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.CategoryTypeAlt_Key = B.ParameterAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 

                      --AND ProvisionName NOT IN  ('Sub Standard','Sub Standard Infrastructure'

                      --,'Sub Standard Ab initio Unsecured','Doubtful-I','Doubtful-II','Doubtful-III','Loss')  
                      SELECT A.ProvisionAlt_Key Code  ,
                             A.BankCategoryID ,
                             A.ProvisionName AssetCategory  ,
                             B.ParameterName CategoryType  ,
                             A.CategoryTypeAlt_Key ,
                             A.ProvisionSecured ProvisionPrcntRBINorms  ,
                             A.AdditionalBanksProvision ,
                             A.AdditionalprovisionRBINORMS AdditionalProvisionPrcntBankNorms  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             (CASE 
                                   WHEN D.AuthorisationStatus IN ( 'NP','MP' )
                                    THEN 1
                             ELSE 0
                                END) BusinessRuleAuthPending  ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModified) ModAppDate  
                      FROM DimProvision_SegStd_Mod A
                             LEFT JOIN ( SELECT MAX(AuthorisationStatus)  AuthorisationStatus  ,
                                                CatAlt_key 
                                         FROM DimBusinessRuleSetup_mod 
                                          WHERE  AuthorisationStatus IN ( 'NP','MP' )

                                                   AND EffectiveFromTimeKey <= v_TimeKey
                                                   AND EffectiveToTimeKey >= v_TimeKey
                                           GROUP BY CatAlt_key ) D   ON D.CatAlt_key = A.BankCategoryID
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CategoryType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Category Type'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.CategoryTypeAlt_Key = B.ParameterAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --and D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimProvision_SegStd_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY ProvisionAlt_Key )
                     ) A
            	  GROUP BY A.Code,A.BankCategoryID,A.AssetCategory,A.CategoryType,A.CategoryTypeAlt_Key,A."ProvisionPrcntRBINorms",A.AdditionalBanksProvision,A."AdditionalProvisionPrcntBankNorms",A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.BusinessRuleAuthPending,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Code  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'ProvisionMaster' TableName  ,
                               * 
                        FROM ( SELECT * 

                               --(Case When D.AuthorisationStatus in ('NP','MP') THEN 1 else 0 END )as result
                               FROM tt_temp_215 A
                                WHERE  CategoryTypeAlt_Key = 1 ) 
                             --left join  DIMBusinessRuleSetup_Mod D on D.CatAlt_key=A.BankCategoryID

                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             -- where  D.EffectiveFromTimeKey <= @TimeKey AND D.EffectiveToTimeKey >= @TimeKey

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
               IF utils.object_id('TempDB..tt_temp_21516') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_170 ';
               END IF;
               DELETE FROM tt_temp16_170;
               UTILS.IDENTITY_RESET('tt_temp16_170');

               INSERT INTO tt_temp16_170 ( 
               	SELECT A.Code ,
                       A.BankCategoryID ,
                       A.AssetCategory ,
                       A.CategoryType ,
                       A.CategoryTypeAlt_Key ,
                       A.ProvisionPrcntRBINorms ,
                       A.AdditionalBanksProvision ,
                       A.AdditionalProvisionPrcntBankNorms ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT A.ProvisionAlt_Key Code  ,
                                A.BankCategoryID ,
                                A.ProvisionName AssetCategory  ,
                                B.ParameterName CategoryType  ,
                                A.CategoryTypeAlt_Key ,
                                A.ProvisionSecured ProvisionPrcntRBINorms  ,
                                A.AdditionalBanksProvision ,
                                A.AdditionalprovisionRBINORMS AdditionalProvisionPrcntBankNorms  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModified) ModAppDate  
                         FROM DimProvision_SegStd_Mod A
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'CategoryType' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'Category Type'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.CategoryTypeAlt_Key = B.ParameterAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimProvision_SegStd_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY ProvisionAlt_Key )
                        ) A
               	  GROUP BY A.Code,A.BankCategoryID,A.AssetCategory,A.CategoryType,A.CategoryTypeAlt_Key,A."ProvisionPrcntRBINorms",A.AdditionalBanksProvision,A."AdditionalProvisionPrcntBankNorms",A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Code  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'ProvisionMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_170 A
                                   WHERE  CategoryTypeAlt_Key = 1 ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag = 20 ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_21520') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_135 ';
                  END IF;
                  DELETE FROM tt_temp20_135;
                  UTILS.IDENTITY_RESET('tt_temp20_135');

                  INSERT INTO tt_temp20_135 ( 
                  	SELECT A.Code ,
                          A.BankCategoryID ,
                          A.AssetCategory ,
                          A.CategoryType ,
                          A.CategoryTypeAlt_Key ,
                          A.ProvisionPrcntRBINorms ,
                          A.AdditionalBanksProvision ,
                          A.AdditionalProvisionPrcntBankNorms ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT A.ProvisionAlt_Key Code  ,
                                   A.BankCategoryID ,
                                   A.ProvisionName AssetCategory  ,
                                   B.ParameterName CategoryType  ,
                                   A.CategoryTypeAlt_Key ,
                                   A.ProvisionSecured ProvisionPrcntRBINorms  ,
                                   A.AdditionalBanksProvision ,
                                   A.AdditionalprovisionRBINORMS AdditionalProvisionPrcntBankNorms  ,
                                   --isnull(A.AuthorisationStatus, 'A') 
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApproved, A.DateModified) ModAppDate  
                            FROM DimProvision_SegStd_Mod A
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'CategoryType' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'Category Type'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.CategoryTypeAlt_Key = B.ParameterAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM DimProvision_SegStd_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY ProvisionAlt_Key )
                           ) A
                  	  GROUP BY A.Code,A.BankCategoryID,A.AssetCategory,A.CategoryType,A.CategoryTypeAlt_Key,A."ProvisionPrcntRBINorms",A.AdditionalBanksProvision,A."AdditionalProvisionPrcntBankNorms",A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Code  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'ProvisionMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_135 A
                                      WHERE  CategoryTypeAlt_Key = 1 ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONMASTER_BUSINESSRULE_STANDARD_SEARCHLIST" TO "ADF_CDR_RBL_STGDB";
