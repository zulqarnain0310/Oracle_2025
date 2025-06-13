--------------------------------------------------------
--  DDL for Procedure DERIVATIVEDETAILSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
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
            IF utils.object_id('TempDB..tt_temp_94') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_94 ';
            END IF;
            DELETE FROM tt_temp_94;
            UTILS.IDENTITY_RESET('tt_temp_94');

            INSERT INTO tt_temp_94 ( 
            	SELECT A.EntityKey ,
                    A.DerivativeEntityID ,
                    A.CustomerACID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.DerivativeRefNo ,
                    A.Duedate ,
                    A.DueAmt ,
                    A.OsAmt ,
                    A.POS ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedBy ,
                    A.DateApproved 
            	  FROM ( SELECT A.EntityKey ,
                             A.DerivativeEntityID ,
                             A.CustomerACID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.DerivativeRefNo ,
                             A.Duedate ,
                             A.DueAmt ,
                             A.OsAmt ,
                             A.POS ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved 
                      FROM CurDat_RBL_MISDB_PROD.DerivativeDetail A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.EntityKey ,
                             A.DerivativeEntityID ,
                             A.CustomerACID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.DerivativeRefNo ,
                             A.Duedate ,
                             A.DueAmt ,
                             A.OsAmt ,
                             A.POS ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved 
                      FROM DerivativeDetail_mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DerivativeDetail_mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.EntityKey,A.DerivativeEntityID,A.CustomerACID,A.CustomerID,A.CustomerName,A.DerivativeRefNo,A.Duedate,A.DueAmt,A.OsAmt,A.POS,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'DerivativeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_94 A ) 
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
               IF utils.object_id('TempDB..tt_temp_9416') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_64 ';
               END IF;
               DELETE FROM tt_temp16_64;
               UTILS.IDENTITY_RESET('tt_temp16_64');

               INSERT INTO tt_temp16_64 ( 
               	SELECT A.EntityKey ,
                       A.DerivativeEntityID ,
                       A.CustomerACID ,
                       A.CustomerID ,
                       A.CustomerName ,
                       A.DerivativeRefNo ,
                       A.Duedate ,
                       A.DueAmt ,
                       A.OsAmt ,
                       A.POS ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedBy ,
                       A.DateApproved 
               	  FROM ( SELECT A.EntityKey ,
                                A.DerivativeEntityID ,
                                A.CustomerACID ,
                                A.CustomerID ,
                                A.CustomerName ,
                                A.DerivativeRefNo ,
                                A.Duedate ,
                                A.DueAmt ,
                                A.OsAmt ,
                                A.POS ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved 
                         FROM DerivativeDetail_mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DerivativeDetail_mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.EntityKey,A.DerivativeEntityID,A.CustomerACID,A.CustomerID,A.CustomerName,A.DerivativeRefNo,A.Duedate,A.DueAmt,A.OsAmt,A.POS,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'DerivativeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_64 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_9420') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_31 ';
                  END IF;
                  DELETE FROM tt_temp20_31;
                  UTILS.IDENTITY_RESET('tt_temp20_31');

                  INSERT INTO tt_temp20_31 ( 
                  	SELECT A.EntityKey ,
                          A.DerivativeEntityID ,
                          A.CustomerACID ,
                          A.CustomerID ,
                          A.CustomerName ,
                          A.DerivativeRefNo ,
                          A.Duedate ,
                          A.DueAmt ,
                          A.OsAmt ,
                          A.POS ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.ApprovedBy ,
                          A.DateApproved 
                  	  FROM ( SELECT A.EntityKey ,
                                   A.DerivativeEntityID ,
                                   A.CustomerACID ,
                                   A.CustomerID ,
                                   A.CustomerName ,
                                   A.DerivativeRefNo ,
                                   A.Duedate ,
                                   A.DueAmt ,
                                   A.OsAmt ,
                                   A.POS ,
                                   A.AuthorisationStatus AuthorisationStatus  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved 
                            FROM DerivativeDetail_mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM DerivativeDetail_mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.EntityKey,A.DerivativeEntityID,A.CustomerACID,A.CustomerID,A.CustomerName,A.DerivativeRefNo,A.Duedate,A.DueAmt,A.OsAmt,A.POS,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'DerivativeMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_31 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DERIVATIVEDETAILSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
