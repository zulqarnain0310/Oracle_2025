--------------------------------------------------------
--  DDL for Procedure GLPRODUCTMASTERSEARCLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --[GLProductMasterSearcList] 1

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14550 
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
         --select * from 	SysCRisMacMenu where menucaption like '%GL%'
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            DBMS_OUTPUT.PUT_LINE('Sac');
            IF utils.object_id('TempDB..tt_temp_149') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_149 ';
            END IF;
            DELETE FROM tt_temp_149;
            UTILS.IDENTITY_RESET('tt_temp_149');

            INSERT INTO tt_temp_149 ( 
            	SELECT A.GLProductAlt_Key ,
                    A.ProductCode ,
                    A.ProductName ,
                    A.SourceName ,
                    A.SourceAlt_key ,
                    A.FacilityType ,
                    A.FacilityTypeAlt_Key ,
                    A.AssetGLCode_STD ,
                    A.InterestReceivableGLCode_STD ,
                    A.InerestAccruedGLCode_STD ,
                    A.InterestIncome_STD ,
                    A.SuspendedAssetGLCode_NPA ,
                    A.SuspendedInterestReceivableGLCode_NPA ,
                    A.SuspendedInterestAccruedGLCode_NPA ,
                    A.SuspendedInterestIncomeGLCode_NPA ,
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
            	  FROM ( SELECT A.GLProductAlt_Key ,
                             B.ProductCode ,
                             B.ProductName ,
                             C.SourceName ,
                             C.SourceAlt_Key ,
                             D.ParameterName FacilityType  ,
                             A.FacilityTypeAlt_Key ,
                             A.AssetGLCode_STD ,
                             A.InterestReceivableGLCode_STD ,
                             A.InerestAccruedGLCode_STD ,
                             A.InterestIncome_STD ,
                             A.SuspendedAssetGLCode_NPA ,
                             A.SuspendedInterestReceivableGLCode_NPA ,
                             A.SuspendedInterestAccruedGLCode_NPA ,
                             A.SuspendedInterestIncomeGLCode_NPA ,
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
                      FROM DimGLProduct_AU A
                             JOIN DimProduct B   ON A.ProductCode = B.ProductCode
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             JOIN DIMSOURCEDB C   ON A.SourceAlt_key = C.SourceAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'Facility Type' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimGLProduct'
                                              AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.FacilityTypeAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.GLProductAlt_Key ,
                             B.ProductCode ,
                             B.ProductName ,
                             C.SourceName ,
                             C.SourceAlt_Key ,
                             D.ParameterName FacilityType  ,
                             A.FacilityTypeAlt_Key ,
                             A.AssetGLCode_STD ,
                             A.InterestReceivableGLCode_STD ,
                             A.InerestAccruedGLCode_STD ,
                             A.InterestIncome_STD ,
                             A.SuspendedAssetGLCode_NPA ,
                             A.SuspendedInterestReceivableGLCode_NPA ,
                             A.SuspendedInterestAccruedGLCode_NPA ,
                             A.SuspendedInterestIncomeGLCode_NPA ,
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
                      FROM DimGLProduct_AU_Mod A
                             JOIN DimProduct B   ON A.ProductCode = B.ProductCode
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                             JOIN DIMSOURCEDB C   ON A.SourceAlt_key = C.SourceAlt_Key
                             AND C.EffectiveFromTimeKey <= v_TimeKey
                             AND C.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'Facility Type' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimGLProduct'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.FacilityTypeAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimGLProduct_AU_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY GLProductAlt_Key )
                     ) A
            	  GROUP BY A.GLProductAlt_Key,A.ProductCode,A.ProductName,A.SourceName,A.SourceAlt_key,A.FacilityType,A.FacilityTypeAlt_Key,A.AssetGLCode_STD,A.InterestReceivableGLCode_STD,A.InerestAccruedGLCode_STD,A.InterestIncome_STD,A.SuspendedAssetGLCode_NPA,A.SuspendedInterestReceivableGLCode_NPA,A.SuspendedInterestAccruedGLCode_NPA,A.SuspendedInterestIncomeGLCode_NPA,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY GLProductAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'GLProductMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_149 A ) 
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
               IF utils.object_id('TempDB..tt_temp_14916') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_119 ';
               END IF;
               DELETE FROM tt_temp16_119;
               UTILS.IDENTITY_RESET('tt_temp16_119');

               INSERT INTO tt_temp16_119 ( 
               	SELECT A.GLProductAlt_Key ,
                       A.ProductCode ,
                       A.ProductName ,
                       A.SourceName ,
                       A.SourceAlt_key ,
                       A.FacilityType ,
                       A.FacilityTypeAlt_Key ,
                       A.AssetGLCode_STD ,
                       A.InterestReceivableGLCode_STD ,
                       A.InerestAccruedGLCode_STD ,
                       A.InterestIncome_STD ,
                       A.SuspendedAssetGLCode_NPA ,
                       A.SuspendedInterestReceivableGLCode_NPA ,
                       A.SuspendedInterestAccruedGLCode_NPA ,
                       A.SuspendedInterestIncomeGLCode_NPA ,
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
               	  FROM ( SELECT A.GLProductAlt_Key ,
                                B.ProductCode ,
                                B.ProductName ,
                                C.SourceName ,
                                C.SourceAlt_Key ,
                                D.ParameterName FacilityType  ,
                                A.FacilityTypeAlt_Key ,
                                A.AssetGLCode_STD ,
                                A.InterestReceivableGLCode_STD ,
                                A.InerestAccruedGLCode_STD ,
                                A.InterestIncome_STD ,
                                A.SuspendedAssetGLCode_NPA ,
                                A.SuspendedInterestReceivableGLCode_NPA ,
                                A.SuspendedInterestAccruedGLCode_NPA ,
                                A.SuspendedInterestIncomeGLCode_NPA ,
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
                         FROM DimGLProduct_AU_Mod A
                                JOIN DimProduct B   ON A.ProductCode = B.ProductCode
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                JOIN DIMSOURCEDB C   ON A.SourceAlt_key = C.SourceAlt_Key
                                AND C.EffectiveFromTimeKey <= v_TimeKey
                                AND C.EffectiveToTimeKey >= v_TimeKey
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'Facility Type' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DimGLProduct'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.FacilityTypeAlt_Key
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimGLProduct_AU_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY GLProductAlt_Key )
                        ) A
               	  GROUP BY A.GLProductAlt_Key,A.ProductCode,A.ProductName,A.SourceName,A.SourceAlt_key,A.FacilityType,A.FacilityTypeAlt_Key,A.AssetGLCode_STD,A.InterestReceivableGLCode_STD,A.InerestAccruedGLCode_STD,A.InterestIncome_STD,A.SuspendedAssetGLCode_NPA,A.SuspendedInterestReceivableGLCode_NPA,A.SuspendedInterestAccruedGLCode_NPA,A.SuspendedInterestIncomeGLCode_NPA,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY GLProductAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'GLProductMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_119 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_14920') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_84 ';
                  END IF;
                  DELETE FROM tt_temp20_84;
                  UTILS.IDENTITY_RESET('tt_temp20_84');

                  INSERT INTO tt_temp20_84 ( 
                  	SELECT A.GLProductAlt_Key ,
                          A.ProductCode ,
                          A.ProductName ,
                          A.SourceName ,
                          A.SourceAlt_key ,
                          A.FacilityType ,
                          A.FacilityTypeAlt_Key ,
                          A.AssetGLCode_STD ,
                          A.InterestReceivableGLCode_STD ,
                          A.InerestAccruedGLCode_STD ,
                          A.InterestIncome_STD ,
                          A.SuspendedAssetGLCode_NPA ,
                          A.SuspendedInterestReceivableGLCode_NPA ,
                          A.SuspendedInterestAccruedGLCode_NPA ,
                          A.SuspendedInterestIncomeGLCode_NPA ,
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
                  	  FROM ( SELECT A.GLProductAlt_Key ,
                                   B.ProductCode ,
                                   B.ProductName ,
                                   C.SourceName ,
                                   C.SourceAlt_Key ,
                                   D.ParameterName FacilityType  ,
                                   A.FacilityTypeAlt_Key ,
                                   A.AssetGLCode_STD ,
                                   A.InterestReceivableGLCode_STD ,
                                   A.InerestAccruedGLCode_STD ,
                                   A.InterestIncome_STD ,
                                   A.SuspendedAssetGLCode_NPA ,
                                   A.SuspendedInterestReceivableGLCode_NPA ,
                                   A.SuspendedInterestAccruedGLCode_NPA ,
                                   A.SuspendedInterestIncomeGLCode_NPA ,
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
                            FROM DimGLProduct_AU_Mod A
                                   JOIN DimProduct B   ON A.ProductCode = B.ProductCode
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   JOIN DIMSOURCEDB C   ON A.SourceAlt_key = C.SourceAlt_Key
                                   AND C.EffectiveFromTimeKey <= v_TimeKey
                                   AND C.EffectiveToTimeKey >= v_TimeKey
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'Facility Type' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'DimGLProduct'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) D   ON D.ParameterAlt_Key = A.FacilityTypeAlt_Key
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM DimGLProduct_AU_Mod 
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
                                                             GROUP BY GLProductAlt_Key )
                           ) A
                  	  GROUP BY A.GLProductAlt_Key,A.ProductCode,A.ProductName,A.SourceName,A.SourceAlt_key,A.FacilityType,A.FacilityTypeAlt_Key,A.AssetGLCode_STD,A.InterestReceivableGLCode_STD,A.InerestAccruedGLCode_STD,A.InterestIncome_STD,A.SuspendedAssetGLCode_NPA,A.SuspendedInterestReceivableGLCode_NPA,A.SuspendedInterestAccruedGLCode_NPA,A.SuspendedInterestIncomeGLCode_NPA,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY GLProductAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'GLProductMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_84 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."GLPRODUCTMASTERSEARCLIST" TO "ADF_CDR_RBL_STGDB";
