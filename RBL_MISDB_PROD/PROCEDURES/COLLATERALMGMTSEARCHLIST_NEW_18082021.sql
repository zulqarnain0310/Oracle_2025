--------------------------------------------------------
--  DDL for Procedure COLLATERALMGMTSEARCHLIST_NEW_18082021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" 
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
         IF ( v_OperationFlag NOT IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_42') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_42 ';
            END IF;
            DELETE FROM tt_temp_42;
            UTILS.IDENTITY_RESET('tt_temp_42');

            INSERT INTO tt_temp_42 ( 
            	SELECT A.TaggingLevel ,
                    A.CollateralAlt_Key ,
                    A.AccountID ,
                    A.UCICID ,
                    A.CustomerID ,
                    A.CustomerName ,
                    A.TaggingAlt_Key ,
                    A.DistributionAlt_Key ,
                    A.DistributionModel ,
                    A.CollateralID ,
                    A.CollateralCode ,
                    A.CollateralTypeAlt_Key ,
                    A.CollateralTypeDescription ,
                    A.CollateralSubTypeAlt_Key ,
                    A.CollateralSubTypeDescription ,
                    A.CollateralOwnerTypeAlt_Key ,
                    A.CollOwnerDescription ,
                    A.CollateralOwnerShipTypeAlt_Key ,
                    A.CollateralOwnershipType ,
                    A.ChargeTypeAlt_Key ,
                    A.CollChargeDescription ,
                    A.ChargeNatureAlt_Key ,
                    A.SecurityChargeTypeName ,
                    A.ShareAvailabletoBankAlt_Key ,
                    A.ShareAvailabletoBank ,
                    A.CollateralShareamount ,
                    A.TotalCollateralvalueatcustomerlevel ,
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
                    A.CrModDate 
            	  FROM ( SELECT B.ParameterName TaggingLevel  ,
                             A.CollateralAlt_Key ,
                             A.AccountID ,
                             A.UCICID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.TaggingAlt_Key ,
                             A.DistributionAlt_Key ,
                             C.ParameterName DistributionModel  ,
                             A.CollateralID ,
                             A.CollateralCode ,
                             A.CollateralTypeAlt_Key ,
                             E.CollateralTypeDescription ,
                             A.CollateralSubTypeAlt_Key ,
                             F.CollateralSubTypeDescription ,
                             A.CollateralOwnerTypeAlt_Key ,
                             G.CollOwnerDescription ,
                             A.CollateralOwnerShipTypeAlt_Key ,
                             H.ParameterName CollateralOwnershipType  ,
                             A.ChargeTypeAlt_Key ,
                             I.CollChargeDescription ,
                             A.ChargeNatureAlt_Key ,
                             J.SecurityChargeTypeName ,
                             A.ShareAvailabletoBankAlt_Key ,
                             D.ParameterName ShareAvailabletoBank  ,
                             A.CollateralShareamount ,
                             A.TotalCollateralvalueatcustomerlevel ,
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
                             NVL(A.DateModified, A.DateCreated) CrModDate  
                      FROM CollateralMgmt A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'TaggingLevel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimRatingType'
                                              AND ParameterName NOT IN ( 'Guarantor' )

            	  AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DistributionModel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Collateral'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ShareAvailabletoBank' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralBank'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                             JOIN DimCollateralType E   ON A.CollateralTypeAlt_Key = E.CollateralTypeAltKey
                             AND E.EffectiveFromTimeKey <= v_Timekey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                             AND F.EffectiveFromTimeKey <= v_Timekey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralOwnerType G   ON A.CollateralOwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                             AND G.EffectiveFromTimeKey <= v_Timekey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CollateralOwnershipType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralOwnershipType'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                             JOIN DimCollateralChargeType I   ON A.ChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                             AND I.EffectiveFromTimeKey <= v_Timekey
                             AND I.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                             AND J.EffectiveFromTimeKey <= v_Timekey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             AND SecurityChargeTypeGroup = 'COLLATERAL'
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT B.ParameterName TaggingLevel  ,
                             A.CollateralAlt_Key ,
                             A.AccountID ,
                             A.UCICID ,
                             A.CustomerID ,
                             A.CustomerName ,
                             A.TaggingAlt_Key ,
                             A.DistributionAlt_Key ,
                             C.ParameterName DistributionModel  ,
                             A.CollateralID ,
                             A.CollateralCode ,
                             A.CollateralTypeAlt_Key ,
                             E.CollateralTypeDescription ,
                             A.CollateralSubTypeAlt_Key ,
                             F.CollateralSubTypeDescription ,
                             A.CollateralOwnerTypeAlt_Key ,
                             G.CollOwnerDescription ,
                             A.CollateralOwnerShipTypeAlt_Key ,
                             H.ParameterName CollateralOwnershipType  ,
                             A.ChargeTypeAlt_Key ,
                             I.CollChargeDescription ,
                             A.ChargeNatureAlt_Key ,
                             J.SecurityChargeTypeName ,
                             A.ShareAvailabletoBankAlt_Key ,
                             D.ParameterName ShareAvailabletoBank  ,
                             A.CollateralShareamount ,
                             A.TotalCollateralvalueatcustomerlevel ,
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
                             NVL(A.DateModified, A.DateCreated) CrModDate  
                      FROM CollateralMgmt_Mod A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'TaggingLevel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DimRatingType'
                                              AND ParameterName NOT IN ( 'Guarantor' )

                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DistributionModel' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'Collateral'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'ShareAvailabletoBank' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralBank'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                             JOIN DimCollateralType E   ON A.CollateralTypeAlt_Key = E.CollateralTypeAltKey
                             AND E.EffectiveFromTimeKey <= v_Timekey
                             AND E.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                             AND F.EffectiveFromTimeKey <= v_Timekey
                             AND F.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimCollateralOwnerType G   ON A.CollateralOwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                             AND G.EffectiveFromTimeKey <= v_Timekey
                             AND G.EffectiveToTimeKey >= v_TimeKey
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'CollateralOwnershipType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'CollateralOwnershipType'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                             JOIN DimCollateralChargeType I   ON A.ChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                             AND I.EffectiveFromTimeKey <= v_Timekey
                             AND I.EffectiveToTimeKey >= v_TimeKey
                             JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                             AND J.EffectiveFromTimeKey <= v_Timekey
                             AND J.EffectiveToTimeKey >= v_TimeKey
                             AND SecurityChargeTypeGroup = 'COLLATERAL'
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM CollateralMgmt_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                       GROUP BY CollateralID )
                     ) A
            	  GROUP BY A.TaggingLevel,A.CollateralAlt_Key,A.AccountID,A.UCICID,A.CustomerID,A.CustomerName,A.TaggingAlt_Key,A.DistributionAlt_Key,A.DistributionModel,A.CollateralID,A.CollateralCode,A.CollateralTypeAlt_Key,A.CollateralTypeDescription,A.CollateralSubTypeAlt_Key,A.CollateralSubTypeDescription,A.CollateralOwnerTypeAlt_Key,A.CollOwnerDescription,A.CollateralOwnerShipTypeAlt_Key,A.CollateralOwnershipType,A.ChargeTypeAlt_Key,A.CollChargeDescription,A.ChargeNatureAlt_Key,A.SecurityChargeTypeName,A.ShareAvailabletoBankAlt_Key,A.ShareAvailabletoBank,A.CollateralShareamount,A.TotalCollateralvalueatcustomerlevel,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'Collateral' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_42 A ) 
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
               IF utils.object_id('TempDB..tt_temp_4216') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_35 ';
               END IF;
               DELETE FROM tt_temp16_35;
               UTILS.IDENTITY_RESET('tt_temp16_35');

               INSERT INTO tt_temp16_35 ( 
               	SELECT A.TaggingLevel ,
                       A.CollateralAlt_Key ,
                       A.AccountID ,
                       A.UCICID ,
                       A.CustomerID ,
                       A.CustomerName ,
                       A.TaggingAlt_Key ,
                       A.DistributionAlt_Key ,
                       A.DistributionModel ,
                       A.CollateralID ,
                       A.CollateralCode ,
                       A.CollateralTypeAlt_Key ,
                       A.CollateralTypeDescription ,
                       A.CollateralSubTypeAlt_Key ,
                       A.CollateralSubTypeDescription ,
                       A.CollateralOwnerTypeAlt_Key ,
                       A.CollOwnerDescription ,
                       A.CollateralOwnerShipTypeAlt_Key ,
                       A.CollateralOwnershipType ,
                       A.ChargeTypeAlt_Key ,
                       A.CollChargeDescription ,
                       A.ChargeNatureAlt_Key ,
                       A.SecurityChargeTypeName ,
                       A.ShareAvailabletoBankAlt_Key ,
                       A.ShareAvailabletoBank ,
                       A.CollateralShareamount ,
                       A.TotalCollateralvalueatcustomerlevel ,
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
                       A.CrModDate 
               	  FROM ( SELECT B.ParameterName TaggingLevel  ,
                                A.CollateralAlt_Key ,
                                A.AccountID ,
                                A.UCICID ,
                                A.CustomerID ,
                                A.CustomerName ,
                                A.TaggingAlt_Key ,
                                A.DistributionAlt_Key ,
                                C.ParameterName DistributionModel  ,
                                A.CollateralID ,
                                A.CollateralCode ,
                                A.CollateralTypeAlt_Key ,
                                E.CollateralTypeDescription ,
                                A.CollateralSubTypeAlt_Key ,
                                F.CollateralSubTypeDescription ,
                                A.CollateralOwnerTypeAlt_Key ,
                                G.CollOwnerDescription ,
                                A.CollateralOwnerShipTypeAlt_Key ,
                                H.ParameterName CollateralOwnershipType  ,
                                A.ChargeTypeAlt_Key ,
                                I.CollChargeDescription ,
                                A.ChargeNatureAlt_Key ,
                                J.SecurityChargeTypeName ,
                                A.ShareAvailabletoBankAlt_Key ,
                                D.ParameterName ShareAvailabletoBank  ,
                                A.CollateralShareamount ,
                                A.TotalCollateralvalueatcustomerlevel ,
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
                                NVL(A.DateModified, A.DateCreated) CrModDate  
                         FROM CollateralMgmt_Mod A
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'TaggingLevel' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DimRatingType'
                                                 AND ParameterName NOT IN ( 'Guarantor' )

                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.TaggingAlt_Key = B.ParameterAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'DistributionModel' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'Collateral'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) C   ON A.DistributionAlt_Key = C.ParameterAlt_Key
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'ShareAvailabletoBank' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'CollateralBank'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.ShareAvailabletoBankAlt_Key = D.ParameterAlt_Key
                                JOIN DimCollateralType E   ON A.CollateralTypeAlt_Key = E.CollateralTypeAltKey
                                AND E.EffectiveFromTimeKey <= v_Timekey
                                AND E.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimCollateralSubType F   ON A.CollateralSubTypeAlt_Key = F.CollateralSubTypeAltKey
                                AND F.EffectiveFromTimeKey <= v_Timekey
                                AND F.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimCollateralOwnerType G   ON A.CollateralOwnerTypeAlt_Key = G.CollateralOwnerTypeAltKey
                                AND G.EffectiveFromTimeKey <= v_Timekey
                                AND G.EffectiveToTimeKey >= v_TimeKey
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'CollateralOwnershipType' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'CollateralOwnershipType'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) H   ON A.CollateralOwnerShipTypeAlt_Key = H.ParameterAlt_Key
                                JOIN DimCollateralChargeType I   ON A.ChargeTypeAlt_Key = I.CollateralChargeTypeAltKey
                                AND I.EffectiveFromTimeKey <= v_Timekey
                                AND I.EffectiveToTimeKey >= v_TimeKey
                                JOIN DimSecurityChargeType J   ON A.ChargeNatureAlt_Key = J.SecurityChargeTypeAlt_Key
                                AND J.EffectiveFromTimeKey <= v_Timekey
                                AND J.EffectiveToTimeKey >= v_TimeKey
                                AND SecurityChargeTypeGroup = 'COLLATERAL'
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM CollateralMgmt_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY CollateralID )
                        ) A
               	  GROUP BY A.TaggingLevel,A.CollateralAlt_Key,A.AccountID,A.UCICID,A.CustomerID,A.CustomerName,A.TaggingAlt_Key,A.DistributionAlt_Key,A.DistributionModel,A.CollateralID,A.CollateralCode,A.CollateralTypeAlt_Key,A.CollateralTypeDescription,A.CollateralSubTypeAlt_Key,A.CollateralSubTypeDescription,A.CollateralOwnerTypeAlt_Key,A.CollOwnerDescription,A.CollateralOwnerShipTypeAlt_Key,A.CollateralOwnershipType,A.ChargeTypeAlt_Key,A.CollChargeDescription,A.ChargeNatureAlt_Key,A.SecurityChargeTypeName,A.ShareAvailabletoBankAlt_Key,A.ShareAvailabletoBank,A.CollateralShareamount,A.TotalCollateralvalueatcustomerlevel,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified,A.CrModBy,A.CrModDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'Collateral' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_35 A ) 
                                --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                                --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALMGMTSEARCHLIST_NEW_18082021" TO "ADF_CDR_RBL_STGDB";
