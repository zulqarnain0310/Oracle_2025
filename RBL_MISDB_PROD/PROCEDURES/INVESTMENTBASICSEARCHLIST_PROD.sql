--------------------------------------------------------
--  DDL for Procedure INVESTMENTBASICSEARCHLIST_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" 
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
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_168') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_168 ';
            END IF;
            DELETE FROM tt_temp_168;
            UTILS.IDENTITY_RESET('tt_temp_168');

            INSERT INTO tt_temp_168 ( 
            	SELECT A.EntityKey ,
                    A.BranchCode ,
                    A.InvEntityId ,
                    A.IssuerEntityId ,
                    A.RefIssuerID ,
                    A.ISIN ,
                    A.InstrTypeAlt_Key ,
                    A.InstrName ,
                    A.InvestmentNature ,
                    A.InternalRating ,
                    A.InRatingDate ,
                    A.InRatingExpiryDate ,
                    A.ExRating ,
                    A.ExRatingAgency ,
                    A.ExRatingDate ,
                    A.ExRatingExpiryDate ,
                    A.Sector ,
                    A.Industry_AltKey ,
                    A.ListedStkExchange ,
                    A.ExposureType ,
                    A.SecurityValue ,
                    A.MaturityDt ,
                    A.ReStructureDate ,
                    A.MortgageStatus ,
                    A.NHBStatus ,
                    A.ResiPurpose ,
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
                             A.BranchCode ,
                             A.InvEntityId ,
                             A.IssuerEntityId ,
                             A.RefIssuerID ,
                             A.ISIN ,
                             A.InstrTypeAlt_Key ,
                             A.InstrName ,
                             A.InvestmentNature ,
                             A.InternalRating ,
                             A.InRatingDate ,
                             A.InRatingExpiryDate ,
                             A.ExRating ,
                             A.ExRatingAgency ,
                             A.ExRatingDate ,
                             A.ExRatingExpiryDate ,
                             A.Sector ,
                             A.Industry_AltKey ,
                             A.ListedStkExchange ,
                             A.ExposureType ,
                             A.SecurityValue ,
                             A.MaturityDt ,
                             A.ReStructureDate ,
                             A.MortgageStatus ,
                             A.NHBStatus ,
                             A.ResiPurpose ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved 
                      FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT A.EntityKey ,
                             A.BranchCode ,
                             A.InvEntityId ,
                             A.IssuerEntityId ,
                             A.RefIssuerID ,
                             A.ISIN ,
                             A.InstrTypeAlt_Key ,
                             A.InstrName ,
                             A.InvestmentNature ,
                             A.InternalRating ,
                             A.InRatingDate ,
                             A.InRatingExpiryDate ,
                             A.ExRating ,
                             A.ExRatingAgency ,
                             A.ExRatingDate ,
                             A.ExRatingExpiryDate ,
                             A.Sector ,
                             A.Industry_AltKey ,
                             A.ListedStkExchange ,
                             A.ExposureType ,
                             A.SecurityValue ,
                             A.MaturityDt ,
                             A.ReStructureDate ,
                             A.MortgageStatus ,
                             A.NHBStatus ,
                             A.ResiPurpose ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved 
                      FROM InvestmentBasicDetail_mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.InvEntityId IN ( SELECT MAX(EntityKey)  
                                                       FROM InvestmentBasicDetail_mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                         GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.EntityKey,A.BranchCode,A.InvEntityId,A.IssuerEntityId,A.RefIssuerID,A.ISIN,A.InstrTypeAlt_Key,A.InstrName,A.InvestmentNature,A.InternalRating,A.InRatingDate,A.InRatingExpiryDate,A.ExRating,A.ExRatingAgency,A.ExRatingDate,A.ExRatingExpiryDate,A.Sector,A.Industry_AltKey,A.ListedStkExchange,A.ExposureType,A.SecurityValue,A.MaturityDt,A.ReStructureDate,A.MortgageStatus,A.NHBStatus,A.ResiPurpose,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'IssuerBasicMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_168 A ) 
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
               IF utils.object_id('TempDB..tt_temp_16816') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_129 ';
               END IF;
               DELETE FROM tt_temp16_129;
               UTILS.IDENTITY_RESET('tt_temp16_129');

               INSERT INTO tt_temp16_129 ( 
               	SELECT IssuerMaster 
               	  FROM ( SELECT A.EntityKey ,
                                A.BranchCode ,
                                A.InvEntityId ,
                                A.IssuerEntityId ,
                                A.RefIssuerID ,
                                A.ISIN ,
                                A.InstrTypeAlt_Key ,
                                A.InstrName ,
                                A.InvestmentNature ,
                                A.InternalRating ,
                                A.InRatingDate ,
                                A.InRatingExpiryDate ,
                                A.ExRating ,
                                A.ExRatingAgency ,
                                A.ExRatingDate ,
                                A.ExRatingExpiryDate ,
                                A.Sector ,
                                A.Industry_AltKey ,
                                A.ListedStkExchange ,
                                A.ExposureType ,
                                A.SecurityValue ,
                                A.MaturityDt ,
                                A.ReStructureDate ,
                                A.MortgageStatus ,
                                A.NHBStatus ,
                                A.ResiPurpose ,
                                A.AuthorisationStatus ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved 
                         FROM InvestmentBasicDetail_mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.InvEntityId IN ( SELECT MAX(EntityKey)  
                                                          FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail_Mod 
                                                           WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                    AND EffectiveToTimeKey >= v_TimeKey
                                                                    AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                            GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.EntityKey,A.BranchCode,A.InvEntityId,A.IssuerEntityId,A.RefIssuerID,A.ISIN,A.InstrTypeAlt_Key,A.InstrName,A.InvestmentNature,A.InternalRating,A.InRatingDate,A.InRatingExpiryDate,A.ExRating,A.ExRatingAgency,A.ExRatingDate,A.ExRatingExpiryDate,A.Sector,A.Industry_AltKey,A.ListedStkExchange,A.ExposureType,A.SecurityValue,A.MaturityDt,A.ReStructureDate,A.MortgageStatus,A.NHBStatus,A.ResiPurpose,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'IssuerBasicMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_129 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_16820') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_94 ';
                  END IF;
                  DELETE FROM tt_temp20_94;
                  UTILS.IDENTITY_RESET('tt_temp20_94');

                  INSERT INTO tt_temp20_94 ( 
                  	SELECT A.EntityKey ,
                          A.BranchCode ,
                          A.InvEntityId ,
                          A.IssuerEntityId ,
                          A.RefIssuerID ,
                          A.ISIN ,
                          A.InstrTypeAlt_Key ,
                          A.InstrName ,
                          A.InvestmentNature ,
                          A.InternalRating ,
                          A.InRatingDate ,
                          A.InRatingExpiryDate ,
                          A.ExRating ,
                          A.ExRatingAgency ,
                          A.ExRatingDate ,
                          A.ExRatingExpiryDate ,
                          A.Sector ,
                          A.Industry_AltKey ,
                          A.ListedStkExchange ,
                          A.ExposureType ,
                          A.SecurityValue ,
                          A.MaturityDt ,
                          A.ReStructureDate ,
                          A.MortgageStatus ,
                          A.NHBStatus ,
                          A.ResiPurpose ,
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
                                   A.BranchCode ,
                                   A.InvEntityId ,
                                   A.IssuerEntityId ,
                                   A.RefIssuerID ,
                                   A.ISIN ,
                                   A.InstrTypeAlt_Key ,
                                   A.InstrName ,
                                   A.InvestmentNature ,
                                   A.InternalRating ,
                                   A.InRatingDate ,
                                   A.InRatingExpiryDate ,
                                   A.ExRating ,
                                   A.ExRatingAgency ,
                                   A.ExRatingDate ,
                                   A.ExRatingExpiryDate ,
                                   A.Sector ,
                                   A.Industry_AltKey ,
                                   A.ListedStkExchange ,
                                   A.ExposureType ,
                                   A.SecurityValue ,
                                   A.MaturityDt ,
                                   A.ReStructureDate ,
                                   A.MortgageStatus ,
                                   A.NHBStatus ,
                                   A.ResiPurpose ,
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ModifiedBy ,
                                   A.DateModified ,
                                   A.ApprovedBy ,
                                   A.DateApproved 
                            FROM InvestmentBasicDetail_mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.InvEntityId IN ( SELECT MAX(EntityKey)  
                                                             FROM CurDat_RBL_MISDB_PROD.InvestmentBasicDetail_Mod 
                                                              WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                       AND EffectiveToTimeKey >= v_TimeKey
                                                                       AND AuthorisationStatus IN ( '1A' )

                                                               GROUP BY EntityKey )
                           ) A
                  	  GROUP BY A.EntityKey,A.BranchCode,A.InvEntityId,A.IssuerEntityId,A.RefIssuerID,A.ISIN,A.InstrTypeAlt_Key,A.InstrName,A.InvestmentNature,A.InternalRating,A.InRatingDate,A.InRatingExpiryDate,A.ExRating,A.ExRatingAgency,A.ExRatingDate,A.ExRatingExpiryDate,A.Sector,A.Industry_AltKey,A.ListedStkExchange,A.ExposureType,A.SecurityValue,A.MaturityDt,A.ReStructureDate,A.MortgageStatus,A.NHBStatus,A.ResiPurpose,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ModifiedBy,A.DateModified,A.ApprovedBy,A.DateApproved );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'IssuerBasicMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_94 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."INVESTMENTBASICSEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
