--------------------------------------------------------
--  DDL for Procedure TRANSACTIONSUBTYPEMASTERSEARCHLIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 20 ,
  v_MenuID IN NUMBER DEFAULT 14560 
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
         --select * from 	SysCRisMacMenu where menucaption like '%Trans%'					
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
            IF utils.object_id('TempDB..tt_temp_289') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_289 ';
            END IF;
            DELETE FROM tt_temp_289;
            UTILS.IDENTITY_RESET('tt_temp_289');

            INSERT INTO tt_temp_289 ( 
            	SELECT A.Transaction_Sub_TypeAlt_Key ,
                    A.Source_System_Name ,
                    A.SourceAlt_Key ,
                    A.Transaction_Sub_Type_Code ,
                    A.Transaction_Sub_Type_Description ,
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
            	  FROM ( SELECT A.Transaction_Sub_TypeAlt_Key ,
                             B.SourceName Source_System_Name  ,
                             B.SourceAlt_Key ,
                             A.Transaction_Sub_Type_Code ,
                             A.Transaction_Sub_Type_Description ,
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
                      FROM DimTransactionSubTypeMaster A
                             JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.Transaction_Sub_TypeAlt_Key ,
                             B.SourceName Source_System_Name  ,
                             B.SourceAlt_Key ,
                             A.Transaction_Sub_Type_Code ,
                             A.Transaction_Sub_Type_Description ,
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
                      FROM DimTransactionSubTypeMaster_Mod A
                             JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                             AND B.EffectiveFromTimeKey <= v_Timekey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM DimTransactionSubTypeMaster_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY Transaction_Sub_TypeAlt_Key )
                     ) A
            	  GROUP BY A.Transaction_Sub_TypeAlt_Key,A.Source_System_Name,A.SourceAlt_Key,A.Transaction_Sub_Type_Code,A.Transaction_Sub_Type_Description,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Transaction_Sub_TypeAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'TransactionSubTypeMaster' TableName  ,
                               * ,
                               LENGTH(AuthorisationStatus) AuthorisationStatuslen  
                        FROM ( SELECT * 
                               FROM tt_temp_289 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY DataPointOwner.AuthorisationStatuslen DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_28916') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_234 ';
               END IF;
               DELETE FROM tt_temp16_234;
               UTILS.IDENTITY_RESET('tt_temp16_234');

               INSERT INTO tt_temp16_234 ( 
               	SELECT A.Transaction_Sub_TypeAlt_Key ,
                       A.Source_System_Name ,
                       A.SourceAlt_Key ,
                       A.Transaction_Sub_Type_Code ,
                       A.Transaction_Sub_Type_Description ,
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
               	  FROM ( SELECT A.Transaction_Sub_TypeAlt_Key ,
                                B.SourceName Source_System_Name  ,
                                B.SourceAlt_Key ,
                                A.Transaction_Sub_Type_Code ,
                                A.Transaction_Sub_Type_Description ,
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
                         FROM DimTransactionSubTypeMaster_Mod A
                                JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                AND B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM DimTransactionSubTypeMaster_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY Transaction_Sub_TypeAlt_Key )
                        ) A
               	  GROUP BY A.Transaction_Sub_TypeAlt_Key,A.Source_System_Name,A.SourceAlt_Key,A.Transaction_Sub_Type_Code,A.Transaction_Sub_Type_Description,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Transaction_Sub_TypeAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'TransactionSubTypeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_234 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_28920') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_199 ';
                  END IF;
                  DELETE FROM tt_temp20_199;
                  UTILS.IDENTITY_RESET('tt_temp20_199');

                  INSERT INTO tt_temp20_199 ( 
                  	SELECT A.Transaction_Sub_TypeAlt_Key ,
                          A.Source_System_Name ,
                          A.SourceAlt_Key ,
                          A.Transaction_Sub_Type_Code ,
                          A.Transaction_Sub_Type_Description ,
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
                  	  FROM ( SELECT A.Transaction_Sub_TypeAlt_Key ,
                                   B.SourceName Source_System_Name  ,
                                   B.SourceAlt_Key ,
                                   A.Transaction_Sub_Type_Code ,
                                   A.Transaction_Sub_Type_Description ,
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
                            FROM DimTransactionSubTypeMaster_Mod A
                                   JOIN DIMSOURCEDB B   ON A.SourceAlt_Key = B.SourceAlt_Key
                                   AND B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM DimTransactionSubTypeMaster_Mod 
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
                                                             GROUP BY Transaction_Sub_TypeAlt_Key )
                           ) A
                  	  GROUP BY A.Transaction_Sub_TypeAlt_Key,A.Source_System_Name,A.SourceAlt_Key,A.Transaction_Sub_Type_Code,A.Transaction_Sub_Type_Description,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Transaction_Sub_TypeAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'TransactionSubTypeMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_199 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TRANSACTIONSUBTYPEMASTERSEARCHLIST" TO "ADF_CDR_RBL_STGDB";
