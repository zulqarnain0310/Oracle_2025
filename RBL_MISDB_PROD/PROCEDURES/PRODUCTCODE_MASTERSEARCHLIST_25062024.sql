--------------------------------------------------------
--  DDL for Procedure PRODUCTCODE_MASTERSEARCHLIST_25062024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" 
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
            IF utils.object_id('TempDB..tt_temp_212') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_212 ';
            END IF;
            DELETE FROM tt_temp_212;
            UTILS.IDENTITY_RESET('tt_temp_212');

            INSERT INTO tt_temp_212 ( 
            	SELECT A.ProductAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SourceName ,
                    A.ProductCode ,
                    A.ProductName ,
                    A.ProductGroup ,
                    A.ProductSubGroup ,
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
            	  FROM ( SELECT A.ProductAlt_Key ,
                             B.SourceAlt_Key ,
                             B.SourceName ,
                             A.ProductCode ,
                             A.ProductName ,
                             A.ProductGroup ,
                             A.ProductSubGroup ,
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

                      --select *
                      FROM DimProduct A
                             JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 

                      --select * into DimGLProduct_Mod from DimGLProduct

                      --alter table DimGLProduct_Mod

                      --add  Remark varchar(max)

                      --,Change varchar(max)
                      SELECT A.ProductAlt_Key ,
                             B.SourceAlt_Key ,
                             B.SourceName ,
                             A.ProductCode ,
                             A.ProductName ,
                             A.ProductGroup ,
                             A.ProductSubGroup ,
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
                      FROM DimProduct_Mod A
                             JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Product_Key IN ( SELECT MAX(Product_Key)  
                                                       FROM DimProduct_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                         GROUP BY Product_Key )
                     ) A
            	  GROUP BY A.ProductAlt_Key,A.SourceAlt_Key,A.SourceName,A.ProductCode,A.ProductName,A.ProductGroup,A.ProductSubGroup,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ProductAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'ProductCodeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_212 A ) 
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
               IF utils.object_id('TempDB..tt_temp_21216') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_167 ';
               END IF;
               DELETE FROM tt_temp16_167;
               UTILS.IDENTITY_RESET('tt_temp16_167');

               INSERT INTO tt_temp16_167 ( 
               	SELECT A.ProductAlt_Key ,
                       A.SourceAlt_Key ,
                       A.SourceName ,
                       A.ProductCode ,
                       A.ProductName ,
                       A.ProductGroup ,
                       A.ProductSubGroup ,
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
               	  FROM ( SELECT A.ProductAlt_Key ,
                                B.SourceAlt_Key ,
                                B.SourceName ,
                                A.ProductCode ,
                                A.ProductName ,
                                A.ProductGroup ,
                                A.ProductSubGroup ,
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
                         FROM DimProduct_Mod A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Product_Key IN ( SELECT MAX(Product_Key)  
                                                          FROM DimProduct_Mod 
                                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                            GROUP BY ProductAlt_Key )
                        ) A
               	  GROUP BY A.ProductAlt_Key,A.SourceAlt_Key,A.SourceName,A.ProductCode,A.ProductName,A.ProductGroup,A.ProductSubGroup,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ProductAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'ProductCodeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_167 A ) 
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
            IF utils.object_id('TempDB..tt_temp_21220') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_132 ';
            END IF;
            DELETE FROM tt_temp20_132;
            UTILS.IDENTITY_RESET('tt_temp20_132');

            INSERT INTO tt_temp20_132 ( 
            	SELECT A.ProductAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SourceName ,
                    A.ProductCode ,
                    A.ProductName ,
                    A.ProductGroup ,
                    A.ProductSubGroup ,
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
            	  FROM ( SELECT A.ProductAlt_Key ,
                             B.SourceAlt_Key ,
                             B.SourceName ,
                             A.ProductCode ,
                             A.ProductName ,
                             A.ProductGroup ,
                             A.ProductSubGroup ,
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
                      FROM DimProduct_Mod A
                             JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Product_Key IN ( SELECT MAX(Product_Key)  
                                                       FROM DimProduct_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND (CASE 
                                                                           WHEN v_AuthLevel = 2
                                                                             AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
            	 THEN 1
            	WHEN v_AuthLevel = 1
            	  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
            	 THEN 1
                                                               ELSE 0
                                                                  END) = 1
                                                         GROUP BY ProductAlt_Key )
                     ) A
            	  GROUP BY A.ProductAlt_Key,A.SourceAlt_Key,A.SourceName,A.ProductCode,A.ProductName,A.ProductGroup,A.ProductSubGroup,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ProductAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'ProductCodeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp20_132 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PRODUCTCODE_MASTERSEARCHLIST_25062024" TO "ADF_CDR_RBL_STGDB";
