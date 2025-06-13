--------------------------------------------------------
--  DDL for Procedure COLLATERALVALUESEARCHLIST_01102021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" 
-- [CollateralValueSearchList] 1,'1000001'

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_CollateralID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   --          GROUP BY	A.CollateralID
   --,A.CollateralValueatSanctioninRs
   --,A.CollateralValueasonNPAdateinRs
   --,A.CollateralValueatthetimeoflastreviewinRs
   --,A.ValuationSourceNameAlt_Key
   --,A.SourceName
   --,A.ValuationDate
   --,A.LatestCollateralValueinRs
   --,A.ExpiryBusinessRule
   --,A.Periodinmonth
   --,A.ValueExpirationDate
   --,A.AuthorisationStatus, 
   --                     A.EffectiveFromTimeKey, 
   --                     A.EffectiveToTimeKey, 
   --                     A.CreatedBy, 
   --                     A.DateCreated, 
   --                     A.ApprovedBy, 
   --                     A.DateApproved, 
   --                     A.ModifiedBy, 
   --                     A.DateModified;
   --Select * from tt_temp_87
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_87') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_87 ';
            END IF;
            DELETE FROM tt_temp_87;
            UTILS.IDENTITY_RESET('tt_temp_87');

            INSERT INTO tt_temp_87 ( 
            	SELECT A.CollateralID ,
                    A.CollateralValueatSanctioninRs ,
                    A.CollateralValueasonNPAdateinRs ,
                    A.CollateralValueatthetimeoflastreviewinRs ,
                    ValuationDate ,
                    A.LatestCollateralValueinRs ,
                    A.ExpiryBusinessRule ,
                    A.Periodinmonth ,
                    A.ValueExpirationDate ,
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
            	  FROM ( SELECT A.CollateralID ,
                             A.CollateralValueatSanctioninRs ,
                             A.CollateralValueasonNPAdateinRs ,
                             B.CollateralValueatthetimeoflastreviewinRs ,
                             UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                             B.CurrentValue LatestCollateralValueinRs  ,
                             B.ExpiryBusinessRule ,
                             B.Periodinmonth ,
                             B.ValuationExpiryDate ValueExpirationDate  ,
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
                      FROM CurDat_RBL_MISDB_PROD.AdvSecurityDetail A --1

                             JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.CollateralID = B.CollateralID

                      --inner join DIMSOURCEDB B

                      --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key

                      --AND B.EffectiveFromTimeKey <= @TimeKey

                      --                     AND B.EffectiveToTimeKey >= @TimeKey
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                               AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION ALL 
                      SELECT A.CollateralID ,
                             A.CollateralValueatSanctioninRs ,
                             A.CollateralValueasonNPAdateinRs ,
                             B.CollateralValueatthetimeoflastreviewinRs ,
                             UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                             B.CurrentValue LatestCollateralValueinRs  ,
                             B.ExpiryBusinessRule ,
                             B.Periodinmonth ,
                             B.ValuationExpiryDate ValueExpirationDate  ,
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
                      FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A --1

                             JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.CollateralID = B.CollateralID

                      --inner join DIMSOURCEDB B

                      --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key

                      --AND B.EffectiveFromTimeKey <= @TimeKey

                      --                     AND B.EffectiveToTimeKey >= @TimeKey
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey

                               --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                               AND A.ENTITYKEY IN ( SELECT MAX(ENTITYKEY)  
                                                    FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey
                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                      GROUP BY CollateralID )
                     ) A );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralValue' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_87 A
                                WHERE  A.CollateralID = v_CollateralID ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
            --      AND RowNumber <= (@PageNo * @PageSize);
            ---------------------------------------------------For Max Default Values check--------------
            OPEN  v_cursor FOR
               SELECT CollateralID ,
                      CollateralValueatSanctioninRs ,
                      CollateralValueasonNPAdateinRs ,
                      LatestCollateralValueinRs CollateralValueatthetimeoflastreviewinRs  ,
                      'CollateralDefaultValue' TableName  
                 FROM CollateralValueDetails 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND CollateralID = v_CollateralID
                         AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                               FROM CollateralValueDetails 
                                                WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                         AND EffectiveToTimeKey >= v_TimeKey
                                                         AND CollateralID = v_CollateralID ) ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_8716') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_57 ';
               END IF;
               DELETE FROM tt_temp16_57;
               UTILS.IDENTITY_RESET('tt_temp16_57');

               INSERT INTO tt_temp16_57 ( 
               	SELECT A.CollateralID ,
                       A.CollateralValueatSanctioninRs ,
                       A.CollateralValueasonNPAdateinRs ,
                       A.CollateralValueatthetimeoflastreviewinRs ,
                       --,A.ValuationSourceNameAlt_Key
                       --,A.SourceName
                       A.ValuationDate ,
                       A.LatestCollateralValueinRs ,
                       A.ExpiryBusinessRule ,
                       A.Periodinmonth ,
                       A.ValueExpirationDate ,
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
               	  FROM ( SELECT A.CollateralID ,
                                A.CollateralValueatSanctioninRs ,
                                A.CollateralValueasonNPAdateinRs ,
                                B.CollateralValueatthetimeoflastreviewinRs ,
                                UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                                B.CurrentValue LatestCollateralValueinRs  ,
                                A.ExpiryBusinessRule ,
                                A.Periodinmonth ,
                                B.ValuationExpiryDate ValueExpirationDate  ,
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
                         FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A --1

                                JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.CollateralID = B.CollateralID

                         --inner join DIMSOURCEDB B

                         --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key

                         --AND B.EffectiveFromTimeKey <= @TimeKey

                         --                     AND B.EffectiveToTimeKey >= @TimeKey
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey

                                  --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                  AND A.EntityKey IN ( SELECT MAX(ENTITYKEY)  
                                                       FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                         GROUP BY CollateralID )
                        ) A );
               --          GROUP BY A.CollateralID
               --,A.CollateralValueatSanctioninRs
               --,A.CollateralValueasonNPAdateinRs
               --,A.CollateralValueatthetimeoflastreviewinRs
               --,A.ValuationSourceNameAlt_Key
               --,A.SourceName
               --,A.ValuationDate
               --,A.LatestCollateralValueinRs
               --,A.ExpiryBusinessRule
               --,A.Periodinmonth
               --,A.ValueExpirationDate
               --,A.AuthorisationStatus, 
               --                     A.EffectiveFromTimeKey, 
               --                     A.EffectiveToTimeKey, 
               --                     A.CreatedBy, 
               --                     A.DateCreated, 
               --                     A.ApprovedBy, 
               --                     A.DateApproved, 
               --                     A.ModifiedBy, 
               --                     A.DateModified
               --Select * from tt_temp_8716
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'CollateralValue' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_57 A
                                   WHERE  A.CollateralID = v_CollateralID ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               /*  IT IS Used For GRID Search which are Pending for Authorization    */
               IF ( v_OperationFlag IN ( 16 )
                ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_87160') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp160 ';
                  END IF;
                  DELETE FROM tt_temp160;
                  UTILS.IDENTITY_RESET('tt_temp160');

                  INSERT INTO tt_temp160 ( 
                  	SELECT A.CollateralID ,
                          A.CollateralValueatSanctioninRs ,
                          A.CollateralValueasonNPAdateinRs ,
                          A.CollateralValueatthetimeoflastreviewinRs ,
                          --,A.ValuationSourceNameAlt_Key
                          --,A.SourceName
                          A.ValuationDate ,
                          A.LatestCollateralValueinRs ,
                          A.ExpiryBusinessRule ,
                          A.Periodinmonth ,
                          A.ValueExpirationDate ,
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
                  	  FROM ( SELECT A.CollateralID ,
                                   A.CollateralValueatSanctioninRs ,
                                   A.CollateralValueasonNPAdateinRs ,
                                   B.CollateralValueatthetimeoflastreviewinRs ,
                                   UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                                   B.CurrentValue LatestCollateralValueinRs  ,
                                   B.ExpiryBusinessRule ,
                                   B.Periodinmonth ,
                                   B.ValuationExpiryDate ValueExpirationDate  ,
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
                            FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A --1

                                   JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.CollateralID = B.CollateralID

                            --inner join DIMSOURCEDB B

                            --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key

                            --AND B.EffectiveFromTimeKey <= @TimeKey

                            --                     AND B.EffectiveToTimeKey >= @TimeKey
                            WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                     AND A.EffectiveToTimeKey >= v_TimeKey
                                     AND NVL(A.AuthorisationStatus, 'A') = 'A' ) A );
                  --Select * from tt_temp_87160
                  --          GROUP BY A.CollateralID
                  --,A.CollateralValueatSanctioninRs
                  --,A.CollateralValueasonNPAdateinRs
                  --,A.CollateralValueatthetimeoflastreviewinRs
                  --,A.ValuationSourceNameAlt_Key
                  --,A.SourceName
                  --,A.ValuationDate
                  --,A.LatestCollateralValueinRs
                  --,A.ExpiryBusinessRule
                  --,A.Periodinmonth
                  --,A.ValueExpirationDate
                  --,A.AuthorisationStatus, 
                  --                     A.EffectiveFromTimeKey, 
                  --                     A.EffectiveToTimeKey, 
                  --                     A.CreatedBy, 
                  --                     A.DateCreated, 
                  --                     A.ApprovedBy, 
                  --                     A.DateApproved, 
                  --                     A.ModifiedBy, 
                  --                     A.DateModified
                  --Select * from tt_temp_8716
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'CollateralValue' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp160 A
                                      WHERE  A.CollateralID = v_CollateralID ) 
                                   --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                   --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                   DataPointOwner ) DataPointOwner ;
                     DBMS_SQL.RETURN_RESULT(v_cursor);

               END;

               --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

               --      AND RowNumber <= (@PageNo * @PageSize)
               ELSE
                  /*  IT IS Used For GRID Search which are Pending for Authorization    */
                  IF ( v_OperationFlag = 20 ) THEN

                  BEGIN
                     IF utils.object_id('TempDB..tt_temp_8720') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_24 ';
                     END IF;
                     DELETE FROM tt_temp20_24;
                     UTILS.IDENTITY_RESET('tt_temp20_24');

                     INSERT INTO tt_temp20_24 ( 
                     	SELECT A.CollateralID ,
                             A.CollateralValueatSanctioninRs ,
                             A.CollateralValueasonNPAdateinRs ,
                             A.CollateralValueatthetimeoflastreviewinRs ,
                             A.ValuationDate ,
                             A.LatestCollateralValueinRs ,
                             A.ExpiryBusinessRule ,
                             A.Periodinmonth ,
                             A.ValueExpirationDate ,
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
                     	  FROM ( SELECT A.CollateralID ,
                                      A.CollateralValueatSanctioninRs ,
                                      A.CollateralValueasonNPAdateinRs ,
                                      B.CollateralValueatthetimeoflastreviewinRs ,
                                      UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                                      B.CurrentValue LatestCollateralValueinRs  ,
                                      A.ExpiryBusinessRule ,
                                      A.Periodinmonth ,
                                      B.ValuationExpiryDate ValueExpirationDate  ,
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
                               FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod A --1

                                      JOIN CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B   ON A.CollateralID = B.CollateralID

                               --inner join DIMSOURCEDB B

                               --ON A.ValuationSourceNameAlt_Key=B.SourceAlt_Key

                               --AND B.EffectiveFromTimeKey <= @TimeKey

                               --                     AND B.EffectiveToTimeKey >= @TimeKey
                               WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                        AND A.EffectiveToTimeKey >= v_TimeKey

                                        --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                        AND A.EntityKey IN ( SELECT MAX(ENTITYKEY)  
                                                             FROM RBL_MISDB_PROD.AdvSecurityDetail_Mod 
                                                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey
                                                                       AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                               GROUP BY CollateralID )
                              ) A );
                     --          GROUP BY A.CollateralID
                     --,A.CollateralValueatSanctioninRs
                     --,A.CollateralValueasonNPAdateinRs
                     --,A.CollateralValueatthetimeoflastreviewinRs
                     --,A.ValuationSourceNameAlt_Key
                     --,A.SourceName
                     --,A.ValuationDate
                     --,A.LatestCollateralValueinRs
                     --,A.ExpiryBusinessRule
                     --,A.Periodinmonth
                     --,A.ValueExpirationDate
                     --,A.AuthorisationStatus, 
                     --                     A.EffectiveFromTimeKey, 
                     --                     A.EffectiveToTimeKey, 
                     --                     A.CreatedBy, 
                     --                     A.DateCreated, 
                     --                     A.ApprovedBy, 
                     --                     A.DateApproved, 
                     --                     A.ModifiedBy, 
                     --                     A.DateModified
                     OPEN  v_cursor FOR
                        SELECT * 
                          FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                                        COUNT(*) OVER ( ) TotalCount  ,
                                        'CollateralValue' TableName  ,
                                        * 
                                 FROM ( SELECT * 
                                        FROM tt_temp20_24 A
                                         WHERE  A.CollateralID = v_CollateralID ) 
                                      --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                      --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                      DataPointOwner ) DataPointOwner ;
                        DBMS_SQL.RETURN_RESULT(v_cursor);

                  END;
                  END IF;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST_01102021" TO "ADF_CDR_RBL_STGDB";
