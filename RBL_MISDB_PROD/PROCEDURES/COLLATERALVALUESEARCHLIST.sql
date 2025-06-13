--------------------------------------------------------
--  DDL for Procedure COLLATERALVALUESEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" 
-- [CollateralValueSearchList] 1,'1000001'

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_CollateralID IN VARCHAR2 DEFAULT ' ' 
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
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_86') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_86 ';
            END IF;
            IF utils.object_id('TempDB..tt_temp_861') IS NOT NULL THEN
             EXECUTE IMMEDIATE 'DROP TABLE temp1';
            END IF;
            DBMS_OUTPUT.PUT_LINE('SachinSac');
            DELETE FROM tt_temp_86;
            UTILS.IDENTITY_RESET('tt_temp_86');

            INSERT INTO tt_temp_86 ( 
            	SELECT A.CollateralID ,
                    ValuationDate ,
                    A.LatestCollateralValueinRs ,
                    A.ExpiryBusinessRule ,
                    A.Periodinmonth ,
                    A.ValueExpirationDate ,
                    A.AuthorisationStatus ,
                    A.SecurityEntityID ,
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
            	  FROM ( SELECT B.CollateralID ,
                             UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                             B.CurrentValue LatestCollateralValueinRs  ,
                             B.ExpiryBusinessRule ,
                             B.Periodinmonth ,
                             UTILS.CONVERT_TO_VARCHAR2(B.ValuationExpiryDate,10,p_style=>103) ValueExpirationDate  ,
                             NVL(B.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             B.SecurityEntityID ,
                             B.EffectiveFromTimeKey ,
                             B.EffectiveToTimeKey ,
                             B.CreatedBy ,
                             B.DateCreated ,
                             B.ApprovedBy ,
                             B.DateApproved ,
                             B.ModifiedBy ,
                             B.DateModified ,
                             NVL(B.ModifiedBy, B.CreatedBy) CrModBy  ,
                             NVL(B.DateModified, B.DateCreated) CrModDate  ,
                             NVL(B.ApprovedBy, B.CreatedBy) CrAppBy  ,
                             NVL(B.DateApproved, B.DateCreated) CrAppDate  ,
                             NVL(B.ApprovedBy, B.ModifiedBy) ModAppBy  ,
                             NVL(B.DateApproved, B.DateModified) ModAppDate  
                      FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail B

                      --inner join DIMSOURCEDB B  

                      --ON B.ValuationSourceNameAlt_Key=B.SourceAlt_Key  

                      --AND B.EffectiveFromTimeKey <= @TimeKey  

                      --                     AND B.EffectiveToTimeKey >= @TimeKey  
                      WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                               AND B.EffectiveToTimeKey >= v_TimeKey
                               AND NVL(B.AuthorisationStatus, 'A') = 'A'
                               AND B.CollateralID = v_CollateralID
                      UNION ALL 
                      SELECT B.CollateralID ,
                             UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                             B.CurrentValue LatestCollateralValueinRs  ,
                             B.ExpiryBusinessRule ,
                             B.Periodinmonth ,
                             UTILS.CONVERT_TO_VARCHAR2(B.ValuationExpiryDate,10,p_style=>103) ValueExpirationDate  ,
                             NVL(B.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             B.SecurityEntityID ,
                             B.EffectiveFromTimeKey ,
                             B.EffectiveToTimeKey ,
                             B.CreatedBy ,
                             B.DateCreated ,
                             B.ApprovedBy ,
                             B.DateApproved ,
                             B.ModifiedBy ,
                             B.DateModified ,
                             NVL(B.ModifiedBy, B.CreatedBy) CrModBy  ,
                             NVL(B.DateModified, B.DateCreated) CrModDate  ,
                             NVL(B.ApprovedBy, B.CreatedBy) CrAppBy  ,
                             NVL(B.DateApproved, B.DateCreated) CrAppDate  ,
                             NVL(B.ApprovedBy, B.ModifiedBy) ModAppBy  ,
                             NVL(B.DateApproved, B.DateModified) ModAppDate  
                      FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod B

                      ----inner join DIMSOURCEDB B  

                      ----ON B.ValuationSourceNameAlt_Key=B.SourceAlt_Key  

                      ----AND B.EffectiveFromTimeKey <= 26002  

                      ----                     AND B.EffectiveToTimeKey >= 26002  
                      WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                               AND B.EffectiveToTimeKey >= v_TimeKey
                               AND B.CollateralID = v_CollateralID
                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
                     ) 
                    --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')  

                    --      AND B.ENTITYKEY  

                    --  IN  

                    --(  

                    --    SELECT MAX(ENTITYKEY)  

                    --    FROM dbo.AdvSecurityValueDetail_Mod 

                    --    WHERE EffectiveFromTimeKey <= @TimeKey  

                    --          AND EffectiveToTimeKey >= @TimeKey  

                    --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  

                    --    GROUP BY CollateralID  

                    --)  
                    A );
            --Select 'tt_temp_86',* from tt_temp_86
            --Select 'tt_temp_86',* from tt_temp_86 Where CollateralID='1000034'  
            DELETE FROM tt_temp1_4;
            UTILS.IDENTITY_RESET('tt_temp1_4');

            INSERT INTO tt_temp1_4 SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralValue' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_86 A
                                WHERE  A.CollateralID = v_CollateralID ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'  

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'  
                             DataPointOwner ) DataPointOwner;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM tt_temp1_4  ;
               DBMS_SQL.RETURN_RESULT(v_cursor);
            --Select A.CollateralID   ,ValuationDate ,A.LatestCollateralValueinRs,B.Documents,A.Periodinmonth 
            -- ,A.ValueExpirationDate ,A.AuthorisationStatus,  A.EffectiveFromTimeKey, A.EffectiveToTimeKey, 
            --  A.CreatedBy,A.DateCreated,A.ApprovedBy,  A.DateApproved, A.ModifiedBy,A.DateModified,  A.CrModBy, 
            -- A.CrModDate, A.CrAppBy,  A.CrAppDate,  A.ModAppBy,  A.ModAppDate   from tt_temp_861 A
            --INNER JOIN DimValueExpiration B ON A.ExpiryBusinessRule=b.ValueExpirationAltKey
            ---------------------------------------------------For Max Default Values check--------------  
            OPEN  v_cursor FOR
               SELECT CollateralID ,
                      CurrentValue CollateralValueatthetimeoflastreviewinRs  ,
                      'CollateralDefaultValue' TableName  
                 FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
                WHERE  EffectiveFromTimeKey <= v_TimeKey
                         AND EffectiveToTimeKey >= v_TimeKey
                         AND CollateralID = v_CollateralID
                         AND ValuationDate = ( SELECT MAX(ValuationDate)  ValuationDate  
                                               FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail 
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
               IF utils.object_id('TempDB..tt_temp_8617') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp17 ';
               END IF;
               DELETE FROM tt_temp17;
               UTILS.IDENTITY_RESET('tt_temp17');

               INSERT INTO tt_temp17 ( 
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
               --Select * from tt_temp_8616
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'CollateralValue' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp17 A
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
                  IF utils.object_id('TempDB..tt_temp_8616') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_56 ';
                  END IF;
                  DBMS_OUTPUT.PUT_LINE('Sachin16');
                  DELETE FROM tt_temp16_56;
                  UTILS.IDENTITY_RESET('tt_temp16_56');

                  INSERT INTO tt_temp16_56 ( 
                  	SELECT A.CollateralID ,
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
                  	  FROM ( SELECT B.CollateralID ,
                                   UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                                   B.CurrentValue LatestCollateralValueinRs  ,
                                   B.ExpiryBusinessRule ,
                                   B.Periodinmonth ,
                                   UTILS.CONVERT_TO_VARCHAR2(B.ValuationExpiryDate,10,p_style=>103) ValueExpirationDate  ,
                                   NVL(B.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   B.EffectiveFromTimeKey ,
                                   B.EffectiveToTimeKey ,
                                   B.CreatedBy ,
                                   B.DateCreated ,
                                   B.ApprovedBy ,
                                   B.DateApproved ,
                                   B.ModifiedBy ,
                                   B.DateModified ,
                                   NVL(B.ModifiedBy, B.CreatedBy) CrModBy  ,
                                   NVL(B.DateModified, B.DateCreated) CrModDate  ,
                                   NVL(B.ApprovedBy, B.CreatedBy) CrAppBy  ,
                                   NVL(B.DateApproved, B.DateCreated) CrAppDate  ,
                                   NVL(B.ApprovedBy, B.ModifiedBy) ModAppBy  ,
                                   NVL(B.DateApproved, B.DateModified) ModAppDate  
                            FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod B -- ON A.CollateralID=B.CollateralID  

                             WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                      AND B.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
                           ) 
                          --AND B.ENTITYKEY  

                          --                 IN  

                          --               (  

                          --                   SELECT MAX(ENTITYKEY)  

                          --                   FROM DBO.AdvSecurityValueDetail_MOD 

                          --                   WHERE EffectiveFromTimeKey <= @TimeKey  

                          --                         AND EffectiveToTimeKey >= @TimeKey  

                          --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  

                          --       GROUP BY CollateralID  

                          --  )  
                          A );
                  --Select 'tt_temp_8616',* from tt_temp_8616 
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
                  --                 A.EffectiveFromTimeKey,   
                  --          A.EffectiveToTimeKey,   
                  --                     A.CreatedBy,   
                  --                     A.DateCreated,   
                  --                     A.ApprovedBy,   
                  --                     A.DateApproved,   
                  --                     A.ModifiedBy,   
                  --                     A.DateModified  
                  --Select * from tt_temp_8616  
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'CollateralValue' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp16_56 A
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
                     IF utils.object_id('TempDB..tt_temp_8620') IS NOT NULL THEN
                      EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_23 ';
                     END IF;
                     DBMS_OUTPUT.PUT_LINE('Sachin20');
                     DELETE FROM tt_temp20_23;
                     UTILS.IDENTITY_RESET('tt_temp20_23');

                     INSERT INTO tt_temp20_23 ( 
                     	SELECT A.CollateralID ,
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
                     	  FROM ( SELECT B.CollateralID ,
                                      UTILS.CONVERT_TO_VARCHAR2(B.ValuationDate,10,p_style=>103) ValuationDate  ,
                                      B.CurrentValue LatestCollateralValueinRs  ,
                                      B.ExpiryBusinessRule ,
                                      B.Periodinmonth ,
                                      UTILS.CONVERT_TO_VARCHAR2(B.ValuationExpiryDate,10,p_style=>103) ValueExpirationDate  ,
                                      NVL(B.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                      B.EffectiveFromTimeKey ,
                                      B.EffectiveToTimeKey ,
                                      B.CreatedBy ,
                                      B.DateCreated ,
                                      B.ApprovedBy ,
                                      B.DateApproved ,
                                      B.ModifiedBy ,
                                      B.DateModified ,
                                      NVL(B.ModifiedBy, B.CreatedBy) CrModBy  ,
                                      NVL(B.DateModified, B.DateCreated) CrModDate  ,
                                      NVL(B.ApprovedBy, B.CreatedBy) CrAppBy  ,
                                      NVL(B.DateApproved, B.DateCreated) CrAppDate  ,
                                      NVL(B.ApprovedBy, B.ModifiedBy) ModAppBy  ,
                                      NVL(B.DateApproved, B.DateModified) ModAppDate  
                               FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod B -- ON A.CollateralID=B.CollateralID  

                                WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                         AND B.EffectiveToTimeKey >= v_TimeKey
                                         AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
                              ) 
                             --AND B.ENTITYKEY  

                             --                 IN  

                             --               (  

                             --                   SELECT MAX(ENTITYKEY)  

                             --                   FROM DBO.AdvSecurityValueDetail_MOD 

                             --                   WHERE EffectiveFromTimeKey <= @TimeKey  

                             --                         AND EffectiveToTimeKey >= @TimeKey  

                             --                         AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')  

                             --       GROUP BY CollateralID  

                             --            )  
                             A );
                     --Select 'tt_temp_8616',* from tt_temp_8616 
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
                     --                 A.EffectiveFromTimeKey,   
                     --          A.EffectiveToTimeKey,   
                     --                     A.CreatedBy,   
                     --                     A.DateCreated,   
                     --                     A.ApprovedBy,   
                     --                     A.DateApproved,   
                     --                     A.ModifiedBy,   
                     --                     A.DateModified  
                     --Select * from tt_temp_8616  
                     OPEN  v_cursor FOR
                        SELECT * 
                          FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ValuationDate DESC  ) RowNumber  ,
                                        COUNT(*) OVER ( ) TotalCount  ,
                                        'CollateralValue' TableName  ,
                                        * 
                                 FROM ( SELECT * 
                                        FROM tt_temp20_23 A
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUESEARCHLIST" TO "ADF_CDR_RBL_STGDB";
