--------------------------------------------------------
--  DDL for Procedure COLLATERALOWNERADDRESSSEARCHLIST_18082021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" 
(
  --Declare--Exec [dbo].[CollateralOwnerAddressSearchList] @OperationFlag =1,@CollateralID='234'--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_CollateralID IN VARCHAR2 DEFAULT ' ' 
)
AS
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

 ---Adding One more Parameter
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
            IF utils.object_id('TempDB..tt_temp_50') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_50 ';
            END IF;
            DELETE FROM tt_temp_50;
            UTILS.IDENTITY_RESET('tt_temp_50');

            INSERT INTO tt_temp_50 ( 
            	SELECT A.CollateralID ,
                    A.AddressType ,
                    A.Company Category  ,
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
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A' ) 
                    --      AND A.Entity_Key IN

                    --(

                    --    SELECT MAX(Entity_Key)

                    --    FROM CollateralOtherOwner

                    --    WHERE EffectiveFromTimeKey <= @TimeKey

                    --          AND EffectiveToTimeKey >= @TimeKey

                    --          AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')

                    --    GROUP BY CollateralID

                    --)
                    A
            	  GROUP BY A.CollateralID,A.AddressType,A.Company,A.AddressLine1,A.AddressLine2,A.AddressLine3,A.City,A.PinCode,A.Country,A.State,A.District,A.STDCodeO,A.PhoneNumberO,A.STDCodeR,A.PhoneNumberR,A.FaxNumber,A.MobileNO,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModified );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY CollateralID  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'Collateral' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_50 A
                                WHERE  CollateralID = v_CollateralID
                                         AND A.AddressType IS NOT NULL ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."COLLATERALOWNERADDRESSSEARCHLIST_18082021" TO "ADF_CDR_RBL_STGDB";
