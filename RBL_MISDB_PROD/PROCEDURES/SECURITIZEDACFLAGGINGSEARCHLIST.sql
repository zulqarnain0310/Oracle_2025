--------------------------------------------------------
--  DDL for Procedure SECURITIZEDACFLAGGINGSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 16 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
   SELECT UTILS.CONVERT_TO_NUMBER(B.timekey,10,0) 

     INTO v_Timekey
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
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
            IF utils.object_id('TempDB..tt_temp_255') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_255 ';
            END IF;
            DELETE FROM tt_temp_255;
            UTILS.IDENTITY_RESET('tt_temp_255');

            INSERT INTO tt_temp_255 ( 
            	SELECT A.AccountFlagAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SourceName ,
                    A.AccountID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.FlagAlt_Key ,
                    A.PoolID ,
                    A.PoolName ,
                    A.AccountBalance ,
                    A.POS ,
                    A.InterestReceivable ,
                    A.ExposureAmount ,
                    A.SecuritizedOutDate ,
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
            	  FROM ( SELECT A.AccountFlagAlt_Key ,
                             A.SourceAlt_Key ,
                             ds.SourceName ,
                             A.AccountID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.FlagAlt_Key ,
                             A.PoolID ,
                             A.PoolName ,
                             A.AccountBalance ,
                             A.POS ,
                             A.InterestReceivable ,
                             A.ExposureAmount ,
                             A.SecuritizedOutDate ,
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
                      FROM SecuritizedACFlaggingDetail A
                             JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.AccountFlagAlt_Key ,
                             A.SourceAlt_Key ,
                             ds.SourceName ,
                             A.AccountID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.FlagAlt_Key ,
                             A.PoolID ,
                             A.PoolName ,
                             A.AccountBalance ,
                             A.POS ,
                             A.InterestReceivable ,
                             A.ExposureAmount ,
                             A.SecuritizedOutDate ,
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
                      FROM SecuritizedACFlaggingDetail_Mod A
                             JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                      FROM SecuritizedACFlaggingDetail_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                        GROUP BY AccountID )
                     ) A
            	  GROUP BY A.AccountFlagAlt_Key,A.SourceAlt_Key,A.SourceName,A.AccountID,A.CustomerID,A.CustomerName,A.FlagAlt_Key,A.PoolID,A.PoolName,A.AccountBalance,A.POS,A.InterestReceivable,A.ExposureAmount,A.SecuritizedOutDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountFlagAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SecuritizedACFlaggingDetail' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_255 A ) 
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
               IF utils.object_id('TempDB..tt_temp_25516') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_202 ';
               END IF;
               DELETE FROM tt_temp16_202;
               UTILS.IDENTITY_RESET('tt_temp16_202');

               INSERT INTO tt_temp16_202 ( 
               	SELECT A.AccountFlagAlt_Key ,
                       A.SourceAlt_Key ,
                       A.SourceName ,
                       A.AccountID ,
                       A.CustomerID ,
                       A.CustomerName ,
                       A.FlagAlt_Key ,
                       A.PoolID ,
                       A.PoolName ,
                       A.AccountBalance ,
                       A.POS ,
                       A.InterestReceivable ,
                       A.ExposureAmount ,
                       A.SecuritizedOutDate ,
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
               	  FROM ( SELECT A.AccountFlagAlt_Key ,
                                A.SourceAlt_Key ,
                                A.SourceName ,
                                A.AccountID ,
                                A.CustomerID ,
                                A.CustomerName ,
                                A.FlagAlt_Key ,
                                A.PoolID ,
                                A.PoolName ,
                                A.AccountBalance ,
                                A.POS ,
                                A.InterestReceivable ,
                                A.ExposureAmount ,
                                A.SecuritizedOutDate ,
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
                         FROM SecuritizedACFlaggingDetail_Mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                         FROM SecuritizedACFlaggingDetail_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                           GROUP BY AccountID )
                        ) A
               	  GROUP BY A.AccountFlagAlt_Key,A.SourceAlt_Key,A.SourceName,A.AccountID,A.CustomerID,A.CustomerName,A.FlagAlt_Key,A.PoolID,A.PoolName,A.AccountBalance,A.POS,A.InterestReceivable,A.ExposureAmount,A.SecuritizedOutDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountFlagAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'SecuritizedACFlaggingDetail' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_202 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_25520') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_167 ';
                  END IF;
                  DELETE FROM tt_temp20_167;
                  UTILS.IDENTITY_RESET('tt_temp20_167');

                  INSERT INTO tt_temp20_167 ( 
                  	SELECT A.AccountFlagAlt_Key ,
                          A.SourceAlt_Key ,
                          A.SourceName ,
                          A.AccountID ,
                          A.CustomerID ,
                          A.CustomerName ,
                          A.FlagAlt_Key ,
                          A.PoolID ,
                          A.PoolName ,
                          A.AccountBalance ,
                          A.POS ,
                          A.InterestReceivable ,
                          A.ExposureAmount ,
                          A.SecuritizedOutDate ,
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
                  	  FROM ( SELECT A.AccountFlagAlt_Key ,
                                   A.SourceAlt_Key ,
                                   A.SourceName ,
                                   A.AccountID ,
                                   A.CustomerID ,
                                   A.CustomerName ,
                                   A.FlagAlt_Key ,
                                   A.PoolID ,
                                   A.PoolName ,
                                   A.AccountBalance ,
                                   A.POS ,
                                   A.InterestReceivable ,
                                   A.ExposureAmount ,
                                   A.SecuritizedOutDate ,
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
                            FROM SecuritizedACFlaggingDetail_Mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                            FROM SecuritizedACFlaggingDetail_Mod 
                                                             WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                      AND EffectiveToTimeKey >= v_TimeKey
                                                                      AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                                              GROUP BY AccountID )
                           ) A
                  	  GROUP BY A.AccountFlagAlt_Key,A.SourceAlt_Key,A.SourceName,A.AccountID,A.CustomerID,A.CustomerName,A.FlagAlt_Key,A.PoolID,A.PoolName,A.AccountBalance,A.POS,A.InterestReceivable,A.ExposureAmount,A.SecuritizedOutDate,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.crModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountFlagAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'SecuritizedACFlaggingDetail' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_167 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SECURITIZEDACFLAGGINGSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
