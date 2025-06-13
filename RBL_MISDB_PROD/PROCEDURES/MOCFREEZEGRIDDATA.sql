--------------------------------------------------------
--  DDL for Procedure MOCFREEZEGRIDDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" 
(
  --Declare--@PageNo         INT         = 1, --@PageSize       INT         = 10, 
  v_OperationFlag IN NUMBER DEFAULT 2 ,
  v_MenuID IN NUMBER DEFAULT 14569 
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
         --select * from 	SysCRisMacMenu where menucaption like '%Product%'				
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
            IF utils.object_id('TempDB..tt_temp_183') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_183 ';
            END IF;
            DELETE FROM tt_temp_183;
            UTILS.IDENTITY_RESET('tt_temp_183');

            INSERT INTO tt_temp_183 ( 
            	SELECT A.Freeze_MOC_Date ,
                    A.AuthorisationStatus ,
                    A.EffectiveFromTimeKey ,
                    A.EffectiveToTimeKey ,
                    A.FreezeBy ,
                    A.Date_of_freeze ,
                    A.ApprovedBySecondLevel ,
                    A.DateApprovedSecondLevel ,
                    A.ModifiedBy ,
                    A.DateModified ,
                    A.ApprovedByFirstLevel ,
                    A.DateApprovedFirstLevel ,
                    A.CrModBy ,
                    A.CrModDate ,
                    A.CrAppBy ,
                    A.CrAppDate ,
                    A.ModAppBy ,
                    A.ModAppDate ,
                    A.MOC_Initialized_Date 
            	  FROM ( SELECT UTILS.CONVERT_TO_VARCHAR2(A.Freeze_MOC_Date,20,p_style=>103) Freeze_MOC_Date  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy FreezeBy  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) Date_of_freeze  ,
                             A.ApprovedBy ApprovedBySecondLevel  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApprovedSecondLevel  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                             B.ApprovedByFirstLevel ,
                             UTILS.CONVERT_TO_VARCHAR2(B.DateApprovedFirstLevel,20,p_style=>103) DateApprovedFirstLevel  ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(B.ApprovedByFirstLevel, B.CreatedBy) CrAppBy  ,
                             NVL(B.DateApprovedFirstLevel, B.DateCreated) CrAppDate  ,
                             NVL(B.ApprovedByFirstLevel, B.ModifiedBy) ModAppBy  ,
                             NVL(B.DateApprovedFirstLevel, B.DateModified) ModAppDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.MOC_Initialized_Date,20,p_style=>103) MOC_Initialized_Date  
                      FROM MOCFreezeDetails A
                             LEFT JOIN MOCFreezeDetails_Mod B   ON A.Freeze_MOC_Date = B.Freeze_MOC_Date
                             AND B.EffectiveFromTimeKey <= v_TimeKey
                             AND B.EffectiveToTimeKey >= v_TimeKey
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                      UNION 
                      SELECT UTILS.CONVERT_TO_VARCHAR2(A.Freeze_MOC_Date,20,p_style=>103) Freeze_MOC_Date  ,
                             NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                             A.EffectiveFromTimeKey ,
                             A.EffectiveToTimeKey ,
                             A.CreatedBy FreezeBy  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) Date_of_freeze  ,
                             A.ApprovedBy ApprovedBySecondLevel  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApprovedSecondLevel  ,
                             A.ModifiedBy ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                             A.ApprovedByFirstLevel ,
                             UTILS.CONVERT_TO_VARCHAR2(A.DateApprovedFirstLevel,20,p_style=>103) DateApprovedFirstLevel  ,
                             NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                             NVL(A.DateModified, A.DateCreated) CrModDate  ,
                             NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                             NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                             NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                             NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                             UTILS.CONVERT_TO_VARCHAR2(A.MOC_Initialized_Date,20,p_style=>103) MOC_Initialized_Date  
                      FROM MOCFreezeDetails_Mod A
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey

                                --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                     FROM MOCFreezeDetails_Mod 
                                                      WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                               AND EffectiveToTimeKey >= v_TimeKey
                                                               AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                       GROUP BY EntityKey )
                     ) A
            	  GROUP BY A.Freeze_MOC_Date,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.FreezeBy,A.Date_of_freeze,A.ApprovedBySecondLevel,A.DateApprovedSecondLevel,A.ModifiedBy,A.DateModified,A.ApprovedByFirstLevel,A.DateApprovedFirstLevel,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.MOC_Initialized_Date );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Date_of_freeze  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'MOCFreezeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_183 A ) 
                             --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                             --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                             DataPointOwner ) DataPointOwner
                 ORDER BY Freeze_MOC_Date DESC ;
               DBMS_SQL.RETURN_RESULT(v_cursor);

         END;

         --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1

         --      AND RowNumber <= (@PageNo * @PageSize);
         ELSE
            /*  IT IS Used For GRID Search which are Pending for Authorization    */
            IF ( v_OperationFlag IN ( 16,17 )
             ) THEN

            BEGIN
               IF utils.object_id('TempDB..tt_temp_18316') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_137 ';
               END IF;
               DELETE FROM tt_temp16_137;
               UTILS.IDENTITY_RESET('tt_temp16_137');

               INSERT INTO tt_temp16_137 ( 
               	SELECT A.Freeze_MOC_Date ,
                       A.AuthorisationStatus ,
                       A.EffectiveFromTimeKey ,
                       A.EffectiveToTimeKey ,
                       A.FreezeBy ,
                       A.Date_of_freeze ,
                       A.ApprovedBySecondLevel ,
                       A.DateApprovedSecondLevel ,
                       A.ModifiedBy ,
                       A.DateModified ,
                       A.ApprovedByFirstLevel ,
                       A.DateApprovedFirstLevel ,
                       A.CrModBy ,
                       A.CrModDate ,
                       A.CrAppBy ,
                       A.CrAppDate ,
                       A.ModAppBy ,
                       A.ModAppDate ,
                       A.MOC_Initialized_Date 
               	  FROM ( SELECT UTILS.CONVERT_TO_VARCHAR2(A.Freeze_MOC_Date,20,p_style=>103) Freeze_MOC_Date  ,
                                NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                A.EffectiveFromTimeKey ,
                                A.EffectiveToTimeKey ,
                                A.CreatedBy FreezeBy  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) Date_of_freeze  ,
                                A.ApprovedBy ApprovedBySecondLevel  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApprovedSecondLevel  ,
                                A.ModifiedBy ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                                A.ApprovedByFirstLevel ,
                                UTILS.CONVERT_TO_VARCHAR2(A.DateApprovedFirstLevel,20,p_style=>103) DateApprovedFirstLevel  ,
                                NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                UTILS.CONVERT_TO_VARCHAR2(A.MOC_Initialized_Date,20,p_style=>103) MOC_Initialized_Date  
                         FROM MOCFreezeDetails_Mod A
                          WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                   AND A.EffectiveToTimeKey >= v_TimeKey

                                   --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                   AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                        FROM MOCFreezeDetails_Mod 
                                                         WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                  AND EffectiveToTimeKey >= v_TimeKey
                                                                  AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                          GROUP BY EntityKey )
                        ) A
               	  GROUP BY A.Freeze_MOC_Date,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.FreezeBy,A.Date_of_freeze,A.ApprovedBySecondLevel,A.DateApprovedSecondLevel,A.ModifiedBy,A.DateModified,A.ApprovedByFirstLevel,A.DateApprovedFirstLevel,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.MOC_Initialized_Date );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Date_of_freeze  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'MOCFreezeMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_137 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_18320') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_102 ';
                  END IF;
                  DELETE FROM tt_temp20_102;
                  UTILS.IDENTITY_RESET('tt_temp20_102');

                  INSERT INTO tt_temp20_102 ( 
                  	SELECT A.Freeze_MOC_Date ,
                          A.AuthorisationStatus ,
                          A.EffectiveFromTimeKey ,
                          A.EffectiveToTimeKey ,
                          A.FreezeBy ,
                          A.Date_of_freeze ,
                          A.ApprovedBySecondLevel ,
                          A.DateApprovedSecondLevel ,
                          A.ModifiedBy ,
                          A.DateModified ,
                          A.ApprovedByFirstLevel ,
                          A.DateApprovedFirstLevel ,
                          A.CrModBy ,
                          A.CrModDate ,
                          A.CrAppBy ,
                          A.CrAppDate ,
                          A.ModAppBy ,
                          A.ModAppDate ,
                          A.MOC_Initialized_Date 
                  	  FROM ( SELECT UTILS.CONVERT_TO_VARCHAR2(A.Freeze_MOC_Date,20,p_style=>103) Freeze_MOC_Date  ,
                                   NVL(A.AuthorisationStatus, 'A') AuthorisationStatus  ,
                                   A.EffectiveFromTimeKey ,
                                   A.EffectiveToTimeKey ,
                                   A.CreatedBy FreezeBy  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) Date_of_freeze  ,
                                   A.ApprovedBy ApprovedBySecondLevel  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApprovedSecondLevel  ,
                                   A.ModifiedBy ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                                   A.ApprovedByFirstLevel ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.DateApprovedFirstLevel,20,p_style=>103) DateApprovedFirstLevel  ,
                                   NVL(A.ModifiedBy, A.CreatedBy) CrModBy  ,
                                   NVL(A.DateModified, A.DateCreated) CrModDate  ,
                                   NVL(A.ApprovedByFirstLevel, A.CreatedBy) CrAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateCreated) CrAppDate  ,
                                   NVL(A.ApprovedByFirstLevel, A.ModifiedBy) ModAppBy  ,
                                   NVL(A.DateApprovedFirstLevel, A.DateModified) ModAppDate  ,
                                   UTILS.CONVERT_TO_VARCHAR2(A.MOC_Initialized_Date,20,p_style=>103) MOC_Initialized_Date  
                            FROM MOCFreezeDetails_Mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey

                                      --AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM MOCFreezeDetails_Mod 
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
                  	  GROUP BY A.Freeze_MOC_Date,A.AuthorisationStatus,A.EffectiveFromTimeKey,A.EffectiveToTimeKey,A.FreezeBy,A.Date_of_freeze,A.ApprovedBySecondLevel,A.DateApprovedSecondLevel,A.ModifiedBy,A.DateModified,A.ApprovedByFirstLevel,A.DateApprovedFirstLevel,A.CrModBy,A.CrModDate,A.CrAppBy,A.CrAppDate,A.ModAppBy,A.ModAppDate,A.MOC_Initialized_Date );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY Date_of_freeze  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'MOCFreezeMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_102 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."MOCFREEZEGRIDDATA" TO "ADF_CDR_RBL_STGDB";
