--------------------------------------------------------
--  DDL for Procedure SALETOARCACFLAGGINGSEARCHLIST_31082023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" 
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
         --SET @Timekey=(SELECT MAX(TIMEKEY) FROM SysDayMatrix where Cast(date as Date)=cast(getdate() as date))
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_249') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_249 ';
            END IF;
            DELETE FROM tt_temp_249;
            UTILS.IDENTITY_RESET('tt_temp_249');

            INSERT INTO tt_temp_249 ( 
            	SELECT A.AccountFlagAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SourceName ,
                    A.AccountID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.FlagAlt_Key ,
                    A.AccountBalance ,
                    A.POS ,
                    A.InterestReceivable ,
                    A.ExposureAmount ,
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
                             A.AccountBalance ,
                             A.POS ,
                             A.InterestReceivable ,
                             A.ExposureAmount ,
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
                      FROM SaletoARCACFlaggingDetail A
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
                             A.AccountBalance ,
                             A.POS ,
                             A.InterestReceivable ,
                             A.ExposureAmount ,
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
                      FROM SaletoARCACFlaggingDetail_Mod A
                             JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                      FROM SaletoARCACFlaggingDetail_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                        GROUP BY AccountID )
                     ) A
            	  GROUP BY A.AccountFlagAlt_Key,A.SourceAlt_Key,A.SourceName,A.AccountID,A.CustomerID,A.CustomerName,A.FlagAlt_Key,A.AccountBalance,A.POS,A.InterestReceivable,A.ExposureAmount,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountFlagAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SaletoARCACFlaggingDetail' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_249 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY LENGTH(AuthorisationStatus) DESC,
                          DateCreated DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_24916') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_196 ';
               END IF;
               DELETE FROM tt_temp16_196;
               UTILS.IDENTITY_RESET('tt_temp16_196');

               INSERT INTO tt_temp16_196 ( 
               	SELECT A.AccountFlagAlt_Key ,
                       A.SourceAlt_Key ,
                       A.SourceName ,
                       A.AccountID ,
                       A.CustomerID ,
                       A.CustomerName ,
                       A.FlagAlt_Key ,
                       A.AccountBalance ,
                       A.POS ,
                       A.InterestReceivable ,
                       A.ExposureAmount ,
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
                                A.AccountBalance ,
                                A.POS ,
                                A.InterestReceivable ,
                                A.ExposureAmount ,
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
                         FROM SaletoARCACFlaggingDetail_Mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                         FROM SaletoARCACFlaggingDetail_Mod 
                                                          WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                   AND EffectiveToTimeKey >= v_TimeKey
                                                                   AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                           GROUP BY AccountID )
                        ) A
               	  GROUP BY A.AccountFlagAlt_Key,A.SourceAlt_Key,A.SourceName,A.AccountID,A.CustomerID,A.CustomerName,A.FlagAlt_Key,A.AccountBalance,A.POS,A.InterestReceivable,A.ExposureAmount,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountFlagAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'SaletoARCACFlaggingDetail' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_196 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                                DataPointOwner ) DataPointOwner
                    ORDER BY LENGTH(AuthorisationStatus) DESC,
                             DateCreated DESC ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
            END IF;
         END IF;
         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
         --      AND RowNumber <= (@PageNo * @PageSize)
         IF ( v_OperationFlag = 20 ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_24920') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_161 ';
            END IF;
            DELETE FROM tt_temp20_161;
            UTILS.IDENTITY_RESET('tt_temp20_161');

            INSERT INTO tt_temp20_161 ( 
            	SELECT A.AccountFlagAlt_Key ,
                    A.SourceAlt_Key ,
                    A.SourceName ,
                    A.AccountID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.FlagAlt_Key ,
                    A.AccountBalance ,
                    A.POS ,
                    A.InterestReceivable ,
                    A.ExposureAmount ,
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
                             A.AccountBalance ,
                             A.POS ,
                             A.InterestReceivable ,
                             A.ExposureAmount ,
                             --,isnull(A.AuthorisationStatus,'A') 
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
                      FROM SaletoARCACFlaggingDetail_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                      FROM SaletoARCACFlaggingDetail_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND AuthorisationStatus IN ( '1A' )

                                                        GROUP BY AccountId )
                     ) A
            	  GROUP BY A.AccountFlagAlt_Key,A.SourceAlt_Key,A.SourceName,A.AccountID,A.CustomerID,A.CustomerName,A.FlagAlt_Key,A.AccountBalance,A.POS,A.InterestReceivable,A.ExposureAmount,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY AccountFlagAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'SaletoARCACFlaggingDetail' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp20_161 A ) DataPointOwner ) DataPointOwner
                 ORDER BY LENGTH(AuthorisationStatus) DESC,
                          DateCreated DESC ;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SALETOARCACFLAGGINGSEARCHLIST_31082023" TO "ADF_CDR_RBL_STGDB";
