--------------------------------------------------------
--  DDL for Procedure WILFULDEFAULTERDIRECTORDETAILGRID_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" 
-- ============================================= 
 --Exec [WilfulDefaulterDirectorDetailGrid] @OperationFlag = 1 
 -- Author:    <FARAHNAAZ>  
 -- Create date:   <1/04/2021>  
 -- Description:   <Grid SP for [WilfulDefaulterDirectorDetailGrid]>
 -- =============================================  

(
  --Declare --@DirectoreName			Varchar(100) ='',--@Pan					Varchar(10)='',--@Din					Numeric(8,2),--@DirectorType			varchar(50)=''
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
         IF ( v_OperationFlag NOT IN ( 16,17 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_308') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_308 ';
            END IF;
            DELETE FROM tt_temp_308;
            UTILS.IDENTITY_RESET('tt_temp_308');

            INSERT INTO tt_temp_308 ( 
            	SELECT Z.Entity_Key ,
                    Z.DirectorName ,
                    Z.PAN ,
                    Z.DIN ,
                    Z.DirectorTypeAlt_Key ,
                    Z.AuthorisationStatus ,
                    Z.EffectiveFromTimeKey ,
                    Z.EffectiveToTimeKey ,
                    Z.CreatedBy ,
                    Z.DateCreated ,
                    Z.ModifiedBy ,
                    Z.DateModified ,
                    Z.ApprovedBy ,
                    Z.DateApproved 
            	  FROM ( SELECT A.Entity_Key ,
                             A.DirectorName ,
                             A.PAN ,
                             A.DIN ,
                             A.DirectorTypeAlt_Key ,
                             B.ParameterName DirectoryType  ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved 
                      FROM WilfulDirectorDetail A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DirectorType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DirectorType'
                                              AND EffectiveFromTimeKey <= v_TimeKey
            	  AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.DirectorTypeAlt_Key = B.ParameterAlt_Key
                      UNION 
                      SELECT A.Entity_Key ,
                             A.DirectorName ,
                             A.PAN ,
                             A.DIN ,
                             A.DirectorTypeAlt_Key ,
                             B.ParameterName DirectoryType  ,
                             A.AuthorisationStatus ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ModifiedBy ,
                             A.DateModified ,
                             A.ApprovedBy ,
                             A.DateApproved 
                      FROM WilfulDirectorDetail_Mod A
                             JOIN ( SELECT ParameterAlt_Key ,
                                           ParameterName ,
                                           'DirectorType' Tablename  
                                    FROM DimParameter 
                                     WHERE  DimParameterName = 'DirectorType'
                                              AND EffectiveFromTimeKey <= v_TimeKey
                                              AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.DirectorTypeAlt_Key = B.ParameterAlt_Key
                             AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                   FROM WilfulDirectorDetail_Mod 
                                                    WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                             AND EffectiveToTimeKey >= v_TimeKey
                                                             AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                     GROUP BY DirectorName )
                     ) Z
            	  GROUP BY Z.Entity_Key,Z.DirectorName,Z.PAN,Z.DIN,Z.DirectorTypeAlt_Key,Z.AuthorisationStatus,Z.EffectiveFromTimeKey,Z.EffectiveToTimeKey,Z.CreatedBy,Z.DateCreated,Z.ModifiedBy,Z.DateModified,Z.ApprovedBy,Z.DateApproved );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DirectorName  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'DirectorName' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_308 A ) 
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
               IF utils.object_id('TempDB..tt_temp_30816') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_251 ';
               END IF;
               DELETE FROM tt_temp16_251;
               UTILS.IDENTITY_RESET('tt_temp16_251');

               INSERT INTO tt_temp16_251 ( 
               	SELECT P.Entity_Key ,
                       P.DirectorName ,
                       P.PAN ,
                       P.DIN ,
                       P.DirectorTypeAlt_Key ,
                       P.AuthorisationStatus ,
                       P.EffectiveFromTimeKey ,
                       P.EffectiveToTimeKey ,
                       P.CreatedBy ,
                       P.DateCreated ,
                       P.ModifiedBy ,
                       P.DateModified ,
                       P.ApprovedBy ,
                       P.DateApproved 
               	  FROM ( SELECT A.Entity_Key ,
                                A.DirectorName ,
                                A.PAN ,
                                A.DIN ,
                                A.DirectorTypeAlt_Key ,
                                B.ParameterName DirectoryType  ,
                                A.AuthorisationStatus ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ModifiedBy ,
                                A.DateModified ,
                                A.ApprovedBy ,
                                A.DateApproved 
                         FROM WilfulDirectorDetail A
                                JOIN ( SELECT ParameterAlt_Key ,
                                              ParameterName ,
                                              'DirectorType' Tablename  
                                       FROM DimParameter 
                                        WHERE  DimParameterName = 'DirectorType'
                                                 AND EffectiveFromTimeKey <= v_TimeKey
                                                 AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.DirectorTypeAlt_Key = B.ParameterAlt_Key
                                AND A.Entity_Key IN ( SELECT MAX(Entity_Key)  
                                                      FROM WilfulDirectorDetail_Mod 
                                                       WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                AND EffectiveToTimeKey >= v_TimeKey
                                                                AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                        GROUP BY DirectorName )
                        ) P
               	  GROUP BY P.Entity_Key,P.DirectorName,P.PAN,P.DIN,P.DirectorTypeAlt_Key,P.AuthorisationStatus,P.EffectiveFromTimeKey,P.EffectiveToTimeKey,P.CreatedBy,P.DateCreated,P.ModifiedBy,P.DateModified,P.ApprovedBy,P.DateApproved );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY DirectorName  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'DirectorName' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_251 A ) 
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
      --Select * from WilfulDirectorDetail_Mod

   END;END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILFULDEFAULTERDIRECTORDETAILGRID_04122023" TO "ADF_CDR_RBL_STGDB";
