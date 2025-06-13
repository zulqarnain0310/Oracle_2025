--------------------------------------------------------
--  DDL for Procedure ACBUSEGMENTSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" 
--exec [ACBUSegmentSearchList] '','','',1

(
  --Declare
  iv_SourceSystem IN VARCHAR2 DEFAULT ' ' ,
  iv_ACBUSegmentCode IN VARCHAR2 DEFAULT ' ' ,
  iv_ACBUSegmentDescription IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER DEFAULT 1 
)
AS
   v_SourceSystem VARCHAR2(10) := iv_SourceSystem;
   v_ACBUSegmentCode VARCHAR2(10) := iv_ACBUSegmentCode;
   v_ACBUSegmentDescription VARCHAR2(100) := iv_ACBUSegmentDescription;
   v_TimeKey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT Timekey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   DBMS_OUTPUT.PUT_LINE(v_Timekey);
   IF ( ( v_SourceSystem = ' ' )
     AND ( v_ACBUSegmentCode = ' ' )
     AND ( v_ACBUSegmentDescription = ' ' )
     AND ( v_operationflag NOT IN ( 16,20 )
    ) ) THEN

   BEGIN
      DBMS_OUTPUT.PUT_LINE('111');
      DELETE FROM tt_TEMP55;
      UTILS.IDENTITY_RESET('tt_TEMP55');

      INSERT INTO tt_TEMP55 ( 
      	SELECT SourceSystem ,
              ACBUSegmentCode ,
              ACBUSegmentDescription ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifyBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              D2Ktimestamp ,
              Remarks ,
              ACBUSegmentEntityID 

      	  --select * from  curdat.Advacbasicdetail
      	  FROM ACBUSegment A
      	UNION 
      	SELECT SourceSystem ,
              ACBUSegmentCode ,
              ACBUSegmentDescription ,
              AuthorisationStatus ,
              EffectiveFromTimeKey ,
              EffectiveToTimeKey ,
              CreatedBy ,
              DateCreated ,
              ModifyBy ,
              DateModified ,
              ApprovedBy ,
              DateApproved ,
              D2Ktimestamp ,
              Remarks ,
              ACBUSegmentEntityID 
      	  FROM ACBUSegment_Mod A );
      OPEN  v_cursor FOR
         SELECT * 
           FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                         COUNT(*) OVER ( ) TotalCount  ,
                         'AccountBusinessSegmentMaster' TableName  ,
                         * 
                  FROM ( SELECT * 
                         FROM tt_TEMP55 A ) 
                       --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'

                       --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                       DataPointOwner ) DataPointOwner ;
         DBMS_SQL.RETURN_RESULT(v_cursor);
      --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
      --      AND RowNumber <= (@PageNo * @PageSize);
      RETURN;

   END;
   END IF;
   BEGIN

      BEGIN
         IF v_SourceSystem = ' ' THEN
          v_SourceSystem := NULL ;
         END IF;
         IF v_ACBUSegmentCode = ' ' THEN
          v_ACBUSegmentCode := NULL ;
         END IF;
         IF v_ACBUSegmentDescription = ' ' THEN
          v_ACBUSegmentDescription := NULL ;
         END IF;
         DBMS_OUTPUT.PUT_LINE('1');
         /*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */
         IF ( v_OperationFlag NOT IN ( 16,17,20 )
          ) THEN

         BEGIN
            IF utils.object_id('TempDB..tt_temp_2') IS NOT NULL THEN
             EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp_2 ';
            END IF;
            DELETE FROM tt_temp_2;
            UTILS.IDENTITY_RESET('tt_temp_2');

            INSERT INTO tt_temp_2 ( 
            	SELECT SourceSystem ,
                    ACBUSegmentCode ,
                    ACBUSegmentDescription ,
                    AuthorisationStatus ,
                    EffectiveFromTimeKey ,
                    EffectiveToTimeKey ,
                    CreatedBy ,
                    DateCreated ,
                    ModifyBy ,
                    DateModified ,
                    ApprovedBy ,
                    DateApproved ,
                    D2Ktimestamp ,
                    Remarks ,
                    ACBUSegmentEntityID 
            	  FROM ( SELECT SourceSystem ,
                             ACBUSegmentCode ,
                             ACBUSegmentDescription ,
                             AuthorisationStatus ,
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             ApprovedBy ,
                             DateApproved ,
                             D2Ktimestamp ,
                             Remarks ,
                             ACBUSegmentEntityID 

                      --select * from  curdat.Advacbasicdetail
                      FROM ACBUSegment 
                       WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                AND A.EffectiveToTimeKey >= v_TimeKey
                                AND NVL(A.AuthorisationStatus, 'A') = 'A'
                                AND ( ( A.SourceSystem = v_SourceSystem )
                                OR ( ACBUSegmentCode = v_ACBUSegmentCode )
                                OR ( ACBUSegmentDescription LIKE '%' || v_ACBUSegmentDescription || '%' ) )
                      UNION 
                      SELECT SourceSystem ,
                             ACBUSegmentCode ,
                             ACBUSegmentDescription ,
                             AuthorisationStatus ,
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             ApprovedBy ,
                             DateApproved ,
                             D2Ktimestamp ,
                             Remarks ,
                             ACBUSegmentEntityID 

                      --select * from  curdat.Advacbasicdetail
                      FROM ACBUSegment_Mod 

                      --inner join curdat.DerivativeDetail E on A.EntityKey=E.EntityKey
                      WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                               AND A.EffectiveToTimeKey >= v_TimeKey

                               --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                               AND ( ( SourceSystem = v_SourceSystem )
                               OR ( ACBUSegmentCode = v_ACBUSegmentCode )
                               OR ( v_ACBUSegmentDescription LIKE '%' || v_ACBUSegmentDescription || '%' ) )
                               AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                    FROM ACBUSegment_Mod 
                                                     WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                              AND EffectiveToTimeKey >= v_TimeKey
                                                              AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM','1A' )

                                                      GROUP BY EntityKey )
                     ) A
            	  GROUP
            	--A.CustomerACID,
            	 --A.CustomerID,
            	 --A.CustomerName,
            	 --A.DerivativeRefNo,
            	 --A.Duedate,
            	 --A.DueAmt,
            	 --A.OsAmt,
            	 --A.POS,
            	 ---------------------------------
            	 BY SourceSystem,ACBUSegmentCode,ACBUSegmentDescription,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifyBy,DateModified,ApprovedBy,DateApproved,D2Ktimestamp,Remarks,ACBUSegmentEntityID );
            OPEN  v_cursor FOR
               SELECT * 
                 FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                               COUNT(*) OVER ( ) TotalCount  ,
                               'InvestmentCodeMaster' TableName  ,
                               * 
                        FROM ( SELECT * 
                               FROM tt_temp_2 A ) 
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
               IF utils.object_id('TempDB..tt_temp_216') IS NOT NULL THEN
                EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp16_2 ';
               END IF;
               DELETE FROM tt_temp16_2;
               UTILS.IDENTITY_RESET('tt_temp16_2');

               INSERT INTO tt_temp16_2 ( 
               	SELECT
               	--A.CustomerACID,
               	 --A.CustomerID,
               	 --A.CustomerName,
               	 --A.DerivativeRefNo,
               	 --A.Duedate,
               	 --A.DueAmt,
               	 --A.OsAmt,
               	 --A.POS,
               	 ---------------------------------
               	 SourceSystem ,
                 ACBUSegmentCode ,
                 ACBUSegmentDescription ,
                 AuthorisationStatus ,
                 EffectiveFromTimeKey ,
                 EffectiveToTimeKey ,
                 CreatedBy ,
                 DateCreated ,
                 ModifyBy ,
                 DateModified ,
                 ApprovedBy ,
                 DateApproved ,
                 D2Ktimestamp ,
                 Remarks ,
                 ACBUSegmentEntityID 
               	  FROM ( SELECT SourceSystem ,
                                ACBUSegmentCode ,
                                ACBUSegmentDescription ,
                                AuthorisationStatus ,
                                EffectiveFromTimeKey ,
                                EffectiveToTimeKey ,
                                CreatedBy ,
                                DateCreated ,
                                ModifyBy ,
                                DateModified ,
                                ApprovedBy ,
                                DateApproved ,
                                D2Ktimestamp ,
                                Remarks ,
                                ACBUSegmentEntityID 
                         FROM ACBUSegment_Mod A

                         --inner join curdat.DerivativeDetail E on A.EntityKey=E.EntityKey
                         WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                  AND A.EffectiveToTimeKey >= v_TimeKey

                                  --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                                  AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                       FROM ACBUSegment_Mod 
                                                        WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                 AND EffectiveToTimeKey >= v_TimeKey
                                                                 AND NVL(AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )

                                                         GROUP BY EntityKey )
                        ) A
               	  GROUP
               	--A.CustomerACID,
               	 --A.CustomerID,
               	 --A.CustomerName,
               	 --A.DerivativeRefNo,
               	 --A.Duedate,
               	 --A.DueAmt,
               	 --A.OsAmt,
               	 --A.POS,
               	 ---------------------------------
               	 BY SourceSystem,ACBUSegmentCode,ACBUSegmentDescription,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifyBy,DateModified,ApprovedBy,DateApproved,D2Ktimestamp,Remarks,ACBUSegmentEntityID );
               OPEN  v_cursor FOR
                  SELECT * 
                    FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                  COUNT(*) OVER ( ) TotalCount  ,
                                  'AccountBusinessSegmentMaster' TableName  ,
                                  * 
                           FROM ( SELECT * 
                                  FROM tt_temp16_2 A ) 
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
                  IF utils.object_id('TempDB..tt_temp_220') IS NOT NULL THEN
                   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp20_2 ';
                  END IF;
                  DELETE FROM tt_temp20_2;
                  UTILS.IDENTITY_RESET('tt_temp20_2');

                  INSERT INTO tt_temp20_2 ( 
                  	SELECT SourceSystem ,
                          ACBUSegmentCode ,
                          ACBUSegmentDescription ,
                          AuthorisationStatus ,
                          EffectiveFromTimeKey ,
                          EffectiveToTimeKey ,
                          CreatedBy ,
                          DateCreated ,
                          ModifyBy ,
                          DateModified ,
                          ApprovedBy ,
                          DateApproved ,
                          D2Ktimestamp ,
                          Remarks ,
                          ACBUSegmentEntityID 
                  	  FROM ( SELECT
                            --E.CustomerACID,
                             --E.CustomerID,
                             --E.CustomerName,
                             --E.DerivativeRefNo,
                             --E.Duedate,
                             --E.DueAmt,
                             --E.OsAmt,
                             --E.POS,
                             ---------------------------------
                             SourceSystem ,
                             ACBUSegmentCode ,
                             ACBUSegmentDescription ,
                             AuthorisationStatus ,
                             EffectiveFromTimeKey ,
                             EffectiveToTimeKey ,
                             CreatedBy ,
                             DateCreated ,
                             ModifyBy ,
                             DateModified ,
                             ApprovedBy ,
                             DateApproved ,
                             D2Ktimestamp ,
                             Remarks ,
                             ACBUSegmentEntityID 
                            FROM ACBUSegment_Mod A
                             WHERE  A.EffectiveFromTimeKey <= v_TimeKey
                                      AND A.EffectiveToTimeKey >= v_TimeKey
                                      AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )

                                      AND A.EntityKey IN ( SELECT MAX(EntityKey)  
                                                           FROM ACBUSegment_Mod 
                                                            WHERE  EffectiveFromTimeKey <= v_TimeKey
                                                                     AND EffectiveToTimeKey >= v_TimeKey
                                                                     AND AuthorisationStatus IN ( '1A' )

                                                             GROUP BY EntityKey )
                           ) A
                  	  GROUP
                  	--A.CustomerACID,
                  	 --A.CustomerID,
                  	 --A.CustomerName,
                  	 --A.DerivativeRefNo,
                  	 --A.Duedate,
                  	 --A.DueAmt,
                  	 --A.OsAmt,
                  	 --A.POS,
                  	 ---------------------------------
                  	 BY SourceSystem,ACBUSegmentCode,ACBUSegmentDescription,AuthorisationStatus,EffectiveFromTimeKey,EffectiveToTimeKey,CreatedBy,DateCreated,ModifyBy,DateModified,ApprovedBy,DateApproved,D2Ktimestamp,Remarks,ACBUSegmentEntityID );
                  OPEN  v_cursor FOR
                     SELECT * 
                       FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY EntityKey  ) RowNumber  ,
                                     COUNT(*) OVER ( ) TotalCount  ,
                                     'AccountBusinessSegmentMaster' TableName  ,
                                     * 
                              FROM ( SELECT * 
                                     FROM tt_temp20_2 A ) 
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

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACBUSEGMENTSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
