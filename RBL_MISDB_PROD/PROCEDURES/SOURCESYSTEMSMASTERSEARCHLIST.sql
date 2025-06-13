--------------------------------------------------------
--  DDL for Procedure SOURCESYSTEMSMASTERSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 17 ,
  v_MenuID IN NUMBER DEFAULT 14552 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
---select AuthLevel,* from SysCRisMacMenu where MenuCaption like '%Source%'    

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
            IF utils.object_id('TempDB..tt_temp_275') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_275 ';
            END IF;
            DELETE FROM tt_temp_275;
            UTILS.IDENTITY_RESET('tt_temp_275');

            INSERT INTO tt_temp_275 ( 
            	SELECT A.SourceAlt_Key ,
                    A.SourceSysName ,
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
                    A.ModAppDate ,
                    UTILS.CONVERT_TO_VARCHAR2(A.StartDate,30,p_style=>101) StartDate ,--Nely added by kapil Khot on 08/07/2024

                    UTILS.CONVERT_TO_VARCHAR2(A.EndDate,30,p_style=>101) EndDate ,--Nely added by kapil Khot on 08/07/2024

                    A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                    A.Reason --Nely added by kapil Khot on 08/07/2024

            	  FROM ( SELECT A.SourceAlt_Key ,
                             A.SourceName SourceSysName  ,
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
                             NVL(A.DateApproved, A.DateModified) ModAppDate  ,
                             A.StartDate ,--Nely added by kapil Khot on 08/07/2024

                             A.EndDate ,--Nely added by kapil Khot on 08/07/2024

                             A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                             A.Reason --Nely added by kapil Khot on 08/07/2024

                      FROM DIMSOURCEDB A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.SourceAlt_Key ,
                             A.SourceName SourceSysName  ,
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
                             NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy ,--New Column 'ApprovedByFirstLevel' is added in Mod table     by kapil khot on 08/07/2024 Previously -->        --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

                             NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate ,--New Column 'DateApprovedByFirstLevel' is added in Mod table by kapil khot on 08/07/2024   Previously -->        --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

                             NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy ,--New Column 'ApprovedByFirstLevel' is added in Mod table     by kapil khot on 08/07/2024  Previously -->       --,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

                             NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate ,--New Column 'DateApprovedByFirstLevel' is added in Mod table by kapil khot on 08/07/2024     Previously -->      --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

                             A.StartDate ,--Nely added by kapil Khot on 08/07/2024

                             A.EndDate ,--Nely added by kapil Khot on 08/07/2024

                             A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                             A.Reason --Nely added by kapil Khot on 08/07/2024

                      FROM DimSourceDB_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Source_Key IN ( SELECT MAX(Source_Key)  
                                                      FROM DimSourceDB_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                        GROUP BY SourceAlt_Key )
                     ) A
            	  GROUP BY A.SourceAlt_Key,A.SourceSysName,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.StartDate --Nely added by kapil Khot on 08/07/2024
                        ,A.EndDate --Nely added by kapil Khot on 08/07/2024
                        ,A.Active_Inactive --Nely added by kapil Khot on 08/07/2024
                        ,A.Reason );--Nely added by kapil Khot on 08/07/2024
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SourceAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SourceSystemMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_275 A ) 
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
               IF utils.object_id('TempDB..tt_temp_27516') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_222 ';
               END IF;
               DELETE FROM tt_temp16_222;
               UTILS.IDENTITY_RESET('tt_temp16_222');

               INSERT INTO tt_temp16_222 ( 
               	SELECT A.SourceAlt_Key ,
                       A.SourceSysName ,
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
                       A.ModAppDate ,
                       UTILS.CONVERT_TO_VARCHAR2(A.StartDate,30,p_style=>101) StartDate ,--Nely added by kapil Khot on 08/07/2024

                       UTILS.CONVERT_TO_VARCHAR2(A.EndDate,30,p_style=>101) EndDate ,--Nely added by kapil Khot on 08/07/2024

                       A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                       A.Reason --Nely added by kapil Khot on 08/07/2024

               	  FROM ( SELECT A.SourceAlt_Key ,
                                A.SourceName SourceSysName  ,
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
                                NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy ,--New Column 'ApprovedByFirstLevel' is added in Mod table     by kapil khot on 08/07/2024 Previously -->        --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

                                NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate ,--New Column 'DateApprovedByFirstLevel' is added in Mod table by kapil khot on 08/07/2024   Previously -->        --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

                                NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy ,--New Column 'ApprovedByFirstLevel' is added in Mod table     by kapil khot on 08/07/2024  Previously -->       --,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

                                NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate ,--New Column 'DateApprovedByFirstLevel' is added in Mod table by kapil khot on 08/07/2024     Previously -->      --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

                                A.StartDate ,--Nely added by kapil Khot on 08/07/2024

                                A.EndDate ,--Nely added by kapil Khot on 08/07/2024

                                A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                                A.Reason --Nely added by kapil Khot on 08/07/2024

                         FROM DimSourceDB_Mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Source_Key IN ( SELECT MAX(Source_Key)  
                                                         FROM DimSourceDB_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                           GROUP BY SourceAlt_Key )
                        ) A
               	  GROUP BY A.SourceAlt_Key,A.SourceSysName,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.StartDate --Nely added by kapil Khot on 08/07/2024
                           ,A.EndDate --Nely added by kapil Khot on 08/07/2024
                           ,A.Active_Inactive --Nely added by kapil Khot on 08/07/2024
                           ,A.Reason );--Nely added by kapil Khot on 08/07/2024
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SourceAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'SourceSystemMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_222 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_27520') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_187 ';
                  END IF;
                  DELETE FROM tt_temp20_187;
                  UTILS.IDENTITY_RESET('tt_temp20_187');

                  INSERT INTO tt_temp20_187 ( 
                  	SELECT A.SourceAlt_Key ,
                          A.SourceSysName ,
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
                          A.ModAppDate ,
                          UTILS.CONVERT_TO_VARCHAR2(A.StartDate,30,p_style=>101) StartDate ,--Nely added by kapil Khot on 08/07/2024

                          UTILS.CONVERT_TO_VARCHAR2(A.EndDate,30,p_style=>101) EndDate ,--Nely added by kapil Khot on 08/07/2024

                          A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                          A.Reason --Nely added by kapil Khot on 08/07/2024

                  	  FROM ( SELECT A.SourceAlt_Key ,
                                   A.SourceName SourceSysName  ,
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
                                   NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy ,--New Column 'ApprovedByFirstLevel' is added in Mod table     by kapil khot on 08/07/2024 Previously -->        --,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy

                                   NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate ,--New Column 'DateApprovedByFirstLevel' is added in Mod table by kapil khot on 08/07/2024   Previously -->        --,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate

                                   NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy ,--New Column 'ApprovedByFirstLevel' is added in Mod table     by kapil khot on 08/07/2024  Previously -->       --,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy

                                   NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate ,--New Column 'DateApprovedByFirstLevel' is added in Mod table by kapil khot on 08/07/2024     Previously -->      --,ISNULL(A.DateApproved,A.DateModified) as ModAppDate

                                   A.StartDate ,--Nely added by kapil Khot on 08/07/2024

                                   A.EndDate ,--Nely added by kapil Khot on 08/07/2024

                                   A.Active_Inactive ,--Nely added by kapil Khot on 08/07/2024

                                   A.Reason --Nely added by kapil Khot on 08/07/2024

                            FROM DimSourceDB_Mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.Source_Key IN ( SELECT MAX(Source_Key)  
                                                            FROM DimSourceDB_Mod 
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
                                                              GROUP BY SourceAlt_Key )
                           ) A
                  	  GROUP BY A.SourceAlt_Key,A.SourceSysName,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.StartDate --Nely added by kapil Khot on 08/07/2024
                              ,A.EndDate --Nely added by kapil Khot on 08/07/2024
                              ,A.Active_Inactive --Nely added by kapil Khot on 08/07/2024
                              ,A.Reason );--Nely added by kapil Khot on 08/07/2024
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY SourceAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'SourceSystemMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_187 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SOURCESYSTEMSMASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
