--------------------------------------------------------
--  DDL for Procedure PUI_DETAILSSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" 
(
  --Declare
  v_CustomerID IN VARCHAR2 DEFAULT ' ' ,
  v_AccountID IN VARCHAR2 DEFAULT ' ' ,
  --@PageNo         INT         = 1, --@PageSize       INT         = 10, 
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
   IF v_CustomerID IS NOT NULL THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM AdvAcProjectDetail A
                              WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                       AND A.EffectiveToTimeKey >= v_TimeKey
                                       AND A.CustomerId = v_CustomerID
                             UNION 
                             SELECT 1 
                             FROM AdvAcProjectDetail_Mod A
                              WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                       AND A.EffectiveToTimeKey >= v_TimeKey
                                       AND A.CustomerId = v_CustomerID );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT 'Customer Id Not Exists' Errormsg  ,
                   'ErrorTable' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   IF v_AccountID IS NOT NULL THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT 1 
                             FROM AdvAcProjectDetail A
                              WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                       AND A.EffectiveToTimeKey >= v_TimeKey
                                       AND A.AccountId = v_AccountID
                             UNION 
                             SELECT 1 
                             FROM AdvAcProjectDetail_Mod A
                              WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                       AND A.EffectiveToTimeKey >= v_TimeKey
                                       AND A.AccountId = v_AccountID );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT 'Account Id Not Exists' Errormsg  ,
                   'ErrorTable' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   END IF;
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_202') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_202 ';
            END IF;
            DELETE FROM tt_temp_202;
            UTILS.IDENTITY_RESET('tt_temp_202');

            INSERT INTO tt_temp_202 ( 
            	SELECT A.CustomerId ,
                    A.CustomerName ,
                    A.AccountId ,
                    A.OriginalEnvisagCompletionDt ,
                    A.RevisedCompletionDt ,
                    A.ActualCompletionDt ,
                    a.ProjectCatgAlt_Key ,
                    A.ProjectCategory ,
                    A.ProjectDelReason_AltKey ,
                    A.ProjectDelReason ,
                    A.StandardRestruct_Altkey ,
                    A.StandardRestruct ,
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
            	  FROM ( SELECT A.CustomerId ,
                             A.CustomerName ,
                             A.AccountId ,
                             UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                             a.ProjectCatgAlt_Key ,
                             H.ParameterName ProjectCategory  ,
                             A.ProjectDelReason_AltKey ,
                             i.ParameterName ProjectDelReason  ,
                             A.StandardRestruct_Altkey ,
                             J.ParameterName StandardRestruct  ,
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
                      FROM AdvAcProjectDetail A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ProjectCategory' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'ProjectCategory'
                                              AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.ProjectCatgAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ProdectDelReson' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'ProdectDelReson'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.ProjectDelReason_AltKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'StandardRestruct' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimYesNo'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) j   ON j.ParameterAlt_Key = A.StandardRestruct_Altkey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.CustomerId ,
                             A.CustomerName ,
                             A.AccountId ,
                             UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                             a.ProjectCatgAlt_Key ,
                             H.ParameterName ProjectCategory  ,
                             A.ProjectDelReason_AltKey ,
                             i.ParameterName ProjectDelReason  ,
                             A.StandardRestruct_Altkey ,
                             J.ParameterName StandardRestruct  ,
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
                      FROM AdvAcProjectDetail_Mod A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ProjectCategory' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'ProjectCategory'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.ProjectCatgAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ProdectDelReson' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'ProdectDelReson'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.ProjectDelReason_AltKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'StandardRestruct' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimYesNo'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) j   ON j.ParameterAlt_Key = A.StandardRestruct_Altkey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))

                                --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM AdvAcProjectDetail_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY CustomerID )
                     ) A
            	  GROUP BY A.CustomerId,A.CustomerName,A.AccountId,A.OriginalEnvisagCompletionDt,A.RevisedCompletionDt,A.ActualCompletionDt,a.ProjectCatgAlt_Key,A.ProjectCategory,A.ProjectDelReason_AltKey,A.ProjectDelReason,A.StandardRestruct_Altkey,A.StandardRestruct,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'PUIMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_202 A
                                WHERE  NVL(AccountId, ' ') = NVL(v_AccountID, ' ')
                                         OR NVL(CustomerID, ' ') = NVL(v_CustomerID, ' ') ) DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_operationflag = 16 ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_20216') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_157 ';
               END IF;
               DELETE FROM tt_temp16_157;
               UTILS.IDENTITY_RESET('tt_temp16_157');

               INSERT INTO tt_temp16_157 ( 
               	SELECT A.CustomerId ,
                       A.CustomerName ,
                       A.AccountId ,
                       A.OriginalEnvisagCompletionDt ,
                       A.RevisedCompletionDt ,
                       A.ActualCompletionDt ,
                       a.ProjectCatgAlt_Key ,
                       A.ProjectCategory ,
                       A.ProjectDelReason_AltKey ,
                       A.ProjectDelReason ,
                       A.StandardRestruct_Altkey ,
                       A.StandardRestruct ,
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
               	  FROM ( SELECT A.CustomerId ,
                                A.CustomerName ,
                                A.AccountId ,
                                UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                                a.ProjectCatgAlt_Key ,
                                H.ParameterName ProjectCategory  ,
                                A.ProjectDelReason_AltKey ,
                                i.ParameterName ProjectDelReason  ,
                                A.StandardRestruct_Altkey ,
                                J.ParameterName StandardRestruct  ,
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
                         FROM AdvAcProjectDetail_Mod A
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'ProjectCategory' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'ProjectCategory'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.ProjectCatgAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'ProdectDelReson' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'ProdectDelReson'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.ProjectDelReason_AltKey
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'StandardRestruct' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DimYesNo'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) j   ON j.ParameterAlt_Key = A.StandardRestruct_Altkey
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))

                                   --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM AdvAcProjectDetail_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY CustomerID )
                        ) A
               	  GROUP BY A.CustomerId,A.CustomerName,A.AccountId,A.OriginalEnvisagCompletionDt,A.RevisedCompletionDt,A.ActualCompletionDt,a.ProjectCatgAlt_Key,A.ProjectCategory,A.ProjectDelReason_AltKey,A.ProjectDelReason,A.StandardRestruct_Altkey,A.StandardRestruct,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'PUIMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_157 A
                                   WHERE  NVL(AccountId, ' ') LIKE '%' || NVL(v_CustomerID, ' ') || '%'
                                            AND NVL(CustomerID, ' ') LIKE '%' || NVL(v_CustomerID, ' ') || '%' ) DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;

            --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

            --      AND RowNumber <= (@PageNo * @PageSize)
            ELSE
               IF ( v_OperationFlag = 20 ) THEN

               BEGIN
                  IF utils.object_id('TempDB..tt_temp_20220') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_122 ';
                  END IF;
                  DELETE FROM tt_temp20_122;
                  UTILS.IDENTITY_RESET('tt_temp20_122');

                  INSERT INTO tt_temp20_122 ( 
                  	SELECT A.CustomerId ,
                          A.CustomerName ,
                          A.AccountId ,
                          A.OriginalEnvisagCompletionDt ,
                          A.RevisedCompletionDt ,
                          A.ActualCompletionDt ,
                          a.ProjectCatgAlt_Key ,
                          A.ProjectCategory ,
                          A.ProjectDelReason_AltKey ,
                          A.ProjectDelReason ,
                          A.StandardRestruct_Altkey ,
                          A.StandardRestruct ,
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
                  	  FROM ( SELECT A.CustomerId ,
                                   A.CustomerName ,
                                   A.AccountId ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.OriginalEnvisagCompletionDt,20,p_style=>103) OriginalEnvisagCompletionDt  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.RevisedCompletionDt,20,p_style=>103) RevisedCompletionDt  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.ActualCompletionDt,20,p_style=>103) ActualCompletionDt  ,
                                   a.ProjectCatgAlt_Key ,
                                   H.ParameterName ProjectCategory  ,
                                   A.ProjectDelReason_AltKey ,
                                   i.ParameterName ProjectDelReason  ,
                                   A.StandardRestruct_Altkey ,
                                   J.ParameterName StandardRestruct  ,
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
                            FROM AdvAcProjectDetail_Mod A
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'ProjectCategory' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'ProjectCategory'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.ProjectCatgAlt_Key
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'ProdectDelReson' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'ProdectDelReson'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) I   ON I.ParameterAlt_Key = A.ProjectDelReason_AltKey
                                   JOIN ( SELECT ParameterAlt_Key ,
                                                 ParameterName ,
                                                 'StandardRestruct' Tablename  
                                          FROM DimParameter 
                                           WHERE  DimParameterName = 'DimYesNo'
                                                    AND EffectiveFromTimeKey <= v_TimeKey
                                                    AND EffectiveToTimeKey >= v_TimeKey ) j   ON j.ParameterAlt_Key = A.StandardRestruct_Altkey
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM AdvAcProjectDetail_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY CustomerID )
                           ) A
                  	  GROUP BY A.CustomerId,A.CustomerName,A.AccountId,A.OriginalEnvisagCompletionDt,A.RevisedCompletionDt,A.ActualCompletionDt,a.ProjectCatgAlt_Key,A.ProjectCategory,A.ProjectDelReason_AltKey,A.ProjectDelReason,A.StandardRestruct_Altkey,A.StandardRestruct,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CustomerID  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'PUIMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_122 A
                                      WHERE  NVL(AccountId, ' ') LIKE '%' || NVL(v_CustomerID, ' ') || '%'
                                               AND NVL(CustomerID, ' ') LIKE '%' || NVL(v_CustomerID, ' ') || '%' ) DataPointOwner ) DataPointOwner ;
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
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;END;
   DECLARE
      v_Cust_Id VARCHAR2(20) := ( SELECT CustomerID 
        FROM AdvAcProjectDetail A
       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                AND A.EffectiveToTimeKey >= v_TimeKey
                AND A.AccountId = v_AccountID );--AND ((H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented'))
      --AND (H.ParameterName NOT IN('Out Default') and I.ParameterName NOT IN('Implemented with Extension')))
      --EXEC RPLenderDetailsSelect @CustomerID=@Cust_Id
   --RETURN -1

   BEGIN
      NULL;

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PUI_DETAILSSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
