--------------------------------------------------------
--  DDL for Procedure DIMKARETMASTER_SEARCHLIST_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 1 ,
  v_MenuID IN NUMBER DEFAULT 14566 
)
AS
   v_TimeKey NUMBER(10,0);
   v_Authlevel NUMBER(10,0);
   --select * from 	SysCRisMacMenu where menucaption like '%Gold%'
   v_Date VARCHAR2(200);
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
   DBMS_OUTPUT.PUT_LINE(v_menuID);
   SELECT UTILS.CONVERT_TO_VARCHAR2(B.Date_,200) Date1  

     INTO v_Date
     FROM SysDataMatrix A
            JOIN SysDayMatrix B   ON A.TimeKey = B.TimeKey
    WHERE  A.CurrentStatus = 'C';
   BEGIN

      BEGIN
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_120') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_120 ';
            END IF;
            DELETE FROM tt_temp_120;
            UTILS.IDENTITY_RESET('tt_temp_120');

            INSERT INTO tt_temp_120 ( 
            	SELECT ProcessDate ,
                    A.KaretMasterAlt_Key ,
                    A.KaretMasterValueName ,
                    A.KaretMasterValueDt ,
                    A.KaretMasterValueAmt ,
                    A.SrcSysKaretValueCode ,
                    A.SrcSysKaretValueName ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.CreatedBy ,
                    A.DateCreated ,
                    A.ApprovedBy ,
                    A.DateApproved ,
                    A.ModifiedBy ,
                    A.DateModifie ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate 
            	  FROM ( SELECT v_Date ProcessDate  ,
                             A.KaretMasterAlt_Key ,
                             A.KaretMasterValueName ,
                             UTILS.CONVERT_TO_VARCHAR2(A.KaretMasterValueDt,20,p_style=>103) KaretMasterValueDt  ,
                             A.KaretMasterValueAmt ,
                             A.SrcSysKaretValueCode ,
                             A.SrcSysKaretValueName ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModifie ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModifie) ModAppDate  
                      FROM DimKaretMaster A

                      -- left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey
                               AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT v_Date ProcessDate  ,
                             A.KaretMasterAlt_Key ,
                             A.KaretMasterValueName ,
                             UTILS.CONVERT_TO_VARCHAR2(A.KaretMasterValueDt,20,p_style=>103) KaretMasterValueDt  ,
                             A.KaretMasterValueAmt ,
                             A.SrcSysKaretValueCode ,
                             A.SrcSysKaretValueName ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy ,
                             A.DateCreated ,
                             A.ApprovedBy ,
                             A.DateApproved ,
                             A.ModifiedBy ,
                             A.DateModifie ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApproved, A.DateModifie) ModAppDate  
                      FROM DimKaretMaster_Mod A

                      -- left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey

                               --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                               AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                    FROM DimKaretMaster_Mod 
                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey
                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                      GROUP BY EntityKey )
                     ) A
            	  GROUP BY ProcessDate,A.KaretMasterAlt_Key,A.KaretMasterValueName,A.KaretMasterValueDt,A.KaretMasterValueAmt,A.SrcSysKaretValueCode,A.SrcSysKaretValueName,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY KaretMasterAlt_Key  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'KaretMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_120 A ) 
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
               IF utils.object_id('TempDB..tt_temp_12016') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_90 ';
               END IF;
               DELETE FROM tt_temp16_90;
               UTILS.IDENTITY_RESET('tt_temp16_90');

               INSERT INTO tt_temp16_90 ( 
               	SELECT ProcessDate ,
                       A.KaretMasterAlt_Key ,
                       A.KaretMasterValueName ,
                       A.KaretMasterValueDt ,
                       A.KaretMasterValueAmt ,
                       A.SrcSysKaretValueCode ,
                       A.SrcSysKaretValueName ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.CreatedBy ,
                       A.DateCreated ,
                       A.ApprovedBy ,
                       A.DateApproved ,
                       A.ModifiedBy ,
                       A.DateModifie ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate 
               	  FROM ( SELECT v_Date ProcessDate  ,
                                A.KaretMasterAlt_Key ,
                                A.KaretMasterValueName ,
                                UTILS.CONVERT_TO_VARCHAR2(A.KaretMasterValueDt,20,p_style=>103) KaretMasterValueDt  ,
                                A.KaretMasterValueAmt ,
                                A.SrcSysKaretValueCode ,
                                A.SrcSysKaretValueName ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy ,
                                A.DateCreated ,
                                A.ApprovedBy ,
                                A.DateApproved ,
                                A.ModifiedBy ,
                                A.DateModifie ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApproved, A.DateModifie) ModAppDate  
                         FROM DimKaretMaster_Mod A

                         -- left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey

                                  --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                  AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                       FROM DimKaretMaster_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                         GROUP BY EntityKey )
                        ) A
               	  GROUP BY ProcessDate,A.KaretMasterAlt_Key,A.KaretMasterValueName,A.KaretMasterValueDt,A.KaretMasterValueAmt,A.SrcSysKaretValueCode,A.SrcSysKaretValueName,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY KaretMasterAlt_Key  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'KaretMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_90 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_12020') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_57 ';
                  END IF;
                  DELETE FROM tt_temp20_57;
                  UTILS.IDENTITY_RESET('tt_temp20_57');

                  INSERT INTO tt_temp20_57 ( 
                  	SELECT ProcessDate ,
                          A.KaretMasterAlt_Key ,
                          A.KaretMasterValueName ,
                          A.KaretMasterValueDt ,
                          A.KaretMasterValueAmt ,
                          A.SrcSysKaretValueCode ,
                          A.SrcSysKaretValueName ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.CreatedBy ,
                          A.DateCreated ,
                          A.ApprovedBy ,
                          A.DateApproved ,
                          A.ModifiedBy ,
                          A.DateModifie ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate 
                  	  FROM ( SELECT v_Date ProcessDate  ,
                                   A.KaretMasterAlt_Key ,
                                   A.KaretMasterValueName ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.KaretMasterValueDt,20,p_style=>103) KaretMasterValueDt  ,
                                   A.KaretMasterValueAmt ,
                                   A.SrcSysKaretValueCode ,
                                   A.SrcSysKaretValueName ,
                                   --,isnull(A.AuthorisationStatus, 'A') 
                                   A.AuthorisationStatus ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy ,
                                   A.DateCreated ,
                                   A.ApprovedBy ,
                                   A.DateApproved ,
                                   A.ModifiedBy ,
                                   A.DateModifie ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModifie, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedBy, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApproved, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedBy, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApproved, A.DateModifie) ModAppDate  
                            FROM DimKaretMaster_Mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM DimKaretMaster_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey

                                                                     --AND AuthorisationStatus IN('1A')
                                                                     AND (CASE 
                                                                               WHEN v_AuthLevel = 2
                                                                                 AND NVL(AuthorisationStatus, 'A') IN ( '1A' )
                  	 THEN 1
                  	WHEN v_AuthLevel = 1
                  	  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP' )
                  	 THEN 1
                                                                   ELSE 0
                                                                      END) = 1
                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP BY ProcessDate,A.KaretMasterAlt_Key,A.KaretMasterValueName,A.KaretMasterValueDt,A.KaretMasterValueAmt,A.SrcSysKaretValueCode,A.SrcSysKaretValueName,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.CreatedBy,A.DateCreated,A.ApprovedBy,A.DateApproved,A.ModifiedBy,A.DateModifie,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY KaretMasterAlt_Key  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'KaretMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_57 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."DIMKARETMASTER_SEARCHLIST_PROD" TO "ADF_CDR_RBL_STGDB";
