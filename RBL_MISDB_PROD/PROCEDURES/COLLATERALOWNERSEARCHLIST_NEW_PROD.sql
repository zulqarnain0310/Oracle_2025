--------------------------------------------------------
--  DDL for Procedure COLLATERALOWNERSEARCHLIST_NEW_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_CollateralID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   BEGIN

      BEGIN
         --SET NOCOUNT ON;
         --Declare @TimeKey as Int
         --	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_61') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_61 ';
            END IF;
            DELETE FROM tt_temp_61;
            UTILS.IDENTITY_RESET('tt_temp_61');

            INSERT INTO tt_temp_61 ( 
            	SELECT A.CollateralID ,
                    A.CustomeroftheBankAlt_Key ,
                    A.CustomeroftheBank ,
                    A.AccountID ,
                    A.CustomerID ,
                    A.OtherOwnerName ,
                    A.PAN ,
                    A.OtherOwnerRelationshipAlt_Key ,
                    A.CollOwnerDescription ,
                    A.IfRelationselectAlt_Key ,
                    A.IfRelationselect ,
                    A.AddressType ,
                    A.Company ,
                    A.AddressLine1 ,
                    A.AddressLine2 ,
                    A.AddressLine3 ,
                    A.City ,
                    A.PinCode ,
                    A.Country ,
                    A.State ,
                    A.District ,
                    A.STDCodeO ,
                    A.PhoneNumberO ,
                    A.STDCodeR ,
                    A.PhoneNumberR ,
                    A.FaxNumber ,
                    A.MobileNO ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModified 
            	  FROM ( SELECT A.CollateralID ,
                             A.CustomeroftheBankAlt_Key ,
                             B.ParameterName CustomeroftheBank  ,
                             A.AccountID ,
                             A.CustomerID ,
                             A.OtherOwnerName ,
                             A.PAN ,
                             A.OtherOwnerRelationshipAlt_Key ,
                             G.CollOwnerDescription ,
                             A.IfRelationselectAlt_Key ,
                             B.ParameterName IfRelationselect  ,
                             A.AddressType ,
                             A.Company ,
                             A.AddressLine1 ,
                             A.AddressLine2 ,
                             A.AddressLine3 ,
                             A.City ,
                             A.PinCode ,
                             A.Country ,
                             A.State ,
                             A.District ,
                             A.STDCodeO ,
                             A.PhoneNumberO ,
                             A.STDCodeR ,
                             A.PhoneNumberR ,
                             A.FaxNumber ,
                             A.MobileNO ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModified 
                      FROM CollateralOtherOwner A
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'CustomeroftheBank' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'DimYesNo'
                                                   AND EffectiveFromTimeKey <= ( SELECT Timekey 
                                                                                 FROM SysDataMatrix 
                                                                                  WHERE  CurrentStatus = 'C' )
            	  AND EffectiveToTimeKey >= ( SELECT Timekey 
                                           FROM SysDataMatrix 
                                            WHERE  CurrentStatus = 'C' ) ) B   ON A.CustomeroftheBankAlt_Key = B.ParameterAlt_Key
                             LEFT JOIN ( SELECT ParameterAlt_Key ,
                                                ParameterName ,
                                                'Relation' Tablename  
                                         FROM DimParameter 
                                          WHERE  DimParameterName = 'Relation'
                                                   AND EffectiveFromTimeKey <= ( SELECT Timekey 
                                                                                 FROM SysDataMatrix 
                                                                                  WHERE  CurrentStatus = 'C' )
                                                   AND EffectiveToTimeKey >= ( SELECT Timekey 
                                                                               FROM SysDataMatrix 
                                                                                WHERE  CurrentStatus = 'C' ) ) C   ON A.IfRelationselectAlt_Key = C.ParameterAlt_Key
                             LEFT JOIN DimCollateralOwnerType G   ON A.OtherOwnerRelationshipAlt_Key = G.CollateralOwnerTypeAltKey
                             AND CollOwnerDescription NOT IN ( 'Primary Customer','Proprietor' )

                             AND G.EffectiveFromTimeKey <= ( SELECT Timekey 
                                                             FROM SysDataMatrix 
                                                              WHERE  CurrentStatus = 'C' )
                             AND G.EffectiveToTimeKey >= ( SELECT Timekey 
                                                           FROM SysDataMatrix 
                                                            WHERE  CurrentStatus = 'C' )
                       WHERE  A.EffectiveFromTimeKey <= ( SELECT Timekey 
                                                          FROM SysDataMatrix 
                                                           WHERE  CurrentStatus = 'C' )
                                AND A.EffectiveToTimeKey >= ( SELECT Timekey 
                                                              FROM SysDataMatrix 
                                                               WHERE  CurrentStatus = 'C' )
                                AND NVL(A.AuthorisationStatus, 'A') = 'A' ) 
                    --AND A.Entity_Key IN

                    --(

                    --    SELECT MAX(Entity_Key)

                    --    FROM CollateralOtherOwner

                    --    WHERE EffectiveFromTimeKey <= @TimeKey

                    --          AND EffectiveToTimeKey >= @TimeKey

                    --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')

                    --    GROUP BY CollateralID

                    --)
                    A
            	  GROUP BY A.CollateralID,A.CustomeroftheBankAlt_Key,A.CustomeroftheBank,A.AccountID,A.CustomerID,A.OtherOwnerName,A.PAN,A.OtherOwnerRelationshipAlt_Key,A.CollOwnerDescription,A.IfRelationselectAlt_Key,A.IfRelationselect,A.AddressType,A.Company,A.AddressLine1,A.AddressLine2,A.AddressLine3,A.City,A.PinCode,A.Country,A.State,A.District,A.STDCodeO,A.PhoneNumberO,A.STDCodeR,A.PhoneNumberR,A.FaxNumber,A.MobileNO,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'Collateral' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_61 A
                                WHERE  A.CollateralID = v_CollateralID ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;
         END IF;

      END;
   EXCEPTION
      WHEN OTHERS THEN

   BEGIN
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize);
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERSEARCHLIST_NEW_PROD" TO "ADF_CDR_RBL_STGDB";
