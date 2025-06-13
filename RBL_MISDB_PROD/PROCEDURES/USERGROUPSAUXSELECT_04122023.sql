--------------------------------------------------------
--  DDL for Procedure USERGROUPSAUXSELECT_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" 
--USE YES_MISDB
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14551 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT AuthLevel 

     INTO v_Authlevel
     FROM SysCRisMacMenu 
    WHERE  MenuId = v_MenuID;
   IF utils.object_id('Tempdb..tt_TmpGroupDtl_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpGroupDtl_2 ';
   END IF;
   DELETE FROM tt_TmpGroupDtl_2;
   UTILS.IDENTITY_RESET('tt_TmpGroupDtl_2');

   INSERT INTO tt_TmpGroupDtl_2 ( 
   	SELECT EntityKey ,
           DeptGroupId ,
           REPLACE(DeptGroupCode, '#', ' ') DeptGroupName  ,
           DeptGroupName DeptGroupDesc  ,
           Menus ,
           AuthorisationStatus ,
           CreatedBy ,
           DateCreated ,
           ModifiedBy ,
           DateModified ,
           ApprovedBy ,
           DateApproved ,
           EffectiveFromTimeKey ,
           EffectiveToTimeKey 
   	  FROM DimUserDeptGroup 
   	 WHERE  EffectiveFromTimeKey <= v_timekey
              AND EffectiveToTimeKey >= v_timekey );
   DELETE FROM tt_TmpGroupDtl1_2;
   UTILS.IDENTITY_RESET('tt_TmpGroupDtl1_2');

   INSERT INTO tt_TmpGroupDtl1_2 ( 
   	SELECT EntityKey ,
           DeptGroupId ,
           REPLACE(DeptGroupCode, '#', ' ') DeptGroupName  ,
           DeptGroupName DeptGroupDesc  ,
           Menus ,
           AuthorisationStatus ,
           CreatedBy ,
           DateCreated ,
           ModifiedBy ,
           DateModified ,
           ApprovedBy ,
           DateApproved ,
           EffectiveFromTimeKey ,
           EffectiveToTimeKey ,
           ApprovedByFirstLevel ,
           DateApprovedFirstLevel 
   	  FROM DimUserDeptGroup_Mod 
   	 WHERE  EffectiveFromTimeKey <= v_timekey
              AND EffectiveToTimeKey >= v_timekey );
   IF utils.object_id('Tempdb..tt_TmpGroupMenuParent_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpGroupMenuParent_2 ';
   END IF;
   DELETE FROM tt_TmpGroupMenuParent_2;
   UTILS.IDENTITY_RESET('tt_TmpGroupMenuParent_2');

   INSERT INTO tt_TmpGroupMenuParent_2 ( 
   	SELECT DeptGroupId ,
           B.ParentId 
   	  FROM ( SELECT DeptGroupId ,
                    DeptGroupName ,
                    DeptGroupDesc ,--,B.ParentId,

                    a_SPLIT.VALUE('.', 'VARCHAR(100)') Menus  
             FROM ( SELECT DeptGroupId ,
                           DeptGroupName ,
                           DeptGroupDesc ,
                           UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Menus, ',', '</M><M>') || '</M>') Menus  
                    FROM tt_TmpGroupDtl_2  ) A
                     /*TODO:SQLDEV*/ CROSS APPLY Menus.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A
             JOIN SysCRisMacMenu B   ON UTILS.CONVERT_TO_NUMBER(A.Menus,10,0) = B.MenuId
   	  GROUP BY DeptGroupId,B.ParentId );
   IF utils.object_id('Tempdb..tt_TmpGroupMenuParent_21') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TmpGroupMenuParent1_2 ';
   END IF;
   DELETE FROM tt_TmpGroupMenuParent1_2;
   UTILS.IDENTITY_RESET('tt_TmpGroupMenuParent1_2');

   INSERT INTO tt_TmpGroupMenuParent1_2 ( 
   	SELECT DeptGroupId ,
           B.ParentId 
   	  FROM ( SELECT DeptGroupId ,
                    DeptGroupName ,
                    DeptGroupDesc ,--,B.ParentId,

                    a_SPLIT.VALUE('.', 'VARCHAR(100)') Menus  
             FROM ( SELECT DeptGroupId ,
                           DeptGroupName ,
                           DeptGroupDesc ,
                           UTILS.CONVERT_TO_CLOB('<M>' || REPLACE(Menus, ',', '</M><M>') || '</M>') Menus  
                    FROM tt_TmpGroupDtl1_2  ) A
                     /*TODO:SQLDEV*/ CROSS APPLY Menus.nodes ('/M') AS Split(a) /*END:SQLDEV*/  ) A
             JOIN SysCRisMacMenu B   ON UTILS.CONVERT_TO_NUMBER(A.Menus,10,0) = B.MenuId
   	  GROUP BY DeptGroupId,B.ParentId );
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('SachinTest');
            IF utils.object_id('TempDB..tt_temp_299') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_299 ';
            END IF;
            DELETE FROM tt_temp_299;
            UTILS.IDENTITY_RESET('tt_temp_299');

            INSERT INTO tt_temp_299 ( 
            	SELECT A.EntityKey ,
                    A.DeptGroupId ,
                    A.DeptGroupName ,
                    A.DeptGroupDesc ,
                    A.Menus ,
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
            	  FROM ( SELECT EntityKey ,
                             T.DeptGroupId ,
                             T.DeptGroupName ,
                             DeptGroupDesc ,
                             Menus || '|' || ParentID Menus  ,
                             NVL(T.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             'Y' IsMainTable  ,
                             T.CreatedBy ,
                             T.DateCreated ,
                             T.ApprovedBy ,
                             T.DateApproved ,
                             T.ModifiedBy ,
                             T.DateModified ,
                             NVL(T.ModifiedBy, T.CreatedBy) CrModBy  ,
                             NVL(T.DateModified, T.DateCreated) CrModDate  ,
                             NVL(T.ApprovedBy, T.CreatedBy) CrAppBy  ,
                             NVL(T.DateApproved, T.DateCreated) CrAppDate  ,
                             NVL(T.ApprovedBy, T.ModifiedBy) ModAppBy  ,
                             NVL(T.DateApproved, T.DateModified) ModAppDate  

                      --select *
                      FROM tt_TmpGroupDtl_2 T
                             LEFT JOIN ( SELECT DeptGroupId ,
                                                ParentID 
                                         FROM ( SELECT DeptGroupId ,
                                                       utils.stuff(( SELECT ',' || UTILS.CONVERT_TO_VARCHAR2(ParentId,10) 
                                                                     FROM tt_TmpGroupMenuParent_2 M1
                                                                      WHERE  M2.DeptGroupId = M1.DeptGroupId ), 1, 1, ' ') ParentID  
                                                FROM tt_TmpGroupMenuParent_2 M2 ) B
                                           GROUP BY DeptGroupId,ParentID ) B   ON T.DeptGroupId = B.DeptGroupId
                       WHERE  T.EffectiveFromTimeKey <= v_TimeKey
                                AND T.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(T.AuthorisationStatus, 'A') = 'A'
                      UNION 

                      --select * into DimGLProduct_Mod from DimGLProduct

                      --alter table DimGLProduct_Mod

                      --add  Remark varchar(max)

                      --,Change varchar(max)
                      SELECT EntityKey ,
                             T.DeptGroupId ,
                             DeptGroupName ,
                             DeptGroupDesc ,
                             Menus || '|' || ParentID Menus  ,
                             NVL(T.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             'Y' IsMainTable  ,
                             T.CreatedBy ,
                             T.DateCreated ,
                             T.ApprovedBy ,
                             T.DateApproved ,
                             T.ModifiedBy ,
                             T.DateModified ,
                             NVL(T.ModifiedBy, T.CreatedBy) CrModBy  ,
                             NVL(T.DateModified, T.DateCreated) CrModDate  ,
                             NVL(T.ApprovedBy, T.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(T.DateApproved, T.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(T.ApprovedBy, T.ModifiedBy) ModAppBy  ,
                             NVL(T.DateApproved, T.DateModified) ModAppDate  

                      --select *
                      FROM tt_TmpGroupDtl1_2 T
                             LEFT JOIN ( SELECT DeptGroupId ,
                                                ParentID 
                                         FROM ( SELECT DeptGroupId ,
                                                       utils.stuff(( SELECT ',' || UTILS.CONVERT_TO_VARCHAR2(ParentId,10) 
                                                                     FROM tt_TmpGroupMenuParent1_2 M1
                                                                      WHERE  M2.DeptGroupId = M1.DeptGroupId ), 1, 1, ' ') ParentID  
                                                FROM tt_TmpGroupMenuParent1_2 M2 ) B
                                           GROUP BY DeptGroupId,ParentID ) B   ON T.DeptGroupId = B.DeptGroupId
                       WHERE  T.EffectiveFromTimeKey <= v_TimeKey
                                AND T.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
                                AND NVL(T.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                AND T.DeptGroupId IN ( SELECT MAX(DeptGroupId)  
                                                       FROM DimUserDeptGroup_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                         GROUP BY DeptGroupId )
                     ) A
            	  GROUP BY A.EntityKey,A.DeptGroupId,A.DeptGroupName,A.DeptGroupDesc,A.Menus,A.AuthorisationStatus,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DeptGroupId  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               * 

                        --'GROUPTypeMaster' TableName, 
                        FROM ( SELECT * 
                               FROM tt_temp_299 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_29916') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_244 ';
               END IF;
               DELETE FROM tt_temp16_244;
               UTILS.IDENTITY_RESET('tt_temp16_244');

               INSERT INTO tt_temp16_244 ( 
               	SELECT A.EntityKey ,
                       A.DeptGroupId ,
                       A.DeptGroupName ,
                       A.DeptGroupDesc ,
                       A.Menus ,
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
               	  FROM ( SELECT EntityKey ,
                                T.DeptGroupId ,
                                DeptGroupName ,
                                DeptGroupDesc ,
                                Menus || '|' || ParentID Menus  ,
                                NVL(T.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                EffectiveFromTimeKey ,
                                EffectiveToTimeKey ,
                                'Y' IsMainTable  ,
                                T.CreatedBy ,
                                T.DateCreated ,
                                T.ApprovedBy ,
                                T.DateApproved ,
                                T.ModifiedBy ,
                                T.DateModified ,
                                NVL(T.ModifiedBy, T.CreatedBy) CrModBy  ,
                                NVL(T.DateModified, T.DateCreated) CrModDate  ,
                                NVL(T.ApprovedBy, T.ApprovedByFirstLevel) CrAppBy  ,
                                NVL(T.DateApproved, T.DateApprovedFirstLevel) CrAppDate  ,
                                NVL(T.ApprovedBy, T.ModifiedBy) ModAppBy  ,
                                NVL(T.DateApproved, T.DateModified) ModAppDate  

                         --select *
                         FROM tt_TmpGroupDtl1_2 T
                                LEFT JOIN ( SELECT DeptGroupId ,
                                                   ParentID 
                                            FROM ( SELECT DeptGroupId ,
                                                          utils.stuff(( SELECT ',' || UTILS.CONVERT_TO_VARCHAR2(ParentId,10) 
                                                                        FROM tt_TmpGroupMenuParent1_2 M1
                                                                         WHERE  M2.DeptGroupId = M1.DeptGroupId ), 1, 1, ' ') ParentID  
                                                   FROM tt_TmpGroupMenuParent1_2 M2 ) B
                                              GROUP BY DeptGroupId,ParentID ) B   ON T.DeptGroupId = B.DeptGroupId
                          WHERE  T.EffectiveFromTimeKey <= v_TimeKey
                                   AND T.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
                                   AND NVL(T.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                   AND T.DeptGroupId IN ( SELECT MAX(DeptGroupId)  
                                                          FROM DimUserDeptGroup_Mod 
                                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                            GROUP BY DeptGroupId )
                        ) A
               	  GROUP BY A.EntityKey,A.DeptGroupId,A.DeptGroupName,A.DeptGroupDesc,A.Menus,A.AuthorisationStatus,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DeptGroupId  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  * 

                           --'GROUPTypeMaster' TableName, 
                           FROM ( SELECT * 
                                  FROM tt_temp16_244 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY DataPointOwner.DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize)
         IF ( v_OperationFlag IN ( 20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_29920') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_209 ';
            END IF;
            DELETE FROM tt_temp20_209;
            UTILS.IDENTITY_RESET('tt_temp20_209');

            INSERT INTO tt_temp20_209 ( 
            	SELECT A.EntityKey ,
                    A.DeptGroupId ,
                    A.DeptGroupName ,
                    A.DeptGroupDesc ,
                    A.Menus ,
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
            	  FROM ( SELECT EntityKey ,
                             T.DeptGroupId ,
                             DeptGroupName ,
                             DeptGroupDesc ,
                             Menus || '|' || ParentID Menus  ,
                             NVL(T.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             'Y' IsMainTable  ,
                             T.CreatedBy ,
                             T.DateCreated ,
                             T.ApprovedBy ,
                             T.DateApproved ,
                             T.ModifiedBy ,
                             T.DateModified ,
                             NVL(T.ModifiedBy, T.CreatedBy) CrModBy  ,
                             NVL(T.DateModified, T.DateCreated) CrModDate  ,
                             NVL(T.ApprovedBy, T.ApprovedByFirstLevel) CrAppBy  ,
                             NVL(T.DateApproved, T.DateApprovedFirstLevel) CrAppDate  ,
                             NVL(T.ApprovedBy, T.ModifiedBy) ModAppBy  ,
                             NVL(T.DateApproved, T.DateModified) ModAppDate  

                      --select *
                      FROM tt_TmpGroupDtl1_2 T
                             LEFT JOIN ( SELECT DeptGroupId ,
                                                ParentID 
                                         FROM ( SELECT DeptGroupId ,
                                                       utils.stuff(( SELECT ',' || UTILS.CONVERT_TO_VARCHAR2(ParentId,10) 
                                                                     FROM tt_TmpGroupMenuParent1_2 M1
                                                                      WHERE  M2.DeptGroupId = M1.DeptGroupId ), 1, 1, ' ') ParentID  
                                                FROM tt_TmpGroupMenuParent1_2 M2 ) B
                                           GROUP BY DeptGroupId,ParentID ) B   ON T.DeptGroupId = B.DeptGroupId
                       WHERE  T.EffectiveFromTimeKey <= v_TimeKey
                                AND T.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
                                AND NVL(T.AuthorisationStatus, 'A') IN ( '1A' )

                                AND T.DeptGroupId IN ( SELECT MAX(DeptGroupId)  
                                                       FROM DimUserDeptGroup_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                         GROUP BY DeptGroupId )
                     ) A
            	  GROUP BY A.EntityKey,A.DeptGroupId,A.DeptGroupName,A.DeptGroupDesc,A.Menus,A.AuthorisationStatus,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DeptGroupId  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               * 

                        --'CollateralSubTypeMaster' TableName, 
                        FROM ( SELECT * 
                               FROM tt_temp20_209 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.DateCreated DESC ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."USERGROUPSAUXSELECT_04122023" TO "ADF_CDR_RBL_STGDB";
