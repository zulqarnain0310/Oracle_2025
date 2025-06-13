--------------------------------------------------------
--  DDL for Procedure COLLATERALVALUEENQUIRESEARCHLIST_01102021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,--,
  --,@CustomerID	Varchar(100)	= NULL
  v_TaggingId IN VARCHAR2 DEFAULT NULL 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;
--,@UCICID		Varchar(12)	=	NULL

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_78') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_78 ';
            END IF;
            DELETE FROM tt_temp_78;
            UTILS.IDENTITY_RESET('tt_temp_78');

            INSERT INTO tt_temp_78 ( 
            	SELECT A.CollateralID ,
                    A.CollateralValueatSanctioninRs ,
                    A.CollateralValueasonNPAdateinRs ,
                    A.CollateralValueatthetimeoflastreviewinRs ,
                    --,A.ValuationSourceNameAlt_Key
                    --,A.SourceName
                    A.ValuationDate ,
                    A.CurrentValue ,
                    --,A.ExpiryBusinessRule
                    --,A.Periodinmonth
                    A.ValuationExpiryDate ,
                    A.DisplayCollateralFor ,
                    A.TaggingAlt_Key ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.TaggingId 
            	  FROM ( SELECT A.CollateralID ,
                             B.CollateralValueatSanctioninRs ,
                             B.CollateralValueasonNPAdateinRs ,
                             A.CollateralValueatthetimeoflastreviewinRs ,
                             --,A.ValuationSourceNameAlt_Key
                             --,B.SourceName
                             A.ValuationDate ,
                             A.CurrentValue ,
                             ----,B.ExpiryBusinessRule
                             --,B.Periodinmonth
                             A.ValuationExpiryDate ,
                             C.ParameterName DisplayCollateralFor  ,
                             B.TaggingAlt_Key ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             (CASE 
                                   WHEN B.TaggingAlt_Key = 1 THEN B.RefCustomerId
                                   WHEN B.TaggingAlt_Key = 2 THEN B.RefSystemAcId
                                   WHEN B.TaggingAlt_Key = 4 THEN B.UCICID   END) TaggingId  
                      FROM CurDat_RBL_MISDB_PROD.AdvSecurityValueDetail A
                             JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                             JOIN DimParameter C   ON B.TaggingAlt_Key = C.ParameterAlt_Key
                             AND C.DimParameterName = 'DimRatingType'
                       WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION ALL 
                      SELECT A.CollateralID ,
                             B.CollateralValueatSanctioninRs ,
                             B.CollateralValueasonNPAdateinRs ,
                             A.CollateralValueatthetimeoflastreviewinRs ,
                             --,A.ValuationSourceNameAlt_Key
                             --,B.SourceName	
                             A.ValuationDate ,
                             A.CurrentValue ,
                             --,B.ExpiryBusinessRule
                             --,B.Periodinmonth
                             A.ValuationExpiryDate ,
                             C.ParameterName DisplayCollateralFor  ,
                             B.TaggingAlt_Key ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             (CASE 
                                   WHEN B.TaggingAlt_Key = 1 THEN B.RefCustomerId
                                   WHEN B.TaggingAlt_Key = 2 THEN B.RefSystemAcId
                                   WHEN B.TaggingAlt_Key = 4 THEN B.UCICID   END) TaggingId  
                      FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod A
                             JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                             JOIN DimParameter C   ON B.TaggingAlt_Key = C.ParameterAlt_Key
                             AND C.DimParameterName = 'DimRatingType'
                       WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                AND B.EffectiveToTimeKey >= v_TimeKey
                                AND A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY CollateralID )
                     ) A );
            --          GROUP BY	A.CollateralID
            --,A.CollateralValueatSanctioninRs
            --,A.CollateralValueasonNPAdateinRs
            --,A.CollateralValueatthetimeoflastreviewinRs
            --,A.ValuationSourceNameAlt_Key
            --,A.SourceName
            --,A.ValuationDate
            --,A.CurrentValue
            --,A.ExpiryBusinessRule
            --,A.Periodinmonth
            --,A.ValuationExpiryDate
            --,A.AuthorisationStatus, 
            --                     A.EffectiveFromTimeKey, 
            --                     A.EffectiveToTimeKey, 
            --                     A.CreatedBy, 
            --                     A.DateCreated, 
            --                     A.ApprovedBy, 
            --                     A.DateApproved, 
            --                     A.ModifiedBy, 
            --                     A.DateModified;
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'CollateralValueEnqury' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_78 A
                                WHERE  A.TaggingId = v_TaggingId ) 
                             --OR A.AccountID = @AccountID		

                             --OR A.UCICID =	@AccountID	)
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
               IF utils.object_id('TempDB..tt_temp_7816') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_53 ';
               END IF;
               DELETE FROM tt_temp16_53;
               UTILS.IDENTITY_RESET('tt_temp16_53');

               INSERT INTO tt_temp16_53 ( 
               	SELECT A.CollateralID ,
                       A.CollateralValueatSanctioninRs ,
                       A.CollateralValueasonNPAdateinRs ,
                       A.CollateralValueatthetimeoflastreviewinRs ,
                       --,A.ValuationSourceNameAlt_Key
                       --,B.SourceName
                       A.ValuationDate ,
                       A.CurrentValue ,
                       --,A.ExpiryBusinessRule
                       --,A.Periodinmonth
                       A.ValuationExpiryDate ,
                       A.DisplayCollateralFor ,
                       A.TaggingAlt_Key ,
                       NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.TaggingId 
               	  FROM ( SELECT A.CollateralID ,
                                B.CollateralValueatSanctioninRs ,
                                B.CollateralValueasonNPAdateinRs ,
                                A.CollateralValueatthetimeoflastreviewinRs ,
                                --,A.ValuationSourceNameAlt_Key
                                --,B.SourceName
                                A.ValuationDate ,
                                A.CurrentValue ,
                                --,B.ExpiryBusinessRule
                                --,B.Periodinmonth
                                A.ValuationExpiryDate ,
                                C.ParameterName DisplayCollateralFor  ,
                                B.TaggingAlt_Key ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                (CASE 
                                      WHEN B.TaggingAlt_Key = 1 THEN B.RefCustomerId
                                      WHEN B.TaggingAlt_Key = 2 THEN B.RefSystemAcId
                                      WHEN B.TaggingAlt_Key = 4 THEN B.UCICID   END) TaggingId  
                         FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod A
                                JOIN CurDat_RBL_MISDB_PROD.AdvSecurityDetail B   ON A.CollateralID = B.CollateralID
                                JOIN DimParameter C   ON B.TaggingAlt_Key = C.ParameterAlt_Key
                                AND C.DimParameterName = 'DimRatingType'
                          WHERE  B.EffectiveFromTimeKey <= v_TimeKey
                                   AND B.EffectiveToTimeKey >= v_TimeKey
                                   AND A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   -- AND ISNULL(A.AuthorisationStatus, 'A') = 'A'

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.ENTITYKEY IN ( SELECT MAX(EntityKey)  
                                                        FROM RBL_MISDB_PROD.AdvSecurityValueDetail_Mod 
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
               --,A.CurrentValue
               --,A.ExpiryBusinessRule
               --,A.Periodinmonth
               --,A.ValuationExpiryDate
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
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'CollateralValue' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_53 A
                                   WHERE  A.TaggingId = v_TaggingId ) 
                                --OR A.AccountID = @AccountID		

                                --OR A.UCICID =	@AccountID	)
                                DataPointOwner ) DataPointOwner ;
                  DBMS_SQL.RETURN_RESULT(v_cursor);

            END;
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALVALUEENQUIRESEARCHLIST_01102021" TO "ADF_CDR_RBL_STGDB";
